# EliteSync v10｜IP-13I-R17 Product Connection Domain-to-Application Mapping Review Result｜v0.1

Status: `REVIEW COMPLETE — DEDICATED PRODUCT CONNECTION PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — DOCUMENT ONLY — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Publication authority and scope

- fresh `origin/main`: `b0196202c78f688723600ac9919cf96463908375`
- authority sole parent: `9d489bbb9883a829282525f2a71d373d33bd33f2`
- authority tree: `88340728f35d9b20794f14acf9ddbd567e8a93af`
- review branch: `review/next-ip-13i-r17-product-connection-domain-to-application-mapping-v0-1`
- tracked scope: exactly this one added result document
- candidate commit / sole parent / tree: established by the immutable Git publication receipt; the candidate must have the fresh authority commit above as its sole parent.

## 2. Fixed evidence ledger

Directly read and verified:

- `AGENTS.md`: `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R17 task: `68d18d4100ba24b493fd2b5ee9388f564aca9100`
- accepted R16-R1 result: `f0da912cb3dcb1525fa36053168310f187cf58cb`
- R16-R1 acceptance: `96110d9484897012c7946b42a2256951ec8a60fc`
- rejected R16 result, retained sections only, at exact rejected candidate `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`: `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`
- accepted R15-R1 result: `fb064b7e290916ba7aa42d53990c9c54d289f5ba`
- R15-R1 acceptance: `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`
- Product Connection evaluator: `35a889ee5460e5c374a5a99bd93bebae49718c5b`
- Common Authority: `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A: `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`
- IP-13D: `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`
- IP-13E: `aa9721dfa66fe17eb2314bc9466870d479c07644`
- accepted Canonical Match application adapter, orchestration contrast only: `789e8905b2c9ee54d902d8b600100896af4f6063`
- accepted Canonical Match adapter Unit test, test-boundary contrast only: `c8298f5e786a47d118b56f47cef6baab7f543b60`

No source outside the task-authorized read scope was used.

## 3. Top-level mapping decision

Option A is supported:

`DEDICATED_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND`

The accepted evaluator can be mapped truthfully into the accepted Product Connection typed record contract. The mapping needs no evaluator, R16-R1 or IP-13E contract repair. It requires the accepted Product Connection family to be implemented in IP-13A and IP-13D before the adapter is implemented and tested against exact readback.

The adapter is synthetic/dev-test-only orchestration. It does not establish authoritative Connection state or perform a state transition.

## 4. Public operation topology

Select Model A: four explicit public operations on one dedicated future adapter:

1. `evaluateCurrentSynthetic(array $request): array`
2. `evaluateTransitionSynthetic(array $request): array`
3. `invalidateCurrentSynthetic(array $request): array`
4. `invalidateTransitionSynthetic(array $request): array`

The explicit method name fixes the fact class. No caller-supplied fact-class discriminator or generic dispatch envelope is needed.

Exact operation-envelope key sets:

| Operation | Exact keys |
|---|---|
| current evaluation | `synthetic_dev_test_only`, `connection`, `state_evidence` |
| transition evaluation | `synthetic_dev_test_only`, `connection`, `state_evidence`, `transition_evidence` |
| current invalidation | `synthetic_dev_test_only`, `connection`, `state_evidence`, `dependency_identity`, `relation` |
| transition invalidation | `synthetic_dev_test_only`, `connection`, `state_evidence`, `transition_evidence`, `dependency_identity`, `relation` |

`synthetic_dev_test_only` must be exactly boolean `true` and belongs only to the operation envelope. It does not enter the Connection descriptor, evaluator input, payload, identity digest or source authority.

No operation accepts a prior evaluator result, prior payload, persisted projection, Match result, or caller-asserted authoritative current Connection state.

## 5. Exact synthetic input model

### 5.1 Connection descriptor

`connection` has exactly:

1. `connection_identity`: non-empty string;
2. `participants`: list of exactly two distinct non-empty strings;
3. `protected_use_scope`: non-empty string.

Participant order is not authority. The descriptor is passed to the evaluator as supplied; record construction uses the canonical binary-string-sorted participant list.

### 5.2 Current-state evidence item

Each `state_evidence` list item has exactly:

1. `state_evidence_identity`
2. `connection_identity`
3. `participants`
4. `state`
5. `required_bindings`
6. `source_evidence`

Identity fields are non-empty strings; participants are exactly two distinct non-empty strings; state is one of the accepted eight `CN_*` literals.

### 5.3 Transition evidence item

Each `transition_evidence` list item has exactly:

1. `transition_identity`
2. `connection_identity`
3. `participants`
4. `from_state`
5. `to_state`
6. `expected_state_revision`
7. `required_bindings`
8. `source_evidence`

Identity fields are non-empty strings; participants are exactly two distinct non-empty strings; from/to states are accepted `CN_*` literals. `expected_state_revision` is the exact five-field source revision in Section 5.5.

### 5.4 Common Authority bindings and source evidence

Each `required_bindings` and `source_evidence.bindings` object has exactly:

1. `authority_owner`
2. `authority_scope`
3. `actor`
4. `actor_role`
5. `subject`
6. `participants`
7. `audience`
8. `purpose`
9. `aggregate_context`
10. `lifecycle_identity`
11. `terminal`

All fields except participants and terminal are non-empty strings. Participants are a structurally valid two-party set. Terminal is boolean. Required/source binding mismatch is structurally valid and remains evaluator semantics.

`source_evidence` has exactly:

1. `record_kind = SOURCE_EVIDENCE`
2. `bindings`
3. `source_condition`
4. `source_revision`
5. `currentness`
6. `freshness`
7. `authoritative_outcome`

Source condition is one Common Authority condition; currentness/freshness are each `bool|null`; authoritative outcome is `COMMITTED | REJECTED | UNKNOWN`. The source revision owner, scope and aggregate context equal the corresponding source-evidence binding fields. This is structural consistency, not equality with the requested Connection descriptor.

### 5.5 Source revision

Every source revision and transition `expected_state_revision` has exactly:

1. `authority_owner`: non-empty string
2. `authority_scope`: non-empty string
3. `lineage`: non-empty string
4. `aggregate_context`: non-empty string
5. `value`: non-negative integer

There is no timestamp or global revision.

## 6. Strict structural gate

Before any evaluator call, validate the exact operation envelope and every nested item, including every candidate in both evidence lists. The lists must be actual lists of arrays; empty lists are structurally valid and retain missing-evidence domain meaning.

Reject before dispatch under the six accepted pre-materialization categories:

1. `CONNECTION_IDENTITY_REQUIRED`
2. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
3. `PROTECTED_USE_SCOPE_REQUIRED`
4. `INVALID_EVIDENCE_SHAPE`
5. `INVALID_CONNECTION_STATE`
6. `INVALID_TARGET_STATE`

The gate validates exact key sets, types, non-empty identifiers, two-party structural sets, lifecycle vocabularies, Common Authority containers, nullable booleans, conditions/outcomes, and complete source-local revisions.

It does not reject structurally valid:

- cross-Connection evidence;
- participant-set mismatch;
- different evidence identities in one resolution set;
- incomparable source revisions;
- equal-revision semantic conflicts;
- required/source or descriptor binding mismatch;
- non-present source condition;
- false/null currentness or freshness;
- transition from-state or expected-revision context mismatch.

Those inputs reach the evaluator. The accepted domain `UNKNOWN` or `REJECTED` result is not converted to an application input error.

Invalidation additionally requires a non-empty `dependency_identity` and relation exactly `CORRECTION | REVOCATION | SUPERSESSION` before evaluator reconstruction. No caller supplies `protected_binding_satisfied`; the adapter derives it.

## 7. Evaluator flows and exact call counts

### 7.1 Current-state evaluation

1. Apply the strict gate.
2. Call `ProductConnectionStateTransitionEvaluator::evaluateCurrent()` exactly once.
3. Validate exact output fact class, classification/reason vocabulary, dependency vector, descriptor correlation and all non-authority fields.
4. Reject any pre-materialization diagnostic that escaped the gate.
5. If a dependency is retained, recover the selected source evidence under Section 8.
6. Compute `protected_binding_satisfied` under Section 9.
7. Construct the exact typed dependency, payload and logical record.
8. Enforce the accepted R16-R1 matrix.
9. Submit through IP-13E exactly once, conditionally retrieve once, verify exact readback and return the bounded result.

No second evaluator call and no retry.

### 7.2 Transition evaluation

1. Apply the strict gate to the descriptor and every state/transition evidence item.
2. Call `ProductConnectionStateTransitionEvaluator::evaluateTransition($connection, $stateEvidence, $transitionEvidence, null)` exactly once.
3. Do not call `evaluateCurrent()` directly. `evaluateTransition()` performs its one current-state evaluation internally.
4. Validate evaluator output and reject any escaped pre-materialization diagnostic.
5. Recover each retained dependency independently.
6. Compute each retained dependency's `protected_binding_satisfied` independently.
7. Construct dependencies and enforce the full R16-R1 presence/cross-field matrix.
8. Construct the exact payload and record, submit once, conditionally retrieve once, verify readback and return.

### 7.3 Call-count table

| Operation | Direct `evaluateCurrent()` | Direct `evaluateTransition()` | Evaluator-internal current evaluation | `invalidate()` | IP-13E submit | IP-13E retrieve |
|---|---:|---:|---:|---:|---:|---:|
| current evaluate | 1 | 0 | 0 | 0 | 1 | 0 or 1 |
| transition evaluate | 0 | 1 | 1 | 0 | 1 | 0 or 1 |
| current invalidate | 1 | 0 | 0 | 1 | 1 | 0 or 1 |
| transition invalidate | 0 | 1 | 1 | 1 | 1 | 0 or 1 |

A gate, evaluator-output, selected-recovery or cross-field failure performs no submit. A non-retrievable storage disposition performs no retrieve. No operation retries any call.

## 8. Source-order-independent selected-evidence recovery

Never select a supplied candidate by array index or arrival order.

### 8.1 Current dependency

For a retained evaluator current dependency, collect every supplied state-evidence item whose following fields equal the dependency exactly:

- `state_evidence_identity`;
- `connection_identity`;
- `state`;
- full five-field `source_evidence.source_revision`;
- `source_evidence.source_condition`.

There must be at least one match. For every match derive the tuple:

`[protected_binding_satisfied, currentness, freshness]`.

All matching candidates must produce the identical tuple. Otherwise fail closed before record construction. Use the common tuple, never the first match.

### 8.2 Transition dependency

For a retained evaluator transition dependency, collect every supplied transition-evidence item matching exactly:

- `transition_identity`;
- `connection_identity`;
- `from_state`;
- `to_state`;
- full five-field own `source_evidence.source_revision`;
- `source_evidence.source_condition`.

The exact full `expected_state_revision` is recoverable semantic metadata. All public-vector matches must have an identical expected-state revision and identical:

`[protected_binding_satisfied, currentness, freshness]`.

If either the expected revision or the three-field metadata differs, fail closed. The common expected revision is placed into the typed transition dependency.

This is consistent with evaluator duplicate resolution: candidates at the same selected identity and exact revision with different required bindings, source evidence or expected revision have different semantic signatures and produce the evaluator's equal-revision conflict instead of a retained dependency. Higher comparable revision selection fixes the selected revision independent of source order. The adapter still rechecks the common privacy-minimal metadata and never turns duplicate arrival order into authority.

## 9. Exact `protected_binding_satisfied` computation

Compute this boolean from each recovered original evidence item. It is never trusted from caller input.

First require exact equality, with PHP-array semantics, between every one of the eleven `required_bindings` fields and the corresponding `source_evidence.bindings` field.

For current-state evidence also require:

- required subject = Connection identity;
- required aggregate context = Connection identity;
- required lifecycle identity = Connection identity;
- required participant set equals the Connection participant set;
- required purpose = Connection protected-use scope;
- required terminal equals whether the evidence state is one of `CN_CLOSED | CN_DECLINED | CN_WITHDRAWN | CN_EXPIRED`.

For transition evidence also require:

- required subject = Connection identity;
- required aggregate context = Connection identity;
- required lifecycle identity = Connection identity;
- required participant set equals the Connection participant set;
- required purpose = Connection protected-use scope.

Set `protected_binding_satisfied = true` only when all applicable checks pass. Source condition, currentness and freshness are excluded from this boolean and copied separately into the typed dependency.

## 10. Typed dependency and payload construction

### 10.1 Current dependency

Map the evaluator dependency plus recovered metadata to the accepted 13-key current-state dependency:

- fixed `dependency_type = CURRENT_STATE_EVIDENCE`;
- identity, Connection identity and state from the evaluator dependency;
- `authority_owner`, `authority_scope`, `aggregate_context`, `source_lineage`, `source_revision_value` from its exact source-revision tuple;
- exact source condition;
- derived `protected_binding_satisfied`;
- recovered currentness/freshness.

### 10.2 Transition dependency

Map to the accepted 15-key transition dependency:

- fixed `dependency_type = TRANSITION_EVIDENCE`;
- identity, Connection identity, from/to states from the evaluator dependency;
- recovered full `expected_state_revision`;
- own revision fields decomposed exactly as for current dependency;
- exact source condition;
- independently derived binding boolean and recovered currentness/freshness.

When both dependencies exist, their opaque identities must be distinct.

### 10.3 Current-state payload

Construct the accepted exact 13-key `PRODUCT_CONNECTION_CURRENT_STATE` payload in its accepted order. Map evaluator classification, current state, canonical reason list, downstream-active and valid-for-protected-use directly after validating them against R16-R1. Use canonical participants and request protected-use scope. Use the constructed current dependency or null. Compute current-state terminality from retained current state. Ordinary evaluation uses the exact non-invalidated object.

### 10.4 Transition payload

Construct the accepted exact 15-key `PRODUCT_CONNECTION_TRANSITION` payload. Retain evaluator current/proposed states and exact reason. Use constructed dependencies or null. Compute:

- `current_state_terminal` only from retained current state;
- `proposed_state_terminal` descriptively from proposed state;
- `terminal_reopen_rejected` exactly when the pre-invalidation evaluator result is `REJECTED / TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN`.

The accepted R16-R1 dependency-presence, context-binding, expected-revision, allowed-transition, reason and aggregate matrix is a mandatory final eligibility check. An evaluator-impossible combination is rejected before submit.

Raw source evidence, raw bindings and unselected candidates never enter either payload.

## 11. Dependency invalidation orchestration

### 11.1 Current fact

1. Strictly gate the full current invalidation request.
2. Freshly call `evaluateCurrent()` exactly once using the supplied descriptor and evidence.
3. Validate and recover the pre-invalidation dependency and build the exact pre-invalidation typed facts.
4. Form the retained identity set from the non-null current dependency.
5. Require the requested identity to match exactly one retained identity. Reject a no-dependency result or mismatch before submit.
6. Call evaluator `invalidate()` exactly once with the fresh evaluator result, requested identity and relation.
7. Verify exact `UNKNOWN / [DEPENDENCY_INVALIDATED]`, unchanged current state and dependency vector, false downstream-active/valid-for-protected-use, and false lifecycle-reset/connection-reopened.
8. Construct the accepted invalidated current payload and continue through one submit and conditional readback.

### 11.2 Transition fact

Follow the same sequence using one `evaluateTransition(..., null)` call. Do not separately call `evaluateCurrent()`. The retained identity set contains the non-null current and/or transition identity; cross-type distinctness makes an exact request match unique. A transition result with no retained dependency is not invalidatable.

Verify after the one `invalidate()` call:

- classification `UNKNOWN`;
- reasons exactly `[DEPENDENCY_INVALIDATED]`;
- current/proposed states unchanged;
- dependency vector unchanged;
- downstream-active and valid-for-protected-use false;
- lifecycle-reset and connection-reopened false.

The payload invalidation object has exactly `invalidated=true`, the requested relation and dependency identity, `lifecycle_reset=false`, and `connection_reopened=false`. The pre-invalidation dependency set, aggregate and terminal descriptors are retained.

Fresh reconstruction plus deterministic payload/record construction makes repeated identical invalidation an exact duplicate. No call to IP-13E `observeInvalidation()` substitutes for Product Connection domain invalidation.

## 12. Exact logical-record construction

Use family:

`PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`

Use Binding Model A exactly:

- authority owner and actor: `PRODUCT_CONNECTION_DERIVATION`;
- current scope: `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION|{protected_use_scope}`;
- transition scope: `PRODUCT_CONNECTION_TRANSITION_DERIVATION|{protected_use_scope}`;
- actor role: `DERIVED_NON_AUTHORITATIVE_CORRELATION`;
- subject and aggregate context: exact Connection identity;
- canonical two-party participants;
- audience: `INTERNAL_APPLICATION_PERSISTENCE`;
- purpose: exact protected-use scope;
- terminal: retained current-state terminality.

Lifecycle basis and identity remain exactly the accepted R16 definition:

`product-connection-lifecycle-v1:` plus the canonical SHA-256 digest of family, derived owner/actor/role, Connection identity, protected-use scope, subject, canonical participants, audience, purpose and aggregate context.

Fact-specific schema markers:

- `product-connection-current-state-derived-projection-v1`
- `product-connection-transition-derived-projection-v1`

Semantic input has exactly family, derived fact class, normalized exact bindings, exact typed payload and schema marker. Recursively sort associative keys; preserve list order after canonical participant/reason normalization. Hash the serialized canonical semantic input.

Using that one digest construct:

- logical record identity `product-connection-record-v1:{digest}`;
- logical intent identity `product-connection-intent-v1:{digest}`;
- source lineage `product-connection-lineage-v1:{digest}`;
- projection identity `product-connection-projection-v1:{digest}`.

The record additionally fixes:

- source condition `PRESENT`;
- derived correlation source revision owner/scope/context matching bindings, lineage above and value `0`;
- top-level currentness/freshness from the accepted dependency aggregate;
- authoritative outcome `UNKNOWN`;
- authoritative outcome metadata `null`;
- correction metadata `null`;
- projection represented revision `0`, projection currentness equal top-level currentness, and lag `CURRENT | LAGGED | UNKNOWN` from that currentness;
- transport observation `AMBIGUOUS`;
- private fixture extensions `[]`;
- exact typed payload.

No timestamp, random value, request order or runtime/auth identity participates.

## 13. IP-13E submit/retrieve ordering

For all four operations:

1. construct and validate the exact record;
2. call `submitAuthoritativeMutation()` exactly once;
3. read `persistence.storage_outcome`;
4. retrieve exactly once only when the outcome is:
   - `STORED_NEW`;
   - `EXACT_DUPLICATE`;
   - `INCOMPARABLE_COEXISTS`;
5. do not retrieve for every other disposition;
6. never retry.

Those three outcomes are retrievable because they mean the exact constructed record is newly stored, already stored identically, or retained alongside source-locally incomparable records. Exact lineage prevents cross-selection. The method name `submitAuthoritativeMutation()` does not make the derived result an authoritative Connection mutation.

## 14. Exact retrieval query and request bindings

Query has exactly:

- `record_family = PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- `authority_owner = PRODUCT_CONNECTION_DERIVATION`;
- fact-specific authority scope from Section 12;
- `aggregate_context = connection_identity`;
- `lineage =` exact constructed `product-connection-lineage-v1:{digest}`.

