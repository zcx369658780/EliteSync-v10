# EliteSync v10｜Android Studio Emulator Home First-Frame Visual & Accessibility Review Task｜v0.1

Status: `PUBLISHED TASK SHEET — ACCEPTED-EVIDENCE-ONLY HOME VISUAL/ACCESSIBILITY REVIEW — NO DEVICE INTERACTION — NO SOURCE MODIFICATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`5b6b07144cd445cfdd572117f4f60a0b88bf7023`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted first-frame baseline acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_FIRST_FRAME_BASELINE_ACCEPTANCE_V0_1.md`

Accepted candidate identity:

- commit: `5adcb2cbca7377c9b6598adccbc0bfa92097a760`
- result blob: `14d9c60cf79b27b562b6ba2931dbb497e3319fcd`
- result SHA-256: `16DA34246E964D705CE0ADBEAFAB49568442553F974191E9A16E2E47A0DB94EC`

This task is evidence review only. It does not authorize new emulator interaction or product implementation.

## 2. Sole objective

Review the accepted unauthenticated Home first-frame evidence for concrete visual and accessibility findings that can be established from the existing screenshot and UI hierarchy alone.

Evaluate only:

1. visible text legibility and visible clipping/truncation;
2. layout overlap, cutoff, or viewport-edge collision visible in the screenshot;
3. semantic-label / text / content-description coverage actually represented by the hierarchy;
4. clickable-node bounds and relative target geometry in captured pixels;
5. selected `首页` tab state consistency between screenshot and hierarchy evidence;
6. whether the accepted pre/post evidence supports deterministic app-level visual stability after the observational Home-tab tap;
7. which exact findings, if any, justify a later bounded source-level locator/review.

Do not infer hidden screen behavior or inspect destinations not represented in this evidence.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted first-frame baseline acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Exact accepted evidence gate

Use only this preserved host evidence root:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-Emulator-FirstFrame-a8dd19155ce3459fa470257e92eb3c70`

Require exactly these identities before substantive review:

### Initial screenshot

Path:

`initial-first-frame.png`

Required SHA-256:

`6A7314CF559197F4D1CD680CE7ACB18B196FEB17F72BFCF5087317FB405324D9`

### Initial hierarchy

Path:

`initial-first-frame.xml`

Required SHA-256:

`C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD`

### Post-interaction screenshot

Path:

`post-home-tab.png`

Required SHA-256:

`95A1D55F49808E5E0556E4AF6F25B95DAB50A3B7C78619AD60E4E9EC7385FE5D`

### Post-interaction hierarchy

Path:

`post-home-tab.xml`

Required SHA-256:

`C3B0C97B9DF56DE4D1331D7B0BF9528895ECD22B05CEA704D1D4EBF67643F3CD`

If any file is missing or any hash differs, STOP substantive review and classify:

`ACCEPTED FIRST-FRAME EVIDENCE NOT AVAILABLE/IDENTICAL — REVIEW NOT COMPLETED — AWAITING INDEPENDENT ACCEPTANCE`

Do not recapture, regenerate, normalize, edit, replace, or repair evidence.

## 5. Evidence interpretation rules

Treat screenshot and hierarchy as complementary evidence.

### Screenshot supports

- what is visibly rendered;
- visible clipping, overlap, contrast impressions, selected-state appearance, and spatial relationships;
- visual comparison between initial and post screenshots, while accounting for already accepted status-bar time variation.

### Hierarchy supports

- exact captured node text/content-description/class/clickable/selected/enabled/focusable fields that are actually present;
- exact pixel bounds;
- parent/child relationships present in the XML.

Do not claim a semantic role, accessibility label, selected state, or target size unless supported by captured fields or exact visible evidence.

If screenshot and hierarchy differ, report the difference; do not silently reconcile it.

## 6. Touch-target review rule

For every clickable node represented in the accepted hierarchy:

- record its exact pixel bounds and pixel width/height;
- identify overlaps or obviously degenerate/zero-area targets if present;
- identify whether the clickable region appears to contain the visible label/control in the screenshot when that can be established;
- do NOT convert px to dp unless an exact accepted density value is already present in the accepted evidence.

The accepted baseline did not establish display density. Therefore any normative dp-size compliance conclusion must be classified:

`NOT DETERMINABLE FROM ACCEPTED EVIDENCE — DISPLAY DENSITY NOT ESTABLISHED`

Do not query the emulator or host for density in this task.

## 7. Semantic/accessibility matrix

Create a bounded matrix for the visible Home first-frame controls and text, including at least:

- title `首页`;
- subtitle `从这里查看慢约进展。`;
- button `查看慢约进展`;
- bottom navigation items `首页`, `发现`, `匹配`, `消息`, `我的`.

For each, where evidence permits, record:

- visible text present: YES/NO;
- hierarchy text present: exact value or absent;
- content-description present: exact value or absent;
- clickable: YES/NO;
- selected-state field/value if represented;
- pixel bounds if represented;
- visible clipping/overlap finding;
- accessibility/semantic concern classification: `SUPPORTED FINDING`, `NO SUPPORTED ISSUE OBSERVED`, or `NOT DETERMINABLE`.

Absence from the hierarchy does not by itself prove the control is inaccessible; characterize only what the captured hierarchy establishes.

## 8. Visual stability comparison

Compare only app-level visual content between initial and post screenshots.

Already accepted fact:

- hierarchy is byte-identical before/after;
- status-bar clock changed between captures.

Determine whether there is any other supported app-level visual difference.

If none is found, classify:

`APP-LEVEL FIRST-FRAME VISUAL STATE STABLE UNDER ACCEPTED OBSERVATIONAL HOME TAP`

Do not claim general determinism across launches/devices from two captures.

## 9. Source-level next-step decision

After the evidence review, determine whether there is at least one concrete, source-actionable Home first-frame finding.

A finding is source-actionable only if:

- it is directly supported by accepted evidence;
- the affected visible control/region is uniquely identifiable;
- there is a plausible need to locate its implementation source for review or remediation;
- no private/backend/participant behavior must be exercised to investigate it.

If at least one source-actionable finding exists, recommend exactly one future bounded Home source-locator/review task. Do not perform it now.

If no source-actionable finding is established, recommend the next bounded evidence step without inventing a defect.

## 10. Explicit prohibitions

Do NOT:

- interact with the emulator or app;
- run `adb`, `uiautomator`, screenshots, or logcat;
- start/stop/reset/wipe/edit an AVD;
- inspect app private storage;
- log in or enter any data;
- access participant/private Conversation data;
- call Backend/Database/PUI production behavior;
- modify product or test source;
- read implementation source merely to explain a visual observation;
- build/rebuild/install APK/AAR;
- run Flutter/Gradle/package acquisition;
- download dependencies/SDK components;
- read README;
- inspect FD02;
- perform broad repository/filesystem archaeology;
- perform broad QA;
- create a Windows Sandbox;
- run DEP13.

## 11. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_FIRST_FRAME_VISUAL_ACCESSIBILITY_REVIEW_RESULT_V0_1.md`

