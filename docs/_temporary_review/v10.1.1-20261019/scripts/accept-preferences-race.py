import pathlib,json,uuid,subprocess,time
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text());pending=json.loads((E/'concurrency-request-pending.json').read_text())
ROOT=r'LOCAL_ONLY_ROOT'
recipient=pending['recipient'];folder=E/'secrets'/('accept-pref-race-'+uuid.uuid4().hex);folder.mkdir()
writer=subprocess.Popen(['php',str(E/'preferences-lock.php'),ROOT,str(folder),str(sessions[recipient]['user']['id'])],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,creationflags=subprocess.CREATE_NO_WINDOW)
deadline=time.monotonic()+15
while not (folder/'pref-locked').exists():
    assert time.monotonic()<deadline;time.sleep(.02)
(folder/'request-a.json').write_text(json.dumps({'path':f'/api/v1/social/requests/{pending["request_id"]}/accept','token':sessions[recipient]['access_token'],'body':{}}))
accept=subprocess.Popen(['php',str(E/'concurrent-kernel.php'),ROOT,str(folder),'a'],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,creationflags=subprocess.CREATE_NO_WINDOW)
while not (folder/'ready-a').exists():
    assert time.monotonic()<deadline;time.sleep(.02)
(folder/'release').write_text('go');time.sleep(1)
assert not (folder/'response-a.json').exists(),'ACCEPT_NOT_WAITING'
(folder/'pref-release').write_text('commit off')
for name,p in [('writer',writer),('accept',accept)]:
    out,err=p.communicate(timeout=15);(folder/(name+'.stdout')).write_bytes(out);(folder/(name+'.stderr')).write_bytes(err);assert p.returncode==0
result=json.loads((folder/'response-a.json').read_text());proof=json.loads((folder/'pref-result.json').read_text());assert result['status']==404 and proof['other_locking_queries_observed']>=1
assert next(r for r in call(recipient,'GET','/social')['requests'] if r['id']==pending['request_id'])['state']=='PENDING'
call(recipient,'POST','/social/preferences',{'requests_enabled':True})
(E/'accept-preferences-race-result.json').write_text(json.dumps({'accept_status':result['status'],'waited_on_user_lock':True,'off_committed_before_accept_resumed':True,'locking_queries_observed':proof['other_locking_queries_observed'],'pending_preserved':True,'preferences_restored_by_owner_api':True}))
print('PREFERENCES_OFF_BEATS_WAITING_ACCEPT_404_PENDING_RETAINED')
