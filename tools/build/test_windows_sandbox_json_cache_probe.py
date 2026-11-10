"""Synthetic inputs and mocked processes only; no SDK, VM, or device execution."""
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_json_cache_probe as probe


class JsonCacheProbeTests(unittest.TestCase):
    def setUp(self):
        temporary = tempfile.TemporaryDirectory(); self.addCleanup(temporary.cleanup)
        self.parent = Path(temporary.name); self.root = self.parent / 'case01'
        self.flutter = self.parent / 'flutter-source'
        for name in probe.cache.CONTROLS:
            path = self.flutter / name; path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b'fixture ' + name.encode())
        self.metadata = {'frameworkVersion': '3.41.7', 'frameworkRevision': 'cc0734ac716fbb8b90f3f9db8020958b1553afa7',
                         'dartSdkVersion': '3.11.5', 'channel': 'stable'}
        self.raw_metadata = json.dumps(self.metadata).encode()
        (self.flutter / probe.VERSION_ROLE).write_bytes(self.raw_metadata)
        (self.flutter / 'bin/cache/dart-sdk/version').write_text('3.11.5')
        self.sdk = self.flutter / 'bin/cache/dart-sdk'; (self.sdk / 'bin').mkdir()
        for name in ['dart.exe', 'dartvm.exe']:
            (self.sdk / 'bin' / name).write_bytes(b'fixture nonexecutable ' + name.encode())
        self.helper = self.parent / 'helper.py'; self.helper.write_text('# fixture-only')
        self.launcher = self.parent / 'launcher.ps1'; self.launcher.write_text('# fixture-only')
        self.real_prerequisites = probe.prerequisites
        self.real_check_reused_inputs = probe.check_reused_inputs
        self.mock(probe, 'PARENT', self.parent)
        self.mock(probe.cache, 'SDK', self.sdk)
        self.mock(probe.cache, 'FLUTTER', self.flutter)
        self.mock(probe.dart, 'LAUNCHER', self.launcher)
        self.mock(probe, 'helpers', return_value=[self.helper, self.launcher])
        self.mock(probe, 'prerequisites', side_effect=lambda: self.evidence())
        self.mock(probe, 'check_reused_inputs', return_value=None)
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

    def evidence(self):
        signature = {'status': 'Valid', 'subject': 'CN=Microsoft Windows, O=Microsoft Corporation', 'signature_type': 'Catalog', 'is_os_binary': True}
        metadata = {'schema': 1, 'path': probe.prior.WHERE, 'bytes': 65536, 'sha256': 'b' * 64,
                    'file_id': {'volume': 1, 'index': '12345'}, 'hard_links': 1, 'file_version': 'fixture-version',
                    'identity_stable': True, 'signature': signature,
                    'automation_assembly': {'full_name': probe.prior.console.prior.ASSEMBLY, 'under_windows': True, 'signature': copy.deepcopy(signature)}}
        return {'pins': [], 'where': metadata}

    def receipt(self, m):
        return {'schema': 1, 'kind': m['kind'], 'mode': m['mode'], 'nonce': m['nonce'],
                'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']), 'native_tool_root_attempts': 1,
                'gradle_root_attempts': 0, 'apk_builds': 0, 'G2': False, 'failure': None, 'tool_images_pinned': True,
                'kernel_file_version': probe.prior.vm.KERNEL_VERSION, 'clr_version': probe.prior.vm.CLR_VERSION,
                'proof': {'root_pid': 1001, 'root_exit': 2, 'stop_reason': None, 'job_final_empty': True,
                          'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 2},
                'cache_state': {**probe.policy.OBSERVATION, 'version_metadata_sha256': m['metadata_sha256'],
                                'version_metadata_bytes': len(self.raw_metadata), 'metadata_source': 'PRESEEDED_CONTROL'}}

    def launched(self):
        self.mock(probe, 'RUNTIME_AUTHORIZED', True)
        m = probe.prepare(self.root); probe.launch(self.root); receipt = self.receipt(m)
        samples = [{'operation': 'process_image_check', 'observed_image': m['executable'], 'pid': 1001},
                   {'operation': 'process_image_check', 'observed_image': probe.prior.console.OS_IMAGE, 'pid': 1002}]
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        (self.root / 'output/samples.jsonl').write_text(''.join(json.dumps(row) + '\n' for row in samples))
        (self.root / 'output/tool.stdout').write_bytes(b'')
        (self.root / 'output/tool.stderr').write_text(probe.cache.ERROR_TEXT)
        return m, receipt, samples

    def rewrite_manifest(self, m):
        for name in ['manifest.json', 'probe/manifest.json']:
            (self.root / name).write_text(json.dumps(m))

    def classify(self, m, receipt, samples, text=None):
        return probe.classify(receipt, m, samples, probe.cache.ERROR_TEXT if text is None else text, self.root)[0]

    def test_default_static_profile_prepares_separate_case_and_readonly_mappings(self):
        with patch.object(probe, 'RUNTIME_AUTHORIZED', False):
            m = probe.prepare(self.root)
            self.assertEqual(probe.frozen(self.root)[1], m)
        self.assertEqual(m['max_launches'], 1); self.assertIs(m['runtime_authorized'], False)
        self.assertEqual(m['json_source'], 'PRESEEDED_CONTROL')
        self.assertEqual(probe.profile().root, self.root)
        self.assertNotEqual(self.root, probe.PREVIOUS)
        mappings = {row.findtext('SandboxFolder'): row.findtext('ReadOnly') for row in ET.fromstring((self.root / 'probe.wsb').read_text()).findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false', r'C:\Inputs\DartSdk': 'true', r'C:\Inputs\FlutterControls': 'true'})
        self.assertEqual(len(m['inputs']), len(m['bindings']) + 2)
        self.assertEqual(m['source_bytes'], sum(row['bytes'] for row in m['bindings']))

    def test_denied_launch_creates_no_claim_and_no_subprocess(self):
        with patch.object(probe, 'RUNTIME_AUTHORIZED', False):
            probe.prepare(self.root); self.run_mock.reset_mock()
            with self.assertRaises(ValueError): probe.launch(self.root)
        self.run_mock.assert_not_called()
        self.assertFalse((self.root / 'launch.claim.json').exists())
        self.assertFalse((self.root / 'launched.json').exists())

    def test_integer_one_does_not_authorize_launch(self):
        with patch.object(probe, 'RUNTIME_AUTHORIZED', 1):
            probe.prepare(self.root); self.run_mock.reset_mock()
            with self.assertRaises(ValueError): probe.launch(self.root)
        self.run_mock.assert_not_called()
        self.assertFalse((self.root / 'launch.claim.json').exists())

    def test_native_one_observer_body_replacement_retains_lock_and_os_guards(self):
        digest = hashlib.sha256(self.raw_metadata).hexdigest()
        raw, generated, patch_data, report = probe.native_source(self.evidence(), digest)
        self.assertEqual(report['observer_replacements'], 1)
        self.assertEqual(generated.count(b'static object ReadCacheState() {'), 1)
        self.assertEqual(report['upstream_report']['replacement_counts'], [1] * 9)
        self.assertEqual(hashlib.sha256(raw).hexdigest(), report['base_sha256'])
        for required in [b'QualifiedInputHash(row)', b'BoundedOSImageHash(actual)', b'UNKNOWN_PROCESS_IMAGE',
                         b'NORMAL_CACHE_LOCK_REQUIRED', b'RequireFreshCache(m)', b'FileShare.Read',
                         b'bytes>32768', b'SameCacheIdentity(lockBefore,lockAfter)',
                         b'SameCacheIdentity(metadataBefore,metadataAfter)', b'new UTF8Encoding(false,true)',
                         b'version_metadata_sha256=digest', b'Regex.IsMatch(expected', b'[0-9a-f]{64}', digest.encode()]:
            self.assertIn(required, generated)
        self.assertEqual(hashlib.sha256(patch_data).hexdigest(), report['patch_sha256'])

    def test_complete_input_extra_image_environment_and_guest_pin_drift_rejected(self):
        m = probe.prepare(self.root)
        for mutate in [lambda x: x['images'].append({'path': '*', 'sha256': '0' * 64}),
                       lambda x: x['inputs'][-1].update(sha256='0' * 64),
                       lambda x: x['environment'].update(FLUTTER_ALREADY_LOCKED='true'),
                       lambda x: x.update(source_bytes=True)]:
            changed = copy.deepcopy(m); mutate(changed); self.rewrite_manifest(changed)
            with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_metadata_manifest_and_source_pin_sha_are_both_checked(self):
        m = probe.prepare(self.root)
        bad = copy.deepcopy(m); bad['metadata_sha256'] = '0' * 64; self.rewrite_manifest(bad)
        with self.assertRaises(ValueError): probe.frozen(self.root)
        bad = copy.deepcopy(m)
        next(row for row in bad['source_pins'] if row['role'] == probe.VERSION_ROLE)['sha256'] = '0' * 64
        self.rewrite_manifest(bad)
        with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_original_control_or_generated_native_source_drift_rejected(self):
        probe.prepare(self.root)
        generated = self.root / 'probe/WhereValidationProbe.cs'; original = generated.read_bytes()
        generated.write_bytes(b'changed native source')
        with self.assertRaises(ValueError): probe.frozen(self.root)
        generated.write_bytes(original)
        (self.flutter / 'LICENSE').write_bytes(b'changed original control')
        with self.assertRaises(ValueError): probe.frozen(self.root)

    def test_clean_exit2_typed_observation_support_is_limited_to_preseeded_metadata(self):
        self.launched(); result = probe.collect(self.root)
        self.assertEqual(result['status'], probe.SUCCESS); self.assertIs(result['tool_qualified'], True)
        self.assertEqual(result['metadata_source'], 'PRESEEDED_CONTROL')
        self.assertEqual(result['metadata_generation'], 'NOT_PROVEN')
        self.assertEqual(result['tool_metadata_consumption'], 'NOT_DIRECTLY_OBSERVED')
        self.assertEqual(result['legacy_feature_flag'], 'NOT_DIRECTLY_OBSERVED')
        self.assertEqual(result['cache_lock_held'], 'NOT_DIRECTLY_OBSERVED')
        self.assertNotIn('future_profile_status', result['observation_policy'])
        for key in ['producer_entry_allowed', 'gradle_allowed', 'apk_allowed', 'device_allowed', 'media_allowed', 'G2']:
            self.assertIs(result[key], False)
        with self.assertRaises(FileExistsError): probe.collect(self.root)

    def test_cache_state_missing_extra_or_boolean_fields_are_rejected(self):
        m, receipt, samples = self.launched()
        states = [{k: v for k, v in receipt['cache_state'].items() if k != 'lock_identity_stable'},
                  {**receipt['cache_state'], 'extra': True}]
        for key, value in [('lock_exists', 1), ('lock_bytes', False), ('lock_reparse', 0),
                           ('lock_identity_stable', 1), ('legacy_version_file_exists', 0)]:
            states.append({**receipt['cache_state'], key: value})
        for state in states:
            with self.subTest(state=state):
                self.assertEqual(self.classify(m, {**receipt, 'cache_state': state}, samples), 'REJECTED')

    def test_state_metadata_sha_bytes_source_and_legacy_must_match(self):
        m, receipt, samples = self.launched()
        for key, value in [('version_metadata_sha256', '0' * 64), ('version_metadata_bytes', True),
                           ('version_metadata_bytes', len(self.raw_metadata) + 1), ('metadata_source', 'GENERATED'),
                           ('legacy_version_file_exists', True), ('lock_identity_stable', False), ('lock_bytes', 1)]:
            bad = copy.deepcopy(receipt); bad['cache_state'][key] = value
            with self.subTest(key=key, value=value): self.assertEqual(self.classify(m, bad, samples), 'REJECTED')

    def test_receipt_failure_wrong_exit_stop_or_incomplete_cleanup_rejects(self):
        m, receipt, samples = self.launched()
        self.assertEqual(self.classify(m, {**receipt, 'failure': 'observer failure'}, samples), 'REJECTED')
        for key, value in [('root_exit', 0), ('root_exit', 255), ('stop_reason', 'UNKNOWN_PROCESS_IMAGE'),
                           ('watchdog_stop', 1), ('job_final_empty', False), ('all_bound_handles_exited', False)]:
            bad = copy.deepcopy(receipt); bad['proof'][key] = value
            with self.subTest(key=key): self.assertEqual(self.classify(m, bad, samples), 'REJECTED')
        self.assertEqual(self.classify(m, receipt, samples, 'wrong error'), 'REJECTED')

    def test_phase_receipt_identity_and_boolean_counters_are_strict(self):
        m, receipt, samples = self.launched()
        for key, value in [('kind', 'where-chain-cache-probe'), ('mode', 'where-chain-cache'),
                           ('native_tool_root_attempts', True), ('input_files', True), ('G2', 0)]:
            with self.subTest(key=key), self.assertRaises(ValueError):
                self.classify(m, {**receipt, key: value}, samples)
        bad = copy.deepcopy(receipt); bad['proof']['root_exit'] = True
        with self.assertRaises(ValueError): self.classify(m, bad, samples)

    def test_missing_unknown_or_conflicting_process_samples_rejects(self):
        m, receipt, samples = self.launched()
        for changed in [[], samples[:1], samples[1:], [{**samples[0], 'observed_image': 'unknown.exe'}, samples[1]],
                        samples + [{**samples[0], 'observed_image': probe.prior.WHERE}]]:
            self.assertEqual(self.classify(m, receipt, changed), 'REJECTED')
        (self.root / 'output/tool.stderr').unlink()
        self.assertEqual(self.classify(m, receipt, samples), 'REJECTED')

    def test_bootstrap_full_input_failure_seals_only_rejected(self):
        m, receipt, _ = self.launched()
        receipt.update(native_tool_root_attempts=0, proof=None, failure='CACHE_METADATA_IDENTITY_DRIFT', input_files=len(m['inputs']))
        (self.root / 'output/result.json').write_text(json.dumps(receipt))
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'REJECTED'); self.assertIsNone(result['observation_policy'])
        self.assertFalse(result['tool_qualified'])

    def test_timeout_claim_is_permanent_and_retry_is_refused(self):
        self.mock(probe, 'RUNTIME_AUTHORIZED', True); probe.prepare(self.root)
        self.run_mock.side_effect = [subprocess.CompletedProcess([], 0, b'', b''), subprocess.TimeoutExpired('fixture', 30, output=b'partial')]
        with self.assertRaises(subprocess.TimeoutExpired): probe.launch(self.root)
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        claim = json.loads((self.root / 'launch.claim.json').read_text())
        self.assertEqual(claim['max_launches'], 1); self.assertIs(claim['refundable'], False)
        with self.assertRaises(ValueError): probe.launch(self.root)

    def historical_rejection(self):
        previous = self.parent / 'previous'; (previous / 'output').mkdir(parents=True)
        records = {'manifest.json': {'fixture': 'manifest'}, 'output/result.json': {'fixture': 'receipt'},
                   'verified-result.json': {'status': 'REJECTED', 'tool_qualified': False, 'cache_state': None,
                                            'producer_entry_allowed': False, 'G2': False}}
        digests, raw = {}, {}
        for name, record in records.items():
            path = previous / name; path.write_text(json.dumps(record)); raw[name] = path.read_bytes()
            digests[name] = hashlib.sha256(raw[name]).hexdigest()
        self.mock(probe, 'PREVIOUS', previous); self.mock(probe, 'PREVIOUS_SHA', digests)
        self.mock(probe.prior, 'prerequisites', return_value=self.evidence())
        return previous, records, digests, raw

    def test_three_old_rejection_documents_are_hard_pinned_and_cannot_drift(self):
        previous, _, _, raw = self.historical_rejection()
        self.assertEqual(len(self.real_prerequisites()['pins']), 3)
        for name in raw:
            path = previous / name; path.write_bytes(b'changed old evidence')
            with self.subTest(name=name), self.assertRaises(ValueError): self.real_prerequisites()
            path.write_bytes(raw[name])

    def test_rehashed_old_result_cannot_be_reclassified_supported(self):
        previous, records, digests, _ = self.historical_rejection()
        record = records['verified-result.json']; record.update(status='SUPPORTED', tool_qualified=True)
        path = previous / 'verified-result.json'; path.write_text(json.dumps(record))
        digests['verified-result.json'] = hashlib.sha256(path.read_bytes()).hexdigest()
        with self.assertRaises(ValueError): self.real_prerequisites()

    def reused_input_baseline(self):
        previous = self.parent / 'reused-input-baseline'; previous.mkdir()
        rows = [{'path': r'C:\Inputs\DartSdk\bin\dartvm.exe', 'sha256': 'a' * 64},
                {'path': r'C:\Inputs\FlutterControls\bin\cache\flutter.version.json', 'sha256': 'b' * 64,
                 'destination': r'C:\BuildWork\Flutter\bin\cache\flutter.version.json'},
                {'path': r'C:\Probe\WhereValidationProbe.exe', 'sha256': 'c' * 64}]
        sources = [{'role': 'bin/cache/flutter.version.json', 'sha256': 'b' * 64,
                    'file_id': {'device': 1, 'inode': 2}, 'bytes': 123}]
        raw = json.dumps({'inputs': rows, 'source_pins': sources}).encode()
        (previous / 'manifest.json').write_bytes(raw)
        self.mock(probe, 'PREVIOUS', previous)
        self.mock(probe, 'PREVIOUS_SHA', {'manifest.json': hashlib.sha256(raw).hexdigest()})
        return previous, rows, sources

    def test_reused_sdk_controls_and_source_identities_match_while_new_probe_may_change(self):
        _, rows, sources = self.reused_input_baseline()
        self.real_check_reused_inputs(rows, sources)
        new_rows = copy.deepcopy(rows); new_rows[-1]['sha256'] = 'd' * 64
        new_rows.append({'path': r'C:\Probe\new-helper.cs', 'sha256': 'e' * 64})
        self.real_check_reused_inputs(new_rows, copy.deepcopy(sources))

    def test_reused_sdk_control_sha_or_source_fileid_drift_rejected(self):
        previous, rows, sources = self.reused_input_baseline()
        for index in [0, 1]:
            changed = copy.deepcopy(rows); changed[index]['sha256'] = '0' * 64
            with self.subTest(index=index), self.assertRaises(ValueError):
                self.real_check_reused_inputs(changed, sources)
        changed_sources = copy.deepcopy(sources); changed_sources[0]['file_id']['inode'] = 3
        with self.assertRaises(ValueError): self.real_check_reused_inputs(rows, changed_sources)
        with self.assertRaises(ValueError): self.real_check_reused_inputs(rows[1:], sources)
        (previous / 'manifest.json').write_bytes(b'changed historical bytes')
        with self.assertRaises(ValueError): self.real_check_reused_inputs(rows, sources)


if __name__ == '__main__': unittest.main()
