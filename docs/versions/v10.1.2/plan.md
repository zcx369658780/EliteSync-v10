# EliteSync v10.1.2｜完整慢约会旅程与正式恋爱关系｜冻结功能计划

日期：2026-10-20。制定：Astra。仓库：`zcx369658780/EliteSync-v10`。

**V10.1.2_FROZEN_FUNCTIONAL_PLAN / OWNER_APPROVED_ENTER_NEXT_VERSION / IMPLEMENTATION_REQUIRES_OWNER_MANUAL_DISPATCH / NOT_STARTED**

## 1. 产品目标与完成定义

本版不是继续规划10.x，也不是重写匹配算法。用户应在已有Android APP内理解并操作：
**准备与关系意图 → 主动报名 → 本轮等待/暂停/退出 → 真实揭晓/无候选/失败 → 对候选独立回应 → 双方相互选择 → 独立Connection → 独立Messaging Consent → 自愿申请正式恋爱关系 → 双方有效实人核验＋双向确认 → 字段级授权分享 → 暂停/结束/恢复与拒绝重入**。

Home保持克制，Progress组织Match/Connection/Relationship，Messages只用于已经独立获准的会话，Me维持本人资料与隐私。不得新增顶层Tab、无限滑动/Feed、单一权威兼容分、恐吓倒计时或用AI推断恋爱事实。

**本版可接受的终点是受控开发环境的真实 APP/Web/API/独立持久 MariaDB 链与可安装 Android 开发 APK，不是公开内测或真实核验供应商已接通。** 未获实人供应商许可时，真实账号正式关系激活必须保持不可用/待核验；仅与运行环境隔离的合成测试身份可走完整激活状态机，绝不在非测试环境显示“已实人认证”。

## 2. 当前 authority / 冻结来源

Owner已在本会话同意进入v10.1.2；冻结默认仅是本版受控开发合同，不能追称为过去已确认的正式运营政策。Owner手动派发本版唯一Codex任务时，才授予该范围内的实施授权。普通代码设计由Codex自主完成；扩大真实数据、设备/网络权限、费用、身份供应商或不可逆资源另由Owner批准。

签发前已实读并独立接受的产品基线：
- v10.1.1集成完成main：`9e25756af9e4a969cc631a54d385d84bce18d890`，Root Tree `7b999e4af667b4c85a08cc8846de060e847b8a6c`。
- apps：`1ddc864a8f7f8f7e024d6102a36057252bc77bab`。
- services：`e4ae92d12d0bbac81a8ed7730a061aaec214da13`。
- 既有正式功能接受 `docs/versions/v10.1.1/acceptance.md`；单次安全集成记录 `docs/versions/v10.1.1/integration.md` 和Astra独立集成验收 `docs/versions/v10.1.1/integration_acceptance.md`。
- Owner新增决定 `docs/decisions/OWNER_PRODUCT_DECISIONS_20261019_LONG_TERM_RELATIONSHIP_V1_0.md` Blob `636990f86fc63e9aa33fb4ac80d5c267ce6b10e6`。
- 10.x路线 `docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md` Blob `d8d34ccf229254e7e064be00590ba509071cf749`，尤其§6.2、§7和§11。
- 2026-09-12已接受APP设计，设计Blob `b72ed9ec851d44aba7be65883186cb275fab22d1`，特别是Canonical Match、Connection、Conversation、Relationship、Onboarding/Readiness、数据类别及用户退出合同。

开工须先只读实核live main；以上只是签发时锚，不能覆盖合法后继。v10.1.0整体PARTIAL/NOT_ACCEPTED与AC-10.1-08 PARTIAL、R1历史事故和残留失败继续保留。

## 3. 定点实读发现：必须复用或纠正的既有实现

