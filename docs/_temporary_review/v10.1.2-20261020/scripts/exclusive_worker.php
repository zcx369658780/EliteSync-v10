<?php
require __DIR__.'/runtime_bootstrap.php';
$role=$argv[1];$f=json_decode(file_get_contents(__DIR__.'/race-exclusive.private.json'),true);
$r=$role==='viewer'?$f['relationship']:$f['relationship2'];
try {
 $result=app(App\Services\FormalRelationshipService::class)->action($f[$role]['id'],$r['id'],'confirm',$r['revision'],'exclusive-'.$role);
 echo json_encode(['role'=>$role,'status'=>200,'state'=>$result['state']]);
} catch(Symfony\Component\HttpKernel\Exception\HttpException $e) { echo json_encode(['role'=>$role,'status'=>$e->getStatusCode(),'message'=>$e->getMessage()]); }
catch(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);}
