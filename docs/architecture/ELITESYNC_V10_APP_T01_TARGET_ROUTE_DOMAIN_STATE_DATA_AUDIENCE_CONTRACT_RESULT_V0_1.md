# EliteSync v10｜APP-T01 Target Route / Domain-State / Data-Audience Contract Result｜v0.1

Status: `CANDIDATE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-12 (Asia/Singapore).

Task base: `5585b6a6aede1de0779d02b381597dee1a982f26`.

Task blob: `8251996c46056596dd3169446737cb25c3640475`.

## 1. Result and authority boundary

APP-T01 establishes the target MVP product/architecture contract below. The target top-level information architecture is exactly:

`Home | Progress | Messages | Me`

The contract preserves the invariant:

`Match != Connection != Conversation != Relationship`

This artifact defines product meanings, route ownership, state authority, consent, audiences, data purposes, explanation and user controls. It does not define or authorize Flutter routes, state-machine code, APIs, databases, providers, services, modules, packages, persistence, migrations, runtime evidence, or implementation work. Existing source is neither adopted nor rejected here. Participant-linked legacy Match remains a retirement/migration target only after replacement and cutover evidence; it is not a second permanent canonical path.

## 2. Target route and ownership contract

| Top-level route | Purpose and owned child surfaces | Must not own or imply | Privacy-safe entry and guards |
|---|---|---|---|
| `Home` | Calm, low-density state hub. Owns a concise next-action/state summary, readiness prompt, Match/Connection/Conversation/Relationship status links, and privacy-safe public/editorial entry. | A feed, full Discover, lifecycle mutation by mere visit, global Profile, Compatibility score, or duplicate lifecycle UI. | Guest sees only public editorial/sign-in entry. Private summaries require the appropriate authenticated audience. A card links to the owning surface; it does not change its domain state. |
| `Progress` | Navigation container for distinct Readiness, Match, Connection and, in Phase 2, Relationship surfaces. Each child retains its own vocabulary and lifecycle authority. | Must not collapse Match, Connection, Conversation or Relationship into one funnel/status, and does not own message content. | Shows only children the viewer may access. Incomplete readiness receives a readiness route, not a fabricated Match state. Private child access is guarded before any content is revealed. |
| `Messages` | Owns Conversation list and thread entry, messaging consent prompts, and Conversation pause/close controls. | Does not establish Connection, infer Relationship, expose unrelated candidates, or turn message activity into lifecycle truth. | Requires the specific Connection/Conversation audience and valid Conversation gate. Locked/pending/paused/closed states reveal only privacy-minimal state and permitted controls, not message content to an unauthorized viewer. |
| `Me` | Owns account-private controls and the conceptual separation of Private Identity, Matching Inputs, Readiness, candidate-scoped Showcase, user-private reflection, settings/privacy, and notification controls. | No globally public MVP Profile; Me is not Discover, a candidate directory, or permission for unrestricted identity/showcase disclosure. | Authentication is required for private sections. Each section is audience-scoped. Showcase preview never implies global publication; candidate sharing remains scoped and revocable subject to established lifecycle authority. |

### 2.1 Child ownership and legacy treatment

| Surface | Owner | Contract |
|---|---|---|
| Readiness | `Progress` for status/action; `Me` for editing its underlying user-controlled inputs | Readiness gates Match participation but is not Match. Editing an input does not silently opt into Match. |
| Match | `Progress` | Canonical forward Match lifecycle with deliberate pacing; proposals are purpose-limited and never a single authoritative Compatibility total score. |
| Connection | `Progress` | A distinct mutual-consent lifecycle. A Match outcome may offer a Connection action but cannot create one automatically. |
| Relationship | `Progress`, Phase 2 only | Separate mutual opt-in support context. It is not inferred from duration, messages or Connection. |
| Conversation | `Messages` | Requires an ACTIVE Connection plus separate messaging consent. Connection alone is insufficient. |
| Private Identity / Matching Inputs / Showcase | `Me` | Separate conceptual surfaces and audiences; they are not one public Profile. |
| Discover / Explore | No MVP top-level route | Discover is removed from the MVP top-level IA. A Phase-2 `Explore/Support Library` may contain public editorial/support content; it is not a candidate feed and is not authorized for implementation here. |
| Legacy top-level Match/Profile | None in target IA | Match becomes a Progress child. Profile is split into Me-owned private/scoped concepts. Names in current source do not retain target ownership by inheritance. |

## 3. Domain-state registries

State identifiers are product-contract identifiers, not implementation enums. `System` may present or expire a state only where expressly allowed; transport/offline/error conditions are presentation conditions and never domain successors.

### 3.1 Onboarding

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `ONB_GUEST` | Public entry; no private account context asserted. | User authenticates/creates account under an approved mechanism; exact assurance is UNKNOWN. | `ONB_ACCOUNT_STARTED` | No | `PUBLIC_EDITORIAL` only; no private summary. | Explain why private routes require sign-in; allow leave/continue. |
| `ONB_ACCOUNT_STARTED` | Account context exists; required setup incomplete. | Account user supplies/corrects required account-private declarations. | `ONB_CORE_COMPLETE`, `ONB_CLOSED` | No | `ACCOUNT_PRIVATE`, and only deliberately supplied `PRIVATE_IDENTITY`. | Show remaining requirements and distinguish declaration from verification; allow correction/closure. |
| `ONB_CORE_COMPLETE` | Minimum onboarding contract completed; readiness remains separate. | User proceeds to Readiness or closes account. | `ONB_CLOSED` | No | Private Me/Home may open; Match still gated by Readiness and opt-in. | Explain completion does not mean ready, matched, connected or verified beyond established evidence. |
| `ONB_CLOSED` | User ended the account/onboarding context. | User under later recovery policy, if any; not defined here. | None in this contract | Yes | Private access ends; retention/deletion follows unresolved legal/data-right authority. | Explain closure effects and any retained UNKNOWN; provide applicable contest/export/delete entry when later decided. |

### 3.2 Readiness

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `RD_NOT_STARTED` | Readiness inputs have not been completed. | Account user starts readiness. | `RD_IN_PROGRESS` | No | No Match-purpose disclosure. | Explain purpose before collection; allow defer. |
| `RD_IN_PROGRESS` | Required readiness work is incomplete. | User supplies/corrects inputs; authorized rule evaluation may present result. | `RD_READY`, `RD_NEEDS_ACTION`, `RD_WITHDRAWN` | No | `READINESS_RESTRICTED`; no candidate audience. | Identify missing/actionable items without exposing sensitive detail elsewhere; allow edit/withdraw. |
| `RD_NEEDS_ACTION` | Current requirements are not met or need attention; not a moral or compatibility judgment. | User corrects/retries; authorized rule evaluation re-evaluates. | `RD_IN_PROGRESS`, `RD_READY`, `RD_WITHDRAWN` | No | Restricted result; must not become Safety or Compatibility evidence. | Explain basis, non-meaning and correction/contest path. |
| `RD_READY` | Current readiness contract is satisfied; Match participation is still off until opt-in. | User changes inputs/withdraws, or authorized rule evaluation detects relevant change. | `RD_IN_PROGRESS`, `RD_NEEDS_ACTION`, `RD_WITHDRAWN` | No | May enable Match opt-in; no automatic `MATCH_PURPOSE_LIMITED` disclosure. | Explain criteria used, limits, and separate Match control. |
| `RD_WITHDRAWN` | User withdrew readiness participation. | User explicitly restarts. | `RD_IN_PROGRESS` | No | Match entry is disabled; previously shared data follows its own authority. | Explain effects without claiming existing Connection/Conversation/Relationship automatically ends. |

### 3.3 Match

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `MT_NOT_OPTED_IN` | Eligible/ready user has not joined Match. | Ready user explicitly opts in. | `MT_ACTIVE` | No | No new candidate-scoped disclosure. | Explain Match purpose, pacing, inputs and revoke/pause controls before opt-in. |
| `MT_ACTIVE` | User is participating; no proposal is implied. | User pauses/withdraws; system presents a proposal using authorized inputs. | `MT_PAUSED`, `MT_PROPOSAL_PRESENTED`, `MT_WITHDRAWN` | No | `MATCH_PURPOSE_LIMITED` processing; candidate data only upon scoped proposal. | Explain inputs/categories used, uncertainty and absence of total truth score. |
| `MT_PAUSED` | New Match activity is paused. | User resumes or withdraws. | `MT_ACTIVE`, `MT_WITHDRAWN` | No | Stop new proposal activity; no automatic downstream closure. | Explain what pauses and what does not; allow resume/withdraw. |
| `MT_PROPOSAL_PRESENTED` | A bounded candidate proposal is available; not a Connection. | Each candidate independently responds; system may expire after an exact duration that remains UNKNOWN. | `MT_INTEREST_RECORDED`, `MT_DECLINED`, `MT_EXPIRED`, `MT_WITHDRAWN` | No | `SHOWCASE_CANDIDATE_SCOPED` only to named candidate audience. | Explain why presented, classes used, uncertainty, expiry authority, decline/withdraw controls. |
| `MT_INTEREST_RECORDED` | This user expressed interest; mutual interest and Connection are not yet established. | Other candidate independently responds; user may withdraw before mutual confirmation where policy permits. | `MT_MUTUAL_INTEREST`, `MT_DECLINED`, `MT_EXPIRED`, `MT_WITHDRAWN` | No | Interest visibility must follow candidate-scoped consent; never public. | Explain one-sided nature and that no Connection/Conversation/Relationship exists. |
| `MT_MUTUAL_INTEREST` | Both candidates expressed Match interest; Connection still requires its own mutual consent action. | Either user may initiate/answer separate Connection consent. | `MT_COMPLETED`, `MT_WITHDRAWN` | No | May make Connection-consent UI available; no automatic Connection record. | Explain separation and available next/stop controls. |
| `MT_DECLINED` | Proposal ended by a candidate decision; no adverse truth is implied. | Candidate unilateral decline. | None for this proposal | Yes | End proposal audience according to lifecycle authority; do not use as Safety fact. | Privacy-minimal result; no reason disclosure unless explicitly chosen and authorized. |
| `MT_EXPIRED` | Proposal ended by system expiry; not a rejection. | System expiry only under later fixed duration. | None for this proposal | Yes | Candidate-scoped access ends under expiry authority. | Explain expiry and non-meaning; allow return to active Match if otherwise valid. |
| `MT_COMPLETED` | This Match proposal reached its bounded end after mutual interest/next-step presentation. | System presentation only after the separate next-step choice. | None for this proposal | Yes | Preserve only purpose-authorized history; does not prove Connection exists. | Explain exact resulting state and what was not created. |
| `MT_WITHDRAWN` | User ended Match participation/proposal involvement. | User unilateral action. | None for affected participation/proposal | Yes | Stop new Match-purpose use/disclosure; downstream domains remain separately governed. | Explain scope and non-effects; provide later re-opt-in as a new authority event. |

### 3.4 Connection

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `CN_NONE` | No Connection consent process exists. | Either candidate initiates after an eligible Match context. | `CN_PENDING` | No | No `CONNECTION_SCOPED` audience. | Explain that Match/mutual interest is not Connection. |
| `CN_PENDING` | A separate Connection request awaits the other person's consent. | Recipient accepts/declines; requester withdraws; system may expire under later policy. | `CN_ACTIVE`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` | No | Minimal request data to the two candidates only. | Show actor/status, non-meaning, accept/decline/withdraw controls. |
| `CN_ACTIVE` | Both users consented to an active Connection. Messaging is still separately gated. | Either user pauses/closes; both may enter separate Conversation-consent flow. | `CN_PAUSED`, `CN_CLOSED` | No | `CONNECTION_SCOPED` audience begins; no message-content authority. | Explain mutual consent and independent Conversation/Relationship controls. |
| `CN_PAUSED` | Connection interaction is paused without asserting closure. | Pausing user resumes or either user closes. | `CN_ACTIVE`, `CN_CLOSED` | No | Restrict Connection entry as defined; do not rewrite Conversation/Relationship facts. | Explain initiator-visible effects and independent domain status. |
| `CN_DECLINED` | Request ended without mutual Connection consent. | Recipient unilateral decline. | None for request | Yes | Request audience ends under authority; no guilt/incompatibility inference. | Privacy-minimal outcome and non-meaning. |
| `CN_WITHDRAWN` | Requester withdrew before mutual consent. | Requester unilateral action. | None for request | Yes | Same bounded audience consequence as request closure. | Explain withdrawal and that no Connection was formed. |
| `CN_EXPIRED` | Request expired without a consent result. | System expiry under later policy. | None for request | Yes | Request access ends; not a decline. | Explain expiry/non-meaning. |
| `CN_CLOSED` | An active/paused Connection was closed. | Either connected user under disclosed unilateral authority. | None for this Connection | Yes | Stop new Connection-scoped use; Conversation/Relationship require separate, explicit handling and are not silently rewritten. | Explain scope, consequences and separate controls for other domains. |

