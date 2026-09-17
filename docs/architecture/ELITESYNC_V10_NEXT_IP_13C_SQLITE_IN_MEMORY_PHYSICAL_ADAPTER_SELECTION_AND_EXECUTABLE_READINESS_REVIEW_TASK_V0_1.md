# EliteSync v10｜Next IP-13C SQLite In-Memory Physical Adapter Selection and Executable Readiness Review Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED SELECTION / READINESS REVIEW — NO PHYSICAL ADAPTER IMPLEMENTATION AUTHORITY`

Date: 2026-09-17 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `7144fe6b81dd7bc5bdb1057632117f286370ef8a`

## 1. Objective

Select and verify the first development/test-grade physical persistence adapter target after accepted IP-13A and IP-13B.

This task is review/readiness only. It must determine whether the repository's already-declared Laravel/PHP test environment supports **SQLite in-memory (`:memory:`)** as the narrow first physical adapter target for a later implementation slice.

It does **not** authorize implementation of the adapter, schema, migration, model, production database, or real/private-data processing.

Fixed candidate direction for review:

`SQLITE_IN_MEMORY_DEVELOPMENT_TEST_ADAPTER`

The review must not silently upgrade this choice into a production database decision.

## 2. Mandatory fresh-base gate

Before any substantive action:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Read only the exact files authorized below.
5. Stop rather than adapt if the authority or expected files differ.

## 3. Exact read scope

Read only:

1. `AGENTS.md`
2. `services/backend-laravel/composer.json`
3. `services/backend-laravel/config/database.php`
4. `services/backend-laravel/phpunit.xml`
5. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
6. `services/backend-laravel/app/Domain/LogicalPersistenceAdapterConformanceContract.php`
7. `docs/architecture/ELITESYNC_V10_BACKEND_IN_MEMORY_LOGICAL_PERSISTENCE_REPOSITORY_CONTRACT_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_BACKEND_LOGICAL_PERSISTENCE_ADAPTER_CONFORMANCE_CONTRACT_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
9. `docs/architecture/ELITESYNC_V10_LOGICAL_PERSISTENCE_SCHEMA_PLAN_V0_1.md`

No directory enumeration, repo-wide search, old repository access, README read, FD02 read, or unrelated architecture/product/research document read is authorized.

## 4. Evidence questions

Answer exactly these questions:

1. Does the current backend configuration declare an SQLite connection?
2. Does the current PHPUnit test configuration already select SQLite `:memory:`?
3. Does the current Composer manifest require any new package solely to use Laravel/PDO SQLite?
4. Is the host PHP runtime able to open an in-memory SQLite connection using the already-installed runtime?
5. Can one temporary in-memory table be created, written, read, and dropped within a single disposable probe process without touching repository files or persistent storage?
6. Does choosing SQLite `:memory:` preserve the IP-13A/IP-13B semantic requirement that physical persistence remains subordinate to the logical repository/conformance contracts?
7. What exact implementation scope should the later IP-13D adapter be allowed to use?
8. What remains explicitly unestablished for production database selection, concurrency, transaction semantics, retention, encryption, deployment, legal/Safety, and real/private data?

## 5. Exact executable probe budget

No Composer command is authorized.

No PHPUnit command is authorized.

No Artisan command is authorized.

No migration command is authorized.

Exactly one disposable PHP CLI probe is authorized from `services/backend-laravel/` after static evidence review.

The probe may only:

- inspect `PDO::getAvailableDrivers()`;
- establish `new PDO('sqlite::memory:')`;
- create one temporary synthetic table in that in-memory database;
- insert one conspicuous synthetic row;
- select that row;
- drop the table;
- print bounded PASS/FAIL facts.

The probe must not:

- open `database/database.sqlite`;
- access MySQL/PostgreSQL/SQL Server/Redis;
- read environment secrets;
- access network/provider services;
- write any repository file;
- create persistent database artifacts;
- process real/private data.

Run the probe exactly once. No retry.

## 6. Selection rule

The result may classify the direction as:

- `SELECTED_FOR_FIRST_DEV_TEST_PHYSICAL_ADAPTER`
- `NOT_SELECTED`
- `READINESS_UNKNOWN`

`SELECTED_FOR_FIRST_DEV_TEST_PHYSICAL_ADAPTER` requires all of:

1. repository static configuration already declares SQLite;
2. PHPUnit already uses SQLite `:memory:`;
3. no Composer-manifest change is needed solely for SQLite support;
4. the single disposable runtime probe exits successfully and proves in-memory create/insert/select/drop;
5. the result keeps all accepted IP-13A/IP-13B authority boundaries explicit.

This classification means only that SQLite `:memory:` is a suitable **development/test-grade first physical adapter target**.

It does not establish or imply:

- production database choice;
- durability;
- multi-process concurrency;
- transaction/isolation sufficiency;
- locking/CAS semantics;
- production scale/performance;
- backup/restore;
- retention/deletion/legal hold;
- encryption/KMS;
- regional/data-residency sufficiency;
- deployment authority;
- real/private-data authorization.

## 7. Required later IP-13D boundary if selected

If SQLite in-memory is selected, recommend a later implementation task whose maximum scope is:

- one bounded SQLite in-memory adapter class under the existing backend source boundary;
- one targeted synthetic unit/integration test file;
- one result document;
- schema/table creation only inside disposable test/in-memory runtime setup, not migrations;
- exact semantic conformance checked against accepted IP-13A and IP-13B contracts;
- no Eloquent model requirement unless separately authorized;
- no persistent SQLite file;
- no production config change;
- no endpoint/controller/client work;
- no real/private data.

Do not implement IP-13D in this task.

## 8. Exact tracked write scope

Create exactly one new tracked file:

`docs/architecture/ELITESYNC_V10_SQLITE_IN_MEMORY_PHYSICAL_ADAPTER_SELECTION_AND_EXECUTABLE_READINESS_REVIEW_RESULT_V0_1.md`

No existing tracked file may change.

## 9. Required result document

Record:

- task-publication commit;
- exact read scope actually used;
- source blobs for `composer.json`, `config/database.php`, `phpunit.xml`, IP-13A source, IP-13B source, IP-13A acceptance, IP-13B acceptance, IP-09 plan;
- static evidence answers to all eight evidence questions;
- exact one-shot PHP probe command or script text and output summary;
- probe attempt count and exit code;
- whether `sqlite` appears in PDO drivers;
- whether create/insert/select/drop succeeded;
- tracked scope proof;
- retained unknowns/non-authorities;
- candidate SHA / sole parent / tree / result blob / relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review is required.

Expected success classification:

`IP-13C SQLITE IN-MEMORY SELECTED FOR FIRST DEV/TEST PHYSICAL ADAPTER — EXISTING LARAVEL/PHPUNIT CONFIG ALREADY DECLARES SQLITE :memory: — ONE-SHOT DISPOSABLE SQLITE RUNTIME PROBE PASS — NO COMPOSER/CONFIG/MIGRATION CHANGE REQUIRED — PRODUCTION DATABASE AND REAL-DATA AUTHORITY REMAIN UNESTABLISHED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
