# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Existing Sandbox Rebinding / Identity Establishment Task v0.1

Status: `TASK AUTHORIZED — EXISTING QUARANTINED SANDBOX REBINDING / IDENTITY ESTABLISHMENT ONLY — NO SECOND SANDBOX — NO START — NO SHARE — NO EXEC — NO MATERIALIZATION — DEP13 NOT AUTHORIZED`

Date: 2026-09-11

Repository: `zcx369658780/EliteSync-v10`

## 1. Purpose

Perform one bounded runtime rebinding / identity-establishment check for the already quarantined Sandbox:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

This task exists only to determine whether that exact existing Sandbox is still the sole applicable running Sandbox and may be bound, under a new governance receipt, to the accepted recovery attempt:

- attempt ID: `RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`
- nonce: `cbbbaef73f3347d9ba72c0eeb04e9e71`

This task does **not** retroactively pass the original launcher contract. It does not create or start another Sandbox, does not share to or execute in the Sandbox, does not materialize M3A roots, and does not run DEP13.

`REBINDING != ORIGINAL LAUNCHER PASS`

`REBINDING != RECOVERY COMPLETION`

`REBINDING != DEP13 AUTHORITY`

## 2. Mandatory repository startup gate

Fresh-fetch GitHub `main` first and require exact durable authority:

`37d3ad36704551a217a4a8478af066622eb93494`

Require exact tree:

`fdf5f3c19549136dbe2b5016a88326224bf77537`

Read FIRST:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_QUARANTINED_SANDBOX_ATTRIBUTION_REVIEW_ACCEPTANCE_V0_1.md`

Require FIRST blob:

`616d7716b8b69513b4175c0e90818f252315886e`

Also read the accepted fixed-guest recovery execution acceptance and result only as exact evidence inputs for preserved attempt identity and quarantine state:

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_EXECUTION_ACCEPTANCE_V0_1.md`
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_GUEST_RECOVERY_EXECUTION_RESULT_V0_1.md`

Require accepted recovery result blob:

`687a62e9c0016bb9521cc2f77fc451d38baa89f1`

Preserve transition FIRST blob:

`18485c95262051e43892436fb52413132c5ee626`

If any identity gate fails, stop before runtime observation.

## 3. Preserved accepted facts

Preserve all of the following:

- original launcher contract remains failed at `START_RESULT_NOT_CAPTURED`;
- exactly one historical `wsb start` invocation occurred in the accepted recovery execution;
- no retry/second creation occurred;
- causal attribution review was accepted as sufficient only for a separately bounded rebinding review;
- historical observed quarantined Sandbox ID is exactly `7ebc163d-7e92-4a63-8218-47c03d5db697`;
- historical attempt ID is exactly `RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- historical nonce is exactly `cbbbaef73f3347d9ba72c0eeb04e9e71`;
- preserved attempt root is exactly `C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`;
- accepted recovery execution performed `0/8` shares and `0/7` materializations;
- no guest exec or DEP13 occurred;
- the accepted seven existing receipts must not be overwritten, edited, renamed, deleted, or reused as the new rebinding receipt.

## 4. Exact runtime observation authority

This task authorizes exactly one runtime command family and no other Sandbox interaction:

`wsb list --raw`

Use exact executable:

`C:/Users/zcxve/AppData/Local/Microsoft/WindowsApps/wsb.exe`

Require CLI version:

`0.8.107.0`

One fresh observation is authorized after repository/FIRST gates pass.

The observation must:

1. return exit `0`;
2. parse as valid JSON;
3. expose `WindowsSandboxEnvironments`;
4. identify applicable running environments only;
5. require count exactly `1`;
6. require the sole running Sandbox ID exactly equal:

`7ebc163d-7e92-4a63-8218-47c03d5db697`

Fail closed on:

- nonzero exit;
- invalid JSON;
- missing required property;
- zero running environments;
- more than one running environment;
- sole ID mismatch.

Do not run `wsb list` repeatedly to wait for a desired state. One fresh observation only.

## 5. Explicitly prohibited Sandbox operations

No `wsb start`.
No second Sandbox creation.
No share.
No `wsb exec`.
No guest filesystem access.
No stop/close/reset/kill.
No cleanup/disposal.
No modification of Sandbox state.
No attempt to recover the historical start stdout, exit code, or direct returned GUID through runtime interaction.

## 6. Preserved receipt verification

This task may perform bounded host-side read-only verification of the existing accepted receipt files under the exact preserved attempt root only.

Expected receipt paths and accepted SHA-256 values:

- `launcher.json` — `1314C3737A786E44C9E3C0DDA19F5EA7058C347587354636224E3427DF5DC465`
- `guest.started.json` — `8A7B6035FC4B0B6AC0DBF7AA16D42453EFF0F9AEC51F17E2459C56409B8CFBCF`
- `share-results.json` — `514D557B925FA8E990FE34D53A203F02A1F87A3D4DD1DE70C5A7A71EBDDC77E4`
- `materialization-results.json` — `328B167E7BF7D7BFC686068BB47DF6DC2D3E303FFFFC4BA0C709EECEF5FEB57D`
- `identity-results.json` — `484A50408A7063C5DF21EF3C7194927237C4BE33D2313E4FEDF7F9D1714A19FD`
- `recovery-result.json` — `A217D0A88F065E6D93FFCDC42549EDC6EB909BE8CED88198DDBDC962F9FEBA97`
- `recovery-summary.json` — `E0B41C440E1814E25099C3A9268EEAFB650B83FEB03759C32A7465FE803FC7C4`

