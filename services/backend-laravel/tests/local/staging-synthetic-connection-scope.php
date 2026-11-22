<?php

// Run only against a newly provisioned, isolated MariaDB.
use App\Models\User;
use App\Services\Accounts\DeviceSessions;
use App\Services\ConversationCapabilityService;
use App\Services\LiveConsentService;
use App\Services\StagingSyntheticConnectionScope;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Contracts\Http\Kernel as HttpKernel;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

require __DIR__.'/../../vendor/autoload.php';
$app = require __DIR__.'/../../bootstrap/app.php';
$kernel = $app->make(Kernel::class);
$kernel->bootstrap();

function check(bool $ok, string $label): void
{
    if (! $ok) {
        throw new RuntimeException($label);
    }
    echo "PASS $label\n";
}

$scope = $app->make(StagingSyntheticConnectionScope::class);
$live = $app->make(LiveConsentService::class);
$config = DB::selectOne('SELECT DATABASE() AS db_name, @@server_id AS server_id');
check($config->db_name === 'elitesync_v2_scope_local' && (int) $config->server_id === 2621135
    && app()->environment('staging') && User::count() === 0, 'empty isolated staging database');
$marker = bin2hex(random_bytes(32));
DB::table('staging_connection_instance')->insert(['id' => 1, 'marker' => $marker]);
config(['staging_connection.marker_sha256' => hash('sha256', $marker)]);

