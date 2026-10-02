# APP-M5-05｜Android synthetic host 标记、端点与 AAR 身份守卫设计（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。仅新增本文件，未修改源码、Gradle、测试、配置或 authority；未运行 Flutter/Gradle/adb、构建、设备、网络、UAC 或安装。

## 两轮准确来源（2/2）

1. **第一轮：定点 host 与 Dart 入口。** 读取 `apps/android/app/build.gradle.kts`、`apps/android/settings.gradle.kts`、`apps/android/app/src/main/java/com/elitesync/MainActivity.kt`、`apps/android/app/src/main/AndroidManifest.xml`、模块 `lib/main.dart`、`lib/main_demo.dart`。用 `Get-FileHash -Algorithm SHA256` 固定下表字节；未读 `local.properties` 内容，也未访问 Gradle 配置中提到的旧仓库位置。
2. **第二轮：仅直接调用与已定位的任务/变体定义。** 读取 `apps/android/build.gradle.kts`，以及 `main.dart`/`main_demo.dart` 直接调用的 `main_prod.dart`、`app_bootstrap.dart`、`app_env.dart`、`secure_storage_service.dart`、`local_storage_service.dart`；重读 `app/build.gradle.kts` 中 `syncFlutterAar`、`preBuild`、debug/profile/release 与 AAR 依赖的准确行。没有索引其它 SDK、目录或工程文件。

| 准确来源（仓库相对） | SHA-256 |
| --- | --- |
| `apps/android/app/build.gradle.kts` | `4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3` |
| `apps/android/settings.gradle.kts` | `A976B7F3D9C4F8446F7AE32A5817188CF4F11A021DD854152CB327A28277D88C` |
| `apps/android/app/src/main/java/com/elitesync/MainActivity.kt` | `4432C60E723FF2C0E5955A50A94E9A8A050DA5472BEB9CDF714E68AE24440FF9` |
| `apps/android/app/src/main/AndroidManifest.xml` | `1923E66B50EEDCB613856665735662A887C0A0A5679110E7E4560CC783767405` |
| `apps/flutter_elitesync_module/lib/main.dart` | `F0F4A6C112774AE0EE78D47B4FFAFD6CF20250B1CA5B6EE112AC4A4EB2BF2B54` |
| `apps/flutter_elitesync_module/lib/main_demo.dart` | `F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02` |
| `apps/android/build.gradle.kts` | `F4DB52252E3F16CDB2EE6B783AB3330366534D236024CE69AD6924C136133461` |
| `apps/flutter_elitesync_module/lib/main_prod.dart` | `AB5AD23F7E00BA195EB8FF11EB1E052739BDA53FE5B7DB33682A67F25BFA9C78` |
| `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart` | `051BEC691642CDE8F94B4DB084C11AEC7C64FA478D769CF23524BBD7F7F45F7B` |
| `apps/flutter_elitesync_module/lib/app/config/app_env.dart` | `C53A449036D50FF9F51363FE73103F22544B610D2B4C83CA1C32BBCC1DCFCD32` |
| `apps/flutter_elitesync_module/lib/core/storage/secure_storage_service.dart` | `6896ECAD91C88A5DAD884C8A1558A931B6819ED44C203F7052B34EFFB2AB69E2` |
| `apps/flutter_elitesync_module/lib/core/storage/local_storage_service.dart` | `410BA0E3437A32417E4CE4ED4C81FB33B11934B38A3606024100A9AA5A283F9A` |

## 当前关系与未闭合风险

- **标记。** APP-M5-04 已接受的 `lib/main.dart` 只在编译期 `ELITESYNC_SYNTHETIC_DEMO=true` 时调用 `main_demo.dart`；缺失或拼错走 prod。host 的 `flutterDartDefines` 可把任意分号/逗号分段转为 `--dart-define=...`，但没有将 synthetic 意图、Android 构建变体和标记强制绑成一个来源。`syncFlutterAar` 对所有 host `preBuild` 共享，且只生成 release AAR；debug 与 release 都消费 `flutter_release:1.0`，profile 消费 `flutter_profile:1.0`。这是当前配置关系，不证明哪份 AAR 已生成。
- **产物。** `syncFlutterAar` 在 `CI=true` 且 release AAR 目录存在时直接跳过；仓库相对 Maven repo 可供 host 依赖解析。现有 `inputs.property("flutterDartDefines", ...)` 只描述 Gradle 任务输入，不证明 CI 跳过的旧 AAR 或依赖缓存与当前 Dart 源码/标记一致。相同 release 坐标供 debug/release 使用，不能仅靠目录区分 synthetic 与 prod 产物。
- **端点。** host default/release `BuildConfig` 是正式域名，debug/profile 为非 loopback IP；`MainActivity` 用这些值补全缺失的 Intent extra，又允许已有 Intent extra 优先于本地 bootstrap 文件返回 API/WS。`main_prod.dart` 会读取该 channel 结果作为 API 优先来源。demo `AppEnv` 固定 loopback 占位 URL、mock 开关并写入 synthetic token/profile/onboarding；它也经过启动缓存清理。虽然 demo 目前未直接读取 host bootstrap，host 仍暴露非 loopback 值及覆盖口，不能凭代码字符串宣称整个 synthetic APK 无网络或对真实端点隔离。

