# EliteSync-v10｜v10.0.0 首版遗留收口｜版前计划草案与 Codex 核查任务单

> 状态：**PROPOSED / CODEX FEASIBILITY REVIEW ONLY / NOT FROZEN / NOT ISSUED FOR IMPLEMENTATION**  
> 日期：2026-10-12（Asia/Shanghai）  
> 发起：Owner 已手动启动第三阶段的 v10.0.0 **版前规划**；网页 GPT 顾问负责草案与最终独立验收；现有 Codex 负责先核查本地事实并提交执行计划草案。  
> 名称：**v10.0.0** 是迁移后首个工程收口版本的拟定编号，**不意味着**公开发布、生产可用、MVP 全部完成或 RuntimeReady。  
> 文档性质：用于 Owner／Astra／Codex 在冻结前对齐；**本文件发布仅授权只读核查与提出实施方案，不授权编写产品代码、运行正式实验、改变保护边界或恢复旧暂停任务**。

## 1. 已核验权威与现状（不是本地实时实测）

- 远端文档规划基线：`zcx369658780/EliteSync-v10` `main`，版前阅读提交 `696834b114d9626efbf46080f42243b6a1a65183`。**本草案最终发布提交以后续真实 GitHub 回执为准**，不能用旧提交冒充草案自身冻结 SHA。
- [动态总目录](../../../../DOC_INDEX_CURRENT.md)、[当前工作流](../../workflow/CURRENT_WORKFLOW.md)、[当前状态](../../../CURRENT_STATE.md)、[第二阶段本地交接](../../migration/CODEX_LOCAL_HANDOFF_20261012.md)、[版本登记](../README.md) 是当下主要读取入口。历史验收不能由动态目录追改。
- 上次 Codex 实测本地 `D:/EliteSync-v10` `main` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`，远端文档更前进。其源码/测试及大量 EVIDENCE 仍有 `LOCAL_ONLY`；95 项具名保护文件历史核验通过，新会话已只读复核。**当前实际文件身份和进展仍须 Codex 再核对所需部分**，不得把远端文档树当作完整执行代码基线。
- 第二阶段发布 `696834b...` 仅含 4 份迁移文档；已接受的 stage-e2e-v2 仅 `SOURCEONLY_SYNTHETIC_TOOLCHAIN_E2E_STAGE_V2`，正式 Driver/JVM/compile/14case/SDK/部署资格仍未证明。
- V57 的窄 `SOURCE_ONLY` 准备例外已获 Owner 批准但 **PAUSED / NOT_ACTIVATED / NOT_DISPATCHED / NOT_EXECUTED**；H2/D0 未签发；`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 等限制保持。此次版前核查不改变它们。

## 2. 版本定位与需要解决的问题

**建议目标：** 在不重做已接受设计、不过度扩展产品、不碰真实用户/生产资产的前提下，对尚未完结的 **本地实现资产、Product Connection 持久化与应用绑定、同意/消息消费链、非生产验证证据** 建立一个明确、可复核的收口版本。先完成可以在本项目既有本地环境通过普通源码/纯虚构 synthetic 验证的增量，而非重新发出旧微任务队列。

这不是“清空所有历史未完成任务”。不同轨道必须区分：①历史已接受但未正式运行；②已有候选或已拒绝需要更正；③LOCAL_ONLY 当前可能已完成但网页未见；④仍待 Owner 独立授权的保护事项；⑤Phase 2/Later。Codex 在可行性回复中应判断本草案是否需要缩小范围，**不得为凑 v10.0.0 编号把保留未知填成 PASS**。

### 候选工作包 A｜安全识别并纳入已有本地成果（建议必需）

- 在 `D:/EliteSync-v10` 实际确认相关 Flutter、Backend 和具名历史证据的当前代码身份、是否已测试、是否已接受、是否只在本地。对照第二阶段的保护清单和已接受契约，产出 **按对象分层的纳入/暂不纳入清单**，避免重复实现或丢失成果。
- 明确远端文档分支、真实本地源码 HEAD、untracked 实现、可用的单独 worktree/基线与本版候选如何建立。**不以粗暴 pull/rebase/reset/stash/clean 或全仓 add 达成“统一”**；不得覆盖原始 dirty/staged/untracked，不能把 rejected 代码直接视为 accepted。
- 版本冻结前提出确定的代码基线与安全 worktree 策略；正式纳入、测试和交付身份须在冻结后按授权范围执行。大量旧 EVIDENCE 不全量复制/哈希；可重用的具名证据需有准确来源。

