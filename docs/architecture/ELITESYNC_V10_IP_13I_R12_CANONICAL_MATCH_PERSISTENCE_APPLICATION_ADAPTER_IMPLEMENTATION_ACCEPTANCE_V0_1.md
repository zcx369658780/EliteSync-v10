# EliteSync v10｜IP-13I-R12 Canonical Match Persistence Application Adapter Implementation Acceptance｜v0.1

Status: `ACCEPTED VIA R12-R2 — CANONICAL MATCH SYNTHETIC DOMAIN→PERSISTENCE→APPLICATION MAPPING VERIFIED — DERIVED PURPOSE CORRECTED — HTTP STILL DEFERRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Original R12 task-publication commit:
`7df2a86046bf429f5f4e16c15b13230cde070404`

R12-R2 task-publication commit:
`74fb7e8aa868c2cbc5c35f530129cbafc3e2d574`

Accepted correction branch:
`review/next-ip-13i-r12-r2-derived-purpose-binding-correction-v0-1`

Accepted immutable correction candidate:
`4e02f6837ebeceb4b0a57b81d0f8e443871af6a4`

Accepted candidate tree:
`a2b51177a76c3b489479245ed7e38207845972ad`

Accepted correction result blob:
`9d071154cb2d4c76158615f6ca408b5fcfc18b86`

Final main integration chain:

- adapter:
  `fa825384865f65e5807852ce09e19f6680154267`
- targeted Unit test:
  `4b4089b496a1852c48b7d2e23203021659be0f75`
- R12-R2 correction result:
  `106bc2c12625f8e0dc750ba4c2d293cfe25611ce`

## 1. Independent acceptance

Fresh independent review established:

- pre-integration `origin/main = 74fb7e8aa868c2cbc5c35f530129cbafc3e2d574`;
- correction candidate is exactly one commit ahead / zero behind the frozen rejected R12 candidate;
- correction changes exactly the authorized adapter, existing targeted Unit test, and one new correction result;
- adapter correction is exactly two value-source substitutions;
- added test case exercises the public `evaluateSynthetic()` path rather than bypassing production orchestration;
- all protected persistence/application/evaluator/Composer blobs remain unchanged;
- exact correction blobs were transplanted to main unchanged.

The rejected original R12 candidate/result were not merged to main.

## 2. Exact accepted main blobs

Current main contains exactly:

- adapter:
  `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
  → `789e8905b2c9ee54d902d8b600100896af4f6063`

- targeted Unit test:
  `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
  → `c8298f5e786a47d118b56f47cef6baab7f543b60`

- R12-R2 correction result:
  `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`
  → `9d071154cb2d4c76158615f6ca408b5fcfc18b86`

## 3. Accepted targeted runtime receipt

Composer Case B:

- exactly one attempt;
- exit `0`;
- `114 installs / 0 updates / 0 removals`;
- scripts/plugins disabled;
- manifest/lock unchanged.

Targeted PHPUnit:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

Receipt:

- exactly one attempt;
- exit `0`;
- `10 tests / 152 assertions`;
- failures `0`;
- errors `0`;
- warnings `0`;
- deprecations `1`;
- no retry;
- no post-run adapter/test correction.

One authorized `git diff --check` passed.

The retained deprecation is not an acceptance blocker because the authorized output did not identify a product-contract failure and the exercised blobs are the final accepted blobs.

## 4. Accepted ordinary application flow

The accepted synthetic/dev-test ordinary flow is:

`strict structural gate`
→ one `CanonicalMatchProposalDecisionEvaluator::evaluate()`
→ exact accepted Match payload
→ exact R11 Match record construction
→ one IP-13E `submitAuthoritativeMutation()`
→ conditional exact-lineage `retrieveCurrentProjection()`
→ strict readback/materialization result.

No retry.
No second evaluator call.
No generic invalidation call.

## 5. Accepted dependency-invalidation flow

The accepted synthetic dependency-invalidation flow is:

`strict structural gate`
→ one fresh evaluator `evaluate()`
→ exact pre-invalidation classification/dependency binding
→ one evaluator `invalidate()`
→ sticky-terminal Match payload
→ one IP-13E submit
→ conditional exact-lineage retrieve.

The flow does not:

- accept caller-supplied prior evaluator state;
- reconstruct prior terminality from already-invalidated `UNKNOWN`;
- infer order from timestamps/storage/arrival/LWW;
- invoke generic IP-13E invalidation observation as a substitute for Match dependency invalidation.

## 6. Accepted derived-purpose correction

Accepted:

`derived bindings.purpose = payload.protected_use_scope`

and lifecycle-basis purpose uses the same protected-use scope.

Source values remain untouched:

- `proposal.required_bindings.purpose`;
- `proposal.source_evidence.bindings.purpose`.

Thus:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

`DERIVED_RECORD_PURPOSE != PERMISSION`

A structurally valid source-purpose mismatch remains evaluator-domain semantics and may produce:

`UNKNOWN / PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`.

## 7. Accepted purpose-mismatch proof

The targeted R12-R2 proof establishes a structurally valid source-purpose mismatch with:

- source required/evidence purpose:
  `SYNTHETIC_OTHER_PURPOSE`;
- payload protected-use scope:
  `SYNTHETIC_MATCH_REVIEW`;
- evaluator-derived classification:
  `UNKNOWN`;
- bounded reason:
  `PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`;
- storage disposition:
  `STORED_NEW`;
- no `INVALID_RECORD_REJECTED`;
- derived record purpose:
  `SYNTHETIC_MATCH_REVIEW`;
- source request/evidence remains unchanged.

Because the pending evaluator exits after the proposal mismatch, the persisted dependency vector is incomplete. Existing R11 aggregation therefore yields:

- `currentness=null`;
- `freshness=null`;
- read disposition `UNKNOWN`;
- exact binding classification `EXACT`;
- exact Match payload remains present in projection;
- `materialized_projection_usable=false`;
- condition:
  `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`.

Therefore:

`DOMAIN_UNKNOWN != STORAGE_REJECTION`

and:

`PERSISTABLE != USABLE`.

## 8. Accepted materialization conditions

The application adapter preserves exactly four bounded conditions:

1. `EXACT_PRIVACY_MINIMAL_CANONICAL_MATCH_PROJECTION_MATERIALIZED`
2. `CANONICAL_MATCH_DEPENDENCY_INVALIDATED_PROJECTION_MATERIALIZED_UNUSABLE`
3. `STORAGE_REJECTED_RETRIEVAL_SKIPPED`
4. `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

