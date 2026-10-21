import pathlib,subprocess,json,time,threading,urllib.request,urllib.error,sys
E=pathlib.Path(__file__).parent;f=json.loads((E/'concurrency-final-fixture.private.json').read_text());kind=sys.argv[1]
def php(*args):return subprocess.run(['php',str(E/'ops_final.php'),*args],capture_output=True)
def waitfile(p):
    until=time.monotonic()+35
    while not p.exists():
        assert time.monotonic()<until,'barrier timeout';time.sleep(.025)
if kind=='capacity':
    ps={}
    for who in ['capB','capC']:
        ps[who]=subprocess.Popen(['php',str(E/'ops_final.php'),'capacity',who],stdout=(E/('capacity-'+who+'.stdout')).open('wb'),stderr=(E/('capacity-'+who+'.stderr')).open('wb'))
    for who in ps:waitfile(E/('capacity-'+who+'.ready'))
    (E/'capacity-go').write_text(str(time.time()))
    for who,p in ps.items():assert p.wait(timeout=35)==0
    rs={who:json.loads((E/('capacity-'+who+'.result.json')).read_text()) for who in ps};assert sorted(r['code'] for r in rs.values())==[200,409]
    loser=next(w for w,r in rs.items() if r['code']==409);r=php('capacity-retry',loser);(E/'capacity-retry.stdout').write_bytes(r.stdout);(E/'capacity-retry.stderr').write_bytes(r.stderr);assert r.returncode==0
    assert json.loads((E/'capacity-retry.json').read_text())['registration']['state']=='WAITLISTED'
    (E/'capacity-summary.json').write_text(json.dumps({'layer':'two independent MariaDB service processes, not two HTTP requests','codes':{w:r['code'] for w,r in rs.items()},'fresh_retry':'WAITLISTED','reserved_seats':2,'capacity':2,'single_winner':True}))
    print('CAPACITY_SINGLE_WINNER_200_409_FRESH_RETRY_WAITLISTED');sys.exit(0)
assert kind in ['event-revoke','safety-logout']
r=php('snapshot','rr3-'+kind+'-before');assert r.returncode==0
writer=subprocess.Popen(['php',str(E/'ops_final.php'),'writer',kind,'rr3'],stdout=(E/('rr3-'+kind+'.writer.stdout')).open('wb'),stderr=(E/('rr3-'+kind+'.writer.stderr')).open('wb'))
waitfile(E/('rr3-'+kind+'.writer-locked.json'))
u=f['users']['eventReader' if kind=='event-revoke' else 'safetyReader'];path='/platform-events/'+f['event'] if kind=='event-revoke' else '/safety/own/'+f['case']
response={}
def read():
    req=urllib.request.Request('http://127.0.0.1:8019/api/v1'+path,headers={'Authorization':'Bearer '+u['session']['access_token'],'Accept':'application/json','X-V1014-Race':kind})
    try:
        with urllib.request.urlopen(req,timeout=45) as r:response.update(code=r.status,body=r.read().decode(),finished_at=time.time())
    except urllib.error.HTTPError as r:response.update(code=r.code,body=r.read().decode(),finished_at=time.time())
    except Exception as e:response.update(error=str(e),finished_at=time.time())
t=threading.Thread(target=read);t.start();waitfile(E/('rr3-'+kind+'.first-read'))
start=time.monotonic();waits=None
while time.monotonic()-start<12:
    r=php('observe');assert r.returncode==0,r.stderr.decode();o=json.loads(r.stdout);wl=json.loads((E/('rr3-'+kind+'.writer-locked.json')).read_text());fr=json.loads((E/('rr3-'+kind+'.first-read')).read_text())
    candidates=[x for x in o['waits'] if int(x['reader_connection'])==fr['connection_id'] and int(x['writer_connection'])==wl['connection_id'] and x['lock_index']=='PRIMARY' and 'users' in x['lock_table']]
    if candidates:waits=o;break
    time.sleep(.1)
assert waits,'exact user PRIMARY wait missing';(E/('rr3-'+kind+'.lock-edge.json')).write_text(json.dumps(waits))
assert t.is_alive(),'reader did not wait'
(E/('rr3-'+kind+'.commit-go')).write_text(str(time.time()))
assert writer.wait(timeout=30)==0;t.join(timeout=30);assert not t.is_alive()
(E/('rr3-'+kind+'.http.private.json')).write_text(json.dumps(response))
assert response.get('code')==(404 if kind=='event-revoke' else 401),response.get('code')
commit=json.loads((E/('rr3-'+kind+'.writer-commit.json')).read_text());assert wl['locked_at']<fr['completed_at']<waits['observed_at']<commit['committed_at']<response['finished_at']
r=php('snapshot','rr3-'+kind+'-after');assert r.returncode==0
before=json.loads((E/('rr3-'+kind+'-before.json')).read_text());after=json.loads((E/('rr3-'+kind+'-after.json')).read_text());changed=[k for k in before if before[k]!=after[k]]
allowed=['platform_events','platform_event_grants','platform_event_registrations','platform_event_audits','platform_event_commands','admin_operation_audits','personal_access_tokens'] if kind=='event-revoke' else ['personal_access_tokens','device_sessions']
assert set(changed)<=set(allowed),changed
bp=json.loads((E/('rr3-'+kind+'-before.private.json')).read_text());ap=json.loads((E/('rr3-'+kind+'-after.private.json')).read_text())
if kind=='event-revoke':
    strip=lambda rows:[{k:v for k,v in x.items() if k not in ['last_used_at','updated_at']} for x in rows]
    assert strip(bp['personal_access_tokens'])==strip(ap['personal_access_tokens'])

summary={'kind':kind,'isolation':wl['isolation'],'reader_connection':fr['connection_id'],'writer_connection':wl['connection_id'],'locator_transaction_level':fr['transaction_level'],'sequence':['writer locks user','actual HTTP locator read completes','reader waits on users PRIMARY','writer revoke service COMMIT','HTTP continues with denial'],'times':{'locked':wl['locked_at'],'first_read':fr['completed_at'],'wait_observed':waits['observed_at'],'committed':commit['committed_at'],'http_finished':response['finished_at']},'status':response['code'],'changed_tables':changed,'unauthorized_report_notification_sanction_side_effects':0,'private_response':False,'reader_layer':'actual product HTTP route, normal middleware','writer_layer':'independent process, real service, same RR database'}
(E/('rr3-'+kind+'.summary.json')).write_text(json.dumps(summary,indent=2));print(json.dumps(summary))
