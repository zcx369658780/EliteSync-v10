# EliteSync v10｜Next IP-13I-R9-R1 Canonical Match Terminality / Invalidation and Record-Eligibility Contract Correction Review Task｜v0.1

Status: `OWNER-AUTHORIZED — DOCUMENT-ONLY CORRECTION REVIEW — EXACTLY ONE RESULT DOCUMENT — NO IMPLEMENTATION / NO RUNTIME COMMANDS — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`

Date: 2026-09-20 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base:
`24597e1b4e4ff19e4fea9438dee63566df03c622`

Rejected R9 candidate:
`b03966d09e91430a31a03eecf5d3b8575602357d`

Rejected R9 result blob:
`1f8394b25ee54373bf4d4e8836075b13b8efcbf1`

R9 independent rejection blob:
`14dcd17ebc5f5dc083bdb9c7f8ee2b188ea55a36`

## 1. Objective

Repair only the two unresolved R9 contract defects:

1. terminal derived Match result → dependency invalidation → `UNKNOWN` must not become an IP-13A terminal reopen;
2. the contract must distinguish evaluator outputs that are eligible for persistence from malformed inputs that a future synthetic adapter must reject before evaluator-to-record construction.

Do not redesign the entire Canonical Match schema.

Preserve the sound R9 direction unless the correction review finds a direct contradiction:

- additive derived family;
- record family:
  `CANONICAL_MATCH_PROPOSAL_DECISION_DERIVED_PROJECTION`;
- typed proposal / participation / decision-slot dependencies;
- source-local dependency revisions;
- deterministic non-global correlation identities;
- privacy-minimal derived payload;
- IP-13F unchanged/non-participating;
- no Match/Connection/Consent/Conversation/relationship/launch authority.

R10 remains blocked until R9-R1 is independently accepted.

## 2. Mandatory fresh-base gate

Before substantive review:

1. Read `AGENTS.md` first.
2. Fresh-fetch `origin/main`.
3. Resolve the commit containing this R9-R1 task.
4. Require `origin/main` to equal that task-publication commit exactly.
5. Create one isolated review branch/worktree from exactly that commit.
6. Verify the result path in Section 5 is absent.
7. Verify every fixed input in Section 4.
8. Stop rather than adapt if authority/path/blob differs.

Recommended branch:

`review/next-ip-13i-r9-r1-terminal-invalidation-record-eligibility-correction-v0-1`

No repository enumeration or unrelated source discovery is authorized.

## 3. Controlling defect

The rejected R9 candidate currently requires:

- `bindings.terminal = terminality.derived_terminal`;
- `derived_terminal=true` exactly for:
  `MUTUALLY_ACCEPTED | DECLINED | WITHDRAWN | EXPIRED`;
- invalidation changes classification to `UNKNOWN`;
- `UNKNOWN` currently implies `derived_terminal=false`;
- `proposal_reopened=false` and `lifecycle_reset=false`.

The accepted IP-13A contract rejects a later non-terminal record under a lifecycle identity that already has a terminal record:

`TERMINAL_IDENTITY_REOPEN_REJECTED`.

Therefore the correction must ensure:

`dependency invalidation != proposal reopen`

and:

`classification UNKNOWN after invalidation != lifecycle terminality reset`.

## 4. Exact authorized read scope

Read only:

1. `AGENTS.md`

2. this R9-R1 task

3. R9 task:
   `docs/architecture/ELITESYNC_V10_NEXT_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_TASK_V0_1.md`

