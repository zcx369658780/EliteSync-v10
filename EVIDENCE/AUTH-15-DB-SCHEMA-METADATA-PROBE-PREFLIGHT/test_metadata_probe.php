<?php

declare(strict_types=1);

define('AUTH15_METADATA_PROBE_TEST_MODE', true);
require __DIR__.'/metadata_probe.php';

final class Auth15FakeMetadataAdapter implements Auth15MetadataAdapter
{
    /** @var array<string, bool> */
    public array $tables = [
        'users' => true,
        'personal_access_tokens' => true,
        'migrations' => true,
    ];

    /** @var array<string, array<int, array<string, mixed>>> */
    public array $columns = [
        'users' => [],
        'personal_access_tokens' => [],
    ];

    /** @var array<string, array<int, array<string, mixed>>> */
    public array $indexes = [
        'users' => [],
        'personal_access_tokens' => [],
    ];

    public bool $throwOnColumns = false;

    public function __construct(public string $driverName = 'mysql')
    {
        foreach (['id', 'phone', 'password', 'disabled', 'role', 'account_type', 'is_synthetic'] as $name) {
            $this->columns['users'][] = ['name' => $name, 'unused_secret' => 'fictional-extra'];
        }
        foreach (['id', 'tokenable_type', 'tokenable_id', 'token', 'created_at', 'last_used_at', 'expires_at'] as $name) {
            $this->columns['personal_access_tokens'][] = ['name' => $name];
        }
        $this->columns['users'][] = ['name' => 'fictional_private_column', 'value' => 'fictional-secret'];
        $this->indexes['users'][] = ['columns' => ['phone'], 'unique' => true, 'name' => 'fictional_index_name'];
        $this->indexes['personal_access_tokens'][] = ['columns' => ['token'], 'unique' => true];
    }

    public function driver(): string
    {
        return $this->driverName;
    }

    public function hasTable(string $table): bool
    {
        return $this->tables[$table];
    }

    public function getColumns(string $table): array
    {
        if ($this->throwOnColumns) {
            throw new RuntimeException('Fictional private exception detail');
        }

        return $this->columns[$table];
    }

    public function getIndexes(string $table): array
    {
        return $this->indexes[$table];
    }
}

$checks = 0;
function auth15_assert_same(mixed $expected, mixed $actual, string $label): void
{
    global $checks;
    $checks++;
    if ($expected !== $actual) {
        throw new RuntimeException('Synthetic check failed: '.$label);
    }
}

$full = auth15_project_metadata(new Auth15FakeMetadataAdapter());
auth15_assert_same(true, $full['ok'], 'full observation');
auth15_assert_same('mysql', $full['driver'], 'allowlisted driver');
auth15_assert_same(true, $full['schema_complete'], 'complete shape');
auth15_assert_same(true, $full['unique_indexes']['users_phone'], 'single-column phone unique');
auth15_assert_same(true, $full['unique_indexes']['personal_access_tokens_token'], 'single-column token unique');
auth15_assert_same(7, count($full['columns']['users']), 'fixed users keys');
auth15_assert_same(7, count($full['columns']['personal_access_tokens']), 'fixed token keys');
auth15_assert_same(false, str_contains(json_encode($full), 'fictional-secret'), 'no extra metadata value');
auth15_assert_same(false, str_contains(json_encode($full), 'fictional_private_column'), 'no extra column name');
auth15_assert_same(false, str_contains(json_encode($full), 'fictional_index_name'), 'no extra index name');

$missingTable = new Auth15FakeMetadataAdapter();
$missingTable->tables['migrations'] = false;
auth15_assert_same(['ok' => false, 'error' => 'MISSING_TABLE'], auth15_project_metadata($missingTable), 'missing table');

$missingColumn = new Auth15FakeMetadataAdapter();
$missingColumn->columns['users'] = array_values(array_filter(
    $missingColumn->columns['users'],
    static fn (array $row): bool => $row['name'] !== 'id',
));
$missingResult = auth15_project_metadata($missingColumn);
auth15_assert_same(false, $missingResult['columns']['users']['id'], 'missing users id');
auth15_assert_same(true, $missingResult['columns']['personal_access_tokens']['id'], 'token id still present');
auth15_assert_same(false, $missingResult['schema_complete'], 'missing column fails closed');

$missingIndex = new Auth15FakeMetadataAdapter();
$missingIndex->indexes['users'] = [['columns' => ['phone', 'id'], 'unique' => true]];
$indexResult = auth15_project_metadata($missingIndex);
auth15_assert_same(false, $indexResult['unique_indexes']['users_phone'], 'composite is not phone unique');
auth15_assert_same(false, $indexResult['schema_complete'], 'missing single-column unique fails closed');

$unknownDriver = new Auth15FakeMetadataAdapter('fictional-driver');
auth15_assert_same(['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'], auth15_project_metadata($unknownDriver), 'unknown driver');

$throws = new Auth15FakeMetadataAdapter();
$throws->throwOnColumns = true;
auth15_assert_same(['ok' => false, 'error' => 'ADAPTER_ERROR'], auth15_project_metadata($throws), 'adapter exception hidden');

$invalid = new Auth15FakeMetadataAdapter();
$invalid->indexes['users'] = [['columns' => 'phone', 'unique' => true]];
auth15_assert_same(['ok' => false, 'error' => 'INVALID_METADATA'], auth15_project_metadata($invalid), 'malformed metadata');

echo 'AUTH-15 synthetic adapter checks: '.$checks.' PASS', PHP_EOL;
