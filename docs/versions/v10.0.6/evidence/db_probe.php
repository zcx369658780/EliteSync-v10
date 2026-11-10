<?php
require getcwd().'/vendor/autoload.php';
$app = require getcwd().'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if (! $app->environment('local') || Illuminate\Support\Facades\DB::connection()->getDatabaseName() !== 'elitesync_v1006_dev'
    || config('database.connections.mysql.host') !== '127.0.0.1' || (int) config('database.connections.mysql.port') !== 43316) {
    throw new RuntimeException('Dedicated database identity mismatch');
}
$users=App\Models\User::query()->where('generation_version','v10.0.6')->orderBy('id')
    ->get(['id','name','role','city','disabled','moderation_status','generation_version','account_type','is_synthetic']);
if ($users->count() !== 3 || App\Models\User::count() !== 3) throw new RuntimeException('Unexpected account scope');
echo json_encode(['time'=>gmdate(DATE_ATOM),'database'=>'elitesync_v1006_dev','port'=>43316,
    'users'=>$users,'astro_rows'=>Illuminate\Support\Facades\DB::table('user_astro_profiles')->count(),
    'migration_rows'=>Illuminate\Support\Facades\DB::table('migrations')->count(),
    'target_token_count'=>Illuminate\Support\Facades\DB::table('personal_access_tokens')->where('tokenable_id',2)->count(),
    'target_session_count'=>Illuminate\Support\Facades\DB::table('sessions')->where('user_id',2)->count()],JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
