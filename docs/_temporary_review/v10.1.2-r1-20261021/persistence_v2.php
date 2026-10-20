<?php
require __DIR__.'/runtime_bootstrap.php';use Illuminate\Support\Facades\DB;
set_exception_handler(function(Throwable $e){fwrite(STDERR,get_class($e).':'.$e->getMessage());exit(1);});
$tables=['formal_relationships','privacy_preferences','journey_audits','journey_commands','match_proposals','match_proposal_slots','matching_participations','product_connections','messaging_consents'];$out=[];
foreach($tables as $t){$rows=DB::table($t)->get()->map(fn($r)=>json_encode($r))->all();sort($rows);$out[$t]=['rows'=>count($rows),'sha256'=>hash('sha256',json_encode($rows))];}echo json_encode($out,JSON_PRETTY_PRINT);
