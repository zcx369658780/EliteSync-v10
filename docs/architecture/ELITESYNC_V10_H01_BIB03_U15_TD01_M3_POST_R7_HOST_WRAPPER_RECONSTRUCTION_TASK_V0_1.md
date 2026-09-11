# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Host Wrapper Reconstruction Task｜v0.1

Status: `PUBLISHED TASK SHEET — OWNER-AUTHORIZED WRAPPER RECONSTRUCTION ONLY — NO WSB SHARE EXECUTION — B CONTROLLED EXPERIMENT PRE-AUTHORIZED AFTER INDEPENDENT C ACCEPTANCE — DEP13 NOT AUTHORIZED`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority and Owner decision

Publication-base `main`:

`0146b63d320292984d2741463c1a8f07be947b7c`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted Owner-decision-gate document:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_NATIVE_SHARE_CONTRACT_AND_HOST_WRAPPER_LOCATOR_REVIEW_ACCEPTANCE_V0_1.md`

Owner decision on 2026-09-11:

- choose Option C first: bounded host-wrapper reconstruction;
- after valid independent acceptance of C, automatically proceed to Option B: exactly one separately governed bounded controlled share experiment, without another Owner confirmation unless C exposes a genuinely new decision;
- Owner additionally permits later use of the local Android Studio emulator for testing/development if appropriate, but that permission does **not** make the emulator a silent substitute for Sandbox-specific DEP13/fixed-guest evidence. Any route change from the Sandbox-specific evidence contract to emulator-based development/testing must be explicit and preserve existing evidence semantics.

The executor may publish one bounded C candidate and must not self-accept it.

## 2. Immutable accepted state

Preserve exactly:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Current rebound/quarantined Sandbox ID:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Preserved evidence namespace:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/continuation-v0-1`

It remains immutable evidence and MUST NOT be cleared, reused, renamed, overwritten, repaired, repurposed, or used as the new wrapper's writable output location.

Installed CLI/package identity remains:

`MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`

Accepted fact boundary: public/static evidence does not explain the native `E_INVALIDARG`; five native/wrapper gaps remain, and the actual historical host wrapper is unavailable from current-project evidence.

## 3. Sole objective

Create a **new, explicit, auditable current-project host wrapper contract** for future `wsb share` execution so the historical process-launch/quoting ambiguity is eliminated prospectively.

C does not attempt to reproduce or infer the missing historical wrapper. It creates a new governed wrapper whose behavior is explicit.

The wrapper must:

1. accept an exact `wsb.exe` path, Sandbox ID, host path, optional sandbox path, writable Boolean, and raw-output Boolean;
2. construct discrete argv tokens rather than an opaque shell command string;
3. never silently normalize slash direction, canonicalize paths, create guest/host directories, change Sandbox ID, or alter caller-provided argument text;
4. emit a deterministic dry-run receipt containing the exact executable path and exact ordered argv tokens before any operational mode can exist;
5. provide a hard default of `DRY_RUN_ONLY` / no process launch;
6. require an explicit future task-owned activation token or equivalent hard gate before any operational `wsb share` process launch is possible;
7. capture future stdout, stderr, exit code, and exact argv in a task-owned evidence location when operational mode is separately authorized;
8. fail closed on missing/ambiguous inputs.

This task authorizes reconstruction of recovery tooling only. It does not authorize an operational share.

## 4. Startup gates

