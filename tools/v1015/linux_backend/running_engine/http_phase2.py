from http_e2e import *
state=load('http-state');after=fixture('snapshot','db-after-restart')
for key in ['users','messages','attachments','notifications','migration_rows','message_facts']:o.need(after[key]==state['before_snapshot'][key],'DURABLE_'+key)
ca=Client(state['tokens']['base-a']['access_token']);cb=Client(state['tokens']['base-b']['access_token']);pair=state['pairs']['base']
v,_,_=cb.request('restart-message-read','GET','/api/v1/messages?peer_id='+str(pair['a']['id']));o.need(any(x['id']==state['messages']['base']['id'] for x in v['items']),'DURABLE_MESSAGE_ID')
v,_,_=ca.request('restart-same-key','POST','/api/v1/messages',state['messages']['base']['body']);o.need(v['id']==state['messages']['base']['id'] and v['idempotent_replay'],'DURABLE_EXACTLY_ONCE')
_,raw,_=cb.request('restart-image-bytes','GET','/api/v1/media/'+str(state['media']['base'])+'/content');o.need(raw==PNG,'DURABLE_IMAGE_BYTES')
v,_,_=cb.request('restart-notification-prefs','GET','/api/v1/notification-preferences');o.need(v['silent'] is True and v['categories']['message'] is False,'DURABLE_PREFS')
for name in ['block','mc','cn']:
 ca2=Client(state['tokens'][name+'-a']['access_token']);cb2=Client(state['tokens'][name+'-b']['access_token'])
 ca2.request('restart-revoked-message-'+name,'POST','/api/v1/messages',state['messages'][name]['body'],status=404)
 cb2.request('restart-revoked-media-'+name,'GET','/api/v1/media/'+str(state['media'][name])+'/content',status=404)
legacy=state['restart_cookie'];headers={'Accept':'text/html','Cookie':legacy['cookie_name']+'='+urllib.parse.quote(legacy['cookie'],safe='')}
Client().request('restart-legacy-session-positive','GET','/admin',headers=headers)
Client().request('restart-legacy-session-logout','POST','/admin/logout',{'_token':legacy['csrf']},status=302,form=True,headers=headers)
Client().request('restart-legacy-session-denied','GET','/admin',status=302,headers=headers)
secret=json.loads((R/'runtime/qualification.json').read_text(encoding='utf-8'))
Client().request('restart-disabled-login','POST','/api/v1/auth/login',{'phone':state['pairs']['disabled']['b']['phone'],'password':secret['fixture_password'],'device_id':'task-disabled-check'},status=403)
cb.request('api-logout','POST','/api/v1/auth/logout',{})
cb.request('api-logout-old-access','GET','/api/v1/notifications',status=401)
Client(state['tokens']['base-b']['refresh_token']).request('api-logout-old-refresh','POST','/api/v1/auth/refresh',{},status=401)
final=fixture('snapshot','db-final')
for k in ['users','messages','attachments','notifications','migration_rows','message_facts']:o.need(final[k]==state['before_snapshot'][k],'NO_EXTRA_SIDE_EFFECTS_'+k)
save('http-phase2-result',{'status':'PASS','same_message_facts_after_restart':True,'messages':final['messages'],'attachments':final['attachments'],'notifications':final['notifications'],'migrations':final['migration_rows'],'legacy_wire_session_survived':True,'revoked_permissions_remain_denied':True,'desktop_wsl_activation_count':0})
