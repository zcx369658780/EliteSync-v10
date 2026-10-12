---
title: navigation
type: note
permalink: elitesync-v10-local/navigation
---

## 2026-10-12 迁移补充（当前生效）
当前管理/执行方式由 [新工作流](../workflow/CURRENT_WORKFLOW.md) 和 [动态总目录](../../DOC_INDEX_CURRENT.md) 指定：网页Astra规划/最终独立验收/复盘，Codex自主实现，Owner方向决定。下方涉及旧Work/单次预算/新Work指定的描述是原归档时点知识，不是当前流程门；科学产品语义、历史接受/拒绝及旧预算冻结仍保留。当前状态见 [CURRENT_STATE](../../CURRENT_STATE.md)。
原始session、EVIDENCE原始证据和本地检索数据库均LOCAL_ONLY；以下本机位置仅供Owner/本地Codex准确定位，网页正文已提供安全摘要，不能假定原件已发布或可直接访问。已有被发布正式文档可按总目录寻找；未发布原证请Owner脱敏提供，不建立指回本地路径的网页访问链。


# EliteSync-v10 记忆导航
核验日期：2026-10-12（Asia/Shanghai）。这是知识入口，不是任务授权或路线图。

## 先读什么
- 当前权威：先读 DOC_INDEX_CURRENT.md、docs/workflow/CURRENT_WORKFLOW.md、CURRENT_STATE.md 和根入口的 2026-10-12 生效段。旧 V212/ISSUED/持续授权是历史状态，不能单独作为当前任务授权；旧任务继续暂停，第三阶段由 Owner 手动启动。
- [主题知识](knowledge.md)：项目重置、领域边界、现行暂停、历史失败与待确认事项；正文已有正式文档时只指向原文。
- [环境记录](environment.md)：区分当前只读检测、历史观测、项目配置与未核验项。
- [本次归档说明](archive-20261012.md)：覆盖来源、缺口、检索实测及本轮变更。
- 既有正式目录：../architecture/README.md、../archive/README.md、../ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md。

## 身份与历史范围
实时根 D:/EliteSync-v10；本轮本地 main，HEAD 4bebc8f394248e254c1368a06fbdee5d2c883301。
Git remote 为 zcx369658780/EliteSync-v10；本轮未 fetch，不能把本地 HEAD 说成当前远端 HEAD。
Git worktree 注册证明同仓库工作树关联；本轮未读取这些树的代码、不切换、不清理 prunable 项。正式 T03 记录也具名绑定 D:/EliteSync-v10-next-t03-20260913。
旧 D:/EliteSync 是 9.x 历史资产来源，不是重置版权威；仅具名 Gradle 复用材料已在 v10 内恢复，未扫描旧仓库。
Work 01a12667-4f4c-7bc2-adfb-dfa5277c36b7/local 的原始 session_meta.cwd 位于 USERPROFILE/.codex/.chatgpt-projects/g-p-6a894f70a9d081919fe97e22388a1fe1；V4 handoff 明确该 Work 的实时仓库为本项目、镜像 sources 只读。不能由镜像路径推定未来会话已激活。
本 Builder 为 01a12b4c-43b8-73a0-bcec-2675f5b21a2d/local，元数据 cwd 与本仓库相符；旧 Builder 已退休。新 Work 尚未指定。
不纳入 HANK、Zotero、DeepLearning-HANK 或名称相似但归属未证的会话。

## 已验证的检索路由
Basic Memory 0.23.2：项目 elitesync-v10-local，mode=local，正文目录就是 D:/EliteSync-v10/docs/memory。先设置进程级 BASIC_MEMORY_CONFIG_DIR=D:/EliteSync-v10/.local-memory-state/basic-memory；每次显式 --project elitesync-v10-local --local。该独立配置和数据库只属本项目，共享 default_project 保持 main。
使用进程级 BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false 避免语义初始化；只用关键词工具，不下载模型。
例：basic-memory tool search-notes "Gradle" --project elitesync-v10-local --local --json
例：basic-memory tool read-note archive-20261012 --project elitesync-v10-local --local --plain
本轮独立Basic Memory库只成功登记归档说明；三个既有正文未被普通工具自动导入，overwrite有路径冲突，未修数据库。完整正文检索使用QMD；不能声称Basic Memory已索引全部知识。
QMD 2.8.3：本项目独立 named index elitesync-v10-memory、collection elitesync-v10-memory，只索引此正文目录；显式 --index 和 -c，不使用共享默认 index。
例：qmd --index elitesync-v10-memory search "Gradle" -c elitesync-v10-memory -n 3
例：qmd --index elitesync-v10-memory get qmd://elitesync-v10-memory/environment.md
recall 0.4.1 Skill 已检查，但 USERPROFILE/.recall.db 与旧 .claude/recall.db 不存在。其 CLI 首次调用会扫描全部四源，不适用于本轮隔离范围；本轮用已定位原始 JSONL 降级，没有建立 recall 索引。
代码图谱已有 D-EliteSync-v10；仅本项目查询。索引无命中不能证明源码不存在。

## 证据与冲突处理
每条知识带性质、适用版本、状态、来源和核验时间。旧记录只作证据；正式后续决定可替代旧决定，助手自报不等于 Owner 批准或当前测试通过。
README 的 bootstrap 表述仍在，但当前已有实现/合成证据；用 CURRENT 和阶段接受文件核具体进度，不由 README 推定尚无实现。
Gradle 的 dq61... 与 c2q... 是不同用途的具名分发，不能擅自互换。Android Studio 当前路径/版本仍待定位。
缺证据时读指定原文及已经证实归属的历史；不复活预算、不更改冻结计划、不恢复自动化。
