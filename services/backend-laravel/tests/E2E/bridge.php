<?php
declare(strict_types=1);
/** Future isolated fixture/observation CLI. Secrets and output remain LOCAL_ONLY. */
require_once __DIR__.'/MainlineEnvironment.php';
try {
    $ctx=json_decode(stream_get_contents(STDIN),true,512,JSON_THROW_ON_ERROR);
    MainlineEnvironment::assertContext($ctx);$mode=$ctx['mode'];
    MainlineEnvironment::need(in_array($mode,['seed','snapshot','fail_asset','disable','projection'],true),'Invalid mode');
    $app=MainlineEnvironment::boot($ctx);$c=$ctx['config'];$args=$ctx['args'];$db=$app['db']->connection();
    if($mode==='seed') {
        MainlineEnvironment::need((int)$db->table('users')->count()===0 && (int)$db->table('chat_messages')->count()===0 && (int)$db->table('notifications')->count()===0,'Fresh migrated empty schema required; never reset');
        $out=$db->transaction(function()use($c,$db){
            $pairs=[];$i=0;
            foreach(['base','block','mc','cn','disabled'] as $name) {
                $pair=[];
                foreach(['a','b'] as $side){
                    $i++;$phone=(string)(19900001600+$i);
                    // Fictional ordinary accounts. Not verified real identities or synthetic-provider bypass.
                    $u=App\Models\User::create(['name'=>'E2E-MAINLINE-'.$name.'-'.$side,'email'=>'e2e-'.$i.'@example.invalid','phone'=>$phone,'password'=>Illuminate\Support\Facades\Hash::make($c['fixture_password']),'role'=>'user','disabled'=>false,'is_synthetic'=>false]);
                    $pair[$side]=['id'=>(int)$u->id,'phone'=>$phone];
                }
                $a=$pair['a']['id'];$b=$pair['b']['id'];
                $db->table('friendships')->insert(['user_a'=>min($a,$b),'user_b'=>max($a,$b),'state'=>'ACTIVE','revision'=>1,'created_at'=>now(),'updated_at'=>now()]);
                $service=app(App\Services\LiveConsentService::class);
                foreach([[$a,$b,'connection','request',0],[$b,$a,'connection','accept',1],[$a,$b,'consent','request',0],[$b,$a,'consent','accept',1]] as [$actor,$peer,$kind,$action,$revision])$service->transition($actor,$peer,$kind,$action,$revision);
                $pairs[$name]=$pair;
            }
            return ['pairs'=>$pairs,'task_blob'=>MainlineEnvironment::$context['grant']['task_blob']];
        });
    } else {
        $owned=[];foreach(($ctx['fixture']['pairs']??[])as $pair)foreach($pair as $who)$owned[]=(int)$who['id'];
        MainlineEnvironment::need(count($owned)===10 && count(array_unique($owned))===10,'Owned fixture identities missing');
        foreach($owned as $id)MainlineEnvironment::need(str_starts_with((string)$db->table('users')->where('id',$id)->value('name'),'E2E-MAINLINE-'),'Non-fixture user');
        if($mode==='snapshot'){
            MainlineEnvironment::need(in_array((int)$args['sender'],$owned,true) && preg_match('/^[a-f0-9-]{36}$/D',$args['key'])===1,'Invalid observation identity');
            $messages=$db->table('chat_messages')->where('sender_id',$args['sender'])->where('client_message_id',$args['key'])->get();
            $ids=$messages->pluck('id')->all();$notes=$db->table('notifications')->whereIn('user_id',$owned)->whereIn('payload->message_id',$ids)->get();
            $out=['message_count'=>$messages->count(),'message_id'=>$ids[0]??null,'attachment_count'=>$db->table('message_attachments')->whereIn('message_id',$ids)->count(),'notification_count'=>$notes->count(),'notice_id'=>$notes->first()->id??null];
        } elseif($mode==='fail_asset'){
            MainlineEnvironment::need(in_array((int)$args['owner'],$owned,true),'Non-fixture owner');
            $count=$db->table('media_assets')->where('id',$args['asset'])->where('owner_user_id',$args['owner'])->update(['status'=>'failed','updated_at'=>now()]);
            MainlineEnvironment::need($count===1,'Missing owned asset');$out=['updated'=>1];
        } elseif($mode==='disable'){
            MainlineEnvironment::need(in_array((int)$args['user'],$owned,true),'Non-fixture user');
            $db->table('users')->where('id',$args['user'])->update(['disabled'=>true,'updated_at'=>now()]);$out=['disabled'=>true];
        } else {
            MainlineEnvironment::need(in_array((int)$args['owner'],$owned,true),'Non-fixture owner');
            $notice=App\Models\AppNotificationItem::where('id',$args['notice'])->where('user_id',$args['owner'])->firstOrFail();
            $out=app(App\Services\NotificationDeliveryService::class)->attempt($notice,$args['device']);
        }
    }
    echo json_encode($out,JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
} catch(Throwable $e){fwrite(STDERR,$e->getMessage()."\n");exit(1);}
