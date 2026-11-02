"""Pure temporary controls and mocked processes; no SDK/VM/device execution."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_flutter_console_probe as probe


class FlutterConsoleProbeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name); self.root = self.parent / 'case01'
        self.flutter = self.parent / 'flutter-source'
        for name in probe.cache.CONTROLS:
            path = self.flutter / name; path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'fixture ' + name.encode())
        (self.flutter / 'bin/cache/flutter.version.json').write_text('{"frameworkVersion":"3.41.7"}')
        (self.flutter / 'bin/cache/dart-sdk/version').write_text('3.11.5')
        self.sdk = self.flutter / 'bin/cache/dart-sdk'; (self.sdk / 'bin').mkdir()
        for name in ['dart.exe', 'dartvm.exe']:
            (self.sdk / 'bin' / name).write_bytes(b'fixture nonexecutable ' + name.encode())
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('# fixture-only')
        self.helper = self.parent / 'helper.py'; self.helper.write_text('# fixture-only')
        self.mock(probe, 'PARENT', self.parent)
        self.mock(probe, 'LAUNCHER', self.launcher)
        self.mock(probe.cache, 'SDK', self.sdk)
        self.mock(probe.cache, 'FLUTTER', self.flutter)
        self.mock(probe, 'baseline', return_value=[{'host': 'synthetic prior VM', 'sha256': 'c' * 64}])
        self.mock(probe, 'helpers', return_value=[self.helper, self.launcher])
        self.mock(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        self.run_mock = self.mock(probe.subprocess, 'run', side_effect=self.process)

    def mock(self, target, name, *args, **kwargs):
        mocked = patch.object(target, name, *args, **kwargs)
        value = mocked.start(); self.addCleanup(mocked.stop)
        return value

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fixture supervisor never executed')
        out = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, out, b'')

    def receipt(self, m):
        return {'schema': 1, 'kind': probe.KIND, 'mode': probe.MODE, 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'kernel_file_version': probe.vm.KERNEL_VERSION, 'clr_version': probe.vm.CLR_VERSION,
                'proof': {'root_pid': 1001, 'root_exit': 2, 'stop_reason': None, 'job_final_empty': True,
                          'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 2},
                'cache_state': {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': m['legacy_version']}}

    def launched(self):
        m = probe.prepare(self.root); probe.launch(self.root); receipt = self.receipt(m)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        samples = [{'operation': 'process_image_check', 'observed_image': probe.EXE, 'pid': 1001},
                   {'operation': 'process_image_check', 'observed_image': probe.console.OS_IMAGE, 'pid': 1002}]
        (self.root / 'output/samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
        (self.root / 'output/tool.stdout').write_text('')
        (self.root / 'output/tool.stderr').write_text(probe.cache.ERROR_TEXT)
        return m, receipt, samples

    def rewrite_manifest(self, m):
        for name in ['manifest.json', 'probe/manifest.json']:
            (self.root / name).write_text(json.dumps(m))

    def test_max1_exact_direct_vm_command_and_normal_private_lock_environment(self):
        m = probe.contract()
        self.assertEqual(m['max_launches'], 1)
        self.assertEqual(m['arguments'][:3], probe.vm.stdio.command()[:3])
        self.assertEqual(m['arguments'][3:], probe.cache.contract()['arguments'][1:])
        self.assertEqual(m['environment']['FLUTTER_ROOT'], str(probe.cache.WORK))
        self.assertNotIn('FLUTTER_ALREADY_LOCKED', m['environment'])
        self.assertFalse(m['producer_entry_allowed'])

    def test_only_fixed_readonly_controls_are_captured_with_provenance(self):
        (self.flutter / 'bin/cache/lockfile').write_bytes(b'do not capture old lock')
        before = probe.cache.sources(); m = probe.prepare(self.root)
        self.assertEqual(probe.cache.sources(), before)
        self.assertEqual(m['source_pins'], before)
        self.assertEqual(m['legacy_version'], '3.41.7')
        fixture = {relative.as_posix() for _, relative in probe.dart.strict_tree_files(self.root / 'fixture')}
        self.assertEqual(fixture, set(probe.cache.CONTROLS))
        for pin in before:
            target = self.root / 'fixture' / pin['role']
            self.assertEqual(target.lstat().st_mtime_ns, pin['mtime_ns'])
            self.assertEqual(probe.base.sha(target), pin['sha256'])
        destinations = {row['destination'] for row in m['inputs'] if 'destination' in row}
        self.assertEqual(destinations, {str(probe.cache.WORK / name) for name in probe.cache.CONTROLS})
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'flutter-vm-console.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Inputs\DartSdk': 'true', r'C:\Probe': 'true', r'C:\Inputs\FlutterControls': 'true', r'C:\ProbeOutput': 'false'})
        self.assertEqual(probe.frozen(self.root)[1], m)

    def test_complete_inputs_include_unique_guest_pin_without_host_byte_claim(self):
        m = probe.prepare(self.root)
        self.assertEqual(len(m['inputs']), len(m['bindings']) + 1)
        self.assertEqual([row for row in m['inputs'] if row.get('kind')], [probe.console.guest_pin()])
        self.assertEqual(m['source_bytes'], sum(row['bytes'] for row in m['bindings']))
        self.assertFalse(any(row['host'] == probe.console.OS_IMAGE for row in m['bindings']))
        self.assertEqual(m['images'][0]['path'], probe.EXE)
        self.assertEqual(m['images'][1], {'path': probe.console.OS_IMAGE, 'sha256': probe.console.OS_SHA})

    def test_extra_images_guest_pin_and_source_bytes_tampering_rejected(self):
        m = probe.prepare(self.root)
        for mutate in [lambda x: x['images'].append({'path': '*', 'sha256': '0' * 64}),
                       lambda x: x['inputs'][-1].update(sha256='0' * 64), lambda x: x.update(source_bytes=True)]:
            changed = copy.deepcopy(m); mutate(changed); self.rewrite_manifest(changed)
            with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_original_control_source_and_private_capture_drift_rejected(self):
        probe.prepare(self.root)
        source = self.flutter / 'LICENSE'; original = source.read_bytes()
        source.write_bytes(b'changed source')
        with self.assertRaises(ValueError): probe.frozen(self.root)
        source.write_bytes(original)
        (self.root / 'fixture/bin/cache/lockfile').write_bytes(b'extra forbidden lock')
        with self.assertRaises(ValueError): probe.inputs(self.root)

    def test_native_eight_exact_substitutions_keep_lock_os_and_environment_guards(self):
        raw, generated, patch_data, report = probe.native_source()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), probe.SOURCE_SHA)
        self.assertEqual(report['replacement_counts'], [1] * 8)
        for required in [b'QualifiedInputHash(row)', b'BoundedOSImageHash(actual)', b'UNKNOWN_PROCESS_IMAGE',
                         b'NORMAL_CACHE_LOCK_REQUIRED', b'PRIVATE_FLUTTER_ROOT_REQUIRED', b'QUALIFIED_ENVIRONMENT_DRIFT',
                         b'FLUTTER_ALREADY_LOCKED', b'StringComparison.OrdinalIgnoreCase', b'RequireFreshCache(m)',
                         probe.vm.KERNEL_VERSION.encode(), probe.vm.CLR_VERSION.encode(), probe.contract()['command_line'].encode()]:
            self.assertIn(required, generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])

    def test_receipt_identity_and_numeric_boolean_forgeries_rejected(self):
        m = probe.prepare(self.root); receipt = self.receipt(m)
        probe.validate_receipt(receipt, m)
        for key, value in [('kind', 'flutter-cache-negative-probe'), ('mode', 'stdio-stage'),
                           ('native_tool_root_attempts', True), ('input_files', True), ('G2', 0), ('gradle_root_attempts', False)]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                probe.validate_receipt({**receipt, key: value}, m)
        self.rewrite_manifest({**m, 'nonce': True})
        with self.assertRaises(ValueError): probe.frozen(self.root)
        self.assertFalse((self.root / 'launch.claim.json').exists())

    def test_exit2_expected_error_cache_tuple_and_dual_images_support_only_negative_path(self):
        self.launched(); result = probe.collect(self.root)
        self.assertEqual(result['status'], probe.SUCCESS)
        self.assertTrue(result['expected_error_observed'])
        self.assertEqual(result['BAT'], 'NOT_PROVEN')
        self.assertEqual(result['cache_lock_held'], 'NOT_DIRECTLY_OBSERVED')
        for key in ['producer_entry_allowed', 'gradle_allowed', 'apk_allowed', 'device_allowed', 'media_allowed', 'G2']:
            self.assertIs(result[key], False)
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_root_zero_wrong_error_or_missing_image_cannot_pass(self):
        m, receipt, samples = self.launched()
        for exit_code in [0, True, 1, None]:
            proof = {**receipt['proof'], 'root_exit': exit_code}
            self.assertEqual(probe.classify(receipt, proof, m, samples, probe.cache.ERROR_TEXT), 'REJECTED')
        self.assertEqual(probe.classify(receipt, receipt['proof'], m, samples, 'different error'), 'REJECTED')
        for subset in [samples[:1], samples[1:], []]:
            self.assertEqual(probe.classify(receipt, receipt['proof'], m, subset, probe.cache.ERROR_TEXT), 'REJECTED')

    def test_stop_unknown_image_watchdog_cleanup_or_environment_drift_rejected(self):
        m, receipt, samples = self.launched()
        for key, value in [('stop_reason', 'UNKNOWN_PROCESS_IMAGE'), ('watchdog_stop', 1),
                           ('job_final_empty', False), ('all_bound_handles_exited', False), ('bound_members', 1)]:
            with self.subTest(key=key):
                self.assertEqual(probe.classify(receipt, {**receipt['proof'], key: value}, m, samples, probe.cache.ERROR_TEXT), 'REJECTED')
        unknown = samples + [{'operation': 'process_image_check', 'observed_image': 'unknown.exe', 'pid': 1003}]
        self.assertEqual(probe.classify(receipt, receipt['proof'], m, unknown, probe.cache.ERROR_TEXT), 'REJECTED')
        for key in ['kernel_file_version', 'clr_version']:
            self.assertEqual(probe.classify({**receipt, key: 'drift'}, receipt['proof'], m, samples, probe.cache.ERROR_TEXT), 'REJECTED')

    def test_bad_cache_tuple_or_boolean_byte_count_cannot_pass(self):
        m, receipt, samples = self.launched()
        for key, value in [('lock_exists', False), ('lock_bytes', False), ('lock_bytes', 1),
                           ('lock_reparse', True), ('legacy_version', 'wrong')]:
            bad = copy.deepcopy(receipt); bad['cache_state'][key] = value
            with self.subTest(key=key, value=value):
                self.assertEqual(probe.classify(bad, bad['proof'], m, samples, probe.cache.ERROR_TEXT), 'REJECTED')

    def test_bootstrap_failure_after_full_inputs_is_sealed_rejected(self):
        m, receipt, _ = self.launched()
        receipt.update(proof=None, native_tool_root_attempts=0, failure='QUALIFIED_ENVIRONMENT_DRIFT', input_files=len(m['inputs']))
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIsNone(result['proof'])
        self.assertIs(result['tool_qualified'], False)

    def test_timeout_permanently_consumes_claim_and_refuses_retry(self):
        probe.prepare(self.root)
        self.run_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        claim = json.loads((self.root / 'launch.claim.json').read_text())
        self.assertEqual(claim['max_launches'], 1); self.assertIs(claim['refundable'], False)
        with self.assertRaises(ValueError): probe.launch(self.root)

    def test_environment_addition_and_existing_case_reuse_are_rejected(self):
        m = probe.prepare(self.root)
        m['environment']['FLUTTER_ALREADY_LOCKED'] = 'true'; self.rewrite_manifest(m)
        with self.assertRaises(ValueError): probe.frozen(self.root)
        with self.assertRaises(ValueError): probe.prepare(self.root)
        with self.assertRaises(ValueError): probe.owned(self.parent / 'case02', False)


if __name__ == '__main__': unittest.main()
