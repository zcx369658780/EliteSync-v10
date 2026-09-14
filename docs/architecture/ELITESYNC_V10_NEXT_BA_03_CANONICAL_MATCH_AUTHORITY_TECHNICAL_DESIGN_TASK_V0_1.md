# EliteSync v10｜NEXT BA-03 Canonical Match Authority Technical Design Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `eff3b67b4dd24fca19a02806d9d5c3af9e71d7f3`

## 1. Authorization and purpose

Under the Owner-delegated bounded-governance convention, BA-03 is authorized for one bounded semantic/interface technical-design artifact because BA-01 is accepted, BA-03 is an independently eligible successor lane, and this work is reversible, documentary, architecture/product-layer only, and creates no implementation, production, legal, Safety, private-data, or irreversible external authority.

This task defines the canonical Match mutation authority and durable lifecycle evidence contract consumed by `/progress/match`.

This task does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client changes, Compatibility total-score design, Connection creation, messaging consent, Relationship state, legal closure, analyzer repair, compatibility cleanup, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the following exact authorities and bounded sections:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only binding/revision/freshness/permitted-action/idempotency/composition rules needed by BA-03
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-03 section only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-B and directly dependent common sections only
7. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only accepted Match/product-invariant boundaries needed for this task

If any exact authority references a narrower accepted canonical Match lifecycle/product contract and its exact path can be resolved without broad discovery, that exact source may be read.

Do not enumerate directories or broadly search the repository.

If the bounded accepted authorities are insufficient to determine a complete required Match lifecycle/actor rule, preserve the missing-source fact and STOP before inventing product policy.

## 3. Exact output and scope

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

The candidate must define semantic authority obligations only. It must not modify backend/client source, tests, dependencies, lockfiles, generated files, configuration, or any existing accepted artifact.

## 4. Required design content

### 4.1 Match authority ownership and aggregate identity

Define the Match authority as the sole semantic writer of canonical Match lifecycle outcomes and durable proposal/decision evidence.

Define, without choosing an ID syntax:

- Match aggregate/proposal identity;
- exact participant bindings;
- proposal/decision lineage;
- actor roles for enrollment, pause, withdrawal, proposal issue, accept, decline, proposal withdraw, and expiry representation where already accepted;
- audience/purpose binding for `/progress/match` projection;
- provenance/revision/currentness/freshness obligations inherited from BA-01.

Route identity, candidate card, countdown, compatibility label/factor, legacy DTO, local state, notification identity, transport state, or one participant's action must never become Match authority.

### 4.2 Complete lifecycle and actor/transition matrix

Provide a complete source/action/actor/target matrix for the accepted canonical Match lifecycle.

At minimum, cover the accepted mutation classes:

- enrollment;
- pause;
- withdrawal;
- proposal issuance;
- proposal accept;
- proposal decline;
- proposal withdrawal where accepted;
- expiry representation under an established future policy.

The matrix must identify:

- exact source condition/state;
- action;
- required actor;
- authoritative preconditions;
- target/outcome;
- resulting evidence;
- forbidden substitutes.

If the accepted sources do not establish any required source/target/actor rule, STOP with:

`BLOCKED_EXACT_CANONICAL_MATCH_LIFECYCLE_SOURCE_INCOMPLETE`

rather than inventing the missing transition.

### 4.3 Mutual-acceptance evidence

Define mutual acceptance so that it requires evidence binding:

- the same authoritative proposal;
- the same exact participants;
- each required participant decision;
- each actor role;
- controlling Match revision/currentness;
- usable freshness; and
- the resulting Match-domain transition/outcome.

One participant's acceptance, route identity, countdown, compatibility factor/label, cached projection, legacy DTO, transport acknowledgement, notification, or local boolean cannot establish mutual acceptance.

Mutual Match acceptance must not create Product Connection, Messaging Consent, Conversation, or Relationship authority.

### 4.4 Exact expiry seam

The design must represent expiry as a Match-domain outcome only where an established policy applies, but must preserve exact expiry duration, clock basis, extension rules, and policy as `RETAINED UNKNOWN` unless a separately accepted authority has closed them.

Do not promote a legacy countdown or client timer to canonical Match authority.

Do not choose a clock technology.

### 4.5 Mutation, idempotency, and concurrency

Define semantic mutation obligations including:

- actor/role validation;
- exact participant/proposal/aggregate binding;
- current authoritative revision precondition;
- usable freshness;
- logical-intent/idempotency correlation;
- duplicate retry behavior;
- conflicting/reordered intent handling;
- stale/superseded intent handling;
- correction/revocation within Match scope;
- transport acknowledgement vs authoritative outcome distinction.

Include truth/negative cases for at least:

