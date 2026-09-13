# EliteSync v10｜NEXT-LDR01 Conversation Legal / Data-Rights Decision-Closure Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — TRACK 2 DECISION / GOVERNANCE ONLY — NO IMPLEMENTATION`

Repository: `zcx369658780/EliteSync-v10`

Owner-authorized sequence: `Track 1 -> Track 2 -> Track 3`.

Track 1 accepted candidate:

`b8f00446e86db8c3afb77f3e9f6f9932a9570ad1`

Track 1 acceptance commit before this task:

`b4d7e4a40ddece22250283a9c767c7f6cb6d0fd6`

Accepted Track 1 artifact:

`docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`

## 1. Objective

Produce one bounded legal/data-rights decision-closure candidate for the retained Conversation/shared-content questions that Track 1 intentionally left unresolved.

This task must separate:

1. product-semantic decisions that can be proposed for Owner acceptance;
2. legal/data-right constraints that can be supported by authoritative public sources;
3. region-specific conclusions that cannot be established until launch geography or other material facts are known;
4. implementation questions that must remain downstream.

This task is decision/governance work only. It does not implement backend, Flutter, API, database, schema, service, retention jobs, export pipelines, deletion workflows, consent systems, or production controls.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `b4d7e4a40ddece22250283a9c767c7f6cb6d0fd6`, inspect intervening commits before proceeding. If they materially alter Track 1 authority or the retained legal/data-right gap register, stop and report the conflict.

No broad repository enumeration is authorized.

## 3. Binding product invariants

Preserve exactly:

- `Match != Connection != Conversation != Relationship`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- Block != Report
- Report != Finding
- Allegation != Finding
- immediate protection != guilt/punishment
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

Conversation access still requires authoritative `CN_ACTIVE` plus separate authoritative mutual messaging consent.

Do not use legal/data-right analysis to collapse these domain boundaries or to invent new runtime authority.

## 4. Exact retained questions in scope

The decision candidate must address exactly these retained Track 2 areas:

### LDR-01 — Conversation retention semantics

Establish a product-level retention decision model distinguishing at minimum:

- active Conversation content;
- Conversation after messaging consent is revoked;
- Conversation after Product Connection is paused;
- Conversation after Product Connection is closed;
- account closure/deletion-request contexts;
- operational/security records where a separate lawful/minimum-necessary basis may exist.

Do not invent a universal retention duration unless authoritative legal/product evidence supports it and the required jurisdiction/material facts are established.

### LDR-02 — Export semantics

Define what the product should mean by an export request, including distinctions between:

- data about the requesting user;
- content authored by the requesting user;
- shared Conversation content involving another participant;
- metadata or system-derived information;
- information that may require redaction, exclusion, or separate treatment.

Do not specify implementation format, endpoint, archive structure, storage job, or service design.

### LDR-03 — Deletion semantics

Separate at minimum:

- hide/remove from local view;
- delete data solely controlled by the requesting user;
- account/data deletion request;
- deletion of shared Conversation content;
- backend erasure obligations where legally applicable;
- records that may need lawful/minimum-necessary preservation.

Do not present `Delete chat` as one ambiguous operation covering all meanings.

### LDR-04 — Revoke semantics

Define what revocation can and cannot mean at product-semantic level for:

- future messaging consent;
- future use of data for an optional purpose;
- already-shared Conversation content;
- previously lawful processing or required operational records.

Do not assume revocation retroactively erases history unless authoritative basis supports that exact conclusion.

### LDR-05 — Closed-history semantics

Produce a decision model for what may remain readable after Conversation and/or Connection closure, explicitly separating:

- ability to send new content;
- ability to read prior content;
- ability to export prior content;
- ability to request deletion;
- retention by the service;
- visibility to the other participant.

Do not infer that `CLOSED` means deleted, invisible, erased, guilty, blocked, or reported.

### LDR-06 — Region-specific data-right implementation boundary

Identify which conclusions are globally safe product principles versus which require launch-region-specific legal authority.

If launch region(s), controller/processor role, age/eligibility model, or other material facts are not established, preserve the corresponding conclusion as `REGION-SPECIFIC AUTHORITY REQUIRED` rather than guessing.

## 5. Research authority and evidence rules

This task authorizes bounded public legal/data-rights research only as necessary to support LDR-01 through LDR-06.

Use primary or authoritative sources whenever available, such as regulator guidance, legislation/regulatory text, official government publications, or official platform/data-protection authority materials.

For every external authority relied upon, record:

- source organization;
- exact URL;
- publication/update date where available;
- access date;
- relevant article/section/guidance heading;
- jurisdiction and applicability;
- what proposition it supports;
- what it does NOT establish for EliteSync.

