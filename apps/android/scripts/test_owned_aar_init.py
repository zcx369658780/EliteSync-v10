"""Isolated source/byte policy checks; never execute Gradle or Kotlin."""
from pathlib import Path
import ast
import hashlib
import itertools
import json
import re
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

FORBIDDEN_AUDIT_EVENTS = []


def forbid_runtime(event, arguments):
    if event in {'subprocess.Popen', 'os.system', 'ctypes.dlopen'} or event.startswith(
            ('socket.', 'os.exec', 'os.spawn', 'os.startfile')):
        FORBIDDEN_AUDIT_EVENTS.append(event)
        raise PermissionError('TEST_RUNTIME_ACCESS_FORBIDDEN:' + event)


sys.addaudithook(forbid_runtime)
SCRIPTS = Path(__file__).resolve().parent
BUILD = SCRIPTS.parent / 'app/build.gradle.kts'
import owned_aar_init as owned


def source_fixture():
    copy = (SCRIPTS / 'owned_flutter_aar_init/aar_runtime.init.gradle').read_bytes()
    if not copy.startswith(owned.PREAMBLE):
        raise AssertionError('owned preamble mismatch')
    source = copy[len(owned.PREAMBLE):]
    for old, new in owned.PATCHES:
        # Restore only the complete, uniquely indented sources line.
        expression = re.compile(rb'(?m)^' + re.escape(new))
        source, count = expression.subn(lambda _: old, source)
        if count != 1:
            raise AssertionError('inverse patch is not unique')
    if owned.digest(source) != owned.UPSTREAM_SHA256:
        raise AssertionError('reconstructed source hash mismatch')
    return source


def make_owned_fixture(project, flutter):
    for relative in owned.REQUIRED_PROJECT_INPUTS:
        target = project / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if relative.startswith(owned.DIRECTORY):
            target.write_bytes((SCRIPTS.parent.parent.parent / relative).read_bytes())
        else:
            target.write_bytes(b'isolated attested project input')
    source = flutter / 'packages/flutter_tools/gradle/aar_init_script.gradle'
    source.parent.mkdir(parents=True, exist_ok=True)
    source.write_bytes(source_fixture())
    (flutter / 'LICENSE').write_bytes((SCRIPTS / 'owned_flutter_aar_init/FLUTTER_LICENSE').read_bytes())
    return source


def fixture_contract(project):
    rows = [{'root': 'project', 'path': name, 'sha256': owned.digest((project / name).read_bytes())}
            for name in owned.REQUIRED_PROJECT_INPUTS]
    return {'ownedAarInitContract': owned.inventory_contract(), 'inventory': rows,
            'definitions': [{'path': x['path'], 'sha256': x['sha256']} for x in rows]}