- duplicate enrollment/pause/withdraw intents;
- duplicate proposal issue intent;
- duplicate acceptance;
- accept vs decline race;
- accept vs proposal-withdraw race where accepted;
- participant decisions arriving in different orders;
- stale client acting on an older proposal revision;
- reordered projection delivery;
- transport timeout after an intent may already have committed;
- changed semantic input under reused idempotency identity;
- actor/participant/proposal mismatch;
- route/countdown/legacy/cache substitution attempt.

All cases must resolve against authoritative current revision and domain preconditions, never client arrival order alone.

### 4.6 Canonical `/progress/match` projection

Define the privacy-minimal Match projection consumed by `/progress/match`, including only accepted Match-domain evidence needed for display and actor-relevant decisions.

At minimum preserve:

- viewer/subject binding;
- canonical Match state/outcome;
- proposal participant/actor-role evidence where applicable;
- mutual-acceptance evidence only when established;
- authority revision/currentness/freshness;
- actor-appropriate permitted actions as descriptive, non-self-authorizing evidence;
- unknown/unavailable/stale/superseded/projection-lag handling;
- reason/factor evidence only where separately product-authorized.

The projection must not expose or manufacture:

- a Compatibility total score;
- Connection consent;
- Messaging Consent;
- Conversation read/send authority;
- Relationship truth;
- guilt, Safety finding, punishment, fraud, deception, or objective incompatibility.

### 4.7 Compatibility and explanation boundary

No authoritative Compatibility total score exists.

If Match evidence contains separately authorized factors or explanations, the design must preserve their source/provenance and exact meaning without summing them into a total score or promoting them to verified truth.

Optional AI/personality/astrology/reference-signal allowlists and provenance constraints remain unresolved unless separately accepted.

### 4.8 Fail-closed and non-substitution behavior

Unknown, unavailable, stale, superseded, incomparable, participant-mismatched, proposal-mismatched, audience-mismatched, purpose-mismatched, actor-role-mismatched, or provenance-unestablished evidence must fail closed for protected Match actions.

`UNKNOWN != ABSENT` and `TRANSPORT FAILURE != DOMAIN OUTCOME` remain binding.

No client enum, local boolean, route, cache, legacy DTO, countdown, compatibility label, notification payload, Home card, or transport acknowledgement may author or restore Match authority.

## 5. Required acceptance evidence inside candidate

The candidate must contain enough documentary evidence for an independent reviewer to verify:

1. Match remains distinct from Connection, Conversation, and Relationship;
2. every accepted mutation class has a complete actor/source/target rule or the task stops on a precise source gap;
3. mutual acceptance binds one proposal, both participants, required actor decisions, revision/currentness/freshness, and resulting Match outcome;
4. one participant/route/countdown/legacy/transport evidence cannot establish mutual acceptance;
5. exact Match expiry policy remains `RETAINED UNKNOWN` unless separately accepted;
6. duplicate/conflicting/reordered intents resolve against authoritative current revision;
7. stale/unknown/unavailable/mismatched evidence fails closed;
8. permitted actions remain descriptive and non-self-authorizing;
9. Match acceptance does not create Connection, Messaging Consent, Conversation, or Relationship authority;
10. no Compatibility total score becomes authoritative;
11. no endpoint/schema/storage/service/client/clock/deployment implementation is selected;
12. scope is exactly the single authorized design artifact; and
13. `git diff --check` passes.

## 6. Explicit non-goals

Do not:

- select exact Match expiry duration/rules/clock basis;
- create Connection, Messaging Consent, Conversation, or Relationship state;
- create a Compatibility total score;
- select optional signal allowlists/provenance policy;
- define endpoint/API/wire/schema/table/index/document/storage/key/service/queue/worker/cache/clock/deployment/auth implementation;
- modify Flutter/client code;
- perform legal research or legal closure;
- inspect private participant/Conversation data;
- run Flutter/Dart/Gradle/backend runtime/network/telemetry work;
- start BA-06 or BA-07.

## 7. Execution and stop boundary

Create a fresh bounded review branch, recommended:

`review/next-ba-03-canonical-match-authority-technical-design-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

After publishing the candidate:

- push the bounded branch;
- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check` result;
- STOP.

Do not merge or self-accept.
Do not implement BA-03.
Do not start BA-06/BA-07.

Expected success classification:

`CANONICAL MATCH AUTHORITY TECHNICAL DESIGN ESTABLISHED — MUTATION / MUTUAL-ACCEPTANCE / REVISION CONTRACT EXPLICIT — EXPIRY POLICY RETAINED UNKNOWN — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

Hard-stop classification when exact accepted Match lifecycle sources are insufficient:

`BLOCKED_EXACT_CANONICAL_MATCH_LIFECYCLE_SOURCE_INCOMPLETE — NO RULES INVENTED`
