# EliteSync v10｜Next IP-12A Backend Runtime Readiness Derived Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Objective

Implement exactly one second bounded backend slice:

`RUNTIME READINESS DERIVED EVALUATOR OVER SYNTHETIC PREREQUISITE-SET / CLAIM EVIDENCE`

The slice MUST consume the already accepted `App\Domain\CommonAuthorityEvidenceContract` semantics and implement only the technology-local, deterministic, in-memory Runtime Readiness derivation needed to prove the accepted IP-02 obligations.

This task does not implement a Readiness writer, verification provider, identity provider, API, database, endpoint, queue, cache, client, production integration, real/private-data processing, legal rule, age rule, Safety authority, launch policy or deployment.

## 2. Fresh-base gate

Before any project write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Record the exact task-publication commit as `TASK_PUBLICATION_COMMIT`.
4. Prove that `TASK_PUBLICATION_COMMIT` contains the independently accepted IP-11H common authority-evidence contract implementation.
5. Create one isolated worktree/branch from exactly `TASK_PUBLICATION_COMMIT`.
6. Verify all three authorized output paths in §3 are absent.
7. Verify the accepted common contract file exists at:
   - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
8. Verify `composer.json` and `composer.lock` exist and capture their pre-task SHA-256 and Git blob identities.
9. If any gate fails, STOP before writing implementation files.

Recommended branch:

`review/next-ip-12a-backend-runtime-readiness-derived-evaluator-implementation-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/RuntimeReadinessDerivedEvaluator.php`
2. `services/backend-laravel/tests/Unit/RuntimeReadinessDerivedEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_DERIVED_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may be modified.

No helper, fixture, trait, snapshot, config, migration, route, controller, model, service, provider, cache, queue, database, endpoint, client or build file may be created or changed.

No `vendor/**` path may be staged or committed.

Fixed source namespace/type:

- namespace: `App\Domain`
- type: `RuntimeReadinessDerivedEvaluator`

Fixed test namespace/type:

- namespace: `Tests\Unit`
- type: `RuntimeReadinessDerivedEvaluatorTest`

Synthetic fixtures must be local to the exact test file.

## 4. Authorized semantics

The evaluator may contain only pure, deterministic, in-memory derivation/classification behavior required to establish the following:

1. Runtime Readiness fact classes remain distinct:
   - `ELIGIBILITY`
   - `CHECKLIST`
   - `VERIFICATION`
   - `EFFECTIVE_READINESS`
   - `PRESENTATION`
2. The evaluator derives only `EFFECTIVE_READINESS`; it MUST NOT write or mutate any source claim.
3. A prerequisite set is an explicit bounded input with its own identity and source-local revision.
4. `UNKNOWN_PREREQUISITE_SET != EMPTY_PREREQUISITE_SET`.
5. An unknown/unavailable/stale/superseded/incomparable prerequisite set MUST fail closed and MUST NOT produce `READY`.
6. `READY` may be derived only when the prerequisite set is current, fresh, authoritative for the exact protected-use scope, and every required prerequisite member is present in the exact set.
7. Every required member MUST be independently current, fresh, authority/binding-valid, and satisfy the accepted member condition for that exact use.
8. Missing required member != authoritative negative member.
9. Unknown member != absent member.
10. One valid member MUST NOT repair another invalid/unknown/stale/superseded/incomparable member.
11. A member outside the prerequisite set MUST NOT influence the result.
12. Duplicate member evidence for the same required prerequisite with incomparable or conflicting source-local revisions MUST fail closed rather than use arrival order.
13. Source-local revision comparisons may only occur within the same authority/scope/lineage/context, using the accepted common contract; no global revision exists.
14. Currentness and freshness remain separate for both prerequisite-set evidence and member evidence.
15. A current-but-stale prerequisite/member MUST fail closed.
16. Freshness MUST NOT manufacture currentness.
17. Derived readiness MUST carry the exact dependency vector of prerequisite-set revision plus every accepted member evidence identity/revision/condition used.
18. A newer correction/revocation/supersession of any dependency invalidates the prior derived result for protected use.
19. Derived readiness MUST NOT back-write or repair prerequisite-set/member evidence.
20. Derived readiness MUST NOT establish launch eligibility, verification truth, Match, Connection, Consent, Conversation, Relationship, Safety, legal or production authority.
21. Projection/output must be privacy-minimal and expose only synthetic opaque prerequisite/member references, coarse conditions, dependency vector and derived readiness classification.
22. Projection/output is not source authority, permission, a bearer capability or a reusable protected-action grant.

Allowed derived classifications are limited to:

- `READY`
- `NOT_READY`
- `UNKNOWN`

`NOT_READY` may be returned only where authoritative current/fresh member evidence establishes a negative prerequisite outcome under the synthetic evaluator input contract. Missing/unknown/unavailable/stale/superseded/incomparable evidence MUST map to `UNKNOWN`, not `NOT_READY`.

## 5. Synthetic prerequisite/member shape

The implementation may define an internal pure input shape inside the single source file, but must preserve at least:

### Prerequisite-set input

- set identity
- protected-use scope
- exact required member identifiers
- source authority/scope/lineage/context
- source-local revision
- source condition
- currentness
- freshness

### Member input

- member identifier
- fact class (`ELIGIBILITY`, `CHECKLIST`, or `VERIFICATION` only for this slice)
- protected-use scope
- source evidence produced using or semantically aligned with `CommonAuthorityEvidenceContract`
- accepted synthetic prerequisite outcome: `SATISFIED` or `UNSATISFIED`

No vendor-specific verification payload, identity evidence, age/region rule, personal data, private Conversation data, Match signal, Compatibility score, telemetry or production configuration may appear.

## 6. Required synthetic proof cases

The exact unit test file must independently prove at least:

1. complete current/fresh prerequisite set + all required satisfied current/fresh members -> `READY`;
2. unknown prerequisite set -> `UNKNOWN`;
3. empty prerequisite set is distinguishable from unknown set and cannot be inferred from it;
4. unavailable prerequisite set -> `UNKNOWN`;
5. stale prerequisite set -> `UNKNOWN`;
6. superseded prerequisite set -> `UNKNOWN`;
7. incomparable prerequisite set evidence -> `UNKNOWN`;
8. missing required member -> `UNKNOWN`;
9. member with `UNKNOWN` source condition -> `UNKNOWN`;
10. member with `ABSENT` source condition remains distinct from `UNKNOWN`;
11. authoritative current/fresh `UNSATISFIED` required member -> `NOT_READY`;
12. one `SATISFIED` member cannot repair another unknown member;
13. current-but-stale member -> `UNKNOWN`;
14. fresh-but-not-current member -> `UNKNOWN`;
15. source binding mismatch for a required member -> `UNKNOWN`;
16. protected-use scope mismatch -> `UNKNOWN`;
17. extra non-required satisfied member has no effect;
18. all required members must belong to the exact prerequisite set;
19. conflicting/incomparable duplicate evidence for one required member -> `UNKNOWN`;
20. same-lineage comparable newer evidence may control only when the evaluator can establish source-local comparability under the common contract;
21. no arrival-order/last-received-wins behavior;
22. dependency vector contains exact prerequisite-set revision and each accepted required-member revision used;
23. dependency correction invalidates previous derived result;
24. dependency revocation invalidates previous derived result;
25. dependency supersession invalidates previous derived result;
26. invalidation does not mutate or rewrite source evidence;
27. derived projection contains no global revision;
28. derived projection is not source authority/permission/bearer capability;
29. derived result does not imply launch eligibility or any downstream Match/Connection/Conversation authority;
30. only synthetic fixtures are used.

Negative assertions are mandatory.

## 7. Vendor/bootstrap and project-command budget

Working directory:

`services/backend-laravel/`

### 7.1 Vendor readiness in the SAME candidate worktree

If both exact files already exist:

- `vendor/autoload.php`
- `vendor/bin/phpunit`

then do NOT run Composer.

If either is absent, exactly one Composer attempt is authorized:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

Rules:

- network use is authorized only for packages already fixed by committed `composer.lock`;
- no retry;
- no `composer update`;
- no `--ignore-platform-reqs`;
- no scripts/plugins;
- no lockfile modification;
- generated `vendor/**` stays untracked/ignored and MUST NOT be staged or committed.

After readiness is established and both new code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/RuntimeReadinessDerivedEvaluatorTest.php`

No retry.

No full suite, Feature tests, filter, coverage, mutation testing or alternate PHPUnit invocation.

After final authoring, run `git diff --check` exactly once.

Read-only Git/provenance commands needed to inspect exact paths, hashes/blobs, diff, parent/tree and ahead/behind relations are allowed and do not count against the project-command budget.

## 8. Manifest/lock preservation

Capture before and after identities for:

- `services/backend-laravel/composer.json`
- `services/backend-laravel/composer.lock`

Both SHA-256 and Git blob identities MUST remain unchanged.

Any tracked manifest/lock modification is a terminal blocker.

## 9. Explicit prohibitions

Do NOT:

- modify `CommonAuthorityEvidenceContract.php` or its test;
- implement Runtime Readiness source writers;
- implement verification provider/vendor logic;
- implement launch eligibility policy;
- choose minimum identity assurance, age, region or legal policy;
- implement endpoint/REST/GraphQL/RPC/wire/serialization;
- implement database/schema/migration/model persistence/cache/queue/event log/transaction/locking;
- implement Notification/Home/Match/Connection/Consent/Conversation behavior;
- implement client/Flutter/Android/UI/route/deep-link behavior;
- run Artisan, migrations, seeders, generators or cache commands;
- run application/runtime entrypoints;
- process real/private data or credentials;
- contact provider/product APIs or production systems;
- access Sandbox/DEP13/B12 or reopen M1/M2/M3;
- self-accept, merge or promote `main`.

Client direction remains:

`RETAINED_FOR_LATER IMPLEMENTATION ROUTE — NOT REJECTED`

## 10. Failure / stop rules

STOP and publish the bounded result without remediation if:

- fresh base/task authority cannot be proven;
- any authorized output path already exists;
- accepted common-contract source file is missing;
- Composer bootstrap is required and fails;
- Composer changes `composer.json` or `composer.lock`;
- targeted PHPUnit cannot start or exits nonzero;
- implementation would require another tracked file, framework feature, dependency change, product-policy choice, real data or broader authority;
- exact prerequisite semantics cannot be expressed without inventing unresolved launch/verification/legal policy.

No retry, alternate path, workaround or scope expansion is authorized.

## 11. Required implementation-result document

The result document must record:

- `TASK_PUBLICATION_COMMIT`;
- branch/worktree and candidate topology;
- exact three tracked paths;
- source/test/result SHA-256 and Git blob identities;
- accepted IP-11H common-contract source blob used;
- semantic coverage map for every required proof case;
- synthetic-only data boundary;
- Composer Case A/B, attempt count and result if run;
- targeted PHPUnit command, one attempt, exit and non-secret summary;
- `git diff --check` one-attempt result;
- pre/post `composer.json` and `composer.lock` SHA-256/blob identities;
- confirmation that vendor is not staged/committed;
- retained unknowns/blockers;
- candidate SHA, sole parent, tree and ahead/behind relation to fresh `origin/main`;
- explicit fresh independent ACCEPT/REJECT review requirement.

## 12. Candidate publication contract

Candidate commit must contain exactly the three authorized files.

Its sole parent must be the exact `TASK_PUBLICATION_COMMIT` from which the worktree was created.

Push only the review branch.

Do not merge, self-accept or move `main`.

Expected success classification:

`IP-12A BACKEND RUNTIME READINESS DERIVED EVALUATOR IMPLEMENTED WITH SYNTHETIC PREREQUISITE/CLAIM EVIDENCE — TARGETED UNIT TEST PASS — DEPENDENCY VECTOR / FAIL-CLOSED UNKNOWN SEMANTICS EXPLICIT — EXACT THREE-FILE SCOPE — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.