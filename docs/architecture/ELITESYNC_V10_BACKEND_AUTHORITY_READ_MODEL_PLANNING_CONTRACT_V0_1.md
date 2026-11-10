# EliteSync v10｜Backend Authority / Read-Model Planning Contract｜v0.1

Status: `CANDIDATE — PLANNING CONTRACT ONLY — NO BACKEND IMPLEMENTATION`

Repository: `zcx369658780/EliteSync-v10`

Fresh planning base: `065d1a9fd56f1f8a9389139cc305d6b43e3a0227`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_B01_BACKEND_AUTHORITY_READ_MODEL_PLANNING_TASK_V0_1.md`

## 1. Purpose and authority boundary

This contract defines the authority and read-model boundaries needed to move the accepted client-side MVP integration contract toward authoritative runtime operation. It covers exactly B01-A through B01-F. It does not create runtime authority, select an implementation, or authorize backend work.

The accepted MVP integration remains valid, APP-T12-B01 remains `CLOSED`, and the exact MVP blocker set remains `NONE`. Every authority named below is required future authority unless an accepted document explicitly states otherwise.

This contract preserves:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- Block != Report; Report != Finding; Allegation != Finding
- immediate protection != guilt/punishment
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

## 2. Contract vocabulary

- **Authoritative writer**: the future domain authority permitted to validate and durably record a domain transition. A client, route, cache, transport, projection, notification, or legacy record is not an authoritative writer.
- **Authoritative read projection**: a server-originated, domain-owned representation derived from authoritative records for a defined audience and purpose. It does not gain mutation authority by being readable.
- **Client-consumable evidence**: the minimum audience-authorized facts a client may use for display or a gated action. Evidence is scoped to subject, audience, purpose, freshness, and revision; identity alone is insufficient.
- **Unknown**: authority or fact is not established. Unknown must not be rendered as absence or converted to a negative domain outcome.
- **Stale**: evidence is older than the owning authority's usable-freshness contract or superseded by a known revision. Stale protected content may be shown only when its owning privacy/consent gate still permits it; it cannot authorize new protected actions.
- **Unavailable**: the authority cannot currently answer. Unavailable is a presentation/transport condition, not a lifecycle transition.
- **Fail-closed**: deny or withhold the protected action or protected content while preserving the last authoritative domain fact only where its audience and freshness rules still permit display.

No client enum, local boolean, route parameter, cached row, unread count, connectivity state, or compatibility identity establishes authority.

## 3. Authority-source matrix

| Track | Required authoritative writer | Required authoritative reader / projection owner | Minimum client-consumable evidence | Unknown, stale, or unavailable behavior |
|---|---|---|---|---|
| B01-A Runtime Readiness | Readiness domain authority, writing only product-authorized eligibility, checklist, and verification facts | Readiness projection owner for the authenticated subject and permitted client purpose | subject binding; separate eligibility, checklist, verification, and effective readiness facts; authority revision; evaluated/freshness marker; correction or revocation marker when applicable | Treat readiness authority as not established; do not infer eligible, complete, verified, or launch-ready; stale evidence cannot unlock a new gated action |
| B01-B Canonical Match | Match domain authority for enrollment, pause, withdrawal, proposal, response, and durable lifecycle transitions | Canonical Match projection owner consumed by `/progress/match` | viewer/subject binding; canonical Match state; permitted next actions; proposal parties and actor role where applicable; mutual-acceptance evidence when established; revision and freshness; reason category only where product-authorized | No lifecycle mutation from the client; no acceptance inferred from transport or cached state; show a presentation condition without manufacturing expiry, decline, withdrawal, or absence |
| B01-C Product Connection | Product Connection domain authority for request and lifecycle transitions | Product Connection projection owner for each authorized participant | Connection identity; participant bindings; initiator/recipient roles where required; exact CN state; authoritative transition evidence; permitted actor/actions; revision and freshness | No local mutual-consent truth; no transition or success simulation; protected actions remain unavailable; stale state cannot authorize a new mutation |
| B01-D Conversation runtime gate | Separate owning authorities for Connection state and mutual messaging consent; Conversation authority may act only after both gates pass | Conversation access projection owner that evaluates both authorities for the requesting participant | authoritative `CN_ACTIVE` evidence plus separate authoritative mutual messaging-consent evidence; audience and participant binding; independent revisions/freshness; read and send grants separately when they differ | If either input is unknown, stale, unavailable, mismatched, or revoked, do not establish `CV_ACTIVE`; deny new read/send authority without inventing a domain outcome |
| B01-E Home live projection | No Home lifecycle writer; each contributing domain retains its own writer | Calm State Hub projection owner combining only already-authorized facts | privacy-minimal Current state, Next decision, and Optional support fields; source-domain identifier per item; source revision/freshness; navigation target only where already authorized; one selected primary action | Omit or mark the affected projection as unknown/unavailable; do not substitute another domain, enrich remotely, or convert missing inputs into a lifecycle fact |
| B01-F OS notification delivery / payload generation | Owning domain decides event eligibility; notification delivery authority generates privacy-minimal payloads and records delivery stages without writing domain outcomes | Notification projection/presentation readers, separated for in-app and external/lock-screen audiences | opaque notification identity; generic presentation category/copy; authorized in-app action discriminator; domain-event reference without sensitive payload identity; attempt/result state where knowable | No audience grant from payload or route identity; external copy stays generic; unknown delivery is not failure of the domain event, and delivery success is not domain success |

The matrix identifies authority roles, not concrete services, endpoints, tables, queues, schemas, or deployment units.

## 4. Mutation and read-model separation

1. A mutation request is only a request to an owning domain authority. The writer validates actor, current authoritative revision, allowed transition, consent/audience preconditions, and idempotency identity before recording any outcome.
2. A successful transport response is not sufficient evidence of a domain mutation. The client relies on authoritative transition evidence or a refreshed authoritative projection.
3. Read projections are derived evidence. They may expose permitted next actions but may not execute, invent, or locally persist authoritative lifecycle transitions.
4. Projection lag must be distinguishable from a domain outcome. A client may request a read refresh, but retry is not mutation authority and must not replay a non-idempotent intent implicitly.
5. Concurrent or repeated mutation intents must be safe at the contract level: the same logical intent cannot create duplicate proposals, requests, consents, or notifications; conflicting intents resolve against authoritative current state and revision, not client arrival order alone.
6. Domain writers remain separate. Match mutual acceptance cannot write Connection consent; Connection activation cannot write messaging consent; Conversation activity cannot write Relationship state; Home and notification systems write none of these lifecycle facts.
7. Correction or revocation must propagate as a new authoritative revision. Cached or projected older evidence cannot override it.

## 5. B01-A — Runtime Readiness authority

### Required separation

Readiness must keep four fact classes distinct:

| Fact class | Meaning | Must not imply |
|---|---|---|
| Eligibility | Product-authorized criteria currently evaluated by the authority | identity verification, checklist completion, or launch eligibility where undecided |
| Required checklist completion | Completion state of each currently authorized prerequisite | verification, overall readiness, or eligibility |
| Verification state | Authority-backed verification status for the applicable fact | global identity assurance or truth beyond its stated scope |
| Presentation state | loading, empty, offline, stale, retryable error, unavailable, or authority not established | any readiness lifecycle fact |

The future writer owns corrections and revocations only to the extent already product-authorized. The projection must make supersession visible so a corrected or revoked fact cannot remain an unlock token.

Launch eligibility and minimum identity assurance remain undecided where not already accepted. This contract does not select them. Legal/data-rights rules governing correction, retention, disclosure, or appeal of readiness evidence remain separate authority.

## 6. B01-B — Canonical Match mutation and durable lifecycle authority

The Match authority must own enrollment, pause, withdrawal, proposal issuance, acceptance, decline, withdrawal, and expiry representation. It must expose the canonical lifecycle state and the actor-specific actions that are currently authoritative for `/progress/match`.

Mutual acceptance evidence must bind the same proposal, both participants, each required actor decision, the authoritative revision, and the resulting Match transition. A route, candidate card, compatibility label, historical DTO, countdown, transport acknowledgement, or one participant's acceptance is insufficient.

Exact Match proposal expiry duration and rules remain `RETAINED UNKNOWN`. The authority must eventually represent expiry without this planning candidate choosing its duration, clock basis, extension rules, or policy. Until those rules are accepted, no client or backend plan may promote a legacy countdown to target authority.

No Compatibility total score becomes authoritative. Match evidence may contain separately authorized factors or explanations, but must not manufacture a total score or treat Match as Connection, Conversation, Relationship, guilt, Safety finding, or verified truth.

## 7. B01-C — Product Connection authority

The Product Connection authority owns authoritative reads and durable transition evidence for exactly:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

The future authority must preserve actor requirements. In particular:

- a request creates pending evidence with initiator and recipient roles;
- recipient acceptance of that pending request is the only consent-establishing transition to `CN_ACTIVE`;
- no direct `CN_NONE -> CN_ACTIVE` transition exists;
- initiator withdrawal, recipient decline, and authority-governed expiry are distinct non-active outcomes;
- pause and close follow only the accepted lifecycle's authorized actors and source states;
- decline, withdrawal, and expiry do not establish guilt, Safety findings, punishment, or objective incompatibility.

Match mutual acceptance is neither a Connection request nor recipient Connection acceptance. A client cannot create Connection authority through local state, a stored peer, optimistic success, or legacy chat behavior.

## 8. B01-D — Conversation runtime authority gate

Product Conversation availability or `CV_ACTIVE` requires both concurrently valid inputs:

1. authoritative, audience-bound `CN_ACTIVE` evidence from Product Connection; and
2. separate authoritative mutual messaging-consent evidence binding the same participants and Conversation purpose.

Neither input substitutes for the other. Sufficient evidence must include subject/participant binding, audience/purpose, authoritative state or grant, revision, and usable freshness. Where read and send permissions can differ, the Conversation access projection must expose them separately; a read grant never silently becomes a send grant.

The following are explicitly insufficient alone or in combination: `eligibleMatch`, `legacyPeer`, a stored route, peer ID, existing Conversation row, unread count, transport connectivity, notification payload identity, or legacy chat behavior.

If either required authority is unknown, unavailable, stale, revoked, or participant-mismatched, the client must not enter or represent active Product Conversation and must not read or send protected content. This is fail-closed access handling, not proof that the Conversation, person, consent, or content is absent.

Conversation retention, export, deletion, consent revoke consequences, closed-history behavior, and region-specific data rights remain Track 2. This contract does not decide whether any historical content remains readable after a future revoke or close event.

## 9. B01-E — Home live projection / read-model authority

Home remains the Calm State Hub and owns no lifecycle. Its future read model may combine only already-authorized, audience-permitted facts from Readiness, Match, Product Connection, Conversation access, and other accepted MVP navigation/support sources. Relationship state, private Conversation content, globally public Profile data, inferred compatibility totals, or candidate-irrelevant Showcase data are not Home enrichment inputs.

Minimum projection semantics are:

| Section | Minimum fields | Boundary |
|---|---|---|
| Current state | source domain; privacy-minimal state label; source revision/freshness; availability | Must not merge lifecycle vocabularies or claim a stronger state than the source authority |
| Next decision | source domain; actor-relevant decision label; currently permitted action or authorized navigation target; urgency only if source-authorized | Must not invent a mutation, consent, countdown, or objective recommendation |
| Optional support | support category; privacy-minimal label; authorized navigation target or informational status | Must remain optional and must not use private/remote enrichment merely to fill the surface |

The read model selects at most one primary action under the accepted low-density Home contract. Selection is presentation ordering over independently authoritative inputs, not a new cross-domain lifecycle or ranking authority.

Each source can fail independently. Unknown or unavailable inputs remain unknown or unavailable; they do not collapse the entire domain graph and do not permit another domain's fact to substitute. Privacy-minimality applies both to returned fields and to which source facts are requested.

## 10. B01-F — OS notification delivery and payload-generation authority

The notification flow has five distinct stages:

1. an owning domain determines whether an event is eligible for notification;
2. a notification authority generates an audience-appropriate, privacy-minimal payload;
3. a delivery channel attempts transport;
4. an OS/channel result is recorded only where knowable;
5. the app presents generic external or in-app copy and evaluates any action against current audience/consent authority.

No later stage rewrites an earlier domain outcome. Delivery attempt, delivery success, OS display, open, dismissal, or transport failure are notification facts only.

External/lock-screen copy remains privacy-minimal and generic by default. In-app presentation may reveal only information independently authorized for the current audience. Payload `user_id`, payload `name`, route parameters, notification type, and deep-link identity do not establish audience authority or consent.

APP-T09 generic notification presentation remains the presentation foundation. APP-T12-B01 remains `CLOSED`: `status_author` payload identity and direct `status_author/:userId` route identity must remain incapable of initiating profile-like loading without separately established audience authority.

## 11. Cross-domain dependency graph

```text
Readiness authority ───────────────> Readiness projection ─────┐
                                                               │
