# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Existing Sandbox Default-Destination Recovery Continuation Task｜v0.1

Status: `PUBLISHED TASK SHEET — RECOVERY CONTINUATION ONLY — B SHARE SUCCESS ACCEPTED — GUEST ACCESS BOUNDED — DEP13 STILL NOT AUTHORIZED`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`aa55b0b5ab4e912f93832612d3157a472954c670`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted B acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_ACCEPTANCE_V0_1.md`

Accepted B result identity:

- candidate commit `9d25aeff289a2f14991836ebe4a1841d629842b2`
- result blob `5f90f16c16064cceabf4def950deb06b5f33fc6f`
- B R4 evidence root `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb`

Accepted current-main wrapper:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

blob:

`b3a751e18d713c98b56d66972d501292544a847f`

The executor may publish one bounded continuation candidate and must not self-accept it.

## 2. Immutable accepted state

Preserve exactly:

`FAILED_START_RESULT_NOT_CAPTURED`

Historical failed share remains:

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted current Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Historical preserved namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

Preserve all prior B/B-R2/B-R4 evidence roots. Do not repair, reuse, rename, clear, overwrite, or repurpose any of them.

Accepted transport fact:

`DIRECT ARGV + WRITABLE + OMIT --sandbox-path -> SHARE SUCCESS`

This fact is specific to the accepted installed/runtime environment and does not rewrite the historical failure.

## 3. Sole objective

Resume the already-governed existing-Sandbox recovery continuation using the accepted default-destination writable-share contract, establish the actual default guest mapping for the new continuation share, and complete the bounded continuation evidence chain required before any DEP13 local-state work can be reconsidered.

This task is a recovery continuation, not DEP13.

## 4. Startup authority gate

The activation prompt MUST supply:

- `REQUIRED_MAIN` = the commit publishing this task;
- `REQUIRED_TASK_BLOB` = the exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the B acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 5. Wrapper identity gate

Use current-main:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

Require both:

- tree blob `b3a751e18d713c98b56d66972d501292544a847f`;
- `git hash-object --path=tools/recovery/Invoke-EliteSyncWsbShare.ps1 tools/recovery/Invoke-EliteSyncWsbShare.ps1` returns exactly the same blob.

Raw worktree SHA/EOL may be recorded but are non-gating.

Do not write index, change attributes/config, copy, normalize, patch, regenerate, rematerialize, merge, or cherry-pick the wrapper.

If this gate fails:

`STOP — CONTINUATION_WRAPPER_GIT_IDENTITY_GATE_FAILED`

## 6. Installed WSB + runtime Sandbox identity gates

Resolve installed `wsb.exe` by normal command resolution only and require version `0.8.107.0` plus package identity `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`.

Then perform exactly one bounded `wsb list --raw` observation before any continuation operation.

Require exactly one running Sandbox with ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Do not start/create/stop/kill/reset/close/connect to any Sandbox to satisfy this gate.

Failure classifications:

`STOP — CONTINUATION_WSB_IDENTITY_CHANGED`

or

`STOP — CONTINUATION_RUNTIME_SANDBOX_IDENTITY_GATE_FAILED`

## 7. Fresh continuation namespace

Create one fresh task-owned host continuation root outside the repository under `$env:TEMP`:

`$env:TEMP/EliteSync-v10-M3A-RECOVERY-CONT-R2-<fresh-nonce>`

Within it create only the bounded continuation controller/evidence files and an empty `evidence/` directory.

This root must be distinct from:

- historical `...RECOVERY-cbbbaef.../continuation-v0-1`;
- all B experiment roots;
- repository worktrees.

The fresh root is the only new writable recovery namespace authorized by this task.

## 8. Continuation transport share

Use the accepted wrapper exactly once to share the fresh continuation root writable into the already-running Sandbox.

Required wrapper inputs:

- exact identity-gated `WsbExePath`;
- Sandbox ID `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: fresh continuation root;
- `SandboxPath`: OMIT entirely;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: fresh continuation root's `evidence/`.

Use one fresh process-scoped activation token; do not persist/report it.

Exactly one continuation transport share launch is authorized in this task.

