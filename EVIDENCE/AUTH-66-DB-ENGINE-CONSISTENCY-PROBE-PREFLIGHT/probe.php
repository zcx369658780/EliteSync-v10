<?php

declare(strict_types=1);

/** AUTH-66: fixed metadata projection. Live execution requires a separate task. */
interface Auth66Adapter
{
    public function driver(): string;

    /** @return array<string, mixed> */
    public function row(string $category): array;
}

/** Two fixed SELECTs, each returning exactly one aggregate row. */
const AUTH66_SQL = [
    'identity' => 'SELECT VERSION() AS version_text, DATABASE() AS database_name, @@hostname AS server_name',
    'engines' => "SELECT COUNT(*) AS relation_total, COALESCE(SUM(table_type = 'BASE TABLE'), 0) AS base_total, COALESCE(SUM(table_type = 'VIEW'), 0) AS view_total, COALESCE(SUM(table_type = 'BASE TABLE' AND UPPER(engine) = 'INNODB'), 0) AS innodb_count, COALESCE(SUM(table_type = 'BASE TABLE' AND engine IS NOT NULL AND UPPER(engine) <> 'INNODB'), 0) AS other_count, COALESCE(SUM(table_type = 'BASE TABLE' AND engine IS NULL), 0) AS null_count FROM information_schema.tables WHERE table_schema = DATABASE()",
];

const AUTH66_COUNT_LIMIT = 10000;

/** @return array<string, mixed> */
function auth66_project(Auth66Adapter $adapter): array
{
    try {
        if ($adapter->driver() !== 'mysql') {
            return ['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'];
        }

        $identity = auth66_exact_row($adapter->row('identity'), ['version_text', 'database_name', 'server_name']);
        $version = auth66_version($identity['version_text']);
        $database = auth66_identifier($identity['database_name']);
        $server = auth66_identifier($identity['server_name']);

        $row = auth66_exact_row($adapter->row('engines'), [
            'relation_total', 'base_total', 'view_total', 'innodb_count', 'other_count', 'null_count',
        ]);
        $relations = auth66_count($row['relation_total']);
        $base = auth66_count($row['base_total']);
        $views = auth66_count($row['view_total']);
        $innodb = auth66_count($row['innodb_count']);
        $other = auth66_count($row['other_count']);
        $null = auth66_count($row['null_count']);
        if ($base + $views !== $relations || $innodb + $other + $null !== $base) {
            throw new UnexpectedValueException('Inconsistent metadata.');
        }

        return [
            'ok' => true,
            'probe_version' => 'AUTH66-1',
            'family' => $version['family'],
            'version' => $version['version'],
            'target_fingerprint_sha256' => hash('sha256', $server."\0".$database),
            'counts' => [
                'base_tables' => $base,
                'innodb' => $innodb,
                'non_innodb' => $other,
                'engine_null' => $null,
                'views' => $views,
            ],
            'scope_completeness' => 'UNKNOWN',
            'backup_consistency' => 'UNKNOWN',
        ];
    } catch (Auth66LimitException) {
        return ['ok' => false, 'error' => 'COUNT_LIMIT_EXCEEDED'];
    } catch (UnexpectedValueException) {
        return ['ok' => false, 'error' => 'INVALID_METADATA'];
    } catch (Throwable) {
        return ['ok' => false, 'error' => 'QUERY_OR_ADAPTER_ERROR'];
    }
}

final class Auth66LimitException extends RuntimeException {}

/** @param array<string, mixed> $row @param list<string> $expected @return array<string, mixed> */
function auth66_exact_row(array $row, array $expected): array
{
    $keys = array_keys($row);
    sort($keys);
    sort($expected);
    if ($keys !== $expected) {
        throw new UnexpectedValueException('Invalid row shape.');
    }
    return $row;
}

function auth66_count(mixed $value): int
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
    if ($count > AUTH66_COUNT_LIMIT) {
        throw new Auth66LimitException('Count limit.');
    }
    return $count;
}

/** @return array{family: string, version: string} */
function auth66_version(mixed $value): array
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

function auth66_identifier(mixed $value): string
{
    if (! is_string($value) || $value === '' || strlen($value) > 255
        || preg_match('/[\x00-\x1F\x7F]/', $value)) {
        throw new UnexpectedValueException('Invalid identifier.');
    }
    return $value;
}

function auth66_run(): void
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

        $adapter = new class implements Auth66Adapter {
            public function driver(): string
            {
                return Illuminate\Support\Facades\DB::connection()->getDriverName();
            }

            public function row(string $category): array
            {
                if (! array_key_exists($category, AUTH66_SQL)) {
                    throw new UnexpectedValueException('Unknown query.');
                }
                $row = Illuminate\Support\Facades\DB::connection()->selectOne(AUTH66_SQL[$category], [], false);
                if (! is_object($row)) {
                    throw new UnexpectedValueException('Missing aggregate row.');
                }
                return get_object_vars($row);
            }
        };
        $result = auth66_project($adapter);
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

if (! defined('AUTH66_TEST_MODE')) {
    auth66_run();
}
