"""Loopback-only v10.1.0 adapter for the accepted v10.0.9 RTC authority gateway.

Owns a separate SFU child and watchdog. It never supervises the historical SFU,
opens a public listener, or uses historical SFU credentials.
"""
import asyncio
import importlib.util
import hashlib
import hmac
import http.client
import json
from urllib.parse import urlsplit, parse_qs
import os
from pathlib import Path
import signal
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
HISTORICAL = ROOT / "docs/versions/v10.0.9"
spec = importlib.util.spec_from_file_location("accepted_rtc_gateway", HISTORICAL / "rtc-gateway.py")
gateway = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gateway)


def _post(port, path, payload, headers):
    """Bounded HTTP client; Nginx may use chunked JSON responses."""
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=1)
    try:
        connection.request("POST", path, body=json.dumps(payload).encode(),
                           headers={"Content-Type": "application/json", **headers})
        response = connection.getresponse()
        body = response.read(131073)
        if response.status != 200 or len(body) > 131072:
            raise RuntimeError("control denied")
        result = json.loads(body)
        if not isinstance(result, dict):
            raise RuntimeError("invalid control response")
        return result
    finally:
        connection.close()


async def backend(action, payload):
    if action not in {"authorize", "sweep", "audit"}:
        raise ValueError("unknown authority action")
    return await asyncio.to_thread(_post, 8030, "/api/v1/rtc-guard/" + action,
                                   payload, {"X-RTC-Gateway": gateway.GATE})


async def control(action, payload):
    if action not in {"ListRooms", "DeleteRoom"}:
        raise ValueError("unknown SFU control action")
    token = gateway.jwt({"sub": "v10100-supervisor", "nbf": int(time.time()) - 2,
                         "exp": int(time.time()) + 20,
                         "video": {"roomList": True, "roomAdmin": True,
                                   "room": payload.get("room", "")}})
    return await asyncio.to_thread(_post, 8034, "/twirp/livekit.RoomService/" + action,
                                   payload, {"Authorization": "Bearer " + token})


# Retain the accepted request/JWT parser; only the private upstream and
# supervisor state live in this deployment adapter.
async def handle(reader,writer):
    upstream=None
    try:
        header=await asyncio.wait_for(reader.readuntil(b'\r\n\r\n'),2)
        if len(header)>32768: raise ValueError('headers too large')
        lines=header.decode('latin1').split('\r\n');method,target,version=lines[0].split(' ')
        url=urlsplit(target)
        if method!='GET' or url.path not in ['/rtc','/rtc/validate'] or not gateway.ready or time.monotonic()-gateway.last_sweep>2.5: raise ValueError('unavailable')
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
        if gateway.decode(a).get('alg')!='HS256' or not hmac.compare_digest(gateway.b64(hmac.new(gateway.SECRET,(a+'.'+b).encode(),hashlib.sha256).digest()),c): raise ValueError('signature')
        claims=gateway.decode(b);now=time.time();grant=claims.get('video',{})
        if claims.get('iss')!=gateway.KEY or claims.get('exp',0)<=now or claims.get('nbf',now+1)>now: raise ValueError('expired')
        if not grant.get('roomJoin') or not grant.get('room') or not claims.get('sub') or grant.get('roomAdmin') or grant.get('roomCreate'): raise ValueError('grant')
        await backend('authorize',{'room':grant['room'],'identity':claims['sub']})
        remote,upstream=await asyncio.open_connection('127.0.0.1',8034)
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
    runtime = Path(os.environ["V10100_PRIVATE_RUNTIME"]).resolve()
    expected = Path("/opt/elitesync-v10.1.0-devpilot/shared/runtime").resolve()
    if runtime != expected:
        raise RuntimeError("unexpected private runtime")
    gateway.backend = backend
    gateway.control = control
    signal.signal(signal.SIGTERM, lambda *_: os._exit(1))
    gateway.child = await asyncio.create_subprocess_exec(
        str(runtime / "livekit-server"), "--config", str(runtime / "livekit.yaml"))
    await asyncio.sleep(1)
    if gateway.child.returncode is not None:
        raise RuntimeError("owned SFU exited before supervision")
    gateway.last_sweep = time.monotonic()
    reader, gateway.watchdog_pipe = os.pipe()
    os.set_blocking(gateway.watchdog_pipe, False)
    gateway.watchdog = await asyncio.create_subprocess_exec(
        sys.executable, str(HISTORICAL / "rtc-watchdog.py"), str(reader),
        str(os.getpid()), str(gateway.child.pid), pass_fds=(reader,), env={})
    os.close(reader)
    monitor = asyncio.create_task(gateway.reconcile())
    server = await asyncio.start_server(handle, "127.0.0.1", 8032, limit=32768)
    try:
        async with server:
            await monitor
    finally:
        server.close()
        await server.wait_closed()
        gateway.stop_sfu()
        if gateway.child.returncode is None:
            await gateway.child.wait()
        if gateway.watchdog.returncode is None:
            gateway.watchdog.terminate()
        os.close(gateway.watchdog_pipe)
    raise SystemExit(1)


if __name__ == "__main__":
    asyncio.run(main())
