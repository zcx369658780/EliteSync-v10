"""Host metadata pump, called only by the task controller, with no HTTP listener.

The isolated broker can request only package metadata/advisories, not arbitrary
URLs or host files. TLS, redirect and body accounting are always Meter's job.
"""
import base64,gzip,hashlib,json,os,re,time
from urllib.parse import parse_qs,urlencode

def target(request):
 path=request['path'];method=request['method'];query=request.get('query','');data=base64.b64decode(request.get('body_base64',''),validate=True)
 if len(data)>1048576:raise ValueError('BROKER_BODY_LIMIT')
 if method=='GET' and not query and (path=='/packages.json' or re.fullmatch(r'/p2/[a-z0-9_.-]+/[a-z0-9_.-]+(?:~dev)?\.json',path)):
  return 'https://repo.packagist.org'+path,None
 if path=='/security-advisories/' and method in ('GET','POST'):
  if method=='POST':
   content_type=request.get('content_type','').split(';',1)[0].lower()
   if content_type=='application/x-www-form-urlencoded':
    value=parse_qs(data.decode(),strict_parsing=True)
    if len(value)>301:raise ValueError('ADVISORY_FORM_SIZE')
    for key,values in value.items():
     if key=='allowPartialAdvisoryResults':
      if values not in (['1'],['0'],['true'],['false']):raise ValueError('ADVISORY_FLAG')
     elif re.fullmatch(r'packages\[(?:[0-9]*)\]',key):
      if len(values)>300 or any(not re.fullmatch('[a-z0-9_.-]+/[a-z0-9_.-]+',v) for v in values):raise ValueError('ADVISORY_NAMES')
     else:raise ValueError('ADVISORY_FORM_FIELD')
   elif content_type=='application/json' or data.startswith(b'{'):
    value=json.loads(data)
    if not isinstance(value,dict) or set(value)-{'packages','allowPartialAdvisoryResults'}:raise ValueError('ADVISORY_SHAPE')
    packages=value['packages']
    if not isinstance(packages,(dict,list)) or len(packages)>300:raise ValueError('ADVISORY_PACKAGES')
    pairs=packages.items() if isinstance(packages,dict) else [(name,'*') for name in packages]
    for name,version in pairs:
     if not isinstance(name,str) or not re.fullmatch('[a-z0-9_.-]+/[a-z0-9_.-]+',name) or not isinstance(version,str) or not re.fullmatch('[a-zA-Z0-9._+*^~<>=| -]{1,200}',version):raise ValueError('ADVISORY_PACKAGE')
   else:raise ValueError('ADVISORY_CONTENT_TYPE')
   return 'https://packagist.org/api/security-advisories/',data
  values=parse_qs(query,strict_parsing=True)
  if set(values)-{'packages[]','allowPartialAdvisoryResults'}:raise ValueError('ADVISORY_QUERY')
  if any(not re.fullmatch('[a-z0-9_.-]+/[a-z0-9_.-]+',v) for v in values.get('packages[]',[])):raise ValueError('ADVISORY_NAME')
  return 'https://packagist.org/api/security-advisories/?'+urlencode(values,doseq=True),None
 raise ValueError('BROKER_ROUTE')

def serve(control,meter,queue,stop_file):
 queue.mkdir(parents=True,exist_ok=True);handled=set();cache={}
 while not stop_file.exists():
  control.need(0<=time.monotonic_ns()-control.rows()[0]['tick_start_ns']<14400*10**9,'BROKER_WINDOW')
  for p in queue.glob('*.request'):
   if p.name in handled:continue
   if not re.fullmatch('[a-f0-9]{32}\.request',p.name):raise RuntimeError('BROKER_REQUEST_NAME')
   if (queue/(p.stem+'.reply')).is_file():handled.add(p.name);continue
   # A partial producer write is not consumed; producer fsync precedes close.
   try:request=json.loads(p.read_bytes())
   except json.JSONDecodeError:continue
   control.need(request['id']==p.stem,'BROKER_REQUEST_ID');url,data=target(request);key=hashlib.sha256((request['method']+url).encode()+(data or b'')).hexdigest()
   if key in cache:
    r=cache[key];control.event('SUPPLY_LOCAL_CACHE_HIT',upstream_request_id=r['request_id'],key=key)
   else:
    r=meter.fetch(url,method=request['method'],data=data,headers={'Content-Type':request.get('content_type') or 'application/json'} if data is not None else None,max_size=16777216)
    cache[key]=r
   body=r['path'].read_bytes();encoding=next((v for k,v in r['headers'].items() if k.lower()=='content-encoding'),'')
   if request['path']=='/packages.json' and r['status']==200:
    if encoding=='gzip':body=gzip.decompress(body)
    elif encoding not in ('','identity'):raise RuntimeError('METADATA_ENCODING')
    doc=json.loads(body);doc['metadata-url']='http://supply:8080/p2/%package%.json'
    if 'security-advisories' in doc:doc['security-advisories']['api-url']='http://supply:8080/security-advisories/'
    for k in ['notify','notify-batch','providers-api','search','list']:doc.pop(k,None)
    body=json.dumps(doc).encode();encoding=''
   if encoding not in ('','identity','gzip'):raise RuntimeError('METADATA_ENCODING')
   body_name=p.stem+'.body';rel=queue.relative_to(control.R).as_posix()+'/'+body_name
   control.write(rel,body);control.jwrite(queue.relative_to(control.R).as_posix()+'/'+p.stem+'.pending-reply',{'status':r['status'],'body':body_name,'encoding':encoding})
   control.event('PREPARE_BROKER_REPLY_COMMIT',id=p.stem)
   (queue/(p.stem+'.pending-reply')).rename(queue/(p.stem+'.reply'))
   handled.add(p.name)
  time.sleep(.02)
