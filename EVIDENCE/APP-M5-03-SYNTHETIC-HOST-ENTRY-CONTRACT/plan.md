# APP-M5-03｜Android host synthetic 入口与端点静态合同（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。唯一仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。只新增本文件，未修改源码、Gradle、配置、测试或 authority，未运行 Flutter/Gradle/adb、网络、构建、安装或设备。

## 两轮准确来源（2/2）

1. **第 1 轮，本仓定点静态读取。** 读取 `apps/android/settings.gradle.kts`、`apps/android/app/build.gradle.kts`、`apps/android/app/src/main/AndroidManifest.xml`、模块 `lib/main.dart` 与 `lib/main_demo.dart`。仅在 `apps/android` 用准确文件名 `MainActivity.kt`、`EliteSyncApp.kt` 定位并读取 host 的直接入口。各文件用 `Get-FileHash -Algorithm SHA256` 核对；没有搜索其它仓库、SDK 或磁盘。
2. **第 2 轮，固定 SDK 文件与直接调用。** 仅在任务给定的 `D:\flutter\packages\flutter_tools\lib\src\commands\build_aar.dart` 上读取 target/选项相关源码；该文件存在。对第 1 轮 `main_demo.dart` 直接调用的仓内 `app_bootstrap.dart`、`app_env.dart`、`secure_storage_service.dart`、`local_storage_service.dart` 作定点读取与 SHA-256。没有读取 `local.properties` 内容、凭据或密钥；未执行工具链。

| 准确来源 | SHA-256 |
| --- | --- |
| `apps/android/settings.gradle.kts` | `A976B7F3D9C4F8446F7AE32A5817188CF4F11A021DD854152CB327A28277D88C` |
| `apps/android/app/build.gradle.kts` | `4D3A83B8940BBE5F14223350FC444C3F2A854E52A2416E525CD2D25ECD686ED3` |
| `apps/android/app/src/main/AndroidManifest.xml` | `1923E66B50EEDCB613856665735662A887C0A0A5679110E7E4560CC783767405` |
| `apps/android/app/src/main/java/com/elitesync/MainActivity.kt` | `4432C60E723FF2C0E5955A50A94E9A8A050DA5472BEB9CDF714E68AE24440FF9` |
| `apps/android/app/src/main/java/com/elitesync/EliteSyncApp.kt` | `AE25ADC53B6EF196892EE827AC086C8CDFFC7D36D9015945BD8324D43011BB46` |
| `apps/flutter_elitesync_module/lib/main.dart` | `CB356264EBEEFF5F75CFCFA8195E59ED8218F19752895EEDA226DDDED698C60A` |
| `apps/flutter_elitesync_module/lib/main_demo.dart` | `F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02` |
| `D:\flutter\packages\flutter_tools\lib\src\commands\build_aar.dart` | `3B5C49E3A8DE1C3C5FEA4A385484DB37C4799ED3B480FA8F265F99BB5F8CBDEB` |
| `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart` | `051BEC691642CDE8F94B4DB084C11AEC7C64FA478D769CF23524BBD7F7F45F7B` |
| `apps/flutter_elitesync_module/lib/app/config/app_env.dart` | `C53A449036D50FF9F51363FE73103F22544B610D2B4C83CA1C32BBCC1DCFCD32` |
| `apps/flutter_elitesync_module/lib/core/storage/secure_storage_service.dart` | `6896ECAD91C88A5DAD884C8A1558A931B6819ED44C203F7052B34EFFB2AB69E2` |
| `apps/flutter_elitesync_module/lib/core/storage/local_storage_service.dart` | `410BA0E3437A32417E4CE4ED4C81FB33B11934B38A3606024100A9AA5A283F9A` |

## 可证合同与缺口

