# EliteSync v10｜NEXT-B01 Backend Authority / Read-Model Planning Task｜v0.1

Status: `OWNER-AUTHORIZED TASK SHEET — PLANNING / CONTRACT ONLY — NO BACKEND IMPLEMENTATION`

Repository: `zcx369658780/EliteSync-v10`

Owner authorization basis: Owner approved execution order `Track 1 -> Track 2 -> Track 3` on 2026-09-13 (Asia/Singapore), with Track 1 first.

Fresh authority at task publication:

`fbcec2814558e8ea1a5413462d9e4a4039d72265`

Current MVP closeout authority:

`docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`

Accepted APP-T12 rerun result:

`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`

Accepted APP-T12 rerun acceptance:

`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_ACCEPTANCE_V0_1.md`

## 1. Objective

Produce one bounded architecture/planning artifact that defines the next backend-authority and read-model planning contract required to move EliteSync v10 from an accepted client-side MVP integration contract toward authoritative runtime operation.

This task is planning/contract work only.

It must answer what authority is required, where that authority must originate, what evidence each client surface may consume, what remains fail-closed, what dependencies exist between backend authorities, and which decisions must remain deferred to later Owner/legal/data-rights authority.

It must NOT implement any backend/API/database/service/runtime changes.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `fbcec2814558e8ea1a5413462d9e4a4039d72265`, inspect intervening commits before proceeding. Do not assume this task remains current if the intervening changes materially alter MVP closeout authority or retained-gap categories.

No broad repository enumeration is authorized by this task.

## 3. Binding invariants

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

Do not reopen APP-T03–T12 or APP-T12-B01 without fresh regression evidence.

APP-T12-B01 remains `CLOSED`.

## 4. Exact in-scope backend authority tracks

The planning artifact must cover exactly these six retained backend-authority gaps:

### B01-A — Runtime Readiness authority

Define the required authority contract for an authoritative runtime Readiness source, including:

- authoritative owner of readiness facts;
- distinction between eligibility facts, required checklist completion, verification state, and presentation state;
- minimum evidence the client may consume;
- stale/unknown/unavailable behavior;
- correction/revocation implications that are already product-authorized;
- explicit boundaries where legal/data-rights decisions are still required.

Do not decide launch eligibility or minimum identity assurance if still retained UNKNOWN / separately undecided.

### B01-B — Canonical Match mutation and durable lifecycle authority

Define the authority contract for:

- Match enrollment/pause/withdrawal;
- proposal issuance/accept/decline/withdraw/expiry representation;
- mutual acceptance evidence;
- durable lifecycle writes;
- idempotency/concurrency expectations at the authority-contract level;
- authoritative read projection consumed by `/progress/match`.

Do not choose the exact Match proposal expiry duration/rules. Keep that item `RETAINED UNKNOWN`.

Do not create an authoritative Compatibility total score.

### B01-C — Product Connection authority

Define the authority contract for:

- authoritative Connection reads;
- pending requests;
- initiator/recipient roles where required by the accepted lifecycle;
- recipient acceptance as the consent-establishing transition to `CN_ACTIVE`;
- pause/close/decline/withdraw/expiry semantics at authority-contract level;
- persistence/mutation evidence the client may rely on.

Do not collapse mutual Match into Connection consent.

### B01-D — Conversation runtime authority gate

Define the evidence contract required before Product Conversation can become available/active:

1. authoritative `CN_ACTIVE` evidence;
2. separate authoritative mutual messaging-consent evidence.

Specify:

- what evidence is sufficient;
- what identities are explicitly insufficient (`eligibleMatch`, `legacyPeer`, stored route, peer ID, existing row, unread count, transport connectivity, legacy chat behavior);
- fail-closed behavior when either authority is unknown/unavailable/stale;
- read/send authority separation where necessary.

Do not resolve Conversation retention/export/deletion/revoke/closed-history semantics. Those remain Track 2 / separate legal-data-rights authority.

### B01-E — Home live projection/read-model authority

Define the backend/read-model planning contract for the Calm State Hub without making Home a lifecycle owner.

The artifact must state:

- which already-authorized domain facts may contribute to Home;
- minimum projection fields required for `Current state`, `Next decision`, and `Optional support`;
- how multiple domain authorities are combined without collapsing their semantics;
- stale/unknown/fail-closed behavior;
- privacy-minimal projection requirements;
- prohibition on private/remote enrichment merely to make Home richer.

