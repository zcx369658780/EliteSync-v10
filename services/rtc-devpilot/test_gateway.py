"""Adapter transport checks; these do not substitute for real cloud RTC media."""
import asyncio
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import importlib.util
import os
import sys
from pathlib import Path
import threading
import unittest
from unittest.mock import AsyncMock, Mock, patch

os.environ.setdefault('LIVEKIT_API_KEY', 'test-only')
os.environ.setdefault('LIVEKIT_API_SECRET', 'not-a-real-key' * 4)
os.environ.setdefault('V1009_GATEWAY_SECRET', 'not-a-real-gateway' * 3)
sys.path.insert(0, str(Path(__file__).parent))
spec = importlib.util.spec_from_file_location('pilot_gateway', Path(__file__).with_name('gateway.py'))
pilot = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pilot)


class AdapterTransportTest(unittest.TestCase):
    def response(self, status, body, chunked=False):
        class Handler(BaseHTTPRequestHandler):
            def do_POST(self):
                self.rfile.read(int(self.headers.get('Content-Length', 0)))
                self.send_response(status)
                if chunked:
                    self.send_header('Transfer-Encoding', 'chunked')
                else:
                    self.send_header('Content-Length', str(len(body)))
                self.end_headers()
                if chunked:
                    self.wfile.write(f'{len(body):x}\r\n'.encode() + body + b'\r\n0\r\n\r\n')
                else:
                    self.wfile.write(body)

            def log_message(self, *_):
                pass

        server = ThreadingHTTPServer(('127.0.0.1', 0), Handler)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(server.server_close)
        self.addCleanup(server.shutdown)
        return lambda: pilot._post(server.server_port, '/test-only', {}, {})

    def test_chunked_authority_json_is_decoded(self):
        self.assertEqual({'allowed_rooms': []}, self.response(200, b'{"allowed_rooms":[]}', True)())

    def test_non_success_is_not_an_allow_list(self):
        with self.assertRaises(RuntimeError):
            self.response(503, b'{"allowed_rooms":[]}')()

    def test_oversized_control_response_is_rejected(self):
        with self.assertRaises(RuntimeError):
            self.response(200, b' ' * 131073)()

    def test_array_response_cannot_be_an_authority_object(self):
        with self.assertRaises(RuntimeError):
            self.response(200, b'[]')()

    def test_invalid_json_is_rejected(self):
        with self.assertRaises(ValueError):
            self.response(200, b'not-json')()

    def test_unknown_backend_action_has_no_network_use(self):
        with self.assertRaises(ValueError):
            asyncio.run(pilot.backend('delete-production', {}))

    def test_unknown_control_action_has_no_network_use(self):
        with self.assertRaises(ValueError):
            asyncio.run(pilot.control('CreateRoom', {}))

    def test_watchdog_start_failure_kills_owned_sfu_and_closes_pipe(self):
        child = Mock(pid=12345, returncode=None)
        child.wait = AsyncMock(return_value=-9)
        pilot.gateway.child = None
        pilot.gateway.watchdog = None
        pilot.gateway.watchdog_pipe = None
        with patch.dict(os.environ, {'V10100_PRIVATE_RUNTIME': '/opt/elitesync-v10.1.0-devpilot/shared/runtime'}), \
                patch.object(pilot.signal, 'signal'), \
                patch.object(pilot.asyncio, 'sleep', new=AsyncMock()), \
                patch.object(pilot.asyncio, 'create_subprocess_exec', new=AsyncMock(
                    side_effect=[child, RuntimeError('test watchdog launch failure')])), \
                patch.object(pilot.os, 'pipe', return_value=(101, 102)), \
                patch.object(pilot.os, 'set_blocking', create=True), \
                patch.object(pilot.os, 'close') as close:
            with self.assertRaisesRegex(RuntimeError, 'watchdog launch failure'):
                asyncio.run(pilot.main())
            child.kill.assert_called_once()
            child.wait.assert_awaited_once()
            self.assertEqual({101, 102}, {call.args[0] for call in close.call_args_list})

    def test_sigterm_before_watchdog_kills_child_and_runs_cleanup(self):
        child = Mock(pid=12345, returncode=None)
        child.kill.side_effect = lambda: setattr(child, 'returncode', -9)
        child.wait = AsyncMock(return_value=-9)
        pilot.gateway.child = None
        pilot.gateway.watchdog = None
        pilot.gateway.watchdog_pipe = None
        handlers = []
        real_sleep = asyncio.sleep
        async def pause(_):
            handlers[-1]()
            await real_sleep(0)
        with patch.dict(os.environ, {'V10100_PRIVATE_RUNTIME': '/opt/elitesync-v10.1.0-devpilot/shared/runtime'}), \
                patch.object(pilot.signal, 'signal', side_effect=lambda _, handler: handlers.append(handler)), \
                patch.object(pilot.asyncio, 'sleep', side_effect=pause), \
                patch.object(pilot.asyncio, 'create_subprocess_exec', new=AsyncMock(return_value=child)):
            with self.assertRaises(asyncio.CancelledError):
                asyncio.run(pilot.main())
            child.kill.assert_called_once()
            child.wait.assert_awaited_once()


if __name__ == '__main__':
    unittest.main()
