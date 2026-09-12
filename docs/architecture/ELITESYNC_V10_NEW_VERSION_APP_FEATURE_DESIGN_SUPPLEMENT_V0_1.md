# EliteSync v10｜New-Version APP Feature-Design Supplement｜v0.1

Status: `OWNER-REVIEWED DESIGN BASELINE — IMPLEMENTATION ROADMAP MAY NOW BE PREPARED — CODE IMPLEMENTATION NOT AUTHORIZED BY THIS ARTIFACT`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Authority inputs:

- accepted APP audit closeout result blob `8afadda0216a3509247fc2a7e5c182e6269442fa`;
- APP audit closeout acceptance commit `d96901e288a6b3da6da12caf226e6d11638838e1`;
- accepted Owner/product boundaries OD-01 through OD-06.

This artifact is a product-design supplement. It does not reopen the old APP audit, inspect private data, authorize Safety Operations, perform new legal research, or authorize source-code implementation.

## 1. Product direction

EliteSync v10 is a calm, consent-sequenced Relationship Decision Support System. The target experience is organized around four questions:

1. what state am I in;
2. what decision is actually needed next;
3. who can see what information and why;
4. how can I pause, revoke, correct, contest, or exit.

The target must preserve:

`Match != Connection != Conversation != Relationship`

AI remains advisory only. AI output is not verified truth, relationship authority, guilt authority, or autonomous Safety authority. Safety information must not become ordinary Compatibility, Ranking, romantic desirability, or public reputation. Private Conversation is not default training/ranking data.

## 2. Top-level product decisions

Recommended and Owner-confirmed direction:

- target MVP navigation: `Home | Progress | Messages | Me`;
- Discover is removed from MVP top-level navigation and redefined as a secondary `Explore / Support Library`, targeted for Phase 2 unless later evidence justifies elevation;
- MVP does not create a globally public user Profile;
- Private Identity, Matching Inputs, Readiness, and Showcase are distinct purpose/lifecycle surfaces;
- no single authoritative Compatibility score in MVP; use reasons, constraints, provenance, and uncertainty instead;
- Match, Connection, Conversation, and Relationship require distinct lifecycle states and distinct consent/authority boundaries;
- Relationship support is a Phase 2 mutual opt-in capability, not an inferred state;
- full private Conversation is not a default AI input;
- canonical Match is the forward path; participant-linked legacy Match is a retirement/migration concern, not a co-equal long-term product model.

## 3. Domain 1 — Home

### Target user problem

Users need a calm answer to: where am I, is action required, and what can I control next. Home must not manufacture engagement pressure.

### Recommended capability

A low-density `Calm State Hub` with at most three primary areas:

- Current state;
- Next decision;
- Optional support.

Home may be genuinely quiet when nothing requires attention.

### KEEP

- current Home entry concept;
- accepted first-frame hierarchy/navigation semantics;
- reusable title/CTA layout primitives.

### REFACTOR

- fixed CTA becomes lifecycle-aware;
- Home becomes a projection of Readiness/Match/Connection/Conversation/Relationship state rather than a Match-specific landing page.

### REMOVE / REPLACE

Do not carry forward engagement-maximization patterns such as streaks, infinite feed, anxiety countdowns, or activity pressure.

### ADD

- readiness summary;
- paused-state summary;
- consent/action-required summary;
- privacy-safe sensitive-card handling;
- stale/offline state;
- resume unfinished setup;
- Explore secondary entry.

### Privacy/data class

Default input is public editorial content plus minimal account-private lifecycle summaries. Peer identity or message text should not be exposed by default on a glanceable Home surface.

### Lifecycle/state model

Home projects, but does not own, states such as `GUEST`, `READINESS_INCOMPLETE`, `READY`, `MATCH_ACTIVE`, `CONNECTION_PENDING/ACTIVE`, `CONVERSATION_ACTIVE`, and `RELATIONSHIP_SUPPORT_ACTIVE`.

