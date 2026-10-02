# APP-T12-G12｜Flutter 模块范围静态分析

状态：`ISSUED`；风险 `LEVEL 2`（APP-T12 G-12 证据门，工具执行）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 精确范围

唯一实时仓库 `D:\EliteSync-v10`，预期本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。保留全部既有 dirty/untracked。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，以及 `EVIDENCE/APP-T12-G12-LOCAL-FLUTTER-EVIDENCE-STATUS/plan.md` 和 `work-review.md`。核对当前 Git 身份、模块 `pubspec.yaml`、`.dart_tool/package_config.json` 存在与本地 `flutter` 命令解析。若预期路径或 HEAD 不符，停止执行并报告差异。

唯一工具执行：在 `apps/flutter_elitesync_module` 中**一次**运行 `flutter analyze --no-pub`。硬时限 180 秒；标准输出和标准错误分别最多保存/展示前 64 KiB，并记录是否截断。超时须终止本次进程树、记录 `TIMEOUT`，不得重试。命令退出非零、启动失败或报告问题时，原样保存退出码、诊断摘要与首个失败点，立即停止分析，不修复、不重跑、不扩大命令范围。允许为这一次分析产生工具自身的本地缓存；不手工改写缓存。

唯一允许新增本目录 `summary.md`，记录输入 Git/模块身份、精确命令、开始/结束时间、时限、退出码、输出截断、问题数量或实际诊断摘要、预算 `1/1`、分析前后 `git status --porcelain` 的差别，以及严格结论。可以读取当前模块和任务文件作定位；不得改源码、配置、测试、其它 authority 或历史 APP-T12 结论。若分析揭示既有问题，仅记入摘要，交给 Work 决定新任务。

## 不跨越的门与停点

不执行 `flutter pub get`、完整测试、Android/Gradle/AAR 构建、adb/设备、网络、UAC、真实账号或备份/DB/密钥/SSH/生产 API，不访问旧 `D:\EliteSync`。不得提交、pull、push、自接受或派发后继。旧任务预算均不重置。模块 analyze 即使退出 0，也只建立当前本地静态检查证据；M5 host 仍 `NOT_FIXED`、设备 `UNKNOWN`、M5 运行 `NOT_READY`，APP-T12 G-08/G-11、真实 Conversation 权限、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。
