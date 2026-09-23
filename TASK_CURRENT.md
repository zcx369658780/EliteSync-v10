# EliteSync v10｜TASK_CURRENT

Task ID: `APP-INT-06-RECOVERY-BASELINE`

Risk Level: `LEVEL 1`（现有 synthetic 行为验证；若需新增持久化或 consent 语义，升至 LEVEL 2 并停止）

Status: `ACCEPTED — OWNER DECISION REQUIRED BEFORE PERSISTENCE/RECOVERY TASK`

Work verdict (2026-09-23): `ACCEPT — EXISTING SYNTHETIC RESTART/UNKNOWN BASELINE ONLY`，见 `EVIDENCE/APP-INT-06-RECOVERY-BASELINE/summary.md`。本任务已结束，不再执行或重发。下一任务如涉及跨进程保存/恢复，需先由 Owner 决定 Connection、独立 Messaging consent 的保存、失效、清除及消息可见性恢复条件；在此之前没有新任务单授权实现。

## Objective / Why now

在已接受并本地集成的 APP-INT-05 主循环上，测定 synthetic demo 的重启、状态失效以及 Match loading/error 时的**现有**行为，形成下一轮持久化/恢复任务的可信基线。APP-INT-05 的运行回执证明同一进程内主循环，尚未证明重启恢复。

## Scope / allowed files

- 只读消费 `CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`EVIDENCE/APP-INT-05/summary.md`，以及 APP-INT-01～05 相关 provider、demo entry 和现有测试。当前代码基线以本地 `main` 为准；先核验工作区冲突，不碰无关 untracked 目录。
- 可新增 `apps/flutter_elitesync_module/test/synthetic_main_loop_recovery_baseline_test.dart`；仅在测试无法表达时，可修改现有 `test/android_runtime_bootstrap_test.dart`。可写 `EVIDENCE/APP-INT-06-RECOVERY-BASELINE/summary.md` 和必要的短回执。**不修改产品 `lib/`、后端、DB、依赖、环境配置或旧接受记录。**
- 使用虚构本地 actor/数据；不读取 app-private data、真实参与者内容或生产服务。

## Acceptance criteria

1. 用针对性测试分别观察新 ProviderContainer/冷启动、Connection active、独立 Messaging consent 后 Conversation active、Connection close 后 relock；明确哪些状态为重新 seed 的 demo fixture，哪些是同一进程状态，哪些有持久化证据。不得把 fresh container 等同实际 Android process restart。
2. 覆盖 Match loading/error 的 Home 摘要与下一步：UNKNOWN/不可用应保持 fail-closed，不宣称有提案或授权。覆盖 Connection non-active 时 Conversation 不可见且 Home 返回连接方向。
3. 在 Android synthetic demo 上做一次有界进程退出与冷启动观察，记录退出前状态、重启后状态及 Home 文案/动作。观察不到时写 UNKNOWN，不能从单元测试推断设备恢复。
4. 证据准确区分 PASS、FAIL、未运行；说明 APK/source 身份、命令次数、设备、截图或日志是否实际保留。结果只给出行为基线及缺口，不宣布 persistence/recovery 已完成。

## Required tests / evidence

优先运行新增 targeted Flutter test 与必要的既有 APP-INT-05 测试；每条命令最多初次加一次针对失败的修正重跑。Android 优先使用能核对与当前集成 blob 相同的现有 debug host；若必须重建，最多一次 locked-dependency build/assemble，不刷新依赖。Android 运行最多一次完整重启观察。保存简短执行回执，不重复全套旧 Builder 检查。

## Stop conditions / forbidden expansion / review

发现现有状态或数据跨重启保留的语义不明、需要决定 consent/消息/Connection 的持久化或清除政策、需要触及真实 auth/session、生产 API/DB、隐私用途、Safety、release 或新 writer 时停止实现并报告具体决策点；不得自行填补产品语义。工具链预算耗尽也停止受影响验证。不能借此修改候选原 SHA 或重审已接受 APP-INT-05。

交付一个结果和证据目录，由 Work 轻量实质审查。若只得到部分证据，按实际范围验收或拒绝，不扩大成生产/内测结论。没有 Owner 决策项且通过门后，Work 按 `AGENTS.md` 自动下达下一张任务单。
