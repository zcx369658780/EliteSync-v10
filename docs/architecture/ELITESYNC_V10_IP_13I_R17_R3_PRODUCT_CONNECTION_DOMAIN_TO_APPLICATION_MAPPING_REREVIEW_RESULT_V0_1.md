# EliteSync v10｜IP-13I-R17-R3 Product Connection Domain-to-Application Mapping Re-Review Result｜v0.1

Status: `REVIEW COMPLETE — REPAIRED EVALUATOR SUPPORTS SELF-CONTAINED PRODUCT CONNECTION PERSISTENCE/APPLICATION MAPPING — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority, topology and tracked scope

- task-publication authority: `ac8a21645637e06f70389af7d781fee435e896ec`;
- task-publication sole parent: `37e7648b50a1ad7eb47097c636e15966cb20cdd4`;
- task blob: `6bb689c88ed5134096064ee828f0e64c63f8c273`;
- review branch: `review/next-ip-13i-r17-r3-product-connection-domain-to-application-mapping-rereview-v0-1`;
- candidate: `THIS_COMMIT`, fixed by the immutable publication receipt;
- candidate sole parent: `ac8a21645637e06f70389af7d781fee435e896ec`;
- candidate tree and result blob: fixed by the immutable publication receipt;
- tracked scope: exactly this one new result document.

No old R17 result is revived, accepted, modified or integrated. Candidate `6af50b3cdf82ac8bc285bd160f773b48b29f1328` remains rejected.

## 2. Fixed evidence ledger

The exact authorized sources were verified as follows:

- `AGENTS.md`: `c9a8e192f7647a1613a195655fe9c22c56502ddb`;
- R17-R3 task: `6bb689c88ed5134096064ee828f0e64c63f8c273`;
- accepted R17-R2 result: `47caffe068ea377ee3f7c5a94bace3f2bb2141aa`;
- R17-R2 acceptance: `acfedada11c3c6e76b83f9674142168245db9c0f`;
- accepted R17-R1 result: `3918eac68121c6d3a7601ac703e5b1663fe9c054`;
- R17-R1 acceptance: `cb44607f773705c168f15ca093935be1893259b7`;
- old R17 independent rejection: `415ee64eb70894eed21eee97e58762307d6e408f`;
- old rejected R17 result at exact candidate `6af50b3cdf82ac8bc285bd160f773b48b29f1328`: `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`;
- accepted R15-R1 result: `fb064b7e290916ba7aa42d53990c9c54d289f5ba`;
- R15-R1 acceptance: `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`;
- accepted R16-R1 result: `f0da912cb3dcb1525fa36053168310f187cf58cb`;
- R16-R1 acceptance: `96110d9484897012c7946b42a2256951ec8a60fc`;
- retained R16 result at exact rejected ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`: `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`, used only for definitions explicitly retained by R16-R1;
- repaired Product Connection evaluator: `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`;
- Common Authority: `e98e7db731d41269a7b89e01db12e1a81364751d`;
- IP-13A: `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`;
- IP-13D: `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`;
- IP-13E: `aa9721dfa66fe17eb2314bc9466870d479c07644`;
- Canonical Match application adapter, orchestration contrast only: `789e8905b2c9ee54d902d8b600100896af4f6063`;
- Canonical Match adapter Unit test, test-boundary contrast only: `c8298f5e786a47d118b56f47cef6baab7f543b60`.

No source outside this ledger was used.

## 3. Top-level mapping decision

Select Option A:

`DEDICATED_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND_AFTER_ORDER_INVARIANCE_REPAIR`

The repaired evaluator removes old R17-F1: within one evidence identity and comparable source-local namespace it checks the whole set, finds the mathematical maximal revision, and evaluates semantic conflict only among maximal candidates. Complete state and transition results are invariant under permutation. The application mapping therefore consumes one stable evaluator decision; it does not sort, filter, retry or reinterpret evidence to manufacture a preferred result.

R17-F2 is also closed here: this document is a self-contained consolidation of the retained R16 definitions and R16-R1 corrections. A future implementer does not need to infer payload or dependency keys from the rejected R16/R17 documents.

