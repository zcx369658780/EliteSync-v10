<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Admin\UserGovernance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class V1008SanctionAppealTest extends TestCase
{
    use RefreshDatabase;

    private User $admin;
    private User $owner;
    private User $other;
    private int $sanction;

    protected function setUp(): void
    {
        parent::setUp();
        config(['app.key' => str_repeat('r', 32)]);
        $this->admin = User::create(['phone' => '19900000901', 'name' => 'Fictional appeal admin', 'password' => 'fixture-password', 'role' => 'admin']);
        $this->owner = User::create(['phone' => '19900000902', 'name' => 'Fictional restricted owner', 'password' => 'fixture-password', 'role' => 'user', 'account_status' => 'active']);
        $this->other = User::create(['phone' => '19900000903', 'name' => 'Fictional non-owner', 'password' => 'fixture-password', 'role' => 'user', 'account_status' => 'active']);
        config(['app.admin_phones' => [$this->admin->phone]]);
        $this->sanction = app(UserGovernance::class)->punish($this->admin, $this->owner->id, 'restrict', 'Private reporter detail must never appear', 0);
    }

    private function endpoint(?int $id = null): string
    {
        return '/api/v1/moderation/sanctions/'.($id ?? $this->sanction).'/appeals';
    }

    public function test_owner_lists_minimal_current_restriction_and_submits_without_changing_authority(): void
    {
        $before = $this->authority();
        $this->actingAs($this->owner, 'sanctum')->getJson('/api/v1/moderation/sanctions')
            ->assertOk()->assertJsonPath('items.0.id', $this->sanction)
            ->assertJsonPath('items.0.appeal', null)->assertDontSee('Private reporter detail');
        $response = $this->postJson($this->endpoint(), ['note' => ' Please review my restriction. '])->assertCreated()
            ->assertJsonPath('sanction_id', $this->sanction)->assertJsonPath('appeal.status', 'submitted')
            ->assertJsonPath('appeal.note', 'Please review my restriction.');
        $this->assertDatabaseHas('sanction_appeals', ['sanction_id' => $this->sanction, 'user_id' => $this->owner->id, 'status' => 'submitted']);
        $this->assertSame($before, $this->authority());
        $this->assertArrayNotHasKey('user_id', $response->json('appeal'));
        $this->assertArrayNotHasKey('report_id', $response->json('appeal'));
    }

    public function test_exact_duplicate_is_idempotent_but_changed_note_conflicts(): void
    {
        $this->actingAs($this->owner, 'sanctum');
        $first = $this->postJson($this->endpoint(), ['note' => 'Review please'])->assertCreated()->json('appeal');
        $this->postJson($this->endpoint(), ['note' => 'Review please'])->assertOk()->assertJsonPath('appeal.id', $first['id']);
        $this->postJson($this->endpoint(), ['note' => 'Different note'])->assertConflict();
        $this->assertDatabaseCount('sanction_appeals', 1);
    }

    public function test_non_owner_unknown_and_forged_actor_are_rejected(): void
    {
        $this->actingAs($this->other, 'sanctum')->postJson($this->endpoint(), ['note' => 'not mine'])->assertNotFound();
        $this->getJson('/api/v1/moderation/sanctions?user_id='.$this->owner->id)->assertOk()->assertJsonPath('items', []);
        $this->actingAs($this->owner, 'sanctum')->postJson($this->endpoint(999999), ['note' => 'missing'])->assertNotFound();
        $this->postJson($this->endpoint(), ['note' => 'forged', 'user_id' => $this->other->id])->assertUnprocessable();
        $this->assertDatabaseCount('sanction_appeals', 0);
    }

    public function test_inactive_restored_wrong_kind_and_stale_account_state_fail_closed(): void
    {
        $this->actingAs($this->owner, 'sanctum');
        foreach ([['active' => false], ['restored_at' => now()], ['kind' => 'banned']] as $change) {
            DB::table('admin_sanctions')->where('id', $this->sanction)->update($change);
            $this->postJson($this->endpoint(), ['note' => 'no longer valid'])->assertNotFound();
            DB::table('admin_sanctions')->where('id', $this->sanction)->update(['active' => true, 'restored_at' => null, 'kind' => 'restrict']);
        }
        DB::table('users')->where('id', $this->owner->id)->update(['moderation_status' => 'normal']);
        $this->postJson($this->endpoint(), ['note' => 'stale owner object'])->assertNotFound();
        $this->assertDatabaseCount('sanction_appeals', 0);
    }

    public function test_disabled_cached_identity_and_unauthenticated_access_are_rejected(): void
    {
        $this->getJson('/api/v1/moderation/sanctions')->assertUnauthorized();
        $this->actingAs($this->owner, 'sanctum');
        DB::table('users')->where('id', $this->owner->id)->update(['disabled' => true]);
        $this->postJson($this->endpoint(), ['note' => 'old identity'])->assertForbidden();
        $this->getJson('/api/v1/moderation/sanctions')->assertForbidden();
        $this->assertDatabaseCount('sanction_appeals', 0);
    }

    public function test_note_validation_and_admin_read_is_escaped_minimal_and_audited(): void
    {
        $this->actingAs($this->owner, 'sanctum');
        foreach (['', '   ', str_repeat('x', 1001)] as $note) {
            $this->postJson($this->endpoint(), ['note' => $note])->assertUnprocessable();
        }
        $this->postJson($this->endpoint(), ['note' => '<script>private appeal</script>'])->assertCreated();
        $url = '/admin/users/'.$this->owner->id;
        $this->actingAs($this->other, 'web')->get($url)->assertForbidden();
        $before = DB::table('admin_operation_audits')->where('action', 'sanction_appeal.view')->count();
        $this->actingAs($this->admin, 'web')->get($url)->assertOk()
            ->assertSee('&lt;script&gt;private appeal&lt;/script&gt;', false)
            ->assertDontSee('<script>private appeal</script>', false);
        $this->assertSame($before + 1, DB::table('admin_operation_audits')->where('action', 'sanction_appeal.view')->count());
        $audit = DB::table('admin_operation_audits')->where('action', 'sanction_appeal.view')->first();
        $this->assertSame($this->admin->id, $audit->actor_user_id);
        $this->assertStringNotContainsString('private appeal', $audit->after_state);
    }

    public function test_restore_disallows_resubmission_and_retains_original_appeal(): void
    {
        $this->actingAs($this->owner, 'sanctum')->postJson($this->endpoint(), ['note' => 'keep this record'])->assertCreated();
        app(UserGovernance::class)->restore($this->admin, $this->owner->id, $this->sanction, 'explicit independent restore', 1);
        $this->postJson($this->endpoint(), ['note' => 'keep this record'])->assertNotFound();
        $this->getJson('/api/v1/moderation/sanctions')->assertOk()->assertJsonPath('items', []);
        $this->assertDatabaseHas('sanction_appeals', ['sanction_id' => $this->sanction, 'note' => 'keep this record']);
    }

    private function authority(): array
    {
        return [json_encode(DB::table('users')->where('id', $this->owner->id)->first()),
            DB::table('admin_sanctions')->orderBy('id')->get()->toJson(),
            DB::table('product_connections')->orderBy('id')->get()->toJson(),
            DB::table('messaging_consents')->orderBy('id')->get()->toJson(),
            DB::table('personal_access_tokens')->get()->toJson()];
    }
}
