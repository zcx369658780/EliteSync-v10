<?php

// This executable fixture is permitted only in a newly named isolated B2 test schema.
require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\User;
use App\Services\AutomationAuthorizationService;
use App\Services\AutomationService;
use App\Services\LifestyleDiscoveryService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

if (! preg_match('/^elitesync_b2_test_[a-f0-9]{12}$/', DB::connection()->getDatabaseName())
    || DB::connection()->getDriverName() !== 'mysql' || ! app()->environment('testing')) {
    throw new RuntimeException('Explicit isolated B2 test schema required');
}
config(['questionnaire.required_answer_count' => 1, 'restoration.enabled' => true,
    'user_automation.retry_seconds' => [0, 0]]);
$mode = $argv[1];
$id = isset($argv[2]) ? (int) $argv[2] : null;
$service = app(AutomationService::class);
if ($mode === 'init') {
    $user = User::factory()->create(['phone' => 'b2-isolated-'.Str::lower(Str::random(16)), 'disabled' => false, 'verify_status' => 'approved']);
    app(\App\Services\MatchingInputService::class)->save($user->id, [
        'revision' => 0, 'confirm' => true, 'birthday' => '1995-01-02', 'gender' => 'male',
        'city_key' => '上海', 'relationship_goal' => 'marriage', 'age_mode' => 'adult_any',
        'age_min' => null, 'age_max' => null, 'region_mode' => 'same_city',
    ]);
    $q = \App\Models\QuestionnaireQuestion::firstOrCreate(['question_key' => 'b2-process-fixture'], [
        'category' => 'test', 'content' => 'Fictional fixture', 'question_type' => 'single_choice',
        'options' => [['option_id' => 'A']], 'enabled' => true, 'version' => 1]);
    \App\Models\QuestionnaireAnswer::create(['user_id' => $user->id, 'questionnaire_question_id' => $q->id,
        'answer_payload' => ['selected_answer' => ['A']], 'version' => 1]);
    $lifestyle = app(LifestyleDiscoveryService::class);
    foreach ($lifestyle->bank()['scenes'] as $revision => $scene) {
        $lifestyle->command($user->id, ['action' => 'answer', 'expected_revision' => $revision,
            'questionnaire_version' => 'lifestyle_v1', 'request_key' => (string) Str::uuid(),
            'scene_id' => $scene['id'], 'option_id' => $scene['options'][0]['id']]);
    }
    app(AutomationAuthorizationService::class)->command($user, ['action' => 'grant', 'expected_revision' => 0,
        'policy_version' => 'weekly_participation_v1', 'consent_version' => 'weekly_consent_v1', 'request_key' => (string) Str::uuid()]);
    $channel = DB::table('dating_round_channels')->where('channel_key', 'default')->first();
    if (! $channel?->active_round_id) {
        app(\App\Services\MatchingRoundService::class)->prepare('default', 'isolated-b2-fixture', now(), now()->addHour(), 'test', null);
    }
    $service->schedule(100);
    $task = DB::table('automation_tasks')->where('user_id', $user->id)->first();
    echo json_encode(['user_id' => $user->id, 'task_id' => $task->id]).PHP_EOL;
} elseif ($mode === 'expire') {
    DB::table('automation_tasks')->where('id', $id)->update(['lease_expires_at' => now()->subSecond(), 'available_at' => now()->subSecond()]);
} elseif ($mode === 'tick') {
    $service->tick('recovery-'.Str::uuid(), 100);
} elseif ($mode === 'revoke') {
    $task = DB::table('automation_tasks')->where('id', $id)->first();
    $user = User::findOrFail($task->user_id);
    $row = app(AutomationAuthorizationService::class)->row($user->id);
    app(AutomationAuthorizationService::class)->command($user, ['action' => 'revoke', 'expected_revision' => $row->revision,
        'policy_version' => 'weekly_participation_v1', 'consent_version' => 'weekly_consent_v1', 'request_key' => (string) Str::uuid()]);
} elseif ($mode === 'inspect') {
    $task = DB::table('automation_tasks')->where('id', $id)->first();
    $p = DB::table('matching_participations')->where('user_id', $task->user_id)->first();
    echo json_encode(['state' => $task->state, 'result_code' => $task->result_code,
        'attempts' => $task->attempt_count, 'reconciliation' => $task->reconciliation,
        'effects' => DB::table('automation_effects')->where('task_id', $id)->count(),
        'participation_revision' => $p->revision ?? 0, 'participation_state' => $p->state ?? 'NOT_ENROLLED',
        'matching_runs' => DB::table('matching_runs')->count(), 'proposals' => DB::table('match_proposals')->count()]).PHP_EOL;
} else {
    $claim = $service->claim('process-'.Str::uuid());
    echo json_encode(['claimed' => $claim->id ?? null]).PHP_EOL;
    flush();
    if (! $claim) { echo 'B2_WORKER_FIXTURE_COMPLETED'.PHP_EOL; exit(0); }
    if ($mode === 'hold') {
        $path = getenv('B2_PROCESS_BARRIER');
        if (! preg_match('#^/tmp/v10116-[a-f0-9]{12}-release$#', $path ?: '')) { throw new RuntimeException('Owned fixture barrier required'); }
        file_put_contents($path.'.claimed', (string) $claim->id);
        $until = microtime(true) + 20;
        while (! file_exists($path) && microtime(true) < $until) { usleep(100000); }
        if (! file_exists($path)) { throw new RuntimeException('Fixture release timed out'); }
    }
    if ($mode === 'kill-before-commit') {
        DB::listen(function ($query) {
            if (str_starts_with(strtolower($query->sql), 'insert into `automation_effects`')) {
                posix_kill(posix_getpid(), 9);
            }
        });
    }
    $service->apply($claim);
    if ($mode === 'kill-after-commit') { posix_kill(posix_getpid(), 9); }
    $service->complete($claim);
}

echo 'B2_WORKER_FIXTURE_COMPLETED'.PHP_EOL;
