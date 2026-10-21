import sys,json,uuid,pathlib
sys.path.insert(0,str(pathlib.Path.cwd()/'tests/Integration/v1015'))
from journey import login,request,receipts
a,b=[login(i,'v1015-final-block-'+str(i)) for i in (1,2)];ta,tb=a['access_token'],b['access_token']
state=request('GET','/api/v1/connections/2',ta).json();assert state['connection']['state']=='CN_CLOSED',state['connection']['state']
request('POST','/api/v1/moderation/blocks',tb,json={'blocked_user_id':1,'reason_code':'V1015_SYNTHETIC_TEST'})
for token,peer in ((ta,2),(tb,1)):
 request('GET',f'/api/v1/messages?peer_id={peer}',token,expected=404)
 request('POST','/api/v1/messages',token,expected=404,json={'receiver_id':peer,'content':'block-must-deny','client_message_id':str(uuid.uuid4())})
for asset in (2,3):
 request('GET',f'/api/v1/media/{asset}/content',tb,expected=404)
 request('GET',f'/api/v1/media/{asset}/content',tb,expected=404,headers={'Range':'bytes=0-31'})
request('POST','/api/v1/auth/logout',ta)
request('GET','/api/v1/profile/basic',ta,expected=401)
print(json.dumps({'result':'PASS_REAL_BLOCK_CLOSED_CN_OLD_MEDIA_DENIAL','connection_state_before_block':state['connection']['state'],'consent_state_before_block':state['consent']['state'],'permissions_not_restored':True,'receipts':receipts},indent=2))
