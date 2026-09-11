# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Recovery Continuation Scope Decision Task v0.1

Status: `TASK AUTHORIZED — GOVERNANCE / RECOVERY-CONTINUATION SCOPE DECISION ONLY — NO WSB RUNTIME — NO SHARE — NO EXEC — NO MATERIALIZATION — DEP13 NOT AUTHORIZED`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Purpose

Decide whether the accepted recovery contract may now be continued on the already rebound existing Sandbox without creating or starting another Sandbox, and if so define the exact bounded continuation-execution scope.

This is governance/scope review only. It does not run `wsb`, share, guest exec, guest access, materialization, DEP13, Maven/source research, acquisition, Gradle/M3/AAR/M2, cleanup, stop, kill, reset, or close.

`RECOVERY CONTINUATION SCOPE != RECOVERY CONTINUATION EXECUTION AUTHORITY`

`RECOVERY CONTINUATION != DEP13 AUTHORITY`

## 2. Mandatory repository startup gate

Fresh-fetch GitHub `main` first and require exact durable authority:

`058eee47bb0d036b31a8a5936548c7237041700f`

Require exact tree:

`c249d1be1ac5707634dbf2d316f577e540697933`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_REBINDING_IDENTITY_ESTABLISHMENT_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`92ec42d3e6290e90170ad07ac119b7c02cbb7bcc`

Also read, as exact accepted evidence inputs only:

1. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_REBINDING_IDENTITY_ESTABLISHMENT_RESULT_V0_1.md`
   - require result blob `cc0ce0007c910cb13baab203d5ad8f4c514b27ff`
2. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_LOCATOR_METHOD_COMPLETION_RESULT_V0_1.md`
   - require result blob `06671fe085baf2fc0940a498bedecffd3780cb63`
3. `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_EXECUTION_RESULT_V0_1.md`
   - require result blob `687a62e9c0016bb9521cc2f77fc451d38baa89f1`

Preserve transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

If any identity gate fails, stop before substantive review.

## 3. Accepted facts to preserve

Preserve without reinterpretation:

- original launcher contract remains failed at `START_RESULT_NOT_CAPTURED`;
- causal attribution was accepted only through the separate governance path;
- current runtime identity was subsequently rebound and established for exactly one existing Sandbox:
  `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- historical attempt ID:
  `RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- historical nonce:
  `cbbbaef73f3347d9ba72c0eeb04e9e71`;
- preserved host attempt root:
  `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- rebinding receipt:
  `rebinding-v0-1.json`;
- accepted rebinding receipt SHA-256:
  `84449F657588C4E3488C1A42F78EB6B1DB27ED1C028C98ABCD7A5EADDE37A915`;
- original recovery execution performed `0/8` shares and `0/7` materializations;
- no guest exec, guest materialization, or DEP13 occurred;
- therefore continuation would resume previously unexecuted recovery work, not repeat a completed share/materialization chain;
- no second Sandbox may be created or started;
- B12 remains NOT AUTHORIZED.

## 4. Exact decision questions

Answer all questions below from accepted repository evidence only.

### Q1 — Existing-Sandbox continuation eligibility

Decide whether a later recovery-continuation execution may use the currently rebound existing Sandbox, subject to a fresh runtime identity observation immediately before any action.

A valid later execution contract must require:

- exactly one fresh `wsb list --raw` observation before continuation action;
- exit `0`, valid JSON, exactly one applicable running Sandbox;
- sole ID exactly `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- no `wsb start`, no second Sandbox creation;
- fresh verification of `rebinding-v0-1.json` SHA-256 before action;
- failure closed on zero/multiple/mismatch/hash mismatch.

Decide whether those gates are sufficient for continuation eligibility without retroactively passing the original launcher contract.

### Q2 — Continuation evidence namespace

Decide whether the preserved historical attempt root may host new continuation-specific evidence while all existing accepted receipts remain immutable.

Preferred bounded namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

The scope review must decide and record:

- whether this exact subdirectory may be created only if absent;
- whether every new continuation receipt/script/log must remain inside it;
- existing top-level accepted receipts and `rebinding-v0-1.json` must never be overwritten, edited, deleted, renamed, or reused;
- if the namespace already exists, later execution must stop rather than clear/reuse it.

### Q3 — Continuation share scope

Decide whether a later continuation execution may resume exactly the previously accepted share map on the rebound Sandbox:

1. writable transport/evidence share for the continuation namespace or exact task-owned host evidence source to a continuation-visible guest transport root;
2. exactly seven read-only source shares:
   - `D:/flutter` -> `C:/M3A/source/flutter`
   - `C:/Users/zcxve/AppData/Local/Android/Sdk` -> `C:/M3A/source/a7/android`
   - `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot` -> `C:/M3A/source/a7/jdk`
   - `C:/Program Files/Git` -> `C:/M3A/source/a7/git`
   - `C:/Users/zcxve/AppData/Local/Pub/Cache` -> `C:/M3A/source/a7/pub`
   - `D:/GradleHome` -> `C:/M3A/source/a7/gradle`
   - `D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/input-r6-r1/apps/flutter_elitesync_module` -> `C:/M3A/source/a7/module`

