import json, sys, urllib.request, urllib.error
from pathlib import Path
root = Path(__file__).parent
creds = json.loads((root/'secrets/credentials.json').read_text(encoding='utf8'))
base = 'http://127.0.0.1:8000/api/v1'
token_file = root/'secrets/probe_tokens.json'
tokens = json.loads(token_file.read_text()) if token_file.exists() else {}
def request(method, path, data=None, token=None):
    headers = {'Accept':'application/json'}
    if data is not None: headers['Content-Type']='application/json'
    if token: headers['Authorization']='Bearer '+token
    req = urllib.request.Request(base+path, data=json.dumps(data).encode() if data is not None else None, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req,timeout=30) as r: return r.status,json.loads(r.read())
    except urllib.error.HTTPError as e: return e.code,json.loads(e.read())
out=[]
phase=sys.argv[1]
if phase=='before':
    for role in ['target','control']:
        status, data=request('POST','/auth/login',creds['accounts'][role]); assert status==200,(role,status)
        tokens[role]=data['access_token']
        out.append({'operation':'login','role':role,'status':status,'user_id':data['user']['id'],'city':data['user']['city']})
    token_file.write_text(json.dumps(tokens))
elif phase=='invalid':
    status,data=request('POST','/profile/city',{'city':''},tokens['target'])
    assert status==422,status
    out.append({'operation':'invalid city','status':status,'data':data})
    status,data=request('GET','/profile/basic',token=tokens['target'])
    out.append({'operation':'read after invalid city','status':status,'data':data})
elif phase in ['read','after']:
    for role in ['target','control']:
        status,data=request('GET','/profile/basic',token=tokens[role])
        out.append({'operation':'profile/basic','role':role,'status':status,'data':data})
    if phase=='after':
        for method,path,payload in [('POST','/profile/city',{'city':'Forbidden'}),('POST','/auth/refresh',{})]:
            status,data=request(method,path,payload,tokens['target']); assert status in [401,403],status
            out.append({'operation':path,'status':status,'data':data})
        for role in ['target','control']:
            status,data=request('POST','/auth/login',creds['accounts'][role]); assert status==(403 if role=='target' else 200),status
            out.append({'operation':'new login','role':role,'status':status,'user_id':data.get('user',{}).get('id')})
else: raise ValueError(phase)
safe=json.dumps(out,ensure_ascii=True,indent=2)
label=sys.argv[2] if len(sys.argv)>2 else phase
assert all(c.isalnum() or c in '-_' for c in label)
dest=root/('api-'+label+'.json')
if dest.exists(): raise RuntimeError('Evidence already exists; choose a fresh label')
dest.write_text(safe)
print(safe)
