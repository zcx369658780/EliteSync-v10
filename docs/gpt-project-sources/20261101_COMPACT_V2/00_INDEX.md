# EliteSync Project Sources｜2026-11-01 Compact V2

本ZIP是完整替换包，不是增量包。请用ZIP内全部文件替换旧Project Sources，不要与旧18份材料或COMPACT_V1叠加。

## 新会话启动：只读三个入口

1. `AGENTS.md`：读取全文，了解当前启动规则与不可变边界。
2. `docs/workflow/ACTIVE_STATE.md`：只读最新CURRENT ENTRY，不向下展开历史。
3. 最新具名Session Handoff：只读当前有效的一份，不递归读取旧handoff。

完成以上三项后停止首读。**不要按01—09顺序全文加载本包。** 项目源是按需参考库，不是每次会话的阅读清单。

## 按需读取

- `01_CURRENT_STATE.md`：非实时项目快照；与live ACTIVE_STATE冲突时以live为准。
- `02_GOVERNANCE.md`：产品治理、角色与不可变边界。
- `03_OWNER_DECISIONS.md`：产品决定摘要；遇到重大方向决策时再读GitHub原件。
- `04_ROADMAP.md`：路线规划，不代表当前任务或完成状态。
- `05_DESIGN_REFERENCE.md`：只有涉及APP结构/体验设计时读取原始设计和接受记录。
- `06_RESEARCH.md`：只有研究或竞品问题相关时读取。
- `07_HANDOFF_RULES.md`：交接、任务单与Prompt精简规则。
- `08_ARCHIVE_MAP.md`：需要追溯历史原件时读取。
- `09_CODEX_SYNC_INSTRUCTION.md`：只有Owner另行手动派发文档同步任务时才使用；本文件本身不授予执行权限。

仓库：`zcx369658780/EliteSync-v10`
实时状态：`docs/workflow/ACTIVE_STATE.md`
现行规则：`AGENTS.md`、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`、`docs/workflow/PROJECT_SOURCE_COMPACTION_POLICY.md`。
本包是快照；每次开工必须fresh读取GitHub。历史原件仍在GitHub，省略不代表删除。
