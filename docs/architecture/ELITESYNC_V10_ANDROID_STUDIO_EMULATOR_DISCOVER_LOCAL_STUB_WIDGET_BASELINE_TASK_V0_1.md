# EliteSync v10｜Android Studio Emulator Discover Local-Stub Widget Baseline Task｜v0.1

Status: `PUBLISHED TASK SHEET — DISCOVER LOCAL-STUB WIDGET BASELINE — SYNTHETIC DATA ONLY — ZERO PRODUCTION REQUESTS — NO UI INTERACTION — NO SOURCE MODIFICATION — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`5e9289aa1614f1d083317ceda09b30084fd1415e`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted Discover runtime-eligibility acceptance:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_DISCOVER_RUNTIME_ELIGIBILITY_REVIEW_ACCEPTANCE_V0_1.md`

Accepted candidate/result:

- candidate commit: `86925a24872d5c7a77bc296879eb718b40f558cf`
- result blob: `b71bc79b4d026b1a69705626603aac1e17251d58`
- accepted eligibility: `DISCOVER LOCAL-STUB WIDGET BASELINE AUTHORABLE`
- direct emulator Discover baseline: NOT AUTHORIZED
- real remote Discover content class: `RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`

This task gathers deterministic synthetic widget evidence only. It does not authorize Discover emulator navigation or production remote access.

## 2. Sole objective

Establish one deterministic Discover first-frame widget baseline using the current `DiscoverPage` with a controlled provider override and explicitly synthetic feed data, while proving:

1. ordinary page/controller initialization occurs through the real current widget/controller chain;
2. the controlled fake `fetchDiscoverFeedPage` is invoked exactly once for initialization;
3. no production `ApiClient` request occurs;
4. no user interaction, destination navigation, refresh/retry, action sheet, or content-detail flow occurs;
5. the initial stable synthetic Discover frame has bounded visual and semantics evidence suitable for later independent review.

This is evidence gathering only. It does not authorize product implementation.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, else `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the Discover runtime-eligibility acceptance named in §1;
6. do not use conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Exact current-source identity gates

Before harness creation, require current-main exact blobs:

- `apps/flutter_elitesync_module/lib/features/discover/presentation/pages/discover_page.dart`
  - `b393ca20ad3e72bc3f3256ac1c1f29d6cbbc91f9`
- `apps/flutter_elitesync_module/lib/features/discover/presentation/controllers/discover_feed_controller.dart`
  - `da3851531aba357d019b512ce8f60cb1d2e9b86e`
- `apps/flutter_elitesync_module/lib/features/home/presentation/providers/home_provider.dart`
  - `a0a58c72d9bd15cf95fd0b7d02568a2d7217c3c1`
- `apps/flutter_elitesync_module/lib/features/home/data/datasource/home_remote_data_source.dart`
  - `58eafaf97749207fdce24d04ffe441d1a3d0b0d5`
- `apps/flutter_elitesync_module/test/features/discover/presentation/pages/discover_page_test.dart`
  - `551e4d2e8db37511422d1e6c4e6b64f92f320704`
- `apps/flutter_elitesync_module/lib/design_system/components/layout/browse_scaffold.dart`
  - `a064369146732eca394d3b2abfe473d5fff3ef48`

If any required identity differs, stop:

`DISCOVER_LOCAL_STUB_BASELINE_SOURCE_IDENTITY_CHANGED`

Do not adapt a harness to changed source by inference.

## 5. Temporary-harness authority

Create exactly one task-owned TEMP Flutter widget-test harness outside tracked repository source/test/build paths.

Requirements:

- fresh task-owned TEMP directory;
- harness is NOT tracked and NOT committed;
- record exact harness path and SHA-256;
- may use current package imports and current local package configuration;
- if package configuration is absent in the dedicated worktree, exactly one `flutter pub get --offline` inside `apps/flutter_elitesync_module` is authorized solely to establish local package state;
- no network package retrieval;
- tracked source/test/pubspec/lock/build/config files must remain byte-identical;
- no alternate second harness.

If host/tool policy prevents the TEMP harness without tracked modifications, stop:

`DISCOVER_LOCAL_STUB_TEMP_HARNESS_NOT_EXECUTABLE`

Do not fall back to modifying `discover_page_test.dart`.

## 6. Controlled synthetic data contract

The harness must define one controlled `HomeRemoteDataSource` subclass/fake equivalent to the already-established focused-test seam and inject it with:

`homeRemoteDataSourceProvider.overrideWithValue(controlledRemote)`

The controlled fake must:

- override `fetchDiscoverFeedPage(...)` directly;
- increment an explicit `discoverFetchCount` on each invocation;
- return exactly three clearly synthetic `HomeFeedDto` items;
- use obviously synthetic, non-personal values such as ids `synthetic-discover-1..3`, generic titles/summaries, author `Synthetic Fixture`, zero/non-sensitive likes, no real participant identifiers, no private Conversation content, and no production-derived values;
- return `hasMore = false`, `nextCursor = null`;
- never delegate to `super.fetchDiscoverFeedPage`.

The synthetic strings must not impersonate a real user, participant, community member, or production record.

## 7. Zero-production-request proof

The harness must prove production request count remains `0`.

Use a task-local counting network client/instrumentation that would increment `apiRequestCount` if its Dio/ApiClient transport were invoked. It may be supplied to the controlled `HomeRemoteDataSource` superclass constructor only as inert instrumentation.

Required final counters:

- `discoverFetchCount == 1`
- `apiRequestCount == 0`
- content-detail entry count `== 0`
- interaction count `== 0`

If `apiRequestCount > 0`, immediately classify the baseline invalid and stop. Do not inspect the response.

Do not contact localhost or any external URL as a test probe; zero-request proof must come from in-process controlled instrumentation.

## 8. Render configuration

Render current `DiscoverPage` only, in a local wrapper sufficient for ProviderScope/theme/router safety.

Required fixed configuration:

- logical viewport `390 x 844`;
- DPR `1.0`;
- light theme;
- default text scale `1.0`;
- no AppShell navigation required;
- content-detail route, if a router is technically required, must be a local stub that records entry count and is never entered.

The harness may pump/settle only until the single controlled initialization fetch completes and the stable synthetic content frame is rendered.

No tap, click, scroll, drag, refresh gesture, retry, action-sheet opening, focus interaction, or route navigation is authorized.

## 9. Required visual/structural evidence

Preserve exactly these three task-owned files outside the repository:

1. exactly one rendered Discover PNG;
2. exactly one bounded semantics/structure JSON/text artifact;
3. exactly one machine-readable receipt JSON/text artifact.

Record SHA-256 and byte size for each.

The receipt must include at least:

- viewport/DPR/theme/text scale;
- all source identity-gate results;
- `discoverFetchCount`;
- `apiRequestCount`;
- interaction count;
- content-detail entry count;
- Flutter exception count;
- presence count for header `发现`;
- presence count for subtitle `浏览少量关系与活动灵感，感兴趣时再看详情。`;
- count of synthetic Discover item ids rendered/represented;
- presence of loading/error/empty states after settle;
- number and labels of visible actionable controls represented by semantics without invoking them;
- exact top-level bounds for header and first synthetic content unit where determinable;
- clipping/overflow/framework exception evidence.

## 10. Baseline interpretation rule

This task may establish only:

- deterministic local-stub rendering of current Discover source;
- source/widget structure visible from synthetic data;
- semantics/actions present without invocation;
- layout/clipping/overflow facts at this single widget configuration;
- zero-production-request and one-controlled-fetch facts.

It must NOT claim:

- production Discover data safety/privacy;
- Backend correctness;
- emulator/runtime equivalence;
- content-detail correctness;
- participant-flow correctness;
- release or production readiness.

## 11. Explicit prohibitions

Do NOT:

- modify tracked source/tests/build/pubspec/configuration;
- commit TEMP harness, package state, or evidence files;
- run emulator/ADB/uiautomator/logcat/device screenshot;
- navigate AppShell to Discover on the emulator;
- call real `/api/v1/discover/feed` or any production/remote endpoint;
- inspect real remote responses;
- tap/click/scroll/refresh/retry/open action sheet/enter content detail;
- access private/user/participant/Conversation data;
- inspect Backend/Database/PUI production behavior;
- run broad/full test suites;
- download dependencies, SDK components, or system images;
- read README;
- inspect FD02;
- search history/non-main branches;
- perform broad repository archaeology;
- create Windows Sandbox;
- run DEP13, B12, M2, M3 acquisition, or unrelated implementation.

## 12. Required result candidate

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_DISCOVER_LOCAL_STUB_WIDGET_BASELINE_RESULT_V0_1.md`

