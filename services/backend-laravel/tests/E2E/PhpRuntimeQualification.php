<?php
declare(strict_types=1);
/** Nonproduction pre-bootstrap capability checks; no Laravel/PDO construction. */
final class PhpRuntimeQualification
{
    public const CLOSED_TASKS = ["5f1c709e31af0d4f2c1c93363c147942db7116c5", "8b6bd9233a08a7f4d0986d6f592eb114dec63e04", "1ade4e5a89116eeba329311ed274229823aafd17", "128fa1f7746ee73ee6d52d2d693715b003a4ec13", "02018a930428bb6417c9fcdd811a6c1350b03988", "0854b37fdc9f11c55088ed2d2f93816a27bc2fa9", "1db7fc7eaadcea172cc52016904836bd71a0b90d", "48d3670ac26b1959c1b59ffb4871109cef09a4c8", "a0eec472b58d53bc25084a395efc0748779d73f8", "a307391e3872ff5367d84ddb7da86e53e531445e"];
    public static function assertTask(string $task,array $policy): void {
        $closed=$policy['closed_runtime_task_blobs']??[];$expected=self::CLOSED_TASKS;sort($closed);sort($expected);
        MainlineEnvironment::need($closed===$expected && preg_match('/^[a-f0-9]{40}$/D',$task)===1 && !in_array($task,$closed,true),'Closed task has no PHP runtime grant');
    }
    public static function assertRuntimePolicy(array $policy): void {
        // A new package archive hash is not an executable or resolved-vendor hash.
        MainlineEnvironment::need(($policy['runtime_qualification_state']??'')==='QUALIFIED_FOR_NEW_OWNER_RUNTIME_TASK'
            && ($policy['composer_lock_state']??'')==='RESOLVED'
            && is_string($policy['reference_executable_sha256']??null)
            && preg_match('/^[a-f0-9]{64}$/D',$policy['reference_executable_sha256'])===1,
            'PHP dependency supply/Composer lock pending; runtime forbidden');
        MainlineEnvironment::need(($policy['vc_runtime']['state']??'')==='QUALIFIED'
            && is_string($policy['vc_runtime']['minimum_version']??null)
            && preg_match('/^[a-f0-9]{64}$/D',$policy['vc_runtime']['source_receipt_sha256']??'')===1
            && preg_match('/^[a-f0-9]{64}$/D',$policy['vc_runtime']['license_receipt_sha256']??'')===1,
            'PHP VC source/license/minimum-version qualification pending');
    }
    public static function capabilities(array $facts,array $manifest,array $policy): void {
        MainlineEnvironment::need(($facts['version']??'')===$policy['php_version'] && ($facts['int_size']??0)===8 && ($facts['zts']??null)===$policy['thread_safe'],'PHP version/architecture/ABI');
        MainlineEnvironment::need(in_array($facts['sapi']??'', ['cli','cli-server'],true),'PHP SAPI mismatch');
        MainlineEnvironment::need(($facts['ini_loaded']??null)===false && empty($facts['ini_scanned']) && empty($facts['auto_prepend']) && empty($facts['auto_append']) && empty($facts['enable_dl']),'Implicit PHP configuration rejected');
        $expected=array_merge($manifest['builtin_modules'],array_keys($manifest['shared_modules']));sort($expected);
        $loaded=array_map('strtolower',$facts['modules']);sort($loaded);
        MainlineEnvironment::need($loaded===$expected,'PHP loaded-module set mismatch');
        foreach($policy['required_modules'] as $module)MainlineEnvironment::need(in_array($module,$loaded,true),'Required PHP module missing');
        foreach($policy['functions'] as $function)MainlineEnvironment::need(($facts['functions'][$function]??false)===true,'Required PHP function unavailable');
        foreach($policy['classes'] as $class)MainlineEnvironment::need(($facts['classes'][$class]??false)===true,'Required PHP class unavailable');
        MainlineEnvironment::need(in_array('mysql',$facts['pdo_drivers']??[],true),'PDO MySQL driver unavailable');
    }
    public static function nativeReceipt(array $receipt,array $manifest,array $expected,int $pid,string $nonce,string $manifestHash): void {
        MainlineEnvironment::need(($receipt['pid']??null)===$pid && ($receipt['nonce']??null)===$nonce && ($receipt['manifest_sha256']??null)===$manifestHash,'PHP native receipt process/profile identity');
        MainlineEnvironment::need(!empty($receipt['images']) && !empty($receipt['system_directory']),'PHP native image observation missing');
        $seen=[];
        foreach($receipt['images'] as $image) {
            $key=strtolower(str_replace('\\','/',$image['path']));
            MainlineEnvironment::need(!isset($seen[$key]),'Duplicate native image');$seen[$key]=true;
            if(isset($expected[$key]))MainlineEnvironment::need($image['sha256']===$expected[$key],'Private native image differs');
            else {
                $name=strtolower(basename(str_replace('\\','/',$image['path'])));
                MainlineEnvironment::need(strtolower(str_replace('\\','/',dirname($image['path'])))===strtolower(str_replace('\\','/',$receipt['system_directory'])) && isset($manifest['windows_system_modules'][$name]) && $image['sha256']===$manifest['windows_system_modules'][$name],'Native dependency outside approved image closure');
            }
        }
        MainlineEnvironment::need(isset($seen[strtolower(str_replace('\\','/',$manifest['_absolute_executable']))]),'PHP image not observed');
        foreach($manifest['_absolute_extensions'] as $p)MainlineEnvironment::need(isset($seen[strtolower(str_replace('\\','/',$p))]),'PHP extension image not observed');
    }
    public static function assertCurrent(array $ctx): void {
        $c=$ctx['config'];$g=$ctx['grant'];$root=$c['task_root'];
        self::assertTask((string)($g['task_blob']??''),['closed_runtime_task_blobs'=>self::CLOSED_TASKS]);
        $path=MainlineEnvironment::path($c['php_runtime_manifest'],$root);
        $bytes=file_get_contents($path);$hash=hash('sha256',$bytes);
        MainlineEnvironment::need($hash===($c['php_runtime_manifest_sha256']??null) && $hash===($g['php_cli_manifest_sha256']??null) && $hash===($g['php_api_manifest_sha256']??null) && $hash===getenv('ELITESYNC_PHP_RUNTIME_MANIFEST_SHA256'),'CLI/API PHP closure differs');
        $manifest=json_decode($bytes,true,512,JSON_THROW_ON_ERROR);
        $policyPath=MainlineEnvironment::path($c['php_requirements'],$root);
        $policyBytes=file_get_contents($policyPath);$policy=json_decode($policyBytes,true,512,JSON_THROW_ON_ERROR);
        self::assertTask($g['task_blob'],$policy);
        self::assertRuntimePolicy($policy);
        MainlineEnvironment::need(hash('sha256',$policyBytes)===($g['php_requirements_file_sha256']??null) && hash('sha256',MainlineEnvironment::canonical($policy))===$manifest['requirements_sha256'],'PHP requirements identity differs');
        MainlineEnvironment::need(($manifest['candidate_parent']??null)===$policy['candidate_parent'] && ($manifest['source_binding']??null)===$c['source_binding'] && ($manifest['source_binding']['apps_tree']??null)===$policy['apps_tree'],'PHP candidate differs');
        $runtime=MainlineEnvironment::path($c['php_runtime_root'],$root);
        $exe=MainlineEnvironment::path($runtime.'/'.$manifest['executable'],$root);
        MainlineEnvironment::need($exe===realpath(PHP_BINARY) && $exe===realpath($c['php']) && hash_file('sha256',$exe)===$policy['reference_executable_sha256'],'PHP executable identity differs');
        MainlineEnvironment::need(realpath((string)ini_get('open_basedir'))===realpath($root) && realpath((string)ini_get('include_path'))===dirname($exe),'PHP include/write scope differs');
        $extensionDir=MainlineEnvironment::path($runtime.'/'.$manifest['extension_directory'],$root);
        MainlineEnvironment::need(realpath((string)ini_get('extension_dir'))===$extensionDir && $extensionDir===realpath($c['php_extension_dir']),'PHP extension directory differs');
        foreach($manifest['files'] as $file) {
            $rel=$file['path'];MainlineEnvironment::need(!str_contains($rel,'..') && !str_contains($rel,':') && !str_contains($rel,'\\') && !str_starts_with($rel,'/'),'PHP manifest traversal');
            $p=MainlineEnvironment::path($runtime.'/'.$rel,$root);
            MainlineEnvironment::need(hash_equals($file['sha256'],hash_file('sha256',$p)) && ($file['source_sha256']??null)===$file['sha256'],'PHP binary/extension/DLL hash changed');
        }
        foreach($policy['source_documents'] as $rel=>$expected) {
            $p=MainlineEnvironment::path($c['source_root'].'/'.$rel,$root);
            MainlineEnvironment::need(hash_file('sha256',$p)===$expected,'Composer inputs changed');
        }
        $functions=[];foreach($policy['functions'] as $function)$functions[$function]=function_exists($function);
        $classes=[];foreach($policy['classes'] as $class)$classes[$class]=class_exists($class,false);
        self::capabilities(['version'=>PHP_VERSION,'int_size'=>PHP_INT_SIZE,'zts'=>(bool)PHP_ZTS,'sapi'=>PHP_SAPI,'ini_loaded'=>php_ini_loaded_file(),'ini_scanned'=>php_ini_scanned_files(),'auto_prepend'=>ini_get('auto_prepend_file'),'auto_append'=>ini_get('auto_append_file'),'enable_dl'=>ini_get('enable_dl'),'modules'=>get_loaded_extensions(),'functions'=>$functions,'classes'=>$classes,'pdo_drivers'=>class_exists('PDO',false)?PDO::getAvailableDrivers():[]],$manifest,$policy);
        $nonce=(string)getenv('ELITESYNC_PHP_START_NONCE');
        MainlineEnvironment::need(preg_match('/^[a-f0-9]{32}$/D',$nonce)===1,'Qualified PHP launcher nonce missing');
        $ready=(string)getenv('ELITESYNC_PHP_NATIVE_READY');$receipt=(string)getenv('ELITESYNC_PHP_NATIVE_RECEIPT');
        foreach([$ready,$receipt] as $p) {
            MainlineEnvironment::path(dirname($p),$root);
            MainlineEnvironment::need(preg_match('/^php-'.$nonce.'[.](?:ready|images)[.]json$/D',basename($p))===1,'Native receipt path mismatch');
        }
        $id=['pid'=>getmypid(),'nonce'=>$nonce,'manifest_sha256'=>$hash];
        if(!file_exists($ready)) {
            $f=fopen($ready,'xb');MainlineEnvironment::need($f!==false,'Native ready creation failed');
            fwrite($f,json_encode($id,JSON_THROW_ON_ERROR));fflush($f);fsync($f);fclose($f);
        } else MainlineEnvironment::need(json_decode(file_get_contents(MainlineEnvironment::path($ready,$root)),true)===$id,'Native ready identity changed');
        $deadline=microtime(true)+10;
        while(!is_file($receipt)){MainlineEnvironment::need(microtime(true)<$deadline,'Native image observation timeout');usleep(20000);}
        $native=json_decode(file_get_contents(MainlineEnvironment::path($receipt,$root)),true,512,JSON_THROW_ON_ERROR);
        $osPolicy=$manifest['windows_os_image_policy']??[];
        MainlineEnvironment::need(($osPolicy['purpose']??'')==='READONLY_LOADED_WINDOWS_OS_IMAGES' && strtolower(str_replace('\\','/',$osPolicy['system_root']['path']??''))===strtolower(str_replace('\\','/',$native['system_directory']??'')),'OS image policy/system root mismatch');
        foreach($manifest['windows_system_modules'] as $name=>$imageHash)MainlineEnvironment::need(($osPolicy['images'][$name]['sha256']??null)===$imageHash,'OS image policy hash mismatch');

        $expected=[];
        foreach($manifest['files'] as $entry) {
            $p=MainlineEnvironment::path($runtime.'/'.$entry['path'],$root);
            $expected[strtolower(str_replace('\\','/',$p))]=$entry['sha256'];
        }
        $manifest['_absolute_executable']=$exe;$manifest['_absolute_extensions']=[];
        foreach($manifest['shared_modules'] as $p)$manifest['_absolute_extensions'][]=MainlineEnvironment::path($runtime.'/'.$p,$root);
        self::nativeReceipt($native,$manifest,$expected,getmypid(),$nonce,$hash);
    }
}
