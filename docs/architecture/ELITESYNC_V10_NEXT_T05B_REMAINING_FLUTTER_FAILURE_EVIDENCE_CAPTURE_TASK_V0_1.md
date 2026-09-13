# EliteSync v10｜NEXT-T05B Remaining Flutter Failure Evidence Capture Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — EVIDENCE CAPTURE / TRIAGE ONLY — NO REPAIRS`

Repository: `zcx369658780/EliteSync-v10`

Current accepted predecessor:

`94e72b5a5aab87fc8705fab19da0a41dda9e0108`

Accepted T05-A candidate:

`4b76981ad369c0596f0a934e73b7d18bd20c478b`

Accepted T04 triage established:

- F01-F07: now repaired and accepted;
- F08-F35: 28 failures remain `UNRESOLVED` because their individual identities/messages were not durably retained;
- no product regression was established for those unresolved failures;
- missing evidence must not be interpreted as harmlessness.

## 1. Objective

Reconstruct durable, exact evidence for the remaining 28 unresolved Flutter test failures under the current accepted source, without repairing them.

The task must establish for each currently failing instance, where reproducible:

- exact test file;
- exact test/group identity;
- failure assertion or exception message;
- relevant stack location(s);
- whether the failure reproduces on current accepted source;
- bounded first-pass classification;
- whether it plausibly threatens an accepted MVP invariant.

This is evidence-capture and triage work only. It does not authorize product or test repair.

## 2. Fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_DETERMINISTIC_TEST_DEBT_REPAIR_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `94e72b5a5aab87fc8705fab19da0a41dda9e0108`, inspect intervening commits before proceeding. If Flutter source/tests or accepted authority changed materially, stop and report the conflict.

## 3. Exact execution authority

This task authorizes a fresh bounded Flutter test evidence run only to reconstruct the remaining non-green suite evidence.

Within `apps/flutter_elitesync_module`:

- if `.dart_tool/package_config.json` is absent, one bounded `flutter pub get --enforce-lockfile` is authorized using only the already-declared locked dependency graph;
- run `flutter test` with an expanded or machine-readable reporter sufficient to capture each failing test identity/message/stack;
- preserve the complete failure identity set in the result artifact;
- targeted reruns of individual failing files/cases are allowed only when necessary to disambiguate a captured failure, and must not be used to repair it.

Do not run the analyzer unless needed to prove a test compilation issue that cannot otherwise be classified; analyzer repair remains out of scope.

## 4. Relationship to F01-F07

F01-F07 were repaired and accepted in T05-A.

The evidence run may demonstrate that the total suite failure count is lower than the prior Track 3 `35` because those seven deterministic failures are now green.

Do not reinterpret that count change as proof that every prior F08-F35 failure still exists. The objective is to identify the current remaining failure set exactly.

The result artifact must reconcile:

- prior Track 3 aggregate `35`;
- seven accepted T05-A repairs;
- current full-suite failing identities;
- any previously unresolved failure that no longer reproduces.

## 5. Required classifications

For every current failing instance, classify into one of:

- `STALE_TEST_EXPECTATION`
- `PRODUCT_REGRESSION_CANDIDATE`
- `TEST_HARNESS_OR_FIXTURE_DEFECT`
- `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC`
- `ENVIRONMENT_OR_TOOLING_FAILURE`
- `DEPENDENCY_OR_PACKAGE_FAILURE`
- `UNRESOLVED`

Classification must be evidence-backed. Do not repair or silently downgrade a failure.

For `PRODUCT_REGRESSION_CANDIDATE`, identify the exact accepted MVP invariant or accepted product contract that appears contradicted. This label is still a candidate finding and does not itself reopen MVP acceptance.

For `UNRESOLVED`, state exactly what additional evidence is missing.

## 6. Required output artifact

Create exactly one new artifact:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`

It must contain at minimum:

1. fresh authority and tool identity;
2. package-graph disposition;
3. exact full-suite command and outcome;
4. exact reconciliation against prior `35` and repaired F01-F07;
5. complete per-failure ledger with test identity/message/stack;
6. first-pass classification for every current failure;
7. MVP-invariant impact assessment;
8. files/areas implicated by each failure;
9. failures that no longer reproduce, if any, without guessing why;
10. explicit list of evidence still unresolved;
11. recommended bounded repair/triage sequencing;
12. explicit non-goals and stop boundary.

Do not modify the accepted T04 or T05-A artifacts.

## 7. Explicit exclusions

Do NOT:

- modify product source;
- modify test source;
- modify dependencies or lockfiles;
- add, remove, skip, mute, quarantine, or weaken tests;
- change authority/consent gates;
- create fake Connection or messaging consent evidence;
- add product theme fallbacks;
- repair any current failure;
- repair analyzer findings A01-A21;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate configuration;
- use emulator/ADB unless a captured test explicitly requires platform execution and the task is separately reauthorized;
- perform backend/API/database/service work;
- perform new legal/data-rights work;
- remove compatibility debt;
- start Phase 2;
- inspect private participant/Profile/Conversation data;
- perform telemetry or Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3.

## 8. Git boundary

Recommended branch:

`review/next-t05b-remaining-flutter-failure-evidence-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`

No product or test source change is permitted.

Recommended commit message:

`docs: capture remaining Flutter failure evidence`

Publish the candidate branch/commit for independent review.

Do not merge or self-accept.

## 9. Completion classification

Successful completion should end substantially as:

`REMAINING FLUTTER FAILURE EVIDENCE CAPTURED — CURRENT NON-GREEN TEST IDENTITIES/CAUSE CANDIDATES EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / BOUNDED REPAIR PLANNING`

Stop after publishing the evidence candidate.
