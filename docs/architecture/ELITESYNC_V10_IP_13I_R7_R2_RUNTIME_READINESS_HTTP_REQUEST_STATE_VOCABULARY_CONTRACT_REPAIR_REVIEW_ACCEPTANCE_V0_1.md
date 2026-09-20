# EliteSync v10｜IP-13I-R7-R2 Runtime Readiness HTTP Request-State Vocabulary Contract Repair Review Acceptance｜v0.1

Status: `ACCEPTED — OPTION A EXACT R5 LITERALS AT HTTP BOUNDARY — R6/R7 SHORTHAND SUPERSEDED — NO TRANSPORT→DOMAIN TRANSLATION — MINIMAL THREE-PATH CORRECTION SCOPE ACCEPTED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

R7-R2 task-publication commit: `04c6d78ad5217d51b6e3d6d083acf982b9619825`

Accepted review branch: `review/next-ip-13i-r7-r2-request-state-vocabulary-contract-repair-v0-1`

Accepted immutable candidate: `41b0d4df9618506d7bb9e280c8ba61baaab48865`

Accepted candidate tree: `d59df1462e1e287c0cf9819de4707f879eb5a2a4`

Accepted result blob: `29b007b2cb1a2e38ef28c762fee86b5a2354f641`

Integrated main commit: `82b1bc9cf35f35e1f0c7052feab2e30c0a59fa78`

## 1. Independent acceptance

Fresh review established:

- pre-integration `origin/main = 04c6d78ad5217d51b6e3d6d083acf982b9619825`;
- candidate sole parent equals that exact task authority;
- candidate is exactly one commit ahead / zero behind;
- candidate adds exactly one authorized document;
- result blob is exactly `29b007b2cb1a2e38ef28c762fee86b5a2354f641`;
- every fixed input object recorded in the result matches the actual Git object.

The exact accepted result was transplanted to main unchanged.

## 2. Accepted vocabulary repair

Accepted decision:

`OPTION_A_EXACT_R5_LITERALS_AT_HTTP_BOUNDARY`

The dedicated endpoint request field:

`prerequisite_set.state`

accepts only:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

The controller must pass that decoded value unchanged to the accepted R5 adapter.

No transport→domain translation, normalization, shorthand alias or compatibility bridge is accepted.

The prior shorthand values:

- `KNOWN`
- `UNKNOWN`

are superseded for this request field and must fail before adapter dispatch as:

HTTP `400 / INVALID_REQUEST_SCHEMA`.

## 3. Accepted source-of-truth relationship

This repair aligns the HTTP request contract with the already accepted R5 vocabulary:

- `RuntimeReadinessDerivedEvaluator::SET_KNOWN = KNOWN_PREREQUISITE_SET`
- `RuntimeReadinessDerivedEvaluator::SET_UNKNOWN = UNKNOWN_PREREQUISITE_SET`

The R5 adapter's strict state gate remains unchanged.

No source/domain authority is created by exposing the exact accepted literals at the HTTP boundary.

## 4. Narrow supersession

Only these prior assumptions are superseded:

- R6 Section 3.1 shorthand request-state enum;
- R7 implementation-task Section 8 shorthand request-state rule;
- frozen R7 controller shorthand allowlist;
- frozen R7 Feature fixture shorthand request values.

All other R6/R7 semantics remain accepted and unchanged, including:

- endpoint path;
- two-key top-level request shape;
- member/evidence/revision structures;
- synthetic-only marker/boundary;
- single adapter dispatch/no retry;
- five-field privacy-minimal success response;
- readiness classification `READY | NOT_READY | UNKNOWN`;
- 200/400/426/500 transport/domain separation;
- secure.transport placement;
- storage/materialization mapping;
- authentication/session/token retained UNKNOWN;
- IP-13F five-family non-participation;
- generic application-envelope endpoint;
- no global revision;
- no LWW/arrival-order authority;
- no production/deployment/real-private-data authority.

## 5. Accepted later correction scope

A separately authorized implementation correction may be based on the exact frozen R7 candidate:

`cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

and change exactly three paths relative to that frozen candidate:

1. MODIFY:
   `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`

2. MODIFY:
   `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

3. CREATE:
   `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_REQUEST_STATE_VOCABULARY_CONTRACT_REPAIR_IMPLEMENTATION_RESULT_V0_1.md`

The frozen route must remain blob-identical:

`services/backend-laravel/routes/api.php = 37c3cd0c193f412fef7c03526fdc1926ad8535b5`

No change is accepted to R5 adapter/evaluator, IP-13A/D/E/F, generic HTTP controller/test, middleware/providers/bootstrap/config, Composer manifests, migrations, client/provider/network, authentication/session/token, legal/Safety, production or real/private-data surfaces.

## 6. Future targeted verification

The corrected successor must use exactly the existing targeted Feature file and one targeted command:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

The corrected test must additionally prove:

- `KNOWN_PREREQUISITE_SET` reaches the intended known-set paths;
- `UNKNOWN_PREREQUISITE_SET` reaches the intended unknown-set path;
- old `KNOWN` fails with HTTP 400 / `INVALID_REQUEST_SCHEMA` before dispatch;
- old `UNKNOWN` fails with HTTP 400 / `INVALID_REQUEST_SCHEMA` before dispatch.

## 7. Acceptance classification

`IP-13I-R7-R2 ACCEPTED — OPTION A EXACT R5 REQUEST-STATE LITERALS FIXED — KNOWN|UNKNOWN SHORTHAND SUPERSEDED ONLY FOR prerequisite_set.state — NO TRANSPORT→DOMAIN TRANSLATION — ALL OTHER R6/R7 HTTP/PRIVACY/IP-13F SEMANTICS RETAINED — THREE-PATH CORRECTION SCOPE ACCEPTED`
