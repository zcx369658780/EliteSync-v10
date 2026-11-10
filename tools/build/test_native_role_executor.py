import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

import native_role_executor as executor


HERE = Path(__file__).resolve().parent


def fixture_pins():
    return executor.input_pins({'images': [
        {'role': role, 'relative_path': relative, 'sha256': 'a' * 64}
        for role, relative in sorted({(role, relative) for role, relative, _ in executor.ROLES.values()})]})


class NativeRoleExecutorTests(unittest.TestCase):
    def receipt_fixture(self):
        pins = fixture_pins()
        manifest = {**executor.role_plan('cmake', pins), 'runtime_authorized': True,
                    'nonce': 'a' * 32, 'binary_sha256': 'b' * 64}
        proof = dict(root_pid=10, root_exit=0, stop_reason=None, successful_samples=2,
                     bound_members=1, job_final_empty=True, all_bound_handles_exited=True,
                     sampling_non_atomic=True, udp_destination='UNKNOWN', disk_limit_sampled=True,
                     transient_disk_overshoot_possible=True, watchdog_stop=0, disk_scan_retries=0,
                     disk_scans_completed=1, disk_deleted_directory_ids=0,
                     disk_directory_open_retries=0, disk_directory_name_retries=0)
        receipt = dict(schema=1, kind='native-role-version', nonce=manifest['nonce'],
                       binary_sha256=manifest['binary_sha256'], role='cmake', failure=None,
                       input_files=len(pins), proof=proof, native_tool_root_attempts=1,
                       gradle_root_attempts=0, apk_builds=0, producer_allowed=False, G2=False,
                       full_process_or_DLL_closure_proven=False)
        return receipt, manifest, pins

    def test_good_synthetic_receipt_retains_sampling_boundary(self):
        receipt, manifest, pins = self.receipt_fixture()
        summary = executor.validate_receipt(receipt, manifest, pins)
        self.assertIs(summary['complete_process_or_DLL_closure_proven'], False)
        self.assertIs(summary['G2'], False)

    def test_outer_success_cannot_hide_STOP_bad_exit_or_incomplete_cleanup(self):
        receipt, manifest, pins = self.receipt_fixture()
        for key, value in [('root_exit', 1), ('root_exit', None), ('root_exit', False),
                           ('stop_reason', 'UNKNOWN_PROCESS_IMAGE'), ('watchdog_stop', 1),
                           ('job_final_empty', False), ('all_bound_handles_exited', False),
                           ('successful_samples', 1), ('bound_members', 99)]:
            bad = copy.deepcopy(receipt);bad['proof'][key] = value
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                executor.validate_receipt(bad, manifest, pins)

    def test_receipt_types_scope_and_manifest_authority_fail_closed(self):
        receipt, manifest, pins = self.receipt_fixture()
        for key, value in [('schema', True), ('failure', 'bootstrap failed'), ('G2', 0),
                           ('producer_allowed', True), ('input_files', True),
                           ('binary_sha256', 'c' * 64)]:
            bad = copy.deepcopy(receipt);bad[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                executor.validate_receipt(bad, manifest, pins)
        for key, value in [('runtime_authorized', False), ('runtime_authorized', 1),
                           ('command_line', 'cmd.exe'), ('producer_allowed', True)]:
            bad = copy.deepcopy(manifest);bad[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                executor.validate_receipt(receipt, bad, pins)

    def test_closed_role_set_has_no_shell_gradle_flutter_or_build_entry(self):
        pins = fixture_pins()
        self.assertEqual(len(executor.ROLES), 16)
        for role in executor.ROLES:
            plan = executor.role_plan(role, pins)
            self.assertIs(plan['runtime_authorized'], False)
            self.assertIs(plan['producer_allowed'], False)
            self.assertIs(plan['G2'], False)
            self.assertNotIn('ComSpec', plan['environment'])
            self.assertFalse(plan['executable'].lower().endswith(('.bat', '.cmd', 'powershell.exe', 'cmd.exe')))

    def test_missing_role_or_hash_drift_cannot_build_pins(self):
        with self.assertRaises(ValueError):
            executor.input_pins({'images': []})
        with self.assertRaises(ValueError):
            executor.input_pins({'images': [{'role': 'private_flutter', 'relative_path': 'bad.exe', 'sha256': 'bad'}]})

    def test_noncanonical_readset_path_or_casefold_duplicate_rejected(self):
        for relative in ('/bad.exe', 'bin//bad.exe', 'bin/../bad.exe'):
            with self.subTest(relative=relative), self.assertRaises(ValueError):
                executor.input_pins({'images': [{'role': 'private_flutter', 'relative_path': relative, 'sha256': 'a' * 64}]})
        graph = {'images': [{'role': role, 'relative_path': relative, 'sha256': 'a' * 64}
                            for role, relative in sorted({(a, b) for a, b, _ in executor.ROLES.values()})]}
        graph['images'].append({**graph['images'][0], 'relative_path': graph['images'][0]['relative_path'].upper()})
        with self.assertRaises(ValueError):
            executor.input_pins(graph)

    def test_historical_baseline_cannot_be_substituted(self):
        with self.assertRaises(ValueError):
            executor.generate_source(b'not the historical source', fixture_pins())

    def test_derivation_preserves_supervisor_and_removes_shutdown_child(self):
        baseline = (HERE / 'windows_sandbox_native_tool_probe.cs').read_bytes()
        generated = executor.generate_source(baseline, fixture_pins()).decode()
        original = baseline.decode().replace('\r\n', '\n')
        first = original.index('    static Child Spawn(')
        last = original.index('    static void SourcePins(')
        self.assertIn(original[first:last], generated)
        self.assertIn(original[original.index('    static object Supervise('):original.index('    static int Main(')], generated)
        self.assertNotIn('Process.Start(', generated)
        self.assertIn('NativeRolePolicy.Validate(m);', generated)

    @unittest.skipUnless(os.name == 'nt', 'Existing Windows C# compiler required')
    def test_real_CSharp_policy_consumer_without_guest_or_SDK(self):
        pins = fixture_pins()
        cases = []
        for role in executor.ROLES:
            m = {**executor.role_plan(role, pins), 'nonce': 'a' * 32, 'binary_sha256': 'b' * 64}
            cases.append({'name': role + '-locked', 'manifest': copy.deepcopy(m), 'accept': False})
            m['runtime_authorized'] = True  # synthetic policy input, never execution
            cases.append({'name': role + '-policy-only', 'manifest': m, 'accept': True})
        good = next(x['manifest'] for x in cases if x['name'] == 'cmake-policy-only')
        changes = [('command_line', good['command_line'] + ' && cmd.exe'),
                   ('executable', r'C:\Windows\System32\cmd.exe'), ('role', 'gradle'),
                   ('mode', 'dart-version'), ('producer_allowed', True), ('G2', True),
                   ('runtime_authorized', 1), ('cwd', r'C:\Windows')]
        for field, value in changes:
            m = copy.deepcopy(good);m[field] = value
            cases.append({'name': 'reject-' + field, 'manifest': m, 'accept': False})
        for field, extra in [('environment', {'JAVA_TOOL_OPTIONS': '-javaagent:bad.jar'}),
                             ('environment', {'DOTNET_STARTUP_HOOKS': 'bad.dll'})]:
            m = copy.deepcopy(good);m[field].update(extra)
            cases.append({'name': 'reject-injected-environment', 'manifest': m, 'accept': False})
        for field in ('inputs', 'images'):
            m = copy.deepcopy(good);m[field][0]['sha256'] = 'c' * 64
            cases.append({'name': 'reject-' + field + '-hash', 'manifest': m, 'accept': False})
        m = copy.deepcopy(good);m['inputs'][0]['destination'] = r'C:\BuildWork\bad.exe'
        cases.append({'name': 'reject-destination-copy', 'manifest': m, 'accept': False})
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / 'NativeRoleProbe.cs'
            source.write_bytes(executor.generate_source((HERE / 'windows_sandbox_native_tool_probe.cs').read_bytes(), pins))
            fixture = root / 'cases.json';fixture.write_text(json.dumps(cases), encoding='utf-8')
            compiler = Path(os.environ['SystemRoot']) / 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
            binary = root / 'PolicyTests.exe'
            compiled = subprocess.run([str(compiler), '/nologo', '/noconfig', '/platform:x64',
                '/r:System.dll', '/r:System.Core.dll', '/r:System.Web.Extensions.dll',
                '/main:NativeRolePolicyTests', '/out:' + str(binary), str(source),
                str(HERE / 'native_role_policy_test.cs')], capture_output=True, timeout=30)
            self.assertEqual(compiled.returncode, 0, compiled.stdout.decode(errors='replace') + compiled.stderr.decode(errors='replace'))
            ran = subprocess.run([str(binary), str(fixture)], capture_output=True, timeout=15)
            self.assertEqual(ran.returncode, 0, ran.stdout.decode(errors='replace') + ran.stderr.decode(errors='replace'))
            self.assertEqual(ran.stdout.strip(), ('VALIDATION_ONLY_NO_SDK_CASES=' + str(len(cases))).encode())


if __name__ == '__main__':
    unittest.main()
