# EliteSync v10｜IP-13I-R9 Canonical Match Record/Projection Contract Repair Review Result｜v0.1

Status: `CANDIDATE — DOCUMENT-ONLY REVIEW COMPLETE — ADDITIVE CANONICAL MATCH DERIVED RECORD/PROJECTION CONTRACT SOUND — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh authority / candidate sole parent: `b2113ac1c4a1c296398fba5db1ff4584ed8035ad`

Authority sole parent / task-publication base: `1e34307dcd38993a856f14dc83b966fd09cdddc6`

Authority tree: `b4fb6cdf64564668110dae06c2fa086b533a3f77`

Review branch: `review/next-ip-13i-r9-canonical-match-record-projection-contract-repair-v0-1`

Candidate commit/tree and authority-relative ahead/behind are resolved externally after immutable publication because this document participates in those identities. The candidate must have `b2113ac1c4a1c296398fba5db1ff4584ed8035ad` as its sole parent and must be `0 / 1` behind/ahead relative to that authority.

## 1. Top-level decisions

`ADDITIVE_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_SOUND`

`IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_MATCH_FAMILY`

`IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_RECORD_REPAIR`

`IP_13F_UNCHANGED_NON_PARTICIPATING`

Exact record family:

`CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`

The family carries one non-null `derived_projection_payload` under the existing generic IP-13A record envelope. It is independent from `RR03_RUNTIME_READINESS_DERIVED_PROJECTION` and is not a transport family, HTTP family, source record, Connection state, Consent state or Conversation gate.

This review authorizes no implementation.

## 2. Exact one-path scope and evidence ledger

This candidate creates exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`

No existing tracked file changes.

Only the authorized inputs were read:

| Evidence | Blob |
|---|---|
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R9 task | `b0208d28b3e39efb7cbafac4a871f7f485a3b1e8` |
| R8 task | `218e291b3b18d900220654dbcb063ac5d007fbcc` |
| accepted R8 result | `10bb30f123d22929a17fe33a7ecd2908db5df786` |
| R8 acceptance | `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8` |
| R7 acceptance | `efa900a6351d98adbe5fe9fce2d846004296b4a9` |
| backend reassessment acceptance | `9001630069a541af79f7b191ac204561a4fd8e6b` |
| core-domain harness acceptance | `17eba174bccdbb688043ecc98d2eae3a9df7b3d3` |
| Canonical Match evaluator | `c101657187348dcafa91afbf0b889bc94f0a0bff` |
| Common Authority | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| IP-13A | `2877f5804710abf7c8eba87a9d59925ad5cc405d` |
| IP-13E | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| IP-13F | `e70f260de92a0047e70b54827f4795edb3b74e00` |
| Runtime Readiness adapter, contrast only | `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5` |

No repository enumeration, unrelated discovery or extra source read occurred.

## 3. Logical-record envelope contract

The additive family retains the existing exact generic record envelope. Its fields and Match-specific rules are:

| Envelope field | Canonical Match rule |
|---|---|
| `logical_record_identity` | `canonical-match-record-v1:` plus the deterministic semantic digest defined in Section 11 |
| `record_family` | exactly `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION` |
| `bindings` | exact Common Authority binding object, normalized as defined below |
| `source_revision` | derived correlation revision only; never a proposal/participant/slot source revision |
| `source_condition` | exactly `PRESENT`, meaning the derived record exists, not that Match source authority exists |
| `currentness` | independent aggregate from Section 10 |
| `freshness` | independent aggregate from Section 10 |
| `logical_intent` | deterministic identity plus exact semantic input from Section 11 |
| `authoritative_outcome` | exactly `UNKNOWN` |
| `authoritative_outcome_metadata` | exactly `null` |
| `correction_metadata` | initially `null`; later only the already accepted generic correction relation/reference shape |
| `projection_metadata` | deterministic projection identity, correlation revision value `0`, bounded lag/currentness fields |
| `transport_observation` | exactly `AMBIGUOUS`; transport is not Match outcome |
| `private_fixture_extensions` | exactly `[]`; excluded from payload, identity and projection |
| `derived_projection_payload` | required, non-null and valid against Sections 5–9 |

### 3.1 Exact derived bindings

