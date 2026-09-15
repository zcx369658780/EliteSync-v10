# EliteSync v10｜NEXT IP-11A Current-v10 Implementation Target and Tooling Source-Fact Discovery Task｜v0.1

Status: `OWNER-DELEGATED BOUNDED READ-ONLY DISCOVERY AUTHORIZED — SOURCE / MANIFEST / TOOLING DECLARATION FACTS ONLY — NO TECHNOLOGY SELECTION OR EXECUTION`

Date: 2026-09-15 (Asia/Singapore)

Repository: `zcx369658780/EliteSync-v10`

Task-publication base: `e01fe5b614dd18ffdcd16ca4c12f41562efbe7f1`

## 1. Purpose

Establish only the current v10 repository-declared implementation-target and tooling source facts needed for a later technology-selection decision.

This task is read-only discovery. It does not select technology, acquire dependencies, resolve packages, run tools, build, test, implement code, modify configuration, inspect caches/artifacts, or authorize any successor automatically.

## 2. Required first reads

After fresh-fetching `main`, read `AGENTS.md` first.

Then read only:

1. `docs/architecture/ELITESYNC_V10_POST_IP01_IP10_IMPLEMENTATION_EXECUTION_ENTRY_REVIEW_ACCEPTANCE_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_POST_IP01_IP10_IMPLEMENTATION_EXECUTION_ENTRY_REVIEW_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_CLIENT_INTEGRATION_PLAN_ACCEPTANCE_V0_1.md`
4. `docs/architecture/ELITESYNC_V10_CLIENT_INTEGRATION_PLAN_V0_1.md`

No other governance read is authorized unless one of these exact files contains a direct exact-path reference needed to interpret an allowlisted source declaration.

## 3. Exact source/manifest/tooling allowlist

Probe existence and, if present, read/hash only these literal repository paths:

### Root project declarations

- `pubspec.yaml`
- `pubspec.lock`
- `analysis_options.yaml`
- `.metadata`

### Primary Flutter/Dart entry/source declarations

- `lib/main.dart`
- `lib/app.dart`
- `test/widget_test.dart`

### Android / Gradle declarations

- `android/settings.gradle`
- `android/settings.gradle.kts`
- `android/build.gradle`
- `android/build.gradle.kts`
- `android/app/build.gradle`
- `android/app/build.gradle.kts`
- `android/gradle.properties`
- `android/gradle/wrapper/gradle-wrapper.properties`

### Tool-version declarations

- `.fvmrc`
- `.fvm/fvm_config.json`
- `.tool-versions`
- `melos.yaml`

These paths are an evidence allowlist, not a statement that they exist or that Flutter/Gradle is the accepted implementation technology.

Do not enumerate directories. Do not broaden to sibling/alternative paths. Do not search by filename, extension, framework name, package name, or synonym. A missing exact path remains `LOCATOR_ABSENT_WITHIN_ALLOWLIST`, not permission to discover another path.

## 4. Facts that may be established

For each allowlisted path, classify only facts directly declared by the file:

- `LOCATOR_EXISTS`
- `LOCATOR_ABSENT_WITHIN_ALLOWLIST`
- `DECLARED_PROJECT_TYPE_OR_TECHNOLOGY`
- `DECLARED_SOURCE_ENTRYPOINT`
- `DEPENDENCY_DECLARED`
- `DEPENDENCY_VERSION_CONSTRAINT_DECLARED`
- `LOCKED_DEPENDENCY_DECLARED`
- `DECLARED_TOOL_OR_PLUGIN_VERSION`
- `DECLARED_LANGUAGE_OR_SDK_CONSTRAINT`
- `DECLARED_SYNTHETIC_TEST_ENTRY`
- `DECLARATION_CONFLICT_OR_AMBIGUITY`
- `NOT_ESTABLISHED_BY_ALLOWLIST`

Do not infer availability, installability, compatibility, buildability, runtime viability, security, legal suitability, production readiness, or technology preference from declarations.

## 5. Mandatory separation of declaration from execution facts

