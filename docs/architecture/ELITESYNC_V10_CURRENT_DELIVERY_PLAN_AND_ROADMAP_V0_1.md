# EliteSync v10｜当前交付计划与路线图｜v0.1

日期：2026-09-21（Asia/Singapore）。
状态：`PROPOSED — SINGLE INDEPENDENT REVIEW REQUIRED — PLANNING ONLY`。
证据快照：`67b14d97732fe831e4ac9321373a8a0a6f7d22f9`。

## 1. 本计划解决什么

保留 Owner 已接受的产品目标，用交付成果、依赖和证据层次替代已过期的“下一步 APP-T01”。不重置 APP-T01～T12、不重开旧 APP audit、不删除历史路线、不宣布可运行 MVP 完成。

本版本接受后，仅替代旧 `ELITESYNC_V10_NEW_VERSION_APP_IMPLEMENTATION_ROADMAP_BASELINE_V0_1.md` 中作为“当前排程”的解释；旧文的产品范围、边界与历史事实继续有效。冲突涉及产品/权限时不得用新路线静默改写。

本次唯一活动为计划文档优化及独立验收/同步。以下 milestone 和建议任务粒度都不是 R17 修复、R18、代码、HTTP、客户端或生产执行授权。

## 2. 产品交付目标与成功定义

目标 IA：`Home | Progress | Messages | Me`。
主循环：`Onboarding -> Readiness -> Match -> Connection -> Conversation`。

产品正确性意味着：状态不混淆、阶段分别同意、信息用途/受众明确、原因/不确定性可理解、可纠正/暂停/退出。无自动 Connection/Conversation、无 globally public MVP Profile、无单一 Compatibility 权威总分、无私密 Conversation 默认 AI/training/ranking 用途。

分清四个出口：

| 出口 | 必要证据 | 不能代替 |
|---|---|---|
| 客户端/领域契约基础 | 状态、路由、受众、fail-closed 边界与静态验收 | 可运行应用 |
| synthetic/dev-test 纵向闭环 | 明确虚构输入、领域到持久化/应用/必要 transport 的精确验证 | 真实状态权威、生产许可 |
| 可演示客户端集成 | 明确平台与运行证据、稳定接口适配、主流程可演示、虚构样例显式标识 | 真实参与者内测 |
| 真实内测/生产准备 | 对应身份/权限/数据/持久化/安全/发布和法律成熟度门槛 | 由文档或 HTTP 200 自动获得 |

## 3. 已有成果：复用，不重新做

来源详见当前证据索引。APP-T12 rerun 在 main 的结果记录 11-area 静态集成矩阵与 G-02～G-13；本次只核实文档，不重跑客户端，不重新声明其完整接受链。

已报告的四栏导航、Me 四目的拆分、独立生命周期界面、Calm Home 静态结构、Explainability、Privacy、notification privacy、common presentation states 和 legacy cutover 基础应按证据复用。

2026-09-21 handoff 记录 Runtime Readiness 与 Canonical Match synthetic/dev-test 切片接受至 HTTP。它们是后续稳定接口的候选复用来源，不是 production writer/auth 的替代。

Product Connection 的历史 evaluator、R15-R1 和 R16-R1 继续作为限定基线；R17-F1 使映射入口暂停，并不把所有前序成果抹除。

## 4. 最小依赖路线

`计划包独立接受 ->（另行授权）R17 缺陷/映射闭合 -> Connection persistence family -> Connection application boundary -> Messaging/Conversation -> Home/Notification 活态依赖 -> synthetic 客户端集成 -> 真实内测/生产成熟度门槛`。

Connection HTTP 的必要性与具体 contract 必须另行决定；本路线不预写 endpoint，也不把 HTTP 任意设为所有下游的硬前置。Messaging 的实际门槛仍是“所需 Connection persistence/application boundary 已接受”。

