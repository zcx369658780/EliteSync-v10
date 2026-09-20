# EliteSync v10｜Next IP-13I-R12-R2 Canonical Match Derived-Purpose Binding Correction Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT THREE-PATH CORRECTION ON FROZEN R12 CANDIDATE — ONE TARGETED UNIT ATTEMPT — NO PERSISTENCE / IP-13E / IP-13F / HTTP CHANGES — FRESH INDEPENDENT REVIEW REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication main:
`250b8c70b7eb92aec20231f38e7c078e9615b5d5`

Accepted R12-R1 result blob:
`84cac5160f2ae81abe21b689eb9baad4502e1b0d`

R12-R1 acceptance blob:
`8ccaaffa4f3ac54c93be33218b32fb40e0a2180f`

R12 independent rejection blob:
`000290eaf9a352dedaf08b6668b8d29806fcf1c0`

Frozen rejected R12 candidate:
`c18d79c968dddf3a26c4d189f783a1354a4fca86`

Frozen candidate tree:
`eecc327c1a3b3f0f332a648c42d04448a60978a7`

## 1. Objective

Correct only the accepted derived-purpose binding defect on top of the exact frozen R12 candidate.

The corrected Canonical Match derived record must use:

`bindings.purpose = payload.protected_use_scope`

and its lifecycle-basis `purpose` must use the same:

`payload.protected_use_scope`.

The source proposal remains untouched:

- `proposal.required_bindings.purpose` remains its original value;
- `proposal.source_evidence.bindings.purpose` remains its original value;
- the evaluator receives the original source proposal/evidence;
- a semantic purpose mismatch remains able to produce:
  `UNKNOWN / PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE`.

No other R12 adapter behavior is to be redesigned.

## 2. Mandatory authority and topology gates

Before any tracked write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R12-R2 task.
4. Require `origin/main` to equal that exact task-publication commit.
5. Read this task.
6. Read accepted R12-R1 result and acceptance.
7. Do NOT merge or transplant the frozen rejected R12 candidate to main.
8. Create one isolated correction branch/worktree from exactly:
   `c18d79c968dddf3a26c4d189f783a1354a4fca86`
9. Verify:
   - HEAD = `c18d79c968dddf3a26c4d189f783a1354a4fca86`
   - sole parent = `7df2a86046bf429f5f4e16c15b13230cde070404`
   - tree = `eecc327c1a3b3f0f332a648c42d04448a60978a7`
10. Verify all fixed blobs in Section 3.
11. Verify the new correction-result path is absent.
12. Stop rather than adapt if any identity differs.

Recommended correction branch:

`review/next-ip-13i-r12-r2-derived-purpose-binding-correction-v0-1`

The correction candidate's sole parent must remain:

`c18d79c968dddf3a26c4d189f783a1354a4fca86`

It is intentionally not parented by current main.

## 3. Exact authorized read scope / fixed inputs

From task-publication main, read only:

1. `AGENTS.md`
2. this R12-R2 task
3. accepted R12-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R12_R1_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`
4. R12-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R12_R1_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
5. R12 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R12_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
6. R11 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R11_CANONICAL_MATCH_PERSISTENCE_FAMILY_IMPLEMENTATION_ACCEPTANCE_V0_1.md`

From frozen R12 candidate `c18d79c968dddf3a26c4d189f783a1354a4fca86`, read only:

7. `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
8. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
9. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_PERSISTENCE_APPLICATION_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`
10. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
11. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
12. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
13. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
14. `services/backend-laravel/composer.json`
15. `services/backend-laravel/composer.lock`
16. `services/backend-laravel/phpunit.xml`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R12-R1 result:
  `84cac5160f2ae81abe21b689eb9baad4502e1b0d`
- R12-R1 acceptance:
  `8ccaaffa4f3ac54c93be33218b32fb40e0a2180f`
- R12 rejection:
  `000290eaf9a352dedaf08b6668b8d29806fcf1c0`
- R11 acceptance:
  `64fc0f3b1e2daf4d901382e2a406d2f1df6b1f7c`
