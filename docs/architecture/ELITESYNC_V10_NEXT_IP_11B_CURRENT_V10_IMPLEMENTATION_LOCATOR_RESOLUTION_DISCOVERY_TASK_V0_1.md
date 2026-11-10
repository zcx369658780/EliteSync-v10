# EliteSync v10｜NEXT IP-11B Current-v10 Implementation Locator Resolution Discovery Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED GOVERNANCE AUTHORIZED — SHALLOW READ-ONLY LOCATOR DISCOVERY ONLY — NO TECHNOLOGY SELECTION — NO IMPLEMENTATION AUTHORITY`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `376112402d4270ce832efb224ad0718b028a0f4e`

## 1. Purpose

Resolve where the current v10 implementation source/manifests actually live after accepted IP-11A proved that its 19 literal root-level locators were absent.

This task may discover repository structure only within the exact shallow bounds below. It must not choose a technology, read broad implementation content, acquire dependencies, invoke tooling, run builds/tests/runtime, inspect caches/artifacts, or access the historical EliteSync repository.

## 2. Required reads

After fresh-fetching `main`, read `AGENTS.md` first. Then read only:

1. `docs/architecture/ELITESYNC_V10_IP_11A_CURRENT_V10_IMPLEMENTATION_TARGET_AND_TOOLING_SOURCE_FACT_DISCOVERY_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_IP_11A_CURRENT_V10_IMPLEMENTATION_TARGET_AND_TOOLING_SOURCE_FACT_DISCOVERY_RESULT_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_POST_IP01_IP10_IMPLEMENTATION_EXECUTION_ENTRY_REVIEW_ACCEPTANCE_V0_1.md`
4. accepted Post-IP01..IP10 execution-entry review, locator/tooling sections only.

Do not broaden documentation reads.

## 3. Authorized repository-structure discovery

Only the following repository-structure operations are authorized:

### A. Root listing

List exactly the repository root tree at the fixed task commit, names/types only.

Do not read file contents during this step.

### B. Candidate implementation roots

From the root listing, only the following exact root directory names may be traversed one level deeper if present:

- `app`
- `apps`
- `backend`
- `client`
- `clients`
- `frontend`
- `mobile`
- `packages`
- `src`
- `server`
- `services`
- `web`
- `android`
- `ios`

No other root directory may be traversed.

For each present authorized candidate root, list names/types one level only. Do not recursively enumerate.

### C. Candidate manifest/source locator identification

From only those root and one-level listings, identify exact candidate paths whose names themselves plausibly declare one of these categories:

- project/workspace manifest;
- lock/dependency manifest;
- source root or entrypoint;
- backend/server module root;
- mobile/client module root;
- synthetic/unit-test root or entrypoint;
- declared tool-version/configuration file.

Do not open candidate contents in this task. Record exact candidate locators only.

## 4. Forbidden discovery

Do not:

- use repository-wide filename search;
- use grep/ripgrep/find/recursive directory enumeration;
- traverse deeper than one level under an authorized candidate root;
- open arbitrary implementation files;
- guess sibling/alternate paths not visible in the authorized listings;
- access old `D:\EliteSync` or any historical repository;
- inspect generated/build/cache/package directories;
- inspect Git LFS or binary artifacts;
- run Flutter, Dart, Gradle, Java, Kotlin, Node, Python, backend runtimes, package managers or build tools;
- use network for dependency/tool discovery;
- access Sandbox, DEP13 or B12.

## 5. Required classifications

For every authorized root/candidate, classify only from names/types:

- `ROOT_ENTRY_PRESENT`
- `ROOT_ENTRY_ABSENT`
- `AUTHORIZED_CANDIDATE_ROOT_PRESENT`
- `AUTHORIZED_CANDIDATE_ROOT_ABSENT`
- `CANDIDATE_MANIFEST_LOCATOR_IDENTIFIED`
- `CANDIDATE_LOCK_LOCATOR_IDENTIFIED`
- `CANDIDATE_SOURCE_LOCATOR_IDENTIFIED`
- `CANDIDATE_TEST_LOCATOR_IDENTIFIED`
- `CANDIDATE_TOOL_CONFIG_LOCATOR_IDENTIFIED`
- `AMBIGUOUS_MULTIPLE_CANDIDATE_LOCATORS`
- `NO_IMPLEMENTATION_LOCATOR_RESOLVED_WITHIN_BOUNDS`

A name is only a locator candidate. It does not establish technology, dependency resolution, buildability or implementation authority.

Preserve exactly:

`CANDIDATE LOCATOR != DECLARED TECHNOLOGY`

`DECLARED TECHNOLOGY != ACCEPTED TECHNOLOGY SELECTION`

`MANIFEST LOCATOR != DEPENDENCY RESOLVED`

`SOURCE LOCATOR != SOURCE BUILDS`

`TEST LOCATOR != TEST PASSES`

## 6. Success outcomes

The task must end in exactly one of:

### Outcome A — one bounded target family resolved

One coherent candidate source/manifest family is identifiable from the shallow listings without conflict. Publish exact candidate locators for a future content-read task. Do not read them yet.

### Outcome B — multiple plausible families

Multiple candidate source/manifest families are visible. Publish all exact candidate locators and stop for a later bounded disambiguation task. Do not choose one.

### Outcome C — none resolved

No candidate implementation locator is visible within the authorized bounds. Report the exact exhausted bounds and stop. Do not expand search.

## 7. Execution facts remain closed

Regardless of outcome:

- `TOOL_AVAILABILITY = NOT_CHECKED`
- `DEPENDENCY_RESOLUTION = NOT_CHECKED`
- `BUILD = NOT_RUN`
- `TEST = NOT_RUN`
- `RUNTIME = NOT_RUN`
- `CACHE_ARTIFACT_STATE = NOT_CHECKED`
- M1 = exhausted
- M2 = deferred
- M3 = blocked
- DEP13 = unauthorized/unestablished
- B12 = unauthorized/unestablished

## 8. Validation density

Include at least 100 independently checkable validation rows covering:

- root listing completeness;
- every authorized candidate root present/absent classification;
- one-level traversal boundary;
- every identified candidate locator and category;
- ambiguity/no-target disposition;
- prohibited-action non-use;
- execution facts remaining closed;
- no technology-selection inference.

Report:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

List every retained unknown and blocker.

## 9. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_IP_11B_CURRENT_V10_IMPLEMENTATION_LOCATOR_RESOLUTION_DISCOVERY_RESULT_V0_1.md`

## 10. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-11b-current-v10-implementation-locator-resolution-discovery-v0-1`

Publish only the exact result file, report branch/candidate/sole parent/tree/blob/scope and `git diff --check`, then STOP.

Do not self-accept, merge, select technology, read identified candidate contents, acquire dependencies, invoke tooling, build/test/run, or start a successor.
