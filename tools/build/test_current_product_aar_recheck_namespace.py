"""Single-attempt namespace checks; no real claims or diagnostic execution."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_product_diagnostic_contract as first_contract
import current_product_config_diagnostic as first
import current_product_inprocess_contract as second_contract
import current_product_inprocess_diagnostic as second
import current_product_aar_recheck_contract as contract
import current_product_aar_recheck_diagnostic as diagnostic


OLD_PAIRS = [(first_contract, first), (second_contract, second)]


def empty(module):
    return {"schema": 1, "task": module.TASK, "owner_authorized": True,
            "max_attempts": module.MAX_ATTEMPTS, "legacy_claims_reused": False,
            "G2": False, "reservations": []}


def reserve(module, ledger, number):
    return module.next_reservation(ledger, manifest_sha256=format(number, "064x"),
                                   command_sha256=format(number + 100, "064x"))


class AarRecheckNamespaceTests(unittest.TestCase):
    def test_single_attempt_rejects_second_without_input_mutation(self):
        initial = empty(contract)
        before = copy.deepcopy(initial)
        reserved = reserve(contract, initial, 1)
        self.assertEqual(initial, before)
        self.assertIsNot(reserved, initial)
        self.assertIsNot(reserved["reservations"], initial["reservations"])
        self.assertEqual(len(reserved["reservations"]), 1)
        self.assertEqual(reserved["max_attempts"], 1)
        self.assertIs(reserved["G2"], False)
        self.assertIs(reserved["legacy_claims_reused"], False)
        before = copy.deepcopy(reserved)
        with self.assertRaises(ValueError):
            reserve(contract, reserved, 2)
        self.assertEqual(reserved, before)
        for invalid in [True, 1.0, 2, 3]:
            with self.subTest(max_attempts=invalid), self.assertRaises(ValueError):
                contract.validate_ledger({**initial, "max_attempts": invalid})

    def test_contracts_reject_both_old_tasks_in_both_directions(self):
        self.assertEqual(contract.TASK, "v1015-aar-registration-config-20261102")
        for old_contract, _ in OLD_PAIRS:
            for receiver, source in [(contract, old_contract), (old_contract, contract)]:
                ledger = reserve(source, empty(source), 1)
                before = copy.deepcopy(ledger)
                with self.subTest(receiver=receiver.TASK, source=source.TASK):
                    with self.assertRaises(ValueError):
                        receiver.validate_ledger(ledger)
                    with self.assertRaises(ValueError):
                        reserve(receiver, ledger, 2)
                    self.assertEqual(ledger, before)

    def test_new_ledger_preserves_old_controllers_and_full_ledger_fixtures(self):
        old_states = [(module.TASK, module.TASK_ROOT, copy.deepcopy(module.properties()),
                       Path(module.__file__).read_bytes()) for _, module in OLD_PAIRS]
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary).resolve()
            fixtures = []
            for index, (old_contract, module) in enumerate(OLD_PAIRS):
                root = parent / f"old-{index}"
                root.mkdir()
                (root / "controller.py").write_bytes(old_states[index][3])
                ledger = empty(old_contract)
                for number in range(1, 4):
                    ledger = reserve(old_contract, ledger, number)
                    old_contract.validate_ledger(ledger)
                    (root / f"reservation-{number}.json").write_text(
                        json.dumps(ledger, indent=2) + "\n", encoding="utf-8")
                fixtures.append((root, {p.name: p.read_bytes() for p in root.iterdir()}))
            root = parent / "new"
            root.mkdir()
            with patch.object(diagnostic, "TASK_ROOT", root):
                self.assertEqual(diagnostic.ledger(), empty(contract))
                result = reserve(contract, diagnostic.ledger(), 1)
                diagnostic.put(root / "reservation-1.json", result)
                self.assertEqual(diagnostic.ledger(), result)
            for old_root, before in fixtures:
                self.assertEqual({p.name: p.read_bytes() for p in old_root.iterdir()}, before)
        for (_, module), before in zip(OLD_PAIRS, old_states):
            self.assertEqual((module.TASK, module.TASK_ROOT, module.properties(),
                              Path(module.__file__).read_bytes()), before)
        self.assertEqual(first_contract.MAX_ATTEMPTS, 3)
        self.assertEqual(second_contract.MAX_ATTEMPTS, 3)

    def test_ledger_rejects_extra_reservation_two(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            with patch.object(diagnostic, "TASK_ROOT", root):
                valid = reserve(contract, empty(contract), 1)
                diagnostic.put(root / "reservation-1.json", valid)
                self.assertEqual(diagnostic.ledger(), valid)
                extra = root / "reservation-2.json"
                extra.write_text("{}\n", encoding="utf-8")
                before = {p.name: p.read_bytes() for p in root.iterdir()}
                with self.assertRaisesRegex(ValueError, "Unexpected permanent reservation"):
                    diagnostic.ledger()
                self.assertEqual({p.name: p.read_bytes() for p in root.iterdir()}, before)

    def test_old_answers_and_boolean_limit_rejected_before_side_effects(self):
        cases = [("授权上述独立3次诊断范围", 1), ("授权新增独立最多3次诊断", 1),
                 ("授权独立最多1次禁网复验", True)]
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            for answer, limit in cases:
                (root / "owner-authorization.json").write_text(json.dumps({
                    "owner_answer": answer, "max_attempts": limit}), encoding="utf-8")
                for mode in ["qualify", "gradle"]:
                    with self.subTest(answer=answer, limit=limit, mode=mode), \
                            patch.object(diagnostic, "TASK_ROOT", root), \
                            patch.object(Path, "mkdir") as mkdir, \
                            patch.object(diagnostic, "qualified_monitor") as qualified, \
                            patch.object(diagnostic.subprocess, "run") as run, \
                            patch.object(diagnostic.subprocess, "Popen") as popen, \
                            patch.object(diagnostic, "product_inputs") as inputs:
                        with self.assertRaisesRegex(ValueError, "Missing explicit new authorization"):
                            diagnostic.prepare(root / "attempt", mode)
                        for operation in [mkdir, qualified, run, popen, inputs]:
                            operation.assert_not_called()
                        self.assertFalse((root / "attempt").exists())

    def test_new_and_both_old_qualification_roots_mutually_reject(self):
        identity = {"bytes": 1, "file_id": [1, 2], "sha256": "c" * 64}
        arguments = {"native_sha256": "a" * 64, "controller_sha256": "b" * 64,
                     "binary_identity": identity, "manifest_sha256": "d" * 64,
                     "receipt_sha256": "e" * 64}
        base = {"schema": 2, "kind": "java-tree-and-disk-churn", "qualified": True,
                "native_source_sha256": "a" * 64, "controller_sha256": "b" * 64,
                "binary_identity": identity, "manifest_sha256": "d" * 64,
                "receipt_sha256": "e" * 64, "disk_churn_operations": 1,
                "gradle_starts": 0, "G2": False}
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary).resolve()
            for index, (_, old) in enumerate(OLD_PAIRS):
                old_root, new_root = parent / f"old-{index}", parent / "new"
                with patch.object(old, "TASK_ROOT", old_root), \
                        patch.object(diagnostic, "TASK_ROOT", new_root):
                    for receiver, own, other in [(old, old_root, new_root),
                                                  (diagnostic, new_root, old_root)]:
                        with self.subTest(receiver=receiver.TASK):
                            self.assertIsNone(receiver.validate_monitor_record(
                                {**base, "root": str(own / "fixture")}, **arguments))
                            with self.assertRaisesRegex(ValueError, "Qualification root outside task"):
                                receiver.validate_monitor_record(
                                    {**base, "root": str(other / "fixture")}, **arguments)

    def test_gradle_command_remains_offline_configuration_dry_run(self):
        with patch.object(diagnostic.subprocess, "run") as run, \
                patch.object(diagnostic.subprocess, "Popen") as popen:
            command = diagnostic.command("gradle")
            self.assertEqual(command.count("--offline"), 1)
            self.assertEqual(command.count("--dry-run"), 1)
            self.assertEqual(command[-1], "assembleAarRelease")
            self.assertIn("-Dorg.gradle.java.installations.auto-download=false", command)
            self.assertIn("-PelitesyncDiagnosticScope=" + contract.TASK, command)
            self.assertNotIn("--refresh-dependencies", command)
            self.assertFalse(any(value in command for value in ["assembleRelease", "bundleRelease", "publish", "installRelease"]))
            run.assert_not_called()
            popen.assert_not_called()


if __name__ == "__main__":
    unittest.main()
