# EliteSync v10｜IP-13I-R10 Canonical Match Domain-to-Application Mapping Review Result｜v0.1

Status: `CANDIDATE — DOCUMENT-ONLY MAPPING REVIEW COMPLETE — DEDICATED CANONICAL MATCH PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh authority / candidate sole parent: `20e0ab5bbc01c310d9375784eabbb8cb365f8f54`

Authority sole parent / task-publication base: `ca445d2ad8354961247e5b20043ebb3b748f4e68`

Authority tree: `e141ea36023202fbe0e5cf3c9368f9e0c713d5f3`

Review branch: `review/next-ip-13i-r10-canonical-match-domain-to-application-mapping-v0-1`

Candidate commit/tree and authority-relative ahead/behind are resolved externally after immutable publication because this document participates in those identities. The candidate must have the fresh authority as its sole parent and be `0 / 1` behind/ahead relative to it.

## 1. Top-level decisions

`DEDICATED_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND`

`PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

`IP_13F_UNCHANGED_NON_PARTICIPATING`

A dedicated synthetic/dev-test adapter can truthfully perform:

`structural gate → one evaluator call → optional one invalidation call → accepted Match record construction → one IP-13E submit → conditional exact-lineage retrieve → exact readback/materialization disposition`

The adapter creates no Match source authority and no transport or HTTP contract. This review authorizes no implementation.

## 2. Exact scope and evidence ledger

This candidate creates exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`

No existing tracked file changes.

Actual authorized inputs and blobs:

| Evidence | Blob |
|---|---|
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R10 task | `7e244fe1ee1425da15300a1d41564d6d4c3ab236` |
| accepted R9-R1 result | `114eb27d2766657d9e6fb364ce83fc8fee82c66d` |
| R9-R1 acceptance | `44f3ee11a0fedbdf80c0c27be47063f42a370cd9` |
| rejected R9 result, schema source only at candidate `b03966d09e91430a31a03eecf5d3b8575602357d` | `1f8394b25ee54373bf4d4e8836075b13b8efcbf1` |
| R8 acceptance | `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8` |
| Canonical Match evaluator | `c101657187348dcafa91afbf0b889bc94f0a0bff` |
| Common Authority | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| IP-13A | `2877f5804710abf7c8eba87a9d59925ad5cc405d` |
| IP-13D | `a81535d174015bb0ecaa9f8caeaabb7490c4354b` |
| IP-13E | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| IP-13F | `e70f260de92a0047e70b54827f4795edb3b74e00` |
| Runtime Readiness adapter, contrast only | `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5` |

The rejected R9 result supplies only schema portions explicitly preserved by accepted R9-R1. Its superseded terminality, invalidation, and reason rules are not reused.

No repository enumeration, unrelated discovery, or additional source read occurred.

## 3. Adapter operation boundary

The dedicated adapter has two internal operations, not one envelope with an optional invalidation field:

1. `evaluateAndMaterialize()` for ordinary evaluation;
2. `invalidateAndMaterialize()` for one dependency-scoped invalidation transition.

Both operations accept a synthetic/dev-test-only input envelope. Neither accepts an evaluator result, derived payload, stored projection, HTTP request, authentication identity, session, token, or provider object.

### 3.1 Ordinary operation input

The ordinary envelope contains exactly:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`

`synthetic_fixture` is exactly:

`ELITESYNC_CANONICAL_MATCH_SYNTHETIC_DEV_TEST_V1`

### 3.2 Invalidation operation input

The invalidation envelope contains exactly:

- `synthetic_fixture`
- `proposal`
- `participation_evidence`
- `decision_slot_evidence`
- `invalidation_request`

`invalidation_request` contains exactly:

- `dependency_identity`: non-empty string;
- `relation`: exactly `CORRECTION | REVOCATION | SUPERSESSION`.

No `pre_invalidation_result`, `classification_before_invalidation`, existing payload, or existing invalidated result is accepted from the caller. The adapter obtains the pre-invalidation result only through the bounded evaluator flow in Section 6.

## 4. Exact synthetic structural gate

The gate runs before evaluator invocation and does not mutate any supplied array.

### 4.1 Proposal

The proposal contains exactly:

- `proposal_identity`
- `participants`
- `protected_use_scope`
- `lifecycle_state`
- `at_most_one_unresolved_precondition`
- `required_bindings`
- `source_evidence`

It requires:

