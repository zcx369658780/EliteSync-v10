"""V1009 private SFU supervisor and authenticated signaling gateway (stdlib only).

The SFU has no published signal/API port. Backend uncertainty terminates its
owned child, not merely the client websocket. No request URLs or JWTs are logged.
"""
import asyncio, base64, hashlib, hmac, json, os, signal, time, pathlib, uuid
from urllib.parse import urlsplit, parse_qs

SECRET=os.environ['LIVEKIT_API_SECRET'].encode()
KEY=os.environ['LIVEKIT_API_KEY']
GATE=os.environ['V1009_GATEWAY_SECRET']
BACKEND=os.environ.get('RTC_AUTHORITY_HOST','host.docker.internal')
child=None
last_sweep=0.0
ready=False

def b64(raw): return base64.urlsafe_b64encode(raw).decode().rstrip('=')
def decode(raw): return json.loads(base64.urlsafe_b64decode(raw+'='*(-len(raw)%4)))
def jwt(claims):
    data=b64(b'{"alg":"HS256","typ":"JWT"}')+'.'+b64(json.dumps({'iss':KEY, **claims},separators=(',',':')).encode())
    return data+'.'+b64(hmac.new(SECRET,data.encode(),hashlib.sha256).digest())

async def http(host,port,path,payload,headers):
    reader,writer=await asyncio.wait_for(asyncio.open_connection(host,port),.6)
    body=json.dumps(payload).encode()
    raw=f'POST {path} HTTP/1.1\r\nHost: {host}\r\nConnection: close\r\nContent-Type: application/json\r\nContent-Length: {len(body)}\r\n'
    for k,v in headers.items(): raw+=k+': '+v+'\r\n'
    try:
        writer.write(raw.encode()+b'\r\n'+body); await writer.drain()
        response=await asyncio.wait_for(reader.read(),1)
        head,body=response.split(b'\r\n\r\n',1)
        if int(head.split(b' ')[1])!=200: raise RuntimeError('control denied')
        return json.loads(body)
    finally:
        writer.close(); await writer.wait_closed()

async def backend(action,payload):
    # Request/reply over a private bind mount avoids exposing a host API NIC.
    key=uuid.uuid4().hex;root=pathlib.Path('/bridge');request=root/'requests'/(key+'.json');reply=root/'replies'/(key+'.json')
    temporary=request.with_suffix('.tmp')
    temporary.write_text(json.dumps({'action':action,'payload':payload}));temporary.replace(request)
    try:
        for _ in range(100):
            if reply.exists():
                result=json.loads(reply.read_text())
                if not result.get('ok'): raise RuntimeError('authority denied')
                return result['data']
            await asyncio.sleep(.01)
        raise RuntimeError('authority timeout')
    finally:
        request.unlink(missing_ok=True);reply.unlink(missing_ok=True)
async def control(action,payload):
    token=jwt({'sub':'rtc-supervisor','nbf':int(time.time())-2,'exp':int(time.time())+20,'video':{'roomList':True,'roomCreate':True,'roomAdmin':True,'room':payload.get('room','')}})
    return await http('127.0.0.1',7880,'/twirp/livekit.RoomService/'+action,payload,{'Authorization':'Bearer '+token})

def stop_sfu():
    global ready
    ready=False
    if child and child.returncode is None:
        child.kill()
    print(json.dumps({'event':'sfu_fail_closed','time':time.time()}),flush=True)

async def reconcile():
    global last_sweep,ready
    while True:
        try:
            result=await backend('sweep',{})
            allowed=set(result['allowed_rooms'])
            rooms=(await control('ListRooms',{})).get('rooms',[])
            for room in rooms:
                name=room['name']
                if name not in allowed:
                    try:
                        await asyncio.wait_for(control('DeleteRoom',{'room':name}),.75)
                    except Exception:
                        # Stop media first; never spend the 5s budget on retry/audit.
                        stop_sfu()
                        try: await backend('audit',{'room':name,'event':'sfu_remove_failed','attempt':1})
                        except Exception: pass
                        return
                    print(json.dumps({'event':'room_removed','room':name,'time':time.time(),'attempt':1}),flush=True)
                    await backend('audit',{'room':name,'event':'sfu_removed','attempt':1})
            last_sweep=time.monotonic(); ready=True
        except Exception:
            stop_sfu()
            return
        await asyncio.sleep(.25)