### 3.5 Conversation

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `CV_LOCKED` | Messaging is unavailable because ACTIVE Connection plus separate consent is absent. | Both users enter Conversation consent only while Connection is active. | `CV_PENDING_CONSENT` | No | No thread content audience. | Explain exact missing gate without leaking private state. |
| `CV_PENDING_CONSENT` | One or both messaging consents are pending. | Each user independently consents/declines; initiator may withdraw. | `CV_ACTIVE`, `CV_LOCKED`, `CV_CLOSED` | No | Minimal consent state shared only with the two actors. | Explain that Connection is not messaging permission; allow accept/decline/withdraw. |
| `CV_ACTIVE` | Both users consented to private Conversation. | Either user pauses/closes/blocks; users create messages within audience contract. | `CV_PAUSED`, `CV_CLOSED` | No | `CONVERSATION_SHARED_PRIVATE`; not default training/ranking input. | Show privacy/audience, controls, retention UNKNOWN and block/report separation. |
| `CV_PAUSED` | New Conversation activity is paused; history and retention rights are separately governed. | Authorized user resumes or closes. | `CV_ACTIVE`, `CV_CLOSED` | No | Limit new activity; do not infer Connection/Relationship change. | Explain pause scope, visibility and resume/close options. |
| `CV_CLOSED` | Conversation lifecycle ended. | Either participant under disclosed authority; a block may also restrict access but is not a report. | None for this Conversation | Yes | New messages stop; exact retention/export/deletion remains UNKNOWN. | Explain closure, non-effects on Relationship/Connection, and available rights when decided. |

