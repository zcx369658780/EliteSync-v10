# EliteSync v10｜Next IP-13I-R15 Product Connection Vertical-Slice Entry and Mapping-Readiness Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY PRODUCT CONNECTION NEXT-DOMAIN ENTRY / RECORD-MAPPING READINESS REVIEW — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`d09edcea6730d5d4cea87e90b38e9938f05bbeea`

Accepted Canonical Match R14 acceptance blob:
`1b40415cb7e7362cc0696e43a4d5e7868f2683b3`

Prior R8 next-domain acceptance blob:
`c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`

## 1. Objective

Re-enter the remaining dependency order after the accepted Canonical Match end-to-end synthetic/dev-test vertical slice and determine the smallest truthful next step for Product Connection.

This task is REVIEW ONLY.

It must independently decide whether the accepted:

`ProductConnectionStateTransitionEvaluator`

can be mapped into the current persistence/application stack without inventing semantics.

The review must analyze both accepted evaluator surfaces:

1. current-state derivation:
   `evaluateCurrent(connection, stateEvidence)`
2. transition derivation:
   `evaluateTransition(connection, stateEvidence, transitionEvidence, matchResult?)`

plus evaluator dependency invalidation.

The review must decide:

- whether Product Connection is now the next dependency-correct domain;
- whether one additive Connection derived record/projection family is sufficient;
- whether current-state and transition derivations require distinct persisted fact classes or distinct record families;
- whether current IP-13A/IP-13D can represent them without new family-specific validation;
- whether current IP-13E operations are sufficient after any required record repair;
- whether IP-13F remains non-participating;
- whether the unused optional `matchResult` parameter creates any accepted Match dependency;
- the exact next bounded task type.

No implementation is authorized.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R15 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r15-product-connection-entry-mapping-readiness-v0-1`

No repository enumeration or unrelated discovery is authorized.

## 3. Controlling accepted baseline

Preserve:

- Canonical Match synthetic/dev-test vertical slice is now accepted end-to-end;
- `Match != Connection != Conversation != Relationship`;
- Match creates no automatic Connection;
- Product Connection evaluator was previously classified by R8 as:
  `NOT_SELECTED_BUT_MAPPING_PLAUSIBLE`;
- Messaging Consent / Conversation remains downstream of Product Connection;
- storage/application/HTTP creates no source authority;
- no auth/session/token or production/real-data authority exists.

Do not infer that the accepted Match HTTP slice is a prerequisite input to Product Connection unless the Product Connection evaluator actually consumes accepted Match semantics.

Do not infer that a Product Connection transition creates messaging consent, Conversation or Relationship authority.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R15 task

3. prior R8 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_ACCEPTANCE_V0_1.md`

4. Canonical Match R14 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R14_CANONICAL_MATCH_SYNTHETIC_HTTP_ENTRY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

5. core-domain semantic integration harness acceptance:
   `docs/architecture/ELITESYNC_V10_IP_12G_BACKEND_CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_ACCEPTANCE_V0_1.md`

6. Product Connection evaluator:
   `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`

7. Common Authority:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

8. current IP-13A:
   `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

9. current IP-13D:
   `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

10. current IP-13E:
    `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`

11. current IP-13F:
    `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`

12. accepted Canonical Match application adapter, contrast only:
    `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R8 acceptance:
  `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`
- R14 acceptance:
  `1b40415cb7e7362cc0696e43a4d5e7868f2683b3`
- core-domain harness acceptance:
  `17eba174bccdbb688043ecc98d2eae3a9df7b3d3`
- Product Connection evaluator:
  `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`
- IP-13D:
  `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- IP-13F:
  `e70f260de92a0047e70b54827f4795edb3b74e00`
- Canonical Match adapter:
  `789e8905b2c9ee54d902d8b600100896af4f6063`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R15_PRODUCT_CONNECTION_VERTICAL_SLICE_ENTRY_AND_MAPPING_READINESS_REVIEW_RESULT_V0_1.md`

No existing file may change.

No code, test, persistence, application, route or HTTP modification.

## 6. Required top-level next-domain decision

Choose exactly one:

### A
`NEXT_DOMAIN = PRODUCT_CONNECTION`

Choose only if Canonical Match closure plus the current accepted evaluator evidence makes Product Connection the earliest dependency-correct remaining vertical slice.

### B
`NEXT_DOMAIN = NONE_BLOCKED`

Choose if Product Connection still depends on an unclosed upstream semantic/application authority.

Do not select Messaging, Calm Home or Notification in R15.

## 7. Match dependency / optional matchResult decision

The evaluator signature contains:

`?array $matchResult = null`

The review must inspect actual implementation use.

Choose exactly one:

- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`
- `MATCH_RESULT_SEMANTIC_DEPENDENCY`
- `INSUFFICIENT_EVIDENCE`

If unused:

- do not persist Match result in Product Connection record merely because the parameter exists;
- do not infer Match authority;
- do not create Match→Connection automatic progression;
- record that current Product Connection semantics are independently sourced from Connection state/transition evidence.

If semantically used, define the exact consumed fields and authority boundary.

No hidden Match dependency may be invented.

