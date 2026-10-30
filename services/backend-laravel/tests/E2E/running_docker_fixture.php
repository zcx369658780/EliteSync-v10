<?php
declare(strict_types=1);
use Tests\E2E\RunningDockerEnvironment;
require_once __DIR__.'/RunningDockerEnvironment.php';
try {
    $mode=$argv[1] ?? ''; RunningDockerEnvironment::need(in_array($mode, ['migrate','seed','snapshot','legacy-session'],true),'Fixture action');
    $app=RunningDockerEnvironment::app(); $db=$app['db']->connection(); $proof=RunningDockerEnvironment::proof();
    if ($mode==='migrate') {
        $raw=RunningDockerEnvironment::connect();
        RunningDockerEnvironment::need((int)$raw->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='".RunningDockerEnvironment::DB."'")->fetchColumn()===0,'New schema must be empty before first migration');
        $exit=$app->make(Illuminate\Contracts\Console\Kernel::class)->call('migrate',['--force'=>true]);
        RunningDockerEnvironment::need($exit===0,'Actual migration failed');
        echo json_encode(['migrated'=>true,'migration_rows'=>$db->table('migrations')->count()],JSON_THROW_ON_ERROR); exit;
    }
    if ($mode==='seed') {
        foreach (['users','chat_messages','notifications'] as $table) { RunningDockerEnvironment::need($db->table($table)->count()===0,'Fixture schema is not empty; never reset'); }
        $result=$db->transaction(function () use ($db,$proof) {
            $pairs=[]; $i=0;
            foreach (['base','block','mc','cn','disabled'] as $name) {
                $pair=[];
                foreach (['a','b'] as $side) {
                    $i++; $phone=(string)(19900002600+$i);
                    $u=App\Models\User::create(['name'=>'TASK-RUNNING-'.$name.'-'.$side,'email'=>'task-running-'.$i.'@example.invalid',
                        'phone'=>$phone,'password'=>Illuminate\Support\Facades\Hash::make($proof['fixture_password']),
                        'role'=>'user','disabled'=>false,'is_synthetic'=>false]);
                    $pair[$side]=['id'=>(int)$u->id,'phone'=>$phone];
                }
                $a=$pair['a']['id'];$b=$pair['b']['id'];
                $db->table('friendships')->insert(['user_a'=>min($a,$b),'user_b'=>max($a,$b),'state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
                $service=app(App\Services\LiveConsentService::class);
                foreach ([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision]) {
                    $service->transition($actor,$peer,$kind,$action,$revision);
                }
                $pairs[$name]=$pair;
            }
            $admin=App\Models\User::create(['name'=>'TASK-RUNNING-admin','email'=>'task-running-admin@example.invalid',
                'phone'=>'19900002999','password'=>Illuminate\Support\Facades\Hash::make($proof['fixture_password']),
                'role'=>'admin','disabled'=>false,'is_synthetic'=>false]);
            return ['pairs'=>$pairs,'admin'=>['id'=>(int)$admin->id,'phone'=>'19900002999']];
        });
        echo json_encode($result,JSON_THROW_ON_ERROR); exit;
    }
    if ($mode==='snapshot') {
        $out=['users'=>$db->table('users')->count(),'messages'=>$db->table('chat_messages')->count(),
            'attachments'=>$db->table('message_attachments')->count(),'notifications'=>$db->table('notifications')->count(),
            'sessions'=>$db->table('device_sessions')->count(),'migration_rows'=>$db->table('migrations')->count(),
            'message_facts'=>$db->table('chat_messages')->orderBy('id')->get(['id','sender_id','receiver_id','client_message_id','content'])->toArray()];
        echo json_encode($out,JSON_THROW_ON_ERROR); exit;
    }
    $user=App\Models\User::where('phone','19900002999')->firstOrFail();
    RunningDockerEnvironment::need($user->name==='TASK-RUNNING-admin' && app(App\Services\Accounts\AdminAccess::class)->allows($user),'Owned admin fixture');
    $sid=Illuminate\Support\Str::random(40);$csrf=Illuminate\Support\Str::random(40);
    // A legacy PHP-serialized synthetic session, not a claim that Laravel11 ran.
    $payload=['_token'=>$csrf,Illuminate\Support\Facades\Auth::guard('web')->getName()=>(int)$user->id,'legacy_format_fixture'=>true];
    $dir=config('session.files');RunningDockerEnvironment::need(str_starts_with(realpath($dir),'/app/storage/'),'Private session path');
    file_put_contents($dir.'/'.$sid,serialize($payload),LOCK_EX);
    app(App\Services\PlatformAccess::class)->recordAdminSession((int)$user->id,$sid);
    $name=config('session.cookie');$prefix=Illuminate\Cookie\CookieValuePrefix::create($name,app('encrypter')->getKey());
    $cookie=app('encrypter')->encrypt($prefix.$sid,false);
    echo json_encode(['cookie_name'=>$name,'cookie'=>$cookie,'csrf'=>$csrf,'session_id'=>$sid,'wire_format'=>'PHP_SERIALIZED_SYNTHETIC_LEGACY'],JSON_THROW_ON_ERROR);
} catch (Throwable $error) { fwrite(STDERR,get_class($error).': '.$error->getMessage()."\n");exit(1); }
