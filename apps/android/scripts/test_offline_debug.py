import importlib.util
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
import types
import sys
import zipfile
from unittest.mock import patch

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

    @unittest.skipUnless(sys.platform == 'win32', 'Windows entry lifecycle')
    def test_zero_exit_without_apk_records_started_build_failure(self):
        roots = {k: Path(v) for k, v in self.config['roots'].items()}
        self.config['knownCompleteCacheProvenance'] = 'unit lifecycle fixture'
        fake = types.SimpleNamespace(pid=1234, poll=lambda: 0, wait=lambda **_: 0)
        observed = types.SimpleNamespace(known=set(), sample=lambda _: ([], []))
        module = types.SimpleNamespace(Observer=lambda: observed)
        with patch.object(entry, 'preflight', return_value=(self.config, roots, self.root)), \
                patch.object(entry.subprocess, 'Popen', return_value=fake), \
                patch.dict(sys.modules, {'windows_build_observer': module}):
            code = entry.execute(self.manifest, '0' * 64, self.root / 'receipt')
        result = json.loads((self.root / 'receipt/result.json').read_text())
        self.assertEqual(code, 90)
        self.assertEqual(result['buildProcessesStarted'], 1)
        self.assertEqual(result['stopReason'], 'BUILD_ARTIFACT_MISSING')


if __name__ == '__main__':
    unittest.main()
