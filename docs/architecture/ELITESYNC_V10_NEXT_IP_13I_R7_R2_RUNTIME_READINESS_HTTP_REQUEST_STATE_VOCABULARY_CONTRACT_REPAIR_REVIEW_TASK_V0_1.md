# EliteSync v10｜Next IP-13I-R7-R2 Runtime Readiness HTTP Request-State Vocabulary Contract Repair Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CONTRACT REPAIR REVIEW — EXACTLY ONE RESULT DOCUMENT — NO CODE / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `e9962fa6ecee5c3821646efe9033d8ab713cfe77`

R7 frozen failed candidate: `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`

R7-V1 verification result blob: `2ef16a0cb0c982edcaab51f977413b456ad51e85`

R7-V1 independent root-cause review commit: `e9962fa6ecee5c3821646efe9033d8ab713cfe77`

## 1. Objective

Repair exactly one accepted transport-contract defect:

the dedicated Runtime Readiness HTTP request currently specifies:

`prerequisite_set.state = KNOWN | UNKNOWN`

while the accepted R5 Runtime Readiness evaluator/application boundary requires the exact state literals:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

This task is REVIEW ONLY.

It must decide the corrected request-state vocabulary and the exact minimal later implementation correction scope.

It must not implement the repair.

## 2. Established failure evidence

The exact immutable R7 candidate was verified once and failed:

- candidate:
  `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`
- tree:
  `1079877dc5bba0813ccdd8a5d5c888de3b51a431`
- targeted attempt:
  `5 tests / 132 assertions / 2 failures / 0 errors`
- both intended adapter-reaching scenarios received HTTP `400`
- no correction or retry occurred.

The independently established root cause is:

- R6 accepted HTTP state literals `KNOWN | UNKNOWN`;
- R7 implemented and tested those literals;
- R5 adapter directly checks against evaluator constants:
  - `KNOWN_PREREQUISITE_SET`
  - `UNKNOWN_PREREQUISITE_SET`;
- therefore the controller-valid request is rejected by the adapter synthetic boundary.

Do not reopen unrelated failure hypotheses without contradictory evidence.

## 3. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Require `origin/main` to equal the publication commit containing this task.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the result path in Section 5 is absent.
6. Verify all fixed inputs in Section 4.
7. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r7-r2-request-state-vocabulary-contract-repair-v0-1`

No repository enumeration or unrelated source discovery.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`
2. this R7-R2 task
3. `docs/architecture/ELITESYNC_V10_IP_13I_R7_V1_VERIFIED_FAIL_INDEPENDENT_ROOT_CAUSE_REVIEW_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_IP_13I_R7_V1_IMMUTABLE_CANDIDATE_VERIFICATION_RESULT_V0_1.md`
5. accepted R6 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_APPLICATION_ADAPTER_TO_TRANSPORT_HTTP_ENTRY_CONTRACT_REVIEW_RESULT_V0_1.md`
6. R6 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R6_RUNTIME_READINESS_HTTP_ENTRY_CONTRACT_REVIEW_ACCEPTANCE_V0_1.md`
7. R7 implementation task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R7_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_TASK_V0_1.md`
8. exact accepted evaluator source:
   `services/backend-laravel/app/Domain/RuntimeReadinessDerivedEvaluator.php`
9. exact accepted R5 application adapter:
   `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`
10. frozen R7 controller from exact candidate `cf8f0fda26ed2735811e55388fa90fc4d6d909ea`:
    `services/backend-laravel/app/Http/Controllers/Api/V2/RuntimeReadiness/RuntimeReadinessEvaluationController.php`
11. frozen R7 targeted Feature test from exact candidate:
    `services/backend-laravel/tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`
12. frozen R7 implementation result from exact candidate:
    `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_HTTP_ENTRY_IMPLEMENTATION_RESULT_V0_1.md`

Expected key blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R7-V1 verification result:
  `2ef16a0cb0c982edcaab51f977413b456ad51e85`
- accepted R6 result:
  `5cffb288f4daba5e52e07fb84000ed8d1d5d994d`
- R6 acceptance:
  `0ed30053987de03e44677819a32315ffe8899999`
- evaluator:
  `1d5918d890d5eb753032b24540a4a133107c811f`
- R5 adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`
- frozen controller:
  `95272cf7d63cf8cdf3db29eaf41c4c3450836f16`
- frozen targeted Feature test:
  `2f885b61519225604c27e9fb0ed7c7b25f138612`
- frozen R7 implementation result:
  `d596c0e1758c34b2697b59f15302a89bf4563e27`

## 5. Exact tracked write scope

Create exactly one path:

`docs/architecture/ELITESYNC_V10_IP_13I_R7_R2_RUNTIME_READINESS_HTTP_REQUEST_STATE_VOCABULARY_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`

No other tracked file may change.

No code, route, controller, test, R6 result, R6 acceptance, R5 source, R7 result or verification result may be modified.

