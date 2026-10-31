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

/** Locate outside the RR transaction; authorize only after coordination locks. */
final class DenyUnverifiedMessagingLiveAccess
{
    public function handle(Request $request, Closure $next): Response
    {
        $service = app(LiveConsentService::class);
        $deny = fn () => response()->json(['message' => 'conversation unavailable'], 404);
        if (! $service->enabled() || ! $request->user()) return $deny();
        $actor = (int) $request->user()->id;
        $peer = (int) ($request->route('peerUserId') ?? 0);
        $domain = app(ConversationDomainService::class);
        $inventory = $request->isMethod('get') && $request->is('api/v1/conversations');
        if ($request->is('api/v1/messages')) $peer = (int) $request->input($request->isMethod('post') ? 'receiver_id' : 'peer_id', 0);
        if ($request->is('api/v1/conversations') && $request->isMethod('post')) $peer = (int) $request->input('peer_user_id', 0);
        if ($request->route('conversationId')) {
            $c = $domain->findConversationForParticipant((int) $request->route('conversationId'), $actor);
            $peer = $c ? (int) $domain->peerUserId($c, $actor) : 0;
        }
        if ($request->route('messageId')) {
            $message = ChatMessage::where('receiver_id', $actor)->find((int) $request->route('messageId'));
            $peer = $message ? (int) $message->sender_id : 0;
        }
        $peers = $inventory ? $domain->listForUser($request->user())->pluck('peer_user_id')->map(fn($id)=>(int)$id)->filter(fn($id)=>$id>0)->unique()->all() : [$peer];
        $participants = array_values(array_unique(array_filter([$actor, ...$peers], fn($id)=>$id>0)));
        sort($participants);
        return DB::transaction(function () use ($request, $next, $service, $deny, $actor, $peer, $domain, $inventory, $peers, $participants) {
            $users = User::whereIn('id', $participants)->orderBy('id')->lockForUpdate()->get()->keyBy('id');
            if (! $users->has($actor)) return $deny();
            $request->user()->setRawAttributes($users->get($actor)->getAttributes(), true);
            // Logout may have committed while this request waited for user locks.
            return app(EnsureAccountActive::class)->handle($request, function () use ($request, $next, $service, $deny, $actor, $peer, $domain, $inventory, $peers) {
                if ($inventory) {
                    $items = $domain->listForUser($request->user())->filter(fn($item)=>in_array((int)$item['peer_user_id'], $peers, true));
                    $items = $items->filter(fn($item)=>$service->gates($actor, (int)$item['peer_user_id'])['live_read_allowed'] ?? false)->values();
                    $request->attributes->set('v1007_conversation_items', $items);
                    return $items->isNotEmpty() ? $next($request) : $deny();
                }
                if (! $service->connection($actor, $peer, true)) return $deny();
                $gates = $service->gates($actor, $peer);
                $purpose = $request->isMethod('get') || $request->route('messageId') ? 'live_read_allowed' : 'live_send_allowed';
                return ($gates[$purpose] ?? false) ? $next($request) : $deny();
            });
        });
    }
}
