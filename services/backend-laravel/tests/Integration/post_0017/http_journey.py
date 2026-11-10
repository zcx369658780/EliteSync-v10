"""Synthetic Windows loopback integration. Set TASK_RUNTIME_ROOT to the new ledger root."""
import os,sys,json,uuid,threading,socket,concurrent.futures,time,shlex
import http.client as http_client
from pathlib import Path
from http.server import BaseHTTPRequestHandler,HTTPServer
R=Path(os.environ['TASK_RUNTIME_ROOT']).resolve();sys.path.insert(0,str(R))
import owned as o
o.need(o.TASK=='V1015_POST_0017_DEVICE_E2E_FINAL_CLOSURE_20261031','TASK_BINDING')
c=json.loads((R/'runtime/secrets/config-LOCAL_ONLY.json').read_text(encoding='utf-8'))
checks=[];raw=[]
def save(rel,value):
    data=(json.dumps(value,ensure_ascii=True,indent=2)+'\n').encode()
    (o.revise if (R/rel).exists() else o.write)(rel,data)
def check(name,condition):
    checks.append({'name':name,'passed':bool(condition)});o.event('HTTP_ASSERTION',name=name,passed=bool(condition))
    if not condition:raise AssertionError(name)
def http(method,path,data=None,token=None,status=(200,),headers=None,binary=None,port=None,timeout=20):
    o.need(path.startswith('/') and (port is None or 0<port<65536),'LOOPBACK_TARGET')
    o.reserve('PREPARE_LOOPBACK_HTTP',{'loopback_http_requests':1},method=method,path=path,port=port or c['api_port'],timeout=timeout)
    h={'Accept':'application/json',**(headers or {})};body=binary
    if token:h['Authorization']='Bearer '+token
    if data is not None:body=json.dumps(data).encode();h['Content-Type']='application/json'
    conn=http_client.HTTPConnection('127.0.0.1',port or c['api_port'],timeout=timeout)
    try:conn.request(method,path,body=body,headers=h);r=conn.getresponse();code=r.status;b=r.read();rh=dict(r.getheaders())
    finally:conn.close()
    try:v=json.loads(b)
    except (ValueError,UnicodeDecodeError):v={'bytes':len(b),'sha256':o.sha(b)}
    o.event('LOOPBACK_HTTP_RESULT',method=method,path=path,status=code)
    raw.append({'method':method,'path':path,'status':code,'response':v,'headers':rh})
    if status and code not in status:raise AssertionError('HTTP '+str(code)+' '+method+' '+path+' '+json.dumps(v,ensure_ascii=True))
    if status:check(method+' '+path+' expected status',True)
    return code,v,b,rh
def fixture(action,data=None):
    v,b,e=o.run('scenario-'+action,[o.DOCKER,'--context','desktop-linux','exec',c['api'],'php','tests/Integration/post_0017/scenario.php',action,json.dumps(data or {})],timeout=40,cost={'synthetic_cli_actions':1})
    check('bounded scenario '+action,v['exit']==0)
    return json.loads(b)
def actors():return json.loads((R/'runtime/secrets/actors-LOCAL_ONLY.json').read_text())
def authorized_pair(a,b):
    fixture('friendship',{'a':a['id'],'b':b['id']})
    for actor,peer,kind,action,revision in [(a,b,'connection','request',0),(b,a,'connection','accept',1),(a,b,'consent','request',0),(b,a,'consent','accept',1)]:
        http('POST',f"/api/v1/connections/{peer['id']}/{kind}",{'action':action,'expected_revision':revision},actor['access'])
def phase_actors():
    http('GET','/api/v1/app/health');http('GET','/api/v1/notification-preferences',status=(401,))
    out={}
    for who in ['a','b','c','d','admin']:
        phone='synthetic-c31-'+who;password='ClosureSyntheticPassword42';device='closure-device-'+who
        _,v,_,_=http('POST','/api/v1/auth/register',{'phone':phone,'password':password,'name':'Fictional Closure '+who},status=(201,))
        check('registration cannot claim password-login T0',v.get('session_retention') is None)
        _,v,_,_=http('POST','/api/v1/auth/login',{'phone':phone,'password':password,'device_id':device})
        receipt=v['session_retention'];check('password-login account/device binding',receipt['user_id']==v['user']['id'] and receipt['device_id']==device)
        out[who]={'id':v['user']['id'],'device':device,'access':v['access_token'],'refresh':v['refresh_token'],'retention':receipt}
        save('runtime/secrets/actors-LOCAL_ONLY.json',out)
    a=out['a'];old=a['access'];_,v,_,_=http('POST','/api/v1/auth/refresh',{},a['refresh'])
    keep=lambda x:{k:v for k,v in x.items() if k!='server_now'}
    check('refresh cannot renew T0 or device deadline',keep(v['session_retention'])==keep(a['retention']))
    a['access']=v['access_token'];a['refresh']=v['refresh_token'];save('runtime/secrets/actors-LOCAL_ONLY.json',out)
    http('GET','/api/v1/notification-preferences',token=old,status=(401,));fixture('admin',{'user':out['admin']['id']})
