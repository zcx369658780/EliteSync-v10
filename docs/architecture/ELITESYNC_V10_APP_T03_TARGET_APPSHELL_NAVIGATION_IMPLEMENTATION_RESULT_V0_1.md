# EliteSync v10｜APP-T03 Target AppShell Navigation Implementation Result｜v0.1

Status: `CANDIDATE — AWAITING INDEPENDENT ACCEPTANCE`

Date: 2026-09-12 (Asia/Singapore).

Task base: `8bbf4a1d3429591a29ff189a3d1d7eb00961728a`.

Task blob: `f789991467a8822cccc57a50857ed6e18f798f73`.

Accepted APP-T01 result blob: `8ebe98c52b322b7e1a7f1dbac8a621748123f418`.

Accepted APP-T02 result blob: `5393438eec4204640b5be639158528bd08ec8b16`.

## 1. Result and scope

APP-T03 implements the MVP top-level AppShell as exactly four primary destinations, in order:

`Home | Progress | Messages | Me`

The implementation changes navigation ownership only. It preserves:

`Match != Connection != Conversation != Relationship`

No Profile-purpose split, readiness/questionnaire/verification change, Match lifecycle change, Connection implementation, Conversation consent/gating, Relationship implementation, Home redesign, Discover implementation change, settings/privacy/notification redesign, retained-UNKNOWN resolution or APP-T04 work was performed.

The work ran in the fresh isolated worktree `D:\EliteSync-v10-app-t03-v0-1`, created from the verified task base. The original dirty detached `D:\EliteSync-v10` worktree was not checked out, staged, cleaned, reset, stashed, adopted or modified.

## 2. Exact changed files

Authorized product source:

