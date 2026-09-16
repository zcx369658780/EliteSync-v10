# EliteSync v10｜Next IP-12E Backend Calm Home Read-Only Composition Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `bc46b89add00c4d3003a047d4f502855e807e63c`

## 1. Objective

Implement exactly one pure, deterministic, read-only Calm Home composition evaluator with synthetic fixtures only.

This slice consumes the already accepted Runtime Readiness, Canonical Match, Product Connection, and Conversation live-gate derived outputs as non-authoritative read inputs. It composes privacy-minimal Home sections and at most one primary action. It performs no writes and creates no source-domain authority.

Future slice name:

`NEXT-IP-12E-BACKEND-CALM-HOME-READ-ONLY-COMPOSITION-EVALUATOR-IMPLEMENTATION-V0-1`

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if the base, paths, or authority differ.

Recommended branch:

`review/next-ip-12e-backend-calm-home-read-only-composition-evaluator-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/CalmHomeReadOnlyCompositionEvaluator.php`
2. `services/backend-laravel/tests/Unit/CalmHomeReadOnlyCompositionEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_CALM_HOME_READ_ONLY_COMPOSITION_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact unit-test file.

## 4. Fixed Home semantics

Home is a zero-writer, read-only composition over four already-derived domains:

- Runtime Readiness
- Canonical Match
- Product Connection
- Conversation live access

The output contains exactly three conceptual sections:

- `CURRENT_STATE`
- `NEXT_DECISION`
- `OPTIONAL_SUPPORT`

Home must not mutate, repair, transition, or synthesize source-domain state.

Home must not infer source authority from presentation order, navigation, cache, route, previous screen, notification origin, or client state.

Partial source availability is handled source-locally. An unavailable/unknown domain must not erase independently valid facts from other domains.

## 5. Primary-action rule

At most one primary action may be emitted.

A primary action may be emitted only when exactly one action candidate is independently established as currently valid under accepted domain authority.

If zero action candidates are valid, emit no primary action.

If more than one action candidate is valid and there is no separately accepted unique precedence rule, emit no primary action.

Do not rank, score, prefer, infer desirability, or invent precedence.

Candidate actions in this bounded slice may only be coarse opaque action categories derived from accepted domain outputs, for example:

- `COMPLETE_READINESS_DECISION`
- `RESPOND_TO_MATCH_DECISION`
- `RESPOND_TO_CONNECTION_DECISION`
- `OPEN_LIVE_CONVERSATION`

The exact action category is presentation metadata only. It is not permission, a bearer capability, a source-domain transition, or a write command.

## 6. Required proof obligations

The source/test pair must independently prove at least:

1. composition is read-only and does not mutate any supplied domain result;
2. `CURRENT_STATE`, `NEXT_DECISION`, `OPTIONAL_SUPPORT` are distinct sections;
3. all outputs remain privacy-minimal and omit source binding envelopes/private payloads;
4. valid Readiness output may contribute state without granting launch authority;
5. valid Match output may contribute state/action candidate without creating Connection;
6. valid Connection output may contribute state/action candidate without granting Consent/Conversation;
7. valid Conversation live gate may expose an `OPEN_LIVE_CONVERSATION` candidate only when accepted live-access evidence permits at least one live capability;
8. live read and live send distinctions remain visible and are not collapsed into a generic permission;
9. unknown/unavailable/stale/superseded/incomparable input from one domain is handled source-locally;
10. one unknown source must not erase independently valid facts from other domains;
11. zero valid action candidates yields no primary action;
12. exactly one valid action candidate may become the primary action;
13. two or more simultaneously valid candidates without accepted precedence yields no primary action;
14. Home never ranks or chooses a candidate by arbitrary order;
15. reordering input domains cannot change the no-precedence outcome;
16. duplicate presentation of the same exact action identity may be deduplicated only when identity and semantic payload are exact duplicates;
17. conflicting same-identity action payloads fail closed and do not produce a primary action;
18. correction/revocation/supersession invalidation of a dependency invalidates only the affected Home fragment/action candidate, not unrelated independently valid fragments;
19. Home creates no source authority, permission, transition, writer, launch authority, Connection, Consent, Conversation content authority, Relationship authority, Notification authority, ranking or Compatibility total;
20. no private Conversation content, previews, drafts, unread counts, hidden Safety evidence, telemetry, analytics, training, ads data, Compatibility total, desirability, or person-worth signal is read or emitted.

## 7. Explicit retained unknowns / forbidden policy invention

Do not implement or choose:

- global action precedence;
- tie-breaking rules;
- ranking or recommendation scores;
- Compatibility total;
- UI layout/styling;
- notification origin behavior;
- route/deep-link behavior;
- navigation stack;
- client caching;
- persistence/database/query enforcement;
- endpoint/wire/API/client behavior;
- real/private-data handling;
- legal/Safety policy;
- production configuration.

## 8. Synthetic-only boundary

Use conspicuous invented literals only. No real/redacted users, private profile facts, Match reasons, Conversation content, notification payloads, verification/Safety evidence, telemetry, credentials, provider responses, or production configuration.

## 9. Same-worktree vendor bootstrap rule

Check only these exact locators:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical.

Generated `vendor/**` must remain untracked/unstaged/uncommitted.

## 10. Exact test/command budget

After both new code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/CalmHomeReadOnlyCompositionEvaluatorTest.php`

No retry.

After final authoring run exactly once:

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
- accepted input source blobs used where applicable;
- semantic proof-case coverage;
- synthetic-only/privacy-minimal boundary;
- Composer Case A/B and exact receipt if run;
- targeted PHPUnit attempt, exit, version/runtime and summary;
- warnings/deprecations if any;
- `git diff --check` receipt;
- pre/post `composer.json` and `composer.lock` SHA-256 + Git blob identities;
- retained unknowns and explicit non-authorities;
- candidate SHA, sole parent, tree, and relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review remains required.

Expected success classification:

`IP-12E BACKEND CALM HOME READ-ONLY COMPOSITION EVALUATOR IMPLEMENTED WITH SYNTHETIC FIXTURES — ZERO-WRITER / PARTIAL-SOURCE / NO-PRECEDENCE-MULTI-CANDIDATE BOUNDARIES EXPLICIT — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