def phase_messages():
    people=actors();a,b,z=people['a'],people['b'],people['c'];authorized_pair(a,b)
    body={'receiver_id':b['id'],'content':'Closure synthetic logical message','client_message_id':str(uuid.uuid4())}
    first=http('POST','/api/v1/messages',body,a['access'])[1];replay=http('POST','/api/v1/messages',body,a['access'])[1]
    check('same-key exact replay identity',first['id']==replay['id'] and replay['idempotent_replay'])
    http('POST','/api/v1/messages',{**body,'content':'conflicting synthetic body'},a['access'],status=(409,))
    http('GET',f"/api/v1/messages?peer_id={a['id']}",token=z['access'],status=(404,))
    lost={**body,'client_message_id':str(uuid.uuid4()),'content':'Closure synthetic dropped ACK'};done=threading.Event();upstream={}
    class DropAck(BaseHTTPRequestHandler):
        def do_POST(self):
            data=json.loads(self.rfile.read(int(self.headers['Content-Length'])))
            upstream['reply']=http('POST','/api/v1/messages',data,a['access'])[1]
            self.close_connection=True;self.connection.shutdown(socket.SHUT_RDWR);self.connection.close();done.set()
        def log_message(self,*args):pass
    o.reserve('PREPARE_LOOPBACK_ACK_DROP_PROXY',{'loopback_proxy_starts':1},bind='127.0.0.1',requests=1)
    proxy=HTTPServer(('127.0.0.1',0),DropAck);thread=threading.Thread(target=proxy.handle_request,daemon=True);thread.start()
    try:
        dropped=False
        try:http('POST','/drop-ack',lost,port=proxy.server_port)
        except (http_client.RemoteDisconnected,ConnectionError):dropped=True
        check('real downstream ACK lost after upstream commit',dropped and done.wait(20))
    finally:proxy.server_close();thread.join(25)
    retry=http('POST','/api/v1/messages',lost,a['access'])[1];check('lost response retry retains one ID',retry['id']==upstream['reply']['id'] and retry['idempotent_replay'])
    race={**body,'client_message_id':str(uuid.uuid4()),'content':'Closure synthetic concurrent message'}
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as p:responses=list(p.map(lambda _:http('POST','/api/v1/messages',race,a['access'])[1],range(4)))
    check('four real HTTP retries converge',len({x['id'] for x in responses})==1)
    obs=fixture('observe');check('three logical messages/notices only',obs['chat_messages']==3 and obs['message_notices']==3 and obs['message_attachments']==0)
    history=http('GET',f"/api/v1/messages?peer_id={a['id']}",token=b['access'])[1]['items'];check('history three unique logical identities',len(history)==3 and len({x['client_message_id'] for x in history})==3)
def multipart(media_type,path):
    boundary='Closure'+uuid.uuid4().hex;name=Path(path).name;mime='image/png' if media_type=='image' else 'video/mp4'
    body=(f'--{boundary}\r\nContent-Disposition: form-data; name="media_type"\r\n\r\n{media_type}\r\n--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="{name}"\r\nContent-Type: {mime}\r\n\r\n').encode()+Path(path).read_bytes()+f'\r\n--{boundary}--\r\n'.encode()
    return body,{'Content-Type':'multipart/form-data; boundary='+boundary}
