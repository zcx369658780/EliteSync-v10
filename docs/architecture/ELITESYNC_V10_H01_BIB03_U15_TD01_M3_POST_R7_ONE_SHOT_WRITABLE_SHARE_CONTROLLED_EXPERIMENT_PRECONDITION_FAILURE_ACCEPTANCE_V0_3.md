# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 One-Shot Writable Share Controlled Experiment Precondition Failure Acceptance｜v0.3

Status: `ACCEPTED — B R3 DID NOT EXECUTE — RAW WORKTREE SHA MISMATCH IS EOL REPRESENTATION, NOT GIT-BLOB DRIFT — OPERATIONAL SHARE BUDGET REMAINS 0/1 — REISSUE WITH GIT-SEMANTIC WRAPPER IDENTITY GATE`

Date: 2026-09-11 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent acceptance

Acceptance-base `main`:

`940781110a47cdcf2ccf72e49f4c38916857c2ba`

Accepted candidate:

- branch: `review/h01-bib03-u15-td01-m3-post-r7-one-shot-writable-share-controlled-experiment-v0-3`
- commit: `91e2811cffa8f39ac091a3d85ec3996284c38d03`
- sole parent: `940781110a47cdcf2ccf72e49f4c38916857c2ba`
- tree: `4ee8d79800169ae54d698f8e84e7c199bea75f6c`
- result blob: `de60a2af03ec7c120fdbcabb1e42ba2cdb52b437`
- reported SHA-256: `0BFE7ABCF0605634E7420A2EDEF465185C85E2151A0978CBFDF105912AB8E68E`

The candidate is accepted as a valid fail-closed precondition result.

## 2. Accepted finding

At exact current `main`, the wrapper path:

`tools/recovery/Invoke-EliteSyncWsbShare.ps1`

resolved to the exact accepted Git blob:

`b3a751e18d713c98b56d66972d501292544a847f`

but the Windows worktree copy had CRLF line endings and therefore a raw-file SHA-256 of:

`E2B6B98E77789C68381A2C06057D37836073E6C6A63EB7F18C0DEC31DF7E7000`

rather than the accepted LF-content SHA-256:

`2776034B4BD42FA5D25EB2997B59EDEE5AEFF3668C567788BBCB3CF222A3BE64`.

The candidate correctly stopped because v0.4 required both identities literally and prohibited rewriting/normalization.

This result does **not** establish source drift. The authoritative repository object identity matched exactly. The observed mismatch is a checked-out text representation/EOL issue under the current worktree, not evidence that the accepted wrapper Git content changed.

## 3. Operational budget and Sandbox meaning

Accepted counters remain:

- operational wrapper calls: `0`;
- operational `wsb share`: `0/1`;
- `wsb --version`: `NOT_RUN`;
- runtime `wsb list --raw`: `NOT_RUN`;
- activation token: `NOT_GENERATED`;
- guest/Sandbox access: `0`.

Therefore the Owner-authorized one-shot operational share budget remains unconsumed.

No conclusion about Windows Sandbox writable-share success/failure may be drawn from B R3.

## 4. Corrected wrapper identity rule

For this repository text file, future B execution must not require the raw Windows worktree bytes to equal the LF Git-blob SHA-256.

The corrected identity gate shall require:

1. current `main` tree path `tools/recovery/Invoke-EliteSyncWsbShare.ps1` resolves exactly to Git blob `b3a751e18d713c98b56d66972d501292544a847f`;
2. a non-mutating Git clean/filter-aware hash of the checked-out path, using `git hash-object --path=tools/recovery/Invoke-EliteSyncWsbShare.ps1 tools/recovery/Invoke-EliteSyncWsbShare.ps1` (or exact equivalent that applies Git's path conversion semantics without writing), resolves to the same blob `b3a751e18d713c98b56d66972d501292544a847f`;
3. raw worktree SHA-256 and EOL counts may be recorded for evidence but are not a pass/fail source-identity condition;
4. no copying, rewriting, normalization, checkout mutation, attributes change, or wrapper modification is authorized.

If the clean/filter-aware object identity does not equal the accepted blob, fail closed.

## 5. Reissue authority

No new Owner decision is required. B has still not reached an operational share.

The same Owner-authorized one-shot B experiment may be reissued with:

- the corrected Git-semantic wrapper identity gate above;
- one fresh B root;
- installed `wsb.exe 0.8.107.0` identity gate;
- one runtime Sandbox identity observation;
- exactly one writable `wsb share` with `SandboxPath` omitted;
- immediate stop after the single result;
- no guest access or DEP13 progression.

If the corrected B reaches an actual operational share and fails, no further Sandbox share experiment is automatically authorized; the Owner's Android Studio emulator permission should then be considered through a separate route-decision task.

## 6. Preserved state

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Prior B evidence roots and historical `continuation-v0-1` remain immutable and must not be reused or repaired.

All durable D-02/U-14/U-12/TP, Backend/Database/PUI, README/FD02, protected-index, legal/Safety/no-processing, LC-03/LC-04/Phase36, B12, M2, and DEP13 boundaries remain in force.

## 7. Acceptance result

`ACCEPT — B R3 PRECONDITION STOP VALID — GIT BLOB IDENTITY PASSED — RAW WORKTREE SHA FAILURE IS EOL REPRESENTATION — NO OPERATIONAL SHARE OCCURRED — REISSUE SAME ONE-SHOT B WITH GIT-SEMANTIC IDENTITY GATE`
