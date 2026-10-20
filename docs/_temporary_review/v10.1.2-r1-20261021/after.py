
import pathlib,json,subprocess,requests
E=pathlib.Path(__file__).parent;label='after01';f=json.loads((E/f'fixture-{label}.private.json').read_text());u=f['users'];receipts=[];checks={}
def call(actor,method,path,body=None,expected=200):
 r=requests.request(method,'http://127.0.0.1:8015/api/v1'+path,json=body,headers={'Accept':'application/json','Authorization':'[REDACTED] '+u[actor]['session']['access_token']},timeout=25);j=r.json();receipts.append({'actor':actor,'method':method,'path':path,'status':r.status_code,'body':j});assert r.status_code in ([expected] if isinstance(expected,int) else expected),(method,path,r.status_code,j);return j
def state(l=label):return json.loads(subprocess.check_output(['php',str(E/'state.php'),l]))
def unchanged(before):assert before['counts']==state()['counts']
def projections():
 a=call('A','GET','/journey')['proposal'];b=call('A','GET','/matches/current')['proposal'];r=call('A','GET','/match-rounds/current')['data'];assert a['showcase'] is None and b['showcase'] is None and not a['decision_available'] and r['result'] is None and r['conversation_capability'] is None;return a
try:
 before=state();errors=[]
 for i,peer in enumerate([u['C']['id'],u['Disabled']['id'],u['B']['id'],u['B']['id']+100000]):errors.append(call('C','POST','/formal-relationships',{'peer_id':peer,'idempotency_key':f'uncontrolled-{i}'},404))
 assert all(e==errors[0] for e in errors);unchanged(before);checks['uncontrolled_self_disabled_absent_same_404_no_side_effects']=True
 # A sequence of numbered targets cannot create contact, and actor rate limiting is independent of existence.
 for i in range(14):call('A','POST','/formal-relationships',{'peer_id':u['A']['id']-2+i,'idempotency_key':f'enumeration-{i}'},[404,429])
 unchanged(before);checks['numbered_enumeration_and_route_cap_no_writes']=True
 call('B','POST','/social/preferences',{'requests_enabled':True});inv=call('B','POST','/social/invites',{'purpose':'friendship'},201)
 req=call('C','POST','/social/requests',{'purpose':'friendship','invitation_token':inv['token'],'idempotency_key':'controlled-friend'},201)
 call('B','POST',f"/social/requests/{req['id']}/accept")
 r=call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'controlled-formal'});assert r['state']=='PENDING_MUTUAL' and r['allowed_actions']==['confirm','withdraw','end'];post=state()
 replay=call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'controlled-formal'});assert replay==r;unchanged(post);checks['real_social_invite_accept_to_formal_pending_no_activation_and_idempotent']=True
 recipient=call('B','GET','/formal-relationships')['relationships'][0];assert recipient['allowed_actions']==['confirm','decline','end']
 call('B','POST','/social/preferences',{'requests_enabled':False});post=state();call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'controlled-formal'},404);unchanged(post)
 call('B','POST','/social/preferences',{'requests_enabled':True});call('C','POST',f"/formal-relationships/{r['id']}/actions",{'action':'confirm','revision':r['revision'],'idempotency_key':'cannot-revive-off-on'},409)
 post=state();call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'new-key-cooldown'},404);unchanged(post);checks['off_on_epoch_blocks_replay_confirm_and_repeated_new_key']=True
 # EXIT invalidates current proposal and both slots; the three product projections agree.
 p=f['proposal'];call('B','PUT','/journey/participation',{'action':'exit','revision':1,'intent':'explicit exit'});a=projections();assert a['state']=='WITHDRAWN' and state()['proposal']['slot_count']==0
 call('A','POST',f"/journey/proposals/{p['id']}/decision",{'action':'accept','revision':p['revision'],'idempotency_key':'old-after-exit'},409)
 call('B','PUT','/journey/participation',{'action':'opt_in','revision':2,'intent':'new explicit generation'});checks['EXIT_HTTP_three_projections_terminal_slots_zero']=True
 subprocess.run(['php',str(E/'new_round.php'),label,'after-round2'],check=True,capture_output=True);g=json.loads((E/'fixture-after-round2.private.json').read_text());p=g['proposal'];assert p['state']=='PENDING' and p['decision_available']
 call('B','PUT','/journey/participation',{'action':'pause','revision':3,'intent':'pause without deciding'});a=projections();assert a['state']=='PENDING' and a['withdraw_available'] and state('after-round2')['proposal']['slot_count']==2
 call('B','PUT','/journey/participation',{'action':'opt_in','revision':4,'intent':'cannot silently carry old proposal'},409)
 call('B','POST',f"/journey/proposals/{p['id']}/decision",{'action':'withdraw','revision':p['revision'],'idempotency_key':'explicit-withdraw'})
 call('B','PUT','/journey/participation',{'action':'opt_in','revision':4,'intent':'new generation after explicit withdrawal'});checks['PAUSE_requires_explicit_withdraw_before_generation3']=True
 subprocess.run(['php',str(E/'new_round.php'),'after-round2','after-round3'],check=True,capture_output=True);g=json.loads((E/'fixture-after-round3.private.json').read_text());p=g['proposal'];a=call('A','GET','/journey')['proposal'];assert a['id']==p['id'] and a['decision_available'] and a['showcase']['summary']=='R1_PRIVATE_SUMMARY_B';checks['old_unexpired_slot_released_and_next_real_round_reveal_succeeds']=True
 p=call('A','POST',f"/journey/proposals/{p['id']}/decision",{'action':'accept','revision':1,'idempotency_key':'current-a'});p=call('B','POST',f"/journey/proposals/{p['id']}/decision",{'action':'accept','revision':p['revision'],'idempotency_key':'current-b'});assert p['state']=='MUTUALLY_ACCEPTED'
 for kind in ['connection','consent']:
  call('A','POST',f"/connections/{u['B']['id']}/{kind}",{'action':'request','expected_revision':0});call('B','POST',f"/connections/{u['A']['id']}/{kind}",{'action':'accept','expected_revision':1})
 call('B','PUT','/journey/participation',{'action':'exit','revision':5,'intent':'exit completed history'})
 cn=call('A','GET',f"/connections/{u['B']['id']}");assert cn['gates']['live_send_allowed'] and cn['gates']['live_read_allowed'];p=call('A','GET','/matches/current')['proposal'];assert p['state']=='MUTUALLY_ACCEPTED' and not p['connection_eligible'] and p['showcase'] is None;checks['completed_history_retained_no_new_match_authority_CN_MC_independent']=True
 (E/'after-result.json').write_text(json.dumps({'isolation':'REPEATABLE-READ','checks':checks,'http_count':len(receipts),'result':'PASS'},indent=2));print(json.dumps(checks))
finally:(E/'after-http.private.json').write_text(json.dumps(receipts,ensure_ascii=False,indent=2))
