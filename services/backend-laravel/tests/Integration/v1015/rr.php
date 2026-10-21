<?php
require __DIR__.'/runtime.php'; // verifies effective DB/environment before any write
$mode = $argv[1] ?? '';
if ($mode === 'probe') {
    $rows = $db->select("SELECT r.trx_mysql_thread_id AS reader_id,b.trx_mysql_thread_id AS writer_id,l.lock_table,l.lock_index,l.lock_type FROM information_schema.INNODB_LOCK_WAITS w JOIN information_schema.INNODB_TRX r ON r.trx_id=w.requesting_trx_id JOIN information_schema.INNODB_TRX b ON b.trx_id=w.blocking_trx_id JOIN information_schema.INNODB_LOCKS l ON l.lock_id=w.requested_lock_id");
    echo json_encode(['waits' => $rows], JSON_THROW_ON_ERROR).PHP_EOL;
    exit(0);
}
$input = json_decode(trim(fgets(STDIN)), true, 512, JSON_THROW_ON_ERROR);
if ($mode === 'writer') {
    $db->beginTransaction();
    App\Models\User::whereIn('id', [1,2])->orderBy('id')->lockForUpdate()->get();
    echo json_encode(['writer_locked' => $identity->connection_id, 'time' => microtime(true)], JSON_THROW_ON_ERROR).PHP_EOL;
    fflush(STDOUT);
    if (trim(fgets(STDIN)) !== 'COMMIT_REVOKE') throw new RuntimeException('EXACT_COMMIT_SIGNAL_REQUIRED');
    app(App\Services\Accounts\DeviceSessions::class)->revoke(App\Models\User::findOrFail(1), $input['session_id']);
    $db->commit();
    echo json_encode(['writer_commit' => $identity->connection_id, 'time' => microtime(true)], JSON_THROW_ON_ERROR).PHP_EOL;
} elseif ($mode === 'reader') {
    echo json_encode(['reader_started' => $identity->connection_id, 'time' => microtime(true)], JSON_THROW_ON_ERROR).PHP_EOL;
    fflush(STDOUT);
    $request = Illuminate\Http\Request::create('/api/v1/conversations', 'GET', [], [], [], ['HTTP_ACCEPT' => 'application/json', 'HTTP_AUTHORIZATION' => 'Bearer '.$input['token']]);
    $kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
    $reply = $kernel->handle($request);
    echo json_encode(['reader_finished' => $identity->connection_id, 'status' => $reply->getStatusCode(), 'time' => microtime(true),
        'body_sha256' => hash('sha256', $reply->getContent()), 'private_body_absent' => !str_contains($reply->getContent(), 'V1015 synthetic reliable text')], JSON_THROW_ON_ERROR).PHP_EOL;
    $kernel->terminate($request, $reply);
    exit($reply->getStatusCode() === 401 ? 0 : 1);
}
