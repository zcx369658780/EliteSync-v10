# EliteSync v10｜Canonical Match Lifecycle Completeness Closure｜v0.1

Status: `PRODUCT/SOURCE-CLOSURE CANDIDATE — FULL AUTHORIZED MATRIX COMPLETE — INDEPENDENT REVIEW REQUIRED — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication commit: `1e968a80427aa4e67821e6ef941e890b8e2ab2d5`

Task blob: `353feab99db44ceff23e1ec59b0160a56f7c4388`

## 1. Purpose, result, and boundary

This artifact completes the full bounded BA-03-RD01 product/source closure matrix. It resolves the canonical Match participation and proposal lifecycle semantics needed for a later separately authorized BA-03 technical design. It does not itself technically design or implement a writer, API, schema, storage, service, endpoint, client, clock, matching algorithm, or production policy.

No accepted-source conflict was found. Where the accepted sources established product meaning, this artifact records `SOURCE_RESOLVED`. Where they deliberately left mutation authority incomplete, this artifact applies only the numbered Owner-delegated rules in the task sheet and records `OWNER_DELEGATED_RULE`. Timing and other expressly deferred choices remain `RETAINED_UNKNOWN`.

Validation totals for the required 40-check matrix are:

| `PASS` | `RETAINED_UNKNOWN` | `BLOCKED` |
|---:|---:|---:|
| 39 | 1 | 0 |

## 2. Exact source provenance

All source objects below were resolved at fixed `origin/main` commit `1e968a80427aa4e67821e6ef941e890b8e2ab2d5`.

| Key | Exact path | Blob / accepted provenance | Bounded use |
|---|---|---|---|
| S1 | `docs/architecture/ELITESYNC_V10_NEXT_BA_03_RD01_CANONICAL_MATCH_LIFECYCLE_COMPLETENESS_CLOSURE_TASK_V0_1.md` | blob `353feab99db44ceff23e1ec59b0160a56f7c4388` | Owner-delegated closure authority, required questions, truth cases, and high-density matrix. |
| S2 | `docs/architecture/ELITESYNC_V10_NEXT_BA_03_CANONICAL_MATCH_AUTHORITY_TECHNICAL_DESIGN_TASK_V0_1.md` | blob `7982cc79430c1cffe8115f02045bf1bfba5b4830` | Records the complete-lifecycle source gap and the later BA-03 design boundary. |
| S3 | `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_ACCEPTANCE_V0_1.md` | blob `565e425aa3550bb64a82c70ff08a107a896669a3`; accepts result blob `c448662bee3f452eb535f298c76388e5565717a4` | Establishes accepted BA-01 provenance and non-substitution/fail-closed boundary. |
| S4 | `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md` | blob `c448662bee3f452eb535f298c76388e5565717a4` | Binding, revision, freshness, permitted-action, idempotency, correction, and composition rules. |
| S5 | `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_ACCEPTANCE_V0_1.md` | blob `9ac039e2d2b20e9eef3a03eeded53f5583fc9a49`; accepts result blob `a8404b3066680f37e9ff94bcfd705ed414cb8d07` | Establishes accepted BA-03 decomposition provenance. |
| S6 | `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md` | blob `a8404b3066680f37e9ff94bcfd705ed414cb8d07` | Names BA-03 mutation classes, mutual-acceptance obligations, projection, and expiry seam. |
| S7 | `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md` | blob `72168985edbb801cce46dc0c33dae3babc2705ee`; accepts result blob `a97f97eafb09b18c604cd5785887a25db08c819d` | Establishes accepted B01-B provenance. |
| S8 | `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md` | blob `a97f97eafb09b18c604cd5785887a25db08c819d` | Match writer/projection separation, mutual-acceptance evidence, no total score, and retained expiry policy. |
| S9 | `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | blob `fb48743f0147fb0d25be697ba02aae63a45d07d8` | Product invariants, exact-scope authority, neutral meanings, and no-processing/no-implementation boundaries. |
| S10 | `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_ACCEPTANCE_V0_1.md` / accepted result `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md` | acceptance blob `f85ecaefdcc819fa42964509d4b02cc4583fbad2`; result blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418` | Accepted visible Match meanings, actor directions, neutral terminal meanings, cross-domain separation, and `MT_*` projection vocabulary. |
| S11 | `docs/architecture/ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_ACCEPTANCE_V0_1.md` / accepted result `docs/architecture/ELITESYNC_V10_APP_T05_CANONICAL_MATCH_LIFECYCLE_FOUNDATION_IMPLEMENTATION_RESULT_V0_1.md` | acceptance blob `2bdf77f832dafd552cac30d54debc47c42f67f79`; result blob `1d99a8f681e8cbe58adab4cde4041111aa5f2087` | Establishes that existing `MT_*` vocabulary/presentation does not create mutation authority; route, raw state, countdown, and legacy behavior are not authority. |
| S12 | `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md` / accepted design `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md` | acceptance blob `063dc18309afdc8f477cc9b22a29da1842776556`; design blob `b72ed9ec851d44aba7be65883186cb275fab22d1` | Owner-accepted canonical Match direction, current MVP maximum of one unresolved proposal, no total score, and retained future active-candidate/expiry details. |
| S13 | `docs/decisions/ADR-013-PACING-AND-CANONICAL-MVP-INTERACTION-STATE-GOVERNANCE.md` | blob `e59e4e0a9e811aa0c51e7da762d2ee1b80a848fb`; status accepted in artifact | Separate participation/Match vocabularies, neutral pause/pass/expiry meanings, bounded supply, no countdown pressure, and all concrete timing values deferred. |
| S14 | `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` | blob `4c00def5a94a117c8d9812996baf193de4a4aeb1` | Current integration evidence: `/progress/match`, ten target presentation states, empty mutation actions, and unresolved backend/expiry authority. |

Application source and tests were excluded as authority.

## 3. Exact-token search ledger

Each authorized phrase was searched separately with fixed-string matching at `origin/main`, limited to `docs/architecture`, `docs/product`, and `docs/decisions`. No synonym expansion, directory enumeration, application-source read, test read, old-repository access, or legal research was used.

| Exact token | Matching documents | Plausible authority opened |
|---|---:|---|
| `Match lifecycle` | 26 | S10, S11, S13 |
| `canonical Match` | 38 | S10, S11, S12, S14 |
| `proposal issuance` | 6 | S6, S8 |
| `proposal accept` | 2 | S1, S2 |
| `proposal decline` | 2 | S1, S2 |
| `proposal withdraw` | 2 | S1, S2 |
| `mutual acceptance` | 14 | S6, S8 |
| `enrollment` | 13 | S6, S8, S11, S12 |
| `pause` | 78 | S10, S11, S12, S13 |
| `withdrawal` | 62 | S10, S11, S12, S13 |
| `expiry` | 93 | S3, S5, S7, S10, S11, S12, S13, S14 |
| `/progress/match` | 18 | S6, S8, S10, S11, S14 |

## 4. Scope model and accepted-vocabulary reconciliation

Canonical Match has two nested semantic scopes:

1. one participant-owned Match-participation context; and
2. zero or more distinct two-participant proposal contexts related to that participation context.

Participation and proposal identities are separate. A proposal decision, terminal outcome, revision, or idempotency identity cannot become participation authority or transfer to another proposal. A later participation context or proposal is a fresh identity, not a reset of an old terminal identity.

The durable authority vocabularies fixed by this closure are:

- participation: `NOT_ENROLLED`, `ENROLLED`, `PAUSED`, `WITHDRAWN`;
- proposal: `PENDING`, `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, `EXPIRED`.

