<?php
use App\Models\User;
use Illuminate\Contracts\Http\Kernel;
use Illuminate\Support\Facades\DB;
$root = '<WORKTREE>/services/backend-laravel';
require $root.'/vendor/autoload.php';
$app = require $root.'/bootstrap/app.php';
$app->make(Kernel::class)->bootstrap();
$db = DB::connection();
if (!$app->environment('local') || $db->getDriverName() !== 'mysql' || $db->getDatabaseName() !== 'elitesync_v10_1_1_dev' || $db->getConfig('host') !== '127.0.0.1' || (int)$db->getConfig('port') !== 43322 || $db->getConfig('unix_socket')) { throw new RuntimeException('guard'); }
$suite=json_decode(file_get_contents(__DIR__.'/secrets/final-suite.json'),true);
$c=array_values(array_filter($suite['cases'],fn($c)=>$c['label']==='positive-none-media'))[0];
$u=User::findOrFail($c['viewer_id']);
if (!$u->is_synthetic || $u->synthetic_batch !== $c['batch']) { throw new RuntimeException('registered synthetic fixture required'); }
$password=bin2hex(random_bytes(16));
$u->password=$password; $u->save();
file_put_contents(__DIR__.'/secrets/accounts.json',json_encode(['accounts'=>['r1'=>['phone'=>$u->phone,'password'=>$password]]]));
file_put_contents(__DIR__.'/secrets/app-target.json',json_encode($c));
echo json_encode(['registered_synthetic_viewer'=>true,'post_id'=>$c['post_id'],'owner_id'=>$c['owner_id'],'viewer_id'=>$c['viewer_id']])."\n";
