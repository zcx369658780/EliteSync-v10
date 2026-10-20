<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserRelationshipEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RelationshipController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $items = UserRelationshipEvent::query()
            ->where(function ($query) use ($user) {
                $query->where('actor_user_id', $user->id);
            })
            ->orderByDesc('id')
            ->limit(30)
            ->get()
            ->map(function (UserRelationshipEvent $event) use ($user) {
                return [
                    'id' => $event->id,
                    'event_type' => $event->event_type, 'legacy_untrusted_history' => true,
                    'status' => $event->status,
                    'actor_user_id' => $event->actor_user_id,
                    'subject_user_id' => $event->subject_user_id,
                    'is_actor' => (int) $event->actor_user_id === (int) $user->id,
                    'happened_at' => optional($event->happened_at)->toIso8601String(),
                ];
            });

        return response()->json([
            'ok' => true,
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        // Legacy client-authored events were never trusted friendship, relationship, CN or MC facts.
        return response()->json(['ok' => false, 'code' => 'LEGACY_RELATIONSHIP_WRITER_CLOSED', 'message' => '请使用关系请求中心；此历史事件入口不再写入。'], 410);
    }
}