### User control

Pause Match, hide sensitive summaries, open source/reason explanations, defer non-essential action.

### Dependencies

Onboarding, Readiness, Match, Connection, Conversation, Relationship, Notifications, Privacy Controls.

### Classification

`MVP`

### Owner decision still required

None for target role. Detailed copy/layout remains implementation-design work.

## 4. Domain 2 — Discover / Explore

### Target user problem

Users may need relationship education, decision-support material, and reflection tools, but a generic feed risks becoming engagement optimization.

### Recommended capability

Replace the top-level Discover feed role with a secondary `Explore / Support Library` containing provenance-bearing public educational/support content.

### KEEP

Card/detail/info interaction primitives and a controlled content-source seam where useful.

### REFACTOR

Remote feed semantics become a bounded content/tool library with source, publication/review date, intended purpose, and withdrawal/stale status.

### REMOVE / REPLACE

Do not migrate the current opaque remote-feed model as a production assumption. The accepted remote Discover class remains `RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`.

### ADD

Provenance, freshness/withdrawal state, topic controls, optional bookmark, and explainable ordering where ordering exists.

### Privacy/data class

Content: `PUBLIC_EDITORIAL`. Bookmark/topic preference: `ACCOUNT_PRIVATE`. MVP must not use private Conversation or Safety evidence for content recommendation.

### Lifecycle/state model

`AVAILABLE -> STALE -> WITHDRAWN` plus transport states separated from content states.

### User control

Disable personalization, clear preferences, hide topic, inspect ordering reason.

### Dependencies

Home, Settings, Explainability, public-content governance.

### Classification

`PHASE 2`

### Owner decision still required

None for current target. Future evidence may justify top-level promotion.

## 5. Domain 3 — Canonical Match

### Target user problem

Users need to know whether they are participating, why a candidate appears, what acceptance means, and how pause/decline/expiry/retry work.

### Recommended capability

Canonical states:

`MATCH_OFF -> ENROLLED -> SEARCHING -> PROPOSAL_AVAILABLE -> ACCEPTED_BY_ME -> MUTUAL_MATCH -> MATCH_COMPLETE`

Terminal/alternate paths from a proposal include `DECLINED`, `WITHDRAWN`, and `EXPIRED`.

`NO_CANDIDATE`, `LOADING`, and network/tooling failures are presentation/transport states, not Match business states.

### Consent

Entering `ENROLLED` requires explicit Match opt-in. Candidate acceptance means willingness to consider progression; it does not create Connection.

### Pacing

MVP target: at most one unresolved candidate proposal at a time.

### Expiry

Proposal expiry is allowed if clearly explained and non-coercive. Expiry must not imply user wrongdoing. Exact duration is a later configurable product value.

### Explanation

Show high-level authorized reason categories, provenance, uncertainty, and what was not used. Do not reveal another person's private raw inputs.

### KEEP

Canonical round-contract seam as planning input.

### REFACTOR

Unify states and event semantics; separate business state from transport/tool failures.

### REMOVE / REPLACE

Participant-linked legacy countdown/result/notification path is a retirement/migration target once the canonical lifecycle is accepted for implementation.

### ADD

Explicit enrollment, pause, decline, withdraw, expiry, reason/provenance explanation, controlled retry.

### Privacy/data class

`MATCH_PURPOSE_LIMITED`; private Conversation and Safety evidence are not ordinary Match inputs.

### User control

Opt in/out, pause, withdraw, adjust authorized matching inputs, correct source inputs, inspect explanation.

### Dependencies

Readiness, Matching Inputs, Showcase, Explainability, Notifications.

### Classification

`MVP`

### Owner decision still required

Exact proposal expiry duration and future active-candidate limit remain configurable details. MVP design assumes one unresolved proposal.

## 6. Domain 4 — Connection

### Target user problem

A mutual Match must not silently become a durable permission to contact.

### Recommended capability

