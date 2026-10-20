<?php
require __DIR__.'/runtime_bootstrap.php';
use Illuminate\Support\Facades\DB;
$result=['database'=>DB::connection()->getDatabaseName(),'isolation'=>DB::selectOne('SELECT @@tx_isolation level')->level,'tables'=>[]];
foreach(['matching_participations','match_proposals','match_proposal_slots','formal_relationships','formal_relationship_slots','privacy_preferences','identity_assertions','dating_rounds','dating_round_channels','dating_round_user_states','matching_runs','matching_run_candidates','journey_commands','journey_audits'] as $table){
 $rows=DB::table($table)->get()->map(fn($r)=>json_encode($r,JSON_UNESCAPED_UNICODE))->all();sort($rows,SORT_STRING);$result['tables'][$table]=['rows'=>count($rows),'values_sha256'=>hash('sha256',json_encode($rows,JSON_UNESCAPED_UNICODE))];
}
echo json_encode($result,JSON_PRETTY_PRINT);