The result must preserve exactly:

- `DECLARED TECHNOLOGY != ACCEPTED TECHNOLOGY SELECTION`
- `DEPENDENCY DECLARED != DEPENDENCY RESOLVED`
- `TOOL VERSION DECLARED != TOOL AVAILABLE`
- `SOURCE ENTRY DECLARED != SOURCE BUILDS`
- `TEST ENTRY DECLARED != TEST PASSES`
- `MANIFEST EXISTS != DEPENDENCY ACQUISITION AUTHORITY`
- `LOCKFILE EXISTS != CURRENT CACHE/ARTIFACT AVAILABILITY`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`

Report execution facts only as:

- `TOOL_AVAILABILITY = NOT_CHECKED`
- `DEPENDENCY_RESOLUTION = NOT_CHECKED`
- `BUILD = NOT_RUN`
- `TEST = NOT_RUN`
- `RUNTIME = NOT_RUN`
- `NETWORK = NOT_USED`
- `CACHE_ARTIFACT_STATE = NOT_CHECKED`

## 6. Preserved historical/tooling boundaries

Do not reopen or alter:

- M1 exhausted;
- M2 deferred;
- M3 blocked;
- Sandbox unavailable/blocker history;
- DEP13 unauthorized/unestablished;
- B12 unauthorized/unestablished.

Do not access the historical `EliteSync` repository or local old-repository paths.

Do not run Flutter, Dart, Gradle, Java, Kotlin, package managers, backend runtimes, scripts, generated tools, emulators/devices, tests, builds, network commands, dependency downloads, cache probes, artifact probes, Sandbox actions, DEP13 or B12.

## 7. Required evidence tables

Produce:

1. exact locator table: path / exists / blob hash / bytes or line count if directly available;
2. declared project/technology facts;
3. dependency declarations by exact manifest source;
4. SDK/language/plugin/tool-version declarations;
5. declared source entrypoints;
6. declared synthetic test entrypoints;
7. conflicts/ambiguities/missing-locator ledger;
8. execution-fact non-check ledger;
9. technology-selection implications limited strictly to what is now knowable vs still unknown.

Do not recommend a framework/provider/database merely because it is declared. A later decision may choose to preserve, replace, or retire current source.

## 8. High-density validation

Include at least 120 independently checkable validation rows.

Use exactly:

- `PASS`
- `RETAINED_UNKNOWN`
- `BLOCKED`

Do not stop after the first ordinary missing locator or ambiguity. Complete every independent allowlisted check still evaluable.

Report totals:

`PASS = N / RETAINED_UNKNOWN = N / BLOCKED = N`

List every retained unknown and blocker.

A missing optional alternative path is not automatically a blocker if another allowlisted declaration establishes the same requested fact. A conflict between simultaneously active declarations, or absence of any source/manifest declaration sufficient to identify a later technology-selection target, is a blocker for the next selection decision.

## 9. Exact output

Write exactly:

`docs/architecture/ELITESYNC_V10_IP_11A_CURRENT_V10_IMPLEMENTATION_TARGET_AND_TOOLING_SOURCE_FACT_DISCOVERY_RESULT_V0_1.md`

## 10. Stop boundary

Create one candidate branch, recommended:

`review/next-ip-11a-current-v10-implementation-target-tooling-source-fact-discovery-v0-1`

Publish only the exact result file.

Report branch, candidate, sole parent, tree, result blob, exact scope and `git diff --check`, then STOP.

Do not self-accept, merge, select technology, create a technology-decision artifact, authorize acquisition, run any toolchain, or start implementation.

Expected success classification:

`CURRENT V10 IMPLEMENTATION TARGET / MANIFEST / TOOLING DECLARATION FACTS ESTABLISHED — EXECUTION FACTS REMAIN NOT_CHECKED/NOT_RUN — READY FOR INDEPENDENT REVIEW AND SEPARATE TECHNOLOGY-SELECTION DECISION — NO IMPLEMENTATION AUTHORITY CREATED`