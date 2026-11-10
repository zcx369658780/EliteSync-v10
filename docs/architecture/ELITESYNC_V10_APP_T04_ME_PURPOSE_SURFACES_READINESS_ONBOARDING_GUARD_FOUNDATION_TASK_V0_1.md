# EliteSync v10｜APP-T04 Me Purpose Surfaces / Readiness / Onboarding Guard Foundation Task｜v0.1

Status: `AUTHORIZED — BOUNDED PRODUCT IMPLEMENTATION — PURPOSE-SURFACE AND GUARD FOUNDATION ONLY`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Authority

Fresh-start authority is current `origin/main` containing:

- accepted APP-T01 target contract blob `8ebe98c52b322b7e1a7f1dbac8a621748123f418`;
- accepted APP-T02 migration inventory blob `5393438eec4204640b5be639158528bd08ec8b16`;
- accepted APP-T03 implementation commit `9c3473d75585ac2402349cded435f8efd9ff7f14`;
- APP-T03 acceptance.

Read FIRST:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260912_V0_1.md`

Then read:

- `docs/architecture/ELITESYNC_V10_APP_T01_TARGET_ROUTE_DOMAIN_STATE_DATA_AUDIENCE_CONTRACT_RESULT_V0_1.md`;
- `docs/architecture/ELITESYNC_V10_APP_T02_CURRENT_TO_TARGET_SOURCE_LOCATOR_MIGRATION_INVENTORY_RESULT_V0_1.md`;
- `docs/architecture/ELITESYNC_V10_APP_T03_TARGET_APPSHELL_NAVIGATION_IMPLEMENTATION_ACCEPTANCE_V0_1.md`;
- this task sheet.

## 2. Local-worktree safety

The original local worktree remains known dirty and detached. Do not modify, clean, stash, reset, checkout over, delete, move, adopt, stage, commit, or otherwise disturb it.

Use a separate fresh clean worktree based on fresh-fetched `origin/main`.

## 3. Sole objective

Establish the **MVP Me purpose-surface and readiness/onboarding guard foundation** without migrating private data models or selecting retained UNKNOWN values.

APP-T04 must make the target ownership visible in the product shell:

`Me`

must expose four clearly separated purpose surfaces:

1. `Private Identity`
2. `Matching Inputs`
3. `Readiness`
4. `Showcase`

and a separate `Privacy & Settings` entry.

At the same time, navigation must stop treating authenticated state as automatic proof that verification/questionnaire/readiness are complete. The implementation must provide a bounded, privacy-safe guard foundation that can represent incomplete readiness without inventing exact eligibility or identity-assurance policy.

This task does **not** complete field-level data migration, identity assurance, Match eligibility, Showcase publication redesign, or final onboarding policy.

## 4. Required behavior

### 4.1 Me landing surface

Replace the temporary direct `Me -> ProfilePage` presentation with a new purpose-oriented Me landing page.

The Me landing page must provide distinct entries for:

- Private Identity;
- Matching Inputs;
- Readiness;
- Showcase;
- Privacy & Settings.

It must not present them as one globally public Profile.

Existing current pages may be reused as temporary compatibility destinations where this task explicitly permits them, but the landing copy must make purpose boundaries clear and must not claim that legacy pages already satisfy the new data contract.

### 4.2 Compatibility mappings

Allowed temporary mappings:

- `Private Identity` may open the existing profile/edit-profile capability as a compatibility surface, with purpose-limiting copy on the Me landing page;
- `Matching Inputs` may open existing questionnaire and/or relevant current profile-edit entry only through a purpose-labelled entry;
- `Readiness` may open or present existing readiness/verification/questionnaire status surfaces without creating a new eligibility result;
- `Showcase` may open the existing Personal Showcase capability, but the new Me entry must describe it as candidate-scoped target ownership and must not claim global publication is authorized;
- `Privacy & Settings` may open the existing Settings/Privacy capability.

Do not change current provider/entity semantics merely to make these mappings look complete.

### 4.3 Readiness guard foundation

The current source shortcut in `navigationGuardProvider` / `NavigationSnapshot` that treats every authenticated user as approved/completed/revealed/`canChat=true` must no longer be the authority for new MVP route access.

Implement only the minimum guard foundation needed to distinguish:

- unauthenticated;
- authenticated but onboarding/setup incomplete or readiness not established;
- readiness-capable/ready where current bounded source already exposes an authoritative status;
- unknown/unavailable state without converting it into ready.

If the current static source does not provide a trustworthy readiness fact for a route, fail closed to a privacy-safe readiness/setup entry rather than fabricate `READY`.

Do **not** choose exact launch eligibility, minimum identity assurance, verification mechanism, or required questionnaire field set.

### 4.4 Match entry consequence

A Me/Readiness surface may explain that readiness is required before Match opt-in, but APP-T04 must not change canonical Match lifecycle implementation.

Do not auto-enroll Match from completing/editing Profile, questionnaire or verification inputs.

### 4.5 Onboarding foundation

Current first-use tutorial mechanics may be reused only as presentation/replay mechanics. They must not be treated as proof of account/readiness completion.

Where a new or adjusted onboarding/setup entry is needed, it must explain purpose and allow recovery/resume without collecting new private data in this task.

## 5. Authorized source scope

APP-T04 may modify only the following existing source areas, and only where directly necessary:

### Router / shell ownership

- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`

