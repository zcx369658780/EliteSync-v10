<?php
use Illuminate\Contracts\Http\Kernel;
use Illuminate\Support\Facades\DB;
$root='<WORKTREE>/services/backend-laravel';
require $root.'/vendor/autoload.php';$app=require $root.'/bootstrap/app.php';$app->make(Kernel::class)->bootstrap();
$db=DB::connection();
if(!$app->environment('local') || $db->getDriverName()!=='mysql' || $db->getDatabaseName()!=='elitesync_v10_1_1_dev' || $db->getConfig('host')!=='127.0.0.1' || (int)$db->getConfig('port')!==43322 || $db->getConfig('unix_socket')){throw new RuntimeException('guard');}
$t=json_decode(file_get_contents(__DIR__.'/secrets/app-product-target.json'),true);$p=$t['post_id'];
$c=json_decode(file_get_contents(__DIR__.'/secrets/app-target.json'),true);
$events=DB::table('app_events')->where('actor_user_id',$c['viewer_id'])->whereIn('event_name',['status_post_like','status_post_unlike'])->get()->filter(fn($r)=>(int)(json_decode($r->payload,true)['status_post_id']??0)===$p);
$notices=DB::table('notifications')->where('user_id',$c['owner_id'])->where('kind','status_like')->get()->filter(fn($r)=>(int)(json_decode($r->payload,true)['status_post_id']??0)===$p);
$out=['likes'=>DB::table('status_post_likes')->where('status_post_id',$p)->count(),'events'=>$events->pluck('event_name')->values()->all(),'notifications'=>$notices->count(),'audience'=>DB::table('status_posts')->where('id',$p)->value('audience')];
echo json_encode($out)."\n";
$rounds=($argv[1]??'')==='b'?2:1;
// Repeated likes within the product's five-minute window reuse the same notice.
if($out!==['likes'=>0,'events'=>array_merge(...array_fill(0,$rounds,['status_post_like','status_post_unlike'])),'notifications'=>1,'audience'=>'SELF']){fwrite(STDERR,"unauthorized effect or missing APP effects\n");exit(1);}
