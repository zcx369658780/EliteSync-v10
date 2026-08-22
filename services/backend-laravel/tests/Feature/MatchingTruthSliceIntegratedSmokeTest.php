<?php

namespace Tests\Feature;

use App\Models\User;
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
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id])
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation unavailable']);

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
            ->assertJsonPath('data.conversation_capability.can_create', true);
        $matchId = $projection->json('data.result.match_id');
        $this->assertIsInt($matchId);
        $this->assertGreaterThan(0, $matchId);

        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.entry_kind', 'eligible_match')
            ->assertJsonPath('items.0.peer_user_id', $peer->id)
            ->assertJsonPath('items.0.match_id', $matchId);
        $this->postJson('/api/v1/conversations', ['peer_user_id' => $peer->id])
            ->assertOk()
            ->assertJsonPath('conversation.peer_user_id', $peer->id)
            ->assertJsonPath('conversation.match_id', $matchId);

        Sanctum::actingAs($outsider);
        $this->getJson('/api/v1/conversation-peers/'.$peer->id)
            ->assertNotFound()
            ->assertExactJson(['message' => 'conversation not found']);
    }
}
