# EliteSync v10｜Next IP-13I-R1 Exact Domain Source-Locator and Core-Harness Acceptance Evidence Repair Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY EVIDENCE REPAIR REVIEW — NO IMPLEMENTATION / NO RUNTIME AUTHORITY — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `cf2832f61977ce9494d39e74fc367aa62df960e7`

## 1. Objective

Repair only the seven exact evidence-location gaps accepted in IP-13I.

Resolve repository locators and evidence status for:

1. Runtime Readiness evaluator
2. Canonical Match evaluator
3. Product Connection evaluator
4. Messaging Consent / Conversation live-gate evaluator
5. Calm Home evaluator
6. Notification evaluator
7. Core-domain semantic integration harness acceptance/runtime receipt

The review must determine the exact repository path/blob for each source and the exact acceptance/result/test/runtime evidence where available.

This task does not implement, modify or rerun domain logic.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review branch/worktree from exactly that commit.
5. Verify the single output path below is absent.
6. Stop rather than adapt if authority/base/path differs.

Recommended branch:

`review/next-ip-13i-r1-domain-evidence-locator-repair-v0-1`

## 3. Exact authorized discovery identifiers

The previously guessed contract filenames are NOT authoritative locators.

Discovery is authorized only using these exact source identifiers already present in the accepted core harness:

- `RuntimeReadinessDerivedEvaluator`
- `CanonicalMatchProposalDecisionEvaluator`
- `ProductConnectionStateTransitionEvaluator`
- `MessagingConsentConversationLiveGateEvaluator`
- `CalmHomeReadOnlyCompositionEvaluator`
- `NotificationEligibilityPrivacyMinimalPayloadEvaluator`
- `CoreDomainSemanticIntegrationHarness`

For acceptance/result/test evidence, discovery may use only exact identifier/title fragments derived from those names plus:
- `CORE DOMAIN SEMANTIC INTEGRATION HARNESS`
- `RUNTIME READINESS`
- `CANONICAL MATCH`
- `PRODUCT CONNECTION`
- `MESSAGING CONSENT`
- `CONVERSATION LIVE`
- `CALM HOME`
- `NOTIFICATION`

No broad semantic search, directory enumeration or unrelated filename guessing is authorized.

## 4. Authorized discovery method

Use narrowly bounded repository search/code search by the exact identifiers in Section 3.

For every search result:
- record exact returned repository path;
- fetch the exact file;
- record its Git blob;
- verify the file actually defines/tests/accepts the named evaluator or harness;
- reject false-positive references.

If repository search returns no result for an exact identifier:
- record `SEARCH_INDEX_NO_RESULT`;
- do not broaden the query;
- do not enumerate directories.

You may additionally inspect exact file paths explicitly referenced by a positively matched authorized file, but only where that reference is literal and directly relevant to one of the seven targets.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_BACKEND_DOMAIN_EVIDENCE_LOCATOR_REPAIR_REVIEW_RESULT_V0_1.md`

No existing tracked file may change.

## 6. Required per-domain evidence record

For each of the six evaluators, record:

- exact class identifier;
- exact source path;
- source blob;
- exact associated test path if discoverable through authorized exact identifier search/reference;
- test blob;
- exact acceptance/result document path if discoverable;
- acceptance/result blob;
- runtime receipt if contained in accepted evidence;
- evidence classification:
  - `RUNTIME_VERIFIED`
  - `STATICALLY_VERIFIED_ONLY`
  - `DOCUMENTARY_ONLY`
  - `UNESTABLISHED`
- retained non-authorities.

Do not upgrade classification from project memory alone. The candidate result must be grounded in repository evidence discovered under this task.

## 7. Core-harness evidence repair

For `CoreDomainSemanticIntegrationHarness`, resolve:

- source path/blob;
- exact targeted test path/blob if available;
- exact result/acceptance path/blob if available;
- runtime receipt and pass/fail state if available;
- which domain evaluators the test actually exercises;
- whether runtime proof is direct for all six evaluator families or only a subset;
- whether any acceptance was superseded by later verification/repair evidence.

If the source exists but no acceptance/runtime artifact can be located within the authorized discovery method, classify it accordingly and do not infer acceptance from memory.

## 8. IP-13I repair decision

After resolving the seven targets, output:

- `DOMAIN_LOCATOR_GAP_STATUS`
- `CORE_HARNESS_ACCEPTANCE_GAP_STATUS`
- `DOMAIN_RUNTIME_EVIDENCE_STATUS`
- `FULL_DOMAIN_TO_HTTP_RUNTIME_STATUS`
- `RUNTIME_READINESS_FIRST_DOMAIN_STATUS`
- `NEXT_BOUNDED_TASK`

If all six domain sources plus sufficient accepted harness/runtime evidence are recovered, determine whether a fresh IP-13I-R2 integration review can now reassess the domain→HTTP chain.

Do not directly authorize or create a domain API implementation unless a future independently accepted review does so.

If evidence remains incomplete, select the narrowest remaining evidence-repair task.

## 9. Explicit prohibitions

Do not:
- modify code;
- modify tests;
- modify routes/controllers/config;
- run Composer;
- run PHPUnit;
- run Artisan;
- run `route:list`;
- run migrations/generators;
- execute domain code;
- access database/provider/network;
- access client code;
- process real/private data;
- perform production/deployment work;
- perform legal/Safety work;
- infer alternate evidence from project memory without repository support.

## 10. Command budget

No Composer, PHPUnit, Artisan, route-list, migration, generator, runtime, network/provider, client, production or data-processing command is authorized.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance and exact-identifier repository search/fetch operations are allowed.

## 11. Required result document

Record:

- task-publication commit;
- candidate SHA / sole parent / tree / ahead-behind;
- exact one-file tracked scope;
- result SHA-256/blob;
- exact search identifier ledger;
- search results / no-result receipts;
- all resolved source/test/result/acceptance paths and blobs;
- seven-target evidence matrix;
- evidence classifications;
- six repair decision outputs;
- retained unknowns/non-authorities;
- `git diff --check`;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification if sufficient evidence is recovered:

`IP-13I-R1 DOMAIN EVIDENCE LOCATOR REPAIR REVIEW COMPLETE — SIX DOMAIN EVALUATOR SOURCE LOCATORS AND CORE-HARNESS ACCEPTANCE/RUNTIME EVIDENCE RESOLVED FROM EXACT IDENTIFIERS — PRIOR IP-13I LOCATOR GAP REPAIRED WITHOUT IMPLEMENTATION — READY FOR FRESH INDEPENDENT REVIEW AND FOLLOW-UP INTEGRATION REASSESSMENT`

If insufficient evidence remains, report exact unresolved identifiers and STOP.

Do not create IP-13I-R2 or any domain API task.
