# EliteSync v10｜Next IP-13I-R9 Canonical Match Record/Projection Contract Repair Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CANONICAL MATCH RECORD/PROJECTION CONTRACT REPAIR REVIEW — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`1e34307dcd38993a856f14dc83b966fd09cdddc6`

Accepted R8 result blob:
`10bb30f123d22929a17fe33a7ecd2908db5df786`

R8 acceptance blob:
`c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`

## 1. Objective

Repair the logical-record / privacy-minimal projection contract gap that prevents the accepted Canonical Match evaluator from being represented losslessly in the current persistence/application stack.

This task is REVIEW ONLY.

It must decide whether a small additive Canonical Match derived-record family can be defined without:

- relabeling Match as RR03 Runtime Readiness;
- collapsing Match classification into source condition, authoritative outcome, storage disposition, projection lag, logical identity or transport metadata;
- creating Match source authority;
- creating Connection, Consent, Conversation, relationship, Home, Notification or launch authority;
- introducing a global revision, LWW or arrival-order meaning;
- changing IP-13F;
- authorizing HTTP, adapter implementation, production persistence or real/private-data processing.

If the contract is sound, R9 must define it precisely enough that a later separately authorized implementation can modify persistence adapters without inventing semantics.

If it is not sound, R9 must state the exact blocker and stop.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R9 task.
4. Require `origin/main` to equal that task-publication commit exactly.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r9-canonical-match-record-projection-contract-repair-v0-1`

No repository enumeration or unrelated source discovery is authorized.

## 3. Controlling accepted baseline

Preserve the accepted R8 decision:

`NEXT_DOMAIN = CANONICAL_MATCH`

Preserve:

`NEXT_TASK_TYPE = RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW — DOCUMENT ONLY`

Preserve:

`IP_13F_DISPOSITION = IP_13F_UNCHANGED_NON_PARTICIPATING`

Canonical Match is derived/descriptive and non-authoritative.

The accepted evaluator output includes:

- record kind `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVATION`;
- classification:
  `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED | UNKNOWN`;
- proposal identity;
- exactly two participants;
- proposal dependency;
- participant-enrolment dependency evidence;
- participant-bound decision-slot dependencies;
- bounded reasons;
- dependency-scoped invalidation;
- terminal proposal semantics;
- explicit false downstream/non-authority fields.

Current IP-13A only has a dedicated derived payload validator for:

`RR03_RUNTIME_READINESS_DERIVED_PROJECTION`

Canonical Match must not be forced into that RR03 family.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R9 task

3. R8 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_TASK_V0_1.md`

4. accepted R8 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_RESULT_V0_1.md`

5. R8 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_ACCEPTANCE_V0_1.md`

6. accepted R7 vertical-slice acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R7_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

7. prior backend vertical-slice reassessment acceptance:
   `docs/architecture/ELITESYNC_V10_BACKEND_VERTICAL_SLICE_INTEGRATION_REASSESSMENT_ACCEPTANCE_V0_1.md`

8. core-domain semantic-integration harness acceptance:
   `docs/architecture/ELITESYNC_V10_IP_12G_BACKEND_CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_ACCEPTANCE_V0_1.md`

9. Canonical Match evaluator:
   `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`

10. Common Authority contract:
    `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

11. current IP-13A logical-persistence reference:
    `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

12. current IP-13E application interface:
    `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`

13. current IP-13F transport-neutral contract:
    `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`