The accepted APP-T01/APP-T05 `MT_*` vocabulary remains a target projection/presentation vocabulary and is not discarded. APP-T05 explicitly establishes that vocabulary presence does not create mutation authority. The nested authority model clarifies rather than replaces the visible meanings:

| Accepted projection meaning | Durable authority source |
|---|---|
| `MT_NOT_OPTED_IN` | Participation `NOT_ENROLLED` when the projection's audience/purpose and currentness pass |
| `MT_ACTIVE` | Participation `ENROLLED` with no current proposal state represented |
| `MT_PAUSED` | Participation `PAUSED` |
| `MT_PROPOSAL_PRESENTED` | Current proposal `PENDING` without current mutual acceptance |
| `MT_INTEREST_RECORDED` | Current proposal remains `PENDING`; one participant's current acceptance is evidence inside that proposal |
| `MT_MUTUAL_INTEREST` | Current proposal `MUTUALLY_ACCEPTED` |
| `MT_DECLINED` | Proposal `DECLINED` |
| `MT_EXPIRED` | Proposal `EXPIRED` only under authoritative expiry evidence |
| `MT_WITHDRAWN` | Must identify whether the authority scope is participation `WITHDRAWN` or proposal `WITHDRAWN`; the label alone is insufficient |
| `MT_COMPLETED` | A bounded projection/presentation conclusion only when separately authoritative evidence supports it; it is not an additional proposal mutation introduced here and cannot reopen terminal `MUTUALLY_ACCEPTED` |

`NO_CANDIDATE`, no-round, loading, offline, timeout, unavailable, stale, projection lag, retryable error, closed-without-evidence, and transport/service failure are authority or presentation conditions, not Match lifecycle states.

