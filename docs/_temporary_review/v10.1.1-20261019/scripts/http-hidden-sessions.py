import pathlib,json,uuid,urllib.request,urllib.error
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
b=sessions['bob']['user']['id']; c=sessions['charlie']['user']['id']
items=call('charlie','GET','/conversations')['items']
cid=next(x['conversation_id'] for x in items if x['peer_user_id']==b)
call('charlie','POST',f'/conversations/{cid}/visibility',{'hidden':True})
assert not any(x['conversation_id']==cid for x in call('charlie','GET','/conversations')['items'])
assert any(x['conversation_id']==cid for x in call('charlie','GET','/conversations?hidden_only=true')['items'])
assert any(x['conversation_id']==cid for x in call('bob','GET','/conversations')['items'])
sessions['charlie']=call('charlie','POST','/auth/login',accounts['charlie'])
assert not any(x['conversation_id']==cid for x in call('charlie','GET','/conversations')['items'])
# Restart persistence is checked separately before a genuinely new incoming message.
second=call('charlie','POST','/auth/login',accounts['charlie'])
call('bob','DELETE','/account/sessions/'+second['session_id'],expected=(404,))
call('charlie','DELETE','/account/sessions/'+second['session_id'])
call('charlie','GET','/privacy',token=second['access_token'],expected=(401,))
call('charlie','POST','/auth/refresh',token=second['refresh_token'],expected=(401,))
call('charlie','GET','/privacy')
old=sessions['charlie'].copy()
sessions['charlie']=call('charlie','POST','/auth/refresh',token=old['refresh_token']) | {'user':old['user']}
call('charlie','POST','/auth/refresh',token=old['refresh_token'],expected=(401,))
call('charlie','GET','/privacy',token=old['access_token'],expected=(401,))
call('charlie','GET','/privacy')
(E/'http-hidden-sessions-results.json').write_text(json.dumps(receipts,indent=2))
(E/'secrets/http-sessions.json').write_text(json.dumps(sessions))
(E/'persistent-readback-target.json').write_text(json.dumps({'conversation_id':cid,'hidden_for_user':c,'peer':b}))
print(json.dumps({'checks':len(receipts),'all_pass':True,'hidden_after_relogin':True,'new_incoming_not_sent_yet':True}))
