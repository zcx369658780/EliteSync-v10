"""Bounded local diagnostic calls; token/cookie/credential material never enters receipts."""
import pathlib,json,sys,requests,hashlib,datetime
E=pathlib.Path(sys.argv[1]).resolve();ACTION=sys.argv[2]
BASE='http://127.0.0.1:8000'
config=json.loads((E/'secrets/configuration.json').read_text())
private=E/'secrets/api-identities.json'
identities=json.loads(private.read_text())if private.exists()else{}
def clean(value):
 if isinstance(value,dict):return {k:clean(v)for k,v in value.items()if not any(s in k.lower()for s in ['token','password','cookie','secret','authorization'])}
 if isinstance(value,list):return [clean(v)for v in value]
 return value
def call(role,method,path,body=None,headers=None):
 h={'Accept':'application/json'}
 if role:h['Authorization']='Bearer '+identities[role]['token']
 if headers:h.update(headers)
 r=requests.request(method,BASE+path,json=body,headers=h,timeout=40)
 try:payload=r.json()
 except ValueError:payload={'bytes':len(r.content),'sha256':hashlib.sha256(r.content).hexdigest()}
 return r.status_code,payload
if ACTION=='login':
 result={}
 for role in ['admin','alice','bob','incomplete']:
  status,payload=call(None,'POST','/api/v1/auth/login',config['accounts'][role])
  result[role]={'status':status,'body':clean(payload)}
  if status==200:
   token=payload.get('token') or payload.get('access_token')
   if not token:raise RuntimeError('missing authenticated result')
   identities[role]={'token':token,'user_id':payload.get('user',{}).get('id')}
 private.write_text(json.dumps(identities))
elif ACTION=='read':
 result={role:{p:{'status':s,'body':clean(b)}for p in ['/api/v1/profile/basic','/api/v1/questionnaire/progress','/api/v1/matches/current']for s,b in [call(role,'GET',p)]}for role in ['alice','bob','incomplete']}
else:raise ValueError('Unknown operation')
path=E/(ACTION+'-'+datetime.datetime.now().strftime('%Y%m%d-%H%M%S')+'.json')
path.write_text(json.dumps(result,ensure_ascii=False,indent=2))
print(json.dumps({'operation':ACTION,'receipt':path.name,'status':{k:v.get('status')if isinstance(v,dict)else None for k,v in result.items()}}))
