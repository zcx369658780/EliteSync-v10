# EliteSync v10｜Next IP-13F Transport-Neutral Application Request / Response Contract Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-19 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `30b49c0fd6472c7b0a8e92c4378b1c66946da521`

## 1. Objective

Implement exactly one pure deterministic transport-neutral request/response contract over the already accepted IP-13E application-interface integration contract.

This slice defines a stable protocol-neutral envelope for the five accepted semantic families without selecting HTTP, REST, JSON wire format, status codes, controllers, routes, middleware, RPC, queues, brokers, provider transports, authentication machinery, SDKs, clients, production topology or real/private-data processing.

The transport-neutral contract is an adapter around accepted application-interface semantics only. It is not a source authority, domain writer, permission token, bearer capability, transport implementation or production API.

Controlling invariants:

- `TRANSPORT_ENVELOPE != SOURCE_AUTHORITY`
- `TRANSPORT_SUCCESS != DOMAIN_OUTCOME`
- `ERROR_MAPPING != DOMAIN_STATE`
- `REQUEST_IDENTITY != PERMISSION`
- `RESPONSE != BEARER_CAPABILITY`
- `PROJECTION != PERMISSION`

Future slice name:

`NEXT-IP-13F-TRANSPORT-NEUTRAL-APPLICATION-REQUEST-RESPONSE-CONTRACT-IMPLEMENTATION-V0-1`

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three authorized output paths below are absent.
6. Verify and record blobs for:
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
   - `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
   - `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
   - `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
   - `docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_PERSISTENCE_BOUNDARY_APPLICATION_INTERFACE_INTEGRATION_CONTRACT_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
   - `services/backend-laravel/composer.json`
   - `services/backend-laravel/composer.lock`
7. Stop rather than adapt if any authority/base/path condition differs.

Recommended branch:

`review/next-ip-13f-transport-neutral-application-request-response-contract-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/TransportNeutralApplicationRequestResponseContract.php`
2. `services/backend-laravel/tests/Unit/TransportNeutralApplicationRequestResponseContractTest.php`
3. `docs/architecture/ELITESYNC_V10_TRANSPORT_NEUTRAL_APPLICATION_REQUEST_RESPONSE_CONTRACT_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact targeted test file.

## 4. Fixed family mapping

The contract must support exactly these five accepted semantic families and no others:

1. authoritative mutation submission
2. authoritative-outcome reconciliation
3. current projection retrieval
4. protected-action revalidation
5. correction/revocation/supersession observation

Use stable internal family identifiers chosen by the implementation, but every family must map one-to-one to the accepted IP-13E operation and must not create a sixth semantic family.

Unknown family input must fail closed as transport-contract `UNKNOWN`; it must not dispatch to any application operation.

## 5. Request envelope

Define one exact protocol-neutral request envelope with only bounded semantic metadata needed for deterministic dispatch/correlation.

At minimum, every request must include:

- request identity / correlation identity;
- exact family identifier;
- immutable semantic payload for that family;
- explicit audience/purpose or exact family-bound data containing them where applicable;
- no hidden defaults that invent actor/role/subject/participants/context.

Rules:

1. Request identity is correlation only.
2. Request identity is not authentication, authorization, source authority, idempotent permission or domain identity.
3. Missing/malformed required fields fail closed before application dispatch.
4. Changed semantic payload under the same request identity is a correlation conflict / malformed reuse; do not silently treat it as retry.
5. Unknown extra top-level envelope fields must fail closed rather than be ignored.
6. Do not infer family from payload shape.
7. Do not infer actor, role, subject, participants, audience, purpose, aggregate/context, lineage or revision.
8. No timestamp, arrival order, request order or transport order may become authority.
9. No global revision exists.

The contract may retain process-local request-correlation state for synthetic proof only. Such state is not persistence authority and must not alter the accepted IP-13E logical intent rules.

## 6. Response envelope

Every handled request must return one exact protocol-neutral response envelope that separates:

- request identity;
- family identity;
- transport-contract disposition;
- application-interface semantic result;
- source/domain outcome where present;
- bounded error/condition classification;
- whether reconciliation/revalidation remains required;
- privacy-minimal explanation category;
- explicit non-authority fields.

Recommended transport-contract dispositions are bounded to:

- `DELIVERED_TO_APPLICATION`
- `REQUEST_REJECTED`
- `UNKNOWN`

These are envelope/dispatch dispositions only.

`DELIVERED_TO_APPLICATION` must never imply:

- source-authoritative outcome;
- domain success;
- persistence success;
- permission;
- bearer capability;
- protected-action execution authority;
- HTTP success;
- production readiness.

The response envelope must expose no private fixture extensions or forbidden private content beyond the accepted privacy-minimal application result.

## 7. Error and condition mapping

Implement a deterministic protocol-neutral mapping layer that preserves semantic distinctions without inventing HTTP semantics.

At minimum preserve or map distinctly:

- malformed request envelope;
- unsupported family;
- changed-input request identity reuse;
- persistence/application `MISSING`;
- `UNKNOWN`;
- `ABSENT`;
- `UNAVAILABLE`;
- `STALE`;
- `SUPERSEDED`;
- `INCOMPARABLE`;
- `INVALIDATED`;
- application mutation rejection/storage rejection;
- immutable-intent mismatch during reconciliation;
- revalidation `DENIED`;
- revalidation `UNKNOWN`.

Rules:

1. Do not map any condition to an HTTP status code.
2. Do not collapse `UNKNOWN` into absence or denial.
3. Do not collapse `STALE` into `SUPERSEDED`.
4. Do not collapse `MISSING` into a negative domain outcome.
5. Do not turn persistence rejection into authoritative domain rejection unless the application result separately carries source-authoritative rejection.
6. Do not turn transport/envelope acceptance into mutation success.
7. Do not invent retryability, permanence, blame, adverse meaning or deletion semantics.
8. Error classification must be privacy-minimal and must not surface raw private source content.

## 8. Five-family dispatch requirements

### 8.1 Mutation submission

- Dispatch exactly once to IP-13E mutation submission for a valid envelope.
- Preserve persistence disposition separately from authoritative outcome.
- If source-carried authoritative outcome is absent, keep `UNKNOWN`.
- `DELIVERED_TO_APPLICATION` does not imply committed.
- Expose whether authoritative reconciliation is required.
- No automatic reconciliation or retry.

### 8.2 Outcome reconciliation

- Dispatch only to IP-13E reconciliation.
- Must not call mutation submission/store.
- Must bind the same immutable intent.
- Exact request-envelope correlation does not substitute for IP-13E logical-intent binding.
- Preserve COMMITTED / REJECTED / UNKNOWN only when established by accepted application semantics.

### 8.3 Current projection retrieval

- Dispatch only to IP-13E projection retrieval.
- Preserve exact request bindings.
- Return only accepted privacy-minimal projection.
- Binding mismatch fails closed.
- Projection remains read-only and non-permission.

### 8.4 Protected-action revalidation

- Dispatch only to IP-13E revalidation.
- Preserve `GRANTED`, `DENIED`, `UNKNOWN` exactly.
- Even `GRANTED` remains descriptive-only and non-bearer.
- Response must preserve `execution_must_revalidate = true`.
- No protected action is executed by this contract.

### 8.5 Invalidation observation

- Dispatch only to IP-13E invalidation observation.
- Preserve correction/revocation/supersession distinction.
- Invalidation does not reset/reopen lifecycle, create aggregate or transition, infer deletion/adverse meaning, or create global ordering.

## 9. Mandatory explicit non-authority fields

Every response, including malformed/unknown/rejected envelopes, must explicitly keep false:

- `source_authority`
- `domain_writer_authority`
- `authoritative_mutation_success`
- `permission`
- `permission_token`
- `bearer_capability`
- `protected_action_executed`
- `transport_execution_authority`
- `http_semantics`
- `controller_authority`
- `route_authority`
- `authentication_authority`
- `production_ready`
- `deployable`
- `real_data_authorized`
- Readiness/Match/Connection/Consent/Conversation/Relationship/Home/Notification/launch authority fields.

The implementation may use additional explicit false fields, but may not omit these.

## 10. Required synthetic proof obligations

The source/test pair must independently prove at least:

1. all five valid family envelopes dispatch exactly once to the corresponding IP-13E method;
2. response request/family identity is stable and deterministic;
3. request identity grants no authority or permission;
4. same request identity + exact same semantic input is correlation-compatible without adding domain meaning;
5. same request identity + changed semantic input fails closed and does not dispatch again;
6. malformed envelope fails closed and does not dispatch;
7. unsupported family returns `UNKNOWN` and does not dispatch;
8. unknown extra top-level envelope field fails closed;
9. mutation storage success with no source-carried outcome remains authoritative `UNKNOWN`;
10. source-carried COMMITTED/REJECTED are preserved without becoming interface-owned authority;
11. transport-contract disposition never upgrades domain outcome;
12. reconciliation is read-only and does not replay/resubmit;
13. projection output remains privacy-minimal and non-permission;
14. private synthetic sentinel does not leak through response/error mapping;
15. `MISSING`, `UNKNOWN`, `ABSENT`, `UNAVAILABLE`, `STALE`, `SUPERSEDED`, `INCOMPARABLE`, `INVALIDATED` remain distinct;
16. changed logical intent in reconciliation remains unknown/mismatch, not success;
17. revalidation `GRANTED` remains descriptive, non-bearer and requires execution-time revalidation;
18. revalidation `DENIED` remains distinct from `UNKNOWN`;
19. invalidation relation remains correction/revocation/supersession-specific;
20. invalidation creates no lifecycle reset/reopen/new aggregate/synthetic transition;
21. no global revision, request-order authority, arrival-order authority, LWW or last-received-wins appears;
22. deterministic repeated processing of allowed exact duplicate request evidence produces the same envelope result and does not mutate supplied inputs;
23. every response carries all mandatory explicit non-authority fields false;
24. no HTTP status, route, controller, middleware, network, serialization-format or authentication implementation is created or implied;
25. all fixtures are conspicuous synthetic-only values.

## 11. Explicit prohibitions

Do not implement or modify:

- HTTP controllers;
- Laravel routes;
- middleware;
- request/response framework classes;
- JSON/API resources or wire serializers;
- HTTP status mappings;
- REST/RPC/GraphQL;
- authentication/session/token implementation;
- service-provider bindings;
- network/provider calls;
- queues/events/jobs/brokers;
- Eloquent/models;
- migrations/schema changes;
- Laravel DB facade;
- persistent SQLite/database;
- production configuration/deployment;
- Flutter/Android/client/UI/navigation;
- telemetry/analytics expansion;
- real/private-data processing;
- retention/deletion/TTL/legal hold;
- legal/Safety policy;
- new domain states/transitions/product policy;
- Sandbox/DEP13/B12/M1/M2/M3.

Do not modify accepted sources/tests.

Do not self-accept, merge, or move `main`.

## 12. Same-worktree vendor bootstrap rule

In the candidate worktree check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, Composer Case A: do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 13. Exact command budget

After both code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/TransportNeutralApplicationRequestResponseContractTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands needed for candidate identities, topology, working-tree proof and review-branch publication are allowed.

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, network/provider/runtime commands or client tooling.

## 14. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file tracked scope;
- source/test/result SHA-256 + Git blobs;
- fixed input blobs;
- exact five family identifiers and dispatch mappings;
- request envelope contract;
- response envelope contract;
- bounded error/condition mapping;
- request-correlation/idempotency behavior;
- proof that transport disposition remains non-authoritative;
- privacy-minimal proof;
- five-family proof matrix;
- mandatory non-authority field proof;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit single-attempt result;
- warnings/deprecations;
- `git diff --check` receipt;
- manifest/lock pre/post SHA-256 + blobs;
- retained unknowns and explicit non-authorities;
- candidate SHA / sole parent / tree / relation to fresh `origin/main`;
- fresh independent ACCEPT/REJECT review requirement.

Expected success classification:

`IP-13F TRANSPORT-NEUTRAL APPLICATION REQUEST/RESPONSE CONTRACT IMPLEMENTED WITH SYNTHETIC FIXTURES — FIVE ACCEPTED APPLICATION SEMANTIC FAMILIES EXPOSED THROUGH STRICT PROTOCOL-NEUTRAL ENVELOPES — ERROR/UNKNOWN/CONDITION MAPPING PRESERVES DOMAIN DISTINCTIONS — TRANSPORT ENVELOPE REMAINS NON-AUTHORITATIVE — TARGETED UNIT TEST PASS — NO HTTP/CONTROLLER/AUTH/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
