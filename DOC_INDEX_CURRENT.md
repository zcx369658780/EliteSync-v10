# EliteSync-v10 当前首读导航

日期：2026-11-01。只提供最小启动入口，不递归加载历史。

1. [现行启动规则](AGENTS.md)：读取全文。
2. [ACTIVE_STATE最新CURRENT ENTRY](docs/workflow/ACTIVE_STATE.md)：只读当前首块，到分隔线停止。
3. [最新具名Session Handoff](docs/workflow/SESSION_HANDOFF_20261101_PROJECT_SOURCES_V2_SYNC_COMPLETE.md)：只读这一份。

完成三项后停止首读。只有目标明确后，才读取当前正式任务、冻结plan及该任务真正相关的专项合同；决策缺证据时再从GitHub定点补读。

- [当前工作流](docs/workflow/CURRENT_WORKFLOW.md)
- [任务发布协议](docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md)
- [Session Handoff模板](docs/workflow/SESSION_HANDOFF_TEMPLATE.md)
- [Project Sources瘦身规则](docs/workflow/PROJECT_SOURCE_COMPACTION_POLICY.md)
- [COMPACT_V2完整项目源索引](docs/gpt-project-sources/20261101_COMPACT_V2/00_INDEX.md)
- [COMPACT_V2镜像说明](docs/gpt-project-sources/20261101_COMPACT_V2_README.md)
- [历史原件封存索引](docs/gpt-project-sources/archive/20261031/ARCHIVE_MANIFEST.md)

Project Sources是快照与按需参考库，不覆盖live main。Owner已确认手动替换COMPACT_V2；Codex报告本地镜像完成（CODEX_REPORTED，Astra未直接读取本地回执）。GitHub、Project附件和账户Memory分别记账。
