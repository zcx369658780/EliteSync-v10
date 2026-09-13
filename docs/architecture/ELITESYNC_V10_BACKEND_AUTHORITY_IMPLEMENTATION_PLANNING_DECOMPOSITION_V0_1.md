# EliteSync v10｜Backend Authority Implementation-Planning Decomposition｜v0.1

Status: `CANDIDATE — PLANNING / DECOMPOSITION ONLY — NO BACKEND IMPLEMENTATION AUTHORIZED`

Repository: `zcx369658780/EliteSync-v10`

Fresh review base: `a85e689789cda57bfe01c547596e7bbf07d6f849`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_BA01_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_TASK_V0_1.md`

## 1. Current authority summary

The accepted Backend Authority / Read-Model Planning Contract defines B01-A through B01-F as future authority obligations. Its Owner-accepted Track-2 companion closes D-01 through D-10 only at the common product-semantic layer. Neither acceptance creates a backend writer, read projection, API, schema, service, migration, deployment unit, legal conclusion, or implementation authority.

This decomposition converts those accepted obligations into seven independently reviewable successor workstreams, BA-01 through BA-07. For every workstream, the first possible successor is a bounded technical-design task. `READY_FOR_BOUNDED_TECHNICAL_DESIGN` never means ready to implement. Implementation and client integration require later, separately dispatched tasks after the relevant technical-design candidate has been independently reviewed and Owner-accepted.

The fresh-start variance gate is closed: task-sheet embedded authority `7b78ba7fec075a9664d25144f78e640fcb296b75` is the sole parent of the user-bound base. The only intervening change is publication of this BA01 task sheet; it does not alter Backend, Track-2, or Owner sequencing authority.

Binding invariants remain:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- Block != Report; Report != Finding; Allegation != Finding
- immediate protection != guilt/punishment
- private Conversation != default Match/ranking/training/advertising data
- no globally public MVP Profile authority
- Showcase remains candidate-scoped
- no authoritative Compatibility total score

Accepted Track-2 semantics also remain binding: Hide, Mute, Pause, Close, Block, Report, Export, deletion request, service erasure, and revoke are distinct; loss of `CN_ACTIVE` or messaging-consent revoke removes live send authority; history is unavailable by default unless a separate history authority is established; no fake rights capability may be shown; and private Conversation has no unrelated-use authority by default.

## 2. Dependency classification and ordered proposal

The classifications below describe the gate **at this candidate's base**. Each BA task has exactly one classification. A released upstream dependency makes a task eligible for a new bounded technical-design dispatch; it never starts that task automatically.

| Task | Current dependency classification | Release condition | Ordered position |
|---|---|---|---|
| BA-01 | `READY_FOR_BOUNDED_TECHNICAL_DESIGN` | Independent acceptance and Owner acceptance of this decomposition | 1 |
| BA-02 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 technical-design contract independently reviewed and Owner-accepted | 2A |
| BA-03 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 technical-design contract independently reviewed and Owner-accepted | 2B |
| BA-04 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 technical-design contract independently reviewed and Owner-accepted | 2C |
| BA-05 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 and BA-04 technical-design contracts independently reviewed and Owner-accepted | 3 |
| BA-06 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 through BA-05 technical-design contracts independently reviewed and Owner-accepted | 4A |
| BA-07 | `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` | BA-01 through BA-05 event/evidence obligations independently reviewed and Owner-accepted | 4B |

Recommended dependency DAG:

```text
BA-01 common evidence envelope
  ├──> BA-02 Readiness authority ───────────────┐
  ├──> BA-03 Match authority ───────────────────┤
  └──> BA-04 Connection authority ──> BA-05 Conversation live gate
                                               │
BA-02 + BA-03 + BA-04 + BA-05 ────────────────┼──> BA-06 Home read model
                                               └──> BA-07 Notification authority
