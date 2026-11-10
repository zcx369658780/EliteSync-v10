# EliteSync v10｜Next IP-13I-R12-R1 Canonical Match Derived-Purpose Binding Contract Correction Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY SINGLE-DEFECT CONTRACT CORRECTION REVIEW — EXACTLY ONE RESULT DOCUMENT — NO CODE / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`a2f28b7585f51a0573a9602b8da7609ba6bd69fa`

Rejected R12 candidate:
`c18d79c968dddf3a26c4d189f783a1354a4fca86`

Rejected R12 adapter blob:
`f1f151b4cb96352521b0823072857153e2ccb4e4`

Rejected R12 targeted Unit blob:
`c99ea59a270e4ff23a3b9fa016eec95db3cccdc3`

Rejected R12 result blob:
`524d67ba1b46724e41cb350317f4310304a775e2`

R12 independent rejection blob:
`000290eaf9a352dedaf08b6668b8d29806fcf1c0`

## 1. Objective

Repair exactly one contract contradiction:

A structurally valid Canonical Match proposal whose source-required binding purpose does not equal its protected-use scope is an accepted persistable domain-`UNKNOWN` case under R9-R1, but R10/R12 currently copy that mismatched source-required purpose into the derived record binding while accepted R11 requires:

`derived bindings.purpose = payload.protected_use_scope`

This task is REVIEW ONLY.

It must decide the exact source of the derived Match record's `bindings.purpose` and the exact minimal later adapter/test correction.

Do not redesign:

- evaluator semantics;
- Match payload schema;
- R11 persistence validator;
- sticky terminality;
- reason vocabulary;
- IP-13E orchestration;
- IP-13F;
- HTTP.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R12-R1 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify all fixed inputs in Section 4.
8. Stop rather than adapt if any identity differs.

Recommended branch:

`review/next-ip-13i-r12-r1-derived-purpose-binding-correction-v0-1`

No repository enumeration or unrelated discovery.

## 3. Controlling accepted facts

Preserve all of the following:

### 3.1 R9-R1

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`

After the structural gate, a proposal whose evidence is structurally valid but whose exact required-binding satisfaction is not established remains a persistable domain `UNKNOWN`.

In particular, this includes a valid proposal whose:

`required_bindings.purpose != protected_use_scope`

which the evaluator may classify with bounded reason:

`PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`.

### 3.2 R11

Every valid Canonical Match derived persistence record requires:

`bindings.purpose = payload.protected_use_scope`

and validates deterministic lifecycle/semantic identities using that derived binding.

R11 is accepted and must not be weakened.

### 3.3 R10/R12 defect

R10 currently states that actor, actor role, subject, audience, and purpose are copied from proposal required bindings.

Rejected R12 implements:

`'purpose' => $sourceBindings['purpose']`

This makes the R9-R1 persistable purpose-mismatch `UNKNOWN` fail R11 storage validation.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R12-R1 task

3. R12 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R12_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_TASK_V0_1.md`

4. R12 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R12_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

5. rejected R12 implementation result at exact candidate
   `c18d79c968dddf3a26c4d189f783a1354a4fca86`:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

6. rejected R12 adapter at the same candidate:
   `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`

7. rejected R12 targeted Unit test at the same candidate:
   `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

8. accepted R9-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

9. R9-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`

10. accepted R10 result:
    `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`

11. R10 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_ACCEPTANCE_V0_1.md`

12. R11 task:
    `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_REFERENCE_SQLITE_IMPLEMENTATION_TASK_V0_1.md`

13. R11 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

14. Canonical Match evaluator:
    `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`

15. Common Authority:
    `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

16. accepted IP-13A:
    `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

Expected blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R12 task:
  `bd5452740ebb6992cfb097f3b265b837eb69dd37`
- R12 rejection:
  `000290eaf9a352dedaf08b6668b8d29806fcf1c0`
- rejected R12 result:
  `524d67ba1b46724e41cb350317f4310304a775e2`
- rejected R12 adapter:
  `f1f151b4cb96352521b0823072857153e2ccb4e4`
- rejected R12 Unit test:
  `c99ea59a270e4ff23a3b9fa016eec95db3cccdc3`
- R9-R1 result:
  `114eb27d2766657d9e6fb364ce83fc8fee82c66d`
- R9-R1 acceptance:
  `44f3ee11a0fedbdf80c0c27be47063f42a370cd9`
- R10 result:
  `0bb112750c0f6803e1d97224bf5b415763176571`
- R10 acceptance:
  `9b23e5f506030d492ef8c617108f906f12fe839d`
- R11 task:
  `0b7d9b9c10c64f1b333dbf3f720947ea27746c57`
- R11 acceptance:
  `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R12_R1_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing file may change.