**拟验收：** 存在真实、有限的 source/test/fixture manifest 与来源/状态分层；版本候选可追溯到确切本地文件身份，原有重要成果不被覆盖；无将仅在本地的文件冒称已公开发布。

### 候选工作包 B｜Product Connection 持久化/应用绑定旧缺口收口（拟主开发增量）

- 历史接受 `R17-R3` 自包含映射与 evaluator、Package A；历史 R18 候选被拒，阻塞点为 `PROTECTED_BINDING_MUST_NOT_DEPEND_ON_PHP_ASSOCIATIVE_KEY_INSERTION_ORDER`。旧 R18-R1 任务文件见：
  [R18-R1 历史精确任务](../../architecture/ELITESYNC_V10_NEXT_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_TASK_V0_1.md) 与 [R17-R3 已接受映射](../../architecture/ELITESYNC_V10_IP_13I_R17_R3_PRODUCT_CONNECTION_DOMAIN_TO_APPLICATION_MAPPING_REREVIEW_ACCEPTANCE_V0_1.md)。
- **先查本地实际进度**：可能已有未提交更正或后续实现；如果已完成则收集当前实现与有效测试证据，而不是按 9 月 21 日旧任务机械重做。旧任务的精确对象与语义是参考/冻结历史，不自动沿用其旧的读写次数、首次 PASS 关窗和已失效 Git 基线。
- 如需实施修正，拟保持 R17-R3 的 Binding Model A、精确结构诊断、字段/生命周期/参与者等既定契约；对 **11 个准确命名 binding 字段逐键精确比较**，使容器键插入顺序不产生权限差异；`participants` 字段在 required/source 间仍按原合同做精确字段值比较（不得擅自排序），并保持独立的 descriptor participant-set 语义。禁止把 `protected_binding_satisfied` 扩成额外 currentness/freshness 判据。
- 回归要包括同名同值不同键顺序（不应改变结果）、命名字段真实差异（必须拒绝）、参与者顺序/类型的合同边界、无权限时 fail-closed、与已接受 Match/Connection 相关持久化的组合回归。实施选择、精确测试命令和可运行工具须 Codex 先核验。

**拟验收：** 有与最终候选对应的真实源码、有效目标回归及组合测试报告；原 R18 被拒历史不被伪装接受，也不把旧失败的首次通过预算重新套用于新版本。

### 候选工作包 C｜Connection → Conversation 最小 synthetic 消费闭环（Codex 确认依赖后决定是否同版）

- 若 B 的实际接口和本地已存在的消费者允许，形成**单一受控、完全虚构 actor/fixture** 的可重复路径：独立 Match/Connection 状态与同意 → 独立消息同意 → 获准读/发 → 暂停/关闭/过期/撤销后读发拒绝及 UI/消费端准确展示。
- Match 不自动创建 Connection；Connection 不自动打开 Conversation。路由标识、缓存和投影 **不等于 live 消息权限**；read/send 必须取决于既定授权边界，发送时仍须检查。状态、transport failure、stale/offline、availability 的区分不得被一个“成功”mock 掩盖。
- 只修补本版实际必要的消费代码与测试；若本地后端已有 BE-12/BE-16 等已接受 fail-closed 能力，应优先复用准确成果而不是另造消息域。HTTP 传输只有当真实消费者需要时才规划，不擅自扩为生产账号/消息系统。
- **先由 Codex 判断 C 是否与 B 可组成可独立验收的同一版**。如果缺必要 writer/contract、不可在非生产条件下验证或将显著扩大版本范围，明确建议 C 拆分到下一版，不得用空 mock 或删除断言“完成”。

**拟验收（若纳入冻结版）：** 生产函数/实际消费输出在 synthetic fixture 下走通成功、失效、负向路径并留有 raw 证据；没有权限跃迁，未把测试数据宣称真实数据。

### 候选工作包 D｜工具链与客户端验证收口（仅对本版实际改动开展）

