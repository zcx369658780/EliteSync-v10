# EliteSync-v10｜v10.0.3 正式冻结版本计划

> **FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**  
> **唯一工程目标**：在**真实 `GoRouter + appRouterProvider + AppShell`** 中证明并修复 Guard 动态变化下的刷新、合法深路径保持、禁止路径安全重定向和 Router/监听资源释放。只修复实际测试证明的路由缺陷；不重做已经接受的 Home synthetic 主循环，不开真实消息权限。  
> 冻结日期：2026-10-13（Asia/Shanghai）。Astra 基于 Owner 已启动的 v10.0.3 规划及 Codex `V10.0.3 PLAN REVIEW — READY_WITH_FINDINGS — IMPLEMENTATION_NOT_AUTHORIZED` 的有界反馈形成。  
> **冻结身份**：以此 `plan.md` 在 GitHub 实际发布的**固定提交 SHA / Git Blob**为权威；候选源码的**唯一父提交**固定为 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`。正式计划发布不等于开始实施，必须由 Owner 手动发送固定链接和明确执行授权给指定 Codex 会话后才可开发。冻结后不得为满足测试而改写 AC 或扩大权限。

## 1. 已接受成果、准确技术基线和未证故障

- GitHub `zcx369658780/EliteSync-v10`：本版固定**代码父提交** `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`，Tree `a25fc46be72056b4940923c45fab81367f17fd2a`。当前原本地新隔离开发基线由 Codex 回报为 `C:/Users/zcxve/.codex/worktrees/elitesync-main-2175dd6/EliteSync-v10`（branch `codex/local-baseline-2175dd6`、HEAD `2175dd62...`，CLEAN），与固定父提交相比仅在**五份规划/记忆/状态文档**存在差异、无产品源码差异；不得为本版覆盖此既有可用基线或原始脏根，建议新建独立候选 worktree。
- 仍受保护的原 `D:/EliteSync-v10` main HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`，默认 index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`，staged0 / tracked修改43 / untracked normal208，109项具名资产受保护；**网页未直接核验本机当前实时字节**。在实施开始和结束只作必要保护回读，不全仓归零或一次性吸收旧本地成果。
- 已核 [APP-INT-05 旧接受](../../../../EVIDENCE/APP-INT-05/summary.md)：`ACCEPT — synthetic Home live-state main loop only`；既有 Home 可按 Readiness→Match→Connection→独立消息同意→Messages 的 synthetic 次序导航，Connection关闭导致本地同意清除/relock。17项历史 targeted tests 和有限 Android 作者回执属**此前固定候选的历史证据**，不是本版或真实后端/设备 PASS。该主循环不重做，不能把其“接受”扩大为当前真实 Router 动态失效已验证。
- 目前 GitHub 代码 `apps/flutter_elitesync_module/lib/app/router/app_router.dart` Git Blob `bd68bfecff4a424cf580ec8bee058952122032e1`：`appRouterProvider` 在 Provider build 中 `ref.watch(navigationGuardProvider)` 并新建 `GoRouter`，redirect 中 `ref.read(navigationGuardProvider)`。**源码确认构建依赖，动态路径是否错误重置、监听是否泄漏属于 `NOT_RUN/NOT_PROVEN`，须先用真实 Router 测试复现或验证，不能事前写成已发生的 bug。**
- 既有 `navigation_guard_provider.dart` Blob `f15eb57367349664dbc057424bae66bf5287473b` 仅以可信 auth 与显式 Dev synthetic 标志建立 Guard 快照，不制造正式 readiness/Match/Conversation authority。既有 `calm_home_projection_provider.dart` Blob `a07e0863573db74fd7705a4657cdedc3295ba91c`、`connection_presentation_provider.dart` Blob `8c5fe6ee3e1e5cf0a6224581988f435ce22a6e5f` 与 Home/Progress UI 仍是现有资产，**不重写**。
- 既有测试 `test/app/router/match_legacy_redirect_regression_test.dart`（blob `cbe7e7002deceab90dad0911926b1a7dd36f1669`）、`first_use_onboarding_router_integration_test.dart`（blob `2761348f172880e097a327f48ab265e7926d6268`）和 `home_page_test.dart`（blob `8e1f7ac22bce5f551c0dbf5faa66968b0551848d`）覆盖初始路由、既有导航/单页状态及部分降级；缺少 Guard 在**同一已安装 AppShell/Router** 运行过程中变动的针对性证明。独立的 [v10.0.3 草案](PLAN_PROPOSAL_V0_1.md)保留历史版前来源，不是正式执行依据。
- 既有 v10.0.0～v10.0.2 `ACCEPTED/CLOSED WITH OBSERVATIONS`；Owner 授权的 17项必要代码/测试/工具已定点进入 GitHub main，且 Codex 回报新隔离基线范围回归 PHP294/3420、PHP12/930、Flutter28 和 BE-12 pure middleware8 通过。两类不同来源的证据不能当本版 Router 动态测试或生产资格。
- 产品 IA `Home | Progress | Messages | Me`，`Match != Connection != Conversation != Relationship`；`PROJECTION != PERMISSION`；BE-12七条私密消息路由保持默认404；V57/H1/H2/D0未激活、`NOT_READY`/`RuntimeReady=false`/`M6 CLOSED` 等不变。

## 2. A｜真实动态 Guard 复现与最窄 Router 修复

**唯一允许修改的现有产品源码：**

`apps/flutter_elitesync_module/lib/app/router/app_router.dart`

- 在与真实应用一致的 `appRouterProvider + GoRouter + StatefulShell/AppShell` 挂载场景下，首先设计/运行可观测的 Guard 更新测试：固定 AppEnv/路由拓扑下，注入合法的虚构 Auth/Readiness Guard 状态变化，观察**同一 Router 实例、当前 path、redirect、页面组件及实际监听释放**。先留修复前失败或基线 PASS 事实，不得仅凭 `ref.watch` 源码就宣布页面已错误跳转。
- **必要行为合同**：Guard 改变时，不以重建 Router 并回到 `initialLocation` 代替规则重新评估；未被新 Guard 禁止的当前深路径、query/可保留的导航上下文应稳定，已有 AppShell / Tab / GoRouter 内层实际页面不因无关 Guard 更新丢失。已禁止的路径按**现有** redirect 规则安全重定向；不新增业务授权、回退政策或“恢复自动跳入旧受保护路径”的逻辑。
- 真实 Guard 已支持的失效顺序优先于理想状态：未登录访问非公开页按既有规则到 `login`；已登录但 Readiness 不成立时对 `/progress/match` 及既有 Match legacy deep paths 重定向到 `/me/readiness`；后台/源 UNKNOWN 不自行提升为 Ready。无关 Guard 快照变更不得强迫合法 Home/Progress/Connection 跳回 Splash/Home 或使旧 Router 继续响应。
- 调整 Router 的刷新桥、稳定性和销毁生命周期可由 Codex 在**该文件**内按已安装 GoRouter/Riverpod API 采取最小方案：确保 Guard 真正触发 redirect 的 reevaluation；生命周期拥有者注销/释放监听与 Router，避免双释放、旧 Router 存活或刷新死循环。不得重定义 `navigationGuardProvider`、改变 `AppShell`、NavGuard/状态数据结构或变更实际 auth/Readiness policy；若本边界无法实现，保留现场报告 `BLOCKED_SCOPE_DECISION`。
- 若测试证实既有路由无缺陷且行为完整通过，**不进行无依据产品代码修改**。交付以真实未覆盖的针对性回归测试和可解释的未证边界为范围内成果；如仅缺测试而确无新的运行时改动，诚实登记，不为凑开发量制造缺陷。

## 3. B｜唯一新测试与真实安全隔离

**唯一新增/修改的产品测试范围：**

`apps/flutter_elitesync_module/test/app/router/home_progress_guard_refresh_test.dart`

- 使用**真的** `appRouterProvider`、`MaterialApp.router`、`StatefulShell/AppShell` 及实际 `Home/Progress/Match/Connection` 路由；可以复用现有 `match_legacy_redirect_regression_test.dart` 和 `first_use_onboarding_router_integration_test.dart` 的安全内存 storage/provider test harness，不得把路由体系替换成 `GoRouter(routes:stub...)` 冒称通过。
- 构造可持续变化的测试层 Auth/Readiness Guard 快照（虚构状态），在**同一 mount 的 ProviderContainer/router 期间**实际更新 Provider，驱动真实 Router 重新评估；单独把新 App 的初始 Guard 设为失效只证明静态启动，不满足本版动态 Gate。
- 提供真实可观察的测试序列：①初始未就绪/UNKNOWN 的 Match 深路径安全到 Readiness；② synthetic Ready 时可从 Home→Progress→Match/Connection 的真实入口导航；③在 Match 深路径切换为 Readiness UNKNOWN/setupRequired 后**立即**安全重定向；④仅改 Guard 非禁止维度时，合法 `/progress`、`/progress/connection` 或 Home 保持当前路径与活跃页面；⑤同一挂载中失去 Auth 后非公开页归到 login；⑥在逐次更新、unmount/dispose 后无旧 Router refresh callback、Router 生命周期 double dispose 异常或不受控路由跳转。
- 同域 Home 状态/Next Decision 的一致性作为有限测试，确认受控 Match loading/error/failed/closed/no candidate 与 Connection paused/closed 后不会把旧 Active/synthetic 状态误标为新消息授权。**仅现有 provider 已支持的 synthetic 状态与失效语义可作为真实行为**；如需自行造出的 stale/revoke 真实来源，记 `UNKNOWN/NOT_PROVEN`，不得用 fixture 赋正式权限或捏造政策。
- **零真实外部调用**：测试用内存 storage、已支持的 mock data、受控虚构 match/guard、RTC watcher disabled；对触发外部 API/网络/持久存储的提供者设显式 fail-fast sentinel 或可读的计数断言。**单独将 HTTP URL 指向 localhost 不构成隔离证明**。若现有 AppShell/Router 无法在不启用真实服务、账号、HTTP/设备的条件下隔离，停止越界点并交付已完成的安全证据，不调整业务权限来凑 PASS。
- 路由路径/导航历史的精确持久规则仅针对当前已有语义测试，**不新增** Readiness失效是否撤销已成立的 Product Connection 这种未定政策。Query 保持只在原路由模型适用且实际可见的合法路径下要求，不能自动恢复原受限界面。

## 4. C｜有界执行、原始证据及独立验收

- 除已有源码 `app_router.dart` 和新测试 `home_progress_guard_refresh_test.dart`，只允许在 `docs/versions/v10.0.3/` 新增**一个可选的有界测试验证脚本**、执行报告、有限 manifest、JSON回执和经过敏感检查的必要原始 stdout/stderr。仅为安全测试隔离必需且不影响全局的配置可以放版本目录；任何额外产品源码/测试路径修改均须触及冻结边界而停下报告，不自动追加。
- 只运行本版动态 Router/Test 与实际受影响的已有原路由/首页必要测试；不机械重跑 PHP294、Flutter28、历史 APP-INT-05 17 项或旧 M5 全链。实际未执行写 `NOT_RUN`；运行失败保留退出码和原始失败，普通环境错误由 Codex 同版诊断、修复、重测。
- 所有测试/依赖不得下载/升级 Flutter SDK、Gradle、包、全局工具，不使用账号、生产 API/DB/SSH、真实消息/RTC/设备/私密信息；测试要有明确零外部调用证明，不仅依赖“作者没有主动请求”。隔离 worktree 可复用**已存在**的可信 Flutter package graph/缓存，但不得改变全局依赖或原本地 root；记录来源及编排。
- 最终将**有限、安全**的源码、测试、manifest、直接运行收据/证据在 GitHub **独立候选分支**固定 commit/tree 发布以供 Astra 真正读取；源/测试身份、代码单父、stdin/out、error streams、实际测试命令/计数、受保护文件和结果必须能核查。自动诊断日志包含本机路径/设备/网络/敏感信息则应本地保留原证，远端只发布安全脱敏证据并说明证据层级，不削弱失败事实或重写旧 raw。
- 原始干净隔离基线 `codex/local-baseline-2175dd6`、原 `D:/EliteSync-v10` 脏根、默认 index、旧worktree、109项保护文件、历史 EVIDENCE 和旧 v10.0.0～v10.0.2 冻结/验收原件保持。版本候选**不自动合入 GitHub main**；验收后按现行长期规则 [CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md) 在 Owner 已批准的流程内安全定点集成和手动本地基线接续，不自动建立新产品版本。

## 5. v10.0.3 冻结验收标准 AC-01～AC-07

| AC | 独立可观察 PASS 条件 |
|---|---|
| **AC-01 精确代码基线与去重** | 候选单父是 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`、原新隔离基线和旧脏主树不受覆盖；Codex 定点保存 Home/Progress/AppShell/Router/Guard 正确文件身份、历史 APP-INT-05 已接受事实及本版本实际新增缺口，未重复实现主循环。 |
| **AC-02 动态路由的真实验证** | 使用真实 `appRouterProvider + GoRouter + AppShell` 的同一次挂载，已有 Guard 从有效→变更后触发正确 redirect；测试实际覆盖 Home→Progress→Match/Connection 和至少一次 Match 深路径失效→Readiness；不以 stub Router、新建 App 起始场景冒充动态刷新。 |
| **AC-03 合法路径和生命周期** | Guard 不相关/非禁止维度改变时合法当前路径/页面保持、不被重新 initialLocation；Auth loss→既有 login、Readiness loss→既有 Readiness；Guard 连续变化/Router dispose 后无错误的残留刷新、双释放或逻辑死循环。必须提供实际组件/路径断言而不只 grep 源码。 |
| **AC-04 不越权与无旧状态残留** | Readiness/Match/Connection 基于真实已有 synthetic provider 的保守状态/CTA，在 UNKNOWN、loading/error、closed/paused 等可观察输入下不保留误导性旧成功与消息许可；没有真实消息 writer/read-send callback、额外状态源、权威/政策发明或业务持久化。 |
| **AC-05 有界真实回归与无外部调用** | 最终候选的动态 Router 新测试、直接必要既有路由/首页测试实际执行 `exit0`，保留初次失败→修复→最终回执；明确验证无外部 API/网络/生产存储/RTC副作用。若某历史场景无法安全执行，只能明记 `NOT_RUN/BLOCKED` 并据证据决定整体 AC，不能自称 PASS。 |
| **AC-06 固定证据可供 Astra 复核** | GitHub 固定候选提交/tree、修改路径有限 manifest、新测试/源码、测试命令/原始安全日志与退出码、原工作树保护回执、真实缺口和 `NOT_PROVEN` 均可独立读取；网页验收和本地作者测试层级明确。 |
| **AC-07 独立验收与安全接续** | Codex 集中交付后 Astra 对照本计划实际冻结 AC 独立终裁并复盘，分别记 Acceptance、GitHub scoped Integration、新本地隔离开发基线、整合后回归；候选不自动合并、V57/H1/H2/D0 不恢复、没有自动 v10.0.4。 |