## 6. Required decision — corrected state vocabulary

The review must choose exactly one:

### Option A — exact R5 literals at HTTP boundary

HTTP request accepts only:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

The controller passes the decoded state unchanged to the R5 adapter.

### Option B — transport shorthand with explicit mapping

HTTP request accepts:

- `KNOWN`
- `UNKNOWN`

and controller explicitly maps them to the accepted R5 literals before adapter dispatch.

### Option C — blocked

Neither A nor B can be safely accepted with current evidence.

Preferred direction is **Option A** because it:

- restores the R6 statement that the endpoint accepts the exact R5 synthetic input;
- adds no transport→domain translation semantics;
- requires no mapper/service file;
- does not change the R5 adapter/evaluator;
- minimizes implementation delta.

The review must independently confirm or reject that preferred direction.

## 7. If Option A is selected

The corrected request contract must state exactly:

`prerequisite_set.state` enum:

- `KNOWN_PREREQUISITE_SET`
- `UNKNOWN_PREREQUISITE_SET`

All other R6 request keys/types and nested semantics remain unchanged.

The result must explicitly state that:

- `KNOWN` is rejected as `INVALID_REQUEST_SCHEMA`;
- `UNKNOWN` is rejected as `INVALID_REQUEST_SCHEMA`;
- no compatibility alias is accepted in this synthetic/dev-test slice;
- no translation occurs before R5 adapter dispatch.

## 8. If Option B is selected

The result must explain why a new transport/domain mapping is preferable despite the existing R6 exact-input claim.

It must fix:

- exact mapping table;
- whether response/domain vocabulary remains full R5 literals or readiness classifications only;
- unknown/malformed mapping behavior;
- why mapping creates no authority;
- exact implementation location.

Do not invent a new mapper file unless current evidence proves it necessary.

## 9. Scope of contract repair

The result must identify exactly which previously accepted statements are superseded.

At minimum address:

- R6 Section 3.1 state enum;
- R7 implementation-task Section 8 state rule;
- any request examples/Feature fixture assumptions dependent on those literals.

Do not rewrite unrelated R6/R7 sections.

The result must preserve unchanged:

- endpoint path;
- top-level request keys;
- member_evidence schema;
- binding/evidence/revision structure;
- synthetic marker;
- privacy-minimal five-field response;
- READY / NOT_READY / UNKNOWN readiness classification;
- 200/400/426/500 separation;
- secure.transport placement;
- authentication/session/token retained UNKNOWN;
- IP-13F five-family non-participation;
- no global revision;
- no LWW/arrival-order authority;
- exact synthetic-only boundary.

## 10. Required future implementation-correction scope

If A or B is selected, define one exact bounded later correction task.

The review must decide whether correction requires exactly:

1. MODIFY frozen R7 controller successor;
2. MODIFY frozen R7 targeted Feature test successor;
3. CREATE one correction implementation result document;

with `routes/api.php` retained blob-identical if the route itself needs no change.

If route source needs no semantic correction, do not include it in the future write scope merely to preserve a prior four-path pattern.

Do not authorize changes to:

- R5 adapter;
- Runtime Readiness evaluator;
- IP-13A/IP-13D/IP-13E/IP-13F;
- generic HTTP controller/test;
- middleware/providers/bootstrap/config;
- Composer manifests;
- migrations;
- client/provider/network;
- auth/session/token;
- legal/Safety;
- production/real-data surfaces.

## 11. Required future targeted verification

The result must define the exact one future targeted Feature test command for the corrected implementation:

`vendor/bin/phpunit tests/Feature/Api/V2/RuntimeReadinessEvaluationTest.php`

The corrected test must additionally prove the old incorrect state literals fail closed if Option A is selected.

No second test file.

## 12. Review-only prohibition

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migrations;
- generators;
- server;
- HTTP/client;
- database probe;
- provider/network;
- production;
- real/private-data operations.

Do not modify candidate code.

## 13. Result document requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path write scope;
- all fixed input blobs actually read;
- V1 failure evidence;
- exact evaluator state constants;
- exact R5 adapter state gate;
- A/B/C decision;
- exact corrected request-state contract;
- exact superseded R6/R7 statements;
- preserved unaffected R6/R7 semantics;
- exact later implementation correction write scope;
- exact future targeted command;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected Option A success classification:

`IP-13I-R7-R2 REVIEW COMPLETE — OPTION A ACCEPTED — HTTP REQUEST STATE VOCABULARY REPAIRED TO KNOWN_PREREQUISITE_SET|UNKNOWN_PREREQUISITE_SET — R6/R7 SHORTHAND KNOWN|UNKNOWN SUPERSEDED — NO TRANSPORT→DOMAIN TRANSLATION — ALL OTHER R6/R7 HTTP/PRIVACY/IP-13F SEMANTICS RETAINED — MINIMAL LATER CONTROLLER+FEATURE-TEST+RESULT CORRECTION SCOPE FIXED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
