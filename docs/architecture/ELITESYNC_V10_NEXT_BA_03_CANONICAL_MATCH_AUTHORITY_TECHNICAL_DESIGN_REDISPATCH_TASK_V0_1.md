# EliteSync v10｜NEXT BA-03 Canonical Match Authority Technical Design Redispatch Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TECHNICAL DESIGN ONLY — HIGH-DENSITY VALIDATION REQUIRED — NO BACKEND IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `b3ebffd09366ff770e1ad06a06f6d7b48e99e50c`

## 1. Authorization and purpose

Under the Owner-delegated bounded-governance convention, BA-03 is re-authorized for one bounded semantic/interface technical-design artifact because BA-01 is accepted and BA-03-RD01 has now independently closed the canonical Match participation/proposal lifecycle completeness gap.

This task defines the canonical Match authority contract consumed by `/progress/match`, including nested participation/proposal authority, actor/source/target rules, mutual acceptance, revision/freshness, idempotency/concurrency, projection semantics, and retained expiry/policy seams.

This task does not authorize backend/API/database/schema/migration/service/queue/worker/deployment implementation, endpoint or wire-format selection, Flutter/client changes, Compatibility total-score design, Product Connection creation, Messaging Consent, Conversation authority, Relationship state, legal closure, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3 work.

## 2. Required first reads and exact authority chain

After fresh-fetching `main`, read `AGENTS.md` first. Then read only these exact authorities and bounded sections:

1. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only Match-relevant binding/revision/freshness/permitted-action/idempotency/composition rules
5. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-03 section only
7. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-B and directly dependent common sections only
9. `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_ACCEPTANCE_V0_1.md`
10. `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`, Match sections only
11. `docs/architecture/ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_ACCEPTANCE_V0_1.md`
12. `docs/architecture/ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_RESULT_V0_1.md`, Match lifecycle/presentation sections only
13. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`
14. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`, Match design sections only
15. `docs/decisions/ADR-013-PACING-AND-CANONICAL-MVP-INTERACTION-STATE-GOVERNANCE.md`, Match/pacing sections only

Do not enumerate directories or broadly search the repository. If any exact path is missing, acceptance provenance cannot be established, or a hard authority contradiction is found, record the full conflict set and stop without inventing a replacement rule.

## 3. Exact output and scope

Produce exactly one candidate:

`docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

Write only that file.

The candidate is semantic technical design only. Do not modify backend/client source, tests, dependencies, lockfiles, generated files, configuration, or any existing accepted artifact.

## 4. Required authority model

### 4.1 Nested authority scopes

Define exactly two distinct Match authority scopes:

#### Participation context

Vocabulary:

- `NOT_ENROLLED`
- `ENROLLED`
- `PAUSED`
- `WITHDRAWN`

Binding rules:

- one authenticated participant owns the participation intent for that context;
- `WITHDRAWN` is terminal for that participation-context identity;
- later participation requires a fresh context and fresh enrollment;
- old participation identity, old idempotency identity, cached enrollment, route, legacy state, or presentation cannot reopen the old context.

#### Proposal context

Vocabulary:

- `PENDING`
- `MUTUALLY_ACCEPTED`
- `DECLINED`
- `WITHDRAWN`
- `EXPIRED`

Binding rules:

- one proposal has exactly one distinct proposal identity and exactly two participants;
- each participant has an independent decision slot;
- one-sided acceptance is decision evidence inside `PENDING`, not another universal state;
- `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, and `EXPIRED` are terminal for that proposal identity;
- any later proposal requires a fresh proposal identity and fresh participant decisions.

Participation and proposal revision/idempotency identities must never substitute for each other.

### 4.2 Participation transition matrix

Define the complete participation actor/source/target contract:

