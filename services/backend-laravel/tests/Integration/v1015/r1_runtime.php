<?php

// R1 synthetic fixtures only. Validate effective configuration before writes.
require dirname(__DIR__, 3).'/vendor/autoload.php';
$app = require dirname(__DIR__, 3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(static function (Throwable $error): void {
    fwrite(STDERR, json_encode(['result' => 'FAIL', 'error_type' => get_class($error)], JSON_THROW_ON_ERROR).PHP_EOL);
    exit(1);
});
$db = Illuminate\Support\Facades\DB::connection();
if (! $app->environment('local') || $db->getDriverName() !== 'mysql'
    || $db->getDatabaseName() !== 'elitesync_v1015_r1_dev' || $db->getConfig('host') !== '127.0.0.1'
    || (int) $db->getConfig('port') !== 43327 || $db->getConfig('unix_socket') || $db->getConfig('url')) {
    throw new RuntimeException('V1015_R1_ISOLATION_GUARD_REJECTED');
}
$identity = $db->selectOne('SELECT DATABASE() AS db, CONNECTION_ID() AS connection_id, @@hostname AS hostname, @@tx_isolation AS isolation_level');
$mode = $argv[1] ?? 'identity';
if ($mode === 'migrate') {
    if (count($db->select('SHOW TABLES')) !== 0) throw new RuntimeException('EMPTY_R1_DATABASE_REQUIRED');
    Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
    echo Illuminate\Support\Facades\Artisan::output();
} elseif ($mode === 'seed') {
    if (App\Models\User::count() !== 0) throw new RuntimeException('EMPTY_OWNED_FIXTURE_REQUIRED');
    $users = [];
    foreach (['A', 'B', 'C'] as $i => $name) {
        $users[] = App\Models\User::create(['phone' => '1990000151'.($i + 1), 'name' => 'V1015 R1 Fiction '.$name,
            'password' => Illuminate\Support\Facades\Hash::make('V1015R1-Test-Only-Password'), 'disabled' => false, 'is_synthetic' => false]);
    }
    [$a, $b] = $users;
    $db->table('friendships')->insert(['user_a' => $a->id, 'user_b' => $b->id, 'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    $consent = app(App\Services\LiveConsentService::class);
    foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision]) {
        $consent->transition($actor->id, $peer->id, $kind, $action, $revision);
    }
    echo json_encode(['fixture' => 'SYNTHETIC_ONLY_R1', 'users' => array_map(fn ($u) => $u->id, $users), 'gates' => $consent->gates($a->id, $b->id)], JSON_THROW_ON_ERROR).PHP_EOL;
} elseif ($mode === 'safety-fixture') {
    if ($db->table('safety_cases')->count() !== 0) throw new RuntimeException('EMPTY_R1_SAFETY_FIXTURE_REQUIRED');
    $people = [];
    foreach (['D','E','F'] as $i => $name) {
        $people[] = App\Models\User::create(['phone' => '1990000151'.($i + 4), 'name' => 'V1015 R1 Fiction '.$name,
            'password' => Illuminate\Support\Facades\Hash::make('V1015R1-Test-Only-Password'),
            'is_synthetic' => true, 'disabled' => false, 'account_status' => 'active', 'moderation_status' => 'normal']);
    }
    [$reporter,$subject,$stranger] = $people;
    $uuid = fn () => (string) Illuminate\Support\Str::uuid();
    $event = $uuid(); $case = $uuid(); $registrations = [$uuid(),$uuid()];
    $db->table('platform_events')->insert(['id' => $event, 'organizer_id' => $reporter->id,
        'title' => 'R1 SYNTHETIC fixture', 'city' => 'TEST_ONLY', 'venue' => 'TEST_ONLY',
        'start_at' => now()->subHours(2), 'end_at' => now()->subHour(), 'capacity' => 2,
        'state' => 'COMPLETED', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    foreach ([$reporter,$subject] as $i => $person) {
        $grant = $uuid();
        $db->table('platform_event_grants')->insert(['id' => $grant, 'event_id' => $event,
            'recipient_id' => $person->id, 'state' => 'ACCEPTED', 'expires_at' => now()->addDay(),
            'created_at' => now(), 'updated_at' => now()]);
        $db->table('platform_event_registrations')->insert(['id' => $registrations[$i], 'event_id' => $event,
            'user_id' => $person->id, 'grant_id' => $grant, 'state' => 'CONFIRMED', 'revision' => 1, 'attendance' => 'UNVERIFIED',
            'created_at' => now(), 'updated_at' => now()]);
    }
    $report = $db->table('moderation_reports')->insertGetId(['reporter_id' => $reporter->id,
        'target_user_id' => $subject->id, 'category' => 'platform_event', 'reason_code' => 'CONDUCT',
        'detail' => 'R1_SYNTHETIC_PRIVATE_STATEMENT_MUST_NOT_DISPLAY', 'status' => 'new',
        'appeal_status' => 'none', 'admin_revision' => 0, 'created_at' => now(), 'updated_at' => now()]);
    $db->table('safety_cases')->insert(['id' => $case, 'event_id' => $event, 'report_id' => $report,
        'reporter_id' => $reporter->id, 'subject_id' => $subject->id,
        'reporter_registration_id' => $registrations[0], 'subject_registration_id' => $registrations[1],
        'category' => 'CONDUCT', 'state' => 'OPEN', 'revision' => 1, 'review_due_at' => now()->addDays(7),
        'idempotency_key' => $uuid(), 'created_at' => now(), 'updated_at' => now()]);
    app(App\Services\NotificationService::class)->createForUser($reporter->id, 'safety_case',
        'R1_SYNTHETIC_PRIVATE_STATEMENT_MUST_NOT_DISPLAY', 'R1_SYNTHETIC_PRIVATE_STATEMENT_MUST_NOT_DISPLAY',
        ['safety_case_id' => $case]);
    echo json_encode(['fixture' => 'TEST_ONLY_DIRECT_SAFETY_FIXTURE_NOT_WORKFLOW_ACCEPTANCE',
        'case_id' => $case, 'reporter' => $reporter->id, 'subject' => $subject->id, 'stranger' => $stranger->id], JSON_THROW_ON_ERROR).PHP_EOL;
} elseif ($mode === 'audit') {
    $messages = $db->table('chat_messages')->get();
    $counts = [];
    foreach ($db->table('notifications')->where('kind', 'message')->get() as $notice) {
        $id = json_decode($notice->payload, true)['message_id'] ?? null;
        if ($id) $counts[$id] = ($counts[$id] ?? 0) + 1;
    }
    echo json_encode(['message_count' => $messages->count(), 'message_ids' => $messages->pluck('id'),
        'client_message_ids' => $messages->pluck('client_message_id'), 'notification_message_id_counts' => $counts,
        'attachment_count' => $db->table('message_attachments')->count()], JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR).PHP_EOL;
} elseif ($mode === 'snapshot') {
    $snapshot = [];
    foreach (['users','device_sessions','chat_messages','message_attachments','notifications','product_connections','messaging_consents','notification_preferences','notification_devices','rtc_sessions'] as $table) {
        if (! Illuminate\Support\Facades\Schema::hasTable($table)) continue;
        $rows = $db->table($table)->get()->map(fn ($row) => (array) $row)->all();
        usort($rows, fn ($a, $b) => strcmp(json_encode($a), json_encode($b)));
        $snapshot[$table] = ['count' => count($rows), 'sha256' => hash('sha256', json_encode($rows, JSON_THROW_ON_ERROR))];
    }
    echo json_encode($snapshot, JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR).PHP_EOL;
} else {
    echo json_encode(['identity' => $identity, 'table_count' => count($db->select('SHOW TABLES')), 'restoration' => app(App\Services\LiveConsentService::class)->enabled()], JSON_THROW_ON_ERROR).PHP_EOL;
}
