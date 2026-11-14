<?php

namespace App\Services;

use App\Models\SupportFeedback;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Support\Facades\DB;

final class SupportFeedbackService
{
    public const CATEGORIES = ['match_recommendation', 'buddy_experience', 'chat_experience',
        'profile_data', 'astro_display', 'ziwei_flying_star_oracle', 'bug_report', 'other_suggestion'];

    public const SOURCES = ['settings', 'version_center', 'profile', 'match', 'buddy', 'astro', 'ziwei', 'feedback'];

    public const STATUSES = ['OPEN', 'IN_REVIEW', 'RESOLVED', 'CLOSED'];

    public function submit(User $actor, array $data): array
    {
        return DB::transaction(function () use ($actor, $data) {
            $owner = User::whereKey($actor->id)->lockForUpdate()->firstOrFail();
            abort_if($owner->disabled, 403, 'ACCOUNT_UNAVAILABLE');
            app(DeviceSessions::class)->assertCurrentCredential($actor);
            $hash = hash('sha256', json_encode([$data['source'], $data['category'], $data['content']], JSON_THROW_ON_ERROR));
            $existing = SupportFeedback::where('user_id', $owner->id)->where('request_key', $data['request_key'])->first();
            if ($existing) {
                abort_unless(hash_equals($existing->request_hash, $hash), 409, 'FEEDBACK_KEY_PAYLOAD_CONFLICT');

                return [$existing, false];
            }
            $feedback = SupportFeedback::create([
                'user_id' => $owner->id, 'request_key' => $data['request_key'], 'request_hash' => $hash,
                'source' => $data['source'], 'category' => $data['category'], 'content' => $data['content'],
                'status' => 'OPEN', 'revision' => 1,
            ]);

            return [$feedback, true];
        });
    }

    public function review(User $actor, int $id, array $data): void
    {
        DB::transaction(function () use ($actor, $id, $data) {
            $admin = User::whereKey($actor->id)->lockForUpdate()->firstOrFail();
            abort_unless(app(AdminAccess::class)->allows($admin), 403);
            $feedback = SupportFeedback::whereKey($id)->lockForUpdate()->firstOrFail();
            $data['expected_revision'] = (int) $data['expected_revision'];
            $hash = hash('sha256', json_encode([$data['expected_revision'], $data['category'], $data['status'],
                $data['public_reply'] ?? null, $data['internal_note'] ?? null], JSON_THROW_ON_ERROR));
            $prior = DB::table('support_feedback_updates')->where('feedback_id', $id)
                ->where('actor_user_id', $admin->id)->where('request_key', $data['request_key'])->first();
            if ($prior) {
                abort_unless(hash_equals($prior->request_hash, $hash), 409, 'FEEDBACK_KEY_PAYLOAD_CONFLICT');

                return;
            }
            abort_unless($feedback->revision === $data['expected_revision'], 409, 'FEEDBACK_REVISION_CONFLICT');
            DB::table('support_feedback_updates')->insert([
                'feedback_id' => $id, 'actor_user_id' => $admin->id,
                'request_key' => $data['request_key'], 'request_hash' => $hash,
                'category' => $data['category'], 'previous_status' => $feedback->status,
                'status' => $data['status'], 'public_reply' => $data['public_reply'] ?? null,
                'internal_note' => $data['internal_note'] ?? null,
                'revision' => $feedback->revision + 1, 'created_at' => now(),
            ]);
            $feedback->forceFill(['category' => $data['category'], 'status' => $data['status'],
                'public_reply' => $data['public_reply'] ?? null, 'revision' => $feedback->revision + 1])->save();
        });
    }
}
