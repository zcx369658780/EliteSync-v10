# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Task｜v0.1

Status: `PUBLISHED TASK SHEET — OWNER-AUTHORIZED ONE-SHOT B EXPERIMENT — EXACTLY ONE OPERATIONAL WSB SHARE — DEFAULT SANDBOX DESTINATION — NO GUEST ACCESS — NO DEP13`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and Owner authorization

Publication-base `main`:

`8b24793683aaf0be57eed7825e5f0e65648cf135`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted C acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_HOST_WRAPPER_RECONSTRUCTION_ACCEPTANCE_V0_1.md`

Accepted C candidate identities:

- candidate commit: `43041b00c8bfc7983ed698e293933f89b9e9d936`
- candidate tree: `32ade6d13a41f27998f7b6347e72940c96b7e4fc`
- wrapper repository path: `tools/recovery/Invoke-EliteSyncWsbShare.ps1`
- wrapper blob: `b3a751e18d713c98b56d66972d501292544a847f`
- wrapper SHA-256: `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`
- C result blob: `56ce487b5334b368df969bd39f8742bbb32b326e`

Owner explicitly authorized C -> B on 2026-09-11. C has now been independently accepted. This task is therefore authorized to perform exactly one operational B experiment under the contract below.

The executor may publish one B result candidate and must not self-accept it.

## 2. Immutable historical state

Preserve exactly:

`FAILED_START_RESULT_NOT_CAPTURED`

and the historical first share blocker:

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Historical rebound/quarantined Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Historical preserved namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

That namespace remains immutable evidence. Do not read its operational contents, clear it, reuse it, rename it, overwrite it, repair it, or repurpose it.

The historical launcher failure must not be reinterpreted if this B experiment succeeds.

## 3. Sole experiment hypothesis

This B experiment tests one bounded question only:

> On the exact installed Windows Sandbox CLI/runtime, with the prospective direct-argv wrapper and the exact rebound Sandbox, does a writable host-folder share succeed when `--sandbox-path` is omitted and the installed CLI/native layer chooses its default Sandbox destination?

This experiment does NOT attempt to prove the general native UDK path contract.

It is specifically designed to remove two variables from the historical failed invocation:

- the unavailable historical process-launch/quoting wrapper; and
- the explicit historical Sandbox path `C:/M3A/transport/continuation-v0-1`.

All other experiment scope is minimized and fail closed.

## 4. Startup gates

Perform in order:

1. fresh-fetch remote `main`;
2. require `main == 8b24793683aaf0be57eed7825e5f0e65648cf135`; otherwise `STOP — MAIN_AUTHORITY_CHANGED` unless a later accepted authority explicitly reissues B;
3. read FIRST the handoff and verify blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this B task;
5. read the exact C acceptance path in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`. Do not inspect protected staged/index state.

## 5. Accepted wrapper materialization gate

The accepted C wrapper is an accepted candidate blob and is not silently assumed to be present in `main`.

Before any runtime Sandbox observation or experiment action:

1. retrieve exact Git blob `b3a751e18d713c98b56d66972d501292544a847f` from the current repository object database / exact accepted candidate object;
2. write it to a **new task-owned temporary host path outside the repository**, under the B experiment root defined in §7, with filename `Invoke-EliteSyncWsbShare.ps1`;
3. compute SHA-256 and require exactly:
   `2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`;
4. if the blob is unavailable or hash mismatches, STOP with `B_ACCEPTED_WRAPPER_IDENTITY_NOT_ESTABLISHED`;
5. do not edit, normalize, patch, or regenerate the wrapper.

Reading/materializing this exact accepted blob is authorized. No candidate merge/cherry-pick is authorized.

## 6. Exact installed WSB identity gate

Resolve the installed `wsb.exe` through normal command resolution only; no broad search.

Require:

- CLI `--version` output exactly `0.8.107.0`;
- resolved package/executable identity remains consistent with accepted package `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`.

Version/help identity checks are allowed. No operational share occurs in this section.

If identity differs, STOP with `B_WSB_IDENTITY_CHANGED`.

## 7. New B experiment root and evidence namespace

Create exactly one new task-owned host root outside the repository under `$env:TEMP`, using a fresh cryptographically random or GUID nonce, for example:

`$env:TEMP/EliteSync-v10-M3B-WSB-SHARE-<nonce>`

Within it create exactly:

- `wrapper/` — contains the exact accepted wrapper materialization;
- `evidence/` — pre-existing empty directory passed to the wrapper;
- B controller/result receipts as needed for this task only.

Requirements:

- root MUST NOT equal or be under the historical `...RECOVERY-cbbbaef.../continuation-v0-1` namespace;
- root MUST NOT be inside the Git repository;
- do not reuse any previous experiment/recovery namespace;
- record root path and nonce in the B result;
- do not create any guest directory.

## 8. Runtime identity gate

After wrapper and WSB identity gates pass, run exactly one bounded runtime observation using the installed CLI's supported `list --raw` form.

Require:

- exactly one running Sandbox;
- its ID is exactly `7ebc163d-7e92-4a63-8218-47c03d5db697`.

If zero, more than one, or a different ID is observed:

`STOP — B_RUNTIME_SANDBOX_IDENTITY_GATE_FAILED`

Do not start, create, stop, close, reset, kill, connect to, or otherwise mutate any Sandbox to satisfy the gate.

The runtime observation is an identity gate only and does not retroactively pass the historical launcher contract.

## 9. Exact one-shot operational share contract

Only after §§5-8 pass, perform exactly one operational invocation of the accepted wrapper.

Required inputs:

