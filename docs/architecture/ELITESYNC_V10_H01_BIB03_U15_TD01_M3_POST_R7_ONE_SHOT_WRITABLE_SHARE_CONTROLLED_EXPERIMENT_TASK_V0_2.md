# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Task｜v0.2

Status: `PUBLISHED TASK SHEET — AUTHORITY-GATE CORRECTION / REISSUE — OWNER-AUTHORIZED ONE-SHOT B EXPERIMENT — EXACTLY ONE OPERATIONAL WSB SHARE — DEFAULT SANDBOX DESTINATION — NO GUEST ACCESS — NO DEP13`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Purpose of this reissue

This v0.2 reissues the B experiment because v0.1 embedded an incorrect startup equality against its publication-base acceptance commit after publication had already advanced `main`.

The v0.1 task remains the substantive experiment contract and is incorporated by exact blob:

- v0.1 path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_TASK_V0_1.md`
- v0.1 blob: `0e9f3e57695157d702f266d77c1a489715694fac`
- v0.1 publication commit: `b88c39f4e7e2ec3ddd761d8457399614b61e3a07`
- v0.1 publication-base C acceptance: `8b24793683aaf0be57eed7825e5f0e65648cf135`

This v0.2 changes only the startup authority mechanism described below. All one-shot experiment scope, evidence requirements, wrapper identity, historical-state preservation, prohibitions, result classifications, Android-emulator route preservation, and durable governance boundaries in v0.1 remain authoritative unless explicitly superseded here.

## 2. Corrected startup authority gate

The activation prompt for this task MUST provide two exact identities:

1. `REQUIRED_MAIN` = the commit that publishes this v0.2 task;
2. `REQUIRED_TASK_BLOB` = the exact Git blob of this v0.2 task.

Executor startup sequence:

1. fresh-fetch remote `main`;
2. require fresh `main == REQUIRED_MAIN`; otherwise `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST:
   `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`
   and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this v0.2 task from `REQUIRED_MAIN` and require its blob equals `REQUIRED_TASK_BLOB`;
5. read incorporated v0.1 by exact blob `0e9f3e57695157d702f266d77c1a489715694fac`;
6. read C acceptance:
   `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_HOST_WRAPPER_RECONSTRUCTION_ACCEPTANCE_V0_1.md`;
7. execute the v0.1 experiment contract with the corrected authority gate from this v0.2.

Do not use the stale v0.1 statement `main == 8b247936...` as an execution gate. That single line is superseded by this v0.2.

## 3. Reaffirmed accepted wrapper identity

The experiment must use only the independently accepted C wrapper:

- candidate commit: `43041b00c8bfc7983ed698e293933f89b9e9d936`
- wrapper blob: `b3a751e18d713c98b56d66972d501292544a847f`
- wrapper SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`

Materialize the exact blob to the new B task-owned temporary root outside the repository as defined by v0.1. Do not merge/cherry-pick the C candidate and do not modify the wrapper.

## 4. Reaffirmed one-shot operational boundary

Exactly one operational `wsb share` process launch is authorized, and only after every v0.1 precondition gate passes.

The one operational attempt MUST:

- bind exact Sandbox ID `7ebc163d-7e92-4a63-8218-47c03d5db697` after the single allowed runtime identity observation;
- use installed `wsb.exe 0.8.107.0` after identity verification;
- use the accepted direct-argv wrapper;
- use the brand-new B host experiment root as `HostPath`;
- set writable mode true;
- retain raw output true;
- OMIT `SandboxPath` entirely;
- use a fresh process-scoped activation token that is not persisted;
- capture wrapper receipt/stdout/stderr/result evidence;
- STOP immediately after the single share result.

No second attempt, alternate mapping, guest access, `wsb exec`, post-success inspection, materialization, DEP13, dependency work, Gradle/M3/AAR/M2, Android Studio/emulator, or downstream execution is authorized in B.

## 5. Historical state remains immutable

Preserve:

`FAILED_START_RESULT_NOT_CAPTURED`

and

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Preserve historical namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

It remains immutable evidence and is not the B experiment root.

## 6. Result and stop rule

Use exactly the result artifact/classifications defined by incorporated v0.1:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_1.md`

Stop immediately after publishing the single B candidate commit. Do not self-accept, merge, run continuation, run DEP13, or publish a downstream task.

## 7. End state

`V0.2 SUPERSEDES ONLY THE STALE V0.1 MAIN-EQUALITY GATE`

`B = EXACTLY ONE OPERATIONAL SHARE ATTEMPT`

`B SUCCESS != FIXED-GUEST RECOVERY CONTINUATION SUCCESS`

`B SUCCESS != DEP13 AUTHORIZATION`

`B FAILURE != LICENSE FOR A SECOND EXPERIMENT`
