"""Observe real APP media and one authorized revocation, never fabricate a call."""
import pathlib,sys,json,importlib.util,threading,subprocess,time
q=pathlib.Path(sys.argv[1]);call=int(sys.argv[2]);action=sys.argv[3];label=sys.argv[4]
spec=importlib.util.spec_from_file_location('client',pathlib.Path(__file__).with_name('runtime-client.py'))
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
processes=[];threads=[];events=[];lock=threading.Lock()
def read(side,process):
    for line in process.stdout:
        if any(word in line for word in ['RTC_LIFECYCLE','RTC_MEDIA_RTP','RTC_LIVEKIT_ROOM_','RTC_LIVEKIT_AUDIO_FRAME','RTC_LIVEKIT_HEARTBEAT_FAIL','RTC_LIVEKIT_TRACK_']):
            with lock:events.append({'side':side,'host_received':time.time(),'line':line.strip()})
for side,serial in [('a','emulator-5584'),('b','emulator-5586')]:
    process=subprocess.Popen(['adb','-s',serial,'logcat','-v','epoch','-T','1','-s','flutter'],stdout=subprocess.PIPE,stderr=(q/(label+'-'+side+'.stderr')).open('w'),text=True,encoding='utf-8',errors='replace',creationflags=subprocess.CREATE_NO_WINDOW)
    processes.append(process);thread=threading.Thread(target=read,args=(side,process),daemon=True);thread.start();threads.append(thread)
subprocess.run([sys.executable,str(pathlib.Path(__file__).with_name('rtc-probe.py')),str(q),str(call),label+'-before'],check=True)
time.sleep(2)
start=time.time();status=None
if action in ['restrict','banned']:
    subprocess.run([sys.executable,str(pathlib.Path(__file__).with_name('browser-action.py')),str(q),action,label,'3'],check=True)
elif action in ['consent','connection']:
    status,current=c.request('bob','GET','/api/v1/connections/2');assert status==200
    status,_=c.request('bob','POST','/api/v1/connections/2/'+action,{'action':'revoke' if action=='consent' else 'close','expected_revision':current[action]['revision']});assert status==200
elif action=='end':
    status,_=c.request('bob','POST',f'/api/v1/rtc/calls/{call}/end');assert status==200
elif action=='block':
    status,_=c.request('bob','POST','/api/v1/moderation/blocks',{'blocked_user_id':2});assert status in [200,201]
else:raise ValueError('unsupported action')
response=time.time();time.sleep(7)
for p in processes:p.terminate()
for thread in threads:thread.join(2)
receipt={'call_id':call,'action':action,'request_started':start,'response_at':response,'status':status,'events':events}
(q/(label+'-observed.json')).write_text(json.dumps(receipt,indent=2));print('Real APP revocation observation retained',action,call)
subprocess.run([sys.executable,str(pathlib.Path(__file__).with_name('rtc-probe.py')),str(q),str(call),label+'-after'],check=True)
