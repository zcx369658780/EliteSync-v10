# EliteSync v10｜APP-T03 Target AppShell Navigation Implementation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — FOUR-DESTINATION APPSHELL ONLY`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start authority is current `origin/main` containing:

- accepted APP-T01 result blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418`;
- accepted APP-T02 result blob `5393438eec4204640b5be639158528bd08ec8b16`;
- APP-T02 acceptance.

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

1. `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md`
3. `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_ACCEPTANCE_V0_1.md`
4. this task sheet.

## 2. Local-worktree safety

The original local repository worktree is known to be detached and dirty.

Do not modify, clean, stash, reset, checkout over, delete, move, adopt, stage, commit, or otherwise disturb it.

APP-T03 explicitly authorizes a new clean worktree from fresh-fetched `origin/main` and a fresh task branch.

## 3. Sole objective

Implement the Owner-approved MVP top-level AppShell navigation:

`Home | Progress | Messages | Me`

This task changes shell/navigation ownership only.

It must not implement the later domain semantics merely because their target labels appear in the shell.

## 4. Required target behavior

### 4.1 Top-level destinations

The visible bottom navigation must contain exactly four primary destinations, in this order:

1. `Home`
2. `Progress`
3. `Messages`
4. `Me`

The old top-level `Discover`, `Match`, and `Profile` labels must no longer appear as primary destinations.

### 4.2 Home

Home remains bound to the current Home surface.

Do not implement Calm Home / lifecycle projection here. That remains APP-T08.

### 4.3 Progress

Progress is a navigation container, not a merged lifecycle state.

Create the minimal target Progress presentation at the exact new path:

`apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`

The page may present bounded entry/navigation affordances for distinct domains, but for APP-T03:

- `Match` is the only current functional child entry authorized;
- it must route to the existing `MatchPortalPage` through a Progress child route;
- Connection must not be fabricated from any transport/capability state;
- Relationship must not be fabricated from the existing local Match relationship-runtime fixture;
- Conversation must remain owned by Messages, not Progress;
- no lifecycle status may be invented from absent/UNKNOWN source authority.

If Connection/Relationship labels are shown, they must be explicitly non-authoritative future/unavailable explanatory presentation, not active states or actions. Prefer the smallest presentation that avoids implying a capability exists.

### 4.4 Messages

Messages remains bound to the current Conversation list.

Do not change Conversation gating, routes, providers, chat models, retention, consent, or private content handling in this task.

### 4.5 Me

Me replaces Profile as the top-level ownership label, but APP-T03 does not perform the Profile-purpose split.

For this bounded task, Me may continue to enter the existing `ProfilePage` as a temporary compatibility child surface.

UI or comments must not claim that the current aggregate Profile already satisfies the target Private Identity / Matching Inputs / Readiness / Showcase separation.

### 4.6 Discover

Remove Discover only from top-level AppShell ownership.

Do not delete or modify Discover feature code, controller, feed source, content entities, detail page, or production/synthetic data behavior.

Any existing non-shell route that remains required by current consumers may stay reachable under temporary compatibility until a later task retires it.

## 5. Exact existing source allowlist

APP-T03 may modify only these existing product source files:

1. `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
2. `apps/flutter_elitesync_module/lib/app/router/app_router.dart`
3. `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`

APP-T03 may create exactly this new product source file:

4. `apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`

No other existing product source file is authorized.

`apps/flutter_elitesync_module/lib/design_system/components/brand/floating_dock_bottom_bar.dart` is NOT authorized by default. If the four-item shell works through its generic API, leave it unchanged. If a concrete compile/runtime-mechanical incompatibility proves a change is necessary, STOP and report the blocker rather than expanding scope yourself.

## 6. Route compatibility boundary

Target top-level route vocabulary must establish `home`, `progress`, `messages`, and `me` ownership.

Legacy route names/constants may be retained as temporary compatibility aliases only where a direct existing consumer requires them.

Do not delete broad legacy route constants or child routes in APP-T03.

In particular:

- Match must become a Progress child/entry, not be deleted;
- Discover feature routes may remain as non-primary compatibility routes if currently required;
- Profile child routes may remain while Me is the top-level owner;
- chat/Conversation routes remain unchanged;
- no `eligibleMatch` / `legacyPeer` chat cutover occurs here.

