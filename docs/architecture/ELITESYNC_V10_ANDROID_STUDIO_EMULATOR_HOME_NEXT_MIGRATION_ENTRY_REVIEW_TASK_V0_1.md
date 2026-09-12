# EliteSync v10｜Android Studio Emulator Home Next Migration Entry Review Task｜v0.1

Status: `PUBLISHED TASK SHEET — POST-REMEDIATION CURRENT-MAIN REVIEW — SELECT ONE NEXT PUBLIC/NON-PRIVATE HOME MIGRATION ENTRY — NO SOURCE MODIFICATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`56c1d63dff1aeacfca38a64c4d9d49a4abd5ed1c`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted Home remediation acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_SEMANTICS_BOUNDED_REMEDIATION_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

Accepted remediation candidate:

- commit: `921f68f1992409d8f5ac37ececaad15aed6febce`
- result blob: `058529ea2590f2fc79a2c9c3ac7057aa8f9ee050`
- accepted APK SHA-256: `C02FCEF8A59404F36793650A743720404F15957F3B098C32AF16A323CA0D8591`

Exact accepted code/test promotion is now current `main` authority.

## 2. Promotion identity gate

Before substantive review, require current-main exact blobs:

- `apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart`
  - `8a185653794ad298650730f0250c7e840b172635`
- `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`
  - `a064369146732eca394d3b2abfe473d5fff3ef48`
- `apps/flutter_elitesync_module/test/design_system/components/floating_dock_bottom_bar_semantics_test.dart`
  - `4a23d9bfbfccfe5858890dc8bcd2aaa30cf763a8`
- `apps/flutter_elitesync_module/test/design_system/components/browse_scaffold_semantics_test.dart`
  - `10b53d486e11755a5c1c6686b7a1eca4045d47f0`

If any identity differs, stop:

`HOME_REMEDIATION_PROMOTION_IDENTITY_CHANGED`

Do not reconstruct or reapply remediation.

## 3. Sole objective

Select exactly one next bounded public/non-private Home UI migration/rebuild entry from the current accepted Home surface, and author a precise review/implementation contract for that one entry only.

This is a planning/ownership review. It does not authorize implementation.

The chosen entry must:

1. be visibly present on the accepted unauthenticated Home first frame;
2. be uniquely owned by current-main source;
3. be inspectable without destination navigation, login, private/user/participant data, Backend/Database/PUI production behavior, telemetry, or analytics;
4. be small enough for one later bounded implementation + focused test + Home-only emulator validation task;
5. have a clear reason to migrate/rebuild now rather than merely change for preference.

If no such entry is supported, do not invent one.

## 4. Authorized Home source scope

Read-only inspection is limited to these already-established current Home ownership files:

- `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`
  - expected blob `6787ac9e56e3eaec87a98a9e901184c426d5b2db`
- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
  - expected blob `2f1d4933fd4fb928afed77f98e84d7cb6021dbf8`
- the two promoted design-system source files in §2.

Within `home_page.dart`, review only these visible Home units:

- `_HomeHeader`
- `_SlowDateProgressCard`
- their direct use by `HomePage.build`

Directly imported theme/token definitions may be read only when required to establish current ownership/invariants for one of these two units. Do not broaden into unrelated design-system or feature source.

Do not inspect the Match destination reached by `查看慢约进展`.

## 5. Accepted runtime evidence scope

The review may rely on the already accepted Home evidence and remediation result only.

Accepted pre-remediation baseline facts include:

- viewport `1080x2400`;
- title `首页`;
- subtitle `从这里查看慢约进展。`;
- CTA `查看慢约进展`;
- five-item floating dock;
- no accepted Home clipping/overlap/cutoff.

Accepted post-remediation facts include:

- app region `y >= 100` visually pixel-identical to the accepted baseline;
- Home title/subtitle/button remain separately represented;
- dock semantics remediation is closed within accepted scope;
- no destination navigation occurred.

Do not recapture runtime evidence in this task.

## 6. Candidate-entry comparison

Compare exactly these two candidate units and no others:

### Candidate H1 — `_HomeHeader`

Current visible role:

- title `首页`;
- subtitle `从这里查看慢约进展。`;
- public/non-private static card.

Review:

- source ownership and blob;
- dependency on tokens/theme only;
- current visual/layout invariants;
- existing direct tests if uniquely locatable from exact class/string anchors without broad test search;
- whether there is concrete migration/rebuild value supported by current evidence/source rather than stylistic preference.

### Candidate H2 — `_SlowDateProgressCard`

Current visible role:

- public Home CTA card labeled `查看慢约进展`;
- action callback routes toward Match, but destination behavior is out of scope.

Review:

- source ownership and blob;
- separation between visible card/button rendering and destination callback;
- current visual/layout/semantic invariants;
- existing direct tests if uniquely locatable from exact key `e1-home-primary-match-cta` or exact CTA string without broad search;
- whether the visual/public unit can be migrated/rebuilt without exercising destination behavior.

Do not inspect the target destination implementation.

## 7. Selection rule

Select exactly one of H1 or H2 only if the evidence establishes a stronger next migration/rebuild case.

Priority order:

1. smaller isolated change surface;
2. lower privacy/backend/navigation coupling;
3. stronger deterministic current baseline and validation route;
4. clearer user-visible migration/rebuild value supported by source/current evidence;
5. ability to validate wholly on Home without destination navigation.

Do not select merely because a component exists or could be redesigned.

If neither has a source/evidence-backed need for modification, final classification must say no migration entry is yet established and recommend one bounded evidence-gathering step instead.

## 8. Required migration contract if selected

For the selected unit, define:

- exact source path/blob/class/widget;
- exact current visual/semantic contract to preserve;
- exact change objective and why it is evidence-backed;
- exact product source paths that a later implementation may modify;
- exact product source paths that must remain unchanged;
- focused test scope;
- offline build requirement, if any;
- one Home-only emulator validation contract;
- visual comparison requirement against the accepted Home baseline/remediation capture;
- privacy/backend/destination boundaries;
- stop rule for a later implementation candidate.

Do NOT provide patch text or modify source.

## 9. Explicit prohibitions

Do NOT:

- modify source/test/build files;
- interact with emulator/app or run adb/uiautomator/logcat/screenshots;
- navigate to any bottom tab or `查看慢约进展` destination;
- inspect Match destination implementation;
- log in or enter/inspect private, participant, or Conversation data;
- inspect Backend/Database/PUI production behavior;
- perform broad UX redesign or broad QA;
- browse unrelated feature modules;
- read README;
- inspect FD02;
- search history or non-main branches;
- acquire dependencies/SDK components;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 10. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_NEXT_MIGRATION_ENTRY_REVIEW_RESULT_V0_1.md`

