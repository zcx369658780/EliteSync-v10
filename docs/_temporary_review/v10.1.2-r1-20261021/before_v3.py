
import pathlib,json,requests,subprocess
E=pathlib.Path(__file__).parent;f=json.loads((E/'fixture-before03.private.json').read_text());u=f['users'];receipts=[]
def call(actor,method,path,body=None):
 r=requests.request(method,'http://127.0.0.1:8015/api/v1'+path,json=body,headers={'Accept':'application/json','Authorization':'[REDACTED] '+u[actor]['session']['access_token']},timeout=25);receipts.append({'actor':actor,'method':method,'path':path,'status':r.status_code,'body':r.json()});return r.status_code,r.json()
def state():return json.loads(subprocess.check_output(['php',str(E/'state.php'),'before03']))
baseline=state();s,r=call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'before-uncontrolled'});assert s==200
s,_=call('C','POST',f"/formal-relationships/{r['id']}/actions",{'action':'withdraw','revision':r['revision'],'idempotency_key':'before-withdraw'});assert s==200
s,_=call('C','POST','/formal-relationships',{'peer_id':u['B']['id'],'idempotency_key':'before-repeat'});assert s==200
post_b1=state();s,_=call('B','PUT','/journey/participation',{'action':'exit','revision':1,'intent':'R1 explicit exit'});assert s==200
for path in ['/journey','/matches/current','/match-rounds/current']:call('A','GET',path)
post_exit=state();assert post_exit['proposal']['state']=='PENDING' and post_exit['proposal']['slot_count']==2
s,_=call('A','POST',f"/journey/proposals/{f['proposal']['id']}/decision",{'action':'accept','revision':1,'idempotency_key':'before-after-exit'});assert s==409
s,_=call('B','PUT','/journey/participation',{'action':'opt_in','revision':2,'intent':'before resume'});assert s==200
s,_=call('B','PUT','/journey/participation',{'action':'pause','revision':3,'intent':'pause'});assert s==200
s,_=call('B','PUT','/journey/participation',{'action':'opt_in','revision':4,'intent':'new generation'});assert s==200
s,j=call('A','GET','/journey');assert s==200 and j['proposal']['state']=='PENDING' and j['proposal']['showcase']['summary']=='R1_PRIVATE_SUMMARY_B'
(E/'before-http.private.json').write_text(json.dumps(receipts,indent=2));out={'B1':{'stranger_request':200,'withdraw_then_new_key':200,'side_effect_delta':{k:post_b1['counts'][k]-baseline['counts'][k] for k in baseline['counts']}},'B2':{'exit_still_pending':post_exit['proposal'],'old_showcase_after_exit':any('R1_PRIVATE_SUMMARY_B' in json.dumps(x['body']) for x in receipts if x['method']=='GET'),'new_generation_still_pending':True,'write_after_exit':409},'isolation':baseline['isolation'],'result':'REPRODUCED_B1_AND_B2'};(E/'before-result.json').write_text(json.dumps(out,indent=2));print(json.dumps(out))
