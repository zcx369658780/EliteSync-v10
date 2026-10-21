<?php

namespace App\Services;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\RtcSession;
use App\Models\StatusPost;
use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\PersonalAccessToken;

/** Isolated transport boundary. No provider SDK, endpoint, secret or network delivery is configured. */
final class NotificationDeliveryService
{
    public const PROVIDER_STATUS = 'REAL_PUSH_PROVIDER_PENDING';
    public const CATEGORIES = ['message', 'rtc', 'match', 'buddy', 'status', 'platform_event', 'safety_case', 'system'];

    public function preferences(int $userId): array
    {
        $row = DB::table('notification_preferences')->where('user_id', $userId)->first();
        $stored = $row ? json_decode($row->categories, true, flags: JSON_THROW_ON_ERROR) : [];

        return ['categories' => array_replace(array_fill_keys(self::CATEGORIES, true), $stored),
            'silent' => (bool) ($row->silent ?? false), 'provider_status' => self::PROVIDER_STATUS];
    }

    public function updatePreferences(int $userId, array $changes): array
    {
        return DB::transaction(function () use ($userId, $changes) {
            User::whereKey($userId)->lockForUpdate()->firstOrFail();
            $prefs = $this->preferences($userId);
            foreach (($changes['categories'] ?? []) as $category => $enabled) {
                if (in_array($category, self::CATEGORIES, true)) {
                    $prefs['categories'][$category] = (bool) $enabled;
                }
            }
            $prefs['silent'] = array_key_exists('silent', $changes) ? (bool) $changes['silent'] : $prefs['silent'];
            DB::table('notification_preferences')->updateOrInsert(['user_id' => $userId],
                ['categories' => json_encode($prefs['categories'], JSON_THROW_ON_ERROR), 'silent' => $prefs['silent'],
                    'updated_at' => now(), 'created_at' => now()]);

            return $prefs;
        });
    }

    public function category(string $kind): string
    {
        return match (true) {
            $kind === 'message' => 'message',
            str_starts_with($kind, 'rtc_') => 'rtc',
            str_starts_with($kind, 'match') => 'match',
            $kind === 'buddy' => 'buddy',
            str_starts_with($kind, 'status') => 'status',
            $kind === 'platform_event' => 'platform_event',
            $kind === 'safety_case' => 'safety_case',
            default => 'system',
        };
    }

    public function categoryEnabled(int $userId, string $kind): bool
    {
        return $this->preferences($userId)['categories'][$this->category($kind)];
    }

    public function register(User $actor, PersonalAccessToken $token, array $data): array
    {
        abort_unless(app()->environment(['local', 'testing']) && $data['transport'] === 'test_only', 403, 'NOTIFICATION_PROVIDER_NOT_APPROVED');
        if ($data['permission'] !== 'granted') {
            $this->revoke((int) $actor->id, $data['device_id']);
            abort(422, 'NOTIFICATION_PERMISSION_REQUIRED');
        }

        return DB::transaction(function () use ($actor, $token, $data) {
            $user = User::whereKey($actor->id)->lockForUpdate()->firstOrFail();
            abort_if($user->disabled || DB::table('account_closures')->where('user_id', $user->id)->exists(), 401, 'ACCOUNT_UNAVAILABLE');
            $current = PersonalAccessToken::query()->whereKey($token->id)->first();
            abort_unless($current && (int) $current->tokenable_id === (int) $user->id
                && $current->tokenable_type === $user->getMorphClass() && $current->can('*'), 401, 'SESSION_REVOKED');
            $family = DB::table('device_sessions')->where('id', $current->device_session_id)
                ->where('user_id', $user->id)->whereNull('revoked_at')->first();
            abort_unless($family && $family->device_id === $data['device_id'], 422, 'CURRENT_DEVICE_SESSION_REQUIRED');
            abort_if(app(DeviceSessions::class)->onlineDeadline($family)->lessThanOrEqualTo(now('UTC'))
                || ($current->expires_at && $current->expires_at->lessThanOrEqualTo(now('UTC'))), 401, 'ONLINE_LOGIN_EXPIRED');
            $hash = hash('sha256', $data['token']);
            abort_if(DB::table('notification_devices')->where('token_hash', $hash)
                ->where('device_id', '!=', $data['device_id'])->exists(), 422, 'NOTIFICATION_TOKEN_ALREADY_BOUND');
            $old = DB::table('notification_devices')->where('device_id', $data['device_id'])->lockForUpdate()->first();
            $changed = ! $old || $old->token_hash !== $hash || (int) $old->user_id !== (int) $user->id
                || $old->device_session_id !== $family->id || $old->revoked_at;
            DB::table('notification_devices')->updateOrInsert(['device_id' => $data['device_id']],
                ['user_id' => $user->id, 'device_session_id' => $family->id, 'transport' => 'test_only',
                    'token_hash' => $hash, 'generation' => $old ? (int) $old->generation + ($changed ? 1 : 0) : 1,
                    'revoked_at' => null, 'created_at' => $old->created_at ?? now(), 'updated_at' => now()]);

            return ['device_id' => $data['device_id'], 'transport' => 'test_only', 'status' => 'TEST_ONLY',
                'provider_status' => self::PROVIDER_STATUS];
        }, 3);
    }

