"""Explicit artificial fixtures; no discovery, SDK reads or bundle writes."""

import importlib.util
import sys
import unittest


for _name, _path in (
    ("aar_material_functions", "D:/EliteSync-v10/apps/android_synthetic_demo/tools/aar_material_functions.py"),
    ("render_module_bundle", "D:/EliteSync-v10/apps/android_synthetic_demo/tools/render_module_bundle.py"),
):
    _spec = importlib.util.spec_from_file_location(_name, _path)
    _module = importlib.util.module_from_spec(_spec)
    sys.modules[_name] = _module
    _spec.loader.exec_module(_module)
_render = sys.modules["render_module_bundle"].render_module_bundle

_SETTINGS = b"""// SOURCE-ONLY synthetic module; NOT_READY.
pluginManagement {
    includeBuild(new File(settingsDir, '../../materials/flutter_sdk/packages/flutter_tools/gradle'))
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
plugins {
    id 'com.android.library' version '8.11.1' apply false
    id 'org.jetbrains.kotlin.android' version '2.2.20' apply false
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        maven { url = uri(new File(settingsDir, '../../materials/maven')) }
    }
}
rootProject.name = 'android_generated'
include ':flutter'
project(':flutter').projectDir = new File(settingsDir, 'Flutter')
include ':sample_alpha'
project(':sample_alpha').projectDir = new File(settingsDir, '../../materials/sample_alpha/android')
include ':sample_beta'
project(':sample_beta').projectDir = new File(settingsDir, '../../materials/sample_beta/android')
"""
_ROOT = b"""// SOURCE-ONLY synthetic module; NOT_READY.
layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/module-root'))
ext.set('output-dir', new File(rootProject.projectDir, '../../publication').path)
ext.set('is-plugin', 'false')
ext.set('buildNumber', 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
subprojects {
    if (name == 'flutter') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/flutter'))
    }
    if (name == 'sample_alpha') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_alpha'))
    }
    if (name == 'sample_beta') {
        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_beta'))
    }
}
"""
_FLUTTER = b"""// SOURCE-ONLY synthetic module; NOT_READY.
plugins {
    id 'com.android.library'
    id 'dev.flutter.flutter-gradle-plugin'
}
group = 'com.elitesync.syntheticdemo'
version = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
android {
    namespace = 'com.elitesync.syntheticdemo'
    compileSdk = 36
    ndkVersion = '27.0.12077973'
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    defaultConfig {
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = '1.0'
    }
    publishing {
        singleVariant('debug')
    }
}
androidComponents {
    beforeVariants(selector().all()) { variantBuilder ->
        variantBuilder.enable = variantBuilder.name == 'debug'
    }
}
flutter {
    source = '../..'
}
dependencies {
    implementation project(':sample_alpha')
    implementation project(':sample_beta')
}
"""
_MANIFEST = b"""<!-- SOURCE-ONLY synthetic module; NOT_READY. -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
    <uses-permission android:name="android.permission.CAMERA" tools:node="remove" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" tools:node="remove" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" tools:node="remove" />
    <application android:allowBackup="false" tools:node="merge">
        <meta-data android:name="flutterProjectType" android:value="module" />
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
"""
_EXPECTED = (
    ("module/.android/settings.gradle", _SETTINGS),
    ("module/.android/build.gradle", _ROOT),
    ("module/.android/Flutter/build.gradle", _FLUTTER),
    ("module/.android/Flutter/src/main/AndroidManifest.xml", _MANIFEST),
)


