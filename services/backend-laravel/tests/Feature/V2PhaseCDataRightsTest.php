<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\ObjectDataRequestService;
use App\Services\ProfileShowcase\ShowcaseWorkflow;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Tests\TestCase;

final class V2PhaseCDataRightsTest extends TestCase
{
    use RefreshDatabase;

    private function account(bool $synthetic = false): User
    {
        $user = User::factory()->create(['phone' => (string) Str::uuid(), 'city' => 'Fixture city']);
        if ($synthetic) {
            $this->authorizeTestParticipation($user);
        }

        return $user;
    }

    public function test_missing_basis_does_not_grant_cross_use_or_accept_deletion(): void
    {
        $owner = $this->account();
        $this->getJson('/api/v1/data-rights/showcase-city')->assertUnauthorized();
        $this->actingAs($owner, 'sanctum')->getJson('/api/v1/data-rights/showcase-city')
            ->assertOk()->assertJsonPath('state', 'LEGAL_BASIS_UNVERIFIED');
        $this->putJson('/api/v1/data-rights/showcase-city', ['state' => 'GRANTED', 'expected_revision' => 0,
            'confirm' => true])->assertConflict();
        $work = $this->postJson('/api/v1/status/posts', ['title' => 'Own work', 'body' => 'Test work'])
            ->assertCreated()->json('item.id');
        $url = "/api/v1/data-rights/objects/work/$work";
        $this->getJson($url)->assertOk()->assertJsonPath('channel', 'REQUEST_CHANNEL_UNAVAILABLE')
            ->assertJsonPath('completion_available', false)->assertJsonMissingPath('receipt');
        $this->postJson($url, ['expected_version' => '1-present', 'confirm' => true, 'request_key' => (string) Str::uuid()])
            ->assertConflict();
        $this->assertDatabaseCount('object_data_requests', 0);
        $this->assertDatabaseCount('data_purpose_grants', 0);
    }

    public function test_correction_only_blocks_dependent_new_publication_and_revocation_removes_city(): void
    {
        $owner = $this->account(true);
        $friend = $this->account();
        $admin = User::factory()->create(['phone' => (string) Str::uuid(), 'role' => 'admin']);
        config(['app.admin_phones' => [$admin->phone]]);
        DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $friend->id, 'state' => 'ACTIVE',
            'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $this->actingAs($owner, 'sanctum');
        $purpose = '/api/v1/data-rights/showcase-city';
        $this->putJson($purpose, ['state' => 'DECLINED', 'expected_revision' => 0, 'confirm' => true])->assertOk();
        $this->postJson("$purpose/reuse", ['expected_revision' => 0, 'confirm' => true])->assertConflict();
        $this->putJson('/api/v1/profile/showcase/draft', ['expected_revision' => 0,
            'self_intro' => 'Independent', 'audiences' => ['friends']])->assertOk();
        $this->putJson($purpose, ['state' => 'GRANTED', 'expected_revision' => 1, 'confirm' => true])->assertOk();
        $this->postJson("$purpose/reuse", ['expected_revision' => 1, 'confirm' => true])->assertOk()
            ->assertJsonPath('draft.city', 'Fixture city')->assertJsonPath('draft.city_derivation_state', 'CURRENT');
        $workflow = app(ShowcaseWorkflow::class);
        $submission = $workflow->submit($owner->id, 2)['submission'];
        $workflow->review($admin, $submission['id'], 2, 'approved', 'Synthetic');
        $workflow->publish($owner->id, 2, 0);
        $this->postJson('/api/v1/profile/city', ['city' => 'Corrected city'])->assertOk();
        $this->getJson($purpose)->assertOk()->assertJsonPath('derivation_state', 'NEEDS_REVIEW');
        $this->postJson('/api/v1/profile/showcase/draft/submit-review', ['expected_revision' => 2])->assertConflict();
        $this->actingAs($friend, 'sanctum')->getJson("/api/v1/profile/showcase/$owner->id")
            ->assertOk()->assertJsonPath('publication.public_fields.city', 'Fixture city');
        $this->actingAs($owner, 'sanctum')->postJson("$purpose/reuse", ['expected_revision' => 2, 'confirm' => true])
            ->assertOk()->assertJsonPath('draft.city', 'Corrected city');
        $next = $workflow->submit($owner->id, 3)['submission'];
        $workflow->review($admin, $next['id'], 3, 'approved', 'Synthetic');
        $this->postJson('/api/v1/profile/city', ['city' => 'New source'])->assertOk();
        $this->postJson('/api/v1/profile/showcase/publication', ['expected_revision' => 3, 'publication_revision' => 1,
            'confirm_public_display' => true])->assertConflict();
        $this->putJson($purpose, [
            'state' => 'REVOKED', 'expected_revision' => 2, 'confirm' => true,
        ])->assertOk();
        $this->getJson('/api/v1/profile/showcase/draft')->assertOk()->assertJsonPath('draft.city', null)
            ->assertJsonMissingPath('submission.snapshot.city');
        $this->actingAs($friend, 'sanctum')->getJson("/api/v1/profile/showcase/$owner->id")->assertOk()
            ->assertJsonMissingPath('publication.public_fields.city')
            ->assertJsonPath('publication.public_fields.self_intro', 'Independent');
        $this->actingAs($owner, 'sanctum')->putJson('/api/v1/profile/showcase/draft', ['expected_revision' => 3,
            'city' => 'Manually entered', 'self_intro' => 'Independent', 'audiences' => ['friends']])
            ->assertOk()->assertJsonPath('draft.city_derivation_state', 'INDEPENDENT');
        $this->postJson('/api/v1/profile/showcase/draft/submit-review', ['expected_revision' => 4])->assertOk();

        (require database_path('migrations/2026_11_20_120000_create_phase_c_data_rights.php'))->down();
        $this->assertDatabaseHas('user_profile_showcase_publications',
            ['user_id' => $owner->id, 'publication_status' => 'withdrawn', 'public_display_eligible' => false]);
        $archived = DB::table('profile_showcase_submissions')->where('id', $submission['id'])->value('snapshot');
        $this->assertArrayNotHasKey('city', json_decode($archived, true, 512, JSON_THROW_ON_ERROR));
        $this->assertDatabaseHas('user_profile_showcase_drafts', ['user_id' => $owner->id, 'city' => 'Manually entered']);
    }