- frozen adapter:
  `f1f151b4cb96352521b0823072857153e2ccb4e4`
- frozen Unit test:
  `c99ea59a270e4ff23a3b9fa016eec95db3cccdc3`
- frozen R12 result:
  `524d67ba1b46724e41cb350317f4310304a775e2`
- frozen IP-13A:
  `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`
- frozen IP-13D:
  `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`
- frozen IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- frozen evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- `composer.json`:
  `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
- `composer.lock`:
  `66327f584d3961c2b53391bb012047dda9cc9d23`
- `phpunit.xml`:
  `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`

No repository enumeration or unrelated source read is authorized.

## 4. Exact tracked write scope

Relative to frozen R12 candidate `c18d79c…`, exactly three tracked paths may change.

### MODIFY

1. `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`

2. `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

### CREATE

3. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

No other tracked path may change.

The original R12 result must remain blob-identical:

`524d67ba1b46724e41cb350317f4310304a775e2`

Do NOT modify:

- IP-13A;
- IP-13D;
- IP-13E;
- IP-13F;
- Canonical Match evaluator;
- Common Authority;
- routes/controllers/Feature tests;
- migrations/config/providers/bootstrap;
- Composer manifests;
- client/provider/network code.

## 5. Exact adapter correction

In `CanonicalMatchPersistenceApplicationAdapter::buildRecord()`, correct only the derived-purpose mapping.

### Before

The rejected candidate uses source-required purpose in both:

- lifecycle basis;
- derived record bindings.

### After

Use exactly:

`$payload['protected_use_scope']`

for:

- lifecycle-basis `purpose`;
- derived `bindings['purpose']`.

Do not change:

- actor;
- actor_role;
- subject;
- audience;
- participants;
- aggregate context;
- authority owner/scope;
- terminal;
- any Match payload field;
- currentness/freshness aggregation;
- evaluator flow;
- invalidation flow;
- submit/retrieve ordering;
- result key set.

Retrieval request purpose remains sourced from:

`$record['bindings']['purpose']`

and therefore automatically uses the corrected derived protected-use scope.

## 6. Source non-mutation rule

Do not modify or normalize:

- `proposal.required_bindings.purpose`;
- `proposal.source_evidence.bindings.purpose`;
- proposal/participation/slot arrays before evaluator invocation.

The evaluator must continue to observe the original source mismatch.

The correction occurs only in derived-record construction after evaluator semantics have been established.

Preserve:

`DERIVED_RECORD_PURPOSE != SOURCE_PURPOSE_SATISFACTION`

`DERIVED_RECORD_PURPOSE != PERMISSION`

## 7. Required added targeted test case

Extend only the existing:

`services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

Add a case with a structurally valid proposal where:

- `protected_use_scope = SYNTHETIC_MATCH_REVIEW`;
- source `required_bindings.purpose` is a different non-empty value, e.g. `SYNTHETIC_OTHER_PURPOSE`;
- source-evidence `bindings.purpose` remains the same original mismatched source value;
- all Common Authority shapes/revision binding requirements remain valid.

Prove:

1. input request remains byte/array-identical after adapter call;
2. evaluator result is represented as:
   - `match_classification = UNKNOWN`;
   - `reason_categories = [PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE]`;
3. storage disposition is accepted/retrievable:
   - expected first store `STORED_NEW`;
   - it must NOT be `INVALID_RECORD_REJECTED`;
4. `match_payload.protected_use_scope = SYNTHETIC_MATCH_REVIEW`;
5. derived record/lifecycle correlation is built with purpose `SYNTHETIC_MATCH_REVIEW`;
6. exact returned result contains no source-purpose normalization claim;
7. source request/evidence purpose remains `SYNTHETIC_OTHER_PURPOSE`;
8. projection readback follows existing R11 aggregation:
   - pending proposal with early proposal-only dependency vector is incomplete;
   - record top-level currentness/freshness therefore remain `null`;
   - exact-lineage retrieval may return an exact bound projection but application/persistence resolution is not `RESOLVED`;
   - `materialized_projection_usable = false`;
   - condition is `CANONICAL_MATCH_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`;
9. source authority, Match authority, permission and bearer capability remain false.

Do not change R11 currentness/freshness semantics to make this case usable.

## 8. Existing R12 proof preservation

All existing R12 Unit obligations remain.

In particular preserve proof for:

- ordinary PENDING;
- terminal MUTUALLY_ACCEPTED / DECLINED / WITHDRAWN;
- semantic UNKNOWN cases;
- strict structural rejection;
- missing participation/slot domain UNKNOWN;
- cross-proposal/wrong-participant UNKNOWN;
- duplicate-slot bounded reasons;
- sticky dependency invalidation;
- repeated invalidation exact duplicate;
- collision/unknown invalidation-target rejection;
- incomparable exact-lineage retrieval;
- terminal reopen storage rejection;
- generic overlay readback unusable;
- exact readback mismatch fail-closed;
- non-authority/HTTP/IP-13F absence;
- source call-site counts and no retry.

No second test file.

## 9. Same-worktree vendor bootstrap

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist:

- Composer Case A;
- run no Composer command.

Otherwise run exactly once from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Composer Case B.

No retry.
No update.
No scripts/plugins.

Manifest/lock blobs must remain unchanged.

## 10. Exact runtime command budget

Run exactly ONE targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`