The binding object remains the existing eleven-key Common Authority shape.

- `authority_owner`: exactly `CANONICAL_MATCH_DERIVATION`
- `authority_scope`: `CANONICAL_MATCH_PROPOSAL_DECISION|` plus the non-empty protected-use scope
- `actor`, `actor_role`, `subject`, `audience`, `purpose`: copied from the structurally accepted synthetic proposal required bindings and remain descriptive only
- `participants`: the exact two unique non-empty proposal participant references, sorted lexicographically before hashing/storage
- `aggregate_context`: exact proposal identity
- `lifecycle_identity`: `canonical-match-lifecycle-v1:` plus the digest of record family, proposal identity, protected-use scope, subject, sorted participants, audience, purpose and aggregate context
- `terminal`: the payload `terminality.derived_terminal` value

The descriptive actor fields establish no authentication, identity, permission or source authority.

### 3.2 Derived correlation revision

The top-level `source_revision` is exactly:

```text
authority_owner   = CANONICAL_MATCH_DERIVATION
authority_scope   = bindings.authority_scope
lineage           = canonical-match-lineage-v1:<semantic digest>
aggregate_context = proposal identity
value             = 0
```

It exists only to satisfy deterministic logical-record correlation. Every real source-local revision remains inside the typed dependencies. Value `0` is not a global, aggregate, wall-clock, arrival-order or latest revision.

### 3.3 Projection metadata

- `projection_identity`: `canonical-match-projection-v1:<semantic digest>`
- `represented_source_revision_value`: `0`, referring only to the derived correlation revision
- `projection_currentness`: exact top-level currentness aggregate
- `lag_classification`: `CURRENT` when top-level currentness is `true`, `LAGGED` when `false`, otherwise `UNKNOWN`

Projection lag does not encode Match classification or source outcome.

## 4. Exact derived payload key set

The payload contains exactly these eleven keys:

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

Exact fixed values:

- `payload_kind = CANONICAL_MATCH_PROPOSAL_DECISION`
- `derived_fact_class = CANONICAL_MATCH_PROPOSAL_DECISION`

`proposal_identity` and `protected_use_scope` must be non-empty strings and must match the generic bindings.

Participant references are not duplicated in the payload. They remain in the generic `bindings.participants` and must equal the unique participant identities represented by a complete participation/decision-slot vector. This avoids a third stored copy while retaining lossless internal readback.

`valid_for_protected_use` is deterministically reconstructed as `classification != UNKNOWN`. Fixed false non-authority fields are contract invariants and are not repeated inside the payload.

## 5. Exact classification and supporting vocabularies

Allowed classification values are exactly:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

Allowed proposal lifecycle states are exactly the first five values above.

Allowed participation states are exactly:

- `NOT_ENROLLED`
- `ENROLLED`
- `PAUSED`
- `WITHDRAWN`

Allowed decision-slot decisions are exactly:

- `PENDING`
- `ACCEPTED`
- `DECLINED`
- `WITHDRAWN`

Allowed source conditions and invalidation relations remain exactly those in Common Authority. No new source condition or revision comparison is introduced.

## 6. Exact bounded reason categories

Persisted reasons are a unique list drawn only from this fixed ordered vocabulary:

