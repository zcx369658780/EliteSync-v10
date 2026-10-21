import pathlib,json,subprocess,time,threading,urllib.request,urllib.error
E=pathlib.Path(__file__).parent;f=json.loads((E/'after-fixture.private.json').read_text());session=json.loads((E/'admin-finalrace-cookie.private.json').read_text())
def php(name,*args):return subprocess.run(['php',str(E/name),*args],capture_output=True)
def waitfile(n):
 end=time.monotonic()+30
 while not (E/n).exists():assert time.monotonic()<end,'barrier timeout';time.sleep(.025)
assert php('snapshot.php','rrfinal-before').returncode==0
writer=subprocess.Popen(['php',str(E/'rrfinal_writer.php')],stdout=(E/'rrfinal.writer.stdout').open('wb'),stderr=(E/'rrfinal.writer.stderr').open('wb'));waitfile('rrfinal.writer-locked.json');response={}
def http():
 req=urllib.request.Request('http://127.0.0.1:8019/admin/safety-cases/'+f['B1_case']+'/evidence?reason=TEST_ONLY_RONE_exact_lock_barrier',headers={'Cookie':session['cookie'],'Accept':'application/json','X-V1014-R1-Race':'history-admin-session'})
 try:
  with urllib.request.urlopen(req,timeout=40) as x:response.update(status=x.status,body=x.read().decode(),finished=time.time())
 except urllib.error.HTTPError as x:response.update(status=x.code,body=x.read().decode(),finished=time.time())
t=threading.Thread(target=http);t.start();waitfile('rrfinal.first-read.private.json');fr=json.loads((E/'rrfinal.first-read.private.json').read_text());wr=json.loads((E/'rrfinal.writer-locked.json').read_text());edge=None;deadline=time.monotonic()+12
while time.monotonic()<deadline:
 r=php('rr_observe.php');assert r.returncode==0;o=json.loads(r.stdout)
 if any(int(x['reader_connection'])==fr['connection_id'] and int(x['writer_connection'])==wr['connection_id'] and x['lock_index']=='PRIMARY' and 'users' in x['lock_table'] for x in o['waits']):edge=o;break
 time.sleep(.08)
assert edge and t.is_alive(),'exact PRIMARY wait not established';(E/'rrfinal.lock-edge.json').write_text(json.dumps(edge));(E/'rrfinal.commit-go').write_text(str(time.time()));assert writer.wait(timeout=25)==0;t.join(25);assert not t.is_alive();(E/'rrfinal.HTTP.private.json').write_text(json.dumps(response));assert response['status']==401,response
commit=json.loads((E/'rrfinal.writer-commit.json').read_text());assert wr['at']<fr['at']<edge['observed_at']<commit['at']<response['finished'];assert fr['transaction_level']==0
assert php('snapshot.php','rrfinal-after').returncode==0
a=json.loads((E/'rrfinal-before.json').read_text());b=json.loads((E/'rrfinal-after.json').read_text());changed=[k for k in a if a[k]!=b[k]];assert changed==['platform_admin_sessions'],changed
out={'isolation':wr['isolation'],'reader_connection':fr['connection_id'],'writer_connection':wr['connection_id'],'locator_transaction_level':fr['transaction_level'],'sequence':['writer locks administrator user','actual Web HTTP case locator read completed','reader waiting on same users PRIMARY','real service revokes exact Web session COMMIT','HTTP401 resumes without case sources'],'times':{'writer_locked':wr['at'],'locator_read':fr['at'],'lock_wait_observed':edge['observed_at'],'writer_COMMIT':commit['at'],'HTTP_finished':response['finished']},'HTTP_status':response['status'],'private_sources_leaked':False,'changed_tables':changed,'unauthorized_case_report_evidence_audit_notification_sanction_writes':0,'reader':'actual Web product endpoint/middleware','writer':'independent real PlatformAccess revokeAdminSession service'}
(E/'rrfinal-summary.json').write_text(json.dumps(out,indent=2));print(json.dumps(out))