1. `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`
2. `apps/flutter_elitesync_module/lib/app/router/app_router.dart`
3. `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
4. `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart` — new

Authorized narrow router tests:

5. `apps/flutter_elitesync_module/test/app/router/app_shell_copy_test.dart`
6. `apps/flutter_elitesync_module/test/app/router/first_use_onboarding_router_integration_test.dart`

Required artifact:

7. `docs/architecture/ELITESYNC_V10_APP_T03_TARGET_APPSHELL_NAVIGATION_IMPLEMENTATION_RESULT_V0_1.md`

`apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart` was inspected only for four-item mechanical compatibility and was not changed. Its generic `items` loop supports four destinations, so the task stop condition was not hit.

## 3. Implemented navigation contract

### 3.1 Primary shell and selected-state mapping

`AppShell` now supplies exactly these localized visible items:

| Index | Target ownership | Visible label | Shell page |
|---:|---|---|---|
| 0 | Home | `首页` | `HomeShellPage` -> existing `HomePage` |
| 1 | Progress | `进展` | `ProgressShellPage` -> new `ProgressPage` |
| 2 | Messages | `消息` | `MessagesShellPage` -> existing `ConversationListPage` |
| 3 | Me | `我的` | `MeShellPage` -> existing `ProfilePage` temporary compatibility surface |

`StatefulShellRoute.indexedStack` now has the same four branches in the same order. `_onTap` continues to use the branch index directly, and the narrow navigation test asserts each label, shell page and selected index.

The old `browseMode: currentIndex != 2` coupling was replaced by the named `_progressIndex = 1` mapping. The test contract asserts that Progress alone uses the non-browse presentation mode, so the old Match index behavior cannot silently attach to Messages.

### 3.2 Progress and Match boundary

The target route vocabulary now includes:

- `AppRouteNames.progress = '/progress'`;
- `AppRouteNames.progressMatch = '/progress/match'`;
- relative child segment `AppRouteNames.progressMatchSegment = 'match'`.

`ProgressPage` is a minimal navigation container. Its only functional child action is `匹配`, which routes to `/progress/match`; that child continues through `MatchShellPage` to the existing `MatchPortalPage` without modifying canonical or legacy Match behavior.

The page presents no Connection or Relationship status/action. Its copy states only that Match does not automatically establish Connection or open Conversation. It imports neither transport `ConnectionStatusBanner` / `chatConnectionProvider` nor the local Match relationship-runtime fixture.

### 3.3 Home, Messages and Me

- Home remains the current `HomePage`; no Calm State Hub redesign was included.
- Messages remains the current `ConversationListPage`; no Conversation data, lifecycle, consent or guard was changed.
- Me establishes `/me` top-level ownership while temporarily rendering the existing aggregate `ProfilePage`. This does not claim the APP-T01 purpose separation is complete.

### 3.4 Compatibility and Discover

- `/match` remains as a temporary compatibility route and redirects to `/progress/match`, so direct existing Match consumers reach the Progress-owned Match child.
- `/profile` remains as a temporary compatibility route and redirects to `/me`.
- `/discover` remains reachable as a standalone non-primary compatibility route through the unchanged Discover surface.
- Discover is absent from the four AppShell branches and bottom navigation. No Discover feature file, controller, data source, entity or behavior changed.
- Legacy Match/Profile/chat child routes and constants remain in place.

Provider warm-up mapping recognizes both the new Progress Match path and legacy Match path, and both new Me and legacy Profile paths. Provider implementations were not changed.

## 4. Required acceptance evidence

| Requirement | Evidence / result |
|---|---|
| Exactly four destinations in target order | `AppShell` item list and four indexed router branches map `首页 / 进展 / 消息 / 我的` at indices `0 / 1 / 2 / 3`; bounded source assertion PASS. |
| Coherent selected state | Direct branch-index mapping retained; navigation test asserts `currentIndex`; bounded source assertion PASS. |
| Home remains Home | Branch 0 still returns `HomeShellPage` -> `HomePage`. |
| Progress is distinct with Match child | Branch 1 returns `ProgressShellPage`; `/progress/match` returns `MatchShellPage` -> existing `MatchPortalPage`. |
| Messages remains Conversation list | Branch 2 still returns `MessagesShellPage` -> `ConversationListPage`. |
| Me owns former Profile position | Branch 3 uses `/me` and `MeShellPage`; current `ProfilePage` is explicitly temporary compatibility presentation. |
| Discover is not primary | No Discover item or shell branch; `/discover` is standalone compatibility only. |
| No fabricated Connection/Relationship | No corresponding state, provider, fixture or action added; bounded import/content assertion PASS. |
| No smuggled consent/Match lifecycle work | No Chat/Conversation or Match projection/provider/data file changed. |
| Exact source boundary | Git changed-path inventory contains only the authorized source/test paths plus this result artifact. `FloatingDockBottomBar` diff is empty. |

## 5. Verification ledger

### 5.1 Formatting

Command:

`dart format lib/app/router/app_shell.dart lib/app/router/app_router.dart lib/app/router/app_route_names.dart lib/features/progress/presentation/pages/progress_page.dart test/app/router/app_shell_copy_test.dart test/app/router/first_use_onboarding_router_integration_test.dart`

Outcome: exit `0`; all six Dart paths formatted. The formatter warned that `package:flutter_lints/flutter.yaml` could not be resolved because the fresh worktree had no resolved package configuration. No dependency retrieval was attempted.

Final check `dart format --output=none --set-exit-if-changed` on the same six paths exited `0` with `0 changed`.

### 5.2 Static analysis

Command:

`flutter analyze --no-pub`

Outcome: exit `1`, `33327 issues found`; **not a usable source-analysis result**. The first and pervasive failures were unresolved `package:flutter/...`, `flutter_riverpod`, project package imports and `flutter_lints`. Exact precondition check established:

- `pubspec.yaml` declares `flutter_test` with the Flutter SDK and `flutter_lints: ^6.0.0`;
- `.dart_tool/package_config.json` is absent in the fresh worktree.

No `pub get`, dependency resolution, cache adoption or network fallback was authorized or performed. This is a local dependency-graph/tooling precondition limitation, not evidence of an APP-T03 product defect.

### 5.3 Narrow router/navigation tests

Command:

`flutter test --no-pub test/app/router/app_shell_copy_test.dart test/app/router/first_use_onboarding_router_integration_test.dart`

Outcome: exit `1` before test discovery/body execution with:

`Error: cannot run without a dependency on either "package:flutter_test" or "package:test".`

Test bodies executed: `0`. The two narrow tests were updated to cover the four-item Dock order, absence of Discover/Match as primary items, all four shell destinations, selected index/`browseMode`, and the Progress-to-Match child entry, but executable PASS/FAIL is `NOT ESTABLISHED` because the same local package configuration is absent.

### 5.4 Bounded source-contract checks

A read-only exact-source assertion checked:

- visible labels equal `首页|进展|消息|我的`;
- exactly four `StatefulShellBranch` declarations;
- `home/progress/messages/me` route constants;
- Progress Match child binding;
- `/match` and `/profile` compatibility redirects;
- Discover retained outside primary shell;
- `_progressIndex = 1` with old `currentIndex != 2` removed;
- no Connection transport or relationship-runtime import/use in `ProgressPage`;
- no `FloatingDockBottomBar` change.

Outcome: exit `0`; all nine assertions `True`.

`git diff --check` passed before result publication. Final staged scope and worktree cleanliness are verified after the exact commit.

## 6. Boundaries retained

- `Match != Connection != Conversation != Relationship`.
- Match remains a distinct Progress child and does not create Connection.
- Transport connectivity is not Product Connection.
- The local Match relationship-runtime fixture is not Product Relationship.
- Messages remains Conversation ownership; no messaging-consent authority was invented.
- Me does not claim Profile-purpose separation is complete.
- Discover implementation is unchanged and its remote-content privacy/production class is not reclassified.
- Retained UNKNOWNs remain unresolved.
- `LOCAL TOOLING BLOCKER != PRODUCT DEFECT`.
- No emulator, ADB, backend/product network, populated private-data, participant, telemetry, Safety, legal, Sandbox/DEP13/B12/M2/M3 or APP-T04 action occurred.

## 7. Classification

The source implementation establishes the bounded four-destination AppShell. Executable static-analysis and widget-test conclusions remain unavailable solely because the clean worktree has no resolved local package graph; this limitation is fully preserved for independent review and is not relabeled as a test pass.

`APP-T03 FOUR-DESTINATION APPSHELL IMPLEMENTED — READY FOR INDEPENDENT ACCEPTANCE`
