import importlib.util
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
import types
import sys
import zipfile
from unittest.mock import Mock, patch


# Process-local test isolation only; never changes Windows/network policy.
# Mocked calls produce no audit events. Any accidental real execution/network
# escape fails this suite even if the code under test catches the exception.
FORBIDDEN_AUDIT_EVENTS = []


def forbid_runtime_access(event, arguments):
    if (event in {'subprocess.Popen', 'os.system', 'ctypes.dlopen'} or
            event.startswith(('socket.', 'os.exec', 'os.spawn', 'os.startfile'))):
        FORBIDDEN_AUDIT_EVENTS.append(event)
        raise PermissionError('TEST_RUNTIME_ACCESS_FORBIDDEN:' + event)


sys.addaudithook(forbid_runtime_access)


def tearDownModule():
    if FORBIDDEN_AUDIT_EVENTS:
        raise AssertionError('REAL_RUNTIME_ACCESS_ATTEMPTED:' + repr(FORBIDDEN_AUDIT_EVENTS))
    print('ISOLATION: real process/socket/native-DLL audit events = 0; '
          'lifecycle observer/Popen/taskkill are fully mocked')

SPEC = importlib.util.spec_from_file_location('offline_debug', Path(__file__).with_name('offline_debug.py'))
entry = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(entry)


class PreflightTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        self.manifest = self.root / 'manifest.json'
        self.config = {
            'schema': 1, 'gradleVersion': '8.14', 'workRoot': str(self.root),
            'roots': {key: str(self.root / key) for key in entry.ROOT_NAMES},
            'inventory': [], 'definitions': [],
        }
        for key, value in self.config['roots'].items():
            base = Path(value)
            base.mkdir()
            p = base / ('bin/gradle.bat' if key == 'gradle' else 'fixture')
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_bytes(b'known cached bytes')
            self.config['inventory'].append({'root': key, 'path': p.relative_to(base).as_posix(), 'sha256': entry.sha256(p)})

    def save(self):
        self.manifest.write_text(json.dumps(self.config), encoding='utf-8')
        return entry.sha256(self.manifest)

    def rejected_without_spawn(self, reason):
        expected = self.save()
        with patch.object(entry.subprocess, 'Popen', side_effect=AssertionError('must not spawn')) as spawn:
            with self.assertRaisesRegex(entry.PreflightError, reason):
                entry.preflight(self.manifest, expected)
            spawn.assert_not_called()

    def test_manifest_identity_mismatch_never_spawns(self):
        self.save()
        with patch.object(entry.subprocess, 'Popen') as spawn:
            with self.assertRaisesRegex(entry.PreflightError, 'MANIFEST_HASH'):
                entry.preflight(self.manifest, '0' * 64)
            spawn.assert_not_called()

    def test_missing_dependency_never_spawns(self):
        Path(self.config['roots']['pub'], 'fixture').unlink()
        self.rejected_without_spawn('MISSING_FILE')

    def test_dependency_hash_mismatch_never_spawns(self):
        Path(self.config['roots']['cache'], 'fixture').write_bytes(b'corrupt')
        self.rejected_without_spawn('FILE_HASH')

    def test_wrong_gradle_version_never_spawns(self):
        self.config['gradleVersion'] = '9.3.1'
        self.rejected_without_spawn('GRADLE_VERSION')

    def test_inventory_cannot_escape_root(self):
        next(x for x in self.config['inventory'] if x['root'] == 'pub')['path'] = '../outside'
        self.rejected_without_spawn('RELATIVE_PATH')

    def test_shell_metacharacter_path_rejected(self):
        self.config['roots']['gradle'] += '&other'
        self.rejected_without_spawn('UNSAFE_PATH')

    def test_caret_path_rejected_without_spawn(self):
        self.config['roots']['gradle'] += '^other'
        self.rejected_without_spawn('UNSAFE_PATH')

    def test_missing_root_scope_never_spawns(self):
        del self.config['roots']['cache']
        self.rejected_without_spawn('ROOT_SCOPES')

    def test_empty_dependency_inventory_never_spawns(self):
        self.config['inventory'] = [x for x in self.config['inventory'] if x['root'] != 'cache']
        self.rejected_without_spawn('EMPTY_SCOPE')

    def test_wrapper_alias_cannot_replace_pinned_bin(self):
        next(x for x in self.config['inventory'] if x['root'] == 'gradle')['path'] = 'gradlew.bat'
        self.rejected_without_spawn('GRADLE_BIN')

    def test_external_tcp_is_violation_loopback_is_allowed(self):
        self.assertFalse(entry.external_tcp('127.0.0.1'))
        self.assertFalse(entry.external_tcp('::1'))
        self.assertTrue(entry.external_tcp('203.0.113.1'))

    def test_valid_attested_inventory_is_read_only(self):
        core = Path(self.config['roots']['gradle'], 'lib/gradle-core-8.14.jar')
        core.parent.mkdir(); core.write_bytes(b'fixture runtime')
        self.config['inventory'].append({'root': 'gradle', 'path': 'lib/gradle-core-8.14.jar', 'sha256': entry.sha256(core)})
        receipt = core.with_name('gradle-base-services-8.14.jar')
        with zipfile.ZipFile(receipt, 'w') as archive:
            archive.writestr('org/gradle/build-receipt.properties', 'versionNumber=8.14\n')
        self.config['inventory'].append({'root': 'gradle', 'path': 'lib/gradle-base-services-8.14.jar', 'sha256': entry.sha256(receipt)})
        self.config['knownCompleteCacheProvenance'] = 'Unit fixture, not a real runtime'
        expected = self.save()
        pin = entry.sha256(Path(self.config['roots']['gradle'], 'bin/gradle.bat'))
        with patch.object(entry, 'PINNED_BIN', pin), patch.object(entry.subprocess, 'Popen') as spawn:
            config, roots, work = entry.preflight(self.manifest, expected)
            self.assertEqual(work, self.root)
            self.assertEqual(set(roots), entry.ROOT_NAMES)
            spawn.assert_not_called()

    def test_changed_build_definition_never_spawns(self):
        self.config['definitions'] = [{'path': 'fixture', 'sha256': '0' * 64}]
        self.rejected_without_spawn('DEFINITION_CHANGED')

    def test_download_in_final_log_rejects_zero_exit(self):
        for log in ['Downloading https://example.invalid/gradle.zip', 'Downloading packages...']:
            self.assertFalse(entry.accepted_exit(0, None, log))
        self.assertTrue(entry.accepted_exit(0, None, 'BUILD SUCCESSFUL'))

    def test_execute_missing_cache_rejects_before_observer_or_child(self):
        Path(self.config['roots']['pub'], 'fixture').unlink()
        expected = self.save()
        observer = Mock(side_effect=AssertionError('must not observe'))
        with patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=observer)}), \
                patch.object(entry.subprocess, 'Popen') as spawn:
            with self.assertRaisesRegex(entry.PreflightError, 'MISSING_FILE'):
                entry.execute(self.manifest, expected, self.root / 'unused-receipt')
            observer.assert_not_called()
            spawn.assert_not_called()

    def test_execute_wrong_manifest_rejects_before_observer_or_child(self):
        self.save()
        observer = Mock(side_effect=AssertionError('must not observe'))
        with patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=observer)}), \
                patch.object(entry.subprocess, 'Popen') as spawn:
            with self.assertRaisesRegex(entry.PreflightError, 'MANIFEST_HASH'):
                entry.execute(self.manifest, '0' * 64, self.root / 'unused-receipt')
            observer.assert_not_called()
            spawn.assert_not_called()

    @unittest.skipUnless(sys.platform == 'win32', 'Windows entry lifecycle')
    def test_zero_exit_without_apk_records_started_build_failure(self):
        roots = {k: Path(v) for k, v in self.config['roots'].items()}
        self.config['knownCompleteCacheProvenance'] = 'unit lifecycle fixture'
        fake = types.SimpleNamespace(pid=1234, poll=lambda: 0, wait=lambda **_: 0)
        observed = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        module = types.SimpleNamespace(Observer=lambda: observed)
        with patch.object(entry, 'preflight', return_value=(self.config, roots, self.root)), \
                patch.object(entry.subprocess, 'Popen', return_value=fake), \
                patch.object(entry.subprocess, 'run') as stop, \
                patch.dict(sys.modules, {'windows_build_observer': module}):
            code = entry.execute(self.manifest, '0' * 64, self.root / 'receipt')
            stop.assert_not_called()
        result = json.loads((self.root / 'receipt/result.json').read_text())
        self.assertEqual(code, 90)
        self.assertEqual(result['buildProcessesStarted'], 1)
        self.assertEqual(result['stopReason'], 'BUILD_ARTIFACT_MISSING')


