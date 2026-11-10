# EliteSync v10｜Next IP-12D Backend Messaging Consent + Conversation Live-Gate Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `36bda84bd66591b8a84fbeb89779552452a46138`

## 1. Objective

Implement exactly one pure, deterministic, in-memory Messaging Consent lifecycle + Conversation live-access gate evaluator with synthetic fixtures only.

This slice consumes the accepted common authority contract and accepted Product Connection semantics. It must preserve the two-input gate:

`current/fresh exact-context CN_ACTIVE` AND `current/fresh participant-/Conversation-purpose-/Connection-context-bound MC_ACTIVE`.

Connection is necessary but not sufficient. Messaging Consent is independent authority. Live read and live send are distinct derived gates.

This task does not read, write, send, store, rank, summarize, preview, moderate, train on, or otherwise process Conversation content.

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if base, paths, or authority differ.

Recommended branch:

`review/next-ip-12d-backend-messaging-consent-conversation-live-gate-evaluator-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/MessagingConsentConversationLiveGateEvaluator.php`
2. `services/backend-laravel/tests/Unit/MessagingConsentConversationLiveGateEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

The source may consume:

- `CommonAuthorityEvidenceContract`
- the already accepted Product Connection state vocabulary/derived-current semantics

It must not modify those files.

## 4. Fixed Messaging Consent lifecycle

Preserve exactly:

- `MC_NONE`
- `MC_PENDING`
- `MC_ACTIVE`
- `MC_DECLINED`
- `MC_WITHDRAWN`
- `MC_REVOKED`

Derived `UNKNOWN` is not a lifecycle state.

Allowed semantic transitions are exactly:

- `MC_NONE -> MC_PENDING` when either participant requests consent in a current authoritative `CN_ACTIVE` context;
- `MC_PENDING -> MC_ACTIVE` when the recipient accepts;
- `MC_PENDING -> MC_DECLINED` when the recipient declines;
- `MC_PENDING -> MC_WITHDRAWN` when the requester withdraws;
- `MC_ACTIVE -> MC_REVOKED` when either participant revokes.

There is no consent pause, resume, close, or implicit inheritance transition.

Terminal old consent identities do not reopen. A later consent attempt requires a fresh consent identity, current Connection context, fresh request, and full transition path.

A new Connection identity does not inherit old consent.

## 5. Fixed Conversation live-gate semantics

The evaluator may derive two distinct booleans/classifications:

- `live_read_allowed`
- `live_send_allowed`

Both require independently:

1. exact current/fresh/binding-valid Product Connection evidence establishing `CN_ACTIVE` for the exact Connection identity and exact two participants; and
2. exact current/fresh/binding-valid Messaging Consent evidence establishing `MC_ACTIVE`, bound to:
   - the exact consent identity;
   - the exact Connection identity;
   - the exact participant set;
   - the exact Conversation-purpose context.

Connection alone must never grant live read or send.

Consent alone must never grant live read or send without a current/fresh exact-context active Connection.

Live read and live send remain separate outputs. The implementation may support distinct synthetic purpose bindings for read and send and must not infer one from the other.

History access, retention, export, deletion, moderation, legal hold, data rights, archived content and post-revocation historical-data behavior are outside this slice.

## 6. Required proof obligations

The source/test pair must independently prove at least:

1. exact Messaging Consent vocabulary and `UNKNOWN` exclusion;
2. exactly two distinct Connection participants are required;
3. `MC_NONE -> MC_PENDING` requires current/fresh exact-context `CN_ACTIVE`;
4. inactive/pending/paused/closed/declined/withdrawn/expired Connection cannot create a usable consent request;
5. `MC_PENDING -> MC_ACTIVE` requires recipient-bound acceptance evidence;
6. requester self-accept cannot substitute for recipient acceptance;
7. `MC_PENDING -> MC_DECLINED` requires recipient-bound decline evidence;
8. `MC_PENDING -> MC_WITHDRAWN` requires requester-bound withdrawal evidence;
9. `MC_ACTIVE -> MC_REVOKED` may be established by either exact participant;
10. no `MC_ACTIVE -> MC_PENDING`, pause, resume, close or implicit reactivation transition;
11. terminal `MC_DECLINED / MC_WITHDRAWN / MC_REVOKED` same-identity consent cannot reopen;
12. later consent lifecycle requires fresh consent identity and full path;
13. a new Connection identity does not inherit old consent;
14. cross-Connection consent evidence fails closed;
15. wrong-participant consent evidence fails closed;
16. missing, unknown, unavailable, stale, superseded or incomparable consent evidence fails closed;
17. current-but-stale consent fails closed;
18. freshness cannot manufacture consent currentness;
19. conflicting equal-revision duplicate consent evidence fails closed;
20. incomparable duplicate consent evidence fails closed;
21. newer same-lineage consent evidence may control without arrival-order authority;
22. no global revision or last-received-wins authority;
23. current/fresh `CN_ACTIVE` without `MC_ACTIVE` grants neither live read nor send;
24. current/fresh `MC_ACTIVE` without current/fresh exact-context `CN_ACTIVE` grants neither live read nor send;
25. exact current/fresh `CN_ACTIVE` + exact current/fresh read-purpose `MC_ACTIVE` may allow live read only;
26. exact current/fresh `CN_ACTIVE` + exact current/fresh send-purpose `MC_ACTIVE` may allow live send only;
27. read consent does not imply send consent and send consent does not imply read consent;
28. revocation invalidates corresponding live gate immediately to fail-closed/false;
29. correction/supersession of Connection or Consent dependency invalidates derived gate;
30. invalidation does not reset/reopen Connection or Consent lifecycle;
31. evaluator creates no Conversation content, message, unread count, preview, notification, Relationship or Home authority;
32. evaluator does not mutate/back-write Connection or Consent source evidence;
33. result is privacy-minimal and omits raw/private fixture payload;
34. no ranking, Compatibility total, desirability, person-worth, training or analytics authority is created.

## 7. Explicit retained unknowns / prohibitions

Do not implement or choose:

- Conversation content storage;
- message send transport;
- websocket/LiveKit/provider behavior;
- unread/read receipts;
- push notification payloads;
- message previews;
- history retention or post-revocation history policy;
- export/delete/data-rights behavior;
- moderation/Safety Operations;
- legal hold or region-specific legal rules;
- persistence/database/query enforcement;
- endpoint/wire/API/client behavior;
- retry/cooldown/expiry timing policy;
- Relationship lifecycle;
- Home ranking/action selection;
- training, analytics or ads use.

## 8. Synthetic-only boundary

Use conspicuous invented `synthetic-*` literals only. No real/redacted user, profile, Conversation message/content, private decision/reason, notification token, telemetry, credential, provider response, Safety evidence or production configuration.

## 9. Same-worktree vendor bootstrap rule

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry, update, scripts/plugins or lockfile mutation. `vendor/**` remains untracked/unstaged/uncommitted.

## 10. Exact test/command budget

After both new code files exist, exactly one targeted PHPUnit attempt:

`vendor/bin/phpunit tests/Unit/MessagingConsentConversationLiveGateEvaluatorTest.php`

No retry.

After final authoring run exactly once:

`git diff --check`

Read-only Git/provenance commands for hashes/blobs/tree/parent/ahead-behind and branch publication are allowed.

## 11. Explicit prohibitions

Do not run full PHPUnit suite, Feature tests, coverage, mutation tests, Artisan, migrations, generators, cache commands, application/runtime entrypoints, provider/network integrations, Sandbox, DEP13 or B12.

Do not modify dependencies, manifests, lockfiles, PHPUnit config, autoload config, existing business files, or client/Flutter/Android paths.

Do not self-accept, merge or move `main`.

## 12. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file tracked scope;
- source/test/result hashes/blobs;
- accepted common-contract and Product Connection source blobs consumed;
- semantic proof-case coverage;
- synthetic-only boundary;
- Composer Case A/B and receipt if run;
- targeted PHPUnit attempt, exit, version/runtime and summary;
- any warnings/deprecations as retained tooling warnings without unauthorized diagnostic rerun;
- `git diff --check` receipt;
- pre/post `composer.json` and `composer.lock` SHA-256 + Git blob identities;
- retained unknowns/non-authorities;
- candidate SHA, sole parent, tree and relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review remains required.

Expected success classification:

`IP-12D BACKEND MESSAGING CONSENT + CONVERSATION LIVE-GATE EVALUATOR IMPLEMENTED WITH SYNTHETIC FIXTURES — CONNECTION AND CONSENT REMAIN INDEPENDENT AUTHORITIES — LIVE READ/SEND GATES FAIL CLOSED AND PURPOSE-BOUND — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
