# EliteSync v10｜NEXT-R4 Canonical Match Test Synchronization Repair Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — TEST-HARNESS REPAIR ONLY — NO PRODUCT SEMANTIC CHANGE`

Repository: `zcx369658780/EliteSync-v10`

Fresh task-publication base:

`5e24a749d366c146503fd6e85d9a861b5562bae3`

Accepted predecessor evidence:

- T05-B evidence capture acceptance: current C01 is the sole remaining bounded test-harness synchronization finding.
- R1 accepted: C02-C20 repaired.
- R2 accepted: C26 repaired.
- R3 accepted: C21-C25/C27/C28 repaired.

## 1. Objective

Repair only current finding C01:

`test/app/router/first_use_onboarding_router_integration_test.dart` — `authenticated shell reaches four target destinations and Match child`

Accepted first-pass classification:

`TEST_HARNESS_OR_FIXTURE_DEFECT`

The current product route `/progress/match` and `MatchShellPage` builder remain established. The defect is the test's insufficient synchronization after nested Progress -> Match navigation.

This task is test-harness repair only.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read the current MVP closeout/handoff, T05-B result + acceptance, R1/R2/R3 acceptances, then this task sheet.
5. If `origin/main` differs from `5e24a749d366c146503fd6e85d9a861b5562bae3`, inspect intervening commits before proceeding. If they alter C01, canonical Match routing, or task authority, stop and report.

## 3. Exact allowed source scope

You may modify ONLY:

`apps/flutter_elitesync_module/test/app/router/first_use_onboarding_router_integration_test.dart`

and create exactly one result artifact:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_TEST_SYNCHRONIZATION_REPAIR_RESULT_V0_1.md`

Do NOT modify any `lib/**` product source.

## 4. Required repair posture

Repair the test synchronization using the minimum stable harness correction necessary after the nested Progress -> Match navigation.

Allowed examples include:

- replacing a single insufficient `pump()` with bounded settling appropriate to existing router behavior;
- using an existing repository helper already intended for router settling if present in the same test surface;
- adding a narrow local test helper only if necessary and only within the authorized test file.

Do not:

- change `/progress/match`;
- change `MatchShellPage`;
- alter AppShell or Progress routing;
- reintroduce legacy Match behavior;
- weaken any authority/consent gate;
- change production timing or navigation solely to satisfy the test;
- add arbitrary long sleeps where deterministic router settling is available.

## 5. Required RED / GREEN evidence

Before repair, run the exact failing test or exact authorized file sufficiently to reproduce C01 RED.

After repair, run the same bounded target and establish C01 GREEN.

Preferred verification:

`flutter test --no-pub test/app/router/first_use_onboarding_router_integration_test.dart --reporter expanded`

If `.dart_tool/package_config.json` is absent in the fresh bounded worktree, one locked restoration is authorized:

`flutter pub get --enforce-lockfile`

No dependency declaration or lockfile change is authorized.

Do not run the full Flutter suite or analyzer in R4.

## 6. Binding boundaries

Preserve:

- canonical Match route is `/progress/match`;
- `Match != Connection != Conversation != Relationship`;
- `ROUTE IDENTITY != CONSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- no authoritative Compatibility total score;
- no legacy Match restoration;
- no product-source change.

## 7. Explicit exclusions

Do NOT:

- modify `lib/**`;
- modify unrelated tests;
- repair analyzer findings A01-A21;
- alter dependencies or lockfiles;
- run backend/legal/compatibility/Phase-2 work;
- resume Sandbox/DEP13/B12/M2/M3;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate configuration;
- run emulator/ADB;
- inspect private data or perform telemetry/Safety operations.

## 8. Git and delivery boundary

Recommended branch:

`repair/next-r4-canonical-match-test-sync-v0-1`

Commit only the authorized test file plus result artifact.

Recommended commit message:

`test: repair canonical Match router synchronization`

Publish candidate branch/commit for independent review.

Do not merge or self-accept.

## 9. Completion classification

Successful completion should end substantially as:

`CANONICAL MATCH TEST SYNCHRONIZATION REPAIRED — C01 GREEN — NO PRODUCT ROUTE OR AUTHORITY SEMANTICS CHANGED — READY FOR INDEPENDENT REVIEW`

Stop after publishing the candidate.
