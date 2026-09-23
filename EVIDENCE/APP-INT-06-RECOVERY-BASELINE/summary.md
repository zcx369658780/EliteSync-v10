# APP-INT-06-RECOVERY-BASELINE｜候选回执

状态：**WORK LEVEL 1 ACCEPT — EXISTING BEHAVIOR BASELINE ONLY**。作者执行时本地 `main` 基线：`ea3d5c75a64270f246f47e7a52f51a90031fa5a6`。范围仅为现有 synthetic/dev 行为的测试和观察；未修改产品 `lib/`、backend、DB、依赖或权限语义。

## 差异与验证

- 新增 `apps/flutter_elitesync_module/test/synthetic_main_loop_recovery_baseline_test.dart`，Git blob `4129fd6ab23cb87cc26640e11ee714e06d037710`；既有 `test/android_runtime_bootstrap_test.dart` 未改。测试采用虚构 match/partner ID，不访问真实数据。
- `flutter pub get --enforce-lockfile`：1 次，PASS；`pubspec.lock` 前后 blob 均为 `b56c4b2c45bab65106c12e4d75d6c5b34209aeb4`。
- `flutter test --no-pub test/synthetic_main_loop_recovery_baseline_test.dart test/synthetic_home_main_loop_integration_test.dart`：1 次，4 tests PASS；没有失败修正重跑。未运行完整测试、analyze 或重新构建。
- 新 ProviderContainer 在同一测试进程里从 `CN_NONE`、`CV_LOCKED` 开始；第一个容器可到 `CN_ACTIVE`、`CV_ACTIVE`，关闭 Connection 后回到 `CN_CLOSED`、`CV_LOCKED` 且 synthetic 内容不可揭示。新容器只证明 provider/fixture 重新初始化，**不是 Android 进程重启或持久化证明**。
- Match provider loading/error 时 Home 摘要为 `UNKNOWN`，下一步指向 Match；没有把未取得的投影标记为 proposal。Connection 非 active 时 Conversation 锁定，Home 指向 Connection。

## Android 一次进程退出与冷启动观察

设备：`elitesync_api36` AVD；`emulator-5554`，`sdk_gphone64_x86_64`，Android API 36。设备启动后安装现有 APP-INT-05 debug APK，`adb install -r` 1 次 PASS。APK 路径：`C:\Users\zcxve\AppData\Local\Temp\EliteSync-v10-app-int-05-home\apps\flutter_elitesync_module\build\host\outputs\apk\debug\app-debug.apk`；1,380,317,731 bytes；SHA-256 `2B0D1C569B847E19F66EFC29B8105142893C42F2ADAF591253333F7AB8799975`。该工作区 HEAD 是 APP-INT-05 候选 `060f9a6499f56a434e6ae4598435d49026ec683a`；当前 main 的 Flutter `lib/` 与候选无差异。此为已有 APK 的来源与代码一致性核对，未在本轮重建二进制。

首次冷启动 `am start -S -W` PASS，PID 4061。通过 Android UI hierarchy 直接观察 Home 初始 `READY · Synthetic`、`MT_PROPOSAL_PRESENTED · Synthetic`、`CN_NONE · Synthetic`、`CV_LOCKED · Synthetic`，按钮“查看连接”。实际点击请求 Connection、模拟接受，再到 Messages 请求消息同意、模拟接受；返回 Home 时观察到 `CN_ACTIVE · Synthetic`、`CV_ACTIVE · Synthetic`，按钮“查看消息”。这两个 active 状态是**该进程内手动推进的本地 simulation**。

随后执行一次 `am force-stop`，旧 PID 消失；`am start -W` 返回 `LaunchState: COLD`，新 PID 4646。启动后直接观察 Home：`READY · Synthetic`、`MT_PROPOSAL_PRESENTED · Synthetic`、`CN_NONE · Synthetic`、`CV_LOCKED · Synthetic`；下一步文案为“连接尚未激活”，按钮“查看连接”。新 PID 在观察结束时仍存活。Readiness 和 Match 是 demo 启动/本地 mock 的重新 seed；Connection/Conversation 的先前 active 状态没有在本次冷启动后出现。此结果只描述该 APK、该设备和一次观察，不决定未来应保存还是清除 consent、消息或 Connection。

UI hierarchy 曾写入模拟器公共 `/sdcard/appint06-ui.xml` 用于直接读取；本地未保留截图或原始日志，未读取 app-private data。未观察真实网络或生产服务，亦未将其缺席计为网络审计结果。无额外 Android build；完整重启观察 1 次。

## 待决边界

下一步若要新增跨进程保存/恢复，必须先明确 Connection 与独立 Messaging consent 的保存、失效、清除政策，以及消息可见性的恢复条件；这属于新的 LEVEL 2 语义任务。本候选不实现这些决定，不声称 persistence/recovery 已完成、真实用户或 release ready。作者保留根目录原有无关 untracked 目录，未提交或推送；Work 的审查结果如下。

## Work 独立验收（2026-09-23）

Verdict: **ACCEPT — EXISTING SYNTHETIC RESTART/UNKNOWN BASELINE ONLY**。

Work 核对两个新增路径与任务允许写集，测试 blob `4129fd6ab23cb87cc26640e11ee714e06d037710`、作者回执原始 blob `2f597cc36ede40d6ac1a7dd384f75e9289825bdb` 均匹配；本地 `main` 在验收前仍为 `ea3d5c75a64270f246f47e7a52f51a90031fa5a6`，没有产品 `lib/`、依赖、后端或 DB 差异。Work 阅读新增测试及现有 Home、Connection、Conversation provider：新容器从 `CN_NONE/CV_LOCKED` 重新 seed，同进程进入 `CN_ACTIVE/CV_ACTIVE` 后关闭 Connection 会清除本地同意并重锁；Match loading/error 的 UNKNOWN 与返回 Match 路由符合现有 fail-closed 分支。测试陈述没有把新容器当成 Android 重启。

Work 独立核对现有 APP-INT-05 APK SHA-256 为 `2B0D1C569B847E19F66EFC29B8105142893C42F2ADAF591253333F7AB8799975`，其工作区 HEAD 为 `060f9a6499f56a434e6ae4598435d49026ec683a`，该提交与本地主线 Flutter `lib/` 无差异。作者报告一次 locked pub get 和一次 targeted test（4 PASS），以及一次设备进程退出/冷启动观察；Work 没有重跑命令或独立复现设备步骤，原始设备日志和截图未保留，故运行结论限于作者回执所记的一次 synthetic/debug 观察。`analyze`、新 APK build、真实网络审计均未运行。本验收不证明持久化恢复，也不决定未来保存或清除 Connection、消息同意及消息可见性的政策；这些仍须 Owner 决策后另立 LEVEL 2 任务。
