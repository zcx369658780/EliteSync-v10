# EliteSync v10｜IP-13I-R12-R1 Canonical Match Derived-Purpose Binding Contract Correction Review Result｜v0.1

Status: `CANDIDATE — DOCUMENT-ONLY SINGLE-DEFECT REVIEW COMPLETE — OPTION A SELECTED — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh authority / candidate sole parent: `a0727d65bb54cb5cf256f26cb23a9fba0b37824e`

Authority parent / task-publication base: `a2f28b7585f51a0573a9602b8da7609ba6bd69fa`

Authority tree: `cc044f914812c7a72316e57112d0a8e3e5207e69`

Review branch: `review/next-ip-13i-r12-r1-derived-purpose-binding-correction-v0-1`

Candidate commit/tree and authority-relative ahead/behind are resolved externally after immutable publication because this document participates in those identities. The candidate must have the fresh authority as its sole parent and be `0 / 1` behind/ahead relative to it.

## 1. Decision

Selected independently:

`OPTION_A — DERIVED_RECORD_PURPOSE = PAYLOAD_PROTECTED_USE_SCOPE`

Exact contract:

`derived bindings.purpose = payload.protected_use_scope`

The derived lifecycle-basis `purpose` uses the same `payload.protected_use_scope`. IP-13E retrieval request binding `purpose` is copied from the derived record binding and therefore has that same value.

The source proposal's `required_bindings.purpose` and source evidence binding purpose remain byte/value unchanged. The evaluator receives those original source objects without translation or mutation.

## 2. Exact one-path scope and evidence ledger

This candidate creates exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R12_R1_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing tracked file changes.

| Evidence | Blob |
|---|---|
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R12-R1 task | `2c5a45957230cb454247a75bdc5f0e6fd988420a` |
| R12 task | `bd5452740ebb6992cfb097f3b265b837eb69dd37` |
| R12 independent rejection | `000290eaf9a352dedaf08b6668b8d29806fcf1c0` |
| rejected R12 result at `c18d79c968dddf3a26c4d189f783a1354a4fca86` | `524d67ba1b46724e41cb350317f4310304a775e2` |
| rejected R12 adapter at the same candidate | `f1f151b4cb96352521b0823072857153e2ccb4e4` |
| rejected R12 Unit test at the same candidate | `c99ea59a270e4ff23a3b9fa016eec95db3cccdc3` |
| accepted R9-R1 result | `114eb27d2766657d9e6fb364ce83fc8fee82c66d` |
| R9-R1 acceptance | `44f3ee11a0fedbdf80c0c27be47063f42a370cd9` |
| accepted R10 result | `0bb112750c0f6803e1d97224bf5b415763176571` |
| R10 acceptance | `9b23e5f506030d492ef8c617108f906f12fe839d` |
| R11 task | `0b7d9b9c10c64f1b333dbf3f720947ea27746c57` |
| R11 acceptance | `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c` |
| Canonical Match evaluator | `c101657187348dcafa91afbf0b889bc94f0a0bff` |
| Common Authority | `e98e7db731d41269a7b89e01db12e1a81364751d` |
| accepted IP-13A | `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f` |

The rejected R12 candidate is evidence only. It is not merged or transplanted by this review.

## 3. Why Option A is required

The structural gate accepts an exact Common Authority shape even when its semantic required-binding satisfaction is not established. The accepted R9-R1 boundary therefore preserves:

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`

The evaluator independently compares the original proposal `required_bindings.purpose` with `protected_use_scope`. A mismatch can truthfully return:

- classification: `UNKNOWN`
- reason: `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`

That result is one of the accepted persistable domain-`UNKNOWN` outcomes. The mismatch is not a malformed input and must not be converted into a structural rejection.

Accepted R11 independently requires every derived Match persistence record to satisfy:

`bindings.purpose = payload.protected_use_scope`

R11 also includes that derived binding in the deterministic lifecycle and semantic identities. Therefore the derived record must express its own bounded derivation context, while the source-required purpose remains available only to the evaluator as unchanged source semantics.

## 4. Option B and Option C disposition

Option B is rejected. Copying a semantically unsatisfied source-required purpose produces a derived binding that differs from `payload.protected_use_scope`; accepted R11 then returns `INVALID_RECORD_REJECTED`. That loses the accepted persistable `UNKNOWN` branch unless R11 is weakened, which this review forbids.

Option C is not selected. Option A reconciles R9-R1, the evaluator and R11 without changing schema, persistence validation, evaluator behavior or authority boundaries.

## 5. Source preservation and non-authority interpretation

The later correction must not mutate or normalize either:

- `proposal.required_bindings.purpose`
- `proposal.source_evidence.bindings.purpose`

The evaluator must continue to see the original proposal, participation and decision-slot arrays. No pre-evaluation translation from source-required purpose to protected-use scope is allowed.

