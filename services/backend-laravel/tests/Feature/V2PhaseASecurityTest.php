<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\User;
use App\Services\ProfileReadinessService;
use App\Services\SlowDatingService;
use App\Services\TrustedIdentityService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;
use Tests\TestCase;

final class V2PhaseASecurityTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'journey.test_issuer_enabled' => true,
            'journey.test_issuer_key' => str_repeat('phase-a-fixture-', 3)]);
    }

    private function subject(): User
    {
        return User::factory()->create(['phone' => (string) Str::uuid(), 'verify_status' => 'approved',
            'realname_verified' => true, 'is_match_eligible' => true, 'disabled' => false,
            'account_status' => 'active', 'moderation_status' => 'normal']);
    }

    public function test_operational_and_forged_identity_flags_cannot_enroll_or_reuse_old_automation_receipt(): void
    {
        $u = $this->subject();
        $this->completeLifestyleFixture($u->id);
        $this->assertSame('real_identity_unavailable', app(ProfileReadinessService::class)->forUser($u)['matching_eligibility']['reason_code']);
        $this->actingAs($u, 'sanctum')->putJson('/api/v1/journey/participation', [
            'action' => 'opt_in', 'revision' => 0, 'intent' => 'fixture'])->assertStatus(403);
        $this->assertDatabaseCount('matching_participations', 0);
        $data = ['action' => 'grant', 'expected_revision' => 0, 'request_key' => (string) Str::uuid(),
            'policy_version' => config('user_automation.policy_version'), 'consent_version' => config('user_automation.consent_version')];
        DB::table('automation_commands')->insert(['user_id' => $u->id, 'request_key' => $data['request_key'],
            'request_hash' => hash('sha256', json_encode(['grant', 0, $data['policy_version'], $data['consent_version'], null], JSON_THROW_ON_ERROR)),
            'action' => 'grant', 'applied_revision' => 1, 'created_at' => now()]);
        $this->putJson('/api/v1/automations/weekly_slow_dating_participation', $data)->assertStatus(403);
        $this->assertFalse(app(SlowDatingService::class)->enrolled($u->id));
        $this->assertCount(0, app(ProfileReadinessService::class)->eligibleUsersQuery()->get());
    }

    public function test_only_signed_current_synthetic_credentials_in_memory_can_use_test_business(): void
    {
        $u = $this->subject();
        $u->update(['is_synthetic' => true]);
        $identity = app(TrustedIdentityService::class);
        $identity->register($u->id);
        $this->assertFalse($identity->participationAllowed($u->id));
        $key = $identity->issue($u->id, 'phase-a-nonce');
        $this->assertTrue($identity->participationAllowed($u->id));
        app()->instance('env', 'production');
        $this->assertFalse($identity->participationAllowed($u->id));
        app()->instance('env', 'testing');
        DB::table('identity_assertions')->where('id', $key)->update(['signature' => str_repeat('0', 64)]);
        $this->assertFalse($identity->participationAllowed($u->id));
        $key = $identity->issue($u->id, 'new-valid-nonce');
        $this->assertFalse($identity->status($u->id)['formal_participation_available']);
        $this->assertTrue($identity->status($u->id)['test_only']);
        $identity->revoke($u->id, $key);
        $this->assertFalse($identity->participationAllowed($u->id));
        $identity->issue($u->id, 'expires', 1);
        $this->travel(2)->minutes();
        $this->assertFalse($identity->participationAllowed($u->id));
    }

    public function test_lifestyle_command_query_is_read_only_scoped_and_distinguishes_absent_applied_and_conflict(): void
    {
        $a = $this->subject();
        $b = $this->subject();
        $body = ['action' => 'answer', 'expected_revision' => 0, 'questionnaire_version' => 'lifestyle_v1',
            'request_key' => (string) Str::uuid(), 'scene_id' => 'home_atmosphere', 'option_id' => 'quiet'];
        $url = '/api/v1/profile/lifestyle-discovery/command-result?'.http_build_query($body);
        $this->actingAs($a, 'sanctum')->getJson($url)->assertOk()->assertJsonPath('command_status', 'NOT_APPLIED');
        $this->assertDatabaseCount('lifestyle_discoveries', 0);
        $this->putJson('/api/v1/profile/lifestyle-discovery', $body)->assertOk();
        $this->getJson($url)->assertOk()->assertJsonPath('command_status', 'APPLIED')->assertJsonPath('current.revision', 1);
        $this->actingAs($b, 'sanctum')->getJson($url)->assertOk()->assertJsonPath('command_status', 'NOT_APPLIED');
        $this->actingAs($a, 'sanctum')->getJson($url.'&option_id=other')->assertStatus(409);
        $this->assertDatabaseCount('lifestyle_discovery_commands', 1);
        $this->assertDatabaseCount('lifestyle_discoveries', 1);
    }

    public function test_legacy_matching_cli_cannot_delete_create_or_release_candidates(): void
    {
        $a = $this->subject();
        $b = $this->subject();
        $match = DatingMatch::create(['week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => $a->id, 'user_b' => $b->id, 'drop_released' => false]);
        $this->artisan('app:dev:run-matching', ['--reset-week' => true, '--release-drop' => true])->assertFailed();
        $this->assertDatabaseCount('dating_matches', 1);
        $this->assertFalse((bool) $match->fresh()->drop_released);
    }

    public function test_additive_migration_is_reversible_without_touching_existing_business_tables(): void
    {
        $user = $this->subject();
        $migration = require database_path('migrations/2026_11_19_230000_phase_a_candidate_and_comment_authority.php');
        $migration->down();
        $this->assertDatabaseHas('users', ['id' => $user->id]);
        $this->assertTrue(Schema::hasTable('match_proposals'));
        $migration->up();
        $this->assertDatabaseCount('candidate_showcase_bindings', 0);
        $this->assertTrue(Schema::hasColumn('status_post_comments', 'original_viewer_ids'));
    }
}
