"""Temporary files/mock subprocesses only; no actual SDK, VM, or device run."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_where_validation as probe


class WhereValidationTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name)
        parents = {phase: self.parent / phase for phase in probe.PARENTS}
        for path in parents.values(): path.mkdir()
        self.mock(probe, 'PARENTS', parents)
        self.flutter = self.parent / 'flutter-source'
        for name in probe.cache.CONTROLS:
            path = self.flutter / name; path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'fixture ' + name.encode())
        (self.flutter / 'bin/cache/flutter.version.json').write_text('{"frameworkVersion":"3.41.7"}')
        (self.flutter / 'bin/cache/dart-sdk/version').write_text('3.11.5')
        self.sdk = self.flutter / 'bin/cache/dart-sdk'; (self.sdk / 'bin').mkdir()
        for name in ['dart.exe', 'dartvm.exe']:
            (self.sdk / 'bin' / name).write_bytes(b'fixture never executed ' + name.encode())
        self.helper = self.parent / 'helper.py'; self.helper.write_text('# fixture-only')
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('# fixture-only')
        self.mock(probe.cache, 'SDK', self.sdk)
        self.mock(probe.cache, 'FLUTTER', self.flutter)
        self.mock(probe.dart, 'LAUNCHER', self.launcher)
        self.mock(probe, 'helpers', return_value=[self.helper, self.launcher])
        self.mock(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        self.real_prerequisites = probe.prerequisites
        self.prerequisites_mock = self.mock(probe, 'prerequisites', side_effect=lambda p: {'pins': [], 'where': self.metadata()})
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

    def metadata(self):
        signature = {'status': 'Valid', 'subject': 'CN=Microsoft Windows, O=Microsoft Corporation', 'signature_type': 'Catalog', 'is_os_binary': True}
        return {'schema': 1, 'path': probe.WHERE, 'bytes': 65536, 'sha256': 'b' * 64,
                'file_id': {'volume': 1, 'index': '12345'}, 'hard_links': 1, 'file_version': 'fixture-version',
                'identity_stable': True, 'signature': signature,
                'automation_assembly': {'full_name': probe.console.prior.ASSEMBLY, 'under_windows': True, 'signature': copy.deepcopy(signature)}}

    def receipt(self, p, m):
        members = {'inventory': 1, 'qualification': 1, 'cache': 4}[p.phase]
        return {'schema': 1, 'kind': p.kind, 'mode': p.mode, 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'kernel_file_version': probe.vm.KERNEL_VERSION, 'clr_version': probe.vm.CLR_VERSION,
                'proof': {'root_pid': 1001, 'root_exit': {'inventory': 0, 'qualification': 1, 'cache': 2}[p.phase],
                          'stop_reason': None, 'job_final_empty': True, 'all_bound_handles_exited': True,
                          'watchdog_stop': 0, 'bound_members': members},
                'cache_state': {'lock_exists': True, 'lock_bytes': 0, 'lock_reparse': False, 'legacy_version': m['legacy_version']}}

    def prepare(self, phase):
        p = probe.Profile(phase)
        return p, probe.prepare(p, p.root)

    def launched(self, phase):
        p, m = self.prepare(phase); probe.launch(p, p.root)
        receipt = self.receipt(p, m)
        samples = [{'operation': 'process_image_check', 'observed_image': m['executable'], 'pid': 1001}]
        if phase == 'cache':
            samples += [{'operation': 'process_image_check', 'observed_image': probe.console.OS_IMAGE, 'pid': 1002},
                        {'operation': 'process_image_check', 'observed_image': probe.WHERE, 'pid': 1003},
                        {'operation': 'process_image_check', 'observed_image': probe.WHERE, 'pid': 1004}]
        (p.root / 'output/result.json').write_text(json.dumps(receipt))
        (p.root / 'output/samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
        (p.root / 'output/tool.stdout').write_bytes(b'')
        (p.root / 'output/tool.stderr').write_text(probe.cache.ERROR_TEXT if phase == 'cache' else '')
        if phase == 'inventory': (p.root / 'output/console-image.json').write_text(json.dumps(self.metadata()))
        return p, m, receipt, samples

    def rewrite_manifest(self, p, m):
        for name in ['manifest.json', 'probe/manifest.json']:
            (p.root / name).write_text(json.dumps(m))

    def classify(self, p, m, r, samples, text=None):
        if text is None: text = probe.cache.ERROR_TEXT if p.phase == 'cache' else ''
        return probe.classify(p, r, m, samples, text, p.root)[0]

    def test_three_contracts_are_exact_independent_max1_and_private_environment(self):
        expected = {'inventory': [probe.FIXTURE], 'qualification': [probe.WHERE, '/Q', '__ELITESYNC_V1015_NEGATIVE_LOOKUP__'],
                    'cache': probe.flutter.contract()['arguments']}
        for phase in probe.PARENTS:
            p = probe.Profile(phase); m = probe.contract(p)
            self.assertEqual(m['arguments'], expected[phase])
            self.assertEqual(m['max_launches'], 1)
            self.assertEqual(m['environment']['PATHEXT'], '.EXE')
            self.assertNotIn('FLUTTER_ALREADY_LOCKED', m['environment'])
            self.assertIs(m['producer_entry_allowed'], False)
            self.assertEqual(m['where_execution_allowed'], phase != 'inventory')
        with self.assertRaises(ValueError): probe.Profile('other')

    def test_front_phases_map_only_probe_output_no_sdk_or_controls(self):
        for phase in ['inventory', 'qualification']:
            p, m = self.prepare(phase)
            mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((p.root / 'probe.wsb').read_text()).findall('MappedFolders/MappedFolder')}
            self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false'})
            self.assertEqual(m['source_pins'], []); self.assertIsNone(m['legacy_version'])
            self.assertFalse(any(str(self.sdk) in row['host'] for row in m['bindings']))
            self.assertEqual(probe.frozen(p, p.root)[1], m)

    def test_cache_readonly_control_capture_and_sdk_mapping(self):
        before = probe.cache.sources(); p, m = self.prepare('cache')
        self.assertEqual(probe.cache.sources(), before)
        self.assertEqual(m['source_pins'], before)
        self.assertEqual(m['legacy_version'], '3.41.7')
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((p.root / 'probe.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false', r'C:\Inputs\DartSdk': 'true', r'C:\Inputs\FlutterControls': 'true'})
        self.assertEqual(probe.frozen(p, p.root)[1], m)

    def test_inventory_fixture_main_has_no_synthetic_console_entry(self):
        generated = probe.fixture_source()
        self.assertIn(probe.WHERE.encode(), generated)
        self.assertIn(b'if(args.Length!=0)return 22;', generated)
        main = generated.split(b'static int Main(string[] args)', 1)[1]
        self.assertNotIn(b'--synthetic-console', main)
        self.assertNotIn(b'if(synthetic)', main)
        self.assertNotIn(b'bool synthetic=', main)

    def test_native_fixed_replacements_preserve_os_environment_and_lock_guards(self):
        evidence = {'pins': [], 'where': self.metadata()}
        for phase, count in [('inventory', 6), ('qualification', 9), ('cache', 9)]:
            p = probe.Profile(phase); raw, generated, patch_data, report = probe.native_source(p, evidence)
            self.assertEqual(report['replacement_counts'], [1] * count)
            self.assertEqual(hashlib.sha256(raw).hexdigest(), report['base_sha256'])
            self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])
            self.assertIn(b'UNKNOWN_PROCESS_IMAGE', generated)
            self.assertIn(b'QUALIFIED_ENVIRONMENT_DRIFT', generated)
            self.assertIn(probe.vm.KERNEL_VERSION.encode(), generated)
            if phase != 'inventory':
                self.assertIn(b'QualifiedInputHash(row)', generated)
                self.assertIn(b'BoundedOSImageHash(actual)', generated)
                self.assertIn(b'size=65536', generated); self.assertIn(b'size=1003520', generated)
            if phase == 'cache':
                self.assertIn(b'RequireFreshCache(m)', generated)
                self.assertIn(b'NORMAL_CACHE_LOCK_REQUIRED', generated)

    def test_guest_only_os_pins_and_host_bytes_are_separate(self):
        for phase, count in [('inventory', 0), ('qualification', 2), ('cache', 2)]:
            p, m = self.prepare(phase)
            self.assertEqual(len(m['inputs']), len(m['bindings']) + count)
            self.assertEqual(len([row for row in m['inputs'] if row.get('kind')]), count)
            self.assertEqual(m['source_bytes'], sum(row['bytes'] for row in m['bindings']))
            self.assertFalse(any(row['host'] in [probe.WHERE, probe.console.OS_IMAGE] for row in m['bindings']))

    def test_typed_receipt_identity_and_nonce_rejected(self):
        p, m = self.prepare('qualification'); receipt = self.receipt(p, m)
        for key, value in [('kind', 'other'), ('mode', 'other'), ('input_files', True),
                           ('native_tool_root_attempts', True), ('G2', 0)]:
            with self.subTest(key=key), self.assertRaises(ValueError): probe.validate_receipt(p, {**receipt, key: value}, m)
        self.rewrite_manifest(p, {**m, 'nonce': True})
        with self.assertRaises(ValueError): probe.frozen(p, p.root)

    def test_inventory_root0_single_member_valid_signed_metadata_only(self):
        p, _, _, _ = self.launched('inventory'); result = probe.collect(p, p.root)
        self.assertEqual(result['status'], probe.STATUSES['inventory'])
        self.assertEqual(result['inventory'], self.metadata())
        self.assertFalse(result['producer_entry_allowed']); self.assertFalse(result['G2'])
        with self.assertRaises(FileExistsError): probe.collect(p, p.root)

    def test_inventory_bad_signature_or_path_rejects(self):
        p, m, receipt, samples = self.launched('inventory')
        for mutate in [lambda x: x['signature'].update(status='NotSigned'), lambda x: x.update(path='different.exe'),
                       lambda x: x.update(identity_stable=False)]:
            metadata = self.metadata(); mutate(metadata)
            (p.root / 'output/console-image.json').write_text(json.dumps(metadata))
            self.assertEqual(self.classify(p, m, receipt, samples), 'REJECTED')

    def test_qualification_exit1_optional_console_and_empty_existing_outputs(self):
        p, m, receipt, samples = self.launched('qualification')
        self.assertEqual(self.classify(p, m, receipt, samples), probe.STATUSES['qualification'])
        with_console = samples + [{'operation': 'process_image_check', 'observed_image': probe.console.OS_IMAGE, 'pid': 1002}]
        receipt['proof']['bound_members'] = 2
        self.assertEqual(self.classify(p, m, receipt, with_console), probe.STATUSES['qualification'])
        self.assertEqual(self.classify(p, m, receipt, with_console, 'unexpected matching result'), 'REJECTED')
        duplicate_where = samples + [{**samples[0], 'pid': 1002}]
        self.assertEqual(self.classify(p, m, receipt, duplicate_where), 'REJECTED')
        (p.root / 'output/tool.stdout').write_bytes(b' \r\n')
        self.assertEqual(self.classify(p, m, receipt, with_console, ' \r\n'), 'REJECTED')

    def test_cache_supports_multiple_exact_where_members_and_normal_lock_negative_path(self):
        p, m, receipt, samples = self.launched('cache')
        self.assertEqual(self.classify(p, m, receipt, samples), probe.STATUSES['cache'])
        result = probe.collect(p, p.root)
        self.assertEqual(result['status'], probe.STATUSES['cache'])
        self.assertEqual(result['proof']['bound_members'], 4)
        self.assertIs(result['where_image_observed'], True)
        for key in ['producer_entry_allowed', 'gradle_allowed', 'apk_allowed', 'device_allowed', 'media_allowed', 'G2']:
            self.assertIs(result[key], False)

    def test_cache_without_sampled_where_can_support_but_does_not_claim_where_observed(self):
        p, m, receipt, samples = self.launched('cache')
        receipt['proof']['bound_members'] = 2
        samples = [row for row in samples if row['observed_image'] != probe.WHERE]
        (p.root / 'output/result.json').write_text(json.dumps(receipt))
        (p.root / 'output/samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
        result = probe.collect(p, p.root)
        self.assertEqual(result['status'], probe.STATUSES['cache'])
        self.assertIs(result['where_image_observed'], False)
        self.assertEqual(result['proof']['bound_members'], 2)

    def test_same_pid_conflicting_image_samples_are_rejected(self):
        p, m, receipt, samples = self.launched('cache')
        conflict = samples + [{'operation': 'process_image_check', 'observed_image': probe.console.OS_IMAGE, 'pid': 1003}]
        self.assertEqual(self.classify(p, m, receipt, conflict), 'REJECTED')

    def test_cache_bad_tuple_error_missing_console_or_wrong_exit_rejected(self):
        p, m, receipt, samples = self.launched('cache')
        for key, value in [('lock_exists', False), ('lock_bytes', False), ('lock_reparse', True), ('legacy_version', 'wrong')]:
            bad = copy.deepcopy(receipt); bad['cache_state'][key] = value
            self.assertEqual(self.classify(p, m, bad, samples), 'REJECTED')
        self.assertEqual(self.classify(p, m, receipt, samples, 'wrong error'), 'REJECTED')
        no_console = [row for row in samples if row['observed_image'] != probe.console.OS_IMAGE]
        bad = copy.deepcopy(receipt); bad['proof']['bound_members'] = 3
        self.assertEqual(self.classify(p, m, bad, no_console), 'REJECTED')
        for code in [0, 1, 255, None]:
            bad = copy.deepcopy(receipt); bad['proof']['root_exit'] = code
            self.assertEqual(self.classify(p, m, bad, samples), 'REJECTED')

    def test_member_mismatch_missing_root_unknown_image_and_stop_are_rejected(self):
        p, m, receipt, samples = self.launched('qualification')
        for key, value in [('bound_members', 2), ('stop_reason', 'UNKNOWN_PROCESS_IMAGE'), ('root_exit', 0),
                           ('watchdog_stop', 1), ('job_final_empty', False), ('all_bound_handles_exited', False)]:
            bad = copy.deepcopy(receipt); bad['proof'][key] = value
            self.assertEqual(self.classify(p, m, bad, samples), 'REJECTED')
        for changed in [[], [{**samples[0], 'pid': 1002}], [{**samples[0], 'observed_image': 'unknown.exe'}]]:
            self.assertEqual(self.classify(p, m, receipt, changed), 'REJECTED')
        for key in ['kernel_file_version', 'clr_version']:
            self.assertEqual(self.classify(p, m, {**receipt, key: 'drift'}, samples), 'REJECTED')

    def test_missing_stdout_or_stderr_prevents_success(self):
        for phase, name in [('inventory', 'tool.stdout'), ('qualification', 'tool.stderr'), ('cache', 'tool.stdout')]:
            p, m, receipt, samples = self.launched(phase)
            (p.root / 'output' / name).unlink()
            self.assertEqual(self.classify(p, m, receipt, samples), 'REJECTED')

    def test_full_input_bootstrap_failure_only_seals_rejected(self):
        p, m, receipt, _ = self.launched('cache')
        receipt.update(proof=None, native_tool_root_attempts=0, input_files=len(m['inputs']), failure='QUALIFIED_ENVIRONMENT_DRIFT')
        (p.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(p, p.root)
        self.assertEqual(result['status'], 'REJECTED'); self.assertFalse(result['tool_qualified'])
        with self.assertRaises(ValueError): probe.validate_receipt(p, {**receipt, 'input_files': True}, m)
        with self.assertRaises(ValueError): probe.validate_receipt(p, {**receipt, 'input_files': len(m['inputs']) - 1}, m)

    def test_manifest_extra_images_environment_and_prerequisite_drift_rejected(self):
        p, m = self.prepare('qualification')
        for mutate in [lambda x: x['images'].append({'path': '*', 'sha256': '0' * 64}),
                       lambda x: x['environment'].update(FLUTTER_ALREADY_LOCKED='true'),
                       lambda x: x['prerequisites'].update(pins=[{'host': 'different', 'sha256': '0' * 64}]),
                       lambda x: x['inputs'][-1].update(sha256='0' * 64), lambda x: x.update(source_bytes=True)]:
            bad = copy.deepcopy(m); mutate(bad); self.rewrite_manifest(p, bad)
            with self.assertRaises(ValueError): probe.frozen(p, p.root)

    def test_cache_original_control_source_drift_rejected(self):
        p, _ = self.prepare('cache'); (self.flutter / 'LICENSE').write_bytes(b'changed source')
        with self.assertRaises(ValueError): probe.frozen(p, p.root)

    def test_timeout_consumes_independent_claim_without_refund_or_retry(self):
        p, _ = self.prepare('inventory')
        self.run_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(p, p.root)
        self.assertEqual((p.root / 'launcher.stdout').read_bytes(), b'partial')
        claim = json.loads((p.root / 'launch.claim.json').read_text())
        self.assertEqual(claim['max_launches'], 1); self.assertIs(claim['refundable'], False)
        with self.assertRaises(ValueError): probe.launch(p, p.root)
        with self.assertRaises(ValueError): probe.prepare(p, p.root)

    def test_real_prerequisites_refuse_missing_predecessor(self):
        self.mock(probe.flutter, 'baseline', return_value=[])
        with self.assertRaises((OSError, ValueError)):
            self.real_prerequisites(probe.Profile('qualification'))

    def test_real_prerequisites_refuse_rejected_predecessor_result(self):
        p, m, _, _ = self.launched('inventory')
        result = probe.collect(p, p.root); result['status'] = 'REJECTED'; result['tool_qualified'] = False
        (p.root / 'verified-result.json').write_text(json.dumps(result))
        self.mock(probe.flutter, 'baseline', return_value=[])
        self.mock(probe, 'frozen', return_value=(p.root, m))
        with self.assertRaises(ValueError): self.real_prerequisites(probe.Profile('qualification'))


if __name__ == '__main__': unittest.main()