```

BA-02, BA-03, and BA-04 may be separately dispatched after BA-01 acceptance and may proceed in parallel because their writers remain distinct. BA-04 does not depend on Match acceptance: Match must never create Connection consent. BA-05 depends on BA-04 because current authoritative `CN_ACTIVE` is one of its two mandatory inputs. BA-06 waits for all source evidence shapes because Home is read-only composition. BA-07 waits for the event/evidence obligations of the emitting domains so notification eligibility cannot invent domain outcomes.

## 3. Common successor-task delivery contract

Every BA successor must have one principal authority responsibility and one reviewable terminal candidate. Unless a later Owner task sheet states a narrower boundary, each technical-design task must:

1. begin from a fresh-fetched, explicitly bound `origin/main` in a separate clean worktree;
2. read only the exact sources bound by its task sheet;
3. produce one named technical-design candidate and, only if explicitly authorized, one result artifact;
4. define semantics and acceptance obligations without creating runtime claims;
5. record every unresolved fact as `UNKNOWN`, `BLOCKED_BY_OWNER_MATERIAL_FACT`, `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY`, or `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE`, as applicable;
6. pass exact-path scope assertions and `git diff --check`;
7. show that no backend/product/test/dependency/schema/migration/global-configuration path changed unless that later task explicitly authorizes such a path;
8. publish its candidate and stop for a fresh independent review; and
9. require a separate Owner acceptance before any dependent BA task, implementation task, or client-integration task starts.

Technical-design acceptance evidence is documentary evidence only: fixed commit/parent/tree/blob identity, exact scope, complete contract matrices, negative assertions, and independent verdict. It is not runtime evidence and must not be reported as implementation completion.

## 4. BA-01 — Common authority evidence envelope / revision contract

### Objective

Define the smallest transport- and storage-neutral semantic envelope that later domain authorities use to express subject/participant binding, audience, purpose, actor role, authority revision, freshness/supersession, permitted actions, authoritative outcome versus transport state, and idempotency identity where applicable.

### Inputs and required source reads

- this decomposition and its future independent acceptance / Owner acceptance;
- `ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md` and its acceptance;
- the MVP closeout handoff for the invariant and presentation-state vocabulary;
- Track-2 Owner acceptance for revocation, history, and no-fake-capability boundaries.

The successor task sheet must bind exact paths, commits, and blobs. It must not authorize a broad source or repository audit.

### Required output

One semantic technical-design candidate specifying:

- mandatory and conditionally mandatory evidence fields;
- binding and validation obligations for subject, participants, audience, purpose, and actor;
- monotonic/superseding revision semantics without choosing a persistence engine;
- freshness evaluation and the difference between stale, unavailable, unknown, and a domain outcome;
- permitted-action evidence that is descriptive and non-self-authorizing;
- correction/revocation representation as a newer authoritative revision;
- logical-intent/idempotency obligations where mutation tasks need them;
- rules preventing transport success, projection lag, route identity, payload identity, or cached state from becoming authority; and
- extension rules that preserve domain ownership rather than creating one universal lifecycle.

### Non-goals

No wire protocol, endpoint, payload serialization, database schema, key format, queue, service boundary, clock technology, deployment topology, authentication implementation, or client implementation is selected. BA-01 does not create a universal domain state or allow one domain to write another.

### Acceptance evidence before BA-02/03/04 dispatch

- a field-obligation matrix maps every required concept to presence, binding, freshness, and fail-closed rules;
- examples cover current, superseded, stale, unavailable, actor-mismatched, audience-mismatched, and duplicate-intent evidence without inventing business outcomes;
- exact assertions prove `transport success != authoritative outcome`, `identity != audience/consent`, and stale evidence cannot authorize a new protected action;
- Match, Connection, Conversation, Readiness, Home, and Notification extension points retain separate owners;
- no technical implementation choice or region-specific fact is embedded;
- candidate identity/scope and independent ACCEPT verdict are recorded, followed by Owner acceptance.

## 5. BA-02 — Runtime Readiness authority

### Objective

Define the bounded technical design obligations for an authoritative Readiness writer and authenticated-subject projection while keeping eligibility, checklist completion, verification, effective readiness, and presentation state separate.

### Inputs and required source reads

- accepted BA-01 contract;
- B01-A sections of the accepted Backend Authority / Read-Model Planning Contract;
- MVP closeout sections for Me / Readiness and common presentation states;
- Track-2 Owner acceptance only for correction/revocation/no-fake-capability limits.

### Required output

One candidate covering:

- ownership and subject binding for each accepted Readiness fact class;
- derivation rules for effective readiness without treating an enum as authority;
- correction/revocation and supersession propagation within already accepted semantics;
- privacy-minimal authenticated-subject read projection;
- actor/permitted-action and revision/freshness behavior;
- fail-closed handling for unknown, stale, or unavailable evidence; and
- a material-fact seam for launch eligibility and minimum identity assurance rather than a guessed policy.

### Non-goals

Do not choose launch eligibility, verification vendors/methods, minimum identity assurance, age policy, jurisdictional correction/appeal rules, retention, endpoint/schema/service topology, or Flutter behavior.

### Acceptance evidence before BA-06 may consume Readiness

- a trace matrix separately preserves eligibility, checklist completion, verification, effective-readiness derivation, and presentation state, and lists what each cannot imply;
- every unlock decision requires current subject-bound authoritative evidence;
- correction and revocation supersede earlier evidence without local/client fallback;
- launch eligibility and identity assurance remain explicit `UNKNOWN` or Owner-material-fact gates;
- region-dependent correction, disclosure, retention, verification, and appeal behavior is not designed;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 6. BA-03 — Canonical Match mutation + durable lifecycle authority

### Objective

Define bounded mutation and read-projection obligations for enrollment, pause, withdrawal, proposal issuance, response, and durable Match lifecycle evidence consumed by `/progress/match`.

### Inputs and required source reads

- accepted BA-01 contract;
- B01-B sections of the accepted Backend Authority / Read-Model Planning Contract;
- MVP closeout canonical Match and legacy-cutover boundaries;
- accepted product Match contract explicitly bound by the future task sheet.

### Required output

One candidate defining:

- actor/state/transition validation obligations for enrollment, pause, withdrawal, proposal issue, accept, decline, withdraw, and expiry representation;
- mutual-acceptance evidence bound to the same proposal, participants, actor decisions, revision, and resulting Match transition;
- idempotency and concurrency outcomes against authoritative current state;
- the privacy-minimal canonical `/progress/match` projection and actor-specific permitted actions;
- projection-lag and transport-failure treatment; and
- an explicit unresolved-policy input for expiry duration, clock basis, extension, and other expiry rules.

### Non-goals

Do not choose exact expiry policy, a Compatibility total score, Connection creation, messaging consent, Relationship state, legacy DTO authority, endpoint/schema/service topology, or client migration.

### Acceptance evidence before BA-06/07 consume Match

- a complete actor/transition table contains no mutation from transport acknowledgement or cached projection;
- two-party acceptance evidence cannot be satisfied by one participant, a route, countdown, or compatibility label;
- concurrency/idempotency cases cover duplicate, reordered, conflicting, and superseded intents without client-arrival-order authority;
- expiry is representable but its policy remains `RETAINED UNKNOWN` and no legacy countdown is promoted;
- Match acceptance is proven not to create Connection, Conversation, or Relationship authority;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 7. BA-04 — Product Connection authority

### Objective

Define bounded authoritative read and mutation-evidence obligations for the accepted Product Connection lifecycle:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

### Inputs and required source reads

- accepted BA-01 contract;
- B01-C sections of the accepted Backend Authority / Read-Model Planning Contract;
- MVP closeout Product Connection boundaries;
- accepted Product Connection lifecycle contract explicitly bound by the future task sheet.

### Required output

One candidate defining:

- connection identity and participant/initiator/recipient bindings;
- complete state/source/target/actor transition obligations;
- request, recipient acceptance, pause, close, decline, withdrawal, and authority-governed expiry evidence;
- mutation idempotency, concurrency, revision, freshness, and permitted-action rules;
- participant-authorized read projection semantics; and
- neutral outcome semantics for decline, withdrawal, and expiry.

### Non-goals

Do not let Match mutual acceptance create a Connection request or consent. Do not allow direct `CN_NONE -> CN_ACTIVE`, local mutual-consent truth, optimistic success, legacy chat authority, messaging consent, Conversation access, Safety/guilt/incompatibility inference, or endpoint/schema/service/client implementation.

### Acceptance evidence before BA-05 dispatch

- the exact-state actor/transition matrix proves recipient acceptance of the same `CN_PENDING` request is the sole transition establishing `CN_ACTIVE`;
- negative cases prove no direct `CN_NONE -> CN_ACTIVE` and no Match/route/stored-peer/legacy-chat substitution;
- duplicate and conflicting request/response/pause/close intents resolve against authoritative revision;
- read evidence exposes only actor-appropriate actions and fails closed on unknown/stale/unavailable/mismatched evidence;
- decline, withdrawal, and expiry are not guilt, Safety, punishment, or objective incompatibility;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 8. BA-05 — Messaging-consent authority + Conversation live gate

### Objective

Define the minimum current-authority design for separate mutual messaging consent, consumption of current `CN_ACTIVE`, and participant-bound Conversation read/send grants. This workstream is live-gate only.

### Inputs and required source reads

- accepted BA-01 and BA-04 contracts;
- B01-D sections of the accepted Backend Authority / Read-Model Planning Contract;
- Track-2 decision candidate and Owner acceptance, especially D-02, D-03, D-08, and D-10;
- MVP closeout Conversation and notification audience boundaries;
- accepted Product Conversation consent/privacy contract explicitly bound by the future task sheet.

### Required output

One candidate defining:

- messaging-consent evidence as a separate authority binding the same participants and Conversation purpose;
- independent revisions/freshness for Connection and messaging-consent inputs;
- live read and send grants separately wherever their semantics differ;
- evaluation, invalidation, and fail-closed rules for unknown, stale, unavailable, revoked, or participant-mismatched evidence;
- propagation obligations that remove new live send authority when consent is revoked or `CN_ACTIVE` is lost; and
- an explicit downstream interface boundary for any future historical-access authority without defining that authority.

### Non-goals

No historical read authority, retention schedule/job, export, access/portability, deletion, account-exit handling, peer-visible deletion effect, rights request, legal hold, backup rule, endpoint/schema/service topology, Conversation content processing, or client integration. `eligibleMatch`, `legacyPeer`, route, row, unread count, connectivity, or payload identity never supplies either live gate.

### Acceptance evidence before BA-06/07 consume Conversation access

- a two-input truth table establishes a live grant only when current participant-bound `CN_ACTIVE` and current participant/purpose-bound mutual messaging consent both pass;
- read and send decisions are explicit and no read grant silently becomes send authority;
- revoke/loss/staleness/unavailability/mismatch cases fail closed without asserting absence or deletion;
- no case grants history after revoke/pause/close; history remains unavailable unless a future separate authority is accepted;
- private Conversation is not exposed for unrelated Match/ranking/training/advertising use;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 9. BA-06 — Calm Home live read model

### Objective

Define a privacy-minimal, read-only Home projection over already accepted upstream authority evidence, retaining Current state, Next decision, and Optional support without creating a cross-domain writer.

### Inputs and required source reads

- accepted BA-01 through BA-05 contracts;
- B01-E sections of the accepted Backend Authority / Read-Model Planning Contract;
- MVP closeout Calm State Hub contract and common presentation-state semantics;
- exact accepted Home contract bound by the future task sheet.

### Required output

One candidate defining:

- source-domain identifier, source revision/freshness, availability, privacy-minimal label, and authorized navigation/action-reference obligations;
- independent source failure and partial-projection semantics;
- selection of at most one primary action as presentation ordering only;
- field and source-query minimization; and
- omission/unknown/unavailable behavior that never substitutes one lifecycle for another.

### Non-goals

Home writes no lifecycle state, executes no mutation, creates no consent, and performs no private-content or remote enrichment. It does not ingest Relationship state, globally public Profile data, private Conversation content, Compatibility totals, or candidate-irrelevant Showcase data. No endpoint/schema/service/client design is selected.

### Acceptance evidence before any Home implementation proposal

- every field traces to an accepted upstream projection and audience/purpose;
- no Home field is stronger than its source evidence and no navigation label grants access;
- missing, unknown, stale, or unavailable source evidence remains source-local and cannot manufacture a lifecycle fact;
- exactly zero lifecycle-writer responsibilities are assigned to Home;
- privacy-minimal source request and response allowlists are explicit;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 10. BA-07 — Notification domain-event / payload-generation / delivery authority

### Objective

Define bounded notification authority across domain-event eligibility, privacy-minimal payload generation, delivery attempt/result evidence, audience-separated presentation, and fresh authority re-check on protected navigation.

### Inputs and required source reads

- accepted BA-01 through BA-05 contracts and their domain-event/evidence obligations;
- B01-F sections of the accepted Backend Authority / Read-Model Planning Contract;
- MVP closeout notification privacy and APP-T12-B01 closure;
- Track-2 D-10 no-fake-capability boundary;
- accepted APP-T09 notification presentation and APP-T12-B01 remediation contracts explicitly bound by the future task sheet.

### Required output

One candidate defining five separate stages:

1. owning-domain event eligibility;
2. audience-appropriate, privacy-minimal payload generation;
3. channel delivery attempt;
4. knowable OS/channel result evidence; and
5. in-app/external presentation plus fresh audience/consent re-evaluation for protected navigation.

It must also define opaque notification identity, generic external category/copy, authorized in-app action discrimination, domain-event references without sensitive identity authority, and the distinction among domain outcome, notification eligibility, attempt, result, open, and dismissal.

### Non-goals

Do not let notification infrastructure write domain outcomes, create consent, grant audience, infer delivery from domain success, or infer domain failure from transport. Do not expose payload `user_id`, `name`, route identity, Profile-like data, private content, or rights capabilities as authority. No vendor/channel selection, endpoint/schema/queue/service topology, client navigation implementation, or global notification configuration is selected.

### Acceptance evidence before any notification implementation proposal

- a stage/evidence matrix assigns one owner to each stage and prohibits reverse writes into domain lifecycle;
- separate external/lock-screen and authenticated in-app audience matrices preserve generic external presentation;
- protected-open cases re-check fresh authority and deny without mark-read or protected fetch when authority fails;
- exact negative assertions preserve APP-T12-B01: payload and route identity cannot initiate profile-like loading or grant audience;
- attempt/result/open/dismissal remain notification facts, not domain success/failure;
- candidate scope, independent ACCEPT verdict, and Owner acceptance are recorded.

## 11. Track-2 and material-fact blocking map

The accepted common product semantics allow BA-01 through BA-07 to be technically designed only within the bounded live-authority slices above after their upstream gates. They do not close the following work. These areas must not enter technical design until the named authority exists.

| Area | Classification | Missing authority / material fact | Effect on BA route |
|---|---|---|---|
| Default historical Conversation access after revoke, pause, close, Block, or account exit | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Region-specific retention/access basis plus Owner-approved applicable posture; current accepted default is unavailable | Excluded from BA-05; separate later history-authority route |
| Conversation retention periods and schedules | `BLOCKED_BY_OWNER_MATERIAL_FACT` | Launch regions, entity/roles, age model, purposes/bases, data classes, operational needs | No duration, job, trigger, or storage promise in BA-05 |
| Export/access/portability semantics and request handling | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Applicable right, class scope, peer balancing, identity verification, timelines, refusal/appeal rules | Separate rights-authority route; no fake capability |
| Deletion/erasure and peer-visible effects | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Applicable erasure scope/exceptions, peer rights, Owner-approved exact outcome | Separate route; accepted default does not alter peer view |
| Account exit and data-deletion handling | `BLOCKED_BY_OWNER_MATERIAL_FACT` | Accountable entity, account model, region, rights channel, per-class outcome | Excluded from live Conversation gate |
| Rights-request verification, timelines, refusals, and appeals | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Jurisdiction-specific rights procedure and proportionate verification | No backend workflow design |
| Backups, legal holds, fraud/security and Safety records | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Specific basis, scope, access owner, retention duration, technical facts | No blanket exception or indefinite retention |
| Minor/age-specific data rights and consent | `BLOCKED_BY_OWNER_MATERIAL_FACT` | Owner age/eligibility model and launch-region facts | BA-02 and BA-05 retain an explicit seam; no age inference |
| Hosting, subprocessors, localization, and cross-border transfers | `BLOCKED_BY_OWNER_MATERIAL_FACT` | Deployment/hosting/vendor/transfer facts and entity/region map | No topology or transfer design in this chain |
| Purpose-by-purpose lawful basis | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Accepted purpose inventory plus qualified jurisdiction-specific decision | No legal-basis inference from product consent |
| Exact Match proposal expiry policy | `UNKNOWN` | Product/Owner decision on duration, clock, extension, and rules | BA-03 represents expiry but cannot select policy |
| Historical rights/retention implementation | `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE` | All relevant material facts and region-specific authority above | Never silently appended to BA-05 |

`BLOCKED_BY_OWNER_MATERIAL_FACT` does not mean the Owner should guess a legal answer. It means the factual operating input must first be established; qualified region-specific authority remains a separate subsequent gate where applicable.

## 12. Technical design, implementation, and client integration remain separate

| Stage | Permitted terminal result | Not established by that result | Required next gate |
|---|---|---|---|
| BA technical design | One bounded semantic/interface design candidate with validation, failure, privacy, idempotency, and evidence obligations | Executable authority, endpoint, schema, service, migration, deployment, runtime evidence | Fresh independent review and Owner acceptance |
| Backend implementation | Separately authorized, narrow implementation candidate against one accepted BA design | Production deployment, cross-domain completion, client consumption, legal readiness | Bounded tests/evidence, fresh independent review, Owner acceptance |
| Client integration | Separately authorized client slice consuming accepted authoritative evidence | New backend authority, consent, legal rights, compatibility retirement, Phase 2 | Client-specific tests/evidence, fresh independent review, Owner acceptance |

No stage may be bundled with the next merely because its tests pass. Client fallbacks, optimistic state, route/payload identity, compatibility records, and locally persisted booleans may not fill a missing backend stage.

## 13. Recommended first successor task identifiers

After independent review and explicit Owner acceptance of this decomposition, recommended bounded task sheets are:

1. `NEXT-BA-01-COMMON-AUTHORITY-EVIDENCE-ENVELOPE-TECHNICAL-DESIGN-V0-1`
   - recommended branch: `review/next-ba-01-common-authority-evidence-envelope-technical-design-v0-1`
   - terminal candidate: `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`
2. `NEXT-BA-02-RUNTIME-READINESS-AUTHORITY-TECHNICAL-DESIGN-V0-1`
   - recommended branch: `review/next-ba-02-runtime-readiness-authority-technical-design-v0-1`
   - terminal candidate: `docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
