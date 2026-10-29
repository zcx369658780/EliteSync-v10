<?php
namespace Tests\Unit;

use App\Support\PrivateMariaDbQualification;
use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use RuntimeException;

final class PrivateMariaDbQualificationTest extends TestCase
{
    private static function valid(): array
    {
        return ['driver' => 'mariadb', 'host' => '127.0.0.1', 'port' => 43329,
            'database' => 'elitesync_v1015_verify_20261029', 'username' => 'v1015_task'];
    }

    public function test_exact_task_configuration_is_only_a_preconnection_check(): void
    {
        PrivateMariaDbQualification::assertConfiguration(self::valid(), true);
        $this->addToAssertionCount(1); // assertApplication still requires live identity and grants.
    }

    #[DataProvider('unsafeConfigurations')]
    public function test_unsafe_configuration_is_rejected_without_any_connection(array $changes, bool $testing = true): void
    {
        $this->expectException(RuntimeException::class);
        PrivateMariaDbQualification::assertConfiguration(array_replace(self::valid(), $changes), $testing);
    }

    public static function unsafeConfigurations(): iterable
    {
        yield 'production environment' => [[], false];
        foreach ([3306,43316,43317,43328,43339] as $port) yield 'wrong port '.$port => [['port' => $port]];
        yield 'port trailing text' => [['port' => '43329junk']];
        yield 'fractional port' => [['port' => 43329.5]];
        yield 'MySQL substitute' => [['driver' => 'mysql']];
        yield 'localhost ambiguity' => [['host' => 'localhost']];
        yield 'remote host' => [['host' => '192.0.2.1']];
        yield 'old schema' => [['database' => 'elitesync_v1015_dev']];
        yield 'root user' => [['username' => 'root']];
        yield 'URL override' => [['url' => 'mysql://unused.invalid/never-connect']];
        yield 'socket override' => [['unix_socket' => 'unused.sock']];
        yield 'read host override' => [['read' => ['host' => 'unused.invalid']]];
        yield 'write host override' => [['write' => ['host' => 'unused.invalid']]];
    }

    public function test_schema_ddl_needed_by_migrations_is_confined_to_task_schema(): void
    {
        PrivateMariaDbQualification::assertGrants([
            'GRANT USAGE ON *.* TO `v1015_task`@`127.0.0.1`',
            'GRANT ALL PRIVILEGES ON `elitesync_v1015_verify_20261029`.* TO `v1015_task`@`127.0.0.1`',
        ]);
        $this->addToAssertionCount(1);
    }

    #[DataProvider('unsafeGrants')]
    public function test_grants_must_not_escape_task_schema(array $grants): void
    {
        $this->expectException(RuntimeException::class);
        PrivateMariaDbQualification::assertGrants($grants);
    }

    public static function unsafeGrants(): iterable
    {
        yield 'empty result' => [[]];
        yield 'global all' => [['GRANT ALL PRIVILEGES ON *.* TO actor']];
        yield 'global file' => [['GRANT FILE ON *.* TO actor']];
        yield 'another database' => [['GRANT SELECT ON `test`.* TO PUBLIC']];
        yield 'grant option' => [['GRANT ALL PRIVILEGES ON `elitesync_v1015_verify_20261029`.* TO actor WITH GRANT OPTION']];
    }

