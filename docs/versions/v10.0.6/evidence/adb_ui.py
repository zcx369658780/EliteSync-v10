import subprocess, sys, json, shlex, datetime, xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).parent
serial='emulator-5580'
def adb(*args, **kwargs):
    return subprocess.run(['adb','-s',serial,*args],check=True,stdout=subprocess.PIPE,stderr=subprocess.PIPE,**kwargs)
action=sys.argv[1]
if action=='observe':
    name=sys.argv[2]
    adb('shell','uiautomator','dump','/sdcard/v1006-window.xml')
    xml=adb('shell','cat','/sdcard/v1006-window.xml').stdout
    (root/(name+'.xml')).write_bytes(xml)
    (root/(name+'.png')).write_bytes(adb('exec-out','screencap','-p').stdout)
    for n in ET.fromstring(xml).iter('node'):
        a=n.attrib
        if a.get('text') or a.get('content-desc') or a.get('class','').endswith(('EditText','CheckBox')):
            print(json.dumps({k:('<password>' if k=='text' and a.get('password')=='true' else a.get(k)) for k in ['text','content-desc','class','bounds','clickable','focused','checked']}))
elif action=='tap': adb('shell','input','tap',sys.argv[2],sys.argv[3])
elif action=='key': adb('shell','input','keyevent',sys.argv[2])
elif action=='account':
    role,field=sys.argv[2:4]
    creds=json.loads((root/'secrets/credentials.json').read_text(encoding='utf8'))
    value=creds['accounts'][role][field]
    adb('shell',input=('input text '+shlex.quote(value)+'\n').encode())
elif action=='text':
    adb('shell',input=('input text '+shlex.quote(sys.argv[2].replace(' ','%s'))+'\n').encode())
else: raise ValueError(action)
print(json.dumps({'time':datetime.datetime.now(datetime.timezone.utc).isoformat(),'serial':serial,'action':action,'exit':0}))
