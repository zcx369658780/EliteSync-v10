# EliteSync v10｜APP-T02 Current-to-Target Source Locator / Migration Inventory Acceptance｜v0.1

Status: `ACCEPTED — SOURCE LOCATOR / MIGRATION INVENTORY VALID — APP-T03 MAY PROCEED UNDER A SEPARATE BOUNDED TASK`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Accepted candidate

- base: `9e7f262acbb00946589e8fe805a2238044584c21`
- candidate commit: `d553240dabcab327921f8da624494b03a2af76cf`
- sole parent: `9e7f262acbb00946589e8fe805a2238044584c21`
- candidate tree: `7d9f6a7313a490822300897a9d623c8a100f3d38`
- result path: `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md`
- result blob: `5393438eec4204640b5be639158528bd08ec8b16`

Candidate scope is exactly one new result artifact.

## 2. Independent acceptance findings

APP-T02 is accepted because it:

- correctly locates the four-target AppShell migration seam in `app_shell.dart`, `app_router.dart`, and `app_route_names.dart`;
- preserves Home and Messages as reusable shell ownership while moving Match under Progress, reframing Profile as Me, and removing Discover only from MVP top-level ownership;
- does not infer current source existence as target retention authority;
- distinguishes canonical Match from the participant-linked legacy Match path and identifies exact retirement/cutover seams without treating the known `flutter_tester` teardown blocker as a product defect;
- identifies the current canonical Match cross-domain conflict where Conversation capability is embedded in Match projection/view semantics;
- identifies the current Profile aggregate as mixing Private Identity, Matching Inputs, Readiness, verification and Showcase concerns that must later be purpose-separated;
- correctly records Conversation as an existing private capability requiring future Connection and messaging-consent gates;
- correctly classifies current transport `chatConnectionProvider` / `ConnectionStatusBanner` as connectivity concepts, not product Connection lifecycle evidence;
- correctly concludes `EXISTING PRODUCT CONNECTION REPRESENTATION = UNKNOWN / NOT LOCATED WITHIN AUTHORIZED SCOPE`, not `ABSENT`;
- correctly concludes `EXISTING PRODUCT RELATIONSHIP REPRESENTATION = UNKNOWN / NOT LOCATED WITHIN AUTHORIZED SCOPE`, while excluding the local Match relationship-runtime fixture from Phase-2 Relationship authority;
- preserves `Block != Report`, private Conversation boundaries, Safety/Compatibility separation, and transport/domain-state separation;
- maps retained UNKNOWNs to the later tasks they actually block rather than resolving them by inference;
- provides an exact bounded APP-T03 change allowlist and leaves all other source outside APP-T03 by default.

## 3. Accepted APP-T03 source boundary

APP-T03 may be separately authorized to change only:

1. `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
2. `apps/flutter_elitesync_module/lib/app/router/app_router.dart`
3. `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`

A new Progress presentation file may be separately authorized by the APP-T03 task if required. `FloatingDockBottomBar` is not pre-authorized unless a concrete four-item mechanical issue is established.

APP-T03 must not implement Profile-purpose separation, Match lifecycle replacement, Connection, Conversation consent, Relationship, notification/privacy redesign, Home lifecycle projection, legacy deletion, or retained UNKNOWN values.

## 4. Preserved boundaries

Continue to preserve:

`Match != Connection != Conversation != Relationship`

`CURRENT SOURCE EXISTS != MUST KEEP`

`DEFERRED != MISSING`

`UNKNOWN != ABSENT`

`LOCAL TOOLING BLOCKER != PRODUCT DEFECT`

The original dirty detached worktree remains outside execution authority and must not be disturbed by downstream tasks.

## 5. Acceptance result

`ACCEPT — APP-T02 SOURCE LOCATOR / MIGRATION INVENTORY VALID — APP-T03 TARGET APPSHELL NAVIGATION IMPLEMENTATION MAY BE DISPATCHED AS A SEPARATE BOUNDED TASK`
