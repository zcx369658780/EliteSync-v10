<?php

declare(strict_types=1);

/**
 * AUTH-15: fixed-scope schema metadata probe, never a data-row reader.
 * Run from the authorized Laravel root through PHP stdin only in a later task.
 * Defining AUTH15_METADATA_PROBE_TEST_MODE prevents bootstrap for synthetic tests.
 */

interface Auth15MetadataAdapter
{
    public function driver(): string;

    public function hasTable(string $table): bool;

    /** @return array<int, array<string, mixed>> */
    public function getColumns(string $table): array;

    /** @return array<int, array<string, mixed>> */
    public function getIndexes(string $table): array;
}

/**
 * Pure projection of fixed, caller-supplied metadata. No Laravel bootstrap here.
 * Returns only fixed JSON-compatible keys and booleans, an allowlisted driver,
 * or a safe error category. Incomplete fields/indexes never yield completeness.
 *
 * @return array<string, mixed>
 */
function auth15_project_metadata(Auth15MetadataAdapter $adapter): array
{
    try {
        $driver = $adapter->driver();
        if (! in_array($driver, ['mysql', 'pgsql', 'sqlite'], true)) {
            return ['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'];
        }

        foreach (['users', 'personal_access_tokens', 'migrations'] as $table) {
            if (! $adapter->hasTable($table)) {
                return ['ok' => false, 'error' => 'MISSING_TABLE'];
            }
        }

        $requiredColumns = [
            'users' => ['id', 'phone', 'password', 'disabled', 'role', 'account_type', 'is_synthetic'],
            'personal_access_tokens' => [
                'id', 'tokenable_type', 'tokenable_id', 'token',
                'created_at', 'last_used_at', 'expires_at',
            ],
        ];
        $columns = [];
        foreach ($requiredColumns as $table => $required) {
            $observed = auth15_column_names($adapter->getColumns($table));
            $columns[$table] = [];
            foreach ($required as $name) {
                $columns[$table][$name] = isset($observed[$name]);
            }
        }

        $unique = [
            'users_phone' => auth15_has_single_column_unique($adapter->getIndexes('users'), 'phone'),
            'personal_access_tokens_token' => auth15_has_single_column_unique(
                $adapter->getIndexes('personal_access_tokens'),
                'token',
            ),
        ];
        $allColumnsPresent = true;
        foreach ($columns as $perTable) {
            if (in_array(false, $perTable, true)) {
                $allColumnsPresent = false;
            }
        }

        return [
            'ok' => true,
            'driver' => $driver,
            'tables' => [
                'users' => true,
                'personal_access_tokens' => true,
                'migrations' => true,
            ],
            'columns' => $columns,
            'unique_indexes' => $unique,
            'schema_complete' => $allColumnsPresent && ! in_array(false, $unique, true),
        ];
    } catch (UnexpectedValueException) {
        return ['ok' => false, 'error' => 'INVALID_METADATA'];
    } catch (Throwable) {
        return ['ok' => false, 'error' => 'ADAPTER_ERROR'];
    }
}

/**
 * @param array<int, array<string, mixed>> $rows
 * @return array<string, true>
 */
function auth15_column_names(array $rows): array
{
    $names = [];
    foreach ($rows as $row) {
        if (! is_array($row) || ! isset($row['name']) || ! is_string($row['name']) || $row['name'] === '') {
            throw new UnexpectedValueException('Invalid column metadata.');
        }
        if (isset($names[$row['name']])) {
            throw new UnexpectedValueException('Duplicate column metadata.');
        }
        $names[$row['name']] = true;
    }

    return $names;
}

/** @param array<int, array<string, mixed>> $rows */
function auth15_has_single_column_unique(array $rows, string $requiredColumn): bool
{
    $found = false;
    foreach ($rows as $row) {
        if (
            ! is_array($row)
            || ! isset($row['columns'], $row['unique'])
            || ! is_array($row['columns'])
            || ! is_bool($row['unique'])
        ) {
            throw new UnexpectedValueException('Invalid index metadata.');
        }
        foreach ($row['columns'] as $column) {
            if (! is_string($column) || $column === '') {
                throw new UnexpectedValueException('Invalid index columns.');
            }
        }
        if ($row['unique'] && array_values($row['columns']) === [$requiredColumn]) {
            $found = true;
        }
    }

    return $found;
}

/** Emits only the pure projection or a safe bootstrap error. No request input. */
function auth15_run_probe(): void
{
    // Keep bootstrap notices and incidental output out of the fixed JSON result.
    @ini_set('display_errors', '0');
    @ini_set('log_errors', '0');
    $initialBufferLevel = ob_get_level();
    ob_start();
    try {
        $root = getcwd();
        if ($root === false) {
            throw new RuntimeException('No Laravel root.');
        }
        require $root.'/vendor/autoload.php';
        $app = require $root.'/bootstrap/app.php';
        $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

        $adapter = new class implements Auth15MetadataAdapter {
            public function driver(): string
            {
                return Illuminate\Support\Facades\Schema::getConnection()->getDriverName();
            }

            public function hasTable(string $table): bool
            {
                return Illuminate\Support\Facades\Schema::hasTable($table);
            }

            public function getColumns(string $table): array
            {
                return Illuminate\Support\Facades\Schema::getColumns($table);
            }

            public function getIndexes(string $table): array
            {
                return Illuminate\Support\Facades\Schema::getIndexes($table);
            }
        };
        $result = auth15_project_metadata($adapter);
    } catch (Throwable) {
        $result = ['ok' => false, 'error' => 'PROBE_ERROR'];
    } finally {
        while (ob_get_level() > $initialBufferLevel) {
            ob_end_clean();
        }
    }

    try {
        echo json_encode($result, JSON_THROW_ON_ERROR), PHP_EOL;
    } catch (Throwable) {
        echo '{"ok":false,"error":"PROBE_ERROR"}', PHP_EOL;
    }
}

if (! defined('AUTH15_METADATA_PROBE_TEST_MODE')) {
    auth15_run_probe();
}