1. `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
2. `INVALID_PROPOSAL_SHAPE`
3. `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`
4. `UNRESOLVED_PROPOSAL_PRECONDITION_NOT_ESTABLISHED`
5. `INVALID_PARTICIPATION_EVIDENCE_SET`
6. `MISSING_PARTICIPATION`
7. `PARTICIPATION_NOT_USABLE`
8. `PARTICIPATION_PREVENTS_ACCEPTANCE`
9. `CROSS_PROPOSAL_SLOT`
10. `WRONG_PARTICIPANT_SLOT`
11. `MISSING_DECISION_SLOT`
12. `INVALID_SLOT_EVIDENCE`
13. `CONFLICTING_SLOT_IDENTITY`
14. `INCOMPARABLE_DUPLICATE_SLOT`
15. `CONFLICTING_EQUAL_REVISION_SLOT`
16. `DECISION_SLOT_NOT_CURRENT_FRESH_BOUND`
17. `INVALID_SLOT_DECISION`
18. `CONFLICTING_TERMINAL_SLOT_DECISIONS`
19. `DEPENDENCY_INVALIDATED`

Evaluator reason suffixes are reduced by exact leading category only:

- participant identities are removed from `MISSING_PARTICIPATION:*`, `PARTICIPATION_NOT_USABLE:*`, `PARTICIPATION_PREVENTS_ACCEPTANCE:*`, `MISSING_DECISION_SLOT:*` and `INVALID_SLOT_DECISION:*`;
- participant identity and source-condition suffix are removed from `DECISION_SLOT_NOT_CURRENT_FRESH_BOUND:*:*`;
- participant suffixes are removed from duplicate-slot resolution reasons.

Any unmapped reason rejects record construction. Categories are deduplicated and emitted in the fixed order above, independent of evaluator input order. They contain no raw evidence, hidden adverse meaning, ranking, Compatibility score, desirability or person-worth inference.

## 7. Exact dependency schemas

### 7.1 Proposal dependency

`proposal_dependency` is one object with exactly:

- `proposal_identity`
- `lifecycle_state`
- `terminal`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

`terminal` must equal `lifecycle_state != PENDING` and must equal the source required-binding terminal marker. The revision fields are copied from the proposal source evidence and remain source-local.

### 7.2 Participation dependency

Each item in `participation_dependencies` contains exactly:

- `participant_identity`
- `state`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

The list contains only evaluator-selected dependencies, at most one per participant identity. It is sorted by participant identity, then owner, scope, context, lineage and revision value. Duplicate participant identities are invalid.

### 7.3 Decision-slot dependency

Each item in `decision_slot_dependencies` contains exactly:

- `slot_identity`
- `proposal_identity`
- `participant_identity`
- `decision`
- `authority_owner`
- `authority_scope`
- `aggregate_context`
- `source_lineage`
- `source_revision_value`
- `source_condition`
- `currentness`
- `freshness`

Only the evaluator-selected duplicate winner is stored. Raw duplicate candidates are excluded. The list is sorted by participant identity, slot identity, owner, scope, context, lineage and revision value. Both slot identity and participant identity must be unique; every proposal identity must equal the payload proposal identity.

For a complete pending-proposal evaluation, the two participation identities and two selected slot participant identities must each equal the sorted two-value binding participant set. Early fail-closed `UNKNOWN` results may carry a partial selected dependency list; absent or conflicting raw evidence is represented only by bounded reasons and is never fabricated.

## 8. Terminality contract

`terminality` contains exactly:

- `source_proposal_terminal`
- `derived_terminal`
- `lifecycle_reset`
- `proposal_reopened`

Rules:

- `source_proposal_terminal` equals `proposal_dependency.terminal`;
- `derived_terminal` is `true` exactly for `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, or `EXPIRED`;
- both values are boolean;
- `lifecycle_reset` is always `false`;
- `proposal_reopened` is always `false`;
- a terminal source proposal requires no participation or decision-slot dependencies because the accepted evaluator returns its current terminal source state after validating the proposal evidence;
- persistence, correction, invalidation, retrieval or transport cannot reopen or reset the proposal.

## 9. Invalidation contract

`invalidation` contains exactly:

- `invalidated`
- `relation`
- `dependency_identity`
- `lifecycle_reset`
- `proposal_reopened`

For a non-invalidated evaluator result:

- `invalidated=false`
- `relation=null`
- `dependency_identity=null`
- `lifecycle_reset=false`
- `proposal_reopened=false`

For a dependency-invalidated evaluator result:

- `invalidated=true`
- `relation` is exactly `CORRECTION | REVOCATION | SUPERSESSION`
- `dependency_identity` is a non-empty identity present in the proposal, participation or selected decision-slot dependency set
- `classification=UNKNOWN`
- `reason_categories` contains exactly the bounded `DEPENDENCY_INVALIDATED` category for the invalidation cause
- lifecycle reset and proposal reopening remain false.

The current generic logical-record invalidation mechanism can still mark the stored projection unusable by logical record identity without semantic change. It does not identify the domain dependency and must not be described as doing so. Dependency-scoped provenance comes only from the payload produced from the accepted evaluator invalidation result. Generic projection invalidation and payload dependency invalidation are separate facts; either makes a readback unusable.

