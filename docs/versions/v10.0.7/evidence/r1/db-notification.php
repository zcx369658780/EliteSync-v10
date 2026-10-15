<?php
try {
$root=$argv[1];require $root.'/vendor/autoload.php';$app=require $root.'/bootstrap/app.php';$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if(!app(App\Services\LiveConsentService::class)->enabled())throw new RuntimeException('R1 isolation gate denied');
$r=['notifications'=>Illuminate\Support\Facades\DB::table('notifications')->where('id',10)->get(['id','user_id','title','body','payload','read_at']), 'connections'=>Illuminate\Support\Facades\DB::table('product_connections')->where('match_id',5)->get(), 'consents'=>Illuminate\Support\Facades\DB::table('messaging_consents')->where('connection_id',4)->get(), 'users'=>App\Models\User::whereIn('id',[11,12])->get(['id','name','disabled'])];echo json_encode($r,JSON_PRETTY_PRINT|JSON_UNESCAPED_UNICODE|JSON_THROW_ON_ERROR);
} catch (Throwable $e) { fwrite(STDERR,'R1 database evidence failed');exit(1); }