    private function withFakeApplication(callable $test): void
    {
        // Pure guard negative tests: no PDO, SQL, migration or server startup.
        $root = sys_get_temp_dir().'/qualification-'.bin2hex(random_bytes(8));
        mkdir($root.'/mariadb_data', 0700, true);
        $file = $root.'/proof.json';
        $proof = ['taskBlob' => '48d3670ac26b1959c1b59ffb4871109cef09a4c8',
            'taskId' => 'V1015_PORTABLE_TOOLCHAIN_RECOVERY_20261029', 'taskRoot' => $root,
            'datadir' => $root.'/mariadb_data', 'host' => '127.0.0.1', 'port' => 43329,
            'database' => 'elitesync_v1015_verify_20261029', 'username' => 'v1015_task', 'serverId' => 123456];
        $connection = new class {
            public object $live;
            public array $grants = ['GRANT USAGE ON *.* TO actor', 'GRANT ALL PRIVILEGES ON `elitesync_v1015_verify_20261029`.* TO actor'];
            public function selectOne(string $sql): object { return $this->live; }
            public function select(string $sql): array { return array_map(fn ($g) => (object) ['grant' => $g], $this->grants); }
        };
        $connection->live = (object) ['version' => '10.11.19-MariaDB', 'port' => 43329,
            'datadir' => $proof['datadir'], 'server_id' => 123456, 'db' => $proof['database'], 'actor' => 'v1015_task@127.0.0.1'];
        $database = new class($connection) {
            public int $calls = 0;
            public function __construct(public object $fake) {}
            public function connection(string $name): object { $this->calls++; return $this->fake; }
        };
        $app = new \Illuminate\Foundation\Application($root);
        $app->instance('env', 'testing');
        $app->instance('config', new \Illuminate\Config\Repository(['database' => ['default' => 'mariadb', 'connections' => ['mariadb' => self::valid()]]]));
        $app->instance('db', $database);
        $oldFile = getenv('ELITESYNC_TASK_DB_QUALIFICATION');
        $oldHash = getenv('ELITESYNC_TASK_DB_QUALIFICATION_SHA256');
        $write = function (array $p) use ($file): void {
            file_put_contents($file, json_encode($p, JSON_THROW_ON_ERROR));
            putenv('ELITESYNC_TASK_DB_QUALIFICATION='.$file);
            putenv('ELITESYNC_TASK_DB_QUALIFICATION_SHA256='.hash_file('sha256', $file));
        };
        try {
            $write($proof);
            $test($app, $proof, $write, $database, $connection);
        } finally {
            putenv($oldFile === false ? 'ELITESYNC_TASK_DB_QUALIFICATION' : 'ELITESYNC_TASK_DB_QUALIFICATION='.$oldFile);
            putenv($oldHash === false ? 'ELITESYNC_TASK_DB_QUALIFICATION_SHA256' : 'ELITESYNC_TASK_DB_QUALIFICATION_SHA256='.$oldHash);
            // Keep task-private synthetic proof files for evidence, no cleanup.
        }
    }

    private function denied(callable $action): void
    {
        try {
            $action();
        } catch (RuntimeException) {
            $this->addToAssertionCount(1);
            return;
        }
        $this->fail('Invalid qualification must fail closed.');
    }

    public function test_missing_and_wrong_hash_reject_before_any_connection(): void
    {
        $this->withFakeApplication(function ($app, $proof, $write, $db): void {
            putenv('ELITESYNC_TASK_DB_QUALIFICATION');
            $this->denied(fn () => PrivateMariaDbQualification::assertApplication($app));
            $write($proof);
            putenv('ELITESYNC_TASK_DB_QUALIFICATION_SHA256='.str_repeat('0', 64));
            $this->denied(fn () => PrivateMariaDbQualification::assertApplication($app));
            $this->assertSame(0, $db->calls);
        });
    }

    public function test_proof_scope_mismatch_rejects_before_any_connection(): void
    {
        $this->withFakeApplication(function ($app, $proof, $write, $db): void {
            foreach (['taskBlob' => 'wrong', 'taskId' => 'other-task', 'taskRoot' => $proof['datadir'],
                'datadir' => $proof['taskRoot'], 'port' => 43328, 'database' => 'old', 'username' => 'root'] as $key => $wrong) {
                $write(array_replace($proof, [$key => $wrong]));
                $this->denied(fn () => PrivateMariaDbQualification::assertApplication($app));
            }
            $this->assertSame(0, $db->calls);
        });
    }

    public function test_every_live_identity_field_and_grants_are_required(): void
    {
        $this->withFakeApplication(function ($app, $proof, $write, $db, $connection): void {
            $valid = clone $connection->live;
            PrivateMariaDbQualification::assertApplication($app);
            $this->addToAssertionCount(1);
            foreach (['version' => '9.6-MySQL', 'port' => 43328, 'datadir' => $proof['taskRoot'],
                'server_id' => 999, 'db' => 'old', 'actor' => 'root@localhost'] as $key => $wrong) {
                $connection->live = clone $valid;
                $connection->live->$key = $wrong;
                $this->denied(fn () => PrivateMariaDbQualification::assertApplication($app));
            }
            $connection->live = $valid;
            $connection->grants = ['GRANT ALL PRIVILEGES ON *.* TO actor'];
            $this->denied(fn () => PrivateMariaDbQualification::assertApplication($app));
        });
    }
}
