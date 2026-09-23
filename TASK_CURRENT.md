# EliteSync v10｜下一张本地任务

**Task ID**：APP-INT-05-LOCAL-REVIEW

**Risk Level**：LEVEL 1

**Status**：预备；本次工作流迁移不执行此任务。任务完成后由 Work 更新本页，Codex 只按当前明确授权的任务执行。

## APP-INT-05 本地候选审查（LEVEL 1）

- **Goal**：对本地候选 `060f9a6499f56a434e6ae4598435d49026ec683a` 的 Home live-state 主循环做轻量但实质的非作者审查，给出 ACCEPT/REJECT；作者自述的 PASS 不是接受。
- **Why now**：APP-INT-01～04 已接受；APP-INT-05 已有实现与 Android 作者回执，却尚未通过独立本地审查。先关闭此门，再决定是否进入持久化/恢复工程。
- **Scope**：以 parent `77ab03389c3cce6dc7498d8a76f1873bdcfc44fd` 为基线，检查固定候选 diff、`docs/architecture/ELITESYNC_V10_APP_INT_05_HOME_LIVE_STATE_MAIN_LOOP_INTEGRATION_RESULT_V0_1.md`、相关现有 provider/contract 与测试回执。先核验候选仍在本地、main 及工作区冲突情况。
- **Files/components**：候选列出的 8 个变更路径；只读审查。无产品源码写权限。若接受，原样本地集成需在该审查结论里另行明确操作条件与冲突检查。
- **Acceptance criteria**：Home 仅读取既有状态；synthetic flag 默认为 false；dev 演示明确标记；唯一主按钮按 Readiness/Match/Connection/Conversation 状态导航；Connection 关闭后 CV_LOCKED；不新增领域 authority/真实网络行为。区分 analyze 的 0 errors 与 lint 导致的非零退出；确认 Android 回执与候选内容一致。
- **Tests/evidence**：优先审阅既有 targeted Flutter、Gradle、模拟器交互和 PID 日志回执；本任务无新的工具链执行预算。若发现证据不足，报告缺口，不将未重跑表述为本轮测试通过。
- **Required evidence**：记录候选对象/parent/tree、8 路径 diff 与 accepted contracts 对照、作者回执的可核实范围、静态审查发现和明确 ACCEPT/REJECT。必要时补最小只读事实；不能以旧回执冒充本轮实测。
- **Review requirement**：非作者 Work 独立审查；候选 `COMPLETE` 标签与作者测试不能代替接受。接受时另核验本地 main 集成条件、冲突与未追踪文件保护，并由 Work 更新 `CURRENT.md`。
- **Stop conditions**：候选不存在、对象不匹配、diff 超出原任务范围、语义或证据不充分、main/工作区冲突不明时停止接受；只给出具体问题。接受不自动开始后继产品任务。
- **Forbidden expansion**：不修改候选后接受旧 SHA；不推送 GitHub；不访问真实/私密数据；不启动生产 API、WebSocket、RTC、DB 或发布；不把 synthetic 证明升级为 release claim。

本页是工作流迁移形成的下一安全任务描述，不追认候选，也不覆盖其原精确任务的已耗预算。
