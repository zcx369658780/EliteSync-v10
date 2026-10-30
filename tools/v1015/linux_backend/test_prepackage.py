"""Pure prepackage regressions. No Linux, PHP, Composer, DB or network launch."""
import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest
import os
import socket
import subprocess
import stat
from types import SimpleNamespace
from unittest.mock import patch

import prepackage as p


_guards = contextlib.ExitStack()


def setUpModule():
    def denied(*_args, **_kwargs):
        raise AssertionError('PURE_TEST_PROCESS_OR_NETWORK_FORBIDDEN')
    for target in ['subprocess.Popen', 'socket.socket.connect', 'socket.create_connection', 'os.system']:
        _guards.enter_context(patch(target, side_effect=denied))
    if hasattr(os, 'startfile'):
        _guards.enter_context(patch('os.startfile', side_effect=denied))


def tearDownModule():
    _guards.close()


def fixture():
    return dict(require={'php': '~8.5.12', 'laravel/framework': '^12.0',
                         'laravel/tinker': '^2.9', 'laravel/sanctum': '^4.0',
                         '6tail/lunar-php': '^1.4', 'workerman/workerman': '^5.1',
                         'ext-curl': '*'},
                **{'require-dev': {'phpunit/phpunit': '^11.0.1', 'nunomaduro/collision': '^8.1'},
                   'config': {'allow-plugins': {'example/plugin': True}},
                   'scripts': {'post-update-cmd': '@php artisan migrate'},
                   'autoload': {'psr-4': {'App\\': 'app/'}}})


class ProfileTests(unittest.TestCase):
    def test_primary_documented_dependency_transform(self):
        current = fixture()
        value = p.profile(current, 13)
        self.assertEqual(value['require']['php'], '~8.4.0')
        self.assertEqual(value['require']['laravel/framework'], '^13.0')
        self.assertEqual(value['require']['laravel/tinker'], '^3.0')
        self.assertEqual(value['require-dev']['phpunit/phpunit'], '^12.0')
        self.assertEqual(value['require-dev']['nunomaduro/collision'], '^8.6')
        self.assertEqual(p.validate_profile(value, current, 13), 'SOLVER_INPUT_ONLY')
        self.assertEqual(current, fixture())

    def test_fallback_keeps_current_tool_majors(self):
        current = fixture()
        value = p.profile(current, 12)
        self.assertEqual(value['require']['laravel/framework'], '^12.0')
        self.assertEqual(value['require']['laravel/tinker'], '^2.9')
        self.assertEqual(value['require-dev'], current['require-dev'])
        self.assertEqual(p.validate_profile(value, current, 12), 'SOLVER_INPUT_ONLY')

    def test_other_packages_and_autoload_are_preserved(self):
        current = fixture()
        for major in (12, 13):
            value = p.profile(current, major)
            for name in ('laravel/sanctum', '6tail/lunar-php', 'workerman/workerman', 'ext-curl'):
                self.assertEqual(value['require'][name], current['require'][name])
            self.assertEqual(value['autoload'], current['autoload'])

    def test_scripts_plugins_and_emulated_platform_removed(self):
        current = fixture()
        current['config']['platform'] = {'php': '8.4.99', 'ext-curl': '99'}
        value = p.profile(current, 13)
        self.assertEqual(value['scripts'], {})
        self.assertEqual(value['config']['allow-plugins'], {})
        self.assertNotIn('platform', value['config'])

    def test_unauthorized_framework_rejected(self):
        with self.assertRaisesRegex(p.Gate, 'FRAMEWORK_NOT_AUTHORIZED'):
            p.profile(fixture(), 14)

    def test_changed_business_dependency_is_rejected(self):
        value = p.profile(fixture(), 13)
        del value['require']['laravel/sanctum']
        with self.assertRaisesRegex(p.Gate, 'PROFILE_NOT_EXACT'):
            p.validate_profile(value, fixture(), 13)

    def test_enabled_hook_rejected(self):
        value = p.profile(fixture(), 13)
        value['scripts']['post-update-cmd'] = '@php artisan migrate'
        with self.assertRaises(p.Gate):
            p.validate_profile(value, fixture(), 13)

    def test_fake_platform_rejected(self):
        value = p.profile(fixture(), 13)
        value['config']['platform'] = {'php': '8.4.99'}
        with self.assertRaises(p.Gate):
            p.validate_profile(value, fixture(), 13)

    def test_changed_target_major_is_rejected(self):
        value = p.profile(fixture(), 13)
        with self.assertRaises(p.Gate):
            p.validate_profile(value, fixture(), 12)


