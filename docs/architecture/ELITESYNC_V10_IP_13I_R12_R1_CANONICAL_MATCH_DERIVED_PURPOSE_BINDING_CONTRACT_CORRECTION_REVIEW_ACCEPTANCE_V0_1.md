# EliteSync v10｜IP-13I-R12-R1 Canonical Match Derived-Purpose Binding Contract Correction Review Acceptance｜v0.1

Status: `ACCEPTED — OPTION A DERIVED RECORD PURPOSE = PAYLOAD PROTECTED-USE SCOPE — SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED — R9-R1 PERSISTABLE DOMAIN UNKNOWN RESTORED WITHOUT R11 CHANGE — HTTP STILL DEFERRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R12-R1 task-publication commit:
`a0727d65bb54cb5cf256f26cb23a9fba0b37824e`

Accepted review branch:
`review/next-ip-13i-r12-r1-derived-purpose-binding-correction-v0-1`

Accepted immutable candidate:
`bce051c914e766317f00df7fbb37b8fe647f0b9f`

Publication-reported candidate tree:
`cae9ab2425396fb985663bdc70660a0559a24e8b`

Accepted result blob:
`84cac5160f2ae81abe21b689eb9baad4502e1b0d`

Integrated main commit:
`347c074c2069d2d4b4e1365c1d2a04c21b98510d`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = a0727d65bb54cb5cf256f26cb23a9fba0b37824e`;
- candidate is exactly one commit ahead / zero behind;
- exactly one authorized result document is added;
- all fixed evidence objects in the R12-R1 ledger resolve to the claimed blobs;
- no code/runtime action occurred;
- the exact accepted result blob was transplanted to main unchanged.

## 2. Accepted decision

Accepted:

`DERIVED_RECORD_PURPOSE = PAYLOAD_PROTECTED_USE_SCOPE`

Exact rule:

`derived bindings.purpose = payload.protected_use_scope`

The derived lifecycle-basis `purpose` uses the same value.

IP-13E retrieval request binding `purpose` continues to be copied from the derived record binding and therefore also equals the payload protected-use scope.

## 3. Source preservation

The following source values remain unmodified:

- `proposal.required_bindings.purpose`;
- `proposal.source_evidence.bindings.purpose`.

The evaluator receives the original source proposal and original source evidence.

No pre-evaluation normalization or translation is permitted.

Therefore a structurally valid mismatch:

`proposal.required_bindings.purpose != proposal.protected_use_scope`

may still truthfully yield:

- classification `UNKNOWN`;
- bounded reason `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`.

## 4. Non-authority interpretation

Preserve:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

`DERIVED_RECORD_PURPOSE != PERMISSION`

The derived purpose records only the bounded protected-use context of the derivation.

It does not:

- repair source evidence;
- claim that source required bindings were satisfied;
- create Match source authority;
- create permission, consent, authentication, session or token authority.

## 5. Persistence/readback interpretation

The accepted purpose correction restores compatibility with R11:

`bindings.purpose = payload.protected_use_scope`

without changing the R11 validator.

For the purpose-mismatch `UNKNOWN` case, the evaluator may stop after proposal evaluation while the proposal remains non-terminal. The persisted dependency vector may therefore be incomplete.

Under accepted R11 aggregation:

- an incomplete pending dependency vector may yield top-level `currentness=null`;
- top-level `freshness=null`;
- storage may still accept the exact derived record;
- exact-lineage retrieval may return the exact projection with a non-`RESOLVED` persistence/application disposition;
- the payload can therefore be faithfully persisted/read while `materialized_projection_usable=false`.

Do not weaken currentness/freshness or readback rules merely to make this `UNKNOWN` usable.

`PERSISTABLE != USABLE`

and:

`DOMAIN_UNKNOWN != STORAGE_REJECTION`.

## 6. Exact supersession

This acceptance supersedes only:

1. R10 result Section 8.2 statement that derived `purpose` is copied from proposal required bindings;
2. R12 task Section 13 equivalent instruction.

For those statements only, the corrected rule is:

`actor / actor_role / subject / audience copied from proposal required bindings; purpose = payload.protected_use_scope`

All other accepted R10 mapping and R11 persistence semantics remain unchanged.

No R11 source or validator change is authorized or required.

## 7. Accepted correction scope

A separately authorized correction may be based on rejected R12 candidate:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

and change exactly three paths relative to that candidate:

1. MODIFY:
   `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`

2. MODIFY:
   `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

3. CREATE:
   `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

The original R12 result remains unchanged historical evidence.

No IP-13A, IP-13D, IP-13E, IP-13F, evaluator, Common Authority, route, controller or HTTP source may change.

## 8. Required correction proof

The corrected targeted Unit proof must include a structurally valid proposal where:

- source-required purpose differs from protected-use scope;
- source evidence purpose remains the original mismatched source value;
- evaluator classification = `UNKNOWN`;
- reason = `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- storage is accepted rather than `INVALID_RECORD_REJECTED`;
- derived record and lifecycle purpose equal payload protected-use scope;
- retrieval request purpose equals derived record purpose;
- source input/evidence arrays remain unchanged;
- exact payload survives persistence/readback according to existing currentness/freshness semantics;
- materialized usability is determined only by the existing readback rules;
- source/Match authority, permission and bearer capability remain false.

## 9. HTTP gate

Canonical Match HTTP remains deferred.

No route, controller, HTTP request/response body, status mapping or authentication rule is authorized until the corrected application adapter is independently accepted.

## 10. Preserved invariants

Preserve:

- `STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`;
- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`;
- `STORED != AUTHORITATIVE`;
- `APPLICATION_RESULT != SOURCE_AUTHORITY`;
- Match != Connection != Conversation != Relationship;
- invalidation != reopen;
- no global revision;
- no LWW / arrival-order / timestamp authority;
- no single authoritative Compatibility score;
- no authentication/session/token authority;
- no production persistence/deployment authority;
- no real/private-data processing.

## 11. Acceptance classification

`IP-13I-R12-R1 ACCEPTED — DERIVED MATCH RECORD PURPOSE = PAYLOAD PROTECTED-USE SCOPE — SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED AND MAY STILL DRIVE PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE UNKNOWN — R9-R1 PERSISTABLE DOMAIN UNKNOWN RESTORED WITHOUT R11 CHANGE — PURPOSE-MISMATCH UNKNOWN MAY BE FAITHFULLY PERSISTED WHILE MATERIALIZATION REMAINS UNUSABLE UNDER EXISTING CURRENTNESS/FRESHNESS RULES — ONLY R10/R12 PURPOSE-COPY INSTRUCTION SUPERSEDED — EXACT THREE-PATH CORRECTION AUTHORIZED NEXT — HTTP STILL DEFERRED`
