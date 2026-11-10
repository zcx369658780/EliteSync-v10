# APP-INT-05｜本地独立审查与集成

Verdict: **ACCEPT — synthetic Home live-state main loop only**

候选 `060f9a6499f56a434e6ae4598435d49026ec683a`；parent `77ab03389c3cce6dc7498d8a76f1873bdcfc44fd`；tree `12c3270116b8d070554dc1221a29d74500599f11`。本地 `main` 集成提交 `03ee72e1abe4e617abc45e9498ec1711ffee9ac9`。审查者审查固定候选；作者的 `COMPLETE` 与测试回执不单独构成接受。

## 审查结果

- 差异恰好八个原任务授权路径，无 bounded repair、依赖或产品外代码变更；固定输入 `app_env.dart`、`home_page.dart`、`calm_home_projection.dart`、`pubspec.lock` 的基线 blob 与原任务一致。
- `useSyntheticHomeProjection` 默认 false，仅 `main_demo.dart` 显式开启；非 dev/关闭时 provider 直接返回原 `CalmHomeProjection.current`，不订阅 synthetic 状态。
- 开启后仅读取现有 navigation、canonical Match、Connection 与 Conversation provider；Home 只导航，不写生命周期。四个摘要显式标为 Synthetic；Match loading/error 作为 UNKNOWN 显示，不伪造提案。
- 唯一主动作按 Readiness → Match → Connection → Messaging consent → Messages 优先选择。Connection 关闭时既有 Conversation provider 清除本地同意并重锁，Home 返回 Connection 动作。新测试覆盖主要状态链；测试未独立覆盖 Match loading/error，但静态分支是 fail-closed。
- 作者结果报告 locked pub get、17 项 targeted tests、Android debug assemble/install/cold launch 与完整主循环 PASS；analyze 最终 0 compile errors，但 18 条既有 warning/info 导致退出码 1。Android 报告的生产 API、真实 WebSocket、RTC、crash 观察均为 0。审查未重跑工具链或独立查看未入库的截图/日志；因此 Android 结论明确依赖作者的有限回执。
- 集成前主线这八个目标路径均未变，工作区仅有无关 untracked 目录；本地 cherry-pick 无冲突。集成后八个路径与候选 blob 完全相同，`git diff --check` 通过；无关目录保留。

## 边界

接受范围限于 Android synthetic/dev Home 投影与作者所报告的运行证明。不建立真实身份、后端 writer、生产 Match/Connection/Conversation 权限、真实数据、发布链或持久化恢复能力。下一任务须先核验重启和 stale/unknown 的真实行为，再定义任何新保存语义；不得把本接受扩展为 release ready。
