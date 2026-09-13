# EliteSync v10｜Backend Common Authority Evidence Envelope Technical Design｜v0.1

Status: `CANDIDATE — BOUNDED SEMANTIC TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Repository: `zcx369658780/EliteSync-v10`

Fresh technical-design base: `428f18f35c645f41da5edfdcfc55d32fbdd3baff`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_BA_01_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_TASK_V0_1.md`

## 1. Purpose and authority boundary

This candidate defines the smallest common semantic contract by which later BA-02 through BA-07 designs may describe authoritative evidence. It defines obligations for binding, provenance, revision, freshness, supersession, permitted actions, correction/revocation, and logical intent. It is deliberately neutral about transport, serialization, storage, services, clocks, caches, deployment, and client implementation.

The common envelope is not a universal business object, lifecycle, state machine, permission token, or authoritative writer. A domain authority authors its own evidence and owns its own revision lineage. Consumers may compare or compose evidence only under the rules below; they cannot merge domain ownership or manufacture a stronger claim.

This design preserves:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- private Conversation != default Match/ranking/training/advertising data
- no globally public MVP Profile authority
- Showcase remains candidate-scoped
- no authoritative Compatibility total score
- loss of authoritative `CN_ACTIVE` or messaging-consent revoke removes new live send authority
- Conversation history is unavailable by default without a separately accepted history authority
- no fake rights capability may be presented

## 2. Contract vocabulary

| Term | Semantic definition |
|---|---|
| Authoritative evidence | A claim authored or affirmed by the domain authority that owns the fact, bound to a defined subject or participants, audience, purpose, revision lineage, and usable-freshness rule. Possession alone does not prove that it is current or usable for a requested action. |
| Authority owner | The domain authority exclusively responsible for validating and authoring the fact or outcome. An authority owner is a semantic responsibility, not a selected service or deployment unit. |
| Subject | The person or domain entity about which an evidence claim is made. The subject is not automatically the requester, actor, participant, or audience. |
| Participant set | The domain-defined set of persons or entities jointly bound by a multi-party fact. Membership does not by itself prove audience, actor role, consent, or permission. |
| Audience | The person, role, or bounded consumer context for which the authority permits the evidence to be disclosed or evaluated. Audience is narrower than technical possession or addressability. |
| Purpose | The accepted use for which evidence may be evaluated. Evidence authorized for one purpose cannot be reused for another merely because its subject or participants match. |
| Actor | The authenticated or otherwise authority-established party requesting or having performed an action. Actor identity alone does not establish actor role or permission. |
| Actor role | The domain-owned role of the actor for the specific aggregate, transition, or evaluation context. Roles such as initiator or recipient are domain extensions, not common-envelope lifecycle roles. |
| Revision | The authority owner's unambiguous position for evidence within one domain-owned lineage. It supports same-lineage currentness and ordering decisions without requiring a numeric value, timestamp, storage primitive, or global order. |
| Supersession | The authority owner's declaration that newer evidence replaces earlier evidence for a specified claim scope in the same lineage. Receipt order and cache order cannot establish supersession. |
| Freshness / usable freshness | The authority-owned condition under which evidence is recent and current enough for a specified audience, purpose, and action. It is evaluated semantically; this contract chooses no duration or clock technology. |
| Stale | Evidence that is outside its usable-freshness condition or cannot satisfy a required freshness check. Stale evidence cannot authorize a new protected action. Display of a prior fact remains separately subject to the owning privacy/consent rule. |
| Unavailable | The authority cannot presently answer or be evaluated. This is an authority-access/presentation condition, not a negative domain outcome. |
| Unknown | The required fact, authority, binding, currentness, or comparison is not established by available authoritative evidence. Unknown is not absent, false, declined, expired, revoked, deleted, or unavailable unless the owning authority separately says so. |
| Authoritative domain outcome | A domain-owned fact that the authoritative writer has validated and authored for its own lifecycle or decision scope. A requested, transmitted, acknowledged, projected, cached, or displayed outcome is not equivalent. |
| Transport acknowledgement / transport state | Evidence only about an attempted exchange, such as accepted for transport, delivered, failed, timed out, or response received. It cannot establish that a domain mutation committed or did not commit. |
| Projection lag | A condition in which a read projection may not yet reflect an authoritative revision known or suspected to exist. Lag is not rollback, absence, rejection, or permission to prefer an older projection. |
| Permitted actions | A descriptive, actor- and context-bound summary of actions the owning domain would presently consider eligible for evaluation. It is not an executable capability, permanent grant, or substitute for validation at mutation time. |
| Correction | New authority-authored evidence that supersedes an earlier erroneous or incomplete claim within the owner's scope. It is not local editing or deletion of history. |
| Revocation | New authority-authored evidence withdrawing a previously authored grant or usable authority within its exact scope. It does not automatically erase history or decide other domains. |
| Logical intent | One domain action the actor means to request, distinguished from the number of transport attempts used to communicate it. |
| Idempotency identity | Authority-evaluable identity binding retries to the same logical intent. It distinguishes a retry from a new intent but does not authenticate the actor, authorize the action, select a key syntax, or guarantee an outcome. |

