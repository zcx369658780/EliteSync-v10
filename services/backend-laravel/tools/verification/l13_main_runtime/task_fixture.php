<?php

// TEST_ONLY, CLI-only verification for this task's newly created private DB.
// The old-looking logical DB alias is inside a fresh container network namespace,
// never a host/previous database. No production or historical data is accepted.
if (PHP_SAPI !== 'cli' || getenv('ELITESYNC_TASK_ID') !== 'V1015_OWNER_STAGED_OCI_L13_MAIN_RUNTIME_INTEGRATION_20261031') {
    throw new RuntimeException('Task CLI identity required.');
}
require dirname(__DIR__, 3).'/vendor/autoload.php';
$app = require dirname(__DIR__, 3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Models\MediaAsset;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

function requireTaskDatabase(): void
{
    $db = DB::connection();
    $c = $db->getConfig();
    if (!app()->environment('local') || $db->getDriverName() !== 'mysql'
        || $db->getDatabaseName() !== 'elitesync_v10_1_4_dev'
        || ($c['host'] ?? '') !== '127.0.0.1' || (int)($c['port'] ?? 0) !== 43325
        || ($c['username'] ?? '') !== 'v1015_owner_oci_31'
        || !empty($c['url']) || !empty($c['unix_socket'])) {
        throw new RuntimeException('Unexpected task database configuration.');
    }
    $server = DB::selectOne('SELECT @@server_id AS id, @@port AS port, VERSION() AS version');
    if ((int)$server->id !== 10153101 || (int)$server->port !== 43325
        || !str_starts_with($server->version, '10.11.19-MariaDB')) {
        throw new RuntimeException('Unexpected new task MariaDB instance.');
    }
}

function tableSnapshot(string $database): array
{
    if (!in_array($database, ['elitesync_v10_1_4_dev', 'v1015_owner_oci_l13_restore_31'], true)) {
        throw new RuntimeException('Unexpected snapshot schema.');
    }
    $tables = DB::select('SELECT TABLE_NAME AS name FROM information_schema.tables WHERE TABLE_SCHEMA = ? ORDER BY TABLE_NAME', [$database]);
    $out = [];
    foreach ($tables as $table) {
        $name = $table->name;
        if (!preg_match('/^[a-zA-Z0-9_]+$/D', $name)) {
            throw new RuntimeException('Unsafe table identity.');
        }
        $rows = array_map(static fn ($row) => json_encode($row, JSON_THROW_ON_ERROR | JSON_INVALID_UTF8_SUBSTITUTE), DB::select("SELECT * FROM `$database`.`$name`"));
        sort($rows, SORT_STRING);
        $out[$name] = ['rows' => count($rows), 'sha256' => hash('sha256', implode("\n", $rows))];
    }
    return $out;
}

requireTaskDatabase();
$mode = $argv[1] ?? '';
if ($mode === 'empty-gate') {
    $tables = tableSnapshot('elitesync_v10_1_4_dev');
    if ($tables !== []) {
        throw new RuntimeException('Migration requires a brand-new empty task schema.');
    }
    echo json_encode(['empty' => true, 'server_id' => 10153101, 'db_port' => 43325, 'tables' => 0], JSON_THROW_ON_ERROR);
} elseif ($mode === 'seed') {
    $password = getenv('ELITESYNC_TEST_PASSWORD');
    if (!str_starts_with((string)$password, 'TEST_ONLY-') || strlen((string)$password) < 24 || User::count() !== 0) {
        throw new RuntimeException('Fresh task-only seed required.');
    }
    $result = DB::transaction(function () use ($password): array {
        $ids = [];
        foreach (['admin', 'platform_a', 'platform_b', 'outsider', 'sender', 'recipient', 'message_outsider', 'disabled'] as $i => $name) {
            $user = User::factory()->create([
                'phone' => '1990000310'.$i, 'name' => 'TEST_ONLY OCI L13 '.$name,
                'password' => Hash::make($password), 'role' => $name === 'admin' ? 'admin' : 'user',
                // These three fictional legacy-flow subjects mirror accepted main fixtures.
                // This field is not an assertion of real-world identity.
                'is_synthetic' => !in_array($name, ['sender', 'recipient', 'message_outsider'], true),
                'disabled' => $name === 'disabled', 'account_status' => 'active', 'moderation_status' => 'normal',
            ]);
            $ids[$name] = (int)$user->id;
        }
        DB::table('friendships')->insert([
            'user_a' => min($ids['sender'], $ids['recipient']),
            'user_b' => max($ids['sender'], $ids['recipient']),
            'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now(),
        ]);
        $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a2ioAAAAASUVORK5CYII=', true);
        $key = 'TEST_ONLY-owner-oci-l13-main/one-pixel.png';
        Storage::disk('v1007')->put($key, $png);
        $asset = MediaAsset::create([
            'owner_user_id' => $ids['sender'], 'media_type' => 'image', 'mime_type' => 'image/png',
            'storage_disk' => 'v1007', 'storage_provider' => 'local', 'storage_key' => $key,
            'status' => 'ready', 'size_bytes' => strlen($png),
        ]);
        return ['ids' => $ids, 'asset_id' => (int)$asset->id, 'asset_sha256' => hash('sha256', $png),
            'all_people_fictional' => true, 'media_scope' => 'seeded TEST_ONLY PNG permission/read fixture; not an upload/verifier claim'];
    });
    echo json_encode($result, JSON_THROW_ON_ERROR);
} elseif ($mode === 'facts') {
    $facts = [];
    foreach (['users', 'chat_messages', 'message_attachments', 'user_blocks', 'platform_events', 'platform_event_registrations', 'platform_event_commands', 'notifications'] as $table) {
        $facts[$table] = DB::table($table)->count();
    }
    $facts['latest_event'] = DB::table('platform_events')->orderByDesc('created_at')->first(['id', 'state', 'revision']);
    echo json_encode($facts, JSON_THROW_ON_ERROR);
} elseif ($mode === 'restored-snapshot') {
    echo json_encode(tableSnapshot('v1015_owner_oci_l13_restore_31'), JSON_THROW_ON_ERROR);
} elseif ($mode === 'snapshot') {
    echo json_encode(tableSnapshot('elitesync_v10_1_4_dev'), JSON_THROW_ON_ERROR);
} else {
    throw new RuntimeException('Unknown task fixture action.');
}
