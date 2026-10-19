import asyncio,json,pathlib,time
import websockets
E=pathlib.Path(__file__).parent
exec((E/'http-matrix.py').read_text().split('for who in accounts:')[0])
sessions=json.loads((E/'secrets/http-sessions.json').read_text())
sessions['charlie']=call('charlie','POST','/auth/login',accounts['charlie'])
async def main():
    c=sessions['charlie']['user']['id']; b=sessions['bob']['user']['id']
    uri=f'ws://127.0.0.1:8013/api/v1/messages/ws/{c}?peer_id={b}'
    async with websockets.connect(uri,additional_headers={'Authorization':'Bearer '+sessions['charlie']['access_token']},proxy=None) as ws:
        greeting=json.loads(await asyncio.wait_for(ws.recv(),4)); assert greeting['type']=='connected'
        start=time.monotonic()
        call('charlie','POST','/auth/logout')
        try:
            while True: await asyncio.wait_for(ws.recv(),5)
        except websockets.exceptions.ConnectionClosed:
            elapsed=time.monotonic()-start
            assert elapsed<=5
            (E/'ws-revoke-result.json').write_text(json.dumps({'connected':True,'closed_after_logout_seconds':elapsed,'under_5_seconds':True}))
    try:
        async with websockets.connect(uri,additional_headers={'Authorization':'Bearer '+sessions['charlie']['access_token']},proxy=None) as ws:
            await asyncio.wait_for(ws.recv(),3)
            raise AssertionError('old session reconnected')
    except (websockets.exceptions.ConnectionClosed,websockets.exceptions.InvalidHandshake): pass
    print('WS_CONNECTED_THEN_REVOKED_AND_OLD_SESSION_DENIED')
asyncio.run(main())
