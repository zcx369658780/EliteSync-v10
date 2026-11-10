<?php

/** Real local MariaDB / HTTP-kernel probe. Never run against shared/production DBs. */
use App\Models\{User, MediaAsset, StatusPost, StatusPostLike};
use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\{DB, Storage};

require dirname(__DIR__, 3).'/vendor/autoload.php';
$app = require dirname(__DIR__, 3).'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
$command = $argv[1] ?? '';
$configPath = $argv[2] ?? '';
$cfg = json_decode(file_get_contents($configPath), true, 512, JSON_THROW_ON_ERROR);
$connection = DB::connection();
if ($connection->getDriverName() !== 'mysql' || $connection->getDatabaseName() !== 'elitesync_v10_1_1_dev'
    || $connection->getConfig('host') !== '127.0.0.1' || $connection->getConfig('unix_socket')
    || (int) $connection->getConfig('port') !== 43322 || ! $app->environment('local')) {
    throw new RuntimeException('R1 exact local database guard rejected');
}
function saveJson(string $path, array $value): void {
    $tmp = $path.'.'.getmypid().'.tmp';
    file_put_contents($tmp, json_encode($value, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_THROW_ON_ERROR));
    rename($tmp, $path);
}
function mark(string $event, array $extra = []): void {
    global $dir;
    file_put_contents($dir.'/events.jsonl', json_encode(['event' => $event, 'wall_time' => microtime(true), 'pid' => getmypid()] + $extra, JSON_THROW_ON_ERROR)."\n", FILE_APPEND | LOCK_EX);
    saveJson($dir.'/'.$event.'.json', ['event' => $event, 'wall_time' => microtime(true)] + $extra);
}
function barrier(string $name): void {
    global $dir;
    $end = microtime(true) + 45;
    while (! is_file($dir.'/'.$name)) {
        if (microtime(true) > $end) { throw new RuntimeException('barrier timeout: '.$name); }
        usleep(10000);
    }
}
function http(string $method, string $path, string $token, array $data = []): array {
    global $app;
    $request = Request::create($path, $method, [], [], [], [
        'HTTP_AUTHORIZATION' => 'Bearer '.$token, 'HTTP_ACCEPT' => 'application/json',
        'CONTENT_TYPE' => 'application/json', 'HTTP_HOST' => '127.0.0.1:8012',
        'HTTP_X_APP_VERSION' => '10.1.1-r1-barrier', 'HTTP_X_SOURCE_PAGE' => 'r1-regression',
    ], json_encode($data, JSON_THROW_ON_ERROR));
    // A new request must resolve Sanctum from its own bearer, even in fixture setup.
    $app->make('auth')->forgetGuards();
    $kernel = $app->make(Kernel::class);
    $response = $kernel->handle($request);
    ob_start();
    $response->sendContent();
    $bytes = ob_get_clean();
    $kernel->terminate($request, $response);
    return ['status' => $response->getStatusCode(), 'length' => strlen($bytes),
        'sha256' => hash('sha256', $bytes), 'content_type' => $response->headers->get('Content-Type'), '_body' => $bytes];
}
function effects(array $c): array {
    $events = DB::table('app_events')->where('actor_user_id', $c['viewer_id'])
        ->whereIn('event_name', ['status_post_like', 'status_post_unlike'])->get(['id', 'event_name', 'payload']);
    $notifications = DB::table('notifications')->where('user_id', $c['owner_id'])->where('kind', 'status_like')->get(['id', 'payload']);
    return ['like_count' => StatusPostLike::where('status_post_id', $c['post_id'])->where('user_id', $c['viewer_id'])->count(),
        'events' => $events->filter(fn ($r) => (int) (json_decode($r->payload, true)['status_post_id'] ?? 0) === $c['post_id'])->values()->all(),
        'notifications' => $notifications->filter(fn ($r) => (int) (json_decode($r->payload, true)['status_post_id'] ?? 0) === $c['post_id'])->values()->all()];
}
function persistedAuthorization(array $c): array {
    // These reads must run after the real request's transaction has ended, so
    // they cannot inherit its RR snapshot or confuse uncommitted state with a
    // successfully committed revocation.
    if (DB::transactionLevel() !== 0 || DB::connection()->getPdo()->inTransaction()) {
        throw new RuntimeException('request left a transaction open before persistent-state readback');
    }
    $post = DB::table('status_posts')->where('id', $c['post_id'])->first(['audience', 'is_deleted']);
    $friendship = DB::table('friendships')->where('user_a', min($c['owner_id'], $c['viewer_id']))
        ->where('user_b', max($c['owner_id'], $c['viewer_id']))->first(['state', 'revision']);
    return ['transaction_level' => DB::transactionLevel(), 'post_exists' => $post !== null,
        'post_audience' => $post?->audience, 'post_is_deleted' => $post ? (bool) $post->is_deleted : null,
        'friendship_state' => $friendship?->state, 'friendship_revision' => $friendship ? (int) $friendship->revision : null,
        'owner_blocks_viewer' => DB::table('user_blocks')->where('blocker_id', $c['owner_id'])->where('blocked_user_id', $c['viewer_id'])->exists(),
        'viewer_blocks_owner' => DB::table('user_blocks')->where('blocker_id', $c['viewer_id'])->where('blocked_user_id', $c['owner_id'])->exists()];
}
function revoke(array $c): array {
    return match ($c['revoke']) {
        'audience' => http('PUT', '/api/v1/status/posts/'.$c['post_id'].'/audience', $c['owner_token'], ['audience' => 'SELF']),
        'unfriend' => http('DELETE', '/api/v1/social/friends/'.$c['viewer_id'], $c['owner_token']),
        'block' => http('POST', '/api/v1/moderation/blocks', $c['owner_token'], ['blocked_user_id' => $c['viewer_id'], 'reason_code' => 'R1_SYNTHETIC']),
        default => throw new RuntimeException('unknown revoke'),
    };
}
if ($command === 'fixture') {
    if (is_file($cfg['suite_path'])) { throw new RuntimeException('suite output already exists'); }
    $cases = [];
    foreach (['race', 'serial', 'positive'] as $mode) {
        foreach ($mode === 'positive' ? ['none'] : ['audience', 'unfriend', 'block'] as $revocation) {
            foreach (['media', 'like', 'unlike'] as $action) {
                $label = $mode.'-'.$revocation.'-'.$action;
                $batch = 'v1011-r1-'.bin2hex(random_bytes(8));
                $users = [];
                foreach (['owner', 'viewer'] as $role) {
                    $users[$role] = User::create(['name' => 'R1 Fiction '.$role, 'email' => $batch.'-'.$role.'@example.invalid',
                        'phone' => '179'.str_pad((string) random_int(0, 99999999), 8, '0', STR_PAD_LEFT),
                        'password' => bin2hex(random_bytes(24)), 'role' => 'user', 'account_type' => 'normal',
                        'is_synthetic' => true, 'synthetic_batch' => $batch, 'disabled' => false,
                        'moderation_status' => 'normal', 'exclude_from_metrics' => true]);
                }
                $owner = $users['owner']; $viewer = $users['viewer'];
                DB::table('friendships')->insert(['user_a' => min($owner->id, $viewer->id), 'user_b' => max($owner->id, $viewer->id),
                    'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
                // Valid CRC-checked 32x32 RGB fixture, also renderable by APP.
                $png = base64_decode('iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAKklEQVR4nGNIaDhAU8QwasGoBaMWjFowasGoBaMWjFowasGoBaMWDBULANs4gFsEScpzAAAAAElFTkSuQmCC');
                $key = 'r1-synthetic/'.$batch.'/cover.png';
                Storage::disk('v1011_relationship')->put($key, $png);
                $asset = MediaAsset::create(['owner_user_id' => $owner->id, 'media_type' => 'image', 'storage_provider' => 'local',
                    'storage_disk' => 'v1011_relationship', 'storage_key' => $key, 'mime_type' => 'image/png',
                    'size_bytes' => strlen($png), 'sha256' => hash('sha256', $png), 'status' => 'ready']);
                $marker = 'PRIVATE_R1_'.$batch;
                $post = StatusPost::create(['author_user_id' => $owner->id, 'cover_media_asset_id' => $asset->id,
                    'title' => $marker, 'body' => $marker.'_BODY', 'audience' => 'FRIENDS', 'visibility' => 'public', 'is_deleted' => false]);
                if ($action === 'unlike') { StatusPostLike::create(['status_post_id' => $post->id, 'user_id' => $viewer->id]); }
                $cases[] = ['label' => $label, 'mode' => $mode, 'revoke' => $revocation, 'action' => $action, 'batch' => $batch,
                    'owner_id' => (int) $owner->id, 'viewer_id' => (int) $viewer->id, 'post_id' => (int) $post->id,
                    'asset_id' => (int) $asset->id, 'storage_key' => $key, 'private_body_marker' => $marker,
                    'expected_media_sha256' => hash('sha256', $png),
                    'owner_token' => $owner->createToken('r1-synthetic')->plainTextToken,
                    'viewer_token' => $viewer->createToken('r1-synthetic')->plainTextToken];
            }
        }
    }
    saveJson($cfg['suite_path'], ['local_only' => true, 'cases' => $cases]);
    echo json_encode(['created_cases' => count($cases), 'created_synthetic_users' => count($cases) * 2])."\n";
    exit(0);
}
$c = $cfg['case']; $dir = $cfg['work_dir'];
if (! is_dir($dir)) { throw new RuntimeException('work_dir must exist'); }
try {
    if ($command === 'observe') {
        $pdo = new PDO($cfg['observer_dsn'], $cfg['observer_user'], $cfg['observer_password'], [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $rows = $pdo->query('SELECT r.trx_mysql_thread_id AS waiting_connection, b.trx_mysql_thread_id AS blocking_connection, r.trx_query AS waiting_query FROM information_schema.INNODB_LOCK_WAITS w JOIN information_schema.INNODB_TRX r ON r.trx_id=w.requesting_trx_id JOIN information_schema.INNODB_TRX b ON b.trx_id=w.blocking_trx_id')->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode($rows, JSON_THROW_ON_ERROR)."\n"; exit(0);
    }
    mark($command.'_started', ['connection_id' => (int) DB::selectOne('SELECT CONNECTION_ID() AS id')->id,
        'database' => DB::connection()->getDatabaseName(), 'version' => DB::selectOne('SELECT VERSION() AS v')->v,
        'session_isolation' => DB::selectOne('SELECT @@session.tx_isolation AS v')->v,
        'global_isolation' => DB::selectOne('SELECT @@global.tx_isolation AS v')->v]);
    if ($command === 'revoke') {
        if ($c['mode'] === 'race') {
            DB::beginTransaction();
            User::whereIn('id', [$c['owner_id'], $c['viewer_id']])->orderBy('id')->lockForUpdate()->get();
            mark('revoker_user_locks_held');
            barrier('allow_revoke');
        }
        $response = revoke($c); unset($response['_body']);
        mark('revocation_written', ['response' => $response]);
        if ($response['status'] !== 200) { throw new RuntimeException('product revocation failed'); }
        if ($c['mode'] === 'race') { DB::commit(); }
        mark('revocation_committed'); exit(0);
    }
    if ($command !== 'reader') { throw new RuntimeException('unknown command'); }
    $before = effects($c);
    $first = false;
    DB::listen(function ($q) use (&$first) {
        $sql = strtolower($q->sql);
        if (! $first && ((str_contains($sql, 'chat_messages') && str_contains($sql, 'attachments'))
            || (str_contains($sql, 'status_posts') && str_contains($sql, 'author_user_id')))) {
            $first = true;
            mark('first_target_read', ['sql' => $q->sql, 'transaction_level' => DB::transactionLevel()]);
        }
        if (str_contains($sql, '`users`') && str_contains($sql, 'for update')) {
            mark('reader_user_locks_acquired', ['transaction_level' => DB::transactionLevel()]);
        }
    });
    DB::connection()->beforeExecuting(function ($sql) {
        if (str_contains(strtolower($sql), '`users`') && str_contains(strtolower($sql), 'for update')) {
            mark('reader_user_lock_attempt', ['transaction_level' => DB::transactionLevel()]);
        }
    });
    $r = match ($c['action']) {
        'media' => http('GET', '/api/v1/media/'.$c['asset_id'].'/content', $c['viewer_token']),
        'like' => http('POST', '/api/v1/status/posts/'.$c['post_id'].'/likes', $c['viewer_token']),
        'unlike' => http('DELETE', '/api/v1/status/posts/'.$c['post_id'].'/likes', $c['viewer_token']),
    };
    $r['private_body_returned'] = str_contains($r['_body'], $c['private_body_marker']);
    $r['private_media_returned'] = $r['sha256'] === $c['expected_media_sha256'];
    file_put_contents($dir.'/response.LOCAL_ONLY.bin', $r['_body']);
    unset($r['_body']);
    $after = effects($c);
    $persisted = persistedAuthorization($c);
    mark('reader_completed', ['response' => $r, 'before' => $before, 'after' => $after, 'persisted_authorization' => $persisted]);
    exit(0);
} catch (Throwable $e) {
    while (DB::transactionLevel() > 0) { DB::rollBack(); }
    mark('worker_exception', ['class' => get_class($e), 'message' => $e->getMessage()]);
    fwrite(STDERR, get_class($e).': '.$e->getMessage()."\n"); exit(2);
}
