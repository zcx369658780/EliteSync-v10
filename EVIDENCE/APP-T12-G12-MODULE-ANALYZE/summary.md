# APP-T12-G12｜Flutter 模块范围静态分析回执（候选）

状态：Codex 工具执行候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。唯一仓库 `D:\EliteSync-v10`，本地分支 `main`，HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 原样保留。模块 `apps/flutter_elitesync_module` 的 `pubspec.yaml` SHA-256 为 `ECBC74EF27D949712532409EADC6BE0928EA56C9CBC603EB0C80FBE0CEC7E6BC`；`.dart_tool/package_config.json` 存在，SHA-256 为 `A0397A29C470252B6DBA62E8E8D3D341209A93944DEBF6B666FCF70917882CA1`。本地 `flutter` 命令解析为 `D:\flutter\bin\flutter.bat`。

## 唯一执行与硬预算

在 `D:\EliteSync-v10\apps\flutter_elitesync_module` 中仅启动一次 `flutter analyze --no-pub`；预算 **1/1 已耗尽**。通过本地进程包装器并行排空 stdout/stderr，各自只捕获前 65,536 字节；设置 180 秒等待上限，超时即终止进程树。此次正常结束，无终止动作。

| 字段 | 实际回执 |
| --- | --- |
| 开始（UTC） | `2026-09-29T15:13:33.157157+00:00` |
| 结束（UTC） | `2026-09-29T15:13:55.534724+00:00` |
| 墙钟耗时 | 22.375 秒；工具自身报告 20.8 秒 |
| 启动状态 | 成功；无启动异常 |
| 命令退出码 | **1** |
| 超时 | **否**，未达到 180 秒 |
| stdout | 3,453 字节；64 KiB 截断 **否** |
| stderr | 32 字节；64 KiB 截断 **否** |
| 工具结尾 | `19 issues found. (ran in 20.8s)` |

分析器列出 **0 error、1 warning、18 info**。输出的首条诊断是 `lib/core/network/interceptors/logging_interceptor.dart:11:5` 的 `avoid_print` info；唯一 warning 是 `lib/features/profile/presentation/widgets/standard_ziwei_grid.dart:508:11` 的 `unused_local_variable`。其余 info 涉及 logging/astro 的 `avoid_print`、telemetry/Chat 测试的 `use_null_aware_elements`，以及 RTC/设计系统测试的 `deprecated_member_use`。这是本次工具的实际非零结果；没有把 info/warning 记为分析通过，也没有因问题看似既有而修复或重跑。

分析前后各执行一次 `git status --porcelain`：均为 140 个状态条目，逐条比较无新增、移除或变化；未观察到本次分析引入的非忽略工作区改动。允许的工具自身本地缓存未手工改写。未运行 `flutter pub get`、测试、Android/Gradle/AAR 构建、adb、设备、网络、真实数据或任何第二次 analyze。

**严格结论：模块范围 analyze 已执行，但退出 1，静态分析门未通过。** 本回执只建立当前本地模块的有界工具执行事实；APP-T12 历史 G-12 不追改，旧预算不重置。问题修复或再验证须由 Work 另立任务，本次失败即停。M5 host 仍 `NOT_FIXED`、设备 `UNKNOWN`、运行 `NOT_READY`；APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。无提交、pull、push；停 Work 独立 LEVEL 2 审查。
