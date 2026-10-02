"""Static fail-closed checks; deliberately starts no synthetic child."""

import os
import subprocess
import unittest
from unittest.mock import patch

from job_probe import run_preflight


class JobPreflightTests(unittest.TestCase):
    def test_unavailable_before_any_launch(self):
        with patch.object(subprocess, "Popen", side_effect=AssertionError("child launch forbidden")) as popen:
            with patch.object(os, "system", side_effect=AssertionError("shell launch forbidden")) as shell:
                receipt = run_preflight()
        popen.assert_not_called()
        shell.assert_not_called()
        self.assertEqual("UNAVAILABLE", receipt["status"])
        self.assertEqual(0, receipt["synthetic_launch_attempts"])
        self.assertEqual(0, receipt["job_creation_attempts"])
        self.assertEqual(0, receipt["resume_attempts"])

    def test_no_tree_success_claim(self):
        receipt = run_preflight()
        self.assertEqual("NOT_STARTED", receipt["parent_observed"])
        self.assertEqual("NOT_STARTED", receipt["descendant_observed"])
        self.assertEqual("NOT_CHECKED", receipt["tree_proof"])
        self.assertEqual("NOT_APPLICABLE_NO_LAUNCH", receipt["residual_state"])

    def test_no_false_time_or_cleanup_bound(self):
        receipt = run_preflight()
        self.assertFalse(receipt["start_limit_enforced"])
        self.assertFalse(receipt["cleanup_limit_enforced"])
        self.assertEqual(
            "SUSPENDED_ASSIGNMENT_AND_BOUNDED_CLEANUP_NOT_ESTABLISHED",
            receipt["reason"],
        )


if __name__ == "__main__":
    unittest.main()
