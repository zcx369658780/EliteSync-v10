# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Acceptance｜v0.1

Status: `ACCEPTED — DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED — DIRECT-ARGV / OMIT-SANDBOXPATH CONTRACT ESTABLISHED FOR THIS INSTALLED RUNTIME — RECOVERY CONTINUATION MAY BE PUBLISHED — NO DEP13 AUTHORITY`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent acceptance authority

Acceptance-base `main`:

`38b27398b26f1f406b339a0ccd1b1dc50250c0f2`

Accepted B candidate:

- branch: `review/h01-bib03-u15-td01-m3-post-r7-one-shot-writable-share-controlled-experiment-v0-4`
- commit: `9d25aeff289a2f14991836ebe4a1841d629842b2`
- sole parent: `38b27398b26f1f406b339a0ccd1b1dc50250c0f2`
- tree: `c4df7382e9b58d2250f1f96fd12f34feee776832`
- result path: `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_ONE_SHOT_WRITABLE_SHARE_CONTROLLED_EXPERIMENT_RESULT_V0_4.md`
- result blob: `5f90f16c16064cceabf4def950deb06b5f33fc6f`
- reported SHA-256: `D3F48DDB8A052982054B50C986B2C56A7C02083D6599A9B560B5181E40CCE44C`

FIRST handoff remains blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`.

## 2. Accepted findings

The B candidate is accepted as a valid one-shot operational result.

Accepted gates and execution facts:

- current-main wrapper tree blob exactly `b3a751e18d713c98b56d66972d501292544a847f`;
- Git clean/filter-aware worktree identity exactly the same blob;
- installed `wsb.exe` identity/version exactly `0.8.107.0` / `MicrosoftWindows.WindowsSandbox_0.8.107.0_x64__cw5n1h2txyewy`;
- exactly one `wsb list --raw` observation found exactly one running Sandbox, ID `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- exactly one operational wrapper call and exactly one `wsb share` launch occurred;
- host path was fresh B R4 root `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3B-WSB-SHARE-R4-5b21067adecf449f82ea9fb842fa91eb`;
- writable mode and raw output were enabled;
- `SandboxPath` / `--sandbox-path` was omitted entirely;
- decoded argv contains exactly seven tokens and no sandbox-destination token/value;
- process exit code was `0`;
- stdout and stderr were empty;
- argv receipt SHA-256 was `124E7BF871521F0C1AD5C4FF836AA37D69421CCBBF38BDE4C491889F474467DB`;
- activation token was not persisted or disclosed;
- no retry, second share, post-result `wsb list`, guest access, `wsb exec`, continuation, materialization, or DEP13 occurred.

## 3. Accepted classification

`ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE SUCCEEDED`

This establishes a bounded runtime contract for this installed environment:

`DIRECT ARGV + WRITABLE + OMIT --sandbox-path -> SHARE SUCCESS`

It does not establish the undocumented native path contract generally and does not retroactively reinterpret the historical failed share.

Historical state remains:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

## 4. What B success does and does not authorize

B success proves only that the exact default-destination share operation succeeded against the exact accepted running Sandbox/runtime.

It does NOT prove:

- fixed-guest recovery continuation success;
- exact default guest mapping location by observation;
- guest-side writability by observation;
- materialization success;
- guest identity of fixed inputs;
- DEP13 local-state completion.

Therefore:

`B SUCCESS != FIXED_GUEST_RECOVERY_CONTINUATION SUCCESS`

`B SUCCESS != DEP13 AUTHORITY`

## 5. Next bounded gate

Owner standing authorization permits publication of a separate existing-Sandbox recovery-continuation task because the transport contract is now demonstrated and no new Owner product decision is required.

The next task must:

1. bind the same accepted Sandbox identity with a fresh runtime gate;
2. use the accepted current-main wrapper and the now-proven default-destination writable-share contract;
3. create a fresh continuation namespace distinct from every previous B/recovery root and preserve all historical evidence roots;
4. use guest access only as explicitly required to identify/validate the default mapped folder and continue the already-governed recovery sequence;
5. re-establish the fixed-guest recovery chain with fail-closed receipts;
6. stop before DEP13 unless the continuation has fully succeeded and has itself been independently accepted.

The task must not treat the B evidence root itself as the durable fixed-input recovery namespace.

## 6. Android Studio emulator route

The Owner's standing permission for later Android Studio emulator testing/development remains valid, but B succeeded, so there is no reason to abandon the Sandbox recovery chain at this gate.

The emulator remains a permitted later development/testing route and must not substitute for Sandbox-specific DEP13 evidence.

## 7. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

DEP13 remains blocked until a fixed-guest recovery continuation actually succeeds and that success is independently accepted.

## 8. Acceptance result

`ACCEPT — ONE-SHOT DEFAULT-DESTINATION WRITABLE SHARE VALID — TRANSPORT CONTRACT ESTABLISHED FOR CURRENT RUNTIME — PUBLISH SEPARATE EXISTING-SANDBOX RECOVERY CONTINUATION — NO DEP13 AUTHORITY`