### 3.6 Relationship

| State | Visible meaning | Exit actor and authority | Allowed successors | Terminal | Data/audience consequence | Explanation and control |
|---|---|---|---|---|---|---|
| `RL_NOT_DECLARED` | No Relationship context exists, regardless of messages or time connected. | Either connected user initiates Phase-2 mutual opt-in. | `RL_PENDING` | No | No `RELATIONSHIP_SHARED_PRIVATE` processing. | Explain non-inference and Phase-2 nature. |
| `RL_PENDING` | A Relationship declaration awaits the other user's consent. | Other user accepts/declines; initiator withdraws. | `RL_ACTIVE`, `RL_NOT_DECLARED` | No | Minimal declaration state shared with the two actors. | Explain voluntary mutual opt-in and decline/withdraw controls. |
| `RL_ACTIVE` | Both users explicitly opted into the Phase-2 support context. | Either user pauses/ends; exact tools remain UNKNOWN. | `RL_PAUSED`, `RL_ENDED` | No | `RELATIONSHIP_SHARED_PRIVATE` only; no public status by default. | Explain purpose, tools actually enabled, limits and pause/end controls. |
| `RL_PAUSED` | Relationship support tools are paused without erasing the declaration history. | Authorized user resumes or either user ends. | `RL_ACTIVE`, `RL_ENDED` | No | Limit Phase-2 support use; no automatic Connection/Conversation mutation. | Explain pause scope and independent domains. |
| `RL_ENDED` | Relationship support context ended. | Either participant under disclosed unilateral authority. | None for this Relationship | Yes | Stop new Relationship-purpose use; retention rights remain separately governed. | Explain explicitly that Connection and Conversation do not automatically close. |

