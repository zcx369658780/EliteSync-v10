"""Synthetic host/collector integration only; never execute SDKs or a guest."""
from contextlib import ExitStack
from datetime import datetime, timedelta, timezone
import hashlib
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import cmake_version_consumer as consumer
import test_native_role_executor as core_fixture
import test_cmake_version_binding as binding_fixture


class CMakeVersionConsumerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name);self.case = self.root / 'new-case'
        self.cmake = self.root / 'CMake';(self.cmake / 'bin').mkdir(parents=True)
        fixture = binding_fixture.CMakeVersionBindingTests();fixture.setUp()
        self.pe, self.stdout = fixture.pe, fixture.stdout
        (self.cmake / 'bin/cmake.exe').write_bytes(self.pe)
        self.expected = json.dumps(fixture.derive(), sort_keys=True).encode()
        self.expected_path = self.root / 'version-expectation.json';self.expected_path.write_bytes(self.expected)
        self.expected_sha = hashlib.sha256(self.expected).hexdigest()
        self.stack = ExitStack();self.addCleanup(self.stack.close)
        for name, value in [('EXPECTATION', self.expected_path), ('EXPECTATION_SHA', self.expected_sha),
                            ('PRIVATE_CMAKE', self.cmake)]:
            self.stack.enter_context(patch.object(consumer, name, value))
        self.host = consumer.derive_host();self.stack.enter_context(patch.object(self.host, 'ROOT', self.case))
        self.pins = core_fixture.fixture_pins()
        self.pins[self.host.core._guest(*self.host.core.ROLES['cmake'][:2])] = hashlib.sha256(self.pe).hexdigest()

    def test_new_policy_binds_expectation_before_any_runtime_authority(self):
        h = self.host
        self.assertEqual(h.policy()['version_expectation_sha256'], self.expected_sha)
        self.assertEqual(h.LIMITS['input_files'], 45)
        self.assertEqual(h.policy()['readonly_preflight_file_denials'], 270)
        self.assertNotEqual(h.SCOPE, 'v1015-cmake-app-local-version-candidate-20261105')
        self.assertIn('import cmake_version_consumer as h;', consumer.derive_source().decode())
        self.assertIn(b'native-cmake-bound-version-preflight', h.guest_source(self.pins, 'a' * 32))
        self.assertIs(h.policy()['G2'], False)

    def test_immutable_base_or_wrong_expectation_rejected_before_compilation(self):
        with self.assertRaises(ValueError):
            consumer.derive_source(b'changed consumed source')
        consumer.read_expectation(self.pins)
        self.expected_path.write_bytes(self.expected + b' ')
        with self.assertRaises(ValueError):
            consumer.read_expectation(self.pins)
        self.expected_path.write_bytes(self.expected)
        bad = dict(self.pins);bad[self.host.core._guest(*self.host.core.ROLES['cmake'][:2])] = 'f' * 64
        with self.assertRaises(ValueError):
            consumer.read_expectation(bad)

    def test_default_launch_does_not_touch_frozen_case(self):
        with patch.object(self.host, 'frozen', side_effect=AssertionError('no launch')):
            for value in (False, None, 1, 'true'):
                with self.assertRaises(ValueError):
                    self.host.launch(new_scope_authorized=value, owner_reference='old')

    def fixture_output(self):
        h = self.host;output = self.case / 'output';output.mkdir(parents=True)
        receipt, _, _ = core_fixture.NativeRoleExecutorTests().receipt_fixture()
        active = {**h.core.role_plan('cmake', self.pins), 'runtime_authorized': True,
                  'nonce': 'a' * 32, 'binary_sha256': 'b' * 64}
        receipt['proof']['root_birth'] = 100
        receipt['input_files'] = len(self.pins)
        self.write('result.json', receipt)
        self.write('guest-preflight.json', {'kind': 'native-cmake-bound-version-preflight',
            'nonce': active['nonce'], 'username': 'WDAGUtilityAccount', 'file_denials': 270,
            'directory_denials': 15, 'output_canary_write_read_delete': True,
            'network_no_active_adapter': True, 'SDK_starts': 0, 'G2': False})
        exe = active['executable']
        rows = [{'operation': 'root_create_attempt', 'utc': '2026-11-05T00:00:00Z'},
                {'operation': 'process_image_check', 'pid': 10, 'birth': 100, 'observed_image': exe}]
        for exited in (False, True):
            rows.append({'utc': '2026-11-05T00:00:01Z', 'members': [
                {'pid': 10, 'birth': 100, 'image': exe, 'exited': exited}], 'endpoints': [],
                'udp_destination': 'UNKNOWN', 'sampling_non_atomic': True})
        (output / 'samples.jsonl').write_text('\n'.join(map(json.dumps, rows)) + '\n', encoding='utf-8')
        (output / 'tool.stdout').write_bytes(self.stdout);(output / 'tool.stderr').write_bytes(b'')
        return {'manifest': {**active, 'runtime_authorized': False}}, receipt

    def write(self, name, data):
        (self.case / 'output' / name).write_text(json.dumps(data), encoding='utf-8')

    def collect(self, contract):
        with patch.object(self.host, 'frozen', return_value=(contract, self.pins)), \
             patch.object(self.host, 'launch_chain', return_value={}), \
             patch.object(self.host.observation, 'observe', return_value={'rows': []}):
            return self.host.collect()

    def test_full_byte_checker_is_wired_after_process_and_log_checks(self):
        contract, receipt = self.fixture_output()
        result = self.collect(contract)
        self.assertEqual(result['status'], 'CMAKE_BOUND_VERSION_SAMPLED_LIFECYCLE_SUPPORTED')
        self.assertEqual(result['version_expectation_sha256'], self.expected_sha)
        self.assertEqual(result['version_bytes']['status'], 'OUTPUT_BYTES_MATCH_OFFLINE_EXPECTATION')
        self.assertIs(result['native_DLL_closure_proven'], False)
        self.assertFalse((self.case / 'verified-result.json').exists())
        receipt['proof']['root_exit'] = 1;self.write('result.json', receipt)
        with self.assertRaises(ValueError):
            self.collect(contract)

    def test_bare_version_extra_bytes_stderr_or_expectation_drift_rejected(self):
        contract, _ = self.fixture_output();output = self.case / 'output'
        for stdout, stderr in [(self.stdout.replace(b'-g37088a8-dirty', b''), b''),
                               (self.stdout + b'\n', b''), (self.stdout, b'warning')]:
            (output / 'tool.stdout').write_bytes(stdout);(output / 'tool.stderr').write_bytes(stderr)
            with self.assertRaises(ValueError):
                self.collect(contract)
        (output / 'tool.stdout').write_bytes(self.stdout);(output / 'tool.stderr').write_bytes(b'')
        self.expected_path.write_bytes(self.expected + b' ')
        with self.assertRaises(ValueError):
            self.collect(contract)

    def test_old_preflight_birth_mismatch_or_extra_marker_rejected(self):
        contract, receipt = self.fixture_output();output = self.case / 'output'
        raw = (output / 'guest-preflight.json').read_bytes()
        self.write('guest-preflight.json', {**json.loads(raw), 'kind': 'native-cmake-vc-preflight'})
        with self.assertRaises(ValueError):
            self.collect(contract)
        (output / 'guest-preflight.json').write_bytes(raw)
        receipt['proof']['root_birth'] = 999;self.write('result.json', receipt)
        with self.assertRaises(ValueError):
            self.collect(contract)
        receipt['proof']['root_birth'] = 100;self.write('result.json', receipt)
        (output / 'guest-watchdog.json').write_text('{}')
        with self.assertRaises(ValueError):
            self.collect(contract)

    def test_old_grant_and_elapsed_window_cannot_authorize_or_renew(self):
        h = self.host;self.case.mkdir()
        h.write_once(self.case / 'case-contract-private.json', {'synthetic': True})
        h.write_once(self.case / 'owner-explicit-grant-private.json', {**h.authority_fields(),
            'scope': 'v1015-cmake-app-local-version-candidate-20261105', 'owner_reply': 'SYNTHETIC_NO_AUTHORITY'})
        with self.assertRaises(ValueError):
            h.grant_record()
        start = datetime(2026, 11, 5, tzinfo=timezone.utc)
        origin = {'monotonic': 1000.0, 'utc': start.isoformat()}
        with self.assertRaises(TimeoutError):
            h.remaining_window(origin, 1180.0, start + timedelta(seconds=180))

    def prepare_fixture(self, *, drift=False):
        h = self.host;compiler = self.root / 'fixture-csc';compiler.write_bytes(b'synthetic compiler')
        mappings = {role: {'host': 'D:\\PrivateInputs\\' + role, 'guest': guest, 'readonly': True}
                    for role, guest in h.core.ROOTS.items()}
        def compile_fixture(*args, **kwargs):
            (self.case / 'probe/NativeRoleProbe.exe').write_bytes(b'synthetic never executed')
            if drift:
                self.expected_path.write_bytes(self.expected + b' ')
            return SimpleNamespace(returncode=0, stdout=b'', stderr=b'')
        self.stack.enter_context(patch.object(h, 'readset', return_value=({}, self.pins, mappings)))
        self.stack.enter_context(patch.object(h, 'compiler_pin', return_value=(compiler, 'b' * 64)))
        self.stack.enter_context(patch.object(h.subprocess, 'run', side_effect=compile_fixture))

    def test_preparation_contract_freezes_expectation_and_active_manifest_stays_absent(self):
        self.prepare_fixture()
        result = consumer.previous.prepare_host(self.host)
        contract, _ = self.host.frozen()
        self.assertEqual(result['status'], 'SOURCE_READY_NOT_AUTHORIZED')
        self.assertEqual(contract['version_expectation_sha256'], self.expected_sha)
        self.assertIs(contract['manifest']['runtime_authorized'], False)
        self.assertFalse((self.case / 'launch.claim.json').exists())
        self.assertFalse((self.case / 'probe/manifest.json').exists())
        with self.assertRaises(FileExistsError):
            consumer.previous.prepare_host(self.host)

    def test_expectation_drift_during_compilation_leaves_terminal_failure(self):
        self.prepare_fixture(drift=True)
        with self.assertRaises(ValueError):
            consumer.previous.prepare_host(self.host)
        self.assertTrue((self.case / 'preparation-failure-private.json').exists())
        self.expected_path.write_bytes(self.expected)
        with self.assertRaises(ValueError):
            self.host.frozen()
        with self.assertRaises(FileExistsError):
            consumer.previous.prepare_host(self.host)


if __name__ == '__main__':
    unittest.main()
