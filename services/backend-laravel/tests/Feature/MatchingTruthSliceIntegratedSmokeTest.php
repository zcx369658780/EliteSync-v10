<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\DatingRoundUserState;
use App\Services\C2LocalMatchScenarioService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MatchingTruthSliceIntegratedSmokeTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config()->set('matching.c2.local_integration_enabled', true);
        config()->set('matching.c2.local_password', 'r1-disposable-smoke');
        config()->set('matching.foundation.read_contract_enabled', true);
        config()->set('matching.foundation.digest_key', 'r1-disposable-smoke');
    }

    public function test_authenticated_truth_chain_and_conversation_gate_are_coherent(): void
    {
        $scenarios = app(C2LocalMatchScenarioService::class);

        $scenarios->build('no_round');
        $actor = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        $peer = User::query()->where('phone', C2LocalMatchScenarioService::PEER_PHONE)->firstOrFail();
        Sanctum::actingAs($actor);
        $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'no_round');
        $this->getJson('/api/v1/conversations')
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id])
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
        $this->assertDatabaseCount('conversations', 0);
        $this->assertDatabaseCount('chat_messages', 0);

        foreach (['failed', 'no_candidate'] as $state) {
            $scenarios->build($state);
            $actor = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
            Sanctum::actingAs($actor);
            $this->getJson('/api/v1/match-rounds/current')
                ->assertOk()
                ->assertJsonPath('data.state', $state)
                ->assertJsonPath('data.result', null)
                ->assertJsonPath('data.conversation_capability', null);
        }

        $scenarios->build('revealed');
        $actor = User::query()->where('phone', C2LocalMatchScenarioService::USER_PHONE)->firstOrFail();
        $peer = User::query()->where('phone', C2LocalMatchScenarioService::PEER_PHONE)->firstOrFail();
        $outsider = User::factory()->create(['phone' => 'r1-smoke-outsider']);
        Sanctum::actingAs($actor);
        $projection = $this->getJson('/api/v1/match-rounds/current')
            ->assertOk()
            ->assertJsonPath('data.state', 'revealed')
            ->assertJsonPath('data.result.partner_id', $peer->id)
            ->assertJsonPath('data.conversation_capability', null)
            ->assertJsonPath('data.user_action', 'refresh')
            ->assertJsonPath('data.next_action_code', null);
        $this->assertSame(
            'open_conversation',
            DatingRoundUserState::query()->where('user_id', $actor->id)->latest('id')->value('next_action_code')
        );
        $matchId = $projection->json('data.result.match_id');
        $this->assertIsInt($matchId);
        $this->assertGreaterThan(0, $matchId);

        // A revealed match does not establish live Conversation permission.
        $this->getJson('/api/v1/conversations')
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id])
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
        $this->assertDatabaseCount('conversations', 0);
        $this->assertDatabaseCount('chat_messages', 0);

        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/conversation-peers/'.$peer->id)
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);
    }
}
