import pathlib,json,uuid
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
sessions['charlie']=call('charlie','POST','/auth/login',accounts['charlie'])
t=json.loads((E/'persistent-readback-target.json').read_text()); cid=t['conversation_id']
assert not any(x['conversation_id']==cid for x in call('charlie','GET','/conversations')['items'])
assert any(x['conversation_id']==cid for x in call('charlie','GET','/conversations?hidden_only=true')['items'])
assert call('charlie','GET','/privacy')['revision']==1
r=json.loads((E/'secrets/race-closure-receipt.json').read_text())
assert call(None,'POST','/account/closure-receipts/'+r['request_id'],{'receipt_token':r['receipt_token']})['status']=='PRIVATE_DATA_ERASURE_COMPLETE'
call(None,'POST','/auth/login',accounts['diana'],expected=(422,403))
call('diana','GET','/privacy',expected=(401,))
call('bob','POST','/messages',{'receiver_id':t['hidden_for_user'],'content':'New authorized incoming after owned restart','client_message_id':str(uuid.uuid4())},expected=(200,201))
assert any(x['conversation_id']==cid for x in call('charlie','GET','/conversations')['items'])
(E/'http-after-restart-results.json').write_text(json.dumps(receipts,indent=2))
(E/'secrets/http-sessions.json').write_text(json.dumps(sessions))
print(json.dumps({'checks':len(receipts),'all_pass':True,'hidden_survived_db_api_ws_restart':True,'authorized_new_message_reappeared':True,'closure_receipt_survived':True}))
