"""Owned loopback front for Windows' single-worker PHP development server.

Empty browser preconnections wait in separate threads, never in Laravel's worker.
All business responses come unchanged from PHP/Laravel on 127.0.0.1:8001.
No credentials, headers or bodies are logged.
"""
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from http.client import HTTPConnection
import sys

HOP = {'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization',
       'te', 'trailer', 'transfer-encoding', 'upgrade'}

class Front(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'
    def forward(self):
        if self.headers.get('Host') not in {'127.0.0.1:8000', 'localhost:8000'}:
            self.send_error(400, 'Dedicated loopback host required')
            return
        try:
            size = int(self.headers.get('Content-Length', '0'))
        except ValueError:
            self.send_error(400)
            return
        if size < 0 or size > 27 * 1024 * 1024:
            self.send_error(413)
            return
        body = self.rfile.read(size) if size else None
        headers = {k: v for k, v in self.headers.items() if k.lower() not in HOP}
        headers['Connection'] = 'close'
        connection = HTTPConnection('127.0.0.1', 8001, timeout=30)
        response_started = False
        try:
            connection.request(self.command, self.path, body=body, headers=headers)
            response = connection.getresponse()
            content = response.read()
            self.send_response(response.status)
            for key, value in response.getheaders():
                if key.lower() not in HOP | {'content-length'}:
                    self.send_header(key, value)
            self.send_header('Content-Length', str(len(content)))
            self.end_headers()
            response_started = True
            if self.command != 'HEAD':
                self.wfile.write(content)
        except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
            self.close_connection = True  # Client cancelled; never invent a 502.
        except (OSError, TimeoutError):
            if not response_started:
                self.send_error(502, 'Owned Laravel development service unavailable')
            self.close_connection = True
        finally:
            connection.close()
    do_GET = do_POST = do_PUT = do_DELETE = do_HEAD = do_OPTIONS = forward

if __name__ == '__main__':
    if len(sys.argv) > 1:
        sys.stderr = open(sys.argv[1], 'x', encoding='utf8', buffering=1)
    ThreadingHTTPServer(('127.0.0.1', 8000), Front).serve_forever()