For the current MVP, the Owner-accepted feature design establishes at most one unresolved proposal for the same participant at a time (S12). Any future multi-candidate or higher active-proposal limit remains unresolved and cannot be inferred from the nested model.

## 5. Complete participation lifecycle

| Source/context | Action | Required actor | Authoritative preconditions | Target/outcome | Resulting evidence | Forbidden substitute |
|---|---|---|---|---|---|---|
| Fresh participation context at `NOT_ENROLLED` | enroll / opt in | The authenticated participant for that context | Then-current separately authoritative eligibility/readiness prerequisites for Match pass; exact subject/audience/purpose/role/revision/freshness bindings pass; explicit participant intent | `ENROLLED` | New Match-authority participation revision binding subject, context, action, and outcome | Readiness alone, route entry, local toggle, transport success, legacy enrollment, or prior context |
| `ENROLLED` | pause | The same authenticated participant | Current participation revision and usable freshness; actor/context binding passes | `PAUSED` | Newer participation revision; new proposal issuance stops | Client pause flag, offline state, notification dismissal, or old projection |
| `PAUSED` | resume | The same authenticated participant | Current pause revision; then-current Match prerequisites and affirmative resume authority pass | `ENROLLED` | Newer participation revision establishing resumed participation | Historical enrollment, reconnect, route open, elapsed time, or cache |
| `ENROLLED` or `PAUSED` | withdraw participation | The same authenticated participant | Current controlling participation revision and actor/context binding pass | `WITHDRAWN` | Terminal participation revision for that context | Proposal decline, local logout, account deletion, transport failure, or Match authority proposal withdrawal |
| Historical terminal `WITHDRAWN` | later return | The participant, but only in a distinct new context | Then-current separate authority permits participation; fresh identity, bindings, revision/freshness, and logical intent | A fresh participation context begins at `NOT_ENROLLED`, then requires its own enrollment | New lineage; old terminal context remains historical | Reopen/reset old context, reuse old enrollment or idempotency identity |

Participation `WITHDRAWN` is terminal for its context. `PAUSED` is not terminal. Pause and withdrawal make every still-`PENDING` proposal involving that participant ineligible for further acceptance; the Match authority authors a newer proposal revision resolving it to proposal `WITHDRAWN`. This cross-scope effect does not turn the participant's action into proposal-writer authority and implies no domain-wide adverse reason.

## 6. Complete proposal lifecycle and participant decisions

One proposal has one distinct identity, exactly two bound participants, one Match-authority lineage, and an independent decision slot for each participant. Decision evidence must bind the actor, actor role as that exact participant, same proposal identity, exact participant set, proposal revision/scope, audience/purpose, currentness, and usable freshness.

