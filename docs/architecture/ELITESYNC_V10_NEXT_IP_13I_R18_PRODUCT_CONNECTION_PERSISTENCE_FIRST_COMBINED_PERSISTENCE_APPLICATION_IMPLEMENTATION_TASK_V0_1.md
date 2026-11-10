# EliteSync v10｜Next IP-13I-R18 Product Connection Persistence-First Combined Persistence + Application Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — TWO HARD SEQUENTIAL PHASES IN ONE CANDIDATE — PHASE A PERSISTENCE MUST PASS BEFORE PHASE B APPLICATION — TARGETED + SHARED REGRESSIONS — NO HTTP / NO DOWNSTREAM`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Task-publication base before this task commit:

`6277d37572a710d92b587e4f439b5c465f8c6c2f`

This task consumes the independently accepted R17-R3 self-contained mapping contract and implements accepted Package A:

`PERSISTENCE_FIRST_WITHIN_SINGLE_SEQUENTIAL_COMBINED_IMPLEMENTATION_TASK`

One candidate may contain both phases only if Phase A passes its exact hard test gate before any Phase B source/test work begins.

## 1. Objective and completion shape

Deliver one complete Product Connection synthetic/dev-test persistence/application boundary:

### Phase A — persistence
Implement the accepted Product Connection derived family in IP-13A and IP-13D with exact payload validation, retention, deterministic correlation validation, duplicate/incomparable/terminal behavior, invalidation semantics, and reference/SQLite parity.

### Phase B — application
Only after Phase A passes, implement one dedicated Product Connection persistence application adapter with the four accepted operations, exact structural gate, repaired-evaluator invocation, selected-evidence recovery, protected-binding computation, exact payload/record construction, one IP-13E submit, conditional exact-lineage retrieve, strict readback, bounded usability, and privacy-minimal non-authority result.

Then run the final combined regression gate, create one result document, and publish one immutable candidate.

No HTTP/controller/route, IP-13F, Messaging/Conversation, client, production or real/private-data work.

## 2. Fresh-base gate

Before any substantive work:

1. Read `AGENTS.md` FIRST from the task-publication authority supplied by the execution prompt.
2. Fresh-fetch `origin/main`.
3. Require `origin/main` to equal that exact task-publication commit.
4. Read this task from that exact commit and verify its blob.
5. Create one isolated implementation branch/worktree from exactly that commit.
6. Verify the three create-only code/test paths and result path in Section 5 are absent.
7. Verify every fixed read/write object blob.
8. Stop rather than adapt on any mismatch.

No repository enumeration, filename/code search, recursive discovery, README, FD02, old repository, whole-repository status/index operations, pull/reset/clean/stash, unrelated local-file inspection or private-data access.

Recommended branch:

`impl/ip-13i-r18-product-connection-persistence-application-v0-1`

## 3. Controlling accepted contract

The complete implementation contract is the accepted R17-R3 result:

`docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_RESULT_V0_1.md`

blob:

`813817fdfe4a67c2835021ca64d74d4ed41acc03`

with acceptance:

`2b1f23520912517f0e3ae6735208253fbfa37b4f`.

Implement exactly that contract, including:

- family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- facts `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` / `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A;
- six structural diagnostics;
- exact 8/19 persisted reasons;
- exact 13/15-key typed dependencies;
- exact 13/15-key typed payloads;
- R16-R1 cross-field/invalidation/currentness/freshness matrices;
- Option-A repaired order-invariant evaluator;
- four explicit adapter operations;
- exact selected-evidence recovery;
- exact protected-binding computation;
- deterministic lifecycle/record/intent/lineage/projection identities;
- one submit + conditional retrieve + strict direct typed-payload readback;
- exact materialization/usability semantics;
- exact 52-key adapter result and privacy/non-authority fields;
- IP-13E existing operations sufficient;
- IP-13F unchanged/non-participating.

No accepted semantic may be widened for implementation convenience.

## 4. Exact authorized read set and fixed blobs

Read only:

1. `AGENTS.md`
   - `c9a8e192f7647a1613a195655fe9c22c56502ddb`

2. this task

3. R17-R3 result
   - path above
   - `813817fdfe4a67c2835021ca64d74d4ed41acc03`

4. R17-R3 acceptance
   - `docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md`
   - `2b1f23520912517f0e3ae6735208253fbfa37b4f`

5. repaired Product Connection evaluator
   - `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
   - `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`

