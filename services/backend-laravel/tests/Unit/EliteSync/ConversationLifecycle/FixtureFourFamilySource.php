<?php
declare(strict_types=1);
namespace EliteSyncConversationLifecycleFixture;
use App\Domain\CommonAuthorityEvidenceContract as Common;
use App\EliteSync\TextAuthority\ExistingEvaluatorEvidenceAdapter as Adapter;
use App\EliteSync\ConversationQualification\ConversationQualificationSource;
use RuntimeException;
/** Fixture control plane only. Configured source data never derives grants from a read request. */
final class FixtureFourFamilySource implements ConversationQualificationSource
{
 private array $bundle=[];
 private bool $throw=false;
 private mixed $hook=null;
 private int $reads=0;
 public function __construct() { $this->configure('fiction-a','cv-a'); }
 public static function profiles():array {
  return ['identity'=>['authority_owner'=>'TEST_IDENTITY_AUTHORITY','authority_scope'=>'TEXT_TEST_SESSION','source_id'=>'fixture-identity','lineage'=>'identity:session-pair'],
   'connection'=>['authority_owner'=>'TEST_PRODUCT_CONNECTION_AUTHORITY','authority_scope'=>'TEXT_TEST_CONNECTION','source_id'=>'fixture-cn','lineage'=>'cn:cn-a'],
   'read_consent'=>['authority_owner'=>'TEST_MESSAGING_CONSENT_AUTHORITY','authority_scope'=>'CONVERSATION_LIVE_READ','source_id'=>'fixture-read','lineage'=>'mc:read-a'],
   'send_consent'=>['authority_owner'=>'TEST_MESSAGING_CONSENT_AUTHORITY','authority_scope'=>'CONVERSATION_LIVE_SEND','source_id'=>'fixture-send','lineage'=>'mc:send-a']];
 }
 public static function ids():array { return ['identity'=>'session-pair','connection'=>'cn-a','read_consent'=>'read-a','send_consent'=>'send-a']; }
 public static function revision(string $family):array { $p=self::profiles()[$family];return ['authority_owner'=>$p['authority_owner'],'authority_scope'=>$p['authority_scope'],'lineage'=>$p['lineage'],'aggregate_context'=>self::ids()[$family],'value'=>7]; }
 /** Explicit trusted fixture setup, never invoked by readAtUsePoint. */
 public function configure(string $actor,string $cvId):void {
  $out=[];foreach(self::ids() as $family=>$id) {
   $p=self::profiles()[$family];$r=['id'=>$id,'participants'=>['fiction-a','fiction-b'],'audience'=>'fixture-audience','revision'=>self::revision($family),'condition'=>'PRESENT','current'=>true,'fresh'=>true];
   if($family==='identity') {
    $r['active']=true;$binding=['authority_owner'=>$p['authority_owner'],'authority_scope'=>$p['authority_scope'],'actor'=>$actor,'actor_role'=>'FIXTURE_CONTRACT_PARTICIPANT','subject'=>$actor,'participants'=>['fiction-a','fiction-b'],'audience'=>'fixture-audience','purpose'=>$p['authority_scope'],'aggregate_context'=>$id,'lifecycle_identity'=>$id,'terminal'=>false];
    $e=Common::evidence($binding,'PRESENT',self::revision($family),true,true,'COMMITTED');
   }else{
    $r+=['requester'=>'fiction-a','recipient'=>'fiction-b','last_actor'=>'fiction-b','paused_by'=>null,'purpose'=>$p['authority_scope'],'connection_id'=>$family==='connection'?null:'cn-a','state'=>$family==='connection'?'CN_ACTIVE':'MC_ACTIVE'];
    $e=Adapter::evidence($r,$family==='connection')['source_evidence'];
   }
   $out[$family]=['record'=>$r,'evidence'=>$e,'provenance'=>['source_id'=>$p['source_id'],'session'=>'session-pair','connection_id'=>'cn-a','conversation_id'=>$cvId]];
  }
  $out['conversation']=null;$this->bundle=$out;
 }
 public function setBundle(array $bundle):void {$this->bundle=$bundle;}
 public function snapshot():array {return $this->bundle;}
 public function throwOnRead(bool $flag):void {$this->throw=$flag;}
 public function setReadHook(?callable $hook):void {$this->hook=$hook;}
 public function callCount():int {return $this->reads;}
 public function readAtUsePoint(array $request):array { $this->reads++;if($this->throw)throw new RuntimeException('FICTIONAL_SOURCE_READ_FAILED');$h=$this->hook;$this->hook=null;if($h!==null)$h();return $this->bundle; }
}
