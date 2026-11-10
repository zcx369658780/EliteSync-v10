<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007MatchNotificationTest extends TestCase
{
    use RefreshDatabase;

    public function test_first_mutual_like_notifies_both_once_and_guides_independent_consent(): void
    {
        config(['restoration.enabled' => true]);
        $a = User::factory()->create(['phone' => '19900000791', 'disabled' => false, 'is_synthetic' => false]);
        $b = User::factory()->create(['phone' => '19900000792', 'disabled' => false, 'is_synthetic' => false]);
        $match = DatingMatch::create(['week_tag' => 'v1007-notification', 'user_a' => $a->id,
            'user_b' => $b->id, 'drop_released' => true]);
        Sanctum::actingAs($a);
        $this->postJson('/api/v1/match/like', ['match_id' => $match->id, 'like' => true])
            ->assertOk()->assertJsonPath('mutual', false);
        $this->assertSame(0, AppNotificationItem::where('kind', 'match_success')->count());
        Sanctum::actingAs($b);
        $this->postJson('/api/v1/match/like', ['match_id' => $match->id, 'like' => true])
            ->assertOk()->assertJsonPath('mutual', true);
        $success = AppNotificationItem::where('kind', 'match_success')->orderBy('user_id')->get();
        $this->assertCount(2, $success);
        $this->assertSame([$a->id, $b->id], $success->pluck('user_id')->all());
        foreach ($success as $notification) {
            $this->assertSame('match_detail', $notification->payload['route_name']);
            $this->assertSame($match->id, $notification->payload['match_id']);
            $this->assertSame($notification->user_id === $a->id ? $b->id : $a->id, $notification->payload['partner_user_id']);
            $this->assertStringContainsString('连接', $notification->body);
            $this->assertStringContainsString('消息同意', $notification->body);
            $this->assertStringNotContainsString('现在可以开始聊天', $notification->body);
        }
        $this->postJson('/api/v1/match/like', ['match_id' => $match->id, 'like' => true])->assertOk();
        $this->assertSame(2, AppNotificationItem::where('kind', 'match_success')->count());
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->getJson('/api/v1/messages?peer_id='.$a->id)->assertNotFound();
    }
}
