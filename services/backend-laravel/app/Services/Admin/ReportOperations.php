<?php

namespace App\Services\Admin;

use App\Models\ModerationReport;
use App\Models\StatusPost;
use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\CurrentQuestionnaire;
use Illuminate\Support\Facades\DB;

final class ReportOperations
{
    public function act(User $actor, int $id, array $data): void
    {
        DB::transaction(function () use ($actor, $id, $data) {
            app(CurrentQuestionnaire::class)->lock();
            abort_unless(app(AdminAccess::class)->allows($actor), 403);
            $r = ModerationReport::whereKey($id)->lockForUpdate()->firstOrFail();
            abort_if($r->category === 'platform_event', 422, 'use the versioned Safety case workspace');
            $version = (int) $data['expected_revision'];
            abort_unless((int) $r->admin_revision === $version, 409, 'stale report revision');
            $s = app(UserGovernance::class);
            $target = $s->target($actor, (int) $r->target_user_id);
            $action = $data['action'];
            $reason = $data['reason'];
            $before = ['status' => $r->status, 'revision' => $version];
            if (in_array($action, ['restrict', 'banned'], true)) {
                $s->punish($actor, $target->id, $action, $reason, (int) $data['expected_user_revision'], $r->id);
            } elseif ($action === 'restore') {
                $s->restore($actor, $target->id, (int) $data['sanction_id'], $reason, (int) $data['expected_user_revision'], $r->id);
            } elseif ($action === 'remove_post') {
                $post = StatusPost::whereKey($r->target_status_post_id)->lockForUpdate()->first();
                abort_unless($post && (int) $post->author_user_id === (int) $r->target_user_id && in_array($post->visibility, ['public', 'square'], true), 422, 'report public content required');
                $post->is_deleted = true;
                $post->deleted_by_user_id = $actor->id;
                $post->deleted_at = now();
                $post->save();
            } else {
                abort_unless(in_array($action, ['triage', 'investigate', 'dismiss', 'close'], true), 422);
            }
            $r->status = match ($action) {
                'triage' => 'triaged','investigate' => 'investigating','dismiss' => 'dismissed','close','restore' => 'closed',default => 'action_taken'
            };
            $r->admin_revision = $version + 1;
            $r->admin_note = $reason;
            $r->resolved_by_user_id = $actor->id;
            $r->resolved_at = now();
            $r->save();
            OperationAudit::record($actor->id, 'report.'.$action, 'report', $id, $reason, $version, $before, ['status' => $r->status, 'revision' => $version + 1]);
        });
    }
}