`STATE VOCABULARY != AUTHORITY`: the labels above classify evidence semantics and evaluation conditions. They are not a universal lifecycle enum and do not replace domain states.

## 3. Evidence claim classes and composition rule

Every use of the envelope must declare the semantic class of the claim being evaluated:

- a domain-authored outcome claim;
- a domain-owned read-projection claim derived from authoritative evidence;
- an authority availability/currentness assessment;
- a transport observation; or
- a projection-delivery/lag observation.

These are claim classes, not wire discriminators or lifecycle states. A consumer must not promote one class into another. In particular, a transport observation cannot become a domain outcome, and a projection observation cannot become a writer.

Evidence from different authority owners has separate lineages. Composition may require several independently valid inputs, but it produces no global revision and no implicit ownership transfer. A composite decision must retain the owner, binding, revision, freshness, and failure state of every required input. One current input cannot repair another stale, unknown, unavailable, or mismatched input.

## 4. Field-obligation matrix

The rows below are semantic concepts, not fields in a JSON object, database record, event, header, token, or public API.

| Common concept | Obligation | Owner | Binds to | Required validation | Revision / freshness rule | Fail-closed behavior | Cannot authorize by itself |
|---|---|---|---|---|---|---|---|
| Authority owner / domain identity | `MANDATORY` | The authoring domain authority | Every authored claim and its lineage | Claimed owner must be the accepted owner of the fact; provenance must be verifiable under a later authorized trust design | Owner remains stable for the lineage; a different owner cannot supersede it | Reject the claim as authoritative when owner or provenance is missing, mismatched, or unestablished | Domain outcome, audience, consent, actor role, or cross-domain ownership |
| Claim class | `MANDATORY` | Authoring owner for authoritative claims; observing layer for non-authoritative observations | The exact claim being evaluated | Must distinguish domain outcome, projection, authority condition, transport observation, and projection observation | Cannot change class merely because a later revision or delivery exists | Do not promote the claim to a stronger class | Any lifecycle result or mutation |
| Subject binding | `MANDATORY` when the claim concerns a subject; otherwise an explicit domain-declared non-subject scope is required | Authoring owner | Exact subject and claim scope | Requested/evaluated subject must match; identity provenance must be established by future authorized trust design | Binding is part of the revision lineage; rebinding creates a different claim context | Withhold protected read/action on missing or mismatched subject | Audience, participation, consent, actor role, or permission |
| Participant set | `CONDITIONALLY MANDATORY` for multi-party facts, grants, transitions, or projections | Authoring domain owner | Exact participant set and domain aggregate | Set membership, cardinality, and role association must satisfy the owning domain contract; subsets and reordered transport representations cannot change semantic membership | Participant change creates a distinct context unless the domain explicitly authors a superseding transition | Deny the multi-party protected use when missing, partial, extra, or mismatched | Mutual consent, audience, active Conversation, or any participant's actor role |
| Audience binding | `MANDATORY` for disclosure, protected read, projection, or action evaluation | Authoring owner | Accepted viewer/consumer role and context | Current requester/consumer must satisfy the exact audience rule; technical possession is irrelevant | Must be re-evaluated with the evidence revision and freshness used for the request | Withhold protected content/action when missing, stale, unknown, or mismatched | Consent, purpose, actor role, mutation, or onward disclosure |
| Purpose binding | `MANDATORY` for every protected use | Authoring owner under accepted product purpose boundaries | Exact use being evaluated | Requested use must equal or be explicitly allowed by the authored purpose; no compatibility or convenience reuse | Purpose cannot broaden through caching, composition, or a newer unrelated claim | Deny the use when missing, unknown, incompatible, or broader than accepted | A different purpose, Match/ranking/training/advertising use, or legal basis |
| Actor identity | `CONDITIONALLY MANDATORY` for actor-specific views and all mutation intents/outcomes | Actor-establishing authority plus owning domain's binding decision | Requesting/performing party in the domain context | Actor identity must be established independently of route/payload/peer identifiers and matched to the domain context | Re-evaluate for the action; an older actor binding cannot outlive superseding domain evidence | Deny actor-specific action or disclosure when absent or mismatched | Actor role, consent, audience, or permission |
| Actor role | `CONDITIONALLY MANDATORY` wherever allowed behavior depends on role | Owning domain authority | Actor, participants, aggregate, action, and revision | Role must be valid for the current domain context and action; do not infer from transport sender or list position | Role must correspond to the revision/freshness used for permitted-action evaluation | Deny the role-dependent action on missing, stale, unknown, or mismatched role | Identity, a different role, or cross-domain permission |
| Revision / lineage position | `MANDATORY` for authoritative outcomes and authoritative projections | Authoring owner | One domain-owned claim lineage | Must support unambiguous same-lineage comparison or explicitly return incomparable/unknown; receipt time is invalid evidence | Only the owner establishes currentness and supersession; no global ordering is required | New protected action is denied if currentness or comparison cannot be established | Freshness, audience, actor permission, or truth outside the claim scope |
| Supersession reference / scope | `CONDITIONALLY MANDATORY` for correction, revocation, replacement, or explicit invalidation | Authoring owner | Prior revision and exact claim scope replaced | Referenced evidence must be in the same owner/lineage and replacement scope must be explicit | New evidence controls only the stated scope; older evidence remains historical, not current authority | Treat prior evidence as unusable for new protected action; ambiguity is `UNKNOWN` | Deletion, erasure, guilt, or another domain outcome |
| Usable-freshness assertion / rule reference | `MANDATORY` for protected reads/actions; display-only uses remain domain-governed | Authoring owner | Evidence revision, audience, purpose, and requested use | Consumer must establish that the current use satisfies the owner's accepted freshness condition | Freshness never overrides a known newer revision; no duration or clock is chosen here | Deny new protected action when missing, stale, unavailable, or not evaluable | Current revision, domain outcome, or permanent permission |
| Authoritative claim payload | `DOMAIN EXTENSION ONLY` | Owning domain authority | Domain-defined fact, outcome, projection, or availability claim | Validate only against that domain's accepted vocabulary and invariants | Must be interpreted with owner, lineage, revision, binding, and freshness | Do not infer a fact when missing or unknown; never borrow another domain's payload | Another domain's lifecycle, relationship truth, guilt, Safety finding, or total Compatibility score |
| Permitted-action evidence | `CONDITIONALLY MANDATORY` when a projection describes next actions | Owning domain authority | Actor, role, subject/participants, audience, purpose, action scope, revision, and freshness | All bindings must match; the writer must independently validate again when an action is requested | Cannot outlive or detach from the evidence revision/freshness it summarizes | Hide/disable the protected action and refresh authority; never execute from cached permission alone | Mutation success, permanent grant, consent, or capability token |
| Correction marker and corrected scope | `CONDITIONALLY MANDATORY` when evidence corrects a prior claim | Owning domain authority | Superseded revision and corrected claim scope | Same-owner/lineage relation and exact scope must be established | Correction is newer authoritative evidence; older claim cannot authorize new action | If correction ordering/scope is unknown, deny dependent protected action | Erasure, legal compliance, or facts beyond corrected scope |
| Revocation marker and revoked scope | `CONDITIONALLY MANDATORY` when a grant is withdrawn | Authority that owns the grant | Superseded grant, subject/participants, audience, purpose, and action scope | Same-owner/lineage relation and revoked scope must be established | Revocation is newer evidence; cached prior grant is unusable for the revoked scope | Immediately deny new action dependent on the revoked grant; history remains separately governed | Historical deletion, peer effect, guilt, Block/Report/Finding, or other-domain revocation |
| Logical-intent / idempotency identity | `CONDITIONALLY MANDATORY` for mutation-capable domain requests and their outcome correlation | Initiating context supplies continuity; owning writer evaluates it | Actor, action kind, target/aggregate, intended semantic input, and domain | Same identity must mean the same logical intent; changed semantic input is not a retry | Compared with authoritative current revision; transport attempts do not create new intent | Do not execute as a new intent when sameness, prior outcome, or current revision is unresolved | Authentication, authorization, ordering, success, or a new business intent |
| Provenance / source-owner binding | `MANDATORY` for any claim treated as authoritative | Authoring owner under a later authorized trust mechanism | Owner, claim class, lineage, and authored evidence | Must distinguish authority-authored evidence from local, route, payload, cache, legacy, notification, or transport assertions | Provenance remains bound across delivery and caching; copying cannot elevate it | Treat unverified or substituted material as non-authoritative | Audience, consent, domain truth, or trust in content beyond its claim |

