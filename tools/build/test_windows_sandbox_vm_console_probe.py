"""Temporary files and mocked processes only; no SDK, guest, or device execution."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_vm_console_probe as probe


class VMConsoleProbeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name); self.root = self.parent / 'case01'
        self.sdk = self.parent / 'sdk'; (self.sdk / 'bin').mkdir(parents=True)
        (self.sdk / 'bin/dartvm.exe').write_bytes(b'fake VM never executed')
        self.script = self.parent / 'fixture.dart'; self.script.write_text('// fixture-only')
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('# fixture-only')
        self.real_baseline = probe.baseline
        self.baseline_mock = self.mock(probe, 'baseline', return_value=[{'host': 'synthetic-baseline', 'sha256': 'a' * 64}])
        self.mock(probe, 'PARENT', self.parent)
        self.mock(probe, 'SCRIPT', self.script)
        self.mock(probe, 'LAUNCHER', self.launcher)
        self.mock(probe.stdio, 'SDK', self.sdk)
        self.mock(probe, 'helpers', return_value=[self.script, self.launcher])
        self.mock(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'b' * 64, 'link_count': 2})
        self.process_mock = self.mock(probe.subprocess, 'run', side_effect=self.process)

    def mock(self, target, name, *args, **kwargs):
        mocked = patch.object(target, name, *args, **kwargs)
        value = mocked.start(); self.addCleanup(mocked.stop)
        return value

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fake supervisor never executed')
        out = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, out, b'')

    def receipt(self, manifest):
        return {'schema': 1, 'kind': probe.KIND, 'mode': probe.MODE, 'nonce': manifest['nonce'],
                'binary_sha256': manifest['binary_sha256'], 'input_files': len(manifest['inputs']),
                'kernel_file_version': probe.KERNEL_VERSION, 'clr_version': probe.CLR_VERSION,
                'native_tool_root_attempts': 1, 'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False,
                'tool_images_pinned': True, 'failure': None,
                'proof': {'root_pid': 1001, 'root_exit': 0, 'stop_reason': None, 'bound_members': 2,
                          'watchdog_stop': 0, 'job_final_empty': True, 'all_bound_handles_exited': True}}

    def stages(self):
        events = [{'sequence': 0, 'query': 'main', 'event': 'entered'}]
        for name in probe.stdio.QUERIES:
            events.append({'sequence': len(events), 'query': name, 'event': 'before'})
            value = 80 if name in probe.stdio.QUERIES[2:4] else False
            events.append({'sequence': len(events), 'query': name, 'event': 'after', 'value': value})
        events.append({'sequence': len(events), 'query': 'main', 'event': 'completed'})
        return events

    def write_events(self, events, tail=''):
        (self.root / 'output/stdio-stages.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in events) + tail)

    def launched(self):
        manifest = probe.prepare(self.root); probe.launch(self.root)
        receipt = self.receipt(manifest)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        self.write_events(self.stages())
        samples = [{'operation': 'process_image_check', 'observed_image': probe.EXE, 'pid': 1001},
                   {'operation': 'process_image_check', 'observed_image': probe.console.OS_IMAGE, 'pid': 1002}]
        (self.root / 'output/samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
        return manifest, receipt, samples

    def rewrite_manifest(self, value):
        for name in ['manifest.json', 'probe/manifest.json']:
            (self.root / name).write_text(json.dumps(value))

    def test_profile_maps_only_readonly_sdk_probe_and_owned_output(self):
        m = probe.prepare(self.root)
        self.assertEqual(m['arguments'], probe.stdio.command())
        self.assertEqual(m['max_launches'], 1)
        self.assertFalse(m['producer_entry_allowed'])
        self.assertEqual(len(m['inputs']), len(m['bindings']) + 1)
        self.assertEqual([row for row in m['inputs'] if row.get('kind')], [probe.console.guest_pin()])
        self.assertFalse(any(row['host'] == probe.console.OS_IMAGE for row in m['bindings']))
        self.assertEqual(m['source_bytes'], sum(row['bytes'] for row in m['bindings']))
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'vm-console.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false', r'C:\Inputs\DartSdk': 'true'})
        self.assertEqual(probe.frozen(self.root)[1], m)
        with self.assertRaises(ValueError): probe.prepare(self.root)

    def test_native_source_has_exact_substitutions_and_both_os_hash_call_sites(self):
        raw, generated, patch_data, report = probe.native_source()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), probe.stdio.BASE_SHA)
        self.assertEqual(report['replacement_counts'], [1] * 6)
        self.assertEqual(report['console_replacement_counts'], [1] * 8)
        self.assertIn(b'QualifiedInputHash(row)', generated)
        self.assertIn(b'BoundedOSImageHash(actual)', generated)
        self.assertIn(b'file.Length!=1003520', generated)
        self.assertIn(b'UNKNOWN_PROCESS_IMAGE', generated)
        self.assertIn(b'QUALIFIED_ENVIRONMENT_DRIFT', generated)
        self.assertIn(probe.KERNEL_VERSION.encode(), generated)
        self.assertIn(probe.CLR_VERSION.encode(), generated)
        self.assertIn(probe.contract()['command_line'].encode(), generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])

    def test_guest_pin_extra_image_or_host_bytes_tampering_rejected(self):
        m = probe.prepare(self.root)
        for mutate in [lambda x: x['inputs'][-1].update(sha256='0' * 64),
                       lambda x: x['images'].append({'path': '*', 'sha256': probe.console.OS_SHA}),
                       lambda x: x.update(source_bytes=True)]:
            changed = copy.deepcopy(m); mutate(changed); self.rewrite_manifest(changed)
            with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_nonce_bool_and_receipt_identity_are_strict(self):
        m = probe.prepare(self.root)
        for nonce in [True, 'invalid']:
            self.rewrite_manifest({**m, 'nonce': nonce})
            with self.assertRaises(ValueError): probe.frozen(self.root)
        for key, value in [('native_tool_root_attempts', True), ('input_files', True), ('G2', 0),
                           ('mode', 'stdio-stage'), ('kind', 'console-execution-qualification-probe')]:
            receipt = self.receipt(m); receipt[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError): probe.validate_receipt(receipt, m)
        self.assertFalse((self.root / 'launch.claim.json').exists())

    def test_clean_complete_vm_source_is_supported_without_flutter_or_producer(self):
        self.launched(); result = probe.collect(self.root)
        self.assertEqual(result['status'], probe.SUCCESS)
        self.assertIs(result['tool_qualified'], True)
        self.assertEqual(len(result['stages']['events']), 14)
        for key in ['producer_entry_allowed', 'flutter_execution_allowed', 'gradle_allowed', 'apk_allowed', 'device_allowed', 'media_allowed', 'G2']:
            self.assertIs(result[key], False)
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_missing_console_or_root_sample_rejects(self):
        _, receipt, samples = self.launched()
        stages = {'complete': True}
        for subset in [samples[:1], samples[1:], [], [{**samples[1], 'pid': 1001}]]:
            self.assertEqual(probe.classify(receipt, receipt['proof'], stages, subset), 'REJECTED')
        self.assertEqual(probe.classify(receipt, receipt['proof'], stages, samples + [{'operation': 'process_image_check', 'observed_image': 'unknown.exe', 'pid': 1003}]), 'REJECTED')

    def test_missing_or_truncated_stages_seal_rejected(self):
        self.launched(); self.write_events(self.stages()[:-1], '{"partial":')
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertFalse(result['stages']['complete'])

    def test_stop_watchdog_or_incomplete_cleanup_rejects(self):
        _, receipt, samples = self.launched()
        for key, value in [('root_exit', 1), ('stop_reason', 'UNKNOWN_PROCESS_IMAGE'), ('watchdog_stop', 1),
                           ('job_final_empty', False), ('all_bound_handles_exited', False), ('bound_members', 1), ('root_pid', True)]:
            proof = {**receipt['proof'], key: value}
            with self.subTest(key=key): self.assertEqual(probe.classify(receipt, proof, {'complete': True}, samples), 'REJECTED')

    def test_zero_member_create_job_failure_seals_only_rejected(self):
        _, receipt, _ = self.launched()
        receipt['native_tool_root_attempts'] = 0
        receipt['proof'].update(root_pid=0, root_exit=None, bound_members=0, stop_reason='Win32Exception: CreateJobObject', job_final_empty=False)
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertFalse(result['tool_qualified'])

    def test_preparation_failure_without_root_seals_only_rejected(self):
        _, receipt, _ = self.launched()
        receipt.update(native_tool_root_attempts=0, input_files=0, proof=None, failure='INPUT_HASH_DRIFT')
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIsNone(result['proof'])

    def test_full_input_bootstrap_failure_without_root_seals_only_rejected(self):
        manifest, receipt, _ = self.launched()
        receipt.update(native_tool_root_attempts=0, input_files=len(manifest['inputs']), proof=None,
                       failure='QUALIFIED_ENVIRONMENT_DRIFT')
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIsNone(result['proof'])
        self.assertIs(result['tool_qualified'], False)

    def test_partial_or_bool_bootstrap_input_count_is_not_normalized(self):
        manifest = probe.prepare(self.root)
        receipt = self.receipt(manifest)
        receipt.update(native_tool_root_attempts=0, proof=None, failure='QUALIFIED_ENVIRONMENT_DRIFT')
        for count in [len(manifest['inputs']) - 1, True, False]:
            with self.subTest(input_files=count), self.assertRaises(ValueError):
                probe.validate_receipt({**receipt, 'input_files': count}, manifest)
        for attempts in [True, False]:
            with self.subTest(attempts=attempts), self.assertRaises(ValueError):
                probe.validate_receipt({**receipt, 'native_tool_root_attempts': attempts}, manifest)

    def test_kernel_or_clr_drift_cannot_pass_clean_vm_proof(self):
        _, receipt, samples = self.launched()
        for key, value in [('kernel_file_version', 'different-kernel'), ('kernel_file_version', None),
                           ('clr_version', 'different-clr'), ('clr_version', None)]:
            with self.subTest(key=key, value=value):
                self.assertEqual(probe.classify({**receipt, key: value}, receipt['proof'], {'complete': True}, samples), 'REJECTED')

    def test_timeout_consumes_claim_and_relaunch_is_refused(self):
        probe.prepare(self.root)
        self.process_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertTrue((self.root / 'launch.claim.json').exists())
        self.assertFalse(json.loads((self.root / 'launch.claim.json').read_text())['refundable'])
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        with self.assertRaises(ValueError): probe.launch(self.root)

    def historical_baseline(self):
        folder = self.parent / 'baseline'; (folder / 'output').mkdir(parents=True)
        m = {'nonce': 'a' * 32, 'binary_sha256': 'b' * 64, 'inputs': [probe.console.guest_pin()]}
        receipt = self.receipt(m)
        receipt.update(kind='console-execution-qualification-probe', mode='console-execution-qualification')
        signature = {'status': 'Valid', 'subject': 'CN=Microsoft Windows, O=Microsoft Corporation', 'signature_type': 'Catalog', 'is_os_binary': True}
        metadata = {'schema': 1, 'path': probe.console.OS_IMAGE, 'bytes': 1003520, 'sha256': probe.console.OS_SHA,
                    'file_id': {'volume': 1, 'index': '12345'}, 'hard_links': 1, 'file_version': 'fixture-version', 'identity_stable': True,
                    'signature': signature, 'automation_assembly': {'full_name': probe.console.prior.ASSEMBLY, 'under_windows': True, 'signature': signature}}
        synthetic = {'schema': 1, 'allocated': True, 'released': True, 'pre_execution_identity_verified': True,
                     'expected_image_sha256': probe.console.OS_SHA, 'hold_ms': 2000, 'root_pid': 1001}
        digests = {}
        for name, value in [('manifest.json', m), ('output/result.json', receipt)]:
            path = folder / name; path.write_text(json.dumps(value)); digests[name] = hashlib.sha256(path.read_bytes()).hexdigest()
        result = {'status': 'CONSOLE_JOB_SYNTHETIC_QUALIFICATION_SUPPORTED', 'tool_qualified': True, 'proof': receipt['proof'],
                  'manifest_sha256': digests['manifest.json'], 'receipt_sha256': digests['output/result.json'], 'inventory': metadata, 'synthetic': synthetic,
                  'producer_entry_allowed': False, 'console_execution_allowed': False, 'vm_execution_allowed': False, 'flutter_execution_allowed': False, 'G2': False}
        path = folder / 'verified-result.json'; path.write_text(json.dumps(result)); digests['verified-result.json'] = hashlib.sha256(path.read_bytes()).hexdigest()
        self.mock(probe, 'BASELINE', folder); self.mock(probe, 'BASELINE_SHA', digests)
        return folder, digests, result

    def test_historical_baseline_pins_all_three_evidence_documents(self):
        folder, _, _ = self.historical_baseline()
        self.assertEqual(len(self.real_baseline()), 3)
        (folder / 'output/result.json').write_text('changed')
        with self.assertRaises(ValueError): self.real_baseline()

    def test_rehashed_baseline_cannot_grant_vm_or_change_os_identity(self):
        folder, digests, result = self.historical_baseline()
        for mutate in [lambda x: x.update(vm_execution_allowed=True),
                       lambda x: x['inventory'].update(sha256='0' * 64),
                       lambda x: x['synthetic'].update(root_pid=1002)]:
            changed = copy.deepcopy(result); mutate(changed)
            path = folder / 'verified-result.json'; path.write_text(json.dumps(changed))
            digests['verified-result.json'] = hashlib.sha256(path.read_bytes()).hexdigest()
            with self.assertRaises(ValueError): self.real_baseline()


if __name__ == '__main__': unittest.main()