`NONE -> CONNECTION_INVITE_AVAILABLE -> PENDING_MUTUAL -> ACTIVE -> PAUSED / CLOSED`

Pending invitations may also become `DECLINED` or `EXPIRED`.

### Explicit mutuality

After mutual Match, a separate `Start a Connection` consent is required from both users.

### Pause

Either user may pause. The peer sees only that the Connection is paused, not a sensitive reason.

### Expiry

Expiry applies to `PENDING_MUTUAL`, not to ACTIVE Connection based on inactivity.

### Reset/closure

Closed Connection cannot be unilaterally reopened. Future reconnection should create a new lifecycle instance rather than mutate a closed one back to active.

### KEEP

The accepted conceptual distinction between Match and Connection.

### REFACTOR

Any implicit Match-success-equals-Connection semantics.

### REMOVE / REPLACE

Automatic Connection creation after Match.

### ADD

Invitation, mutual consent, pause, expiry, close, and lifecycle identity.

### Privacy/data class

`CONNECTION_SCOPED`.

### User control

Accept, decline, pause, resume where mutually valid, close.

### Dependencies

Match, Showcase, Conversation, Notifications.

### Classification

`MVP`

### Owner decision still required

None for independence/consent boundary.

## 7. Domain 5 — Conversation

### Target user problem

Connection permission is not the same as permission to start messaging.

### Recommended capability

`LOCKED -> AVAILABLE_TO_ENABLE -> CONSENT_PENDING -> ACTIVE -> PAUSED / READ_ONLY / CLOSED`

### Availability

Requires ACTIVE Connection and explicit messaging consent by both users.

### Pause/end

Mute is a local notification control; Pause Conversation is a domain action. Paused/closed Connection must constrain new Conversation activity according to the accepted product contract.

### Retention/export/deletion

UI must distinguish hide/local view removal, export, account deletion requests, and any later shared-content deletion semantics. A single ambiguous `Delete chat` control is insufficient.

### Moderation/protection

Block and Report are available but remain distinct: `Block != Report`, and Report is not a Finding.

### KEEP

Existing Conversation-list/unread/routing capability concepts.

### REFACTOR

Gate Conversation on valid Connection plus separate messaging consent.

### REMOVE / REPLACE

No `MATCH -> AUTO_CHAT`; no default use of private Conversation for training/ranking.

### ADD

Pause, close, retention visibility, export/deletion workflow, privacy-safe notification handling.

### Privacy/data class

`CONVERSATION_SHARED_PRIVATE`.

### User control

Mute, pause, close, block, report, export/deletion request.

### Dependencies

Connection, Privacy Center, Notifications, Safety boundary.

### Classification

Basic Conversation: `MVP`. Complex shared-content rights: `PHASE 2 / PRODUCTION-READINESS GATE`.

### Owner decision still required

Exact retention/export/deletion/shared-content semantics remain a later bounded privacy/legal/product decision and are not invented here.

## 8. Domain 6 — Relationship

### Target user problem

Users may want ongoing support after sustained interaction without the system becoming judge of relationship status or quality.

### Recommended capability

A mutual opt-in support context:

`NOT_DECLARED -> PENDING_MUTUAL -> ACTIVE -> PAUSED / ENDED`

### Capability boundary

Potential tools include shared agreements, optional check-ins, communication prompts, private reflection, and explicitly shared reflection.

### AI boundary

AI may help organize user-provided thoughts or generate prompts. It must not infer love, relationship health, guilt, manipulation, or relationship stage from private interaction patterns as authoritative facts.

### Lifecycle independence

Ending Relationship does not automatically close Connection or Conversation; those remain separately controlled.

### KEEP

Relationship as a distinct conceptual context/state.

### REFACTOR

Any future design that would infer relationship status automatically.

### REMOVE / REPLACE

Relationship-health score, romantic-value score, or AI-decided relationship stage.

### ADD

Mutual opt-in, pause/end, private/shared reflection boundaries.

### Privacy/data class