- `WsbExePath`: exact identity-gated installed executable path;
- `SandboxId`: `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- `HostPath`: the **new B experiment root from §7** (not its `evidence/` subdirectory and not any historical namespace);
- `SandboxPath`: OMIT THE PARAMETER ENTIRELY;
- `Writable`: `$true`;
- `RawOutput`: `$true`;
- `ExecutionMode`: `OPERATIONAL`;
- `EvidenceDirectory`: exact pre-existing `evidence/` directory from §7.

Activation gate:

- generate one fresh task-owned activation token for this B run only;
- set it only in the current process scope as `ELITESYNC_WSB_SHARE_ACTIVATION_TOKEN`;
- pass the exact same token through `-ActivationToken`;
- do not persist the token in repository files, durable documentation, command-line reporting, result artifact, or logs beyond what the wrapper itself necessarily receives;
- clear/unset the process-scoped environment value immediately after wrapper completion or failure.

Exactly one call may reach the wrapper in `OPERATIONAL` mode.

Exactly one `wsb share` process launch is authorized.

No second operational wrapper call, no retry, and no alternate mapping is authorized, regardless of result.

## 10. Mandatory immediate stop after share result

After the one operational share returns, STOP all Sandbox activity immediately.

Do NOT:

- run `wsb exec`;
- access guest filesystem/state;
- inspect where the default mapping appeared inside the guest;
- test writability from the guest;
- perform a second `wsb list` unless strictly necessary to recover from a controller exception before determining whether a share launch occurred; normal post-result runtime observation is not authorized;
- materialize fixed inputs;
- run DEP13;
- run any dependency acquisition/build work.

A zero exit/share success is evidence only that this exact one-shot share invocation succeeded. It is NOT recovery-continuation success and NOT DEP13 authority.

A nonzero exit/share failure is the final B experimental result. Do not vary arguments and try again.

## 11. Required evidence capture

Preserve the B experiment root after execution as evidence until independent acceptance.

The result must record, without exposing the activation token:

- fresh `main` identity;
- accepted wrapper blob and SHA-256 gate result;
- installed `wsb.exe` path and `0.8.107.0` identity result;
- B root and nonce;
- runtime identity observation raw result and exact expected-ID match result;
- exact wrapper invocation parameter values except activation token;
- explicit fact that `SandboxPath` was omitted;
- wrapper-generated `wsb-share-argv-receipt.json` SHA-256 and decoded argv;
- stdout/stderr/result evidence filenames and SHA-256 values;
- exact exit code;
- classification of share outcome;
- proof/attestation that exactly one operational launch occurred and no retry/guest access followed.

The result must distinguish:

`ONE_SHOT_SHARE_SUCCESS`

from

`FIXED_GUEST_RECOVERY_CONTINUATION_SUCCESS`.

They are not equivalent.

## 12. Required B result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_1.md`

Do not commit the temporary B root or evidence files into Git. The result artifact records their exact identities/hashes and preserved host location.

Final classification must be exactly one of:

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — AWAITING INDEPENDENT B ACCEPTANCE — NO DEP13 AUTHORITY`

or

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE FAILED — AWAITING INDEPENDENT B ACCEPTANCE — NO RETRY AUTHORITY`

If the experiment does not reach an operational share because an earlier gate fails, classify:

`ONE-SHOT B EXPERIMENT NOT EXECUTED — PRECONDITION GATE FAILED — AWAITING INDEPENDENT B ACCEPTANCE`

Stop immediately after publishing the candidate. Do not self-accept, merge, run recovery continuation, run DEP13, or publish a downstream execution task.

## 13. Android Studio emulator route

Owner authorization to use the local Android Studio emulator for later testing/development remains standing.

B itself does not use Android Studio or an emulator.

If this one-shot B experiment fails or cannot execute, independent B acceptance should normally proceed to a bounded route-decision task that separates:

- unresolved Sandbox-specific DEP13/fixed-guest evidence; and
- testing/development work that may continue through the local Android Studio emulator without falsely claiming Sandbox evidence.

If B succeeds, the next step remains an independently governed recovery-continuation decision/contract before any guest access or DEP13.

## 14. Explicit prohibitions

Do NOT:

- execute more than one operational `wsb share`;
- supply any `SandboxPath` in the operational attempt;
- retry or substitute a mapping;
- run `wsb exec`;
- access guest state;
- create/start/stop/kill/reset/close/connect to a Sandbox;
- touch operational contents of `continuation-v0-1`;
- materialize fixed inputs;
- run DEP13;
- perform Maven/source acquisition/dependency work;
- run Gradle/M3/AAR/M2;
- start Android Studio/emulator;
- read README;
- inspect FD02;
- perform broad repo/path/cache/host/package enumeration;
- inspect protected staged/index state;
- modify the accepted wrapper;
- merge/cherry-pick the C candidate;
- perform product implementation.

## 15. Durable governance boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, accepted legal/Safety/no-processing boundaries, no participant research/recruitment, no private-Conversation inspection, no telemetry/analytics/measurement, no Safety Operations, no new legal research, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 remains blocked until fixed-guest recovery continuation actually succeeds and is independently accepted.

## 16. End state

`B = EXACTLY ONE OPERATIONAL SHARE ATTEMPT`

`B SUCCESS != FIXED-GUEST RECOVERY CONTINUATION SUCCESS`

`B SUCCESS != DEP13 AUTHORIZATION`

`B FAILURE != LICENSE FOR A SECOND EXPERIMENT`

`ANDROID EMULATOR PERMISSION != SANDBOX EVIDENCE SUBSTITUTION`
