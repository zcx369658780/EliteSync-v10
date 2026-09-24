<?php

declare(strict_types=1);

require __DIR__.'/schema_candidate.php';

if (! extension_loaded('pdo_sqlite')) {
    fwrite(STDERR, "AUTH-21 NOT RUN: pdo_sqlite unavailable\n");
    exit(2);
}

$checks = 0;
function auth21_expect(mixed $expected, mixed $actual, string $label): void
{
    global $checks;
    $checks++;
    if ($expected !== $actual) {
        throw new RuntimeException('Fictional check failed: '.$label);
    }
}

$db = auth21_new_memory_database();
auth21_add_fictional_account($db, 'account-A');
auth21_add_fictional_account($db, 'account-B');
auth21_add_fictional_account($db, 'disabled-account', false);

auth21_expect(['status' => 'UNKNOWN'], auth21_fictional_anchor($db, 'account-A', 'device-A'), 'old account no event');
auth21_expect(['status' => 'UNKNOWN'], auth21_fictional_anchor($db, 'account-B', 'device-A'), 'second account no event');
auth21_expect('INSERTED', auth21_record_fictional_event($db, 'account-A', 'device-A', 'event-1', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'first event');
auth21_expect(1, auth21_fictional_event_count($db), 'first count');
auth21_expect('DUPLICATE', auth21_record_fictional_event($db, 'account-A', 'device-A', 'event-1', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'idempotent repeat');
auth21_expect(1, auth21_fictional_event_count($db), 'repeat count');
auth21_expect('CONFLICT', auth21_record_fictional_event($db, 'account-B', 'device-A', 'event-1', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'key cannot cross account');
auth21_expect('CONFLICT', auth21_record_fictional_event($db, 'account-A', 'device-B', 'event-1', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'key cannot cross device');
auth21_expect(['status' => 'UNKNOWN'], auth21_fictional_anchor($db, 'account-B', 'device-A'), 'no cross account anchor');
auth21_expect(['status' => 'UNKNOWN'], auth21_fictional_anchor($db, 'account-A', 'device-B'), 'no cross device anchor');

auth21_expect('INSERTED', auth21_record_fictional_event($db, 'account-A', 'device-A', 'event-2', 'INTERACTIVE_LOGIN', true, true, 2, 200), 'newer event');
$newest = ['status' => 'KNOWN', 'event_order' => 2, 't0_tick' => 200];
auth21_expect($newest, auth21_fictional_anchor($db, 'account-A', 'device-A'), 'newest anchor');
auth21_expect('CONFLICT', auth21_record_fictional_event($db, 'account-A', 'device-A', 'same-order', 'INTERACTIVE_LOGIN', true, true, 2, 210), 'sequence conflict');
auth21_expect('CONFLICT', auth21_record_fictional_event($db, 'account-A', 'device-A', 'older', 'INTERACTIVE_LOGIN', true, true, 1, 150), 'older cannot overwrite');
auth21_expect('CONFLICT', auth21_record_fictional_event($db, 'account-A', 'device-A', 'time-back', 'INTERACTIVE_LOGIN', true, true, 3, 199), 'time cannot move back');
auth21_expect($newest, auth21_fictional_anchor($db, 'account-A', 'device-A'), 'conflicts preserve anchor');

foreach ([
    ['failure', 'INTERACTIVE_LOGIN', false, true],
    ['unconfirmed', 'INTERACTIVE_LOGIN', true, false],
    ['register', 'REGISTER', true, true],
    ['refresh', 'REFRESH', true, true],
    ['rotation', 'TOKEN_ROTATION', true, true],
] as [$key, $kind, $authenticated, $confirmed]) {
    auth21_expect('REJECTED', auth21_record_fictional_event(
        $db, 'account-A', 'device-A', $key, $kind, $authenticated, $confirmed, 3, 300
    ), $key.' does not create login event');
}
auth21_expect('REJECTED', auth21_record_fictional_event($db, 'disabled-account', 'device-A', 'disabled', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'disabled account');
auth21_expect('REJECTED', auth21_record_fictional_event($db, 'unknown-account', 'device-A', 'unknown', 'INTERACTIVE_LOGIN', true, true, 1, 100), 'missing account');
auth21_expect(2, auth21_fictional_event_count($db), 'only two accepted events');
auth21_expect($newest, auth21_fictional_anchor($db, 'account-A', 'device-A'), 'rejections preserve anchor');
auth21_expect(['status' => 'UNKNOWN'], auth21_fictional_anchor($db, 'disabled-account', 'device-A'), 'disabled has no anchor');

echo 'AUTH-21 fictional SQLite checks: '.$checks.' PASS', PHP_EOL;
