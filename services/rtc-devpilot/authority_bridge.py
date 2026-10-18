"""Private Unix socket to the pilot loopback API, without logging request bytes."""
import asyncio
import os
from pathlib import Path
import socket
import stat

SOCKET_ROOT = Path('/opt/elitesync-v10.1.0-devpilot/shared/run')


def prepare_socket(path):
    if path.parent != SOCKET_ROOT or path.name not in {
            'rtc-authority.sock', 'rtc-signal.sock', 'rtc-media.sock'}:
        raise RuntimeError('unexpected private socket')
    if not path.exists():
        return
    info = path.lstat()
    if not stat.S_ISSOCK(info.st_mode) or info.st_uid != os.getuid():
        raise RuntimeError('private socket ownership conflict')
    probe = socket.socket(socket.AF_UNIX)
    try:
        probe.settimeout(.2)
        probe.connect(str(path))
    except ConnectionRefusedError:
        path.unlink()  # Only this task's stopped, owned Unix socket.
    else:
        raise RuntimeError('private socket still active')
    finally:
        probe.close()


async def pipe(reader, writer):
    while True:
        chunk = await reader.read(65536)
        if not chunk:
            return
        writer.write(chunk)
        await writer.drain()


async def relay(reader, writer, port):
    upstream = None
    tasks = []
    try:
        remote, upstream = await asyncio.wait_for(asyncio.open_connection('127.0.0.1', port), 1)
        tasks = [asyncio.create_task(pipe(reader, upstream)), asyncio.create_task(pipe(remote, writer))]
        await asyncio.wait(tasks, return_when=asyncio.FIRST_COMPLETED)
    except (OSError, asyncio.TimeoutError):
        pass
    finally:
        for task in tasks:
            task.cancel()
        await asyncio.gather(*tasks, return_exceptions=True)
        if upstream is not None:
            upstream.close()
        writer.close()


async def main():
    path = SOCKET_ROOT / 'rtc-authority.sock'
    prepare_socket(path)
    server = await asyncio.start_unix_server(lambda r, w: relay(r, w, 8030), str(path), limit=32768)
    path.chmod(0o600)
    async with server:
        await server.serve_forever()


if __name__ == '__main__':
    asyncio.run(main())
