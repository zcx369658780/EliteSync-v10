<?php
namespace App\Services;
use App\Models\User;use Illuminate\Support\Facades\DB;use Illuminate\Support\Facades\Schema;use Illuminate\Support\Str;use Illuminate\Support\Carbon;
/** User locks -> activity -> grant/slots. Candidate discovery carries no authority. */
final class BuddyService {
 const LIVE=['DRAFT','OPEN','REQUESTED','CONFIRMED'];
 public function pref(int $id):object {return DB::table('buddy_preferences')->where('user_id',$id)->lockForUpdate()->first() ?? (object)['enabled'=>false,'revision'=>0];}
 private function users(array $ids):void {app(JourneyStore::class)->users(array_values(array_unique($ids)),true);}
 private function available(int $id):bool {return User::whereKey($id)->where('disabled',false)->where('account_status','active')->where('moderation_status','normal')->lockForUpdate()->exists();}
 private function slot(string $id,int $user,string $role):void {foreach(DB::table('buddy_activities')->whereIn('id',DB::table('buddy_slots')->where('user_id',$user)->select('activity_id'))->whereIn('state',self::LIVE)->where('end_at','<=',now())->orderBy('id')->lockForUpdate()->get() as $expired){$this->state($expired,'EXPIRED',null,'EXPIRED');}$slots=DB::table('buddy_slots')->where('user_id',$user)->orderBy('slot_number')->lockForUpdate()->pluck('slot_number')->all();foreach([1,2,3] as $n){if(!in_array($n,$slots)){DB::table('buddy_slots')->insert(['activity_id'=>$id,'user_id'=>$user,'role'=>$role,'slot_number'=>$n]);return;}}abort(409,'at most three unfinished Buddy activities');}
 private function audit(object $a,?int $actor,string $action):void {DB::table('buddy_audits')->insert(['activity_id'=>$a->id,'actor_id'=>$actor,'action'=>$action,'facts'=>json_encode(['state'=>$a->state,'revision'=>$a->revision]),'created_at'=>now(),'updated_at'=>now()]);}
 private function state(object $a, string $state, ?int $actor, string $action): void
 {
     $previous = $a->state;
     $a->state = $state;
     $a->revision++;
     DB::table('buddy_activities')->where('id', $a->id)->update(['state' => $state, 'revision' => $a->revision, 'updated_at' => now()]);
     if ($state !== 'OPEN') {
         DB::table('buddy_discovery_publications')->where('activity_id', $a->id)->where('state', 'PUBLISHED')
             ->update(['state' => 'WITHDRAWN', 'updated_at' => now()]);
     }
     if (!in_array($state, self::LIVE, true)) {
         $invited = DB::table('buddy_invitations')->where('activity_id', $a->id)->where('state', 'PENDING')
             ->whereNotNull('recipient_id')->pluck('recipient_id')->all();
         DB::table('buddy_slots')->where('activity_id', $a->id)->delete();
         DB::table('buddy_invitations')->where('activity_id', $a->id)->whereIn('state', ['PENDING', 'CONSUMED'])
             ->update(['state' => 'REVOKED', 'updated_at' => now()]);
     }
     $this->audit($a, $actor, $action);
     if ($previous !== $state) {
         foreach (array_unique(array_filter([$a->owner_id, $a->guest_id, ...($invited ?? [])])) as $recipient) {
             if ((int) $recipient !== $actor) $this->notify($a, (int) $recipient);
         }
     }
 }
 private function notify(object $a, int $to): void
 {
     app(NotificationService::class)->createForUser($to, 'buddy', '搭子状态有更新', '请在应用中查看当前有权状态',
         ['buddy_activity_id' => $a->id], sourceEventKey: 'buddy:'.$a->id.':'.$a->revision);
 }
 private function validInvite(object $i,object $a,int $peer):bool {
  if(!in_array($i->state,['PENDING','CONSUMED'],true)||$i->expires_at<=now()&&$i->state==='PENDING'||($i->recipient_id!==null&&(int)$i->recipient_id!==$peer)||!$this->available((int)$a->owner_id)||!$this->available($peer)||!app(SocialPolicy::class)->pairAllowed((int)$a->owner_id,$peer))return false;
  $o=$this->pref((int)$a->owner_id);$p=$this->pref($peer);if(!$o->enabled||!$p->enabled||(int)$i->owner_epoch!==(int)$o->revision||($i->recipient_epoch!==null&&(int)$i->recipient_epoch!==(int)$p->revision))return false;
  if ($i->kind === 'TOKEN') return true;
  if ($i->kind === 'DISCOVERY') {
      return $i->state === 'CONSUMED' && DB::table('buddy_discovery_publications')
          ->where('id', $i->discovery_publication_id)->where('activity_id', $a->id)
          ->where('state', 'CONSUMED')->where('consumed_by', $peer)->lockForUpdate()->exists();
  }
  return $i->kind === 'FRIEND' && DB::table('friendships')->where('id',$i->friendship_id)->where('revision',$i->friendship_revision)->where('user_a',min($a->owner_id,$peer))->where('user_b',max($a->owner_id,$peer))->where('state','ACTIVE')->lockForUpdate()->exists();
 }
 private function current(object $a):void {
  if(!in_array($a->state,self::LIVE,true))return;
  if(Carbon::parse($a->end_at)->isPast()){$this->state($a,'EXPIRED',null,'EXPIRED');return;}
  if(!$this->available((int)$a->owner_id)){$this->state($a,'CANCELLED',null,'ACCOUNT_UNAVAILABLE');return;}
  if($a->guest_id){$i=DB::table('buddy_invitations')->where('id',$a->source_invite_id)->lockForUpdate()->first();if(!$i||!$this->validInvite($i,$a,(int)$a->guest_id))$this->state($a,'WITHDRAWN',null,'SOURCE_REVOKED');}
 }
 private function card(object $a,int $actor):?array {
  $owner=(int)$a->owner_id===$actor;$guest=(int)$a->guest_id===$actor;
  $i=DB::table('buddy_invitations')->where('activity_id',$a->id)->where('recipient_id',$actor)->whereIn('state',['PENDING','CONSUMED'])->orderByDesc('created_at')->lockForUpdate()->first();
  $grant=!$owner&&$i&&$this->validInvite($i,$a,$actor)&&(!$a->guest_id||$guest);
  $history = !$owner && !$guest && !in_array($a->state, self::LIVE, true)
      && DB::table('buddy_invitations')->where('activity_id', $a->id)->where('recipient_id', $actor)->exists();
  if(!$owner&&!$guest&&!$grant&&!$history)return null;
  $out=['id'=>$a->id,'state'=>$a->state,'revision'=>(int)$a->revision,'allowed_actions'=>[]];
  if(!in_array($a->state,self::LIVE,true)||(!$owner&&!$grant))return $out;
  $out+=['owner_id'=>(int)$a->owner_id,'guest_id'=>$a->guest_id?(int)$a->guest_id:null,'type'=>$a->type,'subject'=>$a->subject,'general_city'=>$a->general_city,'place_kind'=>$a->place_kind,'budget_band'=>$a->budget_band,'start_at'=>$a->start_at,'end_at'=>$a->end_at];
  if($owner){$out['allowed_actions']=match($a->state){'DRAFT'=>['open','cancel'],'OPEN'=>['invite','token','revoke_token','cancel'],'REQUESTED'=>['confirm','decline','cancel','revoke_token'],'CONFIRMED'=>['withdraw','complete'],default=>[]};}
  elseif($grant){$out['allowed_actions']=match($a->state){'OPEN'=>['request','decline_invite'],'REQUESTED'=>['withdraw'],'CONFIRMED'=>['withdraw','complete'],default=>[]};}
  if ($owner) {
      $publication = DB::table('buddy_discovery_publications')->where('activity_id', $a->id)->orderByDesc('generation')->lockForUpdate()->first();
      $out['discovery'] = $publication ? ['publication_id' => (int) $publication->id, 'generation' => (int) $publication->generation,
          'state' => $publication->state, 'expires_at' => $publication->expires_at, 'author_label' => $publication->author_label] : null;
      $out['discovery_actions'] = [];
      if ($a->state === 'OPEN' && !$a->guest_id && $this->pref($actor)->enabled) {
          $published = $publication && $publication->state === 'PUBLISHED' && Carbon::parse($publication->expires_at)->isFuture();
          $out['discovery_actions'] = $published ? ['withdraw'] : ['publish'];
      }
  }
  $out['participation_source'] = $a->source_invite_id
      ? DB::table('buddy_invitations')->where('id', $a->source_invite_id)->value('kind') : null;
  return $out;
 }
 private function locked(int $actor,string $id,callable $work,array $extra=[]):array {
  $c=DB::table('buddy_activities')->where('id',$id)->first(['owner_id','guest_id']);abort_unless($c,404,'unavailable');
  return DB::transaction(function()use($actor,$id,$c,$work,$extra){$ids=array_values(array_filter([$actor,(int)$c->owner_id,$c->guest_id?(int)$c->guest_id:null,...$extra]));$this->users($ids);$a=DB::table('buddy_activities')->where('id',$id)->lockForUpdate()->first();abort_unless($a&&(int)$a->owner_id===(int)$c->owner_id&&($a->guest_id===null||(int)$a->guest_id===(int)$c->guest_id||in_array((int)$a->guest_id,$ids,true)),409,'participant changed; reread');$this->current($a);return $work($a);},3);
 }
 public function show(int $actor,string $id):array {return $this->locked($actor,$id,fn($a)=>$this->card($a,$actor)??abort(404,'unavailable'));}
 public function listing(int $actor):array {
  $ids=DB::table('buddy_activities')->where('owner_id',$actor)->orWhere('guest_id',$actor)->orWhereIn('id',DB::table('buddy_invitations')->where('recipient_id',$actor)->select('activity_id'))->orderByDesc('created_at')->limit(50)->pluck('id');$items=[];
  foreach($ids as $id){$v=$this->locked($actor,$id,fn($a)=>$this->card($a,$actor)??[]);if($v)$items[]=$v;}
  $pref=DB::transaction(function()use($actor){$this->users([$actor]);$p=$this->pref($actor);return ['enabled'=>(bool)$p->enabled,'revision'=>(int)$p->revision];});return ['preferences'=>$pref,'activities'=>$items];
 }
 public function preferences(int $actor,bool $enabled,int $revision):array {return DB::transaction(function()use($actor,$enabled,$revision){$this->users([$actor]);$p=$this->pref($actor);abort_unless((int)$p->revision===$revision,409,'stale revision');$next=$revision+((bool)$p->enabled!==$enabled?1:0);DB::table('buddy_preferences')->updateOrInsert(['user_id'=>$actor],['enabled'=>$enabled,'revision'=>$next,'created_at'=>now(),'updated_at'=>now()]);if(!$enabled){foreach(DB::table('buddy_activities')->whereIn('state',self::LIVE)->where(fn($q)=>$q->where('owner_id',$actor)->orWhere('guest_id',$actor))->orderBy('id')->lockForUpdate()->get() as $a)$this->state($a,'WITHDRAWN',$actor,'PREFERENCE_WITHDRAWAL');}return ['enabled'=>$enabled,'revision'=>$next];},3);}
 private function replay(int $actor,string $key,array $input,?object $a=null):?array {$old=DB::table('buddy_commands')->where('actor_id',$actor)->where('idempotency_key',$key)->lockForUpdate()->first();if(!$old)return null;abort_unless(hash_equals($old->fingerprint,hash('sha256',json_encode($input))),409,'idempotency conflict');abort_if($old->kind==='token',409,'token issued; revoke and request a new token if delivery was lost');$a??=DB::table('buddy_activities')->where('id',$old->activity_id)->lockForUpdate()->first();abort_unless($a&&(int)$a->revision===(int)$old->result_revision,409,'superseded command');return $this->card($a,$actor)??abort(404,'unavailable');}
 private function command(int $actor,string $key,array $input,object $a,string $kind):void {DB::table('buddy_commands')->insert(['actor_id'=>$actor,'idempotency_key'=>$key,'fingerprint'=>hash('sha256',json_encode($input)),'activity_id'=>$a->id,'result_revision'=>$a->revision,'kind'=>$kind,'created_at'=>now(),'updated_at'=>now()]);}
 public function create(int $actor,array $d):array {return DB::transaction(function()use($actor,$d){$this->users([$actor]);abort_unless($this->available($actor),404,'unavailable');$input=['create',$d];if($old=$this->replay($actor,$d['idempotency_key'],$input))return $old;$id=(string)Str::uuid();$a=(object)(array_diff_key($d,array_flip(['idempotency_key']))+['id'=>$id,'owner_id'=>$actor,'guest_id'=>null,'state'=>'DRAFT','revision'=>1,'source_invite_id'=>null,'created_at'=>now(),'updated_at'=>now()]);DB::table('buddy_activities')->insert((array)$a);$this->slot($id,$actor,'CREATOR');$this->audit($a,$actor,'CREATE');$this->command($actor,$d['idempotency_key'],$input,$a,'create');return $this->card($a,$actor);},3);}
 public function action(int $actor,string $id,string $action,int $revision,string $key):array {return $this->locked($actor,$id,function($a)use($actor,$action,$revision,$key){$input=[$a->id,$action,$revision];$card=$this->card($a,$actor);abort_unless($card,404,'unavailable');if($old=$this->replay($actor,$key,$input,$a))return $old;abort_unless($a->revision===$revision,409,'stale revision');abort_unless(in_array($action,$card['allowed_actions'],true),409,'action unavailable');
  if($action==='open'){abort_unless($this->pref($actor)->enabled,409,'enable Buddy requests first');$this->state($a,'OPEN',$actor,'OPEN');}
  elseif($action==='request'){$i=DB::table('buddy_invitations')->where('activity_id',$a->id)->where('recipient_id',$actor)->where('state','PENDING')->lockForUpdate()->first();abort_unless($i&&$this->validInvite($i,$a,$actor),404,'unavailable');$this->join($a,$i,$actor);}
  elseif($action==='decline_invite'){DB::table('buddy_invitations')->where('activity_id',$a->id)->where('recipient_id',$actor)->update(['state'=>'DECLINED','updated_at'=>now()]);$a->revision++;DB::table('buddy_activities')->where('id',$a->id)->update(['revision'=>$a->revision,'updated_at'=>now()]);$this->audit($a,$actor,'INVITE_DECLINED');}
  else{$next=match($action){'confirm'=>'CONFIRMED','decline'=>'DECLINED','withdraw'=>'WITHDRAWN','cancel'=>'CANCELLED','complete'=>'COMPLETED'};$this->state($a,$next,$actor,strtoupper($action));}
  $this->command($actor,$key,$input,$a,$action);$peer=$actor===(int)$a->owner_id?$a->guest_id:$a->owner_id;if($peer)$this->notify($a,(int)$peer);return $this->card($a,$actor)??['id'=>$a->id,'state'=>$a->state,'revision'=>$a->revision,'allowed_actions'=>[]];});}
 private function join(object $a,object $i,int $actor):void {abort_unless($a->state==='OPEN'&&!$a->guest_id&&(int)$a->owner_id!==$actor,409,'activity unavailable');$this->slot($a->id,$actor,'GUEST');DB::table('buddy_invitations')->where('id',$i->id)->update(['state'=>'CONSUMED','recipient_id'=>$actor,'recipient_epoch'=>$this->pref($actor)->revision,'updated_at'=>now()]);$a->guest_id=$actor;$a->source_invite_id=$i->id;DB::table('buddy_activities')->where('id',$a->id)->update(['guest_id'=>$actor,'source_invite_id'=>$i->id]);$this->state($a,'REQUESTED',$actor,'REQUEST');}
 public function invite(int $actor,string $id,int $peer,int $revision,string $key):array {return $this->locked($actor,$id,function($a)use($actor,$peer,$revision,$key){$input=[$a->id,'invite',$peer,$revision];abort_unless((int)$a->owner_id===$actor&&$peer!==$actor&&$this->available($peer)&&app(SocialPolicy::class)->pairAllowed($actor,$peer),404,'unavailable');$f=app(SocialPolicy::class)->friendship($actor,$peer);$o=$this->pref($actor);$p=$this->pref($peer);abort_unless($f&&$o->enabled&&$p->enabled,404,'unavailable');if($old=$this->replay($actor,$key,$input,$a))return $old;abort_unless($a->state==='OPEN'&&(int)$a->revision===$revision,409,'stale activity');abort_if(DB::table('buddy_invitations')->where('activity_id',$a->id)->where('recipient_id',$peer)->lockForUpdate()->exists(),409,'recipient already invited in this lifecycle');DB::table('buddy_invitations')->insert(['id'=>(string)Str::uuid(),'activity_id'=>$a->id,'kind'=>'FRIEND','recipient_id'=>$peer,'friendship_id'=>$f->id,'friendship_revision'=>$f->revision,'owner_epoch'=>$o->revision,'recipient_epoch'=>$p->revision,'state'=>'PENDING','expires_at'=>now()->addHours(48),'created_at'=>now(),'updated_at'=>now()]);$this->state($a,'OPEN',$actor,'FRIEND_INVITE');$this->command($actor,$key,$input,$a,'invite');$this->notify($a,$peer);return $this->card($a,$actor);},[$peer]);}
 public function token(int $actor,string $id,int $revision,string $key,bool $revoke=false):array {return $this->locked($actor,$id,function($a)use($actor,$revision,$key,$revoke){abort_unless((int)$a->owner_id===$actor,404,'unavailable');$input=[$a->id,$revoke?'revoke_token':'token',$revision];if($old=$this->replay($actor,$key,$input,$a))return $old;abort_unless(in_array($revoke?'revoke_token':'token',$this->card($a,$actor)['allowed_actions'],true)&&(int)$a->revision===$revision,409,'stale activity');$p=$this->pref($actor);abort_unless($p->enabled,404,'unavailable');DB::table('buddy_invitations')->where('activity_id',$a->id)->where('kind','TOKEN')->whereIn('state',['PENDING','CONSUMED'])->update(['state'=>'REVOKED','updated_at'=>now()]);if($revoke){if($a->source_invite_id)$this->current($a);if(in_array($a->state,self::LIVE,true))$this->state($a,$a->state,$actor,'TOKEN_REVOKED');$this->command($actor,$key,$input,$a,'revoke_token');return $this->card($a,$actor);}$raw=bin2hex(random_bytes(32));$until=now()->addHours(48);DB::table('buddy_invitations')->insert(['id'=>(string)Str::uuid(),'activity_id'=>$a->id,'kind'=>'TOKEN','owner_epoch'=>$p->revision,'token_hash'=>hash('sha256',$raw),'state'=>'PENDING','expires_at'=>$until,'created_at'=>now(),'updated_at'=>now()]);$this->state($a,'OPEN',$actor,'TOKEN_ISSUED');$this->command($actor,$key,$input,$a,'token');return ['token'=>$raw,'expires_at'=>$until->toIso8601String(),'activity'=>$this->card($a,$actor)];});}
 public function redeem(int $actor,string $raw,string $key):array {$i=DB::table('buddy_invitations')->where('token_hash',hash('sha256',$raw))->first(['id','activity_id']);abort_unless($i,404,'unavailable');return $this->locked($actor,$i->activity_id,function($a)use($i,$actor,$key,$raw){$grant=DB::table('buddy_invitations')->where('id',$i->id)->lockForUpdate()->first();abort_unless($grant&&$grant->state==='PENDING'&&$grant->expires_at>now()&&$this->validInvite($grant,$a,$actor),404,'unavailable');$input=[$a->id,'redeem',hash('sha256',$raw)];abort_if(DB::table('buddy_commands')->where('actor_id',$actor)->where('idempotency_key',$key)->exists(),409,'token replay');$this->join($a,$grant,$actor);$this->command($actor,$key,$input,$a,'redeem');$this->notify($a,(int)$a->owner_id);return $this->card($a,$actor);});}
 private function discoveryCard(object $a, object $publication, int $actor): ?array
 {
     if ($publication->state !== 'PUBLISHED' || !Carbon::parse($publication->expires_at)->isFuture()
         || $a->state !== 'OPEN' || $a->guest_id || !Carbon::parse($a->start_at)->isFuture()
         || (int) $a->owner_id === $actor || !$this->available($actor) || !$this->available((int) $a->owner_id)
         || !app(SocialPolicy::class)->pairAllowed($actor, (int) $a->owner_id)) return null;
     $owner = $this->pref((int) $a->owner_id);
     if (!$owner->enabled || (int) $owner->revision !== (int) $publication->owner_epoch || !$this->pref($actor)->enabled) return null;
     return ['publication_id' => (int) $publication->id, 'activity_id' => $a->id,
         'generation' => (int) $publication->generation, 'revision' => (int) $a->revision,
         'type' => $a->type, 'subject' => $a->subject, 'general_city' => $a->place_kind === 'ONLINE' ? '线上' : $a->general_city,
         'place_kind' => $a->place_kind, 'budget_band' => $a->budget_band,
         'start_at' => $a->start_at, 'end_at' => $a->end_at, 'expires_at' => $publication->expires_at,
         'author_label' => $publication->author_label, 'avatar' => null, 'available' => true];
 }

