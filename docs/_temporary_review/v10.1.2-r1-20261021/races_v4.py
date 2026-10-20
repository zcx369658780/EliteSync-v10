
import pathlib,subprocess,json,time,requests,concurrent.futures,re
E=pathlib.Path(__file__).parent;f=json.loads((E/'fixture-race04.private.json').read_text());u=f['users'];receipts=[]
def call(actor,method,path,body=None,expected=200):
 r=requests.request(method,'http://127.0.0.1:8015/api/v1'+path,json=body,headers={'Accept':'application/json','Authorization':'[REDACTED] '+u[actor]['session']['access_token']},timeout=50);j=r.json();receipts.append({'actor':actor,'path':path,'status':r.status_code,'body':j});assert r.status_code==expected,(path,r.status_code,j);return j
def friend(sender,recipient,key):
 call(recipient,'POST','/social/preferences',{'requests_enabled':True});t=call(recipient,'POST','/social/invites',{'purpose':'friendship'},201);q=call(sender,'POST','/social/requests',{'purpose':'friendship','invitation_token':t['token'],'idempotency_key':key},201);call(recipient,'POST',f"/social/requests/{q['id']}/accept")
def snapshot():return json.loads(subprocess.check_output(['php',str(E/'state.php'),'race04']))
def waitfile(p):
 deadline=time.time()+20
 while not p.exists():assert time.time()<deadline,p.name;time.sleep(.03)
def rootwait(writer):
 sql=f'SELECT r.trx_mysql_thread_id,b.trx_mysql_thread_id,w.requesting_trx_id,w.blocking_trx_id,r.trx_query,l.lock_table,l.lock_index,l.lock_data FROM information_schema.INNODB_LOCK_WAITS w JOIN information_schema.INNODB_LOCKS l ON l.lock_id=w.requested_lock_id JOIN information_schema.INNODB_TRX r ON r.trx_id=w.requesting_trx_id JOIN information_schema.INNODB_TRX b ON b.trx_id=w.blocking_trx_id WHERE b.trx_mysql_thread_id={writer};'
 # Secret remains in the owned container, supplied through a short-lived private option file.
 script='set -eu\numask 077\nf=$(mktemp)\ntrap \'rm -f "$f"\' EXIT\nprintf \'[client]\\nuser=root\\npassword=%s\\n\' "$MARIADB_ROOT_PASSWORD" > "$f"\nmariadb --defaults-extra-file="$f" -N -B -e '+"'"+sql+"'"+'\n'
 r=subprocess.run(['docker','exec','-i','elitesync-v1012-journey-db','sh'],input=script.encode(),capture_output=True);assert r.returncode==0
 return [x.split('\t') for x in r.stdout.decode().strip().splitlines() if x]
