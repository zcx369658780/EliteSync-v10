# EliteSync v10｜Next IP-13A Backend In-Memory Logical Persistence Repository Contract Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `6dfa679a3da84b5ac6f06d24b6b2cae820751b92`

## 1. Objective

Implement exactly one pure, deterministic, in-memory logical persistence repository contract and its synthetic unit tests.

This slice realizes the already accepted IP-08 cross-domain interface semantics and IP-09 logical persistence/schema semantics without choosing or implementing SQL/NoSQL, tables, columns, indexes, ORM entities, migrations, transactions, locks, CAS, isolation levels, queues, brokers, service topology, endpoints, wire formats, cloud/storage vendors, encryption/KMS, client mechanisms, real/private data, legal policy, Safety policy, or production behavior.

The repository contract is a storage-boundary semantic adapter only. Storage is not source authority.

Future slice name:

`NEXT-IP-13A-BACKEND-IN-MEMORY-LOGICAL-PERSISTENCE-REPOSITORY-CONTRACT-IMPLEMENTATION-V0-1`

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from exactly that commit.
5. Verify the three authorized output paths below are absent.
6. Verify these accepted source files exist and record their blobs:
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - `services/backend-laravel/app/Domain/CoreDomainSemanticIntegrationHarness.php`
7. Verify accepted planning artifacts remain available:
   - `docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_LOGICAL_PERSISTENCE_SCHEMA_PLAN_V0_1.md`
8. Verify `services/backend-laravel/composer.json` and `composer.lock` exist and record pre identities.
9. Stop rather than adapt if any authority/base/path condition differs.

Recommended branch:

`review/next-ip-13a-backend-in-memory-logical-persistence-repository-contract-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
2. `services/backend-laravel/tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_IN_MEMORY_LOGICAL_PERSISTENCE_REPOSITORY_CONTRACT_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

Because the accepted backend boundary currently uses `app/Domain/` and `app/Contracts/` was not established, do not create a new Contracts directory or framework abstraction layer in this slice.

## 4. Fixed contract boundary

Implement only a pure in-memory repository semantic contract over logical records. The contract may accept/return arrays or immutable PHP values; do not introduce framework persistence classes.

A logical stored record must preserve, at minimum where applicable:

- logical record identity;
- record family/kind;
- authority owner/scope;
- subject and complete participant binding;
- audience/purpose;
- aggregate/context identity;
- lifecycle identity and terminal marker;
- source-local revision tuple: authority owner / authority scope / lineage / aggregate context / revision value;
- source condition;
- currentness independent from freshness;
- immutable logical-intent identity/correlation metadata when supplied;
- authoritative mutation outcome/reconciliation metadata when supplied;
- correction/revocation/supersession relation metadata when supplied;
- privacy-minimal correlation/projection metadata only.

The repository itself must never claim or synthesize source authority.

## 5. Required repository operations

The source may expose a small deterministic surface equivalent to these semantic operations, with exact method naming left to the implementation:

1. `append/store logical record`
2. `resolve current comparable record for exact logical aggregate/context`
3. `read exact logical record identity`
4. `read source-local history for exact authority/scope/lineage/context`
5. `observe invalidation/supersession metadata`
6. `return privacy-minimal persistence projection`

No delete/retention/TTL/purge policy is authorized.

No repository operation may perform a domain transition, protected action, external mutation submission, delivery, or permission decision.

## 6. Fixed semantic rules

Preserve exactly:

1. `STORED != AUTHORITATIVE`.
2. Persistence success does not establish source-authoritative success.
3. Repository presence does not imply currentness, freshness, eligibility, permission, readiness, Match, Connection, Consent, Conversation, Relationship, Notification delivery, Home action, or launch authority.
4. `UNKNOWN != ABSENT`.
5. `STALE != SUPERSEDED`.
6. currentness and freshness remain independent.
7. no global revision exists.
8. revision comparison is allowed only within exact same authority owner / authority scope / lineage / aggregate context, using accepted common-contract semantics.
9. cross-lineage/cross-authority/cross-context records are `INCOMPARABLE`; repository must not choose one as globally newer.
10. no last-write-wins or last-received-wins authority.
11. input ordering must not determine resolved authority.
12. exact duplicate storage is idempotent only when logical identity and every semantic input are identical.
13. same logical-intent identity reused with changed semantic input must fail closed / reject correlation rather than overwrite.
14. idempotency is correlation only; not permission and not success.
15. conflicting equal source-local revisions fail closed as ambiguous/conflicting; do not silently overwrite.
16. a newer comparable same-lineage record may supersede an older comparable record for repository resolution only; this does not create domain authority.
17. correction/revocation/supersession metadata invalidates displaced derived/projection use without lifecycle reset, reopen, new aggregate creation, or synthetic transition.
18. terminal lifecycle identity remains terminal; persistence must not reopen it.
19. fresh later lifecycle requires a fresh lifecycle/aggregate identity where the source domain requires that rule.
20. transport/delivery observations are not domain outcomes.
21. projections/materializations are non-authoritative and may lag; lag/currentness metadata must remain explicit when represented.
22. repository writes must not back-write or mutate supplied source/domain records.
23. repository reads must fail closed on missing, malformed, conflicting, incomparable, unknown, unavailable, stale or superseded evidence as applicable to a protected-current resolution.
24. privacy-minimal projections must omit private Conversation content, message previews/drafts, hidden Safety evidence, Compatibility/ranking/desirability/person-worth, credentials, device tokens, provider payloads, analytics/training/ads data, and raw private fixture extensions.

