"""Build/run only the owned V1009 container using preverified image digests."""
import pathlib,json,subprocess,sys,hashlib,time,ipaddress
q=pathlib.Path(sys.argv[1]).resolve();root=pathlib.Path(__file__).resolve().parent
action=sys.argv[2];images=json.loads((q/'official-images.json').read_text())
env=json.loads((q/'secrets/runtime-env.json').read_text())

def run(label,args):
    if (q/(label+'.stdout')).exists():label+='-'+str(time.time_ns())
    with (q/(label+'.stdout')).open('wb') as out,(q/(label+'.stderr')).open('wb') as err:
        result=subprocess.run(args,stdout=out,stderr=err)
    (q/(label+'.exit')).write_text(str(result.returncode));print(label,'exit',result.returncode,flush=True)
    if result.returncode: raise SystemExit(result.returncode)

if action=='build':
    run('sfu-build',['docker','build','--build-arg','LIVEKIT_IMAGE='+images[0]['pull_ref'],'--build-arg','PYTHON_IMAGE='+images[1]['pull_ref'],'-f',str(root/'Dockerfile.rtc'),'-t','elitesync-v1009-rtc:local',str(root)])
elif action in ['start','start-stall-test','start-usb-tcp','start-lan-udp']:
    if subprocess.run(['docker','inspect','elitesync-v1009-rtc'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0: raise RuntimeError('Existing owned container retained; use explicit restart after inspection')
    private=q/'secrets'
    config={'port':7880,'bind_addresses':['127.0.0.1'],'rtc':{'node_ip':'10.0.2.2','use_external_ip':False,'udp_port':7882,'tcp_port':7881},'keys':{env['LIVEKIT_API_KEY']:env['LIVEKIT_API_SECRET']},'logging':{'level':'warn'}}
    usb_tcp = action == 'start-usb-tcp'
    if usb_tcp:
        config['rtc']={'node_ip':'127.0.0.1','use_external_ip':False,'tcp_port':7881,'force_tcp':True,'enable_loopback_candidate':True}
    lan_udp = action == 'start-lan-udp'
    if lan_udp:
        # This file records a separately granted, exact NIC/source firewall scope.
        # Creating firewall rules or requesting elevation is never done here.
        scope=json.loads((private/'rtc-lan-approval.json').read_text())
        address=ipaddress.ip_address(scope['local_ipv4'])
        assert scope.get('owner_approved') is True and scope['udp_port']==7882
        assert address.version==4 and address.is_private and not address.is_loopback
        assert scope['raw_sfu_7880_published'] is False and scope['public_bind'] is False
        config['rtc']={'node_ip':str(address),'use_external_ip':False,'udp_port':7882,'tcp_port':0}
    (private/'livekit.yaml').write_text(json.dumps(config))
    (private/'gateway.env').write_text('\n'.join(k+'='+env[k] for k in ['LIVEKIT_API_KEY','LIVEKIT_API_SECRET','V1009_GATEWAY_SECRET'])+'\n')
    for name in ['requests','replies']:(q/'bridge'/name).mkdir(parents=True,exist_ok=True)
    test_env=['--env','RTC_GUARD_TEST_STALL=1'] if action=='start-stall-test' else []
    media_mapping = '127.0.0.1:7881:7881/tcp' if usb_tcp else '127.0.0.1:7882:7882/udp'
    if lan_udp: media_mapping=str(address)+':7882:7882/udp'
    run('sfu-create',['docker','run','-d','--name','elitesync-v1009-rtc','--label','elitesync.version=v10.0.9','--env-file',str(private/'gateway.env'),*test_env,'-p','127.0.0.1:7884:7884/tcp','-p',media_mapping,'--mount','type=bind,source='+str(private/'livekit.yaml')+',target=/private/livekit.yaml,readonly','--mount','type=bind,source='+str(q/'bridge')+',target=/bridge','elitesync-v1009-rtc:local'])
else: raise ValueError('Unknown action')
