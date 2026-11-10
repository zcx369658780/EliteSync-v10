# EliteSync v10｜IP-13I-R7-R3 Targeted Failure Independent Root-Cause Review｜v0.1

Status: `REVIEW COMPLETE — R7-R3 NOT YET ACCEPTED — REQUEST-STATE CORRECTION VERIFIED STATICALLY — SOLE TARGETED FAILURE IS FEATURE EXPECTATION DEFECT FOR UNKNOWN MATERIALIZATION — TWO-PATH TEST-CORRECTION SUCCESSOR AUTHORIZED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh review base / current `origin/main`: `222af98133035bef3d73cd9109beacbab71aadf1`

Reviewed correction branch:
`review/next-ip-13i-r7-r3-request-state-vocabulary-correction-v0-1`

Reviewed candidate:
`47d5d474e361d5c6694ecfc453734d7df855c8c9`

Candidate sole parent:
`cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

Candidate tree:
`c752807871d8365ce5cb0085f915da50608e6ae7`

Candidate result blob:
`293dfa4cd94d5b894253bf38f74850f2621c5ae5`

## 1. Candidate scope and immutable identities

Independent comparison established that the candidate is exactly one commit ahead / zero behind the frozen rejected R7 base and changes exactly three paths:

1. controller
2. existing targeted Feature test
3. correction implementation result

Final candidate blobs:

- controller:
  `3a74ae1da7a752de61c47f055c4fab1a8b900e4c`
- targeted Feature test:
  `feb20e1df1fc4a17db60f0adf1adf3e46ecf8c09`
- correction result:
  `293dfa4cd94d5b894253bf38f74850f2621c5ae5`

Frozen route remains:

`37c3cd0c193f412fef7c03526fdc1926ad8535b5`

No route/IP-13F/R5 source change is part of the candidate.

## 2. R7-R2 vocabulary repair is implemented correctly

The controller now accepts only:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

and no longer accepts the legacy shorthand as valid schema.

The targeted run reports no failure in the dedicated shorthand-rejection test.

No evidence from this run contradicts the accepted R7-R2 decision.

The request-state correction is therefore not the cause of the remaining failure.

## 3. Exact targeted receipt

The R7-R3 candidate consumed exactly one targeted Feature attempt:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

Receipt:

- exit `1`
- `6 tests / 223 assertions`
- `1 failure / 0 errors`
- `0 warnings / 2 deprecations`

The sole failure is in:

`test_ready_not_ready_and_unknown_remain_domain_only_privacy_minimal_200_results`

The HTTP response is already successful, but the test expected:

`materialized_projection_usable = true`

and observed:

`materialized_projection_usable = false`.

No retry or post-run assertion correction occurred.

## 4. Root cause

The remaining failure is a Feature-test expectation defect.

Accepted R6 explicitly states:

- `READY | NOT_READY | UNKNOWN` are domain classifications independent of materialization;
- a completed adapter call may return HTTP `200` regardless of classification or projection usability;
- `materialized_projection_usable` is copied from the R5 adapter;
- projection unusable/missing/mismatched remains HTTP `200` and must not rewrite classification.

The accepted R5 adapter constructs generic RR03 currentness/freshness using dependency summaries.

For an exact:

`UNKNOWN_PREREQUISITE_SET`

the adapter's dependency summary returns `null` for generic currentness/freshness because the prerequisite-set state is not the known-set state.

The accepted persistence resolver requires:

- `currentness === true`
- `freshness === true`

for `RESOLVED`.

If currentness is not established, resolution is `UNKNOWN`.

The R5 adapter therefore legitimately returns for this synthetic unknown-set case:

- `readiness_classification = UNKNOWN`
- `materialized_projection_usable = false`
- `condition = RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`

while preserving HTTP `200` at the R7 boundary.

This behavior is consistent with the accepted R6 contract.

## 5. What is not defective

No evidence requires changing:

- controller request-state vocabulary;
- controller success mapping;
- HTTP status mapping;
- route;
- R5 adapter;
- evaluator;
- IP-13A/IP-13D/IP-13E/IP-13F;
- privacy boundary;
- authentication/authority boundary.

The controller must not be changed merely to make UNKNOWN materialization appear usable.

`UNKNOWN != MATERIALIZED_USABLE`

and:

`HTTP 200 != MATERIALIZATION SUCCESS`.

## 6. Exact required Feature expectation

The targeted Feature test should distinguish the three domain classifications.

For READY:

- HTTP 200
- classification READY
- materialized projection usable = true
- condition = `EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

For NOT_READY:

- HTTP 200
- classification NOT_READY
- materialized projection usable = true
- condition = `EXACT_PRIVACY_MINIMAL_RR03_PROJECTION_MATERIALIZED`

For UNKNOWN produced by `UNKNOWN_PREREQUISITE_SET`:

- HTTP 200
- classification UNKNOWN
- materialized projection usable = false
- condition = `RR03_PROJECTION_READBACK_UNUSABLE_OR_MISMATCHED`
- bounded reason categories include exactly the expected unknown-prerequisite-set reason according to the existing adapter result.

The test must continue proving that materialization does not rewrite the domain classification.

## 7. Candidate disposition

R7-R3 candidate `47d5d474e361d5c6694ecfc453734d7df855c8c9` is not yet accepted because its targeted Feature suite does not pass.

However:

- its controller correction is not rejected;
- its route remains valid and frozen;
- its shorthand rejection behavior is not rejected;
- no new contract review is required.

A correction successor may be based directly on this exact R7-R3 candidate and modify only the existing Feature test plus a new correction result document.

## 8. Next gate

Next task:

`IP-13I-R7-R4 UNKNOWN MATERIALIZATION FEATURE-EXPECTATION CORRECTION IMPLEMENTATION`

It must:

- use R7-R3 candidate as sole parent;
- leave controller blob `3a74ae1da7a752de61c47f055c4fab1a8b900e4c` unchanged;
- leave route blob `37c3cd0c193f412fef7c03526fdc1926ad8535b5` unchanged;
- modify only the existing Feature test;
- create one correction result;
- run exactly one targeted Feature attempt;
- perform no contract or production-source expansion.

Final classification:

`IP-13I-R7-R3 TARGETED FAILURE ROOT CAUSE ESTABLISHED — STATE-VOCABULARY CORRECTION RETAINED — SOLE FAILURE = FEATURE TEST INCORRECTLY REQUIRES MATERIALIZED_USABLE TRUE FOR UNKNOWN_PREREQUISITE_SET — ACCEPTED R6/R5 SEMANTICS REQUIRE UNKNOWN DOMAIN CLASSIFICATION TO REMAIN INDEPENDENT FROM MATERIALIZATION — R7-R3 NOT YET ACCEPTED — TWO-PATH TEST-CORRECTION SUCCESSOR AUTHORIZED`
