<?php
// Task-only bootstrap; never deployed or registered by application code.
function qualifyPostL13Task($app): void {
    if (getenv('TASK_ID') !== 'V1015_POST_L13_F1_F3_F4_E2E_20261031'
        || !$app->environment('local') || !config('restoration.enabled')
        || config('database.default') !== 'mysql') { throw new RuntimeException('Task identity gate'); }
    $db=Illuminate\Support\Facades\DB::connection();
    foreach (['host'=>'v1015-prod31-db','port'=>55363,'database'=>'postl13_synthetic','username'=>'prod31_app'] as $k=>$v) {
        if ((string)$db->getConfig($k)!==(string)$v) throw new RuntimeException('Connection identity gate: '.$k);
    }
    if ($db->getConfig('url') || $db->getConfig('unix_socket')) throw new RuntimeException('Alternate connection gate');
    $i=$db->selectOne('select database() as db, @@port as port, @@server_id as sid, current_user() as actor');
    if ($i->db!=='postl13_synthetic' || (int)$i->port!==55363 || (int)$i->sid!==230741380 || !str_starts_with($i->actor,'prod31_app@')) throw new RuntimeException('Live identity gate');
    $grants=$db->select('SHOW GRANTS');
    if (count($grants)!==2) throw new RuntimeException('Unexpected grants');
    foreach ($grants as $row) {
        $grant=array_values((array)$row)[0];
        if (str_contains($grant,'WITH GRANT OPTION')) throw new RuntimeException('Grant option gate');
        if (!str_starts_with($grant,'GRANT USAGE ON *.* TO `prod31_app`@`%`') && $grant!=='GRANT ALL PRIVILEGES ON `postl13\_synthetic`.* TO `prod31_app`@`%`') throw new RuntimeException('Grant scope gate');
    }
    $app->instance('restoration.private-instance-qualified', static fn()=>true);
}
