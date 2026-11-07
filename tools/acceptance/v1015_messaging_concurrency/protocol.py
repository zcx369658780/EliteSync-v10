"""Fail-closed checks for captured messaging concurrency evidence.

These functions validate records, not database behavior by themselves. The caller
must capture lock waits before releasing its holder and retain worker outputs.
"""
import re


EFFECT_FIELDS = (
    "message_ids", "message_hashes", "client_message_ids", "notification_ids",
    "message_event_ids", "attachment_ids",
)


def _require(condition, message):
    if not condition:
        raise ValueError(message)


def _positive_id(value):
    return type(value) is int and value > 0


def _ids(value, label):
    _require(isinstance(value, list) and all(_positive_id(item) for item in value),
             f"{label} must contain positive integer IDs")
    _require(len(value) == len(set(value)), f"{label} contains duplicate IDs")
    return set(value)


def _snapshot(value, label):
    _require(isinstance(value, dict), f"{label} must be an object")
    for field in ("message_ids", "notification_ids", "message_event_ids", "attachment_ids"):
        _ids(value.get(field), f"{label}.{field}")
    expected = {str(identity) for identity in value["message_ids"]}
    for field in ("message_hashes", "client_message_ids"):
        mapping = value.get(field)
        _require(isinstance(mapping, dict) and set(mapping) == expected,
                 f"{label}.{field} must bind exactly the captured message IDs")
        _require(all(isinstance(item, str) and item for item in mapping.values()),
                 f"{label}.{field} requires nonempty strings")
    _require(all(re.fullmatch(r"[0-9a-f]{64}", digest) for digest in value["message_hashes"].values()),
             f"{label} contains an invalid message hash")


def _authorization(snapshot, consent_state, label):
    _require(snapshot.get("cn_state") == "CN_ACTIVE", f"{label} CN must remain active")
    _require(snapshot.get("mc_states") == [consent_state, consent_state],
             f"{label} must contain both expected MC states")


def _rr(value):
    return isinstance(value, str) and value.strip().upper().replace("_", "-") == "REPEATABLE-READ"


def _request_witnesses(replies, wait_rows, holder_id, request_ids, database, locked_user_id):
    _require(_positive_id(holder_id) and _positive_id(locked_user_id), "Invalid holder or locked user ID")
    ids = _ids(request_ids, "request_ids")
    _require(len(ids) == 2 and holder_id not in ids, "Two distinct requests must differ from holder")
    _require(isinstance(database, str) and re.fullmatch(r"[A-Za-z0-9_]+", database), "Invalid database identity")
    _require(isinstance(replies, list) and len(replies) == 2, "Exactly two request replies required")
    seen = set()
    for reply in replies:
        _require(isinstance(reply, dict), "Reply must be an object")
        connection = reply.get("connection_id")
        _require(_positive_id(connection) and connection in ids and connection not in seen,
                 "Reply connections do not match the independent requests")
        seen.add(connection)
        _require(reply.get("kernel_executed") is True, "Actual HTTP kernel execution required")
        _require(reply.get("user_lock_acquired") is True, "Request user-lock acquisition missing")
        _require(type(reply.get("transaction_level")) is int and reply["transaction_level"] == 0,
                 "Request left a transaction open")
        _require(_rr(reply.get("session_isolation")), "Request isolation is not REPEATABLE-READ")
        _require(type(reply.get("status")) is int, "Invalid response status")
        _require(not any(reply.get(key) for key in ("error", "exception", "deadlock")),
                 "Worker error or deadlock cannot be accepted as a response")
    _require(seen == ids, "A request reply is missing")
    _require(isinstance(wait_rows, list), "Lock-wait rows required")
    qualified_table = f"`{database}`.`users`"
    matched = []
    for identity in request_ids:
        rows = [row for row in wait_rows if isinstance(row, dict)
                and type(row.get("waiting_connection")) is int and row["waiting_connection"] == identity
                and type(row.get("blocking_connection")) is int and row["blocking_connection"] == holder_id
                and row.get("table") == qualified_table and row.get("index") == "PRIMARY"
                and row.get("lock_data") == str(locked_user_id)]
        _require(rows, f"Exact request {identity} to holder user-row lock wait missing")
        matched.append(dict(rows[0]))
    return matched


