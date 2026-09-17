# EliteSync v10｜Next IP-13D SQLite In-Memory Physical Persistence Adapter Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — DEV/TEST SQLITE :memory: ONLY — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-17 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `cd51485b69ee588c949837e59d33563a2d4dd35b`

## 1. Objective

Implement exactly one development/test-only SQLite in-memory physical persistence adapter that realizes the accepted IP-13A logical repository semantics and is checked against the accepted IP-13B conformance contract.

The adapter is a disposable physical realization only. It must use `sqlite::memory:` exclusively and must never create or open a persistent SQLite file.

The controlling invariants remain:

- `STORED != AUTHORITATIVE`
- `ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY`

SQLite execution success, row presence, SQL success, adapter conformance, or targeted test success must not create source authority, authoritative mutation success, permission, bearer capability, domain success, production readiness, deployability, or real-data authority.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three authorized output paths below are absent.
6. Read only the fixed source/config inputs listed in this task.
7. Stop rather than adapt if any identity/base/path condition differs.

Recommended branch:

`review/next-ip-13d-sqlite-in-memory-physical-persistence-adapter-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
2. `services/backend-laravel/tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php`
3. `docs/architecture/ELITESYNC_V10_SQLITE_IN_MEMORY_PHYSICAL_PERSISTENCE_ADAPTER_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Do not create a migration, model, repository directory, config file, service-provider binding, schema file, persistent database file, fixture file, helper file, generated file, or endpoint.

Synthetic fixtures must live only in the exact test file.

## 4. Fixed inputs

Read only these exact existing files plus this task:

- `AGENTS.md`
- `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
- `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
- `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
- `services/backend-laravel/config/database.php`
- `services/backend-laravel/phpunit.xml`
- `services/backend-laravel/composer.json`
- `services/backend-laravel/composer.lock`
- `docs/architecture/ELITESYNC_V10_SQLITE_IN_MEMORY_PHYSICAL_ADAPTER_SELECTION_AND_EXECUTABLE_READINESS_REVIEW_ACCEPTANCE_V0_1.md`

No directory enumeration or repo-wide search is authorized.

## 5. Physical adapter boundary

The source must be one deterministic PHP class using PDO directly with an internally owned `sqlite::memory:` connection.

The class may initialize exactly the minimum disposable schema needed to represent the IP-13A logical record contract.

The schema must exist only in the in-memory connection lifetime.

Do not use:

- Eloquent/model;
- migration/schema builder;
- Laravel DB facade;
- service container binding;
- persistent SQLite path;
- filesystem database;
- external DB server;
- MySQL/PostgreSQL/MariaDB/SQL Server;
- Redis/cache;
- queue/event/job.

## 6. Required semantic surface

The adapter must expose operation families semantically equivalent to IP-13A:

1. store one logical record;
2. read exact logical-record identity;
3. resolve current record for exact authority/scope/context and optional exact lineage;
4. read exact-lineage history;
5. observe correction/revocation/supersession invalidation;
6. return privacy-minimal projection.

Exact public method names may differ, but tests must map each operation to the accepted IP-13A reference and IP-13B conformance operation family.

## 7. Mandatory semantic preservation

Preserve exactly:

1. `STORED != AUTHORITATIVE`.
2. `ADAPTER_EQUIVALENCE != SOURCE_AUTHORITY`.
3. no global revision.
4. no last-write-wins or last-received-wins authority.
5. comparison only within exact authority owner / authority scope / lineage / aggregate context.
6. cross-lineage/cross-authority/cross-scope/cross-context remains incomparable.
7. `UNKNOWN != ABSENT != MISSING`.
8. `STALE != SUPERSEDED`.
9. currentness independent from freshness.
10. exact duplicate idempotency only.
11. changed-input intent reuse rejected.
12. idempotency is correlation only; not permission or success.
13. conflicting equal source-local revision fails closed.
14. same-lineage newer comparable record may control repository resolution only.
15. input/store order must not create authority.
16. terminal lifecycle identity does not reopen.
17. later lifecycle requires distinct accepted lifecycle/aggregate identity when applicable.
18. correction/revocation/supersession invalidates projection use without lifecycle reset/reopen/new aggregate/synthetic transition.
19. authoritative outcome metadata remains source-carried only and is not invented by SQL/storage.
20. transport observation is not domain outcome.
21. projections remain privacy-minimal and non-authoritative.
22. supplied source/domain arrays are not mutated.
23. persistent row presence does not imply protected-current validity.
24. SQLite constraints/row order/rowid must not become semantic authority.

## 8. Physical representation rules

The adapter may use one disposable table or a very small bounded set of disposable tables inside the private in-memory connection.

Physical representation must be opaque to callers and must not become a new product/schema authority.

Do not expose SQLite `rowid`, insertion order, auto-increment sequence, database timestamp, or SQL execution order as source revision or authority.

No migration or durable schema contract is created by this slice.

## 9. Required synthetic proof obligations

The source/test pair must prove at least:

1. adapter opens `sqlite::memory:` and never a persistent path;
2. valid logical record store matches IP-13A reference storage semantics;
3. exact duplicate matches reference semantics;
4. changed-input intent reuse matches rejection semantics;
5. same-lineage newer resolution matches reference independent of insertion order;
6. older later insert cannot displace newer reference resolution;
7. equal-revision conflict matches fail-closed reference behavior;
8. cross-lineage records remain incomparable;
9. cross-authority/scope/context remains incomparable;
10. no global revision appears;
11. unknown/absent/missing remain distinct;
12. stale/superseded remain distinct;
13. currentness/freshness remain independent;
14. current-but-stale and fresh-but-not-current do not become protected-current success;
15. terminal identity cannot reopen;
16. correction/revocation/supersession invalidation matches reference semantics;
17. source-carried authoritative outcome is preserved but not invented;
18. transport observation does not become domain outcome;
19. privacy-minimal projection does not leak private sentinel material;
20. all six operation families are classified `CONFORMANT` by IP-13B when compared with the IP-13A reference behavior for equivalent synthetic scenarios;
21. intentionally mutated candidate result is `NON_CONFORMANT` under IP-13B;
22. SQL row presence and successful SQL execution remain explicitly non-authoritative;
23. adapter does not mutate supplied inputs;
24. repeated deterministic reads match reference semantics;
25. all fixture values are conspicuous synthetic-only values.

Negative assertions for source authority, authoritative mutation success, permission, bearer capability, domain success, production readiness, durability, transactional sufficiency, concurrency safety, deployability, Match/Connection/Consent/Conversation/Relationship/Home/Notification/launch authority are mandatory.

## 10. Explicit prohibitions

Do not implement or modify:

- migration/schema files;
- Eloquent models;
- Laravel database config;
- environment files;
- persistent SQLite file;
- production database selection;
- transaction/isolation policy beyond whatever PDO internally requires for the single-process test;
- lock/CAS/concurrency semantics;
- retention/deletion/TTL/legal hold;
- backup/restore/DR;
- encryption/KMS;
- controller/route/API/wire;
- provider/network integration;
- Flutter/Android/client;
- real/private-data processing;
- production configuration/deployment;
- legal/Safety policy;
- new domain states/transitions/product policy;
- ranking/Compatibility/desirability/person-worth;
- Sandbox/DEP13/B12/M1/M2/M3.

Do not modify IP-13A/IP-13B accepted source or tests.

Do not self-accept, merge, move `main`, or start a successor.

## 11. Vendor bootstrap rule

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, Composer Case A: do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## 12. Exact test/command budget

After both code files exist, run exactly one targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands needed for exact parent/tree/blob/ahead-behind/working-tree proof and review-branch publication are allowed.

Do not run full suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, server/runtime/provider/network commands.

## 13. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file scope;
- source/test/result blobs and SHA-256;
- fixed input blobs;
- physical schema description limited to this disposable adapter;
- proof that DSN is exactly `sqlite::memory:` and no persistent file is opened;
- IP-13A reference equivalence proof;
- IP-13B conformance classifications;
- Composer Case A/B;
- targeted PHPUnit single-attempt receipt;
- warnings/deprecations;
- `git diff --check` receipt;
- manifest/lock pre/post identities;
- retained unknowns and explicit non-authorities;
- candidate SHA / sole parent / tree / relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review is required.

Expected success classification:

`IP-13D SQLITE IN-MEMORY PHYSICAL PERSISTENCE ADAPTER IMPLEMENTED WITH SYNTHETIC FIXTURES — ALL SIX LOGICAL OPERATION FAMILIES CONFORM TO ACCEPTED IP-13A REFERENCE UNDER IP-13B — SQLITE ROW/ORDER/EXECUTION SUCCESS REMAINS NON-AUTHORITATIVE — TARGETED UNIT TEST PASS — NO MIGRATION/PERSISTENT-DB/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
