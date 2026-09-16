# EliteSync v10｜Next IP-11H Backend Pure Common Authority-Evidence Contract Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Owner-authorized implementation base: `ef63312531504f06d77370cf095143da329cfa7f`

Accepted IP-11G gate draft: `docs/architecture/ELITESYNC_V10_IP_11G_FINAL_OWNER_IMPLEMENTATION_GATE_DRAFT_V0_1.md`

Accepted IP-11G acceptance commit: `ef63312531504f06d77370cf095143da329cfa7f`

## 1. Owner authorization

The Owner explicitly authorizes execution of exactly:

`NEXT-IP-11H-BACKEND-PURE-COMMON-AUTHORITY-EVIDENCE-CONTRACT-IMPLEMENTATION-V0-1`

against exact accepted main commit:

`ef63312531504f06d77370cf095143da329cfa7f`

This authorization is limited to one pure common authority-evidence / source-condition / immutable-intent contract slice with synthetic fixtures only, exactly as bounded by the independently accepted IP-11G gate.

No other implementation, dependency, product-policy, production, private-data, legal, Safety, client, provider, endpoint, persistence, migration or deployment authority is created.

## 2. Mandatory fresh-base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main == ef63312531504f06d77370cf095143da329cfa7f`.
4. Prove the accepted IP-11G gate is present at that commit.
5. Create one isolated review worktree/branch from that exact commit.
6. Verify all three authorized output paths below are absent at the base.
7. Verify, without enumerating vendor, that these exact readiness locators exist:
   - `services/backend-laravel/vendor/autoload.php`
   - `services/backend-laravel/vendor/bin/phpunit`
8. Stop before any write if any identity/path/readiness condition differs.

A newer/different main is not permission to adapt. No rebase, merge, cherry-pick, alternate base or substitute path is authorized.

Recommended branch:

`review/next-ip-11h-backend-pure-common-authority-evidence-contract-implementation-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
2. `services/backend-laravel/tests/Unit/CommonAuthorityEvidenceContractTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_PURE_COMMON_AUTHORITY_EVIDENCE_CONTRACT_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may be modified.

No helper, fixture, trait, snapshot, config, generated, migration, route, model, controller, service, provider, cache, queue, database, endpoint, client or build file may be created or changed.

No `vendor/**` path may be staged or committed.

The source namespace/type are fixed:

- namespace: `App\Domain`
- type: `CommonAuthorityEvidenceContract`

The test namespace/type are fixed:

- namespace: `Tests\Unit`
- type: `CommonAuthorityEvidenceContractTest`

Synthetic fixtures must live inside the exact test file.

## 4. Authorized implementation semantics only

The source file may contain only dependency-free, deterministic, in-memory representation and pure validation/classification behavior needed to prove:

1. explicit authority owner/scope binding;
2. actor/role binding;
3. exact subject or participant-set binding;
4. exact audience/purpose binding;
5. explicit aggregate/context identity;
6. source-condition distinction including at least `PRESENT`, `ABSENT`, `UNKNOWN`, `UNAVAILABLE`, `STALE`, `SUPERSEDED`, `INCOMPARABLE`;
7. `UNKNOWN != ABSENT`;
8. source-local revision comparison only within the same authority/scope/lineage/context;
9. no global revision and no last-received-wins ordering;
10. currentness and freshness as separate dimensions;
11. currentness does not imply freshness;
12. freshness does not manufacture currentness;
13. one logical-intent identity bound immutably to one full semantic input;
14. exact duplicate correlation only when identity and all semantic inputs match;
15. changed-input reuse of the same intent identity is rejected;
16. idempotency identity is correlation only, not permission or success;
17. authoritative outcome categories distinguish committed, rejected and unknown;
18. transport ambiguity remains unknown until source-authoritative reconciliation resolves it;
19. transport observation alone cannot decide the domain outcome;
20. correction/revocation/supersession invalidates displaced evidence/projection;
21. invalidation does not reset lifecycle, reopen terminal identity, create a new aggregate or synthesize a transition;
22. privacy-minimal projection exposes only bounded opaque synthetic references and explanatory categories;
23. projection is not authority, permission, a bearer capability, success proof or substitute writer;
24. required-binding mismatch/missing/unknown/unavailable/stale/superseded/incomparable conditions fail closed for the affected protected evaluation.

The implementation must not create a general framework, product lifecycle, transport abstraction, persistence adapter or production integration.

## 5. Synthetic-only test obligations

Use conspicuously invented literals only, such as `synthetic-owner-A`, `synthetic-subject-A`, `synthetic-lineage-A`, `synthetic-intent-A`.

The exact unit test file must independently prove at least:

- complete binding preserved;
- authority mismatch fails closed;
- actor/role mismatch fails closed;
- subject/participant mismatch fails closed;
- audience/purpose mismatch fails closed;
- `UNKNOWN` and `ABSENT` remain distinct;
- same-lineage revision comparison only;
- cross-lineage comparison returns `INCOMPARABLE`;
- no global revision output;
- current-but-stale case;
- freshness cannot establish currentness;
- exact duplicate correlation;
- same intent + changed owner/scope rejected;
- same intent + changed subject/participants rejected;
- same intent + changed context rejected;
- same intent + changed expected revision rejected;
- same intent + changed audience/purpose rejected;
- idempotency non-authority;
- idempotency non-success;
- ambiguous transport -> unknown authoritative outcome;
- source-authoritative reconciliation can resolve that unknown outcome;
- correction invalidation;
- revocation invalidation;
- supersession invalidation;
- invalidation does not reset/reopen lifecycle identity;
- privacy-minimal projection excludes raw/private fixture material;
- projection cannot be used as source authority.

Negative assertions are required, not only happy-path assertions.

No real/redacted production data may be used.

## 6. Exact command budget

Working directory:

`services/backend-laravel/`

After both new code files exist, exactly one project-command attempt is authorized:

`vendor/bin/phpunit tests/Unit/CommonAuthorityEvidenceContractTest.php`

No retry is authorized, including after failure.

Also run `git diff --check` exactly once after final authoring.

Read-only Git/provenance commands needed to bind base, inspect the exact three paths, capture diff/stat/hash/blob/tree/parent/ahead-behind evidence, create the bounded commit and push the review branch are authorized and do not count against the single project-command budget.

## 7. Explicit prohibitions

Do not:

- run any other PHPUnit invocation, suite, filter, Feature test, coverage or mutation test;
- run Composer install/update/dump-autoload or package acquisition;
- run Composer scripts/plugins;
- run Artisan, migrations, seeders, generators or cache commands;
- run application/runtime entrypoints;
- access network/provider APIs or production systems;
- read credentials, secrets or production environment values;
- process real/private user or Conversation data;
- implement REST/GraphQL/RPC/HTTP/event-bus/wire/serialization behavior;
- implement database/schema/model persistence/cache/queue/event-log/transaction/locking behavior;
- implement Flutter/Android/client/UI/route/deep-link/local-cache behavior;
- modify `composer.json`, `composer.lock`, PHPUnit config or autoload config;
- alter existing `Matching`, `Support`, `Services` or any other business family;
- inspect or enumerate vendor/cache/generated artifacts beyond the exact readiness launcher use;
- use Sandbox, DEP13 or B12;
- reopen M1/M2/M3;
- self-accept, merge or promote `main`.

Client direction remains:

`RETAINED_FOR_LATER_IMPLEMENTATION_ROUTE — NOT REJECTED`

## 8. Failure / stop rules

Stop and publish the bounded result without remediation if:

- the accepted base differs;
- any authorized path already exists;
- either exact vendor readiness locator is missing;
- the targeted PHPUnit command cannot start or exits nonzero;
- a missing dependency/configuration requirement appears;
- fulfilling the semantics would require another tracked file, dependency, framework feature, product-policy choice, endpoint, persistence mechanism or broader authority.

No retry, alternate path, workaround or scope expansion is authorized.

## 9. Required implementation-result document

The exact result document must record:

- Owner authorization and exact approved base commit;
- branch/worktree identity;
- exact tracked-file inventory proving three files only;
- source/test/result SHA-256 and Git blob identities;
- semantic coverage map for every authorized obligation;
- synthetic fixture boundary;
- exact PHPUnit command, attempt count, exit code and non-secret summary;
- confirmation that no retry/other project command ran;
- `git diff --check` result;
- prohibitions respected;
- retained unknowns/blockers;
- candidate commit, sole parent, tree and remote ahead/behind relation;
- explicit statement that candidate still requires fresh independent ACCEPT/REJECT review.

## 10. Candidate publication contract

The candidate commit must contain exactly the three authorized paths.

Its sole parent must be:

`ef63312531504f06d77370cf095143da329cfa7f`

Push only the review branch.

Do not merge, self-accept or move `main`.

Expected success classification:

`IP-11H BACKEND PURE COMMON AUTHORITY-EVIDENCE CONTRACT IMPLEMENTED WITH SYNTHETIC FIXTURES — TARGETED UNIT TEST PASS — EXACT THREE-FILE SCOPE — NO PRODUCT/PRODUCTION/REAL-DATA AUTHORITY CREATED — READY FOR FRESH INDEPENDENT REVIEW`

If the targeted test fails or the task stops on a blocker, publish the truthful bounded result and STOP.