The derived purpose is assigned only during derived record construction, after the evaluator has returned its original semantic classification and reason.

Preserve exactly:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

`DERIVED_RECORD_PURPOSE != PERMISSION`

The derived purpose records the protected-use context of this bounded derivation. It does not repair source evidence, assert that source required bindings were satisfied, create Match source authority, or create permission, consent, authentication, session or token authority.

## 6. Exact supersession

Option A supersedes only:

1. R10 result Section 8.2 language that derived `purpose` is copied from proposal required bindings;
2. R12 task Section 13 language that derived `purpose` is copied from proposal required bindings.

For those two statements only, read the derived binding rule as:

`actor / actor_role / subject / audience copied from proposal required bindings; purpose = payload.protected_use_scope`

No other accepted R10 mapping or R11 persistence contract is superseded. The original R10 and R12 artifacts remain unchanged historical evidence. No R11 validator change is required or permitted.

## 7. Preserved mapping semantics

All other R10/R11/R12 semantics remain unchanged, including:

- exact synthetic structural gate;
- original evaluator inputs and exactly one evaluator call per ordinary flow;
- fresh evaluate plus exactly one invalidate call for dependency invalidation;
- sticky terminality and `classification_before_invalidation`;
- exact eleven-key Match payload;
- canonical 15-category persisted reason vocabulary;
- collision-free proposal/participant/selected-slot dependency identities;
- independent currentness/freshness aggregation;
- deterministic lifecycle/record/intent/lineage/projection identities;
- one IP-13E submit and conditional exact-lineage retrieve;
- exact readback equivalence;
- dependency-invalidated exact projection remains faithfully materialized but unusable;
- duplicate, incomparable and terminal-reopen behavior;
- IP-13F unchanged and non-participating;
- no HTTP semantics.

Actor, actor role, subject, audience, canonical participants, aggregate context, derived authority owner/scope and terminality rules remain exactly as accepted.

## 8. Exact future implementation correction scope

A later separately authorized correction must start from rejected R12 candidate:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

It may change exactly three tracked paths relative to that candidate:

1. MODIFY `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
2. MODIFY `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
3. CREATE `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

The implementation correction is exactly:

- derived record `bindings.purpose = payload.protected_use_scope`;
- lifecycle-basis `purpose = payload.protected_use_scope`;
- retrieval request purpose continues to come from the corrected derived record binding.

The original R12 result remains unchanged. No IP-13A, IP-13D, IP-13E, IP-13F, evaluator, Common Authority, route, controller or HTTP change is authorized.

## 9. Required targeted test addition

The corrected single Unit test must add a structurally valid proposal fixture where:

- `proposal.required_bindings.purpose != proposal.protected_use_scope`;
- `proposal.source_evidence.bindings.purpose` retains that same original mismatched source-required value;
- evaluator classification is `UNKNOWN`;
- bounded reason is exactly `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- storage outcome is accepted/retrievable under existing R11 rather than `INVALID_RECORD_REJECTED`;
- the exact Match payload is retained in readback according to the existing independent currentness/freshness rules;
- derived record, lifecycle basis and retrieval request purpose equal `payload.protected_use_scope`;
- the input proposal and source evidence remain array/value-identical after the operation;
- source authority, Match authority, permission and bearer capability remain false.

The purpose-mismatch result commonly has a partial pending dependency vector because evaluation stops after the proposal check. The test must preserve R11's resulting currentness/freshness aggregation and readback disposition; it must not weaken those rules merely to claim a usable projection.

## 10. Runtime and HTTP gates

This review ran no Composer, PHPUnit, Artisan, route listing, migration, generator, server, HTTP/client, database probe, provider/network product, production or real/private-data command. It made no code or test change.

A later correction task may separately authorize one targeted PHPUnit attempt and separately fixed Composer/diff-check budgets. This review does not grant those budgets.

Canonical Match HTTP remains deferred until a corrected application adapter is independently accepted. This review does not select or author a route, controller, HTTP request/response shape or status mapping.

## 11. Final classification

`IP-13I-R12-R1 REVIEW COMPLETE — DERIVED MATCH RECORD PURPOSE FIXED TO PAYLOAD PROTECTED-USE SCOPE — SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED AND MAY STILL DRIVE PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE UNKNOWN — R9-R1 PERSISTABLE DOMAIN UNKNOWN RESTORED WITHOUT R11 CHANGE — ONLY R10/R12 PURPOSE-COPY INSTRUCTION SUPERSEDED — EXACT THREE-PATH ADAPTER/TEST CORRECTION SCOPE FIXED — HTTP STILL DEFERRED — READY FOR FRESH INDEPENDENT REVIEW`

Publication is not acceptance. A fresh independent reviewer must issue ACCEPT or REJECT before any correction implementation, merge, movement of `main` or HTTP work.
