# EliteSync v10｜Next IP-13I-R15-R1 Product Connection Structural-Rejection vs Domain-UNKNOWN Reason-Boundary Correction Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY SINGLE-DEFECT REASON-BOUNDARY CORRECTION REVIEW — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`0cc01c18d9c49ad27eb18679346ef0642a299444`

Rejected R15 candidate:
`96a8417138f601f7400736d8d79df9f88e3f5654`

Rejected R15 result blob:
`675baff0963da556f66d4fa86d6bc46c3eedbeba`

R15 independent rejection blob:
`dc5adcdbc26468f433b3a0888be593ebd9bb1125`

## 1. Objective

Correct exactly one R15 defect:

the boundary between:

- malformed structural input that a future Product Connection adapter should reject before persistence; and
- structurally valid semantic mismatch/conflict that the accepted evaluator represents as bounded domain `UNKNOWN` or transition `REJECTED`.

Do not reopen the retained R15 directions unless this correction finds a direct contradiction:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- one additive Product Connection derived family with typed current-state and transition fact classes;
- currentness/freshness recovered from selected source evidence;
- cross-type dependency identity collision avoidance;
- current-state-based terminality;
- IP-13A additive-family compatibility;
- IP-13D reference parity without schema change;
- IP-13E existing operations sufficient after record repair;
- IP-13F unchanged/non-participating;
- downstream Messaging remains blocked.

R16 remains blocked until R15-R1 is independently accepted.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R15-R1 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r15-r1-product-connection-reason-boundary-correction-v0-1`

No repository enumeration or unrelated discovery.

## 3. Controlling defect

Rejected R15 classified these six evaluator reasons as `PRE_MATERIALIZATION_REJECTION_ONLY`:

- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`

The accepted evaluator returns them from resolution logic over structurally present evidence and emits bounded derived `UNKNOWN` results.

R15 task explicitly forbids converting valid domain `UNKNOWN` or transition `REJECTED` into input errors.

R15-R1 must independently classify every Product Connection evaluator reason and fix the exact future persisted reason vocabulary.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R15-R1 task

3. R15 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R15_PRODUCT_CONNECTION_VERTICAL_SLICE_ENTRY_AND_MAPPING_READINESS_REVIEW_TASK_V0_1.md`

4. R15 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

5. rejected R15 result at exact candidate
   `96a8417138f601f7400736d8d79df9f88e3f5654`:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_PRODUCT_CONNECTION_VERTICAL_SLICE_ENTRY_AND_MAPPING_READINESS_REVIEW_RESULT_V0_1.md`

6. Product Connection evaluator:
   `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`

7. Common Authority:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

8. core-domain harness acceptance:
   `docs/architecture/ELITESYNC_V10_IP_12G_BACKEND_CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_ACCEPTANCE_V0_1.md`

9. R14 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R14_CANONICAL_MATCH_SYNTHETIC_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

Expected blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R15 task:
  `024b57589b7c1a0aa5fe8584cf9cb3ef8db844a2`
- R15 rejection:
  `dc5adcdbc26468f433b3a0888be593ebd9bb1125`
- rejected R15 result:
  `675baff0963da556f66d4fa86d6bc46c3eedbeba`
