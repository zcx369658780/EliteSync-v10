# EliteSync v10｜Product Connection Lifecycle Source Resolution Result｜v0.1

Status: `CANDIDATE — SOURCE RESOLUTION / GOVERNANCE ONLY — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Fresh source-resolution base: `06cb18eaf79a8d169522c02332bdfae9c55b02ab`

Task authority: `docs/architecture/ELITESYNC_V10_NEXT_BA_04_SR01_PRODUCT_CONNECTION_LIFECYCLE_SOURCE_RESOLUTION_TASK_V0_1.md`

## 1. Resolution result and boundary

An already accepted Product Connection lifecycle source exists and explicitly resolves pause, close, resume, expiry, and terminality for the existing Connection/request aggregate. The accepted source does **not** explicitly decide whether a later Product Connection lifecycle may be created after a terminal outcome or whether that later lifecycle must use a new aggregate/request.

The bounded result is therefore partial for the complete SR01 question set. This artifact records source-supported facts and the retained product-decision gap only. It does not create, select, or recommend a lifecycle rule and does not modify or redispatch BA-04.

## 2. Fixed accepted source and acceptance provenance

| Evidence role | Exact path | Commit / provenance | Blob at current accepted `main` | Established fact |
|---|---|---|---|---|
| Accepted lifecycle result | `docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_RESULT_V0_1.md` | Candidate commit `57885a241a460307dcba67ff2f313b0bec764c60`; introduced with sole parent `612f634e6af0cb490d8d7117b2e0b078e83c8230` | `27677f6c93f330c934f787660d5f268525e2e0d6` | Sections 3 and 4 define the exact state successors, transition actors, resume rule, expiry source/actor, and terminality for the existing aggregate/request. |
| Independent acceptance | `docs/architecture/ELITESYNC_V10_APP_T06_CONNECTION_MUTUAL_CONSENT_LIFECYCLE_FOUNDATION_ACCEPTANCE_V0_1.md` | Acceptance commit `44f94e1c8249f1bee27055c03223795b4a2afc78`, whose sole parent is the accepted candidate commit; the acceptance text fixes candidate commit `57885a241a460307dcba67ff2f313b0bec764c60` and result blob `27677f6c93f330c934f787660d5f268525e2e0d6` | `f06a0bb94c6d567126285192294a46431dd774ec` | Explicit independent acceptance of the APP-T06 Product Connection lifecycle foundation. |

The accepted candidate commit is an ancestor of current `main`, and its result blob is unchanged at current `main`. Filename, location, current presence, or prose tone was not used as acceptance evidence.

## 3. Question-by-question coverage

| SR01 §4 question | Exact source-supported rule | Coverage |
|---|---|---|
| 1. Legal source state(s) for `CN_PAUSED` | `CN_ACTIVE -> CN_PAUSED`. | `RESOLVED` |
| 2. Actor role(s) allowed to cause `CN_PAUSED` | Either connected participant may pause. | `RESOLVED` |
| 3. Whether and how `CN_PAUSED` resumes | `CN_PAUSED -> CN_ACTIVE`; required actor is the pausing participant. | `RESOLVED` |
| 4. Legal source state(s) for `CN_CLOSED` | `CN_ACTIVE -> CN_CLOSED` and `CN_PAUSED -> CN_CLOSED`. | `RESOLVED` |
| 5. Actor role(s) allowed to cause `CN_CLOSED` | Either connected participant may close from either accepted source. | `RESOLVED` |
| 6. Legal source state(s) for `CN_EXPIRED` | `CN_PENDING -> CN_EXPIRED`. | `RESOLVED` |
| 7. Expiry trigger and multiplicity | The actor is the system with an established expiry policy; the accepted matrix lists expiry only from `CN_PENDING`. Exact expiry duration/policy remains `UNKNOWN`. | `RESOLVED_WITH_POLICY_VALUE_RETAINED_UNKNOWN` |
| 8. Terminality of `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED` | `CN_CLOSED` has no successor for this Connection. Each of `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED` has no successor for this request. | `RESOLVED_FOR_EXISTING_AGGREGATE_OR_REQUEST` |
| 9. Later lifecycle after a terminal/non-active state | The source prohibits any successor on the old Connection/request, but it does not explicitly establish whether a later lifecycle is permitted or require that it be created as a new aggregate/request. | `UNSUPPORTED — OWNER PRODUCT-LIFECYCLE DECISION REQUIRED` |
| 10. Additional rule needed for a complete BA-04 matrix | For the existing aggregate/request, APP-T06 states that every unlisted direct transition is invalid and its matrix lists every accepted transition. The only retained source gap identified by this bounded review is question 9. | `PARTIALLY RESOLVED — DEPENDS ON QUESTION 9` |

## 4. Source-supported lifecycle facts retained exactly

The accepted source supports only the following direct transitions:

| Source | Action | Actor | Target |
|---|---|---|---|
| `CN_NONE` | request | either eligible candidate | `CN_PENDING` |
| `CN_PENDING` | accept | recipient | `CN_ACTIVE` |
| `CN_PENDING` | decline | recipient | `CN_DECLINED` |
| `CN_PENDING` | withdraw | requester / initiator | `CN_WITHDRAWN` |
| `CN_PENDING` | expire | system with an established expiry policy | `CN_EXPIRED` |
| `CN_ACTIVE` | pause | either connected participant | `CN_PAUSED` |
| `CN_ACTIVE` | close | either connected participant | `CN_CLOSED` |
| `CN_PAUSED` | resume | pausing participant | `CN_ACTIVE` |
| `CN_PAUSED` | close | either connected participant | `CN_CLOSED` |

Any unlisted direct transition is invalid in the accepted APP-T06 foundation. In particular, there is no direct `CN_NONE -> CN_ACTIVE` transition. These source facts do not create backend mutation authority, endpoint authority, persistence, or runtime evidence.

## 5. Plausible-source disposition

| Search hit | Disposition |
|---|---|
| APP-T06 result plus its independent acceptance | Selected accepted source. It is the only bounded hit reviewed here that combines a complete existing-aggregate actor/transition matrix with direct acceptance provenance. It remains incomplete only for SR01 §4.9. |
| `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md` | Earlier plausible product-contract source, current blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418`. Its Connection registry corroborates the APP-T06 pause/resume/close/expiry and terminality rules, but its own header remains candidate-scoped and the bounded token results did not independently fix a direct acceptance artifact. It also does not explicitly decide §4.9. It is not needed to establish the selected APP-T06 source chain. |
| APP-T06 task | Authority for the APP-T06 execution, current blob `563a61acd1fa397549aad43beff16a1743a4cbea`; it supplies the bounded vocabulary and separation rules but not the full accepted actor/source/target matrix. The independently accepted result is the controlling evidence used here. |
| MVP closeout/handoff and later backend planning/task documents | Summaries, planning boundaries, or task authorities. They corroborate the state vocabulary and hard rules but deliberately defer the missing complete lifecycle source; they do not resolve §4.9. |
| Conversation data-rights candidate and downstream Conversation/notification documents | Downstream access/effect material, not Product Connection lifecycle authority. |
| Application source and tests | Excluded by SR01: current code behavior and tests cannot establish lifecycle authority. They were not opened. |
| Phrase-only design/workshop hits | The bounded matching lines identify future lifecycle analysis or the need for an explicit lifecycle; they do not supply an accepted actor/source/target contract. |