## 7. Storage/write disposition

For this slice, use bounded non-production outcomes such as:

- `STORED_NEW`
- `EXACT_DUPLICATE`
- `CHANGED_INPUT_REUSE_REJECTED`
- `CONFLICTING_EQUAL_REVISION_REJECTED`
- `INCOMPARABLE_COEXISTS`
- `INVALID_RECORD_REJECTED`

These are repository/storage outcomes only.

They must not be named or interpreted as domain outcomes such as Match accepted, Connection active, Consent granted, message sent, notification delivered, or launch ready.

## 8. Current-resolution disposition

A current-resolution operation may return bounded classifications such as:

- `RESOLVED`
- `MISSING`
- `UNKNOWN`
- `CONFLICTING`
- `INCOMPARABLE`

`RESOLVED` means only that the repository can deterministically select one exact comparable logical record under the accepted source-local rules. It does not mean that record is authoritative/current/fresh for a protected action unless the carried source evidence itself independently establishes those facts.

If multiple incomparable records exist for the requested logical context and the query does not identify a narrower exact lineage, resolution must fail closed as `INCOMPARABLE`.

## 9. Required synthetic proof obligations

The source/test pair must independently prove at least:

1. a valid synthetic logical record can be stored without gaining source authority;
2. storing does not mutate the supplied input;
3. exact duplicate store is idempotent and does not duplicate semantic history;
4. same intent identity + changed semantic input is rejected;
5. idempotency does not imply permission or success;
6. same-lineage newer revision resolves independent of insertion order;
7. same-lineage older revision cannot overwrite newer current resolution;
8. equal-revision identical record deduplicates;
9. equal-revision conflicting semantic record fails closed;
10. cross-lineage records are incomparable and no last-write-wins occurs;
11. cross-authority/scope/context revisions are incomparable;
12. no global revision field exists or is synthesized;
13. unknown condition remains distinct from absent/missing;
14. stale remains distinct from superseded;
15. currentness and freshness remain independent in stored/read projection;
16. current-but-stale cannot be promoted to protected-current success;
17. fresh-but-not-current cannot be promoted to protected-current success;
18. missing exact identity returns missing rather than negative domain outcome;
19. correction invalidates displaced projection use without reopening lifecycle;
20. revocation invalidates displaced projection use without reopening lifecycle;
21. supersession invalidates displaced projection use without reopening lifecycle;
22. terminal identity cannot be reopened by a later stored record with the same lifecycle identity;
23. fresh later lifecycle can coexist only under a distinct accepted lifecycle/aggregate identity;
24. persistence success does not imply authoritative mutation outcome;
25. authoritative outcome metadata, when stored, remains source-carried and is not invented by repository;
26. transport/delivery observation cannot become domain outcome;
27. projection lag/currentness metadata remains explicit and projection stays non-authoritative;
28. privacy-minimal projection omits raw private sentinel material;
29. repository creates no Match/Connection/Consent/Conversation/Relationship/Home/Notification/launch authority;
30. repository creates no persistence technology choice, SQL/NoSQL claim, transaction/locking/CAS/isolation semantics;
31. deterministic repeated reads return the same result;
32. independent input/store ordering cannot create authority;
33. source-local history retrieval is exact-lineage/exact-context bounded;
34. all fixtures are conspicuous synthetic-only values.

Negative assertions are mandatory for non-authority fields.

## 10. Explicit prohibitions

Do not implement or modify:

- Laravel models/Eloquent entities;
- migrations/schema/DDL;
- database connections or SQLite/in-memory DB;
- SQL or NoSQL;
- tables/columns/indexes/keys;
- transactions/locks/CAS/isolation;
- filesystem persistence;
- cache/Redis;
- queues/events/brokers/jobs/schedulers;
- controllers/routes/API resources/serialization/wire contracts;
- HTTP endpoints;
- provider/network integration;
- APNs/FCM/LiveKit/websocket;
- client/Flutter/Android/UI/navigation;
- production configuration/deployment;
- real/private-data processing;
- legal/Safety policy;
- retention/deletion/TTL/legal hold;
- encryption/KMS/vendor selection;
- Sandbox/DEP13/B12/M1/M2/M3;
- new domain states, transitions, precedence, ranking, Compatibility totals or product policy.

Do not modify any accepted evaluator/source/test.

Do not self-accept, merge, or move `main`.

## 11. Same-worktree vendor bootstrap rule

In the candidate worktree check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 12. Exact command budget

After both code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands needed for parent/tree/blob/ahead-behind/working-tree proof and review-branch publication are allowed.

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache/runtime/provider commands.

## 13. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file scope;
- source/test/result SHA-256 + Git blobs;
- accepted Common Authority source blob;
- accepted IP-08/IP-09 planning artifact blobs used;
- proof-case coverage;
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

`IP-13A BACKEND IN-MEMORY LOGICAL PERSISTENCE REPOSITORY CONTRACT IMPLEMENTED WITH SYNTHETIC FIXTURES — STORAGE / SOURCE-AUTHORITY SEPARATION — SOURCE-LOCAL LINEAGE / FAIL-CLOSED CONFLICT / IDEMPOTENCY / INVALIDATION / PRIVACY-MINIMAL PROJECTION BOUNDARIES EXPLICIT — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.