## 5. Revision and supersession contract

### 5.1 Lineage and ordering

1. Revision ordering is meaningful only within a lineage owned by one domain authority for one defined claim scope.
2. The owner must make same-lineage comparison unambiguous enough to determine `same`, `older`, `newer`, `incomparable`, or `unknown`. These comparison results are semantic relations, not required encoded values.
3. No numeric counter, timestamp, database version, event sequence, global revision, or clock is selected by this contract.
4. Evidence from different owners or lineages is not orderable merely because it arrived earlier/later or carries a visually comparable value.
5. A consumer must not infer currentness from receipt order, transport completion, local write time, cache replacement, or UI rendering order.

### 5.2 Current, stale, and superseded

- **Current** means the owning authority establishes that evidence is the controlling revision for its claim scope and that all required bindings and usable-freshness conditions pass.
- **Stale** means the evidence fails usable freshness or its usable freshness cannot be established. Stale does not necessarily mean superseded.
- **Superseded** means the owner has authored newer controlling evidence for the same claim scope. Superseded evidence may remain historical evidence but cannot authorize a new protected action.
- Evidence may be both stale and superseded. Consumers must retain the distinctions because neither label is a business outcome.
- If the consumer cannot establish whether a newer revision exists, current authority is `UNKNOWN`; a new protected action fails closed.

