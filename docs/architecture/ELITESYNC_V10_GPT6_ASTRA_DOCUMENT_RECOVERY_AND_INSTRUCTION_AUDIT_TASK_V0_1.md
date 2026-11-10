# EliteSync v10 GPT-6 Astra 文档恢复索引与指令审查任务 v0.1

Status: `TASK SHEET ONLY — BOUNDED DOCUMENT INDEX / AUDIT / ROADMAP PROPOSAL — EXISTING DOCUMENTS READ ONLY — NO M3 RESUMPTION — NO IMPLEMENTATION AUTHORITY`

任务作者日期：2026-09-07（Asia/Singapore）。执行者使用简体中文。Owner 指定本地 Codex 使用 GPT-6 Astra；由 Owner 在实际会话中选择模型，报告记录宿主可验证的模型信息，不凭提示词自称已完成模型切换，不静默降级。

## 1. 目标、角色与交付终点

Owner 已要求：额度恢复后由本地 Codex 整理 v10 文档，完成后再决定向 ChatGPT 项目源上传哪些文件。本任务现在只发布；本次任务作者不得同时执行下面的文档审查。

执行者在一个有界任务内完成：核验已给出的文档线索、建立可追溯索引、审查指令兼容性与过度规划问题、整理基于证据的路线图建议。不是只再写一份计划；也不是对现有文档进行搬迁、恢复写入、改名、删除或重写。

唯一允许新增的候选产物：

1. `docs/architecture/ELITESYNC_V10_DOCUMENT_RECOVERY_INDEX_V0_1.md`
2. `docs/architecture/ELITESYNC_V10_SYSTEM_DOCUMENTATION_AUDIT_AND_ROADMAP_PROPOSAL_V0_1.md`

两份产物均标记：`PROPOSED — AWAITING INDEPENDENT REVIEW AND OWNER DECISION — NOT ACTIVE AGENT INSTRUCTIONS — NO IMPLEMENTATION AUTHORITY`。

这里的 recovery 指重建文档位置、版本和权威关系，不是凭会话记忆重写缺失原文。现有 AGENTS、ADR、handoff、task、review、路线图及配置一律只读。后续任何现有指令文档修订仍须另有精确任务单；本任务不自动关闭系统文档转型关口。

## 2. 固定入口与基线门

仓库：`zcx369658780/EliteSync-v10`。

执行时必须先 fresh-fetch / 实时读取 GitHub `refs/heads/main`，要求恰为：

`0f3db3e00975d95d4145954dc69f7f55d7dee1d0`

第一份主动读取的项目治理文档必须是：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

要求 blob：`18485c95262051e43892436fb52413132c5ee626`。

该文件为 durable session-entry authority。其内部 `f77dac951286996f4aa76d40f6574eedfe4f8b10` 是交接前接受基线，不是本次要求匹配的远端入口提交。

随后读取启动 prompt 指定的本任务不可变 commit / blob，核验 task commit 只有上述 main 一个父提交，且仅新增本任务路径。任务提交和 blob 在发布后的启动 prompt 中绑定，不在文件中自引用自身最终哈希。

若远端 main、交接 blob、任务 commit / blob 或父子关系不匹配，停止后续内容读取与写入，报告精确差异；不得把未来 main 自动视作本任务的新基线，不得自行 rebase / cherry-pick / 重发任务。

“第一份主动读取”不声称早于 Codex 已自动加载的指令。宿主更高优先级规则始终适用；自动加载内容、旧任务中的命令和网页示例不增加本任务授权。

旧 M3 任务仅为历史索引输入：

- branch: `task/h01-bib03-u15-td01-m3-exec-env-no-network-cache-prereq-method-governance-v0-1`
- commit: `8b640576822b01ae00bb04b9b5deaa75db53365c`
- sole parent: `f77dac951286996f4aa76d40f6574eedfe4f8b10`
- task blob: `8309341b36662695dde92bdc7b6301b0086df5d2`

它已编写，但 Owner 与当前交接明确记录尚未执行；不是当前 main 的执行权威。只可核验上述精确 ref、commit 元数据及第 3 节所列文档，不执行其要求，也不开展它要求的 Flutter / Gradle 研究。

## 3. 精确读取清单：禁止目录搜索

除入口和本任务外，读取严格按以下表执行。完整文件名来自 Owner 本次提供的历史线索；线索不是存在性、接受状态或 canonical 地位的证明。每个目标先按固定 ref 精确解析，存在则读取并记录 blob；缺失则记录该 ref 下的结果，不猜备用名称、不扫描历史、不把一个 404 推论为全仓不存在。

