# EliteSync v10｜Next IP-13I-R6-R2 Provenance-Ledger Correction Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY PROVENANCE CORRECTION — NO SEMANTIC CHANGE — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Pre-task main: `27b199111608492fdb94d047ed61a8a324e7f56f`

Rejected R6-R1 candidate: `79c6b1f788cd4d8f0eb825f915ade41b71f56ba5`

Rejected R6-R1 result blob: `733318a00cff9d093f33da7196accd90e8e6912c`

R6-R1 independent review blob: `93b7180ddabd3c0a92f0ec9301d1d3cbbf156224`

## 1. Objective

Produce one second corrected immutable R6 result candidate.

The only remaining defect is the provenance wording in Section 2 of the R6-R1 candidate.

The R6-R1 candidate correctly fixed object identities and preserved the R6 semantic contract, but Section 2 labeled the full inherited ledger as `Exact input read` while Section 16 correctly stated that R6-R1 read only its authorized exact paths.

R6-R2 must remove that contradiction without reopening the substantive R6 review.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R6-R2 task.
4. Require `origin/main` to equal that task-publication commit exactly.
5. Read this R6-R2 task.
6. Read the R6-R1 independent review.
7. Read the rejected R6-R1 result exactly from commit `79c6b1f788cd4d8f0eb825f915ade41b71f56ba5`.
8. Verify rejected R6-R1 result blob equals `733318a00cff9d093f33da7196accd90e8e6912c`.
9. Verify the original R6 task blob recorded in that result remains `e62bf3d99d5c88af877f50f70241defae24140a8` by reading the original R6 task at commit `681296dde83aeca723007a74e7f23a5935515627`.
10. Create one isolated review branch/worktree from exactly the R6-R2 task-publication commit.
11. Verify the corrected R6 result path is absent on fresh main.
12. Stop rather than adapt if any fixed identity differs.

Recommended branch:

`review/next-ip-13i-r6-r2-provenance-ledger-correction-v0-1`

## 3. Exact authorized read scope

Read only:

1. `AGENTS.md`
2. this R6-R2 correction task
3. `docs/architecture/ELITESYNC_V10_IP_13I_R6_R1_CORRECTED_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
4. rejected R6-R1 result at exact commit `79c6b1f788cd4d8f0eb825f915ade41b71f56ba5`
5. original R6 task at exact commit `681296dde83aeca723007a74e7f23a5935515627`

Do not directly reread any other original R6 fixed-input file.

The original R6 fixed-input identities beyond the original R6 task are inherited evidence. They were already independently cross-checked by the prior R6 rejection review and carried forward by R6-R1. R6-R2 must not reopen them merely to restate their identities.

No repository enumeration, search/discovery, README read, FD02 read, old repository access or unrelated file read is authorized.

## 4. Exact tracked write scope

Create exactly one path:

`docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`

No other tracked file may change.

No code, route, controller, middleware, provider, config, test or accepted R5/IP-13F artifact may change.

## 5. Exact correction rules

Use the rejected R6-R1 result as the complete semantic source.

The corrected result must keep:

- Section 1 byte-for-byte unchanged;
- Sections 3 through 15 byte-for-byte unchanged.

Only the following may change:

### A. Publication metadata

Update:
- status to identify R6-R2 correction-only candidate;
- fresh `origin/main` / R6-R2 task-publication commit;
- publication sole parent;
- review branch;
- candidate/tree external-resolution wording if necessary.

### B. Section 2 provenance wording

Replace the single ambiguous `Exact input read` ledger with two explicit groups.

#### Group 1 — Directly read in this R6-R2 correction rerun

List only:
- `AGENTS.md`;
- R6-R2 correction task;
- R6-R1 independent review;
- rejected R6-R1 result;
- original R6 task at commit `681296dde83aeca723007a74e7f23a5935515627`.

Record their actual blobs.

#### Group 2 — Carried-forward original R6 fixed-input ledger, previously independently verified

Carry forward the remaining original R6 ledger identities exactly as recorded in the rejected R6-R1 result.

State explicitly:

- these entries are inherited from the original R6 evidence chain;
- they were independently cross-checked before R6-R2;
- they were not directly reopened in R6-R2;
- their inclusion is provenance continuity, not a claim of new direct read.

The original R6 task belongs in Group 1 because R6-R2 directly reads it.

Do not call Group 2 `Exact input read`.

### C. Section 16

Update only enough to state:

- this is an R6-R2 provenance-only correction;
- only the R6-R2-authorized exact paths were read;
- the inherited Group 2 ledger was not reopened;
- Sections 1 and 3–15 remain semantically and textually unchanged;
- both prior rejected candidates remain unmerged.

The final classification must state that no semantic contract change occurred.

## 6. Hard semantic freeze

Do not alter:

- `A. DEDICATED_ENDPOINT_CONTRACT_SOUND`;
- `POST /api/v2/runtime-readiness/evaluations`;
- coexistence with generic `POST /api/v2/contracts/application-envelope`;
- five-family IP-13F disposition;
- request schema;
- response schema;
- field visibility matrix;
- READY / NOT_READY / UNKNOWN representation;
- HTTP mapping;
- malformed/synthetic-boundary mapping;
- storage/materialization mapping;
- authentication/session/token retained UNKNOWN;
- privacy boundary;
- future targeted Feature test path and command;
- future four-path implementation write scope;
- retained invariants/UNKNOWNs.

If any substantive correction seems needed, STOP and report blocker instead of editing it.

## 7. Runtime prohibition

Run no:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP/client request;
- database runtime probe;
- provider/network command;
- production action;
- real/private-data operation;
- legal research;
- Safety Operation.

This task is document-only.

## 8. Candidate publication requirements

Publish one immutable candidate on the isolated review branch.

Record externally after publication:

- branch;
- candidate commit;
- sole parent;
- tree;
- corrected result blob;
- exact one-path diff;
- tracked/staged counts if locally available.

The candidate author must not:

- self-accept;
- merge;
- move main;
- begin implementation.

Fresh independent ACCEPT/REJECT review is required.

## 9. Expected classification

`IP-13I-R6-R2 CORRECTION COMPLETE — R6 PROVENANCE LEDGER SPLIT INTO DIRECTLY-READ VS CARRIED-FORWARD VERIFIED EVIDENCE — NO READ-SCOPE CONTRADICTION REMAINS — ORIGINAL R6 SEMANTIC CONTRACT PRESERVED BYTE-FOR-BYTE IN SECTION 1 AND SECTIONS 3–15 — NO RUNTIME/IMPLEMENTATION ACTION — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
