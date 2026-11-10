# EliteSync v10｜IP-13I-R17-R1 Product Connection Duplicate-Resolution Order-Invariance Correction Review Acceptance｜v0.1

Status: `ACCEPTED — OPTION A MAXIMAL COMPARABLE REVISION SCOPE FIXED — EVALUATOR REPAIR GATE OPEN — OLD R17 REMAINS REJECTED`

Date: 2026-09-21 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Independent acceptance

Fresh independent review ACCEPTS immutable candidate:

`0b6aa452254bb7662b7a233c0f6a40d94a6e03f0`

with:

- task-publication authority: `2e85797c0d2add024a21ab524ff502421e45bc27`;
- sole parent: `2e85797c0d2add024a21ab524ff502421e45bc27`;
- candidate tree: `4ad9f9e55574c3ba7b1c752b58849ab2de6fd705`;
- result blob: `3918eac68121c6d3a7601ac703e5b1663fe9c054`;
- comparison to authority: ahead 1 / behind 0;
- exact committed scope: one added result document only;
- remote review branch tip verified at the immutable candidate.

The candidate author did not self-accept.

## 2. Accepted policy

Accepted decision:

`MAXIMAL_COMPARABLE_REVISION_SCOPE_IS_AUTHORITATIVE_FOR_DUPLICATE_CONFLICT_EVALUATION`

Within one evidence identity and one comparable source-local revision namespace:

1. current duplicate resolution is determined by the mathematical maximal source-local revision value;
2. strictly older comparable revisions remain historical evidence but do not decide the current equal-revision semantic-conflict outcome;
3. equal maximal revisions with identical semantic signatures resolve to the common maximal semantic evidence;
4. equal maximal revisions with conflicting signatures use the existing equal-revision conflict reason;
5. namespace mismatch remains the existing incomparable reason;
6. identity mismatch remains the existing conflicting-identity reason.

This is a Product Connection duplicate-resolution policy. It does not change the Common Authority revision tuple or create global revision, LWW, arrival-order, timestamp, permission, authentication, state-mutation, production, or source-authority semantics.

## 3. Independent source check

The accepted R15-R1 contract explicitly states that a comparable higher source-local revision selects the newer candidate and that equal-revision semantic conflict remains a bounded conflict. The current evaluator source instead begins duplicate resolution from the first array element and can return before observing a later higher revision. Option A closes that exact mismatch without changing the existing reason vocabulary.

Current evaluator prechecks for cross-Connection evidence and participant mismatch remain before duplicate resolution and remain persisted domain semantics. The accepted correction does not convert them to structural input errors or reorder those outer checks.

## 4. Preserved contracts

Preserve unchanged:

- six pre-materialization structural diagnostics;
- eight current-state persisted reasons;
- nineteen transition persisted reasons;
- R16-R1 dependency-presence, exact revision/context, currentness/freshness, invalidation and terminal matrices;
- Binding Model A;
- `GENERIC_PROJECTION_INVALIDATION != PRODUCT_CONNECTION_DEPENDENCY_INVALIDATION`;
- `EXACT_MATERIALIZATION != PROTECTED_USE_VALIDITY`;
- `TRANSITION_ADMISSIBLE != AUTHORITATIVE_STATE_CHANGE`;
- `MATCH_RESULT_UNUSED_AND_NON_PARTICIPATING`;
- `Match != Connection != Conversation != Relationship`.

No new reason literal is accepted.

## 5. R17 disposition and next gate

Old R17 candidate remains REJECTED.

Accepted current disposition:

`ORDER-INVARIANCE POLICY FIXED — EVALUATOR REPAIR REQUIRED BEFORE MAPPING RE-REVIEW`

The next bounded task family is:

`IP-13I-R17-R2 PRODUCT CONNECTION DUPLICATE-RESOLUTION ORDER-INVARIANCE EVALUATOR REPAIR + TARGETED TEST TASK`

That task may implement the accepted Option A algorithm in the evaluator and add/modify only explicitly authorized targeted tests. It must cover state and transition permutation semantics plus necessary regression checks.

No Product Connection persistence/application/HTTP work is opened by this acceptance. No R18 is authorized.

## 6. Integration rule

The accepted result blob must be integrated to main unchanged together with this acceptance record. No rejected R17 result is integrated and no candidate rebase/merge is required.

## 7. Acceptance classification

`IP-13I-R17-R1 ACCEPTED — MAXIMAL COMPARABLE REVISION SCOPE FIXED AS ORDER-INVARIANT DUPLICATE-CONFLICT POLICY — EXISTING STRUCTURAL + 8/19 REASON CONTRACTS PRESERVED — EVALUATOR REPAIR AUTHORIZED AS NEXT BOUNDED TASK — OLD R17 REMAINS REJECTED — NO PERSISTENCE / APPLICATION / HTTP AUTHORIZED`
