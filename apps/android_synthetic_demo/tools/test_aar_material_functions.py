"""Fixed-vector tests; loads only the explicitly authorized sibling module."""

from dataclasses import FrozenInstanceError
import importlib.util
import sys
import unittest


_MODULE_PATH = "D:/EliteSync-v10/apps/android_synthetic_demo/tools/aar_material_functions.py"
_SPEC = importlib.util.spec_from_file_location("aar_material_functions", _MODULE_PATH)
_MODULE = importlib.util.module_from_spec(_SPEC)
sys.modules[_SPEC.name] = _MODULE
_SPEC.loader.exec_module(_MODULE)


class MaterialTests(unittest.TestCase):
    def recipe(self, **changes):
        values = dict(
            base_group="com.elitesync.syntheticdemo",
            base_artifact="flutter",
            publication_name="customPub",
            component_name="debug",
            base_version="1.0-SNAPSHOT",
            build_number=None,
            output_root="work/module-output",
        )
        values.update(changes)
        return _MODULE.publication_recipe(**values)

    def test_independent_vectors(self):
        cases = [
            (("a",), "YQ=="), (("bc",), "YmM="),
            (("a", "bc"), "YQ==,YmM="), (("é",), "w6k="),
            (("😀",), "8J+YgA=="), (("a,b",), "YSxi"),
            (("a=",), "YT0="), ((), ""),
            (("bc", "a", "a"), "YmM=,YQ==,YQ=="),
            (("", "a"), ",YQ=="), ((" a ",), "IGEg"),
        ]
        for values, expected in cases:
            with self.subTest(values=values):
                self.assertEqual(_MODULE.encode_dart_defines(values), expected)

    def test_encoder_type_and_surrogate(self):
        for bad in [[], "a", None, (1,), (None,)]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                _MODULE.encode_dart_defines(bad)
        for bad in ["\ud800", "\udfff", "a\ud800b"]:
            with self.subTest(bad=repr(bad)), self.assertRaises(ValueError):
                _MODULE.encode_dart_defines((bad,))

    def test_synthetic_single_argument(self):
        expected = "-Pdart-defines=RUxJVEVTWU5DX1NZTlRIRVRJQ19ERU1PPXRydWU="
        self.assertEqual(_MODULE.synthetic_define_argument(), expected)
        self.assertEqual(_MODULE.synthetic_define_argument(("ELITESYNC_SYNTHETIC_DEMO=true",)), expected)

    def test_synthetic_rejects_other_intent(self):
        correct = "ELITESYNC_SYNTHETIC_DEMO=true"
        for bad in [(), (correct, correct), (correct, "X=1"),
                    ("ELITESYNC_SYNTHETIC_DEMO=false",),
                    (correct, "ELITESYNC_SYNTHETIC_DEMO=false"), (" " + correct,)]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                _MODULE.synthetic_define_argument(bad)
        for bad in [[correct], correct, None, (1,)]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                _MODULE.synthetic_define_argument(bad)

    def test_publication_and_component_are_independent(self):
        result = self.recipe()
        self.assertEqual(result.group_id, "com.elitesync.syntheticdemo")
        self.assertEqual(result.artifact_id, "flutter_customPub")
        self.assertEqual(result.publication_name, "customPub")
        self.assertEqual(result.component_name, "debug")
        self.assertEqual(result.task_name, "assembleAarDebug")
        self.assertEqual(result.repository_relative_path, "work/module-output/outputs/repo")
        self.assertFalse(result.runtime_ready)
        self.assertFalse(result.publication_binding_verified)

    def test_version_order(self):
        self.assertEqual(self.recipe().project_version_proposal, "1.0")
        self.assertEqual(self.recipe(base_version="1-SNAPSHOT-SNAPSHOT").project_version_proposal, "1")
        self.assertEqual(self.recipe(build_number="input-id-SNAPSHOT").project_version_proposal, "input-id-SNAPSHOT")
        self.assertEqual(self.recipe(build_number="2+build.1").project_version_proposal, "2+build.1")

    def test_immutable_record(self):
        result = self.recipe()
        with self.assertRaises(FrozenInstanceError):
            result.artifact_id = "changed"

    def test_non_strings(self):
        for field in ["base_group", "base_artifact", "publication_name",
                      "component_name", "base_version", "output_root"]:
            for bad in [None, 1, True, [], ("a",)]:
                with self.subTest(field=field, bad=bad), self.assertRaises(TypeError):
                    self.recipe(**{field: bad})
        for bad in [1, True, [], ("1",)]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                self.recipe(build_number=bad)

    def test_character_domains(self):
        fields = {
            "base_group": ["", ".com", "com.", "com..x", "com.x+y", "com.é", "com._x", "com/x"],
            "base_artifact": ["", "_a", "-a", "a+b", "a/b", "é", "a b", "a\n"],
            "publication_name": ["", "_a", "a/b", "a+b", "é"],
            "component_name": ["", "all", "profile", "release", "Debug", "debug,release"],
            "base_version": ["", "-SNAPSHOT", "+1", "1/2", "é", "1 2", "1\n"],
            "build_number": ["", "+1", "1/2", "é", "1 2", "1\n"],
        }
        for field, cases in fields.items():
            for bad in cases:
                with self.subTest(field=field, bad=bad), self.assertRaises(ValueError):
                    self.recipe(**{field: bad})

    def test_output_path_boundaries(self):
        for bad in ["", "/root", "C:/root", "C:\\root", "\\\\server\\share",
                    "//server/share", "root/", "root//child", ".", "..",
                    "root/./child", "root/../child", "root\\child", "root:child",
                    "root/é", "root/a b", "root/_child"]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                self.recipe(output_root=bad)
        for good in ["a", "a.b/c-d/e_f", "0/1", "root/a..b"]:
            with self.subTest(good=good):
                self.assertEqual(self.recipe(output_root=good).repository_relative_path,
                                 good + "/outputs/repo")

    def test_valid_character_boundaries(self):
        result = self.recipe(base_group="0.a_b.c-d", base_artifact="0.a-b_c",
                             publication_name="9.p-q_r", base_version="1.2+3-4_5")
        self.assertEqual(result.artifact_id, "0.a-b_c_9.p-q_r")
        self.assertEqual(result.project_version_proposal, "1.2+3-4_5")

    def test_keyword_only(self):
        with self.assertRaises(TypeError):
            _MODULE.publication_recipe("group")

    def build_info(self, **changes):
        values = dict(track_widget_creation=False, tree_shake_icons=False,
                      project_cache_relative_path="work/gradle-cache")
        values.update(changes)
        return _MODULE.synthetic_build_info_arguments(**values)

    def test_build_info_fixed_combinations(self):
        prefix = ("-Pdart-defines=RUxJVEVTWU5DX1NZTlRIRVRJQ19ERU1PPXRydWU=",
                  "-Pdart-obfuscation=false")
        cases = [
            (False, False, prefix + ("-Ptrack-widget-creation=false", "-Ptree-shake-icons=false", "--project-cache-dir=work/gradle-cache")),
            (False, True, prefix + ("-Ptrack-widget-creation=false", "-Ptree-shake-icons=true", "--project-cache-dir=work/gradle-cache")),
            (True, False, prefix + ("-Ptrack-widget-creation=true", "-Ptree-shake-icons=false", "--project-cache-dir=work/gradle-cache")),
            (True, True, prefix + ("-Ptrack-widget-creation=true", "-Ptree-shake-icons=true", "--project-cache-dir=work/gradle-cache")),
        ]
        for track, shake, expected in cases:
            with self.subTest(track=track, shake=shake):
                result = self.build_info(track_widget_creation=track, tree_shake_icons=shake)
                self.assertIs(type(result), tuple)
                self.assertEqual(result, expected)
                self.assertEqual(len(result), 5)

    def test_build_info_strict_bools(self):
        for field in ["track_widget_creation", "tree_shake_icons"]:
            for bad in [0, 1, "true", "false", None, [], (), 0.0]:
                with self.subTest(field=field, bad=bad), self.assertRaises(TypeError):
                    self.build_info(**{field: bad})

    def test_build_info_signature(self):
        function = _MODULE.synthetic_build_info_arguments
        with self.assertRaises(TypeError):
            function(False, False, "cache")
        values = dict(track_widget_creation=False, tree_shake_icons=False,
                      project_cache_relative_path="cache")
        for field in values:
            missing = dict(values)
            del missing[field]
            with self.subTest(missing=field), self.assertRaises(TypeError):
                function(**missing)
        for field in ["extra", "androidProjectArgs", "override", "defines"]:
            with self.subTest(extra=field), self.assertRaises(TypeError):
                self.build_info(**{field: ()})

    def test_build_info_cache_rejections(self):
        for bad in [None, 1, True, [], ("cache",)]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                self.build_info(project_cache_relative_path=bad)
        for bad in ["", "/root", "C:/root", "C:\\root", "\\\\server\\share",
                    "//server/share", "root/", "root//child", ".", "..",
                    "root/./child", "root/../child", "root\\child", "root:child",
                    "root/é", "root/a b", "root/_child", "root/a\n"]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                self.build_info(project_cache_relative_path=bad)

    def test_build_info_cache_preserved(self):
        for good in ["a", "a.b/c-d/e_f", "0/1", "root/a..b"]:
            with self.subTest(good=good):
                self.assertEqual(self.build_info(project_cache_relative_path=good)[4],
                                 "--project-cache-dir=" + good)

    def topology(self, **changes):
        values = dict(module_relative_root="module", include_app=False)
        values.update(changes)
        return _MODULE.module_topology_materials(**values)

    def test_topology_fixed_choices(self):
        cases = [
            ("module", False, (":flutter",), "module/.android/Flutter"),
            ("module", True, (":app", ":flutter"), "module/.android/Flutter"),
            ("work/frozen-module", False, (":flutter",), "work/frozen-module/.android/Flutter"),
            ("work/frozen-module", True, (":app", ":flutter"), "work/frozen-module/.android/Flutter"),
        ]
        for root, app, names, directory in cases:
            with self.subTest(root=root, app=app):
                result = self.topology(module_relative_root=root, include_app=app)
                self.assertEqual(result.root_name, "android_generated")
                self.assertEqual(result.project_names, names)
                self.assertEqual(result.flutter_project_relative_dir, directory)
                self.assertIsNone(result.app_project_relative_dir)
                self.assertEqual(result.publication_module_name, ":flutter")
                self.assertEqual(result.excluded_plugin_candidate_names, (":app", ":flutter"))
                self.assertFalse(result.loader_binding_verified)
                self.assertFalse(result.runtime_ready)

    def test_topology_immutable(self):
        result = self.topology()
        with self.assertRaises(FrozenInstanceError):
            result.project_names = (":other",)
        self.assertFalse(hasattr(result, "__dict__"))
        self.assertIs(type(result.project_names), tuple)
        self.assertIs(type(result.excluded_plugin_candidate_names), tuple)

    def test_topology_root_boundaries(self):
        for bad in [None, 1, True, [], ("module",)]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                self.topology(module_relative_root=bad)
        for bad in ["", "/root", "C:/root", "C:\\root", "\\\\server\\share",
                    "//server/share", "root/", "root//child", ".", "..",
                    "root/./child", "root/../child", "root\\child", "root:child",
                    "root/é", "root/a b", "root/_child", "root/a\n", "root/'x'", "root/${x}"]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                self.topology(module_relative_root=bad)
        for good in ["a", "a.b/c-d/e_f", "0/1", "root/a..b"]:
            with self.subTest(good=good):
                self.assertEqual(self.topology(module_relative_root=good).flutter_project_relative_dir,
                                 good + "/.android/Flutter")

    def test_topology_strict_bool(self):
        for bad in [0, 1, "true", "false", None, [], (), 0.0]:
            with self.subTest(bad=bad), self.assertRaises(TypeError):
                self.topology(include_app=bad)

    def test_topology_signature(self):
        function = _MODULE.module_topology_materials
        with self.assertRaises(TypeError):
            function("module", False)
        with self.assertRaises(TypeError):
            function(module_relative_root="module")
        with self.assertRaises(TypeError):
            function(include_app=False)
        for field in ["plugin", "project", "override", "sdk_path", "app_project_relative_dir"]:
            with self.subTest(extra=field), self.assertRaises(TypeError):
                self.topology(**{field: ()})

    def plugin_fixture(self):
        return {"plugins": {"android": [
            dict(name="sample_alpha", path="materials/sample_alpha", dependencies=["sample_beta"],
                 dev_dependency=True, native_build=True),
            dict(name="sample_beta", path="materials/sample_beta", dependencies=[],
                 dev_dependency=False, native_build=True),
            dict(name="sample_gamma", path="materials/sample_gamma", dependencies=["sample_alpha"],
                 dev_dependency=False, native_build=False),
        ]}}

    def plugins(self, metadata=None, **changes):
        values = dict(metadata=self.plugin_fixture() if metadata is None else metadata,
                      approved_plugin_paths=(("sample_alpha", "materials/sample_alpha"),
                                             ("sample_beta", "materials/sample_beta"),
                                             ("sample_gamma", "materials/sample_gamma")),
                      module_relative_root="work/frozen_module")
        values.update(changes)
        return _MODULE.synthetic_plugin_materials(**values)

    def test_plugin_fixed_materials_and_detachment(self):
        data = self.plugin_fixture()
        result = self.plugins(data)
        self.assertIs(type(result), tuple)
        self.assertEqual(tuple(item.name for item in result), ("sample_alpha", "sample_beta"))
        alpha, beta = result
        self.assertEqual((alpha.project_name, alpha.project_relative_dir, alpha.build_output_relative_dir,
                          alpha.dependencies, alpha.dev_dependency),
                         (":sample_alpha", "materials/sample_alpha/android",
                          "work/frozen_module/.android/plugins_build_output/sample_alpha", ("sample_beta",), True))
        self.assertEqual((beta.project_name, beta.project_relative_dir, beta.build_output_relative_dir,
                          beta.dependencies, beta.dev_dependency),
                         (":sample_beta", "materials/sample_beta/android",
                          "work/frozen_module/.android/plugins_build_output/sample_beta", (), False))
        for item in result:
            self.assertFalse(item.loader_binding_verified)
            self.assertFalse(item.runtime_ready)
            self.assertFalse(hasattr(item, "__dict__"))
        with self.assertRaises(FrozenInstanceError):
            alpha.name = "changed"
        data["plugins"]["android"][0]["dependencies"].clear()
        data["plugins"]["android"][0]["path"] = "changed"
        self.assertEqual(alpha.dependencies, ("sample_beta",))
        self.assertEqual(alpha.project_relative_dir, "materials/sample_alpha/android")
        self.assertEqual(self.plugins({"plugins": {"android": []}}), ())

    def test_plugin_schema_values(self):
        for data in [{}, {"plugins": {}}, {"plugins": {"android": [], "other": []}},
                     {"plugins": {"android": []}, "extra": 1}]:
            with self.subTest(data=data), self.assertRaises(ValueError):
                self.plugins(data)
        for field in ["name", "path", "dependencies", "dev_dependency", "native_build"]:
            data = self.plugin_fixture()
            del data["plugins"]["android"][0][field]
            with self.subTest(field=field), self.assertRaises(ValueError):
                self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][0]["extra"] = "not allowed"
        with self.assertRaises(ValueError):
            self.plugins(data)

    def test_plugin_schema_types(self):
        for bad in [None, [], "json"]:
            with self.subTest(top=bad), self.assertRaises(TypeError):
                _MODULE.synthetic_plugin_materials(metadata=bad, approved_plugin_paths=(), module_relative_root="module")
        for bad in [[], None, "x"]:
            with self.subTest(plugins=bad), self.assertRaises(TypeError):
                self.plugins({"plugins": bad})
        for bad in [(), None, {}]:
            with self.subTest(android=bad), self.assertRaises(TypeError):
                self.plugins({"plugins": {"android": bad}})
        for field, cases in {"name": [1, None], "path": [1, None], "dependencies": [(), None],
                             "dev_dependency": [0, "true", None], "native_build": [1, "true", None]}.items():
            for bad in cases:
                data = self.plugin_fixture()
                data["plugins"]["android"][0][field] = bad
                with self.subTest(field=field, bad=bad), self.assertRaises(TypeError):
                    self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][0]["dependencies"] = [1]
        with self.assertRaises(TypeError):
            self.plugins(data)
        with self.assertRaises(TypeError):
            self.plugins({"plugins": {"android": [[]]}})

    def test_plugin_names_and_false_validation(self):
        for bad in ["app", "flutter", "android_generated", "Sample_alpha", "sample-alpha", "", "sample_unknown"]:
            data = self.plugin_fixture()
            data["plugins"]["android"][0]["name"] = bad
            with self.subTest(name=bad), self.assertRaises(ValueError):
                self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"].append(dict(data["plugins"]["android"][0]))
        with self.assertRaises(ValueError):
            self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][2]["path"] = "../bad"
        with self.assertRaises(ValueError):
            self.plugins(data)

    def test_plugin_approved_types_conflicts(self):
        for bad in [[], None, (("sample_alpha",),), (["sample_alpha", "materials/sample_alpha"],),
                    ((1, "materials/sample_alpha"),), (("sample_alpha", 1),)]:
            error = ValueError if bad == (("sample_alpha",),) else TypeError
            with self.subTest(bad=bad), self.assertRaises(error):
                self.plugins(approved_plugin_paths=bad)
        for bad in [(("sample_alpha", "a"), ("sample_alpha", "b")),
                    (("sample_alpha", "a"), ("sample_beta", "a")),
                    (("sample_alpha", "a"), ("sample_beta", "a/b")),
                    (("sample_alpha", "a/b"), ("sample_beta", "a")),
                    (("flutter", "materials/flutter"),)]:
            with self.subTest(bad=bad), self.assertRaises(ValueError):
                self.plugins(approved_plugin_paths=bad)
        for path in ["work", "work/frozen_module", "work/frozen_module/child", "../bad", "/root", "C:/x"]:
            with self.subTest(path=path), self.assertRaises(ValueError):
                self.plugins(approved_plugin_paths=(("sample_alpha", path),))
        data = {"plugins": {"android": []}}
        self.assertEqual(self.plugins(data, approved_plugin_paths=(("sample_alpha", "a"), ("sample_beta", "ab"))), ())
        self.assertEqual(self.plugins(data, approved_plugin_paths=(("sample_alpha", "work/frozen_module_extra"),)), ())

    def test_plugin_path_mismatch_and_module_root(self):
        for bad in ["materials/sample_beta", "../bad", "/root", "C:/x", "a\\b", "a//b", "a/./b", "a/../b", "a/", "é"]:
            data = self.plugin_fixture()
            data["plugins"]["android"][0]["path"] = bad
            with self.subTest(path=bad), self.assertRaises(ValueError):
                self.plugins(data)
        with self.assertRaises(TypeError):
            self.plugins(module_relative_root=None)
        with self.assertRaises(ValueError):
            self.plugins(module_relative_root="materials")

    def test_plugin_dependency_rejections(self):
        for deps in [["sample_unknown"], ["sample_alpha"], ["sample_beta", "sample_beta"], ["sample_gamma"], ["App"]]:
            data = self.plugin_fixture()
            data["plugins"]["android"][0]["dependencies"] = deps
            with self.subTest(deps=deps), self.assertRaises(ValueError):
                self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][1]["dependencies"] = ["sample_alpha"]
        with self.assertRaises(ValueError):
            self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][0]["native_build"] = False
        data["plugins"]["android"][0]["dependencies"] = ["sample_gamma"]
        with self.assertRaises(ValueError):
            self.plugins(data)
        data = self.plugin_fixture()
        data["plugins"]["android"][2]["dependencies"] = ["sample_unknown"]
        with self.assertRaises(ValueError):
            self.plugins(data)

    def test_plugin_size_boundaries(self):
        sample = self.plugin_fixture()["plugins"]["android"][0]
        with self.assertRaisesRegex(ValueError, "duplicate plugin name"):
            self.plugins({"plugins": {"android": [dict(sample) for _ in range(128)]}})
        with self.assertRaisesRegex(ValueError, "too many plugins"):
            self.plugins({"plugins": {"android": [dict(sample) for _ in range(129)]}})
        pair = ("sample_alpha", "materials/sample_alpha")
        with self.assertRaisesRegex(ValueError, "duplicate approved name"):
            self.plugins(approved_plugin_paths=(pair,) * 128)
        with self.assertRaisesRegex(ValueError, "too many approved paths"):
            self.plugins(approved_plugin_paths=(pair,) * 129)
        for size, message in [(128, "duplicate dependencies"), (129, "too many dependencies")]:
            data = self.plugin_fixture()
            data["plugins"]["android"][0]["dependencies"] = ["sample_beta"] * size
            with self.subTest(size=size), self.assertRaisesRegex(ValueError, message):
                self.plugins(data)

    def test_plugin_signature_and_private_errors(self):
        function = _MODULE.synthetic_plugin_materials
        with self.assertRaises(TypeError):
            function({}, (), "module")
        values = dict(metadata=self.plugin_fixture(), approved_plugin_paths=(), module_relative_root="module")
        for field in values:
            missing = dict(values)
            del missing[field]
            with self.subTest(missing=field), self.assertRaises(TypeError):
                function(**missing)
        with self.assertRaises(TypeError):
            self.plugins(extra=())
        data = self.plugin_fixture()
        data["plugins"]["android"][0]["path"] = "private_marker"
        with self.assertRaises(ValueError) as context:
            self.plugins(data)
        self.assertNotIn("private_marker", str(context.exception))
        self.assertNotIn("sample_alpha", str(context.exception))


if __name__ == "__main__":
    unittest.main(verbosity=2)
