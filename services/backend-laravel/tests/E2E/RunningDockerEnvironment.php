<?php
declare(strict_types=1);
namespace Tests\E2E;
use PDO;
use RuntimeException;
use Illuminate;
/** TEST-ONLY current-task bootstrap. Public index.php never loads this file. */
final class RunningDockerEnvironment
{
    public const TASK = 'V1015_RUNNING_DOCKER_ENGINE_LARAVEL_BATCH_20261030';
    public const BLOB = 'a1cbc75afe406e3e05712c6c51fb63c86bad928d';
    public const PARENT = 'debe4a11d19f25179efef1d90d04e346980c2867';
    public const DB = 'elitesync_v1015_running_20261030';
    public const PORT = 43479;
    public static function need(bool $ok, string $reason): void { if (!$ok) { throw new RuntimeException($reason); } }
    public static function proof(): array
    {
        $file = getenv('ELITESYNC_RUNNING_DOCKER_PROOF');
        $hashFile=getenv('ELITESYNC_RUNNING_DOCKER_PROOF_SHA256_FILE');
        self::need($hashFile==='/task-state/qualification.sha256' && is_file($hashFile),'Task proof digest file');
        $hash=trim(file_get_contents($hashFile));
        self::need($file === '/task-state/qualification.json' && is_string($hash) && strlen($hash) === 64 && is_file($file), 'Current task proof required');
        $raw = file_get_contents($file); self::need(is_string($raw) && hash_equals($hash, hash('sha256', $raw)), 'Task proof bytes changed');
        $p = json_decode($raw, true, 512, JSON_THROW_ON_ERROR);
        self::need(($p['task_id'] ?? '') === self::TASK && ($p['task_blob'] ?? '') === self::BLOB && ($p['parent'] ?? '') === self::PARENT
            && ($p['root_basename'] ?? '') === 'v1015-running-docker-engine-laravel-batch-20261030', 'Task proof identity');
        self::need(time() >= $p['not_before'] && time() < $p['expires'], 'Task runtime window');
        self::need(PHP_VERSION === $p['php_version'] && PHP_OS_FAMILY==='Linux' && PHP_INT_SIZE===8, 'PHP runtime identity');
        $selectors = ['APP_ENV'=>'testing','APP_DB_CONNECTION'=>'mariadb','DB_CONNECTION'=>'mariadb',
            'APP_DB_HOST'=>'db','DB_HOST'=>'db','APP_DB_PORT'=>(string)self::PORT,'DB_PORT'=>(string)self::PORT,
            'APP_DB_DATABASE'=>self::DB,'DB_DATABASE'=>self::DB,'APP_DB_USERNAME'=>'v1015_running','DB_USERNAME'=>'v1015_running',
            'APP_DB_SOCKET'=>'','DB_SOCKET'=>'','APP_DB_URL'=>'','DB_URL'=>'','DATABASE_URL'=>''];
        foreach ($selectors as $key=>$expected) { self::need(getenv($key) === $expected, 'Task DB selector mismatch: '.$key); }
        self::need(getenv('DB_PASSWORD') === $p['db_password'] && getenv('APP_DB_PASSWORD') === $p['db_password'], 'Task DB credential binding');
        self::need(realpath('/app') === '/app' && !empty($p['source_files']), 'Task source closure');
        // Verify the complete closure once per PHP request/CLI execution, keyed by proof bytes.
        // All DB/environment/window checks still execute at every protected use point.
        static $verifiedClosures = [];
        if (!isset($verifiedClosures[$hash])) {
        foreach ($p['source_files'] as $relative=>$expected) {
            self::need(is_string($relative) && !str_contains($relative, '..') && !str_starts_with($relative, '/') && !str_contains($relative, ':'), 'Unsafe task source path');
            $file='/app/'.$relative; $real=realpath($file);
            self::need(is_string($real) && str_starts_with($real, '/app/') && !is_link($file) && is_file($file), 'Task source escaped');
            self::need(hash_equals($expected, hash_file('sha256', $file)), 'Task source bytes changed: '.$relative);
        }
        $verifiedClosures[$hash] = true;
        }
        return $p;
    }
    public static function connect(): PDO
    {
        $p=self::proof();
        $db=new PDO('mysql:host=db;port='.self::PORT.';dbname='.self::DB.';charset=utf8mb4', 'v1015_running', $p['db_password'],
            [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_TIMEOUT=>3]);
        $v=$db->query('SELECT @@version version, @@port port, @@datadir datadir, @@server_id server_id, @@hostname hostname, DATABASE() db, CURRENT_USER() actor')->fetch(PDO::FETCH_ASSOC);
        self::need(str_starts_with($v['version'], $p['mariadb_patch'].'-MariaDB') && (int)$v['port']===self::PORT
            && $v['datadir']==='/var/lib/mysql/' && (int)$v['server_id']===$p['server_id'] && $v['hostname']==='es-v1015-running-db'
            && $v['db']===self::DB && $v['actor']==='v1015_running@%', 'Live task MariaDB identity mismatch');
        foreach ($db->query('SHOW GRANTS')->fetchAll(PDO::FETCH_COLUMN) as $grant) {
            self::need(!str_contains($grant, 'WITH GRANT OPTION') && (str_contains($grant, 'GRANT USAGE ON *.*')
                || str_contains($grant, ' ON `'.str_replace('_', '\\_', self::DB).'`.* ')), 'Task actor has cross-schema privileges');
        }
        try {
            foreach ($db->query('SHOW GRANTS FOR PUBLIC')->fetchAll(PDO::FETCH_COLUMN) as $grant) {
                self::need(str_contains($grant,'GRANT USAGE ON *.*'), 'PUBLIC cross-schema grant');
            }
        } catch (\PDOException $error) {
            // No such PUBLIC grant is equivalent to no inherited PUBLIC privilege.
            if (($error->errorInfo[1] ?? null)!==1141) { throw $error; }
        }
        return $db;
    }
    public static function app(): object
    {
        self::connect();
        // This qualified synthetic instance uses only its task-private local media disk.
        putenv('MEDIA_STORAGE_DISK=v1011_relationship');
        require_once '/app/vendor/autoload.php';
        $app=require '/app/bootstrap/app.php';
        // Only the already-existing explicit E2E eligibility hook is bound.
        // Every CN/MC/Block/account/media use-point still executes production code.
        $app->instance('v1015.mainline-e2e.instance-qualified', static function (): bool { self::connect(); return true; });
        $app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
        self::need($app->environment('testing') && $app['config']->get('database.default')==='mariadb', 'Effective Laravel environment');
        $c=$app['db']->connection()->getConfig();
        self::need($c['driver']==='mariadb' && $c['host']==='db' && (int)$c['port']===self::PORT && $c['database']===self::DB
            && $c['username']==='v1015_running' && empty($c['url']) && empty($c['unix_socket']) && empty($c['read']) && empty($c['write']), 'Effective Laravel DB selectors');
        self::need($app['config']->get('session.serialization')==='php' && $app['config']->get('session.driver')==='file', 'Session format/driver drift');
        self::need($app['config']->get('media.disk')==='v1011_relationship'
            && $app['config']->get('filesystems.disks.v1011_relationship.root')==='/app/storage/app/v1011-relationship-private', 'Task-private media disk');
        return $app;
    }
}
