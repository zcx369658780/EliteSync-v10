# EliteSync v10｜APP-T01 Target Route / Domain-State / Data-Audience Contract Task｜v0.1

Status: `AUTHORIZED — ARCHITECTURE CONTRACT ONLY — NO PRODUCT CODE IMPLEMENTATION`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Expected task-base GitHub `main`:

`d288d286f54b89460a607143bb769c98277ab9fc`

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

1. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_SUPPLEMENT_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_FEATURE_DESIGN_OWNER_ACCEPTANCE_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_APP_CODE_AUDIT_CLOSEOUT_AND_ASTRA_REPLANNING_INPUT_ACCEPTANCE_V0_1.md`
5. only the exact product-boundary inputs referenced by the 2026-09-12 handoff if needed to preserve OD-01 through OD-06.

This task exists because the Owner has accepted the new-version APP feature-design baseline. It must translate that accepted product design into implementation-consumable architecture contracts without modifying product code.

## 2. Local-worktree safety authorization

The Owner's existing local repository is currently reported as a detached dirty worktree containing a tracked `AGENTS.md` modification and 18 untracked architecture documents.

Do **not** modify, clean, stash, reset, checkout over, delete, move, adopt, commit, or otherwise inspect those local changes beyond the minimum needed to recognize that the worktree is unsafe for this task.

This APP-T01 task explicitly authorizes use of a **separate clean Git worktree** created from fresh-fetched `origin/main`, provided all of the following are true:

- the new worktree is created at a fresh path outside the dirty worktree;
- its starting commit is exactly the fresh-fetched task-base or a later Owner-authorized `origin/main` that contains this task sheet;
- the dirty detached worktree is untouched;
- no existing untracked/tracked local artifacts are copied into the new worktree;
- no destructive Git operations are performed on any worktree.

If a separate clean worktree cannot be established safely, stop and report the blocker.

## 3. Sole objective

Produce one new architecture result artifact:

`docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`

The result must turn the accepted feature-design supplement into a precise contract for downstream APP-T02 and later bounded implementation tasks.

Do not modify Flutter/Dart/product source, tests, build files, generated files, API/backend code, database/schema, or configuration.

## 4. Required contract sections

### A. Target route and ownership contract

Define the target MVP information architecture exactly from the Owner-approved design:

`Home | Progress | Messages | Me`

At minimum define:

- top-level route purpose;
- route ownership boundaries;
- child route/surface ownership;
- what does **not** belong in each top-level route;
- target treatment of Discover/Explore;
- target treatment of legacy top-level Match/Profile concepts;
- route/guard requirements for guest, readiness-incomplete, ready, and private states;
- privacy-safe entry behavior.

Do not translate conceptual contexts into service/module/database decomposition.

### B. Domain-state registry

Define product-level state sets for:

1. Onboarding
2. Readiness
3. Match
4. Connection
5. Conversation
6. Relationship

Use the accepted feature-design baseline as authority. Preserve:

`Match != Connection != Conversation != Relationship`

For every state include:

- state identifier;
- user-visible meaning;
- permitted actor(s) that may cause exit/transition;
- required consent/authority;
- allowed successor states;
- terminal/non-terminal status;
- data/audience consequence;
- explanation/control requirement.

### C. Transition and invalid-transition contract

Produce an explicit transition table.

It must make at least these target prohibitions concrete:

- Match must not automatically create Connection;
- Connection must not automatically authorize Conversation;
- Conversation activity must not automatically create or infer Relationship;
- Relationship ending must not automatically prove Connection or Conversation should close;
- Block must not be collapsed into Report;
- Report must not establish Finding/guilt;
- transport/error/offline conditions must not be represented as domain lifecycle facts.

State which transitions require mutual consent, unilateral user action, system expiry, or system presentation only.

### D. Data-class / audience / purpose contract

Use at minimum the accepted target classes:

- `PUBLIC_EDITORIAL`
- `ACCOUNT_PRIVATE`
- `PRIVATE_IDENTITY`
- `READINESS_RESTRICTED`
- `MATCH_PURPOSE_LIMITED`
- `SHOWCASE_CANDIDATE_SCOPED`
- `CONNECTION_SCOPED`
- `CONVERSATION_SHARED_PRIVATE`
- `RELATIONSHIP_SHARED_PRIVATE`
- `USER_PRIVATE_REFLECTION`
- `AI_DERIVED_PRIVATE`
- `SAFETY_RESTRICTED`
- `OPERATIONAL_MINIMUM`

For each class specify:

- meaning;
- default audience;
- permitted product purpose;
- prohibited use/flow;
- user-control requirement;
- lifecycle/expiry authority where currently established;
- retained UNKNOWN where exact retention/legal basis is not Owner-decided.

Preserve:

`Meaning + Provenance + Purpose + Lifecycle Authority`

and the distinctions:

- User declaration != objective truth;
- AI output != verified fact;
- Safety evidence != Compatibility evidence;
- private Conversation != default training/ranking data.

### E. Route-to-domain-to-data mapping

Create a matrix mapping each target top-level/child surface to:

- domain/context consumed;
- lifecycle states displayed/changed;
- data classes readable;
- data classes writable;
- consent/user-control entry points;
- explanation requirements.

This is a product/architecture mapping only. Do not infer database tables, APIs, providers, Riverpod ownership, services, modules, packages, or persistence technology.

### F. Explainability / user-control minimum contract

For key lifecycle-affecting actions define a minimum explanation schema:

- what happened;
- why it happened;
- information classes used;
- what the result does not mean;
- uncertainty/limits where applicable;
- what the user can change, revoke, pause, retry, correct, contest, or close.

Explicitly state that MVP has no single authoritative Compatibility total score.

### G. Guard / entry contract

Define target access behavior at product level for:

- unauthenticated/guest public entry;
- readiness incomplete;
- readiness ready but Match not opted in;
- Match active;
- Connection pending/active/paused/closed;
- Conversation locked/pending/active/paused/closed;
- Relationship not declared/pending/active/paused/ended.

Do not invent exact authentication or identity-assurance mechanisms.

### H. Retained UNKNOWN / Owner-decision blocker map

Preserve as UNKNOWN unless already decided:

- launch segment / exact eligibility;
- minimum identity-assurance mechanism and level;
- exact Match proposal expiry duration;
- exact Conversation/shared-content retention/export/deletion rights;
- region-specific legal/data-right implementation;
- exact Phase-2 Relationship tools;
- optional AI/personality/astrology/reference-signal allowlist.

For each UNKNOWN state exactly which later task is blocked by it and which work may proceed without resolving it.

### I. APP-T02 handoff contract

End with a bounded specification for the next task only:

`APP-T02 — CURRENT-TO-TARGET SOURCE LOCATOR / MIGRATION INVENTORY`

APP-T02 should later be able to inspect source for route ownership, current Profile coupling, canonical/legacy Match consumers, Conversation gates and related migration seams. APP-T01 itself must not perform that source inventory.

## 5. Required explicit target decisions to encode

Treat the following as Owner-approved target decisions, not open questions:

- MVP top-level IA is `Home | Progress | Messages | Me`;
- Home is a calm, low-density state hub;
- Discover is not an MVP top-level feed; it becomes Phase-2 Explore/Support Library;
- Progress is a navigation container only and must not collapse Match/Connection/Relationship semantics;
- Match uses deliberate pacing and no single authoritative Compatibility total score;
- Match and Connection require separate lifecycle authority;
- Connection and Conversation require separate consent;
- Relationship is a Phase-2 mutual opt-in support context;
- MVP has no globally public Profile;
- Profile is split conceptually into Private Identity, Matching Inputs, Readiness and Showcase;
- private Conversation is not default AI/training/ranking input;
- participant-linked legacy Match is a retirement/migration target after replacement/cutover evidence, not a second permanent canonical path;
- lock-screen notification defaults are privacy-minimal;
- AI remains advisory and must not become truth/guilt/Safety/relationship authority.

## 6. Explicit exclusions

Do not:

- edit product source;
- implement routes or state machines;
- inspect populated private Conversation/Profile/participant data;
- perform participant research;
- perform telemetry/analytics/measurement;
- perform Safety Operations;
- perform new legal research;
- resume Sandbox/DEP13/B12/M2/M3;
- inspect README or FD02;
- perform broad repository archaeology;
- perform source locator/migration inventory beyond what is already stated in accepted documents;
- invent service/database/API/provider/module decomposition;
- lock exact retention periods, identity-assurance mechanisms, legal bases, Match expiry duration, or optional AI/reference-signal policy.

## 7. Evidence and source-use rules

- The accepted old APP audit is closed for replanning purposes. Do not rediscover established source facts.
- `DEFERRED != MISSING`.
- `UNKNOWN != ABSENT`.
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`.
- `CURRENT SOURCE EXISTS != MUST KEEP`.
- `NEW IDEA != MUST REFACTOR`.
- Use only the minimum documents necessary to produce the contract.
- If a contradiction is discovered, isolate the exact contradiction and stop before reopening any wider old-code audit.

## 8. Git / publication contract

Work on a fresh task branch based on the authorized fresh `origin/main`.

Suggested branch:

`review/app-t01-target-route-domain-state-data-audience-contract-v0-1`

Create exactly one new result artifact unless a strictly necessary task-local receipt is required. Do not modify prior accepted documents.

Commit and push the candidate branch. Do not merge to `main` and do not self-accept.

Report:

- fresh `origin/main` SHA used;
- task blob SHA;
- branch;
- candidate commit;
- sole parent;
- result path;
- result blob SHA;
- concise final classification;
- confirmation that the dirty detached worktree was not modified.

## 9. Stop condition

Stop immediately after publishing the APP-T01 candidate result.

Do not begin APP-T02.

Final candidate classification should be one of:

`APP-T01 TARGET CONTRACT ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`

or, if an authorized contract cannot be established:

`APP-T01 BLOCKED — <exact bounded blocker>`
