import copy
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

import current_product_source_overlay as overlay
from sandbox_owned_session_cleanup import windows_arguments


class SourceOverlayTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)/'product'
        self.root.mkdir()
        self.git('init', '--quiet')
        self.initial = {
            'apps/flutter_elitesync_module/pubspec.yaml': 'name: fixture\n',
            'apps/flutter_elitesync_module/pubspec.lock': 'packages: {}\n',
            'apps/flutter_elitesync_module/lib/main.dart': 'void main() {}\n',
            'apps/flutter_elitesync_module/test/old_test.dart': 'void testOld() {}\n',
            'apps/android/fixture.txt': 'host\n', 'services/fixture.php': '<?php // fixture\n',
        }
        for name, text in self.initial.items():
            self.write(name, text)
        self.commit()
        self.baseline = self.git('rev-parse', 'HEAD').strip().decode()
        self.write('apps/flutter_elitesync_module/lib/main.dart', 'void main() { run(); }\n')
        self.write('apps/flutter_elitesync_module/test/nested/new_test.dart', 'void testNew() {}\n')
        self.commit()

    def git(self, *args):
        result = subprocess.run(['git', '-C', str(self.root), '-c', 'core.autocrlf=false',
            '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', *args],
            capture_output=True, timeout=20)
        result.check_returncode()
        return result.stdout

    def write(self, name, text):
        target = self.root/name
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(text, encoding='utf-8', newline='')

    def commit(self):
        self.git('add', '--all')
        self.git('commit', '--quiet', '-m', 'fixture')

    def capture(self):
        return overlay.capture_overlay(self.root, self.baseline)

    def project(self):
        root = Path(self.temp.name)/'candidate'
        for name, text in self.initial.items():
            target = root/name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(text.replace('\n', '\r\n').encode())
        return root

    def test_serializable_capture_applies_only_bound_dart_bytes(self):
        captured = self.capture()
        self.assertEqual(captured, json.loads(json.dumps(captured)))
        manifest = captured['manifest']
        self.assertEqual(manifest['baseline_commit'], self.baseline)
        self.assertEqual(manifest['source_identity']['source_commit'], self.git('rev-parse','HEAD').strip().decode())
        self.assertEqual([row['status'] for row in manifest['files']], ['M','A'])
        target = self.project()
        overlay.apply_overlay(captured, target)
        for row in manifest['files']:
            self.assertEqual((target/row['path']).read_bytes(), (self.root/row['path']).read_bytes())
        self.assertEqual((target/'services/fixture.php').read_bytes(), b'<?php // fixture\r\n')

    def test_services_and_docs_changes_are_allowed_and_current_tree_is_recorded(self):
        self.write('services/fixture.php', '<?php // current service\n')
        self.write('docs/note.md', 'current docs\n')
        self.commit()
        captured = self.capture()
        self.assertEqual(captured['manifest']['source_identity']['services_tree'],
                         self.git('rev-parse','HEAD:services').strip().decode())
        self.assertEqual(len(captured['manifest']['files']), 2)

    def test_dirty_tracked_flutter_worktree_and_index_are_rejected(self):
        self.write('apps/flutter_elitesync_module/lib/main.dart', 'dirty\n')
        with self.assertRaises(ValueError): self.capture()
        self.git('add', 'apps/flutter_elitesync_module/lib/main.dart')
        with self.assertRaises(ValueError): self.capture()

    def test_dependencies_android_and_deleted_dart_are_rejected(self):
        for name in ['apps/flutter_elitesync_module/pubspec.yaml',
                     'apps/flutter_elitesync_module/pubspec.lock', 'apps/android/fixture.txt']:
            with self.subTest(name=name):
                self.write(name, 'changed\n'); self.commit()
                with self.assertRaises(ValueError): self.capture()
                self.write(name, self.initial[name]); self.commit()
        (self.root/'apps/flutter_elitesync_module/test/old_test.dart').unlink()
        self.commit()
        with self.assertRaises(ValueError): self.capture()

    def test_wrong_root_nonancestor_and_bounds_are_rejected(self):
        with self.assertRaises(ValueError):
            overlay.capture_overlay(self.root/'apps', self.baseline)
        tree = self.git('rev-parse','HEAD^{tree}').strip().decode()
        orphan = self.git('commit-tree', tree, '-m', 'unrelated fixture').strip().decode()
        with self.assertRaises(ValueError): overlay.capture_overlay(self.root, orphan)
        with patch.object(overlay, 'FILE_LIMIT', 1):
            with self.assertRaises(ValueError): self.capture()
        with patch.object(overlay, 'BYTE_LIMIT', 5):
            with self.assertRaises(ValueError): self.capture()

    def test_apply_rejects_baseline_drift_and_existing_added_file(self):
        captured = self.capture(); target = self.project()
        changed = target/'apps/flutter_elitesync_module/lib/main.dart'
        changed.write_text('unrelated original', encoding='utf-8')
        with self.assertRaises(ValueError): overlay.apply_overlay(captured, target)
        self.assertEqual(changed.read_text(), 'unrelated original')
        changed.write_text(self.initial['apps/flutter_elitesync_module/lib/main.dart'], encoding='utf-8')
        added = target/'apps/flutter_elitesync_module/test/nested/new_test.dart'
        added.parent.mkdir(parents=True); added.write_text('preserve', encoding='utf-8')
        with self.assertRaises(FileExistsError): overlay.apply_overlay(captured, target)
        self.assertEqual(added.read_text(), 'preserve')
        self.assertEqual(changed.read_bytes(), (self.root/'apps/flutter_elitesync_module/lib/main.dart').read_bytes())

    def test_manifest_tampering_and_path_escape_are_rejected(self):
        captured = self.capture(); target = self.project()
        captured['manifest']['files'][0]['path'] = 'apps/flutter_elitesync_module/lib/../../escape.dart'
        with self.assertRaises(ValueError): overlay.apply_overlay(captured, target)
        captured['manifest_sha256'] = hashlib.sha256(json.dumps(captured['manifest'], sort_keys=True,
            separators=(',',':'), ensure_ascii=True).encode()).hexdigest()
        with self.assertRaises(ValueError): overlay.apply_overlay(captured, target)

    def test_missing_modified_target_rejects_and_untracked_input_is_not_captured(self):
        self.write('apps/flutter_elitesync_module/untracked-fixture.txt', 'untracked\n')
        captured = self.capture()
        self.assertEqual(len(captured['manifest']['files']), 2)
        target = self.project()
        (target/'apps/flutter_elitesync_module/lib/main.dart').unlink()
        with self.assertRaises(FileNotFoundError): overlay.apply_overlay(captured, target)

    def test_retarget_changes_only_build_number_and_identity(self):
        captured = self.capture()
        args = ['C:/JDK path/java.exe','-Xmx2048m','-PbuildNumber=old', '--offline',
                '-Pdart-defines=fixture', 'assembleAarRelease']
        entry = dict(argv=args, launch_request=dict(command_line=subprocess.list2cmdline(args),
            cwd='C:/work', environment={'fixture':'same'}), publication_version='old',
            source_identity={'source_commit':'old'}, overlays={'fixture':'same'})
        before = copy.deepcopy(entry)
        result = overlay.retarget_entry(entry, captured)
        expected = '1.0-v1015-'+captured['manifest']['source_identity']['source_commit'][:12]+'-'+captured['manifest_sha256'][:12]
        self.assertEqual(result['publication_version'], expected)
        self.assertEqual(result['argv'], args[:2]+['-PbuildNumber='+expected]+args[3:])
        self.assertEqual(windows_arguments(result['launch_request']['command_line']), result['argv'])
        self.assertEqual(result['base_identity'], before['source_identity'])
        self.assertEqual(result['source_identity'], captured['manifest']['source_identity'])
        self.assertEqual(entry, before)
        self.assertEqual(result['overlays'], before['overlays'])
        self.assertEqual(result['launch_request']['cwd'], before['launch_request']['cwd'])
        self.assertEqual(result['launch_request']['environment'], before['launch_request']['environment'])
        entry['argv'] += ['-PbuildNumber=old']
        entry['launch_request']['command_line'] = subprocess.list2cmdline(entry['argv'])
        with self.assertRaises(ValueError): overlay.retarget_entry(entry, captured)


if __name__ == '__main__': unittest.main()
