# EliteSync v10｜Flutter Test / Analyzer Findings Triage Acceptance｜v0.1

Status: `ACCEPTED — NON-GREEN FLUTTER EVIDENCE TRIAGED — NO PRODUCT REGRESSION ESTABLISHED — REPAIRS REQUIRE SEPARATE AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Accepted candidate:

`0c295423e4277e8fe88cf0acd7bd9b04656e19e8`

Accepted result blob:

`ffc534f19a7db521cf044545d6e145e0e17b7c2b`

Accepted artifact:

`docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`

## 1. Independent acceptance

The T04 triage candidate is accepted for its authorized purpose.

It correctly preserves the difference between established evidence and missing evidence:

- 5 test failures are `STALE_TEST_EXPECTATION`;
- 2 are `TEST_HARNESS_OR_FIXTURE_DEFECT`;
- 28 remain `UNRESOLVED` because the accepted Track 3 artifact did not retain their individual identities/messages;
- 0 product regressions are established by the bounded evidence;
- all 21 analyzer findings are classified, with 11 P1 and 10 P2, and 0 P0.

The accepted triage does not claim that the 28 unresolved failures are harmless. It preserves them as unresolved and requires new evidence before promotion to a repair class or product-regression candidate.

## 2. AppThemeX finding

The focused `AppThemeX.appTokens` `_TypeError` classification is accepted as `TEST_HARNESS_OR_FIXTURE_DEFECT` on the current evidence.

The production `EliteSyncApp` composition supplies `AppThemeTokens` through the accepted light/dark themes, while the two failing tests mount token-dependent widgets under a bare `MaterialApp` without the extension.

This acceptance does not authorize adding a silent product-source fallback. A later repair should be test-only unless fresh evidence establishes a runtime composition path lacking the required theme extension.

## 3. Test-failure acceptance boundary

The five stale expectations are accepted as test-debt candidates because the production source aligns with previously accepted product behavior while the tests still assert superseded presentation or pre-authority behavior.

The two harness defects are accepted as test-fixture debt.

The 28 unresolved failures require a separate evidence-capture/triage task before repair. They must not be guessed from test inventory or treated as non-blocking merely because no regression has yet been established.

## 4. Analyzer acceptance boundary

The analyzer classification is accepted:

- `P1`: 11 infos involving logging/data-minimization review or deprecated RTC audio-route APIs;
- `P2`: 4 warnings and 6 infos involving source hygiene, equivalent syntax cleanup, or deprecated test matchers;
- `P0`: none.

Analyzer priority is a repair-priority classification, not product-severity or legal finding.

## 5. Recommended repair sequencing

A safe first repair batch may target only deterministic, low-semantic-risk debt:

1. update the five stale test expectations to the already accepted Home/Conversation contracts;
2. repair the two `AppThemeX` test fixtures by using the repository theme composition;
3. optionally include test-only deprecated semantics matcher cleanup if bounded separately.

Do not change product authority gates, add fake Conversation authority, add product token fallbacks, or infer behavior for unresolved failures.

A separate evidence-capture task should then reconstruct the identities/messages for the remaining 28 failures before any repair authorization for them.

P1 analyzer findings should be handled only in separate bounded source-review/repair tasks because logging/data-minimization and RTC API migration can have semantic or privacy/runtime effects.

## 6. Final classification

`T04 ACCEPTED — FLUTTER NON-GREEN EVIDENCE TRIAGED — 5 STALE TEST EXPECTATIONS / 2 HARNESS DEFECTS / 28 UNRESOLVED — 21 ANALYZER FINDINGS PRIORITIZED — NO REPAIR AUTHORITY CREATED`