| Source/context | Action | Required actor | Authoritative preconditions | Target/outcome | Resulting evidence | Forbidden substitute |
|---|---|---|---|---|---|---|
| Both intended participants have current `ENROLLED` participation and satisfy then-current separately authoritative Match prerequisites | issue proposal | Match authority/system only | Exact two-participant binding; current eligibility/participation inputs; current MVP one-unresolved-proposal rule; product-authorized proposal purpose; new proposal identity | New proposal `PENDING` | Proposal-issued revision plus two independent undecided decision slots | Either participant, route, candidate card, algorithm output, compatibility label, legacy DTO, notification, or transport acknowledgement |
| Current `PENDING`; actor's decision slot has no controlling terminal decision | accept own slot | Either bound participant, only for their own slot | Same current proposal and participants; actor role; controlling revision; freshness; no pause/withdraw cross-scope invalidation | Remains `PENDING` if only one current acceptance exists; becomes `MUTUALLY_ACCEPTED` only when both slots contain current acceptance for the same proposal revision | One-sided acceptance evidence or terminal mutual-acceptance outcome revision | Other participant's action, prior proposal decision, local boolean, route, countdown, notification, transport success |
| Current `PENDING` | decline | Either bound participant, only as their own decision | Same current proposal/participants; actor role; controlling revision; freshness | `DECLINED` | Terminal proposal revision | Inferred silence, timeout, negative Compatibility meaning, or another person's decision |
| Current `PENDING` | withdraw/cancel proposal | Match authority/system only | A separately product-authorized reason exists; controlling proposal revision and exact scope pass | `WITHDRAWN` | Terminal proposal revision; reason category only if separately authorized | Participant decision withdrawal, participant decline, participation withdrawal, client cancellation, transport failure, or local timer |
| Current `PENDING` involving a participant whose participation becomes `PAUSED` or `WITHDRAWN` | resolve participation effect | Match authority/system only | Newer authoritative participation revision is current and bound to a proposal participant | `WITHDRAWN` | Newer terminal proposal revision referencing only the cross-scope authority condition needed for resolution | Treating participant as proposal writer; adverse reason; keeping old accept authority alive |
| Current `PENDING` | expire | Match authority/system only | A separately established expiry policy applies; its scope/currentness/freshness pass | `EXPIRED` | Terminal proposal revision authored under that policy | Countdown, client timer, elapsed local time, transport timeout, stale policy, or legacy expiry value |
| `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, or `EXPIRED` | any attempt to reopen/reset/mutate to `PENDING` | None | Terminal proposal identity | Reject; terminal outcome remains controlling | Existing terminal evidence remains historical/current as appropriate | Retry, old acceptance, route, cache, notification, or new participant intent |
| Any terminal proposal | later proposal | Match authority/system only, as a distinct issuance | Then-current prerequisites permit it; new proposal identity, revision lineage, participant bindings, and fresh decisions | New `PENDING` proposal | Fresh proposal-issued evidence | Reuse old proposal, decisions, idempotency identity, mutual acceptance, or countdown |

There is no separate participant-owned “proposal withdraw” or “withdraw my prior decision” mutation in this closure. Participants act through accept or decline on their own slot while the proposal is current `PENDING`, or through participation withdrawal. The Match-authority proposal-withdraw action is not a substitute for either. Any future decision-retraction mutation would require a separately accepted rule.

## 7. Mutual-acceptance evidence

Mutual acceptance exists only when one authoritative Match outcome binds all of the following:

- the same current proposal identity and proposal revision/scope;
- the same exact two participants;
- a current authoritative acceptance in each participant's independent decision slot;
- each decision's actor identity and correct participant role;
- the controlling proposal and decision revisions/currentness;
- usable freshness for every required input; and
- the resulting proposal transition from `PENDING` to terminal `MUTUALLY_ACCEPTED`.

Decision arrival order is irrelevant. The first current acceptance leaves the proposal `PENDING`; it is unilateral evidence only. The second valid acceptance may cause the Match authority to author `MUTUALLY_ACCEPTED` only if the first remains current and all bindings still match. A newer proposal revision that changes participants or proposal scope makes prior decision evidence unusable for the changed proposal.

One participant's acceptance, historical acceptance, proposal identity alone, route, countdown, candidate card, compatibility factor/label, cache, legacy DTO, local boolean, notification, or transport acknowledgement cannot establish mutual acceptance.

`MUTUALLY_ACCEPTED` is terminal for that proposal identity. It creates no Product Connection, Messaging Consent, Conversation read/send authority, Relationship state, guilt, Safety finding, verified Compatibility truth, or public person meaning.

## 8. Closure-question matrix (1–45)

| # | Question disposition | Status | Exact provenance / answer |
|---:|---|---|---|
| 1 | Aggregate identity boundary | `OWNER_DELEGATED_RULE` | S1 rule 1; section 4 fixes separate participation and proposal identities. |
| 2 | Enrollment vs proposal scope | `OWNER_DELEGATED_RULE` | S1 rule 1: participation is the parent context containing distinct proposal contexts. |
| 3 | Canonical authority vocabulary | `OWNER_DELEGATED_RULE` | S1 rules 2 and 7; section 4 lists exact participation and proposal vocabularies. |
| 4 | Participation vs proposal states | `OWNER_DELEGATED_RULE` | S1 rules 2 and 7; section 4 separates the two sets. |
| 5 | Presentation/authority conditions excluded | `SOURCE_RESOLVED` | S10, S11, S14: no-round/no-candidate/loading/offline/failed/lag are not Match outcomes. |
| 6 | More than one active proposal | `SOURCE_RESOLVED` | S12 fixes current MVP at most one unresolved proposal per participant; future multi-candidate limit remains unknown. |
| 7 | Enrollment source/action/actor/target | `OWNER_DELEGATED_RULE` | S1 rule 3 plus S10 opt-in prerequisite; section 5 fixes `NOT_ENROLLED -> ENROLLED` by the participant. |
| 8 | Pause actor | `OWNER_DELEGATED_RULE` | S1 rule 3: same participant. |
| 9 | Pause source | `OWNER_DELEGATED_RULE` | S1 rule 3: `ENROLLED -> PAUSED`. |
| 10 | Pause effect on pending proposal | `OWNER_DELEGATED_RULE` | S1 rule 14: proposal becomes acceptance-ineligible and Match authority resolves it to `WITHDRAWN`. |
| 11 | Participation-withdraw actor | `OWNER_DELEGATED_RULE` | S1 rule 3: same participant. |
| 12 | Participation withdrawal terminality | `OWNER_DELEGATED_RULE` | S1 rule 4: terminal for current context. |
| 13 | Later re-enrollment | `OWNER_DELEGATED_RULE` | S1 rule 4: permitted only in a fresh participation context. |
| 14 | Pause resume | `OWNER_DELEGATED_RULE` | S1 rule 3: same participant, `PAUSED -> ENROLLED`, under current affirmative authority. |
| 15 | Proposal issuance prerequisites | `OWNER_DELEGATED_RULE` | S1 rule 5; both participants current/eligible under separate prerequisites and `ENROLLED`; contents not defined here. |
| 16 | Proposal issuer | `OWNER_DELEGATED_RULE` | S1 rule 5: Match authority/system only. |
| 17 | Proposal participant binding | `OWNER_DELEGATED_RULE` | S1 rule 6: exact two participants. |
| 18 | Proposal vs participation identity | `OWNER_DELEGATED_RULE` | S1 rules 1 and 6: distinct identities. |
| 19 | New proposal after terminal outcome | `OWNER_DELEGATED_RULE` | S1 rule 12: fresh proposal identity and decisions. |
| 20 | Historical proposal as current authority | `SOURCE_RESOLVED` | S3/S4 and S1 rule 15 reject historical/superseded substitution. |
| 21 | Acceptance actor | `OWNER_DELEGATED_RULE` | S1 rule 8: either bound participant, own slot only. |
| 22 | Decline actor | `OWNER_DELEGATED_RULE` | S1 rules 8–9: either bound participant, own decision only. |
| 23 | Independent decisions | `OWNER_DELEGATED_RULE` | S1 rules 6 and 8: one slot per participant on same proposal. |
| 24 | One-sided acceptance | `OWNER_DELEGATED_RULE` | S1 rule 7: evidence inside current `PENDING`, not mutual state. |
| 25 | Both accept result | `OWNER_DELEGATED_RULE` | S1 rule 8: terminal `MUTUALLY_ACCEPTED`. |
| 26 | Acceptance after changed revision/scope | `SOURCE_RESOLVED` | S3/S4 currentness rule plus S1 rule 8: prior decision cannot bind changed participants/scope. |
| 27 | Participant withdraws own decision | `NOT_APPLICABLE` | S1 rule 10: no participant proposal-withdraw mutation is retained; use own decline while valid or participation withdrawal. Future retraction needs separate authority. |
| 28 | Proposal-withdraw actor/source/target | `OWNER_DELEGATED_RULE` | S1 rule 10: Match authority/system, current `PENDING`, authorized reason, target `WITHDRAWN`; reason categories not invented. |
| 29 | Decline terminality | `OWNER_DELEGATED_RULE` | S1 rules 9 and 11: either decline makes proposal terminal `DECLINED`. |
| 30 | Later proposal for same people | `OWNER_DELEGATED_RULE` | S1 rule 12: fresh identity and fresh decisions if then-current authority permits. |
| 31 | Expiry-eligible state | `OWNER_DELEGATED_RULE` | S1 rule 13: only current `PENDING`. |
| 32 | Expiry actor | `OWNER_DELEGATED_RULE` | S1 rule 13: Match authority/system under established policy. |
| 33 | Exact expiry duration | `RETAINED_UNKNOWN` | S1 rule 13; S3, S5, S7, S10–S14 preserve the gap. |
| 34 | Exact clock basis | `RETAINED_UNKNOWN` | S1 rule 13; no accepted source selects a clock basis. |
| 35 | Extension/renewal | `RETAINED_UNKNOWN` | S1 rule 13; extension, renewal, cooldown, and re-proposal timing remain unknown. |
| 36 | Expired identity terminal | `OWNER_DELEGATED_RULE` | S1 rule 11: `EXPIRED` terminal. |
| 37 | Later proposal after expiry | `OWNER_DELEGATED_RULE` | S1 rule 12: fresh proposal identity and decisions. |
| 38 | Countdown/client timer | `SOURCE_RESOLVED` | S3/S4, S10–S14: never expiry or Match authority. |
| 39 | Match acceptance vs Product Connection | `SOURCE_RESOLVED` | S3, S5, S7, S8, S10–S14: no Connection is created. |
| 40 | Match acceptance vs Messaging Consent | `SOURCE_RESOLVED` | S3/S4 and S8: another domain's consent is not created. |
| 41 | Match acceptance vs Conversation access | `SOURCE_RESOLVED` | S10–S12 and S14: no Conversation read/send grant. |
| 42 | Match acceptance vs Relationship | `SOURCE_RESOLVED` | S9, S10, S12, S13: no Relationship state. |
| 43 | Neutral decline/withdraw/expiry meaning | `SOURCE_RESOLVED` | S9, S10, S12, S13: no guilt, Safety, punishment, fraud, deception, person worth, or incompatibility truth. |
| 44 | Compatibility total score | `SOURCE_RESOLVED` | S3, S5, S7, S8, S10–S14: prohibited. |
| 45 | Optional signal policy | `RETAINED_UNKNOWN` | S7, S8, S10–S12: optional AI/personality/astrology/reference-signal allowlist/provenance remains unresolved. |

No closure question is `BLOCKED`.

## 9. Expiry and retained-policy seam

Expiry is representable only as a Match-authority outcome from a still-current `PENDING` proposal under a separately established policy. Until that policy exists, the authority cannot infer or author `EXPIRED` from elapsed time, no response, a countdown, client timer, legacy value, transport timeout, scheduled job observation, or UI state.

The following remain `RETAINED UNKNOWN`:

- exact expiry duration;
- exact clock basis and time authority;
- extension and renewal rules;
- cooldown and re-proposal timing after terminal outcomes; and
- any related concrete timeout, cadence, reminder, queue, or operational value.

Expiry is neutral lifecycle cessation, not rejection, wrongdoing, low interest, incompatibility, Safety evidence, punishment, person defect, or Relationship failure.

## 10. Concurrency and idempotency truth cases

These cases fix semantic outcomes for later BA-03 design; they do not select an idempotency key, locking, transaction, queue, clock, or storage mechanism. Every case resolves against the authoritative current revision and exact domain preconditions, never client/transport arrival order.

| Case | Required semantic resolution | Must not happen |
|---|---|---|
| Duplicate enrollment | Correlate the same logical intent to one `ENROLLED` outcome in one participation context. | Create a second participation context from a retry. |
| Duplicate pause | Preserve one `PAUSED` outcome if already authored; otherwise evaluate the controlling `ENROLLED` revision. | Stack pauses or treat transport duplication as authority. |
| Pause vs withdrawal | One intent valid against the controlling participation revision authors the next revision. If pause wins, a later withdrawal must freshly evaluate `PAUSED`; if withdrawal wins, pause is stale and rejected. | Author incompatible current states or reopen `WITHDRAWN`. |
| Duplicate proposal issue | Correlate to one proposal identity and one `PENDING` outcome. | Create another proposal from the same issuance intent. |
| Duplicate accept | Preserve one acceptance in that actor's slot; re-delivery creates no second decision. | Count retries as both participants or mutual acceptance. |
| Accept vs decline | Only intents valid against the controlling `PENDING` revision may affect the proposal. A controlling decline terminates as `DECLINED`; mutual acceptance, if already authoritatively completed first, is terminal. | Produce both terminal outcomes or decide from client arrival order. |
| Accept vs Match-authority proposal withdrawal | If withdrawal controls before mutual acceptance, proposal becomes `WITHDRAWN`; if the second valid acceptance already controls as `MUTUALLY_ACCEPTED`, withdrawal is stale. | Let a delayed intent reopen either terminal state. |
| Both accepts in opposite arrival order | The first valid acceptance remains unilateral `PENDING`; the second valid acceptance completes `MUTUALLY_ACCEPTED` if both bind the same current revision. | Make one participant's transport order privileged. |
| Stale accept after proposal revision | Reject/fail closed when participants, scope, or controlling revision changed. | Rebase the old decision or infer consent. |
| Accept after participation pause | The newer pause makes the pending proposal acceptance-ineligible and Match authority resolves it to `WITHDRAWN`; reject the accept. | Keep old acceptance usable. |
| Accept after participation withdrawal | Resolve proposal to `WITHDRAWN` under newer authority and reject the accept; participation context remains terminal. | Reopen participation or proposal. |
| Delayed accept after decline | Reject against terminal `DECLINED`. | Revive proposal or create mutual acceptance. |
| Expiry racing second acceptance | Only a transition valid under the controlling revision may win: `MUTUALLY_ACCEPTED` or `EXPIRED`, never both. Without an established expiry policy, expiry cannot participate. | Let a countdown or client time choose the result. |
| Old proposal replay after fresh proposal | Reject old identity, decisions, revisions, and idempotency correlation. | Transfer acceptance to the fresh proposal. |
| Transport timeout after possible decision commit | Reconcile authoritative evidence with the same logical intent. | Infer failure/success or silently issue a new business intent. |
| Changed semantic input under reused idempotency identity | Reject as ambiguous misuse or require a separately valid new intent. | Treat changed actor/action/proposal/participants/scope/decision as a retry. |
| Participant/proposal mismatch | Reject mutation and protected projection use. | Infer role from route, payload position, card, or legacy DTO. |
| Historical `MUTUALLY_ACCEPTED` shown as current | Treat as historical only; it cannot authorize a current proposal, Connection, or Conversation. | Restore Match authority from cache or route. |
| Unknown expiry policy with pending proposal | Do not author `EXPIRED`; keep the current authoritative proposal outcome unless another valid transition occurs. | Invent duration, clock, extension, or timeout. |
| Projection lag | Preserve newer known authority; older projection cannot authorize actions or roll state back. | Last-received-wins. |
| Unknown/unavailable Match authority | Fail closed for protected Match action and preserve `UNKNOWN`/unavailable as a non-domain condition. | Infer no Match, decline, expiry, withdrawal, failure, or person meaning. |

## 11. Cross-domain, compatibility, and meaning boundaries

`Match != Connection != Conversation != Relationship` remains binding. Mutual Match acceptance creates none of Product Connection, Messaging Consent, Conversation read/send authority, Relationship state, public Profile authority, guilt, Safety finding, punishment, fraud, deception, person worth, objective incompatibility, verified suitability, or Compatibility truth.

No authoritative Compatibility total score exists. Separately product-authorized factors or explanations, if any, must preserve their source, provenance, purpose, uncertainty, scope, and audience and cannot be summed or promoted to verified truth. Optional AI/personality/astrology/reference-signal allowlists and provenance policy remain `RETAINED UNKNOWN`.

Decline, proposal withdrawal, participation withdrawal, pause, and expiry are neutral bounded choices or lifecycle outcomes. They do not cross into Safety, Ranking, desirability, reputation, Relationship, or person-standing evidence.

Route, candidate card, countdown, cache, local state, legacy DTO, notification identity, transport acknowledgement, raw round state, factor/label, prior proposal, or one participant's action can at most locate or observe a possible Match context. None authors Match state, actor role, audience, purpose, mutual acceptance, expiry, or a current permitted action.

## 12. Retained-gap inventory

Every retained gap found within the authorized closure is listed here:

| Gap | Classification | Consequence |
|---|---|---|
| Exact proposal expiry duration | `RETAINED UNKNOWN` | No proposal may expire from a guessed duration. |
| Exact clock basis/time authority | `RETAINED UNKNOWN` | Client/server/local time technology is not selected. |
| Expiry extension and renewal rules | `RETAINED UNKNOWN` | No automatic extension, renewal, or reset. |
| Cooldown and re-proposal timing | `RETAINED UNKNOWN` | Fresh-proposal eligibility has no invented timing value. |
| Future multi-candidate/active-proposal limit beyond current MVP | `RETAINED UNKNOWN` | Current MVP remains at most one unresolved proposal; no future limit is inferred. |
| Exact eligibility/readiness prerequisite contents for enrollment or issuance | `RETAINED UNKNOWN / SEPARATE PRODUCT AUTHORITY REQUIRED` | This closure requires then-current authority but adds no criterion. |
| Match-authority proposal-withdraw reason categories | `RETAINED UNKNOWN / SEPARATE PRODUCT AUTHORITY REQUIRED` | Withdrawal is allowed only when a reason is separately authorized; no category is invented. |
| Any future participant decision-retraction mutation distinct from decline or participation withdrawal | `RETAINED UNKNOWN / SEPARATE PRODUCT AUTHORITY REQUIRED` | No such mutation exists in this closure. |
| Optional AI/personality/astrology/reference-signal allowlist and provenance policy | `RETAINED UNKNOWN` | No optional signal becomes Match evidence by default. |

None of these gaps blocks this bounded lifecycle closure. They remain explicit inputs or exclusions for later separately authorized work.

## 13. High-density verification matrix (40 checks)

| # | Check | Result | Exact evidence |
|---:|---|---|---|
| 1 | Fixed `origin/main` and task blob match | `PASS` | `origin/main=1e968a80427aa4e67821e6ef941e890b8e2ab2d5`; S1 blob `353feab99db44ceff23e1ec59b0160a56f7c4388`. |
| 2 | Exact one-file scope | `PASS` | Candidate path is the sole authorized output; verified by exact staged/diff-tree scope check. |
| 3 | Accepted BA-01 provenance | `PASS` | S3 acceptance binds S4 result blob. |
| 4 | Accepted B01-B provenance | `PASS` | S7 acceptance binds S8 result blob. |
| 5 | Accepted BA-03 decomposition provenance | `PASS` | S5 acceptance binds S6 result blob. |
| 6 | No broader repository enumeration | `PASS` | Reads used exact task paths and authorized fixed-token searches only. |
| 7 | Exact-token search ledger | `PASS` | Section 3 records all 12 tokens and counts. |
| 8 | Application source/tests excluded as authority | `PASS` | Section 2 and search boundary; no application/test source opened. |
| 9 | Participation context identity | `PASS` | Section 4. |
| 10 | Proposal identity | `PASS` | Sections 4 and 6. |
| 11 | Identities not collapsed | `PASS` | Sections 4 and 6. |
| 12 | Participation vocabulary complete | `PASS` | `NOT_ENROLLED`, `ENROLLED`, `PAUSED`, `WITHDRAWN`. |
| 13 | Proposal vocabulary complete | `PASS` | `PENDING`, `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, `EXPIRED`. |
| 14 | Presentation/transport states excluded | `PASS` | Section 4. |
| 15 | Enrollment actor/source/target | `PASS` | Section 5 row 1. |
| 16 | Pause actor/source/target | `PASS` | Section 5 row 2. |
| 17 | Resume actor/source/target | `PASS` | Section 5 row 3. |
| 18 | Participation withdrawal actor/source/target | `PASS` | Section 5 row 4. |
| 19 | Post-withdraw fresh context | `PASS` | Section 5 row 5. |
| 20 | Proposal issuance actor | `PASS` | Section 6 row 1: Match authority/system only. |
| 21 | Proposal issuance eligibility seam | `PASS` | Section 6 preserves separately authoritative prerequisites without defining them. |
| 22 | Exact participant binding | `PASS` | Section 6: exactly two bound participants. |
| 23 | Independent participant decision slots | `PASS` | Sections 6–7. |
| 24 | One-sided acceptance not mutual | `PASS` | Section 7. |
| 25 | Mutual-acceptance resulting state | `PASS` | `PENDING -> MUTUALLY_ACCEPTED`, section 6. |
| 26 | Decline actor/outcome | `PASS` | Section 6: either bound participant's own decision, `DECLINED`. |
| 27 | Proposal-withdraw actor/outcome | `PASS` | Section 6: Match authority/system, `PENDING -> WITHDRAWN`. |
| 28 | Pause effect on pending proposal | `PASS` | Sections 5–6: acceptance-ineligible, resolved `WITHDRAWN`. |
| 29 | Participation withdrawal effect on pending proposal | `PASS` | Sections 5–6: acceptance-ineligible, resolved `WITHDRAWN`. |
| 30 | Proposal terminal states | `PASS` | `MUTUALLY_ACCEPTED`, `DECLINED`, `WITHDRAWN`, `EXPIRED`. |
| 31 | Terminal proposal cannot reopen | `PASS` | Section 6 terminal row. |
| 32 | Later proposal fresh identity/decisions | `PASS` | Section 6 final row. |
| 33 | Expiry source state | `PASS` | Only current `PENDING`, sections 6 and 9. |
| 34 | Expiry actor | `PASS` | Match authority/system under established policy. |
| 35 | Expiry duration/clock/extension unknown | `RETAINED_UNKNOWN` | Sections 9 and 12 preserve all exact timing gaps. |
| 36 | Route/countdown/cache/legacy/transport rejected | `PASS` | Sections 6, 7, 9, and 11. |
| 37 | No Compatibility total score | `PASS` | Section 11. |
| 38 | Acceptance creates no Connection/Conversation/Relationship | `PASS` | Sections 7 and 11; Messaging Consent also remains separate. |
| 39 | Neutral decline/withdraw/expiry semantics | `PASS` | Sections 9 and 11. |
| 40 | No implementation/API/schema/service/client/legal authority | `PASS` | Sections 1 and 14. |

