<?php
require __DIR__.'/runtime_bootstrap.php';
use Illuminate\Support\Facades\DB;
$s=json_decode(file_get_contents(__DIR__.'/subjects.private.json'),true);$id=$s['users']['Incomplete']['id'];
DB::beginTransaction();DB::table('users')->where('id',$id)->lockForUpdate()->first();file_put_contents(__DIR__.'/app-late2-held','owned synthetic row locked');
$t=microtime(true)+120;while(!file_exists(__DIR__.'/app-late2-release')&&microtime(true)<$t){usleep(50000);}DB::commit();file_put_contents(__DIR__.'/app-late2-released','released');echo 'read-only user lock released';