Storage/readback state does not rewrite Match classification.

Dependency-invalidated exact materialization remains unusable.

## 9. Duplicate / incomparable / terminal behavior

Accepted targeted proof preserves:

- exact duplicate → idempotent correlation;
- changed dependency revision vector → distinct identity/lineage;
- `INCOMPARABLE_COEXISTS` → exact-lineage retrieval;
- no arrival-order/LWW resolution;
- terminal lifecycle followed by non-terminal evaluation → storage rejection/retrieval skipped;
- terminal dependency invalidation → current classification `UNKNOWN`, sticky terminal remains true;
- repeated identical invalidation → exact duplicate correlation.

## 10. Privacy and non-authority

The adapter result remains application-internal and privacy-minimal.

It does not expose raw Common Authority evidence or raw required-bindings containers.

Preserve all false non-authority fields, including:

- source authority;
- Match authority;
- Connection/Consent/Conversation/Relationship authority;
- Home/Notification/launch authority;
- permission;
- bearer capability;
- production readiness;
- real-data authorization.

`authoritative_outcome` remains `UNKNOWN` absent independently source-carried authority.

## 11. IP-13E / IP-13F / HTTP disposition

IP-13E remains unchanged and sufficient for the accepted mapping.

IP-13F remains:

`UNCHANGED / NON-PARTICIPATING`.

No sixth generic application-envelope family is created.

Canonical Match HTTP remains unimplemented and requires a separate document-only entry-contract review before any route/controller work.

## 12. Rejected intermediate evidence

Rejected original R12 candidate:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

remains rejected as a final acceptance candidate.

Its original result blob:

`524d67ba1b46724e41cb350317f4310304a775e2`

remains historical evidence only and was not integrated to main.

The final accepted implementation is the R12-R2 corrected adapter/test/result set.

## 13. Next gate

The next bounded task may be:

`IP-13I-R13 CANONICAL MATCH APPLICATION ADAPTER TO HTTP ENTRY CONTRACT REVIEW — DOCUMENT ONLY`

It must define a dedicated Canonical Match transport/HTTP entry without implementing it.

No route/controller/Feature test is authorized by this acceptance.

## 14. Preserved invariants

Preserve:

- `MATCH_DERIVATION != MATCH_SOURCE_AUTHORITY`
- `STORED != AUTHORITATIVE`
- `APPLICATION_RESULT != SOURCE_AUTHORITY`
- Match != Connection != Conversation != Relationship
- invalidation != reopen
- `UNKNOWN != ABSENT`
- `PERSISTABLE != USABLE`
- no global revision
- no LWW / arrival-order / timestamp authority
- no single authoritative Compatibility score
- no authentication/session/token authority
- no production persistence/deployment authority
- no real/private-data processing
- private Conversation is not default ranking/training/ads data.

## 15. Acceptance classification

`IP-13I-R12 ACCEPTED VIA R12-R2 — CANONICAL MATCH SYNTHETIC DOMAIN→PERSISTENCE→APPLICATION MAPPING VERIFIED — ORDINARY AND STICKY DEPENDENCY-INVALIDATION FLOWS ACCEPTED — DERIVED PURPOSE FIXED TO PROTECTED-USE SCOPE WITHOUT MUTATING SOURCE PURPOSE — PURPOSE-MISMATCH DOMAIN UNKNOWN STORED WITHOUT STORAGE REJECTION WHILE INCOMPLETE DEPENDENCY VECTOR REMAINS UNUSABLE — 10 TESTS / 152 ASSERTIONS / 0 FAILURES / 0 ERRORS — IP-13E/IP-13F UNCHANGED — READY FOR DOCUMENT-ONLY HTTP ENTRY CONTRACT REVIEW`
