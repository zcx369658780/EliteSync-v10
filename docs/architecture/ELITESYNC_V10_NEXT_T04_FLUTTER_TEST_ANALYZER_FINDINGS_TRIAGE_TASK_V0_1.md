# EliteSync v10｜NEXT-T04 Flutter Test / Analyzer Findings Triage Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — TRIAGE / CLASSIFICATION ONLY — NO REPAIR`

Repository: `zcx369658780/EliteSync-v10`

Owner authorization basis: Owner approved a bounded triage of the Track 3 non-green Flutter evidence on 2026-09-13 (Asia/Singapore).

Fresh authority at task publication:

`7f85627f337f24e72708c41836b00bcbd6fdc004`

Accepted Track 3 result:

`docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md`

Accepted Track 3 acceptance:

`docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_ACCEPTANCE_V0_1.md`

## 1. Objective

Triage the newly established non-green Flutter evidence without modifying product source, test source, dependency declarations, lockfiles, generated output, or global tooling configuration.

This task must classify the 35 observed `flutter test` failures and the 21 `flutter analyze --no-pub` findings into bounded, reviewable categories, determine whether any finding threatens an accepted MVP invariant or represents only stale test/source debt, and produce a repair-priority plan for later Owner authorization.

This task does NOT authorize repairs.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `7f85627f337f24e72708c41836b00bcbd6fdc004`, inspect intervening commits before proceeding. If they materially alter Flutter source/tests/tooling evidence or this task scope, stop and report the conflict.

Do not perform broad repository enumeration.

## 3. Binding classification boundaries

Preserve:

- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- `Match != Connection != Conversation != Relationship`

Do not reopen the accepted MVP integration contract solely because the suite is non-green.

Do not classify a failing test as a product regression until the current accepted product contract and current production source contradict the test-observed behavior.

## 4. In-scope evidence

Track 3 established:

- `flutter test`: exit `1`, `+522 -35`;
- `flutter analyze --no-pub`: exit `1`;
- analyzer: `0 errors / 4 warnings / 17 infos`;
- at least one null-check `_TypeError` involving `AppThemeX.appTokens` in `app_presentation_state_view_test.dart`;
- example failing tests include routing/onboarding/acceptance/profile/settings surfaces.

Use the Track 3 result as the primary failure ledger.

Additional reads are allowed only when narrowly needed to classify a listed failure/finding:

- the exact failing test file;
- the directly corresponding production file(s);
- directly relevant accepted architecture/product contract sections.

No private participant/Profile/Conversation runtime data may be inspected.

## 5. Required test-failure classifications

Every one of the 35 failures must be assigned one primary classification:

1. `STALE_TEST_EXPECTATION`
   - test expects superseded route/copy/widget/lifecycle behavior;
   - current source matches accepted contract;
   - repair target would be test expectation, not product behavior.

2. `PRODUCT_REGRESSION_CANDIDATE`
   - current production source appears to violate an accepted MVP/product invariant or accepted behavior;
   - requires separate repair review before any source modification.

3. `TEST_HARNESS_OR_FIXTURE_DEFECT`
   - failure primarily arises from missing/wrong test setup, fixture, theme/provider/context initialization, timing, or harness assumptions rather than accepted product behavior.

4. `SOURCE_QUALITY_DEFECT_NON_PRODUCT_SEMANTIC`
   - real source defect is plausible, but it does not presently establish a product-contract regression; examples may include unsafe null handling or implementation robustness.

5. `UNRESOLVED`
   - available bounded evidence is insufficient; state exactly what additional evidence would be required.

Do not force a classification when evidence is insufficient.

## 6. AppThemeX.appTokens special review

Perform a focused bounded review of the observed null-check `_TypeError` involving `AppThemeX.appTokens` in `app_presentation_state_view_test.dart`.

Determine, without editing or broad execution, whether current evidence best supports:

- test theme/setup omission;
- production widget assuming an unavailable theme extension;
- shared theme-contract defect;
- or `UNRESOLVED`.

Report:

- exact failing seam;
- production precondition assumed;
- test precondition supplied or missing;
- whether the same seam is plausibly reachable in normal product composition;
- whether this warrants a repair candidate and at what priority.

Do not modify theme code or tests.

## 7. Analyzer triage

Classify all 21 analyzer findings by category and repair priority.

At minimum separate:

- 4 warnings;
- 17 infos.

Priority levels:

- `P0` — credible accepted-contract/privacy/safety/runtime correctness risk;
- `P1` — probable runtime robustness or maintainability defect worth near-term repair;
- `P2` — source hygiene/deprecation/cleanup with low immediate product risk;
- `DEFER` — safe to retain for now, with reason.

Analyzer severity alone does not determine product severity.

## 8. Required output artifact

Create exactly one new artifact:

`docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`

It must contain at minimum:

1. fresh authority and bounded evidence basis;
2. summary counts by test-failure classification;
3. a complete 35-failure ledger, grouped where multiple assertions share one root cause but preserving exact test identities/counts;
4. explicit MVP-invariant impact assessment;
5. focused `AppThemeX.appTokens` assessment;
6. analyzer findings grouped by exact category and priority;
7. separation of test-only repair candidates vs product-source repair candidates;
8. unresolved items and required evidence;
9. recommended bounded repair sequence, with no repair authority created;
10. explicit non-goals and stop boundary.

## 9. Execution boundary

This task is primarily source/evidence review.

Do NOT rerun the full `flutter test` suite or full `flutter analyze` merely to reproduce Track 3 results.

A narrowly targeted single-test invocation is allowed ONLY if the existing Track 3 result plus source/test inspection cannot distinguish `TEST_HARNESS_OR_FIXTURE_DEFECT` from `PRODUCT_REGRESSION_CANDIDATE`, and only when it requires no source/config/dependency change. Record why it was necessary.

Do not run `pub get` unless package metadata is unexpectedly absent and the exact already-accepted Track 3 package graph can be restored without changing dependencies; if any broader dependency/tooling repair is needed, stop.

## 10. Explicit exclusions

Do NOT:

- modify product source;
- modify test source;
- modify dependencies, pubspec, lockfile, generated source, or build config;
- silence analyzer findings;
- repair the AppThemeX issue;
- rewrite routes/copy/widgets;
- implement backend/API/database/service work;
- perform legal/data-rights work;
- remove compatibility debt;
- start Phase 2;
- inspect private data;
- perform telemetry/analytics or Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- change global Flutter/Dart/Gradle/Java/network/proxy/certificate/Browser/model/notification configuration.

## 11. Delivery and Git boundary

Work on a fresh bounded branch from verified main.

Recommended branch:

`review/next-t04-flutter-findings-triage-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_FLUTTER_TEST_ANALYZER_FINDINGS_TRIAGE_RESULT_V0_1.md`

Recommended commit message:

`docs: triage Flutter test and analyzer findings`

Publish the candidate branch/commit for independent review.

Do not merge, self-accept, or start repair work.

## 12. Completion classification

Successful completion should end substantially as:

`FLUTTER NON-GREEN EVIDENCE TRIAGED — TEST/ANALYZER FINDINGS CLASSIFIED — MVP IMPACT EXPLICIT — NO REPAIRS PERFORMED — READY FOR INDEPENDENT REVIEW / OWNER REPAIR PRIORITIZATION`

Stop after publishing the triage candidate.
