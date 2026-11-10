<?php
// Explicit fictional session fixture; never grants an ordinary user admin access.
require getcwd().'/vendor/autoload.php';
$app=require getcwd().'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();
if (! $app->environment('local') || config('database.connections.mysql.host') !== '127.0.0.1'
    || (int) config('database.connections.mysql.port') !== 43316
    || Illuminate\Support\Facades\DB::connection()->getDatabaseName() !== 'elitesync_v1006_dev') {
    throw new RuntimeException('Dedicated local database required');
}
$user=App\Models\User::where('phone','19900000602')->where('generation_version','v10.0.6')->firstOrFail();
if ($user->role !== 'user' || $user->disabled) throw new RuntimeException('Active fictional ordinary user required');
$privatePath=__DIR__.'/secrets/target_web_session.json';
if (false && file_exists($privatePath)) {
    $previous=json_decode(file_get_contents($privatePath),true,flags:JSON_THROW_ON_ERROR);
    $id=Illuminate\Cookie\CookieValuePrefix::remove($app['encrypter']->decrypt($previous['value'],false));
} else {
    $session=$app['session']->driver();
    $session->start();
    $app['auth']->guard('web')->login($user);
    $session->save();
    $id=$session->getId();
    $name=config('session.cookie');
    $plain=Illuminate\Cookie\CookieValuePrefix::create($name,$app['encrypter']->getKey()).$id;
    $cookie=$app['encrypter']->encrypt($plain,false);
    file_put_contents($privatePath,json_encode(['name'=>$name,'value'=>$cookie]));
}
// CLI fixture setup does not run HTTP guard resolution. Explicitly associate
// this owned fixture row, so the shared disable action exercises real SQL deletion.
Illuminate\Support\Facades\DB::table('sessions')->where('id',$id)->update(['user_id'=>$user->id]);
echo json_encode(['fixture'=>'ordinary target persistent session','user_id'=>$user->id,
    'sessions'=>Illuminate\Support\Facades\DB::table('sessions')->where('user_id',$user->id)->count(),
    'admin_access'=>app(App\Services\Accounts\AdminAccess::class)->allows($user)],JSON_PRETTY_PRINT);
