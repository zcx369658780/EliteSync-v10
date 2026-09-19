# EliteSync v10｜Next IP-13I-R2 Backend Vertical-Slice Integration Reassessment Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY REASSESSMENT — NO IMPLEMENTATION AUTHORITY — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `996cef44589d174ceb9464ce622d38e5e5b6dedd`

## 1. Objective

Reassess the EliteSync v10 backend vertical slice after IP-13I-R1 repaired all six domain-evaluator locators and the core-harness acceptance/runtime evidence.

This review must determine whether the accepted repository evidence is now sufficient to move from:

`domain semantics + core harness`

and

`logical persistence → physical dev/test adapter → application interface → transport-neutral envelope → Laravel HTTP`

into a first bounded domain-specific v2 API implementation slice.

This task is document-only. It does not create or modify any domain source, persistence source, route, controller, test, authentication, client, production or data-processing path.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the single output path below is absent.
6. Read only the exact evidence paths listed in Section 3.
7. Stop rather than adapt if base/path differs.

Recommended branch:

`review/next-ip-13i-r2-backend-vertical-slice-integration-reassessment-v0-1`

## 3. Exact authorized evidence set

Read only:

1. `AGENTS.md`
2. IP-13I result
3. IP-13I acceptance
4. IP-13I-R1 result
5. IP-13I-R1 acceptance
6. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
7. `services/backend-laravel/app/Domain/RuntimeReadinessDerivedEvaluator.php`
8. `services/backend-laravel/tests/Unit/RuntimeReadinessDerivedEvaluatorTest.php`
9. Runtime Readiness result
10. Runtime Readiness acceptance
11. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
12. Canonical Match acceptance
13. `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
14. Product Connection acceptance
15. `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php`
16. Messaging Consent / Conversation acceptance
17. `services/backend-laravel/app/Domain/CalmHomeReadOnlyCompositionEvaluator.php`
18. Calm Home acceptance
19. `services/backend-laravel/app/Domain/NotificationEligibilityPrivacyMinimalPayloadEvaluator.php`
20. Notification acceptance
21. `services/backend-laravel/app/Domain/CoreDomainSemanticIntegrationHarness.php`
22. `services/backend-laravel/tests/Unit/CoreDomainSemanticIntegrationHarnessTest.php`
23. Core-harness acceptance
24. IP-13A acceptance
25. IP-13B acceptance
26. IP-13D acceptance
27. IP-13E acceptance
28. IP-13F acceptance
29. IP-13H acceptance
30. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
31. `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
32. `services/backend-laravel/app/Http/Controllers/Api/V2/Contracts/TransportEnvelopeController.php`
33. `services/backend-laravel/routes/api.php`
34. IP-08 cross-domain interface plan
35. IP-09 logical persistence plan

Use the exact paths recovered in accepted IP-13I-R1. No discovery/search is authorized in R2.

## 4. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_BACKEND_VERTICAL_SLICE_INTEGRATION_REASSESSMENT_RESULT_V0_1.md`

No existing tracked file may change.

## 5. Reassessment questions

The result must answer:

1. Are all six domain evaluator implementations independently accepted and runtime-verified?
2. Does the accepted core harness provide runtime evidence across all six domain families?
3. Does that core-harness proof itself persist or transport domain outputs through IP-13A→IP-13H?
4. Does any accepted single runtime proof span domain evaluator → persistence → application → IP-13F → HTTP?
5. If not, is such one-shot proof required before beginning a first bounded domain-specific API slice, or can a domain-specific synthetic/dev-only slice itself be the next runtime bridge?
6. Which first domain is safest and most dependency-correct?
7. What exact operation should that first domain slice expose?
8. Should it use the generic application-envelope endpoint or a dedicated v2 domain route?
9. What source/domain evidence should it accept?
10. What persistence behavior should it use?
11. What authentication/actor-binding assumptions must remain prohibited?
12. What client/production gates remain after the first domain slice?

## 6. Runtime Readiness first-domain assessment

Reassess Runtime Readiness as the preferred first domain candidate.

At minimum establish whether its accepted evaluator semantics allow a bounded synthetic/dev-only route that:

- evaluates a complete explicit prerequisite set and member evidence;
- preserves `UNKNOWN` prerequisite-set semantics;
- preserves currentness and freshness independently;
- returns only descriptive readiness/projection evidence;
- does not create Match/Connection/Consent/Conversation/launch authority;
- does not infer authentication or real subject identity from HTTP;
- uses only conspicuous synthetic/test data in the implementation slice;
- can be persisted through the accepted dev/test persistence path without making storage authoritative;
- can be expressed through accepted application/transport semantics without changing IP-13F.

Determine whether the first slice should be:

A. a dedicated Runtime Readiness v2 endpoint; or
B. an application-envelope family/payload specialization behind the generic endpoint.

Select exactly one and justify.

## 7. Dedicated-route vs generic-envelope rule

If selecting a dedicated domain route, justify why it improves domain-specific contract clarity without creating a second authority model.

A dedicated route must still:
- reuse accepted evaluator semantics;
- preserve the same non-authority invariants;
- not bypass IP-13E/IP-13F semantics without explicit accepted justification;
- remain synthetic/dev-only initially;
- avoid authentication/session/token assumptions;
- avoid production persistence.

If selecting the generic envelope, define exactly how Runtime Readiness semantics map into one of the five accepted IP-13E/IP-13F families without inventing a sixth transport family.

If neither mapping is sound, select an intermediate adapter-review task instead.

## 8. Exact next-task decision

Output exactly one `NEXT_BOUNDED_TASK`.

If a first Runtime Readiness domain slice is ready, define:

- task name;
- exact purpose;
- exact semantic operation(s);
- exact expected route or envelope family;
- exact authorized source dependencies;
- maximum write scope;
- test type;
- expected runtime bridge;
- non-authorities;
- explicit exclusions.

Do not create the successor task.

If not ready, define the narrowest missing review/adapter task.

## 9. Required decision outputs

The result must contain:

- `DOMAIN_EVIDENCE_STATUS`
- `CORE_HARNESS_STATUS`
- `PERSISTENCE_TO_HTTP_STATUS`
- `FULL_DOMAIN_TO_HTTP_SINGLE_RUNTIME_STATUS`
- `FIRST_DOMAIN_SLICE_READINESS`
- `FIRST_DOMAIN_SELECTION`
- `CLIENT_INTEGRATION_STATUS`
- `PRODUCTION_READINESS_STATUS`
- `NEXT_BOUNDED_TASK`

Do not claim production readiness.

## 10. Prohibited operations

Do not:
- modify code/routes/controllers/tests/config;
- run Composer/PHPUnit/Artisan/route:list;
- run migrations/generators;
- execute runtime/domain code;
- access provider/network/client;
- access real/private data;
- change auth/session/token;
- perform legal/Safety work;
- perform production/deployment work;
- create the successor task.

## 11. Command budget

No runtime command is authorized.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance reads of exact authorized files are allowed.

## 12. Required result document

Record:

- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact one-file scope;
- result SHA-256/blob;
- exact evidence blobs read;
- domain evidence summary;
- core-harness scope;
- persistence→HTTP summary;
- single-runtime-gap analysis;
- Runtime Readiness first-domain analysis;
- dedicated-route vs generic-envelope decision;
- nine required decision outputs;
- exact successor-task boundary;
- retained non-authorities;
- `git diff --check`;
- fresh independent ACCEPT/REJECT requirement.

Expected successful classification if Runtime Readiness is ready:

`IP-13I-R2 BACKEND VERTICAL-SLICE INTEGRATION REASSESSMENT COMPLETE — DOMAIN EVALUATOR AND CORE-HARNESS EVIDENCE RESTORED — PERSISTENCE-TO-HTTP CHAIN ACCEPTED — FULL SINGLE-TEST DOMAIN-TO-HTTP PROOF REMAINS UNESTABLISHED BUT NO LONGER BLOCKS A BOUNDED SYNTHETIC RUNTIME-READINESS DOMAIN SLICE — EXACT FIRST DOMAIN TASK IDENTIFIED — READY FOR FRESH INDEPENDENT REVIEW`

Otherwise report the exact remaining blocker and STOP.
