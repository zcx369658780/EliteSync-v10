# EliteSync v10｜New-Version APP Implementation Roadmap Baseline｜v0.1

Status: `OWNER-APPROVED PRODUCT TARGET — ROADMAP BASELINE LOCKED FOR PLANNING — CODE EXECUTION REQUIRES BOUNDED TASKS`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Authority:

- accepted APP audit closeout acceptance: `d96901e288a6b3da6da12caf226e6d11638838e1`;
- feature-design supplement blob: `b72ed9ec851d44aba7be65883186cb275fab22d1`;
- Owner acceptance artifact created after direct Owner confirmation on 2026-09-12.

This roadmap locks the product workstream ordering and target capability baseline. It does not grant unrestricted code-change authority. Each implementation unit must still be issued as a bounded task against a fresh repository authority.

## 1. Target MVP outcome

MVP target shell:

`Home | Progress | Messages | Me`

MVP product loop:

`Onboarding -> Readiness -> Match -> Connection -> Conversation`

Relationship is an explicit Phase-2 mutual-opt-in support lifecycle. Explore/Support Library is Phase 2 and is not an MVP blocker.

The target must preserve:

`Match != Connection != Conversation != Relationship`

and the accepted Privacy/Safety/User-Control and AI/Safety authority boundaries.

## 2. Planning principles

1. Product contracts precede broad implementation.
2. Current source existence does not force migration.
3. `DEFERRED != MISSING`, `UNKNOWN != ABSENT`, and `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`.
4. New code should not deepen legacy product semantics that are already targeted for retirement.
5. Private-data-dependent validation remains synthetic/contract-based unless separately authorized.
6. No single task should silently combine product decision, architecture design, migration, and implementation.
7. Legacy removal occurs only after consumer/entry-point inventory and replacement contract are established.
8. Safety evidence remains outside ordinary Match/Compatibility/reputation.

## 3. Workstream ordering

### WS-APP-00 — Target-contract freeze and migration inventory

Goal: convert the accepted product design into implementation-consumable contracts before changing broad UI behavior.

Required outputs:

- target navigation/route ownership contract;
- domain-state vocabulary registry for Onboarding, Readiness, Match, Connection, Conversation, Relationship;
- event/transition contract with invalid-transition rules;
- product data-class/audience registry;
- current-vs-target mapping for AppShell, Home, Discover, Match, Messages, Profile;
- participant-linked legacy Match consumer/entry-point inventory;
- migration/cutover constraints and rollback boundary;
- exact list of unresolved decisions that block only specific downstream work.

No source implementation should begin before the corresponding contract exists.

Classification: `FIRST IMPLEMENTATION-PREPARATION GATE`.

### WS-APP-01 — AppShell and navigation foundation

Goal: establish the target top-level IA without yet implementing all downstream product capabilities.

Target:

`Home | Progress | Messages | Me`

Required work:

- route/navigation model;
- Progress container that keeps Match, Connection and Relationship semantically separate;
- Me container for Showcase, Private Identity, Matching Inputs, Readiness, Settings/Privacy;
- Explore retained as secondary destination, not top-level MVP tab;
- preserve accessible navigation semantics already established on current Home shell where applicable.

Legacy rule:

Do not delete legacy Match or Discover consumers merely because the shell changes; first establish bounded compatibility/cutover behavior.

Classification: `MVP FOUNDATION`.

### WS-APP-02 — Onboarding, identity-purpose split and readiness foundation

Goal: make the first-use path understandable and purpose-limited.

Required work:

- progressive onboarding shell;
- public/guest informational entry;
- Private Identity surface;
- Matching Inputs surface;
- Readiness checklist surface;
- Showcase preview/edit surface;
- explicit Match opt-in;
- resumable draft/recovery states;
- required-vs-optional field metadata and why-needed explanations.

Blocking retained unknowns:

- exact launch eligibility;
- exact minimum identity assurance mechanism/level.

Implementation may proceed on state/UI contracts and synthetic readiness semantics while those exact production choices remain bounded unknowns, provided the code does not hard-code invented requirements.

Classification: `MVP`.

### WS-APP-03 — Canonical Match lifecycle

Goal: implement the accepted canonical Match model without collapsing it into Connection.

Target state model:

`MATCH_OFF -> ENROLLED -> SEARCHING -> PROPOSAL_AVAILABLE -> ACCEPTED_BY_ME -> MUTUAL_MATCH -> MATCH_COMPLETE`

Alternate proposal outcomes:

`DECLINED`, `WITHDRAWN`, `EXPIRED`.

Required work:

- explicit Match enrollment/pause/withdraw;
- one unresolved proposal at a time for MVP;
- explanation/reason/provenance surface;
- distinct transport/loading/no-candidate states;
- expiry-ready contract with duration configurable rather than embedded as product truth;
- synthetic test fixtures that contain no private participant data;
- migration adapter/cutover plan from participant-linked legacy Match.

Must not implement:

- automatic Connection creation;
- private Conversation as Match input;
- Safety-derived ranking;
- authoritative Compatibility total score.

Classification: `MVP CORE`.

### WS-APP-04 — Connection lifecycle

Goal: implement a distinct mutual-consent layer after Match.

Target:

`NONE -> CONNECTION_INVITE_AVAILABLE -> PENDING_MUTUAL -> ACTIVE -> PAUSED / CLOSED`

Alternate pending outcomes:

`DECLINED`, `EXPIRED`.

Required work:

- explicit Start Connection action;
- independent mutual consent;
- pause/resume rules;
- closure semantics;
- no inactivity-based automatic expiry of ACTIVE Connection;
- no unilateral reopening of CLOSED Connection;
- notification events with privacy-minimal payloads.

Classification: `MVP CORE`.

### WS-APP-05 — Conversation lifecycle and message gating

Goal: preserve existing Conversation capability while re-gating it to the accepted lifecycle.

Target:

`LOCKED -> AVAILABLE_TO_ENABLE -> CONSENT_PENDING -> ACTIVE -> PAUSED / READ_ONLY / CLOSED`

Required work:

- Conversation availability based on ACTIVE Connection;
- separate messaging consent;
- mute versus Conversation pause distinction;
- Connection pause/close effect contract;
- privacy-minimal notifications;
- Block and Report entry points remain separate;
- basic export/delete request surface can be scaffolded without inventing final shared-content legal semantics.

Retained blocker for production-complete data rights:

- exact shared Conversation retention/export/deletion rights.

Private populated Conversation inspection remains unauthorized unless separately approved.

Classification: `MVP CORE`, with advanced data-right semantics `PHASE 2 / PRODUCTION-READINESS`.

### WS-APP-06 — Home / Calm State Hub

Goal: make Home a lifecycle-aware, low-density status and next-decision surface.

Required work:

- current lifecycle state summary;
- at most one primary required action;
- optional support area;
- readiness/pause/action-required summaries;
- privacy-safe glance behavior;
- stale/offline indication;
- Explore secondary entry.

Must not add engagement-pressure mechanics.

Classification: `MVP`.

### WS-APP-07 — Explainability, Settings/Privacy and notifications

Goal: provide the minimum cross-domain trust/control layer required before MVP is considered coherent.

Required work:

- explanation component/contract used by Match, Readiness and AI-assisted output;
- provenance/uncertainty/source-class presentation;
- Privacy Control Center;
- point-of-use consent plus central review/revoke;
- notification category controls;
- generic lock-screen defaults;
- AI-use controls by capability rather than only a global switch;
- data-request state UI without pretending unresolved legal semantics are settled.

Classification: `MVP REQUIRED CROSS-CUTTING`.

### WS-APP-08 — Unified presentation-state contract

Goal: remove ambiguous relationships between transport failures and domain states.

Required vocabulary:

`EMPTY`, `WAITING`, `LOADING`, `ERROR_RETRYABLE`, `ACTION_REQUIRED`, `OFFLINE`, `STALE`, `UNAVAILABLE`, `PAUSED`.

Required work:

- preserve user input across retry where safe;
- last-updated indicators for stale cached state;
- no silent production mock fallback;
- no raw private/internal diagnostics in user-facing error surfaces;
- no false success for offline lifecycle-changing actions.

Classification: `MVP`.

### WS-APP-09 — Legacy Match retirement / cutover

Goal: retire participant-linked legacy Match only after the canonical replacement and consumer map are verified.

Required gates:

1. legacy consumer/entry-point inventory complete;
2. canonical replacement contract implemented;
3. navigation/notification consumers migrated;
4. rollback/cutover conditions recorded;
5. synthetic regression coverage established;
6. no hidden requirement established for legacy compatibility.

Then remove/disable the legacy countdown/result/notification ownership.

Classification: `MVP MIGRATION CLOSURE`.

### WS-APP-10 — Phase 2 Explore / Support Library

Goal: reintroduce Discover's useful structural primitives as a bounded support library.

