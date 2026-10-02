"""Only fake times, enum events, and a counted fake consumer are exercised."""

import unittest

from observer_gate import Event, ORDER, Reason, Status, reduce, start_observation


class ObserverGateTests(unittest.TestCase):
    def advance(self, events, deadline=20):
        state = start_observation(deadline)
        for at, event in enumerate(events):
            state = reduce(state, event, at)
            self.assertEqual(state.deadline, deadline)
        return state

    def blocked_zero(self, state, status, reason):
        self.assertEqual((state.status, state.reason), (status, reason))
        self.assertEqual((state.consumer_calls, state.consumer_bytes), (0, 0))

    def post_release_blocked(self, event, at, status, reason):
        state = self.advance(ORDER)
        state = reduce(state, event, at)
        self.assertEqual((state.status, state.reason), (status, reason))
        self.assertEqual((state.consumer_calls, state.consumer_bytes), (1, 4))
        self.assertEqual(state.deadline, 20)
        self.assertEqual(reduce(state, Event.RELEASE, 21), state)

    def test_explicit_success_releases_once(self):
        state = self.advance(ORDER, deadline=11)
        self.assertEqual(state.status, Status.SYNTHETIC_ONLY)
        self.assertEqual((state.consumer_calls, state.consumer_bytes), (1, 4))
        self.assertEqual(state.deadline, 11)

    def test_start_returns_after_deadline(self):
        state = reduce(start_observation(5), Event.START_ENTER, 1)
        state = reduce(state, Event.START_RETURN, 6)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.DEADLINE_EXCEEDED)
        self.assertEqual(state.deadline, 5)

    def test_stream_phase_expires_without_reset(self):
        state = self.advance(ORDER[:3], deadline=3)
        state = reduce(state, Event.STREAM_RETURN, 4)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.DEADLINE_EXCEEDED)
        self.assertEqual(state.deadline, 3)

    def test_cleanup_blocked_then_late_confirmation_stays_unknown(self):
        state = self.advance(ORDER[:5])
        state = reduce(state, Event.CLEANUP_UNCONFIRMED, 5)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.CLEANUP_UNCONFIRMED)
        self.assertEqual(reduce(state, Event.CLEANUP_CONFIRMED, 6), state)

    def test_observer_lost_stays_unknown(self):
        state = self.advance(ORDER[:2])
        state = reduce(state, Event.OBSERVER_LOST, 2)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.OBSERVER_LOST)
        self.assertEqual(reduce(state, Event.RELEASE, 3), state)

    def test_ipc_disconnected_stays_unknown(self):
        state = self.advance(ORDER[:2])
        state = reduce(state, Event.IPC_DISCONNECTED, 2)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.IPC_DISCONNECTED)

    def test_residual_unknown_cannot_be_cleared_by_late_success(self):
        state = self.advance(ORDER[:5])
        state = reduce(state, Event.RESIDUAL_UNKNOWN, 5)
        for event in ORDER[5:]:
            state = reduce(state, event, 6)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.RESIDUAL_UNKNOWN)

    def test_start_not_returned_is_unknown(self):
        state = reduce(start_observation(5), Event.START_ENTER, 1)
        state = reduce(state, Event.START_NOT_RETURNED, 2)
        self.blocked_zero(state, Status.RESIDUAL_UNKNOWN, Reason.START_NOT_RETURNED)

    def test_truncated_and_over_limit_streams_block(self):
        for event, reason in ((Event.STREAM_TRUNCATED, Reason.STREAM_TRUNCATED), (Event.STREAM_OVER_LIMIT, Reason.STREAM_OVER_LIMIT)):
            with self.subTest(event=event):
                state = self.advance(ORDER[:3])
                state = reduce(state, event, 3)
                self.blocked_zero(state, Status.BLOCKED, reason)

    def test_auth_failure_blocks(self):
        state = self.advance(ORDER[:8])
        state = reduce(state, Event.AUTH_FAILED, 8)
        self.blocked_zero(state, Status.BLOCKED, Reason.AUTH_FAILED)

    def test_out_of_order_auth_isolation_and_clear_block(self):
        for event in (Event.AUTH_SUCCESS, Event.ISOLATION_READY, Event.TREE_CLEARED):
            with self.subTest(event=event):
                state = reduce(start_observation(20), event, 0)
                self.blocked_zero(state, Status.BLOCKED, Reason.INVALID_SEQUENCE)

    def test_premature_release_blocks_and_cannot_recover(self):
        state = reduce(start_observation(20), Event.RELEASE, 0)
        self.blocked_zero(state, Status.BLOCKED, Reason.INVALID_SEQUENCE)
        for event in ORDER:
            state = reduce(state, event, 1)
        self.blocked_zero(state, Status.BLOCKED, Reason.INVALID_SEQUENCE)

    def test_duplicate_after_success_adds_no_second_delivery(self):
        state = self.advance(ORDER)
        state = reduce(state, Event.RELEASE, 12)
        self.assertEqual((state.status, state.reason), (Status.BLOCKED, Reason.DUPLICATE_RELEASE))
        self.assertEqual((state.consumer_calls, state.consumer_bytes), (1, 4))
        self.assertEqual(state.deadline, 20)

    def test_fake_time_cannot_go_backwards(self):
        state = reduce(start_observation(20), Event.START_ENTER, 5)
        state = reduce(state, Event.START_RETURN, 4)
        self.blocked_zero(state, Status.BLOCKED, Reason.INVALID_TIME)

    def test_post_release_unknown_events_preserve_history_and_block(self):
        for event, reason in (
            (Event.OBSERVER_LOST, Reason.OBSERVER_LOST),
            (Event.IPC_DISCONNECTED, Reason.IPC_DISCONNECTED),
            (Event.RESIDUAL_UNKNOWN, Reason.RESIDUAL_UNKNOWN),
            (Event.START_NOT_RETURNED, Reason.START_NOT_RETURNED),
            (Event.CLEANUP_UNCONFIRMED, Reason.CLEANUP_UNCONFIRMED),
        ):
            with self.subTest(event=event):
                self.post_release_blocked(event, 12, Status.RESIDUAL_UNKNOWN, reason)

    def test_post_release_failed_events_preserve_history_and_block(self):
        for event, reason in (
            (Event.AUTH_FAILED, Reason.AUTH_FAILED),
            (Event.STREAM_TRUNCATED, Reason.STREAM_TRUNCATED),
            (Event.STREAM_OVER_LIMIT, Reason.STREAM_OVER_LIMIT),
        ):
            with self.subTest(event=event):
                self.post_release_blocked(event, 12, Status.BLOCKED, reason)

    def test_post_release_deadline_expiry_is_unknown(self):
        self.post_release_blocked(
            Event.RETURN_CONFIRMED, 21,
            Status.RESIDUAL_UNKNOWN, Reason.DEADLINE_EXCEEDED,
        )

    def test_post_release_time_reversal_blocks(self):
        self.post_release_blocked(
            Event.RETURN_CONFIRMED, 10,
            Status.BLOCKED, Reason.INVALID_TIME,
        )

    def test_post_release_out_of_order_success_blocks(self):
        self.post_release_blocked(
            Event.AUTH_SUCCESS, 12,
            Status.BLOCKED, Reason.INVALID_SEQUENCE,
        )

    def test_post_release_duplicate_blocks_without_second_delivery(self):
        self.post_release_blocked(
            Event.RELEASE, 12,
            Status.BLOCKED, Reason.DUPLICATE_RELEASE,
        )

    def test_post_release_rejects_non_schema_event(self):
        state = self.advance(ORDER)
        with self.assertRaises(TypeError):
            reduce(state, "OBSERVER_LOST", 12)
        self.assertEqual((state.consumer_calls, state.consumer_bytes), (1, 4))


if __name__ == "__main__":
    unittest.main()
