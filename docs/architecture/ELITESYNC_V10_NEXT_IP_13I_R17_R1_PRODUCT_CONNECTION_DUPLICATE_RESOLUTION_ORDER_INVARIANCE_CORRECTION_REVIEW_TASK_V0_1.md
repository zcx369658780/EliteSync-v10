# EliteSync v10｜Next IP-13I-R17-R1 Product Connection Duplicate-Resolution Order-Invariance Correction Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY DOMAIN-POLICY CORRECTION REVIEW — EXACTLY ONE RESULT DOCUMENT — NO CODE / NO TEST / NO HTTP — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Task-publication base before this task commit:

`fb919b821514bf4c8137922b8404baace2760414`

This task implements the accepted current roadmap transition from M0 to M1. It does not revive rejected R17, does not authorize R18, and does not authorize Product Connection implementation.

## 1. Owner authorization and objective

Owner requested continuation after independent acceptance of the planning package.

The immediate blocking evidence is R17-F1: the accepted Product Connection evaluator's duplicate resolver can produce different domain classifications and protected-use validity for permutations of the same structurally valid evidence multiset when a dominated equal-revision semantic conflict coexists with a higher comparable revision.

The objective is to make one explicit, bounded domain-policy decision for duplicate-resolution precedence so that a later implementation task can make the evaluator order-invariant without inventing source authority, global revision, LWW, timestamp authority, new structural diagnostics, or application-layer evidence filtering.

This task is REVIEW/DESIGN ONLY.

## 2. Fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first from the task-publication authority.
2. Fresh-fetch `origin/main`.
3. Resolve the exact commit containing this task from the execution prompt.
4. Require `origin/main` to equal that exact task-publication commit.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed object in Section 4.
8. Stop rather than adapt if any required authority/path/blob differs.

No repository enumeration, filename search, code search, README read, FD02 access, or old-repository access.

Recommended branch:

`review/next-ip-13i-r17-r1-product-connection-duplicate-resolution-order-invariance-correction-v0-1`

## 3. Controlling accepted boundaries

Preserve all of the following unless direct contradiction is proven:

- `NEXT_DOMAIN = PRODUCT_CONNECTION`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- family `PRODUCT_CONNECTION_STATE_TRANSITION_DERIVED_PROJECTION`;
- facts `PRODUCT_CONNECTION_CURRENT_STATE_DERIVATION` and `PRODUCT_CONNECTION_TRANSITION_DERIVATION`;
- Binding Model A derivation-owned deterministic non-authoritative correlation bindings;
- exact six pre-materialization-only structural diagnostics;
- exact eight persisted current-state reasons;
- exact nineteen persisted transition reasons;
- `protected_binding_satisfied` as non-authoritative typed-dependency metadata;
- R16-R1 dependency-presence/context/revision matrices;
- current-state-based terminality and invalidation context retention;
- `GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- no global revision, LWW, arrival-order, timestamp, authentication/session/token or production authority.

R17 remains rejected. Sound fragments recorded by its rejection may be used only as review evidence; rejected R17 is not an accepted mapping contract.

## 4. Exact authorized read set and fixed objects

Read only the following.

1. `AGENTS.md`
   - expected blob: `c9a8e192f7647a1613a195655fe9c22c56502ddb`

2. this task document

3. current planning entry:
   `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`
   - expected blob: `d75de90b3c0dafe6c5241f135936d0ae653c7e30`

4. current roadmap:
   `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`
   - expected blob: `6f49159f1cce7a28362284191c05adbc08e768aa`
   - use only M1 / validation / task-granularity guidance relevant to this review

5. current evidence index:
   `docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md`
   - expected blob: `5b26a4e396dd8f64c18e25b16ef577df124a6725`
   - use only Product Connection source-closure entries

6. R17 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R17_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`
   - expected blob: `415ee64eb70894eed21eee97e58762307d6e408f`

7. accepted R15-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_RESULT_V0_1.md`
   - expected blob: `fb064b7e290916ba7aa42d53990c9c54d289f5ba`

8. R15-R1 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R15_R1_PRODUCT_CONNECTION_REASON_BOUNDARY_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
   - expected blob: `7424e368a31edcd3e8ccc7d37133d6f4b321ebc3`

9. accepted R16-R1 result:
   `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`
   - expected blob: `f0da912cb3dcb1525fa36053168310f187cf58cb`

10. R16-R1 acceptance:
    `docs/architecture/ELITESYNC_V10_IP_13I_R16_R1_PRODUCT_CONNECTION_DEPENDENCY_PRESENCE_CROSS_FIELD_VALIDATION_CONTRACT_CORRECTION_REVIEW_ACCEPTANCE_V0_1.md`
    - expected blob: `96110d9484897012c7946b42a2256951ec8a60fc`

11. retained original R16 result only at exact rejected ref:
    ref `5494bf6835134ef1af69d5ebe32aa28ef62fc92e`
    path `docs/architecture/ELITESYNC_V10_IP_13I_R16_PRODUCT_CONNECTION_RECORD_PROJECTION_CONTRACT_REVIEW_RESULT_V0_1.md`
    - expected blob: `aee15cf45c75c5a8f1733f5604803fc3ee766b4b`
    - only the sections retained by R16-R1 may be consumed

12. Product Connection evaluator:
    `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
    - expected blob: `35a889ee5460e5c374a5a99bd93bebae49718c5b`

