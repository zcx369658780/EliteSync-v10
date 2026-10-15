"""Build/run only the owned V1009 container using preverified image digests."""
import pathlib,json,subprocess,sys,hashlib
q=pathlib.Path(sys.argv[1]).resolve();root=pathlib.Path(__file__).resolve().parent
action=sys.argv[2];images=json.loads((q/'official-images.json').read_text())
env=json.loads((q/'secrets/runtime-env.json').read_text())

def run(label,args):
    with (q/(label+'.stdout')).open('wb') as out,(q/(label+'.stderr')).open('wb') as err:
        result=subprocess.run(args,stdout=out,stderr=err)
    (q/(label+'.exit')).write_text(str(result.returncode));print(label,'exit',result.returncode,flush=True)
    if result.returncode: raise SystemExit(result.returncode)

if action=='build':
    run('sfu-build',['docker','build','--build-arg','LIVEKIT_IMAGE='+images[0]['pull_ref'],'--build-arg','PYTHON_IMAGE='+images[1]['pull_ref'],'-f',str(root/'Dockerfile.rtc'),'-t','elitesync-v1009-rtc:local',str(root)])
elif action=='start':
    if subprocess.run(['docker','inspect','elitesync-v1009-rtc'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL).returncode==0: raise RuntimeError('Existing owned container retained; use explicit restart after inspection')
    private=q/'secrets'
    config={'port':7880,'bind_addresses':['127.0.0.1'],'rtc':{'node_ip':'10.0.2.2','use_external_ip':False,'udp_port':7882,'tcp_port':7881},'keys':{env['LIVEKIT_API_KEY']:env['LIVEKIT_API_SECRET']},'logging':{'level':'warn'}}
    (private/'livekit.yaml').write_text(json.dumps(config))
    (private/'gateway.env').write_text('\n'.join(k+'='+env[k] for k in ['LIVEKIT_API_KEY','LIVEKIT_API_SECRET','V1009_GATEWAY_SECRET'])+'\n')
    for name in ['requests','replies']:(q/'bridge'/name).mkdir(parents=True,exist_ok=True)
    run('sfu-create',['docker','run','-d','--name','elitesync-v1009-rtc','--label','elitesync.version=v10.0.9','--env-file',str(private/'gateway.env'),'-p','127.0.0.1:7884:7884/tcp','-p','127.0.0.1:7882:7882/udp','--mount','type=bind,source='+str(private/'livekit.yaml')+',target=/private/livekit.yaml,readonly','--mount','type=bind,source='+str(q/'bridge')+',target=/bridge','elitesync-v1009-rtc:local'])
else: raise ValueError('Unknown action')