 public function discovery(int $actor, string $city, string $type, int $limit = 20, ?int $cursor = null): array
 {
     DB::transaction(function () use ($actor) {
         $this->users([$actor]);
         abort_unless($this->available($actor) && $this->pref($actor)->enabled, 403, 'enable Buddy first');
     });
     $candidates = DB::table('buddy_discovery_publications as p')->join('buddy_activities as a', 'a.id', '=', 'p.activity_id')
         ->where('p.state', 'PUBLISHED')->where('p.expires_at', '>', now())->where('a.state', 'OPEN')
         ->whereNull('a.guest_id')->where('a.owner_id', '<>', $actor)->where('a.type', $type)
         ->when($city === '线上', fn ($q) => $q->where('a.place_kind', 'ONLINE'),
             fn ($q) => $q->where('a.place_kind', '<>', 'ONLINE')->where('a.general_city', $city))
         ->when($cursor !== null, fn ($q) => $q->where('p.id', '<', $cursor))
         ->orderByDesc('p.id')->limit(201)->get(['p.id', 'p.activity_id']);
     $items = [];
     $scanned = 0;
     $last = $cursor;
     foreach ($candidates->take(200) as $candidate) {
         $scanned++;
         $last = (int) $candidate->id;
         $item = $this->locked($actor, $candidate->activity_id, function ($a) use ($actor, $candidate) {
             $publication = DB::table('buddy_discovery_publications')->where('id', $candidate->id)
                 ->where('activity_id', $a->id)->lockForUpdate()->first();
             return $publication ? ($this->discoveryCard($a, $publication, $actor) ?? []) : [];
         });
         if ($item) $items[] = $item;
         if (count($items) === $limit) break;
     }
     $more = $candidates->count() > $scanned;
     return ['items' => $items, 'next_cursor' => $more ? (string) $last : null, 'has_more' => $more];
 }

