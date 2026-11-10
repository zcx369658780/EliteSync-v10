"""Operate only owned V1009 APP UI; no business state is fabricated by this helper."""
import pathlib,sys,subprocess,xml.etree.ElementTree as ET,re,time,json
q=pathlib.Path(sys.argv[1]);side=sys.argv[2];action=sys.argv[3]
serial={'a':'emulator-5584','b':'emulator-5586'}[side]
def adb(*args):return subprocess.check_output(['adb','-s',serial,*args],timeout=10)
def nodes():
    adb('shell','rm','-f','/sdcard/v1009-ui.xml')
    result=adb('shell','uiautomator','dump','/sdcard/v1009-ui.xml')
    if b'UI hierchary dumped to' not in result and b'UI hierarchy dumped to' not in result:
        raise RuntimeError('Fresh owned UI dump unavailable')
    return list(ET.fromstring(adb('exec-out','cat','/sdcard/v1009-ui.xml')).iter('node'))
if action=='click':
    text=sys.argv[4]
    for _ in range(4):
        matches=[n for n in nodes() if ((n.get('content-desc','') or n.get('text','')) == text or (text.startswith('V1009 Fictional') and (n.get('content-desc','') or n.get('text','')).startswith(text)))]
        if matches:break
        time.sleep(.3)
    assert matches, 'Requested APP control not visible'
    matches.sort(key=lambda n: ((n.get('content-desc','') or n.get('text','')) != text, n.get('clickable') != 'true'))
    n=matches[0];a=list(map(int,re.findall(r'\d+',n.get('bounds'))))
    adb('shell','input','tap',str((a[0]+a[2])//2),str((a[1]+a[3])//2))
    print('Owned APP UI clicked',side,text)
elif action=='dump':
    items=[{'text':n.get('content-desc','') or n.get('text',''),'bounds':n.get('bounds')} for n in nodes() if n.get('password')!='true' and (n.get('content-desc') or n.get('text'))]
    print(json.dumps(items[-35:],ensure_ascii=False))
elif action=='capture':
    label=sys.argv[4];assert re.fullmatch('[a-zA-Z0-9_-]+',label)
    (q/(label+'-'+side+'.png')).write_bytes(adb('exec-out','screencap','-p'));print('Owned APP screenshot saved',side,label)
else:raise ValueError('Unknown action')