## 4. Allowed and invalid transition contract

### 4.1 Cross-domain allowed transitions/presentations

| Preconditions/current fact | Action and actor | Result | Consent/authority |
|---|---|---|---|
| `ONB_CORE_COMPLETE` | User enters Readiness | `RD_IN_PROGRESS` | Unilateral user action after purpose notice. |
| `RD_READY` + `MT_NOT_OPTED_IN` | User opts into Match | `MT_ACTIVE` | Explicit unilateral user consent; readiness alone is insufficient. |
| `MT_ACTIVE` | System presents an eligible bounded proposal | `MT_PROPOSAL_PRESENTED` | System presentation only, using authorized Match-purpose inputs; not a user-consent substitute. |
| Two independent interests | System presents mutual-interest fact | `MT_MUTUAL_INTEREST` | Two unilateral candidate actions; still no Connection. |
| Eligible Match context + `CN_NONE` | One candidate requests Connection | `CN_PENDING` | Unilateral request; no active Connection yet. |
| `CN_PENDING` | Other candidate accepts | `CN_ACTIVE` | Mutual Connection consent. |
| `CN_ACTIVE` + `CV_LOCKED` | Users independently grant messaging consent | `CV_PENDING_CONSENT` then `CV_ACTIVE` | ACTIVE Connection plus separate mutual Conversation consent. |
| `CN_ACTIVE` and Phase-2 entry allowed | One user initiates Relationship declaration; other accepts | `RL_PENDING` then `RL_ACTIVE` | Separate mutual Relationship opt-in. |
| Any pausable active state | Authorized user pauses/resumes | Corresponding `*_PAUSED` / active state | Disclosed unilateral authority; effects remain domain-local. |
| Proposal/request with established expiry | System expires it | Corresponding `*_EXPIRED` | System expiry only; exact Match proposal duration remains UNKNOWN. |
| User-owned participation/request | User withdraws/closes as specified in registry | Corresponding withdrawn/closed state | Explicit unilateral authority with domain-local effects. |

### 4.2 Invalid transitions and representations