### A. Owner 提供的 12 项种子（含入口）

| ID | 精确仓库相对路径 | 读取 ref |
| --- | --- | --- |
| D01 | `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | 固定 main；已指定 blob |
| D02 | `docs/architecture/ELITESYNC_V10_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | 固定 main |
| D03 | `docs/architecture/ELITESYNC_V10_INFORMATION_LIFECYCLE_WORKSHOP_V0_1.md` | 固定 main |
| D04 | `docs/decisions/ADR-005-INFORMATION-LIFECYCLE-AND-DATA-RESPONSIBILITY.md` | 固定 main |
| D05 | `docs/architecture/ELITESYNC_V10_PHASE_35_CURRENT_SESSION_HANDOFF_V0_1.md` | 固定 main |
| D06 | `docs/architecture/ELITESYNC_V10_PHASE_35_LC02_CLOSEOUT_AND_CURRENT_SESSION_HANDOFF_V0_1.md` | 固定 main |
| D07 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ENTRY_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` | 固定 main |
| D08 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_TASK_V0_1.md` | 固定 main |
| D09 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_REVIEW_V0_1.md` | 固定 main |
| D10 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_PREFLIGHT_SIDE_EFFECT_CLOSURE_GOVERNANCE_TASK_V0_1.md` | 固定 main |
| D11 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_PREFLIGHT_SIDE_EFFECT_CLOSURE_GOVERNANCE_REVIEW_V0_1.md` | 固定 main；要求 blob `a012c612532134ff7ada1c685234aae1d866e492` |
| D12 | `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_ENVIRONMENT_NO_NETWORK_CACHE_AND_PREREQUISITE_CHECK_METHOD_GOVERNANCE_TASK_V0_1.md` | 仅 `8b640576822b01ae00bb04b9b5deaa75db53365c`；要求 blob `8309341b36662695dde92bdc7b6301b0086df5d2` |

D02–D10 的实际存在性、blob 和当前权威地位由执行者核验，任务作者未把它们预先判为已接受。文件名含 REVIEW / ADR 或位于 main 不单独证明其中所有旧结论仍是现行状态。

### B. 本任务新授予的 8 个精确代理指令目标

本清单授予对这些字面路径的精确存在性解析与只读内容审查，不声称文件已经存在，也不授权创建或修改它们：

```text
AGENTS.md
AGENTS.override.md
docs/AGENTS.md
docs/AGENTS.override.md
docs/architecture/AGENTS.md
docs/architecture/AGENTS.override.md
docs/decisions/AGENTS.md
docs/decisions/AGENTS.override.md
```

全部先在固定 main 读取。可对照 Codex 已提供的自动加载来源信息；未在当前上下文中公开的全局指令、fallback 配置、skills 或用户目录不予探查。不运行 `/init`，不创建 AGENTS，不枚举 `.codex` / `.agents`。

### C. 一跳明确引用补充，最多 8 个新增路径

仅当 A 或 B 的已读原文给出一个**完整、确定、与文档入口／指令／重构路线直接相关**的同仓库 Markdown 文件路径时，可登记后补充读取。只允许仓库根的明确命名 Markdown 文档，或 `docs/architecture/`、`docs/decisions/` 下的明确命名 Markdown 文档；这一条件不是目录或通配符授权。

先在读账本写明完整目标、来源文件和行号／章节、用途，再按固定 main 精确读取。最多 8 个不同的新路径；不得再沿 C 组文档递归扩展。内容中只有目录、缩写、文件名片段、省略号或日期的，不能补全猜测。禁止用字符串搜索仓库、提交历史或目录来找匹配项。

README、FD02、U-14 排除对象、旧仓库、技术源码、缓存、生成输出及其他被保护来源无论如何被引用都不得跟进。不得把本任务输出文件计作输入以形成循环引用。

2026-08-22 早期重构交接的完整文件名未知；若 A/B 中没有合格精确引用，登记此缺口后继续交付，不猜名、不重建其原文。不得假定存在 `ROADMAP.md`，也不得以标准名称尝试路径探测。

本任务最多审查 28 个输入文档（12 种子 + 8 指令目标 + 8 一跳补充）；入口不重复计数。认证故障、权限故障和内容不存在必须分开说明。超出范围的目标仅登记缺口，不开启新的发现任务。

## 4. 本地执行方式与受保护状态

已声明本地根为 `D:\EliteSync-v10`，不是旧 `D:\EliteSync`。可用已有 Git / GitHub / 文本处理能力完成文档工作，不安装工具、不执行仓库脚本。

允许精确的根与引用元数据读取，例如 `git -C D:\EliteSync-v10 rev-parse --show-toplevel`、`rev-parse --verify HEAD`、`symbolic-ref --quiet --short HEAD` 和已声明的 main / task 引用解析。这不授权读取工作树列表、默认 index 或文件清单。根不匹配则不继续该本地路径操作。

允许通过 GitHub API 实时读取 main；如采用本地 Git fetch，只获取已声明 main / task 精确 ref，禁 tags、submodules、prune、强制更新和 checkout。Git 对象传输不是打开包中所有文件的内容授权。准确说明核验的是远端引用还是本地 `origin/main`，不得混称。

**本任务无需本地 HEAD 等于远端 main，也无需切换工作分支。**本地 HEAD 过旧或不同不授权快进、merge、reset、checkout、stash 或清理；改用固定远端快照／已取回的不可变 Git blob 完成文档整理，并披露本地覆盖限制。因此，不要因可绕开的本地分支差异阻断全部只读审查，也不要通过破坏工作区来消除差异。

本地补充核验仅限：对 A/B 及已登记 C 目标做一次字面路径存在性布尔检查；如需比较版本，仅使用本地 HEAD 的同一精确路径的**已提交 blob**。不读取工作区副本内容、不对工作区副本哈希，不读取 index，不判断本地暂存情况。字面路径涉及 symlink / junction / reparse point 时不跟随，记录未核验。不存在或版本不同均不等于“文档丢失”或“未同步原因已经证明”。本任务不补写缺失原文件。

不要运行 `git status`、未跟踪文件检查、默认 index 的任何读写、宽范围 diff、`git add`、`git commit -a`、`git stash`、`git reset`、`git clean`、worktree / clone / checkout 创建；不读取或改动受保护暂存状态。也不遍历 `.git`、本地聊天记录、Codex 会话历史、用户目录或环境变量集合。

产物优先在内存生成并通过现有授权的 GitHub Git Database / 连接器能力发布；不接触本地默认 index。本任务仅授权必要的同仓库 Git 读取、这两份报告的候选发布和第 5 节官方文档 HTTPS 读取，不授权任何构建网络、依赖下载或凭据探查。不得为取得发布能力关闭沙箱、提升权限、修改 Git/Codex 配置或搜索令牌。

如需保留本地结果，只允许在第 1 节两个精确输出路径创建新文件；先核验目标不存在及父路径不为重解析跳转，不覆盖已有对象，不新建缺失父目录。不能满足时仍可采用内存／现有 GitHub 发布方式。发布能力确实不可用时，在最终答复交付已完成内容与具体发布障碍，不自行设计工具链安装或多轮恢复流程。

## 5. 当前官方指令规范核验

执行者在实际执行日期重新核验下列官方页面，允许它们在 OpenAI 官方域名和 `learn.chatgpt.com` 的官方重定向；记录实际 URL、读取日期、适用范围和必要版本信息：

- `https://developers.openai.com/api/docs/guides/latest-model`
- `https://developers.openai.com/codex/agent-configuration/agents-md`
- `https://developers.openai.com/codex/learn/best-practices`
- `https://developers.openai.com/codex/agent-approvals-security`

