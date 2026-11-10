"""In-memory pre-resume control flow. No platform calls or real handles."""

from dataclasses import dataclass
from enum import Enum


SYNTHETIC_IDENTITY = "AUTH177_SYNTHETIC_PARENT"
WAIT_TICKS = 1  # A bounded fake-adapter argument, not a wall-clock guarantee.


class Step(Enum):
    OK = "OK"
    FAILED = "FAILED"
    UNKNOWN = "UNKNOWN"


class ParentState(Enum):
    CREATED = "CREATED"
    NOT_CREATED = "NOT_CREATED"
    UNKNOWN = "UNKNOWN"


class WaitState(Enum):
    TERMINATED = "TERMINATED"
    TIMEOUT = "TIMEOUT"
    UNKNOWN = "UNKNOWN"


class Status(Enum):
    PRE_RESUME_STOPPED = "PRE_RESUME_STOPPED"
    RESUME_UNCERTAIN = "RESUME_UNCERTAIN"
    SYNTHETIC_PRE_RESUME_PASSED = "SYNTHETIC_PRE_RESUME_PASSED"


class Cleanup(Enum):
    NOT_REQUIRED = "NOT_REQUIRED"
    NOT_ATTEMPTED = "NOT_ATTEMPTED"
    TERMINATED_CONFIRMED = "TERMINATED_CONFIRMED"
    WAIT_TIMEOUT = "WAIT_TIMEOUT"
    WAIT_UNKNOWN = "WAIT_UNKNOWN"
    TERMINATE_FAILED = "TERMINATE_FAILED"
    HANDLE_UNKNOWN = "HANDLE_UNKNOWN"


class Residual(Enum):
    NO_PARENT_CREATED = "NO_PARENT_CREATED"
    DIRECT_PARENT_TERMINATED_CONFIRMED = "DIRECT_PARENT_TERMINATED_CONFIRMED"
    RESIDUAL_UNKNOWN = "RESIDUAL_UNKNOWN"
    NOT_ASSESSED = "NOT_ASSESSED"


@dataclass(frozen=True)
class ParentCreation:
    state: ParentState
    parent: object | None


@dataclass(frozen=True)
class Result:
    status: Status
    cleanup: Cleanup
    residual: Residual
    trace: tuple[str, ...]


def run_pre_resume(adapter, identity: str) -> Result:
    """Run only fake methods; returned data contains enum states and call names."""
    trace: list[str] = []

    def call(name: str, *args):
        trace.append(name)
        try:
            return getattr(adapter, name)(*args)
        except Exception:
            return Step.UNKNOWN

    def stopped(cleanup: Cleanup, residual: Residual) -> Result:
        return Result(Status.PRE_RESUME_STOPPED, cleanup, residual, tuple(trace))

    def clean_parent(parent: object | None) -> Result:
        trace.append("NO_RESUME")
        if parent is None:
            return stopped(Cleanup.HANDLE_UNKNOWN, Residual.RESIDUAL_UNKNOWN)
        if call("terminate_parent", parent) is not Step.OK:
            return stopped(Cleanup.TERMINATE_FAILED, Residual.RESIDUAL_UNKNOWN)
        waited = call("wait_parent", parent, WAIT_TICKS)
        if waited is WaitState.TERMINATED:
            return stopped(
                Cleanup.TERMINATED_CONFIRMED,
                Residual.DIRECT_PARENT_TERMINATED_CONFIRMED,
            )
        if waited is WaitState.TIMEOUT:
            return stopped(Cleanup.WAIT_TIMEOUT, Residual.RESIDUAL_UNKNOWN)
        return stopped(Cleanup.WAIT_UNKNOWN, Residual.RESIDUAL_UNKNOWN)

    if identity != SYNTHETIC_IDENTITY:
        return stopped(Cleanup.NOT_REQUIRED, Residual.NO_PARENT_CREATED)
    if call("create_job") is not Step.OK:
        return stopped(Cleanup.NOT_REQUIRED, Residual.NO_PARENT_CREATED)
    if call("configure_limits") is not Step.OK:
        return stopped(Cleanup.NOT_REQUIRED, Residual.NO_PARENT_CREATED)

    creation = call("create_parent_suspended", identity)
    if not isinstance(creation, ParentCreation):
        return clean_parent(None)
    if creation.state is ParentState.NOT_CREATED and creation.parent is None:
        trace.append("NO_RESUME")
        return stopped(Cleanup.NOT_REQUIRED, Residual.NO_PARENT_CREATED)
    if creation.state is not ParentState.CREATED or creation.parent is None:
        return clean_parent(creation.parent)

    parent = creation.parent
    if call("assign_parent", parent) is not Step.OK:
        return clean_parent(parent)
    if call("verify_membership", parent) is not Step.OK:
        return clean_parent(parent)
    if call("resume_parent", parent) is not Step.OK:
        # The fake resume may have taken effect; NO_RESUME cannot be asserted.
        return Result(
            Status.RESUME_UNCERTAIN,
            Cleanup.NOT_ATTEMPTED,
            Residual.RESIDUAL_UNKNOWN,
            tuple(trace),
        )
    return Result(
        Status.SYNTHETIC_PRE_RESUME_PASSED,
        Cleanup.NOT_ATTEMPTED,
        Residual.NOT_ASSESSED,
        tuple(trace),
    )
