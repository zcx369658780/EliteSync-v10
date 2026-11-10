# EliteSync v10｜Next IP-13I-R17-R3 Product Connection Domain-to-Application Mapping Re-Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY FRESH MAPPING RE-REVIEW — SELF-CONTAINED IMPLEMENTATION-CONSUMABLE CONTRACT REQUIRED — NO CODE / NO HTTP — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Task-publication base before this task commit:

`37e7648b50a1ad7eb47097c636e15966cb20cdd4`

This task follows accepted R17-R1 policy and accepted R17-R2 evaluator repair. Old R17 remains rejected and may be used only as explicitly bounded review evidence.

## 1. Objective

Perform a fresh Product Connection domain-to-persistence-to-application mapping review against the repaired order-invariant evaluator.

The result must be self-contained enough for later implementation tasks: do not require a future implementer to reconstruct accepted payload keys, typed dependencies, mapping flow, readback, materialization and usability rules from a chain of rejected/corrected documents.

The review must also decide the most efficient safe implementation packaging:

- whether persistence-first can be preserved inside one sequential combined implementation task; or
- whether persistence and application must remain two separately accepted tasks.

This task does not implement either option.

## 2. Fresh-base gate

Before substantive review:

1. Read `AGENTS.md` FIRST from the task-publication authority.
2. Fresh-fetch `origin/main`.
3. Resolve the exact commit containing this task from the execution prompt.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed source blob and exact retained ref.
8. Stop rather than adapt if any authority/path/blob differs.

No repository enumeration, filename search, recursive discovery, README read, FD02 access, old repository access, project runtime, database or private-data operation.

Recommended branch:

`review/next-ip-13i-r17-r3-product-connection-domain-to-application-mapping-rereview-v0-1`

## 3. Controlling accepted contract

Preserve:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- typed facts:
  - `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION`
  - `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A derivation-owned deterministic non-authoritative correlation bindings;
- exact six structural diagnostics;
- exact eight current-state persisted reasons;
- exact nineteen transition persisted reasons;
- both typed dependencies include `protected_binding_satisfied`;
- fully usable iff:
  - `protected_binding_satisfied === true`
  - `source_condition === PRESENT`
  - `currentness === true`
  - `freshness === true`;
- R16-R1 dependency-presence/cross-field/exact-revision matrices;
- current-state-based terminality;
- dependency invalidation preserves pre-invalidation state/dependency/context/aggregate;
- generic projection invalidation remains separate;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- no global revision, LWW, timestamp, arrival-order, auth/session/token or production authority.

Also preserve accepted R17-R1/R17-R2 Option A:

`MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`

The repaired evaluator blob is controlling for this review.

## 4. Exact authorized read set and fixed objects

Read only:

1. `AGENTS.md`
   - blob `c9a8e192f7647a1613a195655fe9c22c56502ddb`

2. this task

3. accepted R17-R2 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_RESULT_V0_1.md`
   - blob `47caffe068ea377ee3f7c5a94bace3f2bb2141aa`

4. accepted R17-R2 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R2_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_EVALUATOR_REPAIR_ACCEPTANCE_V0_1.md`
   - blob `acfedada11c3c6e76b83f9674142168245db9c0f`

5. accepted R17-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_RESULT_V0_1.md`
   - blob `3918eac68121c6d3a7601ac703e5b1663fe9c054`

6. accepted R17-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
   - blob `cb44607f773705c168f15ca093935be1893259b7`

7. R17 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
   - blob `415ee64eb70894eed21eee97e58762307d6e408f`
   - use for F1/F2 and the independently identified sound fragments only

8. old rejected R17 result at exact candidate ref only:
   ref `6af50b3cdf82ac8bc285bd160f773b48b29f1328`
   path `docs/architecture/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`
   - blob `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`
   - use only as rejected mapping evidence; no section becomes accepted merely by reuse

9. accepted R15-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md`
   - blob `fb064b7e290916ba7aa42d53990c9c54d289f5ba`

10. R15-R1 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
    - blob `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`

11. accepted R16-R1 result:
    `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`
    - blob `f0da912cb3dcb1525fa36053168310f187cf58cb`

12. R16-R1 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
    - blob `96110d9484897012c7946b42a2256951ec8a60fc`

13. retained original R16 result only at exact rejected ref:
    ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`
    path `docs/architecture/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md`
    - blob `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`
    - only definitions explicitly retained by R16-R1 may be used

14. repaired Product Connection evaluator:
    `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
    - blob `a2a2fefe2178834aa5051200cf2d1ecc3d4ea885`

15. Common Authority:
    `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
    - blob `e98e7db731d41269a7b89e01db12e1a81364751d`