Preserve:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- fact classes `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` and `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A;
- `MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`;
- `GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`.

## 4. Public adapter topology and exact operation envelopes

Use one dedicated adapter with exactly four explicit public operations:

1. `evaluateCurrentSynthetic(array $request): array`;
2. `evaluateTransitionSynthetic(array $request): array`;
3. `invalidateCurrentSynthetic(array $request): array`;
4. `invalidateTransitionSynthetic(array $request): array`.

The method fixes the fact class. There is no generic fact-class discriminator.

`synthetic_dev_test_only` is the envelope marker and must be exactly boolean `true`. Exact top-level keys are:

| Operation | Exact ordered keys |
|---|---|
| current evaluate | `synthetic_dev_test_only`, `connection`, `state_evidence` |
| transition evaluate | `synthetic_dev_test_only`, `connection`, `state_evidence`, `transition_evidence` |
| current invalidate | `synthetic_dev_test_only`, `connection`, `state_evidence`, `dependency_identity`, `relation` |
| transition invalidate | `synthetic_dev_test_only`, `connection`, `state_evidence`, `transition_evidence`, `dependency_identity`, `relation` |

No request accepts a previous evaluator result, typed payload, persisted projection, Match result, authoritative Connection state, request time, authenticated account, session or token. `dependency_identity` is a non-empty string. `relation` is exactly `CORRECTION | REVOCATION | SUPERSESSION`.

## 5. Exact input containers

### 5.1 Connection descriptor

`connection` has exactly:

1. `connection_identity`: non-empty string;
2. `participants`: list of exactly two distinct non-empty strings;
3. `protected_use_scope`: non-empty string.

Participant order has no authority. The evaluator receives the supplied list; persistence correlation uses the two references sorted lexicographically with binary string ordering.

### 5.2 Current-state evidence

Each `state_evidence` list item has exactly:

1. `state_evidence_identity`;
2. `connection_identity`;
3. `participants`;
4. `state`;
5. `required_bindings`;
6. `source_evidence`.

Both identities are non-empty strings, participants form a valid two-party set, and state is exactly one of `CN_NONE | CN_PENDING | CN_ACTIVE | CN_PAUSED | CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`.

### 5.3 Transition evidence

Each `transition_evidence` list item has exactly:

1. `transition_identity`;
2. `connection_identity`;
3. `participants`;
4. `from_state`;
5. `to_state`;
6. `expected_state_revision`;
7. `required_bindings`;
8. `source_evidence`.

Identity fields are non-empty strings, participants form a valid two-party set, from/to values use the eight-state vocabulary, and expected revision has the exact five-field form below.

### 5.4 Bindings, source evidence and revisions

Both `required_bindings` and `source_evidence.bindings` have exactly these eleven ordered keys:

1. `authority_owner`;
2. `authority_scope`;
3. `actor`;
4. `actor_role`;
5. `subject`;
6. `participants`;
7. `audience`;
8. `purpose`;
9. `aggregate_context`;
10. `lifecycle_identity`;
11. `terminal`.

All values except participants and terminal are non-empty strings; participants are a non-empty structurally valid exact set and terminal is boolean.

`source_evidence` has exactly:

1. `record_kind = SOURCE_EVIDENCE`;
2. `bindings`;
3. `source_condition`;
4. `source_revision`;
5. `currentness`;
6. `freshness`;
7. `authoritative_outcome`.

`source_condition` is exactly `PRESENT | ABSENT | UNKNOWN | UNAVAILABLE | STALE | SUPERSEDED | INCOMPARABLE`; currentness and freshness are each `bool|null`; authoritative outcome is `COMMITTED | REJECTED | UNKNOWN`.

Every source revision and `expected_state_revision` has exactly:

1. `authority_owner`: non-empty string;
2. `authority_scope`: non-empty string;
3. `lineage`: non-empty string;
4. `aggregate_context`: non-empty string;
5. `value`: non-negative integer.

For source evidence, revision owner, scope and aggregate context equal its source bindings. There is no timestamp or global revision.

## 6. Strict pre-materialization gate

Validate the exact envelope and every nested candidate before evaluator dispatch. Evidence containers must be lists of arrays; empty lists are structurally valid and preserve missing-evidence domain meaning. Validate exact keys, types, non-empty strings, participant cardinality, lifecycle vocabulary, Common Authority containers, condition/outcome values, nullable booleans and complete non-negative source-local revisions.

Reject before evaluator dispatch under exactly these six diagnostics:

1. `CONNECTION_IDENTITY_REQUIRED`;
2. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`;
3. `PROTECTED_USE_SCOPE_REQUIRED`;
4. `INVALID_EVIDENCE_SHAPE`;
5. `INVALID_CONNECTION_STATE`;
6. `INVALID_TARGET_STATE`.