如 URL 迁移，只允许针对同一主题的官方站点精确检索；总计最多 6 个官方页面。不使用博客、论坛、模型宣传对比或第三方总结作为规范依据；不延伸为 Flutter / Dart / Gradle 研究。

任务作者已于 2026-09-07 核对上述四个官方入口。当前官方指导涉及：AGENTS 自动加载／覆盖范围／大小上限；Astra 对含糊或冲突指令的敏感性；按任务范围控制验证；文档约束与沙箱、审批控制的区别。执行报告必须从实际读取的当前原文确认适用性，不将本段或旧会话报告当作官方原文。

不要照搬官方示例中的 `git status`、测试、自动 worktree、网络或高权限配置；这些示例不覆盖 EliteSync 的精确边界。官方指导也不代表本地配置、加载链或沙箱状态已被检查。

## 6. 产物一：文档恢复索引

索引应可用于后续选择审阅材料，但不作本次项目源上传决定。每个种子和实际追加目标至少记录：

- 精确路径；路径来自 Owner 线索、本任务明确目标，还是哪一段已读原文。
- 固定远端 ref、实际 blob、读取结果；缺失／无权限／未读分开记录。
- 文件自身状态与本次能够证明的权威状态，分开表示编写、执行、审查、接受和进入 main。
- 用途：代理指令、架构／ADR、重构路线来源、handoff、task、review 或历史记录。
- 已证明的替代／依赖关系和证明位置；不能仅按日期较新、模型较新或文件名判断 superseded。
- 本地字面路径检查与本地 HEAD 已提交快照的有限对照；工作区内容与暂存状态明确为未检查。