14. accepted Runtime Readiness application adapter, contrast evidence only:
    `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R8 task:
  `218e291b3b18d900220654dbcb063ac5d007fbcc`
- R8 result:
  `10bb30f123d22929a17fe33a7ecd2908db5df786`
- R8 acceptance:
  `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`
- R7 acceptance:
  `efa900a6351d98adbe5fe9fce2d846004296b4a9`
- backend reassessment acceptance:
  `9001630069a541af79f7b191ac204561a4fd8e6b`
- core-domain harness acceptance:
  `17eba174bccdbb688043ecc98d2eae3a9df7b3d3`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- IP-13F:
  `e70f260de92a0047e70b54827f4795edb3b74e00`
- Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly one path:

`docs/architecture/ELITESYNC_V10_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`

No other tracked file may change.

Do not modify:

- Canonical Match evaluator;
- Common Authority;
- IP-13A;
- IP-13D;
- IP-13E;
- IP-13F;
- Runtime Readiness adapter;
- routes/controllers/tests;
- Composer manifests;
- migrations/config/providers/bootstrap;
- any product/client/provider source.

## 6. Required top-level decision

Choose exactly one:

### Option A
`ADDITIVE_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_SOUND`

A new additive derived-record family and privacy-minimal projection can be defined without changing accepted source/domain authority semantics.

### Option B
`CURRENT_GENERIC_RECORD_CAN_REPRESENT_MATCH_WITHOUT_NEW_FAMILY`

Only select if the existing generic record/projection contract already represents the Canonical Match result losslessly and safely without overloading fields.

### Option C
`BLOCKED_INSUFFICIENT_OR_CONTRADICTORY_EVIDENCE`

The current evidence cannot support a safe record/projection repair.

R8 evidence strongly suggests Option A, but this review must independently confirm or reject it.

## 7. If Option A is selected — exact record-family decision

Define one exact Canonical Match record family name.

The name must be:

- distinct from RR03;
- explicitly derived/non-authoritative in meaning;
- stable enough for persistence correlation;
- not a transport or HTTP family;
- not a Connection/Consent/Conversation state family.

The result must state whether the family is intended to carry a non-null `derived_projection_payload` under the existing generic record envelope.

Do not create a second general-purpose derived-record abstraction unless current evidence proves it necessary.

## 8. Exact logical-record authority boundary

The repaired record must preserve the generic IP-13A envelope semantics where possible.

The review must decide exact values/rules for at least:

- `record_family`;
- `bindings`;
- `source_revision`;
- `source_condition`;
- `currentness`;
- `freshness`;
- `logical_intent`;
- `authoritative_outcome`;
- `authoritative_outcome_metadata`;
- `correction_metadata`;
- `projection_metadata`;
- `transport_observation`;
- `private_fixture_extensions`;
- non-authority fields.

The review must explicitly decide how a derived Match record obtains its synthetic correlation revision without claiming proposal/participant/decision-slot source authority.

Preserve:

- source-local dependency revisions remain inside the derived payload;
- derived-record correlation revision is not a global revision;
- storage ordering is not domain ordering;
- `authoritative_outcome` remains `UNKNOWN` unless independently source-carried under already accepted rules;
- `STORED != AUTHORITATIVE`.

Do not invent a production writer or source owner.

## 9. Exact Canonical Match derived payload

Define the exact payload key set.

The payload must be privacy-minimal but lossless for the accepted evaluator result and later exact readback comparison.

At minimum decide representation for:

- payload kind;
- derived fact / semantic class;
- bounded Match classification;
- proposal identity;
- participant references, if necessary internally;
- proposal lifecycle facts necessary to preserve terminality;
- protected-use scope;
- bounded reason categories;
- proposal dependency;
- participation dependencies;
- decision-slot dependencies;
- invalidation.

The payload must not contain raw source evidence objects.

The review must decide whether the exact two participant references are needed in the derived payload or are sufficiently represented by generic record bindings plus dependency identities.

Do not store private profile fields, message content, hidden Safety evidence, credentials, provider payloads, ranking signals, Compatibility total, desirability or person-worth claims.

## 10. Exact dependency contracts

Define separate exact dependency shapes for:

### Proposal dependency

At minimum consider:

- proposal identity;
- source-local owner/scope/context;
- source lineage;
- source revision value;
- source condition;
- currentness/freshness;
- lifecycle state/terminality only if semantically necessary.

### Participation dependency

Each exact participant dependency must preserve enough to distinguish the two participants and their source-local evidence.

At minimum consider:

- participant identity;
- participation state;
- source-local owner/scope/context;
- source lineage/revision;
- source condition;
- currentness/freshness.

### Decision-slot dependency

Each slot dependency must preserve enough to support duplicate-resolution and exact readback/invalidation.

At minimum consider:

- slot identity;
- proposal identity if needed;
- participant identity;
- bounded decision;
- source-local owner/scope/context;
- source lineage/revision;
- source condition;
- currentness/freshness.

Do not flatten all dependencies into one undifferentiated RR03-style member list unless losslessness is independently demonstrated.

The result must define canonical ordering and duplicate uniqueness rules for each list-shaped dependency group.

## 11. Bounded classification and reason vocabularies

Fix the exact allowed Match classification vocabulary:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

Define the bounded persisted reason-category vocabulary derived from evaluator reasons.

The result must decide how parameterized reasons such as participant- or slot-specific failures are reduced without exposing raw private/source payloads.

No reason category may create a Compatibility ranking, desirability score, person-worth inference or adverse hidden meaning.

## 12. Terminality and invalidation

The result must define how the derived projection preserves:

- terminal proposal states;
- no reopen;
- no lifecycle reset;
- dependency-scoped invalidation;
- invalidation relation;
- invalidated dependency identity.

The generic derived record/projection must not synthesize:

- proposal reopening;
- Connection creation;
- consent;
- conversation access;
- relationship state;
- launch eligibility.

The result must decide whether invalidation can reuse the current generic logical-record invalidation mechanism without changing its semantics.

## 13. Currentness / freshness aggregation

The review must define the exact derived-record correlation rule for:

- `currentness`;
- `freshness`.

Do not simply copy Runtime Readiness aggregation if Canonical Match dependency semantics differ.

The result must explain how proposal, participation and decision-slot source facts contribute.

For terminal proposal classifications, decide whether currentness/freshness remain required for exact materialization or whether terminal source evidence must still be current/fresh under the accepted evaluator semantics.

No hidden guess is allowed.

## 14. Logical identity and intent

Define the minimum semantic input used for:

- logical record identity;
- logical intent identity;
- derived projection lineage/correlation identity.

The identity scheme must:

- be deterministic;
- be source-order independent;
- distinguish changed source-local revision vectors;
- avoid global revision;
- avoid arrival-order/LWW semantics;
- avoid embedding raw private fixture material;
- not treat Match classification itself as source authority.

Do not silently reuse Runtime Readiness digest fields if the semantic input differs.

## 15. Privacy-minimal projection

Define exactly what the privacy-minimal persistence projection may expose internally to IP-13E after readback.

At minimum decide whether it includes:

- bounded classification;
- proposal identity;
- participant references;
- protected-use scope;
- reason categories;
- dependency summaries;
- invalidation summary;
- terminality summary.

The projection must exclude raw evidence and all prohibited private/source material.

The result must distinguish:

- what must survive persistence for lossless application readback;
- what must remain internal to the record but not be exposed through a future HTTP response;
- what must never be persisted in the derived payload.

R9 does not authorize any HTTP response contract.

## 16. IP-13A compatibility decision

Explicitly decide whether the additive Match family can fit the existing generic record envelope by extending only the family-specific derived-payload validation/projection logic.

Choose exactly one:

- `IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_MATCH_FAMILY`
- `IP13A_GENERIC_ENVELOPE_REQUIRES_SEMANTIC_CHANGE`
- `BLOCKED`

If compatible, identify the exact generic envelope fields that remain unchanged.

Do not authorize implementation here.

## 17. IP-13E sufficiency decision

Explicitly decide whether current IP-13E operations are sufficient after the Match record/projection contract exists.

Choose exactly one:

- `IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_RECORD_REPAIR`
- `IP13E_MAPPING_REVIEW_REQUIRED_BEFORE_SUFFICIENCY_CAN_BE_DECIDED`
- `IP13E_CONTRACT_REPAIR_REQUIRED`

Do not add an evaluator-orchestration method in R9.

If existing operations appear sufficient, that only authorizes a later domain-to-application mapping review, not implementation.

## 18. IP-13F disposition

Must remain exactly one of:

- `IP_13F_UNCHANGED_NON_PARTICIPATING`
- `BLOCKED_BECAUSE_RECORD_REPAIR_REVEALS_TRANSPORT_DEPENDENCY`

Do not add a sixth IP-13F family.

Do not choose or authorize a Match HTTP endpoint.

## 19. Exact future task boundary

If Option A is sound, choose exactly one next task type:

- `CANONICAL_MATCH_RECORD_PROJECTION_IMPLEMENTATION_TASK`
- `CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW — DOCUMENT ONLY`
- `ADDITIONAL_CONTRACT_REPAIR_REVIEW — DOCUMENT ONLY`

The result must explain why.

If an implementation task is next, define only the exact minimum future write scope required to implement the accepted record/projection contract while preserving reference/SQLite equivalence and current generic behavior.

Do not authorize that implementation in R9.

If a mapping review must precede implementation, define its exact inputs and one-result write scope.

## 20. Required result structure

The result must record:

- fresh authority;
- candidate branch/commit/sole parent/tree after publication;
- exact one-path write scope;
- all read input blobs;
- Option A/B/C decision;
- exact record family;
- exact derived payload schema;
- exact dependency schemas;
- exact classification/reason vocabularies;
- exact invalidation/terminality rules;
- currentness/freshness aggregation;
- identity/correlation rules;
- privacy-minimal projection contract;
- IP-13A compatibility decision;
- IP-13E sufficiency decision;
- IP-13F disposition;
- exact next task type/title/scope;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

## 21. Review-only prohibition

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP/client command;
- database runtime probe;
- provider/network work;
- production action;
- real/private-data operation.

Do not modify code.

Do not author R10 or any implementation task from the review branch.

## 22. Expected success classification

If Option A is sound, expected shape:

`IP-13I-R9 REVIEW COMPLETE — ADDITIVE CANONICAL MATCH DERIVED RECORD/PRIVACY-MINIMAL PROJECTION CONTRACT SOUND — EXACT PROPOSAL/PARTICIPATION/DECISION-SLOT DEPENDENCY SEMANTICS FIXED — SOURCE-LOCAL REVISION/TERMINALITY/INVALIDATION/NON-AUTHORITY BOUNDARIES PRESERVED — IP-13A GENERIC ENVELOPE DISPOSITION FIXED — IP-13E SUFFICIENCY DECIDED — IP-13F UNCHANGED/NON-PARTICIPATING — EXACT NEXT BOUNDED TASK FIXED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
