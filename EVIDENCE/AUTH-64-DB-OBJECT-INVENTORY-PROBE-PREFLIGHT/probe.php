<?php

declare(strict_types=1);

/** AUTH-64: fixed, read-only metadata projection. Live execution needs a new task. */
interface Auth64Adapter
{
    public function driver(): string;

    /** @return array<string, mixed> */
    public function row(string $category): array;
}

/** Eight fixed SELECTs, each returning at most one aggregate row. */
const AUTH64_SQL = [
    'identity' => 'SELECT VERSION() AS version_text, DATABASE() AS database_name, @@hostname AS server_name',
    'relations' => 'SELECT COUNT(*) AS total_count, COALESCE(SUM(table_type = \'BASE TABLE\'), 0) AS base_count, COALESCE(SUM(table_type = \'VIEW\'), 0) AS view_count FROM information_schema.tables WHERE table_schema = DATABASE()',
    'columns' => 'SELECT COUNT(*) AS object_count FROM information_schema.columns WHERE table_schema = DATABASE()',
    'indexes' => 'SELECT COUNT(DISTINCT table_name, index_name) AS object_count FROM information_schema.statistics WHERE table_schema = DATABASE()',
    'constraints' => 'SELECT COUNT(*) AS total_count, COALESCE(SUM(constraint_type = \'PRIMARY KEY\'), 0) AS primary_count, COALESCE(SUM(constraint_type = \'UNIQUE\'), 0) AS unique_count, COALESCE(SUM(constraint_type = \'FOREIGN KEY\'), 0) AS foreign_count, COALESCE(SUM(constraint_type = \'CHECK\'), 0) AS check_count FROM information_schema.table_constraints WHERE table_schema = DATABASE()',
    'triggers' => 'SELECT COUNT(*) AS object_count FROM information_schema.triggers WHERE trigger_schema = DATABASE()',
    'routines' => 'SELECT COUNT(*) AS object_count FROM information_schema.routines WHERE routine_schema = DATABASE()',
    'events' => 'SELECT COUNT(*) AS object_count FROM information_schema.events WHERE event_schema = DATABASE()',
];

const AUTH64_OBJECT_LIMIT = 10000;

/** @return array<string, mixed> */
function auth64_project(Auth64Adapter $adapter): array
{
    try {
        if ($adapter->driver() !== 'mysql') {
            return ['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'];
        }

        $identity = auth64_exact_row($adapter->row('identity'), ['version_text', 'database_name', 'server_name']);
        $version = auth64_version($identity['version_text']);
        $database = auth64_identifier($identity['database_name']);
        $server = auth64_identifier($identity['server_name']);

        $relations = auth64_exact_row($adapter->row('relations'), ['total_count', 'base_count', 'view_count']);
        $relationTotal = auth64_count($relations['total_count']);
        $tables = auth64_count($relations['base_count']);
        $views = auth64_count($relations['view_count']);
        if ($tables + $views !== $relationTotal) {
            throw new UnexpectedValueException('Unknown or inconsistent relation type.');
        }

        $columns = auth64_single_count($adapter->row('columns'));
        $indexes = auth64_single_count($adapter->row('indexes'));
        $constraints = auth64_exact_row($adapter->row('constraints'), [
            'total_count', 'primary_count', 'unique_count', 'foreign_count', 'check_count',
        ]);
        $constraintTotal = auth64_count($constraints['total_count']);
        $primary = auth64_count($constraints['primary_count']);
        $unique = auth64_count($constraints['unique_count']);
        $foreign = auth64_count($constraints['foreign_count']);
        $checks = auth64_count($constraints['check_count']);
        if ($primary + $unique + $foreign + $checks !== $constraintTotal) {
            throw new UnexpectedValueException('Unknown or inconsistent constraint type.');
        }

        $triggers = auth64_single_count($adapter->row('triggers'));
        $routines = auth64_single_count($adapter->row('routines'));
        $events = auth64_single_count($adapter->row('events'));
        if ($relationTotal === 0 && ($columns !== 0 || $indexes !== 0 || $constraintTotal !== 0 || $triggers !== 0)) {
            throw new UnexpectedValueException('Inconsistent empty schema.');
        }

        return [
            'ok' => true,
            'probe_version' => 'AUTH64-1',
            'family' => $version['family'],
            'version' => $version['version'],
            'target_fingerprint_sha256' => hash('sha256', $server."\0".$database),
            'counts' => [
                'base_tables' => $tables,
                'views' => $views,
                'columns' => $columns,
                'indexes' => $indexes,
                'primary_constraints' => $primary,
                'unique_constraints' => $unique,
                'foreign_constraints' => $foreign,
                'check_constraints' => $checks,
                'triggers' => $triggers,
                'routines' => $routines,
                'events' => $events,
            ],
            'completeness' => 'UNKNOWN',
            'completeness_reason' => 'PRIVILEGE_VISIBILITY_UNVERIFIED',
        ];
    } catch (Auth64LimitException) {
        return ['ok' => false, 'error' => 'OBJECT_LIMIT_EXCEEDED'];
    } catch (UnexpectedValueException) {
        return ['ok' => false, 'error' => 'INVALID_METADATA'];
    } catch (Throwable) {
        return ['ok' => false, 'error' => 'QUERY_OR_ADAPTER_ERROR'];
    }
}

