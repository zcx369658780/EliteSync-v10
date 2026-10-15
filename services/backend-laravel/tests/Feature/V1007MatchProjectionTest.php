<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\LiveConsentService;
use Database\Seeders\QuestionnaireQuestionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

final class V1007MatchProjectionTest extends TestCase
{
    use RefreshDatabase;

    private User $actor;

    private User $peer;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'questionnaire.required_answer_count' => 1]);
        $this->actor = User::factory()->create(['phone' => '19900000761', 'disabled' => false, 'is_synthetic' => false]);
        $this->peer = User::factory()->create(['phone' => '19900000762', 'disabled' => false, 'is_synthetic' => false]);
        $this->seed(QuestionnaireQuestionSeeder::class);
        $question = QuestionnaireQuestion::where('enabled', true)->firstOrFail();
        QuestionnaireAnswer::create([
            'user_id' => $this->actor->id, 'questionnaire_question_id' => $question->id,
            'answer_payload' => ['value' => $question->options[0]['option_id']],
            'version' => $question->version, 'importance' => 2,
        ]);
        Sanctum::actingAs($this->actor);
    }

    private function match(string $cadence, bool $released = true): DatingMatch
    {
        return DatingMatch::create([
            'week_tag' => $cadence, 'user_a' => $this->actor->id, 'user_b' => $this->peer->id,
            'drop_released' => $released, 'highlights' => 'fixture match explanation',
            'match_reasons' => ['summary' => 'fixture durable explanation'],
        ]);
    }

    public function test_current_recovers_latest_durable_match_outside_weekly_cadence(): void
    {
        $this->match('v1007-daily-old');
        $latest = $this->match('v1007-manual-round-2');
        $this->getJson('/api/v1/match/current')->assertOk()
            ->assertJsonPath('match_id', $latest->id)
            ->assertJsonPath('partner_id', $this->peer->id);
        $this->assertSame(['live_read_allowed' => false, 'live_send_allowed' => false],
            app(LiveConsentService::class)->gates($this->actor->id, $this->peer->id));
        $this->assertDatabaseCount('product_connections', 0);
        $this->assertDatabaseCount('messaging_consents', 0);
        $this->getJson('/api/v1/messages?peer_id='.$this->peer->id)->assertNotFound();
    }

    public function test_history_projects_only_released_matches_in_local_restoration(): void
    {
        $published = $this->match('v1007-released');
        $hidden = $this->match('v1007-unreleased', false);
        $history = $this->getJson('/api/v1/match/history')->assertOk()->assertJsonPath('total', 1);
        $this->assertSame([$published->id], array_column($history->json('items'), 'match_id'));
        $this->assertNotContains($hidden->id, array_column($history->json('items'), 'match_id'));
        $this->getJson('/api/v1/match/current')->assertNotFound();
    }

    public function test_local_old_explanation_does_not_grant_unrestored_algorithm_authority(): void
    {
        $match = $this->match('v1007-old-explanation');
        $match->forceFill(['match_reasons' => ['modules' => [
            ['key' => 'natal_chart', 'score' => 80, 'weight' => .15, 'evidence' => ['engine' => 'legacy']],
        ]]])->save();
        $response = $this->getJson('/api/v1/match/current')->assertOk();
        $module = collect($response->json('match_reasons.modules'))->firstWhere('key', 'natal_chart');
        $this->assertArrayNotHasKey('weight', $module);
        $this->assertArrayNotHasKey('score', $module);
        $this->assertEquals(0, $module['confidence']);
        $this->assertTrue($module['degraded']);
        $this->assertSame('v1007_not_restored', $module['degrade_reason']);
        $this->assertSame(80, $match->fresh()->match_reasons['modules'][0]['score']);
    }

    public function test_disabled_peer_current_and_history_hide_explanation(): void
    {
        $this->match('v1007-disabled');
        $this->peer->forceFill(['disabled' => true])->save();
        $current = $this->getJson('/api/v1/match/current')->assertNotFound();
        $this->assertArrayNotHasKey('match_reasons', $current->json());
        $this->getJson('/api/v1/match/history')->assertOk()
            ->assertJsonPath('total', 0)->assertJsonPath('items', []);
    }

    public function test_blocked_peer_current_and_history_hide_explanation_in_both_directions(): void
    {
        $this->match('v1007-blocked');
        foreach ([[$this->actor, $this->peer], [$this->peer, $this->actor]] as [$blocker, $blocked]) {
            $block = UserBlock::create(['blocker_id' => $blocker->id, 'blocked_user_id' => $blocked->id, 'reason_code' => 'fixture']);
            $current = $this->getJson('/api/v1/match/current')->assertNotFound();
            $this->assertArrayNotHasKey('match_reasons', $current->json());
            $this->getJson('/api/v1/match/history')->assertOk()
                ->assertJsonPath('total', 0)->assertJsonPath('items', []);
            $block->delete();
        }
    }
}
