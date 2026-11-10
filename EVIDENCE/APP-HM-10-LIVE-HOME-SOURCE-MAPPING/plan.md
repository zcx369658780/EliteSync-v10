# APP-HM-10｜Home 活态来源边界静态映射（候选）

日期：2026-09-29。仅 docs-only、当前本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。结论：**APP-T12 G-08 `NOT_READY`**。本轮可确认 Flutter Home 的静态/显式 dev synthetic 展示路径，以及 Laravel 的内容端点和非权威只读组合函数；在本任务限定的入口与直接调用中，没有能供客户端消费、并以当前 actor/audience 绑定四领域来源的 live Home 合同。这个限定范围内的未发现不等于断言仓库其他位置绝对没有相关代码，更不证明真实权限。

## 两轮静态核对回执

| 轮次 | 固定来源与方式 | 发现 |
| --- | --- | --- |
| 1/2 | 根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`、APP-HM-09 `work-review.md`；交付计划与 APP-T12 重审结果；固定 Flutter Home 三文件、Laravel `HomeController.php`、`CalmHomeReadOnlyCompositionEvaluator.php`、`routes/api.php`；当前仓库 codebase-memory 图谱精确符号查询。 | 交付计划 M4 要求消费已接受 producer，Home 静态基础不得冒充活态；APP-T12 G-08 标为 `SEPARATE BACKEND AUTHORITY REQUIRED`、`NO`。图谱该次仅返回 `HomeController`，对 Dart/provider 与 evaluator 不充分，因此以固定源码读取为准。 |
| 2/2 | 任务列明的 Match、Connection、Conversation provider/状态与直接依赖 `navigation_guard_provider.dart`；上述 Laravel 路由、控制器、evaluator 的定点复核；Home 现有 datasource/测试路径的有界字符串核对。 | 确认 Match 是独立 FutureProvider，Connection/Conversation 非 dev 回退未建立；`/home/*` 现有路由只指向内容控制器。一次定点测试文件定位包含不存在的 `tests/Feature/HomeApiTest.php`，该文件没有作为证据；不由缺失推断测试全集。 |

未运行测试、构建、包管理、网络或 DB 命令。下述“无/未建立”只针对上述固定来源与调用链。

## Flutter Calm State Hub：实际输入与输出

`lib/features/home/presentation/pages/home_page.dart` 的 `HomePage.build` 只 `ref.watch(calmHomeProjectionProvider)`，将 `projection.summaries` 渲染为 Current state，并把 `projection.nextDecision` 作为唯一主按钮的文案和 `context.go(...)` 路由；页面本身不获取后端 Home 合同。`state/calm_home_projection.dart` 定义四域摘要、authority 枚举、可空 `stateCode` 和无已判定决定时的“查看进展”回退；`CalmHomeProjection.current` 是固定的 `notYetEstablished` 摘要，默认导航准备状态。

| 摘要/决定 | `calm_home_projection_provider.dart` 的输入与条件 | 当前可陈述的来源等级 |
| --- | --- | --- |
| Readiness | `navigationGuardProvider.readinessState`；unknown 时 `authority=unknown`、`stateCode=null`，其余输出状态名。直接依赖的 `navigation_guard_provider.dart::resolveReadinessGuardState` 仅在认证且 dev synthetic flag 时返回 ready；普通认证返回 unknown。 | 显式 dev synthetic 或 unknown；不是已接受的运行准备度 producer。 |
| Match | `matchRoundProjectionProvider` 的 `AsyncData` 经 `CanonicalMatchLifecycleAdapter.fromRound` 提取 condition/targetState；加载/读取失败为 unknown；`transportUnavailable`、`closedWithoutCompletionEvidence` 亦为 unknown；明确 condition/targetState 才使用 synthetic 摘要。直接 provider 是 `FutureProvider`，读取 `MatchRemoteDataSource.getRoundProjection()`，其存在不等于 Home live 权威。 | 显式 dev synthetic 展示，或者 unknown；Match 投影/传输状态不可升级为 Home 权威。 |
| Connection | `connectionPresentationProvider` 的 `hasSyntheticDevelopmentState` 与 `state?.code`；非 synthetic 为 `notYetEstablished`。其 controller 的 `build` 仅在 dev synthetic flag 下初始化本地 `CN_NONE`，否则返回 `notYetEstablished`。 | 纯本地 synthetic 生命周期或未建立。 |
| Conversation | `conversationAccessProvider` 的 `hasSyntheticDevelopmentState` 与 `state.code`；非 synthetic 设 `notYetEstablished` 且 Home `stateCode=null`。其 controller 的 `build` 在非 dev synthetic flag 下清除本地生命周期并返回未建立。 | 纯本地 synthetic 生命周期或未建立；内部 `CV_LOCKED` 不能当真实同意结论。 |
| Next decision | readiness、Match condition、Connection/Conversation 本地状态形成硬编码导航分支；readiness/Match 不确定或后继状态未建立时不发布 synthetic `authoritativeNextDecision`，由模型回退“查看进展”。 | 页面导航/人工演示决定；没有真实 writer、权限或下一步权威。 |

`calm_home_projection_provider.dart` 最前面的非 dev 或未启用 `useSyntheticHomeProjection` 分支直接返回 `CalmHomeProjection.current`，不读取上述四个状态，也不调用 Laravel Home。APP-HM-01～09 已接受的只是这些限定 synthetic/页面行为；APP-HM-09 `work-review.md` 明确真实 G-08 未关闭。

## Laravel：已有能力及与 Home live 合同的区别

`routes/api.php` 的现有 `home` GET 路由只有 `/banner`、`/shortcuts`、`/feed`，均指向 `HomeController`。`HomeController::banner/shortcuts` 返回 `config('home_content.*')`，`feed` 读取 tab/scene/city/tag 等查询参数，分页、排序并返回内容 items/meta；`discoverFeed` 和 `content` 也处理内容面。`features/home/data/datasource/home_remote_data_source.dart` 对 `/api/v1/home/banner|shortcuts|feed` 的调用属于这一旧内容面，不能据路径中的 `home` 推定为 Calm State Hub 的 readiness/Match/Connection/Conversation 当前态来源。当前固定 `routes/api.php` 中没有指向 `CalmHomeReadOnlyCompositionEvaluator` 的 live Home 路由。

`app/Domain/CalmHomeReadOnlyCompositionEvaluator.php::compose(array $domainInputs)` 是**纯只读组合函数**：接受调用者给的四域输入，按 record kind/分类/`valid_for_protected_use` 等条件投影 fragments，缺少域变 unknown，冲突 fail closed；对可用的 action candidates 校验 context identity，只有唯一有效候选才给 `primary_action`。`invalidate` 可按 dependency identity 和 correction/revocation/supersession 使片段失效并重算决定。结果的 `record_kind=CALM_HOME_READ_ONLY_COMPOSITION`，但 `nonAuthorityFields()` 显式设置 `source_authority=false`、`permission=false`、`bearer_capability=false`、`launch_authority=false` 等。该函数不签发四域来源，不负责鉴别当前 actor/audience，也没有由上述 Home 路由调用。它的内部 schema 也不是 Flutter `CalmHomeProjection` 的客户端可消费传输合同；不能把 evaluator 存在或 `valid_for_protected_use` 输入标记推成现实已核验权限。

## G-08 仍缺的精确桥接

1. **Producer**：四域的当前有效来源及依赖身份未由 Home 链签发。Readiness 的普通运行输入为 unknown；Match 的独立投影可读不证明 Home 当前态/动作；Connection/Conversation 普通分支未建立。`CalmHomeReadOnlyCompositionEvaluator` 要求调用者提供派生输入，自己不是 producer。
2. **Actor/audience 与时效**：限定的 `HomePage → calmHomeProjectionProvider`、`routes/api.php → HomeController` 与 evaluator `compose` 调用签名没有一个经核验的同一 actor/audience 绑定和当前失效传播链。内容 feed 对 `$request->user()` 取 city 仅用于内容排序，不能转化为四域 Home authority。
3. **传输/消费合同**：没有在这些固定 Home 入口中发现把四域派生/失效结果组装成 actor 绑定的 live Home HTTP 响应并由 Flutter Home 消费的路由、解析与安全降级规则。后端 evaluator 的 `sections`、fragments、候选字段和 Flutter 的 `HomeStateSummary`/`HomeNextDecision` 也尚无已接受映射；状态名和权限语义不得凭形似直接对接。

因此仍依 APP-T12 G-08 `SEPARATE BACKEND AUTHORITY REQUIRED / NO`，且 G-05/G-06 的 Connection/Conversation runtime authority 缺口不能被 Home 显示或既有内容 feed 代替。未触及 AUTH-170、AUTH-155 Phase B、真实 CMS 认证/隔离恢复或账号回填。

## 仅建议一张后继最小工程切片（未发布）

建议一个**纯本地 Flutter 合同解析/失败关闭切片**：以人工构造的 `CALM_HOME_READ_ONLY_COMPOSITION` envelope 为输入，新增一个独立纯函数，将 `source_authority=false`、缺域、冲突、失效和不支持 schema 明确映射为 Home `unknown/notYetEstablished` 与无已判定决定；即使有 `primary_action` 也不把它变成路由或权限。候选允许文件可限为新建 `apps/flutter_elitesync_module/lib/features/home/data/contract/calm_home_composition_candidate_parser.dart`、同名定向测试与该任务自己的证据摘要；不改现有 Home provider/page、路由、Laravel 或真实 HTTP。定向验证只用人工 envelope 的正/负解析、未知字段/缺域/冲突/失效和无权限输出，外加格式检查；不连接网络、DB 或设备。

这张切片只固定客户端面对**非权威候选**时的拒绝/降级边界，**不**关闭 G-08。真正 live 对接仍须先有独立审查接受的四域 producer、同一 actor/audience、有效性/失效链和客户端传输合同，再另发任务；本 plan 不发布后继，也不放行真实权限或生产动作。