 public function publishDiscovery(int $actor, string $id, string $action, int $revision, string $key, ?string $label): array
 {
     return $this->locked($actor, $id, function ($a) use ($actor, $action, $revision, $key, $label) {
         abort_unless((int) $a->owner_id === $actor && $this->available($actor), 404, 'unavailable');
         $input = [$a->id, 'discovery_'.$action, $revision, $label];
         if ($old = $this->replay($actor, $key, $input, $a)) return $old;
         abort_unless((int) $a->revision === $revision, 409, 'stale activity');
         $latest = DB::table('buddy_discovery_publications')->where('activity_id', $a->id)->orderByDesc('generation')->lockForUpdate()->first();
         if ($action === 'publish') {
             abort_unless(trim((string) $label) !== '', 422, 'a public label is required');
             abort_unless($a->state === 'OPEN' && !$a->guest_id && $this->pref($actor)->enabled
                 && Carbon::parse($a->start_at)->isFuture(), 409, 'activity cannot be published');
             abort_if($latest && $latest->state === 'PUBLISHED' && Carbon::parse($latest->expires_at)->isFuture(), 409, 'already published');
             $privateText = $a->subject.' '.($a->place_kind === 'ONLINE' ? '' : $a->general_city).' '.$label;
             abort_if(preg_match('/https?:|www\.|@|\d{5,}|微信|電話|电话|手机号|身份证|住址|小区|楼|室|坐标|经纬|[路街巷弄号樓楼室住宅小區区]|[零一二三四五六七八九〇壹贰叁]{5,}|QQ|wechat|\b(?:street|road|avenue|apartment)\b/iu', $privateText), 422, 'public text contains private contacts or location');
             abort_unless($a->place_kind === 'ONLINE' || ($a->general_city && preg_match('/^[\p{L}\s]{2,40}$/u', $a->general_city)), 422, 'choose a coarse city or online');
             DB::table('buddy_discovery_publications')->where('activity_id', $a->id)->where('state', 'PUBLISHED')
                 ->update(['state' => 'WITHDRAWN', 'updated_at' => now()]);
             $until = now()->addHours(48)->min(Carbon::parse($a->start_at));
             DB::table('buddy_discovery_publications')->insert(['activity_id' => $a->id,
                 'generation' => (int) ($latest->generation ?? 0) + 1, 'owner_epoch' => $this->pref($actor)->revision,
                 'author_label' => $label, 'state' => 'PUBLISHED', 'published_at' => now(), 'expires_at' => $until,
                 'created_at' => now(), 'updated_at' => now()]);
         } else {
             abort_unless($latest && in_array($a->state, self::LIVE, true), 409, 'no current publication');
             // A consumed publication remains a participation source after discovery closes.
             DB::table('buddy_discovery_publications')->where('activity_id', $a->id)->where('state', 'PUBLISHED')
                 ->update(['state' => 'WITHDRAWN', 'updated_at' => now()]);
         }
         $this->state($a, $a->state, $actor, 'DISCOVERY_'.strtoupper($action));
         $this->command($actor, $key, $input, $a, 'discovery_'.$action);
         return $this->card($a, $actor);
     });
 }

