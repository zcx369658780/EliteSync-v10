import pathlib,subprocess,json,time
E=pathlib.Path(__file__).parent
def wait(p):
 end=time.monotonic()+15
 while not p.exists():
  assert time.monotonic()<end,p.name
  time.sleep(.02)
r=subprocess.run(['php',str(E/'proposal_race_fixture.php')],capture_output=True)
(E/'proposal-fixture.stdout').write_bytes(r.stdout);(E/'proposal-fixture.stderr').write_bytes(r.stderr);assert r.returncode==0
w=subprocess.Popen(['php',str(E/'race_writer.php'),'proposal'],stdout=(E/'proposal-holder.stdout').open('wb'),stderr=(E/'proposal-holder.stderr').open('wb'))
wait(E/'race-proposal.writer-locked')
workers=[subprocess.Popen(['php',str(E/'proposal_worker.php'),role],stdout=subprocess.PIPE,stderr=subprocess.PIPE) for role in ['owner','viewer']]
try:
 end=time.monotonic()+15;count=0
 while count<2:
  r=subprocess.run(['docker','exec','elitesync-v1012-journey-db','sh','-c','exec mariadb -uroot -p"$MARIADB_ROOT_PASSWORD" -N -e "SELECT COUNT(*) FROM information_schema.INNODB_LOCK_WAITS"'],capture_output=True);assert r.returncode==0
  count=int(r.stdout.strip());assert time.monotonic()<end,'both workers must be in actual lock wait'
  if count<2:time.sleep(.03)
 (E/'race-proposal.release').write_text('release both blocked activation requests')
 w.wait(timeout=10);assert w.returncode==0
 results=[]
 for i,p in enumerate(workers):
  stdout,stderr=p.communicate(timeout=15);(E/f'proposal-worker-{i}.stdout').write_bytes(stdout);(E/f'proposal-worker-{i}.stderr').write_bytes(stderr);assert p.returncode==0
  results.append(json.loads(stdout))
 assert sorted(r['status'] for r in results)==[200,409],results
 assert sum(r.get('state')=='ACCEPTED_BY_ONE' for r in results)==1
 (E/'proposal-result.json').write_text(json.dumps({'both_innodb_waiters':count,'results':results,'holder_committed':True,'isolation':'REPEATABLE-READ'},indent=2))
 print('Proposal concurrent accept PASS: one acceptance, one revision conflict, both actual lock waiters')
finally:
 if not(E/'race-proposal.release').exists():(E/'race-proposal.release').write_text('release on failure')