13. Common Authority:
    `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`
    - expected blob: `e98e7db731d41269a7b89e01db12e1a81364751d`

14. old R17 task at exact frozen ref:
    ref `b0196202c78f688723600ac9919cf96463908375`
    path `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_TASK_V0_1.md`
    - expected blob: `68d18d4100ba24b493fd2b5ee9388f564aca9100`
    - use only its source-order-independence / selected-evidence requirements as historical task evidence

15. rejected R17 result only at exact candidate:
    ref `6af50b3cdf82ac8bc285bd160f773b48b29f1328`
    path `docs/architecture/ELITESYNC_V10_IP_13I_R17_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REVIEW_RESULT_V0_1.md`
    - expected blob: `14d92368dbb6a3e7ab2ed6c0cbcf4b149f831ac8`
    - use only the rejected order-independence claim and otherwise sound fragments identified by the independent rejection

No other source read is authorized.

## 5. Exact tracked write set

Create exactly one file:

`docs/architecture/ELITESYNC_V10_IP_13I_R17_R1_PRODUCT_CONNECTION_DUPLICATE_RESOLUTION_ORDER_INVARIANCE_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing file may change.

No evaluator, tests, persistence, application, route, controller, HTTP, roadmap, context, AGENTS, project-source or downstream document may change.

## 6. Required decision

Choose exactly one top-level decision.

### Option A — MAXIMAL-REVISION-SCOPE CONFLICT POLICY

`MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`

Within one evidence identity and one comparable source-local revision namespace:

1. establish the maximal revision value without using input order;
2. discard no evidence from the input, but treat strictly older comparable revisions as dominated for current duplicate semantic-conflict classification;
3. if all maximal-revision candidates have identical semantic signatures, select that maximal semantic evidence;
4. if maximal-revision candidates conflict semantically, return the existing equal-revision conflict reason;
5. any incomparable namespace remains the existing incomparable reason;
6. distinct evidence identities remain the existing conflicting-identity reason.

This option does not make the revision globally authoritative. It uses only the already accepted source-local comparable revision relation.

### Option B — ANY-HISTORICAL-EQUAL-CONFLICT POISONS THE SET

`ANY_COMPARABLE_EQUAL_REVISION_SEMANTIC_CONFLICT_POISONS_THE_EVIDENCE_SET`

Within one evidence identity, if any two structurally valid candidates in a comparable source-local namespace share an equal revision but conflict semantically, the whole resolution is the existing equal-revision conflict result even when a higher comparable revision also exists.

This policy must still be permutation-invariant and must not let traversal order decide which conflict is noticed.

### Option C — ADDITIONAL DOMAIN DECISION REQUIRED

`ORDER_INVARIANT_DUPLICATE_PRECEDENCE_REMAINS_BLOCKED`

Choose this only if neither A nor B can be reconciled with accepted Product Connection/Common Authority semantics without creating a new product/authority rule not supported by the fixed sources.

Do not invent Option D merely to avoid making the review decision. If another materially distinct policy is necessary, classify as Option C and describe the missing Owner/domain decision.

## 7. Required reasoning and proof obligations

For the selected policy, define exact order-independent behavior for both state evidence and transition evidence.

At minimum cover these multisets under every permutation:

1. one candidate;
2. exact semantic duplicate at equal revision;
3. two equal-revision candidates with conflicting semantics and no higher candidate;
4. R17-F1 shape: two conflicting candidates at revision N plus one semantically usable candidate at N+1;
5. same as #4 where the N+1 candidate matches each lower semantic variant in turn;
6. two or more candidates tied at the maximal revision with identical signatures;
7. two or more candidates tied at maximal revision with conflicting signatures;
8. comparable older/newer chains longer than three elements;
9. incomparable source-local namespace candidates;
10. distinct evidence identities;
11. transition evidence where only `expected_state_revision` differs;
12. transition evidence where from/to or required/source binding semantics differ.

The result must state whether the current reason vocabulary remains sufficient. Prefer no new reason. If a new reason appears unavoidable, Option A/B cannot be selected without a separate reason-contract correction.

## 8. Algorithm contract

If Option A or B is selected, define a deterministic algorithm contract suitable for later implementation.

The algorithm contract must:

- be a pure function of the evidence multiset and accepted source-local revision comparison;
- be invariant under every input permutation;
- never use array index, arrival order, timestamp, storage order, random value, global revision or LWW;
- not pre-filter structurally valid cross-Connection, participant mismatch, identity conflict or incomparable evidence into input errors;
- preserve the six structural diagnostics boundary;
- preserve state and transition semantic signatures unless the review proves a narrow accepted correction is required;
- produce at most one selected evidence or one existing bounded reason;
- work identically for state and transition duplicate-resolution structure, except their existing signatures/reason literals;
- not require application-layer sorting/filtering to compensate for an order-sensitive evaluator.

Sorting may be used as an implementation technique only if the outcome is defined independently of sort stability/order and the semantic policy is already fixed here. Sorting itself is not authority.

## 9. Interaction with Common Authority

Explicitly decide and document:

- whether source-local revision comparability supplies only an ordering relation or also conflict-precedence semantics;
- why the chosen policy does not create a global revision;
- how owner/scope/lineage/aggregate-context mismatch remains `INCOMPARABLE`;
- why a higher comparable revision does or does not dominate a lower equal-revision semantic conflict;
- why the decision does not make old evidence disappear, mutate source evidence, or establish Connection source authority.

Do not change Common Authority source-revision tuple or comparison semantics in this review.

## 10. Accepted reason and persistence consequences

For every affected current-state/transition outcome, state the expected existing reason/classification and whether a dependency is retained.

The review must prove compatibility with:

- R15-R1 six structural diagnostics vs persisted semantic conflicts;
- R16-R1 known/UNKNOWN/ADMISSIBLE/REJECTED dependency-presence matrices;
- exact source-revision tuple binding;
- currentness/freshness aggregation;
- invalidation retention;
- terminal/no-reopen behavior.

Do not rewrite R16-R1 persistence rules merely to accommodate a resolver implementation.

## 11. R17 disposition after this review

This correction review does not accept the old R17 candidate.

If Option A or B is supported, classify old R17 as still rejected and state:

`ORDER-INVARIANCE POLICY FIXED — EVALUATOR REPAIR REQUIRED BEFORE MAPPING RE-REVIEW`

The next bounded task must be an evaluator implementation-and-targeted-test task. Only after that implementation is independently accepted may a fresh Product Connection domain-to-application mapping review be authored.

If Option C is selected, no implementation task may be authored; return to Owner/domain decision.

Do not author R18 in this branch.

## 12. Successor shape if A/B succeeds

Name the exact next task family only, without creating it:

`IP-13I-R17-R2 PRODUCT CONNECTION DUPLICATE-RESOLUTION ORDER-INVARIANCE EVALUATOR REPAIR + TARGETED TEST TASK`

The future task must:

- modify only the exact evaluator and explicitly named existing/new targeted tests;
- include the permutation matrix from this review;
- include both state and transition coverage;
- preserve all six structural diagnostics and 8/19 persisted reasons;
- run only the exact test commands and attempt budget authorized by that future task;
- not modify persistence/application/HTTP.

After independent acceptance of R17-R2 implementation, a fresh mapping review may be authored. The future mapping review must consume the complete R16 retained/corrected source closure and the repaired evaluator blob.

## 13. Runtime/tool prohibition

Runtime commands: NONE.

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- PHP execution;
- server/HTTP;
- database;
- Flutter/Dart/Gradle/Java/Android;
- dependency resolution/download;
- migrations/generators;
- provider/network product operations;
- production or real/private-data operations.

Static source reading is sufficient for this task.

## 14. Result requirements

The single result document must record:

- task-publication authority and candidate topology;
- every fixed source blob;
- Option A/B/C decision;
- exact order-independent state duplicate policy;
- exact order-independent transition duplicate policy;
- permutation proof table for Section 7;
- algorithm contract;
- Common Authority interpretation;
- reason-vocabulary disposition;
- R15-R1/R16-R1 compatibility;
- whether evaluator implementation repair is required;
- exact successor family if applicable;
- preserved non-authorities and downstream block;
- confirmation that no runtime/code action occurred;
- fresh independent ACCEPT/REJECT requirement.

Expected success classification for A/B:

`IP-13I-R17-R1 REVIEW COMPLETE — PRODUCT CONNECTION DUPLICATE-RESOLUTION ORDER-INVARIANCE POLICY FIXED — STATE + TRANSITION PERMUTATION SEMANTICS CLOSED — EXISTING STRUCTURAL/8-19 REASON BOUNDARIES PRESERVED — EVALUATOR REPAIR REQUIRED BEFORE FRESH MAPPING REVIEW — NO PERSISTENCE / APPLICATION / HTTP AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