 public function applyDiscovery(int $actor, int $publicationId, int $generation, int $revision, string $key): array
 {
     $candidate = DB::table('buddy_discovery_publications')->where('id', $publicationId)->first(['activity_id']);
     abort_unless($candidate, 404, 'unavailable');
     return $this->locked($actor, $candidate->activity_id, function ($a) use ($actor, $publicationId, $generation, $revision, $key) {
         abort_unless($this->available($actor) && $this->pref($actor)->enabled && $this->available((int) $a->owner_id)
             && app(SocialPolicy::class)->pairAllowed($actor, (int) $a->owner_id), 404, 'unavailable');
         $input = [$a->id, 'discovery_apply', $publicationId, $generation, $revision];
         $old = DB::table('buddy_commands')->where('actor_id', $actor)->where('idempotency_key', $key)->lockForUpdate()->first();
         if ($old) {
             abort_unless($old->kind === 'discovery_apply' && hash_equals($old->fingerprint, hash('sha256', json_encode($input))), 409, 'idempotency conflict');
             abort_unless((int) $a->guest_id === $actor && DB::table('buddy_invitations')->where('id', $a->source_invite_id)
                 ->where('kind', 'DISCOVERY')->where('discovery_publication_id', $publicationId)->lockForUpdate()->exists(), 404, 'unavailable');
             return $this->card($a, $actor) ?? abort(404, 'unavailable');
         }
         $publication = DB::table('buddy_discovery_publications')->where('id', $publicationId)->where('activity_id', $a->id)->lockForUpdate()->first();
         abort_unless($publication && $this->discoveryCard($a, $publication, $actor), 409, 'activity unavailable');
         abort_unless((int) $publication->generation === $generation && (int) $a->revision === $revision, 409, 'stale discovery card');
         abort_if(DB::table('buddy_commands')->where('actor_id', $actor)->where('kind', 'discovery_apply')
             ->where('created_at', '>', now()->subMinutes(10))->count() >= 5, 429, 'five discovery applications per ten minutes');
         $inviteId = (string) Str::uuid();
         DB::table('buddy_invitations')->insert(['id' => $inviteId, 'activity_id' => $a->id, 'kind' => 'DISCOVERY',
             'recipient_id' => $actor, 'owner_epoch' => $publication->owner_epoch, 'recipient_epoch' => $this->pref($actor)->revision,
             'discovery_publication_id' => $publicationId, 'state' => 'PENDING', 'expires_at' => $publication->expires_at,
             'created_at' => now(), 'updated_at' => now()]);
         DB::table('buddy_discovery_publications')->where('id', $publicationId)
             ->update(['state' => 'CONSUMED', 'consumed_by' => $actor, 'updated_at' => now()]);
         $invite = DB::table('buddy_invitations')->where('id', $inviteId)->lockForUpdate()->first();
         $this->join($a, $invite, $actor);
         $this->command($actor, $key, $input, $a, 'discovery_apply');
         return $this->card($a, $actor);
     });
 }

