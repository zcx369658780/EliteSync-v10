import pathlib,json,uuid,urllib.request,urllib.error,base64
E=pathlib.Path(__file__).parent
src=(E/'http-matrix.py').read_text().split('for who in accounts:')[0]
exec(src)
receipts=[]
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
sessions['charlie']=call('charlie','POST','/auth/login',accounts['charlie'])
b=sessions['bob']['user']['id']; c=sessions['charlie']['user']['id']
p=call('charlie','GET','/privacy'); assert p['revision']>=1
call('charlie','POST','/social/preferences',{'requests_enabled':True})
i=call('charlie','POST','/social/invites',{'purpose':'friendship'},expected=(201,))
r=call('bob','POST','/social/requests',{'purpose':'friendship','invitation_token':i['token'],'idempotency_key':'bc-'+str(uuid.uuid4())},expected=(201,))
call('charlie','POST',f'/social/requests/{r["id"]}/accept')
for kind in ['connection','consent']:
    current=call('bob','GET',f'/connections/{c}')[kind]
    d={'action':'request','expected_revision':current['revision'] if current else 0}
    if current:d['expected_'+kind+'_id']=current['id']
    pending=call('bob','POST',f'/connections/{c}/{kind}',d)[kind]
    call('charlie','POST',f'/connections/{b}/{kind}',{'action':'accept','expected_revision':pending['revision'],'expected_'+kind+'_id':pending['id']})
call('bob','POST','/messages',{'receiver_id':c,'content':'Controlled hide fixture','client_message_id':str(uuid.uuid4())},expected=(200,201))
conversations=call('charlie','GET','/conversations')
(E/'secrets/conversation-response.json').write_text(json.dumps(conversations))
# Capture actual serialized shape before asserting view changes.
print(json.dumps({'conversation_keys':list(conversations),'privacy_revision_saved_by_app':p['revision']}))
png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jG1sAAAAASUVORK5CYII=')
boundary='controlled-'+uuid.uuid4().hex
body=(f'--{boundary}\r\nContent-Disposition: form-data; name="media_type"\r\n\r\nimage\r\n--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="controlled.png"\r\nContent-Type: image/png\r\n\r\n').encode()+png+f'\r\n--{boundary}--\r\n'.encode()
req=urllib.request.Request('http://127.0.0.1:8012/api/v1/media',body,{'Accept':'application/json','Content-Type':'multipart/form-data; boundary='+boundary,'Authorization':'Bearer '+sessions['bob']['access_token']})
with urllib.request.urlopen(req,timeout=30) as response: asset=json.load(response)['asset']
assert asset['storage_disk']=='v1011_relationship'
post=call('bob','POST','/status/posts',{'title':'Controlled image','body':'Fictional private media','audience':'FRIENDS','cover_media_asset_id':asset['id']},expected=(201,))['item']
def content(expected):
    req=urllib.request.Request('http://127.0.0.1:8012/api/v1/media/'+str(asset['id'])+'/content',headers={'Authorization':'Bearer '+sessions['charlie']['access_token'],'Accept':'application/json'})
    try:
        with urllib.request.urlopen(req) as r: code,data=r.status,r.read()
    except urllib.error.HTTPError as r:code,data=r.code,r.read()
    assert code==expected,(code,expected)
    if expected==200:assert data==png
    receipts.append({'actor':'charlie','path':'private-cover-bytes','status':code,'pass':True})
content(200)
call('bob','PUT',f'/status/posts/{post["id"]}/audience',{'audience':'SELF'}); content(404)
call('bob','PUT',f'/status/posts/{post["id"]}/audience',{'audience':'FRIENDS'});content(200)
call('bob','DELETE',f'/social/friends/{c}');content(404)
(E/'http-more-results.json').write_text(json.dumps(receipts,indent=2))
(E/'secrets/http-sessions.json').write_text(json.dumps(sessions))
print(json.dumps({'checks':len(receipts),'all_pass':True}))
