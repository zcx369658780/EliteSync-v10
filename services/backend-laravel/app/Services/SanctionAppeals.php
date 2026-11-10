<?php

namespace App\Services;

use App\Models\User;
use App\Services\Accounts\AdminAccess;
use App\Services\Admin\OperationAudit;
use Illuminate\Support\Facades\DB;

final class SanctionAppeals
{
    private function currentUser(int $id): User
    {
        // Recheck a token that could have been revoked while this request waited for the user lock.
        app(JourneyStore::class)->users([$id], true);
        $user = User::whereKey($id)->lockForUpdate()->firstOrFail();
        abort_unless(! $user->disabled && $user->account_status === 'active'
            && in_array($user->moderation_status, ['normal', 'restricted'], true), 403);

        return $user;
    }

    private function eligibleSanctions(int $userId)
    {
        return DB::table('admin_sanctions')->where('user_id', $userId)
            ->where('kind', 'restrict')->where('active', true)->whereNull('restored_at');
    }

    private function shape(object $appeal): array
    {
        return ['id' => (int) $appeal->id, 'status' => $appeal->status,
            'outcome' => $appeal->review_outcome ?? null, 'revision' => (int) ($appeal->revision ?? 1),
            'submitted_at' => $appeal->submitted_at, 'note' => $appeal->note];
    }

    public function forOwner(int $userId): array
    {
        return DB::transaction(function () use ($userId) {
            $user = $this->currentUser($userId);
            if ($user->moderation_status !== 'restricted') {
                return [];
            }

            return $this->eligibleSanctions($userId)->orderByDesc('id')->limit(50)->get(['id', 'kind', 'created_at'])
                ->map(function ($sanction) use ($userId) {
                    $appeal = DB::table('sanction_appeals')->where('sanction_id', $sanction->id)->where('user_id', $userId)->first();

                    // Administrative reasons and report relationships are intentionally not user-facing.
                    return ['id' => (int) $sanction->id, 'kind' => 'restrict', 'created_at' => $sanction->created_at,
                        'appeal' => $appeal ? $this->shape($appeal) : null];
                })->all();
        });
    }

    public function submit(int $userId, int $sanctionId, string $note): array
    {
        $note = trim($note);
        abort_unless($note !== '' && mb_strlen($note) <= 1000, 422, 'appeal note required');

        return DB::transaction(function () use ($userId, $sanctionId, $note) {
            // Governance restore/ban/restrict also locks this same current user before sanctions.
            $user = $this->currentUser($userId);
            abort_unless($user->moderation_status === 'restricted', 404);
            $sanction = $this->eligibleSanctions($userId)->where('id', $sanctionId)->lockForUpdate()->first();
            abort_unless($sanction, 404);
            $existing = DB::table('sanction_appeals')->where('sanction_id', $sanctionId)->lockForUpdate()->first();
            if ($existing) {
                abort_unless((int) $existing->user_id === $userId && $existing->note === $note, 409, 'appeal already submitted');

                return ['appeal' => $this->shape($existing), 'sanction_id' => $sanctionId, 'created' => false];
            }
            $id = DB::table('sanction_appeals')->insertGetId(['sanction_id' => $sanctionId, 'user_id' => $userId,
                'status' => 'submitted', 'note' => $note, 'submitted_at' => now(), 'created_at' => now(), 'updated_at' => now()]);

            // The record itself contains the authenticated actor/time. No note is duplicated to logs/audits.
            return ['appeal' => $this->shape(DB::table('sanction_appeals')->where('id', $id)->first()),
                'sanction_id' => $sanctionId, 'created' => true];
        });
    }

    public function forAdmin(int $actorId, int $userId)
    {
        return DB::transaction(function () use ($actorId, $userId) {
            $actor = User::whereKey($actorId)->lockForUpdate()->first();
            abort_unless(app(AdminAccess::class)->allows($actor), 403);
            $appeals = DB::table('sanction_appeals as a')->join('admin_sanctions as s', 's.id', '=', 'a.sanction_id')
                ->whereNotExists(fn($q)=>$q->selectRaw('1')->from('moderation_reports as platform_report')->whereColumn('platform_report.id','s.report_id')->where('platform_report.category','platform_event'))
                ->where('a.user_id', $userId)->where('s.user_id', $userId)->where('s.kind', 'restrict')
                ->orderByDesc('a.id')->limit(50)
                ->get(['a.id', 'a.sanction_id', 'a.status', 'a.note', 'a.submitted_at', 's.active', 's.restored_at']);
            foreach ($appeals as $appeal) {
                OperationAudit::record($actorId, 'sanction_appeal.view', 'sanction_appeal', $appeal->id,
                    'restricted user appeal detail view', null, [],
                    ['user_id' => $userId, 'sanction_id' => (int) $appeal->sanction_id, 'status' => $appeal->status]);
            }

            return $appeals;
        });
    }
}