`USER_PRIVATE_REFLECTION` and `RELATIONSHIP_SHARED_PRIVATE` remain separate.

### Dependencies

Connection, Conversation, Privacy, Explainability.

### Classification

`PHASE 2`. AI-enhanced support is `LATER / OPTIONAL`.

### Owner decision still required

None for Phase-2 target existence; exact tools remain later design work.

## 9. Domain 7 — Profile / Private Identity / Matching Inputs / Showcase

### Target user problem

A monolithic Profile cannot safely represent identity, matching purpose, readiness, and public/peer-visible expression at once.

### Recommended capability

Four purpose boundaries:

1. `Private Identity` — account, age/identity assurance and other necessary private attributes;
2. `Matching Inputs` — relationship goals, preferences and authorized matching-purpose inputs;
3. `Readiness` — whether required evidence/consent is sufficient for Match;
4. `Showcase` — user-selected expression shown to a bounded audience.

MVP does not establish an Internet-public profile. Showcase defaults to candidate/connection-scoped visibility.

### KEEP

Reusable current fields/UI primitives as migration inventory only.

### REFACTOR

Split private/session/profile/readiness coupling by purpose and lifecycle authority.

### REMOVE / REPLACE

One Profile serving verification, matching, readiness and public expression simultaneously.

### ADD

Per-field audience, purpose, provenance, last-updated state, correction, revocation, expiry where applicable, and `Preview what others see`.

### Privacy/data class

Private Identity never becomes Showcase merely because it is present in storage.

### Lifecycle/state model

`DRAFT -> ACTIVE -> NEEDS_REVIEW / EXPIRED -> REVOKED / DELETION_PENDING`, applied per relevant data class.

### User control

Preview audience, hide/correct/revoke optional use, manage Showcase independently from identity.

### Dependencies

Onboarding, Readiness, Match, Connection, Settings.

### Classification

`MVP`

### Owner decision still required

Exact minimum Showcase field set remains detailed product design. Global-public profile is not part of MVP.

## 10. Domain 8 — Questionnaire / Verification / Readiness

### Target user problem

Users must understand what is required, what is optional, why information is needed, and what affects Match eligibility.

### Recommended capability

A named readiness checklist rather than a black-box score.

Potential required-for-Match classes include launch-scope eligibility, minimum age eligibility, Owner-approved minimum identity assurance, relationship intent, necessary boundaries/preferences, Match-specific consent, and a minimum Showcase set.

Optional classes may include interests, personality, reflective questions, astrology/reference signals, and richer preferences.

### Verification boundary

Verification only proves the proposition actually checked. `Identity assurance passed` must not become `trustworthy person`.

### Lifecycle/state model

`NOT_STARTED -> IN_PROGRESS -> READY -> NEEDS_UPDATE / EXPIRED`.

Verification-specific status may include `PENDING -> VERIFIED / NOT_VERIFIED / REVIEW_REQUIRED`.

### KEEP

Existing readiness/verification concepts.

### REFACTOR

Group inputs by purpose, necessity, sensitivity, and lifecycle.

### REMOVE / REPLACE

No black-box readiness total score; no mandatory personality/astrology merely to increase profile completeness.

### ADD

Why-needed, eligibility effect, optionality, expiry, correction, retry/review/appeal path.

### Privacy/data class

Every item must know required/optional status, purpose, audience, and lifecycle authority.

### User control

Skip optional items, see exactly what blocks Match, correct/review verification failure.

### Dependencies

Identity, Match, Explainability, Settings.

### Classification

Minimum readiness: `MVP`. Enrichment questionnaire: `LATER / OPTIONAL`.

### Owner decision still required

Launch segment/eligibility and exact minimum identity-assurance method/level remain retained `UNKNOWN` until separately decided.

## 11. Domain 9 — Explainability and User Control

### Target user problem

Users must distinguish declarations, verified facts, AI inference and product advice.

### Recommended capability

A standard explanation contract:

- what happened;
- why it happened;
- information classes used;
- what the output does not mean;
- uncertainty/limits;
- what the user can change.

### Composite score decision

MVP does not use a single authoritative Compatibility score. Reasons/constraints/provenance/uncertainty replace the implication that the system knows how good a future relationship will be.

### AI

AI-assisted output must be labeled, disclose relevant input classes and uncertainty, and expose correction/disable controls where meaningful.

### KEEP

Accepted User Control and Explainability priority.

### REFACTOR

Make explanation a standard part of Match, Readiness and AI capabilities rather than an optional afterthought.

### REMOVE / REPLACE

Authoritative Compatibility score, AI verdict, and opaque recommendation.

### ADD

Provenance, correction, revoke, contest, pause, retry, stale-explanation handling.

### Lifecycle/state model

Explanations become `STALE` when materially relevant inputs change.

### Dependencies

All lifecycle domains.

### Classification

Baseline contract: `MVP`. Advanced counterfactual explanation: `LATER`.

### Owner decision still required

None for MVP removal of a single Compatibility score.

## 12. Domain 10 — Notifications

### Target user problem

Users need timely action cues without privacy leakage or engagement pressure.

### Recommended event taxonomy

`ACTION_REQUIRED`, `MATCH_PROPOSAL`, `CONNECTION_REQUEST`, `NEW_MESSAGE`, `STATE_CHANGED`, `PRIVACY_ACCOUNT`, `OPTIONAL_SUPPORT`.

### Defaults

In-app lifecycle notices are normal product behavior. Push permissions should be requested contextually. Optional support reminders default off.

### Privacy

Lock-screen default should be generic, for example `EliteSync has an update`, rather than peer name, message text, Match result or Relationship state.

### Batching/quiet periods

Non-critical support notices can batch and respect quiet/DND settings. Expired actions cannot remain presented as actionable.

### KEEP

Notification center/unread concepts.

### REFACTOR

Domain-event-driven ownership.

### REMOVE / REPLACE

Legacy Match-specific notification ownership and sensitive lock-screen defaults.

### ADD

Category controls, preview level, expiry, quiet periods, cross-device read state where supported.

### Dependencies

All lifecycle domains and Settings.

### Classification

Core lifecycle notifications: `MVP`; optional support reminders: `LATER`.

### Owner decision still required

Exact OS permission timing and default preview wording are implementation/product-copy details; privacy-minimal default is fixed.

## 13. Domain 11 — Settings / Privacy Control Center

### Target user problem

Users need operational controls, not merely a policy document.

### Recommended capability

A central control center with:

- Visibility & Showcase;
- Match & Readiness;
- Connection & Conversation;
- AI Use;
- Notifications;
- Data & Account;
- Blocked/report-related controls.

Major consent occurs at point of use; Settings allows later review/change/revocation. One onboarding consent must not silently authorize future unrelated purposes.

### AI controls

Controls should be capability-specific, not merely a single global AI switch where distinct data use is involved.

### Data-request lifecycle

`NOT_REQUESTED -> CONFIRMING -> PROCESSING -> COMPLETED / FAILED`.

### KEEP

Any reusable settings entry/UI primitives that later inventory confirms.

### REFACTOR

Central overview plus point-of-use consent.

### REMOVE / REPLACE

Long policy text as the sole privacy/control mechanism.

### ADD

Audience preview, consent status, AI-use controls, data-request status, lifecycle effect explanations.

### Dependencies

All data/lifecycle domains.

### Classification

`MVP`

### Owner decision still required

Region-specific legal right coverage remains outside this artifact and should be resolved at the relevant maturity trigger.

## 14. Domain 12 — Onboarding / First Use

### Target user problem

Users should understand value and control before being asked for substantial private information.

### Recommended flow

