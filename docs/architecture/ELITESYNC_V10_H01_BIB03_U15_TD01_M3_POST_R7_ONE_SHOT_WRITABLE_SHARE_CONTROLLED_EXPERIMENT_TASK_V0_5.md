# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Task｜v0.5

Status: `PUBLISHED TASK SHEET — GIT-SEMANTIC WRAPPER IDENTITY — OWNER-AUTHORIZED ONE-SHOT B EXPERIMENT — EXACTLY ONE OPERATIONAL WSB SHARE — DEFAULT SANDBOX DESTINATION — NO GUEST ACCESS — NO DEP13`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and purpose

This v0.5 reissues the same Owner-authorized one-shot B experiment after independent acceptance of B R3's CRLF/raw-worktree-SHA precondition stop.

Controlling acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_PRECONDITION_FAILURE_ACCEPTANCE_V0_3.md`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

The Owner-authorized operational share count remains `0/1` consumed before this task.

## 2. Startup authority gate

The activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this v0.5 task;
- `REQUIRED_TASK_BLOB` = exact Git blob of this v0.5 task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this v0.5 task from `REQUIRED_MAIN` and require `REQUIRED_TASK_BLOB`;
5. read the controlling v0.3 acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 3. Corrected current-main wrapper identity gate

Use the current-main worktree file directly:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

Accepted Git blob:

`b3a751e18d713c98b56d66972d501292544a847f`

Accepted LF-content SHA-256, retained as provenance only:

`2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`

Perform only these non-mutating identity checks:

1. resolve the current `main` tree object for the exact wrapper path and require blob `b3a751e18d713c98b56d66972d501292544a847f`;
2. compute the checked-out file's Git-clean/filter-aware object identity with:
   `git hash-object --path=tools/recovery/Invoke-EliteSyncWsbShare.ps1 tools/recovery/Invoke-EliteSyncWsbShare.ps1`
   and require output exactly `b3a751e18d713c98b56d66972d501292544a847f`;
3. record the raw worktree SHA-256 and observed EOL counts for evidence only; raw-worktree SHA equality to the LF-content SHA is NOT required.

Do not write the index, do not use `-w`, and do not alter `.gitattributes`, Git configuration, checkout settings, or the wrapper file.

Do not copy, rewrite, normalize, patch, regenerate, merge, cherry-pick, or rematerialize the wrapper.

If either Git-object identity check differs:

`STOP — B_R4_MAIN_WRAPPER_GIT_IDENTITY_GATE_FAILED`

## 4. Fresh B R4 root

Only after §3 passes, create exactly one fresh task-owned host root outside the repository under `$env:TEMP`:

`$env:TEMP/EliteSync-v10-M3B-WSB-SHARE-R4-<fresh-nonce>`

Create only:

- `evidence/` — pre-existing empty evidence directory required by the accepted wrapper;
- bounded B controller/result receipts needed by this task.

Do not reuse, repair, clear, rename, or repurpose any previous B/B-R2 root or historical `continuation-v0-1` evidence.

The current-main wrapper remains read-only at its repository path and is invoked there directly.

## 5. Installed WSB identity gate

Resolve installed `wsb.exe` using normal command resolution only.

Require:

- `wsb.exe --version` output exactly `0.8.107.0`;
- package/executable identity consistent with accepted package `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`.

If changed:

`STOP — B_R4_WSB_IDENTITY_CHANGED`

No operational share occurs here.

## 6. Runtime Sandbox identity gate

Run exactly one bounded runtime observation:

`wsb list --raw`

Require:

- exactly one running Sandbox;
- exact ID `7ebc163d-7e92-4a63-8218-47c03d5db697`.

Otherwise:

`STOP — B_R4_RUNTIME_SANDBOX_IDENTITY_GATE_FAILED`

Do not create/start/stop/kill/reset/close/connect to any Sandbox to satisfy the gate.

This observation does not retroactively pass `FAILED_START_RESULT_NOT_CAPTURED`.

## 7. Exact one-shot operational share

Only after §§3-6 pass, invoke current-main:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

exactly once in operational mode.

Required inputs:

- `WsbExePath`: exact identity-gated installed executable path;
- `SandboxId`: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: fresh B R4 root from §4;
- `SandboxPath`: OMIT THE PARAMETER ENTIRELY;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: exact pre-existing `evidence/` under B R4 root.

Activation gate:

- generate one fresh task-owned activation token;
- set it only in current process scope as `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`;
- pass the identical token via `-ActivationToken`;
- never persist or report the token;
- unset it immediately after wrapper completion/failure.

Exactly one operational wrapper call and exactly one `wsb share` process launch are authorized.

No retry, alternate mapping, second wrapper call, or second share is authorized regardless of outcome.

## 8. Mandatory stop after the share result

After that single operational share returns, STOP all Sandbox activity immediately.

Do NOT:

- run `wsb exec`;
- inspect or access guest filesystem/state;
- determine the default guest mapping location;
- test guest writability;
- run a normal post-result `wsb list`;
- materialize fixed inputs;
- resume recovery continuation;
- run DEP13;
- run dependency acquisition, Gradle/M3/AAR/M2;
- start Android Studio/emulator.

Success proves only this exact default-destination writable share invocation succeeded. It does not prove recovery continuation or authorize DEP13.

Failure proves only this exact one-shot invocation failed and does not authorize another Sandbox share experiment.

## 9. Required evidence

Preserve B R4 root until independent acceptance.

Result artifact must record, without revealing activation token:

- fresh main/task identities;
- wrapper tree blob identity;
- `git hash-object --path` clean/filter-aware identity result;
- raw worktree SHA-256 and EOL counts as non-gating evidence;
- B R4 root/nonce;
- installed WSB identity result;
- raw runtime identity observation and expected-ID result;
- exact wrapper parameters except activation token;
- explicit omission of `SandboxPath`;
- argv receipt filename/SHA-256 and decoded argv;
- stdout/stderr/result filenames and SHA-256;
- exact process exit code;
- exactly-one-launch attestation;
- no retry/guest access/downstream-work attestation.

## 10. Result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_4.md`

