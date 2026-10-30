"""Network-free native handle/ledger integration; fixtures below this task only."""
import importlib.util,json,os,time,threading,unittest,sys,uuid
from pathlib import Path
sys.path.insert(0,str(Path(__file__).parent/'source/tools/v1015/linux_backend/running_engine'))
from supply import Meter
from test_supply import Response,Opener
import owned

class NativeJournalTests(unittest.TestCase):
 def fixture(self,name):
  p=owned.R/'native-test-fixtures'/(name+'-'+uuid.uuid4().hex);p.mkdir(parents=True,exist_ok=False)
  spec=importlib.util.spec_from_file_location('journal_fixture_'+name,owned.R/'owned.py');c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c);c.R=p;c.L=p/'execution_ledger.jsonl'
  with c.L.open('x+b') as f:
   s=owned.rows()[0].copy();st=p.stat();ls=os.fstat(f.fileno());s.update(root_identity=[st.st_dev,st.st_ino],ledger_identity=[ls.st_dev,ls.st_ino],tick_start_ns=time.monotonic_ns(),fixture_only=True)
   f.write((json.dumps(s)+'\n').encode());f.flush();os.fsync(f.fileno())
  return c
 def test_stop_waits_for_active_request_then_rejects_new_io(self):
  c=self.fixture('stop-race');entered=threading.Event();release=threading.Event();stopped=threading.Event();errors=[]
  class Blocking(Opener):
   def open(self,request,timeout):entered.set();assert release.wait(3);return super().open(request,timeout)
  o=Blocking([Response(b'abc',headers={'Content-Length':'3'})]);m=Meter(c,c.R/'bodies',opener=o)
  def supply():
   try:m.fetch('https://repo.packagist.org/a')
   except Exception as e:
    if str(e)!='STOP_REQUESTED':errors.append(str(e))
  def stop():
   try:c.event('TERMINAL_STOP');stopped.set()
   except Exception as e:errors.append(str(e))
  t=threading.Thread(target=supply);t.start();self.assertTrue(entered.wait(2));s=threading.Thread(target=stop);s.start();time.sleep(.1);self.assertFalse(stopped.is_set());release.set();t.join(3);s.join(3);self.assertFalse(t.is_alive());self.assertFalse(s.is_alive());self.assertFalse(errors);self.assertTrue(stopped.is_set())
  with self.assertRaisesRegex(RuntimeError,'STOP_REQUESTED|STOP_SEALED'):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(len(o.requests),1)
 def test_concurrent_reservations_keep_sequence_and_counts(self):
  c=self.fixture('reservations');errors=[]
  def reserve():
   try:c.cost('supply_requests')
   except Exception as e:errors.append(str(e))
  threads=[threading.Thread(target=reserve) for _ in range(12)]
  for t in threads:t.start()
  for t in threads:t.join(3)
  self.assertFalse(errors);self.assertEqual(sum(x.get('amount',0) for x in c.rows() if x['action']=='PREPARE_COST'),12);self.assertEqual(len(c.rows()),13)
 def test_ledger_identity_swap_rejected_before_cost(self):
  c=self.fixture('identity');b=c.L.read_bytes();c.L.rename(c.R/'original-preserved.jsonl');c.L.write_bytes(b)
  with self.assertRaisesRegex(RuntimeError,'LEDGER_IDENTITY'):c.cost('supply_requests')
 def test_expired_task_can_seal_but_cannot_spend(self):
  c=self.fixture('expired');s=c.rows()[0];s['tick_start_ns']-=14401*10**9;c.L.write_bytes((json.dumps(s)+'\n').encode())
  with self.assertRaisesRegex(RuntimeError,'TIME_BUDGET'):c.cost('supply_requests')
  c.event('TERMINAL_STOP');self.assertEqual(c.rows()[-1]['action'],'TERMINAL_STOP')
 def test_concurrent_body_reservations_cannot_overbook(self):
  c=self.fixture('body-race');s=c.rows()[0];s['limits']['supply_bytes']=100;c.L.write_bytes((json.dumps(s)+'\n').encode());wins=[];refused=[]
  def reserve():
   try:wins.append(c.body_prepare(100,1))
   except RuntimeError as e:refused.append(str(e))
  a=threading.Thread(target=reserve);b=threading.Thread(target=reserve);a.start();b.start();a.join(3);b.join(3)
  self.assertEqual(len(wins),1);self.assertEqual(refused,['SUPPLY_BYTES_BUDGET'])
if __name__=='__main__':unittest.main()
