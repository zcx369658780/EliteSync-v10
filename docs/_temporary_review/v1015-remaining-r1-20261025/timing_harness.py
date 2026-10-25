# SANITIZED_STATIC_REVIEW_COPY; raw source hash 4599e57e48193ded9ebb52b8021628eb473e12cf111dcf8684df36915358057c
from device_actions import *
from owned_runtime import PHP,env,B
import hashlib,subprocess,threading,queue

token=json.loads((R/'peer-auth-private.json').read_text())['access_token']
call=None;revoked=False;child=None
fixedPid=None
def fixed_logs(label):
 current=adb(label+'-pid',['shell','pidof',PACKAGE]).stdout.decode().strip()
 assert current==fixedPid,'APP_PID_CHANGED'
 return adb(label,['logcat','-d','--pid='+fixedPid,'-v','epoch'],timeout=20).stdout.decode(errors='replace')
def stamp(line):
 m=re.match(r'\s*(\d+\.\d+)',line)
 return float(m.group(1)) if m else None
def rtp_sample(raw):
 rows={}
 for line in raw.splitlines():
  if 'RTC_MEDIA_RTP callId=1 ' not in line:continue
  values=dict(re.findall(r'(direction|kind|bytes|packets|framesDecoded)=(\S+)',line))
  key=values['direction']+'-'+values['kind']
  if key not in ['outbound-audio','outbound-video','inbound-audio','inbound-video']:continue
  rows.setdefault(key,[]).append((stamp(line),values))
 result={}
 for key,items in rows.items():
  latest=items[-1][0];batch=[v for t,v in items if t is not None and latest-.5<=t<=latest]
  result[key]={'bytes':sum(int(v['bytes']) for v in batch),'packets':sum(int(v['packets']) for v in batch),'framesDecoded':sum(int(v['framesDecoded']) for v in batch if v.get('framesDecoded','null')!='null')}
 assert len(result)==4,'FOUR_RTP_DIRECTIONS_REQUIRED'
 return result