| Invalid transition/representation | Required handling |
|---|---|
| Match proposal, interest or mutual interest -> automatic `CN_ACTIVE` | Prohibited. Present a separate Connection request/consent action. |
| `CN_ACTIVE` -> automatic `CV_ACTIVE` | Prohibited. Require separate mutual messaging consent. |
| Message count, content, duration or activity -> `RL_PENDING`/`RL_ACTIVE` or inferred Relationship | Prohibited. Relationship requires Phase-2 explicit mutual opt-in. |
| `RL_ENDED` -> automatic `CN_CLOSED` or `CV_CLOSED` | Prohibited. Show independent controls and preserve actual states. |
| `CN_CLOSED` -> silent rewrite of Conversation/Relationship | Prohibited. Apply only later explicit cross-domain guard/policy while preserving domain facts and explaining consequences. |
| Offline, timeout, HTTP/socket failure, app crash or local runner failure -> lifecycle decline/expiry/closure | Prohibited. Render a transport/error/offline condition separately and preserve last authoritative domain state. |
| `Block` -> `Report`, or `Report` -> `Finding`/guilt | Prohibited. Block is a user boundary; Report is an allegation/intake; Finding requires separate authorized Safety process. |
| AI output -> verified identity, truth, guilt, Safety fact, readiness fact or Relationship fact | Prohibited. Label as derived/advisory, with provenance and limits. |
| Safety evidence -> Compatibility evidence, or Compatibility evidence -> Safety evidence | Prohibited purpose crossing. |
| User declaration -> objective/verified truth | Prohibited unless a separately identified verification authority and provenance support only that bounded claim. |
| Private Conversation -> default training, ranking, Match or Compatibility input | Prohibited; a future exceptional use requires a new explicit purpose and consent/legal authority, not silence or bundled consent. |
| Any proposal -> single authoritative Compatibility total score | Prohibited. Use bounded, plural, explainable considerations and uncertainty. |

## 5. Data-class / audience / purpose contract

Every data use must carry four inseparable attributes: `Meaning + Provenance + Purpose + Lifecycle Authority`. A class label alone is insufficient authority.

| Data class | Meaning / default audience | Permitted purpose | Prohibited use or flow | User control / lifecycle authority / UNKNOWN |
|---|---|---|---|---|
| `PUBLIC_EDITORIAL` | Curated non-personal guidance; public/guest audience. | Home public entry and later Explore/Support Library. | Candidate profiling, implied endorsement, Safety/Compatibility evidence. | User may leave/dismiss; editorial owner controls lifecycle and provenance. |
| `ACCOUNT_PRIVATE` | Account preferences/status; account user and strictly necessary authorized operation. | Account, settings, privacy and route guards. | Public/candidate disclosure or Match ranking by default. | View/correct/close controls; exact regional retention rights UNKNOWN. |
| `PRIVATE_IDENTITY` | Identity declarations and bounded verification provenance; user and separately authorized assurance actor. | Account integrity and established eligibility/assurance only. | Global Profile, general Showcase, Compatibility, or claim that declarations are objective truth. | View/correct/contest; assurance mechanism/level and legal lifecycle UNKNOWN. |
| `READINESS_RESTRICTED` | Readiness inputs/results; user and narrowly authorized readiness evaluation. | Determine/present readiness and Match gate. | Candidate disclosure, Safety/Compatibility evidence, public Profile. | Edit/withdraw/retry/contest; criteria changes require explanation. |
| `MATCH_PURPOSE_LIMITED` | Authorized Match inputs/derived considerations; Match participant and bounded Match evaluation. | Deliberate proposal selection/presentation and explanation. | Other-purpose reuse, truth/guilt/Safety claims, total Compatibility score. | Opt in/pause/withdraw/correct; exact proposal expiry UNKNOWN. |
| `SHOWCASE_CANDIDATE_SCOPED` | User-approved candidate presentation; only specifically proposed candidate(s). | Understand a bounded proposal and decide interest. | Global publication, search/feed, onward sharing, identity overexposure. | Preview/correct/revoke subject to already-disclosed lifecycle; expiry follows proposal authority. |
| `CONNECTION_SCOPED` | Connection request/state and agreed shared details; the two candidates. | Request, consent and manage Connection. | Automatic messaging/Relationship authority, public disclosure, unrelated ranking. | Accept/decline/withdraw/pause/close; domain-local lifecycle. |
| `CONVERSATION_SHARED_PRIVATE` | Messages/shared content; Conversation participants only plus separately authorized Safety handling when invoked. | User-directed private communication. | Default AI training, Match/ranking, public/profile/showcase use, Relationship inference. | Send/pause/close/block/report and later export/delete rights; exact retention/export/deletion UNKNOWN. |
| `RELATIONSHIP_SHARED_PRIVATE` | Phase-2 mutual Relationship context; opted-in participants. | Explicitly enabled support tools. | Public relationship status, Compatibility/Safety inference, automatic Connection/Conversation control. | Opt in/pause/end; exact tools and retention authority UNKNOWN. |
| `USER_PRIVATE_REFLECTION` | User's private notes/reflections; that user only by default. | User-directed reflection/support. | Candidate/partner disclosure, ranking, Safety fact, training by default. | Create/edit/delete/export subject to later rights; no silent sharing. |
| `AI_DERIVED_PRIVATE` | AI-generated suggestion/summary with recorded input provenance; entitled user(s) only. | Advisory assistance within an explicitly invoked context. | Verified truth, guilt, diagnosis, identity verification, Safety finding, relationship authority or hidden ranking. | Label AI origin/limits; allow dismiss/correct/contest/delete where applicable; optional signal allowlist UNKNOWN. |
| `SAFETY_RESTRICTED` | Block/report evidence and authorized Safety handling; reporter/affected user only as appropriate plus authorized Safety actors. | User protection, report intake and separately governed review. | Compatibility/Match ranking, public accusation, automatic finding/guilt, general AI training. | Block and Report remain separate controls; retention/legal/appeal specifics require later authority. |
| `OPERATIONAL_MINIMUM` | Minimum non-content operational state necessary to provide/secure the product; user and necessary authorized operation. | Delivery, guard presentation, reliability/security at minimum scope. | Reconstructing private content, telemetry expansion, Compatibility/Safety inference, indefinite convenience retention. | Minimize, disclose relevant effects, correct operational errors; exact regional retention/legal basis UNKNOWN. |

