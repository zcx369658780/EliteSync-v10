<?php

// Explicit test fixtures for isolated MariaDB and real loopback HTTP verification.
require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Services\AutomationService;
use App\Services\LifestyleDiscoveryService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

try {
    $database = DB::selectOne('SELECT DATABASE() AS name')->name;
    if (! preg_match('/^elitesync_b2_test_[a-f0-9]{12}$/', $database)
        || DB::connection()->getDriverName() !== 'mysql' || ! app()->environment('testing')) {
        throw new RuntimeException('Explicit isolated B2 test SQL connection required');
    }
    config(['questionnaire.required_answer_count' => 1, 'restoration.enabled' => true]);
    $mode = $argv[1];
    $result = ['mode' => $mode];
    if ($mode === 'init') {
        $user = User::factory()->create(['phone' => 'b2-r1-'.Str::lower(Str::random(16)),
            'disabled' => false, 'verify_status' => 'approved', 'is_synthetic' => false]);
        app(\App\Services\MatchingInputService::class)->save($user->id, [
            'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => 'male',
            'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
            'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
        ]);
        $question = \App\Models\QuestionnaireQuestion::firstOrCreate(['question_key' => 'r1-isolated-fixture'], [
            'category' => 'test', 'content' => 'Fictional R1 fixture', 'question_type' => 'single_choice',
            'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
        \App\Models\QuestionnaireAnswer::create(['user_id' => $user->id,
            'questionnaire_question_id' => $question->id, 'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
        $lifestyle = app(LifestyleDiscoveryService::class);
        foreach ($lifestyle->bank()['scenes'] as $revision => $scene) {
            $lifestyle->command($user->id, ['action' => 'answer', 'expected_revision' => $revision,
                'questionnaire_version' => 'lifestyle_v1', 'request_key' => (string) Str::uuid(),
                'scene_id' => $scene['id'], 'option_id' => $scene['options'][0]['id']]);
        }
        if (! DB::table('dating_round_channels')->where('channel_key', 'default')->value('active_round_id')) {
            app(\App\Services\MatchingRoundService::class)->prepare('default', 'r1-controlled-fixture', now(), now()->addHour(), 'test', null);
        }
        $result += ['user_id' => $user->id, 'token' => $user->createToken('R1-isolated-HTTP', ['*'])->plainTextToken];
    } elseif ($mode === 'tick') {
        $result['processed'] = app(AutomationService::class)->tick('r1-fixture-'.Str::uuid(), 100);
    } else {
        $user = User::where('phone', 'like', 'b2-r1-%')->findOrFail((int) $argv[2]);
        if ($mode === 'expire') {
            DB::table('automation_authorizations')->where('user_id', $user->id)->update(['expires_at' => now()->subSecond()]);
        } elseif ($mode === 'policy') {
            DB::table('automation_authorizations')->where('user_id', $user->id)->update(['policy_version' => 'r1-obsolete-policy']);
        } elseif ($mode === 'inspect') {
            $result += ['participation' => DB::table('matching_participations')->where('user_id', $user->id)->first(),
                'authorization' => DB::table('automation_authorizations')->where('user_id', $user->id)->first(),
                'effects' => DB::table('automation_effects')->where('user_id', $user->id)->get(),
                'tasks' => DB::table('automation_tasks')->where('user_id', $user->id)->get(),
                'matching_runs' => DB::table('matching_runs')->count(),
                'proposals' => DB::table('match_proposals')->count()];
        } else {
            throw new RuntimeException('Unknown R1 fixture mode');
        }
    }
    echo json_encode($result, JSON_THROW_ON_ERROR).PHP_EOL.'R1_FIXTURE_COMPLETED'.PHP_EOL;
} catch (\Throwable $error) {
    fwrite(STDERR, 'R1_FIXTURE_FAILED '.get_class($error).PHP_EOL);
    exit(1);
}
