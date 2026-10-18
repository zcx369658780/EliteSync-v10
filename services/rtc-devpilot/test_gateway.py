"""Adapter transport checks; these do not substitute for real cloud RTC media."""
import asyncio
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import importlib.util
import os
from pathlib import Path
import threading
import unittest

os.environ.setdefault('LIVEKIT_API_KEY', 'test-only')
os.environ.setdefault('LIVEKIT_API_SECRET', 'not-a-real-key' * 4)
os.environ.setdefault('V1009_GATEWAY_SECRET', 'not-a-real-gateway' * 3)
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


if __name__ == '__main__':
    unittest.main()
