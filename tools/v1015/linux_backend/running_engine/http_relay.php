<?php
declare(strict_types=1);
$dir='/app/storage/app/task-http-queue';
$generation=$argv[2]??'1'; if(!in_array($generation,['1','2'],true))throw new RuntimeException('Task relay generation');
$stop='/app/storage/app/task-http-relay-'.$generation.'.stop';
$expires=(int)$argv[1];
while(time()<$expires && !is_file($stop)) {
    foreach(glob($dir.'/*.request.json') as $file) {
        $reply=str_replace('.request.json','.response.json',$file);
        if(is_file($reply))continue;
        try {
            $v=json_decode(file_get_contents($file),true,512,JSON_THROW_ON_ERROR);
            if(!is_string($v['path'])||!str_starts_with($v['path'],'/')||str_starts_with($v['path'],'//')||str_contains($v['path'],"\r")||str_contains($v['path'],"\n"))throw new RuntimeException('Local path required');
            $c=curl_init('http://127.0.0.1:8081'.$v['path']);$headers=[];
            curl_setopt_array($c,[CURLOPT_CUSTOMREQUEST=>$v['method'],CURLOPT_RETURNTRANSFER=>true,CURLOPT_FOLLOWLOCATION=>false,CURLOPT_CONNECTTIMEOUT=>3,CURLOPT_TIMEOUT=>35,CURLOPT_PROXY=>'',CURLOPT_PROTOCOLS=>CURLPROTO_HTTP,
                CURLOPT_HTTPHEADER=>$v['headers'],CURLOPT_HEADERFUNCTION=>static function($c,$s)use(&$headers){$headers[]=rtrim($s,"\r\n");return strlen($s);}]);
            if($v['body_b64']!==null)curl_setopt($c,CURLOPT_POSTFIELDS,base64_decode($v['body_b64'],true));
            $body=curl_exec($c);if($body===false)throw new RuntimeException('Loopback curl '.curl_errno($c));
            $out=['status'=>curl_getinfo($c,CURLINFO_RESPONSE_CODE),'headers'=>$headers,'body_b64'=>base64_encode($body)];curl_close($c);
        } catch(Throwable $e) { $out=['error'=>get_class($e).': '.$e->getMessage()]; }
        file_put_contents($reply.'.partial',json_encode($out,JSON_THROW_ON_ERROR),LOCK_EX);rename($reply.'.partial',$reply);
    }
    usleep(20000);
}
