# EliteSync v10｜Next IP-13I-R18-R1 Product Connection Application Binding-Order Correction Task｜v0.1

Status: `OWNER-AUTHORIZED — RECONSTRUCT RETAINABLE R18 IMPLEMENTATION + NARROW APPLICATION CORRECTION + ONE FINAL COMBINED REGRESSION GATE — NO HTTP / NO DOWNSTREAM`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Task-publication base before this task commit:

`708238f3fcbc535d266945c4c04c2f826647d542`

This task corrects the independently rejected R18 candidate:

`64dd8f8dccbbb3582656f98a70b1e36c6449fe0b`

The rejection did not reopen R17-R3 architecture or Package A. It established one blocking Product Connection application defect:

`PROTECTED_BINDING_MUST_NOT_DEPEND_ON_PHP_ASSOCIATIVE_KEY_INSERTION_ORDER`

and one execution-process deviation:

`FIRST_PASS_MUST_END_THE_TEST_BUDGET`.

## 1. Objective

Produce one corrected R18-R1 candidate that preserves the retainable R18 persistence implementation byte-for-byte, corrects only the Product Connection application's protected-binding comparison and its targeted test coverage, runs one complete final combined regression gate, and publishes one fresh result.

Do not redesign persistence, mapping, evaluator semantics, IP-13E, HTTP or downstream work.

## 2. Fresh-base gate

Before substantive work:

1. read `AGENTS.md` FIRST from the task-publication authority supplied by the execution prompt;
2. fresh-fetch `origin/main`;
3. require `origin/main` to equal that exact task-publication commit;
4. read this task from that exact commit and verify its blob;
5. create one new isolated correction branch/worktree from exactly that task-publication authority;
6. verify the create-only Product Connection code/test/result paths in Section 6 are absent at the task base;
7. verify every fixed object and rejected-candidate blob;
8. stop rather than adapt on any mismatch.

No repository enumeration, filename/code search, recursive discovery, README, FD02, old repository, whole-repository status/index operation, pull/reset/clean/stash, unrelated file inspection or private-data access.

Recommended branch:

`fix/ip-13i-r18-r1-product-connection-binding-order-v0-1`

## 3. Accepted controlling contract

Preserve independently accepted R17-R3:

- mapping Option A;
- IP-13E existing operations sufficient;
- Package A persistence-first sequential implementation;
- complete four-operation adapter contract;
- exact six structural diagnostics;
- exact 8/19 persisted reasons;
- exact 13/15-key dependencies and 13/15-key payloads;
- exact cross-field/currentness/freshness/invalidation matrices;
- Binding Model A;
- deterministic lifecycle/record/intent/lineage/projection identities;
- exact submit/retrieve/readback/usability rules;
- exact 52-key internal result;
- IP-13F unchanged/non-participating.

R17-R1/R17-R2 evaluator policy/implementation remains accepted and unchanged.

## 4. R18 rejection findings controlling this correction

Independent R18 rejection:

`docs/architecture/ELITESYNC_V10_IP_13I_R18_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

blob:

`26bcbaf64953159c0ea53c5e9be78e817e2192c9`.

### R18-F1 — blocking

Rejected adapter blob:

`824f6950a0358d13675fb6cc79ce6c9eeaf45434`

implements protected binding using whole-array PHP strict equality:

`$required === $source`.

That makes result depend on associative key insertion order even though:

- both containers independently pass exact named-key structural validation;
- Common Authority treats them as named binding fields;
- accepted R17-R3 requires exact equality of each corresponding binding field, not insertion-order authority.

Correction must compare each of the exact eleven named binding fields by key/value.

For the `participants` binding field, preserve exact field-value equality between required/source arrays. Do not sort that field as part of required/source equality. The separate descriptor participant comparison remains set-based.

### R18-F2 — process

The rejected run executed a third final-gate PHPUnit process after attempt 2 had already passed, contrary to:

`A passing run ends the test budget.`

For this correction:

- perform all static review/editing before the first test command;
- once the combined test command passes, make no further tracked edit and run no further test command;
- if a post-pass concern is discovered, report it instead of changing/rerunning.

## 5. Exact authorized read set

Read only:

1. `AGENTS.md`
   - expected blob `c9a8e192f7647a1613a195655fe9c22c56502ddb`

2. this task

3. R17-R3 result
   - `docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_RESULT_V0_1.md`
   - blob `813817fdfe4a67c2835021ca64d74d4ed41acc03`

4. R17-R3 acceptance
   - `docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md`
   - blob `2b1f23520912517f0e3ae6735208253fbfa37b4f`

5. R18 task
   - `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_FIRST_COMBINED_PERSISTENCE_APPLICATION_IMPLEMENTATION_TASK_V0_1.md`
   - blob `a9686e0ac8d6ceae404fd2850c1038f24b1188c3`

6. R18 rejected result at exact rejected candidate only
   - ref `64dd8f8dccbbb3582656f98a70b1e36c6449fe0b`
   - path `docs/architecture/ELITESYNC_V10_IP_13I_R18_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_IMPLEMENTATION_RESULT_V0_1.md`
   - blob `31523004ffd8d7d8511bcd667bcdea8d78cc5cd5`
   - execution/history evidence only, not accepted result

7. R18 independent rejection
   - path/blob from Section 4

8. rejected R18 implementation blobs, exact candidate ref only:
   - IP-13A `6178bc7290a9e542a39155756c9dd9e43d9eb0b2`
   - IP-13D `678881a6c5868170270f4a400351966dd2e69a95`
   - persistence test `e4e6b946e5bace72da0bf36db6fd49caa328d00f`
   - application adapter `824f6950a0358d13675fb6cc79ce6c9eeaf45434`
   - adapter test `b1680ef749a7e30b7d696988809360c86ee51171`

9. unchanged repaired evaluator
   - `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
   - blob `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`