- fresh `NOT_ENROLLED -> ENROLLED`: explicit enroll/opt-in by the authenticated participant, only after then-current separately authoritative Match eligibility/readiness prerequisites for that exact use pass;
- `ENROLLED -> PAUSED`: pause by the same participant;
- `PAUSED -> ENROLLED`: resume by the same participant after then-current Match prerequisites pass;
- `ENROLLED -> WITHDRAWN`: participation withdrawal by the same participant;
- `PAUSED -> WITHDRAWN`: participation withdrawal by the same participant;
- historical `WITHDRAWN`: no successor in the same participation identity; later return requires a fresh context.

Concrete eligibility/readiness prerequisite contents remain separately authoritative inputs and must not be invented here.

### 4.3 Proposal issuance and decision matrix

Define the complete proposal contract:

- issue proposal: Match authority/system only;
- prerequisite: both intended participants are currently `ENROLLED` and all then-current separately authoritative Match prerequisites pass;
- current MVP: at most one unresolved proposal per participant;
- result: fresh proposal `PENDING` with two independent undecided decision slots;
- one participant accepts their own slot: remain `PENDING` unless the other slot also contains current acceptance for the same proposal and controlling revision;
- both current acceptances on the same proposal: `PENDING -> MUTUALLY_ACCEPTED`;
- decline: either bound participant may decline under the accepted closure, resolving the proposal to `DECLINED`;
- proposal withdrawal: only as authorized by the accepted closure and Match authority; reason categories remain unresolved unless already product-authorized;
- expiry: `PENDING -> EXPIRED` only when an authoritative future expiry policy applies;
- no direct reset/reopen of terminal proposal identity.

### 4.4 Cross-scope effects

Define the authoritative consequence when participation changes while a proposal is still `PENDING`:

- participation pause or withdrawal makes the affected pending proposal ineligible for further acceptance;
- Match authority authors a newer proposal revision resolving that affected proposal to proposal `WITHDRAWN` under the accepted closure;
- the participant action does not directly become proposal-writer authority;
- no adverse person meaning, guilt, Safety finding, fraud, deception, or objective incompatibility follows.

### 4.5 Mutual-acceptance evidence

Mutual acceptance must conjunctively bind:

- exact proposal identity;
- exact participant set;
- both independent current decision slots;
- both actor identities/roles;
- controlling proposal lineage/revision/currentness;
- usable freshness;
- audience/purpose;
- resulting proposal `MUTUALLY_ACCEPTED` outcome revision.

One participant's acceptance, route identity, candidate card, countdown, Compatibility factor/label, cached projection, notification identity, legacy DTO, local boolean, or transport success is insufficient.

`MUTUALLY_ACCEPTED` creates no Product Connection consent, Messaging Consent, Conversation access, or Relationship authority.

## 5. Revision, currentness, freshness, correction, and permitted actions

Apply BA-01 exactly:

- revisions order only within one Match-owned lineage/scope;
- participation and each proposal retain independent lineages;
- receipt order, UI order, cache order, local write time, countdown, or transport completion cannot establish supersession;
- stale, superseded, incomparable, unknown, unavailable, mismatched, or provenance-unestablished evidence fails closed for protected actions;
- correction/revocation is newer Match-authority evidence in the same scope, never local editing;
- permitted actions are descriptive, actor/context/revision/freshness-bound, and non-self-authorizing;
- every mutation revalidates authoritative current state at write time;
- transport success or timeout is not a Match-domain outcome.

## 6. Idempotency and concurrency truth cases

The design must explicitly cover, at minimum:

1. duplicate enrollment intent;
2. duplicate pause intent;
3. duplicate resume intent;
4. duplicate participation-withdrawal intent;
5. duplicate proposal-issue intent;
6. duplicate one-sided accept;
7. duplicate second acceptance producing mutual acceptance;
8. accept vs decline race;
9. accept vs proposal-withdraw race;
10. accept vs participation pause;
11. accept vs participation withdrawal;
12. pause vs participation withdrawal;
13. proposal expiry vs accept race while expiry policy exists;
14. two participant decisions arriving in either order;
15. delayed old acceptance after decline;
16. delayed old acceptance after proposal withdrawal;
17. delayed old acceptance after expiry;
18. stale client acting on an older proposal revision;
19. reordered projection delivery;
20. transport timeout after mutation may have committed;
21. changed semantic input under reused idempotency identity;
22. actor mismatch;
23. participant mismatch;
24. proposal mismatch;
25. participation-context mismatch;
26. route/countdown/cache/legacy/notification substitution attempt;
27. new proposal attempting to reuse terminal proposal identity;
28. new participation context attempting to reuse historical withdrawn identity.

