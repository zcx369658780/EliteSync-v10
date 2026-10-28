<?php
declare(strict_types=1);
// Standalone offline tests: no Laravel bootstrap, autoloader, database or network.
require __DIR__.'/../../app/Domain/MessagingReplayContract.php';
require __DIR__.'/../../app/Domain/TrustedLoginTimeContract.php';
require __DIR__.'/../../app/Domain/NotificationDeliveryContract.php';
use App\Domain\MessagingReplayContract as M;
use App\Domain\TrustedLoginTimeContract as T;
use App\Domain\NotificationDeliveryContract as N;
$count=0;
function check(bool $ok,string $name): void {global $count; $count++; if(!$ok)throw new RuntimeException($name);}
function rejects(callable $fn,string $name): void {try{$fn();}catch(InvalidArgumentException){check(true,$name);return;}check(false,$name);}
$f=M::fingerprint(2,'synthetic message',[11,12]);
check($f===M::fingerprint(2,'synthetic message',[11,12]),'same immutable payload');
check($f!==M::fingerprint(2,'changed',[11,12]),'content bound');
check($f!==M::fingerprint(3,'synthetic message',[11,12]),'receiver bound');
check($f!==M::fingerprint(2,'synthetic message',[12,11]),'attachment order bound');
check(M::replayDecision(1,2,1,2,$f,$f,true)==='REPLAY','authorized same payload');
check(M::replayDecision(1,2,1,2,$f,$f,false)==='UNAVAILABLE','revocation before replay');
check(M::replayDecision(1,2,9,2,$f,$f,true)==='UNAVAILABLE','cross-account replay');
check(M::replayDecision(1,2,1,3,$f,$f,true)==='CONFLICT','peer cannot change');
check(M::replayDecision(1,2,1,2,$f,str_repeat('0',64),true)==='CONFLICT','same key other payload');
rejects(fn()=>M::fingerprint(0,'x',[]),'invalid receiver');
$now=new DateTimeImmutable('2026-10-28T00:00:00Z');
check(T::deadline('2026-10-20 00:00:00',$now)->format('c')==='2026-11-04T00:00:00+00:00','fixed login deadline');
check(T::deadline('2026-10-20T08:00:00+08:00',$now)->getTimestamp()===T::deadline('2026-10-20T00:00:00Z',$now)->getTimestamp(),'absolute timezone normalized');
check(T::deadline('2026-10-20T00:00:00Z',$now)->getTimestamp()===T::deadline('2026-10-20T00:00:00Z',$now->modify('+1 day'))->getTimestamp(),'refresh now cannot extend anchor');
rejects(fn()=>T::deadline('', $now),'missing time');
rejects(fn()=>T::deadline('tomorrow', $now),'relative time rejected');
rejects(fn()=>T::deadline('2026-02-30 00:00:00', $now),'normalized invalid date rejected');
rejects(fn()=>T::deadline('2026-10-29T00:00:00Z', $now),'future login rejected');
check(N::category('rtc_invite')==='rtc','rtc category');
check(N::category('status_comment')==='status','status category');
check(N::preferences(['message'=>false,'safety_case'=>true,'unknown'=>true])['message']===false,'category denied');
check(!array_key_exists('unknown',N::preferences(['unknown'=>true])),'category allowlist');
check(N::mayAttempt(true,true,true,false,true,true),'current eligible notification');
foreach([[false,true,true,false,true,true],[true,false,true,false,true,true],[true,true,false,false,true,true],[true,true,true,true,true,true],[true,true,true,false,false,true],[true,true,true,false,true,false]] as $claims) check(!N::mayAttempt(...$claims),'deny one failed current guard');
$envelope=N::envelope(12);
check(array_keys($envelope)===['notification_id','title','body'],'no route peer or message in envelope');
check($envelope['notification_id']===12 && $envelope['title']==='EliteSync','locator not authority');
rejects(fn()=>N::envelope(0),'invalid notice');
echo json_encode(['tests'=>$count,'failures'=>0,'evidence'=>'PURE_OFFLINE_PRODUCTION_CONTRACTS_NOT_E2E'],JSON_THROW_ON_ERROR).PHP_EOL;