`WELCOME/VALUE -> HOW ELITESYNC WORKS -> PRIVACY/USER CONTROL -> EXPLORE OR CREATE ACCOUNT -> BASIC ELIGIBILITY -> PRIVATE IDENTITY -> READINESS -> SHOWCASE PREVIEW -> EXPLICIT MATCH OPT-IN`

### Guest/public access

Users who are not Match-ready may still access public Home/help/Explore content. They cannot enter private Messages or Match participation without the required state/consent.

### Consent sequencing

Ask for data and OS permissions when the relevant purpose is reached, not all at first launch.

### Skip/resume/recovery

Non-required steps may be skipped and resumed. Failed identity/verification paths require recovery rather than dead-end rejection language.

### KEEP

The direction that a low-sensitivity public/unauthenticated entry can exist.

### REFACTOR

Progressive disclosure and resumable readiness.

### REMOVE / REPLACE

Collect-everything-first onboarding.

### ADD

Draft/resume, why-needed, effect-on-capability, recovery path.

### Dependencies

Identity, Readiness, Privacy, Explore.

### Classification

`MVP`

### Owner decision still required

None for guest/public direction.

## 15. Domain 13 — Empty / Loading / Error / Offline / Stale

### Recommended vocabulary

`EMPTY`, `WAITING`, `LOADING`, `ERROR_RETRYABLE`, `ACTION_REQUIRED`, `OFFLINE`, `STALE`, `UNAVAILABLE`, `PAUSED`.

Transport state must not masquerade as domain state. Network failure is not `NO_MATCH`; a tooling blocker is not a product defect; deferred evidence is not missing capability.

### KEEP

Domain-specific empty-state concepts such as `noRound` as planning input.

### REFACTOR

Separate technical failures from business states everywhere.

### REMOVE / REPLACE

Infinite spinner, silent fallback, raw internal error, or production mock presented as real content.

### ADD

Input preservation, retry/cancel, last-updated indicator, offline/stale disclosure.

### Privacy/data class

Errors must not expose peer private data, Safety state, raw private payloads, or backend internals.

### Dependencies

All domains.

### Classification

`MVP`

### Owner decision still required

Exact offline mutation support remains later technical design. MVP must not falsely claim a lifecycle-changing action succeeded offline.

## 16. Domain 14 — Public vs Private Content Classification

Adopt the following product-level classes:

| Class | Default audience | Primary purpose |
|---|---|---|
| `PUBLIC_EDITORIAL` | anyone | help/education |
| `ACCOUNT_PRIVATE` | user | account/settings |
| `PRIVATE_IDENTITY` | user + minimum authorized identity roles | identity/eligibility |
| `READINESS_RESTRICTED` | user + minimum readiness/verification capability | readiness |
| `MATCH_PURPOSE_LIMITED` | matching capability | candidate selection |
| `SHOWCASE_CANDIDATE_SCOPED` | explicitly eligible candidate audience | user expression |
| `CONNECTION_SCOPED` | active Connection participants | connection state |
| `CONVERSATION_SHARED_PRIVATE` | Conversation participants | private messaging |
| `RELATIONSHIP_SHARED_PRIVATE` | Relationship participants | shared support |
| `USER_PRIVATE_REFLECTION` | user only | private reflection |
| `AI_DERIVED_PRIVATE` | purpose-specific authorized audience | advisory AI output |
| `SAFETY_RESTRICTED` | authorized Safety roles | minimum necessary protection |
| `OPERATIONAL_MINIMUM` | necessary operational systems | reliable delivery |

Any class transition requires explicit definition of:

`FROM CLASS -> NEW AUDIENCE -> NEW PURPOSE -> PROVENANCE -> LIFECYCLE AUTHORITY -> CONSENT/OTHER AUTHORITY -> RETENTION CONSEQUENCE -> REVOCABILITY`

Fixed target rules:

- Private Identity does not automatically become Showcase;
- Conversation does not automatically become AI analysis input;
- Safety evidence does not flow to Compatibility/Ranking/public reputation;
- Matching Inputs do not automatically become public Profile;
- AI inference does not become verified user fact;
- Relationship state is not derived from chat frequency.