1. Fresh-fetch remote `main` and require the commit publishing this task.
2. Read FIRST the exact handoff and verify blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`.
3. Read this task.
4. Read the exact Owner-decision-gate acceptance named in §1.
5. Do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 5. Authorized implementation scope

A dedicated review branch may add exactly:

1. one new wrapper implementation file at:
   `tools/recovery/Invoke-EliteSyncWsbShare.ps1`
2. one result artifact at:
   `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_HOST_WRAPPER_RECONSTRUCTION_RESULT_V0_1.md`

If `tools/recovery/` does not already exist, creating this exact directory/path is authorized. Do not enumerate neighboring tool directories to choose another location.

The wrapper must be self-contained unless a standard PowerShell/.NET API is used. Do not add dependencies or helper packages.

## 6. Required non-operational verification

The executor may run the new wrapper **only in dry-run/non-launch mode** with synthetic values and with the accepted failed argv values solely to verify deterministic serialization/receipt generation.

The executor may also use a task-owned inert local argv echo helper only if necessary to prove that the chosen process-launch primitive preserves discrete arguments; such a helper must not call `wsb.exe`, access the Sandbox, or remain as an additional repository artifact. Prefer static/API-level proof plus dry-run output when sufficient.

Required evidence:

- exact wrapper blob/SHA-256;
- exact PowerShell/.NET process primitive selected;
- whether it is shell-mediated or direct-process based;
- exact future argv construction rules;
- exact dry-run receipt for the historical failed token set;
- proof that no `wsb` process was launched;
- proof that no path normalization or directory creation occurs.

## 7. Future B experiment interface

C must define, but MUST NOT execute, the exact interface that a future B task will use.

Owner has pre-authorized publication of B after independent acceptance of C. B must still be a separate task and separate execution candidate.

Unless C establishes a material reason otherwise, B should maximize information gain with exactly one operational `wsb share` attempt using:

- the accepted rebound Sandbox ID only after B's own exact runtime identity gate;
- a new task-owned host evidence namespace, never `continuation-v0-1`;
- the accepted installed `wsb.exe` identity;
- the newly accepted C wrapper;
- writable mode;
- installed CLI default Sandbox destination by **omitting `--sandbox-path`**, thereby testing whether the prior explicit guest-path/native-path condition was material;
- exact capture of stdout/stderr/exit/argv;
- STOP immediately after the single share result, with no guest access and no automatic DEP13 progression.

C must not execute this experiment.

## 8. Android Studio emulator Owner authorization

Owner has stated that local Android Studio emulator use is acceptable for later testing/development because sufficient backups exist.

This authorization is recorded as a future route permission, not as an instruction to bypass current evidence contracts.

Specifically:

- C must not start or use the emulator;
- B must remain the one bounded Windows Sandbox share experiment unless a later accepted result makes that unnecessary;
- if the Sandbox route remains blocked after B, a subsequent bounded route-decision task may use the Owner's standing permission to determine what Android/Flutter testing/development can safely move to the local Android Studio emulator while clearly separating emulator evidence from Sandbox-specific DEP13/local-state evidence;
- no existing durable UNKNOWN, U-14/U-12/TP rule, Backend/Database/PUI, legal/Safety/no-processing, or protected-index boundary is implicitly waived by emulator permission.

## 9. Explicit prohibitions

Do NOT during C:

- execute operational `wsb share`;
- run operational `wsb exec`, runtime `wsb list`, start/stop/kill/reset/close/connect to Sandbox;
- access guest state;
- touch operational contents of `continuation-v0-1`;
- create the B experiment namespace;
- materialize fixed inputs;
- run DEP13;
- perform dependency acquisition;
- run Gradle/M3/AAR/M2;
- start Android Studio or an emulator;
- perform product implementation beyond the exact wrapper tooling;
- read README or FD02;
- perform broad repo/path/cache/host enumeration;
- inspect protected staged/index state;
- modify unrelated files.

## 10. Required C candidate

Publish one candidate commit containing only the exact wrapper and result artifact authorized in §5.

Result artifact must classify exactly one of:

`HOST WRAPPER RECONSTRUCTED — PROSPECTIVE ARGV/QUOTING CONTRACT ESTABLISHED — READY FOR INDEPENDENT C ACCEPTANCE`

or

`HOST WRAPPER RECONSTRUCTION INCOMPLETE — PROSPECTIVE ARGV/QUOTING CONTRACT NOT ESTABLISHED — AWAITING INDEPENDENT C ACCEPTANCE`

It must include negative attestations proving no operational `wsb`, guest/Sandbox access, DEP13, emulator, or downstream build/dependency work occurred.

Stop immediately after publishing the candidate. Do not self-accept, merge, execute B, or publish B yourself.

## 11. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected index boundary, accepted legal/Safety/no-processing boundaries, no participant research/recruitment, no private-Conversation inspection, no telemetry/analytics/measurement, no Safety Operations, no new legal research, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 remains blocked until fixed-guest recovery continuation has actually succeeded and that success has been independently accepted.

## 12. End state

`C WRAPPER RECONSTRUCTION != SHARE RETRY`

`C ACCEPTANCE -> OWNER-PREAUTHORIZED B TASK PUBLICATION`

`B SHARE SUCCESS != DEP13 AUTHORIZATION`

`ANDROID EMULATOR PERMISSION != SANDBOX EVIDENCE SUBSTITUTION`