10. Common Authority
    - `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
    - blob `e98e7db731d41269a7b89e01db12e1a81364751d`

11. IP-13E
    - `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
    - blob `aa9721dfa66fe17eb2314bc9466870d479c07644`

12. unchanged shared regression tests:
    - Product Connection evaluator test `c68f82adf44af65ca80e51d7fc73bf1522b81980`
    - Canonical Match persistence family test `aaa5c90f038db7ab3fb92c927c067f7fabe2d423`
    - Canonical Match adapter test `c8298f5e786a47d118b56f47cef6baab7f543b60`
    - reference persistence test `f5ed7cef27459faa2f799040f2166fd8e2d15b1f`
    - SQLite adapter test `5a7c697174710f6b189a6b86681d83d7b4d72d6a`
    - IP-13E application boundary test `78ac776ecb3f48a9614ad94be3349464af6aa4a5`

13. backend tooling-only files:
    - composer.json `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`
    - composer.lock `66327f584d3961c2b53391bb012047dda9cc9d23`
    - phpunit.xml `0ac22afdcc6db3aabbde7e77a0430a8e5738cda9`
    - .gitignore `c7cf1fa675f65701fc1118ad21257badc7899c46`

No other read is authorized.

## 6. Exact tracked write set

Modify exactly:

1. `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
2. `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`

Create exactly:

3. `services/backend-laravel/tests/Unit/ProductConnectionPersistenceFamilyTest.php`
4. `services/backend-laravel/app/Domain/ProductConnectionPersistenceApplicationAdapter.php`
5. `services/backend-laravel/tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php`
6. `docs/architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_RESULT_V0_1.md`

The three Phase-A paths 1–3 MUST finish byte-identical to the rejected R18 blobs:

- IP-13A `6178bc7290a9e542a39155756c9dd9e43d9eb0b2`;
- IP-13D `678881a6c5868170270f4a400351966dd2e69a95`;
- persistence test `e4e6b946e5bace72da0bf36db6fd49caa328d00f`.

Paths 4–5 must start from the rejected R18 implementation content and receive only the correction/test additions needed by this task.

Do not create or integrate the rejected R18 result document.

No other tracked path may change.

## 7. Reconstruction rule

The rejected candidate is not an accepted ancestor.

Create the correction branch from the fresh R18-R1 task-publication authority, not from `64dd8f8d...`.

It is authorized to read/materialize the exact five code/test files from rejected candidate `64dd8f8d...` into the Section 6 paths using exact Git object/path reads.

Do not merge or cherry-pick the rejected commit as an ancestor.

After reconstruction, verify the three Phase-A blobs exactly match Section 6 before editing Phase B paths.

## 8. Required application correction

In `ProductConnectionPersistenceApplicationAdapter.php`, replace whole-associative-array strict equality as the protected-binding equality decision.

Implement a deterministic helper equivalent to:

- iterate the exact eleven Common Authority binding key names;
- for every key require both containers to contain the key;
- require `$required[$key] === $source[$key]`;
- return true only if every corresponding field is exactly equal.

Because the structural gate already requires the exact eleven keys, this helper must not introduce extra accepted keys.

Then retain all existing descriptor checks:

- required subject = Connection identity;
- required aggregate context = Connection identity;
- required lifecycle identity = Connection identity;
- required participants represent the same Connection participant set;
- required purpose = protected-use scope;
- current-state required terminal equals state terminality.

Do not add source condition/currentness/freshness into `protected_binding_satisfied`.

Do not change the evaluator or Common Authority.

## 9. Required targeted regression additions

Extend `ProductConnectionPersistenceApplicationAdapterTest.php`.

At minimum add:

### A. Same named bindings, different associative key insertion order

For one otherwise fully valid current-state request:

1. keep `required_bindings` valid;
2. reconstruct `source_evidence.bindings` with the same exact eleven keys and exactly equal field values but a different associative insertion order;
3. keep source revision owner/scope/context correctly bound;
4. assert the request is not structurally rejected;
5. assert known current classification remains expected;
6. assert persisted dependency has `protected_binding_satisfied === true`;
7. assert protected-valid exact materialization remains usable.

### B. True field mismatch remains false

Create an otherwise valid request where exactly one corresponding required/source binding field value differs while the container remains structurally valid and source revision remains internally consistent.

Assert:

- no structural input exception solely because of the semantic binding mismatch;
- evaluator/application follows the accepted unusable/bounded semantics;
- recovered dependency has `protected_binding_satisfied === false`;
- materialized projection is not protected-use usable.

Do not make associative key order itself authoritative.

Retain all rejected-R18 adapter tests unchanged unless required to add these cases.

## 10. Static audit before runtime

Before the first PHPUnit execution:

- inspect the exact six-path diff;
- verify Phase-A blobs are byte-identical to Section 6;
- verify only adapter/test differ from their rejected-R18 starting blobs, plus the new correction result is not yet required until after test pass;
- verify no whole-array binding equality remains as the protected-binding decision;
- verify no unrelated source change;
- finish all code/test edits.

After this point, the first passing PHPUnit run ends runtime/edit authority.

## 11. Tooling and offline materialization

From `services/backend-laravel`:

Allowed observations:

1. `php -v`
2. `composer --version`

If `vendor/bin/phpunit` is absent, run at most one:

`COMPOSER_DISABLE_NETWORK=1 composer install --no-interaction --prefer-dist --no-progress --no-scripts --no-plugins`

Same constraints as R18:

- network disabled;
- exact lock only;
- no update/audit/scripts/plugins;
- no lock/config change;
- no manual cache exploration;
- no copied vendor.

If offline cache is insufficient, stop.

## 12. Single combined regression gate

Run exactly:

`vendor/bin/phpunit tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php tests/Unit/ProductConnectionPersistenceFamilyTest.php tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php tests/Unit/CanonicalMatchPersistenceFamilyTest.php tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php tests/Unit/InMemoryLogicalPersistenceRepositoryContractTest.php tests/Unit/SqliteInMemoryLogicalPersistenceAdapterTest.php tests/Unit/PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php`

Attempt budget:

- initial combined run: 1;
- only if it fails because of the authorized adapter/test correction, at most 1 correction rerun;
- total maximum: 2 PHPUnit process executions.

**The first passing run ends the task's test/edit budget.**

After a pass:

- do not edit tracked source/test files;
- do not rerun PHPUnit;
- only create/finalize the result document from already observed evidence and publish the candidate.

If a post-pass static concern appears, record it and stop without modifying/rerunning.

## 13. Runtime prohibitions

Except Section 11 and Section 12, no runtime command is authorized.

Do not run:

- any other Composer command;
- Artisan;
- arbitrary PHP scripts;
- server/HTTP;
- external database;
- migrations/generators;
- formatter/static-analysis/coverage;
- dependency update/network;
- Flutter/Dart/Gradle/Java/Android;
- production or real/private-data operations.

## 14. Result document

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_RESULT_V0_1.md`

