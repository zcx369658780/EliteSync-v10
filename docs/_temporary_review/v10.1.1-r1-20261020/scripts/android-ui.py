import subprocess,pathlib,xml.etree.ElementTree as ET,re,json,sys
E=pathlib.Path(__file__).parent
ADB=r'<ANDROID_SDK>\platform-tools\adb.exe'
serial=sys.argv[1];action=sys.argv[2]
assert serial in ['emulator-5554','emulator-5556']
def adb(*args):return subprocess.check_output([ADB,'-s',serial,*args],timeout=15)
def nodes():
    out=adb('shell','uiautomator','dump','/sdcard/v1011-window.xml')
    assert b'dumped to' in out, 'FRESH_DUMP_REQUIRED'
    raw=adb('exec-out','cat','/sdcard/v1011-window.xml')
    (E/('ui-'+serial+'-latest.xml')).write_bytes(raw)
    return list(ET.fromstring(raw).iter('node'))
if action=='dump':
    print(json.dumps([{'text':n.get('content-desc') or n.get('text'),'bounds':n.get('bounds'),'class':n.get('class'),'click':n.get('clickable')} for n in nodes() if n.get('password')!='true' and (n.get('content-desc') or n.get('text') or n.get('class')=='android.widget.EditText')],ensure_ascii=False))
elif action in ['click','click-suffix']:
    matches=[n for n in nodes() if ((n.get('content-desc') or n.get('text') or '').endswith(sys.argv[3]) if action=='click-suffix' else (n.get('content-desc') or n.get('text'))==sys.argv[3]) and n.get('clickable')=='true']
    assert len(matches)==1, 'EXACT_VISIBLE_CONTROL_REQUIRED'
    x1,y1,x2,y2=map(int,re.findall(r'\d+',matches[0].get('bounds')))
    adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2));print('clicked',sys.argv[3])
elif action=='capture':
    label=sys.argv[3];assert re.fullmatch('[a-zA-Z0-9_-]+',label)
    (E/(label+'-'+serial+'.png')).write_bytes(adb('exec-out','screencap','-p'));print('saved',label)
elif action=='seek':
    for attempt in range(6):
        matches=[n for n in nodes() if (n.get('content-desc') or n.get('text') or '').startswith(sys.argv[3]) and n.get('clickable')=='true']
        if len(matches)==1:
            x1,y1,x2,y2=map(int,re.findall(r'\d+',matches[0].get('bounds')))
            if y2-y1>80:
                adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2));print('visible APP control',sys.argv[3]);break
        assert len(matches)<=1,'AMBIGUOUS_CONTROL'
        adb('shell','input','swipe','550','1900','550','700','300')
    else:raise AssertionError('CONTROL_NOT_FOUND')
elif action=='login':
    account=json.loads((E/'secrets/accounts.json').read_text())['accounts'][sys.argv[3]]
    for index,key in enumerate(['phone','password']):
        fields=[n for n in nodes() if n.get('class')=='android.widget.EditText']
        assert len(fields)==2
        x1,y1,x2,y2=map(int,re.findall(r'\d+',fields[index].get('bounds')))
        # Secret values are sent over stdin, never host argv or output.
        adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
        nodes()  # Wait for focus/keyboard state before emitting text.
        command='input keyevent 123 '+' '.join(['67']*40)+'\ninput text '+account[key]+'\ninput keyevent 4\n'
        subprocess.run([ADB,'-s',serial,'shell'],input=command.encode(),stdout=subprocess.DEVNULL,check=True)
        if key=='phone':
            current=[n for n in nodes() if n.get('class')=='android.widget.EditText'][0]
            assert current.get('text')==account['phone'],'PHONE_INPUT_READBACK_MISMATCH'
    boxes=[n for n in nodes() if n.get('class')=='android.widget.CheckBox']
    assert len(boxes)==1
    if boxes[0].get('checked')!='true':
        x1,y1,x2,y2=map(int,re.findall(r'\d+',boxes[0].get('bounds')))
        adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2))
    buttons=[n for n in nodes() if n.get('content-desc')=='进入慢约会' and n.get('clickable')=='true']
    assert len(buttons)==1
    x1,y1,x2,y2=map(int,re.findall(r'\d+',buttons[0].get('bounds')))
    adb('shell','input','tap',str((x1+x2)//2),str((y1+y2)//2));print('login submitted',sys.argv[3])
else:raise ValueError(action)
