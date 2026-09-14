# EliteSync v10｜NEXT BA-02 Runtime Readiness Authority Technical Design Redispatch Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-14 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `0cd5d0fadd0d246e7ed7167377f39f63e200dca7`

## 1. Authorization and purpose

Under the Owner-delegated bounded-governance convention, BA-02 Runtime Readiness Authority Technical Design is re-authorized because the previously blocking effective-readiness product/source gap has been independently closed and accepted.

This task is technical design only. It does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client modification, verification vendor/method selection, age policy, launch policy, legal closure, production access, or private-data activity.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first, then only these exact authorities and bounded sections:

1. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_DECISION_SOURCE_CLOSURE_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_RUNTIME_READINESS_DECISION_SOURCE_CLOSURE_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only binding/revision/freshness/correction/revocation/permitted-action rules required by BA-02
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-02 section only
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-A and directly dependent common sections only
7. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only Readiness/Me/product-invariant boundaries needed here

Do not enumerate directories or broadly search the repository.

If a required exact path is missing or its accepted provenance cannot be established, stop and report the missing authority rather than substituting another source.

## 3. Exact output and scope

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_RUNTIME_READINESS_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

The candidate must define semantic authority obligations only and must not modify backend/client source, tests, dependencies, lockfiles, generated files, configuration, or prior accepted artifacts.

## 4. Required design content

### 4.1 Authority ownership and fact-class separation

Define the Runtime Readiness authority owner as a semantic responsibility for product-authorized Readiness claims only.

Keep these classes separate:

- eligibility;
- required checklist completion;
- verification state for an exact fact/scope;
- effective readiness as a recomputable derived authority conclusion; and
- presentation state.

Explicitly preserve:

- eligibility != verification;
- checklist completion != verification;
- checklist completion != effective readiness;
- verification != global identity truth;
- presentation state != Readiness authority;
- effective readiness != launch eligibility;
- `STATE VOCABULARY != AUTHORITY`.

### 4.2 Subject/audience/purpose/provenance contract

Apply BA-01 exactly:

- authenticated-subject binding;
- audience binding;
- purpose binding;
- authority owner/provenance;
- independent fact-claim scopes;
- revision/currentness;
- usable freshness;
- correction/revocation/supersession;
- descriptive permitted actions only where applicable.

Unknown, unavailable, stale, superseded, incomparable, provenance-unestablished, subject-mismatched, audience-mismatched, or purpose-mismatched evidence must fail closed for any protected unlock.

### 4.3 Effective-readiness derivation

Use the accepted BA-02-RD01 rule exactly.

For one exact protected feature/use scope, derive `READY` only when:

1. the applicable prerequisite set and every prerequisite class in it have already been product-authorized for that exact scope;
2. every required prerequisite is independently established by its owning authority;
3. each claim is bound to the authenticated subject and exact audience/purpose;
4. each claim is the current controlling revision in its lineage and satisfies usable freshness; and
5. no required claim is unknown, unavailable, stale, superseded, incomparable, mismatched, not established, or explicitly non-satisfied.

If the applicable prerequisite set itself is unknown or unestablished, `READY` cannot be derived.

The technical design must not add any prerequisite.

### 4.4 Readiness trace matrix

Provide a trace matrix for eligibility, checklist, verification, effective readiness, and presentation state showing:

- claim owner;
- subject binding;
- claim scope;
- whether/how it may participate in a protected-use readiness derivation;
- revision/freshness rule;
- correction/revocation/supersession behavior;
- what it may unlock/describe;
- what it cannot imply.

### 4.5 Correction/revocation/supersession

Define how newer Readiness evidence invalidates older dependent derived conclusions.

Cover at minimum:

- corrected eligibility;
- corrected checklist completion;
- corrected or revoked verification evidence;
- effective-readiness recomputation/invalidation;
- stale cached evidence after correction/revocation;
- projection lag after a newer authoritative revision;
- unknown/incomparable currentness.

Older evidence must not remain an unlock token after a newer correction, revocation, or superseding revision.

Correction/revocation must not be presented as deletion, erasure, guilt, Safety, or another domain outcome.

### 4.6 Privacy-minimal authenticated-subject projection

Define the minimum subject-authorized Readiness projection needed to expose accepted Readiness facts and current next-step/permitted-action evidence.