No retry.

Do NOT run:

- any other Unit or Feature test;
- full suite;
- coverage;
- mutation;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP/client;
- database external probe;
- provider/network product operation;
- production;
- real/private-data operation.

After final authoring, run exactly one:

`git diff --check`

No other project runtime command is authorized.

## 11. Failure handling

If the one targeted PHPUnit attempt fails:

- do not rerun;
- static correction after the consumed run is permitted only inside the exact three-path write scope;
- do not claim runtime PASS after any post-run correction;
- publish immutable correction candidate with runtime status `RETAINED_UNKNOWN`;
- fresh independent review may authorize a verification-only rerun.

If correction requires:

- IP-13A/IP-13D change;
- IP-13E/IP-13F change;
- evaluator/Common Authority change;
- fourth tracked path;
- HTTP work;

STOP and record the blocker.

## 12. Correction result document

Create exactly:

`docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_DERIVED_PURPOSE_BINDING_CORRECTION_IMPLEMENTATION_RESULT_V0_1.md`

Record:

- task-publication main;
- frozen R12 base SHA/parent/tree;
- correction branch;
- candidate SHA/sole parent/tree/ahead-behind after publication;
- exact three-path diff;
- all fixed input blobs;
- pre/post adapter and Unit-test blobs;
- unchanged original R12 result blob;
- exact derived-purpose code correction;
- source-purpose non-mutation;
- purpose-mismatch domain-UNKNOWN proof;
- accepted storage disposition;
- currentness/freshness `null` behavior for incomplete pending dependency vector;
- unusable readback/materialization condition;
- preservation of existing R12 proof matrix;
- Composer Case A/B receipt;
- exact one PHPUnit receipt;
- tests/assertions/failures/errors;
- warnings/deprecations;
- manifest/lock identities;
- one `git diff --check` receipt;
- tracked/staged counts;
- retained non-authorities;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification:

`IP-13I-R12-R2 DERIVED PURPOSE BINDING CORRECTED — DERIVED MATCH PURPOSE USES PAYLOAD PROTECTED-USE SCOPE WHILE SOURCE REQUIRED PURPOSE REMAINS UNMODIFIED — PURPOSE-MISMATCH PROPOSAL REMAINS DOMAIN UNKNOWN / PROPOSAL_NOT_CURRENT_FRESH_AUTHORITATIVE AND IS ACCEPTED BY R11 PERSISTENCE — INCOMPLETE PENDING DEPENDENCY VECTOR REMAINS UNUSABLE WITHOUT STORAGE REJECTION — ALL OTHER R12 ORDINARY/STICKY-INVALIDATION/DUPLICATE/INCOMPARABLE/PRIVACY/NON-AUTHORITY PROOFS PRESERVED — HTTP STILL DEFERRED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
