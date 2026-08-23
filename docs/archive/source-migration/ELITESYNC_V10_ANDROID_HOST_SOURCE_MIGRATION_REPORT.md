# EliteSync-v10 Android Host Source Migration Report

## 1. Source SHA

`13277df80c3b82f33887ffe110d807ad79b38d8c`

Source repository: `zcx369658780/EliteSync`

Migration source: exact Git baseline tree at `apps/android/`.

## 2. Target Baseline SHA

`9b8a40c858169b265b8cee0795fdfecdde409ef9`

Target repository: `zcx369658780/EliteSync-v10`

## 3. Migration Commit SHA

`2b5065bd2ef406c992656484014759987b8a2f7f`

Commit message: `Migrate canonical Android host source to EliteSync-v10`

## 4. Changed Paths

The migration commit changes only `apps/android/`, including:

- `apps/android/app/`
- `apps/android/build.gradle.kts`
- `apps/android/gradle.properties`
- `apps/android/gradle/`
- `apps/android/gradlew`
- `apps/android/gradlew.bat`
- `apps/android/settings.gradle.kts`
- `apps/android/README.md`

No Flutter module, backend, or infrastructure path is changed by the migration commit.

## 5. Migrated File Count

- Source baseline files: 52
- Target commit files: 52
- Path-set differences: 0

## 6. Excluded Paths

The following were not migrated:

- `build/`
- `.gradle/`
- `local.properties`
- generated files
- APK/AAB outputs
- keystores and signing files
- credentials, keys, and certificates
- emulator or device artifacts
- IDE metadata
- caches, downloaded artifacts, and machine-specific configuration
- legacy `apps/flutter_elitesync/android/`

The exact source baseline contained no tracked entries matching these forbidden categories under `apps/android/`.

## 7. Blob Validation

- Source/target path set: identical
- Source/index canonical blob mismatch count: 0
- Files outside `apps/android/` in the migration commit: 0
- Forbidden generated, local, or signing entries: 0

Git canonical blobs were compared against the source baseline before commit. Windows working-tree line-ending representation was normalized through Git's clean filter; the committed blob identities match the source baseline.

## 8. Runtime Boundary Statement

No Gradle/runtime/device operation performed.

No Android build, APK/AAB build, emulator/device action, Flutter operation, dependency modification, signing configuration change, server operation, or database operation was performed.