The projection must:

- keep fact classes separate;
- expose revision/currentness/freshness sufficient for fail-closed evaluation;
- expose correction/revocation/supersession effects where required;
- keep permitted actions descriptive and non-self-authorizing;
- distinguish unknown/unavailable/stale/superseded/projection-lag conditions from domain facts;
- exclude unrelated Profile, Match, Connection, Messaging Consent, Conversation, Relationship, Safety, public-profile, or Compatibility-total enrichment.

### 4.7 Protected-use gate semantics

Every protected unlock requires all currently product-authorized prerequisites for that exact use to satisfy the accepted effective-readiness rule.

No client enum, local completion flag, route, cache, legacy behavior, old projection, optimistic success, or transport acknowledgement may substitute for current authority.

`TRANSPORT SUCCESS != AUTHORITATIVE READINESS OUTCOME` and `UNKNOWN != ABSENT` remain binding.

### 4.8 Retained material/legal seams

Keep these unresolved and outside the design:

- launch eligibility / production launch readiness: `BLOCKED_BY_OWNER_MATERIAL_FACT`;
- minimum identity assurance threshold/policy: `BLOCKED_BY_OWNER_MATERIAL_FACT`;
- jurisdiction-specific sufficiency / verification / legal implications: `BLOCKED_BY_REGION_SPECIFIC_LEGAL_AUTHORITY`;
- verification vendor/method/evidence type;
- age policy;
- region-specific correction/disclosure/retention/appeal/rights rules;
- hosting/transfers;
- lawful basis.

Do not convert any of these into defaults.

## 5. Required truth / negative cases

Include at minimum:

- all authorized prerequisites current and valid;
- prerequisite set itself unknown/unestablished;
- checklist complete but verification unknown;
- verification established but checklist incomplete;
- eligibility unknown;
- stale eligibility;
- corrected verification superseding an older result;
- revoked/corrected prerequisite invalidating previously derived `READY`;
- subject mismatch;
- audience mismatch;
- purpose mismatch;
- projection lag;
- authority unavailable;
- transport success without authoritative Readiness outcome;
- cached/local completion after newer correction;
- ready-looking presentation without authoritative readiness evidence.

Every case must preserve `UNKNOWN != ABSENT` and `STATE VOCABULARY != AUTHORITY`.

## 6. Explicit non-goals

Do not:

- select launch eligibility policy;
- select minimum identity assurance;
- select verification vendor/method/evidence type;
- select age policy;
- select region-specific legal rules;
- define Match, Connection, Messaging Consent, Conversation, Relationship, or Safety lifecycle rules;
- define endpoint/API/wire format/schema/table/index/document/storage engine/key syntax/service/queue/worker/cache/clock/deployment/authentication implementation;
- modify Flutter/client behavior;
- repair analyzer/compatibility debt;
- start Phase 2 or Sandbox/DEP13/B12/M2/M3.

## 7. Acceptance evidence required inside the candidate

The candidate must provide enough documentary evidence for an independent reviewer to verify:

1. all five Readiness fact classes remain distinct;
2. effective readiness follows the accepted RD01 derivation exactly;
3. no prerequisite is silently added;
4. unknown prerequisite-set membership cannot produce `READY`;
5. correction/revocation/supersession invalidates stale dependent `READY` conclusions;
6. unlocks require current subject-bound authoritative evidence for every accepted prerequisite;
7. launch eligibility and minimum identity assurance remain unresolved seams;
8. no implementation mechanism or region-specific fact is selected;
9. candidate scope is exactly the one authorized document; and
10. `git diff --check` passes.

## 8. Execution and stop boundary

Recommended branch:

`review/next-ba-02-runtime-readiness-authority-technical-design-rerun-v0-1`

After publishing the one authorized candidate:

- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, and `git diff --check`;
- STOP.

Do not merge or self-accept.
Do not implement BA-02.
Do not start BA-03, BA-06, or BA-07.

Expected terminal classification:

`RUNTIME READINESS AUTHORITY TECHNICAL DESIGN ESTABLISHED — SCOPE-SPECIFIC EFFECTIVE-READINESS DERIVATION EXPLICIT — MATERIAL/LEGAL SEAMS PRESERVED — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