Do not treat blogs, vendor marketing, law-firm summaries, AI answers, or secondary commentary as final legal authority. Secondary material may be used only to locate primary sources and must not substitute for them.

Do not claim production legal readiness.

Do not infer jurisdiction from repository location, user location, developer location, app-store availability, or historical project assumptions.

## 6. Required decision structure

For each LDR area, classify proposed conclusions using these labels:

- `PRODUCT DECISION CANDIDATE` — a product semantic recommendation for Owner acceptance;
- `SUPPORTED LEGAL CONSTRAINT` — supported by cited authoritative source within its applicability;
- `REGION-SPECIFIC AUTHORITY REQUIRED` — cannot be closed without jurisdiction/material facts;
- `IMPLEMENTATION DEFERRED` — semantics may be decided but implementation remains later;
- `UNKNOWN` — evidence is insufficient and no safe decision should be inferred.

Never convert a legal constraint into an implementation design automatically.

## 7. Required output artifact

Create exactly one new artifact:

`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_CANDIDATE_V0_1.md`

It must contain at minimum:

1. executive decision summary;
2. LDR-01 through LDR-06 decision matrix;
3. product semantics for retention/export/deletion/revoke/closed history;
4. explicit distinction between local-view removal, user-controlled deletion, shared-content rights, account deletion, and service retention;
5. consent-revocation consequences without retroactive assumptions;
6. closed-history state matrix separating send/read/export/delete/service-retention/peer-visibility;
7. authoritative-source evidence table;
8. region-specific applicability/unknown register;
9. impacts on Track 1 B01-D Conversation gate and Privacy Control Center;
10. issues that block later technical design versus issues that do not;
11. exact Owner decisions still required;
12. explicit non-goals;
13. recommended bounded follow-up after independent review/Owner acceptance.

The candidate must not present itself as accepted legal advice or production legal readiness.

## 8. Required decision posture

Prefer privacy-preserving and user-control-preserving semantics where multiple product choices remain legally possible, but do not fabricate rights or obligations.

At minimum, the candidate should test whether the following product principles can be safely recommended while preserving legal caveats:

- closing or pausing communication stops future authority before it implies historical deletion;
- `Mute`, `Pause Conversation`, `Close Conversation`, `Block`, `Report`, `Hide from my view`, `Export`, and `Delete` remain semantically distinct;
- one participant's deletion request does not automatically establish authority to erase another participant's independently held rights or records;
- shared-content deletion must not be represented as guaranteed until its authority is established;
- private Conversation remains unavailable for unrelated Match/ranking/training use by default;
- UI must not offer fake export/delete/revoke capabilities before backend/legal authority exists.

These are questions/recommendation targets, not pre-accepted legal conclusions.

## 9. Explicit exclusions

Do NOT:

- implement backend/API/database/service changes;
- create schemas, migrations, retention jobs, deletion workers, export services, or endpoint specs;
- modify Flutter/product source;
- acquire dependencies;
- restore Flutter tooling/package graph;
- remove compatibility debt;
- start Phase 2 Explore or Relationship support;
- inspect private participant/Profile/Conversation data;
- perform telemetry/analytics;
- perform Safety Operations;
- investigate reports/findings or moderation cases;
- resume Sandbox/DEP13/B12/M2/M3;
- repair global Browser/model/notify configuration;
- decide exact Match proposal expiry;
- decide optional AI/personality/astrology/reference-signal allowlists;
- declare production legal readiness;
- invent launch regions or assume a jurisdiction.

## 10. Track 3 boundary

Track 3 Flutter tooling/package-graph evidence restoration remains subsequent and separate.

This Track 2 task does not authorize:

- `pub get`;
- Flutter/Dart/Gradle execution;
- dependency acquisition;
- package graph restoration;
- emulator/ADB activity;
- global toolchain repair.

Track 3 may be dispatched only after Track 2 reaches its required independent-review/Owner-decision boundary.

## 11. Delivery and Git boundary

Work on a fresh bounded branch from verified `main`.

Recommended branch:

`review/next-ldr01-conversation-data-rights-decision-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_CANDIDATE_V0_1.md`

Recommended commit message:

`docs: add Conversation data-rights decision closure candidate`

Publish the candidate branch/commit for independent review.

Do not merge, self-accept, or modify `main`.

## 12. Completion classification

Successful completion should end substantially as:

`CONVERSATION DATA-RIGHTS DECISION CANDIDATE ESTABLISHED — PRODUCT/LEGAL/REGION-SPECIFIC BOUNDARIES EXPLICIT — NO IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW / OWNER DECISIONS`

If authoritative sources or material facts do not support closure of a question, preserve it as `REGION-SPECIFIC AUTHORITY REQUIRED` or `UNKNOWN` rather than forcing a decision.

Stop after publishing the candidate.
