# EliteSync-v10｜v10.0.1 正式冻结版本计划

> **FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**  
> **版本目标：** 已接受 Product Connection 测试增强的选择性纳入，以及 `真实 PHP 资格评估 → 当次生成的 synthetic 诊断 JSON → Dart 独立只读诊断消费`。只做非生产诊断链，**不做**后端到 Flutter 的正式聊天消息桥或在线消息授权。  
> **冻结日期：** 2026-10-13（Asia/Shanghai）。网页 Astra 根据 Owner 已发起的 v10.0.1 规划及 Codex `READY_WITH_FINDINGS` 版前核查冻结 A+B+C。  
> **冻结身份：** 以本文件发布于 GitHub 的**实际提交 SHA**与 `plan.md` Git blob 为准；不在文件中自写自身 commit。  
> **权力边界：** 本文件发布不自动启动工作。仅 Owner 将**固定链接与明确的执行授权**手动交付本地 Codex 后，才准许在本文范围内编码、测试和发布隔离候选。历史 [版前草案](PLAN_PROPOSAL_V0_1.md) 保持未冻结的历史身份，不替代本文件，也不通过后续修订调整本版目标、范围、验收标准。

## 1. 固定来源与执行基线

- 仓库：`zcx369658780/EliteSync-v10`；本地工作根 `D:/EliteSync-v10`。截至本计划发布前实读 GitHub `main` `1ad10e6df2bd99da17342850cd6b21a1ea4e855b`（**文档提交**，不是代码父提交）。[现行工作流](../../workflow/CURRENT_WORKFLOW.md)、[状态](../../../CURRENT_STATE.md)、[动态目录](../../../DOC_INDEX_CURRENT.md)、[版本登记](../README.md)。
- 由 Codex 最新只读回报、**尚非网页直接本机核验**：本地 `main` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、默认 index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`、staged 0、tracked 修改43、untracked normal208。结束只读核查后未发生改变。**代码候选的唯一父基线固定为 `4bebc8f394248e254c1368a06fbdee5d2c883301`**，禁止把当代 GitHub main 文档提交当源码父基线。
- [v10.0.0 历史验收](../v10.0.0/acceptance.md) `ACCEPTED/CLOSED`；唯一候选 `18daf9746e2f031fbbbe18682bf0c742aad92a09`、tree `e5ee225f8084dd275278337bb90a8a5414ef6e22`；**Integration Status = NOT_MERGED**。上版的新增测试文件 Git blob `5e59626a5ed640482cc786862f5e1e9c01511262`；此前代码基线测试文件 blob `f3e0d9839ea79795564b0962f36088a41735b727`。这 232 行/139 data sets 已接受，**本版不得重做**。
- Codex 本次核查：上版 26 项 selected closure 中 **25 项与本地一致、唯一待选择性纳入的是上述测试增强**。其余现存共享 repository/SQLite 和 MC family/adapter 保持后续 BE-05/BE-08 的现有字节，不从历史 R18 Phase-A 回退。
- [APP-INT-04 历史接受](../../architecture/ELITESYNC_V10_APP_INT_04_SYNTHETIC_MESSAGING_CONVERSATION_ACCEPTANCE_V0_1.md) 只证 Flutter **demo-local synthetic** 聊天闭环；[BE-12 验收](../../../EVIDENCE/BE-12-UNVERIFIED-MESSAGING-ROUTE-FAIL-CLOSED/work-review.md) 只证七条 `/api/v1` 私密消息路由默认 opaque 404。二者都**没有**授予线上 Conversation 许可。
- Codex 具名 LOCAL_ONLY 实物：`services/backend-laravel/app/EliteSync/ConversationLifecycle/LocalTestConversationLifecycle.php` 的 `apply()/readAtUsePoint()`，`services/backend-laravel/app/EliteSync/ConversationQualification/ConversationUsePointQualifier.php` 的 `evaluateAtUsePoint()`，`services/backend-laravel/tests/Unit/EliteSync/ConversationLifecycle/FixtureFourFamilySource.php`。后端 qualification/lifecycle/text-authority 中另有**共计 5 项源**及 `app/Domain` 中 **3 项依赖**，Codex 已对历史具名 owned manifest 的 8 项源码/fixture做了定向身份对照；**其余准确名称与哈希尚未发布给网页端，属于冻结实施时需要登记的精确 source-intake，而非可任意扩大读取集合的权限**。
- [R18-R1 已接受](../../architecture/ELITESYNC_V10_IP_13I_R18_R1_PRODUCT_CONNECTION_APPLICATION_BINDING_ORDER_CORRECTION_ACCEPTANCE_V0_1.md)：合同不重开，`Match != Connection != Conversation != Relationship`，`STORED != AUTHORITATIVE`，`PROJECTION != PERMISSION`，`ROUTE IDENTITY != CONSENT`。

## 2. 正式工作包 A｜选择性纳入已接受测试增强

1. Owner 手动派发之后，在 **`4bebc8f...` 单父源码基线**上建立新的隔离 `codex/v10-0-1-...` 候选工作树/分支；先核对路径碰撞、同名测试的实际内容与既有 dirty/staged/untracked，不更改原根 `main`、默认 index 或已登记 worktree。
2. **只把 `services/backend-laravel/tests/Unit/ProductConnectionPersistenceApplicationAdapterTest.php` 物化为 Git blob `5e59626a5ed640482cc786862f5e1e9c01511262`**（或如隔离候选实际已含精确相同 Git 对象则直接继承）。记录来自上版 accepted candidate 的 path/blob、原基线 blob、提交/工作树来源。其他 25 项无需盲目拷贝；保留原来已接受的适配器、共享 persistence/MC、现有测试和后续修复，不擅改合同。
3. 对此文件与其实际调用依赖进行**有限必要的 Product Connection 回归**，覆盖上版新增 data provider 与原关键条件。若已有可用的上版 11 类组合测试，可按风险执行适当缩减；不机械重跑全部大包，也不得删除原有效测试或以非运行自述代替验证。
4. 源文件已接受不等于目标分支已集成。若本版候选证实精确 blob 已在候选中，登记 `ALREADY_PRESENT_IN_CANDIDATE` 而不重复新增提交；GitHub main 依旧 `NOT_MERGED`，除非存在另行授权和真实集成证据。

## 3. 正式工作包 B｜非生产、只读的跨语言资格诊断链

**本版唯一新增跨组件能力：** 通过具名 LOCAL_ONLY fixture 驱动真实后端资格领域代码，以同次生成的 UTF-8 JSON 字节作为 Dart 只读诊断输入，在限定环境中验证解析、状态原因和全程零消息授权。**不建立聊天数据传输、业务 HTTP 路由、真实 writer 或可用聊天令牌**。

### 3.1 允许的源码纳入和新增文件

- 可从此前 Codex 已确认的 **五项** ConversationQualification/Lifecycle/TextAuthority 源、**三项**已接收 `app/Domain` 依赖及 `FixtureFourFamilySource.php` 中，按准确历史 owned manifest/path/hash 选择本版测试的必需闭包；范围只到直接所需的具名源与依赖，**不准泛化为全量 `app/EliteSync` 导入**。在改动前先保存每项 path、Git blob/SHA256、来源、必要性、接受层级到有界 intake；身份失配时不得静默升级为“已接受”，应保存并报告实质阻碍。此配置含 **LOCAL_ONLY**，网页端目前不具备它们原始字节，最后必须把必需源码与安全证据发布到可独立访问的候选固定 Git 提交。
- 精确提议并纳入冻结的 **四个新文件**：
  1. `services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/DiagnosticScenarioFactory.php`
  2. `services/backend-laravel/tests/Unit/EliteSync/ConversationQualification/export_diagnostic_fixture.php`
  3. `apps/flutter_elitesync_module/lib/features/qualification_diagnostics/domain/qualification_diagnostic.dart`
  4. `apps/flutter_elitesync_module/test/features/qualification_diagnostics/qualification_diagnostic_test.dart`
- 允许**一个**位于 `docs/versions/v10.0.1/tools/` 的有界验证编排脚本，以及 `docs/versions/v10.0.1/` 下必要执行报告、manifest/原证。若为测试运行必须新增受控 PHPUnit/test-only 配置，可在上述版本目录内建立**一个**生成/声明文件，不覆盖正式全局配置。除上述、A 测试增强及经 intake 选中的有限依赖外，不改已有产品运行时代码。
- 不允许修改 `ConversationUsePointQualifier.php`、`LocalTestConversationLifecycle.php` 的业务/状态/权威语义；它们仅为具名已有实现来源。也不修改 `routes/api.php`、BE-12 middleware、Chat provider、`ProductConversationAccessAdapter.resolve()`、任何 chat read/send callback、正式身份/权限/Writer/消息持久化类。Dart 新文件必须是**独立纯只读诊断数据模块**，不可导入/触发真实聊天 provider 和消息权限路径。
- 若不修改以上既定文件便不能真实调用现有领域函数、或出现有必需的新生产功能缺口，**不得以替换 mock 或扩大代码范围来凑 PASS**：停止该越界部分，保存原始失败与现有安全成果，报告 `BLOCKED_SCOPE_DECISION`，本计划不为此追改。

### 3.2 最小诊断合同（不得自由提升为授权）

导出器需真实调用 `LocalTestConversationLifecycle.apply()/readAtUsePoint()` 与 `ConversationUsePointQualifier.evaluateAtUsePoint()`（若真实路径需要更多现有 Domain evaluator，按具名 intake 记录），由其**实际返回的诊断/原因**构造结果，不可仅用 PHP 硬编码所谓 evaluator PASS。

输出固定为一个带版本的、**完整 schema 白名单**的 JSON envelope；至少含：
- `schema_version`，精确为 `elitesync.qualification-diagnostic.v1`；
- `kind`，精确为 `QUALIFICATION_DIAGNOSTIC`；
- `synthetic_dev_test_only`、`diagnostic_only`，都严格为布尔 `true`；
- 每个场景均含非空 `scenario_id`、`context_id`（仅虚构身份）、有限枚举的 `diagnostic_outcome`、实际 evaluator-derived `reason_codes`（字符串列表）；
- 诊断输出明确只表示 **合同检查通过 / 合同拒绝 / 输入不可用或诊断异常**，不能将合同满足解释成真实生产证据已验或授权成功；
- envelope 与每一记录都必须有固定声明的**零授权值**：`permission=false`、`live_grant=false`、`read_allowed=false`、`send_allowed=false`。后端始终输出 false；Dart 端必须先独立强校验为原始 JSON Boolean false，不准忽略、默认补 false、类型转换或按 reason 推测授权。禁止输出 token、bearer、action/callback、真实用户消息或含混的 `canChat=true` 替代字段。
- 允许实现者在不改变上述含义/验收门前提下，确定 **唯一固定的 JSON records 容器名称与 enum 具体字面量**并在实现测试/manifest 中登记；Dart 严格拒绝任意未声明字段、缺项、错类型、错误版本、跨 context、伪造 true 权限、重复/不一致场景身份。不能放松合同为“遇到未知字段就忽略”。业务原因只能按原 evaluator 输出映射，不得凭空发明 authority。

JSON 只在本地测试内由 PHP exporter **在当次运行重新生成**；Dart 必须消费同次原始字节，编排应记录文件 SHA256、exporter 实际 exit、JSON schema/场景索引以及 Dart 输入 SHA256 的一致性。提交静态预制 JSON、PHP 单独 PASS + Flutter 单独 mock PASS、或 source grep 都**不能**满足本版跨语言闭环。

Dart DTO 仅返回 **read-only diagnostics projection**（包含“synthetic/不具备消息许可”的固定语义）；不得转为已建立的 ConversationAccessState 的活动值，不得写到 Chat/Connection state 或发起 ApiClient、真实网络/设备操作。

### 3.3 应覆盖的具名负向与失效场景

- 尚未形成双方独立同意时的拒绝；
- 即使合同评估满足仍所有许可=false；
- Connection/Conversation pause、close 与相应 relock/拒绝（仅现有领域函数具备的可测语义；未具备者以不可用诊断而非模拟 authoritative 状态代替）；
- 具名 consent revoke 或输入不可用；
- stale/revision mismatch、source 异常/缺失、跨 context；
- JSON 缺键/额外键、版本错误、型别错误、场景 ID 混淆或伪造 true grant；
- 所有拒绝与合同满足场景均不产生真实消息、网络、写者行为、业务提交副作用。

不得为覆盖条数而注入不属于已有领域函数的伪来源：如果某个状态现无可观测的实际领域语义，输出 `UNAVAILABLE / NOT_PROVEN` 并在报告中逐项指出，不得伪造 PASS。可在测试级内存/虚构 journal 执行。

## 4. 正式工作包 C｜有界真实验证与交付

- 必要 PHP 单元/集成测试、非生产 JSON exporter 与 Dart `flutter test` 组成**同一次编排**。建议命令（允许在等价、无网络副作用的本地环境中调整并留下实际 argv）：
  `C:\tools\php85\php.exe -n <上述 PHP exporter 的实际路径>`
  `D:\flutter\bin\flutter.bat test --no-pub --dart-define=QUALIFICATION_DIAGNOSTIC_FIXTURE=<当次生成 JSON 路径> <上述 Dart 测试路径>`
  其中输入文件由**测试编排层**读取，不能让新 Dart 产品数据模块为了获取 path 而建立任意本地/线上文件读取权限。工具版本/依赖入口存在不是已测 PASS；PHP `-n` 下须显式选择已有可信 autoload，不能默认读生产环境变量。
- 无外部服务连接、真实 `.env`、生产/用户 DB、密钥、网络 HTTP 访问；测试限既有可信 PHP/Flutter 安装、synthetic fixtures、内存/测试文件。允许范围内普通依赖定位和本地无副作用修复，不预授权下载/升级 SDK、Flutter/PHP/Composer 依赖或安装新全局组件。
- 对纳入的 BE-12 fail-closed 保障，至少独立核对原 middleware/routing 受保护字节身份及适用的**纯测试层** negative guard；能在限定 environment 下运行既有相关 Feature tests 则记录，不能将仅静态核对写成运行通过。测试进程中允许有界隔离，**禁止**修改生产路由或隐藏实际因旧测试而冲突的历史事实。
- 保存真实命令、exit、stdout/stderr、PHP JSON digest 与 Dart 同一输入 digest、失败→修复→回归、源/test/fixture/工具 identity 和有界 source manifest；实际没执行写 `NOT_RUN`，不能因为辅助 reviewer `NO_FINDINGS` 就自授终验。
- 最终源/test/fixture、必要脱敏 raw 日志与 manifest 必须发布 GitHub **独立候选分支**与固定 commit，供 Astra 对照本冻结提交进行独立读取。敏感/大量 raw LOCAL_ONLY 原证不能自动发布；若必需证据远端不可访问，应标明缺口并通过 Owner 合法脱敏提供，不能仅交本地路径。候选**不自动合入 main**。
- 版本正式代码的 Acceptance Status 与 Integration Status 分开登记；本版纳入上版测试增强只证明它**进入 v10.0.1 隔离候选**，不是 v10.0.0 代码已经合入 GitHub main。除非 Owner 另行决定正式集成目标并有实际证明，v10.0.0 `NOT_MERGED` 保持。

## 5. 不可后改的冻结完成标准

| AC | 可观察的 PASS 条件 |
|---|---|
| **AC-01 安全来源集成** | 候选单父 commit `4bebc8f...`，原 dirty root/index/具名保护成果不受破坏；A 精确测试 blob `5e59626...` 纳入候选，B 必需 LOCAL_ONLY 既有源码/fixture按具名 source-intake 定点引入，未替换 BE-05/BE-08 有效依赖；候选 commit/tree/path/hash 可独立确认。 |
| **AC-02 跨语言同字节链** | 同一有限编排**真实调用**现有 PHP 生命周期/资格领域函数→ freshly generated JSON→独立 Dart DTO/parser/projection，用 exporter 和 Dart 端 raw 输入同一 SHA256/运行收据证明一致，不用预签 JSON 或静态 mock。 |
| **AC-03 严格 fail-closed 合同** | 上述固定字段/schema/version/context/enum 类型、零授权断言、缺项/额外/篡改/true 权限拒绝在实际 Dart 代码中通过；任何“合同满足”都保持 read/send/live_grant/permission=false，且不连接 chat callbacks/real ApiClient。 |
| **AC-04 真实测试与失效证据** | 本版具名 PHP、选定 A 回归、Dart 单测和同次编排真实运行；对双方同意前、合同满足但不授许可、pause/close、revoke、stale/revision、source error、cross-context 的可观察覆盖提供原始记录。未被源语义支持的场景必须标 NOT_PROVEN，不能把静态注释当 PASS。全部冻结范围中的实际可执行核心用例应 PASS；失败/工具诊断原样保留。 |
| **AC-05 保护边界** | 已有 BE-12 七条私密路由默认 404 行为不被修改/绕过；是否在该候选执行 Feature negative regression须有准确证据等级。不存在新增线上 grant、真实 writer、聊天消息读发、设备/SDK/真实数据/生产操作；正式 `RuntimeReady=false` / `M6 CLOSED` 等限制不提升。 |
| **AC-06 可独立审查** | 固定候选 GitHub ref 下真实发布所需 source/test/fixture、diagnostic JSON（仅虚构、脱敏）、manifest、双流/exit、输入 SHA256 和重要失败。Astra 能依据冻结文件独立复核，不靠作者自报；旧已接受/本版新增/未证/排除分层清楚。 |
| **AC-07 版本关闭与双状态** | 作者集中提交、Astra 独立终验（PASS/PARTIAL/FAIL/REVISION）及事实复盘；明确本版与 v10.0.0 各自 Acceptance/Integration、候选基线与保留缺口，不把隔离候选误称正式 main；冻结后只对本版原目标缺陷修复，新要求另版。 |

本计划所要求的场景确实无法由当前已接受领域语义支持时，只能按 `NOT_PROVEN / BLOCKED` 记录与验收结果处理，**不得降低 AC 门或事后缩小范围制造全 PASS**。作者可以自主诊断/修复本版代码及测试；若达到必须修改已排除权威/生产函数的程度，应停止越界操作报告，而非追改本冻结正文。

## 6. 明确排除与剩余未知

- 本版新生产 Dart 模块只负责**纯 read-only diagnostic**。明确排除完整 PHP→HTTP→Flutter 业务桥、Conversation live send/read、Message writer/atomic commit、真实账户/密钥/消息、BE-12 404 route 解除、Chat provider/callback、WebSocket/RTC、安卓安装/设备/应用正式运行和公开发布。
- V57 既有窄 SOURCE_ONLY 准备例外**已批准但暂停未激活**；H1/H2/D0、旧工作队列、Work/Dot 实时监督/自动化均不启动。 `NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned`、`OwnerEnvironment PENDING` 持续。
- 未确认的 source writer、可信在线 consent、真人消息权限、生产备份/解密恢复、真实服务合规/数据生命周期依旧 `UNKNOWN / NOT_PROVEN`。本版不得把虚构来源当正式真值。
- `projectId=null` 是工具线程列表观察，Owner 已确认项目 UI 与实际 Git 根；不能仅以 null 拒绝本版，亦不宣称所有 App 专属 Sources 自动继承已证。
- 第五章、DeepLearning-HANK、旧 EliteSync 9.x、历史全树 EVIDENCE/worktree 清理不属于本版本。

## 7. 执行授权、复盘与结束

1. 当前为 `FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH`。Owner 手动向实际 EliteSync-v10 Codex 会话发送本文件**固定 GitHub 提交链接和明确 v10.0.1 执行指令**后，才能实施 A→B→C。
2. Codex 按本版目标自主调查有限范围、实现、测试、诊断、修复/重测；普通失败不再微审批；真实数据、生产、环境升级、不可逆改变、合同漂移或实质阻碍才报告。
3. 完成时一次性交付候选提交/tree/manifest、实际验证和未完成项，等待 Astra **按本冻结计划**独立验收、复盘。所有代码默认候选分支，不改动原根 main 或 GitHub main，也不自动派发 v10.0.2。
4. 计划耗时约 2–3 工程工作日仅为 Codex 提供的粗估，**不是期限/预算**。实际可获得的用时、返修、工具阻碍和额度顺手记录，没有真实数据则写 `UNKNOWN`。

**终态标识：`V10.0.1 FROZEN — ACCEPTED TEST SELECTIVE INTAKE + REAL PHP-TO-DART SYNTHETIC DIAGNOSTIC ONLY — WAITING OWNER DISPATCH`**