## 6. Route-to-domain-to-data mapping

| Route / child surface | Domain and states consumed or changed | Read classes | Write classes | Consent/control entry | Explanation minimum |
|---|---|---|---|---|---|
| Home / public entry | Onboarding `ONB_GUEST`; no private mutation | `PUBLIC_EDITORIAL` | None | Sign-in/leave | Public nature; private features require guarded entry. |
| Home / private state hub | All domains, summary states only; no lifecycle change by visit | `ACCOUNT_PRIVATE`, state-minimal `READINESS_RESTRICTED`, `MATCH_PURPOSE_LIMITED`, `CONNECTION_SCOPED`, Conversation/Relationship status without content | User dismissal/preferences as `ACCOUNT_PRIVATE` only | Navigate to owner; notification/privacy preferences | What state is summarized, source time, non-meaning and owning control. |
| Progress / Readiness | Readiness registry | `READINESS_RESTRICTED`, relevant `ACCOUNT_PRIVATE` | `READINESS_RESTRICTED` | Start/edit/withdraw/retry/contest | Criteria/basis, data classes, readiness non-meaning, correction path. |
| Progress / Match | Match registry | `MATCH_PURPOSE_LIMITED`, `SHOWCASE_CANDIDATE_SCOPED`, minimum `READINESS_RESTRICTED` gate | Match choices in `MATCH_PURPOSE_LIMITED` | Opt in/pause/withdraw/interest/decline | Proposal basis, provenance categories, uncertainty, no total score, no Connection implication. |
| Progress / Connection | Connection registry | `CONNECTION_SCOPED`, minimal originating Match context | `CONNECTION_SCOPED` | Request/accept/decline/withdraw/pause/close | Actor/consent state and separation from Match, Conversation, Relationship. |
| Progress / Relationship (Phase 2) | Relationship registry | `RELATIONSHIP_SHARED_PRIVATE`, minimum Connection eligibility | `RELATIONSHIP_SHARED_PRIVATE` | Initiate/accept/decline/pause/end | Mutual authority, enabled purpose/tools, independent downstream effects. |
| Messages / list | Conversation registry; minimal Connection gate | State-minimal `CONVERSATION_SHARED_PRIVATE`, `CONNECTION_SCOPED` | Conversation consent/control state | Consent/pause/close/block/report | Why locked/pending/active, privacy audience, non-inference. |
| Messages / thread | `CV_ACTIVE`/paused/closed presentation | `CONVERSATION_SHARED_PRIVATE`, explicitly invoked `AI_DERIVED_PRIVATE` | `CONVERSATION_SHARED_PRIVATE`; Block or Report into distinct `SAFETY_RESTRICTED` records | Send/pause/close/block/report; AI invoke/dismiss | Audience, retention UNKNOWN, AI provenance/limits, Block/Report separation. |
| Me / account & settings | Onboarding/account; notification/privacy preferences | `ACCOUNT_PRIVATE`, `OPERATIONAL_MINIMUM` | `ACCOUNT_PRIVATE` | Correct/close/preferences | Effect, scope, reversibility and unresolved rights. |
| Me / Private Identity | Onboarding/eligibility support, not Profile | `PRIVATE_IDENTITY` | `PRIVATE_IDENTITY` | Supply/correct/contest | Declaration vs verified bounded claim; provenance and assurance UNKNOWN. |
| Me / Matching Inputs & Readiness | Readiness and Match configuration, without opt-in by edit | `READINESS_RESTRICTED`, `MATCH_PURPOSE_LIMITED` | Same classes | Edit/correct/withdraw; separate Match opt-in | Purpose separation and effects of changes. |
| Me / Showcase preview | Candidate-scoped presentation configuration | `SHOWCASE_CANDIDATE_SCOPED`, selected user-origin classes | `SHOWCASE_CANDIDATE_SCOPED` | Preview/correct/revoke | Exact candidate audience; never globally public. |
| Me / private reflection & AI | User-directed reflection/advice | `USER_PRIVATE_REFLECTION`, `AI_DERIVED_PRIVATE` | Same classes | Create/edit/delete/invoke/dismiss/contest | AI origin, input classes, uncertainty and no truth authority. |
| Later Explore/Support Library | Public editorial context only in this contract | `PUBLIC_EDITORIAL` | None by end user here | Leave/dismiss | Editorial provenance and no candidate-feed implication. |

