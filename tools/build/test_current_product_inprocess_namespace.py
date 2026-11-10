"""Old/new diagnostic isolation using pure data and temporary files only."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

import current_product_diagnostic_contract as old_contract
import current_product_config_diagnostic as old
import current_product_inprocess_contract as new_contract
import current_product_inprocess_diagnostic as new


def empty_ledger(contract):
    return {"schema": 1, "task": contract.TASK, "owner_authorized": True,
            "max_attempts": 3, "legacy_claims_reused": False, "G2": False,
            "reservations": []}


def reserve(contract, ledger, number):
    return contract.next_reservation(
        ledger, manifest_sha256=format(number, "064x"),
        command_sha256=format(number + 100, "064x"))


class InprocessNamespaceTests(unittest.TestCase):
    def test_contracts_reject_each_others_task(self):
        self.assertNotEqual(old_contract.TASK, new_contract.TASK)
        for contract, other in [(old_contract, new_contract), (new_contract, old_contract)]:
            for count in [0, 3]:
                ledger = empty_ledger(other)
                for number in range(1, count + 1):
                    ledger = reserve(other, ledger, number)
                before = copy.deepcopy(ledger)
                with self.subTest(contract=contract.TASK, count=count):
                    with self.assertRaises(ValueError):
                        contract.validate_ledger(ledger)
                    with self.assertRaises(ValueError):
                        reserve(contract, ledger, 4)
                    self.assertEqual(ledger, before)

    def test_each_contract_has_three_nonmutating_reservations_and_no_fourth(self):
        for contract in [old_contract, new_contract]:
            with self.subTest(contract=contract.TASK):
                ledger = empty_ledger(contract)
                for number in range(1, 4):
                    before = copy.deepcopy(ledger)
                    result = reserve(contract, ledger, number)
                    self.assertEqual(ledger, before)
                    self.assertIsNot(result, ledger)
                    self.assertIsNot(result["reservations"], ledger["reservations"])
                    for previous, copied in zip(ledger["reservations"], result["reservations"]):
                        self.assertIsNot(previous, copied)
                    self.assertEqual(len(result["reservations"]), number)
                    contract.validate_ledger(result)
                    ledger = result
                before = copy.deepcopy(ledger)
                with self.assertRaises(ValueError):
                    reserve(contract, ledger, 4)
                self.assertEqual(ledger, before)
                self.assertEqual(ledger["max_attempts"], 3)
                self.assertIs(ledger["G2"], False)
                self.assertIs(ledger["legacy_claims_reused"], False)

    def test_new_properties_and_root_do_not_change_old_module(self):
        old_state = (old.TASK, old.TASK_ROOT, copy.deepcopy(old.properties()))
        self.assertEqual(new.TASK, "v1015-inprocess-config-20261102")
        self.assertEqual(old.TASK, "v1015-current-product-config-20261101")
        self.assertNotEqual(new.TASK_ROOT, old.TASK_ROOT)
        with tempfile.TemporaryDirectory() as temporary:
            with patch.object(new, "TASK_ROOT", Path(temporary) / "new"):
                self.assertEqual(new.properties()["elitesyncDiagnosticScope"], new_contract.TASK)
                self.assertEqual((old.TASK, old.TASK_ROOT, old.properties()), old_state)
        self.assertEqual((old.TASK, old.TASK_ROOT, old.properties()), old_state)

    def test_new_persistent_ledger_does_not_read_or_modify_old_three_records(self):
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary).resolve()
            old_root, new_root = parent / "old", parent / "new"
            old_root.mkdir()
            new_root.mkdir()
            old_ledger = empty_ledger(old_contract)
            for number in range(1, 4):
                old_ledger = reserve(old_contract, old_ledger, number)
                old_contract.validate_ledger(old_ledger)
                (old_root / f"reservation-{number}.json").write_text(
                    json.dumps(old_ledger, indent=2) + "\n", encoding="utf-8")
            before = {path.name: path.read_bytes() for path in old_root.iterdir()}
            with patch.object(new, "TASK_ROOT", new_root):
                self.assertEqual(new.ledger(), empty_ledger(new_contract))
                for number in range(1, 4):
                    current = new.ledger()
                    reserved = new.next_reservation(
                        current, manifest_sha256=format(number + 200, "064x"),
                        command_sha256=format(number + 300, "064x"))
                    new.put(new_root / f"reservation-{number}.json", reserved)
                    self.assertEqual(new.ledger(), reserved)
                    self.assertEqual(reserved["task"], new_contract.TASK)
                with self.assertRaises(ValueError):
                    reserve(new_contract, new.ledger(), 4)
            self.assertEqual({path.name: path.read_bytes() for path in old_root.iterdir()}, before)
            self.assertEqual(len(before), 3)

    def test_old_qualification_root_is_rejected_by_new_validator(self):
        with tempfile.TemporaryDirectory() as temporary:
            parent = Path(temporary).resolve()
            identity = {"bytes": 128, "file_id": [1, 2], "sha256": "c" * 64}
            arguments = {"native_sha256": "a" * 64, "controller_sha256": "b" * 64,
                         "binary_identity": identity, "manifest_sha256": "d" * 64,
                         "receipt_sha256": "e" * 64}
            record = {"schema": 2, "kind": "java-tree-and-disk-churn", "qualified": True,
                      "native_source_sha256": "a" * 64, "controller_sha256": "b" * 64,
                      "binary_identity": copy.deepcopy(identity), "manifest_sha256": "d" * 64,
                      "receipt_sha256": "e" * 64, "root": str(parent / "old" / "fixture"),
                      "disk_churn_operations": 1, "gradle_starts": 0, "G2": False}
            with patch.object(new, "TASK_ROOT", parent / "new"):
                with self.assertRaisesRegex(ValueError, "Qualification root outside task"):
                    new.validate_monitor_record(record, **arguments)
                record["root"] = str(parent / "new" / "fixture")
                self.assertIsNone(new.validate_monitor_record(record, **arguments))

    def test_old_owner_answer_rejected_before_preparation_side_effects(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary).resolve()
            (root / "owner-authorization.json").write_text(json.dumps({
                "owner_answer": "授权上述独立3次诊断范围", "max_attempts": 3
            }), encoding="utf-8")
            for mode in ["gradle", "qualify"]:
                with self.subTest(mode=mode), patch.object(new, "TASK_ROOT", root), \
                        patch.object(Path, "mkdir") as mkdir, \
                        patch.object(new, "qualified_monitor") as qualified, \
                        patch.object(new.subprocess, "run") as run, \
                        patch.object(new.subprocess, "Popen") as popen, \
                        patch.object(new, "product_inputs") as inputs:
                    with self.assertRaisesRegex(ValueError, "Missing explicit new authorization"):
                        new.prepare(root / ("attempt-" + mode), mode)
                    for operation in [mkdir, qualified, run, popen, inputs]:
                        operation.assert_not_called()
                    self.assertFalse((root / ("attempt-" + mode)).exists())


if __name__ == "__main__":
    unittest.main()
