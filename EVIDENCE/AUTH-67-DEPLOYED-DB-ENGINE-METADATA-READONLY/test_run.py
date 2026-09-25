"""Synthetic parser tests only; no SSH, Laravel, or database access."""

import copy
import json
import unittest

from run import InvalidOutput, parse_output


FINGERPRINT = "c21262611093ac9b13dc96071af5b8e95b9af46386ea25e47ee28a57adf44a29"
GOOD = {
    "ok": True,
    "probe_version": "AUTH66-1",
    "family": "MariaDB",
    "version": "10.11.14",
    "target_fingerprint_sha256": FINGERPRINT,
    "counts": {"base_tables": 43, "innodb": 42, "non_innodb": 1, "engine_null": 0, "views": 0},
    "scope_completeness": "UNKNOWN",
    "backup_consistency": "UNKNOWN",
}


def encoded(value):
    return (json.dumps(value, separators=(",", ":")) + "\n").encode("utf-8")


class ParserTests(unittest.TestCase):
    def check_rejected(self, raw, code):
        with self.assertRaises(InvalidOutput) as ctx:
            parse_output(raw)
        self.assertEqual(ctx.exception.args[0], code)

    def test_whitelist(self):
        result = parse_output(encoded(GOOD))
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["counts"], GOOD["counts"])
        self.assertEqual(result["scope_completeness"], "UNKNOWN")
        self.assertEqual(result["backup_consistency"], "UNKNOWN")

    def test_duplicate_extra_missing_keys(self):
        self.check_rejected(b'{"ok":true,"ok":false}\n', "DUPLICATE_KEY")
        for mutation in (lambda d: d.update(extra=1), lambda d: d.pop("version")):
            data = copy.deepcopy(GOOD)
            mutation(data)
            self.check_rejected(encoded(data), "SHAPE")
        data = copy.deepcopy(GOOD)
        data["counts"]["extra"] = 1
        self.check_rejected(encoded(data), "COUNT_SHAPE")

    def test_tail_and_utf8(self):
        self.check_rejected(encoded(GOOD) + b"x", "LINE_SHAPE")
        self.check_rejected(encoded(GOOD) + b"\n", "LINE_SHAPE")
        self.check_rejected(b"\xff\n", "UTF8")
        self.check_rejected(b"{}\n", "SHAPE")

    def test_error_class(self):
        self.assertEqual(parse_output(encoded({"ok": False, "error": "QUERY_OR_ADAPTER_ERROR"}))["first_failure"], "QUERY_OR_ADAPTER_ERROR")
        for error in ("SENSITIVE_ERROR", ["PROBE_ERROR"], None):
            self.check_rejected(encoded({"ok": False, "error": error}), "ERROR_SHAPE")
        self.check_rejected(encoded({"ok": False, "error": "PROBE_ERROR", "detail": "secret"}), "ERROR_SHAPE")

    def test_version_and_target(self):
        for key, value, code in (("probe_version", "AUTH66-2", "SHAPE"),
                                 ("family", "MySQL", "VERSION_MISMATCH"),
                                 ("version", "10.11.15", "VERSION_MISMATCH"),
                                 ("target_fingerprint_sha256", "0" * 64, "TARGET_MISMATCH"),
                                 ("target_fingerprint_sha256", "x", "FINGERPRINT_SHAPE")):
            data = copy.deepcopy(GOOD)
            data[key] = value
            self.check_rejected(encoded(data), code)

    def test_count_types_and_limits(self):
        for value in (True, 1.5, "43", -1, 10001):
            data = copy.deepcopy(GOOD)
            data["counts"]["innodb"] = value
            self.check_rejected(encoded(data), "COUNT_VALUE")

    def test_count_reconciliation(self):
        for key, value, code in (("base_tables", 42, "OBJECT_COUNT_MISMATCH"),
                                 ("views", 1, "OBJECT_COUNT_MISMATCH"),
                                 ("innodb", 41, "ENGINE_COUNT_MISMATCH")):
            data = copy.deepcopy(GOOD)
            data["counts"][key] = value
            self.check_rejected(encoded(data), code)

    def test_unknown_and_exception_redaction(self):
        for key in ("scope_completeness", "backup_consistency"):
            data = copy.deepcopy(GOOD)
            data[key] = "PASS"
            self.check_rejected(encoded(data), "UNKNOWN_SHAPE")
        raw = b'{"ok":true,"secret":"password","secret":"again"}\n'
        try:
            parse_output(raw)
        except InvalidOutput as exc:
            self.assertEqual(exc.args, ("DUPLICATE_KEY",))
            self.assertNotIn("password", str(exc))


if __name__ == "__main__":
    unittest.main()