## 7. Index / shell behavior

Update any index-coupled logic inside the authorized AppShell file so it reflects the four destinations.

The current `browseMode` coupling to the old Match index must not silently attach to the wrong destination after the index shift.

Provider warm-up logic inside `AppShell` may be adjusted only as required by the new shell ownership. Do not change provider implementations.

## 8. Privacy and guard boundary

APP-T03 must not invent readiness, Connection, Conversation or identity-assurance guards.

The existing auth-only global redirect may be mechanically updated only if necessary for the new top-level route vocabulary.

Do not claim APP-T01 private-route guard completeness after APP-T03. Full onboarding/readiness/private guard implementation remains APP-T04/APP-T06/APP-T07.

Do not expose new private data on Progress or Me.

## 9. Verification authorization

APP-T03 authorizes only the minimum verification needed for this shell change:

- `dart format` on changed/new Dart files;
- static analysis limited to the Flutter module or narrower affected target;
- existing directly relevant AppShell/router/navigation tests if they can be located by exact symbol/file-name references from the authorized route files;
- creation or modification of narrowly scoped tests only under:
  `apps/flutter_elitesync_module/test/app/router/`
  and only for the four-destination shell / route ownership introduced by APP-T03.

Do not run emulator/ADB, backend/network calls, populated private-data flows, Match runtime tests, Conversation content tests, production Discover, participant workflows, or unrelated test suites.

A test may use synthetic non-private navigation fixtures only.

## 10. Required acceptance evidence

The result must establish, using source diff plus authorized verification where available:

1. visible shell has exactly four primary destinations in target order;
2. selected-state/index mapping is coherent for all four;
3. Home still enters Home;
4. Progress is distinct and provides the bounded Match child entry;
5. Messages still enters the Conversation list ownership;
6. Me owns the former Profile top-level position while current Profile remains only a temporary child compatibility surface;
7. Discover is no longer a primary destination;
8. no product Connection or Relationship state was fabricated;
9. no Conversation consent or Match lifecycle implementation was smuggled into the shell task;
10. no source outside the allowlist/test boundary changed.

## 11. Explicit prohibitions

Do not:

- implement APP-T04 or later work;
- split Profile fields/providers/entities;
- change questionnaire/verification/readiness behavior;
- change canonical Match projection/provider/data source;
- change legacy Match behavior;
- implement Connection;
- implement Conversation consent/gating;
- change ChatRoom/Conversation data;
- implement Relationship;
- redesign Home content/state;
- modify Discover feature implementation;
- redesign settings/privacy/notifications;
- resolve error/offline/stale system-wide behavior;
- delete legacy paths;
- resolve retained UNKNOWNs;
- perform new legal/Safety/participant/telemetry work;
- resume Sandbox/DEP13/B12/M2/M3;
- inspect private populated values;
- read README or FD02.

## 12. Required candidate artifact

Create exactly one implementation result document:

`docs/architecture/ELITESYNC_V10_APP_T03_TARGET_APPSHELL_NAVIGATION_IMPLEMENTATION_RESULT_V0_1.md`

The candidate commit may contain only:

- authorized product source changes;
- authorized narrow router/navigation tests if used;
- the single result document.

Use a fresh branch, suggested:

`review/app-t03-target-appshell-navigation-implementation-v0-1`

Commit and push the candidate.

Do not merge to `main`.
Do not self-accept.
Do not start APP-T04.

## 13. Stop / failure rules

Fail closed and stop if:

- the implementation requires changing an existing product file outside the exact allowlist;
- four-item rendering requires modifying `FloatingDockBottomBar`;
- target Progress cannot be established without choosing Connection/Relationship implementation semantics;
- a current consumer requires deleting/redefining a legacy route beyond the compatibility boundary;
- authorized verification reveals a blocker requiring broad source/test changes.

Report the exact blocker rather than expanding scope.

## 14. Expected success classification

`APP-T03 FOUR-DESTINATION APPSHELL IMPLEMENTED — READY FOR INDEPENDENT ACCEPTANCE`
