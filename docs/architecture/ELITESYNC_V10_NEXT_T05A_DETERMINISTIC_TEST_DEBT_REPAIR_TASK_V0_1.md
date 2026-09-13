# EliteSync v10｜NEXT-T05A Deterministic Test Debt Repair Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — TEST-ONLY REPAIR — NO PRODUCT SOURCE CHANGES`

Repository: `zcx369658780/EliteSync-v10`

Owner authorization basis: Owner approved the recommended first repair batch after T04 acceptance on 2026-09-13 (Asia/Singapore).

Fresh task-publication authority:

`20dba4fc75cbec2bcefd87c5954b8a3c9cf8136f`

Accepted T04 triage artifact:

`docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`

Accepted T04 acceptance:

`docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_ACCEPTANCE_V0_1.md`

## 1. Objective

Repair only the seven deterministic, low-semantic-risk Flutter test debts established and accepted by T04:

- five `STALE_TEST_EXPECTATION` failures: F01-F05;
- two `TEST_HARNESS_OR_FIXTURE_DEFECT` failures: F06-F07.

This task is test-only repair. It must not modify production/product source, authority gates, domain semantics, dependencies, lockfiles, or global tooling configuration.

The goal is to make these seven accepted test-debt cases align with already accepted product behavior and repository theme composition, then verify only the bounded repaired surfaces.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `20dba4fc75cbec2bcefd87c5954b8a3c9cf8136f`, inspect intervening commits before proceeding. If they materially alter the seven target tests or accepted product contracts, stop and report the conflict.

No broad repository audit is authorized.

## 3. Binding invariants

Preserve exactly:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- Block != Report
- Report != Finding
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

Do not weaken fail-closed Conversation behavior to satisfy stale tests.

Do not add a silent product-source fallback for `AppThemeX.appTokens`.

## 4. Exact authorized repair set

Only these seven T04 IDs are authorized:

### F01-F03 — stale Home/recovery expectations

Authorized files:

- `apps/flutter_elitesync_module/test/app/router/invalid_route_recovery_test.dart`
- `apps/flutter_elitesync_module/test/features/acceptance_smoke_test.dart`

Repair requirement:

- replace superseded Home copy/key expectations with assertions that reflect the already accepted Calm State Hub contract;
- preserve the actual recovery/navigation behavior being tested;
- do not change Home production source.

### F04-F05 — stale Conversation expectations

Authorized file:

- `apps/flutter_elitesync_module/test/features/acceptance_smoke_test.dart`

Repair requirement:

- update tests so they verify the accepted fail-closed Conversation behavior when authoritative Connection + mutual messaging consent are absent;
- do not fabricate local consent, fake Connection authority, fake messaging-consent authority, or provider overrides that would make unauthorized private rows/thread content appear;
- route identity, `legacyPeer`, `eligibleMatch`, stored peer identity, or existing mock data must remain insufficient to grant read/send authority;
- production Conversation source must not be changed.

### F06-F07 — missing theme fixture

Authorized file:

- `apps/flutter_elitesync_module/test/shared/presentation_state/app_presentation_state_view_test.dart`

Repair requirement:

- mount the tested widgets under the repository's actual theme composition or an equivalent test fixture that includes `AppThemeTokens`;
- preserve the original common-presentation-state assertions, including stale visibility/retry and authority-not-established protected-content behavior;
- do not change `AppThemeX`, `AppThemeTokens`, `AppPresentationStateView`, `AppEmptyState`, or any production theme/component source.

## 5. Explicitly unauthorized test findings

Do NOT repair, reclassify, or guess:

- F08-F35 (`28 UNRESOLVED`);
- any test failure not one of F01-F07;
- any analyzer finding A01-A21;
- P1 logging/data-minimization findings;
- deprecated RTC APIs;
- deprecated semantics matchers unless they are mechanically required by an authorized F01-F07 edit, in which case stop and report rather than expand scope.

Do not treat a newly observed unrelated failure as authorized repair work.

## 6. Source-write boundary

Allowed tracked modifications are test source only, limited to the three exact test files named above.

No production source modification is authorized.

Do NOT modify:

- `lib/**`;
- backend/API/database/service source;
- `pubspec.yaml`;
- `pubspec.lock`;
- Gradle/Android/iOS/build files;
- generated source;
- configuration files outside the exact test files;
- docs other than the required result artifact.

If a target test cannot be repaired without a production-source change, classify it as `BLOCKED — PRODUCT-SOURCE CHANGE REQUIRED` and stop that repair rather than crossing the boundary.

## 7. Tooling and verification authority

Use the package graph already restorable under the accepted Track 3 boundary.

Authorized verification:

1. if `.dart_tool/package_config.json` is absent in the fresh bounded worktree, run exactly:
   - `flutter pub get --enforce-lockfile`
   using already-declared locked dependencies only;
2. run targeted tests only for the three authorized test files;
3. after all authorized edits, rerun those same targeted test files;
4. run `git diff --check`;
5. verify no tracked changes exist outside the three test files plus the required result artifact.

Do not run the full Flutter test suite in this task.

Do not run full `flutter analyze` or `flutter analyze --no-pub` in this task unless a target-file-only analyzer command is already supported without scope expansion; if uncertain, skip analyzer and record that it was not required.

No emulator/ADB activity is authorized.

## 8. Required result artifact

Create exactly one result artifact:

`docs/architecture/ELITESYNC_V10_DETERMINISTIC_TEST_DEBT_REPAIR_RESULT_V0_1.md`

The result must include:

1. fresh main/task authority;
2. exact changed test files;
3. per-ID F01-F07 repair description;
4. explicit statement that no product source changed;
5. pre/post targeted test outcomes for each authorized file;
6. whether package graph restoration was needed;
7. tracked-file scope verification;
8. `git diff --check` result;
9. any target that remained blocked and why;
10. confirmation that F08-F35 and analyzer findings were untouched;
11. final classification.

## 9. Git boundary

Work on a fresh bounded branch from verified `main`.

Recommended branch:

`repair/next-t05a-deterministic-test-debt-v0-1`

Commit only:

- the three authorized test files that actually require edits;
- `docs/architecture/ELITESYNC_V10_DETERMINISTIC_TEST_DEBT_REPAIR_RESULT_V0_1.md`.

Recommended commit message:

`test: repair deterministic Flutter test debt`

Publish the candidate branch/commit for independent review.

Do not merge, self-accept, or modify `main`.

## 10. Explicit exclusions

Do NOT:

- modify product source;
- weaken or bypass Connection/Conversation authority gates;
- add fake consent or fake audience authority;
- add product theme fallbacks;
- add/change dependencies or lockfile;
- repair F08-F35;
- fix analyzer findings;
- perform backend/legal/data-rights/compatibility/Phase-2 work;
- inspect private participant/Profile/Conversation data;
- perform telemetry/analytics or Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- alter global Flutter/Dart/Gradle/Java/network/proxy/certificate configuration.

## 11. Completion classification

Successful completion should end substantially as:

`DETERMINISTIC FLUTTER TEST DEBT REPAIRED — F01-F07 TARGETED EVIDENCE GREEN OR EXPLICITLY BLOCKED — NO PRODUCT SOURCE OR AUTHORITY SEMANTICS CHANGED — READY FOR INDEPENDENT REVIEW`

Stop after publishing the repair candidate and result artifact.
