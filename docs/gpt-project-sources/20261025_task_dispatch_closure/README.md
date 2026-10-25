# EliteSync-v10 Project Source Increment｜2026-10-25

用途：将Owner批准的A-D任务下达闭环同步进EliteSync GitHub治理文档、项目长期记忆导航和可手动上传的项目源增量包。

## 权威来源

- [Task Dispatch Closure Protocol](../../workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)
- [Current Workflow](../../workflow/CURRENT_WORKFLOW.md)
- [AGENTS.md](../../../AGENTS.md)
- [Memory Navigation](../../memory/navigation.md)
- [ACTIVE_STATE](../../workflow/ACTIVE_STATE.md)
- [Project Source Index](../PROJECT_SOURCE_INDEX_ELITESYNC_V10.md)

## 固定规则摘要

1. A：核对Owner明确授权、原任务、ACTIVE_STATE、live main/Root、候选HEAD、禁止事项与预算。授权明确就直接执行；只有不明确才提问。
2. B：创建唯一正式任务文件，取得Blob SHA并按路径读回全文，核对正文、范围、预算和停止条件。
3. C：更新ACTIVE_STATE，重新读取live main、Root、任务Blob/正文与状态Blob；需要时核验产品Tree。任何步骤失败都明确报告部分完成。
4. D：同一条回复交付任务链接、Blob SHA、最终回读状态、停止门禁及单一可复制Markdown启动Prompt代码框。
5. Owner手动派发Codex。发布不等于派发或执行；Prompt不扩大正式任务授权。任何后续Gate仍按单独Owner授权执行。
6. Project Sources附件不自动随GitHub更新。此ZIP仅为增量更新，需Owner手动上传。

## ZIP范围

此增量包仅含本次治理协议、工作流、记忆规则、启动指导和状态快照；不包含产品源码、原始运行日志、LOCAL_ONLY目录、凭据、控制文件或整个仓库。历史项目源不被覆盖。

生成ZIP后应在交付时附文件清单、SHA-256、GitHub最终main/Root与Blob身份。