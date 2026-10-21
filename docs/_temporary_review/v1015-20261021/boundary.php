<?php
require getenv('V1015_BACKEND_ROOT').'/tests/Integration/v1015/runtime.php';
$input=json_decode(trim(fgets(STDIN)),true,512,JSON_THROW_ON_ERROR);
$family=$db->table('device_sessions')->where('id',$input['session_id'])->where('user_id',3)->first();
if (!$family || !str_starts_with($family->device_id,'v1015-boundary-')) throw new RuntimeException('OWNED_BOUNDARY_FIXTURE_REQUIRED');
$anchor=now('UTC')->startOfSecond()->subSeconds((int)$input['age_seconds']);
$db->table('device_sessions')->where('id',$family->id)->update(['trusted_login_at'=>$anchor]);
echo json_encode(['class'=>'TEST_ONLY_PERSISTED_TIME_FIXTURE','login_at'=>$anchor->toISOString(),'server_now'=>now('UTC')->toISOString()],JSON_THROW_ON_ERROR).PHP_EOL;