No code or test modification.
No R10/R11/R12 artifact modification.

## 6. Required decision

Choose exactly one:

### Option A — derived protected-use purpose

`DERIVED_RECORD_PURPOSE = PAYLOAD_PROTECTED_USE_SCOPE`

The derived Match record's `bindings.purpose` is exactly the payload's accepted `protected_use_scope`, independent of whether the source proposal's required-binding purpose was semantically satisfied.

The source-required purpose remains untouched in source input/evidence and may cause evaluator domain `UNKNOWN`.

### Option B — source-required purpose copied

`DERIVED_RECORD_PURPOSE = SOURCE_REQUIRED_BINDING_PURPOSE`

Only select if R9-R1's persistable domain-`UNKNOWN` rule can still be satisfied without weakening R11.

### Option C — blocked

Choose if neither A nor B can preserve all accepted contracts.

Preferred direction is Option A because R11 already requires it and it preserves the R9-R1 structural-vs-semantic distinction.

The review must independently confirm or reject that direction.

## 7. If Option A is selected

Fix exactly:

`derived bindings.purpose = payload.protected_use_scope`

and therefore:

- derived lifecycle-basis `purpose` uses `payload.protected_use_scope`;
- retrieval request binding `purpose` uses the derived record binding, therefore also the payload protected-use scope;
- source proposal `required_bindings.purpose` is never mutated;
- source evidence binding purpose is never rewritten;
- evaluator continues to see the original source-required purpose;
- purpose mismatch may still truthfully produce `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- that `UNKNOWN` remains eligible for R11 persistence.

Do not change:
- derived actor;
- derived actor_role;
- derived subject;
- derived audience;
- derived participant set;
- derived aggregate context;
- authority owner/scope;
- Match payload;
- currentness/freshness;
- terminality;
- invalidation;
- reason mapping.

## 8. Non-authority interpretation

The result must state explicitly:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

and:

`DERIVED_RECORD_PURPOSE != PERMISSION`

The derived purpose records the bounded protected-use context of the derivation.

It does not:
- repair source evidence;
- establish that source required bindings were satisfied;
- create Match source authority;
- create permission/consent/authentication.

## 9. Exact supersession

If Option A is selected, supersede only:

- R10 Section 8.2 phrase that derived `purpose` is copied from proposal required bindings;
- R12 task Section 13 equivalent instruction.

Preserve all other accepted R10 mapping and R11 persistence contracts.

No R11 validator change.

## 10. Exact future correction scope

If Option A is selected, define one future implementation correction based on rejected R12 candidate:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

Allowed later tracked changes relative to that candidate:

1. MODIFY:
   `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`

2. MODIFY:
   `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

3. CREATE:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

The original R12 result remains unchanged historical evidence.

No IP-13A/IP-13D/IP-13E/IP-13F change.

The corrected Unit test must add at least:

- structurally valid proposal with `required_bindings.purpose != protected_use_scope`;
- evaluator result `UNKNOWN`;
- bounded reason `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- storage outcome retrievable/accepted under existing R11;
- exact Match payload/readback preserved according to currentness/freshness;
- derived record/retrieval purpose equals protected-use scope;
- source input/evidence purpose remains unchanged;
- no source authority/permission created.

## 11. Runtime gate

This R12-R1 review runs no runtime command.

A later correction task may authorize exactly one targeted run of:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

with no retry, under separately fixed Composer/diff-check budgets.

## 12. HTTP gate

HTTP remains deferred.

Do not author or select:
- Match route;
- controller;
- HTTP request/response contract;
- status mapping.

Canonical Match HTTP review remains blocked until corrected application adapter acceptance.

## 13. Review-only prohibition

Do not run:
- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP/client;
- database runtime probe;
- provider/network product operation;
- production;
- real/private-data operation.

Do not modify code.

## 14. Result requirements

Record:
- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all read blobs;
- Option A/B/C decision;
- exact derived-purpose source;
- exact source-evidence non-mutation rule;
- exact non-authority interpretation;
- exact superseded R10/R12 text only;
- exact preserved R10/R11 semantics;
- exact future three-path correction scope;
- required added targeted test case;
- HTTP gate remains deferred;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected Option A success classification:

`IP-13I-R12-R1 REVIEW COMPLETE — DERIVED MATCH RECORD PURPOSE FIXED TO PAYLOAD PROTECTED-USE SCOPE — SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED AND MAY STILL DRIVE PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE UNKNOWN — R9-R1 PERSISTABLE DOMAIN UNKNOWN RESTORED WITHOUT R11 CHANGE — ONLY R10/R12 PURPOSE-COPY INSTRUCTION SUPERSEDED — EXACT THREE-PATH ADAPTER/TEST CORRECTION SCOPE FIXED — HTTP STILL DEFERRED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