Request bindings have exactly:

- viewer `PRODUCT_CONNECTION_DERIVATION`;
- subject exact Connection identity;
- canonical participants;
- audience `INTERNAL_APPLICATION_PERSISTENCE`;
- purpose exact protected-use scope;
- aggregate context exact Connection identity.

They come from the derived record, never headers, authentication, session or runtime identity. Fact-specific scope plus exact lineage prevents current-state/transition cross-selection.

## 15. Strict readback equivalence

Exact readback requires every condition:

- IP-13E resolution `RESOLVED`;
- binding classification `EXACT`;
- projection is an array;
- exact Product Connection family, derived owner and fact-specific scope;
- projection generic invalidation false;
- exact logical record, logical intent, shared lifecycle, source-lineage and projection identities;
- exact subject, canonical participants, audience, purpose and aggregate context;
- represented source revision value `0`;
- exact top-level currentness/freshness and projection currentness/lag;
- generic terminal equals payload current-state terminality;
- exact typed payload present;
- direct canonical PHP-array equality `===` between read payload and constructed payload.

Digest equality alone is insufficient. Any missing, mismatched, cross-fact or generic-invalidated projection fails exact readback.

## 16. Materialization conditions and usability

Exact bounded condition vocabulary:

1. `EXACT_PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_MATERIALIZED_USABLE`
2. `EXACT_PRODUCT_CONNECTION_TRANSITION_PROJECTION_MATERIALIZED_USABLE`
3. `PRODUCT_CONNECTION_CURRENT_STATE_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
4. `PRODUCT_CONNECTION_TRANSITION_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
5. `EXACT_PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_MATERIALIZED_DOMAIN_UNUSABLE`
6. `EXACT_PRODUCT_CONNECTION_TRANSITION_PROJECTION_MATERIALIZED_DOMAIN_UNUSABLE`
7. `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
8. `PRODUCT_CONNECTION_CURRENT_STATE_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`
9. `PRODUCT_CONNECTION_TRANSITION_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Condition priority is: non-retrievable storage; exact invalidated readback; exact usable readback; exact non-invalidated domain-unusable readback; otherwise readback unusable/missing/mismatched/generic-invalidated.