Final classification must be exactly one of:

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

or

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE FAILED — AWAITING INDEPENDENT B ACCEPTANCE — NO RETRY AUTHORITY`

or, if an earlier precondition fails:

`ONE-SHOT B R4 EXPERIMENT NOT EXECUTED — PRECONDITION GATE FAILED — AWAITING INDEPENDENT B ACCEPTANCE`

Stop immediately after publishing the candidate commit. Do not self-accept, merge, run continuation/DEP13, or publish a downstream task.

## 11. Android Studio emulator route

The Owner's authorization to use the local Android Studio emulator for later testing/development remains standing.

Because every prior B stop occurred before operational `wsb share`, this corrected Git-semantic gate is authorized to reach the already-approved one-shot test.

If B R4 reaches an operational share and it fails, or if a later independently accepted result determines the Sandbox route is impractical for a non-artificial environment reason, the next governance step should move to an explicit emulator-route decision rather than continue issuing experimental Sandbox share variants.

Emulator results must not be represented as Sandbox-specific DEP13 evidence.

## 12. Preserved durable boundaries

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Preserve all prior evidence roots and historical `continuation-v0-1` as immutable evidence.

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized. DEP13 remains blocked pending separately accepted fixed-guest recovery-continuation success.

## 13. End state

`B R4 = SAME OWNER-AUTHORIZED ONE-SHOT EXPERIMENT`

`PRIOR OPERATIONAL SHARE COUNT = 0`

`CURRENT MAX OPERATIONAL SHARE COUNT = 1`

`GIT BLOB/CLEAN IDENTITY CONTROLS TEXT SOURCE IDENTITY; RAW CHECKOUT EOL SHA DOES NOT`

`B SUCCESS != DEP13 AUTHORITY`

`B FAILURE != RETRY AUTHORITY`
