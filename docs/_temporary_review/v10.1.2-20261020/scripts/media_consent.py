import asyncio,json,pathlib,requests,websockets,base64,time,uuid
E=pathlib.Path(__file__).parent
s=json.loads((E/'subjects.private.json').read_text());sessions=json.loads((E/'login-sessions.private.json').read_text());receipts=[]
a=s['users']['A']['id'];b=s['users']['B']['id'];base='http://127.0.0.1:8015/api/v1'
def headers(actor):return {'Authorization':'Bearer '+sessions[actor]['access_token'],'Accept':'application/json'}
def call(actor,method,path,body=None,expected=200):
 r=requests.request(method,base+path,headers=headers(actor),json=body,timeout=15);j=r.json();receipts.append({'actor':actor,'method':method,'path':path,'status':r.status_code,'body':j});assert r.status_code in ([expected] if isinstance(expected,int) else expected),(path,r.status_code,j);return j
async def main():
 png=base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jN1kAAAAASUVORK5CYII=')
 r=requests.post(base+'/media',headers=headers('A'),data={'media_type':'image'},files={'file':('synthetic-pixel.png',png,'image/png')},timeout=20);j=r.json();receipts.append({'method':'POST','path':'/media','status':r.status_code,'body':j});assert r.status_code==200,(r.status_code,j)
 asset=j['asset']['id'];call('A','POST','/messages',{'receiver_id':b,'attachment_ids':[asset],'client_message_id':str(uuid.uuid4())},[200,201])
 r=requests.get(base+f'/media/{asset}/content',headers=headers('B'),timeout=10);assert r.status_code==200 and r.content==png;receipts.append({'method':'GET','path':f'/media/{asset}/content','actor':'B','status':200,'bytes':len(r.content)})
 callid=call('A','POST','/rtc/calls',{'peer_user_id':b,'mode':'voice'})['session']['id']
 uri=f'ws://127.0.0.1:8016/api/v1/messages/ws/{a}?peer_id={b}'
 async with websockets.connect(uri,additional_headers=headers('A'),proxy=None) as ws:
  greeting=json.loads(await asyncio.wait_for(ws.recv(),4));assert greeting['type']=='connected';start=time.monotonic()
  cn=call('A','GET',f'/connections/{b}');consent=cn['consent'];
  call('A','POST',f'/connections/{b}/consent',{'action':'revoke','expected_revision':consent['revision'],'expected_connection_id':cn['connection']['id'],'expected_consent_id':consent['id']})
  try:
   while True:await asyncio.wait_for(ws.recv(),5)
  except websockets.exceptions.ConnectionClosed:elapsed=time.monotonic()-start;assert elapsed<5
  receipts.append({'websocket':'connected_then_closed_after_MC_revocation','seconds':elapsed})
 call('A','POST','/messages',{'receiver_id':b,'content':'must refuse after MC revoke','client_message_id':str(uuid.uuid4())},404)
 call('A','POST','/messages',{'receiver_id':b,'attachment_ids':[asset],'client_message_id':str(uuid.uuid4())},404)
 r=requests.get(base+f'/media/{asset}/content',headers=headers('B'),timeout=10);assert r.status_code==404;receipts.append({'method':'GET','path':f'/media/{asset}/content','actor':'B','status':404,'private_png_absent':r.content!=png})
 call('A','POST','/rtc/calls',{'peer_user_id':b,'mode':'voice'},403)
 call('A','GET',f'/rtc/calls/{callid}/livekit',expected=404)
 try:
  async with websockets.connect(uri,additional_headers=headers('A'),proxy=None) as ws:
   await asyncio.wait_for(ws.recv(),3);raise AssertionError('old JWT reopened scoped WS')
 except (websockets.exceptions.ConnectionClosed,websockets.exceptions.InvalidHandshake):receipts.append({'websocket':'old_JWT_reconnect_denied'})
 (E/'media-consent-result.json').write_text(json.dumps(receipts,ensure_ascii=False,indent=2),encoding='utf8');print('MEDIA/WS/RTC current CN-MC grant and revoke chain verified; no RTC media or external server used')
try:asyncio.run(main())
finally:(E/'media-consent-attempt.json').write_text(json.dumps(receipts,ensure_ascii=False,indent=2),encoding='utf8')
