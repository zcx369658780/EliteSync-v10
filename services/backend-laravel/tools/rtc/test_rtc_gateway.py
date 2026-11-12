import asyncio
import importlib.util
import json
import os
from pathlib import Path
import time
import unittest
from unittest.mock import AsyncMock, patch

os.environ.setdefault('LIVEKIT_API_KEY', 'test-key-only')
os.environ.setdefault('LIVEKIT_API_SECRET', 'test-secret-only-not-a-real-credential')
os.environ.setdefault('V1009_GATEWAY_SECRET', 'test-gateway-only-not-a-real-credential')
spec = importlib.util.spec_from_file_location('current_rtc_gateway', Path(__file__).with_name('rtc_gateway.py'))
gateway = importlib.util.module_from_spec(spec)
spec.loader.exec_module(gateway)


class Writer:
    def __init__(self):
        self.data = bytearray()
        self.closed = False

    def write(self, data):
        self.data.extend(data)

    async def drain(self):
        pass

    def close(self):
        self.closed = True

    async def wait_closed(self):
        pass


class Process:
    returncode = None

    def __init__(self):
        self.killed = False

    def kill(self):
        self.killed = True


class GatewayTest(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        gateway.ready = True
        gateway.last_sweep = time.monotonic()
        gateway.child = Process()
        gateway.watchdog = Process()

    def token(self, **changes):
        return gateway.jwt({'sub': 'current-test-identity', 'nbf': int(time.time()) - 1,
                            'exp': int(time.time()) + 60,
                            'video': {'roomJoin': True, 'room': 'current-test-room'}, **changes})

    async def request(self, token, extra=b'', path='/rtc'):
        reader = asyncio.StreamReader()
        reader.feed_data(('GET '+path+'?access_token='+token+' HTTP/1.1\r\n'
                          'Host: localhost\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n').encode()+extra+b'\r\n')
        reader.feed_eof()
        writer = Writer()
        await gateway.handle(reader, writer)
        return writer

    async def test_current_authority_bridge_sends_actual_private_header_and_json(self):
        observed = {}

        async def handler(reader, writer):
            header = await reader.readuntil(b'\r\n\r\n')
            length = int(next(line.split(b':', 1)[1] for line in header.split(b'\r\n') if line.startswith(b'Content-Length:')))
            observed.update(header=header, body=json.loads(await reader.readexactly(length)))
            body = b'{"allowed":true,"call_id":7}'
            writer.write(b'HTTP/1.1 200 OK\r\nContent-Length: '+str(len(body)).encode()+b'\r\nConnection: close\r\n\r\n'+body)
            await writer.drain()
            writer.close()

        server = await asyncio.start_server(handler, '127.0.0.1', 0)
        self.addAsyncCleanup(server.wait_closed)
        self.addCleanup(server.close)
        port = server.sockets[0].getsockname()[1]
        with patch.object(gateway, 'BACKEND', '127.0.0.1'), patch.object(gateway, 'BACKEND_PORT', port):
            result = await gateway.backend('authorize', {'room': 'current-test-room', 'identity': 'current-test-identity'})
        self.assertEqual(result, {'allowed': True, 'call_id': 7})
        self.assertIn(b'POST /api/v1/rtc-guard/authorize HTTP/1.1', observed['header'])
        self.assertIn(('X-RTC-Gateway: '+gateway.GATE).encode(), observed['header'])
        self.assertEqual(observed['body'], {'room': 'current-test-room', 'identity': 'current-test-identity'})

    async def test_valid_signed_join_is_forwarded_only_after_current_authority(self):
        remote = asyncio.StreamReader()
        remote.feed_data(b'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\n\r\n')
        remote.feed_eof()
        upstream = Writer()
        authority = AsyncMock(return_value={'allowed': True})
        with patch.object(gateway, 'backend', authority), patch.object(gateway.asyncio, 'open_connection', AsyncMock(return_value=(remote, upstream))):
            writer = await self.request(self.token())
        authority.assert_awaited_once_with('authorize', {'room': 'current-test-room', 'identity': 'current-test-identity'})
        self.assertTrue(writer.data.startswith(b'HTTP/1.1 101 '))
        self.assertTrue(upstream.data.startswith(b'GET /rtc?access_token='))
        self.assertTrue(writer.closed)

    async def test_invalid_or_ambiguous_join_never_reaches_authority_or_raw_sfu(self):
        head, signature = self.token().rsplit('.', 1)
        wrong_signature = head+'.'+('A' if signature[0] != 'A' else 'B')+signature[1:]
        cases = [
            (self.token(exp=int(time.time())-1), b''),
            (self.token(nbf=int(time.time())+60), b''),
            (self.token(iss='wrong-issuer'), b''),
            (self.token(video={'roomJoin': True, 'room': 'current-test-room', 'roomAdmin': True}), b''),
            ('invalid.signature.value', b''),
            (wrong_signature, b''),
            (self.token(), b'Authorization: Bearer another-token\r\n'),
            (self.token(), b'Host: duplicate\r\n'),
            (self.token(), b'Transfer-Encoding: chunked\r\n'),
            (self.token(), b'Content-Length: 1\r\n'),
        ]
        for token, extra in cases:
            with self.subTest(extra=extra, token_type=token[:8]):
                authority = AsyncMock()
                upstream = AsyncMock()
                with patch.object(gateway, 'backend', authority), patch.object(gateway.asyncio, 'open_connection', upstream):
                    writer = await self.request(token, extra)
                self.assertTrue(writer.data.startswith(b'HTTP/1.1 403 '))
                authority.assert_not_awaited()
                upstream.assert_not_awaited()

    async def test_current_authority_denial_or_stale_monitor_cannot_forward_a_valid_old_token(self):
        for stale in [False, True]:
            with self.subTest(stale=stale):
                gateway.last_sweep = time.monotonic() - (4 if stale else 0)
                upstream = AsyncMock()
                with patch.object(gateway, 'backend', AsyncMock(side_effect=RuntimeError('current authority denied'))), patch.object(gateway.asyncio, 'open_connection', upstream):
                    writer = await self.request(self.token())
                self.assertTrue(writer.data.startswith(b'HTTP/1.1 403 '))
                upstream.assert_not_awaited()

    async def test_authority_failure_stops_owned_media_child(self):
        with patch.object(gateway, 'backend', AsyncMock(side_effect=RuntimeError('unavailable'))):
            await gateway.reconcile()
        self.assertTrue(gateway.child.killed)
        self.assertFalse(gateway.ready)

    async def test_timeout_diagnostic_identifies_phase_without_private_request_data(self):
        cases = [('authority_sweep', True), ('sfu_list_rooms', False)]
        for phase, fail_authority in cases:
            with self.subTest(phase=phase):
                authority = AsyncMock(side_effect=TimeoutError()) if fail_authority else AsyncMock(return_value={'allowed_rooms': []})
                with patch.object(gateway, 'backend', authority), patch.object(gateway, 'control', AsyncMock(side_effect=TimeoutError())), patch('builtins.print') as output:
                    await gateway.reconcile()
                event = json.loads(output.call_args_list[0].args[0])
                self.assertEqual(event['phase'], phase)
                self.assertEqual(event['error_type'], 'TimeoutError')
                self.assertGreaterEqual(event['elapsed_ms'], 0)
                self.assertNotIn(gateway.GATE, json.dumps(event))
                self.assertNotIn('http', json.dumps(event))
                self.assertTrue(gateway.child.killed)

    async def test_room_delete_failure_stops_media_before_optional_audit(self):
        order = []

        async def authority(action, payload):
            if action == 'sweep':
                return {'allowed_rooms': []}
            order.append(('audit', gateway.child.killed))
            raise RuntimeError('audit unavailable')

        async def control(action, payload):
            if action == 'ListRooms':
                return {'rooms': [{'name': 'revoked-test-room'}]}
            raise RuntimeError('SFU delete failed')

        with patch.object(gateway, 'backend', authority), patch.object(gateway, 'control', control):
            await gateway.reconcile()
        self.assertTrue(gateway.child.killed)
        self.assertFalse(gateway.ready)
        self.assertEqual(order, [('audit', True)])


if __name__ == '__main__':
    unittest.main()