6. Common Authority
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - `e98e7db731d41269a7b89e01db12e1a81364751d`

7. IP-13A
   - `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
   - `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`

8. IP-13D
   - `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
   - `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`

9. IP-13E
   - `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
   - `aa9721dfa66fe17eb2314bc9466870d479c07644`

10. Canonical Match adapter, orchestration contrast only
    - `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
    - `789e8905b2c9ee54d902d8b600100896af4f6063`

11. repaired Product Connection evaluator Unit test
    - `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`
    - `c68f82adf44af65ca80e51d7fc73bf1522b81980`

12. Canonical Match persistence family test, persistence-test contrast/regression
    - `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceFamilyTest.php`
    - `aaa5c90f038db7ab3fb92c927c067f7fabe2d423`

13. reference repository regression
    - `services/backend-laravel/tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php`
    - `f5ed7cef27459faa2f799040f2166fd8e2d15b1f`

14. SQLite adapter regression
    - `services/backend-laravel/tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php`
    - `5a7c697174710f6b189a6b86681d83d7b4d72d6a`

15. Canonical Match application adapter test, application-test contrast/regression
    - `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
    - `c8298f5e786a47d118b56f47cef6baab7f543b60`

16. IP-13E application boundary regression
    - `services/backend-laravel/tests/Unit/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php`
    - `78ac776ecb3f48a9614ad94be3349464af6aa4a5`

17. backend dependency/config files, tooling only:
    - `services/backend-laravel/composer.json` — `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
    - `services/backend-laravel/composer.lock` — `66327f584d3961c2b53391bb012047dda9cc9d23`
    - `services/backend-laravel/phpunit.xml` — `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`
    - `services/backend-laravel/.gitignore` — `c7cf1fa675f65701fc1118ad21257badc7899c46`

No other read is authorized.

## 5. Exact tracked write set

Modify exactly:

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
2. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

Create exactly:

3. `services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`
4. `services/backend-laravel/app/Domain/ProductConnectionPersistenceApplicationAdapter.php`
5. `services/backend-laravel/tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php`
6. `docs/architecture/ELITESYNC_V10_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_IMPLEMENTATION_RESULT_V0_1.md`

These four create-only paths are confirmed absent at the pre-task base.

No other tracked file may change.

In particular do NOT modify:

- Product Connection evaluator/test;
- Common Authority;
- IP-13E;
- Canonical Match source/tests;
- Composer/config/lock;
- route/controller/Feature/HTTP;
- IP-13F;
- Flutter/client;
- roadmap/context/AGENTS;
- downstream domain source.

## 6. Tooling preflight and offline materialization

From `services/backend-laravel` in the new isolated worktree:

Allowed environment observations:

1. `php -v`
2. `composer --version`

If either is unavailable, stop and report exact evidence.

If `vendor/bin/phpunit` is absent, run exactly one offline materialization attempt:

`COMPOSER_DISABLE_NETWORK=1 composer install --no-interaction --prefer-dist --no-progress --no-scripts --no-plugins`

Rules:

- network remains disabled;
- consume exact checked-in lock only;
- no Composer update/audit/scripts/plugins;
- no lock/config edits;
- no manual cache exploration;
- no copying vendor from another worktree;
- one Composer attempt maximum;
- if cache material is insufficient, stop and report first actionable missing dependency/error.

After success only verify:

- `vendor/autoload.php` exists;
- `vendor/bin/phpunit` exists.

Ignored `vendor/` must never be staged or committed.

## 7. PHASE A — persistence implementation

