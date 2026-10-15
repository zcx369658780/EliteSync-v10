"""Bounded private-media authorization receipt; no bytes or credentials printed."""
import pathlib,sys,json,importlib.util,http.client,time,hashlib
q=pathlib.Path(sys.argv[1]);asset=int(sys.argv[2]);label=sys.argv[3]
spec=importlib.util.spec_from_file_location('client',pathlib.Path(__file__).with_name('runtime-client.py'))
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
out={'asset_id':asset,'time':time.time(),'checks':[]}
for name in ['alice','bob','pending',None]:
    for ranged in [True,False]:
        h=http.client.HTTPConnection('127.0.0.1',8000,timeout=5)
        headers={} if name is None else {'Authorization':'Bearer '+c.sessions[name]['token']}
        if ranged:headers['Range']='bytes=0-31'
        h.request('GET',f'/api/v1/media/{asset}/content',headers=headers)
        r=h.getresponse();data=r.read();out['checks'].append({'actor':name or 'anonymous','range':ranged,'status':r.status,'bytes':len(data),'sha256':hashlib.sha256(data).hexdigest(),'content_range':r.getheader('Content-Range')});h.close()
(q/(label+'-media-probe.json')).write_text(json.dumps(out,indent=2));print(json.dumps(out))
