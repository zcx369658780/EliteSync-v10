"""Pure evidence-design mock. No launcher, handles, environment or OS APIs."""
import unittest,json,sys
def classify(parent_durable,launch_ok,api_error,child_exit,first_frame=False,stderr=False):
    out={'rootCauseProven':False,'matrixProven':False,'G2_READY_FOR_POPEN':False}
    if not parent_durable:return dict(out,stage='PARENT_RECEIPT_NOT_DURABLE_STOP')
    if not launch_ok:
        return dict(out,stage='INVALID_MIXED_STAGE_RECORD' if child_exit is not None else 'NATIVE_LAUNCH_FAILURE',apiError=api_error)
    if api_error is not None:return dict(out,stage='INVALID_SUCCESS_WITH_STALE_LAST_ERROR')
    return dict(out,stage='POST_FIRST_FRAME' if first_frame else 'NO_FIRST_FRAME_EVIDENCE',childExit=child_exit,stderrAvailable=stderr)
def correlate(expected,observed):
    for k in ['pid','imageHash']:
        if expected.get(k)!=observed.get(k):return 'REJECTED'
    if expected.get('creationTime') is None or observed.get('creationTime') is None:return 'CANDIDATE_NOT_INSTANCE_PROVEN'
    if expected['creationTime']!=observed['creationTime']:return 'REJECTED'
    if not expected.get('attemptId') or expected['attemptId']!=observed.get('attemptId'):return 'CANDIDATE_NOT_INSTANCE_PROVEN'
    return 'INSTANCE_BOUND_NOT_ROOT_CAUSE'
class DesignTests(unittest.TestCase):
    def test_parent_flush_failure_never_authorizes_launch(self):self.assertEqual(classify(False,False,None,None)['stage'],'PARENT_RECEIPT_NOT_DURABLE_STOP')
    def test_native_1314_not_child_exit(self):self.assertEqual(classify(True,False,1314,None)['stage'],'NATIVE_LAUNCH_FAILURE')
    def test_mixed_stage_record_rejected(self):self.assertEqual(classify(True,False,1314,0xc0000142)['stage'],'INVALID_MIXED_STAGE_RECORD')
    def test_stale_last_error_rejected(self):self.assertEqual(classify(True,True,5,0)['stage'],'INVALID_SUCCESS_WITH_STALE_LAST_ERROR')
    def test_no_first_frame_no_matrix_pass(self):
        x=classify(True,True,None,0xc0000142);self.assertEqual(x['stage'],'NO_FIRST_FRAME_EVIDENCE');self.assertFalse(x['matrixProven'])
    def test_stderr_not_causal_proof(self):self.assertFalse(classify(True,True,None,1,stderr=True)['rootCauseProven'])
    def test_first_frame_not_causal_proof(self):self.assertFalse(classify(True,True,None,1,first_frame=True)['rootCauseProven'])
    def test_pid_reuse_rejected(self):self.assertEqual(correlate({'pid':1,'imageHash':'a','creationTime':1},{'pid':1,'imageHash':'a','creationTime':2}),'REJECTED')
    def test_pid_image_time_window_without_creation_not_enough(self):self.assertEqual(correlate({'pid':1,'imageHash':'a'},{'pid':1,'imageHash':'a'}),'CANDIDATE_NOT_INSTANCE_PROVEN')
    def test_instance_bound_still_not_root_cause(self):
        x={'pid':1,'imageHash':'a','creationTime':1,'attemptId':'fixed'};self.assertEqual(correlate(x,x),'INSTANCE_BOUND_NOT_ROOT_CAUSE')
if __name__=='__main__':
    events=[]
    def audit(name,args):
        if name.startswith(('ctypes.','socket.','subprocess.')) or name in ('os.system','os.startfile'):events.append(name);raise RuntimeError('FORBIDDEN_MOCK_RUNTIME')
    sys.addaudithook(audit);r=unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(DesignTests))
    data={'kind':'PURE_EARLY_RECEIPT_DESIGN_MOCK_NOT_OS_VALIDATION','tests':r.testsRun,'failures':len(r.failures),'errors':len(r.errors),'skips':len(r.skipped),'forbiddenAuditEvents':events,'newChildLaunches':0,'G2_READY_FOR_POPEN':False,'exit':0 if r.wasSuccessful() and not events else 1}
    from pathlib import Path
    with (Path(__file__).parent/'design-mock-result.json').open('x',encoding='utf-8') as f:json.dump(data,f,indent=2)
    print(json.dumps(data));sys.exit(data['exit'])