Totals: `PASS=39 / RETAINED_UNKNOWN=1 / BLOCKED=0`.

## 14. Non-goals, re-dispatch condition, and stop boundary

This closure selects no exact expiry timing, clock, extension, renewal, cooldown, proposal frequency, future multi-candidate limit, matching algorithm, candidate ranking, Compatibility total score, optional signal policy, endpoint, API/wire format, schema, storage, service, queue, cache, deployment, authentication, client implementation, regional legal rule, Safety finding, participant research, or production policy.

BA-03 may be separately re-dispatched only after this exact candidate receives a fresh independent ACCEPT verdict, the accepted closure is established on `main`, and a new explicit Owner-authorized task binds that accepted provenance. This candidate does not restart BA-03 and cannot accept itself.

No backend/client implementation, merge, main promotion, successor-task creation, BA-06/BA-07 start, legal closure, private-data activity, or production action is authorized.

Candidate classification:

`CANONICAL MATCH LIFECYCLE COMPLETENESS CLOSURE ESTABLISHED — HIGH-DENSITY VALIDATION MATRIX COMPLETE — PRODUCT LIFECYCLE RULES FIXED / EXPIRY POLICY RETAINED UNKNOWN — NO IMPLEMENTATION AUTHORITY CREATED — READY FOR INDEPENDENT REVIEW`
