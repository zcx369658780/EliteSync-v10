# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Task｜v0.4

Status: `PUBLISHED TASK SHEET — WRAPPER PROMOTED TO MAIN — OWNER-AUTHORIZED ONE-SHOT B EXPERIMENT — EXACTLY ONE OPERATIONAL WSB SHARE — DEFAULT SANDBOX DESTINATION — NO GUEST ACCESS — NO DEP13`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and purpose

This v0.4 reissues the same Owner-authorized one-shot B experiment after accepting B R2's instruction-compatibility stop and promoting the already accepted C wrapper exactly into `main`.

Controlling B R2 acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_PRECONDITION_FAILURE_ACCEPTANCE_V0_2.md`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

The operational share budget remains `0/1` consumed before this task.

## 2. Corrected startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this v0.4 task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task from `REQUIRED_MAIN` and require `REQUIRED_TASK_BLOB`;
5. read controlling B R2 acceptance from §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 3. Wrapper identity gate — no materialization

Use the current-main repository file directly:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

Require its Git blob exactly:

`b3a751e18d713c98b56d66972d501292544a847f`

and SHA-256 exactly:

`2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`

No temporary wrapper copy/materialization is required or authorized. Do not rewrite, copy, normalize, patch, regenerate, merge, or cherry-pick the wrapper.

If current-main path/blob/hash differs:

`STOP — B_R3_MAIN_WRAPPER_IDENTITY_GATE_FAILED`

## 4. Fresh B R3 root

After wrapper identity PASS, create exactly one new task-owned root outside repository under `$env:TEMP`:

`$env:TEMP/EliteSync-v10-M3B-WSB-SHARE-R3-<fresh-nonce>`

Create only:

- `evidence/` as the pre-existing evidence directory required by the wrapper;
- bounded controller/result receipts necessary for this task.

Do not reuse or modify either prior B root, B R2 root, or historical `continuation-v0-1`. All remain evidence.

The repository wrapper path remains read-only input; do not copy it into the B root.

## 5. Installed WSB identity gate

Resolve installed `wsb.exe` via normal command resolution only.

Require:

- `wsb.exe --version` exactly `0.8.107.0`;
- package/executable identity consistent with `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`.

If changed:

`STOP — B_R3_WSB_IDENTITY_CHANGED`

## 6. Runtime identity gate

Run exactly one bounded:

`wsb list --raw`

Require exactly one running Sandbox and exact ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Otherwise:

`STOP — B_R3_RUNTIME_SANDBOX_IDENTITY_GATE_FAILED`

Do not start/create/stop/kill/reset/close/connect to any Sandbox.

This gate does not rewrite `FAILED_START_RESULT_NOT_CAPTURED`.

## 7. Exact one-shot operational share

Only after §§3-6 PASS, invoke the current-main accepted wrapper exactly once in operational mode.

Required inputs:

- `WsbExePath`: identity-gated installed executable;
- `SandboxId`: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: fresh B R3 root from §4;
- `SandboxPath`: OMIT entirely;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: B R3 root's pre-existing `evidence/`.

Activation:

- generate one fresh task-owned activation token;
- set only process-scope `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`;
- pass identical token via `-ActivationToken`;
- never persist or report token;
- unset immediately after completion/failure.

Exactly one operational wrapper call and exactly one `wsb share` process launch are authorized.

No retry or alternate mapping is authorized.

## 8. Immediate stop after share

After the one share returns, STOP all Sandbox activity immediately.

Do NOT:

- run `wsb exec`;
- inspect guest filesystem/mapping;
- test guest writability;
- run another normal post-result `wsb list`;
- materialize fixed inputs;
- run recovery continuation or DEP13;
- run dependency acquisition, Gradle/M3/AAR/M2;
- start Android Studio/emulator.

A zero exit proves only this exact share call succeeded. A nonzero result proves only this exact call failed. Neither authorizes automatic downstream action.

## 9. Required evidence

Preserve B R3 root until independent acceptance.

Result artifact must record:

- fresh main/task identities;
- current-main wrapper path/blob/SHA-256 gate;
- B R3 root/nonce;
- installed WSB identity;
- raw runtime identity result and exact-ID match;
- exact wrapper parameters except activation token;
- explicit `SandboxPath` omission;
- wrapper argv receipt SHA-256 + decoded argv;
- stdout/stderr/result filenames + SHA-256;
- exact exit code;
- exactly-one-launch attestation;
- no retry/guest access/downstream work attestation.

## 10. Result candidate

Publish exactly one artifact on dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_3.md`

Final classification exactly one of:

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE FAILED — AWAITING INDEPENDENT B ACCEPTANCE — NO RETRY AUTHORITY`

or, if an earlier gate fails:

`ONE-SHOT B R3 EXPERIMENT NOT EXECUTED — PRECONDITION GATE FAILED — AWAITING INDEPENDENT B ACCEPTANCE`

Stop after candidate publication. Do not self-accept, merge, run continuation/DEP13, or publish downstream tasks.

## 11. Android Studio emulator route

Owner permission for later local Android Studio emulator testing/development remains standing.

This v0.4 should be the final attempt to reach the already-authorized one-shot Sandbox share without inventing another wrapper/materialization mechanism. If B R3 fails operationally, or a non-wrapper/environment condition makes the Sandbox route impractical after independent acceptance, the next governance step should explicitly evaluate the emulator-development route while keeping Sandbox-specific DEP13 evidence unresolved rather than substituting emulator results.

## 12. Preserved immutable state

Preserve:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Preserve prior B root, B R2 root, and historical `continuation-v0-1` as immutable evidence.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized. DEP13 remains blocked pending separately accepted recovery-continuation success.

## 13. End state

`B R3 = SAME OWNER-AUTHORIZED ONE-SHOT EXPERIMENT`

`PRIOR OPERATIONAL SHARE COUNT = 0`

`CURRENT MAX OPERATIONAL SHARE COUNT = 1`

`MAIN WRAPPER IDENTITY REPLACES TEMP MATERIALIZATION`

`B SUCCESS != DEP13 AUTHORITY`

`B FAILURE != RETRY AUTHORITY`
