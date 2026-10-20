import pathlib,subprocess,json,time,requests,concurrent.futures,sys
E=pathlib.Path(__file__).parent
def php(label,*args):
 r=subprocess.run(['php',str(E/(args[0]+'.php')),*args[1:]],capture_output=True)
 (E/(label+'.stdout')).write_bytes(r.stdout);(E/(label+'.stderr')).write_bytes(r.stderr)
 (E/(label+'.exit.json')).write_text(json.dumps({'exit':r.returncode}))
 assert r.returncode==0,(label,r.stderr.decode(errors='replace'))
 assert not b'Exception' in r.stdout,(label,r.stdout.decode(errors='replace')[:400])
def waitfile(p):
 deadline=time.monotonic()+25
 while not p.exists():
  assert time.monotonic()<deadline,('barrier absent',p.name)
  time.sleep(.02)
def waiting():
 r=subprocess.run(['docker','exec','elitesync-v1012-journey-db','sh','-c','exec mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "SELECT COUNT(*) FROM information_schema.INNODB_LOCK_WAITS"'],capture_output=True)
 assert r.returncode==0,r.stderr
 return int(r.stdout.decode().strip())
for scenario in sys.argv[1:]:
 php('race-'+scenario+'-fixture','race_fixture',scenario)
 f=json.loads((E/f'race-{scenario}.private.json').read_text());base=E/f'race-{scenario}'
 h={'Authorization':'Bearer '+f['viewer']['session']['access_token'],'Accept':'application/json'}
 url='http://127.0.0.1:8015/api/v1/profile-peers/'+str(f['owner']['id'])
 positive=requests.get(url,headers=h,timeout=15)
 assert positive.status_code==200 and positive.json()['profile']['resume']=='SYNTHETIC_PRIVATE_RESUME'
 w=subprocess.Popen(['php',str(E/'race_writer.php'),scenario],stdout=(E/f'race-{scenario}-writer.stdout').open('wb'),stderr=(E/f'race-{scenario}-writer.stderr').open('wb'))
 try:
  waitfile(E/f'race-{scenario}.writer-locked')
  with concurrent.futures.ThreadPoolExecutor(1) as pool:
   pending=pool.submit(requests.get,url,headers=h,timeout=40)
   deadline=time.monotonic()+15;count=0
   while count<1:
    assert time.monotonic()<deadline,('no actual InnoDB waiter',scenario)
    count=waiting()
    if not count:time.sleep(.03)
   assert not pending.done(),'reader must still be blocked'
   (E/f'race-{scenario}.wait-proof.json').write_text(json.dumps({'innodb_lock_waits':count,'reader_pending':True,'writer':json.loads((E/f'race-{scenario}.writer-locked').read_text()),'observed_at':time.time()}))
   (E/f'race-{scenario}.release').write_text('commit revocation now')
   response=pending.result()
  w.wait(timeout=10);assert w.returncode==0,(scenario,'writer failed')
  waitfile(E/f'race-{scenario}.committed')
  j=response.json()
  if scenario in ['audience','pause','credential']:
   assert response.status_code in [200,404],(scenario,response.status_code,j)
   assert 'SYNTHETIC_PRIVATE_RESUME' not in response.text and '1994-02-03' not in response.text,(scenario,'private data leaked')
  elif scenario.startswith('block') or scenario=='disabled':assert response.status_code in [403,404],(scenario,response.status_code,j)
  elif scenario=='session':assert response.status_code==401,(scenario,response.status_code,j)
  (E/f'race-{scenario}-result.json').write_text(json.dumps({'isolation':'REPEATABLE-READ','positive_status':positive.status_code,'blocked_reader_observed':True,'revocation_committed':True,'resumed_status':response.status_code,'body':j,'writer_exit':w.returncode,'private_data_absent':'SYNTHETIC_PRIVATE_RESUME' not in response.text},ensure_ascii=False,indent=2),encoding='utf8')
  print(scenario,'PASS',response.status_code)
 finally:
  if not (E/f'race-{scenario}.release').exists():(E/f'race-{scenario}.release').write_text('release on harness failure')
