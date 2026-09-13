# EliteSync v10｜NEXT BA-04-SR01 Product Connection Lifecycle Source Resolution Task｜v0.1

Status: `OWNER-CONTINUATION-AUTHORIZED — SOURCE RESOLUTION / GOVERNANCE ONLY — NO TECHNICAL-DESIGN OR IMPLEMENTATION AUTHORITY`

Date: 2026-09-13 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `a58b4b9156ed2c7b72b891e93e83cb9cd85b891b`

## 1. Trigger and purpose

BA-04 technical-design execution correctly stopped with:

`BLOCKED_EXACT_CONNECTION_LIFECYCLE_SOURCE_UNRESOLVED`

The bounded BA-04 authorities establish the exact Connection state vocabulary and several hard lifecycle rules, but they do not establish a complete accepted actor/source/target transition matrix for `CN_PAUSED`, `CN_CLOSED`, resume behavior, all `CN_EXPIRED` sources, or terminality.

This task authorizes only a bounded source-resolution review to determine whether those missing lifecycle rules already exist in a repository-accepted Product Connection source that can be bound by exact path, commit, and blob. It does not authorize creating new lifecycle rules.

## 2. Required first reads

After fresh-fetching `main`, read `AGENTS.md` first, then exactly:

1. `docs/architecture/ELITESYNC_V10_NEXT_BA_04_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_TASK_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_BACKEND_PRODUCT_CONNECTION_AUTHORITY_TECHNICAL_DESIGN_*` — do not read because no candidate exists; this pattern is stated only to make the non-existence explicit.
3. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_CONTRACT_V0_1.md`, B01-C only
4. `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_IMPLEMENTATION_PLANNING_DECOMPOSITION_V0_1.md`, BA-04 only
5. `docs/architecture/ELITESYNC_V10_BACKEND_COMMON_AUTHORITY_EVIDENCE_ENVELOPE_TECHNICAL_DESIGN_V0_1.md`, only domain-extension and revision/freshness rules relevant to Connection
6. `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`, only Connection/product-invariant references needed to resolve exact source identity

## 3. Authorized source-resolution method

Do not enumerate directories or perform broad repository discovery.

You may use bounded repository code/file search only for the following exact lifecycle tokens and phrases, within `zcx369658780/EliteSync-v10`:

- `CN_PAUSED`
- `CN_CLOSED`
- `CN_EXPIRED`
- `CN_PENDING`
- `CN_ACTIVE`
- `Product Connection`
- `Connection lifecycle`
- `recipient acceptance`

Search results may be opened only when they plausibly identify a product/architecture/decision artifact that could be an accepted lifecycle authority.

For each plausible source, establish:

- exact repository path;
- exact blob at current accepted `main`;
- the commit/acceptance evidence establishing whether it is accepted authority;
- whether it explicitly covers the missing lifecycle questions listed in §4.

Do not infer acceptance from filename, location, prose tone, or current presence alone.

## 4. Questions that must be resolved from an accepted source

Determine whether accepted authority explicitly specifies each of the following:

1. legal source state(s) for `CN_PAUSED`;
2. actor role(s) allowed to cause `CN_PAUSED`;
3. whether `CN_PAUSED` may resume, and if so the exact target state and actor role(s);
4. legal source state(s) for `CN_CLOSED`;
5. actor role(s) allowed to cause `CN_CLOSED`;
6. legal source state(s) for `CN_EXPIRED`;
7. whether expiry is authority-triggered only or may follow multiple lifecycle states;
8. terminality of `CN_CLOSED`, `CN_DECLINED`, `CN_WITHDRAWN`, and `CN_EXPIRED`;
9. whether any terminal/non-active state permits a later new Connection lifecycle only by creating a new aggregate/request rather than transitioning the old aggregate;
10. any additional actor/source/target rule required to produce a complete BA-04 matrix without invention.

Already accepted hard rules remain binding and need not be rediscovered:

- request creation produces `CN_PENDING` with initiator/recipient roles;
- recipient acceptance of the same authoritative `CN_PENDING` is the sole consent-establishing transition to `CN_ACTIVE`;
- direct `CN_NONE -> CN_ACTIVE` is forbidden;
- initiator withdrawal and recipient decline are distinct;
- decline/withdrawal/expiry do not imply guilt, Safety findings, punishment, or objective incompatibility;
- Match mutual acceptance does not create Connection authority.

## 5. Exact output

Create exactly one artifact:

`docs/architecture/ELITESYNC_V10_PRODUCT_CONNECTION_LIFECYCLE_SOURCE_RESOLUTION_RESULT_V0_1.md`

The artifact must end in exactly one of these terminal classifications:

### Outcome A — accepted exact source found

`PRODUCT CONNECTION LIFECYCLE SOURCE RESOLVED — ACCEPTED SOURCE PATH/COMMIT/BLOB FIXED — BA-04 MAY BE REDISPATCHED WITH EXACT SOURCE BINDING — NO LIFECYCLE RULES INVENTED`

The artifact must include the exact source path, fixed blob, acceptance provenance, and a question-by-question coverage table for §4.

### Outcome B — no accepted exact source found

`PRODUCT CONNECTION LIFECYCLE SOURCE NOT FOUND IN BOUNDED ACCEPTED AUTHORITY — BA-04 REMAINS BLOCKED — OWNER PRODUCT-LIFECYCLE DECISION REQUIRED — NO RULES INVENTED`

The artifact must list which §4 questions remain unsupported and the bounded searches/evidence used to establish the gap.

### Outcome C — source exists but is incomplete

`PRODUCT CONNECTION LIFECYCLE SOURCE PARTIALLY RESOLVED — ACCEPTED SOURCE INCOMPLETE FOR COMPLETE BA-04 MATRIX — OWNER PRODUCT-LIFECYCLE DECISION REQUIRED FOR RETAINED GAPS — NO RULES INVENTED`

The artifact must separate source-supported rules from unsupported rules exactly.

## 6. Non-goals and prohibitions

This task does not authorize:

- defining new Product Connection lifecycle rules;
- choosing among plausible pause/close/resume/expiry policies;
- technical design for BA-04 beyond recording source-supported facts;
- BA-05 work;
- backend/API/schema/database/service/client implementation;
- Flutter or tests;
- legal/data-rights research;
- compatibility cleanup, analyzer repair, Phase 2, or Sandbox/DEP13/B12/M2/M3;
- directory enumeration or broad source discovery.

If no accepted source answers a question, record it as missing authority. Do not use current code behavior, legacy behavior, test expectations, route behavior, or model inference as lifecycle authority.

## 7. Write and stop boundary

Create a bounded review branch, recommended:

`review/next-ba-04-sr01-product-connection-lifecycle-source-resolution-v0-1`

Write only the single result artifact named in §5.

After publishing it, report branch, candidate commit, sole parent, tree, result blob, exact scope, and `git diff --check`, then STOP.

Do not merge, self-accept, modify the existing BA-04 task sheet, or start BA-04/BA-05.
