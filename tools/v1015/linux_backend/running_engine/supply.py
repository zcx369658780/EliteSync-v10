"""Task-private HTTPS supply transport; no automatic redirects or retries.

The injected control owns the single durable ledger. Every request and maximum
body read is fsynced before I/O; an interrupted read keeps its conservative
reservation. Bodies and credential-bearing URLs stay LOCAL_ONLY.
"""
import hashlib,http.client,os,re,urllib.request,urllib.error
from pathlib import Path
from urllib.parse import urlsplit,urljoin

HOSTS={'registry-1.docker.io','auth.docker.io','production.cloudflare.docker.com','production.cloudfront.docker.com',
       'getcomposer.org','repo.packagist.org','packagist.org','api.github.com',
       'github.com','codeload.github.com','objects.githubusercontent.com',
       'release-assets.githubusercontent.com','deb.debian.org'}
def validate_url(url):
 p=urlsplit(url)
 if p.scheme!='https' or p.username is not None or p.password is not None or p.port not in (None,443):raise ValueError('SUPPLY_URL_SCHEME_OR_AUTH')
 if p.hostname not in HOSTS and not re.fullmatch(r'docker-images-prod\.[0-9a-f]+\.r2\.cloudflarestorage\.com',p.hostname or ''):raise ValueError('SUPPLY_HOST_NOT_ALLOWLISTED')
 if p.fragment:raise ValueError('SUPPLY_FRAGMENT')
 return p
class NoRedirect(urllib.request.HTTPRedirectHandler):
 def redirect_request(self,req,fp,code,msg,headers,newurl):return None

class Meter:
 def __init__(self,control,root,opener=None):
  self.control=control;self.root=Path(root).resolve();self.root.mkdir(parents=True,exist_ok=True)
  self.opener=opener or urllib.request.build_opener(NoRedirect())
 def fetch(self,url,headers=None,expected_sha256=None,max_size=536870912,method='GET',data=None,follow_redirects=True):
  with self.control.activity():return self._fetch(url,headers,expected_sha256,max_size,method,data,follow_redirects)
 def _fetch(self,url,headers=None,expected_sha256=None,max_size=536870912,method='GET',data=None,follow_redirects=True):
  headers=dict(headers or {});headers.setdefault('Accept-Encoding','identity');headers.setdefault('User-Agent','EliteSync-v1015-task-supply/1')
  for hop in range(9):
   p=validate_url(url)
   if method not in ('GET','HEAD','POST'):raise ValueError('SUPPLY_METHOD')
   if method=='POST' and not (p.hostname=='packagist.org' and p.path.startswith('/api/security-advisories')):raise ValueError('SUPPLY_POST_ENDPOINT')
   if data is not None and len(data)>1048576:raise ValueError('SUPPLY_REQUEST_BODY_LIMIT')
   record=self.control.cost('supply_requests',url=url,method=method,header_names=sorted(headers),hop=hop)
   request_id=record['seq'];path=self.root/(str(request_id)+'.body')
   # Reserve the entire bounded response BEFORE opening the connection. This
   # covers bytes buffered while reading headers and unknown transport failures.
   reservation=self.control.body_prepare(max_size,request_id)
   self.control.event('PREPARE_SUPPLY_BODY_FILE',request_id=request_id,path=str(path))
   req=urllib.request.Request(url,data=data,headers=headers,method=method)
   try:
    try:response=self.opener.open(req,timeout=60)
    except urllib.error.HTTPError as e:response=e
   except Exception as e:
    self.control.event('SUPPLY_TRANSPORT_FAILURE',request_id=request_id,error_type=type(e).__name__,body_receipt='NOT_ESTABLISHED_NO_RETRY')
    raise
   digest=hashlib.sha256();got=0;status=response.getcode();rh=dict(response.headers.items());length=response.headers.get('Content-Length')
   try:
    expected_length=int(length) if length is not None else None
    if expected_length is not None and (expected_length<0 or expected_length>max_size):raise RuntimeError('SUPPLY_DECLARED_SIZE')
    with path.open('xb') as out:
     while method!='HEAD' and (expected_length is None or got<expected_length):
      n=min(1048576,max_size-got)
      if n==0:raise RuntimeError('SUPPLY_UNKNOWN_EOF_AT_CEILING')
      if expected_length is not None:n=min(n,expected_length-got)
      self.control.event('PREPARE_STREAM_READ',reservation=reservation,maximum=n,already_received=got)
      try:b=response.read(n)
      except http.client.IncompleteRead as e:
       b=e.partial;out.write(b);out.flush();os.fsync(out.fileno());self.control.event('SUPPLY_INCOMPLETE_BODY',request_id=request_id,partial_bytes=got+len(b),conservative_reservation_kept=True);raise
      # Preserve received evidence before a STOP/expiry can reject the receipt.
      # On receipt failure the already-fsynced maximum reservation stays charged.
      out.write(b);out.flush();os.fsync(out.fileno());got+=len(b);digest.update(b)
      if got>max_size:raise RuntimeError('SUPPLY_BODY_SIZE')
      if not b:break
     out.flush();os.fsync(out.fileno())
    if expected_length is not None and method!='HEAD' and got!=expected_length:raise RuntimeError('SUPPLY_TRUNCATED_BODY')
   except Exception as e:
    # Preserve any pending conservative reservation and original body file.
    try:self.control.event('SUPPLY_BODY_FAILURE',request_id=request_id,error_type=type(e).__name__,received_count=got)
    except Exception:pass
    raise
   finally:response.close()
   self.control.body_commit(reservation,got)
   value={'request_id':request_id,'path':path,'status':status,'headers':rh,'sha256':digest.hexdigest(),'bytes':got,'url':url}
   self.control.event('SUPPLY_RESPONSE',request_id=request_id,status=status,bytes=got,sha256=digest.hexdigest(),headers_local_only=rh)
   if status in (301,302,303,307,308) and follow_redirects:
    location=response.headers.get('Location')
    if not location:raise RuntimeError('SUPPLY_REDIRECT_WITHOUT_LOCATION')
    newurl=urljoin(url,location)
    self.control.event('SUPPLY_REDIRECT',request_id=request_id,target_url_local_only=newurl)
    q=validate_url(newurl)
    if q.hostname!=p.hostname:headers={k:v for k,v in headers.items() if k.lower() not in ('authorization','cookie')}
    if status==303:method='GET';data=None
    url=newurl;continue
   if expected_sha256 is not None and digest.hexdigest()!=expected_sha256:raise RuntimeError('SUPPLY_DIGEST_MISMATCH')
   return value
  raise RuntimeError('SUPPLY_REDIRECT_LIMIT')
