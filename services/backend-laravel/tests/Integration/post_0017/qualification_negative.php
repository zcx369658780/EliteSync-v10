<?php
declare(strict_types=1);
if (PHP_SAPI!=='cli' || getenv('TASK_ID')!=='V1015_POST_0017_DEVICE_E2E_FINAL_CLOSURE_20261031') exit(20);
require dirname(__DIR__,3).'/vendor/autoload.php';$app=require dirname(__DIR__,3).'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();require __DIR__.'/qualify.php';
use Illuminate\Support\Facades\DB;
try {
    $out=[];
    foreach (['host'=>'not_the_task_db','port'=>3306,'database'=>'not_the_task_schema','username'=>'not_the_task_user','url'=>'mysql://invalid.invalid/never_connect','unix_socket'=>'/never_connect'] as $key=>$wrong) {
        $name='database.connections.mysql.'.$key;$old=config($name);config([$name=>$wrong]);DB::purge('mysql');$denied=false;
        try{qualifyPost0017Task($app);}catch(RuntimeException){$denied=true;}finally{config([$name=>$old]);DB::purge('mysql');}
        if(!$denied || $app->bound('restoration.private-instance-qualified'))throw new RuntimeException('Invalid connection qualified');
        $out[]=['case'=>$key,'denied'=>true,'connection_to_wrong_target_attempted'=>false];
    }
    $manager=DB::getFacadeRoot();$connection=$manager->connection();
    foreach (['server_id','grants'] as $case) {
        // Keep the real qualified connection; inject only a mismatched observed identity/grant result.
        $wrapped=new class($connection,$case) {
            public function __construct(private $db,private string $case){}
            public function getConfig($key){return $this->db->getConfig($key);}
            public function selectOne($sql){$r=clone $this->db->selectOne($sql);if($this->case==='server_id')$r->server_id++;return $r;}
            public function select($sql){return $this->case==='grants'?[(object)['grant'=>'GRANT ALL PRIVILEGES ON *.* TO `post0017_app`@`%` WITH GRANT OPTION']]:$this->db->select($sql);}
        };
        DB::swap(new class($wrapped){public function __construct(private $db){}public function connection(){return $this->db;}});$denied=false;
        try{qualifyPost0017Task($app);}catch(RuntimeException){$denied=true;}finally{DB::swap($manager);}
        if(!$denied || $app->bound('restoration.private-instance-qualified'))throw new RuntimeException('Injected wrong observation qualified');
        $out[]=['case'=>$case,'denied'=>true,'classification'=>'TEST_INJECTION_ON_REAL_CONNECTION_RESULT'];
    }
    $identity=qualifyPost0017Task($app);
    if(!app(App\Services\LiveConsentService::class)->enabled())throw new RuntimeException('Valid instance denied');
    echo json_encode(['negative_cases'=>$out,'positive'=>true,'effective_schema'=>$identity['db']],JSON_THROW_ON_ERROR).PHP_EOL;
} catch(Throwable $e) {fwrite(STDERR,get_class($e).': '.$e->getMessage().PHP_EOL);exit(1);}