- 已接受的 stage-e2e-v2 SOURCEONLY/SYNTHETIC 不重新证明、不得重复计入新的开发量。针对本版实际修改做必要的 PHP/Flutter/源码及隔离 synthetic 回归；证据必须绑定最终代码、测试、fixture 和关键序列化/消费链。真实执行与未执行项分列。
- Flutter UI 若进入本版，只要求与实际改动对应的有来源状态显示/消费验证；**正式 Android 构建、设备安装、JVM/Driver/14case、SDK/依赖升级或发布不因本草案获准**。如非授权环境阻碍实际集成，明确列证据缺口和下一版的准确前置，而非虚报 Android PASS。
- 延续有效测试、原始失败和必要重测索引，Codex 可自行处理普通错误；不设旧 one-shot 命令预算，也不强制新增多模型审查链。

**拟验收：** 更改范围内必要真实测试与证据身份吻合；若只有 source/synthetic 能通过，版本结论如实限定 source/synthetic，不冒称 RuntimeReady 或 MVP 完成。

## 3. 本版明确不包含 / 需另行决定的事项

1. **V57 / H1：** 已有窄例外批准继承，但**本版草案只允许就其与主路线的依赖做只读核对与排期建议；不激活、不派发、不执行 V57**。若 Codex 认为其是本版不可绕过的前置，单列给 Owner 在正式冻结前作明确决定，不以“清理遗留”为自动授权。
2. H2/D0 及 `D0→T1/T2/T3→L4→B5→Q6→O7` 旧主路线不能由历史文档自动启动；六要求/三模板、projection-v6、宿主硬监督、CreateNew/flush/durability 等未证资格不变。
3. 不进行真实账号迁移、双库解密/隔离恢复、密码哈希迁移、真实私密消息读发、生产 DB/API/SSH、设备/SDK 变更、部署发行或真实用户试验。旧备份存在不等于可恢复。
4. 不改变已接受 APP 正式设计、产品/科学权威、数据用途与安全边界；不新增 AI 权威评分、不打开 Safety Operations、不开第五章/HANK/旧 EliteSync 工作树。
5. 不重开已 `ACCEPT/CLOSED` 的纯文档/合成阶段以制造工作量；不清理所有历史 worktree、全量历史源码/日志或其它不影响本版交付的老债。
6. 暂不承诺完整 MVP、Phase 2、M6、生产发行或“遗留问题全部关闭”；仍未达的目标作为可追溯 retained gaps，不伪装 PASS。

## 4. 建议的冻结版完成标准（等待 Codex 调整）

最终冻结计划至少应有以下**可观察**条件。当前仍只是提案，不能当作已冻结要求：

| ID | 预期可验证结果 | 未通过/范围处理 |
|---|---|---|
| AC-01 | 明确且可复现的本地源码基线、纳入清单、最终候选 Git/tree/源文件身份；保护已有 dirty/untracked/原证 | 无可追溯身份时不能宣布完成 |
| AC-02 | B 已证明不受 PHP associative key insertion order 影响，负向 field/participants/consent 约束不减，既有映射契约未漂移 | 若本地已完成，提供新的相关验证和有效历史来源；否则实现与测试 |
| AC-03 | 对选定版本内容执行真实目标测试及组合回归，保留命令/退出码、raw stdout/stderr、失败→修复→最终重测链 | 环境/权限阻碍如实 UNKNOWN/NOT_RUN；不做假 PASS |
| AC-04 | 若 C 在冻结范围内，独立消息同意和 Connection 失效导致 read/send fail-closed 的 synthetic 消费路径可重复验证 | 若拆分，则不作为本版 PASS 标准，必须在冻结前确定 |
| AC-05 | 按实质风险验证实际序列化及下游消费，交付内容/测试/fixture 身份绑定同一最终候选 | 文本搜索、作者自报、孤立正确 JSON 不替代消费证据 |
| AC-06 | 对所有遗留事项给出 CLOSED_BY_V10_0_0 / ALREADY_ACCEPTED / RETAINED_NOT_IN_SCOPE / BLOCKED_NEEDS_OWNER / UNKNOWN 等准确分类，列出下一步依赖 | 不能把历史拒绝/暂停视为完成 |
| AC-07 | Codex 集中交付方案/结果、证据与剩余风险，Astra 独立对照**冻结版本**作接受/退修/失败结论并复盘 | 作者自测不自接受；只修原范围缺陷，纯新增需求下版 |

原则：**少而能实测、代码进展优先于反复治理链；但不能用不真实的绿色验收换速度。**

