# EliteSync-v10｜v10.0.1 版前计划草案｜已接受成果集成与非生产跨层消费验证

> **PROPOSED / CODEX_FEASIBILITY_REVIEW_ONLY / NOT_FROZEN / IMPLEMENTATION_NOT_AUTHORIZED**
>
> 日期：2026-10-13（Asia/Shanghai）。Owner 本次已明确授权“核查 v10.0.0 是否还有工作，完成则开始规划下一个版本”。本页是 Astra 版前建议，不是冻结版本或开发派发。由 Owner 手动转交当前 Codex 进行**有界只读可行性核查**，再决定冻结范围。不能由发布此文档自动创建开发会话、启动版本、合并候选或解除暂停。
>
> 拟定版本：**v10.0.1**（工程增量，不代表可发布 APP、完整 MVP 或 RuntimeReady）。

## 1. 当前依据与必须先承认的事实

- 文档发布基础：GitHub 仓库 `zcx369658780/EliteSync-v10`，`main`，本草案编制前核实为 `d5997fd325e817dd7e6a4eb294cfa01860b605a6`。本草案的实际 GitHub 发布提交以发布回执为准；此处的提交只是**版前基准**。
- 现行流程：[CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)，[当前状态](../../../CURRENT_STATE.md)，[动态总目录](../../../DOC_INDEX_CURRENT.md)，[版本登记](../README.md)。
- [v10.0.0 独立终验](../v10.0.0/acceptance.md) 与 [复盘](../v10.0.0/retrospective.md)：**ACCEPTED / CLOSED WITH OBSERVATIONS**，仅 synthetic/dev-test；七项 AC 已通过，不再追加 v10.0.0 返修或改写冻结计划。其 [已接受代码候选](https://github.com/zcx369658780/EliteSync-v10/commit/18daf9746e2f031fbbbe18682bf0c742aad92a09) 为单父提交 `4bebc8f394248e254c1368a06fbdee5d2c883301`、tree `e5ee225f8084dd275278337bb90a8a5414ef6e22`，**Integration Status = NOT_MERGED**；除该文件之外还包含版本证据与隔离执行脚本。产品源码零修改、一个现有 Product Connection 测试增加232行、139个数据集。
- 本轮 GitHub 只读比较表明：当前 `main` 与上述 candidate **分叉**，因 main 前进了独立文档提交。**不得**把整份候选分支无条件 merge/cherry-pick 到本地主树，更不得通过 reset/rebase 覆盖现有 dirty/untracked。当前本地 `D:/EliteSync-v10` `main` HEAD `4bebc8f...` 及大量 LOCAL_ONLY 的具体身份来自此前 Codex 回报，不冒今天网页已重验。
- [APP-INT-04 已接受](../../architecture/ELITESYNC_V10_APP_INT_04_SYNTHETIC_MESSAGING_CONVERSATION_ACCEPTANCE_V0_1.md) 只证明 Flutter **demo-local synthetic** 消息同意、列表/阅读/发送与 Connection 失效 relock；不等于后端写者或真实 live Conversation。
- [BE-12 默认拒绝验收](../../../EVIDENCE/BE-12-UNVERIFIED-MESSAGING-ROUTE-FAIL-CLOSED/work-review.md) 证明受控七条真实私密消息路由 fail-closed 404（仅已接受历史范围）；[BE-16](../../../EVIDENCE/BE-16-MATCH-ROUND-NEXT-ACTION-FAIL-CLOSED/work-review.md) 仅限制公开旧 `next_action_code`，不能授予消息权限。Codex 上版报告 `ConversationUsePointQualifier` 当前只有 contract-only，live grant=false；其**当前源码**仍须在本地核对。
- Match、Connection、Conversation、Relationship 相互独立；`STORED != AUTHORITATIVE`、`PROJECTION != PERMISSION`、`ROUTE IDENTITY != CONSENT`。V57 已获窄 SOURCE_ONLY 准备批准仍未激活；H2/D0 未签发，`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 不变。

## 2. 推荐产品工程目标（待 Codex 核查）

**目标：** 不重复 v10.0.0 的测试收口，不重建已有 Flutter synthetic demo，在安全保护本地主树的前提下，将**具名已接受候选**转化为下一安全开发基线的可追溯组成部分，并使后续 backend→Flutter 消费桥具备一个真实、可测试、不会伪装 live 权限的边界。**优先实现代码/接口/消费测试，不额外创造治理审查任务链。**

### 候选工作包 A｜已接受候选的受控集成与安全基线（优先纳入）

1. Codex 只读核实 `v10.0.0` accepted candidate `18daf974...` 与最新 GitHub main、本地 HEAD、dirty tracked/untracked，以及相关 LOCAL_ONLY Product Connection、MC、Flutter 资产的**对象级**差异。仅因本版实际消费者需要读取具名文件，不全量列举223个历史 worktree 或扫所有 EVIDENCE。
2. 提出精确目标：被接受的 **232行测试增强** 是否已存在于本地主树，或应选择性纳入新的受控 integration candidate；其余旧报告/manifest/辅助执行脚本有必要继承哪些、哪些保留固定历史 URL 即可。区分技术代码基线、文档发布分支与用于独立验收的 candidate。
3. 若下版冻结同意纳入，选定**明确父提交、隔离工作树、白名单源文件/测试/必要证据**，仅受控集成，不合并全部历史 raw，不自动改 `main`。如果现有本地已经含相同增强，凭准确 blob 和可执行测试确认，不重复提交。
4. 无论集成结论如何，版本登记仍分别保留 `v10.0.0 Acceptance=ACCEPTED/CLOSED` 和 `Integration=NOT_MERGED`，直至存在**指定集成目标及实际证明**，才可独立更新后者。历史 ACCEPT 记录不改写。

**候选验收：** 有一个可追溯的受控 integration candidate（或精确证明已有集成目标包含相同字节与行为），最小必要测试在其实际最终身份下通过；原始 dirty root 与既有有效证据无损。是否将最终代码合入正式 main 仍由 Owner 单独决定，不以本草案预授权。

### 候选工作包 B｜backend→Flutter 消费桥的准确前置与最小非生产 vertical slice（需 Codex 判断是否同版）

1. 定向调查现有 Product Connection/MC 的**权威输入来源、状态/同意、持久化 producer、use-point qualifier、输出契约、客户端数据适配器和失效传播**。对每一接口分类 `ALREADY_ACCEPTED / IMPLEMENTED_NOT_ACCEPTED / LOCAL_ONLY_UNVERIFIED / MISSING / PAUSED_OR_PROTECTED / UNKNOWN`，无需重复审查已接受独立领域。
2. 明确区分三个证明层：① Flutter demo-local mock 的已接受闭环；② 后端 contract-only 或 synthetic fixture 的行为；③ 真正的**同一 producer→传输/适配→消费者**跨层实测。前两项叠加**不等于**第三项；BE-12 的真实私密路由继续固定 404，无 live grant 放行。
3. **如果能在完全隔离、虚构数据、现有安全执行权限下贯穿至少一条真实边界**，可以建议冻结一个更窄的 vertical slice：例如只读 Connection/MC 状态的可检验契约消费与 stale/revoked/fail-closed UI 状态传播；其输入、输出与消费者必须是实际生产函数/已授权适配边界，不凭静态 mock 对象生成“贯通”PASS。若需具体新增 adapter/transport，先由 Codex 指出精确文件、数据级别、无真实路由副作用、测试入口与回退条件。
4. **如果必须依赖真实 writer、账号、生产 DB/API/SSH、七条消息 live 路由放行、不可得的 authoritative consent、正式 SDK/设备/工具链资格**，则该桥**不应纳入 v10.0.1 冻结版**；将 B 限于界定准确接口和 retained blockers 的版前成果，不得另开“只为文档而文档”的长链。Codex 应提出一个唯一的、具可执行代码价值的替代窄范围，优先 A+其最小回归。
5. 不以本版允许开启用户消息的真实读取/发送，也不把旧 Match action、缓存、route identity 或 synthetic 许可当正式 Connection+Messaging 同意；负向、撤销、过期/暂停边界与不产生副作用是首要合同。

**候选验收（如冻结 B 的垂直切片）：** 给出实际源与消费端身份、准确调用/序列化、同意/无效/撤销的成功与拒绝回归、原始证据，且生产 live 路由仍 fail-closed；不得把仅存在的 local mock 声称跨端生产贯通。是否可以同版必须由 Codex 版前证据决定。

### 候选工作包 C｜有限联合回归与集中交付

- 只运行与最后冻结后的准确 A/B 代码和接口变化直接相关的 PHP、Flutter 单元/组件或 synthetic 集成测试；**不自动复制 v10.0.0 的11-test清单、139 dataset、历史 M5 大型验证包**。若仅整合已有 Product Connection 测试，则合理复用相应有界组合回归。
- 报告真实测试命令、stdout/stderr、失败和修复链、最终代码/test/fixture身份，明确 `NOT_RUN` 与环境阻碍；源代码/测试、证据及有限 manifest 必须可供 Astra 通过 GitHub 固定 ref 读取，必要私密原件经 Owner 安全脱敏提供。
- 保留二层验收：Codex 自测/作者交付不是 Astra 终裁；验收状态 ≠ 集成状态；成功不等于 Android 实际运行/生产许可。

## 3. 范围与保护边界（规划阶段及未来冻结均不能默许解冻）

- 本次发布**仅准许版前只读核查与执行计划反馈**；不自动 merge/cherry-pick/pull/rebase、不修改代码/fixture、不创建正式执行候选，不授权运行测试或 SDK/设备/生产操作。
- 不启动 V57、H1/H2/D0、旧任务队列、旧 Work/Dot 监控或定时检查。V57 准备例外已批准但仍 PAUSED/NOT_ACTIVATED/NOT_DISPATCHED/NOT_EXECUTED。
- 不触碰真实账号、私有消息内容、MariaDB 恢复/解密、生产 DB/API/SSH、密钥/凭据、部署/发布、真实来源 writer 或不可逆删除；不修改正式 APP 15-domain 接受设计、Match/Connection/Conversation/Relationship 各自权限与 data-class 来源。
- 禁止为准备本版而清理原始本地主树、默认 Git index、现有 dirty/staged/untracked、历史未验收 EVIDENCE、旧 worktree。确需处理不同 Git 谱系时，冻结前报告安全 branch/worktree/source-intake 方案，**不擅自认定 main 即唯一正确代码基线**。
- App Sources/Instructions 自动注入完整范围和 `projectId=null` 不构成已证业务障碍，也不宣称已解决；只在实际缺必需资料时有界报告。

## 4. 拟冻结的可观察完成标准（此处仅草案）

| 草案 AC | 如纳入的最终可观察结果 |
|---|---|
| **P-AC01** | 以固定 Git 父提交、具名源测试/fixture身份、候选 commit/tree 证明 v10.0.0 的特定可复用增强已被安全纳入新集成目标，或用实际对象身份证明目标已有相同内容；本地主树保护证据可读。 |
| **P-AC02** | 实际新候选上最小必要 Product Connection/MC 等相关回归可运行，保留准确原始输出、失败→修复→最终 PASS/FAIL；不降既有合同或通过删除测试求绿。 |
| **P-AC03** | 若 B 被正式冻结为实现范围，至少一条具名 producer→transport/adapter→消费者的 nonproduction 状态消费实际贯通，并覆盖有效/无效/撤销/错误/stale 关键边界；没有资格时不得冒真桥或假 PASS。 |
| **P-AC04** | BE-12 真实 live 私密消息路由继续 fail-closed，未从 mock/旧 Match/投影取得在线消息权限，独立同意与 Source authority 没有被替代。 |
| **P-AC05** | 固定候选源码/测试/证据在 GitHub 可供 Astra 独立读取，并逐项分类 ALREADY_ACCEPTED、INTEGRATED、RETAINED_OUT_OF_SCOPE、BLOCKED_NEEDS_OWNER、UNKNOWN 等。 |
| **P-AC06** | 有明确本版 Acceptance Status 与按实际目标的 Integration Status；Astra 对最终冻结计划集中验收并复盘，未自动合并 main、发布客户端或启动后续版。 |

P-AC03 只有在冻结版纳入 B 时才成为硬完成标准；如 B 拆版，须**在冻结前**改为明确的 A 范围，不以后验收困难而追改冻结标准。这里的 P-AC04 也必须在最终冻结版中限定可实际验证的代码/环境范围，不能要求以未授权真实生产访问作为证明。

## 5. 正式流程

1. Astra 发布本草案 → Owner 手动交给现有 Codex 只读核查。
2. Codex 依据本地代码、有效历史接受和运行资格集中返回 `READY / READY_WITH_FINDINGS / BLOCKED`、推荐冻结范围与单一可行替代方案；特别回答 B 是否真正可形成可测试代码增量。
3. Astra 审查 Codex 方案并与 Owner 处理必要受保护方向决定，**另行发布正式 `v10.0.1/plan.md`**，绑定固定冻结提交、代码基线、验收标准、授权边界；在此之前一律 `NOT_FROZEN`。
4. Owner 手动下达已冻结版给 Codex 后，才允许在该版本范围内自主编码/测试/修复，结束后集中交付供 Astra 终验。无需 Work 实时监督、逐命令审批或强制新增多模型审查。
5. 本版结束时独立登记 Acceptance 与 Integration 状态，复盘事实；没有自动后继。

## 6. Codex 本轮核查请求（仅只读）

目标会话：此前 Owner 已指定的 EliteSync-v10 本地 Codex 接收会话 `01a13084-65a4-7c71-bf32-fa60a68d2099/local`，若当前实际线程有变化则以 Owner 手动交付和 Codex 可信元数据为准。历史 `projectId=null` 仅为工具列表观察，不能覆盖 Owner 的 UI 项目归属与真实 Git 顶层证据。

请一次性回复：

1. 当前 cwd/Git HEAD/index/dirty/untracked 与实际远端，识别 v10.0.0 accepted candidate 相对当前主树的具体文件差异，**明确 A 是否还需要代码动作或其实已经具备**；不拿旧接受报告代替当前代码。
2. B 的 source writer / qualifier / contract-only / Flutter data source /消费端与 BE-12 护栏的**具名实物链**：用精确路径、真实方法和已有测试/证据说明 `ALREADY_ACCEPTED / PARTIAL / MISSING / PROTECTED`，判断哪些必须真实后端来源才可验证。
3. 推荐**一个**可在一个版本内独立验收的实际代码增量：A + 可行的极窄 B，或 B 不具备时 A + 已存在消费者范围内必要验证；不要发散为无穷前置治理任务。
4. 指明准确拟修改/复用的文件与测试、最小真实负向用例、允许的本地 dev/synthetic 运行命令（未执行写 PROPOSED）、保护门、隔离 worktree/候选父提交/最终证据发布策略。
5. 对 P-AC01～P-AC06 提出删繁就简的冻结建议，说明不能承诺的条目；给粗略工程时间/环境阻碍、留存技术债/不入范围项，未知写 `UNKNOWN`。
6. 证明本轮**没有实际开发、没有合并、没有运行应用测试、没有启用 V57 或 404 私密消息路由**，最后回复：`V10.0.1 PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED — IMPLEMENTATION NOT AUTHORIZED`。

**结束：`V10.0.1 PROPOSAL PUBLISHED — CODEX FEASIBILITY REVIEW PENDING — DEVELOPMENT NOT STARTED`**
