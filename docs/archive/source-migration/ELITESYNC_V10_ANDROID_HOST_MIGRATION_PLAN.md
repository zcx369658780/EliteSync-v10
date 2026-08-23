# EliteSync-v10 Android Host Migration Plan

## 1. Objective

将 EliteSync 9.x canonical Android host source 迁移到 EliteSync-v10。迁移范围限于受 source control 管理的源代码和构建配置；不迁移 build state、local environment、signing secrets 或 machine state。

本文档仅定义执行方案，不授权或执行源码迁移及任何 Android 操作。

## 2. Source Boundary

- Source repository: `zcx369658780/EliteSync`
- Baseline: `13277df80c3b82f33887ffe110d807ad79b38d8c`
- Canonical Android path: `apps/android/`
- Target: `EliteSync-v10/apps/android/`

后续迁移必须直接读取上述 exact Git baseline tree，不得从本地工作区、构建目录、设备或其他 runtime state 复制。

## 3. Android Canonical / Legacy Boundary

- Canonical Android host: `apps/android/`
- Other observed Android-related path: `apps/flutter_elitesync/android/`

`apps/flutter_elitesync/android/` 位于 legacy Flutter tree，不是 canonical Android host，不纳入迁移。指定 baseline 的 `apps/flutter_elitesync_module/` 中未发现独立 Android 子树。

## 4. Android Assets To Migrate

### Source code

- `app/` 中受 source control 管理的 application source
- Kotlin/Java source
- `AndroidManifest.xml`
- Android resources and source-controlled application assets

### Build configuration

- `settings.gradle` / `settings.gradle.kts`
- `build.gradle` / `build.gradle.kts`
- `gradle.properties`
- Gradle wrapper scripts and wrapper configuration
- 其他位于 canonical boundary 内、受 source control 管理的 Android build files

仅迁移 source-controlled configuration。

## 5. Android Assets NOT To Migrate

- `build/`
- `.gradle/`
- `local.properties`
- generated APK/AAB files
- signing files
- keystores
- certificates
- emulator data
- device state
- IDE metadata
- caches and downloaded artifacts
- machine-specific configuration

## 6. Flutter Integration Boundary

Android host 依赖 `apps/flutter_elitesync_module/`。该 Flutter module 的迁移已经独立完成；本阶段只迁移 `apps/android/`，不修改或重新迁移 Flutter module。

## 7. Gradle / Dependency Boundary

未来迁移包括 source-controlled Gradle wrapper、build scripts 和 dependency declarations。不迁移 Gradle cache、local cache 或 downloaded artifacts。

本计划阶段不执行 Gradle，也不解析或修改依赖。

## 8. Signing Boundary

不迁移 keystore、signing keys、release credentials、certificates 或任何 signing secrets。签名材料及配置需要在后续独立、明确授权的阶段处理。

## 9. Validation Plan

未来完成迁移后，应静态验证：

- `apps/android/` 在 target 中存在；
- 所有迁移文件均位于授权的 Android host boundary；
- path set 与 source baseline 一致；
- Gradle files 与 source baseline 完整一致；
- `AndroidManifest.xml` 与 source baseline 完整一致；
- generated artifacts、local state 和 signing material 均不存在；
- Flutter module、backend 和 infra 未被修改。

该静态验证不执行 Gradle build、APK build、emulator 或 device 操作。

## 10. Known Risks

- Gradle environment compatibility 尚未验证；
- Kotlin 与 Android plugin compatibility 尚未验证；
- Android host 与 Flutter module 的 integration assumptions 尚未验证；
- signing configuration 未迁移且需要独立配置；
- local Android SDK differences 可能影响后续 runtime validation。

本文档仅记录这些风险，不在本阶段解决。

## 11. Next Step

下一阶段为 **Android Host Source Migration Execution**。执行需要新的明确授权。
