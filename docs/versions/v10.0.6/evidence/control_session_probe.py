import json, urllib.request, urllib.error
from pathlib import Path
root=Path(__file__).parent
creds=json.loads((root/'secrets/credentials.json').read_text(encoding='utf8'))
tokens=json.loads((root/'secrets/probe_tokens.json').read_text())
def call(method,path,data=None,token=None,cookie=None):
    h={'Accept':'application/json'}
    if token: h['Authorization']='Bearer '+token
    if cookie: h['Cookie']=cookie
    if data is not None: h['Content-Type']='application/json'
    req=urllib.request.Request('http://127.0.0.1:8000'+path,headers=h,method=method,data=json.dumps(data).encode() if data is not None else None)
    try:
        with urllib.request.urlopen(req,timeout=30) as r: return r.status,r.read()
    except urllib.error.HTTPError as e: return e.code,e.read()
out=[]
status,body=call('POST','/api/v1/profile/city',{'city':'V1006 Control City'},tokens['control']); assert status==200,status
out.append({'operation':'control city POST','user_id':3,'status':status})
status,body=call('GET','/api/v1/profile/basic',token=tokens['control']); d=json.loads(body); assert status==200 and d['city']=='V1006 Control City'
out.append({'operation':'control city readback','user_id':d['id'],'city':d['city'],'status':status})
c=json.loads((root/'secrets/target_web_session.json').read_text())
status,body=call('GET','/admin',cookie=c['name']+'='+c['value']); assert status in [401,403],status
out.append({'operation':'revoked ordinary target session request','status':status,'fixture':'explicit Laravel ordinary session setup; never admin authorization'})
dest=root/'control-session-after-ban.json'; assert not dest.exists(); dest.write_text(json.dumps(out,indent=2)); print(json.dumps(out))