## 7. Minimum explainability and user-control contract

Before or at every lifecycle-affecting action/result, the owning surface must present a context-appropriate explanation containing:

1. **What happened:** authoritative domain, prior state, new state, effective scope and time.
2. **Why:** initiating actor category and applicable declared/rule/consent/expiry basis, without exposing another person's private reason.
3. **Information classes used:** class names in understandable language, provenance category, purpose, and audience—not raw sensitive data unless the viewer is entitled.
4. **What it does not mean:** explicitly separate readiness, Match, Connection, Conversation, Relationship, Safety, verification and AI inference where confusion is plausible.
5. **Uncertainty and limits:** proposal/advice limitations, missing information, expiry, and any retained UNKNOWN. MVP has **no single authoritative Compatibility total score**.
6. **User controls:** only controls actually authorized for that state—change/correct, revoke/withdraw, pause/resume, retry, decline, contest, close, block, report, export/delete when later established—and material non-effects on other domains.

Notifications are privacy-minimal by default: lock-screen presentation must not expose identity, proposal, message, Relationship, Safety, or sensitive state detail. A notification is a prompt to a guarded route, not lifecycle authority. AI remains advisory; its visible output must identify AI provenance and cannot become verified truth, guilt, Safety, readiness, Match, Connection or Relationship authority.

## 8. Guard and entry contract

| Entry condition | Permitted entry | Guarded/redirect behavior | Must not infer |
|---|---|---|---|
| Unauthenticated / guest | Public Home editorial/sign-in entry | Private route attempts return privacy-safe authentication entry without confirming private resource existence. | Account, eligibility, identity or private states. |
| Authenticated, onboarding incomplete | Me setup and public Home; bounded setup summary | Progress/Message private children redirect to required setup without revealing candidate/participant data. | Readiness or Match status. |
| Readiness incomplete / needs action / withdrawn | Readiness child and own Me inputs | Match opt-in/proposals guarded to readiness explanation/control. Existing separately authorized domains are not silently erased. | Incompatibility, Safety concern or permanent ineligibility. |
| `RD_READY` + `MT_NOT_OPTED_IN` | Match explanation/opt-in entry | No candidate proposal or Match-purpose use before opt-in. | Match participation or consent. |
| `MT_ACTIVE` | Match status and authorized proposals | Candidate Showcase only for a live, scoped proposal and entitled viewer. | Connection, messaging or Relationship. |
| Connection pending | Connection consent surface | Messages remains locked; expose only privacy-minimal request state. | Mutual consent. |
| Connection active | Connection controls; Conversation consent entry | Message content remains locked until separate mutual Conversation consent. | Messaging permission or Relationship. |
| Connection paused/closed | Domain-local state/control | Do not rewrite Conversation/Relationship state; apply any later explicit access policy transparently. | Other-domain closure. |
| Conversation locked/pending | Consent/gate explanation only | No thread content. | Active messaging consent. |
| Conversation active | Entitled thread/list and controls | Participant-only content; block/report are distinct. | Relationship or public sharing. |
| Conversation paused/closed | State, permitted history and controls under later rights | No new messages; exact retained-content access follows unresolved policy. | Connection/Relationship change. |
| Relationship not declared/pending | Phase-2 explanation/consent only | No Relationship tools or public status. | Relationship from behavior. |
| Relationship active/paused/ended | Entitled Phase-2 state/tools according to state | Audience remains participants; ending does not auto-close Connection/Conversation. | Public relationship status or other-domain outcome. |

