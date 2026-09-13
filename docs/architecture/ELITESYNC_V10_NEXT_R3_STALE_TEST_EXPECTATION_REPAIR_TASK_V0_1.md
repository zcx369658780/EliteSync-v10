# EliteSync v10｜NEXT-R3 Stale Test Expectation Repair Task｜v0.1

Status: `OWNER-AUTHORIZED TEST-ONLY REPAIR TASK — C21-C25 / C27 / C28 ONLY`

Repository: `zcx369658780/EliteSync-v10`

Current R2 acceptance predecessor:

`7653fb3899e00529963211a0dfc8b5fd6a7749fd`

Accepted R2 candidate:

`44b91f1c0325fef6bb06029277d1886689a91ae0`

Accepted T05-B evidence artifact:

`docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`

## 1. Objective

Repair only the seven accepted `STALE_TEST_EXPECTATION` failures from T05-B:

- C21-C25;
- C27;
- C28.

This is a test-only repair task. Production behavior is already aligned with accepted product/privacy contracts on the current evidence.

Do not modify product source to satisfy stale tests.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_REMAINING_FLUTTER_FAILURE_EVIDENCE_CAPTURE_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_NOTIFICATION_FEEDBACK_COMPOSITION_REPAIR_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If fresh `origin/main` differs from `7653fb3899e00529963211a0dfc8b5fd6a7749fd`, inspect intervening commits before proceeding. Stop if they materially alter the seven target tests or accepted product semantics.

## 3. Authorized target failures

Repair exactly:

### C21

`test/features/onboarding/presentation/first_use_onboarding_page_test.dart`

`the public contract contains exactly five truthful steps`

Update the stale expected step body to the currently accepted product copy including the disclaimer that completing onboarding does not establish account setup or readiness.

Do not weaken that disclaimer.

### C22-C25

Same test file. These tests still look for/tap the stale text `完成` while the accepted current action is `完成引导` with semantic label `完成首次使用引导`.

Update the tests to target current accepted UI semantics.

Preserve the original behavior assertions for completion persistence/failure/timeout/replay return flow.

### C27

`test/features/notification/presentation/pages/notification_center_page_test.dart`

`card tap on unsupported route does not mark notification as read`

The stale test attempts to tap the raw payload title `未知跳转卡片`, but the accepted product deliberately uses privacy-sanitized in-app preview through `NotificationPrivacyContract`.

Update the test to interact with the currently rendered generic/privacy-safe surface without exposing or requiring raw payload identity/title.

Preserve the core assertion: unsupported route/open must not be treated as successful and must not be marked read.

### C28

`test/features/profile/presentation/pages/settings_page_test.dart`

`Settings replay completion returns to canonical Home`

Update stale completion-label interaction from `完成` to the accepted current onboarding completion affordance.

Preserve the canonical Home return assertion.

## 4. Allowed files

Product source modification is prohibited.

The only test files authorized for modification are:

1. `apps/flutter_elitesync_module/test/features/onboarding/presentation/first_use_onboarding_page_test.dart`
2. `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart`
3. `apps/flutter_elitesync_module/test/features/profile/presentation/pages/settings_page_test.dart`

Plus exactly one required result artifact:

`docs/architecture/ELITESYNC_V10_STALE_TEST_EXPECTATION_REPAIR_RESULT_V0_1.md`

Do not modify any `lib/**` file.

## 5. Binding invariants

Preserve exactly:

- onboarding explanation completion != authoritative Readiness/account completion;
- `STATE VOCABULARY != AUTHORITY`;
- `ROUTE IDENTITY != CONSENT`;
- notification raw payload identity/title != display/audience authority;
- generic privacy-minimal notification presentation remains accepted;
- unsupported notification action must not be silently treated as successful or marked read;
- current production copy must not be reverted merely to satisfy old tests.

Do not re-open APP-T12-B01.

## 6. Verification authority

If `.dart_tool/package_config.json` is absent in the bounded fresh worktree, one locked restoration is authorized:

`flutter pub get --enforce-lockfile`

Do not change `pubspec.yaml` or `pubspec.lock`.

Run bounded RED/GREEN targeted tests only for the three authorized test files.

Recommended commands after package graph exists:

- `flutter test --no-pub test/features/onboarding/presentation/first_use_onboarding_page_test.dart --reporter expanded`
- `flutter test --no-pub test/features/notification/presentation/pages/notification_center_page_test.dart --reporter expanded`
- `flutter test --no-pub test/features/profile/presentation/pages/settings_page_test.dart --reporter expanded`

A full suite or analyzer run is not authorized by R3.

The result must report the exact target-case before/after evidence or, if file-level execution includes unrelated cases, explicitly separate the seven target identities from any other results.

## 7. Explicit exclusions

Do NOT:

- modify product source;
- alter onboarding copy or behavior;
- weaken readiness/account disclaimers;
- expose raw notification payload titles/identity;
- weaken notification privacy or mark-read rules;
- repair C01;
- repair analyzer A01-A21;
- perform backend/legal/compatibility/Phase-2 work;
- resume Sandbox/DEP13/B12/M2/M3;
- modify dependencies, lockfiles, generated source, or global environment;
- run emulator/ADB;
- inspect private participant data.

## 8. Delivery boundary

Recommended branch:

`repair/next-r3-stale-test-expectations-v0-1`

Commit only the three authorized test files that actually require changes plus:

`docs/architecture/ELITESYNC_V10_STALE_TEST_EXPECTATION_REPAIR_RESULT_V0_1.md`

Recommended commit message:

`test: repair stale Flutter expectations`

Publish the candidate branch/commit for independent review.

Do not merge or self-accept.

## 9. Completion classification

Successful completion should end substantially as:

`STALE FLUTTER TEST EXPECTATIONS REPAIRED — C21-C25/C27/C28 TARGETED EVIDENCE GREEN — PRODUCT AND PRIVACY SEMANTICS UNCHANGED — READY FOR INDEPENDENT REVIEW`

Stop after publishing the candidate.