Materialization/readback conditions are fact-specific. The single storage-rejected condition is shared because retrieval did not occur; the exact `fact_class` result field still identifies which operation was rejected.

`materialized_projection_usable = true` exactly when:

- readback is exact;
- payload is not dependency-invalidated;
- payload `valid_for_protected_use = true`;
- for current state, classification is a known `CN_*` state;
- for transition, classification is `ADMISSIBLE`.

Persistable current `UNKNOWN`, transition `UNKNOWN`, and transition `REJECTED` remain unusable even after exact materialization.

`EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`

Storage/readback never rewrites evaluator classification or reasons.

## 17. Duplicate, incomparable and terminal behavior

- Repeating exact current-state or transition input constructs identical correlation identities: first accepted storage is `STORED_NEW`, repetition is `EXACT_DUPLICATE`, followed by exact-lineage readback.
- A higher comparable source-local evidence revision is selected by the evaluator independent of order. Its changed typed payload produces a new deterministic digest/lineage. The older derived fact is retained; storage may report `INCOMPARABLE_COEXISTS` at the derived-correlation layer because the derived lineages are distinct. There is no LWW replacement.
- Incomparable supplied source revisions produce the evaluator's bounded `UNKNOWN`; no source candidate is selected by arrival order. That exact `UNKNOWN` payload is persisted if valid.
- Changed semantic input derives a different logical intent. Correct construction cannot reuse one intent identity for changed input; tampered reuse remains storage rejection with retrieval skipped.
- Current-state and transition facts share one lifecycle identity but have distinct fact scopes and lineages.
- After a terminal-current-state record exists, a non-terminal current-state record for that lifecycle is rejected by `TERMINAL_IDENTITY_REOPEN_REJECTED`; retrieval is skipped.
- A later transition fact retaining that terminal current state has generic terminal true and a domain `REJECTED / TERMINAL_CONNECTION_IDENTITY_CANNOT_REOPEN` result. It does not reopen the lifecycle and may be stored under its distinct fact correlation.
- An admissible proposed-terminal transition from a non-terminal current state keeps generic terminal false. Proposed-state terminality is descriptive and does not seal or mutate the lifecycle.
- Repeating the same dependency invalidation freshly reconstructs the same pre-result and produces an identical invalidated payload, record and intent; repetition is `EXACT_DUPLICATE`.

