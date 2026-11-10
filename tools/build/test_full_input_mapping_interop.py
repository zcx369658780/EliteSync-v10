import base64
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import full_input_mapping_interop as interop
import test_sandbox_host_observation as host_fixtures
import test_sandbox_owned_session_cleanup as identity_fixtures


def write_once(path, value):
    with path.open('x', encoding='utf-8') as stream:
        json.dump(value, stream)


class WholeHostInteropTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'output').mkdir()
        (self.root / 'output/result.json').write_text('{"failure":null}', encoding='utf-8')
        self.base = SimpleNamespace(_write_once=write_once)
        fixture = identity_fixtures.OwnedSessionTests(methodName='test_exact_owned_pair_only_renders_held_handle_termination')
        fixture.setUp()
        self.launch = fixture.launch
        self.rows = fixture.rows
        self.rows[0]['CommandLine'] = 'session.exe "' + str(self.root / 'qualification.wsb') + '"'
        encoded = base64.b64encode(json.dumps(self.rows).encode()).decode('ascii')
        self.cim_stub = r'''
$script:cimRows = @([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('__ROWS__')) | ConvertFrom-Json)
foreach($row in $script:cimRows) {
 $row.CreationDate = [datetime]$row.CreationDate
 $row | Add-Member NoteProperty CimClass @{Nested=@{Nested=@{Nested=@{Nested=@{Nested='deep'}}}}}
}
function Get-CimInstance {param($ClassName,$Filter,$ErrorAction)
 if($Filter -eq 'ProcessId=102'){return $script:cimRows[0]}
 if($Filter -eq 'ProcessId=103'){return $script:cimRows[1]}
 return $script:cimRows
}
'''.replace('__ROWS__', encoded)

    def observed_pair(self):
        result = host_fixtures.run_ps(self.cim_stub + interop.observation.snapshot_command())
        self.assertEqual(result.returncode, 0, result.stderr.decode(errors='replace'))
        return {'rows': interop.observation.parse_snapshot(result.stdout), 'stdout': result.stdout,
                'stderr': result.stderr, 'exit_code': result.returncode}

    def stub_closer(self, script, timeout):
        fixture = host_fixtures.CleanupInteropTests(methodName='test_corrected_template_runs_end_to_end_against_stubbed_processes_only')
        prefix = fixture.stub() + self.cim_stub
        assertions = "\nif($script:stops.Count -ne 2){throw 'Wrong stub cleanup count'};[Console]::Write('STUB_CLEANUP_OK')\n"
        result = host_fixtures.run_ps(prefix + script.read_text(encoding='utf-8') + assertions)
        self.assertEqual(result.returncode, 0, (result.stdout + result.stderr).decode(errors='replace'))
        self.assertEqual(result.stdout, b'STUB_CLEANUP_OK')
        return result

    def test_actual_powershell_projection_cleanup_and_collection_form_one_host_path(self):
        events = []
        pair = self.observed_pair()
        replies = [pair, {'rows': [], 'stdout': b'[]', 'stderr': b'', 'exit_code': 0}]
        def observer(**kwargs):
            events.append('observe'); return replies.pop(0)
        def closer(script, timeout):
            events.append('close'); return self.stub_closer(script, timeout)
        def collector(deadline):
            events.append('collect'); return {'status': 'HOST_STUB_COLLECTION_ONLY'}
        result = interop.collect_lifecycle(self.base, {}, self.launch, root=self.root,
            observer=observer, closer=closer, collector=collector, deadline=interop.time.monotonic() + 30)
        self.assertEqual(result['status'], 'HOST_STUB_COLLECTION_ONLY')
        self.assertEqual(events, ['observe', 'close', 'observe', 'collect'])

    def test_already_empty_host_skips_termination(self):
        closer = lambda *args: self.fail('empty host must not terminate anything')
        result = interop.collect_lifecycle(self.base, {}, self.launch, root=self.root,
            observer=lambda **kwargs: {'rows': [], 'stdout': b'[]', 'stderr': b'', 'exit_code': 0},
            closer=closer, collector=lambda deadline: 'collected', deadline=interop.time.monotonic() + 15)
        self.assertEqual(result, 'collected')

    def test_failed_guest_is_not_promoted_but_owned_cleanup_still_precedes_rejection(self):
        (self.root / 'output/result.json').write_text('{"failure":"guest failed"}', encoding='utf-8')
        replies = [self.observed_pair(), {'rows': [], 'stdout': b'[]', 'stderr': b'', 'exit_code': 0}]
        closed = []
        def closer(script, timeout): closed.append(True); return self.stub_closer(script, timeout)
        def collector(deadline): raise ValueError('strict guest collection rejects failure')
        with self.assertRaisesRegex(ValueError, 'rejects failure'):
            interop.collect_lifecycle(self.base, {}, self.launch, root=self.root,
                observer=lambda **kwargs: replies.pop(0), closer=closer, collector=collector,
                deadline=interop.time.monotonic() + 30)
        self.assertEqual(closed, [True])

    def test_observation_failure_never_reaches_termination_or_collection(self):
        def bad(**kwargs): raise ValueError('unclean observation')
        with self.assertRaises(ValueError):
            interop.collect_lifecycle(self.base, {}, self.launch, root=self.root, observer=bad,
                closer=lambda *args: self.fail('no ownership proof'), collector=lambda *args: self.fail('no observation proof'),
                deadline=interop.time.monotonic() + 10)

    def test_concurrent_frontend_is_never_terminated(self):
        rows = self.observed_pair()['rows'] + [{'Name': 'WindowsSandboxClient.exe', 'ProcessId': 104}]
        with patch.object(interop.time, 'monotonic', side_effect=[0, 0, 11]):
            with self.assertRaises(TimeoutError):
                interop.collect_lifecycle(self.base, {}, self.launch, root=self.root,
                    observer=lambda **kwargs: {'rows': rows, 'stdout': b'[]', 'stderr': b''},
                    closer=lambda *args: self.fail('concurrent frontend must not be closed'),
                    collector=lambda *args: self.fail('concurrent frontend is not exited'), deadline=10)


class CandidatePolicyTests(unittest.TestCase):
    def test_ordinary_continue_or_integer_cannot_reach_frozen_or_launch(self):
        for authority, reference in [(False, 'continue'), (1, 'continue'), (True, ''), (None, 'owner')]:
            with self.subTest(authority=authority), patch.object(interop, 'frozen') as frozen:
                with self.assertRaises(ValueError): interop.launch(new_scope_authorized=authority, owner_reference=reference)
                frozen.assert_not_called()

    def test_source_generation_only_changes_guest_scope_and_never_executes(self):
        generated = interop.expected_sources()
        for name in ['full_input_mapping_probe.py', 'full_input_mapping_probe.cs']:
            original = (interop.HERE / name).read_bytes()
            self.assertEqual(generated[name].replace(interop.SCOPE.encode(), interop.consumed.OLD_SCOPE.encode(), 1), original)
        self.assertEqual(set(generated), {'full_input_mapping_probe.py', 'full_input_mapping_probe.cs', *interop.consumed.HELPERS})

    def test_corrupt_generated_closure_rejects_before_compilation(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name, raw in interop.expected_sources().items(): (root / name).write_bytes(raw)
            (root / 'full_input_mapping_probe.py').write_bytes(b'raise RuntimeError("must not execute")')
            with patch.object(interop, 'SOURCES', root), patch.object(interop, 'compile', create=True) as compiled:
                with self.assertRaises(ValueError): interop.load_base()
                compiled.assert_not_called()


if __name__ == '__main__':
    unittest.main()