### Classification

Product-level data-class contract: `MVP`.

Exact retention periods/legal bases remain separate maturity-trigger work.

## 17. Domain 15 — Legacy Removal

### Established current concepts requiring a target decision

1. participant-linked legacy Match countdown/result/notification path — target `REPLACE / RETIRE` after bounded migration;
2. current top-level Match destination — target `REFACTOR` into Progress container while preserving Match as a distinct internal lifecycle;
3. current top-level Discover feed role — target `REPLACE` as an MVP top-level concept and reintroduce as secondary Explore/Support capability;
4. mixed Profile ownership — target `REFACTOR` into Private Identity, Matching Inputs, Readiness and Showcase.

### Target-incompatible patterns if later found

The target architecture does not migrate:

- automatic Match -> Connection;
- automatic Connection -> Conversation;
- Conversation activity -> inferred Relationship;
- romantic desirability/relationship-worth score;
- Safety-derived trust/reputation score;
- report/block-count ranking;
- AI guilt/truth/relationship verdict;
- private Conversation default training/ranking;
- default global-public Profile;
- silent production mock fallback;
- infinite engagement feed/streak/anxiety countdown;
- sensitive lock-screen content by default;
- personality/astrology/reference signals presented as objective truth.

If current existence is not evidenced, keep existence `UNKNOWN`; do not invent removal work.

## 18. Proposed capability map

```text
EliteSync
├─ Experience
│  ├─ Home / Calm State Hub
│  ├─ Progress
│  │  ├─ Match
│  │  ├─ Connection
│  │  └─ Relationship
│  ├─ Messages
│  │  └─ Conversation
│  ├─ Me
│  │  ├─ Showcase
│  │  ├─ Private Identity
│  │  ├─ Matching Inputs
│  │  ├─ Readiness
│  │  └─ Settings / Privacy
│  └─ Explore / Support Library (secondary; Phase 2 target)
├─ Lifecycle
│  ├─ Onboarding
│  ├─ Readiness
│  ├─ Match
│  ├─ Connection
│  ├─ Conversation
│  └─ Relationship
├─ Trust & Control
│  ├─ Consent
│  ├─ Audience / Visibility
│  ├─ Explainability
│  ├─ Correction / Contest
│  ├─ Pause / Revoke / Close
│  ├─ Export / Deletion
│  ├─ Notifications
│  └─ Block / Report
└─ Advisory Support
   ├─ Non-authoritative AI
   ├─ Private reflection
   ├─ Match explanation
   └─ Optional Relationship support
```

This is a product capability map, not a service/module/database decomposition.

## 19. Top-level information architecture

Target MVP:

`Home | Progress | Messages | Me`

- Home: lifecycle/status hub;
- Progress: navigation container for distinct Match, Connection, and Relationship states;
- Messages: Conversation;
- Me: Showcase, Private Identity, Matching Inputs, Readiness, Privacy/Settings;
- Explore: secondary Home entry, targeted for Phase 2.

## 20. End-to-end lifecycle

```text
ONBOARDING
  -> READINESS_INCOMPLETE
  -> READINESS_READY
  -> explicit Match opt-in
  -> MATCH_ENROLLED / SEARCHING
  -> MATCH_PROPOSAL
     -> decline/expire/withdraw -> READY
     -> both independently accept -> MUTUAL_MATCH
  -> separate Connection consent
  -> CONNECTION_PENDING
     -> decline/expire -> EXIT/READY
     -> both consent -> CONNECTION_ACTIVE
  -> optional separate messaging consent
  -> CONVERSATION_PENDING
     -> decline -> CONNECTION_ACTIVE
     -> both consent -> CONVERSATION_ACTIVE
  -> optional Relationship invitation
  -> RELATIONSHIP_PENDING
     -> decline -> CONVERSATION_ACTIVE
     -> both consent -> RELATIONSHIP_ACTIVE
  -> pause/end without collapsing downstream/upstream states

Block = independent protection control.
Report = separate concern submission.
Safety handling does not create ordinary guilt/Compatibility/reputation signals.
```