No arrival-order selection, LWW, proposed-state authority or synthesized Connection mutation is introduced.

## 18. Exact adapter-internal result shape

Return exactly these keys:

1. `record_kind = PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_RESULT`
2. `operation`
3. `fact_class`
4. `classification`
5. `reason_categories`
6. `product_connection_payload`
7. `logical_record_identity`
8. `logical_intent_identity`
9. `lifecycle_identity`
10. `source_projection_lineage`
11. `derived_correlation_revision`
12. `storage_disposition`
13. `projection_read_disposition`
14. `binding_classification`
15. `materialized_projection_usable`
16. `authoritative_outcome`
17. `reconciliation_required`
18. `invalidation_required`
19. `revalidation_required`
20. `condition`
21. `synthetic_dev_test_only`
22. `source_local_revision_only`
23. `global_revision`
24. `last_write_wins`
25. `last_received_wins`
26. `transport_disposition`
27. `http_status`
28. `source_authority`
29. `domain_writer_authority`
30. `authoritative_mutation_success`
31. `permission`
32. `permission_token`
33. `bearer_capability`
34. `transport_execution_authority`
35. `production_ready`
36. `deployable`
37. `real_data_authorized`
38. `readiness_authority`
39. `match_authority`
40. `connection_authority`
41. `consent_authority`
42. `conversation_authority`
43. `relationship_authority`
44. `home_action_authority`
45. `notification_delivery_authority`
46. `launch_authority`
47. `connection_created`
48. `connection_activated`
49. `match_substituted_for_connection`
50. `messaging_consent_granted`
51. `conversation_granted`
52. `source_evidence_mutated`

