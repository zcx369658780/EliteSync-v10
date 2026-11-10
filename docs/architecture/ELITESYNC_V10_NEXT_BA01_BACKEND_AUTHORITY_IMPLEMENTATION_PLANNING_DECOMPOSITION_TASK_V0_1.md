# EliteSync v10｜NEXT-BA01 Backend Authority Implementation-Planning Decomposition Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — IMPLEMENTATION-PLANNING DECOMPOSITION ONLY — NO BACKEND IMPLEMENTATION`

Repository: `zcx369658780/EliteSync-v10`

Fresh task-publication authority:

`7b78ba7fec075a9664d25144f78e640fcb296b75`

Owner direction: resume Backend authority/read-model route before analyzer cleanup, compatibility retirement, or Phase 2.

## 1. Objective

Produce one bounded implementation-planning decomposition artifact that converts the already accepted Backend Authority / Read-Model Planning Contract into a sequence of independently authorizable backend authority tasks.

This task does **not** implement backend/API/database/service changes.

It must answer:

- what the smallest safe backend authority task units are;
- their dependency order;
- which tasks can proceed under currently accepted product semantics;
- which tasks are blocked by retained Track-2 legal/data-rights or launch-material facts;
- what exact acceptance evidence each task must produce before the next task can start;
- where client integration or migration must remain later and separate.

The result is a planning/decomposition contract, not a technical design or implementation patch.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_CANDIDATE_V0_1.md`
   - the accepted Track-2 Owner decision/acceptance artifact on `main`
   - `docs/architecture/ELITESYNC_V10_FLUTTER_FULL_SUITE_CONFIRMATION_ACCEPTANCE_AND_REPAIR_CHAIN_CLOSEOUT_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `7b78ba7fec075a9664d25144f78e640fcb296b75`, inspect intervening commits before proceeding. Stop if they materially alter backend authority, Track-2 boundaries, or the Owner-selected next-phase order.

No broad repository enumeration is authorized.

## 3. Binding invariants

Preserve exactly:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- Block != Report
- Report != Finding
- Allegation != Finding
- immediate protection != guilt/punishment
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

Also preserve accepted Track-2 decisions, including:

- Hide / Mute / Pause / Close / Block / Report / Export / deletion request / service erasure / revoke remain semantically distinct;
- revoking messaging consent or loss of `CN_ACTIVE` removes live send authority;
- read-only historical access is not default authority and must be separately established;
- no fake export/delete/revoke capability before backend + legal authority exist;
- private Conversation remains unavailable for unrelated Match/ranking/training/advertising use by default.

Do not convert region-specific or launch-material UNKNOWNs into implementation assumptions.

## 4. Exact backend authority domains to decompose

Use the accepted Track-1 B01-A through B01-F contract as the mandatory input set.

The decomposition must cover at minimum:

### BA-01 — Common authority evidence envelope / revision contract

Plan the smallest shared semantic contract needed for later domain implementations to express:

- subject / participant binding;
- audience and purpose;
- actor role;
- authority revision/version;
- freshness / supersession;
- permitted actions;
- authoritative outcome versus transport state;
- idempotency identity where relevant.

This task unit may define semantic obligations only. It must not select wire protocol, concrete endpoint path, database schema, queue, or service topology unless a later task is explicitly authorized.

### BA-02 — Runtime Readiness authority

Decompose implementation planning for authoritative Readiness facts and projection while preserving:

- eligibility/checklist/verification/presentation separation;
- undecided launch eligibility and minimum identity assurance;
- correction/revocation implications that depend on Track-2 or region-specific authority.

### BA-03 — Canonical Match mutation + durable lifecycle authority

Decompose planning for:

- enrollment/pause/withdrawal;
- proposal issuance/accept/decline/withdraw/expiry representation;
- mutual-acceptance evidence;
- idempotency/concurrency;
- authoritative `/progress/match` read projection.

Exact proposal expiry duration/rules remain `RETAINED UNKNOWN` and must not be chosen here.

### BA-04 — Product Connection authority

Decompose planning for authoritative reads and mutation evidence for the accepted Connection lifecycle.

Preserve recipient acceptance of `CN_PENDING` as the sole consent-establishing transition to `CN_ACTIVE`; Match mutual acceptance must not substitute for Connection consent.

### BA-05 — Messaging-consent authority + Conversation live gate

Decompose the minimal backend authority required for:

- separate mutual messaging-consent evidence;
- current `CN_ACTIVE` evidence consumption;
- Conversation read/send grants;
- revoke propagation for live access;
- fail-closed behavior on stale/unknown/unavailable evidence.

Do **not** plan or implement historical Conversation read authority, retention jobs, export, deletion, account-exit history, or peer-visibility deletion effects except to mark their explicit downstream blocker dependencies.

