"""Helpers for exactly the two owned V1009 AVDs. Discovery credentials stay local."""
import json,pathlib,subprocess,sys
Q=pathlib.Path(sys.argv[1]);sys.path.insert(0,str(Q/'tools/python'))
import grpc
import emulator_controller_pb2 as pb
import emulator_controller_pb2_grpc as rpc

def client(suffix):
    owned=json.loads((Q/'owned-avds.json').read_text())
    item=next(x for x in owned if x['name']=='elitesync_v1009_'+suffix)
    name=subprocess.check_output(['adb','-s',item['serial'],'emu','avd','name']).decode().splitlines()[0].strip()
    assert name==item['name']
    discovery=pathlib.Path.home()/'AppData/Local/Temp/avd/running'
    found=None
    for ini in discovery.glob('pid_*.ini'):
        fields=dict(line.split('=',1) for line in ini.read_text().splitlines() if '=' in line)
        if fields.get('avd.name')==name:
            assert int(fields['grpc.port'])==item['grpc'];found=fields;break
    assert found is not None
    channel=grpc.insecure_channel('127.0.0.1:'+str(item['grpc']))
    return rpc.EmulatorControllerStub(channel), [('authorization','Bearer '+found['grpc.token'])]

if __name__=='__main__':
    for suffix in ['a','b']:
        stub,headers=client(suffix)
        status=stub.getStatus(pb.google_dot_protobuf_dot_empty__pb2.Empty(),metadata=headers,timeout=3)
        print('Owned AVD',suffix,'booted',status.booted)
