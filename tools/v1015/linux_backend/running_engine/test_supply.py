import io,unittest,urllib.error,hashlib,contextlib
from pathlib import Path
import tempfile
from supply import Meter, validate_url

class Control:
 def __init__(self,request_limit=20,byte_limit=1073741824):self.events=[];self.request_limit=request_limit;self.byte_limit=byte_limit;self.charged=0;self.reserved={}
 def event(self,action,**kw):self.events.append((action,kw));return {'seq':len(self.events)}
 def activity(self):return contextlib.nullcontext()
 def cost(self,category,amount=1,**kw):
  n=sum(x[1].get('amount',0) for x in self.events if x[0]=='PREPARE_COST')
  if n+amount>self.request_limit:raise RuntimeError('REQUEST_BUDGET')
  return self.event('PREPARE_COST',category=category,amount=amount,**kw)
 def body_prepare(self,maximum,request_id):
  if self.charged+sum(self.reserved.values())+maximum>self.byte_limit:raise RuntimeError('BYTE_BUDGET')
  n=len(self.events)+1;self.reserved[n]=maximum;self.event('PREPARE_BODY_READ',maximum=maximum);return n
 def body_commit(self,n,actual):
  assert 0<=actual<=self.reserved[n];del self.reserved[n];self.charged+=actual;self.event('SUPPLY_BODY_BYTES',actual=actual)

class Response(io.BytesIO):
 def __init__(self,b,status=200,headers=None):super().__init__(b);self.status=status;self.headers=headers or {};self.code=status;self.read_calls=0
 def read(self,n=-1):self.read_calls+=1;return super().read(n)
 def getcode(self):return self.status
class Opener:
 def __init__(self,responses):self.responses=list(responses);self.requests=[]
 def open(self,request,timeout):self.requests.append(request);return self.responses.pop(0)

class MeterTests(unittest.TestCase):
 def setUp(self):
  base=Path(__file__).resolve().parent/'_test_artifacts';base.mkdir(exist_ok=True)
  self.tmp=tempfile.TemporaryDirectory(dir=base);self.addCleanup(self.tmp.cleanup);self.root=Path(self.tmp.name)
 def meter(self,responses,control=None):
  c=control or Control();o=Opener(responses);return Meter(c,self.root,opener=o),c,o
 def test_public_https_allowlist(self):
  for u in ['http://repo.packagist.org/a','https://user:pw@repo.packagist.org/a','https://127.0.0.1/a','https://repo.packagist.org.evil.test/a','https://repo.packagist.org:8443/a']:
   with self.subTest(u=u),self.assertRaises(ValueError):validate_url(u)
 def test_exact_raw_body_and_hash(self):
  m,c,o=self.meter([Response(b'abc')]);r=m.fetch('https://repo.packagist.org/packages.json',expected_sha256=hashlib.sha256(b'abc').hexdigest());self.assertEqual(r['path'].read_bytes(),b'abc');self.assertEqual(c.charged,3);self.assertEqual(len(o.requests),1)
 def test_redirect_body_and_hop_both_count(self):
  m,c,o=self.meter([Response(b'redirect',302,{'Location':'https://codeload.github.com/a/b/zip/ref'}),Response(b'zip')]);r=m.fetch('https://api.github.com/repos/a/b/zipball/ref',headers={'Authorization':'Bearer fixture'});self.assertEqual(c.charged,11);self.assertEqual(len(o.requests),2);self.assertNotIn('Authorization',o.requests[1].headers)
 def test_downgrade_rejected_after_counting_redirect_body(self):
  m,c,o=self.meter([Response(b'x',302,{'Location':'http://repo.packagist.org/a'})]);
  with self.assertRaises(ValueError):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(c.charged,1);self.assertEqual(len(o.requests),1)
 def test_error_body_consumed_and_preserved(self):
  m,c,o=self.meter([Response(b'not found',404)]);r=m.fetch('https://repo.packagist.org/a');self.assertEqual(r['status'],404);self.assertEqual(c.charged,9);self.assertEqual(r['path'].read_bytes(),b'not found')
 def test_request_exhaustion_refuses_before_open(self):
  m,c,o=self.meter([Response(b'x')],Control(request_limit=0))
  with self.assertRaises(RuntimeError):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(len(o.requests),0)
 def test_byte_reservation_refuses_before_body_read(self):
  r=Response(b'x');m,c,o=self.meter([r],Control(byte_limit=0))
  with self.assertRaises(RuntimeError):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(r.read_calls,0)
  self.assertEqual(len(o.requests),0)
 def test_digest_mismatch_never_returns_success(self):
  m,c,o=self.meter([Response(b'x')])
  with self.assertRaises(RuntimeError):m.fetch('https://getcomposer.org/download/a',expected_sha256='0'*64)
  self.assertEqual(c.charged,1)
 def test_incomplete_body_counts_partial_and_refuses(self):
  class Broken(Response):
   def read(self,n=-1):
    import http.client
    raise http.client.IncompleteRead(b'abc',5)
  m,c,o=self.meter([Broken(b'')])
  with self.assertRaises(Exception):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(c.charged,0);self.assertTrue(c.reserved)
 def test_no_implicit_retries_on_transport_error(self):
  class Broken(Opener):
   def open(self,request,timeout):self.requests.append(request);raise OSError('fixture failure')
  c=Control();o=Broken([]);m=Meter(c,self.root,opener=o)
  with self.assertRaises(OSError):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(len(o.requests),1)
 def test_received_block_preserved_when_stop_rejects_receipt(self):
  class Stopping(Control):
   def body_commit(self,n,actual):raise RuntimeError('STOP_SEALED')
  m,c,o=self.meter([Response(b'preserve')],Stopping())
  with self.assertRaises(RuntimeError):m.fetch('https://repo.packagist.org/a')
  self.assertEqual(next(self.root.glob('*.body')).read_bytes(),b'preserve');self.assertTrue(c.reserved)
 def test_invalid_content_length_closes_response(self):
  r=Response(b'x',headers={'Content-Length':'bad'});m,c,o=self.meter([r])
  with self.assertRaises(ValueError):m.fetch('https://repo.packagist.org/a')
  self.assertTrue(r.closed)
if __name__=='__main__':unittest.main()