Operation is exactly one of `EVALUATE_CURRENT_STATE | EVALUATE_TRANSITION | INVALIDATE_CURRENT_STATE_DEPENDENCY | INVALIDATE_TRANSITION_DEPENDENCY`. Fact class is the accepted current or transition derived class. Current/proposed states remain only inside the exact typed payload to avoid duplicated, diverging state fields.

`derived_correlation_revision` is the constructed five-field revision. `storage_disposition` is the IP-13E persistence outcome; read disposition and binding classification are null when retrieval is skipped. `invalidation_required` equals payload dependency invalidation. `revalidation_required = !materialized_projection_usable`. All marker/non-authority fields from `global_revision` through `source_evidence_mutated` are fixed false except `synthetic_dev_test_only` and `source_local_revision_only`, which are true; transport disposition and HTTP status are null.

`projection_read_disposition` and `binding_classification` copy the conditional IP-13E retrieval result. `authoritative_outcome` copies the submission result and remains `UNKNOWN`; `reconciliation_required` copies the submission result and remains true because no source-carried outcome exists. `storage_disposition`, materialization fields and condition never alter classification or reasons.

No raw source evidence appears in the result.

## 19. Privacy exclusions and retained non-authorities

Exclude from payload, projection and adapter result:

- raw required bindings and raw source evidence;
- unselected duplicate candidates;
- Match result or Match dependency;
- credentials, sessions and tokens;
- private Conversation/message content;
- provider payloads;
- rankings, Compatibility totals, desirability and person-worth data.

