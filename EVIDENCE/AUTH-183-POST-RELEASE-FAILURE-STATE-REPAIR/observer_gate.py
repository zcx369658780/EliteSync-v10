"""Pure in-memory observer reducer; all time values are caller-supplied fakes."""

from dataclasses import dataclass, replace
from enum import Enum


SYNTHETIC_BYTES = 4  # A count only; no payload is accepted or returned.


class Event(Enum):
    START_ENTER = "START_ENTER"
    START_RETURN = "START_RETURN"
    STREAM_ENTER = "STREAM_ENTER"
    STREAM_RETURN = "STREAM_RETURN"
    CLEANUP_ENTER = "CLEANUP_ENTER"
    CLEANUP_CONFIRMED = "CLEANUP_CONFIRMED"
    RETURN_ENTER = "RETURN_ENTER"
    RETURN_CONFIRMED = "RETURN_CONFIRMED"
    AUTH_SUCCESS = "AUTH_SUCCESS"
    ISOLATION_READY = "ISOLATION_READY"
    TREE_CLEARED = "TREE_CLEARED"
    RELEASE = "RELEASE"
    START_NOT_RETURNED = "START_NOT_RETURNED"
    CLEANUP_UNCONFIRMED = "CLEANUP_UNCONFIRMED"
    IPC_DISCONNECTED = "IPC_DISCONNECTED"
    OBSERVER_LOST = "OBSERVER_LOST"
    RESIDUAL_UNKNOWN = "RESIDUAL_UNKNOWN"
    AUTH_FAILED = "AUTH_FAILED"
    STREAM_TRUNCATED = "STREAM_TRUNCATED"
    STREAM_OVER_LIMIT = "STREAM_OVER_LIMIT"


class Status(Enum):
    ACTIVE = "ACTIVE"
    RESIDUAL_UNKNOWN = "RESIDUAL_UNKNOWN"
    BLOCKED = "BLOCKED"
    SYNTHETIC_ONLY = "SYNTHETIC_ONLY"


class Reason(Enum):
    NONE = "NONE"
    DEADLINE_EXCEEDED = "DEADLINE_EXCEEDED"
    START_NOT_RETURNED = "START_NOT_RETURNED"
    CLEANUP_UNCONFIRMED = "CLEANUP_UNCONFIRMED"
    IPC_DISCONNECTED = "IPC_DISCONNECTED"
    OBSERVER_LOST = "OBSERVER_LOST"
    RESIDUAL_UNKNOWN = "RESIDUAL_UNKNOWN"
    AUTH_FAILED = "AUTH_FAILED"
    STREAM_TRUNCATED = "STREAM_TRUNCATED"
    STREAM_OVER_LIMIT = "STREAM_OVER_LIMIT"
    INVALID_SEQUENCE = "INVALID_SEQUENCE"
    INVALID_TIME = "INVALID_TIME"
    DUPLICATE_RELEASE = "DUPLICATE_RELEASE"


ORDER = (
    Event.START_ENTER,
    Event.START_RETURN,
    Event.STREAM_ENTER,
    Event.STREAM_RETURN,
    Event.CLEANUP_ENTER,
    Event.CLEANUP_CONFIRMED,
    Event.RETURN_ENTER,
    Event.RETURN_CONFIRMED,
    Event.AUTH_SUCCESS,
    Event.ISOLATION_READY,
    Event.TREE_CLEARED,
    Event.RELEASE,
)

UNKNOWN_EVENTS = {
    Event.START_NOT_RETURNED,
    Event.CLEANUP_UNCONFIRMED,
    Event.IPC_DISCONNECTED,
    Event.OBSERVER_LOST,
    Event.RESIDUAL_UNKNOWN,
}
FAILED_EVENTS = {
    Event.AUTH_FAILED,
    Event.STREAM_TRUNCATED,
    Event.STREAM_OVER_LIMIT,
}


@dataclass(frozen=True)
class State:
    deadline: int
    last_at: int
    next_index: int
    status: Status
    reason: Reason
    consumer_calls: int
    consumer_bytes: int


def start_observation(deadline: int) -> State:
    """Set the sole absolute fake deadline before the first stage."""
    if type(deadline) is not int or deadline < 0:
        raise ValueError("deadline must be a non-negative integer")
    return State(deadline, 0, 0, Status.ACTIVE, Reason.NONE, 0, 0)


def reduce(state: State, event: Event, at: int) -> State:
    """Return a new state; never read a system clock or reset the deadline."""
    if not isinstance(state, State) or not isinstance(event, Event):
        raise TypeError("state and event must use the fixed schema")
    if type(at) is not int or at < 0:
        raise ValueError("at must be a non-negative integer")

    if state.status is Status.SYNTHETIC_ONLY:
        # A delivery already happened. Reclassify later trouble without erasing it.
        if at < state.last_at:
            return replace(state, status=Status.BLOCKED, reason=Reason.INVALID_TIME)
        if at > state.deadline:
            return replace(
                state, last_at=at, status=Status.RESIDUAL_UNKNOWN,
                reason=Reason.DEADLINE_EXCEEDED,
            )
        if event in UNKNOWN_EVENTS:
            return replace(
                state, last_at=at, status=Status.RESIDUAL_UNKNOWN,
                reason=Reason[event.name],
            )
        if event in FAILED_EVENTS:
            return replace(
                state, last_at=at, status=Status.BLOCKED,
                reason=Reason[event.name],
            )
        return replace(
            state, last_at=at, status=Status.BLOCKED,
            reason=Reason.DUPLICATE_RELEASE if event is Event.RELEASE else Reason.INVALID_SEQUENCE,
        )
    if state.status is not Status.ACTIVE:
        return state  # Failure and unknown states cannot be cleared by late events.
    if at < state.last_at:
        return replace(state, status=Status.BLOCKED, reason=Reason.INVALID_TIME)
    if at > state.deadline:
        return replace(
            state, last_at=at, status=Status.RESIDUAL_UNKNOWN,
            reason=Reason.DEADLINE_EXCEEDED,
        )
    if event in UNKNOWN_EVENTS:
        return replace(
            state, last_at=at, status=Status.RESIDUAL_UNKNOWN,
            reason=Reason[event.name],
        )
    if event in FAILED_EVENTS:
        return replace(
            state, last_at=at, status=Status.BLOCKED,
            reason=Reason[event.name],
        )
    if event is not ORDER[state.next_index]:
        return replace(
            state, last_at=at, status=Status.BLOCKED,
            reason=Reason.INVALID_SEQUENCE,
        )
    if event is Event.RELEASE:
        return replace(
            state, last_at=at, next_index=state.next_index + 1,
            status=Status.SYNTHETIC_ONLY,
            consumer_calls=state.consumer_calls + 1,
            consumer_bytes=state.consumer_bytes + SYNTHETIC_BYTES,
        )
    return replace(state, last_at=at, next_index=state.next_index + 1)