class ObservationClassificationTests(unittest.TestCase):
    def test_udp_endpoint_does_not_prove_datagram_or_destination(self):
        reason = entry.observation_stop_reason([{'protocol': 'UDP', 'remote': None}], '')
        self.assertEqual(reason, 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE')
        self.assertNotIn('ATTEMPT', reason)

    def test_tcp_socket_state_does_not_prove_payload_transfer(self):
        for state in [3, 5, 8]:
            with self.subTest(state=state):
                reason = entry.observation_stop_reason([
                    {'protocol': 'TCP', 'remote': '203.0.113.1', 'state': state}], '')
                self.assertEqual(reason, 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED')
                self.assertNotIn('ATTEMPT', reason)

    def test_loopback_tcp_ipc_remains_allowed(self):
        for address in ['127.0.0.1', '127.0.0.2', '::1']:
            with self.subTest(address=address):
                self.assertIsNone(entry.observation_stop_reason([
                    {'protocol': 'TCP', 'remote': address}], ''))

    def test_explicit_download_logs_remain_stop_signals(self):
        for log in ['Downloading https://example.invalid/gradle.zip',
                    'Fetching packages...', 'Could not GET https://example.invalid/x']:
            with self.subTest(log=log):
                self.assertEqual(entry.observation_stop_reason([], log), 'DOWNLOAD_ATTEMPT_OBSERVED')

    def test_no_observed_signal_is_not_absolute_network_proof(self):
        self.assertIsNone(entry.observation_stop_reason([], 'BUILD SUCCESSFUL'))
        self.assertIsNone(entry.observation_stop_reason([], ''))

    def test_observer_failure_is_never_a_safe_sample(self):
        self.assertEqual(entry.observation_stop_reason([], '', observer_failed=True), 'OBSERVER_FAILED')

    def test_malformed_socket_is_fail_closed(self):
        for socket in [{'protocol': 'TCP', 'remote': None}, {'protocol': 'UNKNOWN'}, {}]:
            with self.subTest(socket=socket):
                self.assertEqual(entry.observation_stop_reason([socket], ''), 'OBSERVER_FAILED')

    def test_endpoint_still_stops_when_loopback_is_also_present(self):
        sockets = [{'protocol': 'TCP', 'remote': '::1'}, {'protocol': 'UDP', 'remote': None}]
        self.assertEqual(entry.observation_stop_reason(sockets, ''), 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE')

    def test_authorized_udp_policy_records_signal_without_stopping(self):
        signal = entry.observation_stop_reason([{'protocol': 'UDP', 'remote': None}], '')
        self.assertEqual(signal, 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE')
        self.assertIsNone(entry.policy_stop_reason(signal, single_attempt_authorized=True))
        self.assertEqual(entry.policy_stop_reason(signal), signal)

    def test_udp_cannot_hide_non_loopback_tcp(self):
        sockets = [{'protocol': 'UDP', 'remote': None}, {'protocol': 'TCP', 'remote': '203.0.113.1'}]
        signal = entry.observation_stop_reason(sockets, '')
        self.assertEqual(signal, 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED')
        self.assertEqual(entry.policy_stop_reason(signal, single_attempt_authorized=True), signal)

    def test_udp_cannot_hide_download_log(self):
        signal = entry.observation_stop_reason([{'protocol': 'UDP', 'remote': None}], 'Downloading https://example.invalid/tool.zip')
        self.assertEqual(signal, 'DOWNLOAD_ATTEMPT_OBSERVED')
        self.assertEqual(entry.policy_stop_reason(signal, single_attempt_authorized=True), signal)

    def test_invalid_udp_row_still_fails_closed(self):
        self.assertEqual(entry.observation_stop_reason([{'protocol': 'UDP'}], ''), 'OBSERVER_FAILED')

    def test_unknown_policy_signal_fails_closed(self):
        self.assertEqual(entry.policy_stop_reason('UNRECOGNIZED', single_attempt_authorized=True), 'OBSERVER_FAILED')


@unittest.skipUnless(sys.platform == 'win32', 'Windows entry lifecycle; all runtime collaborators mocked')
class MockLifecycleTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        self.roots = {name: self.root / name for name in entry.ROOT_NAMES}
        for path in self.roots.values():
            path.mkdir()
        self.config = {'knownCompleteCacheProvenance': 'isolated lifecycle fixture, no real runtime'}

    def run_case(self, sockets=None, error=None, at_exit=False, log='', capability_error=None, authorized=False):
        if authorized:
            self.config['singleAttemptAuthorization'] = {
                'taskBlob': entry.SINGLE_ATTEMPT_TASK_BLOB, 'maxStarts': 1, 'testsExit': 0, 'staticExit': 0}
        process = Mock(pid=1234)
        continue_udp = authorized and sockets == [{'protocol': 'UDP', 'remote': None}] and not log
        process.poll.side_effect = [0] if at_exit else [None, 0 if isinstance(error, ProcessLookupError) or continue_udp else None]
        process.wait.return_value = 0
        samples = [capability_error or ([], []), error or ([], sockets or [])]
        observer = types.SimpleNamespace(known={1234}, sample=Mock(side_effect=samples))
        factory = Mock(return_value=observer)
        module = types.SimpleNamespace(Observer=factory)

        def fake_spawn(*args, **kwargs):
            kwargs['stdout'].write(log.encode('utf-8'))
            kwargs['stdout'].flush()
            return process

        with patch.object(entry, 'preflight', return_value=(self.config, self.roots, self.root)), \
                patch.object(entry.subprocess, 'Popen', side_effect=fake_spawn) as spawn, \
                patch.object(entry.subprocess, 'run', return_value=types.SimpleNamespace(stdout=b'', stderr=b'')) as stop, \
                patch.object(entry.time, 'sleep') as sleep, \
                patch.dict(sys.modules, {'windows_build_observer': module}):
            if capability_error:
                with self.assertRaisesRegex(entry.PreflightError, 'OBSERVER_FAILED'):
                    entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'receipt')
                spawn.assert_not_called()
                stop.assert_not_called()
                return
            code = entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'receipt', single_attempt_authorized=authorized)
        result = json.loads((self.root / 'receipt/result.json').read_text())
        self.assertEqual(code, 90)
        spawn.assert_called_once()
        process.wait.assert_called_once_with(timeout=30)
        self.assertEqual(result['buildProcessesStarted'], 1)  # one MOCK child, not a real process
        self.assertEqual(result['stage'], 'BUILD_FAILED_OR_STOPPED')
        self.assertEqual(result['networkClaim'], 'SAMPLED_TASK_TCP_UDP_ONLY_ABSOLUTE_NO_NETWORK_NOT_PROVEN')
        self.assertFalse((self.roots['project'] / 'apps/android/app/build/outputs/apk/debug/app-debug.apk').exists())
        return result, stop, sleep

    def test_udp_stops_once_without_retry(self):
        result, stop, sleep = self.run_case([{'protocol': 'UDP', 'remote': None}])
        self.assertEqual(result['stopReason'], 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE')
        stop.assert_called_once_with(['taskkill', '/PID', '1234', '/T', '/F'], capture_output=True)
        sleep.assert_not_called()

    def test_non_loopback_tcp_stops_once_without_retry(self):
        result, stop, sleep = self.run_case([{'protocol': 'TCP', 'remote': '203.0.113.1', 'state': 3}])
        self.assertEqual(result['stopReason'], 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED')
        stop.assert_called_once()
        sleep.assert_not_called()

    def test_observer_read_failure_stops_once(self):
        result, stop, sleep = self.run_case(error=OSError('synthetic network table read failure'))
        self.assertEqual(result['stopReason'], 'OBSERVER_FAILED')
        stop.assert_called_once()
        sleep.assert_not_called()

    def test_missing_root_is_failure_even_if_mock_child_has_exited(self):
        result, stop, sleep = self.run_case(error=ProcessLookupError('ROOT_PROCESS_NOT_OBSERVABLE'))
        self.assertEqual(result['stopReason'], 'OBSERVER_FAILED')
        stop.assert_not_called()
        sleep.assert_not_called()

    def test_capability_failure_rejects_before_mock_child(self):
        self.run_case(capability_error=OSError('synthetic capability failure'))

    def test_download_in_final_log_keeps_fail_closed_after_child_exit(self):
        result, stop, sleep = self.run_case(at_exit=True, log='Downloading https://example.invalid/tool.zip')
        self.assertEqual(result['stopReason'], 'DOWNLOAD_ATTEMPT_OBSERVED')
        stop.assert_not_called()
        sleep.assert_not_called()

    def test_authorized_udp_is_recorded_and_mock_child_continues(self):
        result, stop, sleep = self.run_case([{'protocol': 'UDP', 'remote': None}], authorized=True)
        self.assertEqual(result['stopReason'], 'BUILD_ARTIFACT_MISSING')  # mock exits, no APK is fabricated
        self.assertEqual(result['samplesWithUdpEndpoints'], 1)
        self.assertEqual(result['udpEndpointObservations'], 1)
        observations = [json.loads(x) for x in (self.root / 'receipt/process-network-private.jsonl').read_text().splitlines()]
        self.assertEqual(observations[0]['classification'], 'UDP_ENDPOINT_OBSERVED_REMOTE_UNAVAILABLE')
        self.assertIsNone(observations[0]['stopReason'])
        self.assertTrue((self.root / entry.SINGLE_ATTEMPT_MARKER).is_file())
        stop.assert_not_called()
        sleep.assert_called_once_with(.1)

    def test_authorized_udp_plus_tcp_stops_once_without_retry(self):
        result, stop, sleep = self.run_case([
            {'protocol': 'UDP', 'remote': None}, {'protocol': 'TCP', 'remote': '203.0.113.1'}], authorized=True)
        self.assertEqual(result['stopReason'], 'NON_LOOPBACK_TCP_ENDPOINT_OBSERVED')
        stop.assert_called_once()
        sleep.assert_not_called()

    def test_authorized_udp_plus_download_stops_once_without_retry(self):
        result, stop, sleep = self.run_case([{'protocol': 'UDP', 'remote': None}], authorized=True,
                                           log='Downloading https://example.invalid/tool.zip')
        self.assertEqual(result['stopReason'], 'DOWNLOAD_ATTEMPT_OBSERVED')
        stop.assert_called_once()
        sleep.assert_not_called()

    def test_failed_validation_never_claims_or_starts(self):
        self.config['singleAttemptAuthorization'] = {
            'taskBlob': entry.SINGLE_ATTEMPT_TASK_BLOB, 'maxStarts': 1, 'testsExit': 1, 'staticExit': 0}
        observer = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        with patch.object(entry, 'preflight', return_value=(self.config, self.roots, self.root)), \
                patch.object(entry.subprocess, 'Popen') as spawn, patch.object(entry.subprocess, 'run') as stop, \
                patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=lambda: observer)}):
            with self.assertRaisesRegex(entry.PreflightError, 'SINGLE_BUILD_VALIDATION'):
                entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'receipt', single_attempt_authorized=True)
            spawn.assert_not_called()
            stop.assert_not_called()
        self.assertFalse((self.root / entry.SINGLE_ATTEMPT_MARKER).exists())

    def test_budget_cannot_be_claimed_twice_or_bypassed_by_default_mode(self):
        authorization = {'taskBlob': entry.SINGLE_ATTEMPT_TASK_BLOB, 'maxStarts': 1, 'testsExit': 0, 'staticExit': 0}
        entry.claim_single_build(self.root, authorization)
        with self.assertRaisesRegex(entry.PreflightError, 'SINGLE_BUILD_BUDGET_ALREADY_CLAIMED'):
            entry.claim_single_build(self.root, authorization)
        observer = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        with patch.object(entry, 'preflight', return_value=(self.config, self.roots, self.root)), \
                patch.object(entry.subprocess, 'Popen') as spawn, patch.object(entry.subprocess, 'run') as stop, \
                patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=lambda: observer)}):
            with self.assertRaisesRegex(entry.PreflightError, 'SINGLE_BUILD_BUDGET_ALREADY_CLAIMED'):
                entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'second-receipt')
            spawn.assert_not_called()
            stop.assert_not_called()

    def test_authorized_mode_rejects_preexisting_apk_before_claim(self):
        observer = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        apk = self.roots['project'] / 'apps/android/app/build/outputs/apk/debug/app-debug.apk'
        original_exists = Path.exists
        with patch.object(entry, 'preflight', return_value=(self.config, self.roots, self.root)), \
                patch.object(entry.subprocess, 'Popen') as spawn, patch.object(entry.subprocess, 'run') as stop, \
                patch.object(Path, 'exists', autospec=True, side_effect=lambda path: path == apk or original_exists(path)), \
                patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=lambda: observer)}):
            with self.assertRaisesRegex(entry.PreflightError, 'PREEXISTING_APK'):
                entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'receipt', single_attempt_authorized=True)
            spawn.assert_not_called()
            stop.assert_not_called()
        self.assertFalse(apk.exists())  # only exists() was mocked; no APK fixture generated
        self.assertFalse((self.root / entry.SINGLE_ATTEMPT_MARKER).exists())

    def test_failed_mock_spawn_retains_claim_and_blocks_second_entry(self):
        self.config['singleAttemptAuthorization'] = {
            'taskBlob': entry.SINGLE_ATTEMPT_TASK_BLOB, 'maxStarts': 1, 'testsExit': 0, 'staticExit': 0}
        observer = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        with patch.object(entry, 'preflight', return_value=(self.config, self.roots, self.root)), \
                patch.object(entry.subprocess, 'Popen', side_effect=OSError('synthetic spawn failure')) as spawn, \
                patch.object(entry.subprocess, 'run') as stop, \
                patch.dict(sys.modules, {'windows_build_observer': types.SimpleNamespace(Observer=lambda: observer)}):
            with self.assertRaisesRegex(OSError, 'synthetic spawn failure'):
                entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'first-receipt', single_attempt_authorized=True)
            self.assertTrue((self.root / entry.SINGLE_ATTEMPT_MARKER).is_file())
            with self.assertRaisesRegex(entry.PreflightError, 'SINGLE_BUILD_BUDGET_ALREADY_CLAIMED'):
                entry.execute(self.root / 'mock-manifest', '0' * 64, self.root / 'second-receipt')
            spawn.assert_called_once()
            stop.assert_not_called()


if __name__ == '__main__':
    unittest.main()