### B01-F — OS notification delivery / payload-generation authority

Define the authority boundary between:

- domain event eligibility;
- backend payload generation;
- delivery attempt;
- OS delivery result where knowable;
- in-app presentation;
- external/lock-screen privacy-minimal presentation.

Preserve APP-T09/APP-T12-B01 boundaries:

- notification payload identity does not create audience authority;
- route identity does not create consent;
- external copy remains privacy-minimal by default;
- notification transport/delivery state does not become a domain outcome.

## 5. Required output artifact

Create exactly one new planning artifact under `docs/architecture/`:

`ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`

The artifact must contain at minimum:

1. authority-source matrix for B01-A through B01-F;
2. per-domain authoritative writer / authoritative reader / client-consumable evidence;
3. mutation-vs-read-model separation;
4. fail-closed / stale / unavailable behavior;
5. cross-domain dependency graph;
6. consent/audience gates that no technical identity may bypass;
7. retained UNKNOWN and Track-2 legal/data-rights blockers;
8. what can proceed without Track 2 and what must wait for Track 2;
9. explicit non-goals;
10. recommended bounded follow-up task sequence after independent review and Owner acceptance.

The artifact must remain architecture/authority planning. It must not become an API spec, schema design, service decomposition, migration plan, or implementation task.

## 6. Explicit exclusions

Do NOT:

- modify product source;
- implement backend/API/database/service code;
- create database schema or migration;
- design production endpoint details beyond the minimum authority interface semantics needed for this planning contract;
- perform legal research;
- resolve Conversation retention/export/deletion/revoke/closed-history/region-specific rights;
- resolve exact Match proposal expiry;
- infer optional AI/personality/astrology/reference-signal allowlists;
- start Phase 2 Explore;
- start Phase 2 Relationship support;
- remove compatibility debt;
- acquire dependencies;
- restore Flutter package graph;
- run Flutter/Dart/Gradle tooling;
- inspect private participant/Profile/Conversation data;
- perform telemetry/analytics;
- perform Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- repair global Browser/model/notify configuration;
- reopen APP-T12-B01 absent fresh regression evidence.

## 7. Track separation

Owner has approved the sequence:

`Track 1 -> Track 2 -> Track 3`

This task authorizes Track 1 only.

### Track 2 — NOT authorized by this task

Legal/data-rights decision closure will be a separate task after Track 1 planning is independently reviewed/accepted as appropriate.

Track 2 includes at least:

- Conversation retention;
- export;
- deletion;
- revoke;
- closed-history semantics;
- region-specific data-right implementation.

Do not pre-decide them in Track 1.

### Track 3 — NOT authorized by this task

Flutter tooling/package-graph evidence restoration will be a separate task after Track 2 reaches its required decision boundary.

Do not acquire dependencies or repair tooling in Track 1.

## 8. Source-read boundary

Use the accepted MVP authority documents first. Additional source reads are allowed only when narrowly necessary to determine existing contract names/seams needed for the planning artifact.

Do not conduct a broad source audit.

Do not inspect participant/private runtime data.

If current source evidence is insufficient to establish a backend authority fact, classify it as unestablished/unknown and state what future authority/evidence is required. Do not infer implementation reality from client vocabulary.

## 9. Delivery and Git boundary

Work on a fresh bounded review/planning branch from the verified main authority.

Recommended branch:

`review/next-b01-backend-authority-read-model-planning-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`

Do not modify this task sheet.

Recommended commit message:

`docs: add backend authority read-model planning contract`

Publish the candidate branch/commit for independent review.

Do not merge, self-accept, or modify `main`.

## 10. Completion classification

Successful completion should end with a candidate classification substantially equivalent to:

`BACKEND AUTHORITY / READ-MODEL PLANNING CONTRACT ESTABLISHED — NO BACKEND IMPLEMENTATION PERFORMED — TRACK-2 LEGAL/DATA-RIGHTS BOUNDARIES PRESERVED — READY FOR INDEPENDENT REVIEW`

If a required authority cannot be specified without making a retained UNKNOWN or Track-2 legal/data-rights decision, preserve that dependency explicitly rather than filling the gap.

Stop after publishing the planning candidate.