If it fails, STOP with no retry:

`CONTINUATION_DEFAULT_DESTINATION_SHARE_FAILED`

## 9. Bounded guest mapping resolution

Only after §8 share success, one bounded guest command via `wsb exec` is authorized to resolve the actual default mapped folder corresponding to the fresh continuation host root and verify that the mapping exists.

The guest command must be read-only except for the writable probe explicitly authorized in §10.

Use deterministic PowerShell inside the exact Sandbox and constrain resolution to the documented default mapped-folder area for the Sandbox user plus the exact host-root leaf name. Do not recursively enumerate unrelated guest volumes or profiles.

Record:

- exact guest mapping path found;
- exact resolution command;
- stdout/stderr/exit;
- whether exactly one matching mapped directory exists.

If zero or multiple matching directories exist, STOP:

`CONTINUATION_DEFAULT_GUEST_MAPPING_NOT_UNIQUELY_ESTABLISHED`

This observation establishes the actual default mapping for this continuation only.

## 10. Bounded writable round-trip probe

After a unique guest mapping is established, perform one bounded writable round-trip probe using a task-owned probe file name under the fresh continuation root.

Contract:

1. host creates no probe content before the guest write;
2. guest writes exactly one small deterministic text file inside the resolved mapped directory;
3. host reads only that exact probe file from the fresh continuation root;
4. require exact expected content;
5. preserve the probe as evidence until independent acceptance.

Do not use the probe to inspect any unrelated guest state.

If the round trip fails, STOP:

`CONTINUATION_WRITABLE_ROUND_TRIP_FAILED`

## 11. Re-establish continuation receipts

If §§8-10 all pass, create bounded continuation receipts proving:

- wrapper/current-main identity;
- installed WSB identity;
- runtime Sandbox identity;
- fresh continuation root identity/nonce;
- successful default-destination writable share;
- uniquely resolved guest mapping path;
- successful writable round-trip;
- exact host/guest probe hashes;
- no reuse/mutation of historical continuation evidence.

The candidate must explicitly classify whether the transport/guest-binding layer is now re-established for a future fixed-input continuation.

This task does NOT authorize reading or materializing the seven fixed dependency inputs unless a later task explicitly reauthorizes that next stage.

## 12. Mandatory stop boundary

After continuation receipts are complete, STOP.

Do NOT:

- perform additional `wsb share` attempts;
- inspect unrelated guest filesystem/state;
- read/materialize the seven fixed dependency inputs;
- run DEP13;
- perform Maven/source acquisition;
- run Gradle/M3/AAR/M2;
- run Android Studio/emulator;
- read README;
- inspect FD02;
- broadly enumerate repo/host/cache/guest paths;
- inspect protected staged/index state;
- perform product implementation.

## 13. Required candidate artifact

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_DEFAULT_DESTINATION_RECOVERY_CONTINUATION_RESULT_V0_1.md`

Final classification must be exactly one of:

`RECOVERY CONTINUATION TRANSPORT/GUEST BINDING RE-ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE — DEP13 STILL NOT AUTHORIZED`

or

`RECOVERY CONTINUATION TRANSPORT/GUEST BINDING NOT RE-ESTABLISHED — AWAITING INDEPENDENT ACCEPTANCE — DEP13 REMAINS BLOCKED`

If a startup/precondition gate prevents execution, use the second classification and identify the exact terminal gate.

Stop immediately after publishing the candidate. Do not self-accept, merge, run fixed-input continuation, run DEP13, or publish a downstream task.

## 14. Durable governance boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 remains blocked until fixed-guest recovery continuation actually succeeds and that success is independently accepted.

## 15. End state

`B SHARE SUCCESS -> CONTINUATION TRANSPORT/GUEST-BINDING VALIDATION`

`CONTINUATION TRANSPORT/GUEST BINDING SUCCESS != FIXED-INPUT CONTINUATION SUCCESS`

`CONTINUATION SUCCESS != DEP13 AUTHORITY`

`ANDROID EMULATOR PERMISSION != SANDBOX DEP13 EVIDENCE SUBSTITUTION`
