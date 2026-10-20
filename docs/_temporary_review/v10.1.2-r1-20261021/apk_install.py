from pathlib import Path
import subprocess,time,hashlib,json
E=Path(r'<LOCAL_ROOT>');apk=E/'EliteSync-v10.1.2-R1-88ffeccc.apk';bt=Path(r'<USER_HOME>\AppData\Local\Android\Sdk\build-tools\36.0.0')
for i in range(100):
 r=subprocess.run(['adb','-s','emulator-5554','shell','getprop','sys.boot_completed'],capture_output=True)
 if r.returncode==0 and r.stdout.strip()==b'1':break
 time.sleep(.5)
assert r.returncode==0 and r.stdout.strip()==b'1'
for label,cmd in [('apk-badging',[str(bt/'aapt.exe'),'dump','badging',str(apk)]),('apk-signer',['cmd','/c',str(bt/'apksigner.bat'),'verify','--print-certs',str(apk)]),('apk-install',['adb','-s','emulator-5554','install','-r',str(apk)])]:
 r=subprocess.run(cmd,capture_output=True);(E/(label+'.stdout')).write_bytes(r.stdout);(E/(label+'.stderr')).write_bytes(r.stderr);assert r.returncode==0,(label,r.returncode)
subprocess.run(['adb','-s','emulator-5554','reverse','tcp:8015','tcp:8015'],check=True,capture_output=True)
p=subprocess.check_output(['adb','-s','emulator-5554','shell','pm','path','com.elitesync.v1012dev']).decode().strip().removeprefix('package:');pulled=E/'installed-r1-base.private.apk';subprocess.run(['adb','-s','emulator-5554','pull',p,str(pulled)],check=True,capture_output=True)
h=hashlib.sha256(apk.read_bytes()).hexdigest();assert hashlib.sha256(pulled.read_bytes()).hexdigest()==h
(E/'apk-r1-manifest.json').write_text(json.dumps({'source_commit':'88ffeccce4042f13ce4edccf7604b835b06c8f2d','source_tree':'42052f5f9ee596f82cf525884e1f77256fc7727b','sha256':h,'installed_pull_sha256':h,'bytes':apk.stat().st_size,'serial':'emulator-5554','application_id':'com.elitesync.v1012dev','backend':'same fixed R1 backend / 8015 / elitesync_v10_1_2_dev','signer_sha256':'9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09'},indent=2));print('fixed R1 APK installed and pulled hash matches')
subprocess.run(['adb','-s','emulator-5554','shell','am','force-stop','com.elitesync.v1012dev'],check=True,capture_output=True)
subprocess.run(['adb','-s','emulator-5554','shell','monkey','-p','com.elitesync.v1012dev','-c','android.intent.category.LAUNCHER','1'],check=True,capture_output=True)
