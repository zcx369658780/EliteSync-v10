"""Bounded offline Flutter router runner; preserves every attempt separately.

Usage: python verify_router.py LABEL LOCAL_EVIDENCE_DIR [test paths ...]
Requires existing SDK/package_config/package_graph. Never runs pub get.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[3]
module = root / 'apps/flutter_elitesync_module'
label, evidence = sys.argv[1:3]
tests = sys.argv[3:] or ['test/app/router/home_progress_guard_refresh_test.dart']
output = Path(evidence) / label
output.mkdir(parents=True, exist_ok=False)
command = (['D:/flutter/bin/dart.bat', 'analyze', *tests[1:]] if tests[0] == '--analyze'
           else ['D:/flutter/bin/flutter.bat', 'test', '--no-pub', '--reporter', 'expanded', *tests])
env = dict(os.environ, FLUTTER_SUPPRESS_ANALYTICS='true', CI='true')
start = time.time()
with (output / 'stdout.txt').open('wb') as stdout, (output / 'stderr.txt').open('wb') as stderr:
    result = subprocess.run(command, cwd=module, env=env, stdin=subprocess.DEVNULL, stdout=stdout, stderr=stderr)
paths = ['lib/app/router/app_router.dart', 'test/app/router/home_progress_guard_refresh_test.dart', 'pubspec.lock']
receipt = {
    'command': command, 'stdin': 'DEVNULL', 'exit_code': result.returncode,
    'started_unix': start, 'elapsed_seconds': round(time.time() - start, 2),
    'head': subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD']).decode().strip(),
    'input_raw_sha256': {path: hashlib.sha256((module / path).read_bytes()).hexdigest() for path in paths},
    'stream_sha256': {name: hashlib.sha256((output / name).read_bytes()).hexdigest() for name in ['stdout.txt', 'stderr.txt']},
}
(output / 'receipt.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8')
print(json.dumps(receipt))
sys.exit(result.returncode)
