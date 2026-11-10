"""Isolated shape/identity checks; no monitor, VM, or runtime qualification."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_product_config_diagnostic as diagnostic


class MonitorQualificationTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.task_patch = patch.object(diagnostic, "TASK_ROOT", self.root)
        self.task_patch.start()
        self.addCleanup(self.task_patch.stop)
        self.identities = {
            "native_sha256": "a" * 64,
            "controller_sha256": "b" * 64,
            "binary_identity": {"bytes": 128, "file_id": [7, 9], "sha256": "c" * 64},
            "manifest_sha256": "d" * 64,
            "receipt_sha256": "e" * 64,
        }
        self.record = {
            "schema": 2,
            "kind": "java-tree-and-disk-churn",
            "qualified": True,
            "native_source_sha256": self.identities["native_sha256"],
            "controller_sha256": self.identities["controller_sha256"],
            "binary_identity": copy.deepcopy(self.identities["binary_identity"]),
            "receipt_sha256": self.identities["receipt_sha256"],
            "manifest_sha256": self.identities["manifest_sha256"],
            "root": str(self.root / "fixture-01"),
            "disk_churn_operations": 1,
            "gradle_starts": 0,
            "G2": False,
        }

    def validate(self, record=None, **overrides):
        arguments = {**self.identities, **overrides}
        return diagnostic.validate_monitor_record(
            self.record if record is None else record, **arguments
        )

    def test_valid_record_is_accepted_without_mutation(self):
        before = copy.deepcopy(self.record)
        self.assertIsNone(self.validate())
        self.assertEqual(self.record, before)
        self.assertFalse((self.root / "fixture-01").exists())

    def test_record_requires_exact_fields_and_dict(self):
        for candidate in [None, [], {**self.record, "extra": False}]:
            with self.subTest(candidate=candidate):
                with self.assertRaises(ValueError):
                    diagnostic.validate_monitor_record(candidate, **self.identities)
        for field in self.record:
            candidate = copy.deepcopy(self.record)
            del candidate[field]
            with self.subTest(missing=field), self.assertRaises(ValueError):
                self.validate(candidate)

    def test_schema_is_exact_integer_two(self):
        for value in [True, False, 2.0, "2", 1, 3, None]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                self.validate({**self.record, "schema": value})

    def test_authority_flags_and_start_count_are_strict(self):
        cases = {
            "qualified": [1, "true", False, None],
            "G2": [0, "false", True, None],
            "gradle_starts": [False, True, 0.0, "0", -1, 1, None],
            "kind": ["java-tree", None, 1],
        }
        for field, values in cases.items():
            for value in values:
                with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                    self.validate({**self.record, field: value})

    def test_all_digests_require_full_lowercase_sha256(self):
        fields = ["native_source_sha256", "controller_sha256", "manifest_sha256", "receipt_sha256"]
        for field in fields + ["binary_sha256"]:
            for value in ["a" * 63, "a" * 65, "A" * 64, "g" * 64, " " + "a" * 64, "a" * 64 + "\n", None, 1]:
                candidate = copy.deepcopy(self.record)
                if field == "binary_sha256":
                    candidate["binary_identity"]["sha256"] = value
                else:
                    candidate[field] = value
                with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                    self.validate(candidate)

    def test_source_controller_manifest_and_receipt_identity_drift(self):
        fields = {
            "native_source_sha256": "native_sha256",
            "controller_sha256": "controller_sha256",
            "manifest_sha256": "manifest_sha256",
            "receipt_sha256": "receipt_sha256",
        }
        for field, argument in fields.items():
            with self.subTest(record_field=field), self.assertRaises(ValueError):
                self.validate({**self.record, field: "f" * 64})
            with self.subTest(expected_argument=argument), self.assertRaises(ValueError):
                self.validate(**{argument: "f" * 64})

    def test_binary_identity_rejects_missing_extra_and_invalid_fields(self):
        valid = self.record["binary_identity"]
        candidates = [None, [], {**valid, "extra": 1}]
        candidates += [{key: value for key, value in valid.items() if key != missing} for missing in valid]
        candidates += [{**valid, "bytes": value} for value in [True, False, 128.0, "128", 0, -1, None]]
        candidates += [{**valid, "file_id": value} for value in [(7, 9), [], [7], [7, 9, 10], [True, 9], [7, False], [7.0, 9], [7, "9"], None]]
        for candidate in candidates:
            with self.subTest(identity=candidate), self.assertRaises(ValueError):
                self.validate({**self.record, "binary_identity": candidate})

    def test_each_binary_identity_component_is_bound(self):
        for field, changed in [("bytes", 129), ("file_id", [7, 10]), ("sha256", "f" * 64)]:
            identity = {**self.record["binary_identity"], field: changed}
            with self.subTest(record_field=field), self.assertRaises(ValueError):
                self.validate({**self.record, "binary_identity": identity})
            with self.subTest(expected_field=field), self.assertRaises(ValueError):
                self.validate(binary_identity=identity)

    def test_disk_churn_requires_positive_integer(self):
        for value in [True, False, 0, -1, 1.0, "1", None]:
            with self.subTest(value=value), self.assertRaises(ValueError):
                self.validate({**self.record, "disk_churn_operations": value})
        self.assertIsNone(self.validate({**self.record, "disk_churn_operations": 100}))

    def test_root_is_absolute_direct_child_of_task_root(self):
        invalid = [str(self.root), str(self.root / "nested" / "child"),
                   str(self.root.parent / "outside"), "relative-child",
                   str(self.root / ".." / "outside"), None, 1]
        for value in invalid:
            with self.subTest(root=value), self.assertRaises(ValueError):
                self.validate({**self.record, "root": value})

    def test_filename_binds_both_source_prefixes(self):
        native = self.identities["native_sha256"]
        controller = self.identities["controller_sha256"]
        original = diagnostic.monitor_qualification_path(native, controller)
        self.assertEqual(original, self.root / ("monitor-qualification-" + "a" * 20 + "-" + "b" * 20 + ".json"))
        self.assertNotEqual(original, diagnostic.monitor_qualification_path("f" * 64, controller))
        self.assertNotEqual(original, diagnostic.monitor_qualification_path(native, "f" * 64))
        self.assertEqual(original.parent, self.root)

    def test_filename_rejects_noncanonical_hashes(self):
        for value in [None, 1, True, "a" * 63, "a" * 65, "A" * 64, "g" * 64, "a" * 64 + "\n", " " + "a" * 64]:
            for position in [0, 1]:
                arguments = [self.identities["native_sha256"], self.identities["controller_sha256"]]
                arguments[position] = value
                with self.subTest(value=value, position=position), self.assertRaises(ValueError):
                    diagnostic.monitor_qualification_path(*arguments)

    def test_versioned_put_preserves_legacy_record_and_rejects_overwrite(self):
        legacy = self.root / "monitor-qualification.json"
        original = b'{"legacy": "preserve byte for byte"}\n'
        legacy.write_bytes(original)
        destination = diagnostic.monitor_qualification_path(
            self.identities["native_sha256"], self.identities["controller_sha256"]
        )
        diagnostic.put(destination, self.record)
        written = destination.read_bytes()
        self.assertEqual(json.loads(written), self.record)
        self.assertEqual(legacy.read_bytes(), original)
        with self.assertRaises(FileExistsError):
            diagnostic.put(destination, {"replacement": True})
        self.assertEqual(destination.read_bytes(), written)
        self.assertEqual(legacy.read_bytes(), original)


if __name__ == "__main__":
    unittest.main()