Do not create or modify Phase B adapter/test paths before Phase A passes.

### 7.1 IP-13A

Add the Product Connection family and exact validator/projection behavior required by R17-R3.

At minimum:

- exact family constant;
- dispatch for both exact payload kinds/fact classes;
- exact payload key sets;
- exact typed dependency key sets;
- six diagnostics excluded from persisted reasons;
- 8/19 persisted reason validation;
- exact classification/reason consistency;
- complete dependency-presence and cross-field matrices;
- exact five-field expected-state revision comparison;
- `protected_binding_satisfied` exact boolean type and fully-usable predicate;
- currentness/freshness aggregation consistency;
- cross-type dependency identity distinctness;
- invalidation object and preservation rules;
- current-state-based terminality;
- Binding Model A constants;
- deterministic lifecycle/schema/digest identities and derived revision 0;
- logical intent and projection metadata consistency;
- exact derived payload retention in privacy-minimal projection;
- Product Connection exemption from generic derived-payload invalidation rewrite while preserving generic overlay fields;
- no weakening/change to RR03 or Canonical Match behavior.

Do not infer source authority from family validity.

### 7.2 IP-13D

Mirror IP-13A semantics under existing `sqlite::memory:` physical schema.

Requirements:

- no table/column/migration change;
- Product Connection family payload retained exactly rather than stripped;
- reference validator still gates storage;
- exact payload bytes/structure survive physical store/read/resolve/history projection;
- generic overlay exemption mirrors reference behavior;
- duplicate/changed-input/equal-revision/incomparable/terminal lifecycle behavior remains parity-compatible;
- no new authority.

### 7.3 Product Connection persistence test

Create one `ProductConnectionPersistenceFamilyTest.php` covering reference and SQLite together.

At minimum verify:

- exact valid current-state known record reference/SQLite parity;
- exact current UNKNOWN no-dependency record;
- current `CURRENT_STATE_NOT_CURRENT_FRESH_BOUND` with dependency;
- transition resolution-failure UNKNOWN;
- transition `TRANSITION_NOT_CURRENT_FRESH_BOUND`;
- transition context mismatch;
- ADMISSIBLE;
- all three policy REJECTED categories;
- dependency invalidated current and transition;
- malformed/wrong key/dependency/reason/context/currentness/freshness/terminal shapes rejected;
- 13/15-key dependency exactness;
- expected-state revision exact tuple;
- cross-type identity collision rejection;
- deterministic identity mismatch rejection;
- exact typed payload retained directly in privacy-minimal projection;
- generic projection invalidation does not mutate typed Product Connection dependency invalidation;
- exact duplicate;
- changed-input reuse rejection;
- incomparable coexistence;
- terminal lifecycle no-reopen;
- proposed terminal transition does not make non-terminal current lifecycle terminal;
- reference/SQLite outcome and projection parity.

Use synthetic identifiers only.

## 8. PHASE A hard test gate

Run exactly:

`vendor/bin/phpunit tests/Unit/ProductConnectionPersistenceFamilyTest.php tests/Unit/CanonicalMatchPersistenceFamilyTest.php tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php`

Phase A PHPUnit attempt budget:

- initial: 1;
- after authorized Phase A correction: at most 2 additional;
- maximum Phase A PHPUnit executions: 3.

If a run passes, do not rerun for confidence.

If failure is caused by the authorized Phase A code/test, fix only Phase A write paths and rerun within budget.

If failure requires changing any unlisted file, accepted contract, Composer/tooling, Common Authority, physical schema or another family semantic, STOP.

**Phase B is forbidden unless the entire Phase A command passes with zero test failures/errors.**

If Phase A cannot pass within budget, do not create Phase B files and do not publish an R18 candidate.

## 9. PHASE B — dedicated application adapter

Only after Phase A PASS.

Create:

`ProductConnectionPersistenceApplicationAdapter.php`

using the accepted four-operation topology:

1. `evaluateCurrentSynthetic(array $request): array`
2. `evaluateTransitionSynthetic(array $request): array`
3. `invalidateCurrentSynthetic(array $request): array`
4. `invalidateTransitionSynthetic(array $request): array`

Constructor consumes existing IP-13E application boundary.

### 9.1 Strict synthetic gate

Require exact R17-R3 envelope/nested key sets and marker `synthetic_dev_test_only === true`.

Use `InvalidArgumentException` for application-local pre-materialization rejection, carrying the exact accepted diagnostic literal as the exception message or a deterministic message containing exactly one such literal:

- `CONNECTION_IDENTITY_REQUIRED`
- `EXACTLY_TWO_PARTICIPANTS_REQUIRED`
- `PROTECTED_USE_SCOPE_REQUIRED`
- `INVALID_EVIDENCE_SHAPE`
- `INVALID_CONNECTION_STATE`
- `INVALID_TARGET_STATE`

This exception mechanism is internal synthetic application behavior only; it creates no HTTP status/transport contract.

Do not convert structurally valid cross-Connection/participant/identity/incomparable/maximal-conflict/context/usability conditions into input errors.

### 9.2 Evaluator calls

Implement exact call counts:

- current evaluate: one direct `evaluateCurrent()`;
- transition evaluate: one direct `evaluateTransition(..., null)`, no external current call;
- current invalidate: one fresh current evaluation + one `invalidate()`;
- transition invalidate: one fresh transition evaluation + one `invalidate()`.

No retries or caller-provided prior result.

### 9.3 Recovery and payload/record construction

Implement R17-R3 exactly:

- selected current/transition public-vector matching;
- all exact matches must agree on recovered metadata;
- transition matches must agree on expected-state revision;
- exact protected-binding computation from original required/source bindings + descriptor checks;
- exact typed dependencies;
- exact R16-R1 matrices;
- exact current/transition payloads;
- exact current-state-based terminality;
- exact invalidation retention;
- Binding Model A;
- deterministic lifecycle/record/intent/lineage/projection correlation;
- derived revision value 0;
- fixed non-authority metadata.

Application may canonicalize data only as accepted for persistence correlation; it must not sort/filter source evidence to alter evaluator semantics.

### 9.4 IP-13E orchestration

For a successfully constructed record:

- submit exactly once via existing `submitAuthoritativeMutation()`;
- inspect storage outcome;
- retrieve exactly once only for `STORED_NEW | EXACT_DUPLICATE | INCOMPARABLE_COEXISTS`;
- no retry;
- query/bindings exactly as R17-R3;
- direct typed-payload equality required for exact readback;
- digest/identity equality alone insufficient.

Do not call `observeInvalidation()` to implement Product Connection dependency invalidation.

### 9.5 Usability/result/privacy

Return exactly R17-R3's 52-key internal result.

Preserve:

- exact materialization != protected-use validity;
- current UNKNOWN unusable;
- transition UNKNOWN/REJECTED unusable;
- only exact protected-valid known current state usable;
- only exact protected-valid ADMISSIBLE transition usable;
- generic projection invalidation makes readback unusable without mutating typed dependency invalidation;
- all fixed non-authority fields false;
- no raw source/required bindings or unselected candidates in payload/result.

## 10. Product Connection adapter test

Create one `ProductConnectionPersistenceApplicationAdapterTest.php`.

At minimum cover:

### Structural/gate
- exact synthetic marker/envelope;
- all six structural diagnostics;
- structurally valid cross-Connection/participant/identity/incomparable/conflict/context cases reach evaluator semantics rather than exception.

### Current operation
- known current state exact usable materialization;
- missing evidence UNKNOWN remains unusable;
- selected unusable dependency;
- maximal-revision order-invariant recovery;
- metadata disagreement among exact public-vector recovery matches fails closed;
- current dependency invalidation and repeat determinism.

### Transition operation
- ADMISSIBLE exact usable materialization;
- transition resolution UNKNOWN;
- not-current/fresh/bound UNKNOWN;
- context mismatch;
- three policy REJECTED cases;
- maximal/incomparable/conflicting duplicate cases;
- transition dependency invalidation for current and transition identities;
- no external duplicate current evaluation.