- Product Connection evaluator:
  `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- core-domain harness acceptance:
  `17eba174bccdbb688043ecc98d2eae3a9df7b3d3`
- R14 acceptance:
  `1b40415cb7e7362cc0696e43a4d5e7868f2683b3`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing file may change.

No code/test/persistence/application/route/HTTP modification.

## 6. Required complete reason inventory

Inventory every evaluator reason literal reachable from:

- `evaluateCurrent()`
- `evaluateTransition()`
- `invalidate()`

and classify each exactly once into:

1. `PRE_MATERIALIZATION_REJECTION_ONLY`
2. `PERSISTED_CURRENT_STATE_UNKNOWN_REASON`
3. `PERSISTED_TRANSITION_UNKNOWN_REASON`
4. `PERSISTED_TRANSITION_REJECTED_REASON`
5. `PERSISTED_INVALIDATION_REASON`

If one literal is propagated from current-state evaluation into a transition `UNKNOWN`, record that cross-fact reuse explicitly rather than duplicating semantics.

Do not leave any reachable literal unclassified.

## 7. Structural rejection boundary

A reason may be `PRE_MATERIALIZATION_REJECTION_ONLY` only if a future adapter can determine it from malformed shape/type/cardinality/required-field/illegal-vocabulary input before treating the request as a valid domain derivation.

At minimum re-evaluate:

- `CONNECTION_IDENTITY_REQUIRED`
- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `PROTECTED_USE_SCOPE_REQUIRED`
- `INVALID_EVIDENCE_SHAPE`
- `INVALID_CONNECTION_STATE`
- `INVALID_TARGET_STATE`

The result must state the exact structural gate that makes each one pre-materialization-only.

## 8. Semantic domain-UNKNOWN boundary

Re-evaluate the six rejected-R15 reasons:

- `CROSS_CONNECTION_STATE_EVIDENCE`
- `STATE_PARTICIPANT_MISMATCH`
- `CONFLICTING_STATE_EVIDENCE_IDENTITY`
- `CROSS_CONNECTION_TRANSITION_EVIDENCE`
- `TRANSITION_PARTICIPANT_MISMATCH`
- `CONFLICTING_TRANSITION_IDENTITY`

For each, decide whether:

- the evidence object can be structurally valid under a strict future adapter gate;
- the reason represents cross-aggregate/binding/identity conflict rather than malformed structure;
- it must remain a persistable bounded `UNKNOWN`.

The review must preserve evaluator truth rather than moving a semantic mismatch into HTTP/input validation merely for implementation convenience.

## 9. Duplicate and conflict reasons

Distinguish exactly:

- different evidence identity in one resolution set;
- same identity with incomparable source revisions;
- same identity + equal revision + conflicting semantic signature.

Do not collapse:

- `CONFLICTING_*_EVIDENCE_IDENTITY`
- `INCOMPARABLE_DUPLICATE_*_EVIDENCE`
- `CONFLICTING_EQUAL_REVISION_*_EVIDENCE`

unless the evaluator already does so.

Define which are persistable bounded `UNKNOWN`.

## 10. Transition UNKNOWN vs REJECTED

Fix exact classification:

### Transition `UNKNOWN`

At minimum analyze:

- propagated current-state `UNKNOWN` reasons;
- missing transition evidence;
- cross-Connection transition evidence;
- participant mismatch;
- conflicting transition identity;
- incomparable duplicate transition;
- conflicting equal-revision transition;
- transition evidence not current/fresh/bound;
- current context mismatch.

### Transition `REJECTED`

At minimum analyze:

- terminal Connection cannot reopen;
- direct `CN_NONE → CN_ACTIVE`;
- transition not allowed.

Do not turn a policy/domain decision rejection into transport/input rejection.

## 11. Invalidation reason

`DEPENDENCY_INVALIDATED` must be classified independently.

State exactly whether it is:

- persisted current-state UNKNOWN reason;
- persisted transition UNKNOWN reason;
- or both depending on the invalidated fact.

Preserve:
- classification becomes `UNKNOWN`;
- lifecycle reset false;
- connection reopened false;
- retained current/proposed state context.

## 12. Required corrected persisted vocabularies

Define exact canonical ordered reason vocabularies for:

- current-state derived payload;
- transition derived payload.

The transition vocabulary may include current-state UNKNOWN reasons that are propagated before transition-evidence resolution.

Do not persist pre-materialization-only diagnostics.

Do not invent new reason literals.

## 13. R15 sections preserved/superseded

State exactly which rejected R15 sections remain retained as review evidence and which text is superseded.

Expected narrow supersession:

- Section 6 reason classification only;
- any downstream payload-vocabulary statement that depended on that classification.

Do not silently rewrite:

- next-domain decision;
- unused matchResult;
- Model A;
- dependency identity/collision;
- terminal/invalidation basis;
- currentness/freshness;
- deterministic identity basis;
- IP-13A/IP-13D/IP-13E/IP-13F decisions;
- downstream gating.

If any of those must change because of the corrected reason boundary, explain the exact contradiction.

## 14. R16 gate

If the full reason boundary is corrected without exposing a new blocker, authorize next:

`IP-13I-R16 PRODUCT CONNECTION RECORD/PROJECTION CONTRACT REVIEW — DOCUMENT ONLY`

R16 must then use the corrected persisted reason vocabularies as fixed input.

Do not author R16 from the R15-R1 branch.

If a new blocker appears, define the exact additional document-only review instead.

## 15. Review-only prohibition

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- HTTP/client commands;
- database runtime probes;
- provider/network product operations;
- production operations;
- real/private-data operations.

Do not modify code.

## 16. Result requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all read blobs;
- complete reason inventory;
- exact structural-rejection gate;
- corrected current-state UNKNOWN vocabulary;
- corrected transition UNKNOWN vocabulary;
- corrected transition REJECTED vocabulary;
- invalidation reason disposition;
- duplicate/conflict distinctions;
- exact R15 supersession boundary;
- whether Model A and persistence-stack decisions remain intact;
- R16 gate;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R15-R1 REVIEW COMPLETE — PRODUCT CONNECTION STRUCTURAL-REJECTION VS DOMAIN-UNKNOWN BOUNDARY CORRECTED — CROSS-CONNECTION / PARTICIPANT-MISMATCH / EVIDENCE-IDENTITY-CONFLICT REASONS RETAINED AS BOUNDED PERSISTABLE DOMAIN UNKNOWN WHERE STRUCTURALLY VALID — TRANSITION UNKNOWN VS REJECTED VOCABULARIES FIXED — R15 NEXT-DOMAIN / UNUSED-matchResult / MODEL-A / PERSISTENCE-STACK DIRECTIONS RETAINED — R16 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