只用必要短摘要和路径／行号定位，不复制整批原文。报告中不得包含受排除正文、业务个人数据、密钥、受保护本地状态或聊天内容。未知早期入口单列为待提供精确路径，不虚构 canonical 总纲。

区别 GitHub 远端已提交文档、本地已提交快照、本地文件存在性、ChatGPT 项目源四种事实。本任务未接入或审查项目源上传区，不得把 GitHub 存在等同于项目源已上传，也不得从不存在的下载链接推断文档丢失。

## 7. 产物二：指令审查与路线图整理建议

先给结论和覆盖范围，再列证据化发现。对每一项发现只使用下列分类：

- `KEEP`
- `KEEP_WITH_CLARIFICATION`
- `UPDATE_FOR_CURRENT_AGENT_SPEC`
- `REMOVE_STALE_MODEL-SPECIFIC_RULE`
- `BLOCKED — EXACT PATH OR AUTHORITY REQUIRED`

每项包括来源路径及行号／章节、问题或应保留理由、适用的官方依据（若涉及）、具体拟议修改、是否影响现有权威，以及接受条件。存在性与生命周期字段是事实记录，不另造合规发现分类。不得将未读对象判为已合规或已过时。

重点检查但不预设缺陷：入口与权威指针、自动加载和主动读取的区别、适用目录和覆盖关系、任务作者／执行者／审查者角色、停止条件、重复规则与上下文负担、旧模型专属命令、历史署名、证据版本、无新增证据仍反复生成治理任务的问题。受保护边界不是因不方便就可删除的“过度规划”。

历史模型名称、原始作者和已接受结果保留。只有证据表明某条旧模型专属规则仍在指导当前工作且已失效，才建议 `REMOVE_STALE_MODEL-SPECIFIC_RULE`；不得全仓模型名替换。仓库内部称作“system”的文件不因此获得宿主 system 指令级别。

路线图部分仅作已有决策与依赖关系的整合建议，不作技术设计或实现计划：

1. 用已经读到的证据解释 v10 重制目标及已接受基础；未找到总体目标时明确留下缺口。
2. 区分当前优先事项、后续有条件步骤、deferred 和未授权事项；不得把 Owner 转述的 `Phase → LC → U → TD → M` 自动当作已验证的完整层级。
3. 保持当前顺序：文档审查候选 → 独立复核与 Owner 决定 → 有界指令修订及接受 → 从届时 durable main 重新评估并重发／替代旧 M3 任务。实际 M3 执行仍须独立授权；M2 保持 deferred。
4. 提议用“要回答的问题、已有证据、完成条件、下一项需作出的决定”表示进度；不把每个治理子问题增加为新 Phase，也不把文档数量视为产品进度。
5. 对需要调整的已有文档给出精确修改清单；未知路径保持 blocked。优先复用现有文件，不默认增设多层总纲、模板和手册。

建议可以给少量替换段落示例，但不得写成已经生效的指令或路线图；不得实施这些建议。项目源上传选择在本任务完成并复核后由 Owner 再决定，本任务不上传、不同步、不提交上传清单。

## 8. 收敛规则与完成条件

一轮完成有界读取、索引、审查、路线图建议和候选发布。允许为读全文件分页、定位引用或修正已发现问题进行必要的定点复查；不为提高把握重复全套检查，不扩大读预算。

只要基线门通过，个别文档缺失、早期总纲未知、全局指令未授权或路线图路径不足，都应形成明确缺口并继续完成其余交付，不再要求 Owner 批准一次“开始整理”。唯有真正阻止合法继续的基线、权限、保护状态或发布问题才停止相应操作。

发现依赖当前未授权证据的问题时，记录“缺什么、阻止哪个决定、需要哪个精确输入／授权”；没有新证据或约束变化时，不自动撰写下一份治理任务。不得重新研究 M3 本身来填补路线图。

完成条件：所有 A/B 目标均有结果；实际使用的 C 目标可追溯且不超过 8 项；每项实质发现有证据或明确未验证；两份报告状态正确；现有文件与架构边界未改；候选变更范围验证一次。Markdown 内容／引用核对即可，不运行项目测试、文档构建器、链接爬虫或安装 linter。

