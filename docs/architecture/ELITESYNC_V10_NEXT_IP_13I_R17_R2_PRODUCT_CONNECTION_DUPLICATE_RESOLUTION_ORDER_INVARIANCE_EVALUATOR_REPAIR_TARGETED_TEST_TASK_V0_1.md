# EliteSync v10｜Next IP-13I-R17-R2 Product Connection Duplicate-Resolution Order-Invariance Evaluator Repair + Targeted Test Task｜v0.1

Status: `OWNER-AUTHORIZED — IMPLEMENTATION + TARGETED TEST + RESULT IN ONE BOUNDED TASK — NO PERSISTENCE / APPLICATION / HTTP — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Task-publication base before this task commit:

`81bf13a12765ec888a40883596b2b147e3e0f037`

This task consumes the independently accepted R17-R1 Option A policy and performs one complete bounded engineering delivery: evaluator repair + targeted regression tests + one result document.

It does not authorize a fresh mapping review in the same candidate. It does not authorize R18, persistence, application adapter, HTTP, Messaging/Conversation, production, or real/private-data work.

## 1. Objective

Implement the accepted Product Connection duplicate-resolution policy:

`MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`

The repaired evaluator must make state and transition duplicate resolution invariant to input permutation while preserving all existing outer semantic checks and all accepted reason vocabularies.

The candidate must also extend the existing evaluator Unit test so the R17-F1 counterexample and the accepted permutation matrix become executable regression evidence.

## 2. Fresh-base gate

Before substantive work:

1. read `AGENTS.md` FIRST from the task-publication authority;
2. fresh-fetch `origin/main`;
3. resolve the exact commit containing this task from the execution prompt;
4. require `origin/main` to equal that exact task-publication commit;
5. create one isolated implementation branch/worktree from exactly that commit;
6. verify the result path in Section 5 is absent;
7. verify every fixed source blob in Section 4;
8. verify no authorized write path differs from the fixed blob or expected absence;
9. stop rather than adapt if any gate differs.

No repository enumeration, filename search, code search, README read, FD02 access, old-repository access, whole-repository status/index operation, pull/reset/clean/stash, or unrelated file inspection.

Recommended branch:

`impl/ip-13i-r17-r2-product-connection-duplicate-resolution-order-invariance-v0-1`

## 3. Accepted implementation contract

R17-R1 accepted exactly:

1. outer Connection/participant semantic checks remain outside duplicate resolution and keep their existing precedence;
2. within one evidence identity and one comparable source-local revision namespace, determine the mathematical maximal revision value;
3. strictly older comparable candidates remain input/history but do not participate in the current equal-revision semantic-conflict decision;
4. maximal candidates with identical existing semantic signatures resolve to the common maximal semantic evidence;
5. maximal candidates with conflicting signatures return the existing equal-revision conflict reason;
6. identity mismatch returns the existing conflicting-identity reason;
7. source-local namespace mismatch returns the existing incomparable reason;
8. no new reason, global revision, LWW, timestamp, arrival-order authority, sorting authority, state mutation, permission or source authority.

Existing state/transition semantic signature definitions remain controlling.

Sorting may be used only as a mechanical technique if output is the same pure multiset function. Stable-sort order, original index, array arrival order and representative position must never affect returned evaluator semantics.

## 4. Exact read set and fixed blobs

Read only:

1. `AGENTS.md`
   - expected blob: `c9a8e192f7647a1613a195655fe9c22c56502ddb`

2. this task

3. accepted R17-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_RESULT_V0_1.md`
   - expected blob: `3918eac68121c6d3a7601ac703e5b1663fe9c054`

4. R17-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
   - expected blob: `cb44607f773705c168f15ca093935be1893259b7`

5. R17 rejection, only for the original counterexample and preserved stop boundary:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
   - expected blob: `415ee64eb70894eed21eee97e58762307d6e408f`

