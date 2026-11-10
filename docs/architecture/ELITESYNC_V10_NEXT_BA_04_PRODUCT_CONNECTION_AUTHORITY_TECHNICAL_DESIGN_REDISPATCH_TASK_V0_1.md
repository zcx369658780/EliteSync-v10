# EliteSync v10｜NEXT BA-04 Product Connection Authority Technical Design Redispatch Task｜v0.1

Status: `OWNER-AUTHORIZED REDISPATCH — BOUNDED TECHNICAL DESIGN ONLY — LIFECYCLE SOURCE BLOCKER CLOSED — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `f530071b2832e67342f928917badd85977ba3766`

## 1. Authority and purpose

The Owner previously authorized BA-04 bounded technical design. The first BA-04 execution correctly stopped because the exact accepted lifecycle source could not be resolved within the task's bounded reads.

BA-04-SR01 subsequently resolved APP-T06 as the accepted lifecycle source for the existing aggregate/request and identified one retained Owner product-lifecycle gap. The Owner has now closed that gap in:

`docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_POST_TERMINAL_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`

This redispatch authorizes BA-04 technical design only. It does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client integration, legal closure, compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authorities

After fresh-fetching `main`, read `AGENTS.md` first, then only these exact sources unless one explicitly names another exact path needed to interpret its own accepted rule:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-04 and BA-05 sections only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-C and directly dependent B01-D sections only
7. `docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_RESULT_V0_1.md`, sections 3-5 and retained UNKNOWNs only
9. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_LIFECYCLE_SOURCE_RESOLUTION_RESULT_V0_1.md`
10. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_LIFECYCLE_SOURCE_RESOLUTION_ACCEPTANCE_V0_1.md`
11. `docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_POST_TERMINAL_LIFECYCLE_OWNER_DECISION_CLOSURE_V0_1.md`

Do not enumerate directories, broadly search the repository, inspect implementation source, or use current code/tests as lifecycle authority.

## 3. Exact objective

Produce exactly one technical-design candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

The candidate must define the semantic Product Connection authority contract and nothing beyond it.

The accepted state vocabulary remains exactly:

`CN_NONE`, `CN_PENDING`, `CN_ACTIVE`, `CN_PAUSED`, `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED`.

No new lifecycle state may be added.

## 4. Binding lifecycle rules

The design must preserve the accepted APP-T06 direct transitions for one aggregate/request:

| Source | Action | Required actor | Target |
|---|---|---|---|
| `CN_NONE` | request | either eligible candidate acting as initiator/requester | `CN_PENDING` |
| `CN_PENDING` | accept | recipient | `CN_ACTIVE` |
| `CN_PENDING` | decline | recipient | `CN_DECLINED` |
| `CN_PENDING` | withdraw | requester/initiator | `CN_WITHDRAWN` |
| `CN_PENDING` | expire | system under an established expiry policy | `CN_EXPIRED` |
| `CN_ACTIVE` | pause | either connected participant | `CN_PAUSED` |
| `CN_ACTIVE` | close | either connected participant | `CN_CLOSED` |
| `CN_PAUSED` | resume | the participant who paused | `CN_ACTIVE` |
| `CN_PAUSED` | close | either connected participant | `CN_CLOSED` |

Any unlisted direct transition is invalid for that aggregate/request.

Terminality is binding:

- `CN_CLOSED` has no successor for that Connection;
- `CN_DECLINED`, `CN_WITHDRAWN`, `CN_EXPIRED` have no successor for that request.

The Owner-accepted restart rule is also binding:

- a later Product Connection lifecycle MAY be initiated after a terminal outcome if then-current product eligibility/authority permits it;
- it MUST use a new Product Connection aggregate/request context;
- the old terminal aggregate/request is never reopened, resumed, reactivated, or reused as the consent basis;
- the new lifecycle starts through a new `CN_NONE -> CN_PENDING` request path;
- recipient acceptance of that new authoritative `CN_PENDING` is again the sole consent-establishing transition to the new lifecycle's `CN_ACTIVE`.

Do not invent a `reopen`, `reactivate`, `retry-old-request`, or terminal-state reset transition.

Exact expiry duration/policy remains `UNKNOWN`.

## 5. Required technical-design content

The candidate must include:

### 5.1 Ownership / identity / aggregate semantics

Define the Product Connection authority owner as a semantic responsibility, not a service. Define semantic Connection aggregate/request identity obligations without choosing ID syntax or persistence format. Explicitly distinguish old terminal aggregate/request identity from any later new lifecycle identity.

### 5.2 Complete state/source/target/actor matrix

Provide a complete matrix for all accepted direct transitions and explicit forbidden rows for all terminal-state reopening/reset attempts. Include new-lifecycle initiation as creation of a distinct aggregate/request, not as a transition on the old terminal one.

### 5.3 Mutation contract

Define request, accept, decline, withdraw, pause, resume, close, and authority-governed expiry obligations with:

- actor/role validation;
- participant/aggregate binding;
- current authoritative revision precondition;
- freshness/currentness;
- logical-intent/idempotency correlation inherited from BA-01;
- duplicate/retry behavior;
- correction/supersession inside Product Connection ownership;
- transport acknowledgement vs authoritative transition evidence separation.

### 5.4 Concurrency / idempotency truth cases

Cover at minimum:

- duplicate same-intent request;
- duplicate recipient acceptance;
- accept vs decline race;
- accept vs initiator withdrawal race;
- pause vs close race;
- pause vs resume/close sequencing;
- stale client mutation against older revision;
- reordered older/newer projections;
- transport timeout when prior intent may have committed;
- changed semantic input reusing an idempotency identity;
- actor/participant mismatch;
- attempted mutation of terminal old aggregate/request;
- attempted new lifecycle by reusing old aggregate/request identity;
- valid later lifecycle as a new aggregate/request;
- route/legacy/cache/local-state substitution attempts.

Resolve against authoritative current revision and accepted domain rules, never client arrival order alone.

### 5.5 Participant-authorized read projection

Define privacy-minimal read semantics for the requesting participant, including:

- aggregate/request identity reference;
- participant and role binding;
- exact CN state;
- authoritative revision/freshness/currentness;
- actor-appropriate permitted actions as descriptive evidence only;
- terminality and historical identity distinction sufficient to prevent old aggregate reuse;
- unknown/stale/unavailable/superseded/mismatch/projection-lag handling.

Do not define broad historical data-right access; only define the minimum Product Connection evidence needed to distinguish current vs terminal vs new lifecycle authority.

### 5.6 BA-05 downstream boundary

Define only the Product Connection evidence BA-05 may later consume:

- current authoritative participant-bound `CN_ACTIVE` evidence for the current aggregate;
- Product Connection revision/freshness/currentness;
- participant/audience/purpose bindings.

Make explicit:

- `CN_ACTIVE` is necessary but not sufficient for Product Conversation;
- old terminal aggregate/request evidence cannot authorize Conversation;
- a new Connection lifecycle's `CN_ACTIVE` is distinct from any historical prior lifecycle;
- Connection authority never creates messaging consent;
- no historical Conversation authority is defined;
- BA-05 remains a separate technical-design and Owner gate.

### 5.7 Required negative assertions

Explicitly prove that none of the following creates Product Connection authority:

- Match mutual acceptance;
- Match proposal/candidate/compatibility identity;
- route/deep-link identity;
- `eligibleMatch` / `legacyPeer` / stored peer identity;
- local boolean or local mutual-consent truth;
- optimistic UI success;
- existing chat/Conversation row;
- unread count/connectivity;
- notification payload identity;
- transport success/acknowledgement;
- legacy chat behavior;
- Home card/action label;
- prior terminal Connection/request identity;
- prior `CN_ACTIVE` from a closed historical lifecycle.

## 6. Preserved boundaries / non-goals

Do not define or decide:

- backend/API/schema/storage/service implementation;
- concrete identity/key format;
- endpoint/wire format;
- transaction/locking mechanism;
- exact expiry duration/policy;
- messaging-consent authority;
- Conversation live-gate implementation;
- Conversation history/retention/export/deletion/account-exit/peer-visible deletion effect/rights workflow/legal hold/backups/region-specific rights;
- Match or Readiness policy;
- Relationship state;
- Safety finding/guilt/punishment semantics;
- launch regions/entity roles/age model/hosting/transfers/lawful basis/vendors/deployment facts;
- Flutter/client migration or compatibility cleanup;
- analyzer cleanup or Phase 2.

`Match != Connection != Conversation != Relationship` remains binding.

## 7. Exact execution/write boundary

Create a fresh bounded review branch, recommended:

`review/next-ba-04-product-connection-authority-technical-design-rerun-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Do not modify the original BA-04 task, SR01 artifacts, APP-T06 artifacts, source code, tests, dependencies, lockfiles, generated files, or configuration.

