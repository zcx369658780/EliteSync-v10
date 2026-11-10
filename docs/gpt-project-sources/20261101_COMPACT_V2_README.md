# Project Sources COMPACT_V2 镜像使用说明

日期：2026-11-01。
完整替换ZIP：`EliteSync_Project_Sources_20261101_COMPACT_V2.zip`
ZIP SHA256：`2c0b29d6744f623231640240d29596599b856479d935a97d4fbcef7ea7a45d8e`

[唯一包索引](20261101_COMPACT_V2/00_INDEX.md) → [SHA256 manifest](20261101_COMPACT_V2/SHA256_MANIFEST.json)。ZIP包含10份Markdown正文和1份manifest；manifest逐文件记录UTF-8字节数与SHA256。ZIP为完整替换包，不是增量包。

## 工作流变化

- 新会话只读AGENTS全文、ACTIVE_STATE最新CURRENT ENTRY、最新具名handoff。
- 目标确定后才读取正式任务、当前冻结plan和真正相关的专项合同。
- Session Handoff采用六字段模板，目标300–600字；Codex任务单采用八字段；启动Prompt目标100–200字。
- 保留A–D任务发布闭环、Owner手动派发、一次集中独立验收和所有安全/预算边界。

## 替换与同步边界

Owner需手动用ZIP内全部文件替换现有Project Sources，不要叠加旧附件。生成ZIP不代表Project附件已替换；本说明也不代表账户Memory已更新。GitHub、Project附件和账户Memory分别记账。

本次只涉及治理文档和项目源快照，不涉及产品代码、运行库、Gradle、ADB、设备、供应商或费用。