- non-empty string proposal identity and protected-use scope;
- exactly two unique non-empty string participants;
- lifecycle state in `PENDING | MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- boolean `at_most_one_unresolved_precondition`;
- exact Common Authority binding/evidence/revision structures.

A false unresolved-precondition flag is structurally valid and may produce domain `UNKNOWN`; a non-boolean flag is malformed.

### 4.2 Participation evidence

`participation_evidence` is a list. Each item contains exactly:

- `participant_identity`
- `state`
- `required_bindings`
- `source_evidence`

Every supplied identity is a non-empty string. State is exactly one of:

`NOT_ENROLLED | ENROLLED | PAUSED | WITHDRAWN`

Every binding/evidence/revision container is structurally valid under Common Authority. A missing participant item, a duplicate supplied participant, or a valid outsider identity remains evaluator semantics and may yield persistable `UNKNOWN`; a malformed item is rejected.

### 4.3 Decision-slot evidence

`decision_slot_evidence` is a list. Each item contains exactly:

- `slot_identity`
- `proposal_identity`
- `participant_identity`
- `protected_use_scope`
- `decision`
- `required_bindings`
- `source_evidence`

All four identity/scope values are non-empty strings. Decision is exactly:

`PENDING | ACCEPTED | DECLINED | WITHDRAWN`

Every binding/evidence/revision container is structurally valid. A structurally valid cross-proposal or wrong-participant reference remains evaluator semantics. Missing fields, invalid literals, or malformed source evidence are rejected.

### 4.4 Common Authority structural validation

Every supplied binding has the exact eleven Common Authority keys. Every source evidence object and source revision has its exact contract keys, correct scalar types, non-negative revision value, non-empty authority/context/lineage strings, and matching owner/scope/context between binding and revision.

Currentness, freshness, source condition, authoritative satisfaction, and exact semantic binding failures are not converted into structural failures when their shapes and vocabularies are valid.

### 4.5 Post-evaluator record-eligibility validation

Before record construction, the adapter requires:

- evaluator record kind, classification, reasons, dependencies, invalidation fields, and false non-authority fields to match the accepted contract;
- proposal identity, both participant identities, and every selected slot identity to be pairwise distinct across dependency types;
- selected slot identities to be unique across participants;
- every dependency to be structurally complete;
- every reason to reduce to the accepted fifteen-category persisted vocabulary.

The four pre-materialization-only evaluator categories remain non-persistable:

- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `INVALID_PROPOSAL_SHAPE`
- `INVALID_SLOT_EVIDENCE`
- `INVALID_SLOT_DECISION`

Any violation rejects before evaluator-to-record construction. Structurally valid semantic uncertainty remains a persistable `UNKNOWN` derivation.

## 5. Ordinary evaluator flow

The ordinary operation performs exactly:

1. validate the exact synthetic envelope and nested structural gate;
2. pass the original proposal, participation list, and slot list to `CanonicalMatchProposalDecisionEvaluator::evaluate()` exactly once;
3. do not reorder or mutate evaluator input arrays;
4. validate the evaluator output and record eligibility;
5. reduce/deduplicate reasons into the fixed fifteen-category canonical order;
6. canonicalize only persisted binding participants and dependency lists as required by R9/R9-R1;
7. construct the exact Match payload;
8. construct the exact generic logical record;
9. submit and conditionally retrieve under Sections 9–11.

No second evaluator call, retry, fallback evaluator, or generic invalidation call occurs in the ordinary path.

For an ordinary payload:

- `invalidation.invalidated=false`;
- invalidation relation and identity are `null`;
- `classification_before_invalidation=null`;
- `derived_terminal` follows the current classification;
- `lifecycle_reset=false` and `proposal_reopened=false`.

## 6. Sticky-terminality invalidation flow

The invalidation operation performs exactly:

1. run the same structural gate over the original proposal/participation/slot evidence and the exact invalidation request;
2. call `evaluate()` exactly once on those original inputs;
3. validate and bind that output as the exact pre-invalidation result;
4. construct its canonical dependency set and reject cross-type identity collisions;
5. require `invalidation_request.dependency_identity` to resolve to exactly one proposal, participation, or selected-slot dependency;
6. capture its bounded classification as `classification_before_invalidation`;
7. call `CanonicalMatchProposalDecisionEvaluator::invalidate()` exactly once with the pre-invalidation result, dependency identity, and relation;
8. require the returned result to have current `classification=UNKNOWN`, reasons exactly `[DEPENDENCY_INVALIDATED]`, the same dependency vector, the requested identity/relation, and both lifecycle-reset/reopen flags false;
9. construct the corrected sticky-terminal payload and record;
10. submit and conditionally retrieve under Sections 9–11.

The pre-invalidation state is always a fresh structurally valid evaluator result from the supplied evidence in this bounded adapter. This mapping does not use persisted readback as an evaluator-result reconstruction source.

Sticky terminality is computed exactly:

- `classification_before_invalidation` equals the captured pre-invalidation classification;
- `derived_terminal=true` when that value is `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- otherwise it is false, unless that would attempt a non-terminal materialization under an already terminal lifecycle, in which case IP-13A rejects the reopen and retrieval is skipped;
- `bindings.terminal` equals `derived_terminal`;
- current classification remains `UNKNOWN`;
- proposal reopening and lifecycle reset remain false.

