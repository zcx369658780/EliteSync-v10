# EliteSync v10｜Android Studio Emulator Route Activation Task｜v0.1

Status: `PUBLISHED TASK SHEET — OWNER-AUTHORIZED EMULATOR ROUTE ACTIVATION — LOCAL ANDROID/FLUTTER TESTING PATH ONLY — SANDBOX DEP13 REMAINS UNRESOLVED`

Date: 2026-09-12 (Asia/Singapore).

Repository: `zcx369658780/EliteSync-v10`.

## 1. Publication authority

Publication-base `main`:

`cdb5d97eb20ea808e05cd8120ec423a2e9876e83`

FIRST handoff:

`docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_20260911_V0_1.md`

required blob:

`3aa2ead4cf1084b202b67856075c26ab80b0c9a2`

Accepted existing-Sandbox continuation acceptance:

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_EXISTING_SANDBOX_DEFAULT_DESTINATION_RECOVERY_CONTINUATION_ACCEPTANCE_V0_1.md`

Owner standing authorization already recorded:

- local Android Studio emulator may be used for testing/development if Sandbox route remains impractical;
- emulator evidence must not be represented as Sandbox-specific DEP13 evidence.

The existing-Sandbox route is now closed because its exact runtime subject no longer exists.

## 2. Sole objective

Activate and verify a bounded local Android Studio emulator development/test route for EliteSync v10, using only the current machine's already-installed Android Studio / Android SDK / AVD tooling and current repository state.

This task must determine:

1. whether a usable existing Android emulator/AVD is installed;
2. whether it can be started and reached through `adb` without changing unrelated host configuration;
3. whether the current repository exposes an Android/Flutter runnable surface that can be tested without unauthorized dependency acquisition or broad implementation work;
4. what exact next bounded development/test step can proceed on the emulator.

This task is route activation and smoke validation, not broad product implementation.

## 3. Startup authority gate

Activation prompt MUST provide:

- `REQUIRED_MAIN` = commit publishing this task;
- `REQUIRED_TASK_BLOB` = exact blob of this task.

Startup sequence:

1. fresh-fetch remote `main`;
2. require `main == REQUIRED_MAIN`, otherwise `STOP — MAIN_AUTHORITY_CHANGED`;
3. read FIRST the exact handoff and require blob `3aa2ead4cf1084b202b67856075c26ab80b0c9a2`;
4. read this task and require `REQUIRED_TASK_BLOB`;
5. read the existing-Sandbox continuation acceptance named in §1;
6. do not treat conversation/project memory as execution authority.

No default `git status`; do not inspect protected staged/index state.

## 4. Preserved Sandbox evidence boundary

Remain durable and unresolved:

`FAILED_START_RESULT_NOT_CAPTURED`

`WRITABLE_CONTINUATION_SHARE_FAILED — exit -2147024809 — Value does not fall within the expected range.`

Also preserve accepted B R4 fact:

`DIRECT ARGV + WRITABLE + OMIT --sandbox-path -> SHARE SUCCESS`

Sandbox-specific DEP13 remains blocked.

Do NOT create/start a new Windows Sandbox in this task. Do NOT reuse or mutate any historical Sandbox/B evidence root or `continuation-v0-1`.

## 5. Authorized local Android tooling discovery

Use normal installed-tool resolution and narrow conventional Android tooling locations only. No broad filesystem enumeration.

Authorized checks include:

- Android Studio installation identity/version through normal launcher/product metadata or standard install location;
- Android SDK root through existing environment/configuration already used by Android Studio/Flutter;
- `adb` identity/version;
- emulator binary identity/version;
- existing AVD names via supported emulator/AVD commands;
- Flutter tool identity/version if Flutter is already installed and already part of the repository's accepted local toolchain.

Do not install Android Studio, SDK components, system images, Flutter, Java, Gradle, or packages in this task.

If required tooling is absent, record the exact missing component and stop without downloading it.

## 6. AVD selection and startup

If one or more existing AVDs are present, select exactly one using this order:

1. an already-running Android emulator if exactly one exists;
2. otherwise the single existing AVD if there is exactly one;
3. otherwise choose the AVD whose API/ABI is most clearly compatible with the repository's current Android target from already-authorized project metadata, without opening README/FD02;
4. if no unique bounded choice can be made, stop with `EMULATOR_AVD_SELECTION_NOT_UNIQUE` rather than trial multiple AVDs.

Starting exactly one selected existing AVD is authorized.

Allowed startup actions:

- launch the selected emulator once;
- wait for normal boot readiness;
- use bounded `adb devices` / exact device-targeted `adb shell getprop` checks;
- record AVD/device/API/ABI identity.

Do not create, delete, edit, wipe-data, factory-reset, snapshot-rewrite, or upgrade an AVD.

## 7. Repository Android/Flutter surface locator

After emulator readiness, perform a narrow current-repository locator review to identify the existing Android/Flutter runnable surface.

Authorized repository search anchors:

- `pubspec.yaml`;
- `android/` Gradle project entry files;
- `lib/main.dart`;
- current module/application identifiers needed to launch the app;
- existing test/smoke-test entrypoints directly associated with that runnable surface.

Do not browse README. Do not inspect FD02. Do not perform generalized repository archaeology.

If no runnable Android/Flutter surface exists in current authority, record that fact and stop after producing the route result.

## 8. Bounded build/test smoke authorization

If the current repository contains a runnable Android/Flutter surface and the required tool/dependency state is already locally available, one bounded smoke path is authorized.

Preferred order:

1. use an existing already-built APK/app artifact if an exact current-authority artifact is already available through an authorized locator;
2. otherwise run the minimal existing project command required to build/launch the current Android/Flutter surface **only if it does not require downloading new dependencies or SDK components**;
3. install/launch the resulting/current app on the selected emulator;
4. verify only bounded smoke facts such as process launch, package presence, first frame/activity, and immediately visible fatal startup errors.

Do not perform feature exploration, private-data entry, account login, telemetry/analytics setup, participant workflows, or broad manual QA.

If the build requests network dependency acquisition or missing SDK/component installation, stop with:

`EMULATOR_ROUTE_LOCAL_DEPENDENCY_STATE_INSUFFICIENT`

Do not authorize downloads as a workaround.

## 9. Development authority boundary

Owner authorization permits emulator-based testing/development as the forward route, but this activation task itself does not authorize broad product implementation.

Do not modify product source code in this task unless an exact one-line/minimal non-product test harness adjustment is strictly required to prove the emulator route and is separately documented; prefer no source modification.

No Backend/Database/PUI redesign, no legal/Safety processing changes, no telemetry/analytics, no participant data, no private Conversation inspection, and no production configuration changes.

## 10. Required route result

Publish exactly one result artifact on a dedicated review branch:

`docs/architecture/ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_ROUTE_ACTIVATION_RESULT_V0_1.md`

It must record:

- main/task/FIRST identities;
- Android Studio/SDK/adb/emulator/Flutter identities actually used;
- selected AVD identity and selection rationale;
- emulator boot/connectivity result;
- exact repository runnable-surface locator result;
- whether a bounded smoke build/install/launch was executed;
- exact commands and exit/results for the bounded smoke path;
- whether any dependency or SDK acquisition would have been required;
- exact next recommended bounded development/test task;
- explicit statement that Sandbox DEP13 remains unresolved and emulator evidence is separate.

Final classification exactly one of:

`ANDROID STUDIO EMULATOR ROUTE ACTIVE — LOCAL TEST/DEVELOPMENT MAY PROCEED UNDER SEPARATE BOUNDED TASKS — SANDBOX DEP13 REMAINS UNRESOLVED — AWAITING INDEPENDENT ACCEPTANCE`

or

`ANDROID STUDIO EMULATOR ROUTE NOT YET ACTIVE — LOCAL TOOLING/RUNNABLE-SURFACE GAP IDENTIFIED — AWAITING INDEPENDENT ACCEPTANCE`

## 11. Stop rule

Stop immediately after publishing the single candidate result.

Do not self-accept, merge, begin broad implementation, acquire dependencies, create a new Sandbox, run DEP13, or publish the next development task yourself.

## 12. Durable boundaries

Preserve D-02 durable UNKNOWN, U-14 exclusion, U-12 exact-scope rules, `TP-SOURCE-CLASS-01`, `TP-TARGET-01`, Backend/Database/PUI boundaries, README exhausted, FD02 excluded, protected-index boundary, accepted legal/Safety/no-processing boundaries, and no LC-03/LC-04/Phase36 authority unless separately reauthorized.

B12 remains NOT AUTHORIZED. M2 remains separate and NOT automatically authorized.

Sandbox DEP13 remains blocked; Android emulator evidence is a separate development/test evidence class.

## 13. End state

`EXISTING SANDBOX INSTANCE ABSENT -> EXISTING-SANDBOX ROUTE CLOSED`

`EMULATOR ROUTE ACTIVATION != SANDBOX DEP13 SATISFACTION`

`EMULATOR SMOKE SUCCESS != BROAD IMPLEMENTATION AUTHORITY`

`OWNER-AUTHORIZED EMULATOR ROUTE MAY PROGRESS THROUGH SEPARATE BOUNDED TASKS AFTER INDEPENDENT ACCEPTANCE`
