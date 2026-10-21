import os,sys,json,subprocess
sys.path.insert(0,os.path.join(os.environ['V1015_BACKEND_ROOT'],'tests','Integration','v1015'))
from journey import login,request,receipts
cases=[]
for age,expected in [(15*86400-60,200),(15*86400,401),(15*86400+60,401),(-3600,401)]:
 a=login(3,'v1015-boundary-'+str(age).replace('-','future'))
 p=subprocess.run(['C:/tools/php85/php.exe',os.path.join(os.path.dirname(__file__),'boundary.php')],input=json.dumps({'session_id':a['session_id'],'age_seconds':age})+'\n',text=True,capture_output=True,timeout=15)
 assert p.returncode==0
 fixture=json.loads(p.stdout.strip().splitlines()[-1])
 r=request('GET','/api/v1/profile/basic',a['access_token'],expected=expected)
 cases.append({'age_seconds':age,'profile_status':r.status_code,'actual_http_login_receipt_before_fixture':True,'fixture':fixture})
print(json.dumps({'result':'PASS_TEST_ONLY_SERVER_PERSISTED_BOUNDARIES','physical_elapsed_15_days':'NOT_CLAIMED','device_30day_purge':'NOT_RUN','cases':cases,'receipts':receipts},indent=2))
