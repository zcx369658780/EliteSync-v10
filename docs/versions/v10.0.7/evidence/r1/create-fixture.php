<?php
try {
$root=$argv[1];require $root.'/vendor/autoload.php';$app=require $root.'/bootstrap/app.php';$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if(!app(App\Services\LiveConsentService::class)->enabled())throw new RuntimeException('R1 isolation gate denied');
$c=json_decode(file_get_contents(env('V1007_CREDENTIALS_FILE')),true);
$result=Illuminate\Support\Facades\DB::transaction(function()use($c){
$users=[];foreach(['r1sender'=>'19900000709','r1recipient'=>'19900000710'] as$role=>$phone){if(App\Models\User::where('phone',$phone)->exists())throw new RuntimeException('Preserve existing R1 fixture');
$u=App\Models\User::create(['phone'=>$phone,'password'=>Illuminate\Support\Facades\Hash::make($c['accounts']['bob']['password']),'name'=>'V1007 R1 Fictional '.$role,'role'=>'user','gender'=>$role==='r1sender'?'male':'female','city'=>'V1007 R1 City','birthday'=>'1992-06-10','account_type'=>'test','generation_version'=>'v10.0.7','is_synthetic'=>false,'disabled'=>false]);$users[$role]=$u->id;}
$m=App\Models\DatingMatch::create(['week_tag'=>'v1007-r1-notify','user_a'=>$users['r1sender'],'user_b'=>$users['r1recipient'],'drop_released'=>true]);return ['users'=>$users,'match_id'=>$m->id,'purpose'=>'R1 notification current-permission fixture; not a new matching consumer claim'];});
echo json_encode($result,JSON_PRETTY_PRINT|JSON_THROW_ON_ERROR);

} catch (Throwable $e) { fwrite(STDERR,"R1 fixture failed: ".get_class($e)."\n"); exit(1); }
