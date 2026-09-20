# EliteSync v10｜Canonical Match Derived-Purpose Binding Correction Implementation Result｜v0.1

Status: `CANDIDATE — EXACT THREE-PATH CORRECTION COMPLETE — TARGETED UNIT EXIT 0 WITH ONE DEPRECATION — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh task authority: `74fb7e8aa868c2cbc5c35f530129cbafc3e2d574`

Task-publication parent/base: `250b8c70b7eb92aec20231f38e7c078e9615b5d5`

Frozen rejected R12 base / candidate sole parent: `c18d79c968dddf3a26c4d189f783a1354a4fca86`

Frozen base parent: `7df2a86046bf429f5f4e16c15b13230cde070404`

Frozen base tree: `eecc327c1a3b3f0f332a648c42d04448a60978a7`

Correction branch: `review/next-ip-13i-r12-r2-derived-purpose-binding-correction-v0-1`

Candidate commit/tree and frozen-base-relative ahead/behind are resolved externally after immutable publication because this document participates in those identities. The correction candidate must have the frozen rejected R12 base as its sole parent and be `0 / 1` behind/ahead relative to that base. Its relationship to current main is reported separately because the authorized correction topology intentionally diverges from main.

## 1. Result

`IP-13I-R12-R2 DERIVED PURPOSE BINDING CORRECTED — DERIVED MATCH PURPOSE USES PAYLOAD PROTECTED-USE SCOPE WHILE SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED — PURPOSE-MISMATCH PROPOSAL REMAINS DOMAIN UNKNOWN / PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE AND IS ACCEPTED BY R11 PERSISTENCE — INCOMPLETE PENDING DEPENDENCY VECTOR REMAINS UNUSABLE WITHOUT STORAGE REJECTION — ALL OTHER R12 ORDINARY/STICKY-INVALIDATION/DUPLICATE/INCOMPARABLE/PRIVACY/NON-AUTHORITY PROOFS PRESERVED — HTTP STILL DEFERRED — READY FOR FRESH INDEPENDENT REVIEW`

The correction changes only the derived-purpose source in `buildRecord()` and adds one targeted proof. It does not merge or transplant the rejected R12 candidate into main.

## 2. Exact three-path scope

Relative to frozen rejected R12 candidate `c18d79c968dddf3a26c4d189f783a1354a4fca86`:

Modified:

1. `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
2. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

Created:

3. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

No fourth tracked path is part of the correction.

## 3. Fixed evidence ledger

Task-publication main evidence:

| Evidence | Blob |
|---|---|
| `AGENTS.md` | `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1` |
| R12-R2 task | `78e738712da4df34f6cffa26797d4c567197503c` |
| accepted R12-R1 result | `84cac5160f2ae81abe21b689eb9baad4502e1b0d` |
| R12-R1 acceptance | `8ccaaffa4f3ac54c93be33218b32fb40e0a2180f` |
| R12 independent rejection | `000290eaf9a352dedaf08b6668b8d29806fcf1c0` |
| R11 acceptance | `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c` |

Frozen rejected R12 candidate evidence:

| Evidence | Blob |
|---|---|
| adapter before | `f1f151b4cb96352521b0823072857153e2ccb4e4` |
| targeted Unit test before | `c99ea59a270e4ff23a3b9fa016eec95db3cccdc3` |
| original R12 implementation result | `524d67ba1b46724e41cb350317f4310304a775e2` |
| IP-13A | `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f` |
| IP-13D | `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c` |
| IP-13E | `aa9721dfa66fe17eb2314bc9466870d479c07644` |
| Canonical Match evaluator | `c101657187348dcafa91afbf0b889bc94f0a0bff` |
| `composer.json` | `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1` |
| `composer.lock` | `66327f584d3961c2b53391bb012047dda9cc9d23` |
| `phpunit.xml` | `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9` |

Final adapter/test blobs exercised by the single targeted attempt:

| Output | Blob |
|---|---|
| adapter after | `789e8905b2c9ee54d902d8b600100896af4f6063` |
| targeted Unit test after | `c8298f5e786a47d118b56f47cef6baab7f543b60` |

The original R12 result remains blob-identical at `524d67ba1b46724e41cb350317f4310304a775e2`.

## 4. Exact code correction

Inside `CanonicalMatchPersistenceApplicationAdapter::buildRecord()`, exactly two value sources changed:

- lifecycle-basis `purpose` now uses `$payload['protected_use_scope']`;
- derived `bindings['purpose']` now uses `$payload['protected_use_scope']`.

The IP-13E retrieval request still obtains purpose from `$record['bindings']['purpose']`, so it automatically uses the corrected derived protected-use scope.

No actor, actor role, subject, audience, participants, aggregate context, authority owner/scope, terminality, payload, currentness/freshness aggregation, evaluator/invalidation call, submit/retrieve order or result key changed.

## 5. Source-purpose non-mutation

The adapter still passes the original request proposal, participation list and decision-slot list directly to the evaluator before derived-record construction.

