# EliteSync v10｜NEXT BA-01 Common Authority Evidence Envelope Technical Design Task｜v0.1

Status: `OWNER AUTHORIZED — BOUNDED TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

## 1. Bound authority

Fresh task-publication base:

`9f960f1b2db783b96ddaa31522a4f071561b5186`

Owner authorization:

The Owner explicitly authorizes BA-01 bounded technical design for the Common Authority Evidence Envelope / Revision Contract.

This authorization is limited to documentary semantic technical design. It does not authorize backend/API/database/schema/migration/service/queue/worker/deployment/client implementation or runtime modification.

## 2. Read first and exact source boundary

After fresh-fetching `origin/main` and following `AGENTS.md`, read only the exact authoritative inputs below before substantive design work:

1. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`
4. the accepted Backend Authority / Read-Model planning acceptance artifact corresponding to that contract;
5. `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`
6. the current MVP closeout / current-session handoff only to the extent necessary to preserve accepted invariants and presentation-state vocabulary.

Do not broaden this into a repository-wide source audit. Do not inspect backend/product implementation source unless this task sheet names it; this task intentionally does not.

## 3. Objective

Produce one transport- and storage-neutral semantic technical-design candidate defining the smallest common authority evidence envelope that later BA-02 through BA-07 designs may extend without merging their domain ownership.

The design must cover exactly these common concerns:

- evidence subject / participant binding;
- audience binding;
- purpose binding;
- actor identity and actor role where applicable;
- authority owner/domain identity;
- authority revision and supersession semantics;
- freshness / usability evaluation;
- authoritative outcome versus transport/projection state;
- permitted-action evidence as descriptive, non-self-authorizing evidence;
- correction / revocation as newer authoritative evidence;
- logical-intent / idempotency identity where mutation-capable domains later require it;
- provenance / source-owner binding sufficient to reject local, route, payload, cache, or transport substitution;
- extension rules that preserve Readiness, Match, Connection, Conversation, Home, and Notification as separately owned domains.

## 4. Required terminal artifact

