<?php

namespace App\Services;

use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Support\Facades\DB;

final class ConversationVisibility
{
    public function visible(int $actor, int $conversation, int $peer): bool
    {
        $hidden = DB::table('conversation_hidden_views')->where('user_id', $actor)->where('conversation_id', $conversation)->first();
        if (! $hidden) {
            return true;
        }

        return app(ConversationCapabilityService::class)->canSend($actor, $peer)
            && ChatMessage::where('room_id', app(ConversationDomainService::class)->roomKey($actor, $peer))->where('id', '>', $hidden->hidden_through_id)->where('receiver_id', $actor)->exists();
    }

    public function set(int $actor, int $id, bool $hidden): void
    {
        DB::transaction(function () use ($actor, $id, $hidden) {
            User::whereKey($actor)->lockForUpdate()->firstOrFail();
            $c = app(ConversationDomainService::class)->findConversationForParticipant($id, $actor);
            abort_unless($c, 404);
            $peer = app(ConversationDomainService::class)->peerUserId($c, $actor);
            abort_unless($peer && app(ConversationCapabilityService::class)->canRead($actor, $peer), 404);
            if (! $hidden) {
                DB::table('conversation_hidden_views')->where('user_id', $actor)->where('conversation_id', $id)->delete();

                return;
            }
            $through = (int) ChatMessage::where('room_id', $c->room_key)->max('id');
            DB::table('conversation_hidden_views')->updateOrInsert(['user_id' => $actor, 'conversation_id' => $id], ['hidden_through_id' => $through, 'created_at' => now(), 'updated_at' => now()]);
        });
    }
}
