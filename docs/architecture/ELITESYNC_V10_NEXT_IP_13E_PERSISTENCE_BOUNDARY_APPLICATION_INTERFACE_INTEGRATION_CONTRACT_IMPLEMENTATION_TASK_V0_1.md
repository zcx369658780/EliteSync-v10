# EliteSync v10｜Next IP-13E Persistence Boundary → Application Interface Integration Contract Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — APPLICATION-INTERFACE SEMANTIC INTEGRATION ONLY — NO HTTP/CONTROLLER/PRODUCTION AUTHORITY`

Date: 2026-09-17 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `f84b15a558e34451989e7e96760abe9247642ec0`

## 1. Objective

Implement exactly one pure backend application-interface integration contract that consumes the already accepted logical persistence boundary and dev/test SQLite in-memory physical adapter while preserving the accepted IP-08 cross-domain interface semantics.

This task does NOT implement HTTP, controllers, routes, wire formats, authentication middleware, provider/network behavior, production persistence, persistent databases, real/private-data processing, deployment, legal policy or Safety policy.

The contract is an application-layer semantic integration boundary only.

Controlling invariants:

- `PERSISTENCE_RESULT != AUTHORITATIVE_DOMAIN_OUTCOME`
- `APPLICATION_INTERFACE_RESULT != SOURCE_AUTHORITY`
- `PROJECTION != PERMISSION`
- `REVALIDATION_RESULT != BEARER_CAPABILITY`
- `TRANSPORT_OBSERVATION != DOMAIN_OUTCOME`

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three authorized output paths below are absent.
6. Read only these fixed sources and record their blobs:
   - `docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_V0_1.md`
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
   - `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
   - `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
   - `docs/architecture/ELITESYNC_V10_SQLITE_IN_MEMORY_PHYSICAL_PERSISTENCE_ADAPTER_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
7. Verify `services/backend-laravel/composer.json` and `composer.lock` and record pre identities.
8. Stop rather than adapt if any authority/base/path condition differs.

Recommended branch:

`review/next-ip-13e-persistence-boundary-application-interface-integration-contract-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
2. `services/backend-laravel/tests/Unit/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php`
3. `docs/architecture/ELITESYNC_V10_PERSISTENCE_BOUNDARY_APPLICATION_INTERFACE_INTEGRATION_CONTRACT_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

## 4. Fixed semantic surface

Implement only these five IP-08 application-interface families over the already accepted persistence boundary:

1. authoritative mutation submission semantic envelope;
2. authoritative-outcome reconciliation semantic envelope;
3. current projection retrieval semantic envelope;
4. protected-action revalidation semantic envelope;
5. correction/revocation/supersession observation semantic envelope.

The contract may use `SqliteInMemoryLogicalPersistenceAdapter` internally for dev/test persistence evidence, but persistence never becomes domain authority.

Do not add domain-specific Match/Connection/Consent/Conversation state transitions in this slice.

## 5. Authoritative mutation submission boundary

A mutation submission operation may accept a synthetic semantic request containing at minimum:

- owning authority and scope;
- exact aggregate/context and lineage;
- authenticated actor and exact source-owned role;
- exact subject/participants;
- audience/purpose where applicable;
- immutable logical intent identity plus semantic input;
- expected source-local revision relation;
- source currentness/freshness prerequisites where represented;
- one source-carried asserted authoritative outcome only when explicitly supplied by the synthetic source fixture.

The operation may persist a logical record through the accepted adapter.

Its response must distinguish:

- persistence/storage disposition;
- authoritative domain outcome;
- transport observation;
- reconciliation requirement;
- source-local revision/currentness/freshness evidence;
- privacy-minimal explanation category.

Storage success, INSERT success, record existence, duplicate correlation or adapter conformance must never synthesize an authoritative domain outcome.

If no source-carried authoritative outcome exists, authoritative outcome remains `UNKNOWN`.

## 6. Authoritative-outcome reconciliation boundary

Reconciliation must be read-only with respect to the semantic command.

It must:

- bind the same immutable logical intent;
- read the exact stored logical record/projection;
- return only source-carried `COMMITTED`, `REJECTED` or `UNKNOWN` outcome;
- preserve source-local revision/currentness/freshness/condition;
- never repeat the mutation;
- never upgrade storage success/transport acknowledgement into domain success;
- never infer success from exact duplicate or row presence.

## 7. Current projection retrieval boundary

Projection retrieval must:

- use the accepted persistence projection semantics;
- bind exact viewer/subject/context/audience/purpose supplied by the synthetic request;
- return privacy-minimal read-only evidence;
- preserve `UNKNOWN`, `ABSENT`, `MISSING`, `UNAVAILABLE`, `STALE`, `SUPERSEDED`, `INCOMPARABLE`, `INVALIDATED`, projection lag/currentness and source-local revision semantics;
- expose descriptive capability metadata only, never permission tokens.

No raw private fixture extensions may be returned.

## 8. Protected-action revalidation boundary

Revalidation must be a pure descriptive gate.

Positive revalidation may occur only when all supplied required evidence is:

- exact-context bound;
- source-authoritative in the carried evidence sense;
- condition `PRESENT`;
- current;
- fresh;
- not invalidated;
- not incomparable/conflicting;
- audience/purpose/actor/role/subject/participant bindings exact.

The result must be one of bounded classifications such as:

- `GRANTED`
- `DENIED`
- `UNKNOWN`

But even `GRANTED` must explicitly deny:

- bearer capability;
- reusable permission token;
- source ownership;
- domain writer authority;
- transport execution authority;
- production authorization.

A later execution boundary must revalidate again; this slice does not execute protected actions.

## 9. Correction/revocation/supersession observation boundary

Observation must:

- delegate invalidation to the accepted persistence adapter semantics;
- preserve correction/revocation/supersession relation;
- invalidate dependent projection/protected use;
- not reopen lifecycle;
- not reset lifecycle;
- not create a new aggregate;
- not synthesize a transition;
- not infer deletion, adverse meaning or global ordering.

## 10. Required common response non-authority fields

Every application-interface result must explicitly keep false at minimum:

- `source_authority`
- `domain_writer_authority`
- `authoritative_mutation_success` unless independently source-carried and then still must not become application-interface authority
- `permission_token`
- `bearer_capability`
- `transport_execution_authority`
- `production_ready`
- `deployable`
- `real_data_authorized`

If a bounded descriptive `GRANTED` revalidation exists, it must still keep the authority/token fields false.

## 11. Required synthetic proof obligations

The source/test pair must independently prove at least:

1. a mutation request can be persisted without persistence becoming authoritative;
2. storage success with no source-carried outcome returns authoritative outcome `UNKNOWN`;
3. source-carried `COMMITTED` outcome can be preserved without the application interface claiming ownership;
4. source-carried `REJECTED` outcome can be preserved without the application interface claiming ownership;
5. exact duplicate/idempotency remains correlation only;
6. changed-input intent reuse remains rejected;
7. reconciliation performs no second mutation and preserves exact logical intent;
8. transport acknowledgement cannot become authoritative outcome;
9. projection retrieval is privacy-minimal and read-only;
10. raw private sentinel data does not leak;
11. missing/unknown/absent/stale/superseded/incomparable remain distinct;
12. currentness and freshness remain independent;
13. protected revalidation grants only when all exact current/fresh/PRESENT/bound evidence passes;
14. stale evidence cannot grant;
15. not-current evidence cannot grant;
16. wrong actor/role/subject/participant/audience/purpose/context fails closed;
17. incomparable or invalidated evidence cannot grant;
18. `GRANTED` is descriptive only and is not a bearer capability or reusable permission token;
19. correction observation invalidates projection/protected use without lifecycle reset/reopen;
20. revocation observation does likewise;
21. supersession observation does likewise;
22. no global revision or last-write/last-received authority is introduced;
23. no Match/Connection/Consent/Conversation/Relationship/Home/Notification/launch authority is synthesized;
24. repeated identical reads/revalidation are deterministic;
25. all fixtures are conspicuous synthetic-only values.

## 12. Explicit prohibitions

Do not implement or modify:

- HTTP controllers;
- routes;
- middleware;
- API resources;
- request/response wire serialization;
- REST/GraphQL/websocket endpoints;
- authentication/session/token implementation;
- service-provider binding;
- queues/events/jobs/schedulers;
- Laravel DB facade integration;
- Eloquent models;
- migrations/schema files;
- persistent SQLite files;
- production database configuration;
- external provider/network calls;
- Android/Flutter/client/UI/navigation;
- real/private-data processing;
- legal/Safety policy;
- retention/deletion/TTL/legal hold;
- encryption/KMS;
- observability/telemetry/analytics;
- new domain states/transitions/precedence/ranking/Compatibility totals.

Do not modify any accepted source/test/acceptance artifact.

Do not self-accept, merge, or move `main`.

## 13. Vendor/bootstrap rule

In the candidate worktree check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, Composer Case A: do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## 14. Exact command budget

After both code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands needed for parent/tree/blob/ahead-behind/working-tree proof and review-branch publication are allowed.

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache/runtime/provider/network commands.

## 15. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file scope;
- source/test/result SHA-256 + Git blobs;
- all fixed input blobs;
- five interface-family proof coverage;
- persistence/source-authority separation;
- reconciliation non-replay proof;
- projection privacy-minimal proof;
- revalidation descriptive/non-bearer proof;
- invalidation proof;
- Composer Case A/B and receipt if run;
- targeted PHPUnit single-attempt result;
- warnings/deprecations;
- `git diff --check` receipt;
- manifest/lock pre/post identities;
- retained unknowns and explicit non-authorities;
- candidate SHA / sole parent / tree / relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review is required.

Expected success classification:

`IP-13E PERSISTENCE BOUNDARY → APPLICATION INTERFACE INTEGRATION CONTRACT IMPLEMENTED WITH SYNTHETIC FIXTURES — MUTATION / RECONCILIATION / PROJECTION / REVALIDATION / INVALIDATION SEMANTICS INTEGRATED OVER ACCEPTED SQLITE IN-MEMORY ADAPTER — PERSISTENCE AND APPLICATION INTERFACE REMAIN NON-AUTHORITATIVE — TARGETED UNIT TEST PASS — NO HTTP/CONTROLLER/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.