    public function test_comment_owner_can_request_test_status_after_losing_work_read_access(): void
    {
        $owner = $this->account(true);
        $author = $this->account(true);
        DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $author->id, 'state' => 'ACTIVE',
            'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $work = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts', [
            'title' => 'Work', 'body' => 'Original work',
        ])->assertCreated()->json('item.id');
        $comment = $this->actingAs($author, 'sanctum')->postJson("/api/v1/status-posts/$work/comments",
            ['body' => 'My contribution', 'idempotency_key' => 'phase-c-comment'])->assertCreated()->json('id');
        $url = "/api/v1/data-rights/objects/comment/$comment";
        $this->actingAs($owner, 'sanctum')->getJson($url)->assertNotFound();
        $this->putJson("/api/v1/status/posts/$work/audience", ['audience' => 'SELF'])->assertOk();
        $this->actingAs($author, 'sanctum')->getJson("/api/v1/status/posts/$work")->assertNotFound();
        $this->getJson('/api/v1/data-rights/objects?type=comment')->assertOk()->assertJsonPath('items.0.key', $comment)
            ->assertJsonMissingPath('items.0.body')->assertJsonMissingPath('items.0.status_post_id');
        $this->getJson($url)->assertOk()->assertJsonPath('state', 'NO_REQUEST');
        $key = (string) Str::uuid();
        $this->getJson("$url/result?request_key=$key")->assertOk()->assertJsonPath('state', 'NOT_APPLIED');
        $body = ['request_key' => $key, 'confirm' => true, 'expected_version' => '1'];
        $this->postJson($url, array_replace($body, ['expected_version' => '0']))->assertConflict();
        $this->postJson($url, $body)->assertOk()->assertJsonPath('state', 'REQUESTED_TEST_ONLY');
        $this->postJson($url, $body)->assertOk()->assertJsonPath('state', 'REQUESTED_TEST_ONLY');
        $this->postJson($url, array_replace($body, ['request_key' => (string) Str::uuid()]))->assertConflict();
        $processor = app(ObjectDataRequestService::class);
        $processor->advanceTestOnly($author->id, $key, 'REQUESTED_TEST_ONLY');
        $this->getJson("$url/result?request_key=$key")->assertOk()->assertJsonPath('state', 'ACCEPTED_TEST_ONLY');
        $processor->advanceTestOnly($author->id, $key, 'ACCEPTED_TEST_ONLY');
        $this->getJson("$url/result?request_key=$key")->assertOk()->assertJsonPath('state', 'PROCESSING_TEST_ONLY')
            ->assertJsonMissingPath('receipt');
        $this->assertDatabaseHas('status_post_comments', ['id' => $comment, 'body' => 'My contribution']);
        $this->assertDatabaseCount('object_data_requests', 1);
    }

    public function test_profile_correction_does_not_run_optional_tools(): void
    {
        $owner = $this->account();
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/profile/basic', ['gender' => 'female',
            'city' => 'Current city', 'relationship_goal' => 'friendship', 'birthday' => '1995-08-12',
            'birth_time' => '09:55'])->assertOk()->assertJsonPath('astro_profile', null)
            ->assertJsonPath('user.birth_time', '09:55');
        $this->getJson('/api/v1/profile/basic')->assertOk()->assertJsonPath('birth_time', '09:55');

        $this->postJson('/api/v1/profile/basic', ['gender' => 'female', 'city' => 'Current city',
            'relationship_goal' => 'friendship', 'birthday' => '1995-08-12', 'birth_time' => ''])
            ->assertOk()->assertJsonPath('recomputed_at', null)->assertJsonPath('astro_profile', null)
            ->assertJsonPath('user.birth_time', null);
        $this->getJson('/api/v1/profile/basic')->assertOk()->assertJsonPath('birth_time', null);
        $this->assertNull($owner->fresh()->private_birth_time);
        $this->assertDatabaseCount('user_astro_profiles', 0);
        $this->assertDatabaseCount('user_natal_profiles', 0);
    }

    public function test_login_reads_only_confirmed_account_birth_details(): void
    {
        $owner = $this->account();
        $password = 'Synthetic-local-2026';
        $owner->forceFill(['phone' => '19920261120', 'password' => Hash::make($password), 'private_birth_time' => '09:55'])->save();
        UserAstroProfile::create(['user_id' => $owner->id, 'birth_time' => '12:00', 'birth_place' => 'Legacy derived',
            'birth_lat' => 1.0, 'birth_lng' => 2.0, 'sun_sign' => 'legacy']);
        $this->postJson('/api/v1/auth/login', ['phone' => $owner->phone, 'password' => $password])
            ->assertOk()->assertJsonPath('user.birth_time', '09:55')->assertJsonPath('user.birth_place', null)
            ->assertJsonPath('user.birth_lat', null)->assertJsonPath('user.birth_lng', null);
    }

    public function test_legacy_calculation_reuse_unverified_and_test_only_permission_expire(): void
    {
        $owner = $this->account(true);
        $this->actingAs($owner, 'sanctum');
        $purpose = '/api/v1/data-rights/showcase-city';
        $this->putJson($purpose, ['state' => 'GRANTED', 'expected_revision' => 0, 'confirm' => true])->assertOk();
        DB::table('data_purpose_grants')->where('user_id', $owner->id)->update(['expires_at' => now()->subMinute()]);
        $this->getJson($purpose)->assertOk()->assertJsonPath('state', 'EXPIRED');
        $this->postJson("$purpose/reuse", ['expected_revision' => 0, 'confirm' => true])->assertConflict();
        $this->postJson('/api/v1/profile/astro', ['birth_time' => '09:00'])->assertConflict()
            ->assertJsonPath('code', 'LEGAL_BASIS_UNVERIFIED');
        $this->assertDatabaseCount('user_astro_profiles', 0);
    }

    public function test_work_request_survives_takedown_without_altering_third_party_comment(): void
    {
        $owner = $this->account(true);
        $friend = $this->account();
        DB::table('friendships')->insert(['user_a' => $owner->id, 'user_b' => $friend->id, 'state' => 'ACTIVE',
            'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $work = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/status/posts',
            ['title' => 'Work', 'body' => 'Owned context'])->assertCreated()->json('item.id');
        $comment = $this->actingAs($friend, 'sanctum')->postJson("/api/v1/status-posts/$work/comments",
            ['body' => 'Independent material', 'idempotency_key' => 'third-party'])->assertCreated()->json('id');
        $url = "/api/v1/data-rights/objects/work/$work";
        $this->getJson($url)->assertNotFound();
        $this->actingAs($owner, 'sanctum')->deleteJson("/api/v1/status/posts/$work")->assertOk();
        $this->getJson($url)->assertOk()->assertJsonPath('object_version', '1-withdrawn')->assertJsonPath('state', 'NO_REQUEST');
        $this->postJson($url, ['request_key' => (string) Str::uuid(), 'confirm' => true, 'expected_version' => '1-withdrawn'])
            ->assertOk()->assertJsonPath('state', 'REQUESTED_TEST_ONLY');
        $this->assertDatabaseHas('status_post_comments', ['id' => $comment, 'body' => 'Independent material']);
    }

    public function test_dynamic_natal_permission_is_independent_and_revocation_hides_saved_and_archived_results(): void
    {
        config(['dynamic_charts.enabled' => true]);
        $owner = $this->account(true);
        $this->actingAs($owner, 'sanctum');
        $first = ['source' => 'own_natal', 'revision' => 7];
        $request = ['first' => $first, 'chart_type' => 'transit'];
        $this->putJson('/api/v1/data-rights/showcase-city', ['state' => 'GRANTED',
            'expected_revision' => 0, 'confirm' => true])->assertOk();
        $this->postJson('/api/v1/profile/dynamic', $request)->assertConflict()
            ->assertJsonPath('code', 'PURPOSE_PERMISSION_REQUIRED');
        $purpose = '/api/v1/data-rights/dynamic-natal';
        $this->putJson($purpose, ['state' => 'GRANTED', 'expected_revision' => 0, 'confirm' => true])
            ->assertOk()->assertJsonPath('audience', 'SELF_ONLY');
        $chart = \App\Models\UserDynamicChart::create([
            'user_id' => $owner->id, 'chart_type' => 'transit', 'request' => $request,
            'settings' => [], 'prepared' => ['_purpose_grant_revision' => 1], 'input_signature' => str_repeat('1', 64),
            'input_revision' => 1, 'result_revision' => 1, 'results' => ['sample' => 'Synthetic old result'],
            'status' => 'COMPUTED_UNVERIFIED',
        ]);
        // Missing natal revision is independently stale even while the purpose is valid.
        $url = "/api/v1/profile/dynamic/$chart->id";
        $this->getJson($url)->assertOk()->assertJsonPath('chart.status', 'STALE_RECALCULATION_REQUIRED')
            ->assertJsonPath('chart.results', null);
        app(\App\Services\ToolRevisionHistory::class)->archive($chart, 'dynamic');
        $archive = DB::table('user_tool_revisions')->where('user_id', $owner->id)->value('id');
        $this->getJson("$url/history/$archive")->assertOk()->assertJsonPath('chart.purpose_revision', 1)
            ->assertJsonPath('chart.status', 'STALE_RECALCULATION_REQUIRED')->assertJsonPath('chart.results', null);
        $this->putJson($purpose, ['state' => 'REVOKED', 'expected_revision' => 1, 'confirm' => true])->assertOk();
        $this->getJson($url)->assertOk()->assertJsonPath('chart.status', 'PURPOSE_UNAVAILABLE')->assertJsonPath('chart.results', null);
        $this->getJson("$url/history/$archive")->assertOk()->assertJsonPath('chart.status', 'PURPOSE_UNAVAILABLE')
            ->assertJsonMissingPath('chart.request');
        $this->putJson($purpose, ['state' => 'GRANTED', 'expected_revision' => 2, 'confirm' => true])->assertOk();
        $this->getJson($url)->assertOk()->assertJsonPath('chart.status', 'PURPOSE_UNAVAILABLE');
        $chart->update(['request' => ['first' => ['source' => 'manual']], 'prepared' => []]);
        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Dynamic natal reuse requires a safe downgrade plan.');
        (require database_path('migrations/2026_11_20_120000_create_phase_c_data_rights.php'))->down();
    }

}
