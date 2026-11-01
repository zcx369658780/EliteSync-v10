<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserBlock;
use App\Services\Accounts\DeviceSessions;
use App\Services\ChatWebsocketAuthorizationService;
use App\Services\ConversationDomainService;
use App\Services\LiveConsentService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Laravel\Sanctum\PersonalAccessToken;
use Tests\TestCase;

/** Software authorization regression, not a running Workerman/physical media test. */
final class V1015WsAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->assertSame('sqlite', DB::connection()->getDriverName());
        $this->assertSame(':memory:', DB::connection()->getDatabaseName());
        config(['restoration.enabled' => true]);
    }

    private function pair(): array
    {
        // Entirely fictional in-memory users. No external identity/provider claim.
        $a = User::factory()->create(['phone' => '19900001601', 'disabled' => false, 'is_synthetic' => false]);
        $b = User::factory()->create(['phone' => '19900001602', 'disabled' => false, 'is_synthetic' => false]);
        DB::table('friendships')->insert(['user_a' => $a->id, 'user_b' => $b->id,
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
        $consent = app(LiveConsentService::class);
        foreach ([[$a, $b, 'connection', 'request', 0], [$b, $a, 'connection', 'accept', 1],
                  [$a, $b, 'consent', 'request', 0], [$b, $a, 'consent', 'accept', 1]] as [$actor, $peer, $kind, $action, $revision]) {
            $consent->transition($actor->id, $peer->id, $kind, $action, $revision);
        }
        app(ConversationDomainService::class)->ensureDirectConversation($a->id, $b->id);
        $tokens = app(DeviceSessions::class)->issue($a, 'FINALRTC_SYNTHETIC', true);
        $id = (int) PersonalAccessToken::findToken($tokens['access_token'])->id;
        $service = app(ChatWebsocketAuthorizationService::class);
        $this->assertSame($a->id, $service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id)['actor_id']);
        $this->assertTrue($service->reauthorize($id, $a->id, $b->id));
        return [$a, $b, $tokens, $id, $service];
    }

    public function test_current_actor_peer_and_scope_are_required(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        $this->assertNull($service->authorize('', $a->id, $b->id));
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $b->id, $a->id));
        $this->assertFalse($service->reauthorize($id, $b->id, $a->id));
        $other = User::factory()->create(['phone' => '19900001603']);
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $other->id));
        $restricted = $a->createToken('synthetic-no-chat', ['profile:read']);
        $this->assertNull($service->authorize('Bearer '.$restricted->plainTextToken, $a->id, $b->id));
        $this->assertFalse($service->reauthorize($restricted->accessToken->id, $a->id, $b->id));
    }

    public function test_real_session_rotation_denies_old_token_and_accepts_new_current_token(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        $rotated = app(DeviceSessions::class)->refresh($a, PersonalAccessToken::findToken($tokens['refresh_token']));
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
        $this->assertSame($a->id, $service->authorize('Bearer '.$rotated['access_token'], $a->id, $b->id)['actor_id']);
        $newId = PersonalAccessToken::findToken($rotated['access_token'])->id;
        $this->assertTrue($service->reauthorize($newId, $a->id, $b->id));
    }

    public function test_revoked_device_family_is_rejected_even_if_a_token_row_remains(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        // TEST_INJECTION in the new SQLite fixture: isolate the family guard.
        DB::table('device_sessions')->where('id', $tokens['session_id'])->update(['revoked_at' => now()]);
        $this->assertNotNull(PersonalAccessToken::query()->find($id));
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }

    public function test_committed_mc_revocation_denies_initial_and_ongoing_authorization(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        app(LiveConsentService::class)->transition($b->id, $a->id, 'consent', 'revoke', 2);
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }

    public function test_committed_cn_close_denies_initial_and_ongoing_authorization(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        app(LiveConsentService::class)->transition($a->id, $b->id, 'connection', 'close', 2);
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }

    public function test_peer_block_denies_initial_and_ongoing_authorization(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        UserBlock::query()->create(['blocker_id' => $b->id, 'blocked_user_id' => $a->id]);
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }

    public function test_disabled_actor_denies_initial_and_ongoing_authorization(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        $a->forceFill(['disabled' => true])->save();
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }

    public function test_stale_consent_connection_revision_is_not_current_authority(): void
    {
        [$a, $b, $tokens, $id, $service] = $this->pair();
        // TEST_INJECTION: stale accepted MC evidence against the new CN revision.
        DB::table('product_connections')->where('user_a', min($a->id, $b->id))
            ->where('user_b', max($a->id, $b->id))->increment('revision');
        $this->assertNull($service->authorize('Bearer '.$tokens['access_token'], $a->id, $b->id));
        $this->assertFalse($service->reauthorize($id, $a->id, $b->id));
    }
}
