# EliteSync v10｜Next IP-13I-R6-R1 Evidence-Ledger Correction Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CORRECTION TASK — NO SEMANTIC CHANGE — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Pre-task main: `00064d6b35139bc93b2f750363a018d4768d982a`

Original R6 task-publication commit: `681296dde83aeca723007a74e7f23a5935515627`

Rejected R6 candidate: `b80c6ea9f9a920bcf489afbbf05ebebae86c9faa`

Rejected R6 result blob: `eabebfd11c7753accf2d8709b67a72e079aac588`

Independent rejection blob: `ed8f808f78d2177d1e35ada3483b7374022d61c1`

## 1. Objective

Produce one corrected immutable R6 result candidate.

The correction is strictly limited to the evidence-ledger/topology metadata defect established by the independent review.

The rejected R6 candidate recorded the R6 review task blob as:

`83e226caa727ef607844db838f15a221fbecd95c`

The exact Git blob of the original R6 review task at commit `681296dde83aeca723007a74e7f23a5935515627` is:

`e62bf3d99d5c88af877f50f70241defae24140a8`

The substantive R6 contract is not reopened by this task.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this correction task.
4. Require `origin/main` to equal that task-publication commit exactly.
5. Read the independent rejection record.
6. Read the original R6 task at commit `681296dde83aeca723007a74e7f23a5935515627`.
7. Read the rejected R6 result exactly from commit `b80c6ea9f9a920bcf489afbbf05ebebae86c9faa`.
8. Verify the original R6 task blob equals `e62bf3d99d5c88af877f50f70241defae24140a8`.
9. Verify the five accepted R5 blobs remain unchanged on fresh main.
10. Create one isolated review branch/worktree from exactly the correction-task publication commit.
11. Verify the corrected R6 result path is absent on fresh main.
12. Stop rather than adapt if any fixed identity differs.

Recommended branch:

`review/next-ip-13i-r6-r1-evidence-ledger-correction-v0-1`

## 3. Exact authorized read scope

Read only:

1. `AGENTS.md`
2. this correction task
3. `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_HTTP_ENTRY_CONTRACT_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
4. original R6 task at exact commit `681296dde83aeca723007a74e7f23a5935515627`
5. rejected R6 result at exact commit `b80c6ea9f9a920bcf489afbbf05ebebae86c9faa`
6. current-main versions of the five R5 accepted artifacts needed only to re-resolve their blobs:
   - `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
   - `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
   - `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`
   - `services/backend-laravel/tests/Unit/RuntimeReadinessPersistenceApplicationAdapterTest.php`
   - `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_RR03_ADDITIVE_DERIVED_PROJECTION_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

No repository enumeration, search/discovery, README read, FD02 read, old repository access or unrelated file read is authorized.

## 4. Exact tracked write scope

Create exactly one path:

`docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`

No other tracked file may change.

No code, route, controller, middleware, provider, config, test or accepted R5/IP-13F artifact may change.

## 5. Required correction method

Use the rejected R6 result as the semantic source.

The corrected result must preserve Sections 1 and 3 through 16 of the rejected R6 result substantively unchanged.

Permitted changes are limited to metadata required by the new immutable publication context:

- Status may state corrected candidate / correction-only rerun.
- Fresh `origin/main` / correction-task publication commit must reflect the actual fresh execution base.
- Review branch must reflect the R6-R1 branch.
- Candidate/tree language may remain externally resolved.
- The fixed-input ledger must record:
  - original R6 task commit `681296dde83aeca723007a74e7f23a5935515627`;
  - original R6 task blob `e62bf3d99d5c88af877f50f70241defae24140a8`;
  - this R6-R1 correction task blob;
  - independent rejection blob `ed8f808f78d2177d1e35ada3483b7374022d61c1`;
  - all other original R6 fixed inputs exactly as recorded by the rejected candidate, provided their identities are revalidated and unchanged.
- Section 16 publication text may state that this is a correction-only rerun and that the rejected candidate was not merged.

Do not alter the selected semantic outcome:

`A. DEDICATED_ENDPOINT_CONTRACT_SOUND`

Do not alter:

- exact endpoint;
- IP-13F coexistence/disposition;
- request schema;
- response schema;
- adapter field visibility matrix;
- READY / NOT_READY / UNKNOWN representation;
- HTTP mapping;
- malformed/synthetic-boundary mapping;
- storage/materialization mapping;
- authentication boundary;
- privacy boundary;
- future Feature-test path/command;
- exact later four-path implementation scope;
- retained invariants/UNKNOWNs.

If any substantive semantic correction appears necessary, STOP and report a blocker. Do not combine it into R6-R1.

## 6. Five R5 immutable blob gate

The corrected result must re-establish exactly:

- IP-13A:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13D:
  `a81535d174015bb0ecaa9f8caeaabb7490c4354b`
- Runtime Readiness persistence application adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`
- targeted test:
  `081dbb62597a25b0e230e1e78332033c11821529`
- R5 implementation result:
  `365fc83575ef2e601f19f92281af3ec3821a6fcd`

Any drift is a hard stop.

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

`IP-13I-R6-R1 CORRECTION COMPLETE — R6 TASK BLOB LEDGER REPAIRED TO e62bf3d99d5c88af877f50f70241defae24140a8 — ORIGINAL R6 SEMANTIC CONTRACT PRESERVED — ALL FIVE R5 ACCEPTED BLOBS REVERIFIED — EXACTLY ONE RESULT DOCUMENT — NO RUNTIME/IMPLEMENTATION ACTION — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