Connection identity and participant references are bounded internal correlation values only. R17 grants no HTTP exposure.

Preserve:

- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- `Match != Connection != Conversation != Relationship`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `TRANSITION_ADMISSIBLE != CONNECTION_CREATED`;
- `TRANSITION_ADMISSIBLE != CONNECTION_ACTIVATED`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- no global revision, LWW, arrival-order or timestamp authority;
- no authentication/session/token, provider, production or real/private-data authority.

## 20. Persistence and application implementation sequence

Decision:

`PERSISTENCE_FAMILY_IMPLEMENTATION_FIRST`

Current IP-13A rejects a non-null derived payload outside RR03 and Canonical Match. Current IP-13D neither retains Product Connection payload under a recognized family validator nor exempts it from generic derived-payload invalidation rewrite. A new adapter therefore cannot truthfully establish exact Product Connection readback before the family repair.

Implement and verify IP-13A/IP-13D reference parity first. Only a later separately authorized task may implement the application adapter against the accepted family.

IP-13E decision:

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

One generic submit, conditional exact-lineage retrieve, and existing storage dispositions cover the complete mapping. No new IP-13E method is needed. Generic invalidation observation remains outside Product Connection dependency invalidation.

IP-13F disposition:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

No sixth family, Connection HTTP endpoint or transport contract is introduced.

