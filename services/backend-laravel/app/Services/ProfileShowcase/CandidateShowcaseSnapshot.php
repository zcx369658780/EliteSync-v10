<?php

namespace App\Services\ProfileShowcase;

use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/** Minimal, once-only candidate projection. Never backfill legacy candidates from today's publication. */
final class CandidateShowcaseSnapshot
{
    private const FIELDS = ['self_intro', 'interest_tags', 'lifestyle_tags', 'audiences'];

    /** Caller holds the ordered participant locks in the reveal transaction. */
    public function capture(object $proposal): void
    {
        foreach ([(int) $proposal->user_a, (int) $proposal->user_b] as $owner) {
            $viewer = (int) ($proposal->user_a == $owner ? $proposal->user_b : $proposal->user_a);
            $publication = app(ShowcaseWorkflow::class)->visiblePublicationLocked($viewer, $owner);
            if (! $publication || ! $publication->source_submission_id) {
                continue;
            }
            $source = DB::table('profile_showcase_submissions')->where('id', $publication->source_submission_id)
                ->where('user_id', $owner)->where('state', 'approved')->lockForUpdate()->first();
            if (! $source || (int) $source->content_revision !== (int) $publication->source_revision) {
                continue;
            }
            $snapshot = array_intersect_key($publication->published_payload, array_flip(self::FIELDS));
            $approved = array_intersect_key(json_decode($source->snapshot, true, 512, JSON_THROW_ON_ERROR), array_flip(self::FIELDS));
            if ($snapshot !== $approved) {
                continue;
            }
            DB::table('candidate_showcase_bindings')->insertOrIgnore([
                'proposal_id' => $proposal->id, 'owner_id' => $owner, 'viewer_id' => $viewer,
                'publication_id' => $publication->id, 'source_submission_id' => $source->id,
                'publication_revision' => $publication->revision, 'access_epoch' => $publication->access_epoch,
                'snapshot' => json_encode($snapshot, JSON_THROW_ON_ERROR), 'created_at' => now(),
            ]);
        }
    }

    public function read(object $proposal, int $viewer, int $owner): ?array
    {
        if ($viewer === $owner || ! in_array($viewer, [(int) $proposal->user_a, (int) $proposal->user_b], true)
            || ! in_array($owner, [(int) $proposal->user_a, (int) $proposal->user_b], true)
            || ! in_array($proposal->state, ['PENDING', 'ACCEPTED_BY_ONE', 'MUTUALLY_ACCEPTED'], true)
            || Carbon::parse($proposal->expires_at, 'UTC')->lte(now()->utc())) {
            return null;
        }
        $binding = DB::table('candidate_showcase_bindings')->where('proposal_id', $proposal->id)
            ->where('owner_id', $owner)->where('viewer_id', $viewer)->lockForUpdate()->first();
        if (! $binding) {
            return null;
        }
        $publication = app(ShowcaseWorkflow::class)->visiblePublicationLocked($viewer, $owner);
        if (! $publication || (int) $publication->id !== (int) $binding->publication_id
            || (int) $publication->access_epoch !== (int) $binding->access_epoch) {
            return null;
        }
        $source = DB::table('profile_showcase_submissions')->where('id', $binding->source_submission_id)
            ->where('user_id', $owner)->where('state', 'approved')->lockForUpdate()->first();
        if (! $source) {
            return null;
        }
        $snapshot = json_decode($binding->snapshot, true, 512, JSON_THROW_ON_ERROR);
        if (! app(ShowcaseWorkflow::class)->audienceAllowedLocked($viewer, $owner, $snapshot['audiences'] ?? [])) {
            return null;
        }

        return ['public_id' => 'ES-'.$owner, 'summary' => $snapshot['self_intro'] ?? null,
            'interest_tags' => $snapshot['interest_tags'] ?? [], 'lifestyle_tags' => $snapshot['lifestyle_tags'] ?? [],
            'publication_revision' => (int) $binding->publication_revision];
    }
}
