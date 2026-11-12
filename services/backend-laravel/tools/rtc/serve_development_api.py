"""Give local RTC authority its own PHP worker pool and private listener.

Both listeners use the same Laravel kernel, database and existing gateway guard.
The authority listener has no host port publication. Regular application work
cannot occupy its PHP accept queue. No credentials or request URLs are logged.
"""
import os
from pathlib import Path
import signal
import subprocess
import time


def commands():
    php = ['php', '-d', 'opcache.enable_cli=1',
           '-d', 'opcache.validate_timestamps=1', '-d', 'opcache.revalidate_freq=2']
    return [
        (php + ['-d', 'upload_max_filesize=32M', '-d', 'post_max_size=36M',
                '-S', '0.0.0.0:8080', '-t', '/app/public', '/app/public/index.php'], 4),
        (php + ['-S', '0.0.0.0:8082', '-t', '/app/public',
                '/app/tools/rtc/authority_router.php'], 2),
    ]


def main():
    if not Path('/app/artisan').is_file():
        raise RuntimeError('Expected the owned development application')
    processes = []

    def stop(*_):
        for process in processes:
            try:
                os.killpg(process.pid, signal.SIGTERM)
            except ProcessLookupError:
                pass

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    try:
        for command, workers in commands():
            env = dict(os.environ, PHP_CLI_SERVER_WORKERS=str(workers))
            processes.append(subprocess.Popen(command, env=env, start_new_session=True))
        while all(process.poll() is None for process in processes):
            time.sleep(.1)
    finally:
        stop()
        for process in processes:
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
    return 1


if __name__ == '__main__':
    raise SystemExit(main())
