# Local-first 治理分类与核对索引

日期：2026-11-01。依据 Owner 已确认执行的“Local-first 后续 GitHub 治理整合”附件，第二阶段仅做定点治理文档、索引和旧流程标识。现行角色只定义于 [AGENTS](../../AGENTS.md)、[CURRENT_WORKFLOW](CURRENT_WORKFLOW.md)，本文件不另造审批流程。

## 范围与身份

开工治理分支 `governance/codex-local-first-20261101`，HEAD `7cf3f3124fbd38e8609d9a64487908593d5e994f`；fresh main `8a9e97a1e9414b65d669e07f3188b81764196027`。公开仓库，分支原 ahead 1 / behind 0。本轮仅在已有干净专用治理工作树追加提交，不更改原活动目录文件、分支、HEAD、index 或既有 worktrees。

前轮 Local-first 已在原活动目录生效；本轮导航、历史标记和技能修订仅落在治理工作树，未覆盖原目录的 dirty/untracked。GitHub 治理分支和 main 不同；原本地产品基线也不同，不能混用其当前状态。分支最终身份以真实 commit 和本地回执为准。

## 定点分类

| 入口 | 分类 | 处理及理由 |
|---|---|---|
| AGENTS / CURRENT_WORKFLOW | CURRENT_RULE | 保持 Owner 决策、Codex 自治、网页咨询；仅更新阶段说明和本索引 |
| ACTIVE_STATE 顶部块 | CURRENT_RULE | 唯一短状态入口；原当前块与更早历史全部保留为原字节后缀 |
| Owner 接管决定 | CURRENT_RULE | 追加第二阶段直接授权，不倒改第一阶段决定 |
| README | CURRENT_RULE | 已采用 Local-first，无需重复修订 |
| DOC_INDEX / memory/navigation | DUPLICATE_NAVIGATION | 去掉必读旧 handoff、正式任务前置和远端强制首读，改为有效入口指针 |
| CURRENT_STATE / CURRENT / TASK_CURRENT | HISTORICAL_REFERENCE | 历史状态不是并列当前权威；仅加明确首部标记 |
| DEVELOPMENT_RULES / REVIEW_GATE | SUPERSEDED_WORKFLOW + CURRENT_RULE | 旧网页/Work 角色不再生效；原技术、安全、证据和权限仍保留 |
| TASK_DISPATCH_CLOSURE_PROTOCOL | SUPERSEDED_WORKFLOW + CURRENT_RULE | A–D 与网页派单/终验非前置；原授权、冻结标准与特殊预算继续有效 |
| SESSION_HANDOFF_TEMPLATE | HISTORICAL_REFERENCE | 可选简短参考，不是强制首读或审批表 |
| 两份 2026-11-01 旧 handoff | HISTORICAL_REFERENCE | 按形成时点保留，不再是“最新必读”或后继任务派发 |
| PROJECT_SOURCE_COMPACTION_POLICY | CURRENT_RULE + SUPERSEDED_WORKFLOW | 保留精简、安全、哈希和原文；旧远端唯一权威与发布流程已替代 |
| Sources 总索引 | DUPLICATE_NAVIGATION | 只索引历史集合，移除冲突 handoff 和默认加载规则 |
| COMPACT_V1/V2 外部 README | HISTORICAL_REFERENCE | 加快照适用性说明，不改 ZIP、日期化正文或 manifest |
| elitesync-local-workflow 技能源 | SUPERSEDED_WORKFLOW → CURRENT_RULE | 技能已在本会话可用目录中具名列出；治理分支移除已证实冲突的网页角色和派单流程 |
| dirty-worktree / runtime-slice 技能 | CURRENT_RULE | 已定点核对其任务优先和保护边界，无网页终验冲突，不改文件 |
| 桌面会话是否重新加载技能正文 | UNKNOWN | 可用目录不等于已执行/已刷新；不修改 Desktop、插件或全局配置 |
| 未读取的旧任务、长日志、其它日期快照正文 | UNKNOWN（未审计内容）/ HISTORICAL_REFERENCE（导航定位） | 不做全仓扫描，不替它们裁定产品事实或证据有效性 |

## 检查与保留项

本轮只核对治理差异、链接、原字节后缀、公开内容、整个待推提交范围及原活动状态保护；这不是产品测试或外部独立验收。自己执行的核对记录为 Codex 工程自查。

apps/services 子 Tree 不变；产品测试、构建、数据库、设备、Gradle、ADB 和供应商操作均 NOT_RUN。v10.1.5 PARTIAL_NOT_ACCEPTED、AC05 OPEN、G2 false、真实 Push PENDING、STOP 资产及特殊预算不变。本轮不重新核定其余产品/运行状态。

原目录中的旧导航/技能原文因保护边界未被覆盖；它们受已生效的 Local-first AGENTS 与 Owner 决定约束。会话运行时技能重载 UNKNOWN，不能声称所有会话入口已物理替换。后续若需向原目录传播这些修订，应先针对现有 dirty 原文检查差异和保存恢复点。

未发现需要在当前导航新增替代目标的断链；本轮移除了失时的 handoff 指针，旧历史正文和镜像内部链接未逐一审计。未证明的历史链接或产品状态保持 UNKNOWN，不借治理整合改为 PASS。

只向该治理分支普通 fast-forward 推送，不创建 PR、不合 main、不重写历史。完成后 STOP，不自动传播到原 dirty 根、不开始产品开发或下一轮清理。
