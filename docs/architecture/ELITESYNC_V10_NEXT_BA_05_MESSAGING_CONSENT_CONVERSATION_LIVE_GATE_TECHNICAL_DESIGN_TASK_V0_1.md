# EliteSync v10｜NEXT BA-05 Messaging Consent + Conversation Live Gate Technical Design Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `e761a2ff98543e5b1135f592c298872479f91347`

## 1. Authorization and purpose

Under the Owner-delegated bounded-governance convention, BA-05 is authorized for one bounded semantic/interface technical-design artifact because its accepted upstream gates are now satisfied and this task is reversible, documentary, product/architecture-layer only, and creates no implementation, production, legal, Safety, private-data, or irreversible external authority.

This task defines the minimum current-authority contract for separate mutual messaging consent and the Product Conversation live gate consuming current Product Connection authority.

This task does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client changes, legal closure, Conversation history/retention/export/deletion design, compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the following exact authorities and bounded sections:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only the binding/revision/freshness/permitted-action/idempotency/composition rules required by BA-05
3. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`, only sections needed for the downstream BA-05 `CN_ACTIVE` evidence boundary
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-05 section only
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-D and directly dependent cross-domain sections only
7. `docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_APP_T07_CONVERSATION_AVAILABILITY_MESSAGING_CONSENT_FOUNDATION_RESULT_V0_1.md`, only Product Conversation / messaging-consent lifecycle and access-foundation sections
9. `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`, especially D-02, D-03, D-08, D-10
10. `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_CANDIDATE_V0_1.md`, only the accepted D-02/D-03/D-08/D-10 semantics needed to interpret the Owner acceptance

Do not enumerate directories or broadly search the repository. If one of these exact paths is missing or its accepted provenance cannot be established, stop and report the missing authority instead of inventing a substitute.

## 3. Exact output and scope

Produce exactly one technical-design candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

The candidate must define semantic authority obligations only. It must not modify backend/client source, tests, dependencies, lockfiles, generated files, configuration, or any existing accepted artifact.

## 4. Required design content

### 4.1 Authority ownership separation

Define, without choosing concrete services:

- Product Connection authority as the owner of current participant-bound `CN_ACTIVE` evidence only;
- Messaging Consent authority as a distinct owner of mutual messaging-consent evidence for the exact participant set and Conversation purpose;
- Product Conversation live-gate evaluator/projection as a consumer/composer of those two authorities, not a writer of either one;
- Product Conversation lifecycle/read-send grant evidence as domain-owned evidence that cannot back-write Connection or messaging consent.

Explicitly preserve:

`Match != Connection != Conversation != Relationship`

`CN_ACTIVE != messaging consent`

`read grant != send grant`

`route identity != consent`

`transport success != domain outcome`

### 4.2 Messaging-consent semantic lifecycle

Using only already accepted APP-T07/product semantics, define the bounded messaging-consent lifecycle needed for live-gate evaluation, including:

- no-consent / not-established posture;
- pending consent request where already accepted;
- mutual consent establishment only through the accepted independent-consent path;
- decline/withdraw/revoke/pause/close semantics only where already accepted;
- actor/participant/purpose bindings for each consent outcome;
- correction/revocation/supersession representation using BA-01 revision rules.

Do not invent an unaccepted consent state, actor, transition, cooldown, expiry duration, or reopen rule. If APP-T07 does not fix a complete messaging-consent transition/actor rule required for this design, preserve the exact gap and stop before claiming a complete matrix.

### 4.3 Two-input live-gate truth table

Provide a complete truth table for Product Conversation live access using two independent inputs:

1. current authoritative Product Connection evidence for the current aggregate; and
2. current authoritative mutual messaging-consent evidence for the same participant set and Conversation purpose.

At minimum cover:

- current/fresh `CN_ACTIVE` + current/fresh mutual messaging consent;
- `CN_ACTIVE` + consent pending/not-mutual;
- `CN_ACTIVE` + revoked consent;
- `CN_ACTIVE` + unknown/unavailable/stale/superseded consent;
- `CN_PENDING`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` + any consent state;
- historical/superseded `CN_ACTIVE`;
- `CN_ACTIVE` from the wrong/historical aggregate;
- participant mismatch;
- audience mismatch;
- purpose mismatch;
- projection lag/currentness unknown for either input.

One valid input cannot repair the other. Any required unknown/stale/unavailable/mismatched input fails closed without asserting absence, deletion, guilt, Safety outcome, or relationship meaning.

### 4.4 Read and send grants

Define live Conversation read and send grants separately.

The design must specify:

- the minimum evidence required for live read;
- the minimum evidence required for live send;
- whether the accepted MVP currently treats them identically or whether a semantic distinction must remain explicit;
- that a read grant never silently implies send authority;
- that send authority is removed when authoritative messaging consent is revoked or authoritative current `CN_ACTIVE` is lost;
- that cached rows, cached messages, drafts, unread counts, realtime connectivity, local state, existing routes, or transport success cannot restore either grant.

If accepted sources do not establish a stronger distinction between live read and live send, preserve them as separate grant dimensions with identical current prerequisites rather than collapsing them into one permanent permission.

### 4.5 Revision, freshness, supersession, and propagation

Define independent revision lineages for Product Connection and messaging consent.

Cover at minimum:

- each input has its own owner/revision/freshness/currentness;
- the gate has no global revision that supersedes either input owner;
- correction/revocation of either input invalidates dependent live grants according to its exact scope;
- a newer `CN_PAUSED`/`CN_CLOSED`/terminal Connection revision supersedes a historical `CN_ACTIVE` for live-gate use;
- a newer consent revoke supersedes an earlier mutual-consent grant for live-gate use;
- stale or incomparable input evidence cannot authorize new live protected access;
- projection lag cannot promote older evidence over a known newer revision;
- consumers must reconcile authoritative evidence after transport timeout/unknown outcome rather than infer grant/failure.

