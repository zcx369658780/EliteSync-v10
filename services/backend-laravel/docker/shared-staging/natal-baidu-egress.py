"""Allow the dedicated staging app to tunnel TLS only to the Baidu Web API."""

from argparse import ArgumentParser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import select
import socket
from threading import BoundedSemaphore
import time

HOST = "api.map.baidu.com"
PORT = 443
SLOTS = BoundedSemaphore(4)


class BaiduTunnel(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"
    rbufsize = 0

    def setup(self):
        self.request.settimeout(4)
        super().setup()

    def log_message(self, format, *args):
        # A tunnel carries encrypted traffic; do not log request material.
        pass

    def do_CONNECT(self):
        self.close_connection = True
        if (self.path != f"{HOST}:{PORT}"
                or self.headers.get("Transfer-Encoding")
                or self.headers.get("Content-Length") not in (None, "0")):
            self.send_error(403)
            return
        if not SLOTS.acquire(blocking=False):
            self.send_error(503)
            return
        try:
            self.tunnel()
        finally:
            SLOTS.release()

    def tunnel(self):
        try:
            upstream = socket.create_connection((HOST, PORT), timeout=3)
        except OSError:
            self.send_error(502)
            return
        with upstream:
            self.send_response_only(200, "Connection Established")
            self.end_headers()
            upstream.settimeout(4)
            sockets = (self.connection, upstream)
            deadline = time.monotonic() + 12
            while (remaining := deadline - time.monotonic()) > 0:
                try:
                    readable, _, _ = select.select(sockets, (), (), remaining)
                    for source in readable:
                        data = source.recv(65536)
                        if not data:
                            return
                        target = upstream if source is self.connection else self.connection
                        target.sendall(data)
                except OSError:
                    return


def main():
    parser = ArgumentParser(description=__doc__)
    parser.add_argument("--bind", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=18085)
    options = parser.parse_args()
    with ThreadingHTTPServer((options.bind, options.port), BaiduTunnel) as server:
        server.serve_forever()


if __name__ == "__main__":
    main()