## 21. Exact next bounded task

Exact title:

`IP-13I-R18 PRODUCT CONNECTION PERSISTENCE FAMILY REFERENCE/SQLITE IMPLEMENTATION TASK`

The task opens only after fresh independent acceptance of R17.

Exact read scope:

1. `AGENTS.md`;
2. `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_FAMILY_REFERENCE_SQLITE_IMPLEMENTATION_TASK_V0_1.md`;
3. `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`;
4. `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`;
5. `docs/architecture/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`;
6. `docs/architecture/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_ACCEPTANCE_V0_1.md`;
7. `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`;
8. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`;
9. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`;
10. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`;
11. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php` as bounded family-test contrast.

Exact write scope:

1. modify `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`;
2. modify `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`;
3. create `services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`;
4. create `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_PERSISTENCE_FAMILY_IMPLEMENTATION_RESULT_V0_1.md`.

Exact targeted test scope: one task-budgeted attempt of only:

`vendor/bin/phpunit tests/Unit/ProductConnectionPersistenceFamilyTest.php`

R18 must implement the accepted family validator, both typed payload classes, `protected_binding_satisfied`, R16-R1 cross-field matrices, exact payload retention, generic-overlay exemption, deterministic correlation checks, duplicate/incomparable/terminal behavior and IP-13A/IP-13D parity under `sqlite::memory:`. It must not create the Product Connection application adapter or any HTTP surface.

