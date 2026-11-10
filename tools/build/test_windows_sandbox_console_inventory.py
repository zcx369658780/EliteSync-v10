"""Temporary probe fixtures/mock subprocesses only; no SDK, VM or OS image reads."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_console_inventory as probe


class ConsoleInventoryTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name); self.root = self.parent / 'case01'
        self.source = self.parent / 'fixture.cs'; self.source.write_text('fixture-only source')
        self.launcher = self.parent / 'launch.ps1'; self.launcher.write_text('fixture-only launcher')
        for name, value in [('PARENT', self.parent), ('SOURCE', self.source), ('LAUNCHER', self.launcher)]:
            mocked = patch.object(probe, name, value); mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe, 'helpers', return_value=[self.source, self.launcher])
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.subprocess, 'run', side_effect=self.process)
        self.process_mock = mocked.start(); self.addCleanup(mocked.stop)

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fixture-executable-never-run')
        stdout = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, stdout, b'')

    def prepare(self):
        return probe.prepare(self.root)

    def metadata(self):
        signature = {'status': 'Valid', 'subject': 'CN=Microsoft Windows, O=Microsoft Corporation',
                     'signature_type': 'Catalog', 'is_os_binary': True}
        return {'schema': 1, 'path': r'C:\Windows\System32\conhost.exe', 'bytes': 1234, 'sha256': 'a' * 64,
                'file_id': {'volume': 123, 'index': '123456789012345678'}, 'hard_links': 2, 'file_version': 'fixture-version',
                'identity_stable': True, 'signature': signature,
                'automation_assembly': {'full_name': probe.ASSEMBLY, 'under_windows': True, 'signature': copy.deepcopy(signature)}}

    def receipt(self, m):
        return {'schema': 1, 'kind': 'console-image-inventory-probe', 'mode': 'console-image-inventory', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'proof': {'root_exit': 0, 'stop_reason': None, 'bound_members': 1, 'watchdog_stop': 0,
                          'job_final_empty': True, 'all_bound_handles_exited': True}}

    def launched(self):
        m = self.prepare(); probe.launch(self.root)
        receipt = self.receipt(m)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        return m, receipt

    def test_fixed_os_only_command_and_two_mappings(self):
        m = self.prepare()
        self.assertEqual(m['arguments'], [r'C:\Probe\ConsoleImageInventory.exe'])
        self.assertEqual(m['command_line'], probe.EXE)
        self.assertEqual(m['environment']['PATH'], r'C:\Windows\System32')
        self.assertNotIn('DART_SUPPRESS_ANALYTICS', m['environment'])
        self.assertEqual([row['path'] for row in m['images']], [probe.EXE])
        self.assertFalse(any('DartSdk' in row['path'] for row in m['inputs']))
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'console-inventory.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false'})
        self.assertEqual(probe.frozen(self.root)[1], m)
        with self.assertRaises(ValueError): probe.owned(self.parent / 'case02', False)

    def test_exact_native_base_and_five_replacements(self):
        raw, generated, patch_data, report = probe.native_source()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), probe.stdio.BASE_SHA)
        self.assertEqual(report['replacement_counts'], [1] * 5)
        self.assertIn(probe.EXE.encode(), generated)
        self.assertIn(b'UNKNOWN_PROCESS_IMAGE', generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])
        changed = self.parent / 'changed-base.cs'; changed.write_bytes(raw + b'changed')
        with patch.object(probe.dart, 'SOURCE', changed):
            with self.assertRaises(ValueError): probe.native_source()

    def test_probe_caps_reject_before_hash_and_no_recursive_sdk_scan(self):
        self.prepare()
        for name in ['FILE_LIMIT', 'BYTE_LIMIT']:
            with patch.object(probe, name, 1), patch.object(probe.inventory.os, 'open') as opened:
                with self.assertRaises(ValueError): probe.inputs(self.root)
                opened.assert_not_called()
        original = probe.dart.strict_tree_files
        with patch.object(probe.dart, 'strict_tree_files', wraps=original) as walker:
            probe.inputs(self.root)
            walker.assert_called_once_with(self.root / 'probe')

    def test_fixture_or_manifest_drift_rejected(self):
        m = self.prepare()
        (self.root / 'probe/ConsoleImageInventory.exe').write_bytes(b'changed')
        with self.assertRaises(ValueError): probe.frozen(self.root)
        m['environment']['PATH'] += ';C:\\Injected'
        for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
            path.write_text(json.dumps(m))
        with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_signature_and_assembly_strict_metadata(self):
        good = self.metadata()
        self.assertEqual(probe.validate_inventory(good), good)
        for section, key, value in [(None, 'schema', True), (None, 'bytes', True), (None, 'hard_links', False),
                                    (None, 'path', r'C:\Elsewhere\conhost.exe'), (None, 'identity_stable', 1), (None, 'sha256', 'not-hash'),
                                    ('file_id', 'volume', True), ('file_id', 'index', 1), ('file_id', 'index', 'not-numeric'),
                                    ('file_id', 'index', str(2**64)), (None, 'bytes', 16 * 1024**2 + 1), ('signature', 'status', 'NotSigned'),
                                    ('signature', 'subject', 'CN=Microsoft Windows Fake'), ('signature', 'signature_type', 'Unknown'),
                                    ('signature', 'is_os_binary', 1), ('automation_assembly', 'under_windows', 1),
                                    ('automation_assembly', 'full_name', 'WrongAssembly')]:
            bad = copy.deepcopy(good); (bad if section is None else bad[section])[key] = value
            with self.subTest(section=section, key=key), self.assertRaises(ValueError): probe.validate_inventory(bad)
        bad = copy.deepcopy(good); bad['automation_assembly']['signature']['status'] = 'UnknownError'
        with self.assertRaises(ValueError): probe.validate_inventory(bad)

    def test_strict_receipt_bool_and_unknown_identity_rejected(self):
        m = self.prepare(); good = self.receipt(m)
        for key, value in [('schema', True), ('native_tool_root_attempts', True), ('apk_builds', False), ('nonce', 'forged')]:
            bad = copy.deepcopy(good); bad[key] = value
            with self.assertRaises(ValueError): probe.validate_receipt(bad, m)
        bad = copy.deepcopy(good); bad['proof']['root_exit'] = False
        with self.assertRaises(ValueError): probe.validate_receipt(bad, m)

    def test_successful_inventory_never_grants_console_or_producer(self):
        self.launched()
        (self.root / 'output/console-image.json').write_text(json.dumps(self.metadata()))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'CONSOLE_OS_IMAGE_INVENTORY_SUPPORTED')
        self.assertIs(result['console_execution_allowed'], False)
        self.assertIs(result['producer_entry_allowed'], False)
        self.assertEqual(result['VM'], 'NOT_PROVEN')
        self.assertEqual(result['inventory']['hard_links'], 2)
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_stop_is_sealed_rejected_without_console_whitelist(self):
        _, receipt = self.launched()
        receipt['proof'].update(root_exit=None, stop_reason='UNKNOWN_PROCESS_IMAGE', bound_members=2)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)
        self.assertIs(result['console_execution_allowed'], False)

    def test_fixture_failure_or_invalid_inventory_never_passes(self):
        _, receipt = self.launched()
        (self.root / 'output/console-image.json').write_text('{"schema":true}')
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)

    def test_launcher_timeout_consumes_claim_and_preserves_output(self):
        self.prepare()
        self.process_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        self.assertTrue((self.root / 'launch.claim.json').exists())
        with self.assertRaises(ValueError): probe.launch(self.root)

    def test_bad_frozen_nonce_rejected_before_claim(self):
        m = self.prepare(); m['nonce'] = 'bad nonce'
        for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
            path.write_text(json.dumps(m))
        with self.assertRaises(ValueError): probe.frozen(self.root)
        self.assertFalse((self.root / 'launch.claim.json').exists())

    def test_multibyte_inventory_over_16k_never_accepted(self):
        self.launched(); value = self.metadata(); value['file_version'] = '\u4e2d' * 6000
        path = self.root / 'output/console-image.json'
        path.write_text(json.dumps(value, ensure_ascii=False), encoding='utf-8')
        self.assertGreater(path.stat().st_size, 16384)
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertFalse(result['console_execution_allowed'])


if __name__ == '__main__': unittest.main()
