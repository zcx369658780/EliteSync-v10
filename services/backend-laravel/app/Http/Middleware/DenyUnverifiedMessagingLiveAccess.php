<?php

namespace App\Http\Middleware;

use App\Models\ChatMessage;
use App\Models\User;
use App\Services\ConversationDomainService;
use App\Services\LiveConsentService;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

/** Default fail closed. Only the isolated V1007 local writer can establish current authority. */
final class DenyUnverifiedMessagingLiveAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        $service = app(LiveConsentService::class);
        $deny = fn () => response()->json(['message' => 'conversation unavailable'], 404);
        if (! $service->enabled() || ! $request->user()) {
            return $deny();
        }

        return DB::transaction(function () use ($request, $next, $service, $deny) {
            $actor = (int) $request->user()->id;
            $peer = (int) ($request->route('peerUserId') ?? 0);
            if ($request->is('api/v1/messages')) {
                $peer = (int) $request->input($request->isMethod('post') ? 'receiver_id' : 'peer_id', 0);
            }
            if ($request->is('api/v1/conversations') && $request->isMethod('post')) {
                $peer = (int) $request->input('peer_user_id', 0);
            }
            if ($request->route('conversationId')) {
                $conversation = app(ConversationDomainService::class)->findConversationForParticipant((int) $request->route('conversationId'), $actor);
                $peer = $conversation ? (int) app(ConversationDomainService::class)->peerUserId($conversation, $actor) : 0;
            }
            if ($request->route('messageId')) {
                $message = ChatMessage::where('receiver_id', $actor)->find((int) $request->route('messageId'));
                $peer = $message ? (int) $message->sender_id : 0;
            }
            if ($request->isMethod('get') && $request->is('api/v1/conversations')) {
                $items = app(ConversationDomainService::class)->listForUser($request->user());
                $peers = $items->pluck('peer_user_id')->filter(fn ($id) => is_int($id) && $id > 0)->unique();
                $participants = $peers->push($actor)->unique()->sort()->values()->all();
                User::whereIn('id', $participants)->orderBy('id')->lockForUpdate()->get();
                // Reuse this exact trusted inventory; do not discover new peers
                // after the transaction has already acquired its user locks.
                $request->attributes->set('v1007_conversation_items', $items);
                $eligible = false;
                foreach ($peers as $p) {
                    if ($p !== $actor && ($service->gates($actor, $p)['live_read_allowed'] ?? false)) {
                        $eligible = true;
                        break;
                    }
                }

                return $eligible ? $next($request) : $deny();
            }
            if (! $service->match($actor, $peer, true)) {
                return $deny();
            }
            $gates = $service->gates($actor, $peer);
            $purpose = $request->isMethod('get') || $request->route('messageId') ? 'live_read_allowed' : 'live_send_allowed';

            return ($gates[$purpose] ?? false) ? $next($request) : $deny();
        });
    }
}
