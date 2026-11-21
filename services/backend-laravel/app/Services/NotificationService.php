<?php

namespace App\Services;

use App\Domain\MessagingConsentConversationLiveGateEvaluator as MC;
use App\Domain\ProductConnectionStateTransitionEvaluator as CN;
use App\Models\AppNotificationItem;
use App\Models\ChatMessage;
use App\Models\Conversation;
use App\Models\RtcSession;
use App\Models\StatusPost;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Throwable;

class NotificationService
{
    public const MESSAGE_TITLE = '有一条新消息';

    public const MESSAGE_BODY = '请打开会话查看，读取前会验证当前权限。';

    public const UNAVAILABLE_TITLE = '通知已不可用';

    private function isPrivateMessage(string $kind, array $payload): bool
    {
        return $kind === 'message' || ($payload['source'] ?? '') === 'message'
            || ($payload['route_name'] ?? '') === 'chat_room' || array_key_exists('message_id', $payload);
    }

    public function usesProposalAuthority(AppNotificationItem $notice): bool
    {
        return in_array($notice->kind, ['matching_round', 'match_decision'], true);
    }

    private function roundLocator(AppNotificationItem $notice): ?array
    {
        return preg_match('/^round:([1-9][0-9]*):run:([1-9][0-9]*):revealed$/D', $notice->source_event_key ?? '', $parts)
            ? ['round_id' => (int) $parts[1], 'run_id' => (int) $parts[2]] : null;
    }

    private function proposalForNotice(AppNotificationItem $notice): ?object
    {
        $owner = (int) $notice->user_id;
        $query = DB::table('match_proposals')->where(fn ($pair) => $pair->where('user_a', $owner)->orWhere('user_b', $owner));
        if ($notice->kind === 'matching_round') {
            $locator = $this->roundLocator($notice);
            return $locator ? $query->where($locator)->first() : null;
        }
        return $query->where('id', $notice->payload['proposal_id'] ?? '')->first();
    }

    /** Discover immutable participants before transport takes account locks. */
    public function businessParticipants(AppNotificationItem $notice): array
    {
        $pair = null;
        if ($this->usesProposalAuthority($notice)) {
            $pair = $this->proposalForNotice($notice);
        } elseif (in_array($notice->kind, ['consent_connection', 'consent_message'], true)) {
            $pair = DB::table('product_connections')->find($notice->payload['connection_id'] ?? 0);
        } elseif ($notice->kind === 'social_request') {
            $request = DB::table('social_requests')->find($notice->payload['social_request_id'] ?? 0);
            if ($request && (int) $request->recipient_id === (int) $notice->user_id) {
                return [(int) $request->sender_id, (int) $request->recipient_id];
            }
        }
        if (! $pair || ! in_array((int) $notice->user_id, [(int) $pair->user_a, (int) $pair->user_b], true)) {
            return [];
        }
        return [(int) $pair->user_a, (int) $pair->user_b];
    }

