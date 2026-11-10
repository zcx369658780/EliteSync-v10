"""Synthetic parser and redaction checks; no SSH or Laravel execution."""

import json
import unittest

import run


class ParserTests(unittest.TestCase):
    def setUp(self):
        self.good = {
            "ok": True, "probe_version": "AUTH64-1", "family": "MariaDB", "version": "10.11.14",
            "target_fingerprint_sha256": run.EXPECTED_FINGERPRINT,
            "counts": dict.fromkeys(run.COUNT_KEYS, 0), "completeness": "UNKNOWN",
            "completeness_reason": "PRIVILEGE_VISIBILITY_UNVERIFIED",
        }
        self.good["counts"]["base_tables"] = 43

    def encoded(self, value):
        return (json.dumps(value, separators=(",", ":")) + "\n").encode()

    def reject(self, raw):
        with self.assertRaises(run.InvalidOutput):
            run.parse_output(raw)

    def test_success(self):
        result = run.parse_output(self.encoded(self.good))
        self.assertEqual(result["status"], "PASS")
        self.assertEqual(result["counts"]["base_tables"], 43)

    def test_safe_error(self):
        self.assertEqual(run.parse_output(self.encoded({"ok": False, "error": "QUERY_OR_ADAPTER_ERROR"})),
                         {"status": "PROBE_ERROR", "error": "QUERY_OR_ADAPTER_ERROR"})

    def test_extra_and_missing_keys(self):
        for value in (dict(self.good, extra=1), {k: v for k, v in self.good.items() if k != "counts"},
                      {"ok": False, "error": "PROBE_ERROR", "extra": 1}):
            with self.subTest(value=value):
                self.reject(self.encoded(value))

    def test_duplicate_keys(self):
        self.reject(b'{"ok":false,"error":"PROBE_ERROR","error":"PROBE_ERROR"}\n')
        raw = self.encoded(self.good).replace(b'"base_tables":43', b'"base_tables":43,"base_tables":43')
        self.reject(raw)

    def test_trailing_and_utf8(self):
        for raw in (self.encoded(self.good) + b'x', self.encoded(self.good) + b'\n',
                    self.encoded(self.good)[:-1], b'\xff\n'):
            with self.subTest(raw=raw[:10]):
                self.reject(raw)

    def test_wrong_types_and_fingerprint(self):
        for key, value in (("ok", 1), ("family", 7), ("version", "10.11.15"),
                           ("target_fingerprint_sha256", "x" * 64),
                           ("target_fingerprint_sha256", "0" * 64)):
            with self.subTest(key=key):
                sample = dict(self.good, **{key: value})
                self.reject(self.encoded(sample))
        for value in (True, -1, 10001, 1.5, "1"):
            with self.subTest(count=value):
                sample = dict(self.good)
                sample["counts"] = dict(self.good["counts"], columns=value)
                self.reject(self.encoded(sample))

    def test_relation_mismatch_and_limit(self):
        sample = dict(self.good)
        sample["counts"] = dict(self.good["counts"], base_tables=42)
        self.reject(self.encoded(sample))
        self.reject(b' ' * (run.OUTPUT_LIMIT + 1))

    def test_error_redaction(self):
        self.reject(self.encoded({"ok": False, "error": "secret"}))
        self.reject(self.encoded({"ok": False, "error": ["secret"]}))


if __name__ == "__main__":
    unittest.main(verbosity=1)
