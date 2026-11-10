# APP-M5-01｜Android 最小开发演示本机只读预检（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。本任务只新增本文件，**没有构建、安装、启动设备、运行 adb server 或访问网络/真实数据**。

## 两轮实际来源

1. **第一轮（1/2）**：读取根规则、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，以及 `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md:18,25-34,38-60`。路线图把 M5 早期检查点定义为“指定平台可安装／启动并完成一项确定行为”，需要精确代码、环境、设备、操作与结果；Android 单平台开发演示只是近期工作假设，不能把静态或旧回执写成当前 APK PASS。定点读取 Flutter 模块 `lib/main.dart`、`main_demo.dart`、`main_dev.dart`、`main_prod.dart`、`app/config/app_env.dart`、`app/bootstrap/app_bootstrap.dart`、`pubspec.yaml`，并参考本仓旧 `ELITESYNC_V10_ANDROID_STUDIO_EMULATOR_FIRST_FRAME_BASELINE_ACCEPTANCE_V0_1.md:35-54`。模块 `lib/main.dart` 调用 prod；`main_dev.dart` 默认非 mock、包含远端 API base URL 路径，不应作为纯 synthetic 运行入口；`main_demo.dart` 明确创建 dev flavor、loopback 占位 URL、`useMockData` 与各主功能 mock/synthetic 开关，初始 Home，调用 `seedSyntheticDemoSession` 后 `runEliteSyncApp`。这只是代码路径，未在本任务启动。`seedSyntheticDemoSession` 会写本地 synthetic token/profile；`runEliteSyncApp` 启动前还调用旧私密 Chat 缓存清理，因此未来运行须限定一次性测试设备/账户，不能直接拿真实用户设备当无副作用演示。旧模拟器首帧 acceptance 记录了当时的 AVD/包/启动事实，但其分支、包版本和证据不等于当前 checkout 的 M5 运行证明。
2. **第二轮（2/2）**：仅用 PowerShell `Get-Command` 查询当前 PATH 对 `flutter`、`dart`、`adb`、`java` 的命令解析；对模块固定 `.dart_tool/package_config.json`、`android` 目录和其 `local.properties` 做 `Test-Path -LiteralPath`；对当前进程显式 `ANDROID_HOME`、`ANDROID_SDK_ROOT`、`JAVA_HOME` 判断设置状态，并对本轮固定文件做 SHA-256。全部命令退出 0。没有枚举或猜测其它磁盘路径，没有运行 `flutter doctor`、`flutter --version`、`adb`、Gradle、模拟器、构建或安装。`adb devices -l` **NOT_CHECKED**：该命令在 server 未运行时可能启动 adb server，超过本任务只读停点；设备清单与状态保持 `UNKNOWN`。

## 固定入口与当前本机最小事实

| 文件（仓库相对路径） | SHA-256 |
| --- | --- |
| `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md` | `09506319D1047CA0FE89613AB2D6E3F84C626E93F9CC1A7D11B5A406DC4FF82A` |
| `apps/flutter_elitesync_module/lib/main.dart` | `CB356264EBEEFF5F75CFCFA8195E59ED8218F19752895EEDA226DDDED698C60A` |
| `apps/flutter_elitesync_module/lib/main_demo.dart` | `F542C28670BB3D9C28B4D5DF43E93FBCBD144FCB266FDFB91B9B94789B422D02` |
| `apps/flutter_elitesync_module/lib/main_dev.dart` | `0A258DA84A3165A1E4AE7E05527FDD069F0D772E49E80442E1F1968C4B876D50` |
| `apps/flutter_elitesync_module/lib/main_prod.dart` | `AB5AD23F7E00BA195EB8FF11EB1E052739BDA53FE5B7DB33682A67F25BFA9C78` |
| `apps/flutter_elitesync_module/lib/app/config/app_env.dart` | `C53A449036D50FF9F51363FE73103F22544B610D2B4C83CA1C32BBCC1DCFCD32` |
| `apps/flutter_elitesync_module/lib/app/bootstrap/app_bootstrap.dart` | `051BEC691642CDE8F94B4DB084C11AEC7C64FA478D769CF23524BBD7F7F45F7B` |
| `apps/flutter_elitesync_module/pubspec.yaml` | `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC` |
| `apps/flutter_elitesync_module/.dart_tool/package_config.json` | `A0397A29C470252B6DBA62E8E8D3D341209A93944DEBF6B666FCF70917882CA1` |
| 旧 Android emulator first-frame acceptance | `6289D851011C682DC16E3551DC65CC14A0087E0BF06C611C78A30594C71706EF` |

`Get-Command` 均解析成功：`flutter`、`dart` 指向当前 `D:\flutter\bin` 下的批处理文件，`adb` 指向当前用户 Android SDK 的 `platform-tools\adb.exe`，`java` 指向 Eclipse Adoptium JDK 17 可执行文件。**命令可解析不证明工具版本、SDK 包/许可证、Gradle 或 Android 构建可用**；这些程序均未执行。`.dart_tool/package_config.json` 存在；模块固定 `apps/flutter_elitesync_module/android` 目录及其 `local.properties` 均不存在。当前进程 `ANDROID_HOME`、`ANDROID_SDK_ROOT`、`JAVA_HOME` 均未设置；未据 PATH 反推 SDK 根或搜索其它位置。`adb devices -l`、当前模拟器/实体设备、可安装 Android host、APK、启动及稳定行为均为 `NOT_CHECKED/UNKNOWN`。第一轮早期对不存在的模块内 Gradle 文件进行定点读取尝试返回路径不存在；未因此寻找别处文件。

## 停点与后继

**NOT_READY：尚不足以下达当前 checkout 的 Android 安装/启动动作。** 阻断事实是指定 Flutter 模块没有 Android host 目录，且设备清单未被安全读取；现有入口与 package graph、PATH 命令解析不足以建立安装目标。旧首帧回执属于不同历史分支/版本，不替代本机本次运行。

建议 Work 下一张**有界 Android debug 运行任务**仅在先明确当前 v10 所用的准确 Android host/项目位置、目标受控测试设备或 AVD、设备状态读取方式和可接受的 adb server 行为后发布；任务应固定 synthetic `main_demo.dart` 入口、隔离测试设备/账户、唯一安装/启动与稳定行为、失败停点、回执位置及一次性命令预算。若任一步可能触发 Windows UAC，须在动作前停下，按根规则仅凭 Owner 于**当前 Work 会话**输入“我在”确认到场，再核对该任务自身授权；此确认不放行构建/安装。当前无此授权，本计划不实施或派发后继。

真实账号、Conversation read/send、APP-T12 G-08/G-11、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门保持未变。两轮只读预算 2/2 耗尽，停 Work 独立 LEVEL 2 审查。