class ProvenanceTests(unittest.TestCase):
    def test_exact_source_hash_and_deterministic_output(self):
        source = source_fixture()
        self.assertEqual(owned.digest(source), owned.UPSTREAM_SHA256)
        first = owned.derive_bytes(source)
        self.assertEqual(first, owned.derive_bytes(source))
        self.assertEqual(owned.digest(first), owned.OWNED_SHA256)

    def test_only_header_and_two_exact_lines_change(self):
        source = source_fixture()
        result = owned.derive_bytes(source)
        expected = source
        for old, new in owned.PATCHES:
            self.assertEqual(expected.count(old), 1)
            expected = expected.replace(old, new, 1)
        self.assertEqual(result, owned.PREAMBLE + expected)
        self.assertEqual(result.count(b'\r\n'), source.count(b'\r\n') - 2)

    def test_flavor_request_removed_but_sources_retained(self):
        body = owned.derive_bytes(source_fixture())
        self.assertIn(b'productFlavor.name + buildType.name.capitalize()', body)
        self.assertIn(owned.PATCHES[0][1], body)
        self.assertNotIn(owned.PATCHES[0][0], body)

    def test_no_flavor_request_removed_but_sources_retained(self):
        body = owned.derive_bytes(source_fixture())
        self.assertIn(b'singleVariant(buildType.name)', body)
        self.assertIn(owned.PATCHES[1][1], body)
        self.assertNotIn(owned.PATCHES[1][0], body)

    def test_all_other_upstream_bytes_restore_to_original_hash(self):
        self.assertEqual(owned.digest(source_fixture()), owned.UPSTREAM_SHA256)

    def test_wrong_upstream_hash_rejected(self):
        with self.assertRaisesRegex(owned.OwnedInitError, 'SOURCE_IDENTITY_MISMATCH'):
            owned.derive_bytes(source_fixture() + b'\n')

    def test_missing_context_rejected_independently_of_hash_gate(self):
        bad = source_fixture().replace(owned.PATCHES[0][0], b'withJavadocJar()\r\n')
        with self.assertRaisesRegex(owned.OwnedInitError, 'PATCH_CONTEXT_NOT_UNIQUE'):
            owned._patch_exact(bad)

    def test_duplicate_flavor_context_rejected(self):
        bad = source_fixture().replace(owned.PATCHES[1][0], owned.PATCHES[0][0])
        with self.assertRaisesRegex(owned.OwnedInitError, 'PATCH_CONTEXT_NOT_UNIQUE'):
            owned._patch_exact(bad)

    def test_already_configured_variants_guard_and_publish_remain(self):
        body = owned.derive_bytes(source_fixture())
        for token in [b'publishing.singleVariants.size() != 0', b'withSourcesJar()',
                      b'apply plugin: "maven-publish"', b'from component', b'finalizedBy "publish"',
                      b'moduleProjectTask.dependsOn(pluginProjectTask)']:
            self.assertIn(token, body)
        self.assertNotIn(b'withJavadocJar()', body)

    def test_license_and_source_manifest_match_independent_pins(self):
        directory = SCRIPTS / 'owned_flutter_aar_init'
        self.assertEqual(owned.digest((directory / 'FLUTTER_LICENSE').read_bytes()), owned.LICENSE_SHA256)
        self.assertEqual(owned.digest((directory / 'SOURCE.json').read_bytes()), owned.PROVENANCE_SHA256)
        info = json.loads((directory / 'SOURCE.json').read_bytes())
        self.assertEqual(info['option'], 'A_TRACKED_DERIVATIVE')
        self.assertEqual(owned.digest((directory / 'UPSTREAM.patch').read_bytes()), info['patchSha256'])


class FileGuardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.project, self.flutter = self.root / 'project', self.root / 'flutter'
        self.project.mkdir(); self.flutter.mkdir()
        self.source = make_owned_fixture(self.project, self.flutter)
        self.directory = self.project / owned.DIRECTORY

    def test_valid_copy_is_read_only_and_inside_project(self):
        before = {p: p.read_bytes() for p in [self.source, self.flutter / 'LICENSE']}
        selected = owned.verify_files(self.project, self.flutter)
        self.assertTrue(selected.is_relative_to(self.project))
        self.assertEqual(before, {p: p.read_bytes() for p in before})

    def test_changed_source_is_rejected_without_writing_sdk(self):
        self.source.write_bytes(b'corrupt source fixture')
        before = self.source.read_bytes()
        with self.assertRaisesRegex(owned.OwnedInitError, 'SOURCE_IDENTITY_MISMATCH'):
            owned.verify_files(self.project, self.flutter)
        self.assertEqual(before, self.source.read_bytes())

    def test_missing_owned_file_has_no_sdk_fallback(self):
        (self.directory / 'aar_runtime.init.gradle').unlink()
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_INPUT_MISSING'):
            owned.verify_files(self.project, self.flutter)
        self.assertEqual(owned.digest(self.source.read_bytes()), owned.UPSTREAM_SHA256)

    def test_changed_owned_copy_rejected(self):
        (self.directory / 'aar_runtime.init.gradle').write_bytes(b'withJavadocJar()')
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_OUTPUT_HASH'):
            owned.verify_files(self.project, self.flutter)

    def test_changed_upstream_license_rejected(self):
        (self.flutter / 'LICENSE').write_bytes(b'unknown terms')
        with self.assertRaisesRegex(owned.OwnedInitError, 'SOURCE_LICENSE_MISMATCH'):
            owned.verify_files(self.project, self.flutter)

    def test_missing_owned_license_rejected(self):
        (self.directory / 'FLUTTER_LICENSE').unlink()
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_INPUT_MISSING'):
            owned.verify_files(self.project, self.flutter)

    def test_changed_owned_license_rejected(self):
        (self.directory / 'FLUTTER_LICENSE').write_bytes(b'changed')
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_LICENSE_MISMATCH'):
            owned.verify_files(self.project, self.flutter)

    def test_changed_provenance_rejected(self):
        (self.directory / 'SOURCE.json').write_text('{}')
        with self.assertRaisesRegex(owned.OwnedInitError, 'PROVENANCE_HASH'):
            owned.verify_files(self.project, self.flutter)

    def test_changed_patch_rejected(self):
        (self.directory / 'UPSTREAM.patch').write_bytes(b'changed')
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_PATCH_HASH'):
            owned.verify_files(self.project, self.flutter)

    def test_traversal_and_absolute_child_rejected(self):
        for relative in ['../escape', str(self.source)]:
            with self.subTest(relative=relative), self.assertRaisesRegex(owned.OwnedInitError, 'UNSAFE_OWNED_PATH'):
                owned.checked_file(self.project, relative)

    def test_relative_root_rejected(self):
        with self.assertRaisesRegex(owned.OwnedInitError, 'UNSAFE_OWNED_PATH'):
            owned.checked_file(Path('relative-root'), 'file')

    def test_symlink_detection_is_fail_closed_without_creating_links(self):
        with patch.object(Path, 'is_symlink', return_value=True):
            with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_REDIRECTED_PATH'):
                owned.verify_files(self.project, self.flutter)

    def test_reparse_attribute_is_fail_closed_without_system_changes(self):
        import types
        with patch.object(Path, 'is_symlink', return_value=False), \
                patch.object(Path, 'lstat', return_value=types.SimpleNamespace(st_file_attributes=1024)):
            with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_REDIRECTED_PATH'):
                owned.verify_files(self.project, self.flutter)

    def test_new_inventory_attests_all_owned_definitions(self):
        config = fixture_contract(self.project)
        self.assertEqual(owned.verify_inventory(config, {'project': self.project, 'flutter': self.flutter}),
                         self.directory / 'aar_runtime.init.gradle')

    def test_old_inventory_cannot_authorize_new_inputs(self):
        with self.assertRaisesRegex(owned.OwnedInitError, 'NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY'):
            owned.verify_inventory({}, {'project': self.project, 'flutter': self.flutter})

    def test_missing_inventory_entry_rejected(self):
        config = fixture_contract(self.project)
        config['inventory'].pop()
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_INPUT_NOT_ATTESTED'):
            owned.verify_inventory(config, {'project': self.project, 'flutter': self.flutter})

    def test_missing_definition_rejected(self):
        config = fixture_contract(self.project)
        config['definitions'].pop()
        with self.assertRaisesRegex(owned.OwnedInitError, 'OWNED_INPUT_NOT_ATTESTED'):
            owned.verify_inventory(config, {'project': self.project, 'flutter': self.flutter})

    def test_wrong_contract_scope_rejected(self):
        config = fixture_contract(self.project)
        config['ownedAarInitContract']['scope'] = 'ice'
        with self.assertRaisesRegex(owned.OwnedInitError, 'NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY'):
            owned.verify_inventory(config, {'project': self.project, 'flutter': self.flutter})


def tearDownModule():
    if FORBIDDEN_AUDIT_EVENTS:
        raise AssertionError('REAL_RUNTIME_ACCESS_ATTEMPTED:' + repr(FORBIDDEN_AUDIT_EVENTS))
    print('ISOLATION: real process/socket/native-DLL audit events = 0; source/byte checks only')


