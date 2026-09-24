<?php

declare(strict_types=1);

define('AUTH19_TARGET_PROBE_TEST_MODE', true);
require __DIR__.'/target_probe.php';

final class Auth19FakeAdapter implements Auth19TargetAdapter
{
    /** @var array<string, mixed> */
    public array $row = [
        'version_text' => '8.0.36-log',
        'database_name' => 'fictional_db',
        'server_name' => 'fictional_host',
        'table_count' => '12',
        'estimated_bytes' => '4096',
    ];

    public bool $throw = false;

    public function __construct(public string $driverName = 'mysql') {}

    public function driver(): string
    {
        return $this->driverName;
    }

    public function metadata(): array
    {
        if ($this->throw) {
            throw new RuntimeException('fictional private exception detail');
        }

        return $this->row;
    }
}

$checks = 0;
function auth19_assert_same(mixed $expected, mixed $actual, string $label): void
{
    global $checks;
    $checks++;
    if ($expected !== $actual) {
        throw new RuntimeException('Synthetic check failed: '.$label);
    }
}

$mysql = auth19_project_target(new Auth19FakeAdapter());
auth19_assert_same(true, $mysql['ok'], 'mysql result');
auth19_assert_same('mysql', $mysql['driver'], 'driver');
auth19_assert_same('MySQL', $mysql['family'], 'mysql family');
auth19_assert_same('8.0.36', $mysql['version'], 'mysql version');
auth19_assert_same(12, $mysql['table_count'], 'table count');
auth19_assert_same(4096, $mysql['estimated_bytes'], 'estimated bytes');
auth19_assert_same(hash('sha256', "fictional_host\0fictional_db"), $mysql['target_fingerprint_sha256'], 'fingerprint');
auth19_assert_same($mysql['target_fingerprint_sha256'], auth19_project_target(new Auth19FakeAdapter())['target_fingerprint_sha256'], 'stable fingerprint');
auth19_assert_same(false, str_contains(json_encode($mysql), 'fictional_db'), 'no database name');
auth19_assert_same(false, str_contains(json_encode($mysql), 'fictional_host'), 'no server name');

$maria = new Auth19FakeAdapter();
$maria->row['version_text'] = '5.5.5-10.11.14-MariaDB-0+deb12u2';
$mariaResult = auth19_project_target($maria);
auth19_assert_same('MariaDB', $mariaResult['family'], 'mariadb family');
auth19_assert_same('10.11.14', $mariaResult['version'], 'mariadb normalized version');

$zero = new Auth19FakeAdapter();
$zero->row['table_count'] = 0;
$zero->row['estimated_bytes'] = 0;
auth19_assert_same(true, auth19_project_target($zero)['ok'], 'zero aggregates');

$badDriver = new Auth19FakeAdapter('pgsql');
auth19_assert_same(['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'], auth19_project_target($badDriver), 'driver reject');

foreach ([
    ['version_text', 'unknown'],
    ['database_name', ''],
    ['server_name', "bad\nname"],
    ['table_count', -1],
    ['estimated_bytes', '1.5'],
    ['estimated_bytes', '999999999999999999999999999'],
] as [$key, $value]) {
    $bad = new Auth19FakeAdapter();
    $bad->row[$key] = $value;
    auth19_assert_same(['ok' => false, 'error' => 'INVALID_METADATA'], auth19_project_target($bad), 'malformed '.$key);
}

$extra = new Auth19FakeAdapter();
$extra->row['fictional_secret'] = 'do-not-leak';
auth19_assert_same(['ok' => false, 'error' => 'INVALID_METADATA'], auth19_project_target($extra), 'extra metadata reject');
$throwing = new Auth19FakeAdapter();
$throwing->throw = true;
auth19_assert_same(['ok' => false, 'error' => 'ADAPTER_ERROR'], auth19_project_target($throwing), 'exception hidden');

echo 'AUTH-19 synthetic adapter checks: '.$checks.' PASS', PHP_EOL;
