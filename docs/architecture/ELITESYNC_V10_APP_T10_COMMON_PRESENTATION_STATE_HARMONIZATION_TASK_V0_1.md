# EliteSync v10｜APP-T10 Common Presentation-State Harmonization Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — COMMON PRESENTATION STATE ONLY`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Fresh-start expected `origin/main` contains accepted APP-T09 and this task.

Read FIRST:

- `AGENTS.md`;
- accepted APP-T01 target contract;
- accepted APP-T02 migration inventory;
- APP-T09 acceptance;
- this task.

## Sole objective

Establish a common presentation-state vocabulary and reusable rendering foundation so MVP surfaces distinguish transport/presentation conditions from product lifecycle facts.

Required presentation conditions:

- loading;
- empty / no current content;
- offline / network unavailable;
- stale / last-known data;
- retryable error;
- non-retryable/unavailable;
- unknown / authority not established.

These are presentation/transport conditions only. They must never silently become Match, Connection, Conversation, Readiness, Relationship, Safety, guilt, Compatibility, or eligibility facts.

Preserve:

`LOCAL TOOLING BLOCKER != PRODUCT DEFECT`

`TRANSPORT FAILURE != DOMAIN OUTCOME`

`UNKNOWN != ABSENT`

`STATE VOCABULARY != AUTHORITY`

`Match != Connection != Conversation != Relationship`

## Required behavior

1. Create one reusable presentation-state contract that separates:
   - presentation condition;
   - whether last-known content may be shown;
   - retry availability;
   - user-safe title/body/action copy;
   - domain-state meaning explicitly absent unless supplied by the owning domain.
2. `offline` must not be displayed as empty, declined, closed, expired, rejected, or no-candidate.
3. `stale` must visibly disclose that displayed content may be out of date and must not be promoted to current domain truth.
4. `empty` must mean only that the authorized source currently has no content for that surface; it must not imply ineligibility, rejection, or Safety judgment.
5. `unknown / authority not established` must remain explicit and fail closed for protected data/actions.
6. Retry controls must retry only the owning presentation/data request; they must not mutate lifecycle state.
7. Existing privacy/consent gates from APP-T04/T06/T07/T09 must remain stronger than generic presentation-state components.

## Authorized source scope

May modify these shared state components:

- `apps/flutter_elitesync_module/lib/design_system/components/states/app_empty_state.dart`
- `apps/flutter_elitesync_module/lib/design_system/components/states/app_error_state.dart`
- `apps/flutter_elitesync_module/lib/design_system/components/states/app_loading_skeleton.dart`
- `apps/flutter_elitesync_module/lib/design_system/components/states/app_retry_block.dart`

May create reusable files only under:

- `apps/flutter_elitesync_module/lib/shared/presentation_state/`

For minimal integration proving the contract, may modify only where directly necessary:

- `apps/flutter_elitesync_module/lib/features/match/presentation/widgets/match_round_contract_view.dart`
- `apps/flutter_elitesync_module/lib/features/connection/presentation/pages/connection_page.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart`
- `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart`

Narrow tests may be added/modified only under the corresponding `test/` paths and `test/shared/presentation_state/`.

Do not modify Home, router, domain lifecycle contracts, readiness authority, Profile/Privacy Control Center semantics, backend/API/database/service architecture, build/dependency config, or global configuration.

If harmonization requires changing a domain state or access authority, STOP that sub-action and report the blocker rather than expanding scope.

## Acceptance requirements

The result must establish by source evidence that:

1. shared presentation conditions are explicit and reusable;
2. offline/error/tooling conditions are not domain lifecycle facts;
3. stale content is clearly marked as stale;
4. empty state is not used as rejection/ineligibility/Safety truth;
5. unknown/not-established remains explicit and fail closed;
6. retry cannot mutate lifecycle state;
7. Match/Connection/Conversation privacy and authority boundaries remain unchanged;
8. only authorized source/test/result paths change.

## Verification

Use `dart format`, `git diff --check`, exact static/source assertions, and narrow tests / `flutter analyze --no-pub` only when an existing valid package graph is present. Do not run `pub get` merely to create evidence. If the package graph is absent, executable tests/analyze remain `NOT ESTABLISHED`.

## Required result

Create exactly:

`docs/architecture/ELITESYNC_V10_APP_T10_COMMON_PRESENTATION_STATE_HARMONIZATION_RESULT_V0_1.md`

Report exact changed files, shared state contract, integration points, stale/offline/empty/error semantics, preserved domain/privacy boundaries, verification, blockers, and bounded APP-T11 readiness.

Suggested branch:

`review/app-t10-common-presentation-state-harmonization-v0-1`

Do not merge, self-accept, or start APP-T11.

Expected classification:

`APP-T10 COMMON PRESENTATION STATE HARMONIZATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
