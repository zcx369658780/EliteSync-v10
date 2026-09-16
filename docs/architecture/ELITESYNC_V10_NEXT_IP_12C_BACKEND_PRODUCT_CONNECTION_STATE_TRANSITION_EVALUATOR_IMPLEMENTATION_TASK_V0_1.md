# EliteSync v10｜Next IP-12C Backend Product Connection State/Transition Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `4f20e7dc7497876febfde3b1b7bc6f07db048d7d`

## 1. Objective

Implement exactly one pure, deterministic, in-memory Product Connection state/transition evaluator with synthetic fixtures only.

This task consumes the accepted common authority-evidence contract and accepted Product Connection semantics. It does not create Connection records, does not auto-create Connection from Match, and does not implement Messaging Consent, Conversation live gate, Relationship, Home, Notification, persistence, endpoints, client behavior, production, real/private data, legal rules, Safety operations, or expiry timing policy.

Task name:

`NEXT-IP-12C-BACKEND-PRODUCT-CONNECTION-STATE-TRANSITION-EVALUATOR-IMPLEMENTATION-V0-1`

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if the base, paths, or authority differ.

Recommended branch:

`review/next-ip-12c-backend-product-connection-state-transition-evaluator-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/ProductConnectionStateTransitionEvaluator.php`
2. `services/backend-laravel/tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_STATE_TRANSITION_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

The source may consume the already accepted `CommonAuthorityEvidenceContract` and may define only pure Connection state/transition evaluation logic for this slice.

## 4. Fixed Connection vocabulary and boundary

Preserve exactly these canonical states:

- `CN_NONE`
- `CN_PENDING`
- `CN_ACTIVE`
- `CN_PAUSED`
- `CN_CLOSED`
- `CN_DECLINED`
- `CN_WITHDRAWN`
- `CN_EXPIRED`

Derived uncertainty may be represented as `UNKNOWN`, but `UNKNOWN` must not be inserted into the canonical lifecycle vocabulary.

Match and Connection remain separate authorities:

`Match != Connection`

A `MUTUALLY_ACCEPTED` Match result alone never creates, activates, or proves a Connection.

Connection identity must be explicit and bound to the exact two participants and exact aggregate/context identity.

## 5. Fixed transition semantics for this bounded slice

The evaluator may validate/derive only these canonical transition relations:

- `CN_NONE -> CN_PENDING`
- `CN_PENDING -> CN_ACTIVE`
- `CN_PENDING -> CN_DECLINED`
- `CN_PENDING -> CN_WITHDRAWN`
- `CN_PENDING -> CN_EXPIRED`
- `CN_ACTIVE -> CN_PAUSED`
- `CN_ACTIVE -> CN_CLOSED`
- `CN_PAUSED -> CN_ACTIVE`
- `CN_PAUSED -> CN_CLOSED`

The evaluator must explicitly reject/fail closed for at least:

- `CN_NONE -> CN_ACTIVE`;
- any direct Match-result-to-Connection activation substitution;
- any outgoing transition from `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, or `CN_EXPIRED` on the same Connection identity;
- any transition with stale, unknown, unavailable, superseded or incomparable current-state evidence;
- any participant or aggregate/context mismatch;
- any transition request bound to another Connection identity;
- conflicting equal-revision transition evidence;
- incomparable duplicate transition evidence.

Terminal identities do not reopen. A later Connection lifecycle after a terminal state requires a fresh Connection aggregate identity and fresh authority evidence.

`CN_PAUSED` is non-terminal in this slice and may resume only through the explicit `CN_PAUSED -> CN_ACTIVE` relation.

Expiry duration, clock source, timeout thresholds and scheduling policy remain retained unknowns. `CN_EXPIRED` may only be consumed as already-authoritative current state/transition evidence; do not invent timing policy.

## 6. Current-state / downstream authority boundary

The evaluator may expose a bounded current-state derivation only when the exact Connection evidence is current, fresh, participant-bound and aggregate-bound.

Only an exact current/fresh/binding-valid `CN_ACTIVE` may be labelled as Connection-active for downstream consideration.

That label is not Messaging Consent, Conversation permission, Relationship authority, Home action authority, Notification permission, launch eligibility, or a bearer capability.

`CN_PENDING`, `CN_PAUSED`, terminal states, missing evidence, or uncertain evidence must never be treated as active Connection authority.

## 7. Required proof obligations

The source/test pair must independently prove at least:

1. canonical Connection vocabulary is exact and derived `UNKNOWN` is outside it;
2. Connection identity is explicit;
3. exactly two distinct participant identities are required;
4. current-state evidence must be current/fresh/binding-valid;
5. `CN_NONE -> CN_PENDING` is admissible;
6. `CN_PENDING -> CN_ACTIVE` is admissible only with exact current Connection/request context;
7. `CN_NONE -> CN_ACTIVE` is rejected;
8. `CN_PENDING -> CN_DECLINED` is admissible from valid authoritative evidence;
9. `CN_PENDING -> CN_WITHDRAWN` is admissible from valid authoritative evidence;
10. `CN_PENDING -> CN_EXPIRED` may be consumed without inventing clock/duration policy;
11. `CN_ACTIVE -> CN_PAUSED` is admissible;
12. `CN_ACTIVE -> CN_CLOSED` is admissible;
13. `CN_PAUSED -> CN_ACTIVE` is admissible;
14. `CN_PAUSED -> CN_CLOSED` is admissible;
15. terminal same-identity states have no outgoing transition;
16. later lifecycle after terminal state requires a fresh Connection identity;
17. Match mutual acceptance does not create or activate Connection;
18. cross-Connection transition evidence fails closed;
19. wrong-participant evidence fails closed;
20. missing/unknown/unavailable/stale/superseded/incomparable current evidence yields `UNKNOWN`;
21. current-but-stale fails closed;
22. freshness cannot manufacture currentness;
23. same-lineage newer evidence may control without arrival-order authority;
24. conflicting equal-revision duplicate evidence fails closed;
25. incomparable duplicate evidence fails closed;
26. no global revision or last-received-wins rule exists;
27. only exact current/fresh `CN_ACTIVE` may expose bounded `connection_active_for_downstream_consideration = true`;
28. that active label does not grant Messaging Consent, Conversation, Relationship, Home, Notification or launch authority;
29. correction/revocation/supersession of a used dependency invalidates the derived result without lifecycle reset/reopen;
30. evaluator does not mutate/back-write Connection, Match or transition source evidence;
31. result is privacy-minimal and contains no raw/private fixture payload;
32. no ranking, Compatibility total, desirability or person-worth computation exists.

## 8. Explicit retained unknowns / forbidden policy invention

Do not implement or choose:

- expiry duration or clock authority;
- cooldown/retry/reinvite policy;
- Connection invitation copy or UI behavior;
- persistence/database/query enforcement;
- endpoint/wire/API realization;
- Messaging Consent request/accept/revoke logic;
- Conversation read/send live gate;
- Relationship lifecycle;
- Home/Notification behavior;
- client/Flutter/Android behavior;
- real/private data handling;
- legal or Safety policy.

## 9. Synthetic-only boundary

Use conspicuous invented literals only. No real/redacted users, profiles, Match reasons/signals, private Conversation content, verification/Safety evidence, telemetry, credentials, provider responses, or production configuration.

## 10. Same-worktree vendor bootstrap rule

In the candidate worktree, check only these exact readiness locators:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical.

Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 11. Exact test/command budget

After both new code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/ProductConnectionStateTransitionEvaluatorTest.php`

No retry.

After final authoring, run exactly once:

`git diff --check`

Read-only Git/provenance commands for hashes/blobs/tree/parent/ahead-behind and review-branch publication are allowed.

## 12. Explicit prohibitions

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache commands, application/runtime entrypoints, provider/network integrations, Sandbox, DEP13 or B12.

Do not modify dependencies, manifests, lockfiles, PHPUnit config, autoload config, existing business files, or client/Flutter/Android paths.

Do not self-accept, merge, or move `main`.

## 13. Required result document

The exact result document must record:

- task-publication commit and candidate topology;
- exact three-file tracked scope;
- source/test/result hashes/blobs;
- accepted common-contract source blob used;
- semantic proof-case coverage;
- synthetic-only boundary;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit attempt, exit, version/runtime and summary;
- `git diff --check` receipt;
- pre/post `composer.json` and `composer.lock` SHA-256 + Git blob identities;
- retained unknowns and explicit non-authorities;
- candidate SHA, sole parent, tree, and relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review remains required.

Expected success classification:

`IP-12C BACKEND PRODUCT CONNECTION STATE/TRANSITION EVALUATOR IMPLEMENTED WITH SYNTHETIC FIXTURES — MATCH DOES NOT AUTO-CREATE CONNECTION — ACTIVE/DOWNSTREAM BOUNDARY FAIL-CLOSED — TERMINAL FRESH-IDENTITY RULE PRESERVED — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.