## 10. Currentness and freshness aggregation

Currentness and freshness are aggregated independently over the typed dependency vector. Neither is inferred from classification, source condition, storage disposition or the other aggregate.

Dependency completeness is exact:

- for a terminal source proposal, the complete required vector is the proposal dependency only;
- for a pending source proposal, a complete vector is one proposal dependency, exactly two participation dependencies and exactly two selected decision-slot dependencies covering the exact participant set;
- an early fail-closed result with missing, invalid, incomparable or conflicting dependencies has an incomplete vector.

For each aggregate independently:

1. if any stored dependency value is `false`, aggregate to `false`;
2. otherwise, if the required vector is incomplete or any required dependency value is `null`, aggregate to `null`;
3. otherwise aggregate to `true`.

This preserves important cases:

- a terminal proposal still requires its proposal source evidence to be current and fresh because the accepted evaluator checks those facts before returning a terminal classification;
- a complete current/fresh vector may still classify `UNKNOWN` for a semantic conflict such as conflicting terminal slot decisions;
- an incomplete vector never becomes current/fresh merely because the dependencies that happened to be present were true.

## 11. Deterministic identity, intent and correlation

Before hashing:

- associative keys are recursively sorted;
- binding participants are sorted lexicographically;
- reason categories follow the fixed Section 6 order;
- participation and decision-slot dependencies follow Section 7 ordering;
- no raw source evidence object or private fixture extension participates.

The semantic digest is SHA-256 over exactly:

- record family;
- normalized generic bindings;
- payload;
- a fixed schema marker `canonical-match-derived-projection-v1`.

Identities are:

- logical record: `canonical-match-record-v1:<digest>`
- logical intent: `canonical-match-intent-v1:<digest>`
- derived lineage: `canonical-match-lineage-v1:<digest>`
- projection: `canonical-match-projection-v1:<digest>`

`logical_intent.semantic_input` contains exactly the four semantic-digest inputs above. Changed source-local revision vectors therefore produce a distinct digest. Input list order alone cannot change the digest.

The digest is correlation only. It is not source authority, permission, Match success, a global revision, timestamp, arrival order, LWW or last-received-wins rule.

## 12. Privacy-minimal persistence projection

The IP-13E-visible persistence projection may expose internally:

- the unchanged generic projection fields required for exact binding and source-local correlation;
- `record_family`;
- `derived_projection_payload` with exactly the Section 4 schema;
- generic projection invalidation state and correction relation.

The payload provides lossless application readback for:

- bounded classification;
- proposal identity;
- protected-use scope;
- bounded reasons;
- proposal, participation and selected decision-slot dependency summaries;
- source and derived terminality;
- dependency-scoped invalidation summary.

Exact two participant references survive once in generic `participant_references`; they are required for exact binding and for validating dependency coverage. They are internal application projection data and are not thereby authorized for a future HTTP response.

Raw source evidence objects, required-binding objects, unselected duplicate candidates, private fixture material, profiles/content, messages, hidden Safety evidence, credentials, provider payloads, ranking signals, Compatibility totals, desirability and person-worth data must never be persisted in the Match payload.

R9 defines no HTTP response. A later transport review must independently minimize any external representation.

## 13. IP-13A compatibility

`IP13A_ENVELOPE_COMPATIBLE_WITH_ADDITIVE_MATCH_FAMILY`

The additive family requires extension only of family-specific record validation and family-specific projection payload retention. These generic envelope fields remain unchanged:

- exact record-envelope key set, including optional `derived_projection_payload`;
- Common Authority bindings and revision shape;
- currentness/freshness tri-state fields;
- logical intent shape and fingerprinting;
- authoritative outcome and source-carried metadata rules;
- correction metadata;
- projection metadata;
- transport observation;
- private fixture extension field;
- storage duplicate/conflict/incomparable rules;
- exact/current/lineage queries;
- generic invalidation overlay;
- all non-authority fields.

RR03 family name, validator, payload keys and behavior remain unchanged. The implementation must dispatch derived-payload validation and retention by exact record family, rather than weakening RR03 or allowing arbitrary derived payloads.

## 14. IP-13E sufficiency

