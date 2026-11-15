<?php

// Run in an explicitly isolated B1 MariaDB schema. No development records are read.
require '/app/vendor/autoload.php';
$app = require '/app/bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\LifestyleDiscoveryService;
use Illuminate\Support\Facades\DB;

$database = getenv('B1_TEST_DATABASE');
if (! preg_match('/^elitesync_b1_rr_[a-f0-9]{12}$/', $database ?: '')) {
    throw new RuntimeException('Explicit isolated B1 schema required');
}
$config = DB::connection()->getConfig();
$config['database'] = $database;
$config['username'] = getenv('B1_TEST_USER');
$config['password'] = getenv('B1_TEST_PASSWORD');
$config['url'] = null;
config(['database.connections.b1a' => $config, 'database.connections.b1b' => $config,
    'database.default' => 'b1a']);
$a = DB::connection('b1a');
$b = DB::connection('b1b');
$a->statement('CREATE TABLE users (id BIGINT UNSIGNED PRIMARY KEY) ENGINE=InnoDB');
$a->statement('CREATE TABLE lifestyle_discoveries (user_id BIGINT UNSIGNED PRIMARY KEY,
    questionnaire_version VARCHAR(40), status VARCHAR(24), completed_at DATETIME NULL) ENGINE=InnoDB');
$a->table('users')->insert(['id' => 1]);
$a->table('lifestyle_discoveries')->insert(['user_id' => 1, 'questionnaire_version' => 'lifestyle_v1',
    'status' => 'completed', 'completed_at' => now()]);
$a->statement('SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ');
$b->statement('SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ');
$a->beginTransaction();
try {
    // Mirrors the publisher's candidate locator read before sorted User locks.
    $a->table('users')->pluck('id');
    $b->transaction(function () use ($b) {
        $b->table('users')->where('id', 1)->lockForUpdate()->first();
        $b->table('lifestyle_discoveries')->where('user_id', 1)
            ->update(['status' => 'not_started', 'completed_at' => null]);
    });
    $a->table('users')->where('id', 1)->lockForUpdate()->first();
    $service = app(LifestyleDiscoveryService::class);
    $stale = $service->completed(1);
    $current = $service->completed(1, true);
    if ($stale !== true || $current !== false) {
        throw new RuntimeException('Current-read regression');
    }
    echo json_encode(['database_scope' => 'new isolated schema', 'connections' => 2,
        'isolation' => 'REPEATABLE-READ', 'old_snapshot_completed' => $stale,
        'locked_current_completed' => $current, 'reset_committed_before_user_lock' => true,
        'result' => 'PASS'], JSON_THROW_ON_ERROR).PHP_EOL;
} finally {
    $a->rollBack();
}
