"""Pure evidence checks; these fixtures are not a MariaDB runtime result."""
import copy
import unittest

from protocol import validate_duplicate, validate_revocation


def snapshots():
    before = {
        "message_ids": [7], "message_hashes": {"7": "a" * 64},
        "client_message_ids": {"7": "old-key"}, "notification_ids": [8],
        "message_event_ids": [9], "attachment_ids": [10],
        "cn_state": "CN_ACTIVE", "mc_states": ["MC_ACTIVE", "MC_ACTIVE"],
    }
    after = copy.deepcopy(before)
    after["message_ids"].append(11)
    after["message_hashes"]["11"] = "b" * 64
    after["client_message_ids"]["11"] = "new-key"
    after["notification_ids"].append(12)
    after["message_event_ids"].append(13)
    return before, after


def reply(connection_id, replay=False, denied=False):
    return {
        "status": 404 if denied else 200, "id": None if denied else 11,
        "client_message_id": None if denied else "new-key",
        "idempotent_replay": None if denied else replay,
        "private_marker_present": not denied, "kernel_executed": True,
        "transaction_level": 0, "session_isolation": "REPEATABLE-READ",
        "connection_id": connection_id, "user_lock_acquired": True,
    }


def waits():
    return [
        {"waiting_connection": identity, "blocking_connection": 20,
         "table": "`task_database`.`users`", "index": "PRIMARY", "lock_data": "1"}
        for identity in [21, 22]
    ]