All conflicts resolve against authoritative current revision/domain preconditions, never client-arrival order alone.

## 7. Canonical `/progress/match` projection

Define a privacy-minimal projection that preserves:

- viewer/subject binding;
- current participation context and its authoritative state;
- current proposal identity/state where applicable;
- participant decision evidence appropriate to the viewer;
- mutual acceptance only when authoritatively established;
- Match authority provenance;
- independent lineage/revision/currentness/freshness for relevant participation/proposal evidence;
- actor-appropriate permitted actions as descriptive only;
- unknown/unavailable/stale/superseded/incomparable/projection-lag conditions;
- product-authorized reason/factor evidence only where separately authorized.

Reconcile accepted `MT_*` projection semantics without treating them as mutation authority:

- `MT_NOT_OPTED_IN` ← participation `NOT_ENROLLED` when valid for the projection;
- `MT_ACTIVE` ← participation `ENROLLED` when no more specific proposal presentation applies;
- `MT_PAUSED` ← participation `PAUSED`;
- `MT_PROPOSAL_PRESENTED` ← current proposal `PENDING` without viewer-side interest already recorded;
- `MT_INTEREST_RECORDED` ← current proposal still `PENDING` with viewer-side current acceptance evidence;
- `MT_MUTUAL_INTEREST` ← proposal `MUTUALLY_ACCEPTED`;
- `MT_DECLINED` ← proposal `DECLINED`;
- `MT_EXPIRED` ← authoritative proposal `EXPIRED`;
- `MT_WITHDRAWN` must retain authority-scope distinction between participation withdrawal and proposal withdrawal;
- `MT_COMPLETED` remains bounded presentation meaning only where separate authoritative evidence supports it; it is not a new mutation state.

No-candidate/loading/offline/timeout/unavailable/stale/retryable-error/projection-lag/service-failure conditions are not Match lifecycle states.

## 8. Retained seams — must remain explicit

The design must retain, not solve:

- exact proposal expiry duration;
- exact clock basis/time authority;
- expiry extension/renewal rules;
- cooldown/re-proposal timing;
- future multi-candidate or higher active/unresolved-proposal limits;
- concrete enrollment/proposal eligibility/readiness prerequisite contents;
- proposal-withdraw reason categories unless already separately authorized;
- future participant decision-retraction mutation distinct from decline/participation withdrawal;
- optional AI/personality/astrology/reference-signal allowlist/provenance policy.

Current MVP remains at most one unresolved proposal per participant as accepted upstream.

## 9. Cross-domain and non-substitution boundary

Explicitly prove that Match authority cannot be created or strengthened by:

- route/deep link;
- candidate card;
- countdown/client timer;
- Compatibility factor/label or any total score;
- local boolean/client enum;
- cache or stale projection;
- legacy DTO/state;
- notification payload;
- transport acknowledgement/success;
- Home card/action label;
- Product Connection/Conversation/Relationship state.

No authoritative Compatibility total score exists.

Match mutual acceptance does not create:

- Product Connection request or consent;
- Messaging Consent;
- Conversation live read/send authority;
- Relationship state;
- guilt, Safety finding, punishment, fraud, deception, or objective incompatibility.

## 10. High-density validation matrix

The candidate must include a validation matrix with **at least 60 independently checkable rows**.

Each row must be classified as exactly one of:

- `PASS`
- `RETAINED_UNKNOWN`
- `BLOCKED`

