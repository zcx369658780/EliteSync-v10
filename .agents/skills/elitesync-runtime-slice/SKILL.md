---
name: elitesync-runtime-slice
description: Implement the smallest authorized EliteSync runtime or UI slice with bounded scope and validation. Use for approved Discover, Chat, Me, Settings, or related runtime changes.
---

# elitesync-runtime-slice

## Authority

The current explicit task and `AGENTS.md` outrank this skill. This skill helps
execute an already authorized runtime/UI slice; it never creates source, runtime,
test, evidence, artifact, network, device, or private-data authority.

## Purpose

Implement the smallest authorized runtime/UI slice for the current EliteSync
version without widening its source, verification, or deliverable scope.

## Trigger

- The current task expressly authorizes a runtime/UI implementation slice and its
  source paths.
- The target is Discover / Chat / Me / Settings or another UI/runtime slice.

## Required workflow

1. State the exact task authority, slice, allowed files, deliverable, and commands.
2. State what must not change and which runtime/evidence actions are not authorized.
3. Implement the smallest useful UI/runtime increment.
4. Run only the exact tests, runtime commands, and evidence collection expressly
   authorized by the current task.
5. Create only the task's required deliverable. Report completion or the exact
   blocker; do not invoke another skill or create an extra handoff/evidence file.

## Stop condition

- The smallest safe slice is implemented.
- Authorized verification is complete, with unexecuted checks reported accurately.
- No protected surface has been broken.
- If runtime/test/evidence authority is absent, stop that action and report it.
- If the slice starts touching backend contracts, truth chains, release logic, or
  unclear boundaries, stop and report the boundary without expanding scope.

## Must not do

- Do not treat this skill as implementation or runtime authorization.
- Do not touch backend contracts.
- Do not touch truth chains.
- Do not rewrite release logic.
- Do not widen the slice without approval.
- Do not automatically invoke or hand off to `elitesync-evidence-closeout`.
- Do not run tests, devices, emulators, network calls, or evidence capture unless
  the current task expressly authorizes the exact scope.
- Do not create extra handoff, result, or evidence artifacts beyond the current
  task deliverable.
