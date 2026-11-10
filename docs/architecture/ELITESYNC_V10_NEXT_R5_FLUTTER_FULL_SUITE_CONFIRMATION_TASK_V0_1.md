# EliteSync v10｜NEXT-R5 Flutter Full-Suite Confirmation Task｜v0.1

Status: `OWNER-AUTHORIZED CONFIRMATION TASK — EXECUTION / EVIDENCE ONLY — NO REPAIR`

Repository: `zcx369658780/EliteSync-v10`

Current publication base:

`132e1079b7203afaaa62050a18e7d4efe3f4337f`

## 1. Objective

Run a fresh bounded Flutter full-suite confirmation after accepted R1-R4 repairs and record the exact current test state.

This task exists to answer one question only:

> Does the current accepted repair chain produce a green full Flutter test suite in a fresh bounded worktree?

This task is evidence/confirmation only. It does not authorize repair, source modification, analyzer cleanup, dependency changes, or new product work.

## 2. Required fresh-start gate

Before execution:

1. `git fetch origin`;
2. verify fresh `origin/main`;
3. read `AGENTS.md` FIRST;
4. read, in order:
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_ACCEPTANCE_V0_1.md`;
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_ACCEPTANCE_V0_1.md`;
   - accepted R1, R2, R3, and R4 repair acceptance artifacts;
   - this task sheet.
5. If `origin/main` differs from `132e1079b7203afaaa62050a18e7d4efe3f4337f`, inspect intervening commits. Stop if they alter Flutter test/source authority materially.

## 3. Authorized execution

Within `apps/flutter_elitesync_module`:

1. If `.dart_tool/package_config.json` is absent, run exactly one:

   `flutter pub get --enforce-lockfile`

   This is permitted only for already-declared locked dependencies. Do not add/change dependencies or lockfile content.

2. Run exactly one primary full-suite confirmation:

   `flutter test --reporter expanded`

3. If the expanded output is truncated by host transport and the suite is non-green, one machine-readable rerun is authorized solely to capture exact failing identities/messages:

   `flutter test --no-pub --reporter json`

4. Do not run the analyzer in this task.

## 4. Required evidence

Record:

- Flutter/Dart identities;
- package-graph restoration status if needed;
- exact full-suite command;
- exit code;
- final pass/fail count;
- whether all previously repaired groups remain green;
- if non-green, exact current failing identities/messages/stacks without guessing;
- whether any new failure appears outside the previously known groups;
- dependency and lockfile hashes before/after if package restoration occurs;
- exact tracked-file scope.

## 5. Explicit exclusions

Do NOT:

- modify product source;
- modify test source;
- modify dependencies or lockfile;
- skip, quarantine, suppress, or rewrite failing tests;
- run `flutter analyze`;
- repair any newly observed failure;
- modify backend/API/database/service code;
- perform legal/data-rights work;
- remove compatibility debt;
- start Phase 2;
- inspect private data;
- perform telemetry or Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration.

## 6. Required output artifact

Create exactly one result artifact:

`docs/architecture/ELITESYNC_V10_FLUTTER_FULL_SUITE_CONFIRMATION_RESULT_V0_1.md`

Candidate scope must contain only that result artifact.

No product/test source change is permitted.

## 7. Classification

If the full suite is green, finish substantially as:

`FLUTTER FULL-SUITE CONFIRMATION GREEN — ACCEPTED REPAIR CHAIN INTEGRATES — NO SOURCE CHANGES PERFORMED — READY FOR INDEPENDENT REVIEW`

If non-green, preserve the exact current failure evidence and finish substantially as:

`FLUTTER FULL-SUITE CONFIRMATION NON-GREEN — CURRENT FAILURES EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / NEXT BOUNDED TRIAGE`

Stop after publishing the result candidate. Do not merge, self-accept, or start successor work.
