import json, pathlib, urllib.request, urllib.error, uuid, datetime
E=pathlib.Path(__file__).parent
accounts=json.loads((E/'secrets/accounts.json').read_text())['accounts']
sessions={}
receipts=[]
def call(who,method,path,data=None,expected=(200,),token=None):
    headers={'Accept':'application/json','Content-Type':'application/json'}
    bearer=token if token is not None else sessions.get(who,{}).get('access_token')
    if bearer: headers['Authorization']='Bearer '+bearer
    req=urllib.request.Request('http://127.0.0.1:8012/api/v1'+path,data=json.dumps(data).encode() if data is not None else None,headers=headers,method=method)
    try:
        with urllib.request.urlopen(req,timeout=35) as r: code,body=r.status,r.read()
    except urllib.error.HTTPError as r: code,body=r.code,r.read()
    result=json.loads(body)
    receipts.append({'actor':who,'method':method,'path':path,'status':code,'expected':list(expected),'pass':code in expected})
    (E/'http-matrix-results.json').write_text(json.dumps(receipts,indent=2))
    if code not in expected:
        (E/'secrets/http-failure.json').write_text(json.dumps(result))
        raise AssertionError(f'{who} {method} {path}: {code}, expected {expected}')
    return result
for who in accounts:
    sessions[who]=call(who,'POST','/auth/login',accounts[who])
    assert sessions[who]['access_token']
(E/'secrets/http-sessions.json').write_text(json.dumps(sessions))
a=sessions['alice']['user']['id']; b=sessions['bob']['user']['id']; c=sessions['charlie']['user']['id']
call('bob','GET','/social')
call('charlie','GET',f'/profile-peers/{a}',expected=(404,))
call('alice','POST','/messages',{'receiver_id':b,'content':'must deny before independent grants','client_message_id':str(uuid.uuid4())},expected=(404,))
for kind in ['connection','consent']:
    current=call('alice','GET',f'/connections/{b}')
    row=current[kind]
    payload={'action':'request','expected_revision':row['revision'] if row else 0}
    if row: payload['expected_'+kind+'_id']=row['id']
    pending=call('alice','POST',f'/connections/{b}/{kind}',payload)[kind]
    call('bob','POST',f'/connections/{a}/{kind}',{'action':'accept','expected_revision':pending['revision'],'expected_'+kind+'_id':pending['id']})
msg=call('alice','POST','/messages',{'receiver_id':b,'content':'fictional controlled persistent message','client_message_id':str(uuid.uuid4())},expected=(200,201))
post=call('bob','POST','/status/posts',{'title':'Fictional controlled post','body':'Audience contract fixture','audience':'FRIENDS'},expected=(201,))['item']
call('alice','GET',f'/status/posts/{post["id"]}')
call('charlie','GET',f'/status/posts/{post["id"]}',expected=(404,))
call('alice','POST',f'/status/posts/{post["id"]}/likes')
call('bob','PUT',f'/status/posts/{post["id"]}/audience',{'audience':'SELF'})
call('alice','GET',f'/status/posts/{post["id"]}',expected=(404,))
call('bob','GET','/notifications/unread-count')
call('alice','GET','/privacy')
call('alice','GET','/privacy/preview?audience=partner')
call('alice','GET',f'/profile-peers/{b}?as_partner=true',expected=(422,))
call('alice','DELETE',f'/social/friends/{b}')
call('alice','POST','/messages',{'receiver_id':b,'content':'unfriend preserves independent grants','client_message_id':str(uuid.uuid4())},expected=(200,201))
call('bob','POST','/moderation/blocks',{'blocked_user_id':a})
call('alice','POST','/messages',{'receiver_id':b,'content':'blocked denial','client_message_id':str(uuid.uuid4())},expected=(403,404,409,423))
call('alice','GET',f'/profile-peers/{b}',expected=(404,))
call('alice','GET','/account/sessions')
old=dict(sessions['charlie'])
call('charlie','POST','/auth/logout')
call('charlie','GET','/privacy',expected=(401,),token=old['access_token'])
call('charlie','POST','/auth/refresh',expected=(401,),token=old['refresh_token'])
print(json.dumps({'checks':len(receipts),'all_pass':all(r['pass'] for r in receipts),'time':datetime.datetime.now(datetime.timezone.utc).isoformat()}))
