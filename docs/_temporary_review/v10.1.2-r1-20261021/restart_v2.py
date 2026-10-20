import pathlib,subprocess,json,time,requests,os
E=pathlib.Path(r'<LOCAL_ROOT>');W=pathlib.Path.cwd()
r=subprocess.run(['docker','restart','elitesync-v1012-journey-db'],capture_output=True);(E/'restart-db-v2.stdout').write_bytes(r.stdout);(E/'restart-db-v2.stderr').write_bytes(r.stderr);assert r.returncode==0
for i in range(50):
 r=subprocess.run(['php',str(E/'persistence_v2.php')],capture_output=True)
 if r.returncode==0 and r.stdout.lstrip().startswith(b'{'):break
 time.sleep(.3)
(E/'persistence-v2-after-restart.stdout').write_bytes(r.stdout);(E/'persistence-v2-after-restart.stderr').write_bytes(r.stderr);assert r.returncode==0
before=json.loads((E/'persistence-v2-before-restart.stdout').read_text(encoding='utf-8-sig'));after=json.loads(r.stdout.decode('utf-8-sig'));assert before==after
p=subprocess.Popen(['php','-S','127.0.0.1:8015',str(W/'vendor/laravel/framework/src/Illuminate/Foundation/resources/server.php')],cwd=W/'public',stdout=(E/'api-r1-fixed.stdout').open('wb'),stderr=(E/'api-r1-fixed.stderr').open('wb'),creationflags=subprocess.CREATE_NO_WINDOW)
(E/'api-r1-process.json').write_text(json.dumps({'pid':p.pid,'port':8015,'source':'88ffeccce4042f13ce4edccf7604b835b06c8f2d'}));time.sleep(.5)
f=json.loads((E/'fixture-race04.private.json').read_text());h={'Accept':'application/json','Authorization':'[REDACTED] '+f['users']['A']['session']['access_token']}
r=requests.get('http://127.0.0.1:8015/api/v1/journey',headers=h,timeout=15);assert r.status_code==200;v=r.json()['proposal'];assert v['state']=='WITHDRAWN' and v['showcase'] is None and not v['decision_available']
x=requests.post('http://127.0.0.1:8015/api/v1/formal-relationships',headers=h,json={'peer_id':f['users']['C']['id'],'idempotency_key':'restart-denied'},timeout=15);assert x.status_code==404
(E/'restart-v2-result.json').write_text(json.dumps({'tables_equal':before,'db_restart_exit':0,'source':'88ffeccce4042f13ce4edccf7604b835b06c8f2d','read_after_restart':200,'proposal_state':v['state'],'private_showcase':None,'decision_available':False,'revoked_request_after_restart':404,'result':'PASS'},indent=2));print('owned DB/API restart; nine tables identical; HTTP200 withdrawn no private content; revoked request404')