## 5. 正式版本流程与冻结门

1. **本次已授权且立即可做：** Codex 仅进行有界只读现场核查（准确本地代码/既有测试/适用规则和证据来源），形成一次集中 **执行计划草案与差异清单**；允许必要的 Git fetch/比较，但不 pull/rebase/提交产品实现、正式运行或动保护资产。
2. **Codex 回复后：** Astra 审核可行性与实际代码、必要时向 Owner 提出一个明确取舍；一次性决定 A/B/C/D 的准确工作包、源码基线、测试边界、保护门和时间估计。
3. **后续单独冻结：** 创建/发布 `docs/versions/v10.0.0/plan.md` 正式全文，记录固定 commit SHA/代码基线/真实范围/验收门与授权签发；相应 `docs/versions/README.md` 更新状态。**未出现正式冻结文档与明确执行授权前，不得开始编写本版产品代码。**
4. **冻结后才执行：** Codex 自主决定范围内实现细节、验证、修复、回归、局部进度，无须逐步问 Astra/Work；重要越权/不可逆决定才中途报告。
5. **集中验收：** Codex 交付固定候选身份与原始证据，Astra 独立验收、集中提出原范围缺陷，同版修复，最后记录 `acceptance.md` 和 `retrospective.md`；实际路径以冻结登记为准。冻结后不追改目标，无法成立的版本如实失败/部分完成并在新版本调整。

GitHub 作为任务/证据交换，不充当开发逐步审批中转。网页顾问不会实时监督或唤起 Work；Owner 手动转交 Codex 版前反馈。

## 6. Codex 本轮仅需回复的执行计划草案

指定接收会话（以 Owner 当前提供的真实元数据为准）：`01a12e99-0772-7d12-9520-209b5ecc31ce/local`；应用 UI 属于 `慢约会EliteSync-v10` 项目。即使该会话 `projectId=null`，不能仅凭空值否认已确认的 UI 项目归属；仍需核准实际 cwd/Git 根。

请在本地项目 **只读核查** 并一次性答复：

1. **真实执行现场：** 工作目录、branch/HEAD、remote、staged/tracked/untracked 概况；远端文档提交与本地代码提交区别；哪部分未发布。
2. **遗留清单与优先级：** 针对 A/B/C/D 分别标记 ALREADY_IMPLEMENTED / PARTIAL / MISSING / BLOCKED / UNKNOWN，给准确文件/测试/最近有效证据位置；特别确认 R18-R1 是否已经由 LOCAL_ONLY 代码完成，防止二次重构。
3. **推荐范围：** 是否建议 A+B 为必选、C 纳入还是拆版、D 应针对什么验证；列不应纳入的 V57/H1、M5 正式运行和真实数据操作及原因。如须调整方案，给出**一个**可落地替代版本，不发散成新的路线重构。
4. **拟冻结实施方案：** 工作包顺序、准确影响文件/测试或待定消费者、依赖、最少可见成果、可执行测试命令（若尚未实测标 PROPOSED）、安全候选/worktree 策略、需要的授权/环境阻碍。
5. **验收建议：** 对 AC-01 至 AC-07 指出不可执行或含混处，给可观测替代；说明 synthetic、源码静态、正式平台及生产之间的证明差别。
6. **风险与估计：** 主要风险、最高风险的保护门、粗略工作量及实际可取得的额度/时间；未知写 UNKNOWN，不为管理便利造数字。
7. **回复首行：** `V10.0.0 CODEX PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED`。明确**只核查、未开发、未激活 V57**，列需要 Owner 最后明确决定的问题。

本轮不要另立正式版本、不要启动旧任务、不要自行改 GitHub 的本草案或发布所谓最终候选、不要把提案当执行授权。

## 7. 当前发布边界

本文件是 **Astra 的第一轮提案**，供 Codex 校验现场事实；尚未得到 Codex 可行性反馈与正式冻结验收标准。本次 GitHub 发布只允许更新本草案、动态总目录、版本登记和规划阶段状态等必要文档，不改源码，不重写旧计划/已接受历史。不以本文件中的候选范围宣称已启动/已完成 v10.0.0 的实现。

**结束状态：`V10.0.0 PROPOSAL PUBLISHED — AWAITING CODEX PLAN REVIEW — IMPLEMENTATION NOT AUTHORIZED`**
