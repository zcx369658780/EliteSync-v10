<?php

namespace Tests\Support;

use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

/** Current accepted-main proposal fixture, derived from V1012JourneyTest. */
trait CreatesAcceptedMainMatch
{
    private function createAcceptedMatchContext(User $a, User $b): void
    {
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insertOrIgnore(['channel_key' => 'l13-compat-test'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId([
            'round_key' => (string) Str::uuid(), 'channel_key' => 'l13-compat-test',
            'cadence_key' => (string) Str::uuid(), 'state' => 'revealed',
            'created_by_type' => 'test', 'source' => 'test',
        ] + $stamp);
        $run = DB::table('matching_runs')->insertGetId([
            'round_id' => $round, 'run_key' => (string) Str::uuid(),
            'idempotency_key' => (string) Str::uuid(), 'correlation_id' => (string) Str::uuid(),
            'attempt_no' => 1, 'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'test', 'config_version' => 'test',
        ] + $stamp);
        $match = DB::table('dating_matches')->insertGetId([
            'week_tag' => 'l13-compat-test', 'round_id' => $round, 'matching_run_id' => $run,
            'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true,
        ] + $stamp);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert([
            'id' => $id, 'dating_match_id' => $match, 'round_id' => $round, 'run_id' => $run,
            'user_a' => $a->id, 'user_b' => $b->id, 'generation_a' => 1, 'generation_b' => 1,
            'revealed_at' => now(), 'expires_at' => now()->addHours(168),
        ] + $stamp);
        foreach ([$a, $b] as $user) {
            DB::table('matching_participations')->updateOrInsert(['user_id' => $user->id], [
                'state' => 'ACTIVE', 'generation' => 1, 'revision' => 1, 'opted_in_at' => now(),
            ] + $stamp);
            DB::table('match_proposal_slots')->insert(['user_id' => $user->id, 'proposal_id' => $id]);
        }
        $this->actingAs($a, 'sanctum')->postJson("/api/v1/journey/proposals/$id/decision", [
            'action' => 'accept', 'revision' => 1, 'idempotency_key' => 'fixture-a-'.$id,
        ])->assertOk()->assertJsonPath('state', 'ACCEPTED_BY_ONE');
        $this->actingAs($b, 'sanctum')->postJson("/api/v1/journey/proposals/$id/decision", [
            'action' => 'accept', 'revision' => 2, 'idempotency_key' => 'fixture-b-'.$id,
        ])->assertOk()->assertJsonPath('state', 'MUTUALLY_ACCEPTED');
    }
}
