"""Source/fixture checks only. Never launch a guest or execute a native SDK."""
import hashlib
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import cmake_vc_candidate as candidate
import test_native_role_executor as fixtures


class CMakeVCCandidateTests(unittest.TestCase):
    def setUp(self):
        self.host = candidate.derive_host()

    def test_derivation_has_new_scope_count_and_collector_without_partial_recovery(self):
        h = self.host
        self.assertNotEqual(h.SCOPE, 'v1015-native-cmake-version-qualification-20261105')
        self.assertEqual(h.LIMITS['input_files'], 45)
        self.assertEqual(h.policy()['readonly_preflight_file_denials'], 270)
        self.assertEqual(h.policy()['readonly_preflight_directory_denials'], 15)
        self.assertFalse(hasattr(h, 'finish_preparation'))
        self.assertFalse(hasattr(h, 'PARTIAL_NONCE'))
        self.assertIn('import cmake_vc_candidate as h;', candidate.derive_source().decode())

    def test_original_source_and_wrapper_hashes_fail_closed(self):
        with self.assertRaises(ValueError):
            candidate.derive_source(b'changed consumed source')
        with self.assertRaises(ValueError):
            candidate.derive_wrapper(b'changed consumed guest wrapper')

    def test_generated_guest_has_270_denials_and_locked_new_input_hashes(self):
        pins = fixtures.fixture_pins()
        while len(pins) < 45:
            pins[self.host.core.ROOTS['android_cmake_3_22_1'] + '\\bin\\fixture-%s.dll' % len(pins)] = 'c' * 64
        source = self.host.guest_source(pins, 'a' * 32)
        self.assertIn(b'files!=270||dirs!=15', source)
        self.assertNotIn(b'files!=252', source)
        self.assertIn(b'native-cmake-vc-preflight', source)
        self.assertIn(b'root_birth=rootBirth', source)
        self.assertIn(b'"runtime_authorized"', source.replace(b'\\"', b'"'))

    def test_default_launch_cannot_enter_freeze_or_touch_processes(self):
        with patch.object(self.host, 'frozen', side_effect=AssertionError('must not enter')):
            for value in (False, None, 1, 'true'):
                with self.assertRaises(ValueError):
                    self.host.launch(new_scope_authorized=value, owner_reference='old')

    def test_configuration_keeps_five_RO_roots_and_only_new_case_owned_output(self):
        h = self.host
        mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                    for role, guest in h.core.ROOTS.items()}
        mappings['android_cmake_3_22_1']['host'] = str(candidate.PRIVATE_CMAKE)
        xml = ET.fromstring(h.configuration(mappings, 'a' * 32))
        rows = xml.findall('MappedFolders/MappedFolder')
        self.assertEqual(len(rows), 7)
        self.assertEqual([r.findtext('HostFolder') for r in rows if r.findtext('ReadOnly') == 'false'],
                         [str(h.ROOT / 'output')])
        self.assertEqual(xml.findtext('Networking'), 'Disable')
        mappings['android_cmake_3_22_1']['readonly'] = False
        with self.assertRaises(ValueError):
            h.configuration(mappings, 'a' * 32)

    def test_complete_private_tree_rejects_content_identity_and_membership_drift(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory); (root / 'bin').mkdir()
            (root / 'bin/cmake.exe').write_bytes(b'fixture, never executed')
            actual = candidate.tree_inventory.inventory_trees(roots={'private_cmake': str(root)}, **candidate.TREE_CAPS)
            material = {'private_cmake_root': str(root), 'private_files': 1,
                        'private_bytes': actual['total_bytes'], 'inventory': actual}
            raw = json.dumps(material).encode()
            with patch.object(candidate, 'PRIVATE_CMAKE', root), \
                 patch.object(candidate, 'MATERIALIZATION_SHA', hashlib.sha256(raw).hexdigest()), \
                 patch.object(candidate.base, 'safe_bytes', return_value=raw):
                candidate.verify_private_tree()
                (root / 'bin/cmake.exe').write_bytes(b'changed')
                with self.assertRaises(ValueError):
                    candidate.verify_private_tree()
                (root / 'extra').write_bytes(b'not declared')
                with self.assertRaises(ValueError):
                    candidate.verify_private_tree()

    def test_prepare_freezes_false_authority_and_refuses_second_preparation(self):
        h = self.host
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'candidate'
            compiler = Path(directory) / 'fixture-csc';compiler.write_bytes(b'synthetic compiler')
            pins = fixtures.fixture_pins()
            mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                        for role, guest in h.core.ROOTS.items()}
            def fake_compile(argv, **kwargs):
                self.assertIn('/noconfig', argv)
                self.assertIn('/target:winexe', argv)
                self.assertEqual(kwargs['env']['TEMP'], str(root / 'compile-temp'))
                self.assertEqual(kwargs['env']['TMP'], str(root / 'compile-temp'))
                self.assertFalse(any(k.upper().startswith(('COR_', 'CORECLR_', 'COMPLUS_'))
                                     or k.upper() in ('LIB', 'DOTNET_STARTUP_HOOKS') for k in kwargs['env']))
                (root / 'probe/NativeRoleProbe.exe').write_bytes(b'synthetic binary not executable')
                return SimpleNamespace(returncode=0, stdout=b'', stderr=b'')
            with patch.object(h, 'ROOT', root), patch.object(h, 'readset', return_value=({}, pins, mappings)), \
                 patch.object(h, 'compiler_pin', return_value=(compiler, 'b' * 64)), \
                 patch.object(h.subprocess, 'run', side_effect=fake_compile) as compile_call:
                result = candidate.prepare_host(h)
                self.assertEqual(result['status'], 'SOURCE_READY_NOT_AUTHORIZED')
                self.assertIs(result['claim_created'], False)
                contract, _ = h.frozen()
                self.assertNotIn('partial_receipt_sha256', contract)
                self.assertIs(contract['manifest']['runtime_authorized'], False)
                self.assertFalse((root / 'probe/manifest.json').exists())
                self.assertFalse((root / 'launch.claim.json').exists())
                with self.assertRaises(FileExistsError):
                    candidate.prepare_host(h)
                self.assertEqual(compile_call.call_count, 1)

    def test_compile_failure_retains_artifacts_and_never_reprepares(self):
        h = self.host
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'candidate';pins = fixtures.fixture_pins()
            compiler = Path(directory) / 'fixture-csc';compiler.write_bytes(b'synthetic compiler')
            mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                        for role, guest in h.core.ROOTS.items()}
            with patch.object(h, 'ROOT', root), patch.object(h, 'readset', return_value=({}, pins, mappings)), \
                 patch.object(h, 'compiler_pin', return_value=(compiler, 'b' * 64)), \
                 patch.object(h.subprocess, 'run', return_value=SimpleNamespace(returncode=1, stdout=b'failed', stderr=b'')):
                with self.assertRaises(RuntimeError):
                    candidate.prepare_host(h)
                self.assertTrue((root / 'probe/NativeRoleProbe.cs').exists())
                self.assertTrue((root / 'preparation-failure-private.json').exists())
                self.assertFalse((root / 'case-contract-private.json').exists())
                with self.assertRaises(FileExistsError):
                    candidate.prepare_host(h)

    def test_collector_rejects_old_preflight_bad_exit_or_extra_marker(self):
        h = self.host
        receipt, active, pins = fixtures.NativeRoleExecutorTests().receipt_fixture()
        receipt['proof']['root_birth'] = 100
        with tempfile.TemporaryDirectory() as directory, patch.object(h, 'ROOT', Path(directory)), \
             patch.object(h, 'frozen', return_value=({'manifest': {**active, 'runtime_authorized': False}}, pins)), \
             patch.object(h, 'launch_chain', return_value={}), \
             patch.object(h.observation, 'observe', return_value={'rows': []}):
            output = Path(directory) / 'output';output.mkdir()
            def write(name, value):
                (output / name).write_text(json.dumps(value), encoding='utf-8')
            preflight = {'kind': 'native-cmake-vc-preflight', 'nonce': active['nonce'],
                'username': 'WDAGUtilityAccount', 'file_denials': 270, 'directory_denials': 15,
                'output_canary_write_read_delete': True, 'network_no_active_adapter': True,
                'SDK_starts': 0, 'G2': False}
            write('guest-preflight.json', preflight);write('result.json', receipt)
            exe = active['executable']
            rows = [{'operation': 'root_create_attempt', 'utc': '2026-11-05T00:00:00Z'},
                    {'operation': 'process_image_check', 'pid': 10, 'birth': 100, 'observed_image': exe}]
            for exited in (False, True):
                rows.append({'utc': '2026-11-05T00:00:01Z', 'members': [
                    {'pid': 10, 'birth': 100, 'image': exe, 'exited': exited}],
                    'endpoints': [], 'udp_destination': 'UNKNOWN', 'sampling_non_atomic': True})
            (output / 'samples.jsonl').write_text('\n'.join(map(json.dumps, rows)) + '\n', encoding='utf-8')
            (output / 'tool.stdout').write_bytes(b'cmake version 3.22.1\n')
            (output / 'tool.stderr').write_bytes(b'')
            self.assertEqual(h.collect()['status'], 'CMAKE_VC_VERSION_SAMPLED_LIFECYCLE_SUPPORTED')
            write('guest-preflight.json', {**preflight, 'file_denials': 252})
            with self.assertRaises(ValueError):
                h.collect()
            write('guest-preflight.json', preflight)
            receipt['proof']['root_exit'] = 0xc0000135;write('result.json', receipt)
            with self.assertRaises(ValueError):
                h.collect()
            receipt['proof']['root_exit'] = 0;write('result.json', receipt)
            (output / 'guest-wrapper-failure.json').write_text('{}')
            with self.assertRaises(ValueError):
                h.collect()

    def test_previous_scope_grant_is_rejected_and_launch_window_cannot_renew(self):
        h = self.host
        with tempfile.TemporaryDirectory() as directory, patch.object(h, 'ROOT', Path(directory)):
            h.write_once(Path(directory) / 'case-contract-private.json', {'fixture': True})
            old = {**h.authority_fields(), 'owner_reply': 'SYNTHETIC_NO_AUTHORITY',
                   'scope': 'v1015-native-cmake-version-qualification-20261105'}
            h.write_once(Path(directory) / 'owner-explicit-grant-private.json', old)
            with self.assertRaises(ValueError):
                h.grant_record()
        start = datetime(2026, 11, 5, tzinfo=timezone.utc)
        origin = {'monotonic': 1000.0, 'utc': start.isoformat()}
        self.assertEqual(h.remaining_window(origin, 1179.0, start + timedelta(seconds=100)), 1)
        with self.assertRaises(TimeoutError):
            h.remaining_window(origin, 1180.0, start + timedelta(seconds=180))

    def test_compile_time_source_or_compiler_drift_rejected_before_contract(self):
        for drift in ('source', 'compiler'):
            with self.subTest(drift=drift), tempfile.TemporaryDirectory() as directory:
                h = self.host;root = Path(directory) / 'candidate';pins = fixtures.fixture_pins()
                compiler = Path(directory) / 'fixture-csc';compiler.write_bytes(b'synthetic compiler')
                mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                            for role, guest in h.core.ROOTS.items()}
                state = {'source': 'a' * 64, 'compiler': 'b' * 64}
                def fake_compile(*args, **kwargs):
                    (root / 'probe/NativeRoleProbe.exe').write_bytes(b'synthetic not executable')
                    state[drift] = 'c' * 64
                    return SimpleNamespace(returncode=0, stdout=b'', stderr=b'')
                with patch.object(h, 'ROOT', root), patch.object(h, 'readset', return_value=({}, pins, mappings)), \
                     patch.object(h, 'sources', side_effect=lambda: {'source': state['source']}), \
                     patch.object(h, 'compiler_pin', side_effect=lambda: (compiler, state['compiler'])), \
                     patch.object(h.subprocess, 'run', side_effect=fake_compile):
                    with self.assertRaises(ValueError):
                        candidate.prepare_host(h)
                    self.assertFalse((root / 'case-contract-private.json').exists())
                    self.assertTrue((root / 'preparation-failure-private.json').exists())

    def test_failure_after_contract_blocks_frozen_and_explicit_launch_permanently(self):
        h = self.host
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory) / 'candidate';pins = fixtures.fixture_pins()
            compiler = Path(directory) / 'fixture-csc';compiler.write_bytes(b'synthetic compiler')
            mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                        for role, guest in h.core.ROOTS.items()}
            def fake_compile(*args, **kwargs):
                (root / 'probe/NativeRoleProbe.exe').write_bytes(b'synthetic not executable')
                return SimpleNamespace(returncode=0, stdout=b'', stderr=b'')
            with patch.object(h, 'ROOT', root), patch.object(h, 'readset', return_value=({}, pins, mappings)), \
                 patch.object(h, 'compiler_pin', return_value=(compiler, 'b' * 64)), \
                 patch.object(h.subprocess, 'run', side_effect=fake_compile):
                with patch.object(h, 'frozen', side_effect=ValueError('late freeze failed')):
                    with self.assertRaises(ValueError):
                        candidate.prepare_host(h)
                self.assertTrue((root / 'case-contract-private.json').exists())
                with self.assertRaises(ValueError):
                    h.frozen()
                with patch.object(h, 'grant_record', side_effect=AssertionError('must stop before grant')):
                    with self.assertRaises(ValueError):
                        h.launch(new_scope_authorized=True, owner_reference='synthetic-no-authority')


if __name__ == '__main__':
    unittest.main()
