"""Private script adaptation only; never execute Gradle, Java or a VM."""
import hashlib
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_product_config_diagnostic as old
import current_product_inprocess_diagnostic as d


class AarRegistrationTests(unittest.TestCase):
    def setUp(self):
        self.source = d.layout.FLUTTER / 'packages/flutter_tools/gradle/aar_init_script.gradle'
        self.original = self.source.read_bytes()

    def test_only_two_javadoc_declarations_are_removed(self):
        changed = d.adapt_aar_registration(self.original)
        expected = b''.join(line for number, line in enumerate(
            self.original.splitlines(keepends=True), 1) if number not in (136, 142))
        self.assertEqual(changed, expected)
        self.assertEqual(self.original.count(b'withJavadocJar()'), 2)
        self.assertNotIn(b'withJavadocJar()', changed)
        self.assertEqual(changed.count(b'withSourcesJar()'), 2)
        for fragment in [b'from component', b'finalizedBy "publish"',
                         b'moduleProjectTask.dependsOn(pluginProjectTask)']:
            self.assertEqual(changed.count(fragment), self.original.count(fragment))
        self.assertEqual(self.source.read_bytes(), self.original)

    def test_any_source_drift_or_second_application_is_rejected(self):
        for value in [b'', self.original + b'\n', self.original.replace(b'withJavadocJar()', b'other()'),
                      self.original.replace(b'withSourcesJar()', b'other()'),
                      self.original.replace(b'\r\n', b'\n')]:
            with self.subTest(bytes=len(value)), self.assertRaises(ValueError):
                d.adapt_aar_registration(value)
        with self.assertRaises(ValueError):
            d.adapt_aar_registration(d.adapt_aar_registration(self.original))

    def test_materialization_binds_both_stock_and_changed_script(self):
        stock_pin = d.layout.safe_file(self.source)
        with tempfile.TemporaryDirectory() as name:
            root = Path(name)
            inputs, bindings = [], []
            d.add_private_aar_registration(root, inputs, bindings)
            path = root / 'inputs/adapters/aar-registration.init.gradle'
            original = root / 'aar-registration.original.gradle'
            report = json.loads((root / 'aar-registration-adaptation-private.json').read_bytes())
            self.assertEqual(original.read_bytes(), self.original)
            self.assertEqual(path.read_bytes(), d.adapt_aar_registration(self.original))
            self.assertEqual(report['source_identity'], stock_pin)
            self.assertEqual(report['before_sha256'], hashlib.sha256(self.original).hexdigest())
            self.assertEqual(report['after_sha256'], d.sha(path))
            self.assertEqual(report['removed_source_lines'], [136, 142])
            self.assertEqual(report['runtime_status'], 'NOT_RUN')
            self.assertIs(report['G2'], False)
            self.assertEqual(len(inputs), 2)
            private = next(r for r in inputs if 'destination' in r)
            self.assertEqual(private['destination'], str(d.WORK / 'Adapters/aar-registration.init.gradle'))
            self.assertEqual(private['sha256'], d.sha(path))
            self.assertTrue(any(r['host'] == str(self.source) and r['sha256'] == stock_pin['sha256'] for r in bindings))
            for artifact in [original, root / 'aar-registration.patch', root / 'aar-registration-adaptation-private.json']:
                self.assertTrue(any(r['host'] == str(artifact) and r['sha256'] == d.sha(artifact) for r in bindings))
            diff = (root / 'aar-registration.patch').read_text()
            self.assertEqual(sum(line.startswith('-') and 'withJavadocJar()' in line for line in diff.splitlines()), 2)
            self.assertEqual(self.source.read_bytes(), self.original)
            with self.assertRaises(FileExistsError):
                d.add_private_aar_registration(root, [], [])

    def test_source_identity_drift_is_rejected_before_output(self):
        real_safe = d.layout.safe_file
        calls = 0
        def changed_pin(path):
            nonlocal calls
            pin = real_safe(path)
            if Path(path) == self.source:
                calls += 1
                if calls == 2:
                    pin = {**pin, 'file_id': [0, 0]}
            return pin
        with tempfile.TemporaryDirectory() as name, patch.object(d.layout, 'safe_file', side_effect=changed_pin):
            root = Path(name)
            with self.assertRaises(ValueError):
                d.add_private_aar_registration(root, [], [])
            self.assertEqual(list(root.iterdir()), [])

    def test_product_input_contract_pins_the_changed_script(self):
        guard = (d.HERE / 'current_product_config_guard.init.gradle').read_bytes()
        prior = {'source_commit': d.SOURCE, 'apps_tree': d.APPS, 'services_tree': d.SERVICES,
                 'input_sets': {key: [] for key in ['product', 'native', 'tooling', 'seed']}}
        with tempfile.TemporaryDirectory() as name:
            base = Path(name)
            here = base / 'repo/tools/build'
            here.mkdir(parents=True)
            (here / 'current_product_config_guard.init.gradle').write_bytes(guard)
            module = base / 'repo/apps/flutter_elitesync_module/.android'
            reference = '$flutterSdkPath/packages/flutter_tools/gradle'
            for relative, text in [('settings.gradle', reference), ('include_flutter.groovy', reference * 2),
                                   ('gradle.properties', 'fixture'), ('build.gradle', 'fixture'),
                                   ('Flutter/build.gradle', 'fixture'), ('app/build.gradle', 'fixture')]:
                path = module / relative
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_text(text)
            (module.parent / '.flutter-plugins-dependencies').write_text(json.dumps({'plugins': {'android': []}}))
            root = base / 'attempt'
            (root / 'probe').mkdir(parents=True)
            inputs, bindings = [], []
            with patch.object(d, 'HERE', here), patch.object(d.layout, 'frozen', return_value=(None, prior)), \
                    patch.object(d.subprocess, 'run') as run, patch.object(d.subprocess, 'Popen') as popen:
                d.product_inputs(root, inputs, bindings)
                run.assert_not_called()
                popen.assert_not_called()
            contract = json.loads((root / 'probe/guard-contract.json').read_bytes())
            changed_sha = d.sha(root / 'inputs/adapters/aar-registration.init.gradle')
            self.assertNotEqual(changed_sha, d.AAR_REGISTRATION_SOURCE_SHA256)
            self.assertEqual(contract['source_pins'][str(d.WORK / 'Adapters/aar-registration.init.gradle')], changed_sha)
            self.assertTrue(any(r.get('destination') == str(d.WORK / 'Adapters/aar-registration.init.gradle')
                                and r['sha256'] == changed_sha for r in inputs))

    def test_legacy_controller_and_documentation_gate_are_preserved(self):
        self.assertFalse(hasattr(old, 'adapt_aar_registration'))
        routing = [{'event': 'jni_cmake_finalized', 'path': str(d.WORK / 'state/cmake/jni')}]
        routing += [{'event': 'project_output', 'project': key, 'path': value}
                    for key, value in d.expected_outputs(['jni']).items()]
        text = ':flutter:assembleAarRelease SKIPPED\n:jni:assembleAarRelease SKIPPED\n:jni:javaDocReleaseJar SKIPPED\n'
        self.assertEqual(d.classify({'root_exit': 0, 'stop_reason': None}, text, ['jni'], routing),
                         'CONFIG_GRAPH_SELECTS_DOCUMENTATION_TASK')


if __name__ == '__main__':
    unittest.main()
