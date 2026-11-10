"""Synthetic temporary records/mock processes only; no guest or SDK execution."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_console_qualification as probe


class ConsoleQualificationTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name); self.root = self.parent / 'case01'
        self.source = self.parent / 'fixture.cs'; self.source.write_text('fixture-only synthetic source')
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('fixture-only launcher')
        self.baseline = self.parent / 'baseline'; (self.baseline / 'output').mkdir(parents=True)
        documents = {'output/console-image.json': self.metadata(), 'verified-result.json': {
            'status': 'CONSOLE_OS_IMAGE_INVENTORY_SUPPORTED', 'console_execution_allowed': False, 'producer_entry_allowed': False, 'G2': False}}
        digests = {}
        for name, record in documents.items():
            path = self.baseline / name; path.write_text(json.dumps(record))
            digests[name] = hashlib.sha256(path.read_bytes()).hexdigest()
        for name, value in [('PARENT', self.parent), ('SOURCE', self.source), ('LAUNCHER', self.launcher),
                            ('BASELINE', self.baseline), ('BASELINE_SHA', digests)]:
            mocked = patch.object(probe, name, value); mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe, 'helpers', return_value=[self.source, self.launcher])
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.subprocess, 'run', side_effect=self.process)
        self.process_mock = mocked.start(); self.addCleanup(mocked.stop)

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fixture executable never run')
        out = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, out, b'')

    def metadata(self):
        signature = {'status': 'Valid', 'subject': 'CN=Microsoft Windows, O=Microsoft Corporation', 'signature_type': 'Catalog', 'is_os_binary': True}
        return {'schema': 1, 'path': probe.OS_IMAGE, 'bytes': 1234, 'sha256': probe.OS_SHA, 'file_id': {'volume': 1, 'index': '12345'},
                'hard_links': 2, 'file_version': 'fixture-version', 'identity_stable': True, 'signature': signature,
                'automation_assembly': {'full_name': probe.prior.ASSEMBLY, 'under_windows': True, 'signature': copy.deepcopy(signature)}}

    def prepare(self):
        return probe.prepare(self.root)

    def receipt(self, m):
        return {'schema': 1, 'kind': 'console-execution-qualification-probe', 'mode': 'console-execution-qualification', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'tool_images_pinned': True, 'failure': None,
                'proof': {'root_pid': 1001, 'root_exit': 0, 'stop_reason': None, 'bound_members': 2, 'watchdog_stop': 0,
                          'job_final_empty': True, 'all_bound_handles_exited': True}}

    def synthetic(self):
        return {'schema': 1, 'allocated': True, 'released': True, 'pre_execution_identity_verified': True,
                'expected_image_sha256': probe.OS_SHA, 'hold_ms': 2000, 'root_pid': 1001}

    def launched(self):
        m = self.prepare(); probe.launch(self.root); receipt = self.receipt(m)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        (self.root / 'output/console-image.json').write_text(json.dumps(self.metadata()))
        (self.root / 'output/console-synthetic.json').write_text(json.dumps(self.synthetic()))
        (self.root / 'output/samples.jsonl').write_text(json.dumps({'operation': 'process_image_check', 'observed_image': probe.OS_IMAGE, 'pid': 1002}) + '\n')
        return m, receipt

    def test_exact_two_images_single_guest_pin_and_host_bytes(self):
        m = self.prepare()
        self.assertEqual(m['arguments'], [probe.EXE, '--synthetic-console'])
        self.assertEqual(m['images'], [{'path': probe.EXE, 'sha256': m['images'][0]['sha256']}, {'path': probe.OS_IMAGE, 'sha256': probe.OS_SHA}])
        self.assertEqual([row for row in m['inputs'] if row.get('kind') == 'guest_os_pin'], [probe.guest_pin()])
        self.assertEqual(len(m['inputs']), len(m['bindings']) + 1)
        self.assertFalse(any(row['host'] == probe.OS_IMAGE for row in m['bindings']))
        self.assertEqual(m['source_bytes'], sum(row['bytes'] for row in m['bindings']))
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'console-qualification.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false'})
        self.assertEqual(probe.frozen(self.root)[1], m)

    def test_fixed_base_five_substitutions_preserve_unknown_image_guard(self):
        raw, generated, patch_data, report = probe.native_source()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), probe.prior.stdio.BASE_SHA)
        self.assertEqual(report['replacement_counts'], [1] * 8)
        self.assertIn(b'file.Length!=1003520', generated)
        self.assertIn(b'QualifiedInputHash(row)', generated)
        self.assertIn(b'BoundedOSImageHash(actual)', generated)
        self.assertIn(b'UNKNOWN_PROCESS_IMAGE', generated)
        self.assertIn((probe.EXE + ' --synthetic-console').encode(), generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])

    def test_baseline_hash_schema_and_expected_os_hash_must_match(self):
        self.assertEqual(len(probe.baseline()), 2)
        (self.baseline / 'output/console-image.json').write_text('changed')
        with self.assertRaises(ValueError): probe.baseline()
        data = self.metadata(); data['sha256'] = '0' * 64
        path = self.baseline / 'output/console-image.json'; path.write_text(json.dumps(data))
        with patch.dict(probe.BASELINE_SHA, {'output/console-image.json': hashlib.sha256(path.read_bytes()).hexdigest()}):
            with self.assertRaises(ValueError): probe.baseline()

    def test_guest_pin_or_extra_image_or_host_bytes_tampering_rejected(self):
        m = self.prepare()
        for mutate in [lambda x: x['inputs'][-1].update(sha256='0' * 64),
                       lambda x: x['images'].append({'path': '*', 'sha256': probe.OS_SHA}),
                       lambda x: x.update(source_bytes=True)]:
            changed = copy.deepcopy(m); mutate(changed)
            for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
                path.write_text(json.dumps(changed))
            with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_strict_synthetic_fields_and_root_pid(self):
        m = self.prepare(); proof = self.receipt(m)['proof']
        self.assertEqual(probe.validate_synthetic(self.synthetic(), proof), self.synthetic())
        for key, value in [('schema', True), ('allocated', 1), ('released', False), ('pre_execution_identity_verified', False),
                           ('expected_image_sha256', '0' * 64), ('hold_ms', True), ('hold_ms', 1999), ('root_pid', 1002)]:
            changed = self.synthetic(); changed[key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError): probe.validate_synthetic(changed, proof)
        with self.assertRaises(ValueError): probe.validate_synthetic(self.synthetic(), {**proof, 'root_pid': True})

    def test_clean_synthetic_job_support_does_not_qualify_vm_or_flutter(self):
        self.launched(); result = probe.collect(self.root)
        self.assertEqual(result['status'], 'CONSOLE_JOB_SYNTHETIC_QUALIFICATION_SUPPORTED')
        self.assertIs(result['tool_qualified'], True)
        for key in ['producer_entry_allowed', 'vm_execution_allowed', 'flutter_execution_allowed', 'gradle_allowed', 'apk_allowed', 'G2']:
            self.assertIs(result[key], False)
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_missing_conhost_sample_is_sealed_rejected(self):
        self.launched(); (self.root / 'output/samples.jsonl').write_text('')
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)

    def test_stop_or_fixture_error_never_passes(self):
        _, receipt = self.launched()
        receipt['proof'].update(root_exit=None, stop_reason='UNKNOWN_PROCESS_IMAGE')
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)

    def test_guest_os_pin_pre_spawn_failure_only_seals_rejected(self):
        _, receipt = self.launched()
        receipt.update(native_tool_root_attempts=0, input_files=0, proof=None, failure='INPUT_HASH_DRIFT')
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)
        self.assertIsNone(result['proof'])

    def test_create_job_failure_zero_root_and_members_seals_rejected(self):
        _, receipt = self.launched()
        receipt.update(native_tool_root_attempts=0)
        receipt['proof'].update(root_pid=0, root_exit=None, bound_members=0, stop_reason='Win32Exception: CreateJobObject', job_final_empty=False)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertFalse(result['tool_qualified'])
        self.assertTrue((self.root / 'launch.claim.json').exists())

    def test_spawn_or_assign_failure_zero_members_seals_rejected(self):
        _, receipt = self.launched()
        receipt['proof'].update(root_exit=None, bound_members=0, stop_reason='Win32Exception: AssignProcessToJobObject')
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertFalse(result['tool_qualified'])
        self.assertTrue((self.root / 'launch.claim.json').exists())

    def test_fresh_metadata_sha_and_signature_are_revalidated(self):
        self.launched(); metadata = self.metadata(); metadata['sha256'] = '0' * 64
        (self.root / 'output/console-image.json').write_text(json.dumps(metadata))
        self.assertEqual(probe.collect(self.root)['status'], 'REJECTED')

    def test_single_claim_timeout_no_refund_and_bool_receipt_rejection(self):
        m = self.prepare(); receipt = self.receipt(m); receipt['native_tool_root_attempts'] = True
        with self.assertRaises(ValueError): probe.validate_receipt(receipt, m)
        self.process_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertTrue((self.root / 'launch.claim.json').exists())
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        with self.assertRaises(ValueError): probe.launch(self.root)

    def test_invalid_nonce_rejected_before_synthetic_claim(self):
        m = self.prepare(); m['nonce'] = 'invalid'
        for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
            path.write_text(json.dumps(m))
        with self.assertRaises(ValueError): probe.frozen(self.root)
        self.assertFalse((self.root / 'launch.claim.json').exists())


if __name__ == '__main__': unittest.main()