This R17 branch does not author R18.

## 22. Downstream gate and execution receipt

Messaging Consent / Conversation remains blocked until Product Connection reaches its required accepted persistence/application boundary. Calm Home and Notification remain downstream.

Execution receipt:

- exactly one R17 result document created;
- no code, test, persistence/application source, IP-13F, route, controller or HTTP file modified;
- no Composer, PHPUnit, Artisan, `route:list`, migration, generator, server/HTTP command, database probe, provider/network operation, production operation or real/private-data operation ran;
- no Product Connection implementation, R18 authoring, downstream Messaging work, self-acceptance, merge or main movement occurred.

Fresh independent ACCEPT/REJECT review is required before R18 or any implementation.

## 23. Classification

`IP-13I-R17 REVIEW COMPLETE — DEDICATED PRODUCT CONNECTION PERSISTENCE APPLICATION ADAPTER MAPPING SOUND — CURRENT-STATE / TRANSITION / DEPENDENCY-INVALIDATION SYNTHETIC FLOWS + SOURCE-ORDER-INDEPENDENT SELECTED-EVIDENCE RECOVERY + protected_binding_satisfied COMPUTATION + EXACT RECORD CONSTRUCTION + ONE IP-13E SUBMIT + CONDITIONAL EXACT-LINEAGE READBACK FIXED — DOMAIN CLASSIFICATION KEPT SEPARATE FROM STORAGE/MATERIALIZATION — EXACT IMPLEMENTATION SEQUENCE FIXED — IP-13F UNCHANGED/NON-PARTICIPATING — NO IMPLEMENTATION OR HTTP AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