patterns={
 'peerConnectionClosed':r'onConnectionChangeCLOSED',
 'audioRecordStopped':r'AudioRecord.*stop.*done',
 'audioTrackStopped':r'AudioTrack.*stop.*done',
 'cameraReleased':r'releaseCameraDevice',
 'rendererCancelComplete':r'callId=1 event=renderer_cancel_complete ',
 'roomDisconnectComplete':r'callId=1 event=room_disconnect_complete ',
 'roomDisposeComplete':r'callId=1 event=room_dispose_complete ',
 'leaveComplete':r'callId=1 event=leave_complete ',
}
try:
 call=request('r1-call-create','POST','/api/v1/rtc/calls',token,json={'peer_user_id':1,'mode':'video'})['session']['id']
 assert call==1,'FRESH_R1_CALL1_REQUIRED'
 time.sleep(1.5);click('r1-call-accept','接听',False)
 assert bind('r1-peer-bind',call)['success']
 fixedPid=adb('r1-call-fixed-pid',['shell','pidof',PACKAGE]).stdout.decode().strip();assert fixedPid.isdigit()
 time.sleep(6);peer_media('r1-peer-media-first');first=rtp_sample(fixed_logs('r1-media-first'))
 time.sleep(5);peer_media('r1-peer-media-second');second=rtp_sample(fixed_logs('r1-media-second'))
 assert all(second[k]['bytes']>first[k]['bytes'] and second[k]['packets']>first[k]['packets'] for k in first)
 assert second['inbound-video']['framesDecoded']>first['inbound-video']['framesDecoded']
 (R/'rtc-pre-revoke-flow.json').write_text(json.dumps({'callId':1,'samePid':True,'first':first,'second':second,'fourDirectionsAndDecodedVideoGrew':True},indent=2))
 with (R/'revoke-barrier.stderr.txt').open('xb') as err:
  child=subprocess.Popen([PHP,str(R/'revoke_ready_barrier.php'),'1'],cwd=B,env=env,stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=err,creationflags=subprocess.CREATE_NO_WINDOW)
  messages=queue.Queue()
  def consume():
   with (R/'revoke-barrier.stdout.txt').open('xb') as out:
    for line in iter(child.stdout.readline,b''):
     stamp=time.monotonic_ns();out.write(line);out.flush()
     try:messages.put((stamp,json.loads(line)))
     except (ValueError,UnicodeDecodeError):continue
  reader=threading.Thread(target=consume,daemon=True);reader.start()
  ready_time,ready=messages.get(timeout=30)
  assert ready.get('phase')=='READY' and ready['callId']==1
  # Refresh after process bootstrap/READY; no teardown of this call may have
  # started. Native events must follow its disconnect marker in the phone log
  # clock, used for ordering only, never subtracted from the host clock.
  baseline=fixed_logs('r1-pre-go-baseline')
  assert 'callId=1 event=room_disconnect_start ' not in baseline
  counts={k:len(re.findall(v,baseline)) for k,v in patterns.items()}
  # A single host monotonic clock bounds all observations. PHP cannot enter
  # transition/commit until it receives GO after this timestamp.
  start=time.monotonic_ns();child.stdin.write(b'GO\n');child.stdin.flush()
  commit_received,commit=messages.get(timeout=15)
  assert commit.get('phase')=='COMMITTED' and commit['transactionLevel']==0
  assert all(s=='MC_REVOKED' for s in commit['consentStates'])
  revoked=True
  observations={}
  last=''
  for i in range(12):
   raw=fixed_logs('r1-post-revoke-'+str(i));observed=time.monotonic_ns();last=raw
   starts=[stamp(line) for line in raw.splitlines() if 'callId=1 event=room_disconnect_start ' in line]
   startPhone=next((v for v in starts if v is not None),None)
   for k,p in patterns.items():
    ordered=any(re.search(p,line) and stamp(line) is not None and (k=='rendererCancelComplete' or startPhone is not None and stamp(line)>=startPhone) for line in raw.splitlines())
    if k not in observations and ordered and len(re.findall(p,raw))>counts[k]:
     observations[k]={'hostObservedAfterGoSeconds':(observed-start)/1e9,'newEventCount':len(re.findall(p,raw))-counts[k]}
   if len(observations)==len(patterns):break
   if (observed-start)>15e9:break
   time.sleep(.1)
  code=child.wait(timeout=10);reader.join(timeout=2);assert code==0
  bound=max((x['hostObservedAfterGoSeconds'] for x in observations.values()),default=None)
  result={'callId':1,'clock':'ONE_HOST_MONOTONIC_NS','definition':'GO_SENT_BEFORE_REAL_TRANSITION_TO_HOST_RECEIPT_OF_NEW_SAME_PID_NATIVE_AND_CALL_COMPLETION_EVENTS','bootstrapExcludedByReadyBarrier':True,'commitBracketAfterGoSeconds':[0,(commit_received-start)/1e9],'phpTransitionElapsedSeconds':commit['phpTransitionElapsedSeconds'],'clockAssociation':'No phone/server clock subtraction; logcat retrieval overhead is included in the conservative upper bound','nativeAndLifecycleObservations':observations,'allRequiredEventsObserved':len(observations)==len(patterns),'conservativePostCommitStopUpperBoundSeconds':bound,'fiveSecondBoundSupported':len(observations)==len(patterns) and bound<=5,'exactCommitTimestampMeasured':False,'lastAudibleWaveformStop':'NOT_MEASURED','aec':'NOT_PROVEN','nativeHandleCensus':'NOT_PERFORMED','rawPublished':False}
  (R/'rtc-revoke-timing.json').write_text(json.dumps(result,indent=2))
  print(json.dumps(result),flush=True)
  assert len(observations)==len(patterns),'MISSING_NATIVE_OR_COMPLETION_OBSERVATION'
 assert command('r1-peer-final-stop','stop')['success']
finally:
 if child is not None and child.poll() is None:
  if child.stdin:child.stdin.close()
  try:child.wait(timeout=10)
  except subprocess.TimeoutExpired:child.terminate();child.wait(timeout=5)
 if call is not None and not revoked:
  request('r1-call-exception-end','POST',f'/api/v1/rtc/calls/{call}/end',token)
  command('r1-peer-exception-stop','stop')
