import json,time,uuid,requests,pathlib
from websockets.sync.client import connect
from websockets.exceptions import ConnectionClosed,InvalidHandshake
R=pathlib.Path(__file__).resolve().parent
BASE='http://127.0.0.1:8041/api/v1'
log=(R/'ws-authority-events.jsonl').open('x',encoding='utf-8')
def emit(d):log.write(json.dumps(d)+'\n');log.flush()
def req(method,path,token=None,expected=200,**kw):
 h={'Accept':'application/json'}
 if token:h['Authorization']='Bearer '+token
 r=requests.request(method,BASE+path,headers=h,timeout=8,**kw)
 emit({'step':method+' '+path,'status':r.status_code,'time':time.time()})
 assert r.status_code==expected,(path,r.status_code)
 return r.json()
def login(i):
 credentials=json.loads((R/'LOCAL_ONLY_SYNTHETIC_CREDENTIALS.json').read_text())[str(i)]
 return req('POST','/auth/login',json={**credentials,'device_id':'long-ws-'+str(i)})['access_token']
def ws(t):return connect('ws://127.0.0.1:8042/api/v1/messages/ws/1?peer_id=2',additional_headers={'Authorization':'Bearer '+t},proxy=None,open_timeout=4,close_timeout=1)
try:
 a,b=login(1),login(2)
 w=ws(a);first=json.loads(w.recv(timeout=4));assert first['type']=='connected';w.close();emit({'initial':'connected','closedClient':True})
 w=ws(a);assert json.loads(w.recv(timeout=4))['type']=='connected';emit({'reconnected':'connected'})
 sent=req('POST','/messages',b,json={'receiver_id':1,'content':'LONG_SYNTHETIC_WS','client_message_id':str(uuid.uuid4())})
 while True:
  event=json.loads(w.recv(timeout=4));assert set(event)=={'type','id'} and event['type']=='conversation_changed'
  emit({'pointer':event})
  if event['id']==sent['id']:break
 assert req('GET','/messages?peer_id=2',a)['items']
 c=req('GET','/connections/2',a);cn,mc=c['connection'],c['consent']
 req('POST','/connections/2/consent',a,json={'action':'revoke','expected_revision':mc['revision'],'expected_connection_id':cn['id'],'expected_consent_id':mc['id']})
 committed=time.monotonic();closed=False
 while time.monotonic()-committed<5:
  try:
   event=json.loads(w.recv(timeout=max(.1,5-(time.monotonic()-committed))))
   assert set(event)=={'type','id'} and event['type']=='conversation_changed' and event['id']<=sent['id']
   emit({'alreadyQueuedMinimalPointerAfterRevoke':event})
  except ConnectionClosed:closed=True;break
 assert closed,'ACTIVE_SOCKET_NOT_CLOSED'
 elapsed=time.monotonic()-committed;emit({'activeSocketClosed':True,'secondsAfterRevokeResponse':elapsed});w.close()
 req('GET','/messages?peer_id=2',a,expected=404)
 denied=False;denial=''
 try:
  z=ws(a)
  try:
   event=z.recv(timeout=4)
   raise AssertionError('REVOKED_CONNECTION_RECEIVED_FRAME')
  except ConnectionClosed:denied=True;denial='UPGRADED_THEN_CLOSED_WITHOUT_CONNECTED'
  finally:z.close()
 except InvalidHandshake as e:denied=True;denial=type(e).__name__
 assert denied;emit({'revokedReconnectDenied':True,'wireOutcome':denial,'connectedOrPrivateFrame':False})
 # Restore consent only through current authoritative transition contract.
 c=req('GET','/connections/2',a);cn,mc=c['connection'],c['consent']
 req('POST','/connections/2/consent',a,json={'action':'request','expected_revision':mc['revision'],'expected_connection_id':cn['id'],'expected_consent_id':mc['id']})
 c=req('GET','/connections/1',b);cn,mc=c['connection'],c['consent']
 req('POST','/connections/1/consent',b,json={'action':'accept','expected_revision':mc['revision'],'expected_connection_id':cn['id'],'expected_consent_id':mc['id']})
 emit({'restoredThroughRealApi':True})
 result={'result':'PASS','source':'NEW_RUN_REAL_HTTP_MARIADB_WS','initialAndReconnect':True,'minimalPointer':True,'activeCloseSeconds':elapsed,'revokedReconnectDenied':True,'wireOutcome':denial,'oldHttpDenied':404,'notRtcMediaProof':True}
 (R/'ws-authority-result.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
except Exception as e:
 emit({'result':'FAIL','exceptionType':type(e).__name__});raise
finally:log.close()
