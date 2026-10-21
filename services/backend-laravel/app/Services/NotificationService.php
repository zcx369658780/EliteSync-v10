<?php

namespace App\Services;

use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\Conversation;
use App\Models\RtcSession;
use App\Models\StatusPost;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use Throwable;

class NotificationService
{
    public const MESSAGE_TITLE = '有一条新消息';

    public const MESSAGE_BODY = '请打开会话查看，读取前会验证当前权限。';

    private function isPrivateMessage(string $kind, array $payload): bool
    {
        return $kind === 'message' || ($payload['source'] ?? '') === 'message'
            || ($payload['route_name'] ?? '') === 'chat_room' || array_key_exists('message_id', $payload);
    }

    /** Never serialize legacy message text, names or caller-supplied navigation. */
    public function presentationForUser(AppNotificationItem $notification, int $viewerId): array
    {
        $payload = (array) ($notification->payload ?? []);
        if (in_array($notification->kind,['platform_event','safety_case'],true)) {
            try {
                if ((int)$notification->user_id !== $viewerId) throw new \RuntimeException('unavailable');
                $kind=$notification->kind;
                if ($kind==='platform_event') app(PlatformEventService::class)->show($viewerId,(string)($payload['platform_event_id']??''));
                else app(SafetyCaseService::class)->owner($viewerId,(string)($payload['safety_case_id']??''));
                $key=$kind==='platform_event'?'platform_event_id':'safety_case_id';
                return ['title'=>'本人状态已更新','body'=>'请查看当前有权状态','payload'=>[$key=>$payload[$key]]];
            } catch (Throwable) { return ['title'=>'通知已不可用','body'=>'','payload'=>[]]; }
        }
        if ($notification->kind === 'buddy') {
            try {$a=app(BuddyService::class)->show($viewerId,(string)($payload['buddy_activity_id']??''));if(($a['subject']??null)!==null&&in_array($a['state'],BuddyService::LIVE,true))return ['title'=>'搭子状态有更新','body'=>'请在应用中查看当前有权状态','payload'=>['buddy_activity_id'=>$a['id']]];}catch(Throwable){}
            return ['title'=>'通知已不可用','body'=>'','payload'=>[]];
        }
        if (in_array($notification->kind,['status_like','status_comment'],true)) {
            $actor=(int)($payload['actor_user_id']??0);$postId=(int)($payload['status_post_id']??0);
            try {$safe=app(PostAudience::class)->run($viewerId,$postId,function($p)use($viewerId,$actor,$payload,$notification){if((int)$p->author_user_id!==$viewerId||$p->audience!=='FRIENDS'||!$actor||!app(SocialPolicy::class)->pairAllowed($viewerId,$actor)||!app(SocialPolicy::class)->friendship($viewerId,$actor))return null;if($notification->kind==='status_comment'){$c=DB::table('status_post_comments')->where('id',$payload['status_comment_id']??'')->where('status_post_id',$p->id)->where('author_id',$actor)->where('state','ACTIVE')->lockForUpdate()->first();if(!$c)return null;}return ['title'=>'好友动态有新互动','body'=>'请在当前权限允许时查看','payload'=>['status_post_id'=>$p->id]];},$actor?[$actor]:[],true);if($safe)return $safe;}catch(Throwable){}
            return ['title'=>'通知已不可用','body'=>'','payload'=>[]];
        }
        if ($notification->kind === 'social_request') {
            $row = DB::table('social_requests')->find((int) ($payload['social_request_id'] ?? 0));
            if (! $row || (int) $row->recipient_id !== $viewerId || $row->state !== 'PENDING' || $row->expires_at <= now() || ! app(SocialPolicy::class)->pairAllowed($viewerId, (int) $row->sender_id)) {
                return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
            }

            return ['title' => '有一条新的联系请求', 'body' => '请在关系请求中心查看', 'payload' => ['social_request_id' => $row->id]];
        }
        if (str_starts_with((string) $notification->kind, 'rtc_call_')) {
            $safe = ['title' => '通话通知', 'body' => '请打开APP查看当前有权通话', 'payload' => [], 'available' => false];
            try {
                $id = (int) ($payload['route_args']['call_id'] ?? 0);
                $call = RtcSession::find($id);
                if ($call && app(RtcAuthorityService::class)->authorized($call, $viewerId) && in_array($call->status, ['calling', 'ringing', 'connecting', 'in_call'], true)) {
                    $safe['available'] = true;
                    $safe['payload'] = ['route_name' => 'rtc_call', 'route_args' => ['call_id' => $call->id, 'mode' => $call->mode]];
                }
            } catch (Throwable) {
            }

            return $safe;
        }

        if ($notification->kind === 'status_like') {
            $post = StatusPost::find((int) ($payload['status_post_id'] ?? 0));
            if (! $post || $post->is_deleted || $post->audience !== 'FRIENDS' || (int) $post->author_user_id !== $viewerId) {
                return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
            }
            $actor = (int) ($payload['actor_user_id'] ?? 0);
            if (! $actor || ! app(SocialPolicy::class)->pairAllowed($viewerId, $actor) || ! app(SocialPolicy::class)->friendship($viewerId, $actor)) {
                return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
            }

            return ['title' => '动态收到赞', 'body' => '请在当前权限允许时查看', 'payload' => ['status_post_id' => $payload['status_post_id'] ?? null]];
        }
        if (($payload['actor_user_id'] ?? null) && ! app(SocialPolicy::class)->pairAllowed($viewerId, (int) $payload['actor_user_id'])) {
            return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
        }
        if (($payload['status_post_id'] ?? null)) {
            $post = StatusPost::find($payload['status_post_id']);
            if (! $post || $post->is_deleted || ! app(SocialPolicy::class)->pairAllowed($viewerId, (int) $post->author_user_id) || ((int) $post->author_user_id !== $viewerId && ($post->audience !== 'FRIENDS' || ! app(SocialPolicy::class)->friendship($viewerId, (int) $post->author_user_id)))) {
                return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
            }
        }
        if (! $this->isPrivateMessage((string) $notification->kind, $payload)) {
            return ['title' => $notification->title, 'body' => $notification->body ?? '', 'payload' => $payload];
        }
        $safe = ['title' => self::MESSAGE_TITLE, 'body' => self::MESSAGE_BODY, 'payload' => [], 'available' => false];
        $messageId = filter_var($payload['message_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        $authority = app(LiveConsentService::class);
        if ((int) $notification->user_id !== $viewerId || ! $messageId || ! $authority->enabled()) {
            return $safe;
        }
        try {
            return DB::transaction(function () use ($messageId, $viewerId, $authority, $safe) {
                $message = ChatMessage::query()->select(['id', 'sender_id', 'receiver_id', 'room_id'])->find($messageId);
                if (! $message || (int) $message->receiver_id !== $viewerId
                    || ! ($authority->gates($viewerId, (int) $message->sender_id)['live_read_allowed'] ?? false)) {
                    return $safe;
                }
                $conversation = Conversation::query()->where('room_key', $message->room_id)->first(['id']);
                if (! $conversation) {
                    return $safe;
                }

                // The immutable message binds receiver, peer and room. The payload cannot grant access.
                return array_replace($safe, ['available' => true, 'payload' => ['source' => 'message', 'route_name' => 'chat_room',
                    'route_args' => ['conversation_id' => (string) $conversation->id]]]);
            });
        } catch (Throwable) {
            return $safe; // Unknown/current-reader failures are not notification access grants.
        }
    }

    private function payloadSignature(array $payload): string
    {
        return json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '{}';
    }

    public function createForUser(
        int $userId,
        string $kind,
        string $title,
        ?string $body = null,
        array $payload = [],
        ?string $expiresAt = null,
    ): AppNotificationItem {
        $normalizedKind = mb_substr(trim($kind), 0, 32);
        $normalizedTitle = mb_substr(trim($title), 0, 120);
        $normalizedBody = $body !== null ? trim($body) : null;
        if ($this->isPrivateMessage($normalizedKind, $payload)) {
            $normalizedTitle = self::MESSAGE_TITLE;
            $normalizedBody = self::MESSAGE_BODY;
            $messageId = filter_var($payload['message_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
            $payload = ['source' => 'message'] + ($messageId ? ['message_id' => $messageId] : []);
        }
        $payloadSignature = $this->payloadSignature($payload);

        $existing = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->where('kind', $normalizedKind)
            ->where('title', $normalizedTitle)
            ->where(function ($query) use ($normalizedBody) {
                if ($normalizedBody === null) {
                    $query->whereNull('body');

                    return;
                }
                $query->where('body', $normalizedBody);
            })
            ->whereRaw('payload = ?', [$payloadSignature])
            ->where('created_at', '>=', now()->subMinutes(5))
            ->first();

        if ($existing) {
            return $existing;
        }

        return AppNotificationItem::query()->create([
            'user_id' => $userId,
            'kind' => $normalizedKind,
            'title' => $normalizedTitle,
            'body' => $normalizedBody,
            'payload' => $payload,
            'read_at' => null,
            'expires_at' => $expiresAt,
        ]);
    }

    /**
     * @return Collection<int, AppNotificationItem>
     */
    public function listForUser(int $userId, int $limit = 50): Collection
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->orderByDesc('id')
            ->limit($limit)
            ->get()->filter(function ($n) use ($userId) {
                $p = $this->presentationForUser($n, $userId);

                return ($p['available'] ?? true) && $p['title'] !== '通知已不可用';
            })->values();
    }

    public function unreadCount(int $userId): int
    {
        $count = 0;
        foreach (AppNotificationItem::where('user_id', $userId)->whereNull('read_at')->cursor() as $n) {
            $p = $this->presentationForUser($n, $userId);
            if (($p['available'] ?? true) && $p['title'] !== '通知已不可用') {
                $count++;
            }
        }

        return $count;
    }

    public function markRead(int $userId, int $notificationId): ?AppNotificationItem
    {
        $notification = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->find($notificationId);

        if (! $notification) {
            return null;
        }

        if ($notification->read_at === null) {
            $notification->forceFill(['read_at' => now()])->save();
        }

        return $notification;
    }

    public function markAllRead(int $userId): int
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }
}