## 8. Current-state derivation analysis

Analyze exact output semantics of:

`evaluateCurrent()`

At minimum record:

- record kind;
- exact state vocabulary:
  - `CN_NONE`
  - `CN_PENDING`
  - `CN_ACTIVE`
  - `CN_PAUSED`
  - `CN_CLOSED`
  - `CN_DECLINED`
  - `CN_WITHDRAWN`
  - `CN_EXPIRED`
  - `UNKNOWN`;
- current-state dependency shape;
- bounded reasons;
- duplicate-resolution semantics;
- source-local revision semantics;
- currentness/freshness/binding usability;
- terminal-state semantics;
- `connection_active_for_downstream_consideration`;
- invalidation behavior;
- all false non-authority fields.

Distinguish structural malformed-input diagnostics from valid domain `UNKNOWN` results if evidence supports that distinction.

## 9. Transition derivation analysis

Analyze exact output semantics of:

`evaluateTransition()`

At minimum record:

- record kind;
- transition classification:
  - `ADMISSIBLE`
  - `REJECTED`
  - `UNKNOWN`;
- current state;
- proposed state;
- current-state dependency;
- transition dependency;
- expected-state-revision binding;
- allowed transition matrix;
- terminal reopen rejection;
- direct `CN_NONE → CN_ACTIVE` rejection;
- bounded reasons;
- invalidation behavior;
- `connection_active_for_downstream_consideration`;
- all false downstream authority fields.

Preserve:

`TRANSITION_ADMISSIBLE != CONNECTION_CREATED`

`TRANSITION_ADMISSIBLE != CONNECTION_ACTIVATED`

unless a later separately authorized source writer creates that authoritative fact.

## 10. Current-state vs transition persistence model

Choose exactly one:

### Model A — one record family, typed derived fact classes

One additive Product Connection derived family contains two exact payload fact classes:

- current-state derivation;
- transition derivation.

Choose only if one family can preserve both without field overloading or ambiguous invalidation.

### Model B — two record families

Current-state and transition derivations require separate record families.

### Model C — no new derived family required

Existing generic persistence can already represent both losslessly without semantic field overloading.

### Model D — blocked

Evidence is insufficient or contradictory.

The result must justify the choice from the actual evaluator shape and current IP-13A rules.

Do not copy Canonical Match family design mechanically.

## 11. Exact derived payload requirements

If Model A or B is selected, define what a future record/projection contract must preserve at minimum.

For current-state derivation consider:

- payload kind / fact class;
- connection identity;
- canonical two participant references;
- protected-use scope;
- current state/classification;
- bounded reasons;
- selected current-state dependency;
- terminality;
- downstream-active descriptive flag;
- invalidation.

For transition derivation consider:

- payload kind / fact class;
- connection identity;
- canonical participants;
- protected-use scope;
- transition classification;
- current state;
- proposed state;
- bounded reasons;
- current-state dependency;
- transition dependency;
- expected-state-revision relation if necessary for lossless proof;
- terminal/reopen facts;
- downstream-active descriptive flag;
- invalidation.

Do not persist raw source evidence or required-binding objects inside the derived payload.

## 12. Structural-input vs domain-result boundary

The evaluator returns some reason categories for malformed shapes and others for semantically valid uncertainty/conflict.

The review must inventory exact reason literals and classify each as one of:

- `PRE_MATERIALIZATION_REJECTION_ONLY`
- `PERSISTED_CONNECTION_REASON_CATEGORY`
- `TRANSITION_DECISION_REASON_CATEGORY`
- `INSUFFICIENT_EVIDENCE`

Do not silently persist malformed raw structures merely because the evaluator can return a reason.

Do not convert valid domain `UNKNOWN` or transition `REJECTED` into input errors.

## 13. Dependency identity and duplicate-resolution contract

Define exact future persisted dependency identity requirements for:

- current-state evidence identity;
- transition identity.

The evaluator invalidation API carries one opaque `dependencyIdentity`.

The review must decide whether current-state and transition dependency identities must be collision-free across types for transition payloads.

Preserve source-local duplicate resolution and incomparable/equal-revision conflict semantics.

No global revision, LWW or arrival-order selection.

## 14. Terminality / invalidation / reopen

The review must explicitly analyze:

- terminal connection states:
  `CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`;
- whether a persisted current-state derivation uses terminal marker directly from current state;
- transition derivation terminality basis;
- how dependency invalidation to classification `UNKNOWN` preserves no-reopen semantics;
- whether the evaluator retains enough `current_state` / `proposed_state` context to avoid the Canonical Match sticky-terminality ambiguity;
- how existing IP-13A `TERMINAL_IDENTITY_REOPEN_REJECTED` would interact with a future Connection derived lifecycle.

Choose whether another sticky terminality field is needed or current/proposed state already carries sufficient exact context.

Do not infer lifecycle reset.

## 15. Currentness / freshness aggregation

Define whether the future derived record's top-level:

- `currentness`;
- `freshness`

can be computed exactly from selected current-state and/or transition dependencies.

Analyze separately:

