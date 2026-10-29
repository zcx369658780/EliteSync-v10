<?php
// Task-only synthetic scenario. Qualification occurs before every operation.
require __DIR__.'/../../vendor/autoload.php';
$app = require __DIR__.'/../../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$kernel->bootstrap();
App\Support\PrivateMariaDbQualification::assertApplication($app);
use Illuminate\Support\Facades\DB;
use App\Models\User;
use App\Services\LiveConsentService;

$action = $argv[1] ?? '';
if ($action === 'seed') {
    $pairs = [];
    DB::transaction(function () use (&$pairs) {
        foreach (['race', 'consent', 'connection', 'block'] as $i => $name) {
            $users = [];
            foreach ([0, 1] as $j) {
                $users[] = User::factory()->create(['phone' => '1991029'.str_pad((string) ($i * 2 + $j), 4, '0', STR_PAD_LEFT),
                    'password' => Illuminate\Support\Facades\Hash::make('TaskSynthetic123'), 'disabled' => false, 'is_synthetic' => false]);
            }
            [$a, $b] = $users;
            DB::table('friendships')->insert(['user_a' => $a->id, 'user_b' => $b->id, 'state' => 'ACTIVE', 'revision' => 1, 'created_at' => now(), 'updated_at' => now()]);
            $s = app(LiveConsentService::class);
            foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$act,$revision]) {
                $s->transition($actor->id, $peer->id, $kind, $act, $revision);
            }
            $pairs[$name] = ['sender' => $a->id, 'receiver' => $b->id, 'phoneA' => $a->phone, 'phoneB' => $b->phone];
        }
    });
    echo json_encode(['pairs' => $pairs, 'transactionLevel' => DB::transactionLevel(), 'connectionId' => DB::selectOne('SELECT CONNECTION_ID() AS id')->id], JSON_THROW_ON_ERROR);
} elseif ($action === 'counts') {
    $tables = ['users','device_sessions','personal_access_tokens','chat_messages','message_attachments','notifications','notification_devices','notification_delivery_attempts'];
    $counts = [];
    foreach ($tables as $table) $counts[$table] = DB::table($table)->count();
    echo json_encode($counts, JSON_THROW_ON_ERROR);
} elseif ($action === 'worker') {
    $file = realpath($argv[2] ?? '');
    $root = realpath(dirname(getenv('ELITESYNC_TASK_DB_QUALIFICATION')));
    if (! $file || dirname($file) !== $root) throw new RuntimeException('Task worker input outside root');
    $x = json_decode(file_get_contents($file), true, 512, JSON_THROW_ON_ERROR);
    $slot = $argv[3];
    if (! in_array($slot, ['one','two'], true)) throw new RuntimeException('Invalid slot');
    if ($slot === 'one') {
        DB::beginTransaction();
        User::whereIn('id', [$x['sender'], $x['receiver']])->orderBy('id')->lockForUpdate()->get();
    }
    $start = microtime(true);
    $proof = ['slot' => $slot, 'connectionId' => DB::selectOne('SELECT CONNECTION_ID() AS id')->id, 'start' => $start];
    file_put_contents($root.'/race-'.$slot.'-ready.json', json_encode($proof, JSON_THROW_ON_ERROR), LOCK_EX);
    while (! is_file($root.'/race-go')) {
        if (microtime(true) - $start > 20) throw new RuntimeException('Barrier timeout');
        usleep(10000);
    }
    if ($slot === 'one') usleep(700000); // Hold the real pair lock while peer enters.
    $request = Illuminate\Http\Request::create('/api/v1/messages', 'POST', [], [], [],
        ['HTTP_ACCEPT' => 'application/json', 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => 'Bearer '.$x['token']], json_encode($x['body'], JSON_THROW_ON_ERROR));
    $response = $kernel->handle($request);
    $kernel->terminate($request, $response);
    if ($slot === 'one') DB::commit();
    echo json_encode($proof + ['ended' => microtime(true), 'status' => $response->getStatusCode(), 'body' => json_decode($response->getContent(), true), 'transactionLevel' => DB::transactionLevel()], JSON_THROW_ON_ERROR);
} elseif ($action === 'notice') {
    $owner = (int) $argv[2];
    $n = app(App\Services\NotificationService::class)->createForUser($owner, 'system', 'Synthetic private title', 'Synthetic private body', ['route_name' => 'settings']);
    echo json_encode(['id' => $n->id], JSON_THROW_ON_ERROR);
} elseif ($action === 'delivery') {
    $n = App\Models\AppNotificationItem::findOrFail((int) $argv[2]);
    echo json_encode(app(App\Services\NotificationDeliveryService::class)->attempt($n, $argv[3]), JSON_THROW_ON_ERROR);
} else {
    throw new RuntimeException('Unknown scenario operation');
}
