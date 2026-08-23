# EliteSync-v10 Flutter Module Migration Plan

## 1. Objective

The objective is to migrate the canonical EliteSync 9.x Flutter module source into EliteSync-v10 while preserving its application source and source-controlled project definition.

The migration will not bring forward historical governance, the legacy duplicate Flutter tree, generated build state, SDK caches, emulator/device state, or machine-specific files. This document is an execution plan, not migration authorization.

## 2. Source Boundary

- Source repository: `zcx369658780/EliteSync`
- Source baseline: `13277df80c3b82f33887ffe110d807ad79b38d8c`
- Canonical Flutter source path: `apps/flutter_elitesync_module/`
- Target repository: `zcx369658780/EliteSync-v10`
- Intended target path: `apps/flutter_elitesync_module/`

Future execution must read from the exact baseline Git tree, not a local 9.x worktree, build directory, emulator, device, or cloud/runtime copy.

## 3. Canonical / Legacy Boundary

- Canonical: `apps/flutter_elitesync_module/`
- Legacy duplicate: `apps/flutter_elitesync/`

The legacy duplicate is not v10 canonical source and must not be migrated. Its presence in the source repository is provenance only and does not authorize comparison-driven merging or restoration.

## 4. Flutter Assets To Migrate

The exact baseline canonical module contains 527 tracked files.

### Source code

Candidate source assets are:

- `lib/` — 410 tracked Dart source files.
- `pubspec.yaml` — package metadata, SDK constraints, dependencies, and asset declarations.
- `pubspec.lock` — locked dependency resolution.
- `assets/` — one tracked source asset under the `config/` root.
- `test/` — 110 tracked test/fixture files.
- `analysis_options.yaml` — static-analysis configuration.
- `.metadata`, `.gitignore`, and the module `README.md` as source-controlled Flutter project metadata/documentation.

Candidate presence does not authorize copying in this phase. A later execution must freeze an exact Git-tree file allowlist and preserve source blob identity.

### Platform integration if included in module

The baseline canonical module contains no tracked `android/`, `ios/`, `web/`, `linux/`, `macos/`, or `windows/` directory. Therefore this phase has no embedded platform-runner source to migrate from the module.

The separate Android host at `apps/android` is outside this module and outside this phase.

## 5. Flutter Assets NOT To Migrate

- `build/` output.
- `.dart_tool/` state.
- Flutter SDK and Dart/Pub caches.
- `.flutter-plugins`, `.flutter-plugins-dependencies`, coverage output, and generated plugin registrants.
- Generated code or outputs that are not tracked in the exact baseline Git tree.
- IDE state such as `.idea/`, `.vscode/`, workspace metadata, and local launch configuration.
- Emulator/device artifacts, screenshots, bug reports, APK/AAB files, and device-local state.
- Temporary files, logs, crash files, and local test output.
- `.env`, credentials, secrets, keys, certificates, signing material, and machine-specific paths/configuration.
- Local path packages, package caches, or dependency output outside the exact Git baseline.

No tracked path matching these generated or sensitive categories was found in the canonical baseline module inventory.

## 6. Dependency Boundary

Future migration must include, without modification:

- `pubspec.yaml`.
- `pubspec.lock`.

Future migration must not include:

- Flutter SDK files or SDK cache.
- Dart/Pub cache, including `.pub-cache`.
- `.dart_tool/`, resolved local build state, or generated dependency metadata.
- `build/` or locally materialized packages.
- Local packages not represented by the exact baseline source and dependency declarations.

Dependency installation and resolution are separate validation activities. `flutter pub get`, dependency upgrades, and lockfile regeneration are not part of this plan.

## 7. Android Boundary

`apps/android` is the canonical Android host and is explicitly excluded from Flutter Module Source Migration.

The Android host depends on the Flutter module integration boundary and is scheduled for a later migration phase. This plan does not inspect, copy, modify, build, or validate the Android host.

## 8. Validation Plan

After a separately authorized migration, static validation should confirm:

- `apps/flutter_elitesync_module/` exists in the target.
- The migrated path set exactly matches the approved baseline allowlist.
- Every migrated file blob matches the source baseline.
- `lib/`, `assets/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, and source-controlled metadata are present when included by the allowlist.
- `pubspec.yaml` and `pubspec.lock` match their exact source blobs.
- Generated, cached, local, sensitive, and machine-specific paths are absent.
- No path under `apps/flutter_elitesync/` or `apps/android/` changed.
- No backend path changed.

This static validation must not run `flutter pub get`, `flutter build`, Flutter tests, an emulator, or a device. Runtime/toolchain validation requires a later explicit authorization.

## 9. Known Risks

- Dependency compatibility has not been tested in the v10 environment.
- The locked packages may depend on a specific Flutter/Dart SDK range or local toolchain behavior.
- Asset declarations in `pubspec.yaml` must remain consistent with the migrated `assets/` tree.
- Source code may assume backend API contracts, configuration values, or route behavior that runtime validation has not established.
- The canonical module contains no embedded platform directories and therefore depends on the separate Android host for Android integration.
- The legacy `apps/flutter_elitesync/` duplicate can be confused with canonical source if path boundaries are not enforced.
- Generated files may exist in local worktrees even though they are absent from the exact baseline Git tree.
- Static blob equality will demonstrate migration integrity, not Flutter build, test, runtime, device, or product readiness.

No risk is resolved by this plan.

## 10. Next Step

The next phase is **Flutter Module Source Migration Execution**. It requires new explicit authorization defining the exact source/target path allowlist, exclusion patterns, static validation, commit message, and push boundary.
