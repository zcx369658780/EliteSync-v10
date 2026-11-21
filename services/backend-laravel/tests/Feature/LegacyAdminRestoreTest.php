<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\Accounts\LegacyAdminManifest;
use App\Services\Accounts\LegacyAdminRestore;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class LegacyAdminRestoreTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config([
            'app.url' => 'https://localhost', 'app.debug' => false, 'session.secure' => true,
            'legacy_admin.target' => 'local-v2-function', 'legacy_admin.url' => 'https://localhost',
            'legacy_admin.approval' => 'synthetic-approval', 'app.admin_phones' => ['+12025550170', '+12025550171'],
        ]);
    }

    private function manifest(): array
    {
        return [
            'batch' => 'batch-one', 'source_system' => 'old-fixture', 'snapshot' => 'snapshot-one',
            'target' => 'local-v2-function', 'approval' => 'synthetic-approval', 'operator' => 'qa-fixture',
            'candidates' => [
                ['candidate' => 'fixture-a', 'legacy_user_id' => 902001, 'phone' => '+12025550170', 'status' => 'enabled', 'role' => 'admin'],
                ['candidate' => 'fixture-b', 'legacy_user_id' => 902002, 'phone' => '+12025550171', 'status' => 'enabled', 'role' => 'admin'],
            ],
        ];
    }

    private function command(array $manifest, string $action = 'dry-run', int $exit = 0): void
    {
        $file = tempnam(sys_get_temp_dir(), 'legacy-manifest-');
        try {
            file_put_contents($file, json_encode($manifest, JSON_THROW_ON_ERROR));
            $this->artisan('admin:legacy-restore', ['manifest' => $file, '--action' => $action])->assertExitCode($exit);
        } finally {
            unlink($file);
        }
    }

    private function issue(array $manifest, string $candidate): string
    {
        $code = null;
        $file = tempnam(sys_get_temp_dir(), 'legacy-manifest-');
        try {
            file_put_contents($file, json_encode($manifest, JSON_THROW_ON_ERROR));
            app(LegacyAdminRestore::class)->issue(LegacyAdminManifest::read($file), $candidate, function (string $issued) use (&$code) {
                $code = $issued;
            });
        } finally {
            unlink($file);
        }

        return $code;
    }

    private function claim(string $code)
    {
        return $this->post('https://localhost/admin/legacy-activate', [
            'activation_code' => $code, 'new_password' => 'NewTestPassword1222', 'new_password_confirmation' => 'NewTestPassword1222',
        ]);
    }

    public function test_cli_default_is_readonly_and_apply_is_idempotent_and_collision_safe(): void
    {
        $manifest = $this->manifest();
        $file = tempnam(sys_get_temp_dir(), 'legacy-default-');
        try {
            file_put_contents($file, json_encode($manifest, JSON_THROW_ON_ERROR));
            $this->artisan('admin:legacy-restore', ['manifest' => $file])->assertExitCode(0);
            $this->assertDatabaseCount('legacy_admin_mappings', 0);
        } finally {
            unlink($file);
        }
        $wrong = array_replace($manifest, ['approval' => 'unapproved-ref']);
        $this->command($wrong, 'apply', 1);
        $wrong = array_replace($manifest, ['target' => 'other-target']);
        $this->command($wrong, 'apply', 1);
        $invalid = $manifest;
        $invalid['candidates'][0]['password_hash'] = 'legacy-secret';
        $this->command($invalid, 'dry-run', 1);
        $this->assertDatabaseCount('legacy_admin_batches', 0);

        $existing = User::factory()->create(['phone' => '+12025550171']);
        $this->command($manifest, 'apply', 1);
        $this->assertDatabaseCount('legacy_admin_batches', 0);
        $this->assertDatabaseCount('users', 1);
        $this->assertSame('+12025550171', $existing->fresh()->phone);

        $manifest['candidates'] = [$manifest['candidates'][0]];
        $this->command($manifest, 'apply');
        $original = DB::table('legacy_admin_mappings')->sole();
        $this->command(array_replace($manifest, ['operator' => 'qa-other']), 'apply');
        $this->assertSame($original->user_id, DB::table('legacy_admin_mappings')->sole()->user_id);
        $this->assertNotSame((int) $original->legacy_user_id, (int) $original->user_id);
        $this->assertDatabaseCount('legacy_admin_restore_audits', 1);
        $this->command(array_replace($manifest, ['snapshot' => 'changed-snapshot']), 'apply', 1);
        $this->command(array_replace($manifest, ['batch' => 'new-batch', 'snapshot' => 'changed-snapshot']), 'apply', 1);
    }

    public function test_expiry_rotation_allowlist_single_use_and_rollback_preserve_existing_account(): void
    {
        $manifest = $this->manifest();
        $existing = User::factory()->create(['phone' => '+12025550172']);
        $existing->createToken('normal control');
        $this->command($manifest, 'apply');
        $a = User::where('phone', '+12025550170')->sole();
        $this->assertTrue($a->disabled);
        $this->assertFalse($a->realname_verified);
        $this->assertSame('user', $a->role);
        $this->postJson('/api/v1/auth/login', ['phone' => $a->phone, 'password' => 'old-fixture-password'])->assertUnprocessable();
        $this->get('/admin/legacy-activate')->assertNotFound();
        $this->get('https://localhost/admin/legacy-activate')->assertOk()->assertHeader('Cache-Control', 'no-store, private');

        $expired = $this->issue($manifest, 'fixture-a');
        $this->travel(31)->minutes();
        $this->claim($expired)->assertStatus(422)->assertDontSee($expired);
        $retired = $this->issue($manifest, 'fixture-a');
        $usable = $this->issue($manifest, 'fixture-a');
        $this->claim($retired)->assertStatus(422);
        $this->assertDatabaseHas('legacy_admin_mappings', ['user_id' => $a->id, 'activation_hash' => hash('sha256', $usable)]);
        config(['app.admin_phones' => ['+12025550171']]);
        $this->claim($usable)->assertStatus(422);
        config(['app.admin_phones' => ['+12025550170', '+12025550171']]);
        $this->claim($usable)->assertOk()->assertDontSee($usable);
        $this->assertGuest('web');
        $this->claim($usable)->assertStatus(422);

        $login = $this->postJson('/api/v1/auth/login', ['phone' => $a->phone, 'password' => 'NewTestPassword1222'])->assertOk();
        $login->assertJsonPath('user.id', $a->id)->assertJsonPath('user.realname_verified', false);
        $token = $login->json('access_token') ?? $login->json('token');
        $this->assertIsString($token);
        $this->withToken($token)->getJson('/api/v1/admin/users')->assertOk();
        config(['app.admin_phones' => ['+12025550171']]);
        $this->withToken($token)->getJson('/api/v1/admin/users')->assertForbidden();
        config(['app.admin_phones' => ['+12025550170', '+12025550171']]);
        $this->command($manifest, 'rollback');
        $this->command($manifest, 'rollback');
        $this->assertDatabaseHas('users', ['id' => $a->id, 'disabled' => true, 'role' => 'user']);
        $this->assertDatabaseHas('legacy_admin_mappings', ['user_id' => $a->id, 'state' => 'rolled_back', 'activation_hash' => null]);
        $this->assertDatabaseMissing('personal_access_tokens', ['tokenable_id' => $a->id]);
        $this->assertDatabaseHas('personal_access_tokens', ['tokenable_id' => $existing->id]);
        $this->assertDatabaseHas('users', ['id' => $existing->id, 'disabled' => false]);
        $this->command($manifest, 'apply', 1);
    }
}
