"""Resolve official Docker manifest digests before any pull; no registry token output."""
import json, sys, urllib.request, pathlib, hashlib
q = pathlib.Path(sys.argv[1]); q.mkdir(parents=True, exist_ok=True)
results=[]
for repo, tag in [('livekit/livekit-server','v1.13.10'), ('library/python','3.11-alpine')]:
    auth=json.load(urllib.request.urlopen('https://auth.docker.io/token?service=registry.docker.io&scope=repository:'+repo+':pull'))['token']
    request=urllib.request.Request('https://registry-1.docker.io/v2/'+repo+'/manifests/'+tag, headers={'Authorization':'Bearer '+auth,'Accept':'application/vnd.oci.image.index.v1+json, application/vnd.docker.distribution.manifest.list.v2+json, application/vnd.docker.distribution.manifest.v2+json'})
    with urllib.request.urlopen(request) as response:
        raw=response.read(); digest=response.headers['Docker-Content-Digest']
    assert digest == 'sha256:'+hashlib.sha256(raw).hexdigest()
    manifest=json.loads(raw)
    platforms=[d for d in manifest.get('manifests',[]) if d.get('platform',{}).get('architecture')=='amd64' and d.get('platform',{}).get('os')=='linux']
    if manifest.get('manifests'): assert len(platforms)==1
    results.append({'repository':repo,'tag':tag,'digest':digest,'linux_amd64':platforms,'pull_ref':repo+'@'+digest})
    (q/(repo.replace('/','-')+'-manifest.json')).write_bytes(raw)
(q/'official-images.json').write_text(json.dumps(results,indent=2))
for r in results: print(r['repository'],r['tag'],r['digest'])
