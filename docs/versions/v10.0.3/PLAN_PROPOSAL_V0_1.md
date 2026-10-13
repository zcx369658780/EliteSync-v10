# EliteSync-v10｜v10.0.3 版前计划草案｜Home→Progress 真实应用路由的 synthetic 状态消费与失效回退

> **PROPOSED / CODEX_FEASIBILITY_REVIEW_ONLY / NOT_FROZEN / IMPLEMENTATION_NOT_AUTHORIZED**  
> 日期：2026-10-13（Asia/Shanghai）。Owner 已明确授权**进入 v10.0.3 的规划阶段**；本草案仅供 Codex 在已接受代码和实际本地开发基线中做有界只读核查。**尚无正式冻结版 `plan.md`、执行候选或任何开发/测试/环境/设备/线上授权**。  
> 建议版本定位：从前三版「领域资格 synthetic 诊断→Dart 只读解析→Debug 预览」转向**实际 MVP 应用状态和导航消费**，但不开放真实聊天、生产源权威或实机门禁。

## 1. 已核的事实、产品依据与不是本版新需求的内容

- 本草案发布前 GitHub `main` 为 `9a2ede6c30eb6476950fb071d230d95a9afd4308`，Tree `bbeba46e1584c860b4634273bfd16a4724202ca3`；截至该提交 v10.0.0～v10.0.2 的已接受必要代码合计**17项**已定点纳入远端 main，旧候选原证独立保留。三版 `ACCEPTED/CLOSED WITH OBSERVATIONS` 仅限既定 dev-test / Debug Widget 范围，均**不**代表生产/Android 或正式消息资格。
- Owner 2026-10-13 长期决定已写入 [CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)、[记忆K08/K09](../../memory/knowledge.md)：每版正式独立验收后默认安全定点集成→建立可用本地隔离基线→规划下一版，不自动派发、不动原 dirty main。
- Codex 已报告**新隔离开发基线**：`C:/Users/zcxve/.codex/worktrees/elitesync-main-2175dd6/EliteSync-v10`、branch `codex/local-baseline-2175dd6`、HEAD `2175dd62d9384efa05dd6b5201f58c5282379fbb`、CLEAN，17/17 accepted Git Blobs；在此基线上具名 PHP294/3420、资格12/930、Flutter28及BE-12纯middleware8回归通过（**仅本地 Codex 回执，不是网页重跑**）。随后 GitHub `main` 增加 `9a2ede...` 的纯状态/记忆提交，Codex须定点核对，而不是以缓存 origin/main 代替实时 GitHub。
- **原本地 `D:/EliteSync-v10` 的脏主树仍独立保护**：HEAD `4bebc8f...`、index `2be660...`、43 tracked 修改、208 untracked normal；有独立 Flutter、PHP及设计/指导成果未吸收。旧脏 main **不是**下一版默认代码父提交，也不允许简单 pull/reset/rebase/clean/stash。
- 已接受目标： [APP功能设计与Owner接受](../../gpt-project-sources/07_新版本APP功能设计Owner接受记录.md) 的 MVP IA 为 `Home | Progress | Messages | Me`；`Match != Connection != Conversation != Relationship`；Readiness/Match/Connection/Conversation 状态与权限分别授权。原 [M0–M6路线图](../../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md) 把 Home活态摘要、下游消费者、安全失效与同一可运行客户端主循环分开；其2026-09-21日期、旧 R18 状态仅是历史快照，不能覆盖当前已接受事实。
- GitHub 固定代码实读：`features/home/presentation/pages/home_page.dart`（blob `4a7c0cdfe5bbceb278f2a070de872c490cfeef11`）、`state/calm_home_projection.dart`（`b253b9f87990f9140d495ad6fa6a733b329842ac`）、`providers/calm_home_projection_provider.dart`（`a07e0863573db74fd7705a4657cdedc3295ba91c`），已经有 Calm State Hub、Readiness/Match/Connection/Conversation synthetic 摘要与 next-decision，**不能重画/重写当作本版新能力**。
- `app/router/app_route_names.dart`（blob `d831a56e7f8a7bb162b25f390128b3c004042e68`）与 `app/router/app_router.dart`（blob `bd68bfecff4a424cf580ec8bee058952122032e1`）已有 `/home`、`/progress`、`/progress/match`、`/progress/connection`、`/messages`、`/me/readiness`。真实 `ProgressPage`（blob `8dd79b804c0d82a52eff5f876918d0f4673b2ed4`）提供 Match/Connection 入口。既有 `home_page_test.dart`（blob `8e1f7ac22bce5f551c0dbf5faa66968b0551848d`）测试 Home 卡片与**stub GoRouter** 下的部分 unknown/failed/loading 路由回退；**它不是已证的同一真实 app router 完整状态切换链**。
- `ConnectionPresentationController`（blob `8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f`）已有可选 dev-only synthetic 状态驱动；`APP-INT-04` 先前只接受 Flutter **demo-local synthetic** Conversation consent/list/read/send/relock，不等于后端 live grant。v10.0.0～0.2 的资格 diagnostic parser/widget 严格**仅 Debug/Test 且不接聊天**，本版不将其接进 Home、Progress 或正式用户数据/权限。
- BE-12 七条真实私密消息路由固定 opaque404，V57/H1/H2/D0不因新版规划激活；`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 保持。

## 2. 建议唯一开发主目标（Codex 版前核查后再决定冻结）

**以真实 Flutter AppShell/GoRouter（不是 Home 单元测试的 stub router）为载体，验证 MVP `Home → Progress → Match / Connection` 对已有 synthetic Readiness/Match/Connection 状态的**跨页面消费、下一步导航与失效回退**。只在检测到已接受实际实现中的具名缺口时进行最小补齐，不能重造已接受 UI 或增加未证 authority。优先产出真实消费者测试 + 必要产品代码修复，而不是再次建一条完全隔离的诊断视图。

### 候选 A｜已有实际资产与覆盖差异（版本前只读）

1. 以最新远端 main（草案前代码SHA `9a2ede6c30eb6476950fb071d230d95a9afd4308`）与 Codex clean 隔离基线为源，核对 existing `HomePage`、`CalmHomeProjection`、`calmHomeProjectionProvider`、`AppShell`、`app_router`、`ProgressPage`、`MatchPortalPage`、`ConnectionPage`、`NavigationGuard` 及其**当前测试**。
2. 把目标行为分为 `ALREADY_ACCEPTED_AND_ACTUALLY_TESTED`、`PRESENT_UNTESTED`、`PARTIAL`、`LOCAL_ONLY_UNVERIFIED`、`MISSING`、`PAUSED_OR_PROTECTED`、`UNKNOWN`；与原脏根可能的 `SyntheticRelationshipCard`、App router、通知返回路径等不同成果仅按本任务是否需要比较，不默认带入。
3. 若跨真实 Router 的状态消费及失效闭环**已经在其它固定接受测试中完整证明**，不得重复实现；Codex须提出**一个**最邻近、真正尚缺的 Home/Progress 下游安全消费者增量，保留产品价值，不为补测试数量制造新需求。

### 候选 B｜Home/Progress synthetic 主路径（冻结前确认真实缺口）

按既有 `Home | Progress | Messages | Me` 结构**不添加入口/页签**，复用实际状态 provider 与真实路由，建议最小可测序列：

1. `Readiness` 不完整/UNKNOWN时：Home只给“准备状态”安全入口；不得因为 Match旧缓存/本地 synthetic 状态越过已有 `NavigationGuard`。
2. Readiness synthetic ready后，在**Match ROUND 真可用/不可用/加载/错误/closed**不同来源状态下，Home的摘要/Next decision与 `Progress / Match` 真实页面一致；无权威/无可用提案不生成 Connection或聊天 action。
3. 进入 `Progress / Connection` 只展示经已有 Connection Presentation 合同允许的 synthetic 流转；当连接尚未建立、paused/closed/失效时不能显示错误的 active 或跳至可发送消息。
4. 当进入后发生**revoked、stale、provider error、navigation back/resume** 等可实际模拟的变更，Home、Progress 同一运行上下文自动刷新/回退到保守状态，不能残留先前的“下一步可继续”CTA。若现有 producer 没有定义 stale/revoked 语义，不得发明 authority；按 UNKNOWN/NOT_ESTABLISHED 合同降级。
5. 关于 Messages：可以把**不可越权进入真实 read/send**作为纯负向保护测试，不改 Chat provider/正式路由，也不在本版证明真实通信。只有已接受 demo-local synthetic 消息状态可与 UI 关联时，必须明确其 synthetic 标识与独立 MC，同意不是 Connection 自动赠予。
6. 核验真实 `AppShell` 与 Router 是否可在无真实 auth/HTTP/外部依赖条件下用受控 provider/fixture 测试。若运行真实 router 会调用不可隔离的真实账号/远端/生产操作，停止该路径并报告；不要通过替换 Product 权威或打开消息路由造 PASS。

**任何要修改的现有运行时代码必须是具体失败所证明的必要修复**：不得为了交付量扩充 Home UI、增添营销推荐、关系暗示、全局 AI 分数或无关重构。具体写入白名单由 Codex 版前基于真实代码给出，Astra 冻结时绑定。

### 候选 C｜同一 App 下的有限联合回归与交付

- 验证层优先是**真实 GoRouter/AppShell + state providers 的 widget/integration tests**，而不是另造 mock Router 重复 `home_page_test.dart` 的已有 PASS。测试应有独立场景 oracle、实际界面文案/按钮/路由、状态变更前后无旧成功/权限残留，明确只读导航与禁发消息。
- 必要时有界执行与目标直接依赖的 Flutter widget/provider、既有 Product Connection/MC dev-only tests；不机械重跑 v10.0.0 301、v10.0.1 294、v10.0.2 28 全套，也不把以前的通过视作新候选运行 PASS。
- 如果上述需要新 device/SDK/Android build/install、生产 API/账号或者正式服务器调用，**不纳入当前可执行版**；平台证明需要独立由 Owner 允许的精确 gate，不能从2026旧 M5 任务或此前部分 mock PASS 推出。
- 保留真实失败/诊断/修复、原生 stdout/stderr 与 exit、可信 source/fixture 身份和有限 GitHub manifest；不要发布可能包含凭据、机器网络/设备详情的原始自动诊断日志。最终代码与安全证据发布独立候选固定 SHA/tree、Astra 独立验收；按照 K08，在本版验收后再做安全 GitHub 定点集成+本地新基线接续。

## 3. 本版拟排除（不能静默解冻）

- 全新 Home/Progress UI redesign、将 v10.0.2 资格 diagnostic Widget 接进正式导航、增加顶层 tab/Discover feed、Relationship Phase2 工具。
- 新/改真实 Laravel route、可信 source writers、CN/MC/Conversation live authority、实际 `/api/v1/messages` 放行、真实消息/账号内容、持久化写入/迁移/隐私缓存。
- 生产 DB/API/SSH、密钥、下载/升级 SDK/依赖、Android 设备安装/正式运行、部署发布、正式内测、Safety Operations、隐私数据审阅。
- V57/H1/H2/D0、旧 Work/Dot 实时监督或旧被拒任务复活。其他业务领域与历史冻结 `plan.md`、独立接受正文不可改写。

## 4. 暂拟可观察 AC（**非冻结门**）

| 草案 P-AC | 希望 Codex 证明 |
|---|---|
| P-AC01 基线与复用 | 固定最新主线代码父SHA/隔离本地候选、既有 Home/Progress/Router/相关 accepted 测试的具名 Blob 与准确缺口、原 dirty root保护，**不重复已接受闭环** |
| P-AC02 真实跨页消费 | `Home` current state/next decision→实际 `AppShell` + `Progress Match/Connection` 的受控 synthetic 状态驱动，真实 route与消费者有可观察测试；不以 stub router 冒充 |
| P-AC03 失效安全回退 | 不完整/UNKNOWN/loading/error/closed/revoked/stale（仅实际支持者）导致一致的保守 UI/CTA/路由，旧 active 不残留，不生成 live message action |
| P-AC04 真实限定回归 | 最终代码身份下必要相关 tests exit0，原失败/诊断保留，明确 NOT_RUN/范围，禁用远端服务与真实数据 |
| P-AC05 可独立验收 | 固定 GitHub candidate/commit/tree、需要的代码/fixture/原始安全证据/有限manifest 完整可读，权限边界与 retained gaps 具名 |
| P-AC06 收口和集成 | Astra 依冻结标准独立验收/复盘，分别记 Acceptance、GitHub定点集成、新本地隔离开发基线与实际基线回归，**不自动启动后继** |

如 Codex 证明关键跨页场景已经完整接受或需要保护权限才能验证，Astra 应在**冻结前**调整/替换为一个唯一的真实缺口，不在实施中放宽 AC 或做“纯文档替代产品增量”。

## 5. Codex 本轮只读可行性核查（Owner 手动转交）

建议入口：已核的隔离 clean 开发基线 `C:/Users/zcxve/.codex/worktrees/elitesync-main-2175dd6/EliteSync-v10`；它的旧 HEAD `2175dd...` 是真实本地基线，落后当前远端一项文档提交，但不能由此假定有源码冲突。先定点 fetch/ref 比较，**本次不许为了核查而移动原 root、其 index 或随意 fast-forward 既有隔离分支**。

请集中回答：
1. 验证最新 GitHub `main`、该 clean worktree 本地HEAD/tree/status及历史保护；核真实 Home/Progress/Router/Guard/Readiness/Match/Connection code+tests，区分已通过/有代码但缺运行/本地独立/真正缺失。若旧根有相同实现，避免重复。
2. 根据目标 A–C 提出一个**真实可实施的 Home/Progress 跨真实Router消费与 invalidation 路径**，说明具体从哪里获得 synthetic 状态、哪些 route/provider 具备，哪些是未授权假设；至少一项可观察的必要产品代码改动还是仅测试缺口，诚实区分。
3. 指定有限的**源/测试文件白名单**、最短测试场景、能在隔离且无真实外部调用的条件下运行的可行性、预计工作量。若真正产品实现已完整具备且可独立验收，给唯一邻近替代（不重复改功能）。
4. 确认不动 Chat 权威、不引入真实隐私数据/BE-12解除、不更新 SDK/设备；无法隔离真实 AppShell 依赖则给一项明确阻碍而不是自行开新HTTP endpoint。
5. 对六条 P-AC 给出精简冻结建议与证据层级，未知写 `UNKNOWN`；不得在版前执行开发或应用测试。
6. 以 `V10.0.3 PLAN REVIEW — READY / READY_WITH_FINDINGS / BLOCKED — IMPLEMENTATION_NOT_AUTHORIZED` 汇报，Owner 将整份回报转交 Astra 再决定是否冻结。

**收尾：`V10.0.3 PROPOSED — AWAITING CODEX FEASIBILITY REVIEW — NO IMPLEMENTATION AUTHORIZATION`**