### 5.3 Correction and revocation

A correction or revocation is new authority-authored evidence in the same owner lineage, with explicit replacement scope. It does not arise from local deletion, hiding, route changes, cache eviction, notification dismissal, transport failure, or a client's state enum.

A correction replaces only the specified claim. A revocation withdraws only the specified grant or use. Neither operation automatically decides retention, erasure, peer visibility, history access, Safety, guilt, Match, Connection, Conversation, or Relationship facts outside its owned scope.

### 5.4 Duplicate, reordered, and lagged delivery

- Re-delivery of the same authored revision changes no domain outcome.
- Delivery of an older revision after a newer one cannot roll authority backward.
- Incomparable or unverifiable revisions do not resolve by “last received wins”; protected use fails closed.
- A projection known to lag a newer authoritative revision cannot authorize a new action and must not overwrite the newer evidence in a consumer's decision context.
- If an authoritative outcome is known but its projection is delayed, the outcome remains distinct from the projection condition. A consumer may present an appropriate loading/stale/unavailable state but cannot invent the projected details.
- Possession of cached older evidence after correction or revocation never defeats the newer authority revision.

## 6. Audience, purpose, subject, participant, and actor binding

Authority evaluation is conjunctive. Every concept required by the owning domain for the requested use must be present, current enough, and mutually consistent. A correct subject with the wrong audience fails. A correct audience with the wrong purpose fails. Participant membership with the wrong actor role fails. One passing binding never substitutes for another.

The following are insufficient alone or in combination:

- route or deep-link identity;
- notification or other payload identity;
- peer or participant identifier;
- an existing row, local record, or cache entry;
- unread count;
- transport connectivity, acknowledgement, delivery, open, or dismissal;
- legacy DTO, provider, state, or behavior;
- compatibility label, factor, or score;
- a candidate, Match, Connection, Conversation, or Relationship identifier without the required current evidence; and
- notification event or delivery state.

Identity can locate a subject for an authority query; it cannot establish that the requester may see, act on, contact, rank, train on, or otherwise use that subject's information. `ROUTE IDENTITY != CONSENT` and identity != audience != purpose != actor role != permission.

## 7. Permitted-action semantics

Permitted-action evidence is an owner-authored explanation of which actions are presently eligible to be submitted for authoritative evaluation. It must be bound to:

- the authority owner and domain;
- subject or participant context;
- audience and purpose;
- actor identity and domain role;
- action scope;
- the authoritative revision summarized; and
- the usable-freshness condition evaluated.

It is not a bearer token and does not reserve a future outcome. Before a mutation, the owning writer must re-evaluate current revision, actor/role, audience/purpose where applicable, transition preconditions, consent gates, and logical-intent identity. If any underlying binding, revision, freshness condition, correction, or revocation changes, the listed action must be treated as non-authorizing and re-evaluated. A cached list cannot outlive, broaden, or detach from its source evidence.

Absence of an action from a projection does not by itself prove a terminal domain outcome; it may reflect privacy minimization, audience, stale evidence, unavailable authority, projection lag, or an unestablished fact.

## 8. Logical intent and idempotency obligations

1. A logical intent represents one actor's one domain action against one domain context. Multiple transport attempts may communicate that same intent.
2. Later mutation-domain designs must make a repeated logical intent distinguishable from a distinct new intent without this common contract choosing any identifier syntax.
3. Idempotency identity must remain bound to the actor, action meaning, target/domain context, and intended semantic input. Reusing it with materially different intent cannot be treated as a retry.
4. A transport timeout or failure does not prove that the intent failed to take effect. When prior outcome is unknown, a consumer must query/reconcile authoritative evidence rather than silently issue a new business intent.
5. Duplicate and reordered requests resolve against the owning authority's current revision and domain preconditions, not arrival order alone.
6. Repeated delivery of an already-authored outcome creates no second outcome.
7. Idempotency identity does not establish actor identity, actor role, audience, purpose, consent, permitted transition, or success.

This contract selects no key format, generation algorithm, retention/expiry period, uniqueness mechanism, transaction strategy, storage, transport header, endpoint, queue, or service.

## 9. Common truth cases and negative examples

| Case | Evidence condition | Required evaluation | Must not infer |
|---|---|---|---|
| Current valid evidence | Owner/provenance, bindings, current revision, and usable freshness all pass for the requested use | The evidence may be evaluated only within its exact domain claim and purpose; mutations still require writer re-validation | Permanent permission or another domain's outcome |
| Superseded evidence | Owner establishes a newer controlling revision for the same scope | Deny new protected action based on the older revision; use the newer evidence when independently valid | Rollback, deletion, or absence |
| Stale evidence | Usable-freshness condition fails or cannot be satisfied | Deny new protected action; any display of prior protected fact requires separate owning gate | Revoked, declined, expired, or absent |
| Authority unavailable | Authority cannot currently answer | Present/propagate unavailable as a non-domain condition and withhold protected use | Negative lifecycle outcome or transport-caused domain failure |
| Authority unknown | Required authoritative fact/currentness is not established | Fail closed and retain `UNKNOWN` | `NONE`, false, deleted, expired, or unavailable |
| Subject mismatch | Evidence subject differs from requested/evaluated subject | Reject for the use | Audience or consent from identifier similarity |
| Participant mismatch | Required participant set is partial, extra, or different | Reject multi-party protected use | Mutual consent, `CN_ACTIVE`, or Conversation grant |
| Audience mismatch | Requester/consumer does not satisfy authored audience | Withhold disclosure/action | Public Profile authority or onward-use permission |
| Purpose mismatch | Intended use differs from authored purpose | Deny reuse | Match/ranking/training/advertising authority from private Conversation evidence |
| Actor mismatch | Actor or domain role differs from the bound permitted-action context | Deny the role-dependent action | Role from route position, payload sender, or participant membership |
| Duplicate logical intent | Same semantic intent is retried | Correlate with current authoritative state; do not create a second business outcome | That retry itself is authorized or succeeded |
| Distinct intent reusing identity | Semantic input/action differs while identity is presented as the same | Reject/fail closed as ambiguous misuse | Safe retry semantics |
| Reordered delivery | Older evidence arrives after newer controlling evidence | Keep newer controlling evidence; do not roll back | “Last received” authority |
| Transport success without authoritative outcome | Transport acknowledges/returns while no owner-authored outcome is established | Outcome remains unknown; reconcile through authority evidence | Mutation success, consent, acceptance, or grant |
| Authoritative outcome with delayed projection | Owner-authored outcome is established but read projection has not caught up | Preserve outcome/projection distinction; do not fabricate projected fields | Outcome rollback or complete projection availability |
| Cached older revision after correction | Cache contains pre-correction evidence | Older claim cannot authorize new action; use newer correction when valid | That cache possession defeats correction |
| Cached older revision after revocation | Cache contains the prior grant | Deny action in revoked scope immediately upon authoritative newer evidence | Continued live send, historical erasure, or peer effect |
| Cannot establish whether newer evidence exists | Revision/currentness check cannot be completed | Treat current authority as unknown and deny new protected action | That the locally newest item is current |
| Notification open with protected target | Delivery/open is known but audience/consent evidence is missing | Re-check the owning authority and fail closed | Audience grant, route authority, or mark-read authority |

