# Project Memory Addendum｜2026-10-25

这是EliteSync-v10项目长期记忆增量，不替代实时ACTIVE_STATE。

- Owner是最终产品方向和不可逆决策authority。
- Astra负责Product Advisor、Planner、Independent Reviewer、Orchestrator、Current-state Manager。
- Codex只执行Owner手动派发的正式任务；Astra发布任务和启动Prompt不代表已派发或执行。
- 每次正式任务下达执行A-D闭环：授权冻结 → 创建唯一任务并读回Blob/正文 → 更新ACTIVE_STATE并回读main/Root/任务/状态 → 同一条回复交付链接、Blob、状态、停止门禁和单一启动Prompt代码框。
- 创建、读回、状态更新或最终核验任何一步失败，必须明确报告部分完成，不静默结束，不盲目重复创建任务。
- 启动Prompt为单一可复制Markdown代码框，无开始/结束包装标记，不嵌套代码框；正式任务全文才是权威合同。
- GitHub文档、模型记忆和ChatGPT Project Sources附件不是自动同步的同一系统。Owner要求更新项目源时，生成带清单和SHA-256的日期化增量ZIP，明确需要Owner手动上传。
- 不自动启动Codex、不重置预算、不自动创建后继任务、不自动合并产品、不越级放行下一Gate。
- 以上规则前瞻生效，不追溯更改既有冻结任务的权限、预算、测试结果或接受结论。