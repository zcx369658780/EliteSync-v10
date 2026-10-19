import pathlib,json,datetime,time,subprocess
E=pathlib.Path(__file__).parent;p=json.loads((E/'secrets/phone-lan-plan.json').read_text());state=json.loads((E/'phone-lan-window-state.json').read_text(encoding='utf-8-sig'));end=datetime.datetime.fromisoformat(state['ends_utc']).timestamp()
while time.time()<end and not (E/'phone-lan-window-stop').exists():time.sleep(.25)
r=subprocess.run(['adb','-s','emulator-5556','shell','iptables','-t','nat','-D','OUTPUT','-p','udp','-d',p['host_ipv4'],'--dport','7882','-j','DNAT','--to-destination','10.0.2.2:7882'],capture_output=True,timeout=10)
(E/'phone-avd-dnat-removed.json').write_text(json.dumps({'exit':r.returncode,'time':time.time()}))
subprocess.run(['adb','-s','emulator-5556','emu','avd','hostmicoff'],stdout=subprocess.DEVNULL,timeout=10)
if r.returncode:subprocess.run(['adb','-s','emulator-5556','emu','kill'],stdout=subprocess.DEVNULL,timeout=10)