| 里程碑 | 当前状态 | 必需输出/退出条件 | 真实依赖与并行边界 |
|---|---|---|---|
| M0 当前计划/来源归一 | 本包候选 | 独立审查、精确集成、同步回执；不重审全部产品 | 文档 lane；不依赖工具链恢复 |
| M1 Connection 映射闭合 | R17 REJECTED | 明确 order-invariant conflict policy 的合法决定与必要验证；有效来源完整；新映射候选独立通过 | F1 必须解决；不可用排序/过滤偷偷重定义领域 |
| M2 Connection persistence/application | 未实现/未授权 | 先 IP-13A/IP-13D family 与 exact payload parity，再独立应用编排；代码+目标回归+结果各有精确任务 | persistence-first 有现有源码依据；不强并成一大包 |
| M3 Messaging/Conversation 最小闭环 | 下游受阻 | 独立 message consent、active Connection 依赖、撤回/暂停/关闭/失效语义、只用授权 synthetic 输入 | 不能靠 Match/route identity/本地布尔值取得权限 |
| M4 Home/Notification 活态投影 | 展示基础已有报告 | 依上游已接受状态提供真实于该测试边界的摘要/下一步；通知隐私/过期动作/quiet 边界明确 | 可按已就绪 producer 分片；不得伪造尚未就绪的数据；OS delivery 单独证据 |
| M5 可演示 synthetic 客户端集成 | 运行证据待建立 | 对应平台/构建与启动证据，已有 UI 接口适配、主循环和错误/失效回归、显式虚构样例 | 稳定接口的集成准备可另行并行；不授权 M3/DEP13/B12/M2 |
| M6 真实内测/生产准备 | 未开放 | 活动所需真实 authority writers、auth、持久化、数据权利、安全/发布准备及成熟度审查 | 不是 synthetic MVP 验收的自动延伸 |

这些 M0～M6 是本计划的交付里程碑，不是历史 M1/M2/M3 工具链任务的替代 ID；提及旧构建链时始终带“工具链”限定。

## 5. 15-domain 覆盖与后续最小增量

| 原设计领域 | 保留范围/阶段 | 已有证据层次 | 后续只做什么 |
|---|---|---|---|
| Home | MVP Calm State Hub | 静态投影/导航报告 | 对接已接受 live projection，不重画基础结构 |
| Discover / Explore | Phase 2 | 原语与历史审计 | 不进当前关键路径，不继承未知远端内容 |
| Canonical Match | MVP 独立机会/同意 | 客户端契约 + synthetic HTTP | 客户端绑定和真实 writer gap 分开处理；不自动 Connection |
| Connection | MVP 独立 mutual consent | 契约 + 有新反例的历史 evaluator | M1/M2，保留 8-state/8-19 reasons/失效/terminal 边界 |
| Conversation | MVP 基础交流 | fail-closed 客户端契约报告 | M3；共享权利按具体活动单独决定 |
| Relationship | Phase 2 mutual opt-in | 产品目标 | 不由聊天推断，不升格 MVP blocker |
| Profile-purpose split | MVP 四目的分离 | Me 契约/界面报告 | 仅对接合法来源/受众，身份保证不被 UI 证明 |
| Questionnaire/readiness | MVP named checklist | 客户端契约 + Runtime Readiness 切片 | required/optional 元数据与接口，不发明资格/验证等级 |
| Explainability | MVP 六字段解释 | 既有展示报告 | 伴随每个新 domain 复用并做适配，不另造评分 |
| Notifications | MVP 最小隐私通知 | 展示合同报告 | event/materialization 与 OS delivery 分开闭合 |
| Settings/Privacy | MVP 控制中心 | 目的分离与占位限制报告 | point-of-use 与 central controls 一致，不把请求 UI 写成权利实现 |
| Onboarding | MVP 渐进/可恢复 | 契约基础 | 对接 readiness；允许不提供 optional，不自动全用途 consent |
| Common UI states | MVP | 既有 presentation contract | offline/stale/error 与新接口回归，不重定义领域 state |
| Data classes | MVP 用途/受众分离 | 已接受产品设计 | 每次新增流明确来源/用途/受众/失效，不跨用途默认复用 |
| Legacy removal | MVP 有界 cutover + retained debt | APP-T12 G-11 | 只解决有证据的剩余 consumers；不全仓清理、不访问旧仓库 |

