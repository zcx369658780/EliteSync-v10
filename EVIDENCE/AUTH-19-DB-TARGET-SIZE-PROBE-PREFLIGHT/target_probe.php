<?php

declare(strict_types=1);

/** AUTH-19: fixed metadata only. Real bootstrap requires a separate task. */
interface Auth19TargetAdapter
{
    public function driver(): string;

    /** @return array<string, mixed> */
    public function metadata(): array;
}

/** @return array<string, mixed> */
function auth19_project_target(Auth19TargetAdapter $adapter): array
{
    try {
        if ($adapter->driver() !== 'mysql') {
            return ['ok' => false, 'error' => 'UNSUPPORTED_DRIVER'];
        }

        $raw = $adapter->metadata();
        $required = ['version_text', 'database_name', 'server_name', 'table_count', 'estimated_bytes'];
        $keys = array_keys($raw);
        sort($keys);
        sort($required);
        if ($keys !== $required) {
            throw new UnexpectedValueException('Unexpected metadata shape.');
        }

        $version = auth19_version($raw['version_text']);
        $database = auth19_identifier($raw['database_name']);
        $server = auth19_identifier($raw['server_name']);
        $tables = auth19_nonnegative_integer($raw['table_count']);
        $bytes = auth19_nonnegative_integer($raw['estimated_bytes']);
        if ($tables === 0 && $bytes !== 0) {
            throw new UnexpectedValueException('Inconsistent metadata.');
        }

        return [
            'ok' => true,
            'driver' => 'mysql',
            'family' => $version['family'],
            'version' => $version['version'],
            'target_fingerprint_sha256' => hash('sha256', $server."\0".$database),
            'table_count' => $tables,
            'estimated_bytes' => $bytes,
        ];
    } catch (UnexpectedValueException) {
        return ['ok' => false, 'error' => 'INVALID_METADATA'];
    } catch (Throwable) {
        return ['ok' => false, 'error' => 'ADAPTER_ERROR'];
    }
}

/** @return array{family: string, version: string} */
function auth19_version(mixed $value): array
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

    throw new UnexpectedValueException('Unknown version.');
}

function auth19_identifier(mixed $value): string
{
    if (! is_string($value) || $value === '' || strlen($value) > 255
        || preg_match('/[\x00-\x1F\x7F]/', $value)) {
        throw new UnexpectedValueException('Invalid identifier.');
    }

    return $value;
}

function auth19_nonnegative_integer(mixed $value): int
{
    if (is_int($value) && $value >= 0) {
        return $value;
    }
    if (is_string($value) && preg_match('/\A(?:0|[1-9][0-9]*)\z/D', $value)) {
        $parsed = filter_var($value, FILTER_VALIDATE_INT, ['options' => ['min_range' => 0]]);
        if ($parsed !== false) {
            return $parsed;
        }
    }

    throw new UnexpectedValueException('Invalid aggregate.');
}

function auth19_run_probe(): void
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

        $adapter = new class implements Auth19TargetAdapter {
            private const SQL = 'SELECT VERSION() AS version_text, DATABASE() AS database_name, '
                .'@@hostname AS server_name, COUNT(*) AS table_count, '
                .'COALESCE(SUM(data_length + index_length), 0) AS estimated_bytes '
                .'FROM information_schema.tables WHERE table_schema = DATABASE()';

            public function driver(): string
            {
                return Illuminate\Support\Facades\DB::connection()->getDriverName();
            }

            public function metadata(): array
            {
                // The current connection's write PDO avoids a configured read replica.
                // This is still one read-only SELECT with no connection name or input.
                $row = Illuminate\Support\Facades\DB::connection()->selectOne(self::SQL, [], false);
                if (! is_object($row)) {
                    throw new UnexpectedValueException('No metadata row.');
                }

                return get_object_vars($row);
            }
        };
        $result = auth19_project_target($adapter);
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

if (! defined('AUTH19_TARGET_PROBE_TEST_MODE')) {
    auth19_run_probe();
}