async def handle(reader,writer):
    upstream=None
    try:
        header=await asyncio.wait_for(reader.readuntil(b'\r\n\r\n'),2)
        if len(header)>32768: raise ValueError('headers too large')
        lines=header.decode('latin1').split('\r\n');method,target,version=lines[0].split(' ')
        url=urlsplit(target)
        if method!='GET' or url.path not in ['/rtc','/rtc/validate'] or not ready or time.monotonic()-last_sweep>1.5: raise ValueError('unavailable')
        headers={}
        for line in lines[1:]:
            if not line: continue
            k,v=line.split(':',1);k=k.lower()
            if k in headers: raise ValueError('duplicate header')
            headers[k]=v.strip()
        if 'transfer-encoding' in headers or headers.get('content-length','0') != '0': raise ValueError('GET body denied')
        websocket=url.path=='/rtc'
        if websocket and (headers.get('upgrade','').lower()!='websocket' or 'upgrade' not in headers.get('connection','').lower()): raise ValueError('upgrade required')
        if not websocket and 'upgrade' in headers: raise ValueError('invalid upgrade')
        query=parse_qs(url.query)
        values=query.get('access_token',[])
        bearer=headers.get('authorization','')
        if bearer:
            if values or not bearer.startswith('Bearer '): raise ValueError('ambiguous token')
            values=[bearer[7:]]
        if len(values)!=1: raise ValueError('missing token')
        token=values[0];a,b,c=token.split('.')
        if decode(a).get('alg')!='HS256' or not hmac.compare_digest(b64(hmac.new(SECRET,(a+'.'+b).encode(),hashlib.sha256).digest()),c): raise ValueError('signature')
        claims=decode(b);now=time.time();grant=claims.get('video',{})
        if claims.get('iss')!=KEY or claims.get('exp',0)<=now or claims.get('nbf',now+1)>now: raise ValueError('expired')
        if not grant.get('roomJoin') or not grant.get('room') or not claims.get('sub') or grant.get('roomAdmin') or grant.get('roomCreate'): raise ValueError('grant')
        await backend('authorize',{'room':grant['room'],'identity':claims['sub']})
        remote,upstream=await asyncio.open_connection('127.0.0.1',7880)
        if not websocket:
            # Never turn an authorized validate request into a keepalive tunnel.
            headers['connection']='close'
            header=(lines[0]+'\r\n'+''.join(k+': '+v+'\r\n' for k,v in headers.items())+'\r\n').encode('latin1')
        upstream.write(header);await upstream.drain()
        if not websocket:
            while True:
                data=await asyncio.wait_for(remote.read(65536),2)
                if not data: return
                writer.write(data);await writer.drain()
        response=await asyncio.wait_for(remote.readuntil(b'\r\n\r\n'),2)
        if not response.startswith(b'HTTP/1.1 101 '): raise ValueError('upgrade failed')
        writer.write(response);await writer.drain()
        async def pipe(source,dest):
            while True:
                data=await source.read(65536)
                if not data: break
                dest.write(data);await dest.drain()
        tasks=[asyncio.create_task(pipe(reader,upstream)),asyncio.create_task(pipe(remote,writer))]
        done,pending=await asyncio.wait(tasks,return_when=asyncio.FIRST_COMPLETED)
        for task in pending: task.cancel()
        await asyncio.gather(*tasks,return_exceptions=True)
    except Exception:
        try: writer.write(b'HTTP/1.1 403 Forbidden\r\nContent-Length: 0\r\nConnection: close\r\n\r\n');await writer.drain()
        except Exception: pass
    finally:
        if upstream: upstream.close()
        writer.close()

async def main():
    global child,last_sweep
    # stdout/stderr contains LiveKit's own non-JWT diagnostics; retain LOCAL_ONLY.
    child=await asyncio.create_subprocess_exec('/usr/local/bin/livekit-server','--config','/private/livekit.yaml')
    await asyncio.sleep(1)
    last_sweep=time.monotonic()
    async def watchdog():
        while child.returncode is None:
            if time.monotonic()-last_sweep>2:
                stop_sfu();return
            await asyncio.sleep(.05)
    deadline=asyncio.create_task(watchdog())
    monitor=asyncio.create_task(reconcile())
    server=await asyncio.start_server(handle,'0.0.0.0',7884,limit=32768)
    async with server:
        await monitor
        server.close();await server.wait_closed()
    await child.wait()
    raise SystemExit(1)

if __name__=='__main__': asyncio.run(main())