### 4.6 Aggregate binding after Product Connection restart

Because BA-04 accepted a new-aggregate restart rule, define the downstream consequence explicitly:

- messaging consent and Conversation live grants must bind to the exact current Product Connection aggregate/context they were established for, or to an explicitly accepted semantic relation that is at least as restrictive;
- a new Product Connection aggregate after a historical terminal lifecycle must not inherit old messaging consent or old Conversation live grants by default;
- historical `CN_ACTIVE`, historical messaging consent, historical Conversation rows, peer identity, or prior route cannot shortcut fresh authority evaluation for the new aggregate.

Do not invent historical-read authority or migration/rebinding behavior.

### 4.7 Fail-closed private-data construction boundary

At the semantic design level, preserve the accepted APP-T07 privacy rule:

- private Conversation list/detail/message/draft/realtime protected data must not be treated as available before the live read gate passes;
- direct stored-Conversation routing must re-check current authority before protected detail access;
- send paths must re-check current send authority;
- a protected route existing does not prove that the viewer may construct/fetch private Conversation content.

This is a semantic boundary only. Do not modify Flutter/client implementation.

### 4.8 Historical access exclusion and Track-2 boundary

This BA-05 task is live-gate only.

Explicitly exclude and preserve as separate authority:

- historical Conversation read after revoke, pause, close, Block, or account exit;
- retention durations/schedules;
- export/access/portability workflows;
- deletion/erasure and peer-visible effects;
- account-exit handling;
- legal holds/backups/security exceptions;
- rights-request verification/timelines/refusals/appeals;
- region-specific legal/data-right implementation.

Accepted D-03 conservative posture remains binding: history is unavailable by default unless a separate explicit history-access authority is later established. This is not a statement that historical content is absent or erased.

### 4.9 Explicit negative assertions

Prove that none of the following alone or together creates Product Conversation live read/send authority:

- Match or Match mutual acceptance;
- candidate/proposal/compatibility identity;
- `eligibleMatch`;
- `legacyPeer`;
- route/deep-link/stored-route identity;
- peer ID;
- existing Conversation/chat row;
- unread count;
- cached messages or drafts;
- realtime/websocket connectivity;
- transport acknowledgement/success;
- notification payload identity/open;
- historical `CN_ACTIVE`;
- `CN_ACTIVE` without separate current mutual messaging consent;
- messaging consent without separate current `CN_ACTIVE`;
- Home card/action label;
- local boolean/mock unlock/optimistic UI.

Private Conversation remains outside default Match/ranking/training/advertising use.

## 5. Required truth/concurrency cases

Include explicit cases for at least:

- consent request retry with same logical intent;
- duplicate consent acceptance;
- accept vs decline/withdraw race where already accepted by the product lifecycle;
- Connection pause/close racing with consent acceptance;
- messaging-consent revoke racing with send intent;
- stale `CN_ACTIVE` cached after Connection pause/close;
- stale mutual-consent evidence cached after revoke;
- new Product Connection aggregate with historical consent evidence;
- transport timeout after consent intent may have committed;
- changed semantic input under reused idempotency identity;
- participant/audience/purpose mismatch;
- projection lag on one input while the other is current.

All cases resolve against the current authority of each owning lineage, never client/transport arrival order.

## 6. Required acceptance evidence inside the candidate

The artifact must allow an independent reviewer to verify:

1. Product Connection and messaging consent remain independent authority owners;
2. current live grants require both current participant-bound `CN_ACTIVE` and current participant/purpose-bound mutual messaging consent;
3. one valid input cannot repair another invalid input;
4. read and send grants are explicit dimensions and read never silently becomes send;
5. revoke/loss/stale/unavailable/unknown/mismatch cases fail closed;
6. no historical read authority is created;
7. new Product Connection aggregates do not inherit historical consent/live grants by default;
8. private-data construction/fetch remains gated before protected use;
9. route/row/cache/transport/notification/legacy/local substitutions are rejected;
10. Conversation private content remains outside default Match/ranking/training/advertising use;
11. Track-2/material-fact/legal blockers remain unchanged;
12. no endpoint/wire/schema/storage/service/client/deployment mechanism is selected;
13. candidate scope is exactly the one authorized artifact; and
14. `git diff --check` passes.

## 7. Stop and uncertainty boundary

If the exact accepted APP-T07 messaging-consent lifecycle is insufficient to define any transition/actor behavior required for a complete BA-05 contract, do not invent it. Record the exact missing product-authority fact, publish no misleading complete design, and stop.

No broad repository search or source-code inspection is authorized merely to fill such a gap.

## 8. Git and execution boundary

Recommended branch:

`review/next-ba-05-messaging-consent-conversation-live-gate-technical-design-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

No Flutter/Dart/Gradle/backend runtime/network/private-data/telemetry/Safety/legal-research execution is required or authorized.

After publishing the candidate:

- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check`;
- STOP;
- do not merge or self-accept;
- do not implement BA-05;
- do not start BA-06/07 or client integration.

Expected terminal classification if complete:

`MESSAGING CONSENT + CONVERSATION LIVE-GATE TECHNICAL DESIGN ESTABLISHED — INDEPENDENT TWO-INPUT AUTHORITY / READ-SEND GRANTS / FAIL-CLOSED PROPAGATION EXPLICIT — HISTORY AUTHORITY EXCLUDED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
