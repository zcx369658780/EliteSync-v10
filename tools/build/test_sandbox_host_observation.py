import base64
import subprocess
from types import SimpleNamespace
import unittest
from unittest.mock import patch

import sandbox_host_observation as observation
import test_sandbox_owned_session_cleanup as cleanup_fixtures


def run_ps(source):
    encoded = base64.b64encode(source.encode('utf-16-le')).decode('ascii')
    return subprocess.run(['pwsh', '-NoProfile', '-NonInteractive', '-EncodedCommand', encoded],
                          capture_output=True, timeout=15)


class SnapshotTests(unittest.TestCase):
    def test_noise_null_scalar_bad_fields_and_duplicate_ids_rejected(self):
        for raw in [b'', b'WARNING: truncated\n[]', b'null', b'{}', b'[{}]', b'\xff']:
            with self.subTest(raw=raw), self.assertRaises(ValueError): observation.parse_snapshot(raw)
        self.assertEqual(observation.parse_snapshot(b'[]'), [])

    def test_observation_error_is_not_an_empty_snapshot(self):
        with patch.object(observation.subprocess, 'run', return_value=SimpleNamespace(returncode=1, stdout=b'', stderr=b'failed')):
            with self.assertRaises(ValueError): observation.observe()
        for value in [True, 0, float('nan')]:
            with self.assertRaises(ValueError): observation.observe(timeout_seconds=value)

    def test_zero_one_two_rows_are_json_arrays_without_cim_metadata_warnings(self):
        for count in [0, 1, 2]:
            stub = r'''function Get-CimInstance {
param($ClassName,$Filter,$ErrorAction)
for($number=0;$number -lt __COUNT__;$number++) {
 [pscustomobject]@{ProcessId=(102+$number);ParentProcessId=101;Name='WindowsSandboxRemoteSession.exe';
 CreationDate=[datetime]'2026-11-04T00:00:00Z';ExecutablePath='C:\Package\WindowsSandboxRemoteSession.exe';
 CommandLine='session.exe test';CimClass=@{Nested=@{Nested=@{Nested=@{Nested=@{Nested='deep'}}}}}}
}
}
'''.replace('__COUNT__', str(count))
            result = run_ps(stub + observation.snapshot_command())
            with self.subTest(count=count):
                self.assertEqual(result.returncode, 0, result.stderr.decode(errors='replace'))
                self.assertEqual(len(observation.parse_snapshot(result.stdout)), count)
                self.assertNotIn(b'CimClass', result.stdout)
                self.assertNotIn(b'WARNING', result.stdout)


class CleanupInteropTests(unittest.TestCase):
    def fixture(self):
        # Reuse data construction only; do not import its test class into this
        # module's discovery namespace or execute any real process command.
        fixture = cleanup_fixtures.OwnedSessionTests(methodName='test_exact_owned_pair_only_renders_held_handle_termination')
        fixture.setUp()
        return fixture

    def stub(self):
        return r'''$script:stops = [Collections.Generic.List[int]]::new()
$script:session = [pscustomobject]@{Id=102;StartTime=[datetime]'2026-11-04T00:00:00.1Z';Handle=[intptr]1;HasExited=$false}
$script:server = [pscustomobject]@{Id=103;StartTime=[datetime]'2026-11-04T00:00:00.2Z';Handle=[intptr]2;HasExited=$false}
foreach($item in @($script:session,$script:server)) {$item | Add-Member ScriptMethod WaitForExit {param($timeout) return $this.HasExited}}
function Get-Process {param($Name,$Id,$ErrorAction)
 if($Id -eq 102){return $script:session};if($Id -eq 103){return $script:server}
 foreach($item in @($script:session,$script:server)){if(-not $item.HasExited){$item}}
}
function Get-CimInstance {param($ClassName,$Filter)
 $number = if($Filter -eq 'ProcessId=102'){102}else{103}
 if($number -eq 102){[pscustomobject]@{ExecutablePath='C:\Package\WindowsSandboxRemoteSession.exe';CommandLine='session.exe "C:\Owned\Task\qualification.wsb"';CreationDate=[datetime]'2026-11-04T00:00:00.1Z'}}
 else {[pscustomobject]@{ExecutablePath='C:\Package\WindowsSandboxServer.exe';CommandLine='server.exe session';CreationDate=[datetime]'2026-11-04T00:00:00.2Z'}}
}
function Stop-Process {param($InputObject) $script:stops.Add($InputObject.Id);$InputObject.HasExited=$true}
'''

    def test_original_template_fails_before_any_stub_termination(self):
        f = self.fixture()
        command = observation.original_cleanup.render_cleanup(f.launch, f.recorded, f.rows, f.config)
        result = run_ps(self.stub() + '\ntry {\n' + command + "\n} catch { [Console]::Write('STUB_STOPS=' + $script:stops.Count); throw }\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b'STUB_STOPS=0')
        self.assertIn(b'Null', result.stderr + result.stdout)

    def test_corrected_template_runs_end_to_end_against_stubbed_processes_only(self):
        f = self.fixture()
        command = observation.render_corrected_cleanup(f.launch, f.recorded, f.rows, f.config)
        assertions = r'''
if($script:stops.Count -ne 2 -or $script:stops[0] -ne 102 -or $script:stops[1] -ne 103){throw 'Wrong stub termination sequence'}
[Console]::Write('STUB_CLEANUP_OK')
'''
        result = run_ps(self.stub() + command + assertions)
        self.assertEqual(result.returncode, 0, (result.stderr + result.stdout).decode(errors='replace'))
        self.assertEqual(result.stdout, b'STUB_CLEANUP_OK')


if __name__ == '__main__':
    unittest.main()