### BA-06 — Calm Home live read model

Decompose planning for a privacy-minimal read projection over already-authorized upstream facts.

Home must remain read-only composition and must not become a lifecycle writer or private-content enrichment surface.

### BA-07 — Notification domain-event / payload-generation / delivery authority

Decompose planning for:

- domain event eligibility;
- privacy-minimal payload generation;
- delivery-attempt/result evidence;
- in-app versus lock-screen audience separation;
- fresh audience/consent re-check on protected navigation.

Preserve APP-T12-B01: notification payload identity and route identity never create audience authority.

## 5. Required dependency classification

For each planned backend task, assign exactly one of:

- `READY_FOR_BOUNDED_TECHNICAL_DESIGN` — accepted product/authority semantics are sufficient for a later bounded technical-design task;
- `BLOCKED_BY_OWNER_MATERIAL_FACT` — needs launch/entity/age/hosting/purpose facts;
- `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY` — needs jurisdiction-specific legal/data-right closure;
- `BLOCKED_BY_UPSTREAM_BACKEND_AUTHORITY` — another BA task must exist first;
- `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE` — not part of the current implementation route;
- `UNKNOWN` — evidence insufficient.

Do not use `READY_FOR_BOUNDED_TECHNICAL_DESIGN` as implementation authority.

## 6. Track-2 / material-facts boundary map

The artifact must identify, at minimum, which backend areas are **not** allowed to proceed to technical design until later material facts/region-specific closure exists.

At minimum preserve blockers around:

- historical Conversation access after revoke/pause/close;
- Conversation retention duration/schedules where legal applicability matters;
- export/access/portability semantics and request handling;
- deletion/erasure and peer-visible effects;
- account-exit/data-deletion handling;
- rights request verification/timelines/appeals;
- backups/legal holds/security records where applicable;
- minor/age-specific data rights;
- cross-border/hosting/subprocessor implications where relevant.

Do not perform fresh legal research in BA01 unless a directly accepted source must be re-read for accurate boundary transcription. Do not expand Track 2.

## 7. Required output artifact

Create exactly one new artifact:

`docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`

It must contain at minimum:

1. current authority summary;
2. BA-01 through BA-07 task decomposition;
3. dependency DAG / ordered execution proposal;
4. per-task inputs, outputs, non-goals, and acceptance evidence;
5. per-task dependency classification from Section 5;
6. Track-2/material-facts blocking map;
7. separation of technical design versus implementation versus client integration;
8. explicit source-read requirements for each later task;
9. recommended branch/task identifiers for the first 3–5 successor tasks;
10. stop gates that prevent one backend task from silently starting the next;
11. explicit non-goals;
12. recommended first successor task after independent review and Owner acceptance.

## 8. Planning granularity requirements

Prefer tasks small enough that each can be independently reviewed and accepted.

Do not create one broad task named “implement backend”.

A successor task should have one principal authority responsibility and one reviewable terminal artifact/result.

Where a domain depends on another authority, prefer ordering rather than duplicating ownership.

Suggested likely order to evaluate, but not pre-accept:

`BA-01 common evidence envelope -> BA-02 Readiness and/or BA-03 Match -> BA-04 Connection -> BA-05 messaging-consent/Conversation live gate -> BA-06 Home projection -> BA-07 notification authority`

The candidate may revise this order if the accepted authority contracts support a better dependency structure, but must explain why.

## 9. Explicit exclusions

Do NOT:

- implement backend/API/database/service code;
- create or modify production endpoint specs as if accepted;
- create database schema/migrations;
- change Flutter/product/test source;
- run Flutter/Dart/Gradle tooling;
- acquire dependencies;
- resolve exact Match expiry;
- invent launch regions/entity roles/age model/hosting facts;
- perform new region-specific legal closure;
- implement Conversation retention/export/deletion/history;
- remove compatibility debt;
- start Phase 2 Explore or Relationship support;
- inspect private participant/Profile/Conversation data;
- perform telemetry/analytics or Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- repair analyzer findings;
- change global Browser/model/notification/tooling configuration.

## 10. Delivery and Git boundary

Work on a fresh bounded review/planning branch from verified `main`.

Recommended branch:

`review/next-ba01-backend-authority-implementation-planning-decomposition-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`

Recommended commit message:

`docs: decompose backend authority implementation planning`

Do not merge or self-accept.

## 11. Completion classification

Successful completion should end substantially as:

`BACKEND AUTHORITY IMPLEMENTATION-PLANNING DECOMPOSITION ESTABLISHED — BOUNDED SUCCESSOR TASK CHAIN EXPLICIT — TRACK-2/MATERIAL-FACT BLOCKERS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

Stop after publishing the single planning candidate.
