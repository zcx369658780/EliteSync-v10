<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\NotificationDeliveryService;
use App\Services\NotificationService;
use App\Services\Accounts\DeviceSessions;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class V1015NotificationDeliveryTest extends TestCase
{
    use RefreshDatabase;

    public function test_preferences_are_account_owned_and_permission_denial_keeps_core_access(): void
    {
        $a = User::factory()->create(['phone' => '13811111511']);
        $b = User::factory()->create(['phone' => '13811111512']);
        $this->loginDevice($a, 'dev-a');
        $this->putJson('/api/v1/notification-preferences', ['categories' => ['message' => false], 'silent' => true])
            ->assertOk()->assertJsonPath('categories.message', false)->assertJsonPath('silent', true);
        $this->postJson('/api/v1/notification-devices', ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => 'synthetic-token-a', 'permission' => 'denied'])->assertUnprocessable();
        $this->getJson('/api/v1/notifications')->assertOk();
        Sanctum::actingAs($b);
        $this->getJson('/api/v1/notification-preferences')->assertOk()->assertJsonPath('categories.message', true);
        $this->assertDatabaseCount('notification_devices', 0);
    }

    public function test_device_rotation_and_revoke_never_store_raw_tokens_or_claim_real_delivery(): void
    {
        $a = User::factory()->create(['phone' => '13811111513']);
        $this->loginDevice($a, 'dev-a');
        foreach (['synthetic-one', 'synthetic-two'] as $token) {
            $this->postJson('/api/v1/notification-devices', ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => $token, 'permission' => 'granted'])
                ->assertOk()->assertJsonPath('provider_status', 'REAL_PUSH_PROVIDER_PENDING');
        }
        $this->assertDatabaseCount('notification_devices', 1);
        $this->assertSame(hash('sha256', 'synthetic-two'), DB::table('notification_devices')->value('token_hash'));
        $notice = app(NotificationService::class)->createForUser($a->id, 'system', 'Private name', 'Private body', ['secret' => 'Private detail']);
        $result = app(NotificationDeliveryService::class)->attempt($notice, 'dev-a');
        $this->assertSame('TEST_ONLY', $result['status']);
        $this->assertSame(['notification_id' => $notice->id, 'title' => 'EliteSync', 'body' => '请打开应用查看当前有权通知。'], $result['payload']);
        $this->assertDatabaseHas('notification_delivery_attempts', ['status' => 'TEST_ONLY']);
        $this->deleteJson('/api/v1/notification-devices/dev-a')->assertOk();
        $this->assertSame('SUPPRESSED', app(NotificationDeliveryService::class)->attempt($notice, 'dev-a')['status']);
        $this->postJson('/api/v1/notification-devices', ['device_id' => 'dev-a', 'transport' => 'fcm', 'token' => 'unapproved', 'permission' => 'granted'])->assertUnprocessable();
    }

    public function test_silence_and_category_suppress_attempts_without_mutating_domain_events(): void
    {
        $a = User::factory()->create(['phone' => '13811111514']);
        $this->loginDevice($a, 'dev-a');
        $this->postJson('/api/v1/notification-devices', ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => 'synthetic-one', 'permission' => 'granted'])->assertOk();
        $notice = app(NotificationService::class)->createForUser($a->id, 'system', 'System');
        $this->putJson('/api/v1/notification-preferences', ['silent' => true])->assertOk();
        $this->assertSame('SUPPRESSED', app(NotificationDeliveryService::class)->attempt($notice, 'dev-a')['status']);
        $this->assertDatabaseCount('notifications', 1);
        $this->assertDatabaseCount('notification_delivery_attempts', 0);
    }

    public function test_categories_filter_in_app_and_unread_without_erasing_domain_notification(): void
    {
        $a = User::factory()->create(['phone' => '13811111515']);
        $this->loginDevice($a, 'dev-a');
        app(NotificationService::class)->createForUser($a->id, 'system', 'System');
        $this->getJson('/api/v1/notifications')->assertOk()->assertJsonPath('total', 1);
        $this->putJson('/api/v1/notification-preferences', ['categories' => ['system' => false]])->assertOk();
        $this->getJson('/api/v1/notifications')->assertOk()->assertJsonPath('total', 0);
        $this->getJson('/api/v1/notifications/unread-count')->assertOk()->assertJsonPath('unread_total', 0);
        $this->assertDatabaseCount('notifications', 1);
        $this->putJson('/api/v1/notification-preferences', ['categories' => ['system' => true]])->assertOk();
        $this->getJson('/api/v1/notifications')->assertOk()->assertJsonPath('total', 1);
    }

    public function test_attempt_replay_is_deduplicated_but_permission_denial_revokes_existing_registration(): void
    {
        $a = User::factory()->create(['phone' => '13811111516']);
        $this->loginDevice($a, 'dev-a');
        $data = ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => 'synthetic-private-registration', 'permission' => 'granted'];
        $this->postJson('/api/v1/notification-devices', $data)->assertOk();
        $notice = app(NotificationService::class)->createForUser($a->id, 'system', 'Private name', 'Private body');
        $delivery = app(NotificationDeliveryService::class);
        $this->assertFalse($delivery->attempt($notice, 'dev-a')['deduplicated']);
        $this->assertTrue($delivery->attempt($notice, 'dev-a')['deduplicated']);
        $this->assertDatabaseCount('notification_delivery_attempts', 1);
        $this->postJson('/api/v1/notification-devices', $data)->assertOk();
        $this->assertTrue($delivery->attempt($notice, 'dev-a')['deduplicated']);
        $this->assertDatabaseCount('notification_delivery_attempts', 1);
        $stored = json_encode(DB::table('notification_devices')->first(), JSON_THROW_ON_ERROR);
        $this->assertStringNotContainsString('synthetic-private-registration', $stored);
        $this->postJson('/api/v1/notification-devices', array_replace($data, ['permission' => 'denied']))->assertUnprocessable();
        $this->assertSame('SUPPRESSED', $delivery->attempt($notice, 'dev-a')['status']);
        $this->assertNotNull(DB::table('notification_devices')->value('revoked_at'));
        $this->getJson('/api/v1/notifications')->assertOk();
    }

    public function test_account_switch_rebinds_device_and_old_account_cannot_revoke_new_owner(): void
    {
        $a = User::factory()->create(['phone' => '13811111517']);
        $b = User::factory()->create(['phone' => '13811111518']);
        $one = $this->loginDevice($a, 'shared-device');
        $data = ['device_id' => 'shared-device', 'transport' => 'test_only', 'token' => 'synthetic-shared-token', 'permission' => 'granted'];
        $this->postJson('/api/v1/notification-devices', $data)->assertOk();
        $old = app(NotificationService::class)->createForUser($a->id, 'system', 'Old account');
        $this->loginDevice($b, 'shared-device');
        $this->postJson('/api/v1/notification-devices', $data)->assertOk();
        $this->assertDatabaseCount('notification_devices', 1);
        $this->assertDatabaseHas('notification_devices', ['device_id' => 'shared-device', 'user_id' => $b->id, 'revoked_at' => null]);
        $this->assertSame('SUPPRESSED', app(NotificationDeliveryService::class)->attempt($old, 'shared-device')['status']);
        $this->app['auth']->forgetGuards();
        $this->withToken($one['access_token'])->deleteJson('/api/v1/notification-devices/shared-device')->assertOk();
        $current = app(NotificationService::class)->createForUser($b->id, 'system', 'Current account');
        $this->assertSame('TEST_ONLY', app(NotificationDeliveryService::class)->attempt($current, 'shared-device')['status']);
    }

    public function test_only_current_device_can_register_and_revoked_or_expired_family_suppresses_attempt(): void
    {
        $a = User::factory()->create(['phone' => '13811111519']);
        $issued = $this->loginDevice($a, 'dev-a');
        $data = ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => 'synthetic-one', 'permission' => 'granted'];
        $this->postJson('/api/v1/notification-devices', array_replace($data, ['device_id' => 'some-other-device']))->assertUnprocessable();
        $this->assertDatabaseCount('notification_devices', 0);
        $this->postJson('/api/v1/notification-devices', $data)->assertOk();
        $notice = app(NotificationService::class)->createForUser($a->id, 'system', 'System');
        $this->travel(15)->days();
        $this->assertSame('SUPPRESSED', app(NotificationDeliveryService::class)->attempt($notice, 'dev-a')['status']);
        $this->travelBack();
        app(DeviceSessions::class)->revoke($a, $issued['session_id']);
        $this->assertSame('SUPPRESSED', app(NotificationDeliveryService::class)->attempt($notice, 'dev-a')['status']);
        $this->assertDatabaseCount('notification_delivery_attempts', 0);
    }

    public function test_current_message_and_platform_qualification_precede_minimal_transport_payload(): void
    {
        $a = User::factory()->create(['phone' => '13811111520']);
        $this->loginDevice($a, 'dev-a');
        $this->postJson('/api/v1/notification-devices', ['device_id' => 'dev-a', 'transport' => 'test_only', 'token' => 'synthetic-one', 'permission' => 'granted'])->assertOk();
        foreach ([['message', ['message_id' => 999999]], ['platform_event', ['platform_event_id' => 'unavailable']],
            ['safety_case', ['safety_case_id' => 'unavailable']]] as [$kind, $pointer]) {
            $notice = app(NotificationService::class)->createForUser($a->id, $kind, 'Do not expose private title', 'Do not expose private body', $pointer);
            $reply = app(NotificationDeliveryService::class)->attempt($notice, 'dev-a');
            $this->assertSame('SUPPRESSED', $reply['status']);
            $this->assertSame([], $reply['payload']);
        }
        $this->assertDatabaseCount('notification_delivery_attempts', 0);
    }

    private function loginDevice(User $user, string $deviceId): array
    {
        $issued = app(DeviceSessions::class)->issue($user, 'Notification test', true, $deviceId);
        $this->app['auth']->forgetGuards();
        $this->withToken($issued['access_token']);

        return $issued;
    }
}
