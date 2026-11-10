# EliteSync v10｜Deterministic Test Debt Repair Acceptance｜v0.1

Status: `ACCEPTED — F01-F07 DETERMINISTIC TEST DEBT REPAIRED — TARGETED EVIDENCE GREEN — NO PRODUCT AUTHORITY SEMANTICS CHANGED`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`4b76981ad369c0596f0a934e73b7d18bd20c478b`

Accepted result blob:

`bf684af8a35651e937f3541f1072c2df019ceb50`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_DETERMINISTIC_TEST_DEBT_REPAIR_RESULT_V0_1.md`

## 1. Independent acceptance

The T05-A candidate is accepted for its authorized purpose.

The candidate changes exactly three authorized Flutter test files plus the result artifact and makes no `lib/**`, backend, dependency, lockfile, build, generated, or global-configuration change.

Targeted repair evidence is accepted:

- F01-F02 invalid-route recovery expectations now assert the accepted Calm State Hub surfaces rather than superseded Home copy;
- F03 Home smoke coverage now asserts accepted Calm State Hub structure;
- F04-F05 Conversation smoke coverage now preserves fail-closed behavior and proves route/legacy identity does not create messaging authority;
- F06-F07 test fixtures now supply the repository theme extension through `AppTheme.light` rather than changing product theme semantics;
- targeted evidence moved from `0/7` passing to `7/7` passing.

## 2. Authority and invariant preservation

No fake Conversation authority or consent was introduced.

Preserve:

- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- `UNKNOWN != ABSENT`;
- private Conversation != default Match/ranking/training data;
- no production theme fallback was added.

The T05-A repair does not reopen or weaken the accepted MVP integration contract.

## 3. Remaining evidence boundary

T05-A closes only F01-F07.

F08-F35 remain governed by the accepted T04 classification. In particular, 28 failures remain `UNRESOLVED` because their individual runner identities/messages were not durably retained.

Analyzer findings A01-A21 remain unchanged and unauthorized for repair by this acceptance.

## 4. Next recommended step

The next bounded task should capture exact durable evidence for the remaining 28 unresolved Flutter test failures before any repair authorization:

- exact test identity;
- source file and case name;
- assertion/exception message;
- relevant stack location;
- reproducibility under the current accepted source;
- first-pass classification without repair.

That task must not modify product/test source or infer harmlessness from missing evidence.

## 5. Final classification

`T05-A ACCEPTED — DETERMINISTIC FLUTTER TEST DEBT REPAIRED — F01-F07 TARGETED EVIDENCE GREEN — 28 UNRESOLVED FAILURES RETAINED FOR SEPARATE EVIDENCE CAPTURE`