No timestamp, storage order, arrival order, LWW rule, or global revision participates.

Generic IP-13A/IP-13E invalidation observation is not called for this dependency-scoped flow. The Match payload is the only dependency-provenance carrier; generic logical-record invalidation remains a separate operation with record-level identity only.

## 7. Already-invalidated and repeated invalidation behavior

An already-invalidated evaluator result cannot be supplied because neither adapter operation accepts evaluator-result or derived-payload fields. Any extra field attempting to supply one fails the exact envelope gate before evaluator invocation.

An `UNKNOWN` classification, payload invalidation object, or `classification_before_invalidation` supplied by a caller is never used as an original state.

A repeated request using the same raw structurally valid evidence and the same dependency identity/relation is allowed. It performs one fresh evaluation and one invalidation call again, deterministically reconstructs the same semantic record, and reaches IP-13A/IP-13D as `EXACT_DUPLICATE`. It is idempotent correlation, not a second transition, reopen, retry, or new authority fact.

Changing dependency identity or relation changes the payload digest and produces a distinct intent/record. It remains subject to terminal guard, source-local comparison, and exact readback.

## 8. Evaluator-to-payload and record construction

The adapter uses the accepted R9 schema only as corrected by R9-R1.

### 8.1 Exact payload

The payload retains exactly eleven top-level keys:

1. `payload_kind`
2. `derived_fact_class`
3. `classification`
4. `proposal_identity`
5. `protected_use_scope`
6. `reason_categories`
7. `proposal_dependency`
8. `participation_dependencies`
9. `decision_slot_dependencies`
10. `terminality`
11. `invalidation`

The fixed kind/fact value is `CANONICAL_MATCH_PROPOSAL_DECISION`.

Proposal, participation, and selected-slot dependencies use the exact accepted field shapes. Source owner/scope/context/lineage/revision/condition/currentness/freshness are copied from structurally bound source evidence. Raw source evidence and required-binding objects are excluded.

Participation dependencies are sorted by participant identity, owner, scope, context, lineage, and revision. Selected-slot dependencies are sorted by participant identity, slot identity, owner, scope, context, lineage, and revision. Reasons use the fixed accepted fifteen-category order.

Currentness and freshness are independently aggregated:

1. any required dependency false → false;
2. otherwise incomplete required vector or any required null → null;
3. otherwise true.

Terminal source proposals require only the proposal dependency. Pending proposals require the proposal, exact two participation dependencies, and exact two selected-slot dependencies for a complete vector.

### 8.2 Generic bindings and revision

The derived bindings are:

- `authority_owner=CANONICAL_MATCH_DERIVATION`;
- `authority_scope=CANONICAL_MATCH_PROPOSAL_DECISION|<protected-use-scope>`;
- actor, actor role, subject, audience, and purpose copied from the structurally accepted proposal required bindings;
- participants equal the exact two proposal participant references sorted lexicographically;
- aggregate context equals proposal identity;
- lifecycle identity uses the accepted deterministic lifecycle basis;
- terminal equals corrected `terminality.derived_terminal`.

The derived source revision has the same owner/scope/context, deterministic derived lineage, and value exactly `0`. It is correlation only.

### 8.3 Deterministic identities

The adapter recursively canonicalizes associative keys, canonical list orders, bindings, and payload, then computes SHA-256 over exactly:

- record family;
- normalized generic bindings;
- corrected Match payload;
- schema marker `canonical-match-derived-projection-v1`.

It applies the accepted prefixes:

- `canonical-match-record-v1:`
- `canonical-match-intent-v1:`
- `canonical-match-lineage-v1:`
- `canonical-match-projection-v1:`