It must record:

- main/FIRST/task/acceptance identities;
- promotion identity gate result;
- exact source identities read;
- bounded H1/H2 comparison;
- exact selected entry or explicit no-entry conclusion;
- evidence-backed reason for selection;
- exact migration/rebuild contract if selected;
- exact validation contract;
- next bounded task recommendation;
- negative attestations confirming no source modification, emulator interaction, destination inspection/navigation, private/backend data access, acquisition, broad archaeology, or Sandbox/DEP13 work.

Final classification exactly one of:

`HOME NEXT MIGRATION ENTRY ESTABLISHED — <H1_HOME_HEADER or H2_SLOW_DATE_PROGRESS_CARD> — BOUNDED IMPLEMENTATION CONTRACT AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME NEXT MIGRATION ENTRY NOT YET ESTABLISHED — ADDITIONAL BOUNDED EVIDENCE REQUIRED — AWAITING INDEPENDENT ACCEPTANCE`

Stop after publishing the candidate. Do not self-accept or implement the selected entry.

## 11. Preserved boundaries

`HOME-SEM-SELECTED-01` and `HOME-SEM-FULLSCREEN-CLICK-01` are closed within their accepted validation scope. Do not reopen them absent new evidence.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator evidence remains a separate local development/test evidence class.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 12. End state

`ACCEPTED REMEDIATION -> CURRENT MAIN PROMOTION -> NEXT MIGRATION ENTRY REVIEW`

`MIGRATION ENTRY REVIEW != IMPLEMENTATION`

`PUBLIC HOME SURFACE != DESTINATION AUTHORITY`

`EMULATOR EVIDENCE != SANDBOX DEP13 EVIDENCE`