`IP13E_EXISTING_OPERATIONS_SUFFICIENT_AFTER_RECORD_REPAIR`

After IP-13A and its equivalent physical adapter accept the exact Match family:

- `submitAuthoritativeMutation()` can submit the generic envelope while continuing to return `authoritative_outcome=UNKNOWN` because no source-carried outcome metadata exists;
- `retrieveCurrentProjection()` can resolve and return the privacy-minimal Match projection under exact request bindings;
- `observeInvalidation()` can mark the stored projection unusable without creating domain dependency provenance;
- reconciliation and protected revalidation remain available but are not automatically required by the Match adapter.

No evaluator-orchestration method, Match-specific IP-13E family or contract repair is justified by current evidence. Method naming does not convert the derived record into an authoritative Match mutation because the source-carried outcome and all authority flags remain false/unknown.

This decision authorizes only a later document-only domain-to-application mapping review.

## 15. IP-13F disposition

`IP_13F_UNCHANGED_NON_PARTICIPATING`

The five accepted IP-13F families remain unchanged. Canonical Match evaluation is not a sixth family, and R9 does not select a generic-envelope mapping, dedicated route or HTTP contract.

## 16. Exact next bounded task

Next task type:

`CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW — DOCUMENT ONLY`

Exact task ID/title:

`IP-13I-R10 CANONICAL MATCH DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

Decision objective:

- define one synthetic/dev-test Canonical Match adapter orchestration against the accepted R9 record/projection contract;
- fix the exact structurally accepted proposal, participation and decision-slot input boundary;
- define evaluator-to-record construction, submit/retrieve ordering, readback equivalence and degraded materialization dispositions;
- keep Match classification separate from storage/application outcome;
- decide whether any future dedicated transport entry is conceptually sound while keeping it unauthorized;
- retain IP-13F unchanged/non-participating.

Exact read scope:

1. `AGENTS.md`
2. the accepted R9 task/result/acceptance chain
3. R8 acceptance
4. R7 acceptance
5. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
6. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
7. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
8. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
9. `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
10. `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`, contrast only

Exact write scope:

Create only:

`docs/architecture/ELITESYNC_V10_IP_13I_R10_CANONICAL_MATCH_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`

No code, persistence, adapter, route, controller or test change is authorized. No Composer, PHPUnit, Artisan, migration, generator, server, HTTP/client, database probe, provider/network, production or real/private-data operation is authorized. The review must publish one document candidate and stop for fresh independent ACCEPT/REJECT.

## 17. Retained non-authorities and execution boundary

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- Match creates no automatic Connection, Consent, Conversation, relationship, Home, Notification or launch authority;
- `UNKNOWN != ABSENT` and `DEFERRED != MISSING`;
- no global revision, LWW, arrival-order or timestamp authority;
- no single authoritative Compatibility score;
- authentication/session/token remains unestablished;
- private Conversation is not default ranking/training/ads data;
- no production persistence/deployment or real/private-data authority.

No Composer, PHPUnit, Artisan, `route:list`, migration, generator, server, HTTP/client command, database runtime probe, provider/network work, production action, real/private-data operation, legal research or Safety Operation ran.

No code, persistence source, adapter, route, controller, test or accepted artifact changed. R10 was not authored or started.

Fresh independent ACCEPT/REJECT review is required.

Final classification:

`IP-13I-R9 REVIEW COMPLETE — ADDITIVE CANONICAL MATCH DERIVED RECORD/PRIVACY-MINIMAL PROJECTION CONTRACT SOUND — EXACT PROPOSAL/PARTICIPATION/DECISION-SLOT DEPENDENCY SEMANTICS FIXED — SOURCE-LOCAL REVISION/TERMINALITY/INVALIDATION/NON-AUTHORITY BOUNDARIES PRESERVED — IP-13A GENERIC ENVELOPE COMPATIBLE WITH FAMILY-SPECIFIC MATCH VALIDATION — IP-13E EXISTING OPERATIONS SUFFICIENT AFTER RECORD REPAIR — IP-13F UNCHANGED/NON-PARTICIPATING — NEXT = IP-13I-R10 CANONICAL MATCH DOMAIN-TO-APPLICATION MAPPING REVIEW, DOCUMENT ONLY — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`
