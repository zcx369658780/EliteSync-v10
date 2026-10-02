"""Checks actual fake-consumer calls across fixed synthetic A/B scenarios."""

import unittest
from unittest.mock import patch

from release_gate import _FakeConsumer, _Gate, _evidence_for, run_synthetic


PATHS = ("A_MEMORY", "B_ENCRYPTED_STATE_ONLY")
PRE_RELEASE_FAILURES = (
    "partial_auth_nonzero", "truncated", "tampered", "wrong_key",
    "capacity_limit", "timeout", "interrupted", "cleanup_failure",
    "input_mismatch", "capture_incomplete", "staging_unsafe", "object_replaced",
)


class SyntheticReleaseGateTests(unittest.TestCase):
    def test_all_pre_release_failures_leave_actual_consumer_untouched(self):
        for path in PATHS:
            for scenario in PRE_RELEASE_FAILURES:
                with self.subTest(path=path, scenario=scenario):
                    with patch.object(_FakeConsumer, "consume", side_effect=AssertionError("premature call")) as spy:
                        receipt = run_synthetic(path, scenario)
                    spy.assert_not_called()
                    self.assertEqual("FAILED_PRE_RELEASE", receipt["state"])
                    self.assertEqual((0, 0), (receipt["consumer_calls"], receipt["consumer_bytes"]))
                    self.assertEqual("UNKNOWN", receipt["cleanup"])

    def test_failure_cannot_be_later_released(self):
        for path in PATHS:
            with self.subTest(path=path):
                gate = _Gate(path)
                consumer = _FakeConsumer()
                gate.evaluate(_evidence_for("partial_auth_nonzero"))
                self.assertFalse(gate.release(consumer))
                self.assertFalse(gate.release(consumer))
                self.assertEqual((0, 0), (consumer.calls, consumer.bytes))

    def test_normal_authentication_calls_one_fake_consumer_once(self):
        original_consume = _FakeConsumer.consume
        for path in PATHS:
            with self.subTest(path=path):
                with patch.object(_FakeConsumer, "consume", autospec=True, side_effect=original_consume) as spy:
                    receipt = run_synthetic(path, "normal")
                    self.assertEqual(1, spy.call_count)
                self.assertEqual("ONE_CONSUMER_RELEASED", receipt["state"])
                self.assertEqual((1, 4), (receipt["consumer_calls"], receipt["consumer_bytes"]))

    def test_duplicate_release_does_not_call_twice(self):
        for path in PATHS:
            with self.subTest(path=path):
                receipt = run_synthetic(path, "duplicate_release")
                self.assertEqual("DUPLICATE_DENIED", receipt["reason"])
                self.assertEqual((1, 4), (receipt["consumer_calls"], receipt["consumer_bytes"]))

    def test_import_failure_retains_actual_consumption(self):
        for path in PATHS:
            with self.subTest(path=path):
                receipt = run_synthetic(path, "import_failure")
                self.assertEqual("IMPORT_FAILED_ISOLATED", receipt["state"])
                self.assertEqual((1, 4), (receipt["consumer_calls"], receipt["consumer_bytes"]))

    def test_unknown_path_and_scenario_rejected(self):
        with self.assertRaises(ValueError):
            run_synthetic("real-db", "normal")
        with self.assertRaises(ValueError):
            run_synthetic("A_MEMORY", "arbitrary-command")


if __name__ == "__main__":
    unittest.main()
