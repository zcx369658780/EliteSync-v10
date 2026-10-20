<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use Tests\TestCase;

class V1012R1BoundaryTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        // TestCase checks testing/sqlite/:memory: before RefreshDatabase migrates.
        parent::setUp();
        config(['restoration.enabled' => true, 'journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => str_repeat('fixture-only-key-', 3),
            'questionnaire.required_answer_count' => 1]);
        $this->travelTo(now()->setDate(2026, 10, 21)->setTime(12, 0));
    }

    public function test_unavailable_formal_request_targets_have_one_response_and_no_side_effects(): void
    {
        $actor = $this->subject('actor');
        $disabled = $this->subject('disabled');
        $this->friendship($actor, $disabled);
        $this->preferences($disabled, true);
        $disabled->update(['disabled' => true]);
        $noSource = $this->subject('no-source');
        $closed = $this->subject('closed');
        $this->friendship($actor, $closed);
        $this->preferences($closed, false);
        $this->preferences($noSource, true);
        $before = $this->effects();

        foreach ([$actor->id, 99999999, $disabled->id, $noSource->id, $closed->id] as $i => $peer) {
            $this->request($actor, $peer, 'unavailable-'.$i)->assertNotFound()
                ->assertJsonPath('error.message', 'unavailable');
            $this->assertSame($before, $this->effects());
        }
    }

    public function test_active_friendship_or_cn_can_request_and_valid_replay_is_side_effect_free(): void
    {
        $actor = $this->subject('actor');
        foreach (['friendship', 'connection'] as $kind) {
            $peer = $this->subject($kind);
            $this->preferences($peer, true);
            $kind === 'friendship' ? $this->friendship($actor, $peer) : $this->connection($actor, $peer);
            $first = $this->request($actor, $peer->id, 'request-'.$kind)->assertOk()
                ->assertJsonPath('state', 'PENDING_MUTUAL')->json();
            $after = $this->effects();
            $this->request($actor, $peer->id, 'request-'.$kind)->assertOk()->assertExactJson($first);
            $this->assertSame($after, $this->effects());
        }
        $this->assertDatabaseCount('formal_relationships', 2);
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->assertDatabaseCount('journey_commands', 2);
    }

    public function test_request_permission_epoch_only_changes_with_flag_and_off_on_cannot_revive_pending(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $this->friendship($a, $b);
        $this->preferences($b, true);
        $epoch = (int) DB::table('privacy_preferences')->where('user_id', $b->id)->value('requests_revision');
        $r = $this->request($a, $b->id, 'request')->assertOk()->json();
        $this->preferences($b, true);
        $this->assertSame($epoch, (int) DB::table('privacy_preferences')->where('user_id', $b->id)->value('requests_revision'));
        $this->preferences($b, false);
        $beforeReplay = $this->effects();
        $this->request($a, $b->id, 'request')->assertNotFound()->assertJsonPath('error.message', 'unavailable');
        $this->assertSame($beforeReplay, $this->effects());
        $this->preferences($b, true);
        $this->assertSame($epoch + 2, (int) DB::table('privacy_preferences')->where('user_id', $b->id)->value('requests_revision'));
        $this->identities($a, $b);
        $this->relationshipAction($a, $r, 'confirm', 'confirm-after-off-on')->assertConflict();
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->assertDatabaseMissing('formal_relationships', ['id' => $r['id'], 'state' => 'ACTIVE']);
        $this->assertDatabaseMissing('journey_commands', ['idempotency_key' => 'confirm-after-off-on']);
    }

    public function test_pending_request_cannot_substitute_a_new_source_or_restored_source_revision(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $friend = $this->friendship($a, $b);
        $this->preferences($b, true);
        $r = $this->request($a, $b->id, 'request')->assertOk()->json();
        // Revoke and restore without an intervening relationship read.
        DB::table('friendships')->where('id', $friend)->update(['state' => 'REMOVED', 'revision' => 2]);
        DB::table('friendships')->where('id', $friend)->update(['state' => 'ACTIVE', 'revision' => 3]);
        $this->connection($a, $b); // Another valid source cannot replace the bound one.
        $this->identities($a, $b);
        $this->relationshipAction($a, $r, 'confirm', 'confirm-restored-source')->assertConflict();
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->assertDatabaseMissing('formal_relationships', ['id' => $r['id'], 'state' => 'ACTIVE']);
        $this->assertDatabaseMissing('journey_commands', ['idempotency_key' => 'confirm-restored-source']);
    }

    public function test_terminal_cooldown_and_decline_cannot_be_bypassed_by_changing_request_key(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $this->friendship($a, $b);
        $this->preferences($a, true); $this->preferences($b, true);
        $r = $this->request($a, $b->id, 'first')->assertOk()->json();
        $this->relationshipAction($a, $r, 'withdraw', 'withdraw')->assertOk()->assertJsonPath('state', 'WITHDRAWN');
        $before = $this->effects();
        $this->request($a, $b->id, 'different-key')->assertNotFound()->assertJsonPath('error.message', 'unavailable');
        $this->assertSame($before, $this->effects());
        $this->travel(25)->hours();
        $r = $this->request($a, $b->id, 'after-cooldown')->assertOk()->json();
        $this->relationshipAction($b, $r, 'decline', 'decline')->assertOk()->assertJsonPath('state', 'DECLINED');
        $this->travel(25)->hours();
        $before = $this->effects();
        $this->request($a, $b->id, 'after-decline-new-key')->assertNotFound()->assertJsonPath('error.message', 'unavailable');
        $this->assertSame($before, $this->effects());
        $this->request($b, $a->id, 'recipient-initiated')->assertOk()->assertJsonPath('state', 'PENDING_MUTUAL');
        $this->assertDatabaseCount('formal_relationships', 3);
    }

    public function test_exit_withdraws_pending_and_stale_generation_lazily_releases_both_slots(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $id = $this->proposal($a, $b);
        $this->participate($a, 'exit', 1)->assertOk()->assertJsonPath('state', 'EXITED');
        $this->assertUnavailableAcrossProjections($b);
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'WITHDRAWN']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/journey')->assertOk()
            ->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.connection_eligible', false)
            ->assertJsonPath('proposal.decision_available', false);

        $c = $this->subject('c'); $d = $this->subject('d');
        $old = $this->proposal($c, $d);
        DB::table('matching_participations')->where('user_id', $c->id)->update(['generation' => 2]);
        $this->actingAs($d, 'sanctum')->getJson('/api/v1/journey')->assertOk()
            ->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.decision_available', false);
        $this->assertUnavailableAcrossProjections($d);
        $this->assertDatabaseMissing('match_proposals', ['id' => $old, 'state' => 'PENDING']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->assertDatabaseCount('product_connections', 0);
    }

    public function test_pause_preserves_pending_allows_withdraw_and_blocks_opt_in_until_resolved(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $this->qualify($a);
        $id = $this->proposal($a, $b);
        $this->decision($a, $id, 'accept', 1, 'accept-a')->assertOk()->assertJsonPath('state', 'ACCEPTED_BY_ONE');
        $this->participate($a, 'pause', 1)->assertOk()->assertJsonPath('state', 'PAUSED');
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'ACCEPTED_BY_ONE', 'revision' => 2]);
        $this->assertDatabaseCount('match_proposal_slots', 2);
        foreach ([$a, $b] as $viewer) {
            $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/journey')->assertOk()
                ->assertJsonPath('proposal.decision_available', false)->assertJsonPath('proposal.withdraw_available', true)
                ->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.connection_eligible', false);
        }
        $this->assertUnavailableAcrossProjections($b);
        $this->decision($b, $id, 'accept', 2, 'accept-while-paused')->assertConflict();
        $this->participate($a, 'opt_in', 2)->assertConflict();
        $this->assertDatabaseHas('matching_participations', ['user_id' => $a->id, 'state' => 'PAUSED', 'generation' => 1, 'revision' => 2]);
        $this->decision($a, $id, 'withdraw', 2, 'withdraw-own-pending')->assertOk()->assertJsonPath('state', 'WITHDRAWN');
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->participate($a, 'opt_in', 2)->assertOk()->assertJsonPath('generation', 2)->assertJsonPath('state', 'ACTIVE');
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
    }

    public function test_mutual_history_survives_exit_and_generation_change_without_new_cn_authority(): void
    {
        foreach (['exit', 'generation'] as $mode) {
            $a = $this->subject($mode.'-a'); $b = $this->subject($mode.'-b');
            $id = $this->proposal($a, $b);
            $this->decision($a, $id, 'accept', 1, 'accept-'.$mode.'-a')->assertOk();
            $this->decision($b, $id, 'accept', 2, 'accept-'.$mode.'-b')->assertOk()->assertJsonPath('state', 'MUTUALLY_ACCEPTED');
            $this->assertNotNull(app(LiveConsentService::class)->match($a->id, $b->id));
            foreach (['connection', 'consent'] as $kind) {
                $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/$kind",
                    ['action' => 'request', 'expected_revision' => 0])->assertOk();
                $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/$kind",
                    ['action' => 'accept', 'expected_revision' => 1])->assertOk();
            }
            $cn = $this->getJson("/api/v1/connections/{$a->id}")->assertOk()
                ->assertJsonPath('gates.live_read_allowed', true)->assertJsonPath('gates.live_send_allowed', true)
                ->json('connection');
            if ($mode === 'exit') {
                $this->participate($a, 'exit', 1)->assertOk();
            } else {
                DB::table('matching_participations')->where('user_id', $a->id)->update(['generation' => 2]);
            }
            $this->assertNull(app(LiveConsentService::class)->match($a->id, $b->id));
            $this->actingAs($b, 'sanctum')->getJson('/api/v1/journey')->assertOk()
                ->assertJsonPath('proposal.state', 'MUTUALLY_ACCEPTED')->assertJsonPath('proposal.connection_eligible', false);
            $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'MUTUALLY_ACCEPTED']);
            $this->assertDatabaseHas('product_connections', ['id' => $cn['id'], 'state' => 'CN_ACTIVE', 'revision' => $cn['revision']]);
            $this->assertDatabaseHas('messaging_consents', ['connection_id' => $cn['id'], 'state' => 'MC_ACTIVE', 'revision' => 2]);
            $this->getJson("/api/v1/connections/{$a->id}")->assertOk()
                ->assertJsonPath('gates.live_read_allowed', true)->assertJsonPath('gates.live_send_allowed', true);
        }
    }

    public function test_unactivated_request_cannot_escape_revoked_source_through_pause_resume_generations(): void
    {
        $a = $this->subject('pause-request-a'); $b = $this->subject('pause-request-b');
        $this->friendship($a, $b); $this->preferences($b, true);
        $r = $this->request($a, $b->id, 'request-before-pause')->assertOk()->json();
        $r = $this->relationshipAction($a, $r, 'pause', 'pause-unactivated')->assertOk()->json();
        $this->preferences($b, false);
        $this->relationshipAction($a, $r, 'resume', 'resume-revoked-unactivated')->assertConflict();
        $this->assertDatabaseHas('formal_relationships', ['id' => $r['id'], 'state' => 'WITHDRAWN', 'activated_at' => null]);
        $this->assertDatabaseMissing('journey_commands', ['idempotency_key' => 'resume-revoked-unactivated']);
        $this->assertDatabaseCount('formal_relationship_slots', 0);
    }

    public function test_blocked_and_closed_accounts_with_otherwise_valid_contact_have_no_request_side_effects(): void
    {
        $a = $this->subject('controlled-a');
        foreach (['blocked_by_actor', 'blocked_by_peer', 'closing'] as $mode) {
            $b = $this->subject($mode); $this->friendship($a, $b); $this->preferences($b, true);
            if ($mode === 'closing') { $b->update(['account_status' => 'DELETION_PENDING']); }
            else { DB::table('user_blocks')->insert(['blocker_id' => $mode === 'blocked_by_actor' ? $a->id : $b->id,
                'blocked_user_id' => $mode === 'blocked_by_actor' ? $b->id : $a->id, 'created_at' => now(), 'updated_at' => now()]); }
            $before = $this->effects();
            $this->request($a, $b->id, $mode)->assertNotFound()->assertJsonPath('error.message', 'unavailable');
            $this->assertSame($before, $this->effects());
        }
    }

    public function test_social_and_formal_requests_share_distinct_recipient_quota_in_both_directions(): void
    {
        config(['social.daily_distinct_recipients' => 2]);
        foreach (['social_first', 'formal_first'] as $mode) {
            $a = $this->subject($mode.'-a'); $targets = [];
            foreach (range(1, 3) as $n) {
                $b = $this->subject($mode.'-'.$n); $targets[] = $b;
                $this->friendship($a, $b); $this->preferences($b, true);
            }
            foreach (array_slice($targets, 0, 2) as $n => $b) {
                if ($mode === 'formal_first') { $this->request($a, $b->id, 'formal-'.$n)->assertOk(); }
                else { $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => 'message', 'peer_id' => $b->id, 'idempotency_key' => 'social-'.$n])->assertCreated(); }
            }
            $before = $this->effects();
            if ($mode === 'social_first') { $this->request($a, $targets[2]->id, 'over-formal')->assertStatus(429); }
            else { $this->actingAs($a, 'sanctum')->postJson('/api/v1/social/requests', ['purpose' => 'message', 'peer_id' => $targets[2]->id, 'idempotency_key' => 'over-social'])->assertStatus(429); }
            $this->assertSame($before, $this->effects());
        }
    }

    private function assertUnavailableAcrossProjections(User $viewer): void
    {
        $this->actingAs($viewer, 'sanctum')->getJson('/api/v1/journey')->assertOk()->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.decision_available', false);
        $this->getJson('/api/v1/matches/current')->assertOk()->assertJsonPath('proposal.showcase', null)->assertJsonPath('proposal.decision_available', false);
        $this->getJson('/api/v1/match-rounds/current')->assertOk()->assertJsonPath('data.result', null)->assertJsonPath('data.conversation_capability', null);
    }

    private function subject(string $name): User
    {
        $u = User::factory()->create(['phone' => 'r1-'.$name, 'is_synthetic' => true,
            'verify_status' => 'approved', 'account_status' => 'active', 'moderation_status' => 'normal',
            'disabled' => false, 'is_match_eligible' => true]);
        app(TrustedIdentityService::class)->register($u->id);
        return $u;
    }

    private function preferences(User $u, bool $enabled): void
    {
        $this->actingAs($u, 'sanctum')->postJson('/api/v1/social/preferences', ['requests_enabled' => $enabled])->assertOk();
    }

    private function friendship(User $a, User $b): int
    {
        return DB::table('friendships')->insertGetId(['user_a' => min($a->id, $b->id),
            'user_b' => max($a->id, $b->id), 'state' => 'ACTIVE', 'revision' => 1,
            'created_at' => now(), 'updated_at' => now()]);
    }

    private function connection(User $a, User $b): int
    {
        return DB::table('product_connections')->insertGetId(['user_a' => min($a->id, $b->id),
            'user_b' => max($a->id, $b->id), 'requester_id' => $a->id, 'state' => 'CN_ACTIVE',
            'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    }

    private function identities(User ...$users): void
    {
        foreach ($users as $u) { app(TrustedIdentityService::class)->issue($u->id, 'r1-identity-'.$u->id); }
    }

    private function request(User $a, int $peer, string $key): TestResponse
    {
        return $this->actingAs($a, 'sanctum')->postJson('/api/v1/formal-relationships', ['peer_id' => $peer, 'idempotency_key' => $key]);
    }

    private function relationshipAction(User $a, array $r, string $action, string $key): TestResponse
    {
        return $this->actingAs($a, 'sanctum')->postJson('/api/v1/formal-relationships/'.$r['id'].'/actions',
            ['action' => $action, 'revision' => $r['revision'], 'idempotency_key' => $key]);
    }

    private function effects(): array
    {
        return collect(['formal_relationships', 'formal_relationship_slots', 'journey_commands', 'journey_audits', 'notifications'])
            ->mapWithKeys(fn ($table) => [$table => DB::table($table)->count()])->all();
    }

    private function participate(User $a, string $action, int $revision): TestResponse
    {
        return $this->actingAs($a, 'sanctum')->putJson('/api/v1/journey/participation',
            ['action' => $action, 'revision' => $revision, 'intent' => 'Synthetic fixture intent']);
    }

    private function decision(User $a, string $id, string $action, int $revision, string $key): TestResponse
    {
        return $this->actingAs($a, 'sanctum')->postJson('/api/v1/journey/proposals/'.$id.'/decision',
            ['action' => $action, 'revision' => $revision, 'idempotency_key' => $key]);
    }

    private function qualify(User $u): void
    {
        $q = QuestionnaireQuestion::create(['question_key' => 'default', 'category' => 'test',
            'content' => 'Synthetic preference', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A']], 'sort_order' => 0, 'enabled' => true, 'version' => 1]);
        QuestionnaireAnswer::create(['user_id' => $u->id, 'questionnaire_question_id' => $q->id,
            'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
    }

    /** Real FK parents, no matching execution or external service. */
    private function proposal(User $a, User $b): string
    {
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insertOrIgnore(['channel_key' => 'default'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId(['round_key' => (string) Str::uuid(),
            'channel_key' => 'default', 'cadence_key' => (string) Str::uuid(), 'state' => 'revealed',
            'created_by_type' => 'test', 'source' => 'test'] + $stamp);
        $run = DB::table('matching_runs')->insertGetId(['round_id' => $round, 'run_key' => (string) Str::uuid(),
            'idempotency_key' => 'r1-run-'.$round, 'correlation_id' => (string) Str::uuid(), 'attempt_no' => 1,
            'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'test', 'config_version' => 'test'] + $stamp);
        $match = DB::table('dating_matches')->insertGetId(['week_tag' => 'r1', 'round_id' => $round,
            'matching_run_id' => $run, 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true] + $stamp);
        $id = (string) Str::uuid();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $match, 'round_id' => $round,
            'run_id' => $run, 'user_a' => $a->id, 'user_b' => $b->id, 'generation_a' => 1, 'generation_b' => 1,
            'revealed_at' => now(), 'expires_at' => now()->addHours(168)] + $stamp);
        DB::table('dating_round_channels')->where('channel_key', 'default')->update(['active_round_id' => $round]);
        foreach ([$a, $b] as $u) {
            DB::table('dating_round_user_states')->insert(['round_id' => $round, 'user_id' => $u->id, 'state' => 'revealed', 'dating_match_id' => $match] + $stamp);
            DB::table('matching_participations')->insert(['user_id' => $u->id, 'state' => 'ACTIVE',
                'generation' => 1, 'revision' => 1, 'opted_in_at' => now()] + $stamp);
            DB::table('match_proposal_slots')->insert(['user_id' => $u->id, 'proposal_id' => $id]);
        }
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/match-rounds/current')->assertOk()
            ->assertJsonPath('data.state', 'revealed')->assertJsonPath('data.result.match_id', $match);
        return $id;
    }
}