1. `ProfileReadinessService`已有运营审核、问卷、匹配资格与Showcase状态；其中 `verify_status=approved` 只代表运营参与资格，**不是实人认证**。当前匹配资格尚不等于显式报名/轮次同意。
2. `dating_rounds`、`dating_round_user_states`、`matching_runs`、`DatingMatch`、管理员运营及 `MatchRoundProjectionService` 已有持久骨架和揭晓/无候选/失败投影，不新建并行真值库。
3. 旧 `MatchController::current/confirm` 仍有按问卷/周标签的旧Match选择及直接改 `like_a/like_b` 路径。必须与新版参与、揭晓、候选身份、到期、重放和并发授权统一，不得把旧v1写口继续留为旁路。
4. `/api/v2/canonical-match/evaluations`等具有严格 `synthetic_fixture` 边界，是合成合同/判断输入，不是已可面向正式用户的持久Matching API。允许复用经核实的语义和评估器，不能把客户端送来的合成evidence、revision或自报状态当权威。
5. `LiveConsentService`与v10.1.1好友/请求来源复用现有CN/MC；Match相互接受不等于CN、MC、Conversation。
6. `RelationshipController::store`对旧客户端自写事件返回410，过去 `UserRelationshipEvent` 是 `legacy_untrusted_history`；不得重新开放客户端自报关系作为正式真值。
7. `PrivacyController`仅保存 `SELF/RELATIONSHIP_SHARED` 的未来分享意向，`formal_relationship_available=false`；`SocialPolicy::profile`不向peer开放深层字段。本版要用新的真实后端正式关系事实与字段受众在读写点协调，而不是仅改UI文案。
8. `MatchRoundProjectionService`存在旧 `conversation_eligible` / `next_action_code=open_conversation` 术语，本版必须核清并禁止“揭晓即能直接聊天”的误解或旁路。
9. Flutter `ProgressPage` 已有Match/Connection入口；`MatchRoundContractView`主要只读，CanonicalMatchTargetAction当前无权威动作。Home的部分多域投影是显式synthetic开发呈现，不得冒称生产事实。

上述是当前源码定点观察，不代表所有相关功能都未实现。优先扩展既有持久事实与服务，拒绝无目的全仓考古、双套并行生命周期或新评分算法。

## 4. 版内冻结的开发默认合同

### 4.1 匹配报名与节奏

- 进入Match必须本人明确Opt-in，并持久记录当前参与代际/版本、报名时间、可撤回性与当前状态；运营资格、必要问卷、Showcase等必须提供可解释的逐项准备结果。可选玄学、人格、私聊和内部Safety档案不成为额外强制报名条件。
- 使用既有`DatingRoundChannel`及已接受调度能力，不新建隐藏“每周一次”硬编码；一轮最多向一个用户展示**一个未终结候选**，不能同时有两个需要选择的提案。
- 本版新提案的受控开发默认有效期为**揭晓后7个自然日（168小时）**，按服务器UTC可配置。若已有权威channel/round合同明确指定有效期，则保留其值并记录来源；不倒改已交付提案。不使用焦虑性倒计时；过期按服务器裁决，刷新/重启/重放后不得重开。
- 暂停报名即时禁止未来轮次纳入；如已有等待/未决提案，提供明确撤回当前提案动作且不错误宣称对方违规；恢复是明确Opt-in的新代际，不暗复活已终结提案。
- 运营可以按当前具名权限组织和运行开发轮次，不代表真实市场供给、效果或持续自动匹配已运行。无真实候选要诚实显示`NO_CANDIDATE`，无活动轮次`NO_ROUND`，失败/网络故障分开，不能生成虚构对象。

### 4.2 提案与双向兴趣

- 每个提案有不可复用的权威Identity、round/run/参与者绑定、revision、揭晓/过期时间、每人的决策记录和幂等键。
- `PENDING → ACCEPTED_BY_ME → MUTUALLY_ACCEPTED`；另有`DECLINED / WITHDRAWN / EXPIRED`终态。不同人的接受是不同事实，重放不重复副作用，旧revision/跨账号/跨提案/已撤权/过期一律拒绝。
- Match双方相互选择只生成“可发起独立Connection”的资格；不自动建立Connection、MC、Conversation、正式关系或深层资料共享。单方拒绝/超时不是Safety Finding。
- 候选仅看本人获准的最小Showcase和解释：原因类别、适用限制、输入类别和来源、不确定性，不能看另一人的原问卷、精确生辰、真实身份证件、私聊或内部Safety。不得用单一“分数”当可靠恋爱结论。

### 4.3 Connection、Messaging Consent与关系连续性

- 复用现有CN/MC双向确认及当前生命周期ID+revision；Match决定、好友、搭子、请求仍不互相升级。
- 既有合法独立CN/MC无需为了本版重新授权；新的Match衍生邀请也必须走同样服务端许可，不得用旧`conversation_eligible`或前端导航打开未获准私信/RTC。
- 暂停Match不自动销毁已有合法Connection/Conversation；关闭或撤销各业务独立处理。Block即时禁止联系并撤销其已有联系能力，解Block不恢复。
- 未获MC时，真实消息、附件、WS、RTC、通知和旧token不得绕过拒绝。历史合法会话读权与新消息写权仍按已有合同分开。

### 4.4 正式恋爱关系：双向确认＋双有效实人认证