## 6. 任务粒度与减少往返

每个新任务必须说明新增证据/具体缺陷、要改变的决定、交付后可用能力。没有增量不另起任务。

在同一已接受契约与授权边界内，默认把实现、synthetic 单元测试、相关回归和结果报告作为一个交付包；不为了文档形式把 validator、测试、结果拆成三次排队。新产品政策、权限/数据用途决定仍先明确；不能拿“大任务提速”绕过这些门。

当前建议 WIP：一条活动核心工程任务，加至多一条独立的文档或已稳定接口的准备任务；无实际可用执行者/精确 task 时不宣称并行已启动。共享 IP-13A/IP-13D、routes 等写集合相交时不得并发修改；提前声明独占写路径和消费的接口版本。

后继任务可在已接受结果之后随同回复发布，不提前写 R18，不自动运行 Codex。Owner 要求暂停时不续行。本次结束在计划验收/同步，不恢复产品任务。

## 7. 验证前移

契约任务先固定允许状态、拒绝/UNKNOWN 边界、证据恢复、dependency presence、修订/上下文和失效矩阵，再进行实现。必须考虑相互组合，而不仅各字段单独合法。

领域证据集合的关键检查包括：输入置换、equal-revision conflict 与更高 revision 同时存在、incomparable source namespace、缺少 selected dependency、structurally valid cross-aggregate/participant conflict、terminal 与失效前后 context 保留。R17 反例作为待解决证据保留，不在本计划决定 conflict precedence。

实现任务的目标 tests 与共享边界回归必须一起点名。未来低风险离线 synthetic 单元测试可在 task 中明确设置“初次 + 最多两次仅修正授权代码后的复验”；没有变化不重跑。历史 one-shot、网络/acquisition/cache/构建/真实数据/生产操作不继承此建议。具体命令、文件、副作用和次数始终由 task 决定。

## 8. 缺口不再混成一个总 blocker

每项 blocker 记录稳定 ID、来源、影响 milestone、解除证据、负责角色和是否有活动任务。R17-F1/F2 保留原 ID；APP-T12 G-02～G-13 保留原类别。

synthetic derived Readiness/Match HTTP 成果不自动关闭 G-02/G-03 的真实来源/写入权威缺口。G-07 数据权利和 G-12 工具证据不能被“0 contract blockers”解释为已解决；G-10 Phase 2 不拉回 MVP。

工具链恢复、真实身份/权限、共享数据权利、生产部署分别维护 lane。局部无新证据时保持原条目，不增加同义 Phase。详情在 CURRENT_CONTEXT 与原 APP-T12 结果，不重复全文复制。

## 9. 排期与进度报告

旧交接的 early/mid/late October、November、mid-December 2026 与 January 2027 只保留为历史情景估计，不是本次重新承诺。本轮没有团队吞吐、任务工时或客户端运行证据，不能可靠计算提速百分比或新的完成日期。

每次实质接受/拒绝只更新：获得哪个交付能力、当前活动任务、尚阻塞的真实依赖、下一条有界决定。以有效实现/验证成果衡量，不按文档数、提交数、task 编号计算百分比。

## 10. 维护与停止

GitHub 当前入口/路线/证据索引是工作状态的单点维护位置；历史来源只引用。工程接受后仅更新变化单元与证据指针，不重写所有计划和项目源。

本计划生效须独立接受精确候选并进入 main。它不授权代码、测试、HTTP、下载、工具链、真实数据或部署；完成计划审查和同步后 STOP。