## 10. Domain extension boundaries

Later domain designs must add only domain-owned claims and validations. They inherit all common binding, revision, freshness, fail-closed, provenance, and non-substitution obligations.

| Later task/domain | Permitted extension | Ownership boundary that cannot be crossed |
|---|---|---|
| BA-02 Readiness | Subject-bound eligibility, checklist, verification, effective-readiness derivation, correction/revocation, and Readiness projection claims | Readiness is not Match; presentation state is not readiness authority; launch eligibility and identity assurance remain undecided where not accepted |
| BA-03 Match | Match actor/transition, proposal, mutual-acceptance, permitted-action, and canonical projection claims | Match is not Connection; acceptance cannot create Connection consent; exact expiry policy remains `UNKNOWN`; no total Compatibility score |
| BA-04 Connection | Connection participants/roles, exact CN lifecycle transition evidence, and participant projection claims | Recipient acceptance of `CN_PENDING` is the sole consent-establishing transition to `CN_ACTIVE`; Match cannot substitute; Connection is not messaging consent |
| BA-05 Messaging consent / Conversation live gate | Separately owned messaging-consent evidence and a composite evaluation of current `CN_ACTIVE` plus current messaging consent for read/send grants | Neither input substitutes for the other; messaging consent is not Conversation history authority; revisions remain independent |
| BA-06 Home | Privacy-minimal references to independently authorized upstream projections, each retaining owner/revision/freshness | Home is read-only composition, has no lifecycle writer, creates no global revision, and cannot enrich with private Conversation content |
| BA-07 Notification | Domain-event eligibility reference, privacy-minimal presentation authority, delivery-stage observations, and protected-open re-evaluation | Notification is not a lifecycle writer; payload/route/notification identity cannot create audience, consent, or domain success |

No universal lifecycle enum or cross-domain writer is introduced. Relationship remains separate and Phase 2. Block, Report, Finding, Allegation, and immediate protection remain distinct and do not become common-envelope outcomes.

## 11. Track-2 / material-fact blocker and unknown register

The common envelope may carry or evaluate a later accepted claim; it cannot decide the underlying fact or legal authority.

| Unresolved area | Classification | BA-01 treatment |
|---|---|---|
| Launch region(s), establishment/targeting, accountable entity and role map | `BLOCKED_BY_OWNER_MATERIAL_FACT` | No jurisdiction, controller/processor role, or operating assumption is encoded |
| Age/eligibility model and minor-specific posture | `BLOCKED_BY_OWNER_MATERIAL_FACT` | No age field semantics, threshold, verification method, or child-right rule is designed |
| Hosting, subprocessors, localization, and cross-border transfers | `BLOCKED_BY_OWNER_MATERIAL_FACT` | No topology, vendor, region, or transfer fact is selected |
| Purpose-by-purpose lawful basis and region-specific consent effect | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Product purpose binding is preserved but is not presented as legal basis |
| Retention durations, schedules, legal holds, backups, and security-record exceptions | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | Revision/freshness semantics do not define retention or erasure |
| Export/access/portability, deletion/erasure, rights verification/timelines/appeals | `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` | No capability, promise, workflow, outcome, or peer effect is defined |
| Historical Conversation read after revoke/pause/close/Block/account exit | `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE` | History remains unavailable by default absent separately accepted history authority |
| Exact Match expiry duration, clock basis, extension, and policy | `UNKNOWN` | Common revision/freshness concepts do not select Match business expiry |
| Launch eligibility and minimum identity assurance | `UNKNOWN` | BA-02 must preserve explicit seams; no common-envelope default |
| Verification vendor or method | `UNKNOWN` | Provenance obligation does not select an authentication/verification implementation |
| Optional signal allowlist and provenance constraints | `UNKNOWN` | No signal becomes an authority or Compatibility total score through this envelope |

