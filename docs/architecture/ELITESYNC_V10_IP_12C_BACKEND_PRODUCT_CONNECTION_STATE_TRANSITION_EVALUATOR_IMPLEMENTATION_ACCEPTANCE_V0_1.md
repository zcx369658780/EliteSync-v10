# EliteSync v10｜IP-12C Backend Product Connection State/Transition Evaluator Implementation Acceptance｜v0.1

Status: `ACCEPTED — FRESH INDEPENDENT REVIEW COMPLETE — IMPLEMENTATION SCOPE PRESERVED`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Accepted candidate: `c04d2c902b6bc95f05f3be593e7546c3fc99c605`

Sole parent / task-publication base: `141e99299be0782b16e0280aa6bf6c9505c2d5b3`

Candidate tree: `9647cfd207b31329ad346b64225f7840746bea66`

## Acceptance verdict

`IP-12C ACCEPTED — BACKEND PRODUCT CONNECTION STATE/TRANSITION EVALUATOR ESTABLISHED — MATCH DOES NOT AUTO-CREATE CONNECTION — DIRECT CN_NONE->CN_ACTIVE REJECTED — TERMINAL SAME-IDENTITY STATES DO NOT REOPEN — ONLY CURRENT/FRESH CN_ACTIVE MAY ENTER DOWNSTREAM CONSIDERATION — NO CONSENT/CONVERSATION OR OTHER DOWNSTREAM AUTHORITY CREATED`

## Independently confirmed

- Candidate is exactly one commit beyond task-publication base.
- Exact tracked scope is three new files only; no pre-existing tracked file changed.
- Lifecycle vocabulary remains exactly `CN_NONE / CN_PENDING / CN_ACTIVE / CN_PAUSED / CN_CLOSED / CN_DECLINED / CN_WITHDRAWN / CN_EXPIRED`; derived `UNKNOWN` is not inserted into lifecycle vocabulary.
- Allowed transition set is exactly the accepted bounded set; `CN_NONE -> CN_ACTIVE` is explicitly rejected.
- `Match != Connection`: a `MUTUALLY_ACCEPTED` Match cannot create, activate, or substitute for Connection evidence.
- Connection identity and exact participant set remain explicit.
- Missing, stale, unknown, unavailable, superseded, incomparable, cross-Connection, participant-mismatched, context-mismatched or conflicting evidence fails closed.
- Same-lineage source-local revision may select newer evidence without arrival-order authority; no global revision or last-received-wins rule exists.
- `CN_CLOSED / CN_DECLINED / CN_WITHDRAWN / CN_EXPIRED` are terminal for the same Connection identity and cannot reopen.
- Later lifecycle after a terminal state requires a fresh Connection identity.
- Expiry is consumed only as already-authoritative evidence; no duration/clock/timeout policy is invented.
- Only exact current/fresh/binding-valid `CN_ACTIVE` sets `connection_active_for_downstream_consideration = true`.
- That bounded flag grants no Messaging Consent, Conversation, Relationship, Home, Notification, launch or bearer authority.
- Correction/revocation/supersession invalidates the derivation without lifecycle reset or reopen.
- Result remains privacy-minimal and source evidence is not mutated/back-written.
- Synthetic-only boundary preserved.
- Targeted PHPUnit evidence reported: 39 tests / 155 assertions / 0 failures using PHPUnit 11.5.55 / PHP 8.5.3.
- PHPUnit reported 2 deprecations. The accepted test file contains two docblock-style `@dataProvider` metadata declarations; the warning is retained as test-harness hygiene and does not block this bounded domain implementation. No diagnostic rerun was authorized or performed.
- Composer bootstrap remained lock-preserving: 114 installs / 0 updates / 0 removals, scripts/plugins disabled; composer.json and composer.lock identities unchanged.
- `git diff --check` reported exit 0; LF/CRLF workspace notices did not indicate tracked whitespace errors.

## Retained boundaries

This acceptance does not authorize persistence, endpoint/wire/API realization, expiry timing policy, Messaging Consent logic, Conversation read/send gate, Relationship lifecycle, Home/Notification behavior, production, real/private data, legal conclusions, Safety authority, or client implementation.
