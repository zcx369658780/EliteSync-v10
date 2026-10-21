"""R1 loopback-only real-response fault injection; never a product endpoint.

Forward to the actual guarded Laravel/MariaDB instance, then suppress one
already-committed response. No response substitution, token logging, or mocks.
"""
import hashlib
import http.client
import json
import threading
import time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

lock = threading.Lock()
fault = None


def receipt(**fields):
    print(json.dumps({'time_ns': time.time_ns(), **fields}), flush=True)


class Proxy(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.0'

    def log_message(self, *args):
        pass  # Standard request logs may contain sensitive query parameters.

    def do_GET(self):
        self.forward()

    def do_POST(self):
        self.forward()

    def do_PUT(self):
        self.forward()

    def do_DELETE(self):
        self.forward()

    def forward(self):
        global fault
        if self.headers.get('Transfer-Encoding', '').lower() == 'chunked':
            parts = []
            size_total = 0
            while True:
                size = int(self.rfile.readline(128).split(b';', 1)[0], 16)
                if size == 0:
                    while self.rfile.readline(8192) != b'\r\n':
                        pass
                    break
                size_total += size
                if size_total > 32 * 1024 * 1024:
                    self.send_error(413)
                    return
                parts.append(self.rfile.read(size))
                if self.rfile.read(2) != b'\r\n':
                    self.send_error(400)
                    return
            body = b''.join(parts)
        else:
            body = self.rfile.read(int(self.headers.get('Content-Length', '0')))
        if self.path == '/__r1/control':
            data = json.loads(body)
            action = data.get('action')
            if action not in ('response_loss', 'late_private_read', 'clear'):
                self.send_error(400)
                return
            with lock:
                fault = None if action == 'clear' else action
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'{"test_only":true}')
            receipt(event='fault_armed', action=action)
            return
        selected = None
        parsed = {}
        if self.command == 'POST' and self.path == '/api/v1/messages':
            try:
                parsed = json.loads(body)
            except ValueError:
                pass
        with lock:
            if fault == 'response_loss' and str(parsed.get('content', '')).startswith('V1015_R1_LOSS_'):
                selected, fault = fault, None
            elif fault == 'late_private_read' and self.command == 'GET' and self.path.startswith('/api/v1/messages?'):
                selected, fault = fault, None
        upstream = http.client.HTTPConnection('127.0.0.1', 8030, timeout=25)
        try:
            headers = {k: v for k, v in self.headers.items() if k.lower() not in ('host', 'connection', 'content-length', 'transfer-encoding')}
            upstream.request(self.command, self.path, body=body, headers=headers)
            response = upstream.getresponse()
            result = response.read()
            status = response.status
            response_headers = response.getheaders()
        finally:
            upstream.close()
        if self.path == '/api/v1/messages' and self.command == 'POST':
            item = json.loads(result) if status == 200 else {}
            receipt(event='message_upstream_completed', status=status,
                    client_message_id=parsed.get('client_message_id'),
                    message_id=item.get('id'), replay=item.get('idempotent_replay', False),
                    response_sha256=hashlib.sha256(result).hexdigest(), fault=selected)
        if selected == 'response_loss':
            # Let Dio's real 20s receive timeout expire, with no HTTP bytes sent.
            receipt(event='committed_response_withheld', status=status)
            time.sleep(24)
            self.close_connection = True
            return
        if selected == 'late_private_read':
            receipt(event='private_read_held', status=status, response_sha256=hashlib.sha256(result).hexdigest())
            time.sleep(12)
        self.send_response(status)
        for key, value in response_headers:
            if key.lower() not in ('connection', 'transfer-encoding', 'content-length'):
                self.send_header(key, value)
        self.send_header('Content-Length', str(len(result)))
        self.end_headers()
        try:
            self.wfile.write(result)
            if selected == 'late_private_read':
                receipt(event='late_private_read_delivered', status=status)
        except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
            if selected:
                receipt(event='old_private_response_client_closed', fault=selected)


if __name__ == '__main__':
    receipt(event='test_proxy_started', downstream='loopback8031', upstream='loopback8030')
    ThreadingHTTPServer(('127.0.0.1', 8031), Proxy).serve_forever()