    public function revoke(int $userId, string $deviceId): array
    {
        DB::transaction(function () use ($userId, $deviceId) {
            User::whereKey($userId)->lockForUpdate()->firstOrFail();
            DB::table('notification_devices')->where('user_id', $userId)->where('device_id', $deviceId)
                ->whereNull('revoked_at')->update(['revoked_at' => now(), 'updated_at' => now()]);
        }, 3);

        return ['device_id' => $deviceId, 'status' => 'REVOKED', 'provider_status' => self::PROVIDER_STATUS];
    }

    /** Qualification is re-evaluated before a deduplicated TEST_ONLY receipt can be returned. */
    public function attempt(AppNotificationItem $notice, string $deviceId): array
    {
        if (! app()->environment(['local', 'testing'])) {
            return $this->suppressed();
        }
        // Discover immutable identities outside the transaction, then coordinate
        // with current-user revocation locks before the first consistent read.
        $original = AppNotificationItem::query()->find($notice->id);
        if (! $original) {
            return $this->suppressed();
        }
        $ids = [(int) $original->user_id];
        $pointer = (array) ($original->payload ?? []);
        if ($original->kind === 'message' && ($pointer['message_id'] ?? null)) {
            $message = ChatMessage::find($pointer['message_id']);
            if ($message) {
                $ids[] = (int) $message->sender_id;
            }
        }
        if ($pointer['actor_user_id'] ?? null) {
            $ids[] = (int) $pointer['actor_user_id'];
        }
        if ($pointer['status_post_id'] ?? null) {
            $post = StatusPost::find($pointer['status_post_id']);
            if ($post) {
                $ids[] = (int) $post->author_user_id;
            }
        }
        if (str_starts_with($original->kind, 'rtc_')) {
            $call = RtcSession::find($pointer['route_args']['call_id'] ?? 0);
            if ($call) {
                $ids[] = (int) $call->initiator_user_id;
                $ids[] = (int) $call->peer_user_id;
            }
        }

        return DB::transaction(function () use ($original, $deviceId, $ids) {
            $users = User::whereIn('id', array_unique($ids))->orderBy('id')->lockForUpdate()->get()->keyBy('id');
            $notice = AppNotificationItem::query()->lockForUpdate()->find($original->id);
            if (! $notice) {
                return $this->suppressed();
            }
            $device = DB::table('notification_devices')->where('device_id', $deviceId)
                ->where('user_id', $notice->user_id)->whereNull('revoked_at')->lockForUpdate()->first();
            $user = $users->get($notice->user_id);
            $family = $device ? DB::table('device_sessions')->where('id', $device->device_session_id)
                ->where('user_id', $notice->user_id)->whereNull('revoked_at')->lockForUpdate()->first() : null;
            $prefs = $this->preferences((int) $notice->user_id);
            if (! $device || $device->transport !== 'test_only' || ! $family || ! $user || $user->disabled
                || DB::table('account_closures')->where('user_id', $notice->user_id)->exists()
                || $prefs['silent'] || ! $prefs['categories'][$this->category($notice->kind)]
                || ($notice->expires_at && $notice->expires_at->lessThanOrEqualTo(now()))) {
                return $this->suppressed();
            }
            try {
                if (app(DeviceSessions::class)->onlineDeadline($family)->lessThanOrEqualTo(now('UTC'))) {
                    return $this->suppressed();
                }
                $presentation = app(NotificationService::class)->presentationForUser($notice, (int) $notice->user_id);
                if (! ($presentation['available'] ?? true) || $presentation['title'] === '通知已不可用') {
                    return $this->suppressed();
                }
            } catch (\Throwable) {
                return $this->suppressed();
            }
            // Only this fixed public envelope crosses the isolated transport boundary.
            $payload = ['notification_id' => (int) $notice->id, 'title' => 'EliteSync', 'body' => '请打开应用查看当前有权通知。'];
            $identity = ['notification_id' => $notice->id, 'device_record_id' => $device->id, 'generation' => $device->generation];
            $exists = DB::table('notification_delivery_attempts')->where($identity)->exists();
            if (! $exists) {
                DB::table('notification_delivery_attempts')->insert($identity + ['status' => 'TEST_ONLY',
                    'payload' => json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR), 'created_at' => now(), 'updated_at' => now()]);
            }

            return ['status' => 'TEST_ONLY', 'payload' => $payload, 'deduplicated' => $exists, 'provider_status' => self::PROVIDER_STATUS];
        }, 3);
    }

    private function suppressed(): array
    {
        return ['status' => 'SUPPRESSED', 'payload' => [], 'provider_status' => self::PROVIDER_STATUS];
    }
}