class InventoryTests(unittest.TestCase):
    def test_process_and_network_guards_are_active(self):
        for call in [lambda: subprocess.Popen(['never-run']),
                     lambda: socket.create_connection(('127.0.0.1', 1)),
                     lambda: os.system('never-run')]:
            with self.assertRaisesRegex(AssertionError, 'PURE_TEST_PROCESS_OR_NETWORK_FORBIDDEN'):
                call()

    def test_hardlink_input_refused_before_reading(self):
        fake = unittest.mock.Mock()
        fake.stat.return_value = SimpleNamespace(st_nlink=2, st_mode=stat.S_IFREG)
        with patch.object(p, 'local', return_value=fake):
            with self.assertRaisesRegex(p.Gate, 'SOURCE_HARDLINK_OR_NONFILE'):
                p.read_private('synthetic.php')
        fake.read_bytes.assert_not_called()

    def test_all_transitives_are_listed_not_qualified(self):
        locked = dict(packages=[dict(name='vendor/a', version='1.0', require={'php': '^8.0'},
                                     source={'reference': 'abc'}, dist={'url': 'https://example.invalid/a'},
                                     license=['MIT'])],
                      **{'packages-dev': [dict(name='vendor/dev', version='2.0', conflict={'php': '<8'})]})
        result = p.dependency_inventory(fixture(), locked)
        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]['require'], {'php': '^8.0'})
        self.assertEqual(result[0]['source'], {'reference': 'abc'})
        self.assertEqual(result[1]['conflict'], {'php': '<8'})
        self.assertTrue(all(x['candidate_status'] == 'OLD_LOCK_ONLY_NOT_TARGET_RESOLUTION' for x in result))

    def test_duplicate_package_refused(self):
        row = dict(name='x/a', version='1')
        with self.assertRaisesRegex(p.Gate, 'DUPLICATE_LOCK_PACKAGE'):
            p.dependency_inventory(fixture(), dict(packages=[row], **{'packages-dev': [row]}))

    def test_default_inspect_is_inert(self):
        with patch.object(p, 'build_prepackage', side_effect=AssertionError('unexpected source read')):
            with contextlib.redirect_stdout(io.StringIO()) as out:
                self.assertEqual(p.main([]), 0)
        self.assertFalse(json.loads(out.getvalue())['execute_enabled'])

    def test_execute_cannot_be_unlocked_by_input(self):
        with self.assertRaisesRegex(p.Gate, 'RUNTIME_NOT_IMPLEMENTED'):
            p.runtime_execute({'owner_authorized': True, 'qualified': True})

    def test_cli_execute_refuses_before_source_read(self):
        with patch.object(p, 'build_prepackage', side_effect=AssertionError('unexpected source read')):
            with self.assertRaisesRegex(p.Gate, 'RUNTIME_NOT_IMPLEMENTED'):
                p.main(['execute'])

    def test_fixed_input_bytes_refused(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            (root/'composer.json').write_bytes(b'{}')
            (root/'composer.lock').write_bytes(b'{}')
            with self.assertRaisesRegex(p.Gate, 'FIXED_PARENT_COMPOSER_INPUT_CHANGED'):
                p.input_pair(root)


class DurableEmissionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / p.ROOT_NAME
        self.root.mkdir()
        self.backend = self.root/'source/services/backend-laravel'
        self.backend.mkdir(parents=True)
        st = self.root.stat()
        self.first = dict(seq=1, action='PREPARE_BOOTSTRAP', task_id=p.TASK_ID,
                          task_blob=p.TASK, sole_parent=p.PARENT, attempt_id='attempt-0001',
                          workspace=dict(file_id=st.st_ino, volume=st.st_dev), tick_start=p.monotonic_tick())
        self.save([self.first])
        self.payload = dict(profiles={'13': fixture(), '12': fixture()},
                            state='BLOCKED_LINUX_EXECUTOR_NOT_AVAILABLE')

    def save(self, rows):
        (self.root/'execution_ledger.jsonl').write_bytes(b''.join(
            json.dumps(x).encode()+b'\n' for x in rows))

    def emit(self):
        with patch.object(p, 'build_prepackage', return_value=self.payload):
            return p.write_prepackage(self.backend, self.root)

    def test_three_files_exclusive_write_and_original_ledger_prepare(self):
        result = self.emit()
        self.assertEqual(result['files'], 3)
        rows = [json.loads(x) for x in (self.root/'execution_ledger.jsonl').read_bytes().splitlines()]
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[1]['action'], 'PREPARE_SOURCE_ONLY_PREPACKAGE_WRITE')
        for name, expected in rows[1]['hashes'].items():
            self.assertEqual(p.sha((self.root/'linux-prepackage'/name).read_bytes()), expected)

    def test_existing_output_not_overwritten(self):
        self.emit()
        before = (self.root/'linux-prepackage/prepackage.json').read_bytes()
        with self.assertRaisesRegex(p.Gate, 'PREPACKAGE_ALREADY_EXISTS'):
            self.emit()
        self.assertEqual((self.root/'linux-prepackage/prepackage.json').read_bytes(), before)

    def test_wrong_task_blob_rejected(self):
        self.first['task_blob'] = '0'*40
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'LEDGER_AUTHORITY'):
            self.emit()

    def test_wrong_parent_rejected(self):
        self.first['sole_parent'] = '0'*40
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'LEDGER_AUTHORITY'):
            self.emit()

    def test_second_attempt_rejected(self):
        self.first['attempt_id'] = 'attempt-0002'
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'LEDGER_AUTHORITY'):
            self.emit()

    def test_replaced_root_rejected(self):
        self.first['workspace']['file_id'] += 1
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'TASK_ROOT_REPLACED'):
            self.emit()

    def test_expired_window_rejected(self):
        self.first['tick_start'] -= 14400001
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'TASK_WINDOW'):
            self.emit()

    def test_clock_reversal_rejected(self):
        self.first['tick_start'] += 14400001
        self.save([self.first])
        with self.assertRaisesRegex(p.Gate, 'TASK_WINDOW'):
            self.emit()

    def test_terminal_stop_cannot_prepare(self):
        self.save([self.first, dict(action='TERMINAL_STOP')])
        with self.assertRaisesRegex(p.Gate, 'TASK_STOPPED'):
            self.emit()

    def test_torn_tail_rejected(self):
        path = self.root/'execution_ledger.jsonl'
        path.write_bytes(path.read_bytes().rstrip(b'\n'))
        with self.assertRaisesRegex(p.Gate, 'TORN_LEDGER_TAIL'):
            self.emit()

    def test_external_source_refused(self):
        with patch.object(p, 'build_prepackage', side_effect=AssertionError('unexpected source read')):
            with self.assertRaisesRegex(p.Gate, 'SOURCE_OUTSIDE_TASK_ROOT'):
                p.write_prepackage(Path(self.temp.name), self.root)

    def test_wrong_root_name_refused(self):
        with self.assertRaisesRegex(p.Gate, 'TASK_ROOT_REQUIRED'):
            p.write_prepackage(self.backend, Path(self.temp.name))

    def test_stop_added_during_scan_prevents_write(self):
        def scan(_backend):
            self.save([self.first, dict(action='TERMINAL_STOP')])
            return self.payload
        with patch.object(p, 'build_prepackage', side_effect=scan):
            with self.assertRaisesRegex(p.Gate, 'TASK_STOPPED'):
                p.write_prepackage(self.backend, self.root)
        self.assertFalse((self.root/'linux-prepackage').exists())

    def test_expiration_during_scan_prevents_write(self):
        initial = self.first['tick_start']
        with patch.object(p, 'monotonic_tick', side_effect=[initial, initial + 14400001]):
            with self.assertRaisesRegex(p.Gate, 'TASK_WINDOW'):
                self.emit()
        self.assertFalse((self.root/'linux-prepackage').exists())

    def test_ledger_replacement_during_scan_refused(self):
        def scan(_backend):
            ledger = self.root/'execution_ledger.jsonl'
            ledger.rename(self.root/'original-ledger.jsonl')
            self.save([self.first])
            return self.payload
        with patch.object(p, 'build_prepackage', side_effect=scan):
            with self.assertRaisesRegex(p.Gate, 'LEDGER_REPLACED_DURING_SCAN'):
                p.write_prepackage(self.backend, self.root)
        self.assertFalse((self.root/'linux-prepackage').exists())

    def test_nonterminal_concurrent_append_refused(self):
        def scan(_backend):
            self.save([self.first, dict(action='OTHER_WRITE')])
            return self.payload
        with patch.object(p, 'build_prepackage', side_effect=scan):
            with self.assertRaisesRegex(p.Gate, 'LEDGER_CHANGED_DURING_SCAN'):
                p.write_prepackage(self.backend, self.root)

    @unittest.skipUnless(os.name == 'nt', 'Windows noncooperating-handle policy')
    def test_windows_lock_denies_second_write_and_delete_access(self):
        import ctypes
        file = self.root/'synthetic-lock-check.bin'
        file.write_bytes(b'synthetic evidence kept unchanged')
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.CreateFileW.argtypes = [ctypes.c_wchar_p, ctypes.c_uint32, ctypes.c_uint32,
                                      ctypes.c_void_p, ctypes.c_uint32, ctypes.c_uint32, ctypes.c_void_p]
        kernel.CreateFileW.restype = ctypes.c_void_p
        kernel.CloseHandle.argtypes = [ctypes.c_void_p]
        with p.exclusive_ledger(file):
            for access in (0x40000000, 0x00010000):
                handle = kernel.CreateFileW(str(file), access, 7, None, 3, 0, None)
                error = ctypes.get_last_error()
                if handle != ctypes.c_void_p(-1).value:
                    kernel.CloseHandle(handle)
                    self.fail('second write/delete-access handle unexpectedly succeeded')
                self.assertEqual(error, 32)
        self.assertEqual(file.read_bytes(), b'synthetic evidence kept unchanged')


if __name__ == '__main__':
    unittest.main()