### Persistence/application
- one submit;
- conditional retrieve only for exact accepted dispositions;
- exact duplicate deterministic correlation;
- incomparable coexistence exact-lineage behavior;
- terminal lifecycle no-reopen;
- generic invalidation makes projection unusable without payload mutation;
- strict typed-payload direct equality;
- exact 52-key result;
- no raw evidence/bindings leak;
- fixed false non-authority fields;
- input request not mutated.

Where exact evaluator call count cannot be instrumented without changing production API, prove by adapter structure plus externally observable persistence/result invariants; do not add test-only production hooks.

## 11. PHASE B final combined hard test gate

After Phase B implementation, run exactly:

`vendor/bin/phpunit tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php tests/Unit/ProductConnectionPersistenceFamilyTest.php tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php tests/Unit/CanonicalMatchPersistenceFamilyTest.php tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php tests/Unit/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php`

Phase B/final PHPUnit attempt budget:

- initial final gate: 1;
- after authorized Phase B or shared-scope correction: at most 2 additional;
- maximum final-gate PHPUnit executions: 3.

A passing run ends the test budget.

If failure requires any non-write-set modification, new architecture decision, HTTP, IP-13E change, evaluator change, dependency installation/update or network, STOP.

Do not weaken existing tests.

## 12. Allowed runtime commands

Besides Section 6 offline tooling and exact Phase A/Phase B PHPUnit commands, no runtime commands are authorized.

Do NOT run:

- any other Composer command;
- Artisan;
- arbitrary PHP scripts;
- server/HTTP;
- database commands outside PHPUnit-created in-memory behavior;
- migrations/generators;
- code formatter;
- static-analysis/coverage suites;
- dependency update/download/network;
- Flutter/Dart/Gradle/Java/Android;
- production or real/private-data operations.

## 13. Result document

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_IMPLEMENTATION_RESULT_V0_1.md`

Record:

- execution authority;
- branch/candidate/sole parent/tree after publication;
- exact six-path committed scope;
- before/after IP-13A/IP-13D blobs;
- new persistence test/adapter/adapter-test/result blobs;
- accepted R17-R3 result/acceptance blobs;
- tooling preflight and offline Composer receipt if used;
- Phase A implementation summary;
- exact Phase A command, attempt count, tests/assertions/failures/errors/skips/deprecations;
- explicit hard-gate PASS before Phase B began;
- Phase B implementation summary;
- exact final combined command, attempt count, tests/assertions/failures/errors/skips/deprecations;
- exact Product Connection persistence/application behaviors proven;
- existing RR03/Canonical Match/shared regressions;
- unchanged IP-13E/evaluator/Common Authority/IP-13F;
- confirmation no HTTP/downstream/production/private-data work;
- fresh independent ACCEPT/REJECT requirement.

Successful classification:

`IP-13I-R18 IMPLEMENTATION COMPLETE — PRODUCT CONNECTION PERSISTENCE FAMILY + SQLITE PARITY ACCEPTANCE CANDIDATE AND DEDICATED APPLICATION ADAPTER COMPLETED IN HARD-SEQUENCED PHASES — PHASE A PERSISTENCE GATE PASSED BEFORE PHASE B — EXACT SUBMIT/READBACK/USABILITY + SHARED REGRESSIONS PASS — NO HTTP / IP-13F / DOWNSTREAM AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.

## 14. Candidate publication rule

Only if both hard gates pass:

- candidate is exactly one commit;
- sole parent = task-publication authority from execution prompt;
- exactly six tracked paths from Section 5;
- ignored vendor not committed;
- remote branch points exactly to candidate.

Candidate author cannot self-accept, merge, move main, author Product Connection HTTP or Messaging successor, or start downstream work.

Fresh reviewer must inspect exact code/test diff and both test receipts, then ACCEPT or REJECT before any downstream task is authored.