 public function adminWithdrawDiscovery(int $admin, int $publicationId, int $revision, string $reason): array
 {
     $candidate = DB::table('buddy_discovery_publications')->where('id', $publicationId)->first(['activity_id']);
     abort_unless($candidate, 404, 'unavailable');
     return $this->locked($admin, $candidate->activity_id, function ($a) use ($admin, $publicationId, $revision, $reason) {
         abort_unless(app(\App\Services\Accounts\AdminAccess::class)->allows(User::find($admin)), 403);
         abort_unless((int) $a->revision === $revision, 409, 'stale activity');
         $publication = DB::table('buddy_discovery_publications')->where('id', $publicationId)->where('activity_id', $a->id)->lockForUpdate()->first();
         abort_unless($publication, 404, 'unavailable');
         $before = $publication->state;
         if ($before === 'PUBLISHED') {
             DB::table('buddy_discovery_publications')->where('id', $publicationId)->update(['state' => 'ADMIN_REMOVED', 'updated_at' => now()]);
             $this->state($a, $a->state, $admin, 'DISCOVERY_ADMIN_WITHDRAW');
         }
         app(\App\Services\Admin\OperationAudit::class)->record($admin, 'buddy.discovery_withdraw', 'buddy_discovery', (string) $publicationId,
             $reason, $revision, ['publication_state' => $before], ['publication_state' => $before === 'PUBLISHED' ? 'ADMIN_REMOVED' : $before]);
         return ['publication_id' => $publicationId, 'participation_state' => $a->state];
     });
 }

