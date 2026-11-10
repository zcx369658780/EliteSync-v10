# EliteSync v10｜NEXT BA-04 Product Connection Authority Technical Design Task｜v0.1

Status: `OWNER-AUTHORIZED — BOUNDED TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `81fcbf982d918bc786f99c593e110006301a1dad`

## 1. Owner authorization

The Owner explicitly authorizes BA-04 bounded technical design for Product Connection authority.

This authorization is limited to one semantic/interface technical-design artifact. It does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client integration, legal closure, compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and authority order

After fresh-fetching `main`, read `AGENTS.md` first, then only the following exact authorities unless an accepted document explicitly references a narrower Product Connection source that must be resolved:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-04 and BA-05 sections only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-C and directly dependent B01-D sections only
7. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only the product-invariant / Connection boundaries needed to resolve accepted lifecycle semantics

Do not enumerate directories or broadly search the repository. If an exact accepted Product Connection lifecycle source is referenced by these authorities and its exact path can be resolved without broad discovery, it may be read. If that exact source cannot be resolved within the bounded references, preserve the missing-source fact and do not infer new lifecycle rules.

## 3. Exact objective

Produce exactly one technical-design candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

The candidate must define the semantic authority contract for Product Connection and nothing beyond it.

The accepted Connection state vocabulary is exactly:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

The design must inherit BA-01 common-envelope obligations rather than redefine or weaken them.

## 4. Required design content

The technical design must include, at minimum:

### 4.1 Ownership and identity

Define:

- Product Connection authority owner as a semantic responsibility, not a selected service;
- Connection identity/aggregate semantics without choosing an ID format;
- exact participant-set binding;
- initiator and recipient role binding where applicable;
- subject/audience/purpose/actor-role obligations inherited from BA-01;
- provenance and same-lineage revision obligations.

Identity, route, stored peer, payload identity, Match identity, local row, cache, or legacy chat state must never become Connection authority.

### 4.2 Complete actor/state/transition matrix

Provide a complete matrix covering each accepted source state, target state, allowed actor role, required authoritative preconditions, resulting evidence, and forbidden substitutes.

At minimum, the matrix must make explicit:

- request creation produces `CN_PENDING` with initiator + recipient roles;
- recipient acceptance of the same authoritative `CN_PENDING` request is the sole consent-establishing transition to `CN_ACTIVE`;
- direct `CN_NONE -> CN_ACTIVE` is forbidden;
- initiator withdrawal and recipient decline are distinct transitions/outcomes;
- pause and close are only available from accepted source states and accepted actor roles;
- authority-governed expiry is represented distinctly as `CN_EXPIRED` without inventing policy not already accepted;
- terminal/non-active outcomes do not imply guilt, Safety finding, punishment, fraud, deception, or objective incompatibility.

Do not invent additional state names or collapse Connection with Match, Conversation, or Relationship.

### 4.3 Mutation contract obligations

Define semantic mutation obligations for request, accept, decline, withdraw, pause, close, and expiry handling, including:

- actor/role validation;
- participant/aggregate binding;
- current-revision precondition;
- freshness/currentness requirements;
- logical-intent and idempotency handling inherited from BA-01;
- duplicate retry behavior;
- conflicting/reordered intent handling;
- superseded/stale intent behavior;
- correction/revocation consequences within Product Connection's owned scope;
- distinction between transport acknowledgement and authoritative transition evidence.

Do not choose request syntax, endpoint paths, transaction primitives, key formats, persistence model, queues, locks, or clock technology.

### 4.4 Concurrency and idempotency truth cases

Include explicit truth/negative cases for, at minimum:

- duplicate same-intent request;
- duplicate recipient acceptance;
- accept vs decline race;
- accept vs initiator withdrawal race;
- pause vs close race;
- stale client acting on an older revision;
- reordered delivery of older/newer projections;
- transport timeout after an intent may already have committed;
- retry with changed semantic input under a reused idempotency identity;
- actor/participant mismatch;
- route/legacy/cache substitution attempt.

All cases must resolve against authoritative current revision and domain preconditions, never client arrival order alone.

### 4.5 Authoritative read projection

Define the privacy-minimal participant-authorized Product Connection read projection semantics, including:

- Connection identity reference;
- participant and actor-role view appropriate to the requesting participant;
- exact authoritative CN state;
- authoritative revision and freshness/currentness evidence;
- actor-appropriate permitted actions as descriptive evidence only;
- transition/outcome evidence only to the extent needed by accepted Product Connection semantics;
- unavailable, unknown, stale, superseded, audience-mismatched, participant-mismatched, and projection-lag handling.

Permitted actions must remain non-self-authorizing and require writer revalidation at mutation time.

### 4.6 Downstream BA-05 interface boundary

Define only the semantic evidence BA-05 may later consume from Product Connection:

- current authoritative participant-bound `CN_ACTIVE` evidence;
- independent Product Connection revision/freshness/currentness;
- participant/audience/purpose bindings needed for live-gate evaluation.

Make explicit that:

- `CN_ACTIVE` is necessary but not sufficient for Product Conversation;
- Connection authority does not create messaging consent;
- Connection activation does not create Conversation read/send authority;
- no historical Conversation authority is defined here;
- BA-05 remains a separate technical-design gate even after BA-04 acceptance.

### 4.7 Negative assertions

The candidate must explicitly prove that none of the following can create Product Connection authority:

- Match mutual acceptance;
- Match proposal/candidate/compatibility identity;
- route/deep-link identity;
- `eligibleMatch`;
- `legacyPeer`;
- stored peer identity;
- local boolean or local mutual-consent truth;
- optimistic UI success;
- existing chat/Conversation row;
- unread count or connectivity;
- notification payload identity;
- transport success/acknowledgement;
- legacy chat behavior;
- Home card/action label.

## 5. Preserved blockers and non-goals

This BA-04 design must preserve all accepted Track-2/material-fact boundaries.

It must not define or decide:

- messaging-consent authority or Product Conversation live-gate implementation;
- Conversation historical access, retention, export, deletion, account-exit, peer-visible deletion effect, rights-request workflow, legal hold, backup, or region-specific rights handling;
- Match expiry policy;
- Readiness policy;
- Relationship state;
- Safety guilt/findings/punishment semantics;
- launch regions, entity roles, age model, hosting/transfers, lawful basis, vendors, or deployment facts;
- endpoint/API/wire format/schema/table/index/document/storage engine/key syntax/service/queue/worker/cache/clock/deployment/auth implementation;
- Flutter/client integration or migration;
- compatibility-debt retirement or analyzer cleanup.

`Match != Connection != Conversation != Relationship` remains binding.

## 6. Required acceptance evidence inside the candidate

The candidate must contain enough documentary evidence for an independent reviewer to verify:

1. the exact eight-state Connection vocabulary is preserved without added universal states;
2. the actor/source/target transition matrix is complete for every accepted mutation class;
3. recipient acceptance of the same `CN_PENDING` is the sole transition establishing `CN_ACTIVE`;
4. no direct `CN_NONE -> CN_ACTIVE` path exists;
5. Match/route/legacy/local/transport substitutions are rejected;
6. duplicate/conflicting/reordered intents resolve against authoritative revision;
7. stale/unknown/unavailable/mismatched evidence fails closed;
8. permitted actions are descriptive and non-self-authorizing;
9. decline/withdrawal/expiry remain neutral non-active outcomes rather than Safety/guilt/incompatibility findings;
10. the BA-05 downstream boundary exposes only current participant-bound `CN_ACTIVE` evidence and never messaging consent;
11. no implementation mechanism or region-specific fact is selected;
12. candidate scope is exactly the single authorized technical-design document; and
13. `git diff --check` passes.

## 7. Exact execution and write boundary

Create a fresh bounded review branch, recommended:

`review/next-ba-04-product-connection-authority-technical-design-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Do not modify source code, tests, dependencies, lockfiles, generated files, configuration, other documents, or any previous accepted artifact.

No Flutter/Dart/Gradle/backend runtime/network/private-data/telemetry/Safety/legal-research execution is required or authorized.

## 8. Stop boundary

After publishing the single technical-design candidate:

- push the bounded branch;
- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check` result;
- STOP.

Do not merge or self-accept.
Do not implement BA-04.
Do not create or start BA-05.
Do not dispatch BA-02 or BA-03.
Do not create implementation/client-integration tasks.

Expected terminal classification:

`PRODUCT CONNECTION AUTHORITY TECHNICAL DESIGN ESTABLISHED — EXACT CN LIFECYCLE / ACTOR / REVISION / IDEMPOTENCY CONTRACT EXPLICIT — BA-05 DOWNSTREAM EVIDENCE BOUNDARY PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
