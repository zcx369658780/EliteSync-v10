from http_e2e import *
import re
seed=load('seed-receipt');state={'tokens':{},'pairs':seed['pairs'],'messages':{},'media':{}}
for name,pair in seed['pairs'].items():
 for side,user in pair.items():
  key=name+'-'+side;state['tokens'][key]=login(key,user['phone'],'task-running-'+key);save('http-state',state)
a=state['tokens']['base-a'];old=dict(a)
fresh,_,_=Client(a['refresh_token']).request('refresh-valid','POST','/api/v1/auth/refresh',{})
for k in ['user_id','device_id','login_at','online_expires_at','purge_at','session_id']:o.need(fresh['session_retention'][k]==a['session_retention'][k],'REFRESH_T0_'+k)
Client(old['refresh_token']).request('refresh-old-denied','POST','/api/v1/auth/refresh',{},status=401)
Client(old['access_token']).request('access-old-denied','GET','/api/v1/notifications',status=401)
state['tokens']['base-a']=fresh;save('http-state',state)
for name in ['base','block','mc','cn']:
 pair=state['pairs'][name];ca=Client(state['tokens'][name+'-a']['access_token']);cb=Client(state['tokens'][name+'-b']['access_token'])
 asset=upload(ca,name);state['media'][name]=asset
 body={'receiver_id':pair['b']['id'],'content':'TASK-SYNTHETIC-'+name,'client_message_id':str(uuid.uuid4()),'attachment_ids':[asset]}
 first,_,_=ca.request('message-first-'+name,'POST','/api/v1/messages',body);state['messages'][name]={'body':body,'id':first['id']};save('http-state',state)
 v,_,_=ca.request('message-replay-'+name,'POST','/api/v1/messages',body);o.need(v['id']==first['id'] and v['idempotent_replay'] is True,'F1_EXACTLY_ONCE')
 ca.request('message-conflict-'+name,'POST','/api/v1/messages',dict(body,content='DIFFERENT-SYNTHETIC'),status=409)
 v,_,_=cb.request('message-read-'+name,'GET','/api/v1/messages?peer_id='+str(pair['a']['id']));o.need(any(x['id']==first['id'] for x in v['items']),'PEER_MESSAGE_READ')
 _,raw,h=cb.request('image-read-'+name,'GET','/api/v1/media/'+str(asset)+'/content');o.need(raw==PNG,'IMAGE_REAL_BYTES');o.need('private' in h.get('Cache-Control','') and 'no-store' in h.get('Cache-Control',''),'PRIVATE_CACHE')
 Client(state['tokens']['disabled-a']['access_token']).request('image-third-party-'+name,'GET','/api/v1/media/'+str(asset)+'/content',status=404)
 if name=='base':continue
 if name=='block':cb.request('block-commit','POST','/api/v1/moderation/blocks',{'blocked_user_id':pair['a']['id'],'reason_code':'other'})
 else:
  kind='consent' if name=='mc' else 'connection';action='revoke' if name=='mc' else 'close'
  v,_,_=cb.request('current-'+name,'GET','/api/v1/connections/'+str(pair['a']['id']))
  cb.request('revoke-'+name,'POST','/api/v1/connections/'+str(pair['a']['id'])+'/'+kind,{'peer_id':pair['a']['id'],'action':action,'expected_revision':v[kind]['revision'],'expected_connection_id':v['connection']['id'],'expected_consent_id':v['consent']['id']})
 ca.request('revoked-replay-'+name,'POST','/api/v1/messages',body,status=404)
 ca.request('revoked-new-'+name,'POST','/api/v1/messages',dict(body,client_message_id=str(uuid.uuid4())),status=404)
 cb.request('revoked-message-read-'+name,'GET','/api/v1/messages?peer_id='+str(pair['a']['id']),status=404)
 cb.request('revoked-media-read-'+name,'GET','/api/v1/media/'+str(asset)+'/content',status=404)
