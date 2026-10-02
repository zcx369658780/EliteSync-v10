"""Fixed synthetic A/B release-state exercise; no CMS, files, commands, or DB."""

from __future__ import annotations

from dataclasses import dataclass


_PATHS = frozenset({"A_MEMORY", "B_ENCRYPTED_STATE_ONLY"})
_SCENARIOS = frozenset({
    "normal", "partial_auth_nonzero", "truncated", "tampered", "wrong_key",
    "capacity_limit", "timeout", "interrupted", "cleanup_failure",
    "input_mismatch", "capture_incomplete", "staging_unsafe",
    "object_replaced", "duplicate_release", "import_failure",
})
_FIXED_SYNTHETIC_BYTE_COUNT = 4


@dataclass(frozen=True)
class _Evidence:
    input_matches: bool = True
    capture_complete: bool = True
    auth_exit_zero: bool = True
    staging_safe: bool = True
    cleanup_known: bool = True
    aborted: bool = False
    failure: str | None = None


class _FakeConsumer:
    """Counts the actual mock call before an optional simulated import failure."""

    def __init__(self, fail_after_count: bool = False) -> None:
        self.calls = 0
        self.bytes = 0
        self.fail_after_count = fail_after_count

    def consume(self, byte_count: int) -> None:
        self.calls += 1
        self.bytes += byte_count
        if self.fail_after_count:
            raise RuntimeError("synthetic import failure")


class _Gate:
    def __init__(self, path: str) -> None:
        if path not in _PATHS:
            raise ValueError("unknown synthetic path")
        self.path = path
        self.state = "UNBOUND"
        self.reason = "NOT_STARTED"
        self.cleanup = "UNKNOWN"
        self._sealed_identity: object | None = None
        self._current_identity: object | None = None
        self._released = False

    def evaluate(self, evidence: _Evidence) -> None:
        if self.state != "UNBOUND":
            raise RuntimeError("single evaluation only")
        if not evidence.input_matches:
            self._deny("INPUT_MISMATCH")
        elif evidence.aborted:
            self._deny(evidence.failure or "INTERRUPTED")
        elif not evidence.staging_safe:
            self._deny(evidence.failure or "STAGING_UNSAFE")
        elif not evidence.capture_complete:
            self._deny(evidence.failure or "CAPTURE_INCOMPLETE")
        elif not evidence.auth_exit_zero:
            self._deny(evidence.failure or "AUTH_FAIL")
        elif not evidence.cleanup_known:
            self._deny("CLEANUP_UNKNOWN")
        else:
            # B models a sealed *state* only. No encryption or storage exists.
            self._sealed_identity = object()
            self._current_identity = self._sealed_identity
            self.state = "SEALED_UNRELEASED"
            self.reason = "READY_FOR_SYNTHETIC_RELEASE"

    def replace_identity_for_test(self) -> None:
        if self.state != "SEALED_UNRELEASED":
            raise RuntimeError("not sealed")
        self._current_identity = object()

    def release(self, consumer: _FakeConsumer) -> bool:
        if self._released:
            self.reason = "DUPLICATE_DENIED"
            return False
        if self.state != "SEALED_UNRELEASED":
            return False
        if self._current_identity is not self._sealed_identity:
            self._deny("OBJECT_MISMATCH")
            return False
        self._released = True  # Consumed before calling the mock; exceptions cannot replay it.
        self.state = "ONE_CONSUMER_RELEASED"
        try:
            consumer.consume(_FIXED_SYNTHETIC_BYTE_COUNT)
        except RuntimeError:
            self.state = "IMPORT_FAILED_ISOLATED"
            self.reason = "IMPORT_FAIL_ACTUAL_COUNT_RETAINED"
            return False
        self.reason = "SYNTHETIC_IMPORT_COMPLETE"
        return True

    def _deny(self, reason: str) -> None:
        self.state = "FAILED_PRE_RELEASE"
        self.reason = reason
        self.cleanup = "UNKNOWN"

    def receipt(self, consumer: _FakeConsumer) -> dict[str, str | int]:
        return {
            "path": self.path,
            "state": self.state,
            "reason": self.reason,
            "cleanup": self.cleanup,
            "consumer_calls": consumer.calls,
            "consumer_bytes": consumer.bytes,
        }


def _evidence_for(scenario: str) -> _Evidence:
    if scenario == "partial_auth_nonzero":
        # Partial output exists in the synthetic state, but is never passed on.
        return _Evidence(auth_exit_zero=False, failure="AUTH_FAIL_PARTIAL_OUTPUT")
    if scenario in {"truncated", "tampered", "wrong_key"}:
        return _Evidence(auth_exit_zero=False, failure=scenario.upper())
    if scenario == "capacity_limit":
        return _Evidence(capture_complete=False, failure="LIMIT")
    if scenario == "timeout":
        return _Evidence(aborted=True, failure="TIMEOUT")
    if scenario == "interrupted":
        return _Evidence(aborted=True, failure="INTERRUPTED")
    if scenario == "cleanup_failure":
        return _Evidence(cleanup_known=False)
    if scenario == "input_mismatch":
        return _Evidence(input_matches=False)
    if scenario == "capture_incomplete":
        return _Evidence(capture_complete=False)
    if scenario == "staging_unsafe":
        return _Evidence(staging_safe=False)
    return _Evidence()


def run_synthetic(path: str, scenario: str) -> dict[str, str | int]:
    """Accept only internal scenario names; return metadata, never a marker body."""
    if path not in _PATHS or scenario not in _SCENARIOS:
        raise ValueError("unknown synthetic path or scenario")
    gate = _Gate(path)
    consumer = _FakeConsumer(fail_after_count=scenario == "import_failure")
    gate.evaluate(_evidence_for(scenario))
    if scenario == "object_replaced":
        gate.replace_identity_for_test()
    gate.release(consumer)
    if scenario == "duplicate_release":
        gate.release(consumer)
    return gate.receipt(consumer)