Do not structurally reject a valid cross-Connection identity, different valid participant set, different evidence identity, incomparable revision namespace, maximal equal-revision semantic conflict, required/source binding mismatch, non-present source condition, false/null currentness or freshness, or transition context mismatch. Those reach the evaluator and retain their accepted bounded domain result.

## 7. Evaluator and invalidation call contract

| Operation | Direct `evaluateCurrent()` | Direct `evaluateTransition()` | Internal current evaluation | `invalidate()` | Retry |
|---|---:|---:|---:|---:|---:|
| current evaluate | 1 | 0 | 0 | 0 | 0 |
| transition evaluate | 0 | 1 | 1 | 0 | 0 |
| current invalidate | 1 fresh | 0 | 0 | 1 | 0 |
| transition invalidate | 0 | 1 fresh | 1 | 1 | 0 |

Transition operations never call `evaluateCurrent()` externally. Pass `null` for the unused Match argument. Validate the evaluator result's fact class, classification, exact reason vocabulary, descriptor correlation, dependency vector and fixed false non-authority fields. A gate/output/recovery/matrix failure submits nothing.

For invalidation, build and validate the fresh pre-invalidation result first. The requested identity must match exactly one retained typed dependency. Call `invalidate()` once and require `UNKNOWN / [DEPENDENCY_INVALIDATED]`, unchanged dependency/state/context, false downstream-active and protected-use validity, and false lifecycle reset/reopen.

Duplicate resolution is already order invariant in the evaluator. The application must not sort or filter evidence to change its semantics and must not perform a second evaluator call.

## 8. Selected-evidence recovery

Recovery operates only after the repaired evaluator retains a dependency. It restores persistence metadata omitted from the privacy-minimal public dependency vector; it does not resolve duplicates again.

For a current dependency, collect every supplied state item matching exactly:

- `state_evidence_identity`;
- Connection identity;
- state;
- all five own source-revision fields;
- source condition.

There must be at least one match. Derive `[protected_binding_satisfied, currentness, freshness]` for every match and require all tuples to be identical. Otherwise fail closed before record construction.

For a transition dependency, collect every supplied transition item matching exactly:

- transition identity;
- Connection identity;
- from state;
- to state;
- all five own source-revision fields;
- source condition.

Require at least one match and equality across all matches of:

- exact five-field `expected_state_revision`;
- `protected_binding_satisfied`;
- currentness;
- freshness.

Conflicting maximal semantic candidates are already rejected by the evaluator; lower dominated candidates do not match the selected maximal revision. These checks close persistence recovery without introducing representative-index or arrival-order authority.

## 9. Exact protected-binding computation

Compute the boolean from the recovered original item; never accept it from the caller.

For both fact types require:

1. exact PHP-array equality of each of the eleven required-binding fields with the corresponding source-evidence binding field;
2. required subject = Connection identity;
3. required aggregate context = Connection identity;
4. required lifecycle identity = Connection identity;
5. required participant set = Connection participant set;
6. required purpose = Connection protected-use scope.

For current-state evidence also require required terminal to equal whether its evidence state is `CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`.

Set `protected_binding_satisfied=true` only if every applicable check passes. Source condition, currentness and freshness are excluded and persisted separately. This boolean is not source authority, permission, authentication or a bearer capability.

## 10. Exact typed dependencies

Current-state dependency has exactly these 13 ordered keys:

1. `dependency_type = CURRENT_STATE_EVIDENCE`;
2. `state_evidence_identity`;
3. `connection_identity`;
4. `state`;
5. `authority_owner`;
6. `authority_scope`;
7. `aggregate_context`;
8. `source_lineage`;
9. `source_revision_value`;
10. `source_condition`;
11. `protected_binding_satisfied`;
12. `currentness`;
13. `freshness`.

Transition dependency has exactly these 15 ordered keys:

1. `dependency_type = TRANSITION_EVIDENCE`;
2. `transition_identity`;
3. `connection_identity`;
4. `from_state`;
5. `to_state`;
6. `expected_state_revision` with all five exact fields;
7. `authority_owner`;
8. `authority_scope`;
9. `aggregate_context`;
10. `source_lineage`;
11. `source_revision_value`;
12. `source_condition`;
13. `protected_binding_satisfied`;
14. `currentness`;
15. `freshness`.

