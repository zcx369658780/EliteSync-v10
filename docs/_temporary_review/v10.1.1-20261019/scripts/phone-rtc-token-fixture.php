<?php
$root=$argv[1];$mode=$argv[2];require $root.'/vendor/autoload.php';$app=require $root.'/bootstrap/app.php';$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
$db=Illuminate\Support\Facades\DB::connection();if($db->getDatabaseName()!=='elitesync_v10_1_1_dev'||(int)$db->getConfig('port')!==43322)throw new RuntimeException('WRONG_DB');
$call=App\Models\RtcSession::findOrFail(14);if(!in_array((int)$call->initiator_user_id,[2,3],true)||!in_array((int)$call->peer_user_id,[2,3],true))throw new RuntimeException('WRONG_FICTIONAL_PAIR');
try {
    $join=app(App\Services\LiveKitTokenService::class)->issueJoinInfo($call,App\Models\User::findOrFail(2));
    if($mode!=='before')throw new RuntimeException('POST_BLOCK_JOIN_WAS_ALLOWED');
    file_put_contents(__DIR__.'/secrets/phone-rtc-old-join.json',json_encode($join));echo 'OFFICIAL_ISSUER_CONTROLLED_PRE_REVOCATION_JWT_SAVED';
}catch(Symfony\Component\HttpKernel\Exception\HttpException $error){
    if($mode!=='after'||$error->getStatusCode()!==404)throw $error;
    echo 'POST_BLOCK_OFFICIAL_NEW_JOIN_REJECTED_404';
}
