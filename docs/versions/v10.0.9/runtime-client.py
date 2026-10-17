"""Owned V1009 local API preparation. Tokens are kept exclusively under secrets/."""
import pathlib,json,sys,urllib.request,urllib.error
q=pathlib.Path(sys.argv[1]);accounts=json.loads((q/'secrets/accounts.json').read_text())['accounts']
sessions_path=q/'secrets/api-sessions.json'
sessions=json.loads(sessions_path.read_text()) if sessions_path.exists() else {}

def request(name,method,path,body=None):
    assert path.startswith('/api/v1/') and '..' not in path
    headers={'Content-Type':'application/json','Accept':'application/json'}
    if name in sessions:headers['Authorization']='Bearer '+sessions[name]['token']
    req=urllib.request.Request('http://127.0.0.1:8000'+path,data=json.dumps(body).encode() if body is not None else None,headers=headers,method=method)
    try:
        with urllib.request.urlopen(req,timeout=10) as r:return r.status,json.load(r)
    except urllib.error.HTTPError as r:
        try:return r.code,json.load(r)
        except Exception:return r.code,{}

if __name__=='__main__':
    action=sys.argv[2]
    if action=='login':
        for name in ['alice','bob','pending','admin']:
            status,data=request(name,'POST','/api/v1/auth/login',accounts[name]);assert status==200,(name,status)
            token=data.get('access_token') or data.get('token') or data.get('data',{}).get('access_token')
            assert token
            user=data.get('user') or data.get('data',{}).get('user');assert user
            sessions[name]={'token':token,'id':user['id']};print(name,'API login',status,'user',user['id'])
        sessions_path.write_text(json.dumps(sessions,indent=2))
    elif action=='renew':
        status,current=request('alice','GET','/api/v1/connections/'+str(sessions['bob']['id']));assert status==200
        assert current['connection']['state']=='CN_ACTIVE'
        assert current['consent']['state'] in ['MC_REVOKED','MC_DECLINED','MC_WITHDRAWN']
        for name,peer,operation,revision in [('alice','bob','request',current['consent']['revision']),('bob','alice','accept',1)]:
            status,data=request(name,'POST','/api/v1/connections/'+str(sessions[peer]['id'])+'/consent',{'action':operation,'expected_revision':revision})
            print(name,'independent consent',operation,status,data.get('consent',{}).get('state'));assert status==200
    elif action=='consent':
        for name,peer,kind,operation,revision in [('alice','bob','connection','request',0),('bob','alice','connection','accept',1),('alice','bob','consent','request',0),('bob','alice','consent','accept',1)]:
            status,data=request(name,'POST','/api/v1/connections/'+str(sessions[peer]['id'])+'/'+kind,{'action':operation,'expected_revision':revision})
            print(name,kind,operation,status,data.get(kind,{}).get('state'));assert status==200
    else:raise ValueError('Unknown action')
