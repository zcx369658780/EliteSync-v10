"""Only the explicit owned stall-test deployment accepts this fault signal."""
import http.client,time,json,pathlib,subprocess,sys
q=pathlib.Path(sys.argv[1]);label=sys.argv[2]
time.sleep(2)
c=http.client.HTTPConnection('127.0.0.1',7884,timeout=2);c.request('GET','/rtc/validate');assert c.getresponse().status==403;c.close()
t=time.time();r=subprocess.run(['docker','exec','elitesync-v1009-rtc','kill','-USR1','1'],capture_output=True)
stop=None
for _ in range(100):
    state=json.loads(subprocess.check_output(['docker','inspect','elitesync-v1009-rtc','--format','{{json .State}}']))
    if not state['Running']:stop=time.time();break
    time.sleep(.05)
out={'fault':'explicit SIGUSR1 blocks gateway main event loop for 10 seconds','watchdog':'independent process and anonymous pipe','trigger_at':t,'container_stopped_at':stop,'observed_seconds':None if stop is None else stop-t,'trigger_exit':r.returncode,'state':state}
(q/(label+'.json')).write_text(json.dumps(out,indent=2));print(json.dumps(out))
assert stop is not None and stop-t<=5 and state['ExitCode']==1
