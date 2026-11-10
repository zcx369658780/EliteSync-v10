# EliteSync v10｜Android Studio Emulator Home H1/H2 Large-Text Reflow Evidence Task｜v0.1

Status: `PUBLISHED TASK SHEET — HOME-ONLY 390x844 / 2.0-TEXT-SCALE H1/H2 EVIDENCE — TEMP HARNESS ONLY — NO SOURCE/TEST MODIFICATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`69ef207d7f8e6759e381f211bd8680436f6982dc`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted migration-entry review acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_NEXT_MIGRATION_ENTRY_REVIEW_ACCEPTANCE_V0_1.md`

Accepted review candidate/result:

- candidate commit: `78b7f2f66aceb845e20b713e424b9eaa748891e1`
- result blob: `dceb1a40507f94fd1612bd25aa38c435bec7a056`
- accepted decision: `NO HOME MIGRATION ENTRY YET ESTABLISHED`

This task gathers one missing piece of evidence only. It does not authorize implementation.

## 2. Sole objective

Establish whether either of the two current accepted Home units has a concrete large-text reflow failure at one bounded configuration:

- H1 `_HomeHeader`
- H2 `_SlowDateProgressCard`

Required render configuration:

- logical viewport exactly `390 x 844`;
- device-pixel ratio `1.0` for the widget harness;
- light theme;
- text scale exactly `2.0` using Flutter's current `TextScaler`/MediaQuery mechanism;
- current-main Home source only;
- no UI interaction and no destination navigation.

The task must not presume a failure exists.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted migration-entry review acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Exact current-source identity gates

Before creating the temporary harness, require current-main exact blobs:

- `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`
  - `6787ac9e56e3eaec87a98a9e901184c426d5b2db`
- `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`
  - `a064369146732eca394d3b2abfe473d5fff3ef48`
- `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`
  - `cd6d6dfe5fce921d41b5b97f2fa8a0e230480bc6`

Also require the promoted dock source remains:

- `apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`
  - `8a185653794ad298650730f0250c7e840b172635`

If any required identity differs, stop with:

`HOME_LARGE_TEXT_SOURCE_IDENTITY_CHANGED`

Do not adapt the evidence harness to changed source by inference.

## 5. Temporary-harness authority

The existing tracked Home test does not contain a `2.0` text-scaler case. Do NOT edit it.

Exactly one temporary, task-owned Flutter widget-test harness outside tracked repository source/test paths is authorized.

Requirements:

- create under a fresh task-owned temporary host directory, not under tracked repository paths;
- record exact path and SHA-256 of the harness in the result;
- use current package imports from `apps/flutter_elitesync_module`;
- do not copy or modify product source;
- do not create or edit any tracked `.dart`, Gradle, pubspec, Android, or configuration file;
- do not commit the temporary harness;
- use only already-installed/local dependency state.

If host policy prevents creation/execution of such a temporary harness without tracked-repository modification, stop:

`HOME_LARGE_TEXT_TEMP_HARNESS_NOT_EXECUTABLE_UNDER_HOST_POLICY`

Do not fall back to editing `home_page_test.dart`.

## 6. Harness construction contract

The harness must render the current `HomePage` through a minimal local router/wrapper sufficient for the current widget tree, with a local Match stub route that is never entered.

It must set:

- `tester.view.physicalSize = Size(390, 844)`;
- `tester.view.devicePixelRatio = 1.0`;
- light theme;
- MediaQuery text scaling exactly `2.0` using a framework-supported `TextScaler` path.

No tap, gesture, route navigation, text entry, focus manipulation, or runtime network/backend call is authorized.

The harness may pump and settle only as needed to produce a stable current Home frame.

## 7. Required H1 evidence

For `_HomeHeader`, collect only evidence available from the focused widget render:

- title `首页` present exactly once;
- subtitle `从这里查看慢约进展。` present exactly once;
- title and subtitle widget/global bounds;
- enclosing H1 card bounds if determinable from exact current tree;
- vertical ordering;
- whether either text overflows, clips, paints outside its intended parent, overlaps the other text, or triggers a Flutter framework exception;
- whether both remain fully contained within the visible Home viewport.

Do not infer typography quality or redesign preference from successful fit.

## 8. Required H2 evidence

For `_SlowDateProgressCard`, collect only:

- CTA key `e1-home-primary-match-cta` present exactly once;
- CTA label `查看慢约进展` present exactly once;
- CTA/button bounds;
- icon bounds if directly obtainable;
- label/text bounds;
- enclosing H2 card bounds if determinable;
- button action count/semantics action count without invoking the action;
- whether icon/label clip, overlap, escape the button/card, or trigger a Flutter framework exception;
- whether the CTA remains fully contained within the visible Home viewport.

Do not tap the CTA. Do not inspect or enter Match.

## 9. Evidence artifact contract

Produce task-owned local evidence outside the repository sufficient to support the result, including:

- exactly one rendered Home image at the required configuration;
- one bounded semantics snapshot/tree or deterministic widget-bound receipt;
- one machine-readable or text receipt containing H1/H2 bounds, exception count, and pass/fail observations.

Record SHA-256 for each preserved evidence file.

No emulator/adb/uiautomator capture is authorized. This is a Flutter widget-harness evidence task only.

## 10. Entry decision rule

After evidence collection, classify H1 and H2 independently:

`LARGE_TEXT CONTRACT PASS`

or

`LARGE_TEXT CONTRACT FAIL — SOURCE-ACTIONABLE REFLOW DEFECT ESTABLISHED`

Use this exact selection rule:

- H1 FAIL and H2 PASS -> nominate H1;
- H1 PASS and H2 FAIL -> nominate H2;
- both FAIL -> nominate H1 first because it is lower-coupled;
- both PASS -> preserve `NO HOME MIGRATION ENTRY ESTABLISHED`.

Do not nominate an entry on stylistic preference alone.

## 11. Explicit prohibitions

Do NOT:

- modify tracked source, tests, build files, pubspec, Android config, or repository tooling;
- interact with emulator/app or run adb/uiautomator/logcat;
- navigate to Match or another dock destination;
- invoke the CTA callback;
- log in or enter/inspect private/user/participant/Conversation data;
- access Backend/Database/PUI production behavior;
- run broad/full test suites;
- download packages, SDK components, or system images;
- read README;
- inspect FD02;
- search history or non-main branches;
- perform broad repository archaeology;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 12. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_H1_H2_LARGE_TEXT_REFLOW_EVIDENCE_RESULT_V0_1.md`

Candidate commit must contain only that result artifact. Temporary harness/evidence must not be committed.

Result must record:

- main/FIRST/task/acceptance identities;
- all source identity gates;
- temporary harness path/SHA-256 and execution command/result;
- exact viewport/text-scale/theme configuration;
- rendered evidence paths/SHA-256 values;
- H1 bounds and finding;
- H2 bounds/action-count and finding;
- Flutter exception/overflow result;
- exact entry decision under §10;
- exact next bounded task recommendation;
- negative attestations for tracked modifications, UI interaction, destination navigation, private/backend data, acquisition, broad QA, Sandbox/DEP13.

Final classification exactly one of:

`HOME LARGE-TEXT EVIDENCE ESTABLISHED — H1_HOME_HEADER MIGRATION ENTRY NOMINATED — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME LARGE-TEXT EVIDENCE ESTABLISHED — H2_SLOW_DATE_PROGRESS_CARD MIGRATION ENTRY NOMINATED — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME LARGE-TEXT EVIDENCE ESTABLISHED — NO HOME MIGRATION ENTRY ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE`

or, on precondition failure:

`HOME LARGE-TEXT EVIDENCE NOT ESTABLISHED — PRECONDITION/TEMP-HARNESS GATE FAILED — AWAITING INDEPENDENT ACCEPTANCE`

Stop immediately after publishing the candidate. Do not self-accept or implement H1/H2.

## 13. Preserved boundaries

`HOME-SEM-SELECTED-01` and `HOME-SEM-FULLSCREEN-CLICK-01` remain closed within accepted scope.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved. Emulator/widget evidence remains separate from Sandbox DEP13 evidence.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 14. End state

`NO MIGRATION ENTRY -> ONE LARGE-TEXT REFLOW EVIDENCE PASS`

`LARGE-TEXT EVIDENCE != IMPLEMENTATION AUTHORITY`

`TEMP HARNESS != TRACKED TEST MODIFICATION`

`WIDGET EVIDENCE != SANDBOX DEP13 EVIDENCE`