It neither modifies nor normalizes:

- `proposal.required_bindings.purpose`;
- `proposal.source_evidence.bindings.purpose`.

The added proof sets both source values to `SYNTHETIC_OTHER_PURPOSE` while `protected_use_scope` remains `SYNTHETIC_MATCH_REVIEW`, retains an array-identical request after the operation, and confirms that the returned result does not expose or claim normalization of the source purpose.

Preserved:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

`DERIVED_RECORD_PURPOSE != PERMISSION`

## 6. Purpose-mismatch domain-UNKNOWN proof

The added targeted case establishes:

- `match_classification = UNKNOWN`;
- `reason_categories = [PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE]`;
- first storage outcome = `STORED_NEW`;
- storage outcome is not `INVALID_RECORD_REJECTED`;
- payload protected-use scope = `SYNTHETIC_MATCH_REVIEW`;
- derived record purpose = `SYNTHETIC_MATCH_REVIEW`;
- lifecycle digest basis purpose = `SYNTHETIC_MATCH_REVIEW`;
- retrieval binding with the derived scope is `EXACT`;
- retrieval binding with the original mismatched source purpose is `MISMATCH`;
- exact Match payload remains present in the bounded projection readback;
- source-required and source-evidence purposes remain `SYNTHETIC_OTHER_PURPOSE` in the original request.

The evaluator stops after the proposal mismatch, so the pending dependency vector contains the proposal dependency and no participation or selected-slot dependencies. Existing R11 aggregation therefore produces:

- top-level currentness: `null`;
- top-level freshness: `null`;
- projection read disposition: `UNKNOWN` rather than `RESOLVED`;
- `materialized_projection_usable=false`;
- condition: `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`.

Thus:

`DOMAIN_UNKNOWN != STORAGE_REJECTION`

and:

`PERSISTABLE != USABLE`

No currentness, freshness or readback rule was weakened.

## 7. Existing R12 proof preservation

The original test methods remain unchanged and the same targeted file continues to cover:

- ordinary PENDING exact materialization;
- terminal MUTUALLY_ACCEPTED, DECLINED and WITHDRAWN behavior;
- semantic UNKNOWN behavior;
- strict structural rejection;
- missing participation/slot domain UNKNOWN;
- cross-proposal/wrong-participant UNKNOWN;
- bounded duplicate-slot reasons;
- sticky dependency invalidation and repeated exact-duplicate invalidation;
- invalidation target collision/unknown rejection;
- ordinary exact duplicate and incomparable exact-lineage retrieval;
- terminal reopen storage rejection;
- generic-overlay readback unusable;
- exact readback and request-binding mismatch fail closed;
- exact result key/non-authority/privacy boundary;
- no IP-13F or HTTP dependency;
- bounded evaluator/invalidate/submit/retrieve call-site counts and no retry.

The targeted run passed all ten test methods after the additive correction case was included.

## 8. Composer receipt

Both vendor locators were absent, so Composer Case B ran exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Receipt:

- exit: `0`
- operations: `114 installs / 0 updates / 0 removals`
- scripts: disabled
- plugins: disabled
- retry: none

Manifest identities before and after bootstrap:

- `composer.json`: `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`: `66327f584d3961c2b53391bb012047dda9cc9d23`

Both manifest blobs remained unchanged.

## 9. Targeted PHPUnit receipt

Exactly one attempt ran from `services/backend-laravel/`:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

Receipt:

- PHPUnit: `11.5.55`
- runtime: `PHP 8.5.3`
- exit: `0`
- tests: `10`
- assertions: `152`
- failures: `0`
- errors: `0`
- warnings: `0`
- deprecations: `1`
- result: `OK, but there were issues!`
- retry: none
- post-run adapter/test correction: none

The authorized output did not expand the retained deprecation source. The exercised adapter/test blobs are the final blobs reported in Section 3.

No other Unit or Feature test, full suite, coverage, mutation, Artisan, route listing, migration, generator, server, HTTP/client, external database probe, provider/network product operation, production operation or real/private-data operation ran.

## 10. Static check and publication state

Exactly one authorized command is consumed after final authoring:

`git diff --check`

Receipt: `PASS`.

At immutable publication, tracked/staged changes must be `0 / 0`. The candidate must preserve exactly the three paths in Section 2, the after blobs in Section 3, the unchanged original R12 result and the unchanged Composer manifest identities.

## 11. Retained boundaries and next gate

The correction changes no IP-13A, IP-13D, IP-13E, IP-13F, evaluator, Common Authority, route, controller, Feature test, migration, configuration/provider/bootstrap, Composer manifest, client/provider/network or HTTP surface.

All result authority and permission fields remain false, including source authority, Match authority, permission and bearer capability. No source evidence is repaired, no source purpose satisfaction is inferred and no production or real/private-data authority is created.

HTTP remains deferred. Publication is not acceptance. A fresh independent reviewer must issue ACCEPT or REJECT before any merge, movement of `main`, HTTP work or successor task.