 public function revokePair(int $a,int $b,bool $friendOnly=false):void {if(!Schema::hasTable('buddy_activities'))return;$q=DB::table('buddy_invitations')->whereIn('state',['PENDING','CONSUMED'])->whereIn('activity_id',DB::table('buddy_activities')->where('owner_id',$a)->select('id'))->where('recipient_id',$b);$q2=DB::table('buddy_invitations')->whereIn('state',['PENDING','CONSUMED'])->whereIn('activity_id',DB::table('buddy_activities')->where('owner_id',$b)->select('id'))->where('recipient_id',$a);$ids=$q->when($friendOnly,fn($q)=>$q->where('kind','FRIEND'))->pluck('id')->merge($q2->when($friendOnly,fn($q)=>$q->where('kind','FRIEND'))->pluck('id'));DB::table('buddy_invitations')->whereIn('id',$ids)->update(['state'=>'REVOKED','updated_at'=>now()]);foreach(DB::table('buddy_activities')->whereIn('state',self::LIVE)->whereIn('source_invite_id',$ids)->orderBy('id')->lockForUpdate()->get() as $row)$this->state($row,'WITHDRAWN',null,$friendOnly?'FRIENDSHIP_REMOVED':'PAIR_BLOCKED');}
 public function revokeUser(int $id):void {if(!Schema::hasTable('buddy_activities'))return;foreach(DB::table('buddy_activities')->whereIn('state',self::LIVE)->where(fn($q)=>$q->where('owner_id',$id)->orWhere('guest_id',$id))->orderBy('id')->lockForUpdate()->get() as $a)$this->state($a,'CANCELLED',null,'ACCOUNT_REVOKED');DB::table('buddy_invitations')->where('recipient_id',$id)->update(['state'=>'REVOKED','updated_at'=>now()]);}
}
