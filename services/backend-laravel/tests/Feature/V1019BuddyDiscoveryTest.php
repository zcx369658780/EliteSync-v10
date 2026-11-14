<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\User;
use App\Services\BuddyService;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

final class V1019BuddyDiscoveryTest extends TestCase
{
    use RefreshDatabase;

    private function person(): User
    {
        config(['restoration.enabled' => true]);
        $user = User::factory()->create(['is_synthetic' => true, 'phone' => fake()->unique()->numerify('199########')]);
        $this->actingAs($user, 'sanctum')->putJson('/api/v1/buddy/preferences', ['enabled' => true, 'revision' => 0])->assertOk();
        return $user;
    }

    private function activity(User $owner): array
    {
        $draft = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/buddy/activities', [
            'type' => 'STUDY', 'subject' => '一起安静读书', 'general_city' => '杭州', 'place_kind' => 'ONLINE',
            'budget_band' => 'LOW', 'start_at' => now()->addDays(3)->toIso8601String(),
            'end_at' => now()->addDays(3)->addHour()->toIso8601String(), 'idempotency_key' => uniqid('create-'),
        ])->assertCreated()->json();
        return $this->action($owner, $draft, 'open');
    }

    private function action(User $actor, array $activity, string $action): array
    {
        return $this->actingAs($actor, 'sanctum')->postJson('/api/v1/buddy/'.$activity['id'].'/actions', [
            'action' => $action, 'revision' => $activity['revision'], 'idempotency_key' => uniqid('act-'),
        ])->assertOk()->json();
    }

    private function publish(User $owner, array $activity): array
    {
        return $this->actingAs($owner, 'sanctum')->postJson('/api/v1/buddy/'.$activity['id'].'/discovery', [
            'action' => 'publish', 'revision' => $activity['revision'], 'author_label' => '读书伙伴',
            'idempotency_key' => uniqid('publish-'),
        ])->assertOk()->json();
    }

    private function applyBody(array $activity, string $key): array
    {
        return ['generation' => $activity['discovery']['generation'], 'revision' => $activity['revision'], 'idempotency_key' => $key];
    }

    public function test_explicit_minimal_publication_and_independent_participation_survive_public_window(): void
    {
        $owner = $this->person(); $guest = $this->person();
        $activity = $this->activity($owner);
        $this->actingAs($guest, 'sanctum')->getJson('/api/v1/buddy/discovery?city=线上&type=STUDY')->assertOk()->assertJsonCount(0, 'items');
        $activity = $this->publish($owner, $activity);
        $publication = $activity['discovery']['publication_id'];
        $this->actingAs($guest, 'sanctum')->getJson('/api/v1/buddy/discovery?city=线上&type=STUDY')->assertOk()
            ->assertJsonCount(1, 'items')->assertJsonPath('items.0.author_label', '读书伙伴')->assertJsonPath('items.0.avatar', null)
            ->assertJsonMissingPath('items.0.owner_id')->assertJsonMissingPath('items.0.allowed_actions');
        $body = $this->applyBody($activity, 'apply-once');
        $requested = $this->postJson('/api/v1/buddy/discovery/'.$publication.'/apply', $body)->assertOk()->assertJsonPath('state', 'REQUESTED')->json();
        $this->assertSame('DISCOVERY', $requested['participation_source']);
        $this->assertDatabaseCount('buddy_slots', 2);
        $before = AppNotificationItem::count();
        $this->postJson('/api/v1/buddy/discovery/'.$publication.'/apply', $body)->assertOk();
        $this->assertSame($before, AppNotificationItem::count());
        $confirmed = $this->action($owner, $requested, 'confirm');
        $this->travel(49)->hours();
        $this->actingAs($guest, 'sanctum')->postJson('/api/v1/buddy/discovery/'.$publication.'/apply', $body)->assertOk()->assertJsonPath('state', 'CONFIRMED');
        $this->getJson('/api/v1/buddy/'.$activity['id'])->assertOk()->assertJsonPath('state', 'CONFIRMED');
        $this->actingAs($owner, 'sanctum')->postJson('/api/v1/buddy/'.$activity['id'].'/discovery', [
            'action' => 'withdraw', 'revision' => $confirmed['revision'], 'idempotency_key' => 'withdraw-public-only',
        ])->assertOk()->assertJsonPath('state', 'CONFIRMED');
        app(BuddyService::class)->revokePair($owner->id, $guest->id, true);
        $confirmed = $this->actingAs($guest, 'sanctum')->getJson('/api/v1/buddy/'.$activity['id'])->assertOk()->assertJsonPath('state', 'CONFIRMED')->json();
        $this->action($guest, $confirmed, 'complete');
        $terminal = $this->actingAs($owner, 'sanctum')->getJson('/api/v1/buddy/'.$activity['id'])->assertOk()->assertJsonPath('state', 'COMPLETED');
        $terminal->assertJsonMissingPath('subject')->assertJsonPath('allowed_actions', []);
        $notice = AppNotificationItem::where('user_id', $owner->id)->where('kind', 'buddy')->latest('id')->firstOrFail();
        $presentation = app(NotificationService::class)->presentationForUser($notice, $owner->id);
        $this->assertSame(['buddy_activity_id' => $activity['id']], $presentation['payload']);
        $this->assertDatabaseCount('buddy_slots', 0);
        foreach (['friendships', 'product_connections', 'messaging_consents', 'conversations'] as $table) $this->assertDatabaseCount($table, 0);
    }

    public function test_unique_guest_conflicts_and_current_revocation(): void
    {
        $owner = $this->person(); $guest = $this->person(); $other = $this->person();
        $activity = $this->publish($owner, $this->activity($owner));
        $path = '/api/v1/buddy/discovery/'.$activity['discovery']['publication_id'].'/apply';
        $body = $this->applyBody($activity, 'first');
        $this->actingAs($guest, 'sanctum')->postJson($path, $body)->assertOk();
        $this->actingAs($other, 'sanctum')->postJson($path, $this->applyBody($activity, 'second'))->assertStatus(409);
        $this->actingAs($guest, 'sanctum')->postJson($path, array_replace($body, ['revision' => 99]))->assertStatus(409);
        $this->assertDatabaseCount('buddy_invitations', 1);
        $this->assertSame(1, DB::table('buddy_commands')->where('kind', 'discovery_apply')->count());
        $this->putJson('/api/v1/buddy/preferences', ['enabled' => false, 'revision' => 1])->assertOk();
        $this->putJson('/api/v1/buddy/preferences', ['enabled' => true, 'revision' => 2])->assertOk();
        $this->postJson($path, $body)->assertOk()->assertJsonPath('state', 'WITHDRAWN')->assertJsonMissingPath('subject');
        $this->assertDatabaseCount('buddy_slots', 0);
    }

    public function test_withdraw_expiry_generation_and_current_filter(): void
    {
        $owner = $this->person(); $guest = $this->person();
        $activity = $this->publish($owner, $this->activity($owner));
        $old = $activity;
        $activity = $this->actingAs($owner, 'sanctum')->postJson('/api/v1/buddy/'.$activity['id'].'/discovery', [
            'action' => 'withdraw', 'revision' => $activity['revision'], 'idempotency_key' => 'remove',
        ])->assertOk()->json();
        $this->actingAs($guest, 'sanctum')->postJson('/api/v1/buddy/discovery/'.$old['discovery']['publication_id'].'/apply', $this->applyBody($old, 'stale'))->assertStatus(409);
        $activity = $this->publish($owner, $activity);
        $this->assertSame(2, $activity['discovery']['generation']);
        $this->actingAs($guest, 'sanctum')->getJson('/api/v1/buddy/discovery?city=杭州&type=STUDY')->assertOk()->assertJsonCount(0, 'items');
        $this->getJson('/api/v1/buddy/discovery?city=线上&type=MEAL')->assertOk()->assertJsonCount(0, 'items');
        $this->getJson('/api/v1/buddy/discovery?city=线上&type=STUDY&limit=21')->assertStatus(422);
        $this->travel(49)->hours();
        $this->getJson('/api/v1/buddy/discovery?city=线上&type=STUDY')->assertOk()->assertJsonCount(0, 'items');
        $this->postJson('/api/v1/buddy/discovery/'.$activity['discovery']['publication_id'].'/apply', $this->applyBody($activity, 'expired'))->assertStatus(409);
    }

    public function test_guest_slots_and_success_only_quota_are_not_recharged_by_replay(): void
    {
        $guest = $this->person();
        $last = null;
        for ($i = 0; $i < 6; $i++) {
            $owner = $this->person();
            $activity = $this->publish($owner, $this->activity($owner));
            $path = '/api/v1/buddy/discovery/'.$activity['discovery']['publication_id'].'/apply';
            $body = $this->applyBody($activity, 'application-'.$i);
            $this->actingAs($guest, 'sanctum');
            if ($i === 5) { $this->postJson($path, $body)->assertStatus(429); break; }
            $last = $this->postJson($path, $body)->assertOk()->json();
            $this->postJson($path, $body)->assertOk();
            $this->action($guest, $last, 'withdraw');
        }
        $this->assertSame(5, DB::table('buddy_commands')->where('kind', 'discovery_apply')->count());
        // Failed quota requests create neither a participant nor an additional command.
        $this->assertSame(5, DB::table('buddy_activities')->where('guest_id', $guest->id)->count());
        $this->assertSame(0, DB::table('buddy_slots')->where('user_id', $guest->id)->count());
    }

    public function test_requested_guest_occupies_three_slots_and_failed_fourth_is_atomic(): void
    {
        $guest = $this->person();
        for ($i = 0; $i < 4; $i++) {
            $owner = $this->person();
            $activity = $this->publish($owner, $this->activity($owner));
            $response = $this->actingAs($guest, 'sanctum')->postJson(
                '/api/v1/buddy/discovery/'.$activity['discovery']['publication_id'].'/apply', $this->applyBody($activity, 'slot-'.$i));
            $response->assertStatus($i === 3 ? 409 : 200);
        }
        $this->assertSame(3, DB::table('buddy_slots')->where('user_id', $guest->id)->count());
        $this->assertDatabaseCount('buddy_invitations', 3);
        $this->assertSame(1, DB::table('buddy_discovery_publications')->where('state', 'PUBLISHED')->count());
    }

    public function test_admin_withdraw_is_audited_and_never_revokes_consumed_participation(): void
    {
        $owner = $this->person(); $guest = $this->person();
        $admin = User::factory()->create(['role' => 'admin', 'phone' => '19900019999']);
        config(['app.admin_phones' => [$admin->phone]]);
        $activity = $this->publish($owner, $this->activity($owner));
        $path = '/admin/buddy-community/discovery/'.$activity['discovery']['publication_id'].'/withdraw';
        $form = ['revision' => $activity['revision'], 'reason' => 'development moderation check', 'confirm' => 1];
        $this->actingAs($guest, 'web')->post($path, $form)->assertForbidden();
        $this->actingAs($admin, 'web')->post($path, $form)->assertRedirect('/admin/buddy-community');
        $this->assertDatabaseHas('buddy_discovery_publications', ['id' => $activity['discovery']['publication_id'], 'state' => 'ADMIN_REMOVED']);
        $this->assertDatabaseHas('admin_operation_audits', ['action' => 'buddy.discovery_withdraw', 'reason' => $form['reason']]);
        $activity = $this->actingAs($owner, 'sanctum')->getJson('/api/v1/buddy/'.$activity['id'])->assertOk()->json();
        $activity = $this->publish($owner, $activity);
        $requested = $this->actingAs($guest, 'sanctum')->postJson('/api/v1/buddy/discovery/'.$activity['discovery']['publication_id'].'/apply', $this->applyBody($activity, 'consumed'))->assertOk()->json();
        $form['revision'] = $requested['revision'];
        $this->actingAs($admin, 'web')->post('/admin/buddy-community/discovery/'.$activity['discovery']['publication_id'].'/withdraw', $form)->assertRedirect();
        $this->actingAs($guest, 'sanctum')->getJson('/api/v1/buddy/'.$activity['id'])->assertOk()->assertJsonPath('state', 'REQUESTED');
    }
}

