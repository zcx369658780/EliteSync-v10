# EliteSync v10｜Next IP-13I-R10 Canonical Match Domain-to-Application Mapping Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CANONICAL MATCH DOMAIN→APPLICATION MAPPING REVIEW — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`ca445d2ad8354961247e5b20043ebb3b748f4e68`

Accepted R9-R1 result blob:
`114eb27d2766657d9e6fb364ce83fc8fee82c66d`

R9-R1 acceptance blob:
`44f3ee11a0fedbdf80c0c27be47063f42a370cd9`

Rejected R9 result semantic source:
- candidate: `b03966d09e91430a31a03eecf5d3b8575602357d`
- result blob: `1f8394b25ee54373bf4d4e8836075b13b8efcbf1`

## 1. Objective

Define one exact synthetic/dev-test Canonical Match domain-to-application orchestration against the accepted R9/R9-R1 record/projection contract.

This task is REVIEW ONLY.

It must decide whether a dedicated Canonical Match persistence application adapter is semantically sound before any implementation.

The mapping review must fix:

- exact structural input gate;
- exact evaluator invocation;
- exact pre-invalidation/post-invalidation binding flow;
- exact R9/R9-R1 record construction;
- exact submit/retrieve ordering through current IP-13E;
- exact readback equivalence test;
- exact storage/materialization disposition mapping;
- exact idempotent/repeated-input behavior;
- exact already-invalidated input behavior;
- exact invalidation orchestration boundary;
- exact non-authority and privacy boundaries;
- exact future implementation write scope if sound.

It must not implement the adapter, persistence family, route, controller or test.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R10 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r10-canonical-match-domain-to-application-mapping-v0-1`

No repository enumeration or unrelated discovery is authorized.

## 3. Accepted controlling contract

Preserve the accepted R9-R1 decisions:

- family:
  `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`
- sticky terminality after invalidation;
- `classification_before_invalidation` inside terminality;
- `STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`;
- exactly fifteen persisted Match reason categories;
- proposal / participant / selected-slot dependency identities collision-free across types;
- deterministic source-order-independent correlation;
- top-level correlation revision value `0`;
- currentness/freshness aggregated independently;
- raw source evidence excluded from derived payload;
- `authoritative_outcome=UNKNOWN` absent independently source-carried outcome;
- IP-13A generic envelope compatible after family-specific validation/retention repair;
- IP-13E existing operations sufficient;
- IP-13F unchanged/non-participating;
- no Match source authority and no automatic Connection/Consent/Conversation/relationship authority.

Preserve the R9-R1 acceptance constraint:

An already-invalidated `UNKNOWN` must not be used by itself as a fresh pre-invalidation source for sticky terminality reconstruction.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R10 task

3. R9-R1 accepted result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

4. R9-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`

5. rejected R9 result at exact candidate:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`
   from:
   `b03966d09e91430a31a03eecf5d3b8575602357d`

6. R8 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_ACCEPTANCE_V0_1.md`

7. Canonical Match evaluator:
   `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`

8. Common Authority:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

9. IP-13A:
   `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

10. IP-13D physical reference:
    `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

11. IP-13E:
    `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`

12. IP-13F:
    `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`

13. accepted Runtime Readiness adapter, contrast only:
    `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R9-R1 result:
  `114eb27d2766657d9e6fb364ce83fc8fee82c66d`
- R9-R1 acceptance:
  `44f3ee11a0fedbdf80c0c27be47063f42a370cd9`
- rejected R9 result:
  `1f8394b25ee54373bf4d4e8836075b13b8efcbf1`
- R8 acceptance:
  `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13D:
  `a81535d174015bb0ecaa9f8caeaabb7490c4354b`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- IP-13F:
  `e70f260de92a0047e70b54827f4795edb3b74e00`
- Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`

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
- any client/provider/product source.

## 6. Required top-level decision

Choose exactly one:

### Option A
`DEDICATED_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND`

A dedicated synthetic/dev-test adapter can truthfully orchestrate:

`input gate → evaluator → accepted Match derived record → IP-13E submit → conditional retrieve → exact readback/materialization result`

without changing accepted authority semantics.

### Option B
`PERSISTENCE_FAMILY_IMPLEMENTATION_REQUIRED_BEFORE_MAPPING_CAN_BE_FIXED`

The record contract is sound, but mapping cannot yet be specified precisely until IP-13A/IP-13D actually implement the Match family.

### Option C
`ADDITIONAL_APPLICATION_CONTRACT_REPAIR_REQUIRED`

The current IP-13E operation set is insufficient for a truthful Match adapter.

### Option D
`BLOCKED`

The current evidence is insufficient or contradictory.

R9-R1 suggests Option A may be sound, but this review must independently decide.

## 7. Exact synthetic structural input gate

If Option A is selected, define the exact adapter input shape:

- proposal object;
- participation evidence list;
- decision-slot evidence list;
- optional invalidation request, if any.

The gate must reject before evaluator-to-record construction any input excluded by R9-R1, including:

- invalid proposal identity/scope/lifecycle vocabulary;
- participant cardinality other than exactly two unique non-empty strings;
- malformed Common Authority bindings/evidence/revision structures;
- invalid participation state vocabulary;
- invalid slot identity/proposal/participant identity;
- invalid slot decision vocabulary;
- cross-type dependency identity collisions;
- invalid invalidation identity/relation shape.

Do not treat semantic uncertainty as malformed input.

The result must define whether the adapter has:
- one normal evaluation operation plus a separate invalidation operation; or
- one envelope with an optional invalidation sub-object.

Do not invent transport/HTTP request shape.

## 8. Evaluator invocation

Define exact normal evaluation flow:

1. structural gate;
2. canonicalize only where contract requires order independence;
3. call `CanonicalMatchProposalDecisionEvaluator::evaluate()` exactly once;
4. bound/reduce reasons;
5. verify output classification/reasons/dependency structure against accepted contract;
6. construct Match payload;
7. construct generic logical record.

No second evaluator call is allowed in the ordinary non-invalidation path unless exact evidence proves it necessary.

Do not mutate input arrays.

## 9. Invalidation orchestration

Define an exact invalidation flow compatible with sticky terminality.

At minimum decide:

- invalidation request fields;
- how the dependency identity is checked against the bound dependency set;
- how relation is checked against `CORRECTION | REVOCATION | SUPERSESSION`;
- how the exact pre-invalidation result is obtained;
- whether it comes from a fresh evaluator call against supplied evidence, exact persisted readback, or either under explicit binding rules;
- how `classification_before_invalidation` is captured;
- exactly one call to `CanonicalMatchProposalDecisionEvaluator::invalidate()`;
- how repeated invalidation is handled;
- how an already-invalidated result fails closed;
- how sticky terminality is preserved without reading timestamps/history order;
- how generic record invalidation remains separate from dependency-scoped Match invalidation.

The result must not allow:
- an already-invalidated `UNKNOWN` alone to seed another invalidation record;
- ambiguous dependency identity;
- inferred prior classification from storage order.

## 10. Exact Match payload and record construction

Use the accepted R9 + R9-R1 contract as authoritative.

Define the adapter construction rules for:

- bounded reason mapping;
- proposal dependency;
- participation dependencies;
- decision-slot dependencies;
- currentness;
- freshness;
- terminality;
- invalidation;
- deterministic sorting;
- deterministic semantic digest;
- logical record identity;
- logical intent identity;
- lifecycle identity;
- lineage;
- projection identity;
- derived correlation revision;
- source condition;
- authoritative outcome;
- projection metadata;
- private fixture extensions.

Do not redefine the accepted schema.

If the mapping review discovers an unavoidable ambiguity in the accepted schema, select Option D rather than silently changing it.

## 11. Submit ordering and storage semantics

Define exact ordering through IP-13E.

Expected conceptual flow if sound:

1. evaluator-derived record constructed;
2. call `submitAuthoritativeMutation()` once;
3. inspect persistence storage disposition;
4. retrieve only when storage disposition permits exact correlation;
5. no retry.

Preserve:

- storage success != Match classification;
- submit method name does not make Match authoritative;
- `authoritative_outcome=UNKNOWN` absent source-carried outcome;
- exact duplicate is idempotent correlation only.

Define which storage outcomes are retrievable and which skip retrieval.

Do not add an IP-13E method.

## 12. Exact retrieve query / request binding

Define the exact query fields used to retrieve the current Match projection.

At minimum decide:

- record family;
- derived authority owner;
- derived authority scope;
- aggregate context / proposal identity;
- lineage.

Define exact request bindings:

- viewer;
- subject;
- participants;
- audience;
- purpose;
- aggregate context.

The adapter must use only deterministic derived bindings defined by R9.

Do not infer authentication identity from the request/runtime environment.

## 13. Exact readback equivalence

Define when a retrieved Match projection is usable.

At minimum require:

- retrieval resolution exact/usable under existing IP-13E semantics;
- binding classification `EXACT`;
- generic projection not invalidated;
- readback derived payload present;
- readback payload byte/semantic equality against constructed payload under canonicalized representation;
- sticky terminality agrees;
- invalidation provenance agrees;
- record family exactly Match family.

The result must define whether equality is direct array equality after canonical construction or digest equality plus structural validation.

No approximate comparison.

## 14. Materialization disposition contract

Define exactly three or similarly bounded internal adapter dispositions, without creating source authority.

At minimum distinguish:

1. exact Match projection materialized and usable;
2. storage rejected / retrieval skipped;
3. stored but readback unusable/missing/mismatched/invalidated.

For each define:

- whether Match classification remains evaluator output;
- whether materialized projection usable is true/false;
- whether reconciliation/revalidation flags are needed;
- whether invalidation required is distinct;
- whether any retry occurs.

Do not reinterpret Match `UNKNOWN` as HTTP/server failure.

R10 defines no HTTP status.

## 15. Repeated / duplicate input

Define exact behavior for:

- exact same semantic input repeated;
- same logical intent with changed semantic input;
- distinct dependency revision vector;
- incomparable source-local dependencies;
- terminal lifecycle plus later non-terminal fresh evaluation;
- terminal lifecycle plus dependency invalidation;
- repeated same dependency invalidation request.

Preserve IP-13A duplicate/conflict/terminal guard semantics.

Do not introduce LWW or arrival-order resolution.

## 16. Adapter result shape

Define the exact internal adapter result key set if Option A is selected.

At minimum decide whether it exposes internally:

- Match classification;
- bounded reason categories;
- Match derived payload;
- logical record identity;
- logical intent identity;
- lifecycle identity;
- source projection lineage;
- derived correlation revision;
- storage disposition;
- projection read disposition;
- materialized projection usable;
- authoritative outcome;
- reconciliation required;
- invalidation required;
- revalidation required;
- condition;
- synthetic/dev-test-only marker;
- mandatory false non-authority fields.

This is application-internal, not an HTTP contract.

Do not expose raw source evidence.

## 17. Privacy boundary

Explicitly exclude from persisted Match payload and adapter public-facing future surfaces:

- raw Common Authority evidence objects;
- raw required bindings;
- unselected duplicate slot candidates;
- private profile content;
- private Conversation/message content;
- hidden Safety evidence;
- credentials/tokens;
- provider payloads;
- rankings;
- single Compatibility total;
- desirability/person-worth inferences.

Participant/proposal/slot identifiers remain bounded internal correlation values only.

R10 does not authorize their HTTP exposure.

## 18. IP-13A / IP-13D implementation sequencing

If Option A is selected, decide whether the next actual implementation task must first implement the Match family in:

- IP-13A reference repository; and
- IP-13D sqlite::memory: adapter

before implementing the Match application adapter.

Choose exactly one:

- `PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`
- `PERSISTENCE_AND_ADAPTER_IMPLEMENT_TOGETHER_IN_ONE_BOUNDED_TASK`
- `ADDITIONAL_REVIEW_REQUIRED`

The result must justify the minimum safe sequence.

Do not authorize implementation in R10.

## 19. IP-13E sufficiency

Reconfirm exactly one:

- `IP13E_EXISTING_OPERATIONS_SUFFICIENT`
- `IP13E_CONTRACT_REPAIR_REQUIRED`
- `BLOCKED`

If sufficient, explain why current methods are enough despite names such as `submitAuthoritativeMutation()`.

No method addition in R10.

## 20. IP-13F disposition

Must remain:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

unless current evidence reveals a contradiction, in which case classify blocked.

No sixth family.
No Match route.
No HTTP contract.

## 21. Future HTTP gate

R10 must explicitly state whether a future dedicated Match HTTP entry may be reviewed only after:

- persistence family implementation acceptance;
- Match adapter implementation acceptance;
- targeted runtime proof of domain→persistence→application mapping.

No route or HTTP path is selected here.

## 22. Exact next task boundary

If Option A is selected, choose exactly one next task type:

- `CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_TASK`
- `CANONICAL_MATCH_PERSISTENCE_PLUS_ADAPTER_IMPLEMENTATION_TASK`
- `ADDITIONAL_DOCUMENT_ONLY_REVIEW`

Define:

- exact next task ID/title;
- exact read scope;
- exact write scope;
- exact targeted test scope;
- no HTTP scope.

Do not author that next task from the R10 branch.

## 23. Retained invariants

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`
- `STORED != AUTHORITATIVE`
- `APPLICATION_RESULT != SOURCE_AUTHORITY`
- Match != Connection != Conversation != Relationship
- invalidation != reopen
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- no global revision
- no LWW / arrival-order / timestamp authority
- no single authoritative Compatibility score
- no auth/session/token authority
- no production persistence/deployment authority
- no real/private-data processing
- private Conversation is not default ranking/training/ads data.

## 24. Review-only prohibition

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
- production action;
- real/private-data operation.

Do not modify code.

## 25. Result requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path write scope;
- all read input blobs;
- Option A/B/C/D decision;
- exact structural input gate;
- normal evaluator flow;
- invalidation flow;
- record/payload construction mapping;
- submit/retrieve ordering;
- retrieve query/bindings;
- exact readback equivalence;
- materialization dispositions;
- repeat/duplicate semantics;
- adapter result shape;
- privacy exclusions;
- IP-13A/IP-13D sequencing;
- IP-13E sufficiency;
- IP-13F disposition;
- future HTTP gate;
- exact next task type/title/scope;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape:

`IP-13I-R10 REVIEW COMPLETE — DEDICATED CANONICAL MATCH PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — SYNTHETIC INPUT GATE / STICKY INVALIDATION FLOW / RECORD CONSTRUCTION / IP-13E SUBMIT+RETRIEVE / EXACT READBACK / MATERIALIZATION DISPOSITIONS FIXED — IP-13F UNCHANGED/NON-PARTICIPATING — EXACT NEXT IMPLEMENTATION SEQUENCE FIXED — NO IMPLEMENTATION OR HTTP AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
