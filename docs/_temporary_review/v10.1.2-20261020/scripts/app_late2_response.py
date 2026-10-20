
import pathlib,subprocess,xml.etree.ElementTree as ET,time,json,re
E=pathlib.Path(__file__).parent;backend=pathlib.Path(r'$WORKTREE\services\backend-laravel')
def adb(*a):return subprocess.run(['adb','-s','AUTHORIZED_AVD',*a],capture_output=True,check=True).stdout
def dump(label):
 adb('shell','uiautomator','dump','/sdcard/v1012-late.xml');data=adb('exec-out','cat','/sdcard/v1012-late.xml');(E/(label+'.xml')).write_bytes(data);return ET.fromstring(data)
def tapdesc(needle,label):
 root=dump(label)
 nodes=list(root.iter('node'));nodes.sort(key=lambda n:n.get('content-desc','')!=needle)
 for n in nodes:
  if needle in n.get('content-desc',''):
   x1,y1,x2,y2=map(int,re.findall(r'\d+',n.get('bounds')));adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2));return
 raise AssertionError('control missing '+needle)
p=subprocess.Popen(['php',str(E/'app_late2_holder.php')],cwd=backend,stdout=(E/'app-late2-holder.stdout').open('wb'),stderr=(E/'app-late2-holder.stderr').open('wb'))
try:
 deadline=time.time()+10
 while not (E/'app-late2-held').exists():assert time.time()<deadline;time.sleep(.05)
 adb('shell','input','tap','1009','200');time.sleep(.8)
 tapdesc('Back','app-late2-loading');tapdesc('我的','app-late2-back')
 for i in range(3):adb('shell','input','swipe','600','2050','600','650','250')
 tapdesc('本地设置','app-late2-me')
 for i in range(3):adb('shell','input','swipe','600','2050','600','650','250')
 tapdesc('退出账号','app-late2-settings');tapdesc('退出','app-late2-logout-dialog');time.sleep(.6)
 root=dump('app-late2-signedout-before-release');desc='\n'.join(n.get('content-desc','') for n in root.iter('node'));assert '账号登录' in desc and '代际' not in desc
 (E/'app-late2-release').write_text('release after session epoch changed');p.wait(timeout=10);assert p.returncode==0;time.sleep(1)
 root=dump('app-late2-signedout-after-response');desc='\n'.join(n.get('content-desc','') for n in root.iter('node'));assert '账号登录' in desc and '参与状态' not in desc
 (E/'app-late2-signedout-after-response.png').write_bytes(adb('exec-out','screencap','-p'))
 (E/'app-late2-response-result.json').write_text(json.dumps({'held_synthetic_user_read':True,'signed_out_before_release':True,'late_response_did_not_restore_old_view':True,'writer_exit':p.returncode,'real_APP':True},indent=2));print('APP sign-out during pending refresh: late result discarded')
finally:
 (E/'app-late2-release').write_text('always release owned read lock')