Record:

- authority and task blob;
- rejected R18 candidate/result/review blobs;
- branch/candidate/sole parent/tree after publication;
- exact six-path scope;
- exact three byte-identical Phase-A blobs;
- rejected vs corrected adapter/test blobs;
- exact field-wise binding equality implementation;
- new insertion-order regression and true mismatch regression;
- PHP/Composer preflight;
- offline Composer receipt if used;
- exact combined PHPUnit command;
- attempt count;
- tests/assertions/failures/errors/skips/deprecations;
- confirmation first passing run ended test/edit budget;
- confirmation no HTTP/IP-13F/downstream/private-data work;
- fresh independent ACCEPT/REJECT requirement.

Successful classification:

`IP-13I-R18-R1 CORRECTION COMPLETE — R18 PHASE-A PERSISTENCE BLOBS PRESERVED EXACTLY — APPLICATION PROTECTED-BINDING COMPARISON NOW FIELD-WISE AND ASSOCIATIVE-KEY-ORDER-INVARIANT — TRUE BINDING MISMATCH STILL FAILS PROTECTED USE — FULL COMBINED REGRESSION PASS — FIRST PASS STOP RULE HONORED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.

## 15. Publication rule

Only after the combined gate passes:

- publish one immutable candidate;
- sole parent = R18-R1 task-publication authority from the execution prompt;
- exactly the six Section 6 tracked paths;
- ignored vendor not committed;
- remote correction branch points exactly to candidate.

Candidate author cannot self-accept, merge, move main, author HTTP/downstream tasks or start Messaging/Conversation work.
