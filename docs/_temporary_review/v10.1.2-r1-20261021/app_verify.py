from pathlib import Path
import json,xml.etree.ElementTree as X,hashlib
E=Path.cwd()
def labels(name):return '\n'.join((n.get('content-desc','') for n in X.parse(E/(name+'.xml')).iter('node')))
checks={}
s=labels('app-r1-proposal-positive');checks['positive_showcase_and_decisions']='R1_PRIVATE_SUMMARY_B' in s and '独立接受候选' in s and '拒绝候选' in s
s=labels('app-r1-paused-only-withdraw');checks['pause_no_showcase_only_withdraw']='R1_PRIVATE_SUMMARY_B' not in s and '独立接受候选' not in s and '拒绝候选' not in s and '撤回当前提案' in s
s=labels('app-r1-exited-no-candidate');checks['exit_withdrawn_no_content_no_decisions']='提案状态：已撤回' in s and 'R1_PRIVATE_SUMMARY_B' not in s and '独立接受候选' not in s and '撤回当前提案' not in s
s=labels('app-r1-formal-actor-actions');checks['formal_pending_correct_requester_actions']='关系状态：等待双方独立回应' in s and '撤回关系申请' in s and '拒绝关系申请' not in s and 'TEST_ONLY' in s
checks['uncontrolled_APP_rejected']='Not found' in labels('app-r1-formal-uncontrolled-denied')
checks['closed_receiver_APP_rejected']='Not found' in labels('app-r1-closed-denied')
for label in ['uncontrolled','closed-denial']:
 a=json.loads((E/('app-before-'+label+'.stdout')).read_text());b=json.loads((E/('app-after-'+label+'.stdout')).read_text());checks[label+'_zero_side_effects']=a['counts']==b['counts']
assert all(checks.values()),checks
out={'fixed_source':'88ffeccce4042f13ce4edccf7604b835b06c8f2d','apk_sha256':json.loads((E/'apk-r1-manifest.json').read_text())['sha256'],'actual_AVD':'elitesync_v1009_a / emulator-5554','checks':checks,'evidence_level':'actual APP taps and UI XML/screenshots plus real API/MariaDB readback; no mocks','limits':['Receiver role APP not separately logged in; server role HTTP and Widget tests cover it.','PAUSE re-enroll rejection uses generic Request failed UI; HTTP409 proven separately.','Old pending formal action buttons may remain in cached UI until refresh; current server source validation remains mandatory.'],'result':'PASS'}
(E/'app-r1-result.json').write_text(json.dumps(out,ensure_ascii=False,indent=2));print(json.dumps(checks))
