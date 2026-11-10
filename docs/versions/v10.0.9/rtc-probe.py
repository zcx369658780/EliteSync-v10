"""Current local RTC/JWT checks. Raw credentials never enter command output."""
import pathlib,sys,json,importlib.util,http.client,time,socket
q=pathlib.Path(sys.argv[1]);call=int(sys.argv[2]);label=sys.argv[3]
spec=importlib.util.spec_from_file_location('client',pathlib.Path(__file__).with_name('runtime-client.py'))
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
private=q/'secrets'/('rtc-probe-'+str(call)+'.json')
result={'call_id':call,'time':time.time()}
status,body=c.request('alice','GET',f'/api/v1/rtc/calls/{call}/livekit')
result['current_join_status']=status
if status==200:
    info=body['livekit'];private.write_text(json.dumps(info))
if private.exists():
    info=json.loads(private.read_text())
    h=http.client.HTTPConnection('127.0.0.1',7884,timeout=3)
    try:
        h.request('GET','/rtc/validate',headers={'Authorization':'Bearer '+info['token']})
        r=h.getresponse();result['saved_jwt_validate_status']=r.status;r.read()
    except Exception as e:result['saved_jwt_validate_error']=type(e).__name__
    finally:h.close()
for port in [7880,7881]:
    with socket.socket() as s:
        s.settimeout(.3);result['raw_port_'+str(port)+'_reachable']=s.connect_ex(('127.0.0.1',port))==0
(q/(label+'-probe.json')).write_text(json.dumps(result,indent=2));print(json.dumps(result))
