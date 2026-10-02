# APP-M5-02｜当前 v10 仓库 Android host 精确定位（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。仅新增本文件；未运行 Flutter、Gradle、adb、设备、网络、构建或安装，未访问旧仓库、SDK、真实数据、备份或密钥。

## 两轮实际定位（2/2）

1. **第 1 轮：本仓有界文件名索引。** 在仓库根用 `Get-ChildItem -LiteralPath . -Force` 列出根层可见项目，并仅在 `apps` 下执行 `rg --files --hidden --no-ignore apps`，用精确 glob 限定 `settings.gradle*`、`build.gradle*`、`gradlew*`、`AndroidManifest.xml`、`local.properties`，排除 `.git`。根层无上述标记文件。`apps/android` 命中 `settings.gradle.kts`、`build.gradle.kts`、`gradlew`、`gradlew.bat`、`app/build.gradle.kts`、`app/src/main/AndroidManifest.xml`；`apps/flutter_elitesync_module/.android` 命中 `settings.gradle`、`build.gradle`、`gradlew`、`gradlew.bat`、`local.properties`、`app/build.gradle`、`app/src/main/AndroidManifest.xml`、`Flutter/build.gradle`、`Flutter/src/main/AndroidManifest.xml`。没有扩大到其它仓库或磁盘。
2. **第 2 轮：仅读命中文件及模块 `pubspec.yaml`/入口。** 对下表准确路径使用 `Get-Content` 和 `Get-FileHash -Algorithm SHA256`，并用 `git status --short -- <准确路径>`、`git ls-tree -r --name-only HEAD -- <准确路径>` 核对所列文件的工作区与 HEAD 跟踪情况。没有读取别处 Gradle 文件、执行工具链或访问配置中提到的旧仓库路径。

| 准确路径（仓库相对） | SHA-256 |
| --- | --- |
| `apps/android/settings.gradle.kts` | `A976B7F3D9C4F8446F7AE32A5817188CF4F11A021DD854152CB327A28277D88C` |
| `apps/android/build.gradle.kts` | `F4DB52252E3F16CDB2EE6B783AB3330366534D236024CE69AD6924C136133461` |
| `apps/android/app/build.gradle.kts` | `4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3` |
| `apps/android/app/src/main/AndroidManifest.xml` | `1923E66B50EEDCB613856665735662A887C0A0A5679110E7E4560CC783767405` |
| `apps/flutter_elitesync_module/.android/settings.gradle` | `58ED6CF1A5FF74237DBA2C0DBBD19669AEEEA145C2F442462B04C20541A8F609` |
| `apps/flutter_elitesync_module/.android/build.gradle` | `5A611DADB1C89E576BD50D964EFEB52B0AC9883FB4773E594BF75C37979AB760` |
| `apps/flutter_elitesync_module/.android/app/build.gradle` | `880E8F96916520DF0854AECA56E63650AC58C344D5F9EB8144875E11911D1FC7` |
| `apps/flutter_elitesync_module/.android/app/src/main/AndroidManifest.xml` | `8F3733DE037BB59E8A4DDAE6BED39ECE45194DD0C877FD44DCAD735B754712CA` |
| `apps/flutter_elitesync_module/.android/local.properties` | `59A3FB4D3A3886BE22B7623DB26731420C67A13E6D63A3842C410111EA2920D2` |
| `apps/flutter_elitesync_module/pubspec.yaml` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` |
| `apps/flutter_elitesync_module/lib/main.dart` | `CB356264EBEEFF5F75CFCFA8195E59ED8218F19752895EEDA226DDDED698C60A` |
| `apps/flutter_elitesync_module/lib/main_demo.dart` | `F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02` |

## 绑定判断与停点

**HOST_FOUND_IN_REPO，运行入口仍未确立。** `apps/android/settings.gradle.kts` 声明 Android `:app`，其仓库相对 Maven repo 指向 `../flutter_elitesync_module/build/host/outputs/repo`。`apps/android/app/build.gradle.kts` 明确将 `../flutter_elitesync_module` 作为模块目录，`preBuild` 依赖 `syncFlutterAar`，后者调用 `flutter build aar --no-debug --no-profile`，再以 `com.elitesync.flutter_elitesync_module:flutter_release:1.0` 等坐标消费模块 AAR。因此 `apps/android` 是**与当前 Flutter 模块路径绑定的仓内 Android host 配置**，不能再按“仓库无 host”处理。上述四个 `apps/android` 关键文件均列于 HEAD 且工作区状态无差异；此判断仅及这些文件，不能证明完整构建图或全部依赖与当前 dirty 源码一致。

模块 `.android/settings.gradle` 明示 `Generated file. Do not edit.`，`.android/app/build.gradle` 声明 `com.elitesync.flutter_elitesync_module.host` 并依赖 `project(":flutter")`；这表明另有模块生成式 runner。所读 `.android` 文件不在当前 HEAD 的准确路径清单内，也无普通 `git status --short` 条目；不把生成内容当作受 Git 固定的 v10 产品 host。`pubspec.yaml` 明确这是 Flutter module，并说明其版本只供 `flutter run` 的 Runner app，不影响嵌入它的 native host。

**不能给出唯一可信的 M5 synthetic 安装/构建入口。** `lib/main.dart` 默认转到 `main_prod.dart`；`main_demo.dart` 才是 APP-M5-01 确认的 synthetic/dev 入口。当前所读 `apps/android` 的 AAR 构建命令未指定 `-t lib/main_demo.dart` 或其它已核对的入口选择机制，生成式 runner 配置也未提供本任务可验证的 synthetic 入口绑定。`apps/android` 还含旧仓库位置的可选本地 Maven 路径和网络仓库、不同 ABI 与 API base URL 配置；只读取了这些字符串，没有访问对应位置或运行依赖解析。不得据目录名、Gradle 声明或历史 APK 回执认定当前 checkout 可安装、可启动或不会触达真实端点。

未核实：Gradle wrapper/插件与依赖解析、完整 Android 源码和 manifest 合成、AAR 产物是否存在及其源码身份、默认入口实际打包结果、SDK/JDK 版本与许可证、设备清单和安装目标、构建/签名/启动/稳定行为。设备仍 `UNKNOWN`；`adb devices -l` 未运行。APP-M5-01 对模块固定 `android` 目录不存在的结论保持成立，但此次定位发现了 `apps/android` 及 `.android` 两个不同位置。

**唯一建议下一步：**由 Work 独立审查本定位后，另立有界的仓内 Android host **synthetic 入口绑定/构建图静态核对**任务，固定 `apps/android` 与 `main_demo.dart` 的目标关系、必要的最小配置修改范围及负向检查，先确认不会默默采用 prod 入口或真实端点，再单独决定是否发布带设备与一次性预算的运行任务。本任务不生成、修改或运行 host，不自行派发后继。

两轮只读定位预算 **2/2 已耗尽**。APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变；停 Work 独立 LEVEL 2 审查。无提交、pull、push。
