# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Task｜v0.3

Status: `PUBLISHED TASK SHEET — CORRECTED WRAPPER MATERIALIZATION — OWNER-AUTHORIZED ONE-SHOT B EXPERIMENT — EXACTLY ONE OPERATIONAL WSB SHARE — DEFAULT SANDBOX DESTINATION — NO GUEST ACCESS — NO DEP13`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and purpose

This v0.3 reissues B after independent acceptance of the prior precondition stop. The prior experiment did not execute any operational `wsb share`; its only failure was the wrapper materialization method.

Controlling acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_PRECONDITION_FAILURE_ACCEPTANCE_V0_1.md`

The Owner-authorized operational budget remains exactly one share launch and is still unconsumed.

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted wrapper identity remains:

- blob: `b3a751e18d713c98b56d66972d501292544a847f`
- SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`

## 2. Corrected startup authority gate

The activation prompt MUST supply:

- `REQUIRED_MAIN` = the commit publishing this v0.3 task;
- `REQUIRED_TASK_BLOB` = this task's exact blob.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this v0.3 task from `REQUIRED_MAIN` and require `REQUIRED_TASK_BLOB`;
5. read the precondition-failure acceptance named in §1;
6. read the accepted C wrapper acceptance if needed;
7. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 3. New B root

Create exactly one new task-owned root outside the repository under `$env:TEMP` with a fresh GUID/nonce:

`$env:TEMP/EliteSync-v10-M3B-WSB-SHARE-R2-<nonce>`

Create exactly:

- `wrapper/`
- `evidence/`
- bounded task-owned controller/result receipts as required.

Do NOT reuse or modify:

- failed prior B root `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3B-WSB-SHARE-30d7ecfd4f2d4b9db5400e811bed4821`;
- historical `.../continuation-v0-1`.

Both remain evidence.

## 4. Exact corrected wrapper materialization

This task authorizes exactly one wrapper-materialization method.

Materialize exact Git blob:

`b3a751e18d713c98b56d66972d501292544a847f`

into the new root's:

`wrapper/Invoke-EliteSyncWsbShare.ps1`

using a byte-preserving stdout redirection from:

`git cat-file blob b3a751e18d713c98b56d66972d501292544a847f`

through `cmd.exe` redirection to the exact quoted destination path.

The controller must record the exact materialization command form used, excluding no sensitive data because this step has no activation token.

Immediately compute SHA-256 of the materialized file and require exactly:

`2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`

If hash mismatches or materialization fails:

`STOP — B_R2_ACCEPTED_WRAPPER_IDENTITY_NOT_ESTABLISHED`

Do not try another retrieval/materialization method.

Do not edit, normalize, patch, regenerate, merge, or cherry-pick the wrapper.

## 5. Installed WSB identity gate

Only after wrapper identity PASS:

- resolve installed `wsb.exe` through normal command resolution;
- require `--version` exactly `0.8.107.0`;
- require package/executable identity consistent with `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`.

If changed:

`STOP — B_R2_WSB_IDENTITY_CHANGED`

No operational share in this section.

## 6. Runtime identity gate

After §§4-5 PASS, run exactly one bounded:

`wsb list --raw`

Require exactly one running Sandbox and exact ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Otherwise:

`STOP — B_R2_RUNTIME_SANDBOX_IDENTITY_GATE_FAILED`

Do not start/create/stop/kill/reset/close/connect to any Sandbox.

This runtime gate does not rewrite historical `FAILED_START_RESULT_NOT_CAPTURED`.

## 7. Exact one-shot operational share

Only after all earlier gates PASS, invoke the accepted wrapper exactly once in operational mode.

Required inputs:

- `WsbExePath`: identity-gated installed executable;
- `SandboxId`: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: the new v0.3 B root itself;
- `SandboxPath`: OMIT entirely;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: new root's pre-existing `evidence/`.

Activation:

- generate one fresh task-owned activation token;
- set it process-scope only as `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`;
- pass identical token via `-ActivationToken`;
- never persist or report the token;
- unset immediately after wrapper completion/failure.

Exactly one operational wrapper call and exactly one `wsb share` process launch are authorized.

No retry, no alternate mapping, no second materialization method.

## 8. Immediate stop rule

After the one share returns, STOP all Sandbox activity.

Do NOT:

- run `wsb exec`;
- inspect guest filesystem or mapping location;
- test guest writability;
- run another normal post-result `wsb list`;
- materialize fixed inputs;
- run recovery continuation or DEP13;
- run dependency acquisition, Gradle/M3/AAR/M2;
- start Android Studio/emulator.

Success proves only this exact one-shot share succeeded. Failure proves only this exact one-shot share failed. Neither result authorizes automatic downstream execution.

## 9. Required evidence

Preserve the new B root until independent acceptance.

Result artifact must record:

- fresh main/task identities;
- new root/nonce;
- exact wrapper materialization method;
- wrapper SHA-256 gate result;
- installed WSB identity result;
- raw runtime identity observation and exact-ID result;
- exact wrapper invocation parameters except activation token;
- explicit omission of `SandboxPath`;
- argv receipt SHA-256 + decoded argv;
- stdout/stderr/result filenames + SHA-256;
- exact exit code;
- exactly-one-launch attestation;
- no retry/guest access/downstream work attestation.

## 10. Result candidate

Publish exactly one artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_2.md`

Final classification exactly one of:

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE FAILED — AWAITING INDEPENDENT B ACCEPTANCE — NO RETRY AUTHORITY`

or, if a precondition fails before operational launch:

`ONE-SHOT B R2 EXPERIMENT NOT EXECUTED — PRECONDITION GATE FAILED — AWAITING INDEPENDENT B ACCEPTANCE`

Stop after publishing candidate. Do not self-accept, merge, run continuation/DEP13, or publish downstream tasks.

## 11. Android Studio emulator route

Owner permission for later local Android Studio emulator testing/development remains standing.

This corrected B task still runs first because the prior B never reached Sandbox execution. If this corrected B fails operationally or the Sandbox route remains impractical after independent acceptance, the next governance step should evaluate an explicit emulator-development route without treating emulator results as Sandbox-specific DEP13 evidence.

## 12. Preserved state and durable boundaries

Preserve:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized. DEP13 remains blocked pending separately accepted recovery-continuation success.

## 13. End state

`B R2 = SAME OWNER-AUTHORIZED ONE-SHOT EXPERIMENT, NOT A SECOND SHARE ATTEMPT`

`PRIOR B OPERATIONAL SHARE COUNT = 0`

`CURRENT MAX OPERATIONAL SHARE COUNT = 1`

`B SUCCESS != DEP13 AUTHORITY`

`B FAILURE != RETRY AUTHORITY`