No Flutter/Dart/Gradle/backend runtime/network/private-data/telemetry/Safety/legal-research execution is authorized.

## 8. Acceptance evidence and stop boundary

The candidate must allow an independent reviewer to verify:

1. all eight CN states are preserved;
2. the APP-T06 actor/source/target matrix is complete and unchanged;
3. terminal old aggregate/request cannot reopen or reset;
4. later lifecycle is represented only as a new aggregate/request;
5. every new `CN_ACTIVE` still requires recipient acceptance of that new `CN_PENDING`;
6. no direct `CN_NONE -> CN_ACTIVE` exists;
7. concurrency/idempotency resolve against authoritative revision;
8. stale/unknown/unavailable/mismatched evidence fails closed;
9. permitted actions are non-self-authorizing;
10. BA-05 receives only current participant-bound `CN_ACTIVE` evidence, never messaging consent;
11. no implementation mechanism, expiry value, legal conclusion, or region-specific fact is selected;
12. candidate scope is exactly the single authorized artifact;
13. `git diff --check` passes.

After publishing the candidate, STOP.

Do not merge or self-accept.
Do not implement BA-04.
Do not start BA-05.
Do not dispatch BA-02 or BA-03.

Expected classification:

`PRODUCT CONNECTION AUTHORITY TECHNICAL DESIGN ESTABLISHED — COMPLETE ACCEPTED CN LIFECYCLE INCLUDING NEW-AGGREGATE RESTART RULE EXPLICIT — BA-05 DOWNSTREAM EVIDENCE BOUNDARY PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