try:
 friend('A','C','r1-race4-contact')
 friend('C','B','r1-pause-source')
 # An unactivated request must not launder its revoked source via a resumed generation.
 rel=call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'r1-unactivated'})
 for act in ['pause','resume','pause']:rel=call('C','POST',f"/formal-relationships/{rel['id']}/actions",{'action':act,'revision':rel['revision'],'idempotency_key':'r1-unactivated-'+act+str(rel['revision'])})
 assert rel['confirmation_generation']==2
 call('B','POST','/social/preferences',{'requests_enabled':False});pre=snapshot();call('C','POST',f"/formal-relationships/{rel['id']}/actions",{'action':'resume','revision':rel['revision'],'idempotency_key':'r1-revoked-resume'},409)
 assert snapshot()['counts']['journey_commands']==pre['counts']['journey_commands']
 (E/'unactivated-source-result-v4.json').write_text(json.dumps({'real_HTTP':True,'pre_activation_generation':2,'revoked_resume_status':409,'new_command_count':0,'activation':False,'scope':'synthetic controlled friendship with receiver requests enabled, later revoked'},indent=2))
 assert call('A','GET','/match-rounds/current')['data']['state']=='revealed'
 assert call('A','GET','/journey')['proposal']['showcase']['summary']=='R1_PRIVATE_SUMMARY_B'
 for mode in ['contact','exit']:
  before=snapshot();peer=u['C' if mode=='contact' else 'B']['id'];writer=subprocess.Popen(['php',str(E/'race_writer_v4.php'),mode],stdout=(E/f'race4-{mode}-writer.stdout').open('wb'),stderr=(E/f'race4-{mode}-writer.stderr').open('wb'))
  try:
   waitfile(E/f'race4-{mode}.held');held=json.loads((E/f'race4-{mode}.held').read_text());start=time.time()
   with concurrent.futures.ThreadPoolExecutor(1) as pool:
    path='/formal-relationships' if mode=='contact' else '/journey';method='POST' if mode=='contact' else 'GET';body={'peer_id':peer,'idempotency_key':'r1-wait-contact'} if mode=='contact' else None
    pending=pool.submit(requests.request,method,'http://127.0.0.1:8015/api/v1'+path,json=body,headers={'Accept':'application/json','Authorization':'[REDACTED] '+u['A']['session']['access_token'],'X-R1-Request':'r1-'+mode},timeout=45)
    try:
     deadline=time.time()+15;rows=[]
     while not rows:
      assert time.time()<deadline,'no exact waiting edge';rows=rootwait(held['writer_connection_id'])
      if not rows:time.sleep(.03)
     (E/f'race4-{mode}.observed-waits.json').write_text(json.dumps(rows,indent=2));edge=next((x for x in rows if '`users`' in x[4] and 'in (?, ?)' in x[4] and 'for update' in x[4] and 'users' in x[5] and x[6]=='PRIMARY' and x[7]==str(peer)),None);assert edge and int(edge[1])==held['writer_connection_id'] and not pending.done()
     proof={'reader_connection_id':int(edge[0]),'writer_connection_id':int(edge[1]),'requesting_trx_id':edge[2],'blocking_trx_id':edge[3],'target_sorted_synthetic_ids':sorted([u['A']['id'],peer]),'waiting_query':edge[4],'requested_lock_table':edge[5],'requested_lock_index':edge[6],'requested_lock_data':edge[7],'reader_pending':True,'http_sent_at':start,'wait_observed_at':time.time(),'held':held,'exclusive_owned_api_request':'r1-'+mode};(E/f'race4-{mode}.exact-wait.json').write_text(json.dumps(proof,indent=2));(E/f'race4-{mode}.release').write_text('commit only after exact paired lock edge')
    finally:
     (E/f'race4-{mode}.release').write_text('release after exact wait or harness exception')
    r=pending.result();received=time.time()
   writer.wait(timeout=10);assert writer.returncode==0;waitfile(E/f'race4-{mode}.committed');commit=json.loads((E/f'race4-{mode}.committed').read_text());assert received>=commit['after_commit_at']>=proof['wait_observed_at']>=start
   after=snapshot();j=r.json()
   if mode=='contact':assert r.status_code==404 and before['counts']==after['counts'] and j['error']['message']=='unavailable'
   else:assert r.status_code==200 and j['proposal']['showcase'] is None and not j['proposal']['decision_available'] and 'R1_PRIVATE_SUMMARY_B' not in r.text and after['proposal']['state']=='WITHDRAWN' and after['proposal']['slot_count']==0
   out={'isolation':held['isolation'],'exact_reader_writer_edge':True,'reader_connection_id':int(edge[0]),'writer_connection_id':int(edge[1]),'committed_before_response':True,'http_status':r.status_code,'private_showcase_absent':'R1_PRIVATE_SUMMARY_B' not in r.text,'side_effect_delta':{k:after['counts'][k]-before['counts'][k] for k in before['counts']},'writer_exit':writer.returncode,'result':'PASS'};(E/f'race4-{mode}-result.json').write_text(json.dumps(out,indent=2));print(mode,json.dumps(out))
  finally:
   if not (E/f'race4-{mode}.release').exists():(E/f'race4-{mode}.release').write_text('release on harness exception')
finally:(E/'race4-setup-http.private.json').write_text(json.dumps(receipts,ensure_ascii=False,indent=2))
