# EliteSync v10｜APP-T09 Explainability / Privacy / Notification Foundation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — EXPLAINABILITY / PRIVACY / NOTIFICATION FOUNDATION ONLY`

Date: 2026-09-13 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

Read FIRST: `AGENTS.md`, accepted APP-T01 target contract, APP-T02 inventory, APP-T08 acceptance, then this task.

## Objective

Establish three cross-cutting MVP foundations without inventing backend authority:

1. reusable explainability schema/presentation;
2. a truthful Privacy Control Center under the existing Me privacy/settings path;
3. privacy-minimal notification presentation defaults.

Preserve `Match != Connection != Conversation != Relationship`, `UNKNOWN != ABSENT`, and `STATE VOCABULARY != AUTHORITY`.

## Explainability minimum

Create a reusable presentation contract capable of showing, where the owning surface has evidence:
- what happened;
- why it happened;
- information classes used;
- what the result does not mean;
- uncertainty/limits;
- what the user can change, revoke, pause, retry, correct, contest, or close.

Do not introduce a single authoritative Compatibility score. AI/system output must not be presented as verified truth, guilt, Safety finding, or relationship authority.

## Privacy Control Center

The `/me/privacy-settings` surface must become a purpose-oriented control/explanation center, not a fake set of server controls.

It should distinguish at minimum:
- Private Identity;
- Matching Inputs / Readiness;
- candidate-scoped Showcase;
- Product Connection;
- private Conversation;
- optional AI-derived/private support;
- Safety-restricted information;
- operational minimum data.

For each area, show only controls actually available today. Where export/delete/retention/revoke/server visibility or legal-region behavior is not established, label it `NOT YET ESTABLISHED` / unresolved rather than rendering a working toggle.

Do not claim a globally public MVP Profile exists.

## Notification privacy

Establish a presentation-level notification privacy contract: lock-screen/external notification preview must be generic by default and must not expose peer identity, candidate identity, message text, Match result, Connection state, Safety/report information, or private Profile/Showcase content merely for convenience.

In-app notification detail may remain richer only where the existing authorized app surface already has the relevant access authority. Do not create OS push/backend delivery architecture or claim delivery guarantees.

## Authorized source scope

May modify only where directly necessary:
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/privacy_settings_page.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/settings_page.dart`
- existing notification presentation/entity/provider files already located by APP-T02, but only for presentation/privacy semantics;
- existing bounded explanation widgets/pages in Match/Readiness/Showcase only if a minimal integration is required.

May create bounded reusable files under:
- `apps/flutter_elitesync_module/lib/shared/explainability/`
- `apps/flutter_elitesync_module/lib/features/privacy/`
- `apps/flutter_elitesync_module/lib/features/notification/presentation/`

Narrow tests may be added/modified only under corresponding `test/` paths.

Do not modify backend/API/database/service decomposition, Match/Connection/Conversation lifecycle authority, readiness authority, Home, Relationship, build/dependency config, or global Browser/model/notify config.

If a required change needs new backend persistence, new OS notification integration, or unresolved legal/retention semantics, stop that sub-action and report the blocker; continue other authorized parts.

## Retained UNKNOWNs

Do not resolve:
- Conversation retention/export/deletion rights;
- region-specific legal/data-right implementation;
- exact identity-assurance mechanism;
- optional AI/personality/astrology/reference-signal allowlist;
- Product Connection/Conversation backend mutation authority;
- exact Relationship tools.

## Verification

Use `dart format`, `git diff --check`, exact source assertions, and narrow tests / `flutter analyze --no-pub` only when an existing package graph is present. Do not run `pub get` merely to create evidence. If package graph is absent, executable tests/analyze remain `NOT ESTABLISHED`.

## Required result

Create exactly:
`docs/architecture/ELITESYNC_V10_APP_T09_EXPLAINABILITY_PRIVACY_NOTIFICATION_FOUNDATION_RESULT_V0_1.md`

Report exact changed files, explainability schema, Privacy Control Center behavior, notification privacy default, retained UNKNOWNs, verification, blockers, and bounded APP-T10 readiness.

Suggested branch:
`review/app-t09-explainability-privacy-notification-foundation-v0-1`

Do not merge, self-accept, or start APP-T10.

Expected classification:
`APP-T09 EXPLAINABILITY / PRIVACY / NOTIFICATION FOUNDATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
