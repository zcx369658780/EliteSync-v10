<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\LiveConsentService;
use App\Services\SlowDatingService;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Testing\TestResponse;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class V1012JourneyTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => str_repeat('fixture-only-key-', 3),
            'questionnaire.required_answer_count' => 1]);
        $this->travelTo(now()->setDate(2026, 10, 20)->setTime(12, 0));
    }

    private function subject(string $name): User
    {
        $user = User::factory()->create(['phone' => 'v1012-'.$name, 'is_synthetic' => true,
            'verify_status' => 'approved', 'account_status' => 'active',
            'moderation_status' => 'normal', 'disabled' => false, 'is_match_eligible' => true]);
        app(TrustedIdentityService::class)->register($user->id);
        return $user;
    }

    private function qualify(User ...$users): void
    {
        $q = QuestionnaireQuestion::create(['question_key' => 'v1012-fixture', 'category' => 'test',
            'content' => 'Synthetic preference', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A']], 'sort_order' => 0, 'enabled' => true, 'version' => 1]);
        foreach ($users as $user) {
            QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $q->id,
                'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        }
    }

    private function relationship(User $a, User $b): array
    {
        // R1 fixture declares independent controlled contact; this is not formal consent.
        DB::table('friendships')->updateOrInsert(['user_a' => min($a->id, $b->id), 'user_b' => max($a->id, $b->id)], ['state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        DB::table('privacy_preferences')->updateOrInsert(['user_id' => $b->id], ['requests_enabled' => true]);
        return $this->actingAs($a, 'sanctum')->postJson('/api/v1/formal-relationships',
            ['peer_id' => $b->id, 'idempotency_key' => 'request'])->assertOk()->json();
    }

    private function action(User $actor, array $r, string $action, string $key): TestResponse
    {
        return $this->actingAs($actor, 'sanctum')->postJson("/api/v1/formal-relationships/{$r['id']}/actions",
            ['action' => $action, 'revision' => $r['revision'], 'idempotency_key' => $key]);
    }

    private function activate(User $a, User $b): array
    {
        app(TrustedIdentityService::class)->issue($a->id, 'identity-a');
        app(TrustedIdentityService::class)->issue($b->id, 'identity-b');
        $r = $this->relationship($a, $b);
        $r = $this->action($a, $r, 'confirm', 'confirm-a')->assertOk()->assertJsonPath('state', 'PENDING_MUTUAL')->json();
        return $this->action($b, $r, 'confirm', 'confirm-b')->assertOk()->assertJsonPath('state', 'ACTIVE')->json();
    }

    public function test_operational_approval_admin_and_client_flags_do_not_activate_real_accounts(): void
    {
        $a = User::factory()->create(['phone' => 'real-a', 'role' => 'admin', 'is_synthetic' => false,
            'verify_status' => 'approved', 'realname_verified' => true]);
        $b = User::factory()->create(['phone' => 'real-b', 'is_synthetic' => false,
            'verify_status' => 'approved', 'realname_verified' => true]);
        $r = $this->relationship($a, $b);
        $this->action($a, $r, 'confirm', 'real-confirm')->assertForbidden();
        $this->postJson("/api/v1/formal-relationships/{$r['id']}/actions", [
            'action' => 'confirm', 'revision' => 1, 'idempotency_key' => 'forged', 'verified' => true,
        ])->assertUnprocessable();
        $this->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('identity.activation_available', false)
            ->assertJsonPath('identity.real_provider', 'PENDING');
        $this->assertDatabaseCount('formal_relationship_slots', 0);
    }

    public function test_field_sharing_defaults_private_can_be_withdrawn_and_pause_requires_both_again(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $a->update(['birthday' => '1990-01-02', 'public_zodiac_sign' => 'Capricorn']);
        $r = $this->activate($a, $b);
        // Established formal sharing survives removal of its independent request source.
        $this->actingAs($a, 'sanctum')->deleteJson("/api/v1/social/friends/{$b->id}")->assertOk();
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/privacy/resume', ['resume' => 'Synthetic biography'])->assertOk();
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/privacy/peers/{$a->id}")->assertOk()
            ->assertJsonMissingPath('profile.birthday')->assertJsonMissingPath('profile.resume');
        $fields = ['birthday' => 'RELATIONSHIP_SHARED', 'resume' => 'RELATIONSHIP_SHARED',
            'interests' => 'SELF', 'zodiac' => 'SELF'];
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/privacy', ['fields' => $fields, 'expected_revision' => 0])->assertOk();
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/privacy/peers/{$a->id}")->assertOk()
            ->assertJsonPath('profile.birthday', '1990-01-02')->assertJsonPath('profile.resume', 'Synthetic biography')
            ->assertJsonMissingPath('profile.zodiac');
        $fields['resume'] = 'SELF';
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/privacy', ['fields' => $fields, 'expected_revision' => 1])->assertOk();
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/privacy/peers/{$a->id}")->assertOk()
            ->assertJsonPath('profile.birthday', '1990-01-02')->assertJsonMissingPath('profile.resume');
        $r = $this->action($a, $r, 'pause', 'pause')->assertOk()->assertJsonPath('state', 'PAUSED')->json();
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->actingAs($b, 'sanctum')->getJson("/api/v1/privacy/peers/{$a->id}")->assertNotFound();
        $r = $this->action($b, $r, 'resume', 'resume')->assertOk()
            ->assertJsonPath('confirmation_generation', 2)->assertJsonPath('confirmed_me', false)
            ->assertJsonPath('confirmed_peer', false)->json();
        $r = $this->action($a, $r, 'confirm', 'reconfirm-a')->assertOk()->assertJsonPath('state', 'PENDING_MUTUAL')->json();
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->action($b, $r, 'confirm', 'reconfirm-b')->assertOk()->assertJsonPath('state', 'ACTIVE');
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
    }

    public function test_revoked_identity_hides_sharing_and_does_not_prevent_ending_or_allow_resurrection(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $r = $this->activate($a, $b);
        app(TrustedIdentityService::class)->revoke($a->id, DB::table('identity_assertions')->where('user_id', $a->id)->value('id'));
        $r = $this->actingAs($a, 'sanctum')->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('relationships.0.state', 'SUSPENDED_REVERIFY')->json('relationships.0');
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $r = $this->action($a, $r, 'end', 'end')->assertOk()->assertJsonPath('state', 'ENDED')->json();
        $this->action($b, $r, 'resume', 'resurrect')->assertConflict();
        $this->action($b, $r, 'confirm', 'late-confirm')->assertConflict();
        $this->assertDatabaseHas('formal_relationships', ['id' => $r['id'], 'state' => 'ENDED']);
    }

    public function test_test_only_assertions_reject_forgery_nonce_replay_and_wrong_environment(): void
    {
        $a = $this->subject('a');
        $issuer = app(TrustedIdentityService::class);
        $id = $issuer->issue($a->id, 'single-use');
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('identity.test_only', true)->assertJsonPath('identity.real_provider', 'PENDING');
        try {
            $issuer->issue($a->id, 'single-use');
            $this->fail('A consumed nonce must not be issued again.');
        } catch (HttpException $e) {
            $this->assertSame(409, $e->getStatusCode());
        }
        $this->assertDatabaseCount('identity_assertions', 1);
        DB::table('identity_assertions')->where('id', $id)->update(['signature' => str_repeat('0', 64)]);
        $this->getJson('/api/v1/formal-relationships')->assertOk()->assertJsonPath('identity.activation_available', false);
        $issuer->issue($a->id, 'valid-second');
        $oldEnvironment = app()->environment();
        try {
            app()->instance('env', 'production');
            $this->assertFalse($issuer->sandbox());
            $this->assertFalse($issuer->valid($a->id));
            try {
                $issuer->issue($a->id, 'production-denied');
                $this->fail('TEST_ONLY issuer must fail outside its sandbox.');
            } catch (HttpException $e) {
                $this->assertSame(403, $e->getStatusCode());
            }
        } finally {
            app()->instance('env', $oldEnvironment);
        }
        $this->assertDatabaseMissing('identity_assertions', ['nonce' => 'production-denied']);
    }

    public function test_participation_draft_opt_in_pause_and_resume_have_explicit_generations(): void
    {
        $a = $this->subject('a');
        $this->actingAs($a, 'sanctum')->putJson('/api/v1/journey/participation',
            ['action' => 'draft', 'revision' => 0, 'intent' => 'Take time'])->assertOk()
            ->assertJsonPath('state', 'NOT_ENROLLED')->assertJsonPath('generation', 0);
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 1, 'intent' => 'Take time'])->assertUnprocessable();
        $this->qualify($a);
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 1, 'intent' => 'Take time'])->assertOk()
            ->assertJsonPath('state', 'ACTIVE')->assertJsonPath('generation', 1)->assertJsonPath('revision', 2);
        $this->putJson('/api/v1/journey/participation', ['action' => 'pause', 'revision' => 1, 'intent' => ''])->assertConflict();
        $this->putJson('/api/v1/journey/participation', ['action' => 'pause', 'revision' => 2, 'intent' => 'Break'])->assertOk()
            ->assertJsonPath('state', 'PAUSED')->assertJsonPath('generation', 1);
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 3, 'intent' => 'Ready'])->assertOk()
            ->assertJsonPath('state', 'ACTIVE')->assertJsonPath('generation', 2);
        $this->assertDatabaseCount('match_proposals', 0);
    }

    public function test_proposal_identity_revision_and_idempotency_preserve_separate_consents(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b'); $outsider = $this->subject('outsider');
        $id = $this->proposalFixture($a, $b);
        $body = ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'accept-a'];
        $url = "/api/v1/journey/proposals/$id/decision";
        $this->actingAs($outsider, 'sanctum')->postJson($url, $body)->assertNotFound();
        $this->actingAs($a, 'sanctum')->postJson('/api/v1/journey/proposals/'.Str::uuid().'/decision', $body)->assertNotFound();
        $first = $this->postJson($url, $body)->assertOk()->assertJsonPath('state', 'ACCEPTED_BY_ONE')
            ->assertJsonPath('connection_eligible', false)->json();
        $this->postJson($url, $body)->assertOk()->assertExactJson($first);
        $this->postJson($url, array_replace($body, ['action' => 'decline']))->assertConflict();
        $this->actingAs($b, 'sanctum')->postJson($url, ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'stale'])->assertConflict();
        $this->postJson($url, ['action' => 'accept', 'revision' => 2, 'idempotency_key' => 'accept-b'])->assertOk()
            ->assertJsonPath('state', 'MUTUALLY_ACCEPTED')->assertJsonPath('connection_eligible', true);
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->assertDatabaseCount('formal_relationships', 0);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->postJson('/api/v1/matches/confirm', ['target_user_id' => $a->id, 'like' => true])->assertStatus(410);
        $this->assertDatabaseHas('dating_matches', ['user_a' => $a->id, 'like_a' => null, 'like_b' => null]);
    }

    public function test_expired_and_previous_generation_proposals_cannot_be_accepted(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $id = $this->proposalFixture($a, $b);
        DB::table('matching_participations')->where('user_id', $a->id)->update(['generation' => 2]);
        $this->actingAs($a, 'sanctum')->postJson("/api/v1/journey/proposals/$id/decision",
            ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'old-generation'])->assertConflict();
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'WITHDRAWN']);
        $c = $this->subject('expiry-c'); $d = $this->subject('expiry-d');
        $id = $this->proposalFixture($c, $d);
        $this->actingAs($c, 'sanctum');
        $this->travel(169)->hours();
        $this->postJson("/api/v1/journey/proposals/$id/decision",
            ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'expired'])->assertConflict();
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'EXPIRED']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->assertDatabaseCount('journey_commands', 0);
        $this->assertDatabaseCount('product_connections', 0);
    }

    public function test_reissuing_a_revoked_bound_credential_does_not_restore_an_active_relationship(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $r = $this->activate($a, $b);
        $issuer = app(TrustedIdentityService::class);
        $old = DB::table('identity_assertions')->where('user_id', $a->id)->value('id');
        $issuer->revoke($a->id, $old);
        $issuer->issue($a->id, 'replacement-a');
        // No relationship read occurs between revocation and replacement issuance.
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('identity.activation_available', true)
            ->assertJsonPath('relationships.0.id', $r['id'])
            ->assertJsonPath('relationships.0.state', 'SUSPENDED_REVERIFY')
            ->assertJsonPath('relationships.0.confirmed_me', false)
            ->assertJsonPath('relationships.0.confirmed_peer', false);
        $this->assertDatabaseCount('formal_relationship_slots', 0);
    }

    public function test_replacement_before_first_read_cannot_hide_expiry_of_a_bound_credential(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $issuer = app(TrustedIdentityService::class);
        $issuer->issue($a->id, 'short-lived-a', 1);
        $issuer->issue($b->id, 'long-lived-b', 120);
        $r = $this->relationship($a, $b);
        $r = $this->action($a, $r, 'confirm', 'confirm-a')->assertOk()->json();
        $r = $this->action($b, $r, 'confirm', 'confirm-b')->assertOk()->assertJsonPath('state', 'ACTIVE')->json();
        $this->travel(2)->minutes();
        $issuer->issue($a->id, 'replacement-after-expiry');
        $this->actingAs($a, 'sanctum')->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('identity.activation_available', true)
            ->assertJsonPath('relationships.0.id', $r['id'])
            ->assertJsonPath('relationships.0.state', 'SUSPENDED_REVERIFY');
        $this->assertDatabaseCount('formal_relationship_slots', 0);
        $this->actingAs($b, 'sanctum')->getJson('/api/v1/formal-relationships')->assertOk()
            ->assertJsonPath('identity.activation_available', true)
            ->assertJsonPath('relationships.0.state', 'SUSPENDED_REVERIFY');
    }

    public function test_peer_cannot_complete_an_old_proposal_after_acceptor_pauses_and_reenrolls(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $this->qualify($a);
        $id = $this->proposalFixture($a, $b);
        $url = "/api/v1/journey/proposals/$id/decision";
        $this->actingAs($a, 'sanctum')->postJson($url,
            ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'accept-a'])->assertOk()
            ->assertJsonPath('state', 'ACCEPTED_BY_ONE');
        $this->putJson('/api/v1/journey/participation', ['action' => 'pause', 'revision' => 1, 'intent' => 'Break'])->assertOk();
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 2, 'intent' => 'Return'])->assertConflict();
        $this->postJson($url, ['action' => 'withdraw', 'revision' => 2, 'idempotency_key' => 'explicit-withdraw-before-return'])->assertOk()->assertJsonPath('state', 'WITHDRAWN');
        $this->putJson('/api/v1/journey/participation', ['action' => 'opt_in', 'revision' => 2, 'intent' => 'Return'])->assertOk()
            ->assertJsonPath('state', 'ACTIVE')->assertJsonPath('generation', 2);
        $this->actingAs($b, 'sanctum')->postJson($url,
            ['action' => 'accept', 'revision' => 2, 'idempotency_key' => 'accept-b'])->assertConflict();
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'state' => 'WITHDRAWN',
            'revision' => 3, 'decision_a' => 'ACCEPTED', 'decision_b' => 'PENDING']);
        $this->assertDatabaseCount('match_proposal_slots', 0);
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
    }

    public function test_same_decision_key_reprojects_current_canonical_published_showcase(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $id = $this->proposalFixture($a, $b);
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        $draft = DB::table('user_profile_showcase_drafts')->insertGetId(['user_id' => $b->id,
            'self_intro' => 'Unpublished private draft'] + $stamp);
        DB::table('user_profile_showcase_publications')->insert(['user_id' => $b->id,
            'source_draft_id' => $draft, 'source_moderation_status' => 'approved', 'published_at' => now(),
            'published_payload' => json_encode(['self_intro' => 'First published introduction',
                'interest_tags' => ['reading'], 'lifestyle_tags' => ['early_riser']]),
            'public_display_eligible' => true] + $stamp);
        $body = ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'accept-a'];
        $url = "/api/v1/journey/proposals/$id/decision";
        $this->actingAs($a, 'sanctum')->postJson($url, $body)->assertOk()
            ->assertJsonPath('showcase.summary', 'First published introduction')
            ->assertJsonPath('showcase.interest_tags', ['reading'])
            ->assertJsonMissing(['summary' => 'Unpublished private draft']);
        DB::table('user_profile_showcase_publications')->where('user_id', $b->id)->update([
            'published_payload' => json_encode(['self_intro' => 'Later published introduction',
                'interest_tags' => ['music'], 'lifestyle_tags' => []]), 'updated_at' => now(),
        ]);
        $this->postJson($url, $body)->assertOk()->assertJsonPath('state', 'ACCEPTED_BY_ONE')
            ->assertJsonPath('revision', 2)->assertJsonPath('showcase.summary', 'Later published introduction')
            ->assertJsonPath('showcase.interest_tags', ['music'])
            ->assertJsonMissing(['summary' => 'First published introduction']);
        $this->assertDatabaseCount('journey_commands', 1);
        $this->assertDatabaseHas('match_proposals', ['id' => $id, 'revision' => 2, 'decision_a' => 'ACCEPTED']);
    }

    public function test_proposal_expiry_removes_new_connection_context_but_preserves_existing_explicit_consents(): void
    {
        $a = $this->subject('a'); $b = $this->subject('b');
        $this->qualify($a, $b);
        $id = $this->proposalFixture($a, $b);
        $url = "/api/v1/journey/proposals/$id/decision";
        $this->actingAs($a, 'sanctum')->postJson($url,
            ['action' => 'accept', 'revision' => 1, 'idempotency_key' => 'accept-a'])->assertOk();
        $this->actingAs($b, 'sanctum')->postJson($url,
            ['action' => 'accept', 'revision' => 2, 'idempotency_key' => 'accept-b'])->assertOk()
            ->assertJsonPath('state', 'MUTUALLY_ACCEPTED')->assertJsonPath('connection_eligible', true);
        $live = app(LiveConsentService::class);
        $this->assertNotNull($live->match($a->id, $b->id));
        $this->assertDatabaseCount('product_connections', 0);
        foreach (['connection', 'consent'] as $kind) {
            $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/$kind",
                ['action' => 'request', 'expected_revision' => 0])->assertOk();
            $this->actingAs($b, 'sanctum')->postJson("/api/v1/connections/{$a->id}/$kind",
                ['action' => 'accept', 'expected_revision' => 1])->assertOk();
        }
        $current = $this->getJson("/api/v1/connections/{$a->id}")->assertOk()
            ->assertJsonPath('gates.live_read_allowed', true)
            ->assertJsonPath('gates.live_send_allowed', true)->json('connection');
        $this->travel(169)->hours();
        $this->assertNull($live->match($a->id, $b->id));
        $proposal = app(SlowDatingService::class)->proposal($a->id, $id);
        $this->assertNull($proposal['showcase']);
        $this->assertNull($proposal['explanation']);
        $this->assertFalse($proposal['connection_eligible']);
        $this->getJson("/api/v1/connections/{$a->id}")->assertOk()
            ->assertJsonPath('connection.id', $current['id'])
            ->assertJsonPath('gates.live_read_allowed', true)
            ->assertJsonPath('gates.live_send_allowed', true);
        $closed = $this->actingAs($a, 'sanctum')->postJson("/api/v1/connections/{$b->id}/connection",
            ['action' => 'close', 'expected_revision' => $current['revision'],
                'expected_connection_id' => $current['id']])->assertOk()
            ->assertJsonPath('connection.state', 'CN_CLOSED')
            ->assertJsonPath('gates.live_send_allowed', false)->json('connection');
        $this->postJson("/api/v1/connections/{$b->id}/connection", ['action' => 'request',
            'expected_revision' => $closed['revision'], 'expected_connection_id' => $closed['id']])->assertNotFound();
        $this->assertDatabaseCount('product_connections', 1);
        $this->assertDatabaseCount('friendships', 0);
        $this->assertDatabaseCount('social_requests', 0);
        $this->assertDatabaseHas('product_connections', ['id' => $closed['id'], 'state' => 'CN_CLOSED']);
    }

    /** A revealed product proposal, with real foreign-key parents and no matching execution. */
    private function proposalFixture(User $a, User $b): string
    {
        $stamp = ['created_at' => now(), 'updated_at' => now()];
        DB::table('dating_round_channels')->insertOrIgnore(['channel_key' => 'v1012-test'] + $stamp);
        $round = DB::table('dating_rounds')->insertGetId(['round_key' => Str::uuid()->toString(),
            'channel_key' => 'v1012-test', 'cadence_key' => Str::uuid()->toString(), 'state' => 'revealed',
            'created_by_type' => 'test', 'source' => 'test'] + $stamp);
        $run = DB::table('matching_runs')->insertGetId(['round_id' => $round, 'run_key' => Str::uuid()->toString(),
            'idempotency_key' => 'fixture-run-'.Str::uuid()->toString(), 'correlation_id' => Str::uuid()->toString(), 'attempt_no' => 1,
            'state' => 'succeeded', 'trigger_source' => 'test', 'actor_type' => 'test',
            'eligibility_cutoff_at' => now(), 'algorithm_version' => 'test', 'config_version' => 'test'] + $stamp);
        $match = DB::table('dating_matches')->insertGetId(['week_tag' => 'v1012', 'round_id' => $round,
            'matching_run_id' => $run, 'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => true] + $stamp);
        $id = Str::uuid()->toString();
        DB::table('match_proposals')->insert(['id' => $id, 'dating_match_id' => $match, 'round_id' => $round,
            'run_id' => $run, 'user_a' => $a->id, 'user_b' => $b->id, 'generation_a' => 1, 'generation_b' => 1,
            'revealed_at' => now(), 'expires_at' => now()->addHours(168)] + $stamp);
        foreach ([$a, $b] as $user) {
            DB::table('matching_participations')->insert(['user_id' => $user->id, 'state' => 'ACTIVE',
                'generation' => 1, 'revision' => 1, 'opted_in_at' => now()] + $stamp);
            DB::table('match_proposal_slots')->insert(['user_id' => $user->id, 'proposal_id' => $id]);
        }
        return $id;
    }
}