16. current IP-13A:
    `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`
    - blob `65d4a6c1bc3c535d56e4d4b50110eef6efc7b45f`

17. current IP-13D:
    `services/backend-laravel/app/Domain/SqliteInMemoryLogicalPersistenceAdapter.php`
    - blob `640fb4a6cd0269d8eb55f218a2fc8ce823014f7c`

18. current IP-13E:
    `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`
    - blob `aa9721dfa66fe17eb2314bc9466870d479c07644`

19. accepted Canonical Match application adapter, orchestration contrast only:
    `services/backend-laravel/app/Domain/CanonicalMatchPersistenceApplicationAdapter.php`
    - blob `789e8905b2c9ee54d902d8b600100896af4f6063`

20. accepted Canonical Match adapter Unit test, test-boundary contrast only:
    `services/backend-laravel/tests/Unit/CanonicalMatchPersistenceApplicationAdapterTest.php`
    - blob `c8298f5e786a47d118b56f47cef6baab7f543b60`

No other read is authorized.

## 5. Exact tracked write set

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_RESULT_V0_1.md`

No existing file may change.

No code/test/persistence/application/route/controller/HTTP/client/config changes.

## 6. Required top-level mapping decision

Choose exactly one:

### Option A

`DEDICATED_PRODUCT_CONNECTION_PERSISTENCE_APPLICATION_ADAPTER_MAPPING_SOUND_AFTER_ORDER_INVARIANCE_REPAIR`

Choose only if the repaired evaluator plus accepted R15-R1/R16-R1 contract supports a truthful complete mapping.

### Option B

`ADDITIONAL_PRODUCT_CONNECTION_MAPPING_OR_RECORD_REPAIR_REQUIRED`

Use only if a concrete remaining semantic contradiction exists.

### Option C

`IP13E_CONTRACT_REPAIR_REQUIRED`

Use only if exact submit/retrieve/readback cannot be supported by existing IP-13E semantics.

### Option D

`BLOCKED`

Use only for insufficient/contradictory fixed evidence.

Old R17 Option A does not pre-decide this re-review.

## 7. Self-contained exact input and operation contract

If mapping is sound, restate exact synthetic/dev-test application input containers sufficient for implementation without forcing the implementer to reopen the rejected R17 result.

At minimum define:

- operation envelope marker and exact keys;
- Connection descriptor exact keys;
- current-state evidence exact keys;
- transition evidence exact keys;
- Common Authority required/source binding exact keys;
- source evidence exact keys;
- exact five-field source revision;
- strict structural gate and exact six diagnostics.

Choose and fully specify the public adapter operation topology.

Expected bounded direction may remain four explicit operations:

- current-state evaluate;
- transition evaluate;
- current-state dependency invalidate;
- transition dependency invalidate.

If another topology is selected, justify why it is safer and not unnecessarily generic.

No caller may supply prior evaluator result, persisted payload/projection, Match result or authoritative Connection state outside accepted evidence.

## 8. Repaired evaluator call contract

For each operation define exact call count:

- current evaluation: `evaluateCurrent()` exactly once;
- transition evaluation: `evaluateTransition()` exactly once and no extra external `evaluateCurrent()`;
- current invalidation: fresh `evaluateCurrent()` once + `invalidate()` once;
- transition invalidation: fresh `evaluateTransition()` once + `invalidate()` once.

No retries.

Explicitly state that duplicate resolution is now source-order invariant at the evaluator itself. Application recovery must not sort/filter evidence to change evaluator semantics.

## 9. Selected-evidence recovery after repaired evaluator

Define the exact recovery procedure from original supplied evidence when evaluator retains a dependency.

Current dependency matching must include:

- state evidence identity;
- Connection identity;
- state;
- exact five-field source revision;
- source condition.

Transition dependency matching must include:

- transition identity;
- Connection identity;
- from state;
- to state;
- exact own five-field source revision;
- source condition.

Because the evaluator dependency vector still omits some original metadata, recovered matching candidates must additionally agree on all recoverable fields needed for persistence, including:

- `protected_binding_satisfied`;
- currentness;
- freshness;
- for transition, exact `expected_state_revision`.

If exact public-vector matches disagree on those values, fail closed before record construction.

Explain why this is now recovery only, not a workaround for evaluator selection.

## 10. Exact protected-binding computation

Restate the exact builder algorithm.

For both dependency types:

- exact required/source Common Authority binding equality;
- required subject = Connection identity;
- required aggregate context = Connection identity;
- required lifecycle identity = Connection identity;
- required participant set = Connection participants;
- required purpose = protected-use scope.

For current-state evidence additionally:

- required terminal = terminality of evidence state.

Exclude source condition/currentness/freshness from the boolean.

The boolean is not source authority, permission, auth or bearer capability.

## 11. Exact typed dependency and payload contract

The result must include complete ordered key sets, not only references.

Restate the exact current dependency keys and transition dependency keys including `protected_binding_satisfied`.

Restate complete current-state payload and transition payload ordered key sets and exact classification/reason/invalidation/terminal semantics.

Restate:

- known current-state dependency requirements;
- current-state UNKNOWN with/without dependency;
- propagated current-state UNKNOWN in transition;
- transition resolution failure UNKNOWN;
- `TRANSITION_NOT_CURRENT_FRESH_BOUND`;
- `TRANSITION_CURRENT_CONTEXT_MISMATCH`;
- `ADMISSIBLE`;
- each policy `REJECTED`;
- dependency invalidation.

Do not change R16-R1 matrices.

## 12. Record construction and deterministic identities

Restate Binding Model A constants and exact deterministic identity inputs.

Must include:

- family;
- derived authority owner;
- fact-specific scopes;
- fixed actor/role/audience;
- subject;
- canonical participants;
- purpose;
- aggregate context;
- stable lifecycle identity;
- current-state-based terminal marker;
- source condition;
- derived correlation revision 0;
- authoritative outcome UNKNOWN;
- null authoritative/correction metadata;
- ambiguous transport observation;
- empty private fixture extensions;
- schema markers;
- record/intent/lineage/projection identities.

No random/time/request-order/runtime-account inputs.

## 13. IP-13E submit/retrieve and exact readback

Independently confirm or reject:

`IP13E_EXISTING_OPERATIONS_SUFFICIENT`

If sufficient, define:

1. construct exact record;
2. `submitAuthoritativeMutation()` exactly once;
3. inspect storage disposition;
4. retrieve only for exact justified dispositions;
5. exact-lineage query;
6. exact request bindings from derived record;
7. no retry.

Independently decide retrievable storage dispositions from current semantics.

Exact readback must require, at minimum:

- application resolution RESOLVED;
- binding classification EXACT;
- exact family/derived owner/fact-specific scope;
- generic projection not invalidated;
- exact record/intent/lifecycle/lineage/projection identities;
- represented derived revision 0;
- exact terminal/currentness/freshness/lag fields;
- direct typed payload equality, not digest alone.

## 14. Materialization and usability

Define bounded application-internal materialization conditions.

Preserve:

`EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`

Current-state projection usable only if:

- exact readback;
- not dependency-invalidated;
- known current-state classification;
- valid-for-protected-use true.

Transition projection usable only if:

- exact readback;
- not dependency-invalidated;
- classification ADMISSIBLE;
- valid-for-protected-use true.

Current UNKNOWN, transition UNKNOWN and transition REJECTED remain unusable even if stored/read exactly.

Generic projection invalidation also makes readback unusable without mutating Product Connection dependency invalidation.

## 15. Duplicate/incomparable/terminal behavior with repaired evaluator

Restate exact behavior for:

- exact duplicate requests;
- higher comparable selected evidence;
- lower historical equal-revision conflicts dominated by a higher maximal revision;
- conflicting maximal equal-revision evidence;
- incomparable namespace;
- changed semantic input;
- shared lifecycle across two fact classes;
- terminal current state followed by non-terminal current state;
- terminal current state followed by transition fact;
- proposed terminal transition from non-terminal current state;
- repeated dependency invalidation.

No arrival-order authority.

## 16. Adapter internal result contract and privacy

Define complete adapter result key set suitable for implementation.

The result must distinguish:

- operation/fact class;
- evaluator classification/reasons;
- exact typed payload;
- record/intent/lifecycle/lineage correlation;
- storage/readback/binding outcomes;
- materialized projection usability;
- authoritative outcome/reconciliation/invalidation/revalidation;
- bounded condition;
- synthetic/dev-test marker;
- source-local-revision-only marker;
- false non-authority fields.

Exclude raw source evidence, raw required bindings, unselected duplicates, Match result, credentials/session/token, private messages/provider payloads/ranking/desirability/person-worth material.

No HTTP contract.

## 17. Persistence/application implementation packaging decision

Choose exactly one:

### Package A

`PERSISTENCE_FIRST_WITHIN_SINGLE_SEQUENTIAL_COMBINED_IMPLEMENTATION_TASK`

This means one later implementation task may contain two hard phases in one candidate:

Phase A:
- implement Product Connection family/validator/payload retention in IP-13A/IP-13D;
- run exact Product Connection persistence tests and required existing-family regressions;
- only if Phase A passes may Phase B begin.

Phase B:
- implement dedicated Product Connection application adapter;
- run exact adapter tests plus required shared persistence/application regressions;
- produce one combined result;
- publish one candidate containing both phases;
- independent review happens once on the complete candidate.

Select Package A only if no unaccepted architecture decision lies between the phases and application implementation can safely consume the just-implemented persistence family inside the same candidate while preserving persistence-first execution order.

### Package B

`PERSISTENCE_IMPLEMENTATION_REQUIRES_SEPARATE_ACCEPTANCE_BEFORE_APPLICATION_TASK`

Select if application work must not proceed before independent acceptance of persistence code.

### Package C

`ADDITIONAL_IMPLEMENTATION_PACKAGING_REVIEW_REQUIRED`

Use only for a concrete unresolved dependency.

This packaging decision concerns task granularity only; it does not weaken tests, source scope or independent review.

## 18. Future implementation validation contract

If Package A or B is selected, define exact future test classes/scope categories required, including:

Persistence:
- Product Connection family validator;
- both payload fact classes;
- exact 8/19 reason matrices;
- typed dependency validation;
- exact expected revision/context;
- deterministic identities;
- exact payload retention;
- generic overlay exemption;
- exact duplicate;
- incomparable;
- terminal no-reopen;
- existing RR03/Canonical Match regression where shared code is changed;
- IP-13A/IP-13D parity.

Application:
- all four operations or chosen topology;
- exact evaluator call counts;
- selected evidence recovery;
- protected binding computation;
- one submit;
- conditional retrieve;
- exact readback equality;
- invalidation flows;
- UNKNOWN/REJECTED unusability;
- generic invalidation unusability;
- duplicate/incomparable/terminal behavior;
- no raw evidence leak;
- fixed false non-authority fields.

Do not invent exact commands if the current fixed read set does not include the future test files; define test-scope requirements and let the implementation task bind exact paths/commands.

## 19. IP-13F and downstream

Must remain:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

unless a direct contradiction in fixed sources is demonstrated.

No sixth IP-13F family.
No Product Connection HTTP endpoint in this review.
No Messaging/Conversation task is authorized.

Messaging remains blocked until the required Product Connection persistence/application boundary is independently accepted.

## 20. Exact successor family

If mapping is sound, name one successor family only.

If Package A:

`IP-13I-R18 PRODUCT CONNECTION PERSISTENCE-FIRST COMBINED PERSISTENCE + APPLICATION IMPLEMENTATION TASK`

If Package B:

`IP-13I-R18 PRODUCT CONNECTION PERSISTENCE FAMILY REFERENCE/SQLITE IMPLEMENTATION TASK`

Do not create R18 in this branch.

## 21. Runtime prohibition

Runtime commands: NONE.

Do not run Composer, PHPUnit, PHP, Artisan, server/HTTP, database, migrations, generators, Flutter/Dart/Gradle/Android, dependency resolution/download, network product calls, production or real/private-data operations.

## 22. Result requirements

The single result document must record:

- task authority/candidate topology;
- all fixed blobs/refs;
- Option A/B/C/D mapping decision;
- repaired-evaluator impact;
- exact input/operation contract;
- exact call counts;
- selected-evidence recovery;
- protected-binding algorithm;
- complete typed dependency and payload key sets;
- full cross-field/invalidation matrix summary;
- Binding Model A and deterministic identities;
- IP-13E sufficiency and submit/retrieve/readback;
- materialization/usability;
- duplicate/incomparable/terminal behavior;
- complete adapter result key set/privacy exclusions;
- Package A/B/C implementation packaging decision;
- future validation scope;
- IP-13F/downstream disposition;
- exact successor family;
- confirmation no runtime/code action occurred;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape:

`IP-13I-R17-R3 REVIEW COMPLETE — REPAIRED ORDER-INVARIANT EVALUATOR SUPPORTS DEDICATED PRODUCT CONNECTION PERSISTENCE/APPLICATION MAPPING — SELF-CONTAINED IMPLEMENTATION CONTRACT FIXED — EXACT RECOVERY/BINDING/PAYLOAD/RECORD/SUBMIT/READBACK/USABILITY RULES FIXED — IMPLEMENTATION PACKAGING DECIDED — IP-13F UNCHANGED/NON-PARTICIPATING — NO HTTP OR DOWNSTREAM AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
