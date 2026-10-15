<?php

namespace Tests\Feature;

use App\Models\AppReleaseVersion;
use App\Models\User;
use App\Services\Admin\ReleaseManagement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Tests\TestCase;

final class V1008ReleaseTest extends TestCase
{
    use RefreshDatabase;

    private function admin(): User
    {
        $user = User::create(['name' => 'Release fixture', 'phone' => '19900000861',
            'password' => 'fixture-password', 'role' => 'admin', 'disabled' => false]);
        config(['app.admin_phones' => [$user->phone]]);
        return $user;
    }

    private function metadata(array $override = []): array
    {
        return array_replace(['action' => 'upsert', 'expected_revision' => 0, 'confirm' => '1',
            'reason' => 'Fictional development release', 'version_name' => '0.01.05', 'version_code' => 105,
            'min_supported_version_name' => '0.01.04', 'download_url' => 'http://127.0.0.1:8000/fixture.apk',
            'sha256' => str_repeat('a', 64), 'changelog' => '<script>fixture</script>', 'force_update' => false], $override);
    }

    public function test_web_create_edit_activate_and_deactivate_are_audited_and_read_by_app(): void
    {
        $admin = $this->admin();
        $this->actingAs($admin, 'web')->post('/admin/releases', $this->metadata())->assertRedirect('/admin/releases');
        $release = AppReleaseVersion::sole();
        $this->assertFalse($release->is_active);
        $this->get('/admin/releases')->assertOk()->assertSee('&lt;script&gt;fixture&lt;/script&gt;', false);
        $this->post('/admin/releases', $this->metadata(['id' => $release->id, 'expected_revision' => 1,
            'changelog' => 'Edited fixture']))->assertRedirect();
        $this->post('/admin/releases', $this->metadata(['id' => $release->id, 'expected_revision' => 2,
            'action' => 'activate']))->assertRedirect();
        $this->getJson('/api/v1/app/version/check?platform=android&channel=development&version_name=0.01.01')
            ->assertOk()->assertJsonPath('source', 'database')->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', true)->assertJsonPath('latest_version_name', '0.01.05')
            ->assertJsonPath('changelog', 'Edited fixture');
        $this->post('/admin/releases', $this->metadata(['id' => $release->id, 'expected_revision' => 3,
            'action' => 'deactivate']))->assertRedirect();
        $this->getJson('/api/v1/app/version/check?platform=android&channel=development&version_name=0.01.01')
            ->assertOk()->assertJsonPath('source', 'config');
        $this->assertDatabaseCount('admin_operation_audits', 4);
        $this->assertDatabaseHas('admin_operation_audits', ['actor_user_id' => $admin->id,
            'action' => 'release.web.activate', 'target_id' => (string) $release->id, 'expected_version' => 2]);
    }

    public function test_stale_and_duplicate_transition_do_not_mutate_or_audit(): void
    {
        $admin = $this->admin();
        $this->actingAs($admin, 'web')->post('/admin/releases', $this->metadata())->assertRedirect();
        $id = AppReleaseVersion::sole()->id;
        $this->post('/admin/releases', $this->metadata(['action' => 'activate', 'id' => $id]))->assertStatus(409);
        $this->post('/admin/releases', $this->metadata(['action' => 'deactivate', 'id' => $id,
            'expected_revision' => 1]))->assertStatus(409);
        $this->assertDatabaseCount('admin_operation_audits', 1);
        $this->assertFalse(AppReleaseVersion::sole()->is_active);
        $this->assertDatabaseHas('admin_versions', ['key' => ReleaseManagement::KEY, 'revision' => 1]);
    }

    public function test_invalid_metadata_confirmation_and_foreign_channel_are_rejected(): void
    {
        $admin = $this->admin();
        $this->actingAs($admin, 'web');
        foreach ([['sha256' => 'invalid'], ['download_url' => 'javascript:alert(1)'],
            ['download_url' => 'file:///fixture.apk'], ['download_url' => 'http://example.com/a.apk'],
            ['download_url' => 'http://127.0.0.1:8001/a.apk'], ['min_supported_version_name' => '0.02.00'],
            ['version_name' => 'banana'], ['confirm' => '0'], ['reason' => '']] as $override) {
            $this->post('/admin/releases', $this->metadata($override))->assertSessionHasErrors();
        }
        $foreign = AppReleaseVersion::create(['platform' => 'android', 'channel' => 'stable',
            'version_name' => '0.01.05', 'version_code' => 105, 'download_url' => 'https://example.com/a.apk']);
        $this->post('/admin/releases', $this->metadata(['id' => $foreign->id, 'action' => 'activate']))->assertNotFound();
        $this->assertDatabaseCount('admin_operation_audits', 0);
    }

    public function test_cli_and_web_share_single_active_and_cli_audit(): void
    {
        $admin = $this->admin();
        $service = app(ReleaseManagement::class);
        $first = $service->web($admin->id, $this->metadata());
        $service->web($admin->id, $this->metadata(['action' => 'activate', 'id' => $first->id, 'expected_revision' => 1]));
        $second = $service->cli('android', 'development', $this->metadata(['version_name' => '0.01.06', 'version_code' => 106]));
        $service->cli('android', 'development', $this->metadata(['version_name' => '0.01.06', 'version_code' => 106]));
        $this->assertSame(1, AppReleaseVersion::where('platform', 'android')->where('channel', 'development')->where('is_active', true)->count());
        $this->assertFalse($first->refresh()->is_active);
        $this->assertTrue($second->refresh()->is_active);
        $this->assertDatabaseHas('admin_operation_audits', ['actor_user_id' => null, 'action' => 'release.cli.upsert']);
    }

    public function test_non_admin_cannot_manage_releases(): void
    {
        $user = $this->admin();
        $user->update(['role' => 'user']);
        $this->actingAs($user, 'web')->get('/admin/releases')->assertForbidden();
        $this->post('/admin/releases', $this->metadata())->assertForbidden();
        $this->assertDatabaseCount('app_release_versions', 0);
    }
}

