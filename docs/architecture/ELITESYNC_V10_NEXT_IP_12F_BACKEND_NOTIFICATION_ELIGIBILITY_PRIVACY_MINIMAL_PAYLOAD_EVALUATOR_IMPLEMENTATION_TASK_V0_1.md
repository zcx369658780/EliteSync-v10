# EliteSync v10｜Next IP-12F Backend Notification Eligibility + Privacy-Minimal Payload Evaluator Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `f3a498e36a459d1531b60dbc5ff0c7dccb246c5f`

## 1. Objective

Implement exactly one pure, deterministic, in-memory Notification eligibility/privacy-minimal-payload evaluator with synthetic fixtures only.

This slice preserves the accepted four-layer Notification separation:

1. source-domain event authority
2. notification eligibility
3. privacy-minimal payload generation
4. delivery attempt/result evidence

This task implements only layers 2 and 3 plus bounded layer-separation assertions. It does not send notifications, call providers, inspect device tokens, implement delivery transport, write notification state, create source-domain outcomes, or process real/private data.

Future slice name:

`NEXT-IP-12F-BACKEND-NOTIFICATION-ELIGIBILITY-PRIVACY-MINIMAL-PAYLOAD-EVALUATOR-IMPLEMENTATION-V0-1`

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if base/path/authority differs.

Recommended branch:

`review/next-ip-12f-backend-notification-eligibility-privacy-minimal-payload-evaluator-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/NotificationEligibilityPrivacyMinimalPayloadEvaluator.php`
2. `services/backend-laravel/tests/Unit/NotificationEligibilityPrivacyMinimalPayloadEvaluatorTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_NOTIFICATION_ELIGIBILITY_PRIVACY_MINIMAL_PAYLOAD_EVALUATOR_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only inside the exact test file.

## 4. Fixed semantic boundary

Preserve these non-equivalences:

`SOURCE DOMAIN EVENT != NOTIFICATION ELIGIBILITY`

`NOTIFICATION ELIGIBILITY != PAYLOAD`

`PAYLOAD != AUDIENCE/ACCESS`

`DELIVERY SUCCESS != DOMAIN SUCCESS`

`OPEN/DISMISS != DOMAIN OUTCOME`

`ROUTE/DEEP-LINK IDENTITY != PERMISSION`

`TRANSPORT FAILURE != DOMAIN FAILURE`

Notification eligibility may be derived only from exact current/fresh/binding-valid synthetic source-domain evidence plus an explicit synthetic notification-purpose/audience context.

A valid source-domain event does not automatically make a notification eligible.

Unknown/unavailable/stale/superseded/incomparable/missing/conflicting evidence must fail closed to `UNKNOWN` eligibility.

Allowed eligibility classifications are exactly:

- `ELIGIBLE`
- `INELIGIBLE`
- `UNKNOWN`

Only explicit current/fresh/binding-valid negative eligibility evidence may produce `INELIGIBLE`.

## 5. Privacy-minimal payload boundary

The evaluator may produce only coarse synthetic payload fields needed to explain a bounded notification, such as:

- opaque event reference
- opaque context reference
- coarse category
- generic title token
- generic body token
- optional route identity as a non-authoritative locator

It must not include or derive:

- private Conversation content
- message previews/drafts
- unread counts derived from private content
- hidden Safety evidence
- Compatibility total/ranking/desirability/person-worth
- real names/contact info/profile fields
- credentials/device tokens/provider payloads
- telemetry/analytics/training/ads signals

External/lock-screen audience defaults must be generic/privacy-minimal; do not create richer external content from internal/in-app facts.

A route/deep-link field is identity/navigation metadata only and must never imply permission.

## 6. Protected action revalidation

If a payload contains an action/route identity, the evaluator must expose that any later protected action still requires fresh source-authority revalidation.

No notification-origin action may carry a reusable permission grant, bearer capability, domain-success assertion, consent authority, Connection authority, Conversation authority, or launch authority.

## 7. Layer separation / delivery non-authority

The evaluator may accept synthetic delivery-attempt/result evidence only to prove separation. It must never infer domain outcome from delivery success/failure/open/dismiss.

Delivery facts may be represented only as coarse observation metadata such as:

- `NOT_ATTEMPTED`
- `ATTEMPTED`
- `DELIVERED`
- `FAILED`
- `OPENED`
- `DISMISSED`

These are not source-domain states.

## 8. Required proof obligations

The source/test pair must independently prove at least:

1. source-domain event authority and notification eligibility remain separate;
2. eligible requires current/fresh/binding-valid source evidence plus explicit purpose/audience eligibility input;
3. source event alone does not imply eligible;
4. explicit current/fresh valid negative eligibility may produce `INELIGIBLE`;
5. missing/unknown/unavailable/stale/superseded/incomparable eligibility evidence yields `UNKNOWN`;
6. conflicting equal-revision evidence fails closed;
7. incomparable duplicate evidence fails closed;
8. same-lineage newer evidence may control independent of arrival order;
9. no global revision or last-received-wins rule;
10. payload generation requires `ELIGIBLE` and cannot repair unknown eligibility;
11. payload remains privacy-minimal and omits private/raw fixture material;
12. external/lock-screen payload remains generic and no richer than permitted audience policy input;
13. route/deep-link identity does not grant permission;
14. protected action requires fresh revalidation marker;
15. payload does not create source-domain authority, consent, Connection, Conversation, Relationship, Home, launch, ranking, Compatibility-total or person-worth authority;
16. delivery success does not imply domain success;
17. delivery failure does not imply domain failure;
18. open/dismiss does not imply domain outcome;
19. transport observation does not mutate source event/eligibility/payload evidence;
20. correction/revocation/supersession of a dependency invalidates eligibility/payload derivation without changing source-domain lifecycle;
21. input order does not create authority;
22. evaluator remains deterministic and zero-writer.

## 9. Explicit prohibitions

Do not implement:

- APNs/FCM/provider transport
- device token handling
- OS notification channels
- scheduling/background jobs
- retries/backoff
- notification persistence/database tables
- endpoint/wire/API/client behavior
- Home navigation behavior
- deep-link execution
- real/private data
- Conversation content/previews/drafts
- Safety Operations
- legal hold/retention policy
- analytics/training/ads

Do not use Sandbox, DEP13 or B12, and do not reopen M1/M2/M3.

## 10. Same-worktree vendor bootstrap rule

Check only these exact locators:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. Generated `vendor/**` remains untracked/unstaged/uncommitted.

## 11. Exact test/command budget

After both new code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/NotificationEligibilityPrivacyMinimalPayloadEvaluatorTest.php`

No retry.

After final authoring, run exactly once:

`git diff --check`

Read-only Git/provenance commands for hashes/blobs/tree/parent/ahead-behind and review-branch publication are allowed.

## 12. Required result document

Record:

- task-publication commit/candidate topology;
- exact three-file tracked scope;
- source/test/result hashes/blobs;
- accepted common-contract source blob used;
- semantic proof-case coverage;
- synthetic-only/privacy-minimal boundary;
- Composer Case A/B and receipt if run;
- targeted PHPUnit attempt/exit/version/runtime/summary;
- warnings/deprecations if any;
- `git diff --check` receipt;
- pre/post `composer.json` and `composer.lock` SHA-256 + Git blob identities;
- retained unknowns/non-authorities;
- candidate SHA, sole parent, tree, and relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review remains required.

Expected success classification:

`IP-12F BACKEND NOTIFICATION ELIGIBILITY + PRIVACY-MINIMAL PAYLOAD EVALUATOR IMPLEMENTED WITH SYNTHETIC FIXTURES — FOUR-LAYER SEPARATION PRESERVED — EXTERNAL PAYLOAD GENERIC — ACTION REVALIDATION REQUIRED — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