Own source revisions decompose exactly into owner, scope, aggregate context, lineage and value. If both dependency types exist, their opaque identities must differ. A dependency is fully usable iff binding satisfied is true, condition is `PRESENT`, currentness is true and freshness is true.

## 11. Exact typed payloads and reason vocabularies

### 11.1 Current-state payload

Payload kind: `PRODUCT_CONNECTION_CURRENT_STATE`. Exact 13 ordered keys:

1. `payload_kind`;
2. `derived_fact_class`;
3. `connection_identity`;
4. `participant_references`;
5. `protected_use_scope`;
6. `classification`;
7. `current_state`;
8. `reason_categories`;
9. `current_state_dependency`;
10. `connection_active_for_downstream_consideration`;
11. `valid_for_protected_use`;
12. `terminality`;
13. `invalidation`.

`derived_fact_class = PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`. Classification is one of the eight states or `UNKNOWN`. `terminality` has exactly `current_state_terminal`. The exact ordered eight-reason vocabulary is:

1. `MISSING_CURRENT_STATE_EVIDENCE`;
2. `CROSS_CONNECTION_STATE_EVIDENCE`;
3. `STATE_PARTICIPANT_MISMATCH`;
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`;
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`;
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`;
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
8. `DEPENDENCY_INVALIDATED`.

### 11.2 Transition payload

Payload kind: `PRODUCT_CONNECTION_TRANSITION`. Exact 15 ordered keys:

1. `payload_kind`;
2. `derived_fact_class`;
3. `connection_identity`;
4. `participant_references`;
5. `protected_use_scope`;
6. `classification`;
7. `current_state`;
8. `proposed_state`;
9. `reason_categories`;
10. `current_state_dependency`;
11. `transition_dependency`;
12. `connection_active_for_downstream_consideration`;
13. `valid_for_protected_use`;
14. `terminality`;
15. `invalidation`.

`derived_fact_class = PRODUCT_CONNECTION_TRANSITION_DERIVATION`; classification is `ADMISSIBLE | REJECTED | UNKNOWN`. `terminality` has exactly `current_state_terminal`, `proposed_state_terminal`, `terminal_reopen_rejected`. Expected state revision appears only inside the transition dependency.

The exact ordered nineteen-reason vocabulary is:

1. `MISSING_CURRENT_STATE_EVIDENCE`;
2. `CROSS_CONNECTION_STATE_EVIDENCE`;
3. `STATE_PARTICIPANT_MISMATCH`;
4. `CONFLICTING_STATE_EVIDENCE_IDENTITY`;
5. `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE`;
6. `CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`;
7. `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`;
8. `MISSING_TRANSITION_EVIDENCE`;
9. `CROSS_CONNECTION_TRANSITION_EVIDENCE`;
10. `TRANSITION_PARTICIPANT_MISMATCH`;
11. `CONFLICTING_TRANSITION_IDENTITY`;
12. `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE`;
13. `CONFLICTING_EQUAL_REVISION_TRANSITION_EVIDENCE`;
14. `TRANSITION_NOT_CURRENT_FRESH_BOUND`;
15. `TRANSITION_CURRENT_CONTEXT_MISMATCH`;
16. `TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`;
17. `DIRECT_NONE_TO_ACTIVE_REJECTED`;
18. `TRANSITION_NOT_ALLOWED`;
19. `DEPENDENCY_INVALIDATED`.

Reason lists are unique and canonical. The six structural diagnostics are never persisted.

### 11.3 Invalidation object

Both payloads use exactly:

1. `invalidated`;
2. `relation`;
3. `dependency_identity`;
4. `lifecycle_reset`;
5. `connection_reopened`.

Ordinary facts use `false, null, null, false, false`. Invalidated facts use true, the requested relation and exact retained dependency identity, while lifecycle reset and reopen remain false.

## 12. Complete cross-field and invalidation matrix

### 12.1 Current facts

- Known `CN_*`: empty reasons; `current_state=classification`; one fully usable current dependency with matching Connection/state; aggregate currentness/freshness `true/true`; protected-use valid; downstream-active only for `CN_ACTIVE`; current-state terminality matches the four terminal states.
- `UNKNOWN` for the first six current reasons: no dependency, null current state, `null/null` aggregate, false downstream/protected-use/terminal.
- `UNKNOWN / CURRENT_STATE_NOT_CURRENT_FRESH_BOUND`: one dependency; null current state; at least one usability predicate false; aggregate copies dependency currentness/freshness.
- Invalidated current: only a pre-result retaining a dependency is eligible; preserve dependency, pre-invalidation current state, aggregate and terminality; classification becomes `UNKNOWN`; reason is only `DEPENDENCY_INVALIDATED`; downstream/protected-use false.

### 12.2 Transition facts

- Propagated current-state `UNKNOWN`: proposed state and transition dependency null. First six current reasons have no dependencies and `null/null`; `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` retains only its current dependency and uses incomplete-vector aggregation.
- Transition resolution-failure `UNKNOWN` for reasons 8–13: known current state plus fully usable current dependency; no transition dependency or proposed state; aggregate `null/null`; downstream-active follows current state.
- `TRANSITION_NOT_CURRENT_FRESH_BOUND`: both dependencies; current usable, transition fails at least one usability predicate; proposed state equals transition `to_state`; complete-vector aggregation applies.
- `TRANSITION_CURRENT_CONTEXT_MISMATCH`: both dependencies fully usable; actual mismatch in from/current or exact five-field expected/current revision; aggregate `true/true`.
- `ADMISSIBLE`: both dependencies fully usable and distinct; exact current/from, proposed/to and expected-current revision equality; non-terminal current state; pair is exactly one of `NONE->PENDING`, `PENDING->ACTIVE|DECLINED|WITHDRAWN|EXPIRED`, `ACTIVE->PAUSED|CLOSED`, `PAUSED->ACTIVE|CLOSED`; empty reasons; protected-use valid.
- `REJECTED`: both dependencies fully usable with exact context. Terminal reason requires terminal current; direct-none reason requires `NONE->ACTIVE`; general not-allowed requires a non-terminal pair outside the nine allowed pairs and not direct none-active. Protected-use invalid.
- Invalidated transition: legal only when the fresh pre-result retains at least one dependency; preserve exact dependency set, states, aggregate and terminal descriptors; classification becomes `UNKNOWN`, reason only `DEPENDENCY_INVALIDATED`, downstream/protected-use false.

For each currentness and freshness dimension independently: current fact mirrors its dependency or null; transition yields null with no current dependency, false for current=false plus absent transition, null for current true/null plus absent transition, false if either present dependency is false, true if both are true, otherwise null.

## 13. Binding Model A and deterministic record construction

Record family is `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`.

Exact derived bindings:

- authority owner and actor: `PRODUCT_CONNECTION_DERIVATION`;
- current scope: `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION|{protected_use_scope}`;
- transition scope: `PRODUCT_CONNECTION_TRANSITION_DERIVATION|{protected_use_scope}`;
- actor role: `DERIVED_NON_AUTHORITATIVE_CORRELATION`;
- subject and aggregate context: Connection identity;
- participants: canonical binary-string-sorted two-party list;
- audience: `INTERNAL_APPLICATION_PERSISTENCE`;
- purpose: protected-use scope;
- lifecycle identity: deterministic value below;
- terminal: terminality of retained current state only.

Lifecycle basis has exactly family, derived authority owner, actor, actor role, Connection identity, protected-use scope, subject, canonical participants, audience, purpose and aggregate context. Lifecycle identity is `product-connection-lifecycle-v1:` plus the SHA-256 digest of its canonical serialized basis. Fact class, classification, dependency revision, invalidation, arrival order and time do not enter it.

Schema marker is `product-connection-current-state-derived-projection-v1` or `product-connection-transition-derived-projection-v1`.

Semantic input has exactly:

1. `record_family`;
2. `derived_fact_class`;
3. normalized exact `bindings`;
4. exact typed `derived_projection_payload`;
5. `schema_marker`.

Recursively sort associative keys, preserve contract list order after participant/reason canonicalization, serialize and SHA-256 hash. The same digest forms:

- record identity `product-connection-record-v1:{digest}`;
- intent identity `product-connection-intent-v1:{digest}`;
- lineage `product-connection-lineage-v1:{digest}`;
- projection identity `product-connection-projection-v1:{digest}`.

The logical record has exactly:

1. `logical_record_identity`;
2. `record_family`;
3. `bindings`;
4. `source_revision`;
5. `source_condition`;
6. `currentness`;
7. `freshness`;
8. `logical_intent`;
9. `authoritative_outcome`;
10. `authoritative_outcome_metadata`;
11. `correction_metadata`;
12. `projection_metadata`;
13. `transport_observation`;
14. `private_fixture_extensions`;
15. `derived_projection_payload`.

Fix source condition `PRESENT`; derived revision owner/scope/context equal bindings, lineage is the deterministic lineage and value is `0`; top-level currentness/freshness use the accepted aggregate; logical intent has exact `intent_identity` and the canonical semantic input; authoritative outcome is `UNKNOWN`; authoritative outcome metadata and correction metadata are null; projection metadata has exact projection identity, represented revision `0`, projection currentness equal top-level currentness, and lag `CURRENT | LAGGED | UNKNOWN`; transport observation is `AMBIGUOUS`; private extensions are `[]`.

No random, time, request-order, runtime-account, auth or transport identity enters any digest.

## 14. IP-13E disposition and exact submit/readback

Decision:

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

For every successful application construction:

1. build and validate the exact record;
2. call `submitAuthoritativeMutation()` exactly once;
3. inspect `persistence.storage_outcome`;
4. call `retrieveCurrentProjection()` exactly once only for `STORED_NEW`, `EXACT_DUPLICATE` or `INCOMPARABLE_COEXISTS`;
5. skip retrieval for all other dispositions;
6. never retry.

The exact query has only:

- `record_family` = Product Connection family;
- `authority_owner = PRODUCT_CONNECTION_DERIVATION`;
- fact-specific authority scope;
- `aggregate_context` = Connection identity;
- `lineage` = exact constructed lineage.

Request bindings have only:

- viewer `PRODUCT_CONNECTION_DERIVATION`;
- subject = Connection identity;
- canonical participants;
- audience `INTERNAL_APPLICATION_PERSISTENCE`;
- purpose = protected-use scope;
- aggregate context = Connection identity.

Exact readback requires application resolution `RESOLVED`, binding `EXACT`, an array projection, exact family/owner/fact scope, generic invalidation false, and equality of record, intent, lifecycle, lineage and projection identities. It also requires represented revision `0`, exact subject/participants/audience/purpose/context, terminal marker, top-level currentness/freshness, projection currentness/lag, and direct canonical PHP-array equality of the typed payload. Digest equality alone is insufficient.

The method name `submitAuthoritativeMutation()` does not turn the derived record into authoritative Connection state. Submission keeps authoritative outcome `UNKNOWN` and reconciliation required.

## 15. Materialization and protected-use validity

Condition vocabulary is exactly:

1. `EXACT_PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_MATERIALIZED_USABLE`;
2. `EXACT_PRODUCT_CONNECTION_TRANSITION_PROJECTION_MATERIALIZED_USABLE`;
3. `PRODUCT_CONNECTION_CURRENT_STATE_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`;
4. `PRODUCT_CONNECTION_TRANSITION_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`;
5. `EXACT_PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_MATERIALIZED_DOMAIN_UNUSABLE`;
6. `EXACT_PRODUCT_CONNECTION_TRANSITION_PROJECTION_MATERIALIZED_DOMAIN_UNUSABLE`;
7. `STORAGE_REJECTED_RETRIEVAL_SKIPPED`;
8. `PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`;
9. `PRODUCT_CONNECTION_TRANSITION_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`.

Priority is non-retrievable storage, exact dependency-invalidated readback, exact usable readback, exact non-invalidated domain-unusable readback, then unusable/missing/mismatched/generic-invalidated readback.

Current projection is usable only when readback is exact, generic projection is not invalidated, payload dependency invalidation is false, classification is a known `CN_*`, and payload protected-use validity is true. Transition projection is usable only when the same readback/invalidation requirements hold, classification is `ADMISSIBLE`, and protected-use validity is true.

Current `UNKNOWN`, transition `UNKNOWN` and transition `REJECTED` remain unusable even when stored and read exactly. Generic projection invalidation makes readback unusable without mutating Product Connection dependency invalidation or evaluator classification.

## 16. Duplicate, incomparable and terminal behavior

- Exact repeated input derives the same record/intent/lineage/projection identities: first accepted storage is `STORED_NEW`, repetition `EXACT_DUPLICATE`, both followed by exact-lineage readback.
- A higher comparable source revision is selected by the evaluator regardless of order. Lower equal-revision conflicts dominated by that higher maximal revision do not poison selection. Changed selected semantics derive a different deterministic lineage; the older derived record remains history and storage may return `INCOMPARABLE_COEXISTS` at the derived-correlation layer.
- Conflicting maximal equal-revision signatures yield the existing bounded state/transition conflict reason and no dependency of that fact type.
- Namespace mismatch yields the existing incomparable reason. No candidate is selected by order.
- Changed semantic input derives a distinct intent. Reuse of an identity with changed input is rejected and retrieval skipped.
- Current and transition facts share one lifecycle identity but use different fact scopes, schema markers and lineages.
- Once a terminal-current record exists, a later non-terminal record for that lifecycle is rejected as `TERMINAL_IDENTITY_REOPEN_REJECTED`; retrieval is skipped.
- A transition evaluated from terminal current state is generically terminal and domain `REJECTED / TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`; it cannot reopen the lifecycle.
- An admissible proposed-terminal transition from non-terminal current state has descriptive proposed terminality but generic terminal remains false.
- Repeating identical dependency invalidation freshly reconstructs the same pre-result and deterministic invalidated record, producing `EXACT_DUPLICATE`.

No arrival order, LWW, proposed-state authority or synthesized Connection mutation exists.

## 17. Exact adapter result and privacy exclusions

Return exactly these 52 ordered keys:

1. `record_kind = PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_RESULT`;
2. `operation`;
3. `fact_class`;
4. `classification`;
5. `reason_categories`;
6. `product_connection_payload`;
7. `logical_record_identity`;
8. `logical_intent_identity`;
9. `lifecycle_identity`;
10. `source_projection_lineage`;
11. `derived_correlation_revision`;
12. `storage_disposition`;
13. `projection_read_disposition`;
14. `binding_classification`;
15. `materialized_projection_usable`;
16. `authoritative_outcome`;
17. `reconciliation_required`;
18. `invalidation_required`;
19. `revalidation_required`;
20. `condition`;
21. `synthetic_dev_test_only`;
22. `source_local_revision_only`;
23. `global_revision`;
24. `last_write_wins`;
25. `last_received_wins`;
26. `transport_disposition`;
27. `http_status`;
28. `source_authority`;
29. `domain_writer_authority`;
30. `authoritative_mutation_success`;
31. `permission`;
32. `permission_token`;
33. `bearer_capability`;
34. `transport_execution_authority`;
35. `production_ready`;
36. `deployable`;
37. `real_data_authorized`;
38. `readiness_authority`;
39. `match_authority`;
40. `connection_authority`;
41. `consent_authority`;
42. `conversation_authority`;
43. `relationship_authority`;
44. `home_action_authority`;
45. `notification_delivery_authority`;
46. `launch_authority`;
47. `connection_created`;
48. `connection_activated`;
49. `match_substituted_for_connection`;
50. `messaging_consent_granted`;
51. `conversation_granted`;
52. `source_evidence_mutated`.

Operation is exactly `EVALUATE_CURRENT_STATE | EVALUATE_TRANSITION | INVALIDATE_CURRENT_STATE_DEPENDENCY | INVALIDATE_TRANSITION_DEPENDENCY`. Fact class matches the typed payload. Read disposition and binding classification are null when retrieval is skipped. `invalidation_required` equals payload dependency invalidation; `revalidation_required = !materialized_projection_usable`. `synthetic_dev_test_only` and `source_local_revision_only` are true. Fields 23–25 and 28–52 are fixed false; transport disposition and HTTP status are null. Authoritative outcome remains `UNKNOWN`; reconciliation remains required.

Exclude raw source evidence, raw required/source bindings, unselected candidates, Match result/dependency, credentials/session/token, private Conversation or message content, provider payloads, ranking, Compatibility totals, desirability and person-worth material. No HTTP contract is created.

## 18. Persistence/application packaging decision

Select Package A:

`PERSISTENCE_FIRST_WITHIN_SINGLE_SEQUENTIAL_COMBINED_IMPLEMENTATION_TASK`

Reasoning:

1. Current IP-13A rejects a Product Connection typed derived family and current IP-13D strips its payload; persistence must therefore be implemented first.
2. The accepted R15-R1/R16-R1/R17-R1/R17-R2 contracts and this self-contained mapping fully fix every architecture decision needed by both phases.
3. The application adapter can consume the just-implemented additive family without a new public contract or schema decision.
4. A hard test gate between phases prevents application work from masking persistence defects.
5. One complete candidate lets one independent reviewer verify IP-13A/IP-13D parity, adapter orchestration and shared regressions together without weakening persistence-first order.

The future combined task must have two sequential hard phases:

### Phase A — persistence

- add Product Connection family constants, exact validators and payload retention to IP-13A;
- mirror them in IP-13D without physical schema change;
- exempt Product Connection payload from generic invalidation rewrite while preserving generic overlay state;
- add Product Connection persistence-family tests;
- run the task-bound exact persistence tests and required existing-family regressions;
- begin Phase B only if every Phase A command passes.

### Phase B — application

- add the dedicated four-operation Product Connection adapter;
- add exact adapter tests;
- run the task-bound adapter and shared persistence/application regressions;
- create one combined result and publish one combined candidate for one fresh independent ACCEPT/REJECT.

Package A changes task granularity only. It does not allow parallel phases, bypass Phase A tests, self-acceptance, HTTP, production or downstream work.

## 19. Future validation contract

The successor task must bind exact paths and commands. Its scope must cover:

Persistence:

- Product Connection family validator in both IP-13A and IP-13D;
- both exact typed payload classes and exact 8/19 reason vocabularies;
- 13/15-key dependency validation including binding boolean;
- expected-state revision and context matrices;
- currentness/freshness aggregation and dependency presence;
- deterministic lifecycle/record/intent/lineage/projection identities;
- direct payload retention and generic-overlay exemption;
- exact duplicate, changed-input, incomparable and terminal no-reopen behavior;
- invalidation retention;
- IP-13A/IP-13D parity;
- existing RR03 and Canonical Match regressions wherever shared code changes.

Application:

- all four operations and strict envelope/nested gates;
- exact evaluator and invalidation call counts;
- all state/transition permutation-relevant recovery cases;
- protected-binding computation;
- full R16-R1 matrix enforcement;
- one submit and conditional retrieve;
- exact query/bindings and direct typed-payload readback equality;
- current/transition invalidation flows and repeated invalidation;
- UNKNOWN/REJECTED exact-but-unusable behavior;
- generic invalidation readback unusability;
- duplicate/incomparable/maximal/terminal behavior;
- no raw evidence leakage;
- exact result shape and fixed false non-authority fields.

No exact command is invented here because future test files are outside this review's fixed read set.

## 20. IP-13F, downstream and exact successor

IP-13F disposition:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

No sixth family, Product Connection HTTP endpoint or transport surface is added. Messaging Consent / Conversation remains blocked until the combined Product Connection persistence/application candidate is independently accepted.

The single exact successor task family is:

`IP-13I-R18 PRODUCT CONNECTION PERSISTENCE-FIRST COMBINED PERSISTENCE + APPLICATION IMPLEMENTATION TASK`

This branch does not author R18.

## 21. Execution receipt and independent review gate

- exactly one R17-R3 result document was created;
- no existing document, code, test, persistence, application, route/controller, HTTP, client or config file changed;
- no PHP, PHPUnit, Composer, Artisan, server/HTTP, database, migration/generator, Flutter/Dart/Gradle/Android, dependency resolution/download, product-network, production or real/private-data command ran;
- no implementation, R18, Messaging/Conversation, self-acceptance, merge or main movement occurred.

A fresh independent reviewer must bind this immutable candidate, its sole parent, tree, result blob and unique changed path, then issue one ACCEPT/REJECT before any R18 task may be authored.

## 22. Final classification

`IP-13I-R17-R3 REVIEW COMPLETE — REPAIRED ORDER-INVARIANT EVALUATOR SUPPORTS DEDICATED PRODUCT CONNECTION PERSISTENCE/APPLICATION MAPPING — SELF-CONTAINED IMPLEMENTATION CONTRACT FIXED — EXACT RECOVERY/BINDING/PAYLOAD/RECORD/SUBMIT/READBACK/USABILITY RULES FIXED — PERSISTENCE-FIRST SINGLE SEQUENTIAL COMBINED IMPLEMENTATION PACKAGING DECIDED — IP-13F UNCHANGED/NON-PARTICIPATING — NO HTTP OR DOWNSTREAM AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
