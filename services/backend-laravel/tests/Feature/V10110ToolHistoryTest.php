<?php

namespace Tests\Feature;

use App\Models\User;
use App\Services\DynamicChartService;
use App\Services\NatalCalculationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class V10110ToolHistoryTest extends TestCase
{
    use RefreshDatabase;

    private function owner(): User
    {
        static $number = 1;
        return User::create(['phone' => '1991100'.str_pad((string) $number++, 4, '0', STR_PAD_LEFT),
            'password' => 'fictional-test-only', 'birthday' => '2000-01-01']);
    }

    private function input(): array
    {
        return ['civil_date' => '2000-01-01', 'civil_time' => '12:00', 'time_precision' => 'minute',
            'timezone' => 'Europe/London', 'latitude' => 51.5, 'longitude' => 0.0];
    }

    public function test_mbti_history_is_private_and_request_key_is_immutable(): void
    {
        config(['features.mbti_enabled' => true]);
        $owner = $this->owner();
        Sanctum::actingAs($owner);
        $quiz = $this->getJson('/api/v1/profile/mbti/quiz')->assertOk()->json();
        $body = ['version_code' => $quiz['version_code'], 'request_key' => 'b0f7b2c7-a379-49ce-8a83-cfa655941000',
            'answers' => array_map(fn ($q) => ['question_id' => $q['question_id'], 'option' => 'A'], $quiz['items'])];
        $id = $this->postJson('/api/v1/profile/mbti/submit', $body)->assertOk()->json('attempt_id');
        $this->postJson('/api/v1/profile/mbti/submit', $body)->assertOk()->assertJsonPath('attempt_id', $id);
        $this->assertDatabaseCount('mbti_attempts', 1);
        $body['answers'][0]['option'] = 'B';
        $this->postJson('/api/v1/profile/mbti/submit', $body)->assertConflict();
        $this->getJson('/api/v1/profile/mbti/history')->assertOk()->assertJsonCount(1, 'items');
        $this->getJson('/api/v1/profile/mbti/history/'.$id)->assertOk()
            ->assertJsonPath('attempt.source', 'configured_lite_quiz')->assertHeader('Cache-Control', 'no-store, private');
        $this->getJson('/api/v1/profile/mbti/result')->assertJsonPath('attempt_id', $id);
        Sanctum::actingAs($this->owner());
        $this->getJson('/api/v1/profile/mbti/history/'.$id)->assertNotFound();
        $this->getJson('/api/v1/profile/mbti/history')->assertJsonCount(0, 'items');
        $owner->forceFill(['disabled' => true])->save();
        Sanctum::actingAs($owner);
        $this->getJson('/api/v1/profile/mbti/history')->assertForbidden();
    }

    public function test_natal_edit_archives_previous_version_and_revalidates_results(): void
    {
        Sanctum::actingAs($this->owner());
        $this->mock(NatalCalculationService::class, fn ($mock) => $mock->shouldReceive('compute')
            ->andReturn(['western' => ['calculation_status' => 'CALCULATED', 'oracle_status' => 'UNVERIFIED']]));
        $body = ['input' => $this->input(), 'settings' => [], 'expected_revision' => 0];
        $this->postJson('/api/v1/profile/natal', $body)->assertOk();
        $body['input']['civil_time'] = '12:01';
        $body['expected_revision'] = 1;
        $this->postJson('/api/v1/profile/natal', $body)->assertOk()->assertJsonPath('profile.input_revision', 2);
        $id = $this->getJson('/api/v1/profile/natal/history')->assertOk()->assertJsonCount(1, 'items')->json('items.0.id');
        $this->getJson('/api/v1/profile/natal/history/'.$id)->assertOk()
            ->assertJsonPath('historical', true)->assertJsonPath('profile.input.civil_time', '12:00')
            ->assertJsonPath('profile.input_revision', 1);
        $this->getJson('/api/v1/profile/natal')->assertJsonPath('profile.input.civil_time', '12:01');
        config(['natal.python' => '/unavailable-v10110-test-python']);
        $this->getJson('/api/v1/profile/natal/history/'.$id)->assertOk()
            ->assertJsonPath('profile.status', 'STALE_RECALCULATION_REQUIRED')->assertJsonPath('profile.results', null);
        Sanctum::actingAs($this->owner());
        $this->getJson('/api/v1/profile/natal/history/'.$id)->assertNotFound();
    }

    public function test_dynamic_retry_history_and_owner_delete_are_consistent(): void
    {
        $owner = $this->owner();
        Sanctum::actingAs($owner);
        $this->partialMock(DynamicChartService::class, fn ($mock) => $mock->shouldReceive('compute')->twice()
            ->andReturn(['status' => 'CALCULATED', 'oracle_status' => 'UNVERIFIED']));
        $source = ['source' => 'manual', 'input' => $this->input()];
        $body = ['chart_type' => 'synastry', 'first' => $source, 'second' => $source,
            'settings' => [], 'expected_revision' => 0, 'request_key' => 'b0f7b2c7-a379-49ce-8a83-cfa655942000'];
        $id = $this->postJson('/api/v1/profile/dynamic', $body)->assertOk()->json('chart.id');
        $this->postJson('/api/v1/profile/dynamic', $body)->assertOk()->assertJsonPath('chart.id', $id);
        $this->assertDatabaseCount('user_dynamic_charts', 1);
        $bad = $body;
        $bad['second']['input']['civil_time'] = '13:00';
        $this->postJson('/api/v1/profile/dynamic', $bad)->assertConflict();
        $bad['request_key'] = 'b0f7b2c7-a379-49ce-8a83-cfa655942001';
        $bad['expected_revision'] = 1;
        $this->postJson('/api/v1/profile/dynamic/'.$id, $bad)->assertOk()->assertJsonPath('chart.input_revision', 2);
        $this->postJson('/api/v1/profile/dynamic', $body)->assertConflict();
        $archive = $this->getJson('/api/v1/profile/dynamic/'.$id.'/history')->assertOk()->json('items.0.id');
        $this->getJson('/api/v1/profile/dynamic/'.$id.'/history/'.$archive)->assertOk()
            ->assertJsonPath('chart.input_revision', 1)->assertJsonPath('chart.request.second.input.civil_time', '12:00');
        Sanctum::actingAs($this->owner());
        $this->deleteJson('/api/v1/profile/dynamic/'.$id)->assertNotFound();
        $this->getJson('/api/v1/profile/dynamic/'.$id.'/history/'.$archive)->assertNotFound();
        Sanctum::actingAs($owner);
        $this->deleteJson('/api/v1/profile/dynamic/'.$id)->assertOk()->assertJsonPath('deleted', true);
        $this->getJson('/api/v1/profile/dynamic/'.$id)->assertNotFound();
        $this->getJson('/api/v1/profile/dynamic/'.$id.'/history')->assertNotFound();
        $this->postJson('/api/v1/profile/dynamic', $bad)->assertStatus(410);
        $this->assertDatabaseCount('user_tool_revisions', 0);
    }

    public function test_dynamic_failed_compute_retries_original_command_without_new_row_or_revision(): void
    {
        Sanctum::actingAs($this->owner());
        $calls = 0;
        $this->partialMock(DynamicChartService::class, function ($mock) use (&$calls) {
            $mock->shouldReceive('compute')->twice()->andReturnUsing(function () use (&$calls) {
                if (++$calls === 1) {
                    throw new \RuntimeException('controlled calculator failure');
                }
                return ['status' => 'CALCULATED', 'oracle_status' => 'UNVERIFIED'];
            });
        });
        $source = ['source' => 'manual', 'input' => $this->input()];
        $body = ['chart_type' => 'comparison', 'first' => $source, 'second' => $source,
            'settings' => [], 'expected_revision' => 0, 'request_key' => 'b0f7b2c7-a379-49ce-8a83-cfa655943000'];
        $this->postJson('/api/v1/profile/dynamic', $body)->assertStatus(503);
        $this->postJson('/api/v1/profile/dynamic', $body)->assertOk()
            ->assertJsonPath('chart.input_revision', 1)->assertJsonPath('chart.result_revision', 1);
        $this->assertDatabaseCount('user_dynamic_charts', 1);
        $this->assertDatabaseCount('dynamic_chart_commands', 1);
    }

    public function test_new_history_is_bounded_and_mbti_rejects_duplicate_answers(): void
    {
        config(['features.mbti_enabled' => true]);
        Sanctum::actingAs($this->owner());
        for ($index = 0; $index < 22; $index++) {
            \App\Models\MbtiAttempt::create(['user_id' => auth()->id(), 'version_code' => 'lite3_v1',
                'answers_json' => [], 'score_json' => [], 'confidence_json' => [],
                'tie_break_log_json' => [], 'result_letters' => 'INTJ', 'submitted_at' => now()]);
        }
        $page = $this->getJson('/api/v1/profile/mbti/history')->assertOk()->assertJsonCount(20, 'items');
        $this->getJson('/api/v1/profile/mbti/history?before_id='.$page->json('next_before_id'))
            ->assertOk()->assertJsonCount(2, 'items')->assertJsonPath('next_before_id', null);
        $answers = [['question_id' => 1, 'option' => 'A'], ['question_id' => 2, 'option' => 'B'],
            ['question_id' => 3, 'option' => 'A'], ['question_id' => 1, 'option' => 'A']];
        $this->postJson('/api/v1/profile/mbti/submit', ['version_code' => 'lite3_v1', 'answers' => $answers])->assertUnprocessable();
        $this->postJson('/api/v1/profile/dynamic', ['request_key' => 'invalid'])->assertUnprocessable();
        $this->getJson('/api/v1/profile/natal/history?before_id=-1')->assertUnprocessable();
        $this->assertDatabaseCount('mbti_attempts', 22);
    }
}