class KotlinSourceContractTests(unittest.TestCase):
    def test_ordinary_r1_selects_owned_source(self):
        code = BUILD.read_text(encoding='utf-8')
        self.assertIn('val ordinaryR1Runtime = isV1015R1LocalBuild && !isIceDiagnosticBuild && !isV1015R1RetentionProbe', code)
        self.assertIn('if (ordinaryR1Runtime) validateOwnedRuntimeAarInit', code)

    def test_selected_init_is_consumed_and_scoped(self):
        code = BUILD.read_text(encoding='utf-8')
        self.assertIn('"-I=${aarInit.absolutePath}"', code)
        self.assertIn('"-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime"', code)

    def test_derived_copy_exists_without_javadoc_requests(self):
        path = SCRIPTS / 'owned_flutter_aar_init/aar_runtime.init.gradle'
        self.assertTrue(path.is_file(), 'owned source is missing')
        code = path.read_text(encoding='utf-8')
        self.assertNotIn('withJavadocJar()', code)
        self.assertEqual(code.count('withSourcesJar()'), 2)

    def test_extracted_kotlin_selector_for_all_flag_combinations(self):
        code = BUILD.read_text(encoding='utf-8')
        expression = re.search(r'val ordinaryR1Runtime = ([^\n]+)', code)[1]
        tree = ast.parse(expression.replace('&&', ' and ').replace('!', 'not '), mode='eval')
        def resolve(node, values):
            if isinstance(node, ast.Expression): return resolve(node.body, values)
            if isinstance(node, ast.Name): return values[node.id]
            if isinstance(node, ast.UnaryOp) and isinstance(node.op, ast.Not): return not resolve(node.operand, values)
            if isinstance(node, ast.BoolOp) and isinstance(node.op, ast.And): return all(resolve(x, values) for x in node.values)
            raise AssertionError('unsupported selector syntax')
        names = ['isV1015R1LocalBuild', 'isIceDiagnosticBuild', 'isV1015R1RetentionProbe']
        for r1, ice, retention in itertools.product([False, True], repeat=3):
            values = dict(zip(names, (r1, ice, retention)))
            with self.subTest(**values): self.assertEqual(resolve(tree, values), r1 and not ice and not retention)
        self.assertIn('require(!isV1015R1LocalBuild || isV1015LocalBuild)', code)

    def test_other_modes_keep_sdk_and_existing_targets(self):
        code = BUILD.read_text(encoding='utf-8')
        self.assertIn('else File(flutterSdkPath, "packages/flutter_tools/gradle/aar_init_script.gradle")', code)
        self.assertIn('if (isIceDiagnosticBuild) "assembleAarDebug" else "assembleAarRelease"', code)
        self.assertIn('else if (isV1015R1RetentionProbe) "lib/dev/v1015_r1_retention_probe.dart" else "lib/main.dart"', code)

    def test_kotlin_hash_gate_and_all_pins_match_python_contract(self):
        code = BUILD.read_text(encoding='utf-8').split('// OWNED_R1_AAR_INIT_BEGIN:', 1)[1].split('// OWNED_R1_AAR_INIT_END', 1)[0]
        for value in [owned.UPSTREAM_SHA256, owned.OWNED_SHA256, owned.LICENSE_SHA256, owned.PROVENANCE_SHA256]:
            self.assertIn(value, code)
        self.assertIn('LinkOption.NOFOLLOW_LINKS', code)
        self.assertIn('candidate.toRealPath() == candidate.normalize()', code)
        self.assertNotIn('catch', code)

    def test_owned_scope_guard_and_gradle_inputs_are_explicit(self):
        code = BUILD.read_text(encoding='utf-8')
        self.assertIn('inputs.files(aarInit,', code)
        self.assertIn('inputs.property("ownedRuntimeAarInitScope",', code)
        init = (SCRIPTS / 'owned_flutter_aar_init/aar_runtime.init.gradle').read_bytes()
        self.assertTrue(init.startswith(owned.PREAMBLE))
        self.assertIn(b"projectProperties['elitesyncOwnedAarInit'] != '" + owned.SCOPE.encode() + b"'", init)

    def test_no_publication_or_generation_tasks_disabled(self):
        code = BUILD.read_text(encoding='utf-8')
        init = (SCRIPTS / 'owned_flutter_aar_init/aar_runtime.init.gradle').read_text(encoding='utf-8')
        for text in [code, init]:
            self.assertNotIn('.enabled=false', text.replace(' ', ''))
            self.assertNotIn('GenerateModuleMetadata', text)
        self.assertIn('debugImplementation("com.elitesync.flutter_elitesync_module:', code)

    def test_offline_entry_checks_owned_inventory_before_observer(self):
        code = (SCRIPTS / 'offline_debug.py').read_text(encoding='utf-8')
        self.assertLess(code.index('verify_owned_inventory(config, roots)'), code.index('from windows_build_observer import Observer'))
        self.assertIn('SINGLE_ATTEMPT_TASK_BLOB', code)
        self.assertIn('SINGLE_BUILD_BUDGET_ALREADY_CLAIMED', code)


if __name__ == '__main__':
    unittest.main()
