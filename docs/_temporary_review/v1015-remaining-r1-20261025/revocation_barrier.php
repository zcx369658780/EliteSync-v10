<?php // SANITIZED_STATIC_REVIEW_COPY; not an execution entry
// raw source SHA256 d27a545013009d166597cf0f93d91066920c1a6f869c17c9b2dd6374338f9b97

// Synthetic-only local harness. Guard effective config before migrations/writes.
require '<CONTINUITY_WORKTREE>/services/backend-laravel'.'/vendor/autoload.php';
$app = require '<CONTINUITY_WORKTREE>/services/backend-laravel'.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
set_exception_handler(static function (Throwable $error): void {
    fwrite(STDERR, json_encode(['result' => 'FAIL', 'error_type' => get_class($error)], JSON_THROW_ON_ERROR).PHP_EOL);
    exit(1);
});
$db = Illuminate\Support\Facades\DB::connection();
if (! $app->environment('local') || $db->getDriverName() !== 'mysql'
    || $db->getDatabaseName() !== 'elitesync_v1015_long_dev' || $db->getConfig('host') !== '127.0.0.1'
    || (int) $db->getConfig('port') !== 43328 || $db->getConfig('unix_socket') || $db->getConfig('url')) {
    throw new RuntimeException('V1015_ISOLATION_GUARD_REJECTED');
}
$identity = $db->selectOne('SELECT DATABASE() AS db, CONNECTION_ID() AS connection_id, @@hostname AS hostname, @@tx_isolation AS isolation_level');

$callId = (int) ($argv[1] ?? 0);
if ($callId !== 1) throw new RuntimeException('EXACT_R1_SYNTHETIC_CALL1_REQUIRED');
$users = App\Models\User::orderBy('id')->get(['id','name','phone']);
if ($users->count() !== 3) throw new RuntimeException('EXACT_THREE_OWNED_FIXTURE_USERS_REQUIRED');
foreach ($users as $i => $u) {
    if ($u->id !== $i+1 || $u->name !== 'V1015 Fiction '.['A','B','C'][$i] || $u->phone !== '1990000150'.($i+1)) throw new RuntimeException('SYNTHETIC_FIXTURE_IDENTITY_REJECTED');
}
$call = App\Models\RtcSession::findOrFail($callId);
if ($call->initiator_user_id !== 2 || $call->peer_user_id !== 1 || $call->status !== 'in_call') throw new RuntimeException('OWNED_FLOWING_CALL_REQUIRED');
$cn = $db->table('product_connections')->where('user_a',1)->where('user_b',2)->orderByDesc('id')->first();
$mc = $db->table('messaging_consents')->where('connection_id',$cn->id)->where('purpose',App\Domain\MessagingConsentConversationLiveGateEvaluator::PURPOSE_LIVE_READ)->orderByDesc('generation')->first();
// Bootstrap and all fixture lookups finish before the parent starts its clock.
echo json_encode(['phase'=>'READY','callId'=>$callId],JSON_THROW_ON_ERROR).PHP_EOL;
flush();
if (trim(fgets(STDIN)) !== 'GO') throw new RuntimeException('EXACT_GO_BARRIER_REQUIRED');
$before = hrtime(true);
app(App\Services\LiveConsentService::class)->transition(2,1,'consent','revoke',(int)$mc->revision,(int)$cn->id,(int)$mc->id);
$after = hrtime(true);
if ($db->transactionLevel() !== 0) throw new RuntimeException('TRANSACTION_NOT_CLOSED');
echo json_encode(['phase'=>'COMMITTED','callId'=>$callId,'phpTransitionElapsedSeconds'=>($after-$before)/1e9,'transactionLevel'=>0,'consentStates'=>$db->table('messaging_consents')->where('connection_id',$cn->id)->pluck('state')->all()],JSON_THROW_ON_ERROR).PHP_EOL;
flush();