Verification is limited to:

- exact path exists;
- exact file type;
- exact SHA-256 match.

Do not reinterpret or edit their contents for this task. Do not enumerate the attempt root beyond these literal seven receipt names plus the one new rebinding receipt defined below.

If any expected accepted receipt is absent or hash-mismatched, fail closed.

## 7. New rebinding receipt

If and only if:

- repository/FIRST gates pass;
- all seven accepted receipt hashes match;
- one fresh `wsb list --raw` observation passes and returns exactly one running Sandbox with the exact expected ID;

create exactly one new task-owned host-side receipt at:

`C:/Users/zcxve/AppData/Local/Temp/EliteSync-v10-M3A-RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71/rebinding-v0-1.json`

The path must not already exist.

If it exists, stop. Do not overwrite, delete, rename, clear, or reuse it.

The receipt must be written atomically through a same-directory temporary file, flushed/closed, and atomically renamed to the final path.

Required fields:

- `schema = existing-sandbox-rebinding/v1`
- `attempt_id = RECOVERY-cbbbaef73f3347d9ba72c0eeb04e9e71`
- `nonce = cbbbaef73f3347d9ba72c0eeb04e9e71`
- `sandbox_id = 7ebc163d-7e92-4a63-8218-47c03d5db697`
- `original_launcher_contract = FAILED_START_RESULT_NOT_CAPTURED`
- `causal_attribution = ACCEPTED_FOR_BOUNDED_REBINDING_REVIEW`
- `runtime_observation_exit = 0`
- `runtime_running_count = 1`
- `runtime_observed_sandbox_id = 7ebc163d-7e92-4a63-8218-47c03d5db697`
- `accepted_receipts_verified = 7`
- `accepted_receipt_hash_mismatches = 0`
- `second_sandbox_created = false`
- `sandbox_started = false`
- `sandbox_shared = false`
- `sandbox_exec = false`
- `materialization_run = false`
- `dep13_run = false`
- `written_utc`
- `classification`

Success classification in the receipt:

`EXISTING SANDBOX REBOUND — CURRENT RUNTIME IDENTITY ESTABLISHED — RECOVERY CONTINUATION NOT YET AUTHORIZED — DEP13 NOT RUN`

This new receipt does not rewrite or supersede any earlier receipt.

## 8. Failure behavior

If any gate fails before receipt creation:

- do not create `rebinding-v0-1.json` unless a bounded failure receipt can be safely written without overwriting existing evidence; if no such exact failure-receipt path is defined, report the failure only in the repository result;
- do not create a second Sandbox;
- do not stop/close/reset/kill the observed Sandbox;
- do not share or exec;
- do not run DEP13;
- preserve all existing evidence unchanged.

## 9. Result artifact

Create exactly one bounded result document on a fresh review branch whose sole parent is the verified durable `main`.

Recommended result path:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_REBINDING_IDENTITY_ESTABLISHMENT_RESULT_V0_1.md`

The result must include:

1. repository/FIRST/task gates;
2. seven-receipt hash verification table;
3. exact single `wsb list --raw` observation and parsed state;
4. whether the expected Sandbox is currently the unique running Sandbox;
5. whether `rebinding-v0-1.json` was created;
6. rebinding receipt SHA-256 if created;
7. explicit statement that original launcher failure remains unchanged;
8. exact rebinding classification;
9. explicit NOT_RUN/NOT_AUTHORIZED section;
10. one safest next bounded task recommendation.

## 10. Final classifications

On success use:

`EXISTING SANDBOX REBINDING COMPLETE — CURRENT RUNTIME IDENTITY ESTABLISHED — READY FOR RECOVERY CONTINUATION SCOPE DECISION — DEP13 NOT RUN`

On failure use:

`EXISTING SANDBOX REBINDING FAILED — CURRENT RUNTIME IDENTITY NOT ESTABLISHED — DEP13 NOT RUN`

## 11. Explicit NOT_RUN / NOT_AUTHORIZED

No second Sandbox.
No `wsb start`.
No share.
No `wsb exec`.
No guest access.
No materialization.
No DEP13.
No Maven/source research.
No acquisition/package fill.
No Flutter/Dart execution.
No Gradle/M3/AAR/M1/M2.
No product implementation.
No LC-03 / LC-04 / Phase 36.
No README read.
FD02 remains excluded.
No broad repository/cache/host search.
No protected staged/index inspection.
No automatic helper agents.

## 12. Candidate governance and stop rule

The executor must not self-accept.
Do not modify `main`.
Do not publish or execute recovery continuation or DEP13 tasks in the same execution.

After publishing the candidate, stop and report:

- review branch;
- candidate commit;
- sole parent;
- candidate tree;
- result path;
- result blob;
- result SHA-256 if available;
- final classification;
- runtime running Sandbox count;
- runtime observed Sandbox ID;
- accepted receipt hash pass count;
- rebinding receipt created yes/no;
- rebinding receipt SHA-256 if created.

`REBINDING COMPLETION != RECOVERY CONTINUATION AUTHORITY`

`REBINDING COMPLETION != DEP13 AUTHORITY`
