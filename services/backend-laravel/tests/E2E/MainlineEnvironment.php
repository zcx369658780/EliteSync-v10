<?php
declare(strict_types=1);
/** TEST-ONLY bootstrap/instance qualification. Never loaded by public/index.php. */
final class MainlineEnvironment
{
    public const DB = 'elitesync_v1015_mainline_e2e_20261029';
    public const CURRENT_TASK = '1db7fc7eaadcea172cc52016904836bd71a0b90d';
    public static array $context;
    public static function canonical(mixed $value): string {
        $sort = function ($v) use (&$sort) {
            if (!is_array($v)) return $v;
            if (!array_is_list($v)) ksort($v);
            return array_map($sort, $v);
        };
        return json_encode($sort($value), JSON_UNESCAPED_SLASHES|JSON_THROW_ON_ERROR);
    }
    public static function need(bool $ok, string $reason): void { if (!$ok) throw new RuntimeException($reason); }
    public static function path(string $value, string $root): string {
        foreach([$value,$root] as $raw) {
            self::need(!str_starts_with(str_replace('\\','/',$raw),'//'), 'Network/device path rejected');
            self::need(preg_match('~^(?:[A-Za-z]:[\\\\/]|/)~',$raw)===1 && !preg_match('~(?:^|[\\\\/])\\.\\.(?:[\\\\/]|$)~',$raw),'Absolute canonical path required');
            for($q=$raw;;$q=dirname($q)) {
                self::need(!is_link($q),'Linked ancestor');
                $real=realpath($q);
                self::need($real!==false && strcasecmp(str_replace('\\','/',rtrim($q,'/\\')),str_replace('\\','/',rtrim($real,'/\\')))===0,'Resolved/aliased ancestor rejected');
                if(strcasecmp(str_replace('\\','/',rtrim($q,'/\\')),str_replace('\\','/',rtrim($root,'/\\')))===0)break;
                self::need(dirname($q)!==$q,'Path outside private root');
            }
        }
        $p=realpath($value);$r=realpath($root);
        self::need($p!==false && $r!==false && ($p===$r || str_starts_with($p,$r.DIRECTORY_SEPARATOR)), 'Non-private path');
        for($q=$p;;$q=dirname($q)){
            self::need(!is_link($q), 'Linked input');
            if(is_file($q))self::need((stat($q)['nlink']??0)===1,'Hardlink input');
            if($q===$r)break;
            self::need(dirname($q)!==$q,'Root mismatch');
        }
        return $p;
    }
    public static function assertContext(array $ctx): void {
        $c=$ctx['config'];$g=$ctx['grant'];
        self::need(($g['owner_authorized']??false)===true && preg_match('/^[a-f0-9]{40}$/D',$g['task_blob']??'')===1 && $g['task_blob']!==self::CURRENT_TASK, 'New Owner runtime grant required');
        self::need(($g['action']??'')==='mainline_api_db_e2e' && ($g['new_instance_qualified']??false)===true,'Scope/qualification missing');
        $now=time();self::need(strtotime($g['not_before'])<=$now && $now<strtotime($g['expires_at']),'Grant expired');
        self::need(hash_equals($g['config_sha256'],hash('sha256',self::canonical($c))),'Config changed');
        self::need(($c['database']??'')===self::DB && ($c['db_port']??0)===43349 && ($c['api']??'')==='http://127.0.0.1:43359/api/v1','Wrong endpoint');
        self::need(($c['source_binding']??null)===($g['source_binding']??null),'Source mismatch');
        self::need(preg_match('/^v1015-mainline-live-.*20261029/',basename($c['task_root']))===1,'New runtime root required');
        self::need(strlen($c['fixture_password']??'')>=16,'Synthetic credential missing');
        self::path($c['source_root'],$c['task_root']);self::path($c['datadir'],$c['task_root']);
        self::need(($c['db_username']??'')==='v1015_e2e' && (int)($c['server_id']??0)>0,'Instance identity missing');
        self::need(!empty($c['source_files']),'Hashed source closure missing');
        foreach($c['source_files'] as $rel=>$expected) {
            self::need(!str_contains($rel,'..') && !str_starts_with($rel,'/') && !str_contains($rel,':'),'Unsafe source manifest');
            $p=self::path($c['source_root'].DIRECTORY_SEPARATOR.$rel,$c['task_root']);
            self::need(hash_equals($expected,hash_file('sha256',$p)),'Source bytes changed');
        }
    }
    public static function connect(array $ctx): PDO {
        self::assertContext($ctx);self::$context=$ctx;$c=$ctx['config'];
        $pdo=new PDO('mysql:host=127.0.0.1;port=43349;dbname='.self::DB.';charset=utf8mb4',$c['db_username'],$c['db_password'],[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_TIMEOUT=>3]);
        $live=$pdo->query('SELECT @@version AS version, @@port AS port, @@datadir AS datadir, @@server_id AS server_id, DATABASE() AS db, CURRENT_USER() AS actor')->fetch(PDO::FETCH_ASSOC);
        self::need(str_starts_with($live['version'],'10.11.19-MariaDB') && (int)$live['port']===43349 && realpath($live['datadir'])===realpath($c['datadir']) && (int)$live['server_id']===$c['server_id'] && $live['db']===self::DB && $live['actor']==='v1015_e2e@127.0.0.1','Live database identity mismatch');
        foreach($pdo->query('SHOW GRANTS')->fetchAll(PDO::FETCH_COLUMN) as $grant) {
            self::need(!str_contains($grant,'WITH GRANT OPTION') && (str_contains($grant,'GRANT USAGE ON *.*') || str_contains($grant,' ON `'.self::DB.'`.* ')),'Cross-schema grants');
        }
        foreach($pdo->query('SHOW GRANTS FOR PUBLIC')->fetchAll(PDO::FETCH_COLUMN) as $grant) self::need(str_contains($grant,'GRANT USAGE ON *.*'),'PUBLIC privileges not isolated');
        return $pdo;
    }
    public static function boot(array $ctx): object {
        $pdo=self::connect($ctx);$c=$ctx['config'];$root=$c['task_root'];$source=self::path($c['source_root'],$root);
        foreach(['DATABASE_URL','DB_URL','ELITESYNC_TASK_DB_QUALIFICATION','ELITESYNC_TASK_DB_QUALIFICATION_SHA256'] as $name)putenv($name);
        $env=['APP_ENV'=>'testing','APP_KEY'=>$c['app_key'],'APP_DB_CONNECTION'=>'mariadb','DB_CONNECTION'=>'mariadb','DB_HOST'=>'127.0.0.1','DB_PORT'=>'43349','DB_DATABASE'=>self::DB,'DB_USERNAME'=>$c['db_username'],'DB_PASSWORD'=>$c['db_password'],'DB_SOCKET'=>'','V1007_LOCAL_RESTORATION'=>'true','V1007_DB_PORT'=>'43349','CACHE_STORE'=>'array','SESSION_DRIVER'=>'array','QUEUE_CONNECTION'=>'sync','LOG_CHANNEL'=>'single','APP_URL'=>'http://127.0.0.1:43359'];
        foreach(['APP_CONFIG_CACHE','APP_SERVICES_CACHE','APP_PACKAGES_CACHE','APP_ROUTES_CACHE','APP_EVENTS_CACHE'] as $name)$env[$name]=$root.'/cache/'.$name.'.php';
        foreach($env as $k=>$v){putenv($k.'='.$v);$_ENV[$k]=$v;$_SERVER[$k]=$v;}
        require_once $source.'/vendor/autoload.php';
        $app=require $source.'/bootstrap/app.php';$app->make(Illuminate\Contracts\Http\Kernel::class)->bootstrap();
        self::need($app->environment('testing') && $app['config']->get('database.default')==='mariadb','Wrong Laravel environment');
        $db=$app['db']->connection();
        self::need($db->getDatabaseName()===self::DB && (int)$db->getConfig('port')===43349 && $db->getConfig('host')==='127.0.0.1' && !$db->getConfig('url') && !$db->getConfig('unix_socket') && !$db->getConfig('read') && !$db->getConfig('write'),'Effective Laravel selector mismatch');
        foreach(['v1007','v1009','v1011_relationship'] as $disk) {
            $path=$app['config']->get('filesystems.disks.'.$disk.'.root');
            if($path)self::path($path,$root);
        }
        // Only environment eligibility is adapted, never CN/MC/Block/actor authorization.
        require_once __DIR__.'/MainlineConsentService.php';
        MainlineConsentService::install($app);
        return $app;
    }
}