Changed source-local dependency revision vectors change the digest. Input order alone cannot.

### 8.4 Remaining envelope values

- record family: `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- source condition: `PRESENT`, meaning only that the derived record exists;
- authoritative outcome: `UNKNOWN`;
- authoritative outcome metadata: `null`;
- correction metadata: initially `null`;
- projection represented revision: `0`;
- projection currentness: aggregate currentness;
- projection lag: `CURRENT | LAGGED | UNKNOWN` from currentness only;
- transport observation: `AMBIGUOUS`;
- private fixture extensions: exactly `[]`.

## 9. IP-13E submit ordering

After record construction:

1. call `submitAuthoritativeMutation()` exactly once;
2. read `persistence.storage_outcome` without treating it as Match classification;
3. retrieve exactly once only for `STORED_NEW`, `EXACT_DUPLICATE`, or `INCOMPARABLE_COEXISTS`;
4. skip retrieval for `CHANGED_INPUT_REUSE_REJECTED`, `CONFLICTING_EQUAL_REVISION_REJECTED`, `INVALID_RECORD_REJECTED`, or any unknown disposition;
5. perform no retry.

`INCOMPARABLE_COEXISTS` is retrievable here because the record is stored and the Match query carries its exact deterministic lineage. This does not choose among incomparable source-local lineages and does not copy the stricter RR03 adapter choice mechanically.

The method name `submitAuthoritativeMutation()` creates no Match authority. The submitted record has no source-carried outcome, so application authoritative outcome remains `UNKNOWN` and reconciliation remains required under IP-13E.

## 10. Exact retrieval query and bindings

The retrieve query contains exactly:

- `record_family=CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- `authority_owner=CANONICAL_MATCH_DERIVATION`;
- `authority_scope=CANONICAL_MATCH_PROPOSAL_DECISION|<protected-use-scope>`;
- `aggregate_context=<proposal_identity>`;
- `lineage=<constructed canonical-match-lineage-v1 digest>`.

The IP-13E request bindings contain exactly:

- `viewer=record.bindings.actor`;
- `subject=record.bindings.subject`;
- `participants=record.bindings.participants` in canonical sorted order;
- `audience=record.bindings.audience`;
- `purpose=record.bindings.purpose`;
- `aggregate_context=record.bindings.aggregate_context`.

Viewer is a descriptive synthetic binding copied from accepted evidence. It is not inferred from runtime, authentication, session, token, or transport state.

## 11. Exact readback equivalence

Readback is exactly equivalent only when all are true:

- IP-13E resolution is `RESOLVED`;
- binding classification is `EXACT`;
- projection record family equals the Match family;
- generic `projection_invalidated=false`;
- logical record identity, logical intent identity, lifecycle identity, derived lineage, projection identity, and represented revision value equal the constructed record;
- derived payload is present and passes the exact Match family validator;
- readback payload is direct PHP array-identical (`===`) to the canonically constructed payload;
- sticky terminality, classification-before-invalidation, dependency invalidation identity/relation, and lifecycle-reset/reopen flags agree exactly.

Digest equality alone is insufficient. Approximate comparison, subset comparison, reordered noncanonical lists, omitted nulls, or reason-set-only comparison is rejected.

An exactly equivalent payload with `invalidation.invalidated=true` proves faithful materialization but remains unusable for protected use under Section 12.

## 12. Bounded materialization dispositions

The internal adapter uses exactly four conditions:

### 12.1 `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`

- storage outcome is retrievable;
- readback is exactly equivalent;
- payload is not dependency-invalidated;
- evaluator Match classification is preserved, including ordinary `UNKNOWN`;
- `materialized_projection_usable=true`;
- `invalidation_required=false`;
- `revalidation_required=false`;
- reconciliation remains the IP-13E submission value;
- no retry.

### 12.2 `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`

- storage outcome is retrievable;
- readback is exactly equivalent;
- payload carries accepted dependency invalidation;
- Match classification remains evaluator `UNKNOWN`;
- `materialized_projection_usable=false`;
- `invalidation_required=true` as a bounded state flag; it does not direct a generic overlay call;
- `revalidation_required=true`;
- no retry.

### 12.3 `STORAGE_REJECTED_RETRIEVAL_SKIPPED`

- storage outcome is not one of the three retrievable outcomes;
- evaluator classification and bounded reasons remain reported as evaluator facts;
- `materialized_projection_usable=false`;
- projection read disposition is `null`;
- `revalidation_required=true`;
- no retry.

