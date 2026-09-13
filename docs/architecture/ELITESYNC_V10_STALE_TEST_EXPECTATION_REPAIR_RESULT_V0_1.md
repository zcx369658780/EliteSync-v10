# EliteSync v10｜Stale Test Expectation Repair Result｜v0.1

Status: `CANDIDATE — C21-C25 / C27 / C28 STALE TEST EXPECTATIONS REPAIRED — INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-13 (Asia/Shanghai)

Fresh base:

`09a8c121cca784c77a1eab77b52852d41faf593d`

Branch:

`repair/next-r3-stale-test-expectations-v0-1`

## 1. Authorized scope and exact changed files

This candidate repairs only the seven accepted `STALE_TEST_EXPECTATION` findings C21-C25, C27, and C28.

Changed files are exactly:

1. `apps/flutter_elitesync_module/test/features/onboarding/presentation/first_use_onboarding_page_test.dart`;
2. `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart`;
3. `apps/flutter_elitesync_module/test/features/profile/presentation/pages/settings_page_test.dart`;
4. `docs/architecture/ELITESYNC_V10_STALE_TEST_EXPECTATION_REPAIR_RESULT_V0_1.md`.

No `lib/**`, product behavior, dependency input, lockfile, generated source, global configuration, backend, legal/data-rights, compatibility, or Phase-2 file was changed.

## 2. Repair disposition

### C21 — truthful onboarding public contract

The expected fifth-step body now includes the accepted disclaimer:

`完成本引导不代表账户设置或准备状态已经完成。`

The test therefore preserves, rather than weakens, the distinction between completing first-use explanation and authoritative account setup or Readiness.

### C22-C25 — accepted completion affordance

Four onboarding completion tests now locate the accepted visible action `完成引导` instead of stale text `完成`. Their original assertions remain intact for:

- completion persistence and return to the invoking app;
- write-failure dismissal behavior;
- timeout dismissal behavior;
- replay completion state and safe return.

### C27 — privacy-safe notification interaction

The unsupported-route card test now explicitly proves the raw payload title `未知跳转卡片` is absent, locates the rendered generic title `有一条新提醒`, taps that privacy-safe card surface, and retains the assertion that no notification is marked read.

It does not expose or require raw payload identity/title and does not alter `NotificationPrivacyContract` or notification production behavior.

### C28 — Settings replay completion

The Settings replay test now locates `完成引导` and retains its assertions that completion returns to canonical Home and preserves completed onboarding state.

## 3. Exact RED evidence

Before repair, the three authorized files were run separately with `--no-pub --reporter expanded`.

| Target file | RED result | Authorized target failures |
|---|---:|---|
| `first_use_onboarding_page_test.dart` | exit `1`, `+16 -5` | C21 public-copy tuple mismatch; C22-C25 stale `完成` finders |
| `notification_center_page_test.dart` | exit `1`, `+14 -1` | C27 raw payload title finder found zero widgets |
| `settings_page_test.dart` | exit `1`, `+21 -1` | C28 stale `完成` finder found zero widgets |

No additional failure appeared in these bounded RED runs.

## 4. Exact GREEN evidence

After changing and formatting only the three authorized test files, the same three commands were run again:

| Target file | GREEN result |
|---|---:|
| `first_use_onboarding_page_test.dart` | exit `0`, `+21`, `All tests passed!` |
| `notification_center_page_test.dart` | exit `0`, `+15`, `All tests passed!` |
| `settings_page_test.dart` | exit `0`, `+22`, `All tests passed!` |

All seven target identities are GREEN. The bounded notification file also confirms the accepted R2 C26 test remains GREEN, including fail-closed StatusAuthor behavior without payload identity authority.

A full Flutter suite and analyzer were not run because R3 does not authorize them.

## 5. Dependency and lockfile disposition

The fresh worktree initially lacked `.dart_tool/package_config.json`. Exactly one task-authorized locked restoration was performed:

`flutter pub get --enforce-lockfile`

It exited `0` and restored the package graph. Dependency input SHA-256 values were unchanged before and after:

- `pubspec.yaml`: `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`;
- `pubspec.lock`: `9D392F33B4324149B282AA62721D642D37A4BD5E1677DB403CB5A7373C385EEE`.

No dependency or lockfile change is part of this candidate.

## 6. Preserved invariants and explicit exclusions

Preserved exactly:

- onboarding explanation completion != authoritative Readiness/account completion;
- `STATE VOCABULARY != AUTHORITY`;
- `ROUTE IDENTITY != CONSENT`;
- notification raw payload identity/title != display/audience authority;
- generic privacy-minimal notification presentation;
- unsupported notification interaction does not become a successful open or mark-read action;
- APP-T12-B01 remains closed.

The candidate does not repair C01, analyzer findings A01-A21, or any unrelated failure. It does not change onboarding/readiness semantics, notification privacy presentation, authority gates, R1/R2 production source, backend/legal/compatibility/Phase-2 work, or Sandbox/DEP13/B12/M2/M3 state.

`git diff --check`: `PASS`.

## 7. Final classification

`STALE FLUTTER TEST EXPECTATIONS REPAIRED — C21-C25/C27/C28 TARGETED EVIDENCE GREEN — PRODUCT AND PRIVACY SEMANTICS UNCHANGED — READY FOR INDEPENDENT REVIEW`
