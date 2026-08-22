<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ConversationDomainService;
use App\Services\ConversationCapabilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function index(Request $request, ConversationDomainService $service, ConversationCapabilityService $capabilities): JsonResponse
    {
        $actorId = (int) $request->user()->id;
        $items = $service->listForUser($request->user())
            ->filter(fn (array $item) => empty($item['peer_user_id']) || $capabilities->canRead($actorId, (int) $item['peer_user_id']))
            ->map(function (array $item) use ($capabilities, $actorId) {
                if (!empty($item['peer_user_id'])) $item['conversation_capability'] = $capabilities->evaluate($actorId, (int) $item['peer_user_id']);
                return $item;
            });

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'items' => $items->values(),
            'total' => $items->count(),
            'note' => $items->isEmpty() ? '4.0A conversation domain skeleton only' : null,
        ]);
    }

    public function store(Request $request, ConversationDomainService $service, ConversationCapabilityService $capabilities): JsonResponse
    {
        $data = $request->validate([
            'peer_user_id' => ['required', 'integer', 'min:1'],
            'title' => ['nullable', 'string', 'max:120'],
        ]);

        $actorId = (int) $request->user()->id;
        $peerId = (int) $data['peer_user_id'];
        $conversation = $service->findDirectConversation($actorId, $peerId);
        $eligible = $conversation
            ? $capabilities->canRead($actorId, $peerId)
            : $capabilities->canCreate($actorId, $peerId);
        if (!$eligible) {
            return response()->json(['message' => 'conversation unavailable'], 404);
        }

        $entry = $conversation
            ? $service->summarizeConversation($conversation, $actorId)
            : $service->eligibleMatchForPeer($request->user(), $peerId);
        if (!$entry) {
            return response()->json(['message' => 'conversation unavailable'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'conversation' => $entry,
        ]);
    }

    public function show(Request $request, int $conversationId, ConversationDomainService $service, ConversationCapabilityService $capabilities): JsonResponse
    {
        $actorId = (int) $request->user()->id;
        $conversation = $service->findConversationForParticipant($conversationId, $actorId);
        $peerId = $conversation ? $service->peerUserId($conversation, $actorId) : null;

        if (!$conversation || !$peerId || !$capabilities->canRead($actorId, $peerId)) {
            return response()->json(['message' => 'conversation not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'conversation' => $service->summarizeConversation($conversation, $actorId),
        ]);
    }

    public function showPeer(Request $request, int $peerUserId, ConversationDomainService $service, ConversationCapabilityService $capabilities): JsonResponse
    {
        $actorId = (int) $request->user()->id;
        if (!$capabilities->canRead($actorId, $peerUserId)) {
            return response()->json(['message' => 'conversation not found'], 404);
        }

        $conversation = $service->findDirectConversation($actorId, $peerUserId);
        $entry = $conversation
            ? $service->summarizeConversation($conversation, $actorId)
            : $service->eligibleMatchForPeer($request->user(), $peerUserId);

        if (!$entry) {
            return response()->json(['message' => 'conversation not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'conversation' => $entry,
        ]);
    }
}