It must record:

- main/FIRST/task/acceptance identities;
- all four evidence paths and verified SHA-256 values;
- screenshot dimensions actually observed from the image file, if directly obtainable without rewriting it;
- hierarchy node count and bounded control matrix;
- supported visible text/clipping/overlap findings;
- semantic/accessibility matrix;
- clickable-node pixel geometry;
- explicit `NOT DETERMINABLE` items, especially dp-size compliance absent density;
- initial/post app-level visual stability conclusion;
- exact source-actionable finding(s), if any;
- exact next recommended bounded task;
- negative attestations confirming no emulator interaction, source read/modification, login/private data, acquisition, or broad QA.

Final classification exactly one of:

`HOME FIRST-FRAME VISUAL/ACCESSIBILITY REVIEW COMPLETE — SOURCE-ACTIONABLE FINDING(S) ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME FIRST-FRAME VISUAL/ACCESSIBILITY REVIEW COMPLETE — NO SOURCE-ACTIONABLE ISSUE ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE`

or, if the evidence gate fails:

`ACCEPTED FIRST-FRAME EVIDENCE NOT AVAILABLE/IDENTICAL — REVIEW NOT COMPLETED — AWAITING INDEPENDENT ACCEPTANCE`

Stop after candidate publication. Do not self-accept or publish the next task.

## 12. Sandbox boundary

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator UI evidence remains a separate local development/test evidence class.

## 13. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 14. End state

`ACCEPTED FIRST FRAME -> STATIC VISUAL/ACCESSIBILITY REVIEW`

`STATIC REVIEW != BROAD QA`

`PIXEL BOUNDS != DP COMPLIANCE WITHOUT DENSITY`

`SUPPORTED FINDING != IMPLEMENTATION AUTHORITY`

`EMULATOR EVIDENCE != SANDBOX DEP13 EVIDENCE`