4. R9 independent rejection:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_CANDIDATE_INDEPENDENT_REVIEW_V0_1.md`

5. rejected R9 result at exact candidate:
   `docs/architecture/ELITESYNC_V10_IP_13I_R9_CANONICAL_MATCH_RECORD_PROJECTION_CONTRACT_REPAIR_REVIEW_RESULT_V0_1.md`
   from commit
   `b03966d09e91430a31a03eecf5d3b8575602357d`

6. R8 acceptance:
   `docs/architecture/ELITESYNC_V10_IP_13I_R8_POST_R7_NEXT_DOMAIN_VERTICAL_SLICE_SELECTION_REVIEW_ACCEPTANCE_V0_1.md`

7. Canonical Match evaluator:
   `services/backend-laravel/app/Domain/CanonicalMatchProposalDecisionEvaluator.php`

8. Common Authority:
   `services/backend-laravel/app/Domain/CommonAuthorityEvidenceContract.php`

9. IP-13A:
   `services/backend-laravel/app/Domain/InMemoryLogicalPersistenceRepositoryContract.php`

10. IP-13E:
    `services/backend-laravel/app/Domain/PersistenceBoundaryApplicationInterfaceIntegrationContract.php`

11. Runtime Readiness adapter, contrast only:
    `services/backend-laravel/app/Domain/RuntimeReadinessPersistenceApplicationAdapter.php`

Expected fixed blobs:

- `AGENTS.md`:
  `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`
- R9 task:
  `b0208d28b3e39efb7cbafac4a871f7f485a3b1e8`
- R9 rejection:
  `14dcd17ebc5f5dc083bdb9c7f8ee2b188ea55a36`
- rejected R9 result:
  `1f8394b25ee54373bf4d4e8836075b13b8efcbf1`
- R8 acceptance:
  `c79c5011ceaadbd0d18fc7c581eab97d0fa86ff8`
- Canonical Match evaluator:
  `c101657187348dcafa91afbf0b889bc94f0a0bff`
- Common Authority:
  `e98e7db731d41269a7b89e01db12e1a81364751d`
- IP-13A:
  `2877f5804710abf7c8eba87a9d59925ad5cc405d`
- IP-13E:
  `aa9721dfa66fe17eb2314bc9466870d479c07644`
- Runtime Readiness adapter:
  `9547793d1b88103c4e7cdadff3c8cffa7c12a4e5`

No other source read is authorized.

## 5. Exact tracked write scope

Create exactly:

`docs/architecture/ELITESYNC_V10_IP_13I_R9_R1_CANONICAL_MATCH_TERMINALITY_INVALIDATION_AND_RECORD_ELIGIBILITY_CONTRACT_CORRECTION_REVIEW_RESULT_V0_1.md`

No existing file may change.

No code, test, route, persistence/application source or accepted artifact may be modified.

## 6. Required terminality/invalidation decision

Choose exactly one:

### Model A — sticky terminality in materialized derived records

A terminal derived Match lifecycle remains terminal after dependency invalidation even when current classification becomes `UNKNOWN`.

If selected, define exactly:

- how `terminality.derived_terminal` is computed before and after invalidation;
- whether `bindings.terminal` remains `true`;
- what invariant permits `classification=UNKNOWN` together with `derived_terminal=true`;
- how the builder deterministically knows the pre-invalidation terminal state;
- whether any additional payload field is required;
- how exact readback validates the combination.

The model must preserve:
- `proposal_reopened=false`;
- `lifecycle_reset=false`;
- IP-13A terminal guard;
- no global revision.

### Model B — generic invalidation-overlay-only persistence for terminal results

A terminal derived Match record remains stored unchanged. Dependency invalidation does not create a second non-terminal record under the same lifecycle; the generic invalidation overlay marks the stored projection unusable.

If selected, define exactly:

- whether terminal invalidation produces no new Match derived record;
- what happens to payload-level `invalidation` for persisted terminal records;
- whether payload invalidation remains permitted only for non-terminal derived records;
- how dependency identity provenance is retained or explicitly remains unavailable in the persisted terminal projection;
- how a later adapter reports degraded materialization without pretending generic invalidation identifies a domain dependency.

The model must not claim more dependency provenance than the stored evidence contains.

### Model C — blocked

Choose if neither A nor B can preserve evaluator invalidation, no-reopen semantics, and exact persistence truth without another contract change.

Do not implement any model here.

## 7. Required record-eligibility boundary

Define one exact distinction between:

### A. pre-materialization input rejection

Inputs that a future synthetic Canonical Match adapter must reject before constructing a derived record.

At minimum decide treatment of:

- missing/invalid proposal identity;
- invalid participant cardinality;
- empty/invalid protected-use scope;
- malformed Common Authority binding/evidence/revision shape;
- invalid proposal lifecycle literal;
- invalid participation-state literal;
- invalid slot decision literal;
- malformed slot identity/proposal identity/participant identity.

### B. persistable evaluator UNKNOWN result

Structurally valid inputs that the evaluator may truthfully classify `UNKNOWN` and whose result must remain losslessly persistable.

Examples to classify explicitly include:

- current/fresh/source-authority failure;
- unresolved proposal precondition;
- missing participation evidence;
- participation not usable;
- participation prevents acceptance;
- missing decision slot;
- incomparable/conflicting duplicate slot;
- decision-slot currentness/freshness/binding failure;
- conflicting terminal slot decisions;
- dependency invalidation according to the selected terminality model.

The result must state:

`STRUCTURAL_INPUT_REJECTION != DOMAIN_UNKNOWN_DERIVATION`.

## 8. Persisted reason-vocabulary correction

Using Section 7, divide the rejected R9 reason list into:

1. `PRE_MATERIALIZATION_REJECTION_ONLY`
2. `PERSISTED_MATCH_REASON_CATEGORY`

If a reason can never occur after the accepted structural input gate, remove it from the persisted payload vocabulary.

If a reason can occur after the gate and must be persisted, keep its bounded category and exact suffix-reduction rule.

Do not retain impossible categories merely for symmetry with the evaluator.

## 9. Dependency identity uniqueness

Explicitly decide whether materializable input must enforce:

- unique participant identities — already required;
- unique selected slot identity per participant;
- unique selected slot identities across the two participants;
- no collision between proposal identity, participant identities and slot identities when those strings are later used as dependency invalidation identities.

The accepted evaluator invalidation API carries only one opaque `dependency_identity` string and no dependency type.

If cross-type identity collision would make persisted invalidation ambiguous, the future adapter boundary must reject such a materializable input or the contract must add a typed invalidation discriminator.

Do not leave this ambiguous for R10.

## 10. Terminality payload correction

After selecting Model A/B/C, replace only the rejected R9 terminality/invalidation rules that conflict.

Preserve the remaining R9 payload schema unless a directly necessary field change is justified.

The result must explicitly state which rejected-R9 sections/fields are:

- preserved unchanged;
- superseded;
- narrowed.

Do not silently rewrite unrelated identity, privacy, dependency, reason or IP-13E/IP-13F decisions.

## 11. IP-13A compatibility re-check

Choose exactly one:

- `IP13A_ENVELOPE_COMPATIBLE_AFTER_R9_R1_CORRECTION`
- `IP13A_GENERIC_ENVELOPE_REQUIRES_ADDITIONAL_CONTRACT_CHANGE`
- `BLOCKED`

The result must explain how the selected terminality model interacts with:

`TERMINAL_IDENTITY_REOPEN_REJECTED`.

If Model B is selected, explain how generic invalidation overlay remains truthful.

If Model A is selected, explain why an invalidated terminal record still satisfies the terminal lifecycle invariant.

## 12. IP-13E sufficiency re-check

Choose exactly one:

- `IP13E_EXISTING_OPERATIONS_STILL_SUFFICIENT_AFTER_CORRECTION`
- `IP13E_MAPPING_REVIEW_REQUIRED_BEFORE_SUFFICIENCY_DECISION`
- `IP13E_CONTRACT_REPAIR_REQUIRED`

Do not add an evaluator-orchestration method.

## 13. IP-13F disposition

Must remain:

`IP_13F_UNCHANGED_NON_PARTICIPATING`

unless the correction reveals a concrete contradiction, in which case classify the review blocked.

No sixth family.
No Match route.
No HTTP contract.

## 14. R10 gate

R10 is authorized next only if all are fixed:

- terminality/invalidation model;
- materializable-input boundary;
- persisted reason vocabulary;
- dependency identity uniqueness;
- IP-13A compatibility;
- IP-13E sufficiency.

If fixed, next task may return to:

`IP-13I-R10 CANONICAL MATCH DOMAIN-TO-APPLICATION MAPPING REVIEW — DOCUMENT ONLY`

If not fixed, define the exact additional contract repair required instead.

Do not author R10 from this branch.

## 15. Review-only prohibition

Do not run:

- Composer;
- PHPUnit;
- Artisan;
- `route:list`;
- migration;
- generator;
- server;
- HTTP/client command;
- database runtime probe;
- provider/network work;
- production action;
- real/private-data operation.

Do not modify code.

## 16. Result requirements

Record:

- fresh authority;
- branch/candidate/sole parent/tree after publication;
- exact one-path scope;
- all actual read blobs;
- Model A/B/C decision;
- exact corrected terminality/invalidation contract;
- exact materializable-input boundary;
- persisted-vs-rejected reason categories;
- dependency identity uniqueness rules;
- exact superseded/preserved R9 sections;
- IP-13A compatibility;
- IP-13E sufficiency;
- IP-13F disposition;
- exact next task;
- retained non-authorities;
- confirmation no runtime/code action ran;
- fresh independent ACCEPT/REJECT requirement.

Expected success shape:

`IP-13I-R9-R1 REVIEW COMPLETE — CANONICAL MATCH TERMINALITY/INVALIDATION CONTRACT REPAIRED WITHOUT REOPEN — MATERIALIZABLE INPUT BOUNDARY AND PERSISTED UNKNOWN REASONS FIXED — DEPENDENCY INVALIDATION IDENTITY UNAMBIGUOUS — IP-13A/IP-13E/IP-13F DISPOSITIONS RECONFIRMED — R10 GATE RESOLVED — NO IMPLEMENTATION AUTHORIZED — READY FOR FRESH INDEPENDENT REVIEW`

Then STOP.