The exact authentication and minimum identity-assurance mechanisms are intentionally not selected by this contract.

## 9. Retained UNKNOWN and Owner-decision blocker map

`UNKNOWN != ABSENT` and `DEFERRED != MISSING`. Work listed as permitted may use synthetic states and this contract but must not silently choose the unknown value.

| Retained UNKNOWN | Blocks later work | Work allowed meanwhile |
|---|---|---|
| Launch segment / exact eligibility | Final launch eligibility rules, production rollout gate, segment-specific onboarding/readiness acceptance. | Route/state contracts, synthetic UI states, source locator inventory and non-segment-specific architecture planning. |
| Minimum identity-assurance mechanism and level | Identity verification implementation, assurance-dependent eligibility and production guard acceptance. | Preserve `PRIVATE_IDENTITY` boundary, declaration/provenance UI contract and synthetic guard states. |
| Exact Match proposal expiry duration | Production expiry configuration, copy, timers and expiry acceptance cases. | Model `MT_EXPIRED`, expiry authority and synthetic duration-independent behavior. |
| Exact Conversation/shared-content retention, export and deletion rights | Persistence lifecycle, user-rights implementation, production Conversation close/delete/export acceptance. | Preserve private class/purpose boundaries, model controls as pending policy, locate current source seams in APP-T02 without reading participant data. |
| Region-specific legal/data-right implementation | Region launch, legal basis/notice/rights implementation and production data-lifecycle lock. | Maintain minimization, audience/purpose/provenance fields and region-neutral synthetic architecture contracts; no new legal research. |
| Exact Phase-2 Relationship tools | Relationship feature scope, detailed UX and implementation roadmap. | Preserve Phase-2 mutual opt-in lifecycle and isolation from Connection/Conversation; MVP proceeds without the tools. |
| Optional AI/personality/astrology/reference-signal allowlist | Any production use, weighting, claims or UI for those optional signals. | Exclude by default; retain advisory/provenance/consent constraints and design with no dependency on them. |

## 10. Safety, privacy and meaning invariants

- `Match != Connection != Conversation != Relationship`.
- Match must not auto-create Connection.
- Connection must not auto-authorize Conversation.
- Conversation activity must not infer Relationship.
- Relationship ending must not automatically close Connection or Conversation.
- `Block != Report`; `Report != Finding`.
- AI output is not verified truth, guilt, Safety, identity, readiness or relationship authority.
- Safety evidence is not Compatibility evidence, and the reverse is also prohibited.
- A user declaration is not objective truth; provenance must identify declaration versus bounded verification.
- Private Conversation is not default training, ranking or Match data.
- There is no single authoritative Compatibility total score.
- There is no globally public MVP Profile.
- Transport, offline, error, timeout, app failure and local tooling failure are not domain lifecycle facts. In particular, the retained Match runner teardown/exit blocker is not a product defect and creates no lifecycle evidence.

## 11. Bounded APP-T02 handoff

The only next task specified by APP-T01 is:

`APP-T02 — CURRENT-TO-TARGET SOURCE LOCATOR / MIGRATION INVENTORY`

Subject to a fresh task sheet, authority and read scope, APP-T02 may locate—without implementing—the current source ownership and migration seams for:

- top-level and child route ownership relative to `Home | Progress | Messages | Me`;
- current Profile coupling relative to Private Identity, Matching Inputs, Readiness and candidate-scoped Showcase;
- canonical Match consumers and participant-linked legacy Match retirement seams;
- Connection and separate Conversation consent/gate representations;
- Relationship references, only to classify target Phase-2 boundaries;
- current uses that cross the data-class, audience, purpose or explanation contract.

APP-T02 must preserve `CURRENT SOURCE EXISTS != MUST KEEP`, `DEFERRED != MISSING`, `UNKNOWN != ABSENT`, and `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`. It must not inspect populated private participant/Profile/Conversation data, perform migration, implement routes/states, choose APIs/databases/services/providers/modules, resolve the retained UNKNOWNs, or treat this candidate as accepted before independent acceptance and Owner authority.

APP-T01 does not start APP-T02 and publishes no final implementation roadmap.

## 12. Classification

`APP-T01 TARGET CONTRACT ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`

This is a candidate classification only. The author does not self-accept it; independent acceptance and any later Owner authorization remain separate gates.