    /** Never serialize legacy message text, names or caller-supplied navigation. */
    public function presentationForUser(AppNotificationItem $notification, int $viewerId): array
    {
        if ((int) $notification->user_id !== $viewerId
            || ($notification->expires_at && $notification->expires_at->lessThanOrEqualTo(now('UTC')))
            || ! app(NotificationDeliveryService::class)->categoryEnabled($viewerId, (string) $notification->kind)) {
            return ['title' => '通知已不可用', 'body' => '', 'payload' => [], 'available' => false];
        }
        $payload = (array) ($notification->payload ?? []);
        if (in_array($notification->kind,['platform_event','safety_case'],true)) {
            try {
                if ((int)$notification->user_id !== $viewerId) throw new \RuntimeException('unavailable');
                $kind=$notification->kind;
                if ($kind==='platform_event') app(PlatformEventService::class)->notificationTarget($viewerId,(string)($payload['platform_event_id']??''));
                else app(SafetyCaseService::class)->owner($viewerId,(string)($payload['safety_case_id']??''));
                $key=$kind==='platform_event'?'platform_event_id':'safety_case_id';
                return ['title'=>'本人状态已更新','body'=>'请查看当前有权状态','payload'=>[$key=>$payload[$key]]];
            } catch (Throwable) { return ['title'=>'通知已不可用','body'=>'','payload'=>[]]; }
        }
        if ($notification->kind === 'buddy') {
            try {
                $a = app(BuddyService::class)->show($viewerId, (string) ($payload['buddy_activity_id'] ?? ''));
                return ['title' => '搭子状态有更新', 'body' => '请在应用中查看当前有权状态',
                    'payload' => ['buddy_activity_id' => $a['id']]];
            } catch (Throwable) {}
            return ['title'=>'通知已不可用','body'=>'','payload'=>[]];
        }
        if (in_array($notification->kind, ['status_like', 'status_comment'], true)) {
            $actor = (int) ($payload['actor_user_id'] ?? 0);
            $postId = (int) ($payload['status_post_id'] ?? 0);
            $commentId = (string) ($payload['status_comment_id'] ?? '');
            $comments = app(StatusCommentAudience::class);
            $authors = $commentId !== '' ? $comments->commentAuthors($postId, $commentId) : [];
            try {
                $safe = $actor ? app(PostAudience::class)->run($viewerId, $postId, function (StatusPost $post) use ($viewerId, $actor, $commentId, $notification, $comments, $payload) {
                    $posts = app(PostAudience::class);
                    if ((int) $post->author_user_id !== $viewerId || $post->audience === PostAudience::SELF
                        || ! $posts->allowedLocked($post, $actor)) {
                        return null;
                    }
                    if ($notification->kind === 'status_comment') {
                        $comment = DB::table('status_post_comments')->where('id', $commentId)->where('status_post_id', $post->id)
                            ->where('author_id', $actor)->lockForUpdate()->first();
                        if (! $comment || ! $comments->displayed($comment) || $comments->presentation($post, $comment, $viewerId) === null) {
                            return null;
                        }
                    } else {
                        // Legacy likes were delivered under the friends grant.
                        $publicWhenLiked = ($payload['audience_basis'] ?? null) === PostAudience::PUBLIC_AUTHENTICATED;
                        if ((! $publicWhenLiked && ! app(SocialPolicy::class)->friendship($viewerId, $actor))
                            || ! DB::table('status_post_likes')->where('status_post_id', $post->id)
                                ->where('user_id', $actor)->lockForUpdate()->exists()) {
                            return null;
                        }
                    }

                    return ['title' => '动态有新互动', 'body' => '请在当前权限允许时查看',
                        'payload' => ['status_post_id' => $post->id]];
                }, [$actor, ...$authors], true) : null;
                if ($safe !== null) {
                    return $safe;
                }
            } catch (Throwable) {
            }

            return ['title' => '通知已不可用', 'body' => '', 'payload' => [], 'available' => false];
        }
        if ($notification->kind === 'social_request') {
            $hint = DB::table('social_requests')->find((int) ($payload['social_request_id'] ?? 0));
            if ($hint && (int) $hint->recipient_id === $viewerId) {
                try {
                    return DB::transaction(function () use ($hint, $viewerId) {
                        app(JourneyStore::class)->users([$viewerId, (int) $hint->sender_id]);
                        $row = DB::table('social_requests')->where('id', $hint->id)->lockForUpdate()->first();
                        abort_unless($row && $row->sender_id === $hint->sender_id && (int) $row->recipient_id === $viewerId
                            && $row->state === 'PENDING' && $row->expires_at
                            && Carbon::parse($row->expires_at, 'UTC')->gt(now('UTC')), 404);
                        return ['title' => '有一条新的联系请求', 'body' => '请在关系请求中心查看',
                            'payload' => ['social_request_id' => $row->id, 'route_name' => 'social_baseline'],
                            'todo' => ['kind' => 'social_request', 'due_at' => Carbon::parse($row->expires_at, 'UTC')->toISOString()]];
                    }, 3);
                } catch (Throwable) {
                }
            }
            return ['title' => self::UNAVAILABLE_TITLE, 'body' => '', 'payload' => [], 'available' => false];
        }
        if ($notification->kind === 'consent_connection' || $notification->kind === 'consent_message') {
            try {
                $cn = DB::table('product_connections')->where('id', $payload['connection_id'] ?? 0)->first();
                if (! $cn || ! in_array($viewerId, [(int) $cn->user_a, (int) $cn->user_b], true)) throw new \RuntimeException;
                $peer = (int) ($cn->user_a == $viewerId ? $cn->user_b : $cn->user_a);
                return DB::transaction(function () use ($notification, $payload, $cn, $viewerId, $peer) {
                    app(JourneyStore::class)->users([$viewerId, $peer]);
                    $current = app(LiveConsentService::class)->current($viewerId, $peer);
                    abort_unless((int) ($current['connection']['id'] ?? 0) === (int) $cn->id, 404);
                    $connection = $notification->kind === 'consent_connection';
                    $kind = $connection ? 'connection' : 'consent';
                    $pending = $connection ? CN::STATE_PENDING : MC::STATE_PENDING;
                    $state = $current[$connection ? 'connection' : 'consent'];
                    $eventId = preg_match('/^consent-event:([1-9][0-9]*)$/D', $notification->source_event_key ?? '', $source)
                        ? (int) $source[1] : 0;
                    $event = DB::table('live_consent_events')->where('connection_id', $cn->id)
                        ->where('kind', $kind)->where('actor_id', $peer)->find($eventId);
                    abort_unless($event, 404);
                    $result = ['title' => '连接或消息同意有更新', 'body' => '请查看当前状态',
                        'payload' => ['route_name' => 'connection_current', 'route_args' => ['peer_id' => $peer]]];
                    if ($event?->to_state === $pending) {
                        abort_unless($state['state'] === $pending
                            && $state['revision'] === (int) $event->revision
                            && (int) $state['requester_id'] === $peer
                            && ($connection || ($current['connection']['state'] === CN::STATE_ACTIVE
                                && (isset($payload['request_consent_id'])
                                    ? (int) $state['id'] === (int) $payload['request_consent_id']
                                    : $state['generation'] === 1))), 404);
                        $result['todo'] = ['kind' => $connection ? 'connection_response' : 'consent_response', 'due_at' => null];
                    }
                    return $result;
                }, 3);
            } catch (Throwable) { return ['title' => '通知已不可用', 'body' => '', 'payload' => [], 'available' => false]; }
        }
        if ($notification->kind === 'showcase_review') {
            $row = DB::table('profile_showcase_submissions')->where('id', $payload['submission_id'] ?? 0)->where('user_id', $viewerId)->first();
            return $row ? ['title' => '本人资料审核有更新', 'body' => '请查看当前审核状态',
                'payload' => ['route_name' => 'showcase_current', 'route_args' => []]]
                : ['title' => '通知已不可用', 'body' => '', 'payload' => [], 'available' => false];
        }
        if ($this->usesProposalAuthority($notification)) {
            try {
                $proposal = $this->proposalForNotice($notification);
                $context = $proposal
                    ? app(SlowDatingService::class)->notificationContext($viewerId, (string) $proposal->id) : null;
                $todo = $context['todo'] ?? null;
                if ($todo && $notification->kind === 'matching_round') {
                    return ['title' => '有一项匹配提案待回应', 'body' => '请查看本人当前进程',
                        'payload' => ['route_name' => 'journey_task', 'route_args' => ['proposal_id' => (string) $proposal->id]],
                        'todo' => $todo];
                }
                if ($context && $notification->kind === 'match_decision') {
                    return ['title' => '匹配进程有更新', 'body' => '请查看本人当前进程',
                        'payload' => ['route_name' => 'journey_task']];
                }
                $round = $notification->kind === 'matching_round' ? $this->roundLocator($notification) : null;
                if (! $proposal && $round && DB::table('dating_round_user_states')
                    ->where('round_id', $round['round_id'])->where('user_id', $viewerId)
                    ->where('state', 'no_candidate')->whereNull('dating_match_id')
                    ->whereExists(fn ($query) => $query->selectRaw('1')->from('dating_rounds')
                        ->where('id', $round['round_id'])->where('active_run_id', $round['run_id'])
                        ->whereIn('state', ['revealed', 'no_candidate']))->exists()) {
                    return ['title' => '匹配轮次结果已发布', 'body' => '请查看本人当前进程',
                        'payload' => ['route_name' => 'journey_task']];
                }
            } catch (Throwable) {
            }
            return ['title' => self::UNAVAILABLE_TITLE, 'body' => '', 'payload' => [], 'available' => false];
        }
        if (str_starts_with((string) $notification->kind, 'rtc_call_')) {
            $safe = ['title' => '通话通知', 'body' => '请打开应用查看当前通话状态', 'payload' => [], 'available' => false];
            try {
                $call = RtcSession::find((int) ($payload['route_args']['call_id'] ?? 0));
                if ($call && app(RtcAuthorityService::class)->authorized($call, $viewerId)) {
                    $active = in_array($call->status, ['calling', 'ringing', 'connecting', 'in_call'], true);
                    // Old invite locators resolve to a read-only terminal result, never Accept.
                    $safe['available'] = true;
                    $safe['payload'] = ['route_name' => $active ? 'rtc_call' : 'rtc_call_result',
                        'route_args' => ['call_id' => $call->id, 'mode' => $call->mode]];
                }
            } catch (Throwable) { }
            return $safe;
        }

        if (($payload['actor_user_id'] ?? null) && ! app(SocialPolicy::class)->pairAllowed($viewerId, (int) $payload['actor_user_id'])) {
            return ['title' => '通知已不可用', 'body' => '', 'payload' => []];
        }
        if (array_key_exists('status_post_id', $payload) || array_key_exists('status_comment_id', $payload)
            || ($payload['route_name'] ?? '') === 'status_author') {
            // Other old notification shapes cannot safely establish content authority.
            return ['title' => '通知已不可用', 'body' => '', 'payload' => [], 'available' => false];
        }
        if (! $this->isPrivateMessage((string) $notification->kind, $payload)) {
            return ['title' => $notification->title, 'body' => $notification->body ?? '', 'payload' => $payload];
        }
        $safe = ['title' => self::MESSAGE_TITLE, 'body' => self::MESSAGE_BODY, 'payload' => [], 'available' => false];
        $messageId = filter_var($payload['message_id'] ?? null, FILTER_VALIDATE_INT, ['options' => ['min_range' => 1]]);
        $authority = app(LiveConsentService::class);
        if ((int) $notification->user_id !== $viewerId || ! $messageId || ! $authority->availableForActor($viewerId)) {
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
        ?string $sourceEventKey = null,
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
        // Current communication events use the explicit durable lifecycle key.
        // Older unrelated producers keep their existing compatibility semantics.
        if ($sourceEventKey === null) {
            $existing = AppNotificationItem::where('user_id', $userId)->where('kind', $normalizedKind)
                ->where('title', $normalizedTitle)->where('body', $normalizedBody)
                ->whereRaw('payload = ?', [$this->payloadSignature($payload)])
                ->where('created_at', '>=', now()->subMinutes(5))->first();
            if ($existing) return $existing;
            return AppNotificationItem::create(['user_id' => $userId, 'kind' => $normalizedKind,
                'title' => $normalizedTitle, 'body' => $normalizedBody, 'payload' => $payload,
                'read_at' => null, 'expires_at' => $expiresAt]);
        }
        return AppNotificationItem::query()->firstOrCreate(
            ['user_id' => $userId, 'source_event_key' => $sourceEventKey],
            ['kind' => $normalizedKind, 'title' => $normalizedTitle, 'body' => $normalizedBody,
                'payload' => $payload, 'read_at' => null, 'expires_at' => $expiresAt],
        );
    }

    /**
     * @return Collection<int, AppNotificationItem>
     */
    public function listForUser(int $userId, int $limit = 50, ?int $beforeId = null): Collection
    {
        return $this->pageForUser($userId, $limit, $beforeId)['items'];
    }

    /** @return array{items: Collection<int, AppNotificationItem>, has_more: bool, next_before_id: ?int} */
    public function pageForUser(int $userId, int $limit = 50, ?int $beforeId = null, string $channel = 'current'): array
    {
        $limit = max(1, min(100, $limit));
        $scanLimit = 100;
        $query = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->when($channel !== 'history', fn ($q) => $q
                ->where(fn ($expiry) => $expiry->whereNull('expires_at')->orWhere('expires_at', '>', now('UTC'))))
            ->when($beforeId !== null, fn ($q) => $q->where('id', '<', $beforeId));
        $candidates = $query->orderByDesc('id')->limit($scanLimit + 1)->get();
        $delivery = app(NotificationDeliveryService::class);
        $categories = $delivery->preferences($userId)['categories'];
        $items = new Collection;
        $scanned = 0;
        $cursor = null;
        // Bound dynamic permission checks. The raw cursor also advances over
        // unavailable notices so the next page can still reach older reminders.
        foreach ($candidates->take($scanLimit) as $notification) {
            $scanned++;
            $cursor = (int) $notification->id;
            if (! $categories[$delivery->category((string) $notification->kind)]) {
                continue;
            }
            $presentation = $this->presentationForUser($notification, $userId);
            $available = $this->isAvailable($presentation);
            if ($channel === 'history' ? $available : ! $available) {
                continue;
            }
            if ($channel === 'todo' && ! isset($presentation['todo'])) {
                continue;
            }
            $items->push($notification);
            if ($items->count() >= $limit) {
                break;
            }
        }

        return ['items' => $items, 'has_more' => $candidates->count() > $scanned, 'next_before_id' => $cursor];
    }

    public function isAvailable(array $presentation): bool
    {
        return ($presentation['available'] ?? true) && $presentation['title'] !== self::UNAVAILABLE_TITLE;
    }

    public function unreadCount(int $userId): int
    {
        $count = 0;
        foreach (AppNotificationItem::where('user_id', $userId)->whereNull('read_at')->cursor() as $n) {
            if (! app(NotificationDeliveryService::class)->categoryEnabled($userId, (string) $n->kind)) {
                continue;
            }
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

        AppNotificationItem::whereKey($notificationId)->where('user_id', $userId)
            ->whereNull('read_at')->update(['read_at' => now()]);

        return $notification->refresh();
    }

    public function markAllRead(int $userId): int
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }
}