**AAR Dart target：当前固定为 prod 路由，synthetic 未绑定。** host `app/build.gradle.kts` 的 `syncFlutterAar` 调用 `flutter build aar --no-debug --no-profile`，其 `flutterDartDefines` 只转换为 `--dart-define=...` 参数。指定 SDK 文件的 `BuildAarCommand` 声明 `usesDartDefineOption()`，但在构建路径中将 `targetFile` 直接固定为 `lib/main.dart`，并将该文件作为 `forcedTargetFile` 和 `buildAar(target: ...)` 的目标；本次来源未见可把 AAR target 改为 `main_demo.dart` 的选项。当前模块 `lib/main.dart` 直接调用 `main_prod.dart`，没有按 dart define 分派；故仅设置现有 `flutterDartDefines` **不能证明**将当前 host AAR 切到 synthetic 入口。

**host 端点：存在非 loopback 默认值与覆盖路径。** `app/build.gradle.kts` 为 default/release 写入正式域名 API/WS `BuildConfig` 字符串，为 debug 写入远端 IP API/WS 字符串，profile 继承 debug。`MainActivity` 在 Intent 对应 extra 为空时填入 `BuildConfig` 默认值，`getBootstrap` 再按 Intent extra 优先、本地 `elitesync_bootstrap.json` 次之返回端点；外部 Intent extra 可覆盖默认值。Manifest 将其声明为 launcher FlutterActivity。没有证据表明当前 AAR 入口会忽略这些值，也没有证据证明运行时实际发起网络请求。`EliteSyncApp` 对当前配置的 Baidu native SDK 开关会早退；不能由此推出整个应用无网络行为。

**demo 数据边界：代码意图明确，但未接入 host。** `main_demo.dart` 设置 loopback 占位 API URL、mock/synthetic 开关、Home 初始路由；启动前写入 synthetic access token/profile/onboarding 状态并删除 refresh token。直接存储实现分别调用 `FlutterSecureStorage` 和 `SharedPreferences`；`runEliteSyncApp` 在启动前还调用旧私密 Chat 缓存清理。此路径有设备本地写入副作用，不能在真实用户设备/账户上作为无副作用演示。host 的非 loopback 默认值及可覆盖值与 demo loopback 意图尚未形成受控一致合同。

**结论：`NOT_FIXED`。** 当前源码足以证明仓内 host 绑定 Flutter module 和本机 SDK AAR target 的选择方式，不能证明当前 host 使用 `main_demo.dart`、隔离了端点、AAR 与当前源码一致，或 APK 可构建/安装/启动。`CI=true` 且预制 release AAR 存在时，host 的 `syncFlutterAar` 还可能跳过重建；本轮没有检查产物或实际环境。设备状态仍 `UNKNOWN`，`adb devices -l` 未运行。

## 一张最小可审后继候选任务（建议，未派发）

建议 Work 另立 **Android host synthetic 配置绑定** LEVEL 2 任务，允许修改且仅允许修改 `apps/flutter_elitesync_module/lib/main.dart`、`apps/android/app/build.gradle.kts`、`apps/android/app/src/main/java/com/elitesync/MainActivity.kt` 及这些逻辑所需的定向测试文件。利用当前 AAR 的 `--dart-define` 能力，在 `main.dart` 增加显式、默认关闭的编译期 synthetic 入口分派；在 host 构建中让该标记与仅供受控 debug 的 loopback `BuildConfig` 端点同源，防止预制 AAR 跳过时错用旧 prod 产物；在 `MainActivity` 对 synthetic 构建阻断 Intent/本地 bootstrap 的非 loopback 端点覆盖。保持无标记的现有 prod 行为和 release 配置不变。

负向检查至少覆盖：无标记与 release 不进入 demo；synthetic 标记缺失/拼错不能静默视为 demo；host 非 loopback 默认或 Intent/bootstrap 覆盖不得进入 synthetic；`CI` 预制 AAR 不得冒充当前 synthetic 产物；任何测试不得使用真实账户、设备或端点。回退为撤回本候选任务的上述限定源码/配置差异并核对无标记产物仍走既有入口；保留所有其它工作区改动。此建议不是构建或安装授权，具体参数、测试预算及实现差异须由 Work 新任务固定并独立审查。

两轮静态预算 **2/2 已耗尽**。APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变；停 Work 独立 LEVEL 2 审查。无提交、pull、push。