3. `NEXT-BA-03-CANONICAL-MATCH-AUTHORITY-TECHNICAL-DESIGN-V0-1`
   - recommended branch: `review/next-ba-03-canonical-match-authority-technical-design-v0-1`
   - terminal candidate: `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
4. `NEXT-BA-04-PRODUCT-CONNECTION-AUTHORITY-TECHNICAL-DESIGN-V0-1`
   - recommended branch: `review/next-ba-04-product-connection-authority-technical-design-v0-1`
   - terminal candidate: `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`
5. `NEXT-BA-05-MESSAGING-CONSENT-CONVERSATION-LIVE-GATE-TECHNICAL-DESIGN-V0-1`
   - recommended branch: `review/next-ba-05-messaging-consent-conversation-live-gate-technical-design-v0-1`
   - terminal candidate: `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`

Identifiers 2–4 describe parallel-eligible work after BA-01 acceptance; listing order is not authority to start them. BA-05 remains blocked until BA-04 is accepted.

## 14. Stop gates

For every BA task:

1. publication is terminal; do not merge or self-accept;
2. an independent fresh-session ACCEPT/REJECT review is mandatory;
3. Owner acceptance is mandatory before a dependent task can be dispatched;
4. acceptance of a design never authorizes implementation;
5. acceptance of an implementation never authorizes client integration or deployment;
6. a missing upstream revision, audience, actor, freshness, idempotency, or source binding is a stop condition, not an invitation to infer it;
7. a Track-2/material-fact dependency must retain its exact blocker classification and may not be converted into a default;
8. a runtime/tooling failure may not be converted into a domain outcome;
9. scope drift into another BA domain, compatibility cleanup, analyzer repair, Phase 2, legal closure, or historical Sandbox work stops the task; and
10. no task creates or starts its successor as part of delivery.

## 15. Explicit non-goals of this decomposition

This candidate does not:

- implement or modify backend, API, database, schema, migration, service, queue, worker, deployment, Flutter, Android, test, dependency, or lockfile source;
- select concrete endpoint paths, wire formats, storage engines, tables, keys, vendors, service topology, hosting, subprocessors, or regions;
- perform legal research or legal/data-rights closure;
- decide Match expiry, launch eligibility, identity-assurance threshold, age model, entity role, purpose/legal basis, retention duration, export/delete behavior, peer effect, or historical-access authority;
- inspect private participant, Profile, Conversation, Safety, Report, or Finding data;
- create a public Profile, broaden Showcase, create a Compatibility total score, or merge domain ownership;
- restore tooling, acquire dependencies, run Flutter/Dart/Gradle, repair analyzer findings, remove compatibility debt, start Phase 2, or resume Sandbox/DEP13/B12/M2/M3; or
- merge, self-accept, promote `main`, dispatch a successor, or create an implementation handoff.

## 16. Recommended first successor and completion classification

The first successor after fresh independent acceptance and explicit Owner acceptance of this candidate should be:

`NEXT-BA-01-COMMON-AUTHORITY-EVIDENCE-ENVELOPE-TECHNICAL-DESIGN-V0-1`

It is the only task currently classified `READY_FOR_BOUNDED_TECHNICAL_DESIGN`. Its dispatch must be a new, exact task sheet. BA-02 through BA-07 remain blocked by upstream backend-authority design acceptance or deferred Track-2/material-fact gates as recorded above.

`BACKEND AUTHORITY IMPLEMENTATION-PLANNING DECOMPOSITION ESTABLISHED — BOUNDED SUCCESSOR TASK CHAIN EXPLICIT — TRACK-2/MATERIAL-FACT BLOCKERS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
