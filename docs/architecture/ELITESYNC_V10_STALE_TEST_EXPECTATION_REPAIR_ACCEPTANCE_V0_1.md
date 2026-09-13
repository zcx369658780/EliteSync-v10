# EliteSync v10｜Stale Test Expectation Repair Acceptance｜v0.1

Status: `ACCEPTED — C21-C25 / C27 / C28 STALE TEST EXPECTATIONS REPAIRED — PRODUCT AND PRIVACY SEMANTICS PRESERVED`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`f28d82e8c5081d5812e39edac8ffac986fe57caa`

Accepted result blob:

`40666bfe2e963f53548ad84dbb4a58f3851d70ee`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_STALE_TEST_EXPECTATION_REPAIR_RESULT_V0_1.md`

## 1. Independent acceptance

The R3 candidate is accepted for its authorized purpose.

It modifies only the three authorized test files plus the required result artifact. No `lib/**`, product behavior, dependency input, lockfile, generated source, backend, legal/data-rights, compatibility, Phase-2, or global configuration is changed.

## 2. Accepted repair scope

### C21-C25

The onboarding tests now assert the accepted current explanatory copy and `完成引导` affordance while preserving the distinction between onboarding explanation completion and authoritative account/Readiness state.

### C27

The notification test now explicitly asserts that raw payload title `未知跳转卡片` is absent, interacts with the privacy-safe rendered title `有一条新提醒`, and preserves the requirement that unsupported interaction does not mark the notification read.

This strengthens rather than weakens the accepted notification privacy boundary.

### C28

The Settings replay test now uses the accepted `完成引导` action and preserves its existing canonical Home and completion-state assertions.

## 3. Verification acceptance

Accepted targeted evidence:

- onboarding tests: `+16 -5 -> +21`;
- notification tests: `+14 -1 -> +15`;
- settings tests: `+21 -1 -> +22`;
- all seven authorized target findings are GREEN;
- accepted R2 C26 remains GREEN within the notification target file;
- `git diff --check`: PASS.

## 4. Preserved boundaries

Preserve:

- onboarding explanation completion != authoritative Readiness/account completion;
- `STATE VOCABULARY != AUTHORITY`;
- `ROUTE IDENTITY != CONSENT`;
- notification raw payload identity/title != display or audience authority;
- generic privacy-minimal notification presentation;
- unsupported notification interaction does not become successful open or mark-read;
- APP-T12-B01 remains closed.

## 5. Remaining current test repair item

The remaining accepted T05-B test-harness finding is:

- C01 canonical Match nested-route synchronization.

It should be handled in a separate bounded R4 test-harness task. Analyzer findings A01-A21 remain outside this acceptance.

## 6. Final classification

`R3 ACCEPTED — STALE FLUTTER TEST EXPECTATIONS REPAIRED — C21-C25/C27/C28 GREEN — PRODUCT AND PRIVACY SEMANTICS PRESERVED — READY FOR R4 OWNER-AUTHORIZED TEST-HARNESS REPAIR`