Required work:

- public editorial/support content contract;
- provenance/freshness/withdrawal;
- optional topic preference/bookmark;
- no private Conversation/Safety-based personalization;
- explainable ordering if personalization exists.

Classification: `PHASE 2`.

### WS-APP-11 — Phase 2 Relationship support

Goal: implement mutual, non-authoritative ongoing relationship support.

Target:

`NOT_DECLARED -> PENDING_MUTUAL -> ACTIVE -> PAUSED / ENDED`

Required work:

- explicit mutual opt-in;
- private vs shared reflection separation;
- end/pause without automatically rewriting Connection or Conversation;
- no relationship-health/romantic-value score;
- no AI-inferred relationship stage.

Classification: `PHASE 2`.

### WS-APP-12 — Later/Optional AI and reference signals

Potential scope:

- private reflection assistance;
- optional Relationship-support AI;
- personality/reference signals;
- astrology/reference signals;
- advanced explanations/personalization.

Preconditions:

- purpose-specific data allowlist;
- provenance and uncertainty contract;
- user control/disable path;
- no truth/relationship/Safety authority;
- no conversion into hidden desirability or reputation ranking.

Classification: `LATER / OPTIONAL`.

## 4. Recommended implementation-task sequence

The next Codex implementation-preparation tasks should be issued in this order unless a newly discovered bounded dependency requires adjustment:

1. `APP-T01` — target route/ownership + domain-state contract artifact;
2. `APP-T02` — current-vs-target source locator and legacy Match consumer inventory;
3. `APP-T03` — AppShell target navigation implementation;
4. `APP-T04` — Profile-purpose split/readiness/onboarding contract and first bounded implementation;
5. `APP-T05` — canonical Match state model and synthetic fixture implementation;
6. `APP-T06` — Connection lifecycle implementation;
7. `APP-T07` — Conversation gating/lifecycle implementation without populated private-data inspection;
8. `APP-T08` — Home Calm State Hub implementation;
9. `APP-T09` — Explainability/Privacy/Notification cross-cutting implementation;
10. `APP-T10` — state/error/offline/stale harmonization;
11. `APP-T11` — legacy Match bounded retirement/cutover;
12. `APP-T12` — MVP integration acceptance and remaining-gap review.

Phase 2 tasks follow only after MVP target acceptance.

These IDs are planning identifiers, not self-authorizing execution orders. Each task still requires a task sheet or explicit bounded prompt with fresh repository authority.

## 5. MVP exit criteria candidate

MVP may be considered product-structurally complete only when:

- target four-destination shell is coherent;
- onboarding/readiness is resumable and purpose-limited;
- Match, Connection and Conversation are independently represented and consent-gated;
- no path automatically collapses Match -> Connection -> Conversation;
- Home accurately projects lifecycle state without engagement pressure;
- user can inspect/correct/revoke/pause where promised;
- private/public/data-purpose boundaries are visible in UI and contract;
- no single authoritative Compatibility score exists;
- private Conversation is not default ranking/training/AI input;
- Safety evidence cannot enter ordinary Match/Compatibility/reputation;
- legacy Match no longer owns active product semantics after cutover;
- loading/error/offline/stale states cannot masquerade as domain outcomes;
- retained production-readiness unknowns are explicitly recorded rather than guessed.

## 6. Parallel non-APP route preservation

The existing Sandbox/DEP13/B12/M2 chain remains separate. This roadmap does not cancel its accepted facts, but it is no longer the conceptual APP feature-design route.

Existing boundaries remain:

- Sandbox/DEP13 unresolved;
- B12 not authorized;
- M2 separately authorized only if/when issued;
- no new acquisition follows from this APP roadmap.

A future task must explicitly state whether it belongs to APP redesign or the independent dependency/recovery chain. Neither route silently authorizes the other.

## 7. No-processing and governance exclusions

This roadmap does not authorize:

- participant research/recruitment;
- private Conversation inspection;
- telemetry/analytics/measurement;
- Safety Operations;
- new legal research without a maturity-trigger task;
- broad private/cache archaeology;
- unrestricted production data access.

## 8. Roadmap classification

`NEW-VERSION APP PRODUCT TARGET ACCEPTED — APP IMPLEMENTATION ROADMAP BASELINE LOCKED FOR PLANNING — NEXT ACTION IS BOUNDED APP-T01 CONTRACT WORK — SOURCE IMPLEMENTATION MUST NOT OUTRUN PRODUCT/STATE/DATA CONTRACTS`