**无法通过真实测试证明某一设定的情况下，只能如实记 `NOT_PROVEN/PARTIAL/BLOCKED`，不得在实施期回写更弱 AC。** 原本已合法的路径语义与资源安全不能为追求代码变更反而退化；若只需测试即可证明现有实现正确，允许无产品源码改动的准确交付。

## 6. 保持暂停及执行方式

- 新真实账号、OAuth/session、实时 source writers、消息/Conversation read-send、BE-12七条 live 路由/HTTP、设备/Android release/install、持久化恢复、生产环境、真实权限及真实数据、对隐私/安全或政策语义的定义均**不在范围**。
- `Readiness` 丧失是否撤销已建立的 `Connection` 仍是未确定产品政策；本版不得自行决定、不得改变 `ConnectionPresentationController` 状态机制。Home 下一步只导航且不生成真实聊天许可。
- 源码和测试之外不动 Home/Progress/Main/AppShell/NavigationGuard/Match/Connection/Chat、诊断 Widget 的已接受行为；需修改排除文件才能修复时，只报告具体所需权限与最小证据，不能暗中纳入。
- 未授权的 UAC、SDK/依赖升级、生产 DB/API/SSH、隐私数据、敏感自动日志发布、部署/上线、真实平台 M5/M6资格等，均不可执行。
- 由 Owner 以冻结计划**固定 GitHub 提交**手动派发给指定 Codex 后才实施。Codex 冻结范围内自主编码、诊断、必要修复及回归，不需要微步骤审批。结束时向 Owner 交付候选和实际运行证据，等待 Astra 最终独立验收；不自动开始下一版。

**`V10.0.3 FROZEN — REAL_GOROUTER_DYNAMIC_GUARD_REFRESH_AND_SAFE_PATH_RETENTION — AWAITING_OWNER_MANUAL_DISPATCH`**
