<?php

declare(strict_types=1);

define('AUTH66_TEST_MODE', true);
require __DIR__.'/probe.php';

final class Auth66Fake implements Auth66Adapter
{
    /** @var array<string, array<string, mixed>> */
    public array $rows = [
        'identity' => ['version_text' => '5.5.5-10.11.14-MariaDB', 'database_name' => 'fictional_db', 'server_name' => 'fictional_host'],
        'engines' => ['relation_total' => '3', 'base_total' => '2', 'view_total' => '1', 'innodb_count' => '2', 'other_count' => '0', 'null_count' => '0'],
    ];
    public ?string $throwAt = null;
    /** @var list<string> */
    public array $calls = [];

    public function __construct(public string $driverName = 'mysql') {}

    public function driver(): string
    {
        return $this->driverName;
    }

    public function row(string $category): array
    {
        $this->calls[] = $category;
        if ($this->throwAt === $category) {
            throw new RuntimeException('fictional secret, connection and SQL');
        }
        return $this->rows[$category];
    }
}

$checks = 0;
function auth66_assert(mixed $expected, mixed $actual, string $label): void
{
    global $checks;
    $checks++;
    if ($expected !== $actual) {
        throw new RuntimeException('Synthetic check failed: '.$label);
    }
}

function auth66_bad(Auth66Fake $fake, string $error, string $label): void
{
    auth66_assert(['ok' => false, 'error' => $error], auth66_project($fake), $label);
}

$all = new Auth66Fake();
$result = auth66_project($all);
auth66_assert(true, $result['ok'], 'all InnoDB valid');
auth66_assert('MariaDB', $result['family'], 'family');
auth66_assert('10.11.14', $result['version'], 'version');
auth66_assert(2, $result['counts']['base_tables'], 'base total');
auth66_assert(2, $result['counts']['innodb'], 'InnoDB');
auth66_assert(1, $result['counts']['views'], 'view separated');
auth66_assert('UNKNOWN', $result['scope_completeness'], 'scope unknown');
auth66_assert('UNKNOWN', $result['backup_consistency'], 'consistency unknown');
auth66_assert(hash('sha256', "fictional_host\0fictional_db"), $result['target_fingerprint_sha256'], 'AUTH-20 fingerprint');
auth66_assert(array_keys(AUTH66_SQL), $all->calls, 'two fixed queries');
$json = json_encode($result, JSON_THROW_ON_ERROR);
auth66_assert(false, str_contains($json, 'fictional_db'), 'database hidden');
auth66_assert(false, str_contains($json, 'fictional_host'), 'host hidden');

$mixed = new Auth66Fake();
$mixed->rows['engines']['innodb_count'] = '1';
$mixed->rows['engines']['other_count'] = '1';
auth66_assert(1, auth66_project($mixed)['counts']['non_innodb'], 'mixed engines');
$null = new Auth66Fake();
$null->rows['engines']['innodb_count'] = '1';
$null->rows['engines']['null_count'] = '1';
auth66_assert(1, auth66_project($null)['counts']['engine_null'], 'null engine');
$empty = new Auth66Fake();
foreach ($empty->rows['engines'] as $key => $_value) {
    $empty->rows['engines'][$key] = '0';
}
auth66_assert(0, auth66_project($empty)['counts']['base_tables'], 'empty database');

$mismatch = new Auth66Fake();
$mismatch->rows['engines']['base_total'] = '3';
auth66_bad($mismatch, 'INVALID_METADATA', 'engine parts mismatch');
$unknownType = new Auth66Fake();
$unknownType->rows['engines']['relation_total'] = '4';
auth66_bad($unknownType, 'INVALID_METADATA', 'relation parts mismatch');
$missing = new Auth66Fake();
unset($missing->rows['engines']['null_count']);
auth66_bad($missing, 'INVALID_METADATA', 'missing key');
$extra = new Auth66Fake();
$extra->rows['engines']['secret'] = 'fictional secret';
auth66_bad($extra, 'INVALID_METADATA', 'extra key');
$extraIdentity = new Auth66Fake();
$extraIdentity->rows['identity']['secret'] = 'fictional secret';
auth66_bad($extraIdentity, 'INVALID_METADATA', 'extra identity key');

foreach (['-1', '999999999999999999999999', '1.5', null, true] as $badCount) {
    $bad = new Auth66Fake();
    $bad->rows['engines']['innodb_count'] = $badCount;
    auth66_bad($bad, 'INVALID_METADATA', 'bad count');
}
$limit = new Auth66Fake();
$limit->rows['engines']['relation_total'] = (string) (AUTH66_COUNT_LIMIT + 1);
auth66_bad($limit, 'COUNT_LIMIT_EXCEEDED', 'count cap');
$atLimit = new Auth66Fake();
$atLimit->rows['engines'] = ['relation_total' => '10000', 'base_total' => '10000', 'view_total' => '0', 'innodb_count' => '10000', 'other_count' => '0', 'null_count' => '0'];
auth66_assert(true, auth66_project($atLimit)['ok'], 'cap inclusive');

$badDriver = new Auth66Fake('pgsql');
auth66_bad($badDriver, 'UNSUPPORTED_DRIVER', 'driver rejected');
auth66_assert([], $badDriver->calls, 'driver rejected before queries');
$badVersion = new Auth66Fake();
$badVersion->rows['identity']['version_text'] = 'unknown';
auth66_bad($badVersion, 'INVALID_METADATA', 'version rejected');
$badFamily = new Auth66Fake();
$badFamily->rows['identity']['version_text'] = '10.11.14-MariaDBgarbled';
auth66_bad($badFamily, 'INVALID_METADATA', 'family rejected');
$badHost = new Auth66Fake();
$badHost->rows['identity']['server_name'] = "bad\nname";
auth66_bad($badHost, 'INVALID_METADATA', 'identity rejected');
$throw = new Auth66Fake();
$throw->throwAt = 'engines';
auth66_bad($throw, 'QUERY_OR_ADAPTER_ERROR', 'exception redacted');
auth66_assert(false, str_contains(json_encode(auth66_project($throw)), 'fictional secret'), 'exception detail hidden');

echo 'AUTH-66 synthetic checks: '.$checks.' PASS', PHP_EOL;