$make = static function (int $index, array $overrides = []): int {
    return (int) User::forceCreate(array_replace([
        'name' => 'Synthetic scope '.$index,
        'email' => "scope$index@example.invalid",
        'phone' => '1990000430'.$index,
        'password' => bcrypt('local-fixture-only-2026'),
        'role' => 'user',
        'disabled' => false,
        'account_status' => 'active',
        'is_synthetic' => true,
        'account_type' => 'test',
        'synthetic_batch' => 'restricted-remote-qa',
    ], $overrides))->id;
};
[$a, $b, $c, $d, $e] = [$make(1), $make(2), $make(3), $make(4, ['role' => 'admin']), $make(5, ['synthetic_batch' => 'wrong-batch'])];
$sessions = app(DeviceSessions::class);
$aToken = $sessions->issue(User::findOrFail($a), 'Synthetic local', true)['access_token'];
$cToken = $sessions->issue(User::findOrFail($c), 'Synthetic local', true)['access_token'];
$httpStatus = static function (int $peer, ?string $token = null): int {
    app('auth')->forgetGuards();
    $headers = ['HTTP_ACCEPT' => 'application/json'];
    if ($token !== null) {
        $headers['HTTP_AUTHORIZATION'] = 'Bearer '.$token;
    }
    $request = Request::create('https://scope-stage.elitesync.invalid/api/v1/messages?peer_id='.$peer, 'GET', [], [], [], $headers);

    return app(HttpKernel::class)->handle($request)->getStatusCode();
};
$now = Carbon::now('UTC')->startOfSecond();
Carbon::setTestNow($now);
$approval = [
    'target' => 'elitesync-restricted-scope-local',
    'schema' => 'elitesync_v2_scope_local',
    'server_id' => 2621135,
    'origin' => 'https://scope-stage.elitesync.invalid',
    'batch' => 'restricted-remote-qa',
    'a' => $a, 'b' => $b,
    'ticket' => 'LOCAL-QA-01',
    'expires_at' => $now->copy()->addHour()->format('Y-m-d\TH:i:s\Z'),
];
$file = tempnam(sys_get_temp_dir(), 'scope-qa-');
if ($file === false) {
    throw new RuntimeException('Local manifest setup failed');
}
$cli = static function (string $action, array $values) use ($kernel, $file): int {
    file_put_contents($file, json_encode($values, JSON_THROW_ON_ERROR));

    return $kernel->call('qa:staging-connection-pair', ['action' => $action, 'manifest' => $file]);
};
try {
    check(! $live->availableForActor($a) && ! $live->enabledForPair($a, $b), 'no grant denies actor and pair');
    check($httpStatus($b) === 401, 'HTTP unauthenticated denied');
    config(['staging_connection.enabled' => false]);
    check($cli('grant', $approval) !== 0, 'disabled switch rejects CLI grant');
    config(['staging_connection.enabled' => true]);
    check($cli('grant', array_replace($approval, ['server_id' => 2621124])) !== 0, 'wrong manifest server rejected');
    check($cli('grant', array_replace($approval, ['b' => $d])) !== 0, 'admin rejected');
    check($cli('grant', array_replace($approval, ['b' => $e])) !== 0, 'cross-batch candidate rejected');
    check($cli('grant', array_replace($approval, ['expires_at' => $now->format('Y-m-d\TH:i:s\Z')])) !== 0, 'expired approval rejected');
    check($cli('grant', $approval) === 0 && $scope->allowsPair($a, $b) && $scope->allowsPair($b, $a), 'CLI grants only named unordered pair');
    check(! $live->enabledForPair($a, $c) && ! $live->availableForActor($c), 'unlisted test account denied');
    check($httpStatus($b, $cToken) === 404, 'HTTP unlisted actor receives no conversation');
    check(! $live->gates($a, $b)['live_send_allowed'] && ! $live->gates($a, $b)['live_read_allowed'], 'grant without Connection denied');
    check($httpStatus($b, $aToken) === 404, 'HTTP grant without Connection denied');

    // Separate local consent actors and ordinary Connection context.
    DB::table('friendships')->insert([
        'user_a' => min($a, $b), 'user_b' => max($a, $b), 'state' => 'ACTIVE',
        'revision' => 1, 'created_at' => $now, 'updated_at' => $now,
    ]);
    $live->transition($a, $b, 'connection', 'request', 0);
    $cn = $live->transition($b, $a, 'connection', 'accept', 1);
    check($cn['connection']['state'] === 'CN_ACTIVE' && ! $live->gates($a, $b)['live_send_allowed'], 'Connection without MC denied');
    check($httpStatus($b, $aToken) === 404, 'HTTP active Connection without MC denied');
    $live->transition($a, $b, 'consent', 'request', 0);
    check(! $live->gates($a, $b)['live_send_allowed'], 'pending unilateral consent denied');
    $live->transition($b, $a, 'consent', 'accept', 1);
    $gates = $live->gates($a, $b);
    check($gates['live_read_allowed'] && $gates['live_send_allowed'], 'active Connection and bilateral MC authorize HTTP policy');
    check($httpStatus($b, $aToken) === 200, 'HTTP paired granted actor receives authorized initial read');
    check(! app(ConversationCapabilityService::class)->canWebSocket($a, $b), 'candidate WSS remains disabled');
    config(['staging_connection.marker_sha256' => str_repeat('0', 64)]);
    check(! $scope->allowsPair($a, $b) && ! $live->gates($a, $b)['live_send_allowed'], 'mismatched database marker fails closed');
    config(['staging_connection.marker_sha256' => hash('sha256', $marker)]);
    Carbon::setTestNow($now->copy()->addHour());
    check(! $scope->allowsPair($a, $b) && ! $live->gates($a, $b)['live_read_allowed'], 'expired grant fails closed');
    Carbon::setTestNow($now->copy()->addMinute());
    $revocation = array_diff_key($approval, ['expires_at' => true]);
    $revocation['ticket'] = 'LOCAL-QA-02';
    check($cli('revoke', $revocation) === 0 && ! $scope->allowsPair($a, $b), 'revocation ends authority immediately');
    check($httpStatus($b, $aToken) === 404, 'HTTP revoked grant closes existing session access');
    check($cli('grant', $approval) !== 0 && DB::table('staging_connection_grants')->count() === 1, 'revoked grant cannot replay');
    check(DB::table('staging_connection_grants')->where('approval', 'LOCAL-QA-01')
        ->where('revocation', 'LOCAL-QA-02')->whereNotNull('revoked_at')->exists(), 'grant and revocation audit retained');
} finally {
    Carbon::setTestNow();
    unlink($file);
}
