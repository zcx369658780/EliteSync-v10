# SANITIZED_STATIC_REVIEW_COPY; source SHA256 ada5abe088b7fbec81060f2054e9e550ad4c817bf0bdca1ecb19c91f4d857a48
from device_actions import *
from media_stats import rtp_sample
from collections import Counter
import hashlib

token=json.loads((R/'peer-auth-private.json').read_text())['access_token'];call=None
fixedPid=adb('focus-fixed-pid',['shell','pidof',PACKAGE]).stdout.decode().strip();assert fixedPid.isdigit()
def fixed_logs(label):
 assert adb(label+'-pid',['shell','pidof',PACKAGE]).stdout.decode().strip()==fixedPid,'APP_PID_CHANGED'
 return adb(label,['logcat','-d','--pid='+fixedPid,'-v','epoch'],timeout=20).stdout.decode(errors='replace')
def delta(before,after):
 counts=Counter(before.splitlines());new=[]
 for line in after.splitlines():
  if counts[line]:counts[line]-=1
  else:new.append(line)
 return new
def warnings(lines):
 result={'cameraCode4':0,'cameraCode5':0,'trackDisposeNull':0,'cameraLevels':{},'nullLevels':{}}
 for s in lines:
  level=re.match(r'\s*\d+\.\d+\s+\d+\s+\d+\s+([VDIWEF])\s',s)
  tag=level.group(1) if level else 'UNPARSED'
  for code in [4,5]:
   if re.search(r'Device error received, code '+str(code)+r'\b',s):
    result['cameraCode'+str(code)]+=1;result['cameraLevels'][tag]=result['cameraLevels'].get(tag,0)+1
  if 'trackDispose() track is null' in s:
   result['trackDisposeNull']+=1;result['nullLevels'][tag]=result['nullLevels'].get(tag,0)+1
 return result
try:
 baseline=fixed_logs('focus-before-call-baseline')
 call=request('focus-call-create','POST','/api/v1/rtc/calls',token,json={'peer_user_id':1,'mode':'video'})['session']['id'];assert call==1
 time.sleep(1.5);click('focus-call-accept','鎺ュ惉',False)
 assert bind('focus-peer-bind',call)['success'];time.sleep(6)
 peer_media('focus-peer-state-first');first=rtp_sample(fixed_logs('focus-media-first'))
 time.sleep(5);peer_media('focus-peer-state-second');preEnd=fixed_logs('focus-before-ui-end');second=rtp_sample(preEnd)
 assert all(second[k]['bytes']>first[k]['bytes'] and second[k]['packets']>first[k]['packets'] for k in first)
 assert second['inbound-video']['framesDecoded']>first['inbound-video']['framesDecoded']
 click('focus-real-ui-hangup','鎸傛柇');time.sleep(1)
 for i in range(5):
  post=fixed_logs('focus-post-ui-end-'+str(i))
  if 'callId=1 event=room_dispose_complete ' in post and 'callId=1 event=leave_complete ' in post:break
  time.sleep(.2)
 d=request('focus-ended-state','GET','/api/v1/rtc/calls/1',token);assert d['session']['status']=='ended'
 new=delta(preEnd,post);events=[]
 for s in new:
  m=re.search(r'RTC_LIFECYCLE callId=1 event=(\w+) ',s)
  if m:events.append(m.group(1))
 counts=Counter(events)
 for event in ['renderer_cancel_complete','room_disconnect_start','room_disconnect_complete','room_dispose_start','room_dispose_complete','leave_complete']:assert counts[event]>=1,event
 assert not counts['room_dispose_failed'] and not counts['leave_failed']
 native={name:sum(bool(re.search(pattern,s)) for s in new) for name,pattern in [('peerConnectionClosed','onConnectionChangeCLOSED'),('audioRecordStopped','AudioRecord.*stop.*done'),('audioTrackStopped','AudioTrack.*stop.*done'),('cameraReleased','releaseCameraDevice')]}
 assert all(native.values())
 assert command('focus-peer-stop','stop')['success']
 result={'rootLabel':R.name,'callId':1,'samePidThroughout':True,'fourDirectionRtpGrew':True,'first':first,'second':second,'videoDecodeGrew':True,'endPath':'REAL_APP_UI_HANGUP','serverStatus':'ended','newLifecycleSequence':events,'newLifecycleCounts':dict(counts),'newNativeEndpoints':native,'beforeCallWarnings':warnings(baseline.splitlines()),'duringMediaWarnings':warnings(delta(baseline,preEnd)),'afterHangupWarnings':warnings(new),'exceptionsInPostEndDelta':{s:sum(s in line for line in new) for s in ['ConcurrentModificationError','Unhandled Exception','PlatformException','MediaConnectException','StateError']},'appRoomDisconnectSequenceOnce':counts['room_disconnect_start']==1,'appRoomDisposeSequenceOnce':counts['room_dispose_start']==1,'aec':'NOT_PROVEN','lastAudibleWaveform':'NOT_MEASURED','nativeHandleCensus':'NOT_PERFORMED','rawPublished':False}
 (R/'warning-call-result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
finally:
 if call is not None:
  status=request('focus-finally-call-status','GET',f'/api/v1/rtc/calls/{call}',token)['session']['status']
  if status!='ended':
   request('focus-finally-api-end','POST',f'/api/v1/rtc/calls/{call}/end',token)
   command('focus-finally-peer-stop','stop')
