<?php

declare(strict_types=1);

define('AUTH64_TEST_MODE', true);
require __DIR__.'/probe.php';

final class Auth64Fake implements Auth64Adapter
{
    /** @var array<string, array<string, mixed>> */
    public array $rows = [
        'identity' => ['version_text' => '5.5.5-10.11.14-MariaDB', 'database_name' => 'fictional_db', 'server_name' => 'fictional_host'],
        'relations' => ['total_count' => '3', 'base_count' => '2', 'view_count' => '1'],
        'columns' => ['object_count' => '8'],
        'indexes' => ['object_count' => '3'],
        'constraints' => ['total_count' => '4', 'primary_count' => '1', 'unique_count' => '1', 'foreign_count' => '1', 'check_count' => '1'],
        'triggers' => ['object_count' => '1'],
        'routines' => ['object_count' => '2'],
        'events' => ['object_count' => '1'],
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
function auth64_assert(mixed $expected, mixed $actual, string $label): void
{
    global $checks;
    $checks++;
    if ($expected !== $actual) {
        throw new RuntimeException('Synthetic check failed: '.$label);
    }
}

function auth64_bad(Auth64Fake $fake, string $error, string $label): void
{
    auth64_assert(['ok' => false, 'error' => $error], auth64_project($fake), $label);
}

$fake = new Auth64Fake();
$result = auth64_project($fake);
auth64_assert(true, $result['ok'], 'valid projection');
auth64_assert('MariaDB', $result['family'], 'family');
auth64_assert('10.11.14', $result['version'], 'normalized version');
auth64_assert(2, $result['counts']['base_tables'], 'base tables distinct from views');
auth64_assert(1, $result['counts']['views'], 'views distinct from tables');
auth64_assert(1, $result['counts']['check_constraints'], 'check constraints counted');
auth64_assert('UNKNOWN', $result['completeness'], 'visibility incomplete');
auth64_assert('PRIVILEGE_VISIBILITY_UNVERIFIED', $result['completeness_reason'], 'visibility reason');
auth64_assert(hash('sha256', "fictional_host\0fictional_db"), $result['target_fingerprint_sha256'], 'AUTH-20 fingerprint algorithm');
auth64_assert($result, auth64_project(new Auth64Fake()), 'stable projection');
auth64_assert(array_keys(AUTH64_SQL), $fake->calls, 'exactly eight fixed queries');
$json = json_encode($result, JSON_THROW_ON_ERROR);
auth64_assert(false, str_contains($json, 'fictional_db'), 'database name hidden');
auth64_assert(false, str_contains($json, 'fictional_host'), 'server name hidden');
auth64_assert(false, str_contains($json, 'fictional secret'), 'exception hidden');

$empty = new Auth64Fake();
foreach (['relations', 'columns', 'indexes', 'constraints', 'triggers', 'routines', 'events'] as $category) {
    foreach ($empty->rows[$category] as $key => $_value) {
        $empty->rows[$category][$key] = '0';
    }
}
auth64_assert(true, auth64_project($empty)['ok'], 'empty database');
auth64_assert(0, auth64_project($empty)['counts']['base_tables'], 'empty table count');

$badDriver = new Auth64Fake('pgsql');
auth64_bad($badDriver, 'UNSUPPORTED_DRIVER', 'driver rejected');
auth64_assert([], $badDriver->calls, 'driver rejected before query');

$cases = [
    ['relations', 'base_count', '-1'],
    ['columns', 'object_count', '1.5'],
    ['indexes', 'object_count', '9999999999999999999999999'],
    ['triggers', 'object_count', null],
    ['identity', 'version_text', 'unknown'],
    ['identity', 'database_name', ''],
    ['identity', 'server_name', "bad\nname"],
];
foreach ($cases as [$category, $key, $value]) {
    $bad = new Auth64Fake();
    $bad->rows[$category][$key] = $value;
    auth64_bad($bad, 'INVALID_METADATA', 'malformed '.$category.'.'.$key);
}

$limit = new Auth64Fake();
$limit->rows['columns']['object_count'] = (string) (AUTH64_OBJECT_LIMIT + 1);
auth64_bad($limit, 'OBJECT_LIMIT_EXCEEDED', 'object cap');
$exactLimit = new Auth64Fake();
$exactLimit->rows['columns']['object_count'] = (string) AUTH64_OBJECT_LIMIT;
auth64_assert(true, auth64_project($exactLimit)['ok'], 'cap inclusive');

$missing = new Auth64Fake();
unset($missing->rows['constraints']['foreign_count']);
auth64_bad($missing, 'INVALID_METADATA', 'missing field');
$extra = new Auth64Fake();
$extra->rows['events']['secret'] = 'fictional secret';
auth64_bad($extra, 'INVALID_METADATA', 'extra field');
$extraIdentity = new Auth64Fake();
$extraIdentity->rows['identity']['secret'] = 'fictional secret';
auth64_bad($extraIdentity, 'INVALID_METADATA', 'extra identity field');

$unknownType = new Auth64Fake();
$unknownType->rows['relations']['total_count'] = '4';
auth64_bad($unknownType, 'INVALID_METADATA', 'unknown relation type');
$unknownConstraint = new Auth64Fake();
$unknownConstraint->rows['constraints']['total_count'] = '5';
auth64_bad($unknownConstraint, 'INVALID_METADATA', 'unknown constraint type');
$inconsistentEmpty = new Auth64Fake();
$inconsistentEmpty->rows['relations'] = ['total_count' => '0', 'base_count' => '0', 'view_count' => '0'];
auth64_bad($inconsistentEmpty, 'INVALID_METADATA', 'inconsistent empty database');

$permission = new Auth64Fake();
$permission->throwAt = 'triggers';
auth64_bad($permission, 'QUERY_OR_ADAPTER_ERROR', 'query or permission failure hidden');
auth64_assert(false, str_contains(json_encode(auth64_project($permission)), 'fictional secret'), 'error detail hidden');

echo 'AUTH-64 synthetic checks: '.$checks.' PASS', PHP_EOL;