6. accepted R15-R1 result, only duplicate/reason-boundary semantics:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md`
   - expected blob: `fb064b7e290916ba7aa42d53990c9c54d289f5ba`

7. R15-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
   - expected blob: `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`

8. Product Connection evaluator:
   `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
   - expected blob: `35a889ee5460e5c374a5a99bd93bebae49718c5b`

9. Common Authority, comparison contract only:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
   - expected blob: `e98e7db731d41269a7b89e01db12e1a81364751d`

10. existing evaluator Unit test:
    `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`
    - expected blob: `dc408a781d58ddf5c52f6cb0a140e642d3c30775`

No other read is authorized.

## 5. Exact write set

Modify exactly:

1. `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
2. `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`

Create exactly:

3. `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_RESULT_V0_1.md`

No other tracked file may change.

Do not modify Common Authority, persistence, application, routes/controllers, HTTP tests, roadmap/context/AGENTS, Flutter/client source, build/config/dependency files, or downstream domain code.

## 6. Required evaluator repair

Repair only the shared private duplicate-resolution logic required to implement accepted Option A.

The implementation must preserve the existing caller sequence:

- empty-evidence handling remains in state/transition resolver;
- structurally valid cross-Connection checks remain before duplicate resolution;
- participant mismatch checks remain before duplicate resolution;
- duplicate resolution handles evidence identity, source-local namespace, maximal revision and maximal semantic signatures;
- downstream usability/context/terminal/allowed-transition flow remains unchanged.

Required duplicate resolver behavior for a non-empty structurally valid set:

1. if any evidence identity differs from the common identity, return the existing identity-conflict reason;
2. if source revisions are not all in one comparable namespace, return the existing incomparable reason;
3. compute maximal source-local revision value independently of input order;
4. collect all candidates at that maximal value;
5. if their existing semantic signatures are not strictly identical, return the existing equal-revision conflict reason;
6. otherwise return one maximal candidate whose complete semantic signature equals the common signature.

The returned candidate must be semantically independent of representative array position. Do not leak array index/order into any evaluator output.

Do not alter public method signatures, lifecycle vocabulary, state/transition signatures, reason strings, invalidation behavior, Common Authority comparison semantics, or matchResult non-participation.

## 7. Required targeted Unit coverage

Extend the existing evaluator Unit test. Do not create a second evaluator test file.

Add reusable test helpers only within the same test file as needed.

At minimum cover all of the following.

### 7.1 State evidence

1. original R17-F1 multiset:
   - rev N `CN_PENDING`;
   - rev N `CN_ACTIVE`;
   - rev N+1 `CN_ACTIVE`;
   - assert all 6 permutations produce exactly the same complete evaluator result;
   - expected selected revision N+1 and classification `CN_ACTIVE`.

2. same shape with the N+1 state matching the other lower semantic variant; all permutations must converge to that N+1 semantic result.

3. maximal-revision tie with identical signatures; all permutations converge.

4. maximal-revision tie with conflicting signatures; all permutations produce:
   `UNKNOWN / CONFLICTING_EQUAL_REVISION_STATE_EVIDENCE`
   with no current dependency.

5. equal-revision conflict with no higher candidate remains the existing conflict.

6. longer comparable revision chain; all tested permutations/substantial reorderings select the maximal revision.

7. incomparable namespace remains `INCOMPARABLE_DUPLICATE_STATE_EVIDENCE` independent of order.

8. different evidence identity remains `CONFLICTING_STATE_EVIDENCE_IDENTITY` independent of order.

9. newer but unusable evidence still controls current duplicate selection and then fails through the existing usability reason; older usable evidence must not override it.

### 7.2 Transition evidence

10. direct transition analogue of R17-F1; all 6 permutations of the three transition candidates produce the same complete transition result.

11. maximal transition tie differing only in `expected_state_revision` yields existing equal-revision transition conflict independent of order.

12. maximal transition tie differing in from/to semantics yields existing equal-revision transition conflict independent of order.

13. lower dominated transition differences in expected-state revision/from/to do not poison a unique valid higher comparable revision.

14. incomparable transition namespace remains `INCOMPARABLE_DUPLICATE_TRANSITION_EVIDENCE` independent of order.

15. different transition identity remains `CONFLICTING_TRANSITION_IDENTITY` independent of order.

### 7.3 Existing regression

The entire existing `ProductConnectionStateTransitionEvaluatorTest.php` must still pass, including:

- exact lifecycle vocabulary;
- connection shape checks;
- all allowed transitions;
- direct none-to-active rejection;
- terminal reopen rejection;
- current/transition source usability;
- current-context mismatch;
- invalidation behavior;
- existing higher-revision order test;
- existing equal-revision and incomparable duplicate tests;
- non-authority assertions.

Do not weaken/delete an existing assertion to make the new implementation pass unless the accepted R17-R1 policy directly contradicts it. No such known contradiction is authorized by this task.

## 8. Exact test command and attempt budget

Allowed runtime command, from `services/backend-laravel`, exactly:

`vendor/bin/phpunit tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`

Attempt budget:

- initial run: at most 1;
- after an authorized code/test correction caused by a failing targeted test: at most 2 additional reruns;
- total maximum: 3 PHPUnit command executions.

Do not run any other test command.

Do not run Composer, Artisan, PHP scripts, server/HTTP, database, migrations, generators, code formatters, static-analysis suites, coverage, dependency installation/update, network operations, Flutter/Dart/Gradle/Android or production commands.

If `vendor/bin/phpunit`, required dependencies, or test environment is unavailable, stop with the exact tooling evidence. Do not install/fetch/repair the environment.

A passing first run ends the runtime budget; do not rerun merely for confidence.

## 9. Failure and repair boundaries

Within the same candidate, if the targeted PHPUnit run exposes a defect caused by the authorized evaluator/test change, repair only the two authorized source/test paths and rerun within budget.

Stop rather than adapt if failure requires:

- changing Common Authority;
- new/changed reason vocabulary;
- persistence/application changes;
- a public evaluator API change;
- dependency/toolchain installation or configuration;
- reading or modifying any unlisted file;
- changing accepted Product Connection semantics beyond Option A.

Do not hide an infrastructure failure as a product failure.

## 10. Result document requirements

The result document must record:

- fresh execution authority;
- branch/candidate/sole parent/tree after publication;
- exact three-path tracked scope;
- before/after evaluator and test blobs;
- accepted R17-R1 result/acceptance blobs;
- exact implementation algorithm;
- explicit confirmation outer cross-Connection/participant precedence remains unchanged;
- state/transition permutation cases implemented;
- exact PHPUnit command;
- exact number of attempts used;
- tests/assertions/failures/errors/skips if reported;
- any local/runtime limitation actually observed;
- confirmation no other runtime/tool action occurred;
- confirmation R17 remains rejected and no mapping review/R18 was authored;
- fresh independent ACCEPT/REJECT requirement.

Expected successful classification:

`IP-13I-R17-R2 IMPLEMENTATION COMPLETE — OPTION-A MAXIMAL-REVISION DUPLICATE RESOLUTION IMPLEMENTED — STATE + TRANSITION PERMUTATION REGRESSION COVERAGE ESTABLISHED — EXISTING EVALUATOR CONTRACT REGRESSION PASSES — NO NEW REASON / GLOBAL REVISION / ARRIVAL-ORDER AUTHORITY — READY FOR FRESH INDEPENDENT REVIEW BEFORE MAPPING RE-REVIEW`

Then STOP.

## 11. Publication and review topology

Candidate must be one commit with sole parent equal to the task-publication authority from the execution prompt.

Committed diff must contain exactly the two modified code/test paths and one new result document.

Candidate author may self-check but may not self-accept, merge, move main, author the fresh mapping review, author R18, or start persistence/application/HTTP/Messaging work.

Fresh independent reviewer must compare the immutable candidate to the frozen task authority, inspect the exact code/test diff and test receipt, and ACCEPT or REJECT before any mapping re-review is authored.
