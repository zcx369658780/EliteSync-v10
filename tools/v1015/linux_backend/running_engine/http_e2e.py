"""Task-only real loopback HTTP driver; all raw credentials remain LOCAL_ONLY."""
import os,sys,json,urllib.request,urllib.error,urllib.parse,urllib.response,http.cookiejar,base64,uuid,time,io,email.message
from pathlib import Path
R=Path(__file__).resolve().parent
sys.path.insert(0,str(R));import owned as o
sys.path.insert(0,str(R/'source/tools/v1015/linux_backend/running_engine'))
from engine import Engine,PREFIX
BASE='http://127.0.0.1:56705'
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,*a,**k):return None
class LoopbackRelay(urllib.request.HTTPHandler):
 def http_open(self,request):
  o.need(request.host=='127.0.0.1:56705','TASK_HTTP_HOST')
  identifier=uuid.uuid4().hex;rel='work/backend/storage/app/task-http-queue/'+identifier
  o.jwrite(rel+'.pending',{'method':request.get_method(),'path':request.selector,'headers':[k+': '+v for k,v in request.header_items()],'body_b64':base64.b64encode(request.data).decode() if request.data is not None else None})
  o.event('PREPARE_HTTP_REQUEST_ATOMIC_RENAME',source=rel+'.pending',destination=rel+'.request.json');os.replace(R/(rel+'.pending'),R/(rel+'.request.json'))
  reply=R/(rel+'.response.json');deadline=time.monotonic()+45
  while not reply.exists():
   o.need(time.monotonic()<deadline,'LOOPBACK_RELAY_TIMEOUT');time.sleep(.05)
  value=json.loads(reply.read_text(encoding='utf-8'));o.need('error' not in value,'LOOPBACK_RELAY_ERROR '+value.get('error',''))
  headers=email.message.Message()
  for line in value['headers']:
   if ':' in line:
    k,v=line.split(':',1);headers.add_header(k,v.strip())
  response=urllib.response.addinfourl(io.BytesIO(base64.b64decode(value['body_b64'])),headers,request.full_url,value['status']);response.msg='Task loopback HTTP';return response
class Client:
 def __init__(self,token=None):
  self.token=token;self.jar=http.cookiejar.CookieJar();self.opener=urllib.request.build_opener(urllib.request.ProxyHandler({}),LoopbackRelay(),NoRedirect(),urllib.request.HTTPCookieProcessor(self.jar))
 def request(self,name,method,path,data=None,status=200,form=False,headers=None):
  o.need(path.startswith('/') and not path.startswith('//'),'HTTP_PATH')
  h={'Accept':'application/json'};h.update(headers or {})
  if self.token:h['Authorization']='Bearer '+self.token
  if isinstance(data,bytes):body=data
  elif data is not None:
   body=urllib.parse.urlencode(data).encode() if form else json.dumps(data).encode();h['Content-Type']='application/x-www-form-urlencoded' if form else 'application/json'
  else:body=None
  prepared=o.cost('http',name=name,method=method,path=path);seq=prepared['seq']
  try:
   try:response=self.opener.open(urllib.request.Request(BASE+path,data=body,headers=h,method=method),timeout=25)
   except urllib.error.HTTPError as ex:response=ex
   with response:
    raw=response.read(2097153);code=response.status;rh=dict(response.headers);o.need(len(raw)<=2097152,'HTTP_RESPONSE_LIMIT')
  except Exception as ex:
   o.jwrite('runtime/http/'+str(seq)+'-'+name+'-LOCAL_ONLY.json',{'error':type(ex).__name__,'message':str(ex)});raise
  o.jwrite('runtime/http/'+str(seq)+'-'+name+'-LOCAL_ONLY.json',{'method':method,'path':path,'request_headers':h,'request_body_b64':base64.b64encode(body or b'').decode(),'status':code,'headers':rh,'body_b64':base64.b64encode(raw).decode()})
  o.event('HTTP_RESULT',name=name,status=code,response_bytes=len(raw),body_sha256=o.sha(raw));print(name,code,flush=True)
  allowed=(status,) if isinstance(status,int) else status;o.need(code in allowed,'HTTP_STATUS '+name+' expected '+str(allowed)+' got '+str(code))
  try:value=json.loads(raw)
  except (ValueError,UnicodeDecodeError):value=None
  return value,raw,rh
 def cookie_header(self):return '; '.join(c.name+'='+c.value for c in self.jar)
def fixture(mode,name=None):
 e=Engine(o);result,b,err=e.call(name or 'http-fixture-'+mode,['exec',PREFIX+'-api','timeout','--kill-after=5','60','php','tests/E2E/running_docker_fixture.php',mode],timeout=70,categories=('php_cli',))
 o.need(result['exit']==0,'FIXTURE_'+mode);value=json.loads(b);o.jwrite('runtime/'+(name or 'http-fixture-'+mode)+'-LOCAL_ONLY.json',value);return value
def save(name,value):o.jwrite('runtime/'+name+'-LOCAL_ONLY.json',value,replace=(R/'runtime'/ (name+'-LOCAL_ONLY.json')).exists())
def load(name):return json.loads((R/'runtime'/(name+'-LOCAL_ONLY.json')).read_text(encoding='utf-8'))
def login(name,phone,device):
 secret=json.loads((R/'runtime/qualification.json').read_text(encoding='utf-8'));v,_,_=Client().request('login-'+name,'POST','/api/v1/auth/login',{'phone':phone,'password':secret['fixture_password'],'device_id':device});o.need(v['session_retention']['login_at'] and v['session_retention']['online_expires_at'],'TRUSTED_T0');return v
PNG=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a2ioAAAAASUVORK5CYII=')
def upload(client,name):
 boundary='task'+uuid.uuid4().hex;body=('--'+boundary+'\r\nContent-Disposition: form-data; name="media_type"\r\n\r\nimage\r\n--'+boundary+'\r\nContent-Disposition: form-data; name="file"; filename="synthetic.png"\r\nContent-Type: image/png\r\n\r\n').encode()+PNG+('\r\n--'+boundary+'--\r\n').encode()
 v,_,_=client.request('upload-'+name,'POST','/api/v1/media',body,headers={'Content-Type':'multipart/form-data; boundary='+boundary});o.need(v['asset']['status']=='ready','REAL_IMAGE_READY');return v['asset']['id']
def csrf(raw):
 import re
 m=re.search(rb'name="_token"\s+value="([^"]+)"',raw);o.need(m is not None,'CSRF_FORM');return m.group(1).decode()