def phase_media_notifications():
    people=actors();a,b,z=people['a'],people['b'],people['c'];device={'device_id':b['device'],'transport':'test_only','token':'closure-synthetic-provider-one','permission':'granted'}
    http('POST','/api/v1/notification-devices',device,b['access']);one=fixture('delivery',{'user':b['id'],'device':b['device']});check('minimal test-only transport receipt',one['status']=='TEST_ONLY' and set(one['payload'])=={'notification_id','title','body'})
    check('test transport idempotency',fixture('delivery',{'user':b['id'],'device':b['device']})['deduplicated'])
    http('PUT','/api/v1/notification-preferences',{'silent':True},b['access']);check('silent suppresses delivery',fixture('delivery',{'user':b['id'],'device':b['device']})['status']=='SUPPRESSED')
    http('PUT','/api/v1/notification-preferences',{'silent':False,'categories':{'message':False}},b['access']);check('disabled category suppresses',fixture('delivery',{'user':b['id'],'device':b['device']})['status']=='SUPPRESSED')
    prefs=http('GET','/api/v1/notification-preferences',token=b['access'])[1];check('category persisted in actual DB',prefs['categories']['message'] is False and prefs['silent'] is False)
    http('PUT','/api/v1/notification-preferences',{'categories':{'message':True}},b['access'])
    http('POST','/api/v1/notification-devices',{**device,'transport':'fcm'},b['access'],status=(422,403))
    http('POST','/api/v1/notification-devices',{**device,'token':'closure-synthetic-provider-two'},b['access']);check('token rotation changes generation',not fixture('delivery',{'user':b['id'],'device':b['device']})['deduplicated'])
    http('POST','/api/v1/notification-devices',{**device,'permission':'denied'},b['access'],status=(422,));check('permission denial revokes transport',fixture('delivery',{'user':b['id'],'device':b['device']})['status']=='SUPPRESSED')
    http('POST','/api/v1/notification-devices',device,b['access']);obs=fixture('observe');check('actual DB stores only token hash',not obs['raw_token_column'] and obs['token_hashes_valid'])
    blob,headers=multipart('image',R/'media/synthetic.png');asset=http('POST','/api/v1/media',token=a['access'],binary=blob,headers=headers)[1]['asset'];check('real private image upload reaches ready',asset['status']=='ready')
    http('POST','/api/v1/messages',{'receiver_id':b['id'],'content':'Closure synthetic PNG upload','client_message_id':str(uuid.uuid4()),'attachment_ids':[asset['id']]},a['access'])
    media=f"/api/v1/media/{asset['id']}/content";image=http('GET',media,token=b['access'])[2];check('actual uploaded image bytes',o.sha(image)==o.sha((R/'media/synthetic.png').read_bytes()))
    part=http('GET',media,token=b['access'],headers={'Range':'bytes=0-15'},status=(206,))[2];check('private image exact 206 range',part==image[:16]);http('GET',media,token=z['access'],status=(404,))
    before=fixture('observe');video,headers=multipart('video',R/'media/synthetic-h264.mp4');response=http('POST','/api/v1/media',token=a['access'],binary=video,headers=headers,status=(422,))[1]
    check('missing verifier explicitly rejects real valid H264', 'verification is unavailable' in json.dumps(response))
    after=fixture('observe');check('unverified H264 cannot create a ready asset',before==after)
    save('test/h264-api-gate.json',{'fixture_valid_h264_and_full_decode':True,'api_status':422,'verifier_unavailable':True,'asset_created':False,'classification':'H264_FIXTURE_PASS__API_VERIFIER_GATE_BLOCKED__ANDROID_NOT_RUN'})
    save('runtime/secrets/media-LOCAL_ONLY.json',{'asset_id':asset['id'],'path':media})
def phase_revocation():
    p=actors();a,b,z=p['a'],p['b'],p['c'];media=json.loads((R/'runtime/secrets/media-LOCAL_ONLY.json').read_text())['path']
    notice=next(n for n in http('GET','/api/v1/notifications',token=b['access'])[1]['items'] if n['kind']=='message')
    http('POST',f"/api/v1/connections/{a['id']}/consent",{'action':'revoke','expected_revision':2},b['access'])
    http('GET',f"/api/v1/messages?peer_id={a['id']}",token=b['access'],status=(404,));http('GET',media,token=b['access'],status=(404,))
    old=http('GET',f"/api/v1/notifications/{notice['id']}",token=b['access'])[1]['item'];check('old notice contains no authorized route',old['payload']==[] and old['route_name']=='' and old['route_args']==[])
    check('MC revoke suppresses substitute',fixture('delivery',{'user':b['id'],'device':b['device']})['status']=='SUPPRESSED')
    http('POST',f"/api/v1/connections/{a['id']}/connection",{'action':'close','expected_revision':2},b['access'])
    http('POST','/api/v1/moderation/blocks',{'blocked_user_id':a['id']},b['access']);before=fixture('observe')
    http('POST','/api/v1/messages',{'receiver_id':b['id'],'content':'not allowed','client_message_id':str(uuid.uuid4())},a['access'],status=(404,));check('terminal Block creates no message side effects',before==fixture('observe'))
    fixture('expire',{'user':a['id']});http('GET','/api/v1/notification-preferences',token=a['access'],status=(401,))
