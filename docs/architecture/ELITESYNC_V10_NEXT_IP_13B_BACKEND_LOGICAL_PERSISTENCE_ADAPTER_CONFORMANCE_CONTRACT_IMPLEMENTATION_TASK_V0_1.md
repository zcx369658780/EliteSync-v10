# EliteSync v10｜Next IP-13B Backend Logical Persistence Adapter Conformance Contract Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `b15cce5fe08a2230381738ed2037ec8b37a2a248`

## 1. Objective

Implement exactly one pure backend logical-persistence adapter conformance contract and synthetic unit tests.

This slice establishes the technology-neutral seam between future physical persistence adapters and the already accepted IP-13A in-memory logical persistence repository contract. It must prove that an adapter may preserve storage/read/reconciliation semantics without becoming source authority or changing any accepted domain semantics.

This task does NOT choose or implement a database, ORM, migration, schema, transport endpoint, controller, production adapter, or real-data path.

Future slice name:

`NEXT-IP-13B-BACKEND-LOGICAL-PERSISTENCE-ADAPTER-CONFORMANCE-CONTRACT-IMPLEMENTATION-V0-1`

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three authorized output paths below are absent.
6. Verify and record these accepted blobs without modifying them:
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
   - `docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_LOGICAL_PERSISTENCE_SCHEMA_PLAN_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_IN_MEMORY_LOGICAL_PERSISTENCE_REPOSITORY_CONTRACT_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
7. Verify `services/backend-laravel/composer.json` and `composer.lock` exist and record pre identities.
8. Stop rather than adapt if any authority/base/path condition differs.

Recommended branch:

`review/next-ip-13b-backend-logical-persistence-adapter-conformance-contract-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
2. `services/backend-laravel/tests/Unit/LogicalPersistenceAdapterConformanceContractTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_LOGICAL_PERSISTENCE_ADAPTER_CONFORMANCE_CONTRACT_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Do not create `app/Contracts/`, framework bindings, service providers, configuration entries, models, migrations, controllers, routes, or serializers.

Synthetic fixtures must live only in the exact test file.

## 4. Fixed semantic role

The source must define a pure deterministic semantic conformance boundary for a future persistence adapter.

The contract may use arrays/immutable PHP values and may delegate to the accepted `InMemoryLogicalPersistenceRepositoryContract` as the reference semantic implementation for synthetic proof.

It must expose or prove a bounded operation family equivalent to:

1. store/append logical record;
2. read exact logical record identity;
3. resolve current exact-context comparable record;
4. read exact-lineage history;
5. observe correction/revocation/supersession invalidation;
6. obtain privacy-minimal non-authoritative projection.

The adapter conformance layer is a semantic seam only. It must not perform physical persistence and must not invent persistence technology behavior.

## 5. Core conformance invariant

Preserve exactly:

`ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY`

A future adapter is conformant only when, for the same semantic inputs, it preserves the accepted repository meanings and non-authority fields.

Conformance success must never establish:

- source authority;
- authoritative mutation success;
- permission or bearer capability;
- domain success;
- Runtime Readiness;
- Match;
- Product Connection;
- Messaging Consent;
- Conversation live read/send;
- Relationship;
- Calm Home action;
- Notification delivery;
- launch eligibility;
- production readiness.

## 6. Required conformance dimensions

The implementation/test pair must compare or validate adapter behavior over at least these dimensions:

1. operation identity/family;
2. storage disposition;
3. read/resolution disposition;
4. exact logical-record identity;
5. authority owner/scope binding;
6. exact aggregate/context binding;
7. source-local lineage/revision identity;
8. source condition;
9. currentness independent from freshness;
10. immutable logical-intent correlation;
11. authoritative-outcome metadata only when source-carried;
12. correction/revocation/supersession invalidation semantics;
13. lifecycle terminality/no-reopen semantics;
14. privacy-minimal projection allowlist;
15. explicit non-authority fields;
16. deterministic result independent of insertion/input ordering where the accepted repository contract requires order independence.

Conformance must fail closed if a compared adapter result:

- changes any semantic disposition;
- synthesizes authority or success;
- removes required fail-closed distinctions;
- introduces global revision or last-write/last-received authority;
- promotes incomparable records into a global ordering;
- merges `UNKNOWN` with `ABSENT`/`MISSING`;
- merges `STALE` with `SUPERSEDED`;
- conflates currentness with freshness;
- changes terminal/invalidation semantics;
- leaks prohibited private material;
- invents authoritative outcome metadata;
- treats transport/delivery observation as domain outcome.

## 7. Required bounded classifications

Use clear non-production conformance classifications such as:

- `CONFORMANT`
- `NON_CONFORMANT`
- `UNKNOWN`

These are adapter-review classifications only.

`CONFORMANT` does not mean source-authoritative, product-valid, production-ready, durable, transactional, concurrent-safe, or deployable.

`UNKNOWN` must be used when exact semantic comparison cannot be established from the supplied bounded evidence.

## 8. Mandatory equivalence proofs

Synthetic tests must prove at least:

1. accepted in-memory reference behavior can be classified `CONFORMANT` against itself/reference adapter behavior;
2. conformance success still returns all source/domain authority fields false;
3. storage success remains `STORED != AUTHORITATIVE` through the adapter seam;
4. exact duplicate remains idempotent correlation only;
5. changed-input intent reuse remains rejected;
6. same-lineage newer resolution remains independent of insertion order;
7. equal revision conflict remains fail-closed;
8. cross-lineage records remain incomparable;
9. no global revision is introduced;
10. unknown/absent/missing remain distinct;
11. stale/superseded remain distinct;
12. currentness/freshness remain independent;
13. current-but-stale and fresh-but-not-current do not become protected-current success;
14. terminal lifecycle identity cannot reopen;
15. invalidation preserves no lifecycle reset/reopen/new aggregate/synthetic transition;
16. source-carried authoritative outcome metadata may be preserved but not invented;
17. transport observation remains non-domain-outcome;
18. privacy-minimal projection omits private sentinel material;
19. a deliberately mutated storage disposition is `NON_CONFORMANT`;
20. a deliberately mutated resolution disposition is `NON_CONFORMANT`;
21. a deliberately synthesized permission/source-authority/domain-success field is `NON_CONFORMANT`;
22. a deliberately introduced global revision or LWW marker is `NON_CONFORMANT`;
23. a deliberately leaked private field/sentinel is `NON_CONFORMANT`;
24. missing or structurally incomplete comparable evidence yields `UNKNOWN` rather than guessed conformance;
25. repeated conformance evaluation is deterministic and does not mutate supplied reference/candidate values;
26. all fixtures are conspicuous `synthetic-*` values.

Negative assertions for non-authority fields are mandatory.

## 9. Physical persistence remains prohibited

Do NOT implement or modify:

- SQL/NoSQL/SQLite;
- Laravel Eloquent/model classes;
- migrations/schema/DDL;
- database connections;
- tables/columns/indexes/keys;
- repositories backed by filesystem/cache/Redis;
- transactions/locks/CAS/isolation;
- queue/event/broker/job/scheduler behavior;
- service provider/container bindings;
- controllers/routes/API resources;
- HTTP/wire/serialization contracts;
- provider/network integration;
- Android/Flutter/client code;
- retention/deletion/TTL/legal hold;
- encryption/KMS/vendor choice;
- real/private-data processing;
- production configuration/deployment;
- legal or Safety policy;
- new product/domain states, transitions, precedence, ranking, Compatibility totals, scoring or person-worth logic;
- Sandbox/DEP13/B12/M1/M2/M3.

Do not modify the accepted IP-13A repository contract, its tests, Common Authority contract, or any accepted domain evaluator.

Do not self-accept, merge, or move `main`.

## 10. Same-worktree vendor bootstrap rule

In the candidate worktree check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 11. Exact command budget

After both code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/LogicalPersistenceAdapterConformanceContractTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands needed for parent/tree/blob/ahead-behind/working-tree proof and review-branch publication are allowed.

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache/runtime/provider commands.

## 12. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file scope;
- source/test/result SHA-256 + Git blobs;
- accepted Common Authority blob;
- accepted IP-13A source/test/acceptance blobs;
- accepted IP-08/IP-09 planning blobs;
- conformance proof coverage;
- explicit `ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY` boundary;
- synthetic-only boundary;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit single-attempt result;
- warnings/deprecations;
- `git diff --check` receipt;
- pre/post composer manifest/lock SHA-256 + blobs;
- retained unknowns and explicit non-authorities;
- candidate SHA / sole parent / tree / relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review is required.

Expected success classification:

`IP-13B BACKEND LOGICAL PERSISTENCE ADAPTER CONFORMANCE CONTRACT IMPLEMENTED WITH SYNTHETIC FIXTURES — REFERENCE-SEMANTIC EQUIVALENCE / FAIL-CLOSED DIVERGENCE / NON-AUTHORITY BOUNDARIES EXPLICIT — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.