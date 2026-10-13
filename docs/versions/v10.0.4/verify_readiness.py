"""Bounded offline runner. Usage: python verify_readiness.py LABEL LOCAL_DIR [--analyze]."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[3]
module = root / 'apps/flutter_elitesync_module'
output = Path(sys.argv[2]) / sys.argv[1]
output.mkdir(parents=True, exist_ok=False)
paths = ['lib/features/me/presentation/pages/me_purpose_pages.dart',
         'test/features/me/presentation/pages/readiness_purpose_page_test.dart']
tests = [paths[1], 'test/synthetic_readiness_match_integration_test.dart',
         'test/app/router/first_use_onboarding_router_integration_test.dart']
command = (['D:/flutter/bin/dart.bat', 'analyze', *paths] if '--analyze' in sys.argv
           else ['D:/flutter/bin/flutter.bat', 'test', '--no-pub', '--reporter', 'expanded', *tests])
start = time.time()
with (output / 'stdout.txt').open('wb') as stdout, (output / 'stderr.txt').open('wb') as stderr:
    result = subprocess.run(command, cwd=module, stdin=subprocess.DEVNULL,
                            env=dict(os.environ, CI='true', FLUTTER_SUPPRESS_ANALYTICS='true'),
                            stdout=stdout, stderr=stderr)
receipt = {'command': command, 'stdin': 'DEVNULL', 'exit_code': result.returncode,
           'started_unix': start, 'elapsed_seconds': round(time.time() - start, 2),
           'head': subprocess.check_output(['git', '-C', str(root), 'rev-parse', 'HEAD']).decode().strip(),
           'input_raw_sha256': {p: hashlib.sha256((module / p).read_bytes()).hexdigest()
                                for p in dict.fromkeys([*paths, *tests, 'pubspec.lock'])},
           'stream_sha256': {p: hashlib.sha256((output / p).read_bytes()).hexdigest()
                             for p in ['stdout.txt', 'stderr.txt']}}
(output / 'receipt.json').write_text(json.dumps(receipt, indent=2), encoding='utf-8')
print(json.dumps(receipt))
sys.exit(result.returncode)