The matrix must cover all of the following groups:

### A. Authority/provenance
1. exact authority owner;
2. participation identity separation;
3. proposal identity separation;
4. participant binding;
5. audience binding;
6. purpose binding;
7. actor-role binding;
8. revision lineage;
9. freshness;
10. permitted-action non-self-authorization.

### B. Participation lifecycle
11. enroll;
12. pause;
13. resume;
14. withdraw from enrolled;
15. withdraw from paused;
16. withdrawn terminality;
17. fresh participation context after withdrawal;
18. prerequisite seam preservation.

### C. Proposal lifecycle
19. proposal issuance;
20. two decision slots;
21. first acceptance remains pending;
22. second acceptance establishes mutual acceptance;
23. decline;
24. proposal withdrawal;
25. expiry representation;
26. terminal proposal no reopen;
27. fresh proposal identity;
28. current one-unresolved-proposal MVP limit;
29. future multi-candidate limit retained unknown.

### D. Cross-scope effects
30. pause invalidates pending acceptance path;
31. withdrawal invalidates pending acceptance path;
32. Match authority authors proposal withdrawal outcome;
33. no cross-scope ownership transfer.

### E. Mutual acceptance
34. same proposal;
35. both exact participants;
36. both actor decisions;
37. same controlling revision/currentness;
38. freshness;
39. one-sided acceptance insufficient;
40. no Connection creation.

### F. Idempotency/concurrency
41–55. Cover the required truth cases in section 6 with separate rows; more rows may be added.

### G. Projection/non-substitution
56. `MT_*` reconciliation;
57. projection state != authority;
58. countdown not authority;
59. Compatibility total score absent;
60. legacy/cache/route/notification/transport non-substitution.

### H. Retained seams
Add separate rows for every retained seam in section 8.

The candidate must report totals:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

and must list every retained unknown and every blocker explicitly.

Do not stop after the first ordinary retained unknown. Continue through the complete matrix unless a hard authority contradiction makes further work invalid or unsafe.

## 11. Required acceptance evidence

An independent reviewer must be able to verify from the candidate that:

- nested participation/proposal lifecycle is complete;
- actors and source/target rules are explicit;
- one-sided acceptance cannot become mutual acceptance;
- mutual acceptance cannot create downstream consent/access domains;
- terminal identities cannot reopen;
- new contexts/proposals require fresh identities and decisions;
- all concurrency/idempotency cases resolve against authoritative current revisions;
- exact expiry/timing/future-policy seams remain unresolved rather than guessed;
- canonical projection stays privacy-minimal and non-authoritative;
- no Compatibility total score appears;
- no endpoint/schema/storage/service/client/clock/deployment implementation is selected;
- exact scope is the single authorized artifact;
- `git diff --check` passes;
- validation totals and complete retained/blocker lists are present.

## 12. Execution and stop boundary

Create a fresh bounded review branch, recommended:

`review/next-ba-03-canonical-match-authority-technical-design-rerun-v0-1`

Write only:

`docs/architecture/ELITESYNC_V10_BACKEND_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_V0_1.md`

After publishing the candidate:

- push the bounded branch;
- report branch, candidate commit, sole parent, tree, artifact blob, exact scope, `git diff --check`, validation totals, all retained unknowns, and all blockers;
- STOP.

Do not merge or self-accept.
Do not implement BA-03.
Do not start BA-06/BA-07.

Expected success classification:

`CANONICAL MATCH AUTHORITY TECHNICAL DESIGN ESTABLISHED — NESTED PARTICIPATION/PROPOSAL AUTHORITY + MUTUAL ACCEPTANCE + REVISION/IDEMPOTENCY CONTRACT EXPLICIT — HIGH-DENSITY VALIDATION COMPLETE — EXPIRY/TIMING POLICY RETAINED UNKNOWN — NO BACKEND IMPLEMENTATION PERFORMED — READY FOR INDEPENDENT REVIEW`
