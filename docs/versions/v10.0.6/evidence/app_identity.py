import subprocess,json,sys,xml.etree.ElementTree as ET
from pathlib import Path
root=Path(__file__).parent
raw=subprocess.check_output(['adb','-s','emulator-5580','shell','run-as','com.elitesync','cat','shared_prefs/FlutterSharedPreferences.xml'])
values={x.get('name'):x.text for x in ET.fromstring(raw)}
key='flutter.last_known_profile'
profile=json.loads(values[key]) if key in values else None
if profile:
    assert profile.get('phone') in ['19900000601','19900000602','19900000603']
result={'serial':'emulator-5580','package':'com.elitesync','cached_identity_present':profile is not None,
        'identity':{k:profile.get(k) for k in ['id','phone']} if profile else None,
        'profile_cache_presence':{k:('flutter.'+k) in values for k in ['last_known_profile','profile_summary_snapshot_v1','profile_detail_snapshot_v1']},
        'purpose':'identity/cleanup only; cached identity is not persistence proof; secure credentials were not read'}
(root/('app-identity-'+sys.argv[1]+'.json')).write_text(json.dumps(result,indent=2))
print(json.dumps(result))