Candidate commit must contain only that result artifact.

Result must record:

- main/FIRST/task/acceptance identities;
- source identity gates;
- TEMP harness path/SHA-256;
- exact execution command and result;
- synthetic dataset specification;
- final controlled/ApiClient/interaction/navigation counters;
- evidence paths/byte sizes/SHA-256 values;
- visual/structural/semantics findings;
- Flutter exception/overflow result;
- exact limits of what this baseline establishes;
- exact next bounded recommendation;
- negative attestations for tracked modifications, production request, UI interaction, remote/private data, acquisition, broad QA, Sandbox/DEP13.

Final classification exactly one of:

`DISCOVER LOCAL-STUB WIDGET BASELINE ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`

or

`DISCOVER LOCAL-STUB WIDGET BASELINE NOT ESTABLISHED — CONTROLLED/LOCAL GATE FAILED — AWAITING INDEPENDENT ACCEPTANCE`

Stop immediately after publishing the one candidate. Do not self-accept or publish an implementation/runtime task.

## 13. Preserved boundaries

Real Discover remote content remains:

`RUNTIME REMOTE CONTENT OF UNKNOWN PRIVACY/PRODUCTION CLASS`

Direct Discover emulator baseline remains unauthorized.

Home H1/H2 remain `NO MIGRATION ENTRY ESTABLISHED`; closed Home semantics findings remain closed absent new evidence.

Remain unchanged:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Accepted B R4 share-success fact remains valid. Sandbox DEP13 remains unresolved. Widget evidence remains separate from Sandbox DEP13 evidence.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

## 14. End state

`DISCOVER REMOTE PATH NOT AUTHORIZED -> CONTROLLED LOCAL-STUB WIDGET BASELINE`

`LOCAL-STUB BASELINE != EMULATOR BASELINE`

`SYNTHETIC DATA != PRODUCTION DATA CLASSIFICATION`

`WIDGET EVIDENCE != SANDBOX DEP13 EVIDENCE`
