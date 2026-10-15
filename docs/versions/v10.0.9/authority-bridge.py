"""Private request/reply bridge; keeps Laravel's host listener loopback-only."""
import concurrent.futures, http.client, json, pathlib, sys, time
q=pathlib.Path(sys.argv[1]);root=q/'bridge'
secret=json.loads((q/'secrets/runtime-env.json').read_text())['V1009_GATEWAY_SECRET']
for name in ['requests','replies']: (root/name).mkdir(parents=True,exist_ok=True)

def dispatch(path):
    key=path.stem
    if len(key)!=32 or any(c not in '0123456789abcdef' for c in key): return
    try:
        item=json.loads(path.read_text());path.unlink(missing_ok=True)
        if item['action'] not in ['authorize','sweep','audit']: raise ValueError('action')
        c=http.client.HTTPConnection('127.0.0.1',8002,timeout=.75)
        try:
            c.request('POST','/api/v1/rtc-guard/'+item['action'],json.dumps(item['payload']),{'Content-Type':'application/json','X-RTC-Gateway':secret})
            r=c.getresponse();body=r.read()
            result={'ok':r.status==200,'data':json.loads(body) if r.status==200 else {}}
        finally: c.close()
    except Exception: result={'ok':False,'data':{}}
    out=root/'replies'/(key+'.json');tmp=out.with_suffix('.tmp');tmp.write_text(json.dumps(result));tmp.replace(out)

with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
    while True:
        for path in (root/'requests').glob('*.json'):
            # Rename claims a request before a worker can process it again.
            claimed=path.with_suffix('.work')
            try: path.rename(claimed)
            except FileNotFoundError: continue
            pool.submit(dispatch,claimed)
        time.sleep(.01)
