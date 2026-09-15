# EliteSync v10｜NEXT BA-06 Calm Home Live Read Model Technical Design Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — HIGH-DENSITY TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `185f76c2c877de0d2fb3db81357726c0509ba0e1`

## 1. Authorization and objective

BA-06 is authorized for one bounded semantic/interface technical-design artifact because BA-01 through BA-05 technical designs are now independently accepted. This task is documentary and reversible. It creates no backend implementation, client integration, production, legal, Safety, private-data, processing, deployment, or irreversible external authority.

Objective: define the Calm Home live read-model projection as a privacy-minimal read-only composition over already-authoritative upstream evidence.

Home owns no lifecycle writer and may not invent, repair, rank, merge, or strengthen source-domain facts.

## 2. Required first reads

Fresh-fetch `main` and read `AGENTS.md` first. Then read only these exact authorities:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, composition/binding/revision/freshness/permitted-action sections only
3. `docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`, only projection/effective-readiness consumer boundary
5. `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`, only canonical `/progress/match` projection and actor-action boundary
7. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`, only participant projection / current-state boundary
9. `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
10. `docs/architecture/ELITESYNC_V10_BACKEND_MESSAGING_CONSENT_CONVERSATION_LIVE_GATE_TECHNICAL_DESIGN_V0_1.md`, only live read/send grant and fail-closed boundary
11. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-E and common composition sections only
12. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-06 section only
13. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`
14. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`, Home / Calm State Hub sections only

Do not enumerate directories or broadly search the repository.

If one exact path is missing or accepted provenance cannot be established, record it as a blocker. Continue all independent validation rows that do not depend on the missing object; do not stop after the first ordinary blocker.

## 3. Exact output

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_CALM_HOME_LIVE_READ_MODEL_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

## 4. Required design content

### 4.1 Home ownership and read-only composition

Define Home as a read-only projection/composition owner only.

Home must never:

- write Readiness, Match, Connection, Messaging Consent, Conversation, Relationship, Safety, Profile, or Notification lifecycle facts;
- create a global revision across source domains;
- reinterpret unknown/unavailable/stale as negative outcomes;
- use one valid source to repair another invalid source;
- infer consent or authority from identity, route, cache, payload, or historical display state.

### 4.2 Three-section projection contract

Define exact semantic contracts for:

1. **Current state**
2. **Next decision**
3. **Optional support**

For each, specify:

- source-domain identity;
- source evidence class;
- audience/purpose/subject or participant binding;
- source lineage/revision/currentness/freshness;
- privacy-minimal label/descriptor;
- navigation target only when separately authorized;
- permitted action only as descriptive, non-self-authorizing evidence;
- unavailable/unknown/stale/projection-lag handling;
- forbidden substitutions and forbidden enrichments.

### 4.3 Primary-action selection

Home may surface at most one primary action under the accepted low-density Calm State Hub contract.

Define a deterministic semantic selection rule that:

- selects only among currently source-authorized actor-relevant candidate actions;
- never manufactures urgency, severity, ranking, desirability, recommendation strength, or person-worth;
- does not compare revisions across domains as a global order;
- does not use private Conversation content, Compatibility total scores, hidden Safety evidence, or unaccepted AI signals;
- treats no valid action as equivalent to domain mutation authority;
- produces no primary action if no source-authorized candidate exists.

Do not invent timing SLAs or quantitative priority scores.

### 4.4 Source-by-source composition matrix

Provide explicit rows for at least:

- Readiness current/effective state;
- Match participation/proposal state and actor-relevant action;
- Product Connection current state and actor-relevant action;
- Conversation live-read grant;
- Conversation live-send grant;
- messaging consent current grant where minimally necessary to explain a gate without exposing unrelated detail;
- source unavailable;
- source stale;
- source superseded;
- source unknown;
- source projection lag;
- subject mismatch;
- participant mismatch;
- audience mismatch;
- purpose mismatch.

For each row identify what Home may show, what it must omit, and whether it may participate in primary-action selection.

### 4.5 Privacy-minimality and protected-data boundary

