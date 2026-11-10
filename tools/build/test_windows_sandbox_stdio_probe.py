"""Only temporary SDK/script fixtures and mocked process calls."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_stdio_probe as probe


class StdioProbeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name)
        self.root = self.parent / 'case01'
        self.sdk = self.parent / 'sdk'
        (self.sdk / 'bin').mkdir(parents=True)
        (self.sdk / 'bin/dartvm.exe').write_bytes(b'fixture-vm-nonexecutable')
        (self.sdk / 'bin/dart.exe').write_bytes(b'fixture-wrapper-nonexecutable')
        self.script = self.parent / 'script.dart'; self.script.write_text('fixture script')
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('fixture launcher')
        for name, value in [('PARENT', self.parent), ('SDK', self.sdk), ('SCRIPT', self.script), ('LAUNCHER', self.launcher)]:
            mocked = patch.object(probe, name, value); mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe, 'helpers', return_value=[self.script, self.launcher])
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.dart, 'compiler_identity', return_value={'bytes': 1, 'file_id': [1, 2], 'sha256': 'a' * 64, 'link_count': 2})
        mocked.start(); self.addCleanup(mocked.stop)
        mocked = patch.object(probe.subprocess, 'run', side_effect=self.process)
        self.process_mock = mocked.start(); self.addCleanup(mocked.stop)

    def process(self, args, **kwargs):
        if '/target:winexe' in args:
            Path(next(arg[5:] for arg in args if arg.startswith('/out:'))).write_bytes(b'fixture-native')
        out = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, out, b'')

    def prepare(self):
        return probe.prepare(self.root)

    def events(self):
        events = [{'query': 'main', 'event': 'entered'}]
        for query in probe.QUERIES:
            events += [{'query': query, 'event': 'before'}, {'query': query, 'event': 'after',
                         'value': 80 if query in probe.QUERIES[2:4] else False}]
        events.append({'query': 'main', 'event': 'completed'})
        return [{'sequence': sequence, **event} for sequence, event in enumerate(events)]

    def write_markers(self, events):
        path = self.root / 'output/stdio-stages.jsonl'
        path.write_text(''.join(json.dumps(event) + '\n' for event in events), encoding='utf-8')
        return path

    def receipt(self, m):
        return {'schema': 1, 'kind': 'stdio-stage-probe', 'mode': 'stdio-stage', 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'proof': {'root_exit': 0, 'stop_reason': None, 'bound_members': 1, 'watchdog_stop': 0,
                          'job_final_empty': True, 'all_bound_handles_exited': True}}

    def launch_receipt(self):
        m = self.prepare(); probe.launch(self.root)
        r = self.receipt(m)
        (self.root / 'output/result.json').write_text(json.dumps(r))
        return m, r

    def test_native_transform_exact_base_identity_and_five_substitutions(self):
        raw, generated, patch_data, report = probe.native_source()
        self.assertEqual(hashlib.sha256(raw).hexdigest(), probe.BASE_SHA)
        self.assertEqual(report['replacement_counts'], [1] * 5)
        self.assertIn(probe.EXE.encode(), generated)
        self.assertIn(subprocess.list2cmdline(probe.command()).encode(), generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])
        bad = self.parent / 'wrong-source.cs'; bad.write_bytes(raw + b'changed')
        with patch.object(probe.dart, 'SOURCE', bad):
            with self.assertRaises(ValueError): probe.native_source()
        duplicated = raw.replace(b'kind="native-tool-probe"', b'kind="native-tool-probe",kind="native-tool-probe"')
        bad.write_bytes(duplicated)
        with patch.object(probe.dart, 'SOURCE', bad), patch.object(probe, 'BASE_SHA', hashlib.sha256(duplicated).hexdigest()):
            with self.assertRaisesRegex(ValueError, 'exactly one'): probe.native_source()

    def test_fixed_vm_command_mappings_and_single_image(self):
        m = self.prepare()
        self.assertEqual(m['arguments'], [probe.EXE, '--resolved_executable_name=' + probe.dart.EXE, '--executable_name=' + probe.dart.EXE, probe.DESTINATION])
        self.assertEqual(m['environment'], probe.dart.environment())
        self.assertEqual([row['path'] for row in m['images']], [probe.EXE])
        self.assertEqual([row['destination'] for row in m['inputs'] if 'destination' in row], [probe.DESTINATION])
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'stdio.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false', r'C:\Inputs\DartSdk': 'true'})
        self.assertEqual(probe.frozen(self.root)[1], m)
        with self.assertRaises(ValueError): probe.owned(self.parent / 'case02', False)

    def test_source_and_script_caps_before_open_and_inventory_drift(self):
        self.script.write_bytes(b'x' * 16385)
        with patch.object(probe.inventory.os, 'open') as opened:
            with self.assertRaises(ValueError): probe.pinned_bytes(self.script, 16384)
            opened.assert_not_called()
        self.script.write_text('fixture script')
        self.prepare()
        (self.sdk / 'bin/dartvm.exe').write_bytes(b'changed')
        with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_failed_launch_and_timeout_never_refund(self):
        self.prepare()
        self.process_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        self.assertTrue((self.root / 'launch.claim.json').exists())
        with self.assertRaises(ValueError): probe.launch(self.root)

    def test_complete_markers_and_getter_error_preserved(self):
        self.prepare(); events = self.events()
        events[6] = {'sequence': 6, 'query': 'stdout_terminal_columns', 'event': 'error', 'kind': 'StdoutException'}
        stages = probe.markers(self.write_markers(events))
        self.assertTrue(stages['complete'])
        self.assertEqual(stages['events'][6]['kind'], 'StdoutException')

    def test_marker_missing_partial_before_and_truncated_tail(self):
        self.prepare(); path = self.root / 'output/stdio-stages.jsonl'
        self.assertEqual(probe.markers(path)['status'], 'NO_STAGE_RECORDED')
        self.write_markers(self.events()[:2])
        stages = probe.markers(path)
        self.assertFalse(stages['complete'])
        self.assertEqual(stages['events'][-1]['event'], 'before')
        with path.open('ab') as stream: stream.write(b'{"sequence":2,"query":')
        stages = probe.markers(path)
        self.assertEqual(len(stages['events']), 2)
        self.assertIsNotNone(stages['incomplete_tail'])

    def test_marker_schema_order_bool_int_and_cap_rejected(self):
        self.prepare()
        for change in [lambda e: e[2].update(sequence=True), lambda e: e[2].update(query='stdin_has_terminal'),
                       lambda e: e[6].update(value=True), lambda e: e[0].update(extra=1)]:
            events = self.events(); change(events)
            with self.assertRaises(ValueError): probe.markers(self.write_markers(events))
        path = self.root / 'output/stdio-stages.jsonl'; path.write_bytes(b'x' * 16385)
        with self.assertRaises(ValueError): probe.markers(path)

    def test_clean_vm_success_keeps_producer_unproven(self):
        self.launch_receipt(); self.write_markers(self.events())
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'STDIO_VM_SINGLE_PROCESS_SOURCE_SUPPORTED')
        self.assertIs(result['tool_qualified'], True)
        self.assertIs(result['producer_entry_allowed'], False)
        self.assertEqual(result['wrapper'], 'NOT_PROVEN')
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_conhost_stop_sealed_without_stage_or_qualification(self):
        _, r = self.launch_receipt()
        r['proof'].update(root_exit=None, stop_reason='GradleDiagnostic+SafetyStop: UNKNOWN_PROCESS_IMAGE', bound_members=2)
        (self.root / 'output/result.json').write_text(json.dumps(r))
        (self.root / 'output/samples.jsonl').write_text(json.dumps({'operation': 'process_image_check', 'observed_image': r'C:\Windows\System32\conhost.exe'}) + '\n')
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'STDIO_VM_REPRODUCED_UNQUALIFIED_CONSOLE')
        self.assertIs(result['tool_qualified'], False)
        self.assertEqual(result['stages']['status'], 'NO_STAGE_RECORDED')

    def test_similar_stop_name_never_claims_console_reproduction(self):
        _, r = self.launch_receipt()
        r['proof'].update(root_exit=None, stop_reason='OTHER_UNKNOWN_PROCESS_IMAGE', bound_members=2)
        (self.root / 'output/result.json').write_text(json.dumps(r))
        (self.root / 'output/samples.jsonl').write_text(json.dumps({'operation': 'process_image_check', 'observed_image': r'C:\Windows\System32\conhost.exe'}) + '\n')
        self.assertEqual(probe.collect(self.root)['status'], 'REJECTED')

    def test_nonce_and_false_signature_claim_rejected_before_launch(self):
        m = self.prepare()
        for key, value in [('nonce', 'wrong'), ('dartvm_authenticode_status', 'Valid')]:
            bad = copy.deepcopy(m); bad[key] = value
            for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
                path.write_text(json.dumps(bad))
            with self.subTest(key=key), self.assertRaises(ValueError):
                probe.frozen(self.root)
        self.assertFalse((self.root / 'launch.claim.json').exists())

    def test_unknown_stop_rejected_and_receipt_forgery_rejected(self):
        m, r = self.launch_receipt()
        r['proof'].update(root_exit=None, stop_reason='OTHER_STOP')
        (self.root / 'output/result.json').write_text(json.dumps(r))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED')
        self.assertIs(result['tool_qualified'], False)
        for key, value in [('schema', True), ('input_files', 0), ('gradle_root_attempts', 1), ('failure', 'failed')]:
            bad = copy.deepcopy(r); bad[key] = value
            with self.assertRaises(ValueError): probe.validate_result(bad, m)
        bad = copy.deepcopy(r); bad['proof']['job_final_empty'] = False
        with self.assertRaises(ValueError): probe.validate_result(bad, m)


if __name__ == '__main__': unittest.main()
