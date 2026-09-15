# EliteSync v10｜Backend Calm Home Live Read Model Technical Design｜v0.1

Status: `TECHNICAL-DESIGN CANDIDATE — READ-ONLY MULTI-DOMAIN COMPOSITION DEFINED — INDEPENDENT REVIEW REQUIRED — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit: `d94f3b031daa500addbd1d81054a8bb0ed8b8ce1`

Task blob: `d47ac0eb3566a21fdb2e5e4d8f91f4cc98fcf24d`

## 1. Result, purpose, and authority boundary

This candidate defines Calm Home as a privacy-minimal, read-only composition over independently authoritative Runtime Readiness, canonical Match, Product Connection, and Product Conversation live-access evidence. Home answers three calm questions—current state, next decision, and optional support—without becoming a lifecycle, consent, access, ranking, Safety, notification, or mutation authority.

Home owns exactly zero lifecycle writers. It cannot author, correct, revoke, supersede, merge, rank, strengthen, repair, or execute any source-domain fact. Each source retains its own authority owner, subject/participants, audience, purpose, lineage, revision/currentness, freshness, correction/revocation semantics, and failure condition. The composition creates no global revision or global transaction.

This document selects no endpoint, API, wire format, schema, table, key, index, persistence, transaction, cache, service, queue, clock, deployment, authentication, refresh, retry, Flutter, or client mechanism. It uses no production/private data and authorizes no backend implementation.

## 2. Fixed accepted authority chain

All source objects were resolved at fixed `origin/main` commit `d94f3b031daa500addbd1d81054a8bb0ed8b8ce1`.

| Key | Accepted authority | Fixed provenance and bounded use |
|---|---|---|
| S1 | BA-01 Common Authority Evidence Envelope acceptance/design | acceptance blob `565e425aa3550bb64a82c70ff08a107a896669a3`; accepted design blob `c448662bee3f452eb535f298c76388e5565717a4`; supplies composition, binding, revision/freshness, correction/revocation, and permitted-action rules. |
| S2 | BA-02 Runtime Readiness acceptance/design | acceptance blob `0757c322e17436d9d4c007a1ebda3ac3d38fc917`; accepted design blob `372c6b5f3d65bdb9dc19c9af33801484768c7f1a`; supplies scope-specific effective readiness and authenticated-subject projection. |
| S3 | BA-03 Canonical Match acceptance/design | acceptance blob `ae5b6ecec72bedfb501ec09c5c9a9aa75f5be8c8`; accepted design blob `7de2c0e8aa568ff80d87dca941fa3e55a009c178`; supplies the participant-authorized Match projection and actor-action boundary. |
| S4 | BA-04 Product Connection acceptance/design | acceptance blob `d3b6cf099009d44302925e98f9ab8dfb70a19f2f`; accepted design blob `e93ab283efb6b05aa7fbc1487536c174a7280a8e`; supplies participant-authorized current Connection projection. |
| S5 | BA-05 Messaging Consent + Conversation Live Gate acceptance/design | acceptance blob `a133285b0a1923d5d2965ced989d1c8b1dbf8e49`; accepted design blob `d35909ede0bb8c0f8891581ce69c50d7758d914d`; supplies separate live-read/live-send decisions and fail-closed private-data boundary. |
| S6 | Backend Authority / Read-Model Planning Contract | blob `a97f97eafb09b18c604cd5785887a25db08c819d`; B01-E fixes Calm Home as read-only, three-section, at-most-one-primary composition. |
| S7 | Backend Authority Implementation-Planning Decomposition | blob `a8404b3066680f37e9ff94bcfd705ed414cb8d07`; BA-06 fixes the source, minimization, partial-projection, and non-goal boundary. |
| S8 | Owner-accepted APP Feature Design | acceptance blob `063dc18309afdc8f477cc9b22a29da1842776556`; accepted design blob `b72ed9ec851d44aba7be65883186cb275fab22d1`; fixes the low-density Calm State Hub and privacy/non-pressure principles. |

All required accepted provenance exists and is consistent for this task. The Owner-accepted design's earlier broad Home examples do not add Relationship as an input here: this task and accepted B01-E explicitly bound BA-06 to Readiness, Match, Product Connection, and Conversation live-access evidence only.

## 3. Evidence vocabulary and conjunctive admission gate

| Term | Home meaning |
|---|---|
| Source evidence | A domain-owned read projection or live-grant decision carrying verifiable authority provenance and exact bindings. |
| Current | The source owner establishes the controlling same-lineage revision and all required bindings/freshness pass for the Home use. |
| Stale | The evidence fails or cannot establish its source-owned usable-freshness condition; it is not necessarily superseded. |
| Superseded | The source owner establishes a newer controlling revision in the same scope; the older item cannot guide a protected action. |
| Unknown | The required fact, provenance, comparison, or currentness is not established. `UNKNOWN != ABSENT`. |
| Unavailable | The source cannot currently answer. It is an authority-access condition, not a lifecycle outcome. |
| Incomparable | The source cannot establish a valid same-lineage ordering; receipt order cannot resolve it. |
| Projection lag | A delivery/projection condition where a newer authoritative revision is known but its permitted projection details are not yet available. |
| Display-valid | The source explicitly permits the minimum fact to be displayed to this viewer/purpose under its display freshness rule. |
| Action-guidance-valid | The source's actor-relevant permitted-action evidence is current, fresh, correctly bound, and eligible to be considered as a Home candidate; the source writer must still revalidate. |

An item is admitted only when source owner/provenance, claim class, source-domain identity, subject or exact participant set, audience, Home purpose, actor/role where applicable, source lineage/revision/currentness, and the source's usable-freshness rule all conjunctively pass for the intended display or guidance use.

A valid input never repairs, orders, refreshes, or substitutes for an invalid input. Evidence from different owners remains incomparable as revision order. Home retains each input's condition and cannot synthesize `current` from “latest received.”

## 4. Home-owned semantic envelope

Each returned item must make the following semantic fields evaluable without prescribing a representation:

| Obligation | Required meaning | Forbidden inference |
|---|---|---|
| Section | Exactly `Current state`, `Next decision`, or `Optional support`. | Section position is not urgency, severity, lifecycle, or authority. |
| Source domain | Exactly Readiness, Match, Product Connection, or Conversation live-access gate. | No generic relationship/global-status owner. |
| Source evidence class | Domain projection, grant decision, authority condition, or projection-lag observation kept distinct. | Transport/projection observation cannot become an outcome. |
| Binding | Exact viewer/subject or participant set, audience, purpose, and actor role where needed. | Identity, route, or possession is not consent/audience. |
| Source lineage/revision | The source-owned scope and controlling relation. | No cross-domain comparison or global revision. |
| Currentness/freshness | Independently evaluated for the exact Home display or action-guidance use. | Display-valid does not imply action-valid. |
| Label/descriptor | Minimum source-faithful, non-adverse, non-coercive meaning. | No person worth, Safety meaning, total score, or inferred Relationship. |
| Navigation target | Included only when separately audience/purpose authorized by its owner. | Navigation is neither access nor mutation authority. |
| Permitted action | Descriptive actor/context/revision/freshness-bound source evidence only. | Not a token, reservation, execution, or successful outcome. |
| Condition | Exact source-local unknown/unavailable/stale/superseded/incomparable/lag state when necessary. | No conversion to absent, declined, expired, failed, or global outage. |

Home requests and returns only this minimum envelope. It does not request hidden fields merely to discard them later.

## 5. Three-section projection contract

### 5.1 Current state

Current state presents a small set of independently sourced, privacy-minimal facts that help the viewer understand where the accepted domains currently stand. It may show one minimum item per valid/representable source; it never merges vocabularies into one journey status.

Required per item: source domain, source evidence class, exact viewer/subject or participant binding, Home audience/purpose, source lineage/revision/currentness/freshness, privacy-minimal source-faithful label, and source-local condition when current fact cannot safely be shown.

Navigation may be included only if separately authorized and must re-check the destination's own access gate. No permitted action is implied by a state label. A historical/coarse fact may appear only when the source explicitly authorizes that exact display despite action guidance being invalid; it must be marked non-actionable and cannot participate in primary selection.

### 5.2 Next decision

Next decision contains only actor-relevant source-authorized candidate actions or authorized navigation to the owning decision surface. Each candidate retains source domain, exact actor/role and context, audience/purpose, source revision/currentness/freshness, the minimum decision label, and an explicit statement that the owning authority revalidates the action.

Home neither executes nor queues the action. It does not infer that an absent action means completion, terminal state, rejection, or no need. Unknown, unavailable, stale, superseded, incomparable, mismatched, or lagged action evidence is omitted from action candidates; a source-local condition may be shown separately when privacy-authorized.

### 5.3 Optional support

Optional support is genuinely optional, non-blocking, non-urgent assistance tied to an accepted source-domain need or already-authorized public/account-private support destination. It must retain source/domain category, Home audience/purpose, minimal label, and separately authorized navigation where present.

Optional support cannot be filled using private or remote enrichment. It cannot use Conversation content, peer previews, Match raw inputs, candidate-irrelevant Showcase, hidden Safety evidence, public-profile enrichment, analytics, training/ranking signals, or unaccepted AI signals. If no authorized support item exists, the section is absent/quiet; empty space is not a failure.

## 6. Source-by-source composition matrix

| Source/evidence condition | Home may show | Home must omit | Primary-action candidate? |
|---|---|---|---:|
| Current scope-specific Readiness conclusion and inputs | Coarse effective-readiness label, exact protected-use scope, source condition, and separately authorized next step | Raw verification/checklist evidence not needed for Home; launch/global identity claims | Yes, only a current actor-relevant source action |
| Readiness valid for display but not action guidance | Minimum coarse state with non-actionable/source-local condition | Action, unlock, implied `READY`, inferred missing prerequisite | No |
| Current Match participation | Privacy-minimal participant-owned state and actor-relevant source action | Candidate identity/details when no authorized current proposal; total score; raw inputs | Yes, only current descriptive action |
| Current Match proposal | Minimum viewer-authorized proposal state/own decision meaning and current action | Other participant's private reason/decision detail; raw Showcase; inferred Connection | Yes, only current own-role action |
| Current Product Connection | Minimum exact CN state, viewer role, aggregate distinction, and source action | Other participant's private reason; inferred messaging/Conversation/Relationship authority | Yes, only current own-role action |
| Conversation live-read grant | Coarse `available/not currently established` live-read decision when useful | Messages, previews, drafts, unread private detail, participant content | Navigation only when separately authorized; grant itself is not an action |
| Conversation live-send grant | Separate coarse send decision and source-authorized control/navigation | Read implication, drafts, content, optimistic send action | Yes only for a separately source-authorized actor action; send revalidates at boundary |
| Minimum messaging-consent evidence needed to explain gate | Coarse consent-gate reason/category already authorized for the viewer | Consent request details beyond minimum, historical consent, another participant's private reason | Yes only when BA-05 exposes a current actor-relevant consent action |
| Source unavailable | Source-local unavailable descriptor if audience-authorized | Lifecycle outcome, stale detail not separately displayable, action | No |
| Source stale | Source-local stale descriptor; historical/coarse fact only if separately display-valid | Current claim, mutation guidance, inferred newer result | No |
| Source superseded | Newer valid evidence if available; otherwise source-local updating condition | Superseded fact as current; old permitted action | No for superseded item |
| Source unknown/not established | Source-local unknown/omission according to privacy contract | Absence, negative state, failure, action | No |
| Source projection lag | Updating/lag condition without fabricated details | Rollback, older action, invented new payload | No for lagged item |
| Subject mismatch | Nothing from that evidence | State, identity confirmation, navigation, action | No |
| Participant mismatch | Nothing from that evidence | Peer/aggregate facts, consent, state, action | No |
| Audience mismatch | Nothing protected | Existence confirmation, label, navigation, action | No |
| Purpose mismatch | Nothing for Home use | Reused Match/training/advertising/Safety meaning | No |
| Incomparable revisions | Source-local unable-to-establish-currentness condition | Last-received winner, action, rollback | No |
| Transport refresh success only | Refresh observation if needed and privacy-safe | Source mutation success or new lifecycle state | No |
| Displayable historical/coarse fact | Exact minimum source-authorized historical/coarse descriptor, marked non-actionable | Currentness, permitted action, cross-domain inference | No |

## 7. Deterministic at-most-one primary-action rule

Primary selection is presentation filtering, never a cross-domain lifecycle, recommendation, urgency, severity, or ranking authority.

1. Build candidates only from currently source-authorized, actor-relevant permitted-action evidence admitted under section 3.
2. Remove every candidate with invalid provenance, binding, currentness, freshness, mismatch, correction/revocation, supersession, incomparability, unavailability, unknown, or known projection lag.
3. Remove candidates whose label, navigation, or requested display would exceed the source-authorized Home audience/purpose or privacy minimum.
4. If zero candidates remain, return no primary action.
5. If exactly one remains, it may be the sole primary action, still descriptive and subject to writer revalidation.
6. If multiple remain, select one only when separate accepted product authority establishes a unique Home presentation precedence applicable to those exact candidates. Otherwise return no primary action; candidates may remain privacy-minimal non-primary next-decision summaries only where the low-density contract permits.
7. Never break a tie with timestamps across domains, revision numbers, source arrival order, private content, unread/activity counts, countdowns, Compatibility totals/factors, Safety evidence, predicted engagement, model output, inferred desirability, or person worth.

No currently accepted source supplies a general cross-domain urgency or precedence ranking. Therefore the deterministic current result for an unresolved multi-candidate tie is no primary action. This is a fail-closed presentation result, not a missing lifecycle outcome or global product failure.

## 8. Independent refresh, correction, and revocation propagation

| Event | Required Home reaction | Forbidden reaction |
|---|---|---|
| One source publishes newer valid evidence | Replace only that source item's controlling input after owner/currentness/binding/freshness pass; recompute affected display and candidate selection. | Rewrite other domains or create a global revision. |
| One source becomes stale | Remove its action candidacy immediately; retain only source-authorized stale/coarse display or condition. | Infer negative outcome or let another source repair it. |
| One source becomes unavailable | Mark/omit only that source; recompute from remaining valid inputs. | Collapse all Home to failure or retain protected action. |
| Correction changes a shown fact | Propagate the newer same-lineage corrected scope; remove/replace dependent label/action. | Locally edit source meaning or erase unrelated history. |
| Revocation removes a grant/action | Remove the dependent Home action/navigation as soon as newer authoritative revocation is established. | Continue from cache or infer history deletion/peer effect. |
| Projection lags a known newer revision | Do not show older item/action as current; show only permitted updating condition. | Roll back to older projection or fabricate details. |
| Two domains update independently | Evaluate each in its own lineage and recompute composition without ordering them. | Synthesize cross-domain atomic commit or “latest global state.” |
| Refresh transport succeeds | Record no source-domain outcome unless newer authoritative evidence is independently established. | Treat HTTP/transport success as lifecycle success. |
| Older delivery follows newer evidence | Ignore it for current/action use; preserve only separately authorized history. | Last-arrival-wins rollback. |
| Revision comparison is unknown/incomparable | Fail closed for that source's action guidance and show/omit source condition as authorized. | Compare visual counters/timestamps across owners. |

Home does not promise synchronized snapshots across domains. It does promise that every displayed/action-guiding item identifies its independent source evidence condition and that no known newer evidence is rolled back.

## 9. Empty and partial composition semantics

| Input shape | Required result |
|---|---|
| All sources valid | Compose privacy-minimal independent items; run the at-most-one rule; do not merge revisions or lifecycles. |
| Only one source valid | Show only its authorized minimum and possibly its sole valid action; absence of other sources is not repaired or inferred. |
| Several valid, several unavailable | Show valid items plus only authorized source-local unavailable conditions; no global failure. |
| All sources unavailable | Show a calm global presentation that source evidence cannot currently be obtained, without claiming domain failure/absence; no primary action. |
| All facts unknown/not established | Show/omit according to privacy-safe unknown semantics; no lifecycle inference, navigation grant, or primary action. |
| No actor-relevant action | Home is genuinely quiet; no fabricated CTA, urgency, or support filler. |
| Display-valid but action-invalid | Show only the authorized non-actionable coarse fact/condition; exclude it from primary selection. |
| Historical/coarse display authorized | Clearly retain historical/non-current scope; never present it as current permission or action guidance. |
| One source mismatch | Omit that evidence while independently evaluating unaffected sources. |
| Valid live-read but invalid live-send | Show read and send separately; never infer send from read or collapse both into “Conversation active.” |
| Invalid live-read but apparently valid live-send | Fail closed for protected Conversation construction/read; do not expose content; send remains separately evaluated and cannot grant read. |
| Multiple valid actions without accepted precedence | No primary action; only separately authorized non-primary summaries may remain. |

Partial composition is normal evidence shape, not a global outage, product failure, user fault, Safety signal, or invitation to enrich from private/legacy sources.

## 10. Privacy-minimal source and response allowlist

Home may consume only:

- Readiness: authenticated subject, exact protected-use scope, coarse effective-readiness conclusion/condition, independent source revision/freshness, and minimum actor-relevant action;
- Match: viewer binding, participation/proposal identity and privacy-minimal state, minimum own-role decision meaning, independent revision/freshness, and minimum actor-relevant action;
- Product Connection: viewer/participant/role binding, current aggregate distinction, privacy-minimal CN state, independent revision/freshness, and minimum actor-relevant action;
- Conversation live gate: separate coarse live-read and live-send grant decisions, their independently retained Connection and Messaging Consent evidence conditions, and only minimum actor-relevant gate action/navigation already authorized.

Home must neither request nor return:

- private Conversation message text, attachments, previews, drafts, realtime content, peer-private details, or unread private details;
- Compatibility total scores, hidden rankings, raw Match inputs, or candidate-irrelevant Showcase data;
- hidden Safety evidence, moderation evidence, allegations, reports, findings, restrictions, reputation, or person-worth signals;
- globally public Profile enrichment, private Identity detail, or peer identity by default on a glanceable surface;
- analytics, telemetry, activity/engagement counts, advertising signals, model-training inputs, predicted behavior, or unaccepted AI/personality/astrology/reference signals;
- Relationship state or inferred relationship meaning; or
- notification payload identity, route, cache, legacy DTO, local state, or transport outcome as source authority.

When a source exposes only a coarse grant or condition, Home consumes only that coarse evidence. Technical possession of richer data is irrelevant and creates no audience or purpose authority.

## 11. Cross-domain truth preservation

- `Match != Connection != Conversation != Relationship`.
- `UNKNOWN != ABSENT`.
- `STATE VOCABULARY != AUTHORITY`.
- `ROUTE IDENTITY != CONSENT`.
- `TRANSPORT FAILURE != DOMAIN OUTCOME`.
- `LIVE READ GRANT != LIVE SEND GRANT`.
- `HOME COMPOSITION != NEW LIFECYCLE`.
- `PRIMARY-ACTION SELECTION != CROSS-DOMAIN RANKING AUTHORITY`.
- `DISPLAY-VALID != ACTION-GUIDANCE-VALID`.
- `ONE VALID SOURCE != REPAIR OF ANOTHER SOURCE`.

Match does not imply Product Connection. Product Connection does not imply Messaging Consent or Conversation access. Conversation activity/access does not imply Relationship. Home presentation, navigation, labels, or source identifiers create none of those facts.

## 12. High-density validation matrix

Each of the following 153 rows is independently checkable and has exactly one disposition.

| ID | Family | Independently checkable assertion | Disposition |
|---:|---|---|---|
| A01 | Authority/no-writer | Home owns zero Readiness lifecycle writers. | `PASS` |
| A02 | Authority/no-writer | Home owns zero Match lifecycle writers. | `PASS` |
| A03 | Authority/no-writer | Home owns zero Product Connection lifecycle writers. | `PASS` |
| A04 | Authority/no-writer | Home owns zero Messaging Consent or Conversation lifecycle writers. | `PASS` |
| A05 | Authority/no-writer | Home cannot correct, revoke, supersede, execute, or repair a source-domain fact. | `PASS` |
| A06 | Authority/no-writer | Home composition creates no global lifecycle, revision, transaction, or permission token. | `PASS` |
| B07 | Binding | Every Readiness item binds the authenticated subject and exact protected-use purpose. | `PASS` |
| B08 | Binding | Every Match item binds the exact viewer and required participant/proposal context. | `PASS` |
| B09 | Binding | Every Connection item binds the exact viewer, participant set, role, and aggregate. | `PASS` |
| B10 | Binding | Every Conversation grant binds the exact participants, purpose, and current Connection context. | `PASS` |
| B11 | Binding | Subject mismatch causes source-local omission and no action candidate. | `PASS` |
| B12 | Binding | Participant mismatch causes source-local omission and no action candidate. | `PASS` |
| B13 | Binding | Audience mismatch withholds protected label, navigation, and action. | `PASS` |
| B14 | Binding | Purpose mismatch prevents Home reuse, including analytics/ranking/training reuse. | `PASS` |
| C15 | Revision/currentness | Readiness retains its own lineage/revision/currentness/freshness. | `PASS` |
| C16 | Revision/currentness | Match participation and proposal evidence retain their own source lineages. | `PASS` |
| C17 | Revision/currentness | Product Connection retains its aggregate-owned lineage. | `PASS` |
| C18 | Revision/currentness | Connection and Messaging Consent inputs behind Conversation grants retain independent lineages. | `PASS` |
| C19 | Revision/currentness | Cross-domain revision values are never compared as a global order. | `PASS` |
| C20 | Revision/currentness | Receipt/UI/cache/transport order cannot establish source currentness. | `PASS` |
| C21 | Revision/currentness | Incomparable or unknown revision relation fails closed for that source's action guidance. | `PASS` |
| C22 | Revision/currentness | Display and action uses independently satisfy the source's applicable freshness rule. | `PASS` |
| D23 | Current state | Current state identifies the source domain and claim class. | `PASS` |
| D24 | Current state | Current state retains exact subject/participants, audience, and Home purpose. | `PASS` |
| D25 | Current state | Current state exposes only a privacy-minimal source-faithful label. | `PASS` |
| D26 | Current state | Current state never merges source lifecycle vocabularies. | `PASS` |
| D27 | Current state | Current state may include navigation only when separately authorized. | `PASS` |
| D28 | Current state | State labels do not imply permitted actions or mutation success. | `PASS` |
| D29 | Current state | Historical/coarse display is explicitly non-current/non-actionable when separately authorized. | `PASS` |
| D30 | Current state | Unknown/unavailable/stale/lag is represented as a condition, not a negative state. | `PASS` |
| E31 | Next decision | Every candidate originates in current source-authorized actor-relevant permitted-action evidence. | `PASS` |
| E32 | Next decision | Every candidate retains source actor/role/context/revision/freshness binding. | `PASS` |
| E33 | Next decision | Home action evidence is descriptive and non-self-authorizing. | `PASS` |
| E34 | Next decision | The source writer revalidates every submitted mutation. | `PASS` |
| E35 | Next decision | Invalid/stale/superseded/lagged/mismatched action evidence is not a candidate. | `PASS` |
| E36 | Next decision | Absence of an action does not infer completion, terminality, rejection, or no need. | `PASS` |
| E37 | Next decision | Navigation to a decision surface grants neither access nor mutation authority. | `PASS` |
| E38 | Next decision | Home neither executes nor queues a source action. | `PASS` |
| F39 | Optional support | Optional support remains optional, quiet, and non-blocking. | `PASS` |
| F40 | Optional support | Each support item has an accepted source/category and Home audience/purpose. | `PASS` |
| F41 | Optional support | Support navigation is present only when separately authorized. | `PASS` |
| F42 | Optional support | Empty optional support remains empty and is not filled through enrichment. | `PASS` |
| F43 | Optional support | Support cannot create urgency, recommendation strength, or person meaning. | `PASS` |
| F44 | Optional support | Support cannot use private Conversation, Safety, ranking, analytics, or unaccepted AI inputs. | `PASS` |
| G45 | Primary selection | Candidate construction admits only current source-authorized own-role actions. | `PASS` |
| G46 | Primary selection | Zero candidates yields no primary action. | `PASS` |
| G47 | Primary selection | Exactly one valid candidate may yield exactly one primary action. | `PASS` |
| G48 | Primary selection | Multiple candidates without separate accepted unique precedence yield no primary action. | `PASS` |
| G49 | Primary selection | A separately accepted unique Home precedence, if later present, may select only among already valid candidates. | `PASS` |
| G50 | Primary selection | Selection never compares cross-domain revisions or timestamps. | `PASS` |
| G51 | Primary selection | Selection never uses urgency, SLA, countdown, or quantitative priority score invented here. | `PASS` |
| G52 | Primary selection | Selection never uses content, unread/activity count, total score, Safety evidence, or model prediction. | `PASS` |
| G53 | Primary selection | Selection creates no ranking/desirability/person-worth claim. | `PASS` |
| G54 | Primary selection | The primary action remains non-self-authorizing and may disappear after source correction/revocation. | `PASS` |
| H55 | Privacy minimality | Home requests only allowlisted minimum source fields. | `PASS` |
| H56 | Privacy minimality | Privacy minimization governs the source query as well as returned fields. | `PASS` |
| H57 | Privacy minimality | Peer identity is not exposed by default on the glanceable Home surface. | `PASS` |
| H58 | Privacy minimality | Candidate-irrelevant Showcase data is neither requested nor returned. | `PASS` |
| H59 | Privacy minimality | Globally public Profile enrichment is excluded. | `PASS` |
| H60 | Privacy minimality | Raw Readiness/Match/Connection evidence is omitted when a coarse authorized state suffices. | `PASS` |
| H61 | Privacy minimality | Source possession of richer data does not broaden Home audience or purpose. | `PASS` |
| H62 | Privacy minimality | Withheld/missing data is not reconstructed from another domain or legacy source. | `PASS` |
| I63 | Read/send separation | Conversation live-read and live-send are separate Home evidence dimensions. | `PASS` |
| I64 | Read/send separation | A live-read grant never implies a live-send grant. | `PASS` |
| I65 | Read/send separation | A live-send grant never grants protected Conversation reading or content construction. | `PASS` |
| I66 | Read/send separation | Send authority is re-evaluated at the send boundary by the owning gate. | `PASS` |
| I67 | Read/send separation | Loss/revocation of either BA-05 prerequisite propagates independently to both current MVP grant decisions. | `PASS` |
| I68 | Read/send separation | A coarse grant decision never exposes message, draft, preview, unread, or realtime private detail. | `PASS` |
| J69 | Failure conditions | Unknown remains unknown and never becomes absence. | `PASS` |
| J70 | Failure conditions | Unavailable remains authority access failure and never becomes domain failure. | `PASS` |
| J71 | Failure conditions | Stale remains distinct from superseded. | `PASS` |
| J72 | Failure conditions | Superseded evidence cannot guide a new action. | `PASS` |
| J73 | Failure conditions | Incomparable revisions do not resolve by last-received-wins. | `PASS` |
| J74 | Failure conditions | Known projection lag prevents older action guidance and cannot roll authority backward. | `PASS` |
| J75 | Failure conditions | A source-local failure condition does not collapse other valid sources. | `PASS` |
| J76 | Failure conditions | A valid source cannot repair an invalid source. | `PASS` |
| J77 | Failure conditions | Transport refresh success is not a domain mutation or freshness proof. | `PASS` |
| J78 | Failure conditions | Error/offline/loading/timeout conditions are presentation observations, not lifecycle states. | `PASS` |
| K79 | Correction/revocation | Correction is accepted only as newer owner-authored same-lineage evidence with exact scope. | `PASS` |
| K80 | Correction/revocation | Revocation is accepted only as newer grant-owner evidence with exact scope. | `PASS` |
| K81 | Correction/revocation | Correction replaces/removes only the affected Home label/action dependency. | `PASS` |
| K82 | Correction/revocation | Revocation immediately removes dependent current action/navigation guidance. | `PASS` |
| K83 | Correction/revocation | Cached older evidence never defeats a correction or revocation. | `PASS` |
| K84 | Correction/revocation | Correction/revocation in one source does not author another source's state. | `PASS` |
| K85 | Correction/revocation | Correction/revocation does not infer deletion, peer effect, Safety, guilt, or Relationship meaning. | `PASS` |
| K86 | Correction/revocation | Primary selection is recomputed after any affected source correction/revocation. | `PASS` |
| L87 | Partial availability | All valid sources compose without a global revision. | `PASS` |
| L88 | Partial availability | One valid source may be shown without inventing the other sources. | `PASS` |
| L89 | Partial availability | Several valid and unavailable sources produce a partial, not globally failed, Home. | `PASS` |
| L90 | Partial availability | All unavailable sources yield a calm unavailable presentation and no primary action. | `PASS` |
| L91 | Partial availability | All unknown facts yield no inferred lifecycle and no primary action. | `PASS` |
| L92 | Partial availability | No actor-relevant action permits a genuinely quiet Home. | `PASS` |
| L93 | Partial availability | Display-valid/action-invalid evidence remains non-actionable and excluded from selection. | `PASS` |
| L94 | Partial availability | Multiple valid actions without accepted precedence yield no primary action. | `PASS` |
| M95 | Non-substitution | Route/deep-link identity cannot establish Home audience, consent, source state, or action. | `PASS` |
| M96 | Non-substitution | Cache/local enum/boolean cannot establish current source authority. | `PASS` |
| M97 | Non-substitution | Notification payload/identity/open/dismissal cannot establish source outcome or Home access. | `PASS` |
| M98 | Non-substitution | Legacy DTO/state cannot become current target authority. | `PASS` |
| M99 | Non-substitution | Transport acknowledgement/success/failure cannot establish a domain outcome. | `PASS` |
| M100 | Non-substitution | Home card/label/CTA cannot create consent, permission, mutation, freshness, or currentness. | `PASS` |
| N101 | Cross-domain | Match state/acceptance does not create Product Connection. | `PASS` |
| N102 | Cross-domain | Product Connection state does not create Messaging Consent or Conversation access. | `PASS` |
| N103 | Cross-domain | Messaging Consent alone cannot repair invalid Product Connection evidence. | `PASS` |
| N104 | Cross-domain | Conversation grant/activity does not establish Relationship. | `PASS` |
| N105 | Cross-domain | Readiness does not establish Match, Connection, Conversation, or launch eligibility. | `PASS` |
| N106 | Cross-domain | Home composition is not a new lifecycle and primary selection is not ranking authority. | `PASS` |
| O107 | No total/hidden ranking | No authoritative Compatibility total score is requested, computed, displayed, or inferred. | `PASS` |
| O108 | No total/hidden ranking | Authorized factors/labels cannot become a total, action precedence, or person ranking. | `PASS` |
| O109 | No total/hidden ranking | Engagement/activity/unread data cannot drive hidden Home ranking. | `PASS` |
| O110 | No total/hidden ranking | Primary selection expresses no recommendation strength, desirability, or person worth. | `PASS` |
| P111 | No Conversation enrichment | Home never requests or displays private message content or attachments. | `PASS` |
| P112 | No Conversation enrichment | Home never requests or displays drafts, realtime content, or peer-private previews. | `PASS` |
| P113 | No Conversation enrichment | Home never uses unread private detail or content-derived activity. | `PASS` |
| P114 | No Conversation enrichment | Private Conversation is not a Match/ranking/advertising/analytics/training input. | `PASS` |
| Q115 | No Safety reputation | Hidden Safety evidence/moderation material is excluded from Home composition. | `PASS` |
| Q116 | No Safety reputation | Block, Report, Allegation, Finding, and restriction cannot be collapsed into reputation/person worth. | `PASS` |
| Q117 | No Safety reputation | Ordinary unknown/pause/decline/withdraw/expiry conditions imply no guilt or Safety finding. | `PASS` |
| Q118 | No Safety reputation | Primary selection cannot use hidden Safety severity, reputation, or punishment signals. | `PASS` |
| R119 | No implementation choice | No endpoint/API/wire/schema/table/index/storage/key is selected. | `PASS` |
| R120 | No implementation choice | No service/queue/cache/transaction/clock/deployment/auth mechanism is selected. | `PASS` |
| R121 | No implementation choice | No backend or Flutter/client implementation behavior is selected or performed. | `PASS` |
| R122 | No implementation choice | No analytics, telemetry, model-training, private-data processing, or legal mechanism is selected. | `PASS` |
| S123 | Scope/Git | Task authority and task blob are fixed in this candidate. | `PASS` |
| S124 | Scope/Git | Accepted upstream provenance and result blobs are explicitly traceable. | `PASS` |
| S125 | Scope/Git | Candidate scope is exactly the one authorized technical-design artifact. | `PASS` |
| S126 | Scope/Git | Required document-level scope and `git diff --check` are independently verifiable before publication. | `PASS` |
| T127 | Retained seam | Exact launch eligibility remains unresolved and cannot be inferred from effective Readiness. | `RETAINED_UNKNOWN` |
| T128 | Retained seam | Exact minimum identity-assurance threshold/policy remains unresolved. | `RETAINED_UNKNOWN` |
| T129 | Retained seam | Verification vendor/method/evidence type remains unresolved. | `RETAINED_UNKNOWN` |
| T130 | Retained seam | Age/eligibility model remains unresolved. | `RETAINED_UNKNOWN` |
| T131 | Retained seam | Region-specific Readiness correction/disclosure/retention/appeal requirements remain unresolved. | `RETAINED_UNKNOWN` |
| T132 | Retained seam | Readiness rights-request handling remains unresolved. | `RETAINED_UNKNOWN` |
| T133 | Retained seam | Hosting/transfer posture remains unresolved. | `RETAINED_UNKNOWN` |
| T134 | Retained seam | Purpose-specific lawful basis remains unresolved. | `RETAINED_UNKNOWN` |
| T135 | Retained seam | Exact Match proposal expiry duration remains unresolved. | `RETAINED_UNKNOWN` |
| T136 | Retained seam | Exact Match clock basis/time authority remains unresolved. | `RETAINED_UNKNOWN` |
| T137 | Retained seam | Match expiry extension/renewal rules remain unresolved. | `RETAINED_UNKNOWN` |
| T138 | Retained seam | Match cooldown/re-proposal timing remains unresolved. | `RETAINED_UNKNOWN` |
| T139 | Retained seam | Future Match multi-candidate/higher unresolved-proposal limits remain unresolved. | `RETAINED_UNKNOWN` |
| T140 | Retained seam | Concrete Match enrollment/proposal eligibility/readiness prerequisite contents remain unresolved. | `RETAINED_UNKNOWN` |
| T141 | Retained seam | Product-authorized Match proposal-withdraw reason categories remain unresolved. | `RETAINED_UNKNOWN` |
| T142 | Retained seam | Future Match participant decision-retraction mutation remains unresolved. | `RETAINED_UNKNOWN` |
| T143 | Retained seam | Optional AI/personality/astrology/reference-signal allowlist/provenance remains unresolved. | `RETAINED_UNKNOWN` |
| T144 | Retained seam | Exact Product Connection expiry policy remains unresolved. | `RETAINED_UNKNOWN` |
| T145 | Retained seam | Historical Conversation read after revoke/pause/close/Block/account exit remains unresolved. | `RETAINED_UNKNOWN` |
| T146 | Retained seam | Conversation/shared-content retention periods/schedules remain unresolved. | `RETAINED_UNKNOWN` |
| T147 | Retained seam | Conversation export/access/portability remains unresolved. | `RETAINED_UNKNOWN` |
| T148 | Retained seam | Conversation deletion/erasure and peer-visible effects remain unresolved. | `RETAINED_UNKNOWN` |
| T149 | Retained seam | Conversation/account-exit handling remains unresolved. | `RETAINED_UNKNOWN` |
| T150 | Retained seam | Conversation rights-request verification/timelines/appeals remain unresolved. | `RETAINED_UNKNOWN` |
| T151 | Retained seam | Conversation legal-hold/backups handling remains unresolved. | `RETAINED_UNKNOWN` |
| T152 | Retained seam | Region-specific Conversation/data-right implementation remains unresolved. | `RETAINED_UNKNOWN` |
| T153 | Retained seam | The future concrete Optional-support catalog and any ordering beyond already authorized items remain unresolved. | `RETAINED_UNKNOWN` |

Validation totals:

`PASS = 126 / RETAINED_UNKNOWN = 27 / BLOCKED = 0`

## 13. Complete retained-unknown and blocker register

Every retained unknown in this candidate is listed exactly once below. Home does not solve, infer, display as fact, or use for selection any conclusion dependent on these seams:

1. exact launch eligibility;
2. exact minimum identity-assurance threshold/policy;
3. verification vendor/method/evidence type;
4. age/eligibility model;
5. region-specific Readiness correction/disclosure/retention/appeal requirements;
6. Readiness rights-request handling;
7. hosting/transfer posture;
8. purpose-specific lawful basis;
9. exact Match proposal expiry duration;
10. exact Match clock basis/time authority;
11. Match expiry extension/renewal rules;
12. Match cooldown/re-proposal timing;
13. future Match multi-candidate/higher unresolved-proposal limits;
14. concrete Match enrollment/proposal eligibility/readiness prerequisite contents;
15. product-authorized Match proposal-withdraw reason categories;
16. future Match participant decision-retraction mutation;
17. optional AI/personality/astrology/reference-signal allowlist/provenance;
18. exact Product Connection expiry policy;
19. historical Conversation read after revoke/pause/close/Block/account exit;
20. Conversation/shared-content retention periods/schedules;
21. Conversation export/access/portability;
22. Conversation deletion/erasure and peer-visible effects;
23. Conversation/account-exit handling;
24. Conversation rights-request verification/timelines/appeals;
25. Conversation legal-hold/backups handling; and
26. region-specific Conversation/data-right implementation; and
27. the future concrete Optional-support catalog and any ordering beyond already authorized items.

These upstream seams do not block the current Home design because Home either consumes a separately authoritative coarse current fact/grant or omits the affected claim/action. They do block Home from inventing dependent labels, urgency, access, history, reasons, timing, legal promises, or actions.

Blockers: `NONE`.

## 14. Rejected substitutions and non-goals

Rejected as Home evidence or action authority: route/deep link, cached/local state, notification identity/payload, legacy DTO/state, transport success/failure, last-arrival order, cross-domain revision comparison, private Conversation content, Compatibility total score, hidden ranking, Safety evidence/reputation, public Profile enrichment, candidate-irrelevant Showcase, analytics/telemetry/training signals, unaccepted AI signals, and Relationship inference.

This candidate does not define Relationship state, historical Conversation authority, data rights, legal conclusions, Safety rules, notification authority, source lifecycles, exact policies, implementation mechanisms, detailed UI copy/layout, Phase 2, Sandbox/DEP13/B12/M2/M3, or successor execution.

## 15. Independent-review and stop boundary

Independent review must verify: exact accepted provenance; zero Home writers; all three section contracts; the source-by-source show/omit/action matrix; deterministic at-most-one rule; independent per-source revision/freshness; read/send separation; refresh/correction/revocation propagation; partial and empty semantics; source-query and response minimization; cross-domain non-implication; all 153 validation dispositions and totals; complete retained/blocker lists; exact one-file scope; and `git diff --check`.

This candidate requires fresh independent ACCEPT/REJECT review. Its author must not accept it, merge it, promote `main`, implement BA-06, start BA-07, or create a successor task.

`CALM HOME LIVE READ MODEL TECHNICAL DESIGN ESTABLISHED — READ-ONLY MULTI-DOMAIN COMPOSITION / PRIMARY-ACTION SELECTION / PRIVACY-MINIMALITY EXPLICIT — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
