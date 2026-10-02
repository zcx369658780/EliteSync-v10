"""Fixed artificial-byte checks; no subprocess, file content, or secret input."""

import unittest

from raw_reader import run_synthetic


class RawDualStreamTests(unittest.TestCase):
    def assert_bounded(self, result):
        self.assertTrue(result["threads_cleaned"])
        self.assertTrue(result["distinct_reader_threads"])
        for name in ("stdout", "stderr"):
            stream = result[name]
            self.assertLessEqual(stream["actual_returned"], stream["limit"] + 1)
            self.assertLessEqual(stream["peak_retained"], stream["limit"] + 1)
            self.assertTrue(all(0 < n <= min(stream["limit"] + 1, 8) for n in stream["requests"]))
            self.assertTrue(all(0 <= got <= ask for ask, got in zip(stream["requests"], stream["completions"])))
            self.assertEqual(stream["actual_returned"], sum(stream["completions"]))

    def test_zero_limits_and_peer_eof(self):
        result = run_synthetic("zero", stdout_limit=0, stderr_limit=0)
        self.assert_bounded(result)
        self.assertEqual("COMPLETE", result["status"])
        self.assertEqual(0, result["stdout"]["actual_returned"])
        self.assertTrue(result["stdout"]["eof"])
        self.assertTrue(result["stderr"]["eof"])

    def test_exact_limits_require_eof(self):
        result = run_synthetic("exact", stdout_limit=8, stderr_limit=3)
        self.assert_bounded(result)
        self.assertEqual("COMPLETE", result["status"])
        self.assertEqual(8, result["stdout"]["actual_returned"])
        self.assertEqual(3, result["stderr"]["actual_returned"])
        self.assertTrue(result["stdout"]["eof"])
        self.assertTrue(result["stderr"]["eof"])

    def test_one_witness_byte_is_failure(self):
        result = run_synthetic("over", stdout_limit=8, stderr_limit=4)
        self.assert_bounded(result)
        self.assertEqual("STDOUT_LIMIT", result["status"])
        self.assertEqual(9, result["stdout"]["actual_returned"])
        self.assertFalse(result["stdout"]["eof"])

    def test_zero_limit_with_one_witness(self):
        result = run_synthetic("over", stdout_limit=0, stderr_limit=0)
        self.assert_bounded(result)
        self.assertEqual("STDOUT_LIMIT", result["status"])
        self.assertEqual((1,), result["stdout"]["requests"])

    def test_both_streams_overflow_independently(self):
        result = run_synthetic("both_over", stdout_limit=17, stderr_limit=9)
        self.assert_bounded(result)
        self.assertEqual("BOTH_LIMIT", result["status"])
        self.assertEqual(18, result["stdout"]["actual_returned"])
        self.assertEqual(10, result["stderr"]["actual_returned"])
        self.assertTrue(result["stdout"]["overflow"])
        self.assertTrue(result["stderr"]["overflow"])

    def test_peer_close_is_complete_only_after_eof(self):
        result = run_synthetic("peer_close", stdout_limit=4, stderr_limit=4)
        self.assert_bounded(result)
        self.assertEqual("COMPLETE", result["status"])
        self.assertTrue(result["stdout"]["eof"])
        self.assertTrue(result["stderr"]["eof"])

    def test_read_exception_fails_closed(self):
        result = run_synthetic("read_error")
        self.assert_bounded(result)
        self.assertEqual("READ_ERROR", result["status"])
        self.assertTrue(result["stdout"]["read_error"])
        self.assertFalse(result["stdout"]["eof"])

    def test_unknown_scenario_is_rejected(self):
        with self.assertRaises(ValueError):
            run_synthetic("external command")


if __name__ == "__main__":
    unittest.main()