final class Auth64LimitException extends RuntimeException {}

/** @param array<string, mixed> $row @param list<string> $expected @return array<string, mixed> */
function auth64_exact_row(array $row, array $expected): array
{
    $keys = array_keys($row);
    sort($keys);
    sort($expected);
    if ($keys !== $expected) {
        throw new UnexpectedValueException('Invalid row shape.');
    }
    return $row;
}

/** @param array<string, mixed> $row */
function auth64_single_count(array $row): int
{
    return auth64_count(auth64_exact_row($row, ['object_count'])['object_count']);
}

function auth64_count(mixed $value): int
{
    if (is_int($value) && $value >= 0) {
        $count = $value;
    } elseif (is_string($value) && preg_match('/\A(?:0|[1-9][0-9]*)\z/D', $value)) {
        $parsed = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 0]]);
        if ($parsed === false) {
            throw new UnexpectedValueException('Integer overflow.');
        }
        $count = $parsed;
    } else {
        throw new UnexpectedValueException('Invalid count.');
    }
    if ($count > AUTH64_OBJECT_LIMIT) {
        throw new Auth64LimitException('Object limit.');
    }
    return $count;
}

/** @return array{family: string, version: string} */
function auth64_version(mixed $value): array
{
    if (! is_string($value) || $value === '' || strlen($value) > 128
        || ! preg_match('/\A[0-9A-Za-z.+_-]+\z/D', $value)) {
        throw new UnexpectedValueException('Invalid version.');
    }
    if (preg_match('/\A(?:5\.5\.5-)?([0-9]+\.[0-9]+\.[0-9]+)-MariaDB(?:[-+][0-9A-Za-z.+_-]+)?\z/D', $value, $matches)) {
        return ['family' => 'MariaDB', 'version' => $matches[1]];
    }
    if (str_contains(strtolower($value), 'mariadb')) {
        throw new UnexpectedValueException('Unknown MariaDB version.');
    }
    if (preg_match('/\A([0-9]+\.[0-9]+\.[0-9]+)(?:[-+][0-9A-Za-z.+_-]+)?\z/D', $value, $matches)) {
        return ['family' => 'MySQL', 'version' => $matches[1]];
    }
    throw new UnexpectedValueException('Unknown server family.');
}

function auth64_identifier(mixed $value): string
{
    if (! is_string($value) || $value === '' || strlen($value) > 255
        || preg_match('/[\x00-\x1F\x7F]/', $value)) {
        throw new UnexpectedValueException('Invalid identifier.');
    }
    return $value;
}

function auth64_run(): void
{
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

        $adapter = new class implements Auth64Adapter {
            public function driver(): string
            {
                return Illuminate\Support\Facades\DB::connection()->getDriverName();
            }

            public function row(string $category): array
            {
                if (! array_key_exists($category, AUTH64_SQL)) {
                    throw new UnexpectedValueException('Unknown query.');
                }
                // Keep the current configured connection and its write PDO; SQL remains SELECT-only.
                $row = Illuminate\Support\Facades\DB::connection()->selectOne(AUTH64_SQL[$category], [], false);
                if (! is_object($row)) {
                    throw new UnexpectedValueException('Missing aggregate row.');
                }
                return get_object_vars($row);
            }
        };
        $result = auth64_project($adapter);
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

if (! defined('AUTH64_TEST_MODE')) {
    auth64_run();
}