No other share is eligible.

The review must explicitly decide whether the writable transport should map the existing attempt root or only the exact continuation namespace, preferring the narrowest safe write exposure.

### Q4 — New guest binding contract

The historical top-level `guest.started.json` is an accepted host-side `NOT_RUN` receipt and must remain immutable.

Define a new continuation-specific binding sentinel, preferably:

`continuation-v0-1/guest.bound.json`

It must bind at minimum:

- historical attempt ID;
- historical nonce;
- exact rebound Sandbox ID;
- accepted rebinding receipt SHA-256;
- continuation version/namespace;
- written-before-materialization assertion;
- no-second-Sandbox assertion;
- original launcher contract remains failed.

Decide whether this new sentinel is sufficient for attributing later continuation guest output without rewriting the historical `guest.started.json`.

### Q5 — Target-absence and materialization scope

Because accepted recovery execution ran `0/7` materializations, decide whether later continuation may perform the accepted target-absence gates and, only if all are absent, materialize exactly:

1. Flutter -> `C:/M3A/tools/flutter`
2. Android SDK -> `C:/M3A/tools/android`
3. JDK -> `C:/M3A/tools/jdk`
4. Git -> `C:/M3A/tools/git`
5. Pub cache -> `C:/M3A/cache/pub`
6. Gradle root -> `C:/M3A/cache/gradle`
7. Fixed module -> `C:/M3A/work/apps/flutter_elitesync_module`

Using only the already accepted robocopy contract:

`robocopy <guest-seed> <fixed-target> /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /XJ /NFL /NDL /NP /NJH`

Exit `0..7` = success; otherwise terminal failure.

No target may be overwritten, merged, deleted, or reused. If any target exists before first copy, later execution must fail closed before materialization.

### Q6 — Identity verification and terminal boundary

Decide whether the accepted bounded source/guest identity baselines from the locator/method contract may be reused unchanged for continuation verification.

A later execution, if authorized, must stop with one of:

`FIXED-GUEST RECOVERY CONTINUATION COMPLETE — DEP13 NOT RUN`

or

`FIXED-GUEST RECOVERY CONTINUATION FAILED — QUARANTINED — DEP13 NOT RUN`

It must not run DEP13 in the same execution.

### Q7 — Failure quarantine

Decide whether the conservative accepted quarantine policy remains appropriate:

- preserve continuation evidence;
- leave existing rebound Sandbox running;
- no retry;
- no second Sandbox;
- no `wsb start`;
- no stop/close/reset/kill;
- no cleanup/disposal;
- first blocker ends execution;
- no DEP13.

## 5. Required disposition

Choose exactly one:

A. `RECOVERY CONTINUATION SCOPE COMPLETE — READY FOR EXISTING-SANDBOX RECOVERY CONTINUATION EXECUTION`

B. `RECOVERY CONTINUATION SCOPE BLOCKED — SPECIFIC EXECUTION CONTRACT ELEMENTS UNRESOLVED`

C. `RECOVERY CONTINUATION NOT PERMITTED ON REBOUND SANDBOX`

If B or C, list exact blocker(s). Do not perform runtime investigation to fill them.

## 6. Explicit prohibitions

No runtime `wsb` command.
No `wsb start`.
No second Sandbox creation.
No share.
No `wsb exec`.
No guest access.
No materialization.
No DEP13.
No Maven/source-object research.
No acquisition/package fill.
No Flutter/Dart execution.
No Gradle/M3/AAR/M1/M2.
No cleanup/stop/close/reset/kill.
No README read.
FD02 remains excluded.
No broad repository/cache/host search.
No protected staged/index inspection.
No automatic helper agents.
No product implementation / LC-03 / LC-04 / Phase 36.

## 7. Required result artifact

Create exactly one bounded result document on a fresh review branch whose sole parent is verified current durable `main`.

Recommended path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_RECOVERY_CONTINUATION_SCOPE_DECISION_RESULT_V0_1.md`

The result must contain:

1. repository/FIRST/task gates;
2. accepted rebinding/attempt facts;
3. Q1-Q7 decisions;
4. exact continuation evidence namespace;
5. exact proposed writable/read-only share scope;
6. exact new guest-binding sentinel contract;
7. target-absence/materialization scope;
8. identity verification scope;
9. failure quarantine decision;
10. disposition A/B/C;
11. unresolved blocker count;
12. explicit NOT_RUN / NOT_AUTHORIZED section;
13. one safest next bounded task recommendation.

## 8. Candidate governance and stop rule

Executor must not self-accept.
Do not modify `main`.
Do not publish or execute the downstream recovery-continuation task in the same execution.

After publishing the candidate, stop and report:

- review branch;
- candidate commit;
- sole parent;
- candidate tree;
- result path;
- result blob;
- result SHA-256 if available;
- final classification;
- disposition A/B/C;
- unresolved blocker count;
- later continuation-execution readiness yes/no.

`RECOVERY CONTINUATION SCOPE COMPLETION != EXECUTION AUTHORITY`

`RECOVERY CONTINUATION SUCCESS, IF LATER ACHIEVED, != DEP13 AUTHORITY UNTIL INDEPENDENT ACCEPTANCE`
