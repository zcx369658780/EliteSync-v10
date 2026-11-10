"""Supplemental real local HTTP matrix. Does not stand in for dual APP media."""
import pathlib,sys,json,importlib.util,time,uuid
q=pathlib.Path(sys.argv[1]);phase=sys.argv[2]
s=importlib.util.spec_from_file_location('c',pathlib.Path(__file__).with_name('runtime-client.py'));c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
checks=[]
def check(name,actor,method,path,body,expected):
    status,data=c.request(actor,method,path,body);checks.append({'name':name,'status':status,'expected':expected,'time':time.time()});assert status in expected,(name,status);return data
if phase=='disabled':
    check('disabled old token','bob','GET','/api/v1/rtc/calls',None,[401])
    check('disabled fresh login','bob','POST','/api/v1/auth/login',c.accounts['bob'],[403])
    check('disabled peer new call','alice','POST','/api/v1/rtc/calls',{'peer_user_id':3,'mode':'video'},[403])
    check('match alone no RTC','pending','POST','/api/v1/rtc/calls',{'peer_user_id':2,'mode':'video'},[403])
elif phase=='restored-login':
    check('restore does not restore old token','bob','GET','/api/v1/rtc/calls',None,[401])
    data=check('explicit new login','bob','POST','/api/v1/auth/login',c.accounts['bob'],[200])
    token=data.get('access_token') or data.get('token') or data.get('data',{}).get('access_token');assert token
    c.sessions['bob']={'id':3,'token':token};c.sessions_path.write_text(json.dumps(c.sessions,indent=2))
elif phase=='restricted':
    check('restricted login valid','bob','GET','/api/v1/profile/basic',None,[200])
    check('restricted history read','bob','GET','/api/v1/conversation-peers/2',None,[200])
    check('restricted new send denied','bob','POST','/api/v1/messages',{'receiver_id':2,'content':'V1009 denied restricted send','client_message_id':str(uuid.uuid4())},[403,404])
    check('restricted new RTC denied','bob','POST','/api/v1/rtc/calls',{'peer_user_id':2,'mode':'video'},[403])
    data=check('restricted own sanctions','bob','GET','/api/v1/moderation/sanctions',None,[200])
    sanctions=data['items'];assert sanctions
    sid=sanctions[0]['id']
    check('own appeal survives restrict','bob','POST',f'/api/v1/moderation/sanctions/{sid}/appeals',{'note':'V1009 fictional permission regression appeal'},[200,201])
    check('appeal does not restore RTC','bob','POST','/api/v1/rtc/calls',{'peer_user_id':2,'mode':'video'},[403])
else:raise ValueError('unknown phase')
(q/('runtime-matrix-'+phase+'.json')).write_text(json.dumps({'kind':'SUPPLEMENTAL_REAL_HTTP_NOT_MEDIA','checks':checks},indent=2));print(json.dumps(checks))
