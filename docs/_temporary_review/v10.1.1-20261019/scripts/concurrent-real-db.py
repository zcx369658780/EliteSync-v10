import pathlib,json,uuid,subprocess,time
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
ROOT=r'LOCAL_ONLY_ROOT'
def run_pair(label,inputs,expected):
    folder=E/'secrets'/('concurrency-'+label+'-'+uuid.uuid4().hex);folder.mkdir()
    processes={}
    for side,data in inputs.items():
        (folder/('request-'+side+'.json')).write_text(json.dumps(data))
        processes[side]=subprocess.Popen(['php',str(E/'concurrent-kernel.php'),ROOT,str(folder),side],cwd=ROOT,stdout=subprocess.PIPE,stderr=subprocess.PIPE,creationflags=subprocess.CREATE_NO_WINDOW)
    deadline=time.monotonic()+15
    while not all((folder/('ready-'+s)).exists() for s in processes):
        assert time.monotonic()<deadline,'WORKER_NOT_READY'
        time.sleep(.02)
    (folder/'release').write_text('release')
    results={}
    for side,p in processes.items():
        stdout,stderr=p.communicate(timeout=20);(folder/(side+'.stdout')).write_bytes(stdout);(folder/(side+'.stderr')).write_bytes(stderr)
        results[side]=json.loads((folder/('response-'+side+'.json')).read_text())
        assert p.returncode==0,(label,side,p.returncode)
    codes=sorted(r['status'] for r in results.values()); assert codes==expected,(label,codes)
    (E/('concurrency-'+label+'-result.json')).write_text(json.dumps({'actual_statuses':codes,'expected_statuses':expected,'two_independent_mysql_processes':True,'all_pass':True}))
    return results
fresh=call('bob','POST','/auth/login',accounts['bob'])
race=run_pair('refresh',{'a':{'path':'/api/v1/auth/refresh','token':fresh['refresh_token'],'body':{}},'b':{'path':'/api/v1/auth/refresh','token':fresh['refresh_token'],'body':{}}},[200,401])
winner=next(r['body'] for r in race.values() if r['status']==200)
call('bob','GET','/privacy',token=winner['access_token'])
call('bob','POST','/auth/refresh',token=fresh['refresh_token'],expected=(401,))
call('bob','POST','/auth/logout',token=winner['access_token'])
call('bob','POST','/auth/refresh',token=winner['refresh_token'],expected=(401,))
i_b=call('bob','POST','/social/invites',{'purpose':'friendship'},expected=(201,))
i_c=call('charlie','POST','/social/invites',{'purpose':'friendship'},expected=(201,))
inputs={}
for side,who,invite in [('a','bob',i_c),('b','charlie',i_b)]:
    inputs[side]={'path':'/api/v1/social/requests','token':sessions[who]['access_token'],'body':{'purpose':'friendship','invitation_token':invite['token'],'idempotency_key':'crossed-'+uuid.uuid4().hex}}
crossed=run_pair('crossed-requests',inputs,[201,409])
side,result=next((s,r) for s,r in crossed.items() if r['status']==201)
(E/'concurrency-request-pending.json').write_text(json.dumps({'sender':'bob' if side=='a' else 'charlie','recipient':'charlie' if side=='a' else 'bob','request_id':result['body']['id']}))
print(json.dumps({'refresh_concurrency':[200,401],'crossed_request_concurrency':[201,409],'pending_for_actual_app_acceptance':True}))
