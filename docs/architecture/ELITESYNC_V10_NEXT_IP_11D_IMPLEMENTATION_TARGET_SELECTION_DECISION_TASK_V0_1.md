# EliteSync v10｜NEXT IP-11D Implementation Target Selection Decision Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — TARGET-SELECTION DECISION ONLY — NO TOOLING/BUILD/IMPLEMENTATION AUTHORITY`

Date: 2026-09-16 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `a4d4bc528a1afca25bae359e2ce3c42785d2fb23`

## 1. Purpose

Produce one bounded Owner-level implementation-target selection decision using only already accepted documentary semantics and accepted declaration evidence.

The decision must select exactly one first implementation direction from the two independently declared directions established by accepted IP-11C:

1. client direction — `apps/android/` Android host + `apps/flutter_elitesync_module/` embedded Flutter module;
2. backend direction — `services/backend-laravel/` Laravel backend project.

This task selects only the FIRST implementation direction for subsequent bounded readiness work. It does not reject, deprecate, redesign, delete, or permanently exclude the other direction.

## 2. Authority and non-goals

This task is a governance/architecture decision only. It does not authorize:

- source-code edits;
- dependency acquisition/resolution;
- package/network commands;
- Flutter/Dart/Gradle/Java/Kotlin/PHP/Composer/Node/Python invocation;
- build/test/runtime execution;
- generated outputs;
- cache/artifact probing;
- database/schema/API/client implementation;
- production deployment;
- private/real-user data processing;
- legal conclusions;
- Safety Operations;
- Sandbox/DEP13/B12;
- reopening M1/M2/M3.

M1 remains exhausted. M2 remains deferred. M3 remains blocked.

## 3. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_IP_11C_CANDIDATE_TARGET_FAMILY_DECLARATION_READ_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_IP_11C_CANDIDATE_TARGET_FAMILY_DECLARATION_READ_RESULT_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_POST_IP01_IP10_IMPLEMENTATION_EXECUTION_ENTRY_REVIEW_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_POST_IP01_IP10_IMPLEMENTATION_EXECUTION_ENTRY_REVIEW_V0_1.md`
5. `docs/architecture/ELITESYNC_V10_COMMON_BACKEND_IMPLEMENTATION_CONTRACT_TECHNOLOGY_NEUTRAL_FOUNDATION_ACCEPTANCE_V0_1.md`
6. `docs/architecture/ELITESYNC_V10_CROSS_DOMAIN_API_INTERFACE_PLAN_ACCEPTANCE_V0_1.md`
7. `docs/architecture/ELITESYNC_V10_LOGICAL_PERSISTENCE_SCHEMA_PLAN_ACCEPTANCE_V0_1.md`
8. `docs/architecture/ELITESYNC_V10_CLIENT_INTEGRATION_PLAN_ACCEPTANCE_V0_1.md`

Do not enumerate directories, search the repository, or inspect additional source/manifests.

## 4. Selection criteria

Compare the two declared directions only against the accepted first-slice requirements and current blockers.

For each direction evaluate independently:

- Can the direction host the previously recommended smallest first slice shape: one pure common authority-evidence / source-condition / immutable-intent contract slice with synthetic fixtures only?
- Can the slice avoid real/private data?
- Can it avoid production/external systems/providers?
- Can it avoid unresolved product/legal/Safety policy seams?
- Can it be reviewed/reverted in one independent cycle?
- How much target-specific technology/tool/dependency evidence remains missing before execution?
- Does the direction force unrelated client UI, provider, device, platform, storage, network, deployment, or domain-product assumptions into the first slice?
- Does it preserve accepted IP-01/IP-08/IP-09 semantics with the least new authority surface?
- Does current declaration evidence expose a plausible synthetic/unit-test boundary for the first slice?
- What exact downstream discovery/readiness task becomes necessary if this direction is selected?

Do not score based on general industry preference, familiarity, aesthetics, future scalability, popularity, or undocumented assumptions.

## 5. Mandatory decision shape

Choose exactly one:

`SELECT_CLIENT_DIRECTION_FIRST`

or

`SELECT_BACKEND_DIRECTION_FIRST`

The selected direction must be justified only from accepted repository evidence and current bounded goals.

The non-selected direction must be classified:

`RETAINED_FOR_LATER_IMPLEMENTATION_ROUTE — NOT REJECTED`

Do not select both. Do not invent a third direction.

## 6. Downstream task identification

After selection, identify exactly one immediate successor task. It must still be PRE-IMPLEMENTATION and narrowly close the selected direction's next missing execution facts.

Examples of allowed successor classes:

- selected-target tool/dependency declaration-vs-availability readiness discovery;
- selected-target synthetic test-harness/source-boundary confirmation;
- selected-target technology realization acceptance decision.

The successor must not acquire dependencies, run builds/tests, or edit source unless a later task separately authorizes those actions.

## 7. High-density validation

Include at least 140 independently checkable validation rows.

Every row must be one of:

`PASS`

`RETAINED_UNKNOWN`

`BLOCKED`

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

Do not stop at the first unknown or blocker.

At minimum cover:

- declaration provenance;
- client host/module coherence;
- backend independence;
- synthetic-first-slice suitability;
- private-data exclusion;
- legal/Safety exclusion;
- tool/dependency unknowns;
- build/runtime unknowns;
- reversibility;
- review size;
- accepted common-contract fit;
- accepted interface/persistence/client boundaries;
- non-selected route retention;
- successor-task narrowness;
- M1/M2/M3/Sandbox/DEP13/B12 preservation.

## 8. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_IP_11D_IMPLEMENTATION_TARGET_SELECTION_DECISION_V0_1.md`

## 9. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-11d-implementation-target-selection-decision-v0-1`

Publish only the exact output file. Report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, run tools, acquire dependencies, implement, or start the successor task.

Expected terminal classification must include the exact selected direction and:

`FIRST IMPLEMENTATION DIRECTION SELECTED — NON-SELECTED DIRECTION RETAINED — NEXT PRE-IMPLEMENTATION READINESS TASK IDENTIFIED — NO IMPLEMENTATION AUTHORITY CREATED`
