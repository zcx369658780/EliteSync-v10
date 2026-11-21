<?php

declare(strict_types=1);

use App\Services\SyntheticConnectionScope;
use Illuminate\Contracts\Console\Kernel;
use Illuminate\Support\Facades\DB;

require '/var/www/html/vendor/autoload.php';
$app = require '/var/www/html/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();

try {
    $functionFixture = in_array('--function', $argv, true);
    $expectedDatabase = $functionFixture ? SyntheticConnectionScope::DATABASE : 'elitesync_v2_r0';
    $expectedUser = $functionFixture ? 'elitesync_function_app' : 'elitesync_r0_app';
    $expectedServer = $functionFixture ? SyntheticConnectionScope::SERVER_ID : 2621111;
    $config = config('database.connections.mariadb');
    if (! $app->environment('staging') || config('database.default') !== 'mariadb'
        || $config['url'] || $config['unix_socket'] || $config['host'] !== 'r0-db'
        || (int) $config['port'] !== 3306 || $config['database'] !== $expectedDatabase
        || $config['username'] !== $expectedUser
        || ($functionFixture && ! app(SyntheticConnectionScope::class)->targetsFixtureRuntime())) {
        throw new RuntimeException('Unexpected staging connection settings');
    }
    $identity = DB::selectOne('SELECT DATABASE() AS db_name, VERSION() AS db_version, @@server_id AS server_id');
    if ($identity->db_name !== $expectedDatabase
        || ! preg_match('/^10\.11\..*MariaDB/i', $identity->db_version)
        || (int) $identity->server_id !== $expectedServer) {
        throw new RuntimeException('Unexpected database identity');
    }
    $tables = DB::selectOne('SELECT COUNT(*) AS total FROM information_schema.tables WHERE table_schema = DATABASE()');
    $isInitial = in_array('--empty', $argv, true);
    if ($isInitial && (int) $tables->total !== 0) {
        throw new RuntimeException('Database is not empty');
    }
    echo json_encode(['schema' => $identity->db_name, 'version' => $identity->db_version,
        'server_id' => (int) $identity->server_id, 'tables' => (int) $tables->total], JSON_THROW_ON_ERROR), PHP_EOL;
} catch (Throwable $error) {
    fwrite(STDERR, "R0 database preflight refused the connection or schema\n");
    exit(1);
}
