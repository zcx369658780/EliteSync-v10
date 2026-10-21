<?php
// Synthetic-only local harness. Guard effective config before migrations/writes.
require dirname(__DIR__, 3).'/vendor/autoload.php';
$app = require dirname(__DIR__, 3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(static function (Throwable $error): void {
    fwrite(STDERR, json_encode(['result' => 'FAIL', 'error_type' => get_class($error)], JSON_THROW_ON_ERROR).PHP_EOL);
    exit(1);
});
$db = Illuminate\Support\Facades\DB::connection();
if (! $app->environment('local') || $db->getDriverName() !== 'mysql'
    || $db->getDatabaseName() !== 'elitesync_v1015_dev' || $db->getConfig('host') !== '127.0.0.1'
    || (int) $db->getConfig('port') !== 43326 || $db->getConfig('unix_socket') || $db->getConfig('url')) {
    throw new RuntimeException('V1015_ISOLATION_GUARD_REJECTED');
}
$identity = $db->selectOne('SELECT DATABASE() AS db, CONNECTION_ID() AS connection_id, @@hostname AS hostname, @@tx_isolation AS isolation_level');
$mode = $argv[1] ?? 'identity';
if ($mode === 'migrate') {
    echo 'GUARD '.json_encode($identity, JSON_THROW_ON_ERROR).PHP_EOL;
    Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
    echo Illuminate\Support\Facades\Artisan::output();
} elseif (in_array($mode, ['seed', 'seed-relations'], true)) {
    if ($mode === 'seed') {
        if (App\Models\User::count() !== 0) throw new RuntimeException('SEED_REQUIRES_EMPTY_OWNED_DATABASE');
        $users = [];
        foreach (['A', 'B', 'C'] as $i => $name) {
            $users[] = App\Models\User::create(['phone' => '1990000150'.($i+1), 'name' => 'V1015 Fiction '.$name,
                'password' => Illuminate\Support\Facades\Hash::make('V1015-Test-Only-Password'), 'disabled' => false, 'is_synthetic' => false]);
        }
    } else {
        $users = App\Models\User::where('name', 'like', 'V1015 Fiction %')->orderBy('id')->get()->all();
        if (count($users) !== 3) throw new RuntimeException('OWNED_FIXTURE_IDENTITY_REQUIRED');
    }
    [$a, $b] = $users;
    App\Models\DatingMatch::firstOrCreate(['week_tag' => 'v1015', 'user_a' => $a->id, 'user_b' => $b->id], ['drop_released' => true]);
    $db->table('friendships')->insert(['user_a' => min($a->id,$b->id), 'user_b' => max($a->id,$b->id), 'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
    $consent = app(App\Services\LiveConsentService::class);
    foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision]) {
        $consent->transition($actor->id, $peer->id, $kind, $action, $revision);
    }
    echo json_encode(['fixture' => 'SYNTHETIC_ONLY', 'users' => array_map(fn($u)=>$u->id, $users), 'gates' => $consent->gates($a->id, $b->id)], JSON_THROW_ON_ERROR).PHP_EOL;
} elseif ($mode === 'snapshot') {
    $result = [];
    foreach (['users', 'device_sessions', 'chat_messages', 'message_attachments', 'notifications', 'product_connections', 'messaging_consents', 'notification_preferences', 'notification_devices'] as $table) {
        $rows = $db->table($table)->get()->map(fn($r)=>(array)$r)->all();
        usort($rows, fn($a,$b)=>strcmp(json_encode($a),json_encode($b)));
        $result[$table] = ['count' => count($rows), 'sha256' => hash('sha256', json_encode($rows, JSON_THROW_ON_ERROR))];
    }
    echo json_encode($result, JSON_PRETTY_PRINT | JSON_THROW_ON_ERROR).PHP_EOL;
} else {
    echo json_encode(['identity' => $identity, 'tables' => count($db->select('SHOW TABLES')), 'restoration' => app(App\Services\LiveConsentService::class)->enabled()], JSON_THROW_ON_ERROR).PHP_EOL;
}