cb=Client(state['tokens']['base-b']['access_token'])
v,_,_=cb.request('notifications-present','GET','/api/v1/notifications');o.need(v['total']>=1,'NOTICE_PERSISTED')
v,_,_=cb.request('preferences-silent','PUT','/api/v1/notification-preferences',{'categories':{'message':False},'silent':True});o.need(v['categories']['message'] is False and v['silent'] is True,'OWNED_PREF')
v,_,_=cb.request('notification-device-test-only','POST','/api/v1/notification-devices',{'device_id':'task-running-base-b','transport':'test_only','token':'TASK-SYNTHETIC-NO-PROVIDER','permission':'granted'});o.need(v['provider_status']=='REAL_PUSH_PROVIDER_PENDING','NO_REAL_PUSH')
cb.request('notification-unapproved-provider','POST','/api/v1/notification-devices',{'device_id':'task-running-base-b','transport':'fcm','token':'TASK-SYNTHETIC-NO-PROVIDER','permission':'granted'},status=422)
cb.request('notification-device-delete','DELETE','/api/v1/notification-devices/task-running-base-b')
cb.request('activity-opaque-locator','GET','/api/v1/platform-events/'+str(uuid.uuid4()),status=(404,405))
admin=Client();_,raw,_=admin.request('admin-login-form','GET','/admin/login',headers={'Accept':'text/html'});secret=json.loads((R/'runtime/qualification.json').read_text(encoding='utf-8'))
admin.request('admin-authenticate','POST','/admin/login',{'phone':seed['admin']['phone'],'password':secret['fixture_password'],'_token':csrf(raw)},status=302,form=True,headers={'Accept':'text/html'})
_,raw,_=admin.request('admin-positive','GET','/admin',headers={'Accept':'text/html'});csrf_token=csrf(raw)
target=str(state['pairs']['disabled']['b']['id'])
form=re.search(rb'<form[^>]*action="[^"]*/admin/users/'+target.encode()+rb'/disable"[^>]*>(.*?)</form>',raw,re.S);o.need(form is not None,'OWNED_ADMIN_DISABLE_FORM')
revision=re.search(rb'name="expected_revision"[^>]*value="([0-9]+)"',form.group(1));o.need(revision is not None,'LIVE_ADMIN_REVISION')
admin.request('admin-missing-csrf','POST','/admin/users/'+target+'/disable',{'confirm_disable':'1','expected_revision':revision.group(1).decode(),'reason':'TASK SYNTHETIC'},status=419,form=True,headers={'Accept':'text/html'})
admin.request('disable-owned-user-confirmed','POST','/admin/users/'+target+'/disable',{'_token':csrf_token,'confirm_disable':'1','expected_revision':revision.group(1).decode(),'reason':'TASK SYNTHETIC ONLY'},status=302,form=True,headers={'Accept':'text/html'})
Client(state['tokens']['disabled-b']['access_token']).request('disabled-old-access','GET','/api/v1/notifications',status=401)
Client(state['tokens']['disabled-b']['refresh_token']).request('disabled-old-refresh','POST','/api/v1/auth/refresh',{},status=401)
old_cookie=admin.cookie_header();admin.request('admin-logout','POST','/admin/logout',{'_token':csrf_token},status=302,form=True,headers={'Accept':'text/html'})
Client().request('admin-old-cookie-denied','GET','/admin',status=302,headers={'Accept':'text/html','Cookie':old_cookie})
legacy=fixture('legacy-session','legacy-cookie-positive');lh={'Accept':'text/html','Cookie':legacy['cookie_name']+'='+urllib.parse.quote(legacy['cookie'],safe='')}
Client().request('legacy-php-session-positive','GET','/admin',headers=lh)
Client().request('legacy-php-session-logout','POST','/admin/logout',{'_token':legacy['csrf']},status=302,form=True,headers=lh)
Client().request('legacy-php-session-denied','GET','/admin',status=302,headers=lh)
state['restart_cookie']=fixture('legacy-session','legacy-cookie-before-restart');state['before_snapshot']=fixture('snapshot','db-before-restart');save('http-state',state)
o.need(state['before_snapshot']['messages']==4 and state['before_snapshot']['attachments']==4 and state['before_snapshot']['notifications']==4,'EXACT_DB_CARDINALITY')
save('http-phase1-result',{'status':'PASS','messages':4,'attachments':4,'notifications':4,'legacy_wire_format':'PHP_SERIALIZED_SYNTHETIC_LEGACY','old_laravel11_binary_cookie':'NOT_RUN'})
