import pathlib,json,uuid,base64,urllib.request
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
sessions['charlie']=call('charlie','POST','/auth/login',accounts['charlie'])
f=json.loads((E/'secrets/closure-fixtures.json').read_text())
held=call('alice','POST','/status/posts',{'title':'Held fictional evidence title','body':'HELD_ORIGINAL_BODY_KEEP','audience':'SELF','cover_media_asset_id':f['assets'][2]['id']},expected=(201,))['item']
f['held_post']=held['id']
call('alice','POST','/social/preferences',{'requests_enabled':True})
i=call('alice','POST','/social/invites',{'purpose':'friendship'},expected=(201,))
r=call('charlie','POST','/social/requests',{'purpose':'friendship','invitation_token':i['token'],'idempotency_key':'case-fixture-'+str(uuid.uuid4())},expected=(201,))
call('alice','POST',f'/social/requests/{r["id"]}/accept')
png=(E/'secrets/closure-original.png').read_bytes(); boundary='fixture-'+uuid.uuid4().hex
body=(f'--{boundary}\r\nContent-Disposition: form-data; name="media_type"\r\n\r\nimage\r\n--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="case-fixture.png"\r\nContent-Type: image/png\r\n\r\n').encode()+png+f'\r\n--{boundary}--\r\n'.encode()
req=urllib.request.Request('http://127.0.0.1:8012/api/v1/media',body,{'Accept':'application/json','Content-Type':'multipart/form-data; boundary='+boundary,'Authorization':'Bearer '+sessions['alice']['access_token']})
with urllib.request.urlopen(req,timeout=30) as r:a=json.load(r)['asset']
f['assets'].append({'label':'reported-post','id':a['id'],'key':a['storage_key'],'disk':a['storage_disk'],'sha256':a['sha256']})
post=call('alice','POST','/status/posts',{'title':'Reported fictional evidence title','body':'REPORTED_ORIGINAL_BODY_KEEP','audience':'FRIENDS','cover_media_asset_id':a['id']},expected=(201,))['item']
f['reported_post']=post['id']
report=call('charlie','POST',f'/status/posts/{post["id"]}/report',{'reason_code':'spam','detail':'Controlled fictional evidence-retention exercise'})
f['report_id']=report['report']['id']
(E/'secrets/closure-fixtures.json').write_text(json.dumps(f));(E/'secrets/http-sessions.json').write_text(json.dumps(sessions))
(E/'closure-evidence-prepared.json').write_text(json.dumps({'held_post':True,'reported_post':True,'report_created':True,'all_registered_fictional':True}))
print('HELD_AND_REPORTED_FICTIONAL_EVIDENCE_PREPARED')