`BLOCKED_BY_OWNER_MATERIAL_FACT` establishes a missing factual input, not a legal conclusion. `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` requires later qualified, jurisdiction-bound closure after material facts exist. No retained item is an implementation blank.

## 12. Design consequences and rejected substitutions

### Accepted design consequences

- Common semantics reduce accidental coupling while every domain retains its writer and revision lineage.
- Composite gates preserve each input's identity, binding, revision, and freshness rather than minting a global authority token.
- Consumers must be able to distinguish non-authoritative observations from authority-authored outcomes.
- Permitted-action displays may become unavailable sooner than a prior domain fact disappears; this is intentional fail-closed behavior.
- Future implementations must choose mechanisms that can uphold these obligations, but no mechanism is selected here.

### Rejected substitutions

- A global revision or timestamp was rejected because it would imply cross-domain ordering and choose clock/version semantics.
- A universal lifecycle/state envelope was rejected because it would merge domain ownership and make presentation vocabulary appear authoritative.
- Route, payload, cache, legacy DTO, and transport identities were rejected as provenance because technical possession is not authority.
- A permanent permission token derived from permitted actions was rejected because authority can be corrected, revoked, superseded, or become stale.
- A client-generated “success” state was rejected because transport success and domain outcome are distinct.
- A single Conversation consent/history grant was rejected because Connection, messaging consent, live read/send, and historical access are separate authorities.

## 13. Verification obligations for independent review

An independent review should verify all of the following from this artifact alone and its exact authorities:

1. every required vocabulary term has a precise, non-implementation definition;
2. the field-obligation matrix records obligation level, owner, binding, validation, revision/freshness, fail-closed behavior, and non-authority for every common concept;
3. current, stale, superseded, unavailable, and unknown remain distinct;
4. subject, participants, audience, purpose, actor, and actor role are conjunctive and fail closed on mismatch;
5. stale/superseded evidence cannot authorize new protected action;
6. correction and revocation require newer owner-authored evidence;
7. permitted actions remain descriptive and revision/freshness-bound;
8. logical intent differs from transport retry and idempotency identity is non-authorizing;
9. all required negative/truth cases are covered without new business policy;
10. BA-02 through BA-07 extension boundaries preserve separate authority owners;
11. Track-2/material-fact blockers and retained unknowns remain explicit;
12. no endpoint, wire format, schema, storage, key syntax, service topology, clock technology, cache, deployment, authentication implementation, client integration, or legal conclusion is selected; and
13. candidate scope is exactly this artifact and `git diff --check` passes.

## 14. Explicit non-goals

This candidate does not:

- define or modify endpoint paths, API surfaces, REST/GraphQL/gRPC/protobuf/JSON formats, schemas, tables, columns, indexes, documents, migrations, storage engines, keys, ID syntax, queues, event buses, services, workers, caches, clocks, authentication, deployment, hosting, vendors, or subprocessors;
- implement or modify backend, client, Flutter, product, test, dependency, lockfile, generated, or global-configuration source;
- create runtime authority, a consent ledger, a read model, a mutation writer, a history authority, a retention/export/deletion service, or a rights capability;
- decide launch regions, entity roles, age model, lawful basis, retention, export, deletion, history, peer effects, hosting/transfers, Match expiry, verification method, or optional-signal policy;
- inspect private participant, Profile, Conversation, Match, Safety, Report, Finding, or telemetry data;
- create a public Profile, broaden Showcase, introduce a Compatibility total score, or merge Match, Connection, Conversation, Relationship, Home, Notification, Block, Report, or Safety ownership;
- remove compatibility debt, repair analyzer findings, acquire dependencies, run Flutter/Dart/Gradle, start Phase 2, or resume Sandbox/DEP13/B12/M2/M3; or
- create BA-02/03/04 task sheets, implement this design, merge, self-accept, or dispatch a successor.

## 15. Completion and stop boundary

This candidate is verifiable through exact source-document review, single-path scope assertions, exact semantic assertions, and `git diff --check`. No runtime, backend, network, dependency, Flutter, Dart, Gradle, private-data, telemetry, or legal-research execution is required or authorized.

`COMMON AUTHORITY EVIDENCE ENVELOPE TECHNICAL DESIGN ESTABLISHED — TRANSPORT/STORAGE NEUTRAL — DOMAIN OWNERSHIP AND TRACK-2 BLOCKERS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

Publication is terminal. It does not authorize implementation, merge, self-acceptance, client integration, or BA-02/03/04 dispatch.
