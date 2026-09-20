# EliteSync v10｜计划文档优化变更说明｜2026-09-21｜v0.1

状态：`AUTHOR COMPLETE — PROPOSED — FRESH INDEPENDENT ACCEPT/REJECT REQUIRED`。
仓库：`zcx369658780/EliteSync-v10`。
冻结 author base：`67b14d97732fe831e4ac9321373a8a0a6f7d22f9`。

## 1. Owner 本轮授权与终点

Owner：“可以，请你开始 全面优化项目计划路线图等文档，如果需要更改项目源文档也可以给我压缩包我手动上传，完成后请给我一个codex同步命令”。

范围解释：完成项目计划/路线/协作/入口的文档优化，提供项目源更新与可执行的独立验收/同步入口。不是仅给建议，也不是 R17 修复、R18、代码或新产品决定的授权。

ChatGPT 为本候选作者，不接受自己的修改。交给非候选作者 Codex 一次独立审查；通过才原样集成，随后仅执行精确文档同步。无需再增加形式性的第三方接受预审。产品工程保持暂停。

## 2. 为什么需要改

| 具体证据 | 问题 | 本包改变 |
|---|---|---|
| 旧 CURRENT_CONTEXT blob e22cc69... | 仍把 9/10 Sandbox 阻塞作为全项目当前入口 | 刷新分层进度、活动边界和独立 lane；历史原文留在精确 base |
| 原 roadmap blob 20863c... | next action 仍为 APP-T01 | 保留旧产品路线原文，新增当前交付计划，不重置历史任务 |
| APP-T12 main result 4c00def... | 客户端契约/界面已有报告但运行/authority gap 仍在 | 区分契约、synthetic、客户端运行与生产四类出口 |
| R17 rejection 415ee64... | F1 组合反例、F2 缺 retained source | 反例前移；固定继承清单；不重新接受 R17 |
| 旧协作条款 | 已有“无增量不重审”原则，但 task 粒度与预算不统一 | 同一边界完整交付、一次独立审查、未来 task 明确验证预算 |
| 项目源 01/03/04/05 | 固定 9/12 main、FIRST 和 APP-T01 next action 已过期 | 提供稳定导航摘要包；未来 main 实时核验 |

## 3. 精确候选写集合

仅六个 UTF-8 Markdown 文件，无代码/测试/构建配置变化：

1. 修改 `AGENTS.md`。
2. 修改 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`。
3. 新增 `docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md`。
4. 新增 `docs/architecture/ELITESYNC_V10_DELIVERY_WORKFLOW_AND_TASK_CONTRACT_V0_1.md`。
5. 新增 `docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md`。
6. 新增本文件 `docs/architecture/ELITESYNC_V10_PLANNING_OPTIMIZATION_CHANGELOG_2026_09_21_V0_1.md`。

原 2026-09-12 roadmap、feature design、Owner acceptance、全部既有 ADR/task/result/acceptance/rejection/handoff 均不修改。accepted 原文不移动、不删除、不改署名。

本包候选 sole parent 必须为上述 frozen base。candidate/tree/逐文件 blob 由不可变发布回执与后续独立审查任务固定，不把自引用 commit hash 填进正文形成循环。

## 4. 关键优化与适用范围

- 当前状态单点维护，历史证据保留；不把日期或 main 归属单独当接受。
- 当前路线覆盖原 15-domain，围绕已存在基础的下一增量，不以 task 数衡量进度。
- WIP 与并行仅为未来计划；无可用执行者/精确任务不假称在并行工作。
- 实现、目标回归、结果可在同一已批准边界交付；不静默合并产品政策与实现。
- 离线 synthetic 测试“初次 + 至多两次修正后复验”是未来 task authoring 建议，不改任何已冻结 one-shot 或启动本轮测试。
- frozen execution base 与 current integration main 分开，例外必须由各 task 明确授权，不把 R17 特例推广成自动追随。
- 本地同步优先使用全新独立文档目录；现有工作区有歧义不覆盖，不宣称全仓 clean。

## 5. 没有作出的改变

没有选择 R17-F1 conflict policy；没有改 evaluator/reasons/payload；没有写 R18；没有实现 Product Connection family/adapter/HTTP；没有启动 Messaging、客户端运行、构建恢复、生产或真实数据。

仍保持 IP-13F unchanged/non-participating，Match/Connection/Conversation/Relationship 分离，Binding Model A，8/19 reasons、6 structural diagnostics、R16-R1 cross-field/terminal/invalidation，所有 non-authority 边界。

不关闭 auth/session/token、eligibility/identity assurance、expiry、Conversation rights、PUI/D02、U-12/U-14/TP、M1/M2/M3/DEP13/B12、LC-03/LC-04/Phase36、Safety/legal/no-processing 未决事项。

未执行 Composer、PHPUnit、Artisan、HTTP/server、数据库、Flutter/Dart/Gradle/Android、依赖安装/下载或环境 probe。未访问旧仓库、README、FD02、真实/私密数据或本地受保护工作区。只能确认本次工具执行，不替作者历史报告证明全部命令历史。

## 6. 独立审查关注点

1. 候选相对 frozen base 恰好六条文档变更；既有 accepted artifacts 完全不变。
2. 原 AGENTS/current context 的保护边界被保留，阶段用语只纠正范围，不产生一般实现许可。
3. 当前状态明确 R17 REJECTED，未用 handoff 的 IN FLIGHT 复活旧任务。
4. 15-domain/MVP/Phase2/Later 范围没有削减或扩张；APP-T12 报告与 runtime evidence 分开。
5. retained R16 ref/blob/章节完整，索引没有把 rejected 全稿变成 accepted。
6. 验证预算、并行和 frozen-base 例外只影响未来明确任务，不绕过当前权限。
7. 项目源只有导航/产品摘要，不替代 exact source；同步 task 不覆盖用户修改。

## 7. 项目源更新约定

外部压缩包用于替换既有 01～05 五份项目源摘要，并提供上传说明。旧 Owner Review Draft 不再作为当前状态入口；产品权威正文和 Owner acceptance 位于 GitHub，不改写/删除仓库历史草稿。

包可以在候选审查前上传作为导航，但须明确新规则/路线只有独立接受且在 main 后生效。包不命令回退任何 main，也不自动授权读取全部索引或任何代码。

## 8. 发布终点

作者完成内容/来源/范围自检后发布 immutable candidate 与独立验收/同步 task。reviewer ACCEPT 才可集成；REJECT 只记录具体缺陷并停止。当前对外描述应为“优化稿已完成并发布，待独立验收生效”，不得写成“作者已接受”。