## 21. KEEP / REFACTOR / REPLACE / ADD / DEFER summary

| Domain | Primary target treatment |
|---|---|
| Home | `REFACTOR` around accepted reusable entry primitives |
| Discover | `REPLACE` top-level feed role; `ADD` Phase-2 Explore library |
| Match | `REFACTOR` canonical lifecycle; `REPLACE/RETIRE` legacy path |
| Connection | `ADD` explicit independent lifecycle |
| Conversation | `REFACTOR` around Connection + consent; `ADD` lifecycle controls |
| Relationship | `ADD` Phase-2 mutual support lifecycle |
| Profile | `REFACTOR` into four purpose boundaries |
| Readiness | `REFACTOR` into named checklist; `ADD` correction/expiry/review |
| Explainability | `ADD/REFACTOR` as standard product contract |
| Notifications | `REFACTOR` to domain-event/privacy-minimal model |
| Settings/Privacy | `ADD/REFACTOR` central + point-of-use controls |
| Onboarding | `REFACTOR` to progressive disclosure |
| UI state contract | `ADD/REFACTOR` common transport/domain vocabulary |
| Data classes | `ADD` explicit product classification/transition contract |
| Legacy | bounded migration/removal only for established or later-proven targets |

`DEFERRED != MISSING`, `UNKNOWN != ABSENT`, `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`, and `CURRENT SOURCE EXISTS != MUST KEEP` remain mandatory planning distinctions.

## 22. Roadmap phase candidate

### MVP

- `Home | Progress | Messages | Me` target shell;
- progressive onboarding;
- Private Identity / Matching Inputs / Readiness / Showcase split;
- minimum readiness contract;
- canonical Match lifecycle;
- explicit Connection lifecycle;
- basic Conversation lifecycle;
- no single Compatibility total score;
- minimum explainability contract;
- Privacy Control Center;
- privacy-minimal notifications;
- common empty/loading/error/offline/stale contract;
- product-level data-class contract;
- legacy Match migration/cutover design.

### Phase 2

- Explore / Support Library;
- mutual Relationship support;
- richer Connection controls;
- richer shared-content data-right workflows;
- advanced Showcase audience;
- explainable optional content personalization;
- richer notification controls;
- non-blocking legacy cleanup.

### Later / Optional

- AI private reflection;
- AI-assisted Relationship support;
- optional personality/reference signals;
- optional astrology/reference signals;
- counterfactual explanation;
- advanced offline behavior;
- broader public Showcase only if separately justified;
- evidence-backed personalization.

## 23. Retained decisions / unknowns before production maturity

The Owner has accepted the design direction above. The following remain intentionally unresolved rather than silently invented:

- launch segment and exact eligibility scope;
- exact minimum identity-assurance mechanism/level;
- exact Match proposal expiry duration and any future multi-candidate limit;
- exact Conversation/shared-content retention/export/deletion rights;
- region-specific data-right implementations and legal bases;
- exact Phase-2 Relationship tools;
- exact optional AI/personality/astrology signal allowlist and evidence standard.

These retained items do not reopen the old APP audit. They become bounded future product/privacy/legal/technical tasks when their maturity trigger is reached.

## 24. Implementation boundary

After Owner acceptance of this supplement, planning may proceed to an APP capability-gap and implementation-roadmap baseline. Code implementation must still occur through separately authorized bounded tasks.

No authority is created here for participant research, private Conversation inspection, telemetry/analytics/measurement, Safety Operations, new legal research, Sandbox/DEP13, B12, M2, or unrelated acquisition.

`ASTRA FEATURE-DESIGN SUPPLEMENT READY FOR OWNER REVIEW — FINAL ROADMAP NOT YET LOCKED`

Owner acceptance is recorded separately after review.