- 新增**独立持久正式Relationship聚合**，不可把旧自报事件或CN/MC行改名充当。建议生命周期`NOT_DECLARED / PENDING_MUTUAL / ACTIVE / PAUSED / SUSPENDED_REVERIFY / ENDED / DECLINED / WITHDRAWN`，状态字典和可达边在实施报告明确定义，任何终态不能单边复活原生命周期。
- 必须二人明确逐次确认同一Relationship Identity，并在激活提交前重新核对双方**服务端可信的有效实人验证凭据**。运营`verify_status`、支付实名、客户端布尔值、Web管理员按钮、原UserRelationshipEvent、Match/CN/MC均不能替代。
- 本版开发默认**每人同一时间最多一个ACTIVE正式关系**，以数据库并发与服务器事务实现，而不是UI判断；这是为受控软件验证冻结的保守约束，**并非Owner已确认的永久婚恋或社会政策**。可保留未来可版本化调整的模型，不强制删除历史生命周期。
- 任一方随时可暂停本人更深分享或直接结束关系，退出无需对方同意或当前有效实人认证；结束不自动惩罚、不默认删除共享合法消息，CN/MC仍由其独立授权合同约束。Block则按v10.1.1已经接受的保护语义立即终止/失效恋爱专属共享且解Block不暗复活。
- 认证过期、撤回或无法核实：不凭技术失效宣称双方感情已终结，但立即暂停恋爱专属字段投影并进入`SUSPENDED_REVERIFY`；即使认证恢复，也需双方明确再次确认才可恢复共享，不允许自动重新开放。两个账号的认证事实都必须每次读时有效。
- 未选择供应商且未批准费用/数据外发：仅在隔离本地`testing/development`、指定合成账号/夹具、不可抵达真实用户环境的受控验证替身中跑激活与撤回端到端。标记`DEV_SYNTHETIC_VERIFIED / TEST_ONLY`及专用来源，有效期、重放/伪造测试。其它环境默认`PROVIDER_NOT_CONFIGURED / NOT_VERIFIED / ACTIVATION_UNAVAILABLE`；任何客户端或管理员不得把测试替身写成真实用户实人完成。

### 4.5 字段分享、撤权与隐私

- 正式关系只提供**最大可授权范围**。已有`birthday/interests/resume/zodiac`意向及未来最小真实字段需要本人实际存储且选择`RELATIONSHIP_SHARED`、关系ACTIVE、双方认证有效、双向确认且双方未Block，才可向特定peer展示。
- 若`resume`等字段实际没有合法持久值，返回缺失/未提供，不要造虚假履历；是否补充小型本人编辑入口由本版需要决定，不扩为全套Profile重构。
- 证件、精确出生时间/地点、原星盘输入、私聊、内部举报/处罚/纠纷和操作审计始终不随正式关系公开。分享改变、退出/暂停、Block、认证失效后对旧链接、缓存刷新、列表、通知、媒体及所有授权读点必须及时fail-closed。
- 延续v10.1.1 R1证明的有序用户锁＋锁后当前读规则，尤其MariaDB RR不能在等待协调锁前创建可污染授权的旧快照。关键并发组合用真实双连接确定性屏障证明，不能只靠SQLite或sleep。

## 5. 实施环境与数据界限

- 只用独立、本版归属确认的**本地合成开发环境**。建议`elitesync_v10_1_2_dev`与新的独立Docker volume；DB仅loopback，优先43323（占用则在本地安全范围内选择并记录替代端口）；APP API可优先8015、WS8016，必须确认不占用未知既有服务。
- 严禁复用或`migrate:fresh`清空v10.1.1曾发生误清/恢复的库、v10.1.0试点、其它历史SQL或真实用户库。新本版库初始为空且有归属证据时才允许迁移和seed虚构成员。建库/迁移前验证`APP_DB_CONNECTION`优先、host/port/db、`APP_ENV`、volume身份并建立最小可恢复点；禁止依赖仅`DB_CONNECTION=sqlite`的想当然防护。普通PHPUnit必须停在内存SQLite隔离，实际MariaDB专项在独立受控测试命令运行。
- 开发APK必须标明`v10.1.2-dev`、包名、versionCode、ABI、构建源码commit/tree、签名及APK SHA/安装读回；必要时采用隔离应用ID避免覆盖v10.1.1获接受开发APK。既有已获授权AVD可用于演练；**手机USB、麦克风/相机、UDP精确窗口、系统防火墙、UAC提升不由旧v10.1.1的一次性授权自动续期**。
- 原dirty根`D:/EliteSync-v10`、旧仓`D:/EliteSync`及所有未提交成果/备份/既有volume一律保护。已有干净专用树可安全连续接续，不强制新建多个worktree。不进行无关云端部署/阿里云修改/裸公网IP/备案/身份供应商/Push/支付/AI外传或任何费用。
- 本版不要求员工服务、线下活动或v10.1.3独立搭子/社区。全部算法oracle、与本版无差异的历史RTC长测不重复。

