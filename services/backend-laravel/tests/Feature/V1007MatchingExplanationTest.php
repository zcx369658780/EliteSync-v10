<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Services\AstroCompatibilityService;
use App\Services\MatchingEngineService;
use Database\Seeders\QuestionnaireQuestionSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

final class V1007MatchingExplanationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        config(['restoration.enabled' => true, 'features.personality_test_enabled' => false,
            'python_astro.api_base' => '', 'python_astro.render_url' => '']);
        Http::preventStrayRequests();
    }

    public function test_actual_local_astro_scores_and_effective_weights_exclude_unrestored_modules(): void
    {
        $signals = ['private_bazi' => '己巳 壬申 戊辰 己未', 'zodiac_animal' => '蛇',
            'public_zodiac_sign' => '处女座', 'gender' => 'male', 'birthday' => '1989-09-05'];
        $result = app(AstroCompatibilityService::class)->score($signals, array_replace($signals, ['gender' => 'female']));
        foreach (['natal_chart', 'ziwei', 'pair_chart'] as $key) {
            $this->assertEquals(0, $result['effective_weights'][$key]);
            $this->assertSame(0, $result[$key]);
            $this->assertTrue($result['module_details'][$key]['degraded']);
            $this->assertSame('v1007_not_restored', $result['module_details'][$key]['degrade_reason']);
        }
    }

    public function test_real_engine_pair_persists_explanation_consistent_with_scoring_exclusions(): void
    {
        $this->seed(QuestionnaireQuestionSeeder::class);
        $question = QuestionnaireQuestion::where('enabled', true)->firstOrFail();
        $users = [];
        foreach (['male', 'female'] as $index => $gender) {
            $user = User::factory()->create(['phone' => '1990000078'.($index + 1), 'city' => '上海',
                'gender' => $gender, 'birthday' => '1989-09-05', 'disabled' => false, 'is_synthetic' => false,
                'public_mbti' => 'INTJ', 'private_bazi' => '己巳 壬申 戊辰 己未',
                'zodiac_animal' => '蛇', 'public_zodiac_sign' => '处女座']);
            QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $question->id,
                'selected_answer_json' => [$question->options[0]['option_id']],
                'acceptable_answers_json' => [$question->options[0]['option_id']],
                'answer_payload' => ['value' => $question->options[0]['option_id']], 'importance' => 2, 'version' => $question->version]);
            $users[] = $user;
        }
        $profiles = [];
        foreach ($users as $user) $profiles[$user->id] = ['vector' => ['EI' => 50, 'SN' => 50, 'TF' => 50, 'JP' => 50]];
        $pairs = app(MatchingEngineService::class)->buildPairs($profiles);
        $this->assertCount(1, $pairs);
        $persisted = DatingMatch::create($pairs[0] + ['week_tag' => 'v1007-explanation-fixture', 'drop_released' => true]);
        $modules = collect($persisted->fresh()->match_reasons['modules'])->keyBy('key');
        foreach (['natal_chart', 'ziwei', 'pair_chart'] as $key) {
            $this->assertTrue($modules->has($key));
            $this->assertEquals(0, $modules[$key]['weight']);
            $this->assertSame(0, $modules[$key]['score']);
            $this->assertTrue($modules[$key]['degraded']);
        }
        foreach (['mbti', 'personality'] as $key) {
            if ($modules->has($key)) {
                $this->assertEquals(0, $modules[$key]['weight']);
                $this->assertSame(0, $modules[$key]['score']);
            }
        }
        $this->assertSame(0, $persisted->score_mbti_total);
        $this->assertSame(0, $persisted->score_personality_total);
    }
}
