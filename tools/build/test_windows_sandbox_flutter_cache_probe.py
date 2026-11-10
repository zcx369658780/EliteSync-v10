"""Focused temporary fixtures/mock subprocess tests; no installed SDK or VM."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_flutter_cache_probe as probe

REAL_HELPERS = probe.helpers


class FlutterCacheProbeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory()
        self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name)
        self.flutter = self.parent / 'flutter-source'
        for name in probe.CONTROLS:
            path = self.flutter / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'fixture ' + name.encode())
        (self.flutter / 'bin/cache/flutter.version.json').write_text('{"frameworkVersion":"3.41.7"}')
        (self.flutter / 'bin/cache/dart-sdk/version').write_text('3.11.3')
        self.sdk = self.flutter / 'bin/cache/dart-sdk'
        (self.sdk / 'bin').mkdir()
        (self.sdk / 'bin/dart.exe').write_bytes(b'fixture-nonexecutable-dart')
        self.source, self.launcher = self.parent / 'native.cs', self.parent / 'launch.ps1'
        self.source.write_text('fixture source'); self.launcher.write_text('fixture launcher')
        self.root = self.parent / 'case'
        for name, value in [('PARENT', self.parent), ('FLUTTER', self.flutter), ('SDK', self.sdk),
                            ('SOURCE', self.source), ('LAUNCHER', self.launcher)]:
            mock = patch.object(probe, name, value); mock.start(); self.addCleanup(mock.stop)
        mock = patch.object(probe, 'helpers', return_value=[self.source, self.launcher])
        mock.start(); self.addCleanup(mock.stop)
        mock = patch.object(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        mock.start(); self.addCleanup(mock.stop)
        mock = patch.object(probe.subprocess, 'run', side_effect=self.process)
        self.run_mock = mock.start(); self.addCleanup(mock.stop)

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fixture-native')
        stdout = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, stdout, b'')

    def receipt(self, m):
        return {'schema': 1, 'kind': m['kind'], 'mode': m['mode'], 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'proof': {'root_exit': 2, 'stop_reason': None, 'job_final_empty': True,
                          'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 1},
                'cache_state': {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': '3.41.7'}}

    def prepare(self):
        return probe.prepare(self.root)

    def test_exact_command_environment_and_complete_helper_pins(self):
        m = probe.contract()
        expected = (r'C:\Inputs\DartSdk\bin\dart.exe --packages=C:\BuildWork\Flutter\packages\flutter_tools\.dart_tool\package_config.json '
                    r'C:\BuildWork\Flutter\bin\cache\flutter_tools.snapshot --suppress-analytics --no-version-check --machine assemble')
        self.assertEqual(m['command_line'], expected)
        self.assertEqual(m['environment'], {**probe.dart.environment(), 'FLUTTER_ROOT': str(probe.WORK)})
        self.assertNotIn('FLUTTER_ALREADY_LOCKED', m['environment'])
        self.assertIs(m['producer_entry_allowed'], False)
        helpers = {p.name for p in REAL_HELPERS()}
        for name in ['windows_sandbox_dart_probe.py', 'current_product_apk_inventory.py', 'windows_sandbox_runtime_probe.py']:
            self.assertIn(name, helpers)

    def test_only_ten_private_controls_preserve_source_hash_and_mtime(self):
        (self.flutter / '.git').mkdir()
        (self.flutter / 'bin/cache/lockfile').write_bytes(b'must not copy')
        m = self.prepare()
        fixture = {path.relative_to(self.root / 'fixture').as_posix() for path, _ in probe.dart.strict_tree_files(self.root / 'fixture')}
        self.assertEqual(fixture, set(probe.CONTROLS))
        destinations = [row['destination'] for row in m['inputs'] if 'destination' in row]
        self.assertEqual(set(destinations), {str(probe.WORK / name) for name in probe.CONTROLS})
        for pin in m['source_pins']:
            target = self.root / 'fixture' / pin['role']
            self.assertEqual(target.lstat().st_mtime_ns, pin['mtime_ns'])
            self.assertEqual(probe.base.sha(target), pin['sha256'])
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'flutter-cache.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Inputs\DartSdk': 'true', r'C:\Probe': 'true', r'C:\Inputs\FlutterControls': 'true', r'C:\ProbeOutput': 'false'})
        self.assertEqual(probe.frozen(self.root)[1], m)

    def test_source_and_fixture_drift_rejected(self):
        self.prepare()
        original = self.flutter / 'LICENSE'
        original.write_bytes(b'changed source')
        with self.assertRaises(ValueError):
            probe.frozen(self.root)
        (self.root / 'fixture/bin/cache/lockfile').write_bytes(b'forbidden extra')
        with self.assertRaises(ValueError):
            probe.inputs(self.root)

    def test_fixed_version_and_command_guard_rejected(self):
        (self.flutter / 'bin/cache/flutter.version.json').write_text('{"frameworkVersion":"wrong"}')
        with self.assertRaises(ValueError):
            self.prepare()
        with self.assertRaises(ValueError):
            probe.prepare(self.root)
        with self.assertRaises(ValueError):
            probe.owned(self.parent / 'nested/case', False)

    def test_aggregate_caps_reject_before_hash(self):
        self.prepare()
        for name, cap in [('FILE_LIMIT', 1), ('BYTE_LIMIT', 1)]:
            with patch.object(probe, name, cap), patch.object(probe.inventory.os, 'open') as opened:
                with self.assertRaises(ValueError):
                    probe.inputs(self.root)
                opened.assert_not_called()

    def test_failed_launch_consumes_claim_and_cannot_retry(self):
        self.prepare()
        self.run_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.CompletedProcess([], 1, b'failure', b'error')]
        with self.assertRaises(ValueError):
            probe.launch(self.root)
        self.assertTrue((self.root / 'launch.claim.json').exists())
        with self.assertRaises(ValueError):
            probe.launch(self.root)

    def test_timeout_keeps_claim_and_partial_output(self):
        self.prepare()
        self.run_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired):
            probe.launch(self.root)
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        self.assertTrue((self.root / 'launch.claim.json').exists())

    def test_receipt_proof_cache_state_and_bool_forgeries_rejected(self):
        m = self.prepare(); receipt = self.receipt(m)
        probe.validate_result(receipt, m)
        for section, key, value in [(None, 'kind', 'native-tool-probe'), (None, 'native_tool_root_attempts', True),
                                    (None, 'gradle_root_attempts', 1), ('proof', 'root_exit', 0), ('proof', 'bound_members', 2),
                                    ('proof', 'watchdog_stop', 1), ('cache_state', 'lock_exists', False),
                                    ('cache_state', 'lock_bytes', False), ('cache_state', 'lock_reparse', True), ('cache_state', 'legacy_version', 'wrong')]:
            bad = copy.deepcopy(receipt)
            (bad if section is None else bad[section])[key] = value
            with self.subTest(section=section, key=key), self.assertRaises(ValueError):
                probe.validate_result(bad, m)

    def test_collect_requires_exact_error_and_exclusive_result(self):
        m = self.prepare(); probe.launch(self.root)
        (self.root / 'output/result.json').write_text(json.dumps(self.receipt(m)))
        (self.root / 'output/tool.stdout').write_text('')
        (self.root / 'output/tool.stderr').write_text('wrong error')
        with self.assertRaises(ValueError):
            probe.collect(self.root)
        (self.root / 'output/tool.stderr').write_text(probe.ERROR_TEXT)
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'FLUTTER_PRIVATE_CACHE_NEGATIVE_PATH_SUPPORTED')
        self.assertEqual(result['BAT'], 'NOT_PROVEN')
        self.assertIs(result['producer_entry_allowed'], False)
        with self.assertRaises(FileExistsError):
            probe.collect(self.root)

    def test_manifest_chain_and_cli_additions_rejected(self):
        m = self.prepare()
        m['environment']['FLUTTER_ALREADY_LOCKED'] = 'true'
        for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
            path.write_text(json.dumps(m))
        with self.assertRaises(ValueError):
            probe.frozen(self.root)
        with self.assertRaises(SystemExit):
            probe.main(['prepare', '--root', str(self.root), '--mode', 'gradle'])


if __name__ == '__main__':
    unittest.main()