Match authority ──────────────────> /progress/match projection ├──> Home projection
                                                               │    (read-only composition)
Connection authority ─────────────> Connection projection ─────┤
          │                                                    │
          │ authoritative CN_ACTIVE                            │
          v                                                    │
Conversation access evaluator <── messaging-consent authority ─┘
          │
          └──> Conversation read/send grants

Owning domain event eligibility ──> notification payload generation
                                           │
                                           v
                                  delivery attempt / OS result
                                           │
                                           v
                                  privacy-minimal presentation
                                  + fresh audience-gate check
```

Arrows mean evidence dependency, not shared ownership. Home cannot write upstream state. Notification transport cannot write a domain outcome. Conversation depends on Connection plus messaging consent but does not collapse either authority. Match has no arrow that creates Connection.

## 12. Consent and audience gates that identity cannot bypass

- A participant ID proves only a technical identifier, not audience, consent, actor role, or current authorization.
- A route or deep link is navigation intent, not an access grant.
- A notification payload is transport input, not audience authority.
- A candidate, proposal, Match, `eligibleMatch`, or `legacyPeer` identity is not Connection consent.
- `CN_ACTIVE` alone is not messaging consent; messaging consent alone is not `CN_ACTIVE`.
- An existing Conversation row, unread count, cached message, or connected transport is not read/send authority.
- A cached projection cannot bypass a correction, revocation, newer authority revision, or freshness limit.
- A Home card or next-action label cannot grant the mutation or navigation authority it describes.
- A Showcase reference is candidate-scoped and cannot become globally public Profile authority.

Every protected read or action must be evaluated against current authoritative evidence for the requesting subject, audience, purpose, and actor role.

## 13. Retained UNKNOWNs and Track 2 boundaries

### Retained UNKNOWN — not decided here

- exact Match proposal expiry duration/rules;
- optional AI/personality/astrology-like/reference-signal allowlist and provenance constraints;
- launch eligibility or minimum identity assurance where not already accepted.

These are not implementation blanks to be filled by an engineer, client fallback, legacy behavior, or inferred backend policy.

### Track 2 legal/data-rights authority required

- Conversation retention;
- export;
- deletion;
- revoke consequences;
- closed-history semantics;
- region-specific data-right implementation.

Readiness evidence correction, revocation, retention, disclosure, or appeal implications that require legal/data-rights decisions must also remain deferred rather than being silently embedded in a technical design.

### May proceed after this candidate's independent review and Owner acceptance, without Track 2

- bounded semantic authority-interface planning for Readiness, Match, Connection, Home projection, and notification event/delivery separation;
- bounded evidence-envelope planning for authoritative source, audience/purpose, revision, freshness, actor role, and permitted actions;
- bounded idempotency/concurrency contract planning for Match and Connection mutations;
- bounded Conversation gate-input planning up to evaluating current `CN_ACTIVE` plus current messaging-consent evidence, while leaving post-revoke and historical-content behavior unspecified;
- evidence and acceptance planning that proves clients fail closed without acquiring dependencies or touching product source.

All such work still needs a separate task. This list is sequencing guidance, not implementation authority.

### Must wait for Track 2

- any Conversation behavior after revoke or close that depends on retention or historical-read rights;
- export and deletion behavior or guarantees;
- region-specific storage, access, disclosure, erasure, or retention behavior;
- client controls or backend claims representing any of those capabilities;
- technical choices whose correctness depends on the unresolved legal/data-rights outcome.

Track 3 Flutter tooling/package-graph evidence restoration remains later and separate. Compatibility cleanup, Phase 2 Explore/Relationship, and Sandbox/DEP13/B12/M2/M3 remain unauthorized.

## 14. Explicit non-goals

This candidate does not:

- define endpoints, payload wire formats, database tables, schemas, indexes, queues, services, deployment units, migrations, or implementation ownership;
- implement or simulate any backend, API, database, service, Flutter, notification, or runtime behavior;
- select Match expiry rules, launch eligibility, identity-assurance thresholds, or optional signal allowlists;
- decide legal/data-rights matters or conduct legal research;
- establish a globally public Profile, broaden Showcase, or create a Compatibility total score;
- merge Match, Connection, Conversation, or Relationship authority;
- authorize private data inspection, telemetry, Safety Operations, dependency acquisition, tooling restoration, compatibility retirement, Phase 2, or historical Sandbox work;
- reopen APP-T03–T12 or APP-T12-B01 without fresh regression evidence.

## 15. Recommended bounded follow-up sequence

This sequence begins only after fresh independent review of this candidate and explicit Owner acceptance. Each item requires its own bounded authorization and must stop at its stated gate.

1. **Authority evidence-envelope contract** — define common semantic fields and validation obligations for source, subject/audience/purpose, revision, freshness, actor role, and permitted action without choosing transport or storage.
2. **Readiness authority contract** — close only B01-A product-authorized semantics, preserving undecided launch eligibility, identity assurance, and legal/data-rights boundaries.
3. **Match mutation authority contract** — define B01-B transition, actor, idempotency, concurrency, and canonical projection semantics while retaining exact expiry as unknown and forbidding a total score.
4. **Connection authority contract** — define B01-C authoritative read/write evidence and recipient-acceptance semantics without borrowing Match or Conversation authority.
5. **Conversation gate-input contract** — define B01-D evaluation of the two independent current authorities; stop before retention, revoke consequences, or historical-content semantics.
6. **Home projection contract** — define B01-E privacy-minimal read composition only after upstream evidence shapes are accepted.
7. **Notification authority contract** — define B01-F event eligibility, payload generation, delivery-stage evidence, and fresh audience-gate evaluation while preserving generic presentation.
8. **Track 1 integration review** — independently verify cross-domain separation, fail-closed behavior, and retained boundaries before any implementation proposal.
9. **Owner Track 1 closeout** — accept, revise, or reject the integrated planning chain.
10. **Track 2 task dispatch** — only the Owner may separately authorize legal/data-rights decision closure. Track 3 remains subsequent to its required gate.

No step above authorizes code. Any later implementation proposal must be separately scoped after the relevant planning contract, independent review, Owner acceptance, and Track 2 dependency checks.

## 16. Verification and stop boundary

This planning candidate is verifiable by exact source-document review, single-path diff review, and whitespace checks. Flutter/Dart/Gradle tooling, dependency resolution, backend/network execution, private data, telemetry, and runtime evidence are neither needed nor authorized.

Completion classification:

`BACKEND AUTHORITY / READ-MODEL PLANNING CONTRACT ESTABLISHED — NO BACKEND IMPLEMENTATION PERFORMED — TRACK-2 LEGAL/DATA-RIGHTS BOUNDARIES PRESERVED — READY FOR INDEPENDENT REVIEW`

Publication of this candidate is the terminal action. It does not merge, self-accept, start Track 2 or Track 3, or create successor authority.
