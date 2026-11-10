# EliteSync v10｜Next IP-12G Backend Core-Domain Semantic Integration Harness Implementation Task｜v0.1

Status: `OWNER-AUTHORIZED — EXACT BOUNDED IMPLEMENTATION TASK — FRESH INDEPENDENT REVIEW REQUIRED AFTER CANDIDATE`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `b6a37df235078639096478bed47cc4d9a594aed0`

## 1. Objective

Implement exactly one pure, deterministic, synthetic-only backend semantic integration harness that composes the already accepted bounded evaluators without adding persistence, endpoints, providers, production behavior, or new product policy.

This task verifies that the accepted domain separations still hold when the chain is exercised together:

`Runtime Readiness -> Canonical Match -> Product Connection -> Messaging Consent / Conversation live gate -> Calm Home -> Notification eligibility/payload`

The harness is test/integration semantics only. It is not a production orchestrator, workflow engine, service layer, controller, repository, scheduler, or event bus.

Future slice name:

`NEXT-IP-12G-BACKEND-CORE-DOMAIN-SEMANTIC-INTEGRATION-HARNESS-IMPLEMENTATION-V0-1`

## 2. Mandatory base gate

Before any write:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Prove `origin/main` equals this task-publication commit.
4. Create one isolated review worktree/branch from that exact commit.
5. Verify all three authorized output paths below are absent.
6. Stop rather than adapt if base, paths, or authority differ.

Recommended branch:

`review/next-ip-12g-backend-core-domain-semantic-integration-harness-v0-1`

## 3. Exact tracked write scope

Create exactly these three new tracked files and no others:

1. `services/backend-laravel/app/Domain/CoreDomainSemanticIntegrationHarness.php`
2. `services/backend-laravel/tests/Unit/CoreDomainSemanticIntegrationHarnessTest.php`
3. `docs/architecture/ELITESYNC_V10_BACKEND_CORE_DOMAIN_SEMANTIC_INTEGRATION_HARNESS_IMPLEMENTATION_RESULT_V0_1.md`

No existing tracked file may change.

Synthetic fixtures must live only in the exact test file.

## 4. Accepted inputs that may be consumed

The harness may consume only the already accepted source contracts/evaluators on the task-publication base:

- `CommonAuthorityEvidenceContract`
- `RuntimeReadinessDerivedEvaluator`
- `CanonicalMatchProposalDecisionEvaluator`
- `ProductConnectionStateTransitionEvaluator`
- `MessagingConsentConversationLiveGateEvaluator`
- `CalmHomeReadOnlyCompositionEvaluator`
- `NotificationEligibilityPrivacyMinimalPayloadEvaluator`

Do not change or subclass them.

## 5. Required integration proofs

The source/test pair must prove at least:

1. A valid Runtime Readiness result does not create Match, Connection, Consent, Conversation, Home action, or Notification authority.
2. `MUTUALLY_ACCEPTED` Match does not create Product Connection.
3. `CN_ACTIVE` does not create or imply Messaging Consent.
4. `MC_ACTIVE` without exact current/fresh `CN_ACTIVE` does not enable Conversation live read/send.
5. Exact current/fresh `CN_ACTIVE` plus exact purpose-bound `MC_ACTIVE` enables only the corresponding live gate(s).
6. Read consent and send consent remain independently scoped end-to-end.
7. Calm Home may project source-local state but remains zero-writer and cannot create source authority.
8. Multiple valid Home action candidates with no accepted precedence produce no primary action.
9. Notification source event does not imply eligibility.
10. Notification payload exists only for `ELIGIBLE` and remains privacy-minimal/generic for external or lock-screen presentation.
11. Notification route/deep-link locator never grants permission or bearer capability.
12. Delivery/open/dismiss observations never change source-domain outcome.
13. Correction/revocation/supersession of a dependency invalidates only dependent derivations; it must not reset/reopen unrelated lifecycle identities.
14. Unknown/unavailable/stale/superseded/incomparable evidence in one domain does not silently become success in another domain.
15. No global revision or last-received-wins authority appears anywhere in the integrated result.
16. No Compatibility total, ranking, desirability, person-worth, analytics, training, or ads authority appears.
17. No Conversation content, message preview, unread count, hidden Safety evidence, real/private identity/profile data, credential, device token, or provider payload is read or emitted.
18. Reordering independent synthetic inputs does not change authoritative meaning where ordering has no accepted semantics.
19. The integrated harness remains deterministic and zero-writer.
20. The integrated output is non-authoritative for persistence, endpoint, transport, provider, client, legal, Safety, deployment, or production actions.

## 6. Explicit non-authorities

Do not implement or choose:

- database/schema/model/repository persistence;
- endpoint/wire/controller/request/response behavior;
- queue/event bus/background job/scheduler;
- APNs/FCM/LiveKit/websocket/provider transport;
- device token or credential handling;
- client/Flutter/Android/UI/navigation behavior;
- production configuration or deployment;
- legal/Safety policy or real/private-data processing;
- ranking, Compatibility scoring, recommendation, person-worth, analytics, training, or ads processing;
- new domain states, transitions, precedence, expiry/cooldown/retry policy, or source writers.

## 7. Same-worktree vendor bootstrap rule

Check only:

- `services/backend-laravel/vendor/autoload.php`
- `services/backend-laravel/vendor/bin/phpunit`

If both exist, do not run Composer.

Otherwise exactly one attempt is authorized from `services/backend-laravel/`:

`composer install --no-interaction --no-progress --prefer-dist --no-scripts --no-plugins`

No retry. No update. No scripts/plugins. `composer.json` and `composer.lock` must remain byte/blob identical. `vendor/**` remains untracked/unstaged/uncommitted.

## 8. Exact test/command budget

After both code files exist, exactly one targeted PHPUnit attempt is authorized:

`vendor/bin/phpunit tests/Unit/CoreDomainSemanticIntegrationHarnessTest.php`

No retry.

After final authoring, run exactly once:

`git diff --check`

Read-only Git/provenance commands for hashes/blobs/tree/parent/ahead-behind and review-branch publication are allowed.

## 9. Required result document

Record:

- task-publication commit and candidate topology;
- exact three-file tracked scope;
- source/test/result blobs and SHA-256 where possible;
- exact accepted input source blobs consumed;
- semantic integration proof coverage;
- synthetic-only/privacy-minimal boundary;
- Composer Case A/B receipt;
- targeted PHPUnit attempt/exit/version/runtime/summary/warnings;
- `git diff --check` receipt;
- pre/post `composer.json` and `composer.lock` SHA-256 + Git blob identities;
- retained unknowns/non-authorities;
- candidate SHA, sole parent, tree, relation to fresh `origin/main`;
- statement that fresh independent ACCEPT/REJECT review remains required.

Expected success classification:

`IP-12G BACKEND CORE-DOMAIN SEMANTIC INTEGRATION HARNESS IMPLEMENTED WITH SYNTHETIC FIXTURES — CROSS-DOMAIN AUTHORITY SEPARATIONS PRESERVED — FAIL-CLOSED INVALIDATION / PRIVACY-MINIMAL / ZERO-WRITER BOUNDARIES PROVEN — TARGETED UNIT TEST PASS — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
