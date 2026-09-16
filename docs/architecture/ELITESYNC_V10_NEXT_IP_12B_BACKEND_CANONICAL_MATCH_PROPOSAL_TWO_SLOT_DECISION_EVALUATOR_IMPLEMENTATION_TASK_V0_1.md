# EliteSync v10｜Next IP-12B Backend Canonical Match Proposal + Two-Slot Decision Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `3132d768e857ec3dcb673958fa30c3d8b5dbb604`

## 1. Objective

Implement exactly one pure, deterministic, in-memory Canonical Match proposal/two-slot decision evaluator with synthetic fixtures only.

This task consumes the accepted common authority contract and accepted Match semantics. It does not implement Product Connection creation, ranking, Compatibility totals, expiry/cooldown/retraction policy, notifications, persistence, endpoints, client behavior, real/private data, legal rules, Safety operations, or production integration.

Future slice name:

`NEXT-IP-12B-BACKEND-CANONICAL-MATCH-PROPOSAL-TWO-SLOT-DECISION-EVALUATOR-IMPLEMENTATION-V0-1`

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if the base, paths, or authority differ.

Recommended branch:

`review/next-ip-12b-backend-canonical-match-proposal-two-slot-evaluator-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`
2. `services/backend-laravel/tests/Unit/CanonicalMatchProposalDecisionEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_PROPOSAL_TWO_SLOT_DECISION_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

The source may consume the already accepted `CommonAuthorityEvidenceContract` and may define only pure Match proposal/two-slot evaluation logic needed for this bounded slice.

## 4. Fixed Match semantics

Preserve exactly these lifecycle vocabularies:

Participation:

- `NOT_ENROLLED`
- `ENROLLED`
- `PAUSED`
- `WITHDRAWN`

Proposal:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`

Decision-slot evidence must remain separate from proposal lifecycle.

One-sided acceptance remains decision evidence inside `PENDING`; it is not a proposal lifecycle state.

Each proposal has exactly two independent participant-bound decision slots.

Mutual acceptance may be derived only when both exact current slots for the same current proposal independently establish acceptance and every required binding/currentness/freshness condition passes.

Terminal proposal identities never reopen. Later lifecycle requires a fresh proposal identity and fresh decision slots.

Participation pause or withdrawal makes pending proposal acceptance unusable for the affected participant and the evaluator must fail closed rather than invent a new proposal outcome.

Current MVP at-most-one-unresolved-proposal policy may be represented only as an input/precondition flag in this slice; do not implement storage/query enforcement.

## 5. Allowed evaluator outputs

The evaluator may return only bounded derived decision classifications such as:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`
- `UNKNOWN`

`UNKNOWN` is a derived uncertainty condition and must not be inserted into the canonical proposal lifecycle vocabulary.

The result must remain non-authoritative for Product Connection, Messaging Consent, Conversation, Relationship, Home, Notification, launch eligibility, ranking, Compatibility total, or person worth.

## 6. Required proof obligations

The source/test pair must independently prove at least:

1. two exact participants are required;
2. proposal identity and participant binding are explicit;
3. exactly two participant-bound decision slots exist;
4. one-sided accept remains `PENDING`;
5. two current/fresh exact-proposal accept slots may derive `MUTUALLY_ACCEPTED`;
6. a slot for another proposal identity cannot contribute;
7. a slot for the wrong participant cannot contribute;
8. duplicate conflicting same-slot evidence fails closed;
9. incomparable revision evidence fails closed;
10. newer same-lineage slot evidence may control without arrival-order authority;
11. missing slot evidence yields `UNKNOWN`, not decline;
12. unknown/unavailable/stale/superseded/incomparable slot evidence yields `UNKNOWN`;
13. current-but-stale fails closed;
14. freshness cannot manufacture currentness;
15. exact source-local revision only, no global revision;
16. participant `PAUSED` prevents fresh pending acceptance use for that participant;
17. participant `WITHDRAWN` prevents fresh pending acceptance use for that participant;
18. terminal proposal identities cannot reopen to `PENDING` or `MUTUALLY_ACCEPTED`;
19. fresh later lifecycle requires a distinct proposal identity;
20. decline evidence for the exact current proposal can derive `DECLINED` only when binding/currentness/freshness are valid;
21. withdrawal evidence for the exact current proposal can derive `WITHDRAWN` only when the accepted actor/binding semantics are represented by synthetic input;
22. expiry may be consumed only as already-authoritative proposal evidence; do not invent timing/duration/clock policy;
23. accepted terminal state cannot be overridden by later-arriving stale/non-authoritative slot evidence;
24. evaluator does not create Product Connection or any downstream authority;
25. evaluator does not compute a Compatibility total, score, rank, desirability, person-worth, or recommendation;
26. evaluator does not mutate/back-write participation/proposal/slot source evidence;
27. result is privacy-minimal and contains no raw/private fixture payload;
28. correction/revocation/supersession of a dependency invalidates the derived result without reopening/resetting the proposal identity.

## 7. Explicit retained unknowns / forbidden policy invention

Do not implement or choose:

- proposal expiry duration or clock authority;
- cooldown/renewal/retraction policy;
- future multi-candidate policy;
- ranking or Compatibility scoring;
- optional AI/personality/astrology/reference signals;
- concrete launch prerequisites;
- rejection/withdrawal private reasons;
- Product Connection creation;
- notification behavior;
- persistence/database/query enforcement;
- endpoint/wire/client behavior.

## 8. Synthetic-only boundary

Use conspicuous invented literals only. No real/redacted users, profiles, private decisions/reasons, Match signals, Compatibility data, Conversation content, verification/Safety evidence, telemetry, credentials, provider responses, or production configuration.

## 9. Same-worktree vendor bootstrap rule

In the candidate worktree, check only these exact readiness locators:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical.

Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 10. Exact test/command budget

After both new code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/CanonicalMatchProposalDecisionEvaluatorTest.php`

No retry.

After final authoring, run exactly once:

`git diff --check`

Read-only Git/provenance commands for hashes/blobs/tree/parent/ahead-behind and review-branch publication are allowed.

## 11. Explicit prohibitions

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache commands, application/runtime entrypoints, provider/network integrations, Sandbox, DEP13 or B12.

Do not modify dependencies, manifests, lockfiles, PHPUnit config, autoload config, existing business files, or client/Flutter/Android paths.

Do not self-accept, merge, or move `main`.

## 12. Required result document

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

`IP-12B BACKEND CANONICAL MATCH PROPOSAL/TWO-SLOT DECISION EVALUATOR IMPLEMENTED WITH SYNTHETIC FIXTURES — ONE-SIDED ACCEPTANCE REMAINS PENDING — MUTUAL ACCEPTANCE REQUIRES TWO CURRENT EXACT-PROPOSAL SLOTS — TERMINAL FRESH-IDENTITY / FAIL-CLOSED UNKNOWN BOUNDARIES EXPLICIT — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
