# EliteSync v10｜NEXT-T03 Flutter Tooling / Package-Graph Evidence Restoration Task｜v0.1

Status: `OWNER-AUTHORIZED TRACK 3 TASK — TOOLING / EVIDENCE RESTORATION ONLY — NO PRODUCT IMPLEMENTATION`

Repository: `zcx369658780/EliteSync-v10`

Owner-approved sequence: `Track 1 -> Track 2 -> Track 3`.

Track 1 acceptance is established.

Track 2 Owner acceptance commit immediately before this task:

`c45b7f8525c7a185cb84a2576e13674526292e14`

Accepted Track 2 Owner decision artifact:

`docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`

## 1. Objective

Restore and independently characterize the Flutter tooling/package-graph evidence state for the EliteSync v10 Flutter module without changing product behavior, backend behavior, legal/data-right semantics, compatibility scope, or dependency-governance authority.

The retained MVP tooling/evidence gap is currently:

- clean Flutter review worktrees lack `.dart_tool/package_config.json`;
- executable Flutter tests are `NOT ESTABLISHED`;
- `flutter analyze --no-pub` is `NOT ESTABLISHED`.

This task may establish whether those evidence gaps can be restored using the repository's already-declared dependency graph and currently authorized local tooling.

It must NOT treat the absence of package graph/test/analyze evidence as a product defect.

## 2. Required fresh-start gate

Before substantive work:

1. `git fetch origin`.
2. Verify fresh `origin/main`.
3. Read `AGENTS.md` FIRST.
4. Read, in order:
   - `docs/architecture/ELITESYNC_V10_MVP_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260913_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_BACKEND_AUTHORITY_READ_MODEL_PLANNING_ACCEPTANCE_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_CONVERSATION_DATA_RIGHTS_DECISION_CLOSURE_OWNER_ACCEPTANCE_V0_1.md`
   - this task sheet.
5. If `origin/main` differs from `c45b7f8525c7a185cb84a2576e13674526292e14`, inspect intervening commits before proceeding. If they materially alter Flutter dependency declarations, tooling policy, or Track 3 scope, stop and report the conflict.

No broad repository enumeration is authorized.

## 3. Binding invariants

Preserve exactly:

- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`
- `TRANSPORT FAILURE != DOMAIN OUTCOME`
- `UNKNOWN != ABSENT`
- `DEFERRED != MISSING`
- `CURRENT SOURCE EXISTS != MUST KEEP`
- `Match != Connection != Conversation != Relationship`
- `STATE VOCABULARY != AUTHORITY`
- `ROUTE IDENTITY != CONSENT`
- private Conversation != default Match/ranking/training data
- no globally public MVP Profile authority
- candidate-scoped Showcase
- no authoritative Compatibility total score

Track 1/2 decisions do not authorize product implementation here.

## 4. Exact in-scope evidence targets

This task is limited to the Flutter module used by the accepted APP-T03–T12 chain.

Establish, where technically possible within this task's authority:

### T03-A — Local Flutter/Dart tool availability

Record exact locally invoked Flutter and Dart versions/identities needed to interpret the evidence.

Do not upgrade, downgrade, install, repair, or globally reconfigure Flutter/Dart.

### T03-B — Declared dependency graph inputs

Read only the minimum repository dependency manifests/lockfiles required to understand the already-declared Flutter package graph.

Do not redesign dependency versions.

Do not modify `pubspec.yaml`, lockfiles, Gradle files, Android manifests, generated registrants, or dependency declarations.

### T03-C — Package graph restoration attempt

A bounded `flutter pub get` / equivalent package-graph restoration attempt is authorized ONLY for already-declared repository dependencies, subject to the stop rules below.

This authorization does NOT authorize:

- adding packages;
- changing package versions;
- changing dependency sources;
- editing lockfiles intentionally;
- resuming Sandbox/DEP13/B12 acquisition;
- manually downloading or substituting artifacts;
- bypassing dependency/source governance;
- changing proxy, certificate, browser, model, notification, system-wide package-manager, Gradle, Java, Android SDK, or global network configuration.

If restoration requires any such change, stop and classify the blocker precisely.

Generated/local ephemeral package metadata such as `.dart_tool/package_config.json` may be created by the authorized tooling command in the bounded worktree. Do not commit generated/tooling-state output unless the task sheet explicitly requires it; this task does not.

### T03-D — Flutter test evidence

If package graph restoration succeeds without crossing a stop boundary, run the minimum repository-relevant Flutter test command necessary to establish executable test evidence for the accepted MVP Flutter module.

Prefer existing test scope rather than inventing new tests.

Do not modify product/test source merely to make tests pass.

Classify failures by evidence category, for example:

- product/test assertion failure;
- compile/type failure;
- dependency/toolchain failure;
- environment/runtime failure;
- teardown/runner failure;
- authorization boundary blocker.

Do not automatically classify every failed Flutter command as a product defect.

### T03-E — Analyze evidence

If the package graph is established, run:

`flutter analyze --no-pub`

for the bounded Flutter module or the exact accepted repository scope required by its existing configuration.

Record the result faithfully.

Do not modify product source to silence analyzer output in this task.

## 5. Historical route separation

The historical Sandbox/DEP13/B12/M2/M3 route remains separate.

Known preserved blocker:

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

This Track 3 task does NOT authorize resuming that chain.

If `flutter pub get` reaches an already-declared dependency whose source acquisition is governed by the historical DEP13/B12 chain, or otherwise requires authority outside ordinary already-declared package restoration, STOP before bypassing, substituting, or acquiring it through an unauthorized route.

Report the exact package/source and the authority boundary encountered.

Do not infer B12 authorization from this Track 3 task.

## 6. Repository write boundary

Do not modify product, backend, test, dependency, build, generated-source, configuration, or lockfile content as a means of restoring evidence.

Permitted repository write output is exactly one documentation artifact:

`docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md`

Local ephemeral tooling state created by commands is not a repository deliverable and must not be intentionally committed.

If an authorized command modifies a tracked lockfile or other tracked repository file automatically, do not commit that modification. Record it, restore only the task-created tracked change if safely possible without touching unrelated user state, and otherwise stop/report according to `AGENTS.md` boundaries.

## 7. Required result artifact

The result artifact must contain at minimum:

1. fresh authority and exact task base;
2. exact Flutter/Dart tool versions observed;
3. exact bounded module/scope used;
4. pre-attempt package-graph state;
5. package-graph restoration command and result;
6. whether `.dart_tool/package_config.json` became established;
7. Flutter test command(s) and exact result, if authorized/reachable;
8. `flutter analyze --no-pub` command and exact result, if authorized/reachable;
9. failure classification separating product/test, tooling, dependency/source, environment/runtime, and authorization blockers;
10. whether any tracked file was changed by tooling and its final disposition;
11. explicit statement that tooling evidence does not itself alter MVP contract acceptance;
12. explicit statement that no product/backend/legal/compatibility/Phase-2 work was performed;
13. recommended next action based strictly on evidence.

## 8. Success / partial / blocked classifications

Use evidence-based classification.

### Full evidence restoration

If package graph, Flutter tests, and analyze all become executable and produce interpretable results without unauthorized changes:

`FLUTTER TOOLING / PACKAGE-GRAPH EVIDENCE RESTORED — TEST AND ANALYZE EVIDENCE ESTABLISHED — NO PRODUCT CHANGES PERFORMED`

This classification does NOT imply all tests/analyzer checks pass; the artifact must state the exact outcomes separately.

### Partial restoration

If package graph is restored but one or more later evidence targets cannot be established for a bounded non-product reason:

`FLUTTER PACKAGE GRAPH RESTORED — TOOLING EVIDENCE PARTIALLY ESTABLISHED — REMAINING BLOCKER CLASSIFIED — NO PRODUCT CHANGES PERFORMED`

### Authority/dependency/environment blocked

If the package graph cannot be restored without crossing an unauthorized dependency/source/global-environment boundary:

`FLUTTER TOOLING EVIDENCE RESTORATION BLOCKED — PACKAGE/ENVIRONMENT/AUTHORITY BOUNDARY IDENTIFIED — NOT A PRODUCT DEFECT`

Do not force a success classification.

## 9. Explicit exclusions

Do NOT:

- change Flutter/product source;
- change tests to obtain green results;
- implement backend/API/database/service changes;
- change Track 1 or Track 2 decisions;
- perform new legal research;
- determine launch regions or production legal readiness;
- remove compatibility debt;
- start Phase 2 Explore or Relationship support;
- inspect private participant/Profile/Conversation data;
- perform telemetry/analytics;
- perform Safety Operations;
- resume Sandbox/DEP13/B12/M2/M3;
- add/change dependencies;
- manually acquire governed dependency artifacts;
- change global Browser/model/notify/network/proxy/certificate/toolchain configuration;
- install/upgrade/downgrade Flutter, Dart, Gradle, Java, Android SDK, or system packages;
- run emulator/ADB unless a test command intrinsically requires an already-available local runner and no configuration/change is needed; otherwise stop before doing so;
- reopen APP-T12-B01 absent fresh regression evidence.

## 10. Delivery / Git boundary

Work on a fresh bounded branch/worktree from verified `main`.

Recommended branch:

`review/next-t03-flutter-tooling-evidence-restoration-v0-1`

Commit only:

`docs/architecture/ELITESYNC_V10_FLUTTER_TOOLING_PACKAGE_GRAPH_EVIDENCE_RESTORATION_RESULT_V0_1.md`

Recommended commit message:

`docs: record Flutter tooling evidence restoration result`

Publish the candidate branch/commit for independent review.

Do not merge, self-accept, or modify `main`.

## 11. Stop boundary

Stop after publishing the single result candidate.

Do not use a successful package-graph restoration as implicit authority to start product implementation, compatibility cleanup, backend work, or Phase 2.

Do not use a failed tooling command as authority to modify product source or dependency governance.