## 6. 冻结验收标准（AC-10.1.2-01～12）

**AC-01｜基线及隔离：** 基于实时已接受v10.1.1 main；冻结文件保留；独立开发库/卷/原dirty及v10.1.1恢复资产保护；测试有效DB selector前置失败关闭。

**AC-02｜准备与明确报名：** APP真实展示运营审核≠实人、必填/可选、问卷、Showcase和匹配意图；可保存草稿/重启再读，合资格Opt-in真实写库，暂停/退出/恢复按代际正确；不合资格/禁用/Block等拒绝并解释下一步。

**AC-03｜低频轮次与无候选：** 真实Web后台获准运营动作→任务/consumer→MariaDB轮次投影→APP；无round、等待、运行、无候选、失败、retry和关闭均有真实区分；不用假计时/假候选。

**AC-04｜提案与双向决策：** 单未决候选、揭晓后限定Showcase、7日开发默认/服务器到期、双方独立回应、单方拒绝/撤回/过期、重放/旧revision/错误actor/跨轮次/并发双响应严格持久一致；不能通过旧v1 `confirm`绕过。

**AC-05｜授权解释与数据用途：** APP显示原因类别/来源/不确定性/非目标；另一人原问卷、精确出生时地、私聊和Safety不流出；Match不自动CN、MC、Conversation或Relationship。

**AC-06｜CN/MC真实连续：** 合法双方经分别同意后能走现有文字消息与必要媒体使用点，未同意/撤权后普通消息、附件、WS、RTC拒绝；既有好友/搭子/Match事实不暗转同意，旧JWT和独立CN生命期验证。

**AC-07｜正式关系双向＋实人门禁：** 开发隔离合成A/B经双方双确认＋两份有效TEST_ONLY身份凭据可进ACTIVE；少一方、过期、撤销、客户端bool、admin、旧事件或非开发环境皆不可激活；不声称真实身份供应商成功。

**AC-08｜正式关系生命周期：** 并发申请、重复、拒绝、暂停、认证失效、双方重确认恢复、任一方退出及终态不可旧代际复活。每人一ACTIVE的开发默认在真实MariaDB并发下成立；退出不生成Finding，不自动毁掉独立合法CN/MC。

**AC-09｜分享与撤权一致：** 默认SELF、本人选择的4字段、已有合法值、双方有效认证/关系状态/Block，实际服务端读回；撤回后旧URL/列表/通知/缓存/并发读不出现新敏感数据。MariaDB RR有真实确定性屏障；未公开证件/精确生辰/内部Safety。

**AC-10｜Android实际体验：** Home | Progress | Messages | Me中完整主要路径可操作；真实服务器、切号/晚响应/重登/离线/失败恢复、准备/无候选/未核验不是同一个状态。新版APK在获准AVD安装、包/签名/hash/readback和同版本后端绑定；不使用纯mock截图冒全链。

**AC-11｜Web、数据库与安全回归：** 独立Web后台限定轮次/队列/故障及最少审计；管理员不能确立恋爱或实人认证；数据库/服务受控重启后报名、提案、双向决策、关系和分享仍一致。必要负例覆盖账号禁用/注销/Block、跨账号/旧token、RBAC、旧匹配旁路和并发TOCTOU。已有功能不因新关系代码回归破坏。

**AC-12｜集中交付：** 固定源码Commit/Tree、apps/services、迁移、测试实际exit/stdout/stderr、真实API/APP/Web/DB回执、SDK/设备/供应商NOT_RUN、原失败及本版新失败、非作者复核、APK与专属资源收尾。Codex仅交`CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE`，不自称PASS/ACCEPTED、不合产品main、不启动1.3。

## 7. 出口与不能被掩盖的观察

一版一次综合任务、Codex在已获授权范围连续调查/实现/测试/修复/非作者复核后集中交候选；同版真实阻断才触发有界集中R1。旧失败与v10.1.1 DB事故原样保留。真实身份供应商尚未接入属于明确外部门禁，而不是默认放宽双方实人核验条件。

成功的开发出口为：**V10.1.2_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / REAL_IDENTITY_PROVIDER_PENDING**。只有Astra独立审阅源码、持久化、实际正反链、APK及限制后才能给出版本接受；安全集成仍是接受之后的单独状态。v10.1.3不会被本计划自动启动。