Only Me child routes and readiness/setup guard wiring may change. Do not alter the four top-level destination set established by APP-T03.

### Me / profile presentation

- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/profile_page.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/edit_profile_page.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/personal_showcase_page.dart`
- `apps/flutter_elitesync_module/lib/features/profile/presentation/pages/settings_page.dart`

These existing pages may receive only minimal compatibility labels/entry adjustments if needed. Do not perform field migration.

APP-T04 may create new presentation files under:

`apps/flutter_elitesync_module/lib/features/me/presentation/pages/`

for the Me landing/purpose pages.

### Readiness / guard / onboarding foundation

- `apps/flutter_elitesync_module/lib/shared/providers/navigation_guard_provider.dart`
- `apps/flutter_elitesync_module/lib/shared/models/navigation_snapshot.dart`
- `apps/flutter_elitesync_module/lib/features/onboarding/application/first_use_onboarding_coordinator.dart`
- `apps/flutter_elitesync_module/lib/features/onboarding/presentation/first_use_onboarding_page.dart`
- bounded presentation reads from current Profile/Questionnaire/Verification providers/pages already located by APP-T02.

If changing a Profile/Questionnaire/Verification **provider, entity, repository, data source or model** appears necessary, STOP and report the exact blocker. Those data-contract changes are not authorized by APP-T04.

## 6. Explicitly prohibited source changes

Do not modify:

- Profile domain entities;
- Profile providers/notifiers/data sources/repositories;
- questionnaire providers/entities/data sources;
- verification providers/entities/data sources;
- Showcase draft/publication entities/controllers;
- Match projection/provider/data source;
- Conversation/Chat source;
- Connection implementation;
- Relationship implementation;
- Discover/Home redesign;
- Backend/API/database/service/module decomposition;
- build/dependency configuration.

## 7. Retained UNKNOWNs — must remain UNKNOWN

Do not select or infer:

- launch segment / exact eligibility;
- minimum identity-assurance mechanism or level;
- required verification provider/mechanism;
- exact questionnaire required-field set;
- Match proposal expiry;
- Conversation retention/export/deletion rights;
- region-specific legal/data-right behavior;
- Phase-2 Relationship tools;
- optional AI/personality/astrology/reference-signal allowlist.

Where a UI needs wording for an unresolved item, say it is not yet established rather than inventing policy.

## 8. Privacy and meaning invariants

Preserve:

- Private Identity != Matching Inputs != Readiness != Showcase;
- no globally public MVP Profile;
- editing Matching Inputs does not opt the user into Match;
- readiness is not Compatibility, Safety, trustworthiness or moral worth;
- verification proves only its bounded verified proposition;
- user declaration != objective truth;
- optional astrology/personality/reference surfaces remain excluded from required readiness unless later authorized;
- Showcase is not globally public by default;
- `Match != Connection != Conversation != Relationship`.

## 9. Verification authorization

Authorized verification is limited to:

- `dart format` on changed/new files;
- `git diff --check`;
- exact-source/static contract assertions;
- `flutter analyze --no-pub` only if a valid existing package graph is present in the fresh worktree;
- narrowly relevant synthetic router/widget tests under existing/new test paths for Me landing and readiness guards, without private data.

Do not run `pub get`, dependency acquisition, network dependency resolution, emulator, ADB, backend/product network calls or private-data flows merely to make verification executable.

If `.dart_tool/package_config.json` is absent again, record executable analysis/test as `NOT ESTABLISHED`; do not call that a product failure or pass.

## 10. Required acceptance behavior

The result must establish, by source evidence:

1. top-level AppShell remains exactly `Home | Progress | Messages | Me`;
2. Me no longer directly equates to one aggregate Profile surface;
3. five purpose-labelled Me entries exist as specified;
4. no entry claims globally public Profile authority;
5. authenticated state is no longer hard-coded as automatic readiness/verification/questionnaire/chat authority for new target guard behavior;
6. unknown/unavailable readiness does not become ready by default;
7. editing/setup does not auto-opt into Match;
8. no Profile/Questionnaire/Verification data contract was migrated or invented;
9. APP-T03 compatibility and four-tab behavior remain intact.

## 11. Required result artifact

Create:

`docs/architecture/ELITESYNC_V10_APP_T04_ME_PURPOSE_SURFACES_READINESS_ONBOARDING_GUARD_FOUNDATION_RESULT_V0_1.md`

The result must report:

- exact changed files;
- purpose-surface mappings;
- guard-state source and fail-closed behavior;
- what remains compatibility-only;
- retained UNKNOWNs;
- verification ledger;
- exact blockers, if any;
- bounded recommendation for APP-T05 readiness.

## 12. Candidate rules

Use a fresh candidate branch, suggested:

`review/app-t04-me-purpose-readiness-onboarding-guard-foundation-v0-1`

Candidate commit may contain only:

- authorized APP-T04 source changes;
- narrowly relevant synthetic tests;
- the single APP-T04 result artifact.

Do not merge to `main`.
Do not self-accept.
Do not start APP-T05.

Expected success classification:

`APP-T04 ME PURPOSE / READINESS / ONBOARDING GUARD FOUNDATION ESTABLISHED — READY FOR INDEPENDENT ACCEPTANCE`