### 12.4 `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

- storage outcome permitted retrieval, but resolution/binding/family/identity/payload/terminality/invalidation equivalence failed or generic projection was invalidated;
- evaluator classification remains unchanged;
- `materialized_projection_usable=false`;
- `revalidation_required=true`;
- no retry.

Match `UNKNOWN` never means HTTP failure, server failure, storage rejection, or missing data by itself. R10 defines no HTTP status.

## 13. Duplicate, changed, incomparable, and terminal behavior

- Exact same semantic input: same payload/digest/identities; persistence returns `EXACT_DUPLICATE`; exact retrieval may still establish usable materialization.
- Same logical identity or intent with changed semantic input: adapter-generated identities normally change with input; forced reuse is rejected by IP-13A/IP-13D and retrieval is skipped.
- Distinct dependency revision vector: new payload digest, record/intent/lineage/projection identities; a source-local incomparable disposition may coexist; retrieve only the exact new lineage, never select by arrival order.
- Conflicting equal derived source revision: preserve persistence rejection; no adapter override.
- Terminal lifecycle followed by a non-terminal fresh evaluation: rejected by `TERMINAL_IDENTITY_REOPEN_REJECTED`; no retrieval and no lifecycle reset.
- Terminal lifecycle followed by valid dependency invalidation: classification becomes `UNKNOWN`, sticky terminality and `bindings.terminal=true` remain; the invalidated record may coexist under its distinct exact lineage.
- Repeated identical dependency invalidation: deterministic `EXACT_DUPLICATE`; no second transition is inferred.

No LWW, timestamp, arrival-order, last-received, or global-revision rule is introduced.

## 14. Exact adapter result key set

For structurally accepted operations, the application-internal result contains exactly:

1. `record_kind`
2. `operation`
3. `match_classification`
4. `reason_categories`
5. `match_payload`
6. `logical_record_identity`
7. `logical_intent_identity`
8. `lifecycle_identity`
9. `source_projection_lineage`
10. `derived_correlation_revision`
11. `storage_disposition`
12. `projection_read_disposition`
13. `binding_classification`
14. `materialized_projection_usable`
15. `authoritative_outcome`
16. `reconciliation_required`
17. `invalidation_required`
18. `revalidation_required`
19. `condition`
20. `synthetic_dev_test_only`
21. `source_local_revision_only`
22. `global_revision`
23. `last_write_wins`
24. `last_received_wins`
25. `transport_disposition`
26. `http_status`
27. `source_authority`
28. `match_authority`
29. `connection_authority`
30. `consent_authority`
31. `conversation_authority`
32. `relationship_authority`
33. `home_action_authority`
34. `notification_delivery_authority`
35. `launch_authority`
36. `permission`
37. `bearer_capability`
38. `production_ready`
39. `real_data_authorized`

Fixed values:

- `record_kind=CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_RESULT`;
- `operation=EVALUATE | INVALIDATE`;
- `synthetic_dev_test_only=true`;
- `source_local_revision_only=true`;
- derived correlation revision is the exact five-key revision object with value `0`;
- `transport_disposition=null` and `http_status=null`;
- keys 22–24 and 27–39 are false.

`match_payload` is privacy-minimal persistence content, not raw evaluator/source input. Structural rejection occurs before this result shape and produces no persistence/application adapter result.

## 15. Privacy boundary

Never persist or expose through the adapter result:

- raw Common Authority evidence objects;
- raw required-binding objects;
- unselected duplicate slot candidates;
- private profile or content fields;
- private Conversation or message content;
- hidden Safety evidence;
- credentials, sessions, tokens, or bearer material;
- provider payloads;
- rankings or a single Compatibility total;
- desirability or person-worth inferences;
- synthetic private fixture extensions.

Proposal, participant, and selected-slot identifiers survive only as bounded internal correlation/dependency values. Their internal persistence does not authorize later HTTP exposure.

## 16. IP-13A and IP-13D implementation sequencing

`PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`

Current IP-13A accepts a non-null derived payload only for RR03. Current IP-13D delegates validation to IP-13A and then removes derived payloads for non-RR03 families. Therefore an adapter implemented first could only be rejected or lose its Match payload.

The next implementation must update IP-13A and IP-13D together so they remain behaviorally equivalent for:

- exact Match family validation and payload retention;
- corrected sticky terminality and fifteen reasons;
- dependency identity collision rejection;
- deterministic projection/readback;
- separation of generic overlay invalidation from Match dependency invalidation;
- existing RR03 and generic-family behavior unchanged;
- existing `sqlite::memory:` DSN and two-table physical shape unchanged.

The dedicated Match adapter must be a later task after this persistence family implementation has independent acceptance and targeted runtime proof.

## 17. IP-13E sufficiency

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

The current methods already provide every required action:

- one record submission through `submitAuthoritativeMutation()`;
- exact-lineage current projection lookup with binding comparison through `retrieveCurrentProjection()`;
- generic logical-record invalidation remains available separately through `observeInvalidation()`;
- reconciliation/revalidation remain available without becoming adapter orchestration methods.

The submission method name does not create source authority because source-carried outcome metadata is absent, the record authoritative outcome is `UNKNOWN`, and IP-13E returns non-authority flags.

No Match-specific IP-13E method or contract repair is required.

## 18. IP-13F and future HTTP gate

`IP_13F_UNCHANGED_NON_PARTICIPATING`

No sixth IP-13F family, Match route, endpoint, controller, request envelope, response body, status mapping, or authentication rule is selected.

A dedicated Match HTTP entry may be reviewed only after all three are independently accepted:

1. Canonical Match persistence family implementation in IP-13A/IP-13D;
2. dedicated Match persistence application adapter implementation;
3. targeted runtime proof of the synthetic domain→persistence→application mapping, including sticky invalidation and exact readback.

Even then, a separate document-only transport/HTTP review is required before implementation.

## 19. Exact next bounded task

Next task type:

`CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_TASK`

Exact task ID/title:

`IP-13I-R11 CANONICAL MATCH PERSISTENCE FAMILY REFERENCE/SQLITE IMPLEMENTATION TASK`

### 19.1 Exact read scope

1. `AGENTS.md`
2. accepted R10 task/result/acceptance chain
3. accepted R9-R1 task/result/acceptance chain
4. rejected R9 result only at candidate `b03966d09e91430a31a03eecf5d3b8575602357d` for schema portions preserved by R9-R1
5. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
6. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
7. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
8. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
9. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`, contrast only
10. `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`, contrast only

### 19.2 Exact write scope

Modify exactly:

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
2. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

Create exactly:

3. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php`
4. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`

No application adapter, IP-13E, IP-13F, route, controller, Feature test, migration, schema, provider, bootstrap, configuration, Composer manifest, client, or HTTP path is in scope.

### 19.3 Exact targeted test scope

The future task may authorize only:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceFamilyTest.php`

The test must cover reference/SQLite parity for ordinary and sticky-invalidated terminal payloads, exact payload retention/readback, reason and identity rejection, generic-overlay separation, duplicate/revision/incomparable behavior, terminal reopen rejection, RR03 non-regression, and unchanged `sqlite::memory:` two-table behavior.

Any Composer bootstrap, targeted PHPUnit attempt count, and `git diff --check` budget must be fixed by that future task. R10 does not execute or authorize them now.

The R11 task itself is not authored or started here.

## 20. Retained invariants and execution boundary

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- Match != Connection != Conversation != Relationship;
- invalidation != reopen;
- `UNKNOWN != ABSENT` and `DEFERRED != MISSING`;
- no global revision, LWW, arrival-order, timestamp, or storage-order authority;
- no single authoritative Compatibility score;
- no authentication/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing;
- private Conversation is not default ranking/training/ads data.

No Composer, PHPUnit, Artisan, `route:list`, migration, generator, server, HTTP/client command, database runtime probe, provider/network product operation, production action, real/private-data operation, legal research, or Safety Operation ran.

No code, persistence source, adapter, route, controller, test, accepted artifact, or rejected R9 artifact changed. No implementation task or HTTP task was authored or started.

Fresh independent ACCEPT/REJECT review is required.

Final classification:

`IP-13I-R10 REVIEW COMPLETE — DEDICATED CANONICAL MATCH PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — SYNTHETIC INPUT GATE / STICKY INVALIDATION FLOW / RECORD CONSTRUCTION / IP-13E SUBMIT+RETRIEVE / EXACT READBACK / MATERIALIZATION DISPOSITIONS FIXED — IP-13F UNCHANGED/NON-PARTICIPATING — EXACT NEXT IMPLEMENTATION SEQUENCE FIXED — NO IMPLEMENTATION OR HTTP AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