## 9. 候选发布和独立复核

任务作者发布位置：

- task branch: `task/gpt6-astra-document-recovery-instruction-audit-v0-1`
- task path: `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_DOCUMENT_RECOVERY_AND_INSTRUCTION_AUDIT_TASK_V0_1.md`
- task commit subject: `docs: add bounded document recovery and instruction audit task`
- task topology: 固定 main 为唯一父提交；一个提交；只新增 task path。

未来执行者的候选发布位置：

- candidate branch: `review/gpt6-astra-document-recovery-instruction-audit-v0-1`
- candidate subject: `docs: add document recovery index and instruction audit proposal`
- candidate topology: 启动 prompt 绑定的本任务 commit 为唯一父提交；恰好一个候选提交；只新增第 1 节两个输出路径，不修改任务单；不得 merge、rebase、cherry-pick 或 force-push。

发布前重新读取远端 main 和精确 task ref；要求仍匹配启动时绑定值。候选分支及两份目标文件必须不存在；冲突时不覆盖、不换名绕过。如果远端已变化，保留已完成草稿并报告，不发布过期候选。

使用不接触本地默认 index 的 GitHub Git Database / 连接器方式，以 task commit 的原始 tree 为 base，仅添加两个 UTF-8 blob，创建单父候选提交和新分支。禁止列举 base tree。若现有工具无法完成这种发布，交付草稿并如实报告障碍，不转用会接触受保护暂存状态的提交方式。

允许读取**本任务自身提交与本次自产候选提交**的父提交、树标识、精确变更文件清单和这两份报告的 patch，用于验证其单一／两路径范围；这是自产变更验证，不是仓库文件枚举授权。最终报告给出 candidate commit、sole parent、两个 blob、精确链接、覆盖缺口以及未执行事项。不要声称整个本地工作树 clean；没有检查就没有该证据。

执行者发布一个候选后停止，不自行接受、不更新 main、不提交 PR 合并、不发下一项任务，也不创建额外 closeout 文件。独立新会话返回明确 ACCEPT / REJECT；Owner 再决定文档修订和项目源上传。文档候选接受也不自动接受其中每一项路线图建议或授权实现。

## 10. 原有边界完整保留

README documentary-read budget 仍耗尽；FD02 永久排除；无仓库／目录枚举、文件名搜索、代码搜索、`rg --files`、`find`、`fd`、`git ls-files`、`git ls-tree`、`git grep`、递归 listing 或 globs。不得访问旧 `D:\EliteSync` 或源仓库 `zcx369658780/EliteSync`。

受保护无关 staged state 不得检查、修改、unstage、覆盖、丢弃、reset、clean、提交、引用、总结或使用。文档整理不提供绕过此限制的理由。

保持 D-02 unresolved / `D02-DURABLE-UNKNOWN-01`；U-14 exclusion；U-12 exact-scope target rules；`TP-SOURCE-CLASS-01`；`TP-TARGET-01`；Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`；Database `0/8 NOT INSPECTED / NOT AUTHORIZED`；deferred PUI；PUI-PREREQ-12=`0`；accepted legal / Safety 与 no-processing 边界；implementation、LC-03、LC-04、Phase 36 均未授权。

保持交接中的既有表述：`CORE PRE-ALPHA LEGAL BOUNDARY IS SUBSTANTIALLY COMPLETE; PRODUCTION LEGAL READINESS IS DEFERRED TO MATERIAL MATURITY TRIGGERS.` 这不是本任务重新作出的法律结论；法律不重新被设为当前关键路径。无参与者研究、招募、业务数据处理、private-Conversation 检查、telemetry / analytics / measurement、Safety Operations 或新法律研究。

M1 冻结目标的一次性 lane 已耗尽；结果仍为 `False / WORKTREE-STATE NON-HIT ONLY`，不是全局不存在或构建失败。M2 deferred。M3 blocked；既有方法类别和预检 Outcome B 保留。方法优先级、文档研究、指令修订和候选接受都不等于 M3 执行授权。

本任务不运行 Flutter、Dart、Gradle、Java / Android 工具、`syncFlutterAar`、依赖解析、安装、缓存／环境检查、`.android` 或其他生成输出检查、artifact probe、M1 重试或任何构建前置检查；不执行技术设计或实现工作，不扩充技术源码读取范围。历史文档内命令只作文本证据，永不执行。

任务作者终点：只发布本任务，核验 commit / blob / sole parent / 单一路径，给 Owner 启动 prompt，然后停止。执行者终点与之不同，见第 8–9 节。
