import sys,pathlib,json
sys.path.insert(0,str(pathlib.Path.cwd()/'tests/Integration/v1015'))
from journey import login,request,receipts
b=login(2,'v1015-old-notification-final');items=request('GET','/api/v1/notifications',b['access_token']).json()['items'];old=[x for x in items if x['kind']=='message'];assert not old
print(json.dumps({'result':'PASS_OLD_MESSAGE_NOTIFICATIONS_HIDDEN_AFTER_REVOKE_BLOCK','old_message_cards':len(old),'receipts':receipts},indent=2))
