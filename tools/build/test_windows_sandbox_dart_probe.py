"""Temporary fixtures and mocked process calls only; never touch installed SDK."""
import copy
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import xml.etree.ElementTree as ET

import windows_sandbox_dart_probe as probe

REAL_HELPERS = probe.helpers


class DartProbeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.parent = Path(self.temp.name)
        self.sdk = self.parent / 'sdk'
        (self.sdk / 'bin').mkdir(parents=True)
        (self.sdk / 'bin/dart.exe').write_bytes(b'fixture-only-not-executable')
        (self.sdk / 'version').write_text('3.10.0')
        self.source = self.parent / 'source.cs'
        self.source.write_text('fixture source')
        self.launcher = self.parent / 'launcher.ps1'
        self.launcher.write_text('fixture launcher')
        self.compiler = self.parent / 'compiler.exe'
        self.compiler.write_bytes(b'fixture-only-compiler')
        for name, value in [('PARENT', self.parent), ('SDK', self.sdk), ('SOURCE', self.source),
                            ('LAUNCHER', self.launcher), ('COMPILER', self.compiler)]:
            patcher = patch.object(probe, name, value)
            patcher.start(); self.addCleanup(patcher.stop)
        patcher = patch.object(probe, 'helpers', return_value=[self.source, self.launcher])
        patcher.start(); self.addCleanup(patcher.stop)
        patcher = patch.object(probe.subprocess, 'run', side_effect=self.fake_process)
        self.process = patcher.start(); self.addCleanup(patcher.stop)
        self.root = self.parent / 'case'

    def fake_process(self, args, **kwargs):
        if '/target:winexe' in args:
            destination = next(value[5:] for value in args if value.startswith('/out:'))
            Path(destination).write_bytes(b'fixture-helper')
        output = b'{"pid":123,"creationUtc":"2026-11-02T00:00:00Z"}' if '-File' in args else b''
        return subprocess.CompletedProcess(args, 0, output, b'')

    def prepare(self):
        return probe.prepare(self.root)

    def receipt(self, m):
        return {'schema': 1, 'kind': 'native-tool-probe', 'mode': 'dart-version',
                'nonce': m['nonce'], 'binary_sha256': m['binary_sha256'], 'input_files': len(m['inputs']),
                'native_tool_root_attempts': 1, 'gradle_root_attempts': 0, 'apk_builds': 0,
                'G2': False, 'failure': None, 'tool_images_pinned': True,
                'proof': {'root_exit': 0, 'stop_reason': None, 'job_final_empty': True,
                          'all_bound_handles_exited': True, 'watchdog_stop': 0, 'bound_members': 1}}

    def test_fixed_compiler_accepts_and_records_managed_hardlinks(self):
        probe.os.link(self.compiler, self.parent / 'compiler-service-link.exe')
        pin = probe.compiler_identity()
        self.assertEqual(pin['link_count'], 2)
        self.assertEqual(self.prepare()['compiler_identity'], pin)
        self.assertEqual(probe.frozen(self.root)[1]['compiler_identity'], pin)

    def test_fixed_compiler_nonregular_and_oversize_rejected_before_open(self):
        with patch.object(probe, 'COMPILER', self.parent), patch.object(probe.os, 'open') as opened:
            with self.assertRaises(ValueError):
                probe.compiler_identity()
            opened.assert_not_called()
        with patch.object(probe, 'COMPILER_BYTE_LIMIT', 1), patch.object(probe.os, 'open') as opened:
            with self.assertRaises(ValueError):
                probe.compiler_identity()
            opened.assert_not_called()

    def test_fixed_compiler_growth_during_read_rejected(self):
        original = probe.os.read
        changed = False

        def grow(fd, count):
            nonlocal changed
            data = original(fd, count)
            if not changed:
                changed = True
                with self.compiler.open('ab') as output:
                    output.write(b'growth')
            return data

        with patch.object(probe.os, 'read', side_effect=grow):
            with self.assertRaisesRegex(ValueError, 'Compiler read exceeded size/cap'):
                probe.compiler_identity()

    def test_fixed_compiler_link_count_drift_rejected(self):
        original = probe.os.read
        changed = False

        def link_during_read(fd, count):
            nonlocal changed
            data = original(fd, count)
            if not changed:
                changed = True
                probe.os.link(self.compiler, self.parent / 'new-service-link')
            return data

        with patch.object(probe.os, 'read', side_effect=link_during_read):
            with self.assertRaisesRegex(ValueError, 'Compiler changed while reading'):
                probe.compiler_identity()

    def test_exact_command_environment_and_readonly_mappings(self):
        m = self.prepare()
        self.assertEqual(m['arguments'], [probe.EXE, '--version'])
        self.assertEqual(m['command_line'], probe.EXE + ' --version')
        self.assertNotIn('FLUTTER_ALREADY_LOCKED', m['environment'])
        self.assertEqual(m['environment']['PATH'], r'C:\Inputs\DartSdk\bin;C:\Windows\System32')
        tree = ET.fromstring((self.root / 'dart.wsb').read_text())
        mappings = {x.findtext('SandboxFolder'): x.findtext('ReadOnly') for x in tree.findall('MappedFolders/MappedFolder')}
        self.assertEqual(mappings, {r'C:\Probe': 'true', r'C:\ProbeOutput': 'false', r'C:\Inputs\DartSdk': 'true'})
        self.assertEqual(m['dart_authenticode_status'], 'NotSigned')
        self.assertEqual(probe.frozen(self.root)[1], m)

    def test_root_must_be_new_direct_child(self):
        for root in [self.parent, self.parent / 'missing/child', Path('relative')]:
            with self.assertRaises(ValueError):
                probe.prepare(root)
        self.prepare()
        with self.assertRaises(ValueError):
            self.prepare()

    def test_frozen_rejects_sdk_additions_and_identity_drift(self):
        self.prepare()
        extra = self.sdk / 'new-file'
        extra.write_bytes(b'new')
        with self.assertRaises(ValueError):
            probe.frozen(self.root)
        extra.unlink()
        (self.sdk / 'bin/dart.exe').write_bytes(b'changed')
        with self.assertRaises(ValueError):
            probe.frozen(self.root)

    def test_helper_pins_include_cross_module_dependencies(self):
        names = {path.name for path in REAL_HELPERS()}
        self.assertIn('current_product_aar_recheck_contract.py', names)
        self.assertIn('current_product_build_plan.py', names)
        self.assertIn('windows_sandbox_runtime_probe.py', names)
        self.assertIn('current_product_apk_inventory.py', names)

    def test_runtime_helper_drift_rejected(self):
        runtime = self.parent / 'runtime-helper.py'
        runtime.write_text('fixture original')
        with patch.object(probe, 'helpers', return_value=[self.source, self.launcher, runtime]):
            self.prepare()
            runtime.write_text('fixture changed')
            with self.assertRaises(ValueError):
                probe.frozen(self.root)

    def test_walk_error_must_propagate_before_hash(self):
        (self.root / 'probe').mkdir(parents=True)

        def denied(root, *, followlinks, onerror):
            self.assertFalse(followlinks)
            onerror(PermissionError('fixture unreadable subtree'))
            return iter(())

        with patch.object(probe.os, 'walk', side_effect=denied), patch.object(probe.inventory.os, 'open') as opened:
            with self.assertRaises(PermissionError):
                probe.inputs(self.root)
            opened.assert_not_called()

    def test_inventory_file_cap_rejects_before_any_hash(self):
        (self.root / 'probe').mkdir(parents=True)
        with patch.object(probe, 'INPUT_FILE_LIMIT', 1), patch.object(probe.inventory.os, 'open') as hashed:
            with self.assertRaises(ValueError):
                probe.inputs(self.root)
            hashed.assert_not_called()

    def test_enumeration_stops_on_first_excess_file_before_hash(self):
        (self.root / 'probe').mkdir(parents=True)
        visited = []

        def enumerate_files(root):
            for relative in [Path('bin/dart.exe'), Path('version')]:
                visited.append(relative)
                yield root / relative, relative
            self.fail('Enumeration continued beyond the first excess file')

        with patch.object(probe, 'INPUT_FILE_LIMIT', 1), \
                patch.object(probe, 'strict_tree_files', side_effect=enumerate_files) as walked, \
                patch.object(probe.inventory.os, 'open') as hashed:
            with self.assertRaisesRegex(ValueError, 'during enumeration'):
                probe.inputs(self.root)
            self.assertEqual(len(visited), 2)
            walked.assert_called_once_with(self.sdk)
            hashed.assert_not_called()

    def test_enumeration_cap_aggregates_roots_excluding_guest_manifest(self):
        (self.root / 'probe').mkdir(parents=True)
        (self.root / 'probe/manifest.json').write_text('excluded')
        with patch.object(probe, 'INPUT_FILE_LIMIT', 2):
            self.assertEqual(len(probe.inputs(self.root)[0]), 2)
        (self.root / 'probe/extra.txt').write_text('excess')
        with patch.object(probe, 'INPUT_FILE_LIMIT', 2), patch.object(probe.inventory.os, 'open') as hashed:
            with self.assertRaisesRegex(ValueError, 'during enumeration'):
                probe.inputs(self.root)
            hashed.assert_not_called()

    def test_inventory_byte_cap_rejects_before_any_hash(self):
        (self.root / 'probe').mkdir(parents=True)
        with patch.object(probe, 'INPUT_BYTE_LIMIT', 1), patch.object(probe.inventory.os, 'open') as hashed:
            with self.assertRaises(ValueError):
                probe.inputs(self.root)
            hashed.assert_not_called()

    def test_inventory_growth_during_hash_exceeding_cap_rejected(self):
        (self.root / 'probe').mkdir(parents=True)
        original = probe.inventory.os.read
        cap = sum(path.stat().st_size for path in [self.sdk / 'bin/dart.exe', self.sdk / 'version'])
        changed = False

        def grow(fd, count):
            nonlocal changed
            data = original(fd, count)
            if not changed:
                changed = True
                with (self.sdk / 'bin/dart.exe').open('ab') as output:
                    output.write(b'x' * (cap + 1))
            return data

        with patch.object(probe, 'INPUT_BYTE_LIMIT', cap), patch.object(probe.inventory.os, 'read', side_effect=grow):
            with self.assertRaisesRegex(ValueError, 'read exceeded declared size or byte limit'):
                probe.inputs(self.root)

    def test_frozen_rejects_environment_tampering(self):
        m = self.prepare()
        m['environment']['FLUTTER_ALREADY_LOCKED'] = 'true'
        for path in [self.root / 'manifest.json', self.root / 'probe/manifest.json']:
            path.write_text(json.dumps(m))
        with self.assertRaises(ValueError):
            probe.frozen(self.root)

    def test_single_claim_permanent_even_failed_launch(self):
        self.prepare()
        self.process.side_effect = [subprocess.CompletedProcess([], 0, b'', b''),
                                    subprocess.CompletedProcess([], 1, b'failure', b'error')]
        with self.assertRaises(ValueError):
            probe.launch(self.root)
        self.assertTrue((self.root / 'launch.claim.json').is_file())
        self.assertEqual(json.loads((self.root / 'launcher-exit.json').read_text()), {'exit_code': 1})
        with self.assertRaises(ValueError):
            probe.launch(self.root)
        self.assertEqual(self.process.call_count, 4)  # signature, compile, absence, launcher

    def test_launcher_timeout_preserves_consumed_claim_and_output(self):
        self.prepare()
        self.process.side_effect = [subprocess.CompletedProcess([], 0, b'', b''),
                                   subprocess.TimeoutExpired('fixture', 30, output=b'partial', stderr=b'timeout')]
        with self.assertRaises(subprocess.TimeoutExpired):
            probe.launch(self.root)
        self.assertTrue((self.root / 'launch.claim.json').exists())
        self.assertEqual((self.root / 'launcher.stdout').read_bytes(), b'partial')
        self.assertEqual(json.loads((self.root / 'launcher-exit.json').read_text())['status'], 'TIMEOUT_CLAIM_CONSUMED')
        with self.assertRaises(ValueError):
            probe.launch(self.root)

    def test_presence_and_nonempty_output_block_before_claim(self):
        self.prepare()
        self.process.return_value = subprocess.CompletedProcess([], 1, b'', b'')
        self.process.side_effect = None
        with self.assertRaises(ValueError):
            probe.launch(self.root)
        self.assertFalse((self.root / 'launch.claim.json').exists())
        (self.root / 'output/unexpected').write_bytes(b'x')
        with self.assertRaises(ValueError):
            probe.launch(self.root)

    def test_forged_receipt_identity_counts_and_proof_rejected(self):
        m = self.prepare(); good = self.receipt(m)
        probe.validate_result(good, m)
        for key, value in [('kind', 'other'), ('schema', True), ('nonce', 'bad'),
                           ('input_files', 0), ('native_tool_root_attempts', True),
                           ('gradle_root_attempts', 1), ('G2', True), ('tool_images_pinned', False)]:
            bad = copy.deepcopy(good); bad[key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                probe.validate_result(bad, m)
        for key, value in [('root_exit', True), ('stop_reason', 'STOP'), ('job_final_empty', False),
                           ('watchdog_stop', 1), ('bound_members', 2), ('all_bound_handles_exited', False)]:
            bad = copy.deepcopy(good); bad['proof'][key] = value
            with self.subTest(key=key), self.assertRaises(ValueError):
                probe.validate_result(bad, m)

    def test_collect_exact_version_and_exclusive_verified_result(self):
        m = self.prepare(); probe.launch(self.root)
        (self.root / 'output/result.json').write_text(json.dumps(self.receipt(m)))
        (self.root / 'output/tool.stdout').write_text('Dart SDK version: 3.10.0 (stable)')
        (self.root / 'output/tool.stderr').write_text('')
        result = probe.collect(self.root)
        self.assertEqual(result['status'], 'DART_SINGLE_PROCESS_COMPATIBILITY_SUPPORTED')
        self.assertIs(result['producer_entry_allowed'], False)
        self.assertEqual(result['APK'], 'NOT_PROVEN')
        with self.assertRaises(FileExistsError):
            probe.collect(self.root)

    def test_collect_rejects_wrong_version_and_manifest_chain(self):
        m = self.prepare(); probe.launch(self.root)
        (self.root / 'output/result.json').write_text(json.dumps(self.receipt(m)))
        (self.root / 'output/tool.stdout').write_text('Dart SDK version: 3.10.01')
        (self.root / 'output/tool.stderr').write_text('')
        with self.assertRaises(ValueError):
            probe.collect(self.root)
        launch = json.loads((self.root / 'launched.json').read_text())
        launch['manifest_sha256'] = 'fake'
        (self.root / 'launched.json').write_text(json.dumps(launch))
        with self.assertRaises(ValueError):
            probe.collect(self.root)

    def test_cli_rejects_extra_tool_or_mode(self):
        for args in [['prepare', '--root', str(self.root), '--mode', 'gradle'],
                     ['run', '--root', str(self.root)], ['collect']]:
            with self.assertRaises(SystemExit):
                probe.main(args)


if __name__ == '__main__':
    unittest.main()