## 6. Bounded search ledger

Searches were fixed-string searches at commit `06cb18eaf79a8d169522c02332bdfae9c55b02ab`. No directory enumeration, legacy-repository access, broad synonym search, implementation inspection, or external research was performed.

| Authorized exact token / phrase | Matching tracked paths |
|---|---:|
| `CN_PAUSED` | 11 |
| `CN_CLOSED` | 11 |
| `CN_EXPIRED` | 10 |
| `CN_PENDING` | 14 |
| `CN_ACTIVE` | 29 |
| `Product Connection` | 34 |
| `Connection lifecycle` | 18 |
| `recipient acceptance` | 9 |

Only plausible product/architecture/governance hits were opened. Acceptance was established through the exact APP-T06 acceptance artifact and Git ancestry/blob checks, not inferred from search rank or current-tree presence.

## 7. Retained gap and authority effect

The following remains unsupported by accepted source:

- whether a person may begin another Product Connection lifecycle after `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, or `CN_EXPIRED`;
- if permitted, whether that later lifecycle must be represented by a new Connection aggregate, a new request within another aggregate boundary, or another explicitly accepted semantic identity;
- the actor/preconditions for any such later lifecycle.

This is an Owner product-lifecycle decision gap, not an implementation blank. BA-04 remains blocked from claiming a complete lifecycle matrix until a fresh authority explicitly fixes that rule or explicitly narrows BA-04 so no restart/re-entry decision is required. APP-T06's “none for this Connection/request” terminality must remain binding and must not be expanded into permission to create another lifecycle.

No BA-04 technical design, BA-05 work, backend/API/schema/storage/service/client implementation, legal research, lifecycle policy selection, or existing-artifact modification was performed.

`PRODUCT CONNECTION LIFECYCLE SOURCE PARTIALLY RESOLVED — ACCEPTED SOURCE INCOMPLETE FOR COMPLETE BA-04 MATRIX — OWNER PRODUCT-LIFECYCLE DECISION REQUIRED FOR RETAINED GAPS — NO RULES INVENTED`