- current-state derivation with missing/invalid/unresolved evidence;
- transition derivation when current state resolves but transition evidence is missing;
- transition derivation with both dependencies;
- invalidated result.

Do not copy Runtime Readiness or Match aggregation rules without evidence.

## 16. Logical identity / lifecycle identity

Define the minimum semantic inputs required for future deterministic:

- logical record identity;
- logical intent identity;
- lifecycle identity;
- source projection lineage;
- projection identity.

The lifecycle identity should represent the Product Connection lifecycle without embedding:

- current classification;
- proposed transition result;
- source revision vector;
- invalidation relation;
- storage order;
- timestamp.

The review must decide whether connection identity + protected-use scope + participant set + relevant descriptive bindings are sufficient.

No global revision.

## 17. IP-13A compatibility decision

Choose exactly one:

- `IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_CONNECTION_FAMILY`
- `IP13A_GENERIC_ENVELOPE_REQUIRES_SEMANTIC_CHANGE`
- `IP13A_EXISTING_GENERIC_RECORD_ALREADY_SUFFICIENT`
- `BLOCKED`

Remember current IP-13A only permits non-null derived payloads for accepted RR03 and Canonical Match families.

If an additive family is required, identify whether family-specific validation/retention is sufficient without changing generic envelope semantics.

## 18. IP-13D parity decision

Choose exactly one:

- `IP13D_CAN_RETAIN_ADDITIVE_CONNECTION_FAMILY_WITH_REFERENCE_PARITY`
- `IP13D_REQUIRES_PHYSICAL_SCHEMA_CHANGE`
- `IP13D_NOT_APPLICABLE_YET`
- `BLOCKED`

No migration/table/column change should be inferred merely because a new family is added.

## 19. IP-13E sufficiency decision

Choose exactly one:

- `IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_CONNECTION_RECORD_REPAIR`
- `IP13E_MAPPING_REVIEW_REQUIRED_BEFORE_SUFFICIENCY_DECISION`
- `IP13E_CONTRACT_REPAIR_REQUIRED`
- `BLOCKED`

Do not add a Product Connection-specific IP-13E method in R15.

## 20. IP-13F disposition

Choose exactly one:

- `IP_13F_UNCHANGED_NON_PARTICIPATING`
- `IP_13F_EXISTING_FAMILY_MAPPING_REVIEW_REQUIRED`
- `BLOCKED_BECAUSE_CURRENT_TRANSPORT_MODEL_INSUFFICIENT`

Do not add a sixth family.

Do not choose a Connection HTTP endpoint in R15.

## 21. Downstream gating

Record the exact downstream consequence.

At minimum decide whether:

- Messaging Consent / Conversation remains blocked by Product Connection vertical-slice closure;
- Calm Home remains blocked by multiple upstream projections;
- Notification remains blocked by upstream state/event materialization.

Do not authorize downstream work.

## 22. Exact next task type

Choose exactly one:

- `PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW — DOCUMENT ONLY`
- `PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW — DOCUMENT ONLY`
- `PRODUCT_CONNECTION_PERSISTENCE_FAMILY_IMPLEMENTATION_TASK`
- `ADDITIONAL_PRODUCT_CONNECTION_CONTRACT_REVIEW — DOCUMENT ONLY`
- `NO NEXT TASK — BLOCKED`

If a record/projection contract is not yet fixed, do not jump to implementation.

The result must name the exact next task ID/title and precise read/write scope.

## 23. Retained invariants

Preserve:

- Match != Connection != Conversation != Relationship;
- Match no automatic Connection;
- Connection no automatic Conversation;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- `UNKNOWN != ABSENT`;
- `DEFERRED != MISSING`;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no single authoritative Compatibility score;
- private Conversation is not default ranking/training/ads data;
- no auth/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing.

## 24. Review-only prohibition

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

## 25. Result requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all read blobs;
- next-domain A/B decision;
- matchResult participation decision;
- current-state semantic model;
- transition semantic model;
- reason classification;
- persistence Model A/B/C/D;
- payload/dependency requirements;
- dependency identity/collision rules;
- terminality/invalidation/reopen decision;
- currentness/freshness aggregation;
- deterministic identity basis;
- IP-13A decision;
- IP-13D decision;
- IP-13E decision;
- IP-13F disposition;
- downstream gating;
- exact next task type/title/scope;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape if Product Connection is next and needs additive record repair:

`IP-13I-R15 REVIEW COMPLETE — NEXT DOMAIN = PRODUCT_CONNECTION — OPTIONAL matchResult UNUSED/NON-PARTICIPATING UNDER CURRENT EVALUATOR — CURRENT-STATE + TRANSITION DERIVATIONS REQUIRE EXPLICIT CONNECTION DERIVED RECORD/PROJECTION CONTRACT BEFORE APPLICATION/HTTP — TERMINALITY/INVALIDATION/DEPENDENCY IDENTITY AND SOURCE-LOCAL REVISION BOUNDARIES FIXED OR PRECISELY SCOPED FOR NEXT REVIEW — IP-13E SUFFICIENCY/IP-13F DISPOSITION DECIDED — DOWNSTREAM MESSAGING REMAINS BLOCKED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
