"""One-process-per-case synthetic tests; receipts contain metadata only."""

from __future__ import annotations

import unittest
from unittest import mock

import supervisor


class SyntheticSupervisorTests(unittest.TestCase):
    def receipt(self, case: str, result: dict[str, str | int | None]) -> None:
        print(
            f"{case} status={result['status']} exit={result['exit_code']} "
            f"stdout_bytes={result['stdout_bytes']} stderr_bytes={result['stderr_bytes']}"
        )
        self.assertLessEqual(result["stdout_bytes"], 33)
        self.assertLessEqual(result["stderr_bytes"], 33)

    def test_normal(self) -> None:
        result = supervisor.run_synthetic("normal")
        self.receipt("normal", result)
        self.assertEqual(("COMPLETE", 0, 2, 0), (
            result["status"], result["exit_code"], result["stdout_bytes"], result["stderr_bytes"]
        ))

    def test_nonzero_with_stdout_is_rejected(self) -> None:
        result = supervisor.run_synthetic("nonzero")
        self.receipt("nonzero", result)
        self.assertEqual(("EXIT_NONZERO", 7, 1, 0), (
            result["status"], result["exit_code"], result["stdout_bytes"], result["stderr_bytes"]
        ))

    def test_stdout_limit(self) -> None:
        result = supervisor.run_synthetic("stdout_limit")
        self.receipt("stdout_limit", result)
        self.assertEqual("STDOUT_LIMIT", result["status"])
        self.assertEqual(33, result["stdout_bytes"])

    def test_stderr_limit(self) -> None:
        result = supervisor.run_synthetic("stderr_limit")
        self.receipt("stderr_limit", result)
        self.assertEqual("STDERR_LIMIT", result["status"])
        self.assertEqual(33, result["stderr_bytes"])

    def test_timeout(self) -> None:
        result = supervisor.run_synthetic("timeout", wall_seconds=0.2)
        self.receipt("timeout", result)
        self.assertEqual("TIMEOUT", result["status"])
        self.assertIsNotNone(result["exit_code"])

    def test_start_error(self) -> None:
        with mock.patch.object(supervisor.subprocess, "Popen", side_effect=OSError):
            result = supervisor.run_synthetic("normal")
        self.receipt("start_error", result)
        self.assertEqual(("START_ERROR", None, 0, 0), (
            result["status"], result["exit_code"], result["stdout_bytes"], result["stderr_bytes"]
        ))


if __name__ == "__main__":
    unittest.main(verbosity=2)