def phase_concurrent_mc():
    p=actors();a,b=p['c'],p['d'];authorized_pair(a,b);barrier=threading.Barrier(2)
    body={'receiver_id':b['id'],'content':'Closure MC race','client_message_id':str(uuid.uuid4())}
    nonce=uuid.uuid4().hex;folder=R/'runtime/storage/app/post0017-control'
    o.reserve('PREPARE_OWN_PAIR_LOCK_SIGNALS',{'pair_lock_signal_groups':1},paths=['runtime/storage/app/post0017-control/'+nonce+'.ready','runtime/storage/app/post0017-control/'+nonce+'.release'])
    folder.mkdir(parents=True,exist_ok=True);ready=folder/(nonce+'.ready');release=folder/(nonce+'.release')
    def hold():return o.run('hold-new-synthetic-user-pair',[o.DOCKER,'--context','desktop-linux','exec',c['api'],'php','tests/Integration/post_0017/hold_pair.php',str(a['id']),str(b['id']),nonce],timeout=55,cost={'private_pair_lock_holds':1})
    def send():barrier.wait();return http('POST','/api/v1/messages',body,a['access'],status=(200,404),timeout=45)[0]
    def revoke():barrier.wait();return http('POST',f"/api/v1/connections/{a['id']}/consent",{'action':'revoke','expected_revision':2},b['access'],timeout=45)[0]
    observed=[]
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        holder=pool.submit(hold)
        try:
            deadline=time.monotonic()+15
            while not ready.exists():
                if holder.done() or time.monotonic()>deadline:raise RuntimeError('Pair lock readiness failed')
                time.sleep(.1)
            state=json.loads(ready.read_text());check('real pair lock holds two rows under RR',state['locked'] and state['rows']==2 and state['isolation']=='REPEATABLE-READ')
            send_future=pool.submit(send);revoke_future=pool.submit(revoke)
            sql="select count(distinct w.requesting_trx_id) from information_schema.innodb_lock_waits w join information_schema.innodb_locks l on l.lock_id=w.requested_lock_id join information_schema.innodb_trx holder on holder.trx_id=w.blocking_trx_id where l.lock_table='`post0017_synthetic`.`users`' and holder.trx_mysql_thread_id="+str(int(state['connection_id']))+";"
            cmd='exec mariadb --batch --skip-column-names --protocol=tcp --host="$(hostname -i)" --port=55417 --user=root --password="$MARIADB_ROOT_PASSWORD" -e '+shlex.quote(sql)
            for n in range(5):
                result,out,err=o.run('observe-own-db-lock-overlap-'+str(n),[o.DOCKER,'--context','desktop-linux','exec',c['db'],'sh','-c',cmd],timeout=12,cost={'own_db_lock_observation_queries':1})
                check('own DB lock observation query',result['exit']==0);count=int(out.strip());observed.append(count)
                if count>=2:break
                time.sleep(.5)
            check('two real request transactions wait on owned user locks',max(observed)>=2)
        finally:
            if not release.exists():o.write(str(release.relative_to(R)),b'RELEASE_OWN_SYNTHETIC_LOCK')
        held,stdout,stderr=holder.result();check('bounded holder releases without row mutation',held['exit']==0 and json.loads(stdout)['rows_modified']==0)
        result=send_future.result();revoke_future.result()
    before=fixture('observe');http('POST','/api/v1/messages',body,a['access'],status=(404,));check('no replay after committed MC revoke',before==fixture('observe'))
    fixture('disable',{'user':a['id']});http('GET','/api/v1/notification-preferences',token=a['access'],status=(401,403))
    save('test/concurrent-mc-outcome.json',{'send_status':result,'committed_revoke_status':200,'post_revoke_replay':404,'isolation':'REPEATABLE-READ','observed_waiting_request_transaction_counts':observed,'actual_lock_overlap_observed':max(observed)>=2,'classification':'ACTUAL_HTTP_MARIADB_LOCK_OVERLAP_NOT_DEVICE'})

phases={'actors':phase_actors,'messages':phase_messages,'media_notifications':phase_media_notifications,'revocation':phase_revocation,'concurrent_mc':phase_concurrent_mc}
if __name__=='__main__':
    phase=sys.argv[1];error=None
    try:phases[phase]()
    except Exception as ex:error=repr(ex)
    finally:
        save('runtime/'+phase+'-raw-LOCAL_ONLY.json',raw)
        save('test/'+phase+'-http-receipt.json',{'phase':phase,'checks':checks,'passed':sum(x['passed'] for x in checks),'error':error,'classification':'NEW_TASK_REAL_WINDOWS_HTTP_AND_MARIADB_NOT_APP_DEVICE'})
    print(json.dumps({'phase':phase,'checks':len(checks),'error':error}));sys.exit(1 if error else 0)