def _one_added(before, after, label):
    old, new = set(before), set(after)
    _require(old <= new and len(new - old) == 1, f"Expected one additional {label}")
    return next(iter(new - old))


def validate_duplicate(before, after, replies, wait_rows, holder_id, request_ids,
                       database, locked_user_id, client_message_id):
    """Require genuine overlap and exactly one persisted logical message."""
    _snapshot(before, "before")
    _snapshot(after, "after")
    _authorization(before, "MC_ACTIVE", "before")
    _authorization(after, "MC_ACTIVE", "after")
    matched = _request_witnesses(replies, wait_rows, holder_id, request_ids, database, locked_user_id)
    _require(isinstance(client_message_id, str) and client_message_id, "Expected client key required")
    for reply in replies:
        _require(reply["status"] == 200 and _positive_id(reply.get("id")), "Duplicate request did not succeed")
        _require(reply.get("client_message_id") == client_message_id, "Returned client key mismatch")
        _require(type(reply.get("idempotent_replay")) is bool, "Replay classification missing")
        _require(reply.get("private_marker_present") is True, "Positive message-body marker missing")
    _require(replies[0]["id"] == replies[1]["id"], "Duplicate requests returned different messages")
    _require(sum(reply["idempotent_replay"] for reply in replies) == 1, "Exactly one replay result required")
    message_id = _one_added(before["message_ids"], after["message_ids"], "message")
    _require(message_id == replies[0]["id"], "Persisted message differs from returned identity")
    _one_added(before["notification_ids"], after["notification_ids"], "message notification")
    _one_added(before["message_event_ids"], after["message_event_ids"], "message_sent event")
    _require(before["attachment_ids"] == after["attachment_ids"], "Unexpected attachment write")
    for field in ("message_hashes", "client_message_ids"):
        _require(all(after[field][key] == value for key, value in before[field].items()),
                 f"Existing {field} changed")
    _require(after["client_message_ids"][str(message_id)] == client_message_id, "Persisted client key mismatch")
    return {"passed": True, "scenario": "concurrent_duplicate", "message_id": message_id,
            "request_connection_ids": list(request_ids), "holder_connection_id": holder_id,
            "matched_waits": matched}


def validate_revocation(before, after, replies, wait_rows, holder_id, request_ids,
                        database, locked_user_id, revoker_result):
    """Require committed MC revocation, real lock handoff, and no message effects.

    No ordering is imposed between reader acquisition and the revoker's post-
    commit acknowledgment: that acknowledgment may be emitted later.
    """
    _snapshot(before, "before")
    _snapshot(after, "after")
    _authorization(before, "MC_ACTIVE", "before")
    _authorization(after, "MC_REVOKED", "after")
    matched = _request_witnesses(replies, wait_rows, holder_id, request_ids, database, locked_user_id)
    _require(isinstance(revoker_result, dict), "Revoker result required")
    _require(type(revoker_result.get("status")) is int and revoker_result["status"] == 200,
             "Revocation route did not succeed")
    _require(revoker_result.get("committed") is True, "Revocation commit missing")
    _require(type(revoker_result.get("connection_id")) is int and revoker_result["connection_id"] == holder_id,
             "Revoker differs from observed lock holder")
    _require(type(revoker_result.get("transaction_level")) is int and revoker_result["transaction_level"] == 0,
             "Revoker left a transaction open")
    _require(_rr(revoker_result.get("session_isolation")), "Revoker isolation is not REPEATABLE-READ")
    _require(not any(revoker_result.get(key) for key in ("error", "exception", "deadlock")),
             "Revoker worker error cannot be accepted as committed denial")
    for reply in replies:
        _require(reply["status"] == 404 and reply.get("private_marker_present") is False,
                 "Revoked request was not a private-body-free 404")
        _require(reply.get("id") is None and reply.get("client_message_id") is None
                 and reply.get("idempotent_replay") is None, "Denied response contains success identity")
    for field in EFFECT_FIELDS:
        _require(before[field] == after[field], f"Revoked requests changed {field}")
    return {"passed": True, "scenario": "revoke_before_requests", "denied_requests": len(replies),
            "request_connection_ids": list(request_ids), "holder_connection_id": holder_id,
            "matched_waits": matched}
