# EliteSync v10｜Android Studio Emulator Home Semantics Source-Locator Review Task｜v0.1

Status: `PUBLISHED TASK SHEET — READ-ONLY HOME SOURCE-LOCATOR/SEMANTICS REVIEW — TWO ACCEPTED FINDINGS ONLY — NO SOURCE MODIFICATION — NO EMULATOR INTERACTION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`103425a27baf14780cce6843f8e71db5f9bd316b`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted visual/accessibility review acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_FIRST_FRAME_VISUAL_ACCESSIBILITY_REVIEW_ACCEPTANCE_V0_1.md`

Accepted candidate/result:

- candidate commit: `5e547c8d9a989e405f5e0a30c9644c93778cf06f`
- result blob: `86f2d9692503a954f599290d0fc43f643c47eb4c`
- accepted findings: `HOME-SEM-SELECTED-01`, `HOME-SEM-FULLSCREEN-CLICK-01`

This task authorizes read-only source location and semantics ownership analysis only.

## 2. Sole objective

Using only exact current-authority repository evidence, uniquely locate the implementation source responsible for:

1. the Home surface displaying `首页`, `从这里查看慢约进展。`, and `查看慢约进展`;
2. the bottom-navigation Home selected semantics implicated by `HOME-SEM-SELECTED-01`;
3. the Home content semantics/actionable-node configuration implicated by `HOME-SEM-FULLSCREEN-CLICK-01`.

Then determine whether the captured hierarchy fields follow from the located source configuration and, only if supported, author a bounded remediation contract for a later implementation task.

Do not modify source in this task.

## 3. Startup authority gate

The activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the accepted visual/accessibility review acceptance named in §1;
6. read the accepted visual/accessibility result blob only as needed for the two exact finding definitions;
7. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Authorized source-locator anchors

Repository search is limited to current `main` and only these exact textual anchors:

- `首页`
- `从这里查看慢约进展。`
- `查看慢约进展`

Search may additionally use direct source identifiers discovered in the same exact matching files solely to follow the Home surface or bottom-navigation construction one step outward.

Do not use broad semantic keywords such as `navigation`, `semantics`, `accessibility`, `selected`, `Scaffold`, `GestureDetector`, `InkWell`, or `MergeSemantics` as repo-wide discovery terms unless they occur inside an already-authorized exact matching file and are inspected only within that file or one directly referenced local component.

Do not browse unrelated modules/directories.

## 5. Unique-locator rule

First locate exact file(s) containing the three anchors.

If the anchors resolve to exactly one Home surface implementation chain, record:

- exact repository path(s);
- Git blob SHA(s);
- exact line/function/widget/class identifiers;
- direct import/component relationship between Home surface and bottom navigation if present.

If multiple unrelated candidate surfaces remain and cannot be disambiguated from direct references, stop broadening and classify:

`HOME SEMANTICS SOURCE OWNERSHIP NOT UNIQUELY LOCATED`

Do not search history, branches, README, issues, generated build outputs, or broad repository structure to resolve ambiguity.

## 6. Read-only semantics ownership review

After unique location, inspect only the minimum source required to answer the following.

### A. `HOME-SEM-SELECTED-01`

Determine:

- what source object/widget/component renders the Home bottom-navigation item;
- how visual selection is determined;
- whether an explicit semantics/accessibility selected state is supplied;
- whether the current source configuration plausibly explains why the captured hierarchy has `selected=false` while the visual Home item is selected.

Classification exactly one of:

- `SOURCE CAUSE ESTABLISHED`
- `SOURCE CONTRIBUTION ESTABLISHED BUT RUNTIME PROJECTION NOT FULLY PROVEN`
- `NOT EXPLAINED FROM AUTHORIZED SOURCE`

### B. `HOME-SEM-FULLSCREEN-CLICK-01`

Determine:

- what source object/widget/component owns the `首页` + `从这里查看慢约进展。` semantic label/description;
- what source construct makes that node actionable/clickable/focusable, if identifiable;
- what layout/semantics wrapper could account for the captured full-viewport bounds;
- whether the current source configuration plausibly explains the hierarchy node `[0,0][1080,2400]`.

Use the same three classifications above.

Do not claim actual TalkBack traversal, hit-testing conflict, focus behavior, or user harm from source inspection alone.

## 7. Remediation-contract rule

A remediation contract may be proposed only if the source review uniquely establishes a concrete source-level change surface.

For each accepted finding, record:

- exact source path/blob;
- exact source construct to change;
- intended semantic outcome;
- what must remain visually/functionally unchanged;
- bounded validation needed on the emulator afterward;
- whether the change can be isolated from Backend/Database/PUI, login/private data, participant workflows, telemetry/analytics, and production behavior.

Do NOT write patch text or edit source in this task.

If source cause is not sufficiently established, use:

`REMEDIATION CONTRACT NOT YET AUTHORABLE — SOURCE CAUSE INCOMPLETE`

Do not invent a fix.

## 8. Explicit prohibitions

Do NOT:

- modify implementation/test/build source;
- create a patch or commit product code;
- interact with emulator/app;
- run `adb`, `uiautomator`, screenshots, logcat, accessibility services, or density queries;
- navigate to `发现`, `匹配`, `消息`, `我的`, or progress destinations;
- log in or enter any data;
- access app private storage, Backend, Database, PUI production behavior, participant data, or private Conversation data;
- build/rebuild/install APK/AAR;
- run Flutter/Gradle/package acquisition;
- download dependencies/SDK components;
- read README;
- inspect FD02;
- search git history or non-main branches;
- perform broad source archaeology;
- create Windows Sandbox;
- run DEP13.

## 9. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_HOME_SEMANTICS_SOURCE_LOCATOR_REVIEW_RESULT_V0_1.md`

It must record:

- main/FIRST/task/acceptance identities;
- exact search anchors used;
- exact source path/blob identities located;
- unique-locator result;
- source ownership chain for the Home surface and bottom navigation;
- separate causal matrix for `HOME-SEM-SELECTED-01` and `HOME-SEM-FULLSCREEN-CLICK-01`;
- exact limits between source evidence and runtime inference;
- remediation-contract status;
- exact bounded next step;
- negative attestations confirming no source modification, emulator interaction, private/backend data access, dependency acquisition, broad archaeology, or Sandbox/DEP13 work.

Final classification exactly one of:

`HOME SEMANTICS SOURCE OWNERSHIP LOCATED — BOUNDED REMEDIATION CONTRACT AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME SEMANTICS SOURCE OWNERSHIP LOCATED — REMEDIATION CONTRACT NOT YET AUTHORABLE — AWAITING INDEPENDENT ACCEPTANCE`

or

`HOME SEMANTICS SOURCE OWNERSHIP NOT UNIQUELY LOCATED — AWAITING INDEPENDENT ACCEPTANCE`

Stop immediately after publishing the candidate. Do not self-accept or publish/execute remediation.

## 10. Preserved boundaries

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved and blocked. Emulator evidence remains a separate local development/test evidence class.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 11. End state

`STATIC UI FINDING -> READ-ONLY SOURCE OWNERSHIP REVIEW`

`SOURCE OWNERSHIP != REMEDIATION EXECUTION AUTHORITY`

`SOURCE EVIDENCE != RUNTIME ACCESSIBILITY BEHAVIOR`

`EMULATOR EVIDENCE != SANDBOX DEP13 EVIDENCE`