Create exactly one technical-design candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`

The candidate must remain a design contract only and must include at minimum:

### 4.1 Contract vocabulary

Define precise meanings for at least:

- authoritative evidence;
- authority owner;
- subject;
- participant set;
- audience;
- purpose;
- actor;
- actor role;
- revision;
- supersession;
- freshness / usable freshness;
- stale;
- unavailable;
- unknown;
- authoritative domain outcome;
- transport acknowledgement / transport state;
- projection lag;
- permitted actions;
- correction;
- revocation;
- logical intent;
- idempotency identity.

Definitions must preserve `UNKNOWN != ABSENT`, `TRANSPORT FAILURE != DOMAIN OUTCOME`, and `STATE VOCABULARY != AUTHORITY`.

### 4.2 Field-obligation matrix

Provide a field-obligation matrix that identifies for each common concept:

- whether it is mandatory, conditionally mandatory, or domain extension only;
- who owns it;
- what it binds to;
- what validation is required;
- freshness / revision rules;
- fail-closed behavior when missing, stale, unavailable, mismatched, or superseded;
- what the field explicitly cannot authorize by itself.

Do not turn this matrix into a JSON/schema/wire format.

### 4.3 Revision and supersession contract

Define semantic obligations for:

- current versus superseded evidence;
- monotonic or otherwise unambiguous revision ordering without choosing a storage engine or clock technology;
- correction and revocation through newer authoritative evidence;
- duplicate/reordered delivery of already-authored evidence;
- projection lag relative to authoritative revision;
- client/cache possession of an older revision;
- failure to establish whether newer evidence exists.

Stale or superseded evidence must not authorize a new protected action.

### 4.4 Audience / purpose / actor binding

Specify how evidence must remain bound to its accepted subject/participants, audience, purpose, and actor context.

The contract must explicitly reject all of the following as sufficient authority:

- route identity;
- payload identity;
- peer identifier;
- existing row/cache;
- unread count;
- transport connectivity;
- legacy DTO/state;
- compatibility label/score;
- notification delivery/open state.

Identity alone must not become audience, consent, or permission.

### 4.5 Permitted-action semantics

Define permitted-action evidence as a descriptive view over current domain authority, not an independent writer or permanent capability token.

The design must require re-evaluation when the owning domain revision/freshness/audience/actor binding changes, and must not allow a cached permitted-action list to outlive the authority evidence that justified it.

### 4.6 Logical intent / idempotency obligations

Define only the common semantic obligations needed by later mutation domains:

- a repeated logical intent must be distinguishable from a distinct new intent;
- transport retry does not create a new business outcome;
- duplicate/reordered requests must resolve against authoritative current revision;
- idempotency identity must not itself authorize the mutation;
- no concrete key syntax, TTL, storage implementation, endpoint, or service is selected.

### 4.7 Common negative examples / truth cases

Include bounded examples for at least:

- current valid evidence;
- superseded evidence;
- stale evidence;
- unavailable authority;
- unknown authority;
- subject mismatch;
- participant mismatch;
- audience mismatch;
- purpose mismatch;
- actor mismatch;
- duplicate logical intent;
- reordered delivery;
- transport success with no authoritative outcome;
- authoritative outcome with delayed projection;
- cached older revision after newer revocation/correction.

Examples must not invent Readiness, Match, Connection, Conversation, Home, or Notification business policy beyond already accepted contracts.

### 4.8 Domain extension boundaries

Define how later BA-02 through BA-07 may extend this common envelope while retaining their own authority owners.

Explicitly preserve:

- Readiness is not Match;
- Match is not Connection;
- Connection is not messaging consent;
- messaging consent is not Conversation history authority;
- Home is read-only composition and not a lifecycle writer;
- Notification is not a domain lifecycle writer and notification identity does not create audience authority.

No universal lifecycle enum/state machine may be introduced.

### 4.9 Blocker / unknown register

Any unresolved item must retain one of the accepted classifications when applicable:

- `UNKNOWN`;
- `BLOCKED_BY_OWNER_MATERIAL_FACT`;
- `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY`;
- `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE`.

Do not choose or infer:

- launch regions;
- legal entity/role;
- age model;
- lawful basis;
- retention periods;
- export/deletion/history rights;
- hosting/transfer facts;
- exact Match expiry policy;
- verification vendor/method;
- any other region-specific or Owner material fact.

## 5. Mandatory invariants

The candidate must preserve at minimum:

- `Match != Connection != Conversation != Relationship`;
- `UNKNOWN != ABSENT`;
- `DEFERRED != MISSING`;
- `STATE VOCABULARY != AUTHORITY`;
- `ROUTE IDENTITY != CONSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`;
- `CURRENT SOURCE EXISTS != MUST KEEP`;
- private Conversation != default Match/ranking/training/advertising data;
- no globally public MVP Profile authority;
- candidate-scoped Showcase;
- no authoritative Compatibility total score;
- loss of authoritative `CN_ACTIVE` or messaging-consent revoke removes new live send authority;
- Conversation history remains unavailable by default absent a separately accepted history authority;
- no fake rights capability may be shown.

## 6. Explicit non-goals and prohibited choices

Do NOT select, design, or modify any of the following:

- endpoint paths or API surface;
- JSON/protobuf/GraphQL/REST/gRPC wire format;
- database schema/tables/documents/columns/indexes;
- persistence engine;
- revision database primitive/version column/event sequence implementation;
- key/ID syntax;
- queue/event bus/vendor;
- service or microservice topology;
- authentication implementation;
- clock source/technology;
- cache technology;
- deployment topology;
- hosting/region/vendor/subprocessor;
- migration plan;
- Flutter/client integration;
- backend/product/test source;
- dependencies or lockfiles;
- legal conclusion or region-specific rights implementation;
- compatibility cleanup;
- analyzer repair;
- Phase 2;
- Sandbox/DEP13/B12/M2/M3.

Do not create BA-02, BA-03, BA-04, implementation, or client-integration task sheets as part of this task.

## 7. Acceptance criteria

A reviewable BA-01 candidate is complete only if all of the following are explicit:

1. the field-obligation matrix is complete and internally consistent;
2. current/superseded/stale/unavailable/unknown states are semantically distinguishable without using transport status as domain truth;
3. audience/purpose/actor/subject/participant mismatches fail closed;
4. stale or superseded evidence cannot authorize new protected actions;
5. permitted actions are non-self-authorizing and tied to the evidence revision/freshness they summarize;
6. correction/revocation are represented as newer authoritative evidence, not local deletion or route state;
7. idempotency semantics distinguish logical intent from transport retry without choosing implementation details;
8. no route/payload/cache/legacy/notification/transport identity becomes consent, audience, or authority;
9. all six downstream domain families retain separate owners and extension boundaries;
10. Track-2/material-fact/region-specific blockers are preserved, not defaulted;
11. there is no endpoint/schema/storage/service/clock/deployment/client implementation choice;
12. candidate scope contains exactly the authorized technical-design artifact;
13. `git diff --check` passes;
14. candidate is committed and pushed on a bounded review branch with a single parent equal to the task-publication commit;
15. delivery stops for independent review and does not self-accept or dispatch successors.

## 8. Expected branch and final classification

Recommended branch:

`review/next-ba-01-common-authority-evidence-envelope-technical-design-v0-1`

Expected final classification:

`COMMON AUTHORITY EVIDENCE ENVELOPE TECHNICAL DESIGN ESTABLISHED — TRANSPORT/STORAGE NEUTRAL — DOMAIN OWNERSHIP AND TRACK-2 BLOCKERS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

## 9. Stop boundary

After publishing the single candidate artifact and pushing the bounded branch, STOP.

Do not merge, self-accept, implement backend code, modify client source, run unrelated tooling, create successor tasks, or infer BA-02/03/04 authority.