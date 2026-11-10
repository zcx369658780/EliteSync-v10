"""Synthetic-only, in-memory tests for pre-resume failure closure."""

import unittest

from pre_resume import (
    Cleanup,
    ParentCreation,
    ParentState,
    Residual,
    Status,
    Step,
    SYNTHETIC_IDENTITY,
    WAIT_TICKS,
    WaitState,
    run_pre_resume,
)


class FakeAdapter:
    def __init__(self, **responses):
        self.parent = None
        self.responses = responses
        self.calls = []

    def _respond(self, name):
        value = self.responses.get(name, Step.OK)
        if isinstance(value, Exception):
            raise value
        return value

    def create_job(self):
        self.calls.append("create_job")
        return self._respond("create_job")

    def configure_limits(self):
        self.calls.append("configure_limits")
        return self._respond("configure_limits")

    def create_parent_suspended(self, identity):
        self.calls.append("create_parent_suspended")
        assert identity == SYNTHETIC_IDENTITY
        if "create_parent_suspended" in self.responses:
            return self._respond("create_parent_suspended")
        self.parent = object()
        return ParentCreation(ParentState.CREATED, self.parent)

    def assign_parent(self, parent):
        self.calls.append("assign_parent")
        assert parent is self.parent
        return self._respond("assign_parent")

    def verify_membership(self, parent):
        self.calls.append("verify_membership")
        assert parent is self.parent
        return self._respond("verify_membership")

    def resume_parent(self, parent):
        self.calls.append("resume_parent")
        assert parent is self.parent
        return self._respond("resume_parent")

    def terminate_parent(self, parent):
        self.calls.append("terminate_parent")
        assert parent is self.parent
        return self._respond("terminate_parent")

    def wait_parent(self, parent, ticks):
        self.calls.append("wait_parent")
        assert parent is self.parent
        assert ticks == WAIT_TICKS
        return self._respond("wait_parent") if "wait_parent" in self.responses else WaitState.TERMINATED


class PreResumeTests(unittest.TestCase):
    def check_trace(self, adapter, result, expected):
        self.assertEqual(result.trace, expected)
        self.assertEqual(adapter.calls, [name for name in expected if name != "NO_RESUME"])
        self.assertEqual(adapter.calls.count("resume_parent"), expected.count("resume_parent"))

    def test_job_creation_failure_stops_before_parent(self):
        adapter = FakeAdapter(create_job=Step.FAILED)
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job",))
        self.assertEqual((result.status, result.cleanup, result.residual), (Status.PRE_RESUME_STOPPED, Cleanup.NOT_REQUIRED, Residual.NO_PARENT_CREATED))

    def test_limits_exception_stops_before_parent(self):
        adapter = FakeAdapter(configure_limits=RuntimeError("synthetic"))
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits"))
        self.assertEqual(result.cleanup, Cleanup.NOT_REQUIRED)
        self.assertEqual(result.residual, Residual.NO_PARENT_CREATED)

    def test_parent_explicitly_not_created(self):
        adapter = FakeAdapter(create_parent_suspended=ParentCreation(ParentState.NOT_CREATED, None))
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "NO_RESUME"))
        self.assertEqual(result.cleanup, Cleanup.NOT_REQUIRED)
        self.assertEqual(result.residual, Residual.NO_PARENT_CREATED)

    def test_created_parent_without_handle_is_unknown(self):
        adapter = FakeAdapter(create_parent_suspended=ParentCreation(ParentState.CREATED, None))
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "NO_RESUME"))
        self.assertEqual(result.cleanup, Cleanup.HANDLE_UNKNOWN)
        self.assertEqual(result.residual, Residual.RESIDUAL_UNKNOWN)

    def test_assignment_failure_terminates_exact_parent_and_waits(self):
        adapter = FakeAdapter(assign_parent=Step.FAILED)
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "NO_RESUME", "terminate_parent", "wait_parent"))
        self.assertEqual(result.cleanup, Cleanup.TERMINATED_CONFIRMED)
        self.assertEqual(result.residual, Residual.DIRECT_PARENT_TERMINATED_CONFIRMED)

    def test_assignment_failure_wait_timeout_is_residual_unknown(self):
        adapter = FakeAdapter(assign_parent=Step.FAILED, wait_parent=WaitState.TIMEOUT)
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "NO_RESUME", "terminate_parent", "wait_parent"))
        self.assertEqual(result.cleanup, Cleanup.WAIT_TIMEOUT)
        self.assertEqual(result.residual, Residual.RESIDUAL_UNKNOWN)

    def test_membership_unknown_never_resumes(self):
        adapter = FakeAdapter(verify_membership=Step.UNKNOWN)
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "verify_membership", "NO_RESUME", "terminate_parent", "wait_parent"))
        self.assertEqual(result.cleanup, Cleanup.TERMINATED_CONFIRMED)

    def test_terminate_failure_is_residual_unknown(self):
        adapter = FakeAdapter(assign_parent=Step.FAILED, terminate_parent=Step.FAILED)
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "NO_RESUME", "terminate_parent"))
        self.assertEqual(result.cleanup, Cleanup.TERMINATE_FAILED)
        self.assertEqual(result.residual, Residual.RESIDUAL_UNKNOWN)

    def test_all_preconditions_resume_exactly_once(self):
        adapter = FakeAdapter()
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "verify_membership", "resume_parent"))
        self.assertEqual(result.status, Status.SYNTHETIC_PRE_RESUME_PASSED)
        self.assertEqual(result.residual, Residual.NOT_ASSESSED)

    def test_resume_exception_does_not_claim_no_resume(self):
        adapter = FakeAdapter(resume_parent=RuntimeError("synthetic"))
        result = run_pre_resume(adapter, SYNTHETIC_IDENTITY)
        self.check_trace(adapter, result, ("create_job", "configure_limits", "create_parent_suspended", "assign_parent", "verify_membership", "resume_parent"))
        self.assertEqual(result.status, Status.RESUME_UNCERTAIN)
        self.assertEqual(result.residual, Residual.RESIDUAL_UNKNOWN)


if __name__ == "__main__":
    unittest.main()