class ProtocolTest(unittest.TestCase):
    def duplicate(self):
        before, after = snapshots()
        return [before, after, [reply(21), reply(22, replay=True)], waits(),
                20, [21, 22], "task_database", 1, "new-key"]

    def revoked(self):
        before, _ = snapshots()
        after = copy.deepcopy(before)
        after["mc_states"] = ["MC_REVOKED", "MC_REVOKED"]
        revoker = {"status": 200, "committed": True, "transaction_level": 0,
                   "session_isolation": "REPEATABLE-READ", "connection_id": 20}
        return [before, after, [reply(21, denied=True), reply(22, denied=True)],
                waits(), 20, [21, 22], "task_database", 1, revoker]

    def test_duplicate_passes_with_two_waiting_connections(self):
        result = validate_duplicate(*self.duplicate())
        self.assertTrue(result["passed"])
        self.assertEqual(result["message_id"], 11)

    def test_revocation_passes_without_commit_ack_timestamp_ordering(self):
        result = validate_revocation(*self.revoked())
        self.assertTrue(result["passed"])
        self.assertEqual(result["denied_requests"], 2)

    def test_missing_or_misdirected_wait_is_rejected(self):
        for field, value in [
            ("waiting_connection", 999), ("blocking_connection", 999),
            ("table", "`old_database`.`users`"), ("index", "secondary"),
            ("lock_data", "2"),
        ]:
            with self.subTest(field=field):
                args = self.duplicate()
                args[3][0][field] = value
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)
        args = self.duplicate()
        args[3].pop()
        with self.assertRaises(ValueError):
            validate_duplicate(*args)

    def test_duplicate_or_holder_request_connection_is_rejected(self):
        for identities in [[21, 21], [20, 22], [21], [True, 22]]:
            with self.subTest(identities=identities):
                args = self.duplicate()
                args[5] = identities
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)

    def test_foreign_response_connection_is_rejected(self):
        args = self.duplicate()
        args[2][0]["connection_id"] = 999
        with self.assertRaises(ValueError):
            validate_duplicate(*args)

    def test_kernel_isolation_transaction_and_lock_evidence_are_required(self):
        for field, value in [
            ("status", 500), ("kernel_executed", False),
            ("session_isolation", "READ-COMMITTED"), ("transaction_level", 1),
            ("user_lock_acquired", False),
        ]:
            with self.subTest(field=field):
                args = self.duplicate()
                args[2][0][field] = value
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)

    def test_rr_underscore_form_is_normalized(self):
        args = self.duplicate()
        args[2][0]["session_isolation"] = "REPEATABLE_READ"
        self.assertTrue(validate_duplicate(*args)["passed"])

    def test_duplicate_identity_and_exactly_one_replay_are_required(self):
        for field, value in [
            ("id", 12), ("client_message_id", "another-key"),
            ("idempotent_replay", False), ("private_marker_present", False),
        ]:
            with self.subTest(field=field):
                args = self.duplicate()
                args[2][1][field] = value
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)

    def test_extra_or_missing_duplicate_side_effect_is_rejected(self):
        for field in ["message_ids", "notification_ids", "message_event_ids", "attachment_ids"]:
            with self.subTest(field=field):
                args = self.duplicate()
                args[1][field].append(99)
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)
        args = self.duplicate()
        args[1]["notification_ids"] = [8]
        with self.assertRaises(ValueError):
            validate_duplicate(*args)

    def test_existing_message_body_and_key_must_not_change(self):
        for field, replacement in [("message_hashes", "c" * 64), ("client_message_ids", "changed")]:
            with self.subTest(field=field):
                args = self.duplicate()
                args[1][field]["7"] = replacement
                with self.assertRaises(ValueError):
                    validate_duplicate(*args)

    def test_new_row_must_bind_to_returned_message_and_key(self):
        args = self.duplicate()
        args[1]["client_message_ids"]["11"] = "wrong"
        with self.assertRaises(ValueError):
            validate_duplicate(*args)

    def test_duplicate_requires_live_cn_and_both_mc_rows(self):
        for state in [[], ["MC_ACTIVE"], ["MC_REVOKED", "MC_ACTIVE"]]:
            args = self.duplicate()
            args[1]["mc_states"] = state
            with self.assertRaises(ValueError):
                validate_duplicate(*args)
        args = self.duplicate()
        args[0]["cn_state"] = "CN_CLOSED"
        with self.assertRaises(ValueError):
            validate_duplicate(*args)

    def test_revocation_500_or_private_body_is_not_denial(self):
        for field, value in [("status", 500), ("private_marker_present", True), ("id", 11)]:
            args = self.revoked()
            args[2][0][field] = value
            with self.assertRaises(ValueError):
                validate_revocation(*args)

    def test_revocation_requires_persisted_both_mc_states(self):
        for states in [["MC_ACTIVE", "MC_ACTIVE"], [], ["MC_REVOKED"]]:
            args = self.revoked()
            args[1]["mc_states"] = states
            with self.assertRaises(ValueError):
                validate_revocation(*args)

    def test_revocation_requires_committed_matching_successful_writer(self):
        for field, value in [
            ("committed", False), ("status", 500), ("connection_id", 999),
            ("transaction_level", 1), ("session_isolation", "READ-COMMITTED"),
        ]:
            args = self.revoked()
            args[8][field] = value
            with self.assertRaises(ValueError):
                validate_revocation(*args)

    def test_revocation_cannot_change_message_or_notification_effects(self):
        for field in ["message_ids", "notification_ids", "message_event_ids", "attachment_ids"]:
            args = self.revoked()
            args[1][field].append(99)
            with self.assertRaises(ValueError):
                validate_revocation(*args)
        args = self.revoked()
        args[1]["message_hashes"]["7"] = "d" * 64
        with self.assertRaises(ValueError):
            validate_revocation(*args)

    def test_revocation_cannot_close_cn_to_fake_mc_case(self):
        args = self.revoked()
        args[1]["cn_state"] = "CN_CLOSED"
        with self.assertRaises(ValueError):
            validate_revocation(*args)

    def test_malformed_snapshots_raise_value_error(self):
        for bad in [None, {}, {"message_ids": [7, 7]}]:
            args = self.duplicate()
            args[0] = bad
            with self.assertRaises(ValueError):
                validate_duplicate(*args)


if __name__ == "__main__":
    unittest.main()
