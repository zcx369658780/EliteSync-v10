<?php
declare(strict_types=1);
// Synthetic integration bootstrap only. Production never loads this file.
function qualifyFinalRtcTask($app): array {
    if (getenv('TASK_ID') !== 'V1015_FINAL_DEVICE_RTC_WS_H264_GATE_20261031'
        || !$app->environment('local') || !config('restoration.enabled')
        || config('database.default') !== 'mysql') throw new RuntimeException('Task environment gate');
    $db=Illuminate\Support\Facades\DB::connection();
    foreach (['host'=>'v1015-finalrtc-db','port'=>55418,'database'=>'finalrtc_synthetic','username'=>'finalrtc_app'] as $key=>$expected) {
        if ((string)$db->getConfig($key)!==(string)$expected) throw new RuntimeException('Connection identity gate: '.$key);
    }
    if ($db->getConfig('url') || $db->getConfig('unix_socket')) throw new RuntimeException('Alternate connection gate');
    $identity=$db->selectOne('select database() as db, @@port as port, @@server_id as server_id, current_user() as actor');
    if ($identity->db!=='finalrtc_synthetic' || (int)$identity->port!==55418 || (int)$identity->server_id!==273104318
        || $identity->actor!=='finalrtc_app@%') throw new RuntimeException('Effective instance gate');
    $grants=$db->select('SHOW GRANTS');
    if (count($grants)!==2) throw new RuntimeException('Grant cardinality gate');
    foreach ($grants as $row) {
        $grant=array_values((array)$row)[0];
        if (str_contains($grant,'WITH GRANT OPTION') ||
            (!str_starts_with($grant,'GRANT USAGE ON *.* TO `finalrtc_app`@`%`') &&
             $grant!=='GRANT ALL PRIVILEGES ON `finalrtc\_synthetic`.* TO `finalrtc_app`@`%`')) throw new RuntimeException('Grant scope gate');
    }
    $app->instance('restoration.private-instance-qualified', static fn()=>true);
    return (array)$identity;
}
