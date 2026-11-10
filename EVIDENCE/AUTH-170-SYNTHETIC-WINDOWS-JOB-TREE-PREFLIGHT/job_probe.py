"""Fail-closed static entry for the proposed Windows Job synthetic preflight.

No process, Job, service, shell, or external tool is created here. The fixed
artificial parent/descendant exercise is unavailable until assign-before-resume
and bounded failed-assignment cleanup have a reviewed implementation.
"""

from __future__ import annotations


def run_preflight() -> dict[str, str | int | bool]:
    """Return a limited UNAVAILABLE receipt without trying a child launch."""
    return {
        "status": "UNAVAILABLE",
        "reason": "SUSPENDED_ASSIGNMENT_AND_BOUNDED_CLEANUP_NOT_ESTABLISHED",
        "synthetic_launch_attempts": 0,
        "job_creation_attempts": 0,
        "resume_attempts": 0,
        "parent_observed": "NOT_STARTED",
        "descendant_observed": "NOT_STARTED",
        "tree_proof": "NOT_CHECKED",
        "start_limit_enforced": False,
        "cleanup_limit_enforced": False,
        "residual_state": "NOT_APPLICABLE_NO_LAUNCH",
    }