Home must not require or reveal private Conversation content, peer message previews, drafts, unread private details, globally public Profile data, candidate-irrelevant Showcase data, Safety evidence, internal moderation evidence, Compatibility totals, or unrelated analytics/model-training signals.

Where a protected source domain exposes only a grant or coarse state, Home consumes only that coarse authorized evidence.

### 4.6 Cross-domain truth preservation

Explicitly preserve:

- `Match != Connection != Conversation != Relationship`;
- `UNKNOWN != ABSENT`;
- `STATE VOCABULARY != AUTHORITY`;
- `ROUTE IDENTITY != CONSENT`;
- `TRANSPORT FAILURE != DOMAIN OUTCOME`;
- `read grant != send grant`;
- Home composition != new lifecycle;
- primary-action selection != cross-domain ranking authority.

### 4.7 Refresh, lag, and correction propagation

Define how Home reacts when:

- one source publishes a newer revision;
- one source becomes stale;
- one source becomes unavailable;
- a correction/revocation invalidates a previously shown action;
- a source projection lags a known newer revision;
- two source domains update independently;
- transport refresh succeeds without proving source-domain mutation success.

Home must not roll a source backward or synthesize a global transaction.

### 4.8 Empty and partial composition behavior

Define semantics for:

- all sources valid;
- only one valid source;
- several valid and several unavailable sources;
- all sources unavailable;
- all source facts unknown/not established;
- no current actor-relevant action;
- source fact valid for display but too stale/insufficient for mutation guidance;
- displayable historical/coarse fact where action authority is not valid.

Do not collapse partial composition into global product failure.

## 5. High-density validation matrix

The candidate must include **at least 90 independently checkable validation rows**.

Rows must cover, at minimum, these families:

A. Authority ownership and no-writer behavior
B. Subject/participant/audience/purpose binding
C. Per-domain revision/currentness/freshness
D. Current-state composition
E. Next-decision composition
F. Optional-support composition
G. Primary-action selection
H. Privacy-minimality
I. Read-vs-send separation
J. Unknown/unavailable/stale/superseded/lag cases
K. Correction/revocation propagation
L. Partial-source availability
M. Route/cache/notification/legacy substitution attempts
N. Cross-domain non-implication
O. No total-score / no hidden ranking
P. No private Conversation enrichment
Q. No Safety-derived reputation/person-worth use
R. No implementation choice
S. Exact one-file scope and Git hygiene

The matrix must report totals:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

List every retained unknown and every blocker.

Do not stop after the first ordinary retained unknown or ordinary blocker. Complete every independent validation row still evaluable within scope.

## 6. Hard-stop conditions

Hard stop only when one of these occurs:

- fresh `origin/main` does not match the task-publication authority and variance cannot be bounded safely;
- required accepted upstream technical-design provenance is missing such that the core Home composition contract cannot be established;
- completing the design would require inventing a lifecycle, consent rule, legal conclusion, Safety rule, production policy, private-data authority, or implementation mechanism.

Ordinary missing optional/support semantics should be retained as `RETAINED_UNKNOWN` when the core contract remains designable.

## 7. Explicit non-goals

Do not select or implement:

- endpoint/API/wire/schema/table/index/storage/key/service/queue/cache/clock/deployment/auth mechanism;
- Flutter/client changes;
- backend implementation;
- telemetry/analytics/model-training;
- Compatibility total score or ranking system;
- Safety scoring/reputation;
- Relationship lifecycle;
- historical Conversation authority;
- legal/data-right decisions;
- new public Profile/Showcase exposure;
- new notification authority;
- Phase 2;
- Sandbox/DEP13/B12/M2/M3.

## 8. Execution boundary

Recommended branch:

`review/next-ba-06-calm-home-live-read-model-technical-design-v0-1`

Publish exactly the one candidate file, report branch/candidate/sole parent/tree/blob/scope/`git diff --check`, validation totals, retained unknowns and blockers, then STOP.

Expected success classification:

`CALM HOME LIVE READ MODEL TECHNICAL DESIGN ESTABLISHED — READ-ONLY MULTI-DOMAIN COMPOSITION / PRIMARY-ACTION SELECTION / PRIVACY-MINIMALITY EXPLICIT — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
