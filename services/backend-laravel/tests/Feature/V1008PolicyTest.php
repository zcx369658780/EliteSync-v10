<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Accounts\DisableUser;
use App\Services\Admin\UserGovernance;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class V1008PolicyTest extends TestCase
{
    use RefreshDatabase;

    private function users(): array
    {
        $a = User::create(['phone' => '19900000801', 'password' => 'fixture-password', 'role' => 'admin']);
        config(['app.admin_phones' => [$a->phone]]);

        return [$a, User::create(['phone' => '19900000802', 'password' => 'fixture-password', 'role' => 'user'])];
    }

    public function test_review_is_versioned_audited_and_stale_request_is_atomic(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $s->review($a, $u->id, 'approved', 'operating eligibility approved', 0);
        $this->assertSame('approved', $u->fresh()->verify_status);
        $this->assertDatabaseCount('admin_operation_audits', 1);
        try {
            $s->review($a, $u->id, 'rejected', 'stale', 0);
            $this->fail('stale accepted');
        } catch (HttpException $e) {
            $this->assertSame(409, $e->getStatusCode());
        }
        $this->assertSame('approved', $u->fresh()->verify_status);
        $this->assertDatabaseCount('admin_operation_audits', 1);
    }

    public function test_restrict_does_not_clear_ban_and_restore_requires_exact_owned_sanction(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $u->createToken('old');
        DB::table('sessions')->insert(['id' => 'old-session', 'user_id' => $u->id, 'payload' => '', 'last_activity' => time()]);
        $ban = $s->punish($a, $u->id, 'banned', 'ban fixture', 0);
        $restriction = $s->punish($a, $u->id, 'restrict', 'independent restriction', 1);
        $this->assertTrue($u->fresh()->disabled);
        $this->assertDatabaseMissing('sessions', ['user_id' => $u->id]);
        $this->assertSame(0, $u->tokens()->count());
        $s->restore($a, $u->id, $ban, 'undo own ban', 2);
        $this->assertFalse($u->fresh()->disabled);
        $this->assertSame('restricted', $u->fresh()->moderation_status);
        $s->restore($a, $u->id, $restriction, 'undo restriction', 3);
        $this->assertSame('normal', $u->fresh()->moderation_status);
        $this->assertSame(0, $u->tokens()->count());
    }

    public function test_role_only_actor_and_admin_targets_are_refused(): void
    {
        [$a,$u] = $this->users();
        config(['app.admin_phones' => []]);
        try {
            app(UserGovernance::class)->review($a, $u->id, 'approved', 'denied', 0);
            $this->fail('unauthorized');
        } catch (HttpException $e) {
            $this->assertSame(403, $e->getStatusCode());
        }
        $this->assertSame('pending', $u->fresh()->verify_status);
    }

    public function test_restrict_restore_preserves_independent_visibility_and_metrics(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $u->forceFill(['visibility_scope' => 'hidden', 'is_square_visible' => false, 'exclude_from_metrics' => true, 'is_match_eligible' => false])->save();
        $id = $s->punish($a, $u->id, 'restrict', 'fixture restricted', 0);
        $row = DB::table('admin_sanctions')->find($id);
        $prior = json_decode($row->prior_state, true);
        $this->assertSame('hidden', $prior['attributes']['visibility_scope']);
        $s->restore($a, $u->id, $id, 'restore restriction only', 1);
        $this->assertDatabaseHas('users', ['id' => $u->id, 'disabled' => false, 'moderation_status' => 'normal',
            'visibility_scope' => 'hidden', 'is_square_visible' => false, 'exclude_from_metrics' => true, 'is_match_eligible' => false]);
        $this->assertDatabaseHas('admin_sanctions', ['id' => $id, 'active' => false]);
    }

    public function test_last_ban_restores_original_fields_and_keeps_changes_from_independent_writer(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $u->forceFill(['visibility_scope' => 'hidden', 'is_square_visible' => false, 'exclude_from_metrics' => true])->save();
        $id = $s->punish($a, $u->id, 'banned', 'fixture ban', 0);
        $u->fresh()->forceFill(['visibility_scope' => 'private'])->save();
        $s->restore($a, $u->id, $id, 'restore own changes', 1);
        $this->assertDatabaseHas('users', ['id' => $u->id, 'disabled' => false, 'moderation_status' => 'normal',
            'visibility_scope' => 'private', 'is_square_visible' => false, 'exclude_from_metrics' => true]);
    }

    public function test_overlapping_bans_and_restriction_restore_in_both_orders(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $u->forceFill(['visibility_scope' => 'hidden', 'is_square_visible' => false, 'exclude_from_metrics' => true])->save();
        $restriction = $s->punish($a, $u->id, 'restrict', 'first restriction', 0);
        $first = $s->punish($a, $u->id, 'banned', 'first ban', 1);
        $second = $s->punish($a, $u->id, 'banned', 'second ban', 2);
        $s->restore($a, $u->id, $second, 'remove latest ban only', 3);
        $this->assertTrue($u->fresh()->disabled);
        $s->restore($a, $u->id, $first, 'remove remaining ban', 4);
        $this->assertFalse($u->fresh()->disabled);
        $this->assertSame('restricted', $u->fresh()->moderation_status);
        $this->assertFalse($u->fresh()->is_match_eligible);
        $s->restore($a, $u->id, $restriction, 'remove restriction', 5);
        $this->assertDatabaseHas('users', ['id' => $u->id, 'disabled' => false, 'moderation_status' => 'normal',
            'visibility_scope' => 'hidden', 'is_square_visible' => false, 'exclude_from_metrics' => true]);
        $this->assertDatabaseCount('admin_operation_audits', 6);
    }

    public function test_preexisting_external_disable_survives_all_owned_restores(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        app(DisableUser::class)->execute($u->id);
        $restriction = $s->punish($a, $u->id, 'restrict', 'restriction beside external disable', 0);
        $ban = $s->punish($a, $u->id, 'banned', 'owned additional ban', 1);
        $s->restore($a, $u->id, $ban, 'remove owned ban', 2);
        $s->restore($a, $u->id, $restriction, 'remove owned restriction', 3);
        $this->assertDatabaseHas('users', ['id' => $u->id, 'disabled' => true, 'moderation_status' => 'banned', 'is_match_eligible' => false]);
        $this->assertDatabaseHas('admin_sanctions', ['user_id' => $u->id, 'kind' => 'external_ban', 'active' => true]);
    }

    public function test_later_independent_disable_and_unknown_legacy_sanction_fail_closed(): void
    {
        [$a,$u] = $this->users();
        $s = app(UserGovernance::class);
        $ban = $s->punish($a, $u->id, 'banned', 'owned ban', 0);
        app(DisableUser::class)->execute($u->id);
        try {
            $s->restore($a, $u->id, $ban, 'cannot own later disable', 1);
            $this->fail('external disable cleared');
        } catch (HttpException $e) {
            $this->assertSame(409, $e->getStatusCode());
        }
        $this->assertTrue($u->fresh()->disabled);
        $this->assertDatabaseCount('admin_operation_audits', 1);
        $this->assertDatabaseHas('admin_sanctions', ['id' => $ban, 'active' => true]);
        DB::table('admin_sanctions')->where('id', $ban)->update(['prior_state' => null, 'applied_state' => null]);
        try {
            $s->restore($a,$u->id,$ban,'legacy unknown',1);
            $this->fail('legacy sanction accepted');
        } catch (HttpException $e) {
            $this->assertSame(409,$e->getStatusCode());
        }
        $this->assertTrue($u->fresh()->disabled);
        $this->assertDatabaseCount('admin_operation_audits',1);
        $this->assertDatabaseHas('admin_sanctions',['id' => $ban, 'active' => true]);
    }
}
