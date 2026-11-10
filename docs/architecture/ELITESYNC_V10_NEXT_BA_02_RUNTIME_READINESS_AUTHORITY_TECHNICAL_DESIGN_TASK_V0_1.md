# EliteSync v10｜NEXT BA-02 Runtime Readiness Authority Technical Design Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `2c2f235c9def9f1d970e7401fd9e3a69da2d348a`

## 1. Authorization and purpose

Under the Owner-delegated bounded-governance convention, BA-02 is authorized for one bounded semantic/interface technical-design artifact because the accepted BA-01 upstream gate is satisfied and this work is reversible, documentary, architecture/product-layer only, and creates no implementation, production, legal, Safety, private-data, or irreversible external authority.

This task defines the authoritative Runtime Readiness writer/projection contract while preserving the accepted separation among eligibility, required-checklist completion, verification, effective readiness, and presentation state.

This task does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client changes, legal closure, identity-verification vendor selection, age-policy selection, compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only the following exact authorities and bounded sections:

1. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only binding/revision/freshness/correction/revocation/permitted-action rules required by BA-02
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-02 section only
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-A and directly dependent common sections only
7. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only accepted product-invariant / Readiness / Me boundaries needed for this task

If any of these exact authorities references a narrower accepted Runtime Readiness / eligibility / checklist / verification product contract and that exact path can be resolved without broad discovery, that exact source may be read.

Do not enumerate directories or broadly search the repository.

If the exact accepted source needed to resolve a required eligibility/checklist/verification/effective-readiness rule cannot be resolved from these bounded references, preserve the missing-source fact and STOP before inventing a product policy or lifecycle rule.

## 3. Exact output and scope

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

The candidate must define semantic authority obligations only. It must not modify backend/client source, tests, dependencies, lockfiles, generated files, configuration, or any existing accepted artifact.

## 4. Required design content

### 4.1 Authority ownership and fact-class separation

Define the Runtime Readiness authority as the semantic owner of only product-authorized Readiness facts.

Preserve the exact separation among at least:

1. eligibility;
2. required checklist completion;
3. verification state for each applicable fact;
4. effective readiness as a derived authority conclusion only where accepted product rules establish its derivation; and
5. presentation state such as loading / empty / offline / stale / retryable error / unavailable / authority-not-established.

Explicitly prove:

- eligibility != verification;
- checklist completion != verification;
- checklist completion != overall/effective readiness;
- presentation state != Readiness lifecycle/fact authority;
- a client enum/local boolean/route/cache does not create Readiness authority.

### 4.2 Subject, audience, purpose, provenance, revision, freshness

Define the authenticated-subject Readiness evidence contract using BA-01:

- exact subject binding;
- audience and purpose binding;
- authority owner/provenance;
- independent fact-class claim scope;
- authoritative revision/currentness;
- usable freshness;
- correction/revocation/supersession evidence where applicable;
- descriptive permitted actions, if any, as non-self-authorizing evidence only.

Unknown, unavailable, stale, superseded, incomparable, audience-mismatched, purpose-mismatched, subject-mismatched, or provenance-unestablished evidence must fail closed for any protected unlock.

`UNKNOWN != ABSENT` remains binding.

### 4.3 Readiness derivation trace matrix

Provide a trace matrix with one row per accepted Readiness fact class showing:

- authority owner;
- source claim/fact;
- subject binding;
- whether it participates in effective-readiness derivation;
- authoritative prerequisite(s);
- revision/freshness rule;
- correction/revocation behavior;
- what it may unlock or describe;
- what it must not imply.

If accepted authority does not establish the exact derivation of effective readiness, record that derivation as a retained product/source gap and STOP before claiming a complete effective-readiness rule.

Do not invent launch eligibility, minimum identity assurance, verification thresholds, age policy, or regional legal criteria.

### 4.4 Correction, revocation, and supersession

Define how newer Readiness authority evidence supersedes older evidence within the exact owned claim scope.

Cover at minimum:

- corrected eligibility evidence;
- corrected checklist evidence;
- corrected/revoked verification evidence;
- effective-readiness recomputation/invalidation only where its accepted derivation is established;
- stale cached evidence after correction/revocation;
- projection lag after a newer authoritative revision;
- unknown currentness or incomparable revisions.

Older evidence must not remain an unlock token after a newer correction/revocation/superseding revision.

Correction/revocation must not be converted into deletion, erasure, guilt, Safety, or another domain outcome.

### 4.5 Privacy-minimal authenticated-subject read projection

Define the minimum participant/subject-authorized Readiness projection for the authenticated subject, including only fields needed to represent accepted Readiness facts and current actor-relevant next steps.

The projection must:

- preserve separate fact classes rather than collapse them into one boolean;
- expose revision/currentness/freshness sufficient for fail-closed use;
- expose correction/revocation/supersession effects where necessary;
- expose actor-appropriate permitted action/next-step evidence only as descriptive, non-self-authorizing evidence;
- distinguish unknown / unavailable / stale / superseded / projection-lag conditions from domain facts;
- avoid unrelated Profile, Match, Conversation, Relationship, Safety, Compatibility-total, or public-profile enrichment.

### 4.6 Unlock / gate semantics

Define the semantic rule for any feature that consumes Readiness:

- every unlock requires current subject-bound authoritative evidence for each accepted prerequisite;
- stale, superseded, unavailable, unknown, mismatched, or unestablished evidence cannot unlock;
- no client fallback, old projection, local completion flag, route, cache, or optimistic success may substitute for authority;
- transport success != Readiness outcome;
- an unavailable or unknown authority does not mean the user failed eligibility or verification.

Do not authorize or select concrete backend writer behavior, API shape, schema, endpoint, storage, clock, or client implementation.

### 4.7 Material-fact and legal seams

Preserve explicit seams for unresolved matters, including where applicable:

- launch eligibility;
- minimum identity assurance;
- exact verification vendor/method;
- age/eligibility model;
- region-dependent correction/disclosure/retention/appeal rules;
- rights-request handling;
- retention duration;
- hosting/transfer posture;
- purpose-specific lawful basis.

Use the existing classifications where supported:

- `UNKNOWN`;
- `BLOCKED_BY_OWNER_MATERIAL_FACT`;
- `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY`;
- `DEFERRED_POST_MVP_OR_SEPARATE_ROUTE`.

Do not convert a missing fact into a default.

## 5. Required truth / negative cases

Include explicit cases for at least:

- all accepted prerequisite facts current and valid;
- checklist complete but verification unknown;
- verification established but checklist incomplete;
- eligibility unknown;
- stale eligibility;
- corrected verification superseding an older result;
- revoked/corrected prerequisite that had previously contributed to effective readiness;
- subject mismatch;
- audience mismatch;
- purpose mismatch;
- projection lag;
- authority unavailable;
- transport success without authoritative Readiness outcome;
- cached/local completion flag after newer authoritative correction;
- presentation-state `ready`/loaded-looking UI without authoritative readiness evidence.

Every case must preserve `STATE VOCABULARY != AUTHORITY` and `UNKNOWN != ABSENT`.

## 6. Explicit non-goals

This task must not:

- select launch eligibility policy, minimum identity assurance, verification vendor/method, age policy, jurisdiction-specific correction/appeal/retention rules, or legal conclusions;
- define Match, Connection, Messaging Consent, Conversation, Relationship, Safety, or Home/Notification lifecycle authority;
- create a globally public Profile;
- create a Compatibility total score;
- select endpoint/API/wire format/schema/table/index/document/storage engine/key syntax/service/queue/worker/cache/clock/deployment/auth implementation;
- modify Flutter/client behavior;
- inspect private participant/Conversation/Safety data;
- run Flutter/Dart/Gradle/backend/network/private-data/telemetry/legal-research execution;
- implement BA-02;
- create or start BA-03/BA-06/BA-07 as part of delivery.

## 7. Required acceptance evidence

The candidate must contain enough documentary evidence for independent review to verify:

1. eligibility, checklist completion, verification, effective readiness, and presentation state remain distinct;
2. every protected unlock requires current subject-bound authoritative evidence;
3. correction/revocation/supersession prevent older evidence from remaining an unlock token;
4. unknown/unavailable/stale/mismatched evidence fails closed without becoming a negative user outcome;
5. the authenticated-subject projection is privacy-minimal;
6. permitted actions remain descriptive and non-self-authorizing;
7. launch eligibility / minimum identity assurance / age / vendor / regional legal rules remain explicit seams rather than invented defaults;
8. no implementation mechanism is selected;
9. scope is exactly the one authorized document; and
10. `git diff --check` passes.

If an exact accepted source is insufficient for a complete required Readiness derivation/fact rule, the task must stop with a precise missing-source classification instead of fabricating the rule.

## 8. Execution and stop boundary

Create a bounded review branch, recommended:

`review/next-ba-02-runtime-readiness-authority-technical-design-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

After publishing:

- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check` result;
- STOP.

Do not merge or self-accept.
Do not implement BA-02.
Do not start BA-03, BA-06, or BA-07.

Expected terminal classification if fully established:

`RUNTIME READINESS AUTHORITY TECHNICAL DESIGN ESTABLISHED — FACT-CLASS / DERIVATION / CORRECTION / FAIL-CLOSED CONTRACT EXPLICIT — MATERIAL-FACT AND LEGAL SEAMS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`

Expected terminal classification if exact product authority is insufficient:

`BLOCKED_EXACT_RUNTIME_READINESS_SOURCE_INCOMPLETE — RETAINED PRODUCT/MATERIAL-FACT GAP RECORDED — NO RULES INVENTED`