## 实现前失败关闭合同（建议，尚未实现）

1. **单一显式来源与变体门。** 由 host 的专用、默认关闭的 synthetic 构建意图产生 Dart `ELITESYNC_SYNTHETIC_DEMO=true` 与 host `BuildConfig` synthetic 标识；generic `flutterDartDefines` 不得自行注入/重复/冲突该保留键。只有受控 debug 变体可接受此意图；profile/release 或同时请求其它变体时必须在产物生成前失败。无意图、拼错或缺失标记维持当前 prod 分派；宣称 synthetic 但任一标记不一致则失败，不可静默退回 prod。
2. **AAR 与 host 身份同源。** synthetic 路径必须在本次受控输入下生成或核对精确来源身份，不能利用 `CI=true` 的旧预制 release AAR 跳过。synthetic 与普通产物的输出/依赖选择须隔离，或对固定输入、标记及 AAR 字节建立可核验且失败关闭的绑定；相同 Maven 坐标、仅不同目录或仅 Gradle 输入声明都不足以单独证明身份。无匹配回执、缓存不确定或解析到另一产物时停止，不进入安装步骤。现有 `preBuild`/共享 `flutter_release:1.0` 结构尚未满足这一条，具体 Gradle 实现及可验证回执须在后继源码任务审查。
3. **synthetic 端点封闭。** synthetic host 的 API/WS `BuildConfig` 仅给固定 loopback 占位或不可达测试端点；`MainActivity` 的 Intent extra 与本地 bootstrap 对 API/WS 不能覆盖为非 loopback（最简单是 synthetic 分支忽略两者并返回固定安全值）。保持普通 prod 路径的现有行为；不得让 debug 名称本身代表 synthetic。对运行时其它网络路径的隔离仍须后续静态/运行证据，不能从本条直接推出无网络。

**负向用例**：未给标记/拼错标记仍是 prod；直接通过 generic define 注入 true、重复或相互冲突的键被拒；synthetic 请求 profile/release 或混合变体被拒；`CI=true` 且已有旧 AAR 不得复用；AAR 标记/源码身份与 host 不符不得继续；Intent 与 bootstrap 给出非 loopback API/WS 时 synthetic 仍只返回固定安全值；普通 prod 默认和原有端点选择不受 synthetic 分支误伤。验证只可先在虚构/本地配置上做定向静态和构建图检查，运行、设备和端点访问仍须另行授权。

## 唯一建议后继与停点

建议 Work 另立一张 **Android host synthetic 守卫实现** LEVEL 2 任务，允许路径仅 `apps/android/app/build.gradle.kts`、`apps/android/settings.gradle.kts`、`apps/android/app/src/main/java/com/elitesync/MainActivity.kt` 与三者的定向测试/证据文件；保留已接受的 Dart 入口 `main.dart`。任务应先固定专用意图、debug 限制、AAR 身份验证方法、端点常量及测试预算，再实现并独立审查。回退仅撤销该任务限定的 host 差异/测试，恢复普通构建关系，保留全部其它工作区改动。若这些路径无法建立产物隔离或准确身份，结果必须是 `NOT_FIXED`，不得发明一个“可运行”命令或扩大路径自行修复。

**当前结论：`NOT_FIXED`；M5 运行仍 `NOT_READY`。** 设备 `UNKNOWN`，未核依赖解析、AAR 字节、APK、安装或真实运行。两轮只读预算 **2/2 已耗尽**。APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变；停 Work 独立 LEVEL 2 审查。无提交、pull、push。