class RendererTests(unittest.TestCase):
    def fixture(self):
        config = dict(module_id="flutter", group_id="com.elitesync.syntheticdemo",
                      namespace="com.elitesync.syntheticdemo", module_root="module",
                      sdk_root="materials/flutter_sdk", maven_root="materials/maven",
                      agp_version="8.11.1", kotlin_version="2.2.20", compile_sdk=36,
                      min_sdk=26, target_sdk=35, ndk_version="27.0.12077973", input_id="a" * 64)
        metadata = {"plugins": {"android": [
            dict(name="sample_alpha", path="materials/sample_alpha", dependencies=["sample_beta"],
                 dev_dependency=True, native_build=True),
            dict(name="sample_beta", path="materials/sample_beta", dependencies=[],
                 dev_dependency=False, native_build=True),
        ]}}
        approved = (("sample_alpha", "materials/sample_alpha"),
                    ("sample_beta", "materials/sample_beta"),
                    ("sample_gamma", "materials/sample_gamma"))
        return dict(config=config, metadata=metadata, approved_plugin_paths=approved)

    def test_complete_independent_bytes(self):
        result = _render(**self.fixture())
        self.assertEqual(result, _EXPECTED)
        self.assertIs(type(result), tuple)
        for pair in result:
            self.assertIs(type(pair), tuple)
            self.assertIs(type(pair[0]), str)
            self.assertIs(type(pair[1]), bytes)
            self.assertNotIn(b"\r", pair[1])
            self.assertFalse(pair[1].startswith(b"\xef\xbb\xbf"))
            self.assertTrue(pair[1].endswith(b"\n"))
            self.assertFalse(pair[1].endswith(b"\n\n"))

    def test_paths_and_no_app(self):
        result = _render(**self.fixture())
        settings, root, flutter, manifest = [pair[1] for pair in result]
        self.assertIn(b"new File(settingsDir, 'Flutter')", settings)
        self.assertIn(b"../../materials/sample_alpha/android", settings)
        self.assertIn(b"../../outputs/flutter", root)
        self.assertIn(b"../../publication').path", root)
        self.assertIn(b"source = '../..'", flutter)
        self.assertNotIn(b"include ':app'", settings)
        self.assertNotIn(b"local.properties", settings + flutter)
        self.assertNotIn(b"module_plugin_loader", settings)
        self.assertNotIn(b"<activity", manifest)

    def test_input_detachment_and_false_gamma(self):
        fixture = self.fixture()
        fixture["metadata"]["plugins"]["android"].append(dict(
            name="sample_gamma", path="materials/sample_gamma", dependencies=["sample_alpha"],
            dev_dependency=False, native_build=False))
        result = _render(**fixture)
        self.assertEqual(result, _EXPECTED)
        fixture["config"]["input_id"] = "b" * 64
        fixture["metadata"]["plugins"]["android"][0]["name"] = "changed"
        self.assertEqual(result, _EXPECTED)

    def test_empty_native_full_expectation(self):
        fixture = self.fixture()
        fixture["metadata"]["plugins"]["android"] = []
        settings = _SETTINGS.replace(b"include ':sample_alpha'\nproject(':sample_alpha').projectDir = new File(settingsDir, '../../materials/sample_alpha/android')\n", b"").replace(
            b"include ':sample_beta'\nproject(':sample_beta').projectDir = new File(settingsDir, '../../materials/sample_beta/android')\n", b"")
        root = _ROOT.replace(b"    if (name == 'sample_alpha') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_alpha'))\n    }\n", b"").replace(
            b"    if (name == 'sample_beta') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_beta'))\n    }\n", b"")
        flutter = _FLUTTER.replace(b"    implementation project(':sample_alpha')\n    implementation project(':sample_beta')\n", b"")
        expected = ((_EXPECTED[0][0], settings), (_EXPECTED[1][0], root),
                    (_EXPECTED[2][0], flutter), (_EXPECTED[3][0], _MANIFEST))
        self.assertEqual(_render(**fixture), expected)

    def test_order_and_approved_order_independence(self):
        fixture = self.fixture()
        fixture["approved_plugin_paths"] = tuple(reversed(fixture["approved_plugin_paths"]))
        self.assertEqual(_render(**fixture), _EXPECTED)
        fixture["metadata"]["plugins"]["android"].reverse()
        settings = _SETTINGS.replace(b"include ':sample_alpha'\nproject(':sample_alpha').projectDir = new File(settingsDir, '../../materials/sample_alpha/android')\ninclude ':sample_beta'\nproject(':sample_beta').projectDir = new File(settingsDir, '../../materials/sample_beta/android')\n",
            b"include ':sample_beta'\nproject(':sample_beta').projectDir = new File(settingsDir, '../../materials/sample_beta/android')\ninclude ':sample_alpha'\nproject(':sample_alpha').projectDir = new File(settingsDir, '../../materials/sample_alpha/android')\n")
        root = _ROOT.replace(b"    if (name == 'sample_alpha') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_alpha'))\n    }\n    if (name == 'sample_beta') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_beta'))\n    }\n",
            b"    if (name == 'sample_beta') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_beta'))\n    }\n    if (name == 'sample_alpha') {\n        layout.buildDirectory.set(new File(rootProject.projectDir, '../../outputs/plugins/sample_alpha'))\n    }\n")
        flutter = _FLUTTER.replace(b"    implementation project(':sample_alpha')\n    implementation project(':sample_beta')\n",
                                  b"    implementation project(':sample_beta')\n    implementation project(':sample_alpha')\n")
        self.assertEqual(_render(**fixture), ((_EXPECTED[0][0], settings), (_EXPECTED[1][0], root),
                                            (_EXPECTED[2][0], flutter), (_EXPECTED[3][0], _MANIFEST)))

    def test_valid_variable_fields(self):
        fixture = self.fixture()
        fixture["config"]["ndk_version"] = "1.0.0"
        fixture["config"]["input_id"] = "0123456789abcdef" * 4
        expected_id = b"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"
        original_id = b"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        expected = ((_EXPECTED[0][0], _SETTINGS),
                    (_EXPECTED[1][0], _ROOT.replace(original_id, expected_id)),
                    (_EXPECTED[2][0], _FLUTTER.replace(original_id, expected_id).replace(b"27.0.12077973", b"1.0.0")),
                    (_EXPECTED[3][0], _MANIFEST))
        self.assertEqual(_render(**fixture), expected)

    def test_config_schema_and_types(self):
        for bad in [None, [], "config"]:
            fixture = self.fixture()
            fixture["config"] = bad
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                _render(**fixture)
        for key in self.fixture()["config"]:
            fixture = self.fixture()
            del fixture["config"][key]
            with self.subTest(missing=key), self.assertRaises(ValueError):
                _render(**fixture)
            fixture = self.fixture()
            fixture["config"][key] = None
            with self.subTest(type=key), self.assertRaises(TypeError):
                _render(**fixture)
        for key in ["extra", "app", "targets", "override"]:
            fixture = self.fixture()
            fixture["config"][key] = "unknown"
            with self.subTest(extra=key), self.assertRaises(ValueError):
                _render(**fixture)
        for key in ["compile_sdk", "min_sdk", "target_sdk"]:
            fixture = self.fixture()
            fixture["config"][key] = True
            with self.subTest(bool=key), self.assertRaises(TypeError):
                _render(**fixture)

    def test_fixed_fields_and_injections(self):
        for key in ["module_id", "group_id", "namespace", "module_root", "sdk_root",
                    "maven_root", "agp_version", "kotlin_version"]:
            for bad in ["", "app", "../x", "module/.android/Flutter", "${x}", "x'", "x\n", "C:/x", "a\\b"]:
                fixture = self.fixture()
                fixture["config"][key] = bad
                with self.subTest(key=key, bad=bad), self.assertRaises(ValueError):
                    _render(**fixture)
        for key in ["compile_sdk", "min_sdk", "target_sdk"]:
            fixture = self.fixture()
            fixture["config"][key] = 1
            with self.subTest(key=key), self.assertRaises(ValueError):
                _render(**fixture)

    def test_ndk_id_errors(self):
        for key, cases in {
            "ndk_version": ["", "0.1.2", "01.2.3", "1.2", "1.2.3.4", "1.-2.3", "1.2.3\n", "１.2.3", "${x}", "1.2.3'"],
            "input_id": ["", "a" * 63, "a" * 65, "A" * 64, "g" * 64, "a" * 63 + "\n", "${x}", "'" * 64],
        }.items():
            for bad in cases:
                fixture = self.fixture()
                fixture["config"][key] = bad
                with self.subTest(key=key, bad=bad), self.assertRaises(ValueError):
                    _render(**fixture)

    def test_approved_fixture_and_conflicts(self):
        for approved in [(("sample_unknown", "materials/sample_unknown"),),
                         (("sample_alpha", "materials/real_cache"),),
                         (("sample_alpha", "module"),),
                         (("sample_alpha", "outputs"),),
                         (("sample_alpha", "materials/sample_alpha"), ("sample_beta", "materials/sample_alpha/child")),
                         (("sample_alpha", "materials/sample_alpha"), ("sample_alpha", "materials/sample_alpha"))]:
            fixture = self.fixture()
            fixture["metadata"]["plugins"]["android"] = []
            fixture["approved_plugin_paths"] = approved
            with self.subTest(approved=approved), self.assertRaises(ValueError):
                _render(**fixture)
        fixture = self.fixture()
        fixture["approved_plugin_paths"] = []
        with self.assertRaises(TypeError):
            _render(**fixture)

    def test_metadata_schema_and_flags(self):
        for bad in [{}, {"plugins": {}}, {"plugins": {"android": []}, "extra": 1}]:
            fixture = self.fixture()
            fixture["metadata"] = bad
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                _render(**fixture)
        for bad in [None, [], "json"]:
            fixture = self.fixture()
            fixture["metadata"] = bad
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                _render(**fixture)
        for key in ["name", "path", "dependencies", "dev_dependency", "native_build"]:
            fixture = self.fixture()
            del fixture["metadata"]["plugins"]["android"][0][key]
            with self.subTest(missing=key), self.assertRaises(ValueError):
                _render(**fixture)
        for key in ["dev_dependency", "native_build"]:
            fixture = self.fixture()
            fixture["metadata"]["plugins"]["android"][0][key] = 1
            with self.subTest(key=key), self.assertRaises(TypeError):
                _render(**fixture)

    def test_dependency_and_size_errors(self):
        for variant in ["duplicate", "cycle", "native_false", "unknown", "129"]:
            fixture = self.fixture()
            entries = fixture["metadata"]["plugins"]["android"]
            if variant == "duplicate":
                entries.append(dict(entries[0]))
            elif variant == "cycle":
                entries[1]["dependencies"] = ["sample_alpha"]
            elif variant == "native_false":
                entries[1]["native_build"] = False
            elif variant == "unknown":
                entries[0]["dependencies"] = ["sample_gamma"]
            else:
                fixture["metadata"]["plugins"]["android"] = [dict(entries[0]) for _ in range(129)]
            with self.subTest(variant=variant), self.assertRaises(ValueError):
                _render(**fixture)
        fixture = self.fixture()
        sample = fixture["metadata"]["plugins"]["android"][0]
        fixture["metadata"]["plugins"]["android"] = [dict(sample) for _ in range(128)]
        with self.assertRaisesRegex(ValueError, "duplicate plugin name"):
            _render(**fixture)

    def test_signature_and_private_errors(self):
        fixture = self.fixture()
        with self.assertRaises(TypeError):
            _render(fixture["config"], fixture["metadata"], fixture["approved_plugin_paths"])
        for key in fixture:
            missing = dict(fixture)
            del missing[key]
            with self.subTest(key=key), self.assertRaises(TypeError):
                _render(**missing)
        with self.assertRaises(TypeError):
            _render(**fixture, extra=1)
        fixture["config"]["sdk_root"] = "private_marker"
        with self.assertRaises(ValueError) as context:
            _render(**fixture)
        self.assertNotIn("private_marker", str(context.exception))


if __name__ == "__main__":
    _suite = unittest.defaultTestLoader.loadTestsFromModule(sys.modules[__name__])
    _result = unittest.TextTestRunner(verbosity=2).run(_suite)
    sys.exit(0 if _result.wasSuccessful() else 1)
