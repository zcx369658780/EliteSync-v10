# EliteSync v10.1.2｜完整慢约会与正式恋爱关系｜Codex唯一综合长任务单

签发：2026-10-20，Astra。**V10.1.2_LONG_TASK_READY / OWNER_MANUAL_DISPATCH_PENDING / IMPLEMENTATION_NOT_STARTED / NO_NEXT_VERSION**。

这是已冻结v10.1.2版本的一次综合任务，不是又一轮只读规划、全仓考古或微任务链。Owner于2026-10-20同意进入本版；**本任务还需Owner将整份任务交给本地Codex，转交即为该冻结开发范围的一次性实施授权**。不得由Codex提前按GitHub发布自动开工。

## A. Authority、唯一源与冻结身份

- Owner：真实产品取舍、真实数据、费用及重大不可逆权限。
- Astra：冻结范围、独立验收和集中反馈；不做Work/dot实时监督。
- Codex：获手动派发后，连续调查、实施、迁移受控开发库、测试、修复、非作者复核和集中交付。自行解决范围内普通工程问题，不每命令请求批准。

**必须完整读取并按原字节遵守**：
1. `docs/versions/v10.1.2/plan.md`，冻结Blob `2ebd2ea05b3d7dae52cc3995de913eeb0fde375e`。其中§4的默认参数及AC-01～12不可偷偷削减。
2. `docs/workflow/CURRENT_WORKFLOW.md`及`docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md`。
3. `CURRENT_STATE.md`、`DOC_INDEX_CURRENT.md`、`PRODUCT_DECISIONS.md`、2026-10-19 Owner补充决定与10.x正式路线。
4. `docs/versions/v10.1.1/integration_acceptance.md`、`acceptance.md`、`integration.md`、原R1实施报告和两个manifest；只为继承源码、安全经验与观察，不重新接受v10.1.1。

本计划签发时已接受main产品锚：
- main `9e25756af9e4a969cc631a54d385d84bce18d890`，Tree `7b999e4af667b4c85a08cc8846de060e847b8a6c`。
- apps `1ddc864a8f7f8f7e024d6102a36057252bc77bab`。
- services `e4ae92d12d0bbac81a8ed7730a061aaec214da13`。
- 已接受的v10.1.1源代码Commit `ee2459953146a135ae9b118a1ffe75946efd0183`。

**开工、提交和发布前均重新实核live main**。签发后若多了纯文档提交，合法保留；若出现相关产品并发改变，定点compare和归属核查，不能无声覆盖。创建/复用明确归属的安全干净连续开发树，任务分支可命名`codex/v10.1.2-slow-dating-relationship`；原`D:/EliteSync-v10` dirty根、`D:/EliteSync`旧仓及既有所有专用树原证不盲reset/pull/stash/clean/prune/force。

## B. 一次完成的实施范围

**B1：真实准备与主动报名。** 复用ProfileReadinessService、问卷草稿、运营审核、Showcase发布与现有轮次；把匹配资格、缺项/原因、报名opt-in、暂停/恢复/退出、轮次参与状态和用户可控意图接为实际API/持久库/Flutter。运营`verify_status=approved`不得变成实人核验。可选玄学、MBTI或全量私聊不得成为强制准备项目。重登、切号、服务重启不得丢报名或误把网络故障称为未匹配。

**B2：真实轮次、等待、揭晓、无候选和失败。** 保留`dating_rounds`/`matching_runs`和已接受consumer；Web后台使用现有授权轮次操作、排队、失败/重试/关闭。明示channel cadence的真实配置，不硬编码全站周频；仅运行有真实测试输入的既有匹配算法，不重算新的“恋爱价值分”。无round/无候选/服务失败/候选未揭晓分开投影；恰好一个未决候选；无结果不伪造结果。修正旧投影中揭晓`conversation_eligible/open_conversation`误授权语义。

**B3：Canonical Match的受控真实写入。** 在现有被接受的domain contracts与持久Round/Match之上建立真实用户授权入口与安全状态机；绝不可将`/api/v2/canonical-match/evaluations`的外来`synthetic_fixture`JSON当正式用户事实。每位用户对唯一提案独立接受/拒绝/撤回；服务器UTC设过期、当前revision和幂等，开发默认揭晓后168小时；复用旧`/api/v1/matches/current/confirm`时必须迁移到统一权威服务或安全关闭旧写旁路。拒绝未揭晓、已到期、错误账号、越过单提案限制和提交重复通知；先决权限均在锁后当前读，避免再现v10.1.1 RR旧快照竞态。每个提案保留审计与版本/退回理由，终态不重生。

**B4：推进仍按同意层分离。** 双方Match接受不自动创建CN/MC/会话，接着明确引导CN双方独立同意，再明确MC双方同意，才可合法发消息/使用媒体/WS/RTC。适配既有好友/受控请求、不反写其它事实。合法旧CN/MC及Block、注销和已有媒体权限不能因本版直接失效；必要回归覆盖旧Token及晚到请求。

**B5：新增权威正式Relationship聚合。** 保留旧`/relationships`客户端自写410及历史`legacy_untrusted_history`，新建独立服务端受信写入、查询和审计。具名请求→双方明确确认→双有效实人凭证→ACTIVE；拒绝/撤回/暂停/认证失效SUSPENDED_REVERIFY/任何一方终结，前后revision和生命周期ID有明确单向终态及再次确认。开发默认同一人最多一段ACTIVE关系并真实并发守护，这不是不可逆的生产独占政策。退出不依赖对方同意/实人有效，不生成Safety Finding；结束Relation不能擅自关闭本来独立合法CN/MC；Block即时阻断联系、关系分享，解Block不自动恢复。

**B6：可信身份适配及硬拒绝。** 不选择/调用支付宝微信、不支付、不提交资质、不传真实生辰/证件。只提供服务端可信身份断言抽象（issuer、credential identity、subject绑定、有效期/撤销/版本和审计），隔离本地test-only签发者仅对明确合成账户和测试模式开放。没有真实供应商的账号始终`PROVIDER_NOT_CONFIGURED/NOT_VERIFIED`且正式关系ACTIVE及深分享不可用。伪造客户端`verified=true`、admin用户审核、旧实人布尔、重放合成票据、跨账号和切环境均拒绝。UI必须对dev替身展示`TEST_ONLY`，永不冒称真实身份认证成功。

**B7：真正的恋爱字段分享。** 延续v10.1.1已有`SELF/RELATIONSHIP_SHARED`及privacy revision；仅按当前双方正式关系、双方有效凭证、本人字段单项选择、Block/禁用状态和具体用途授权读出实际存在的`birthday/interests/resume/zodiac`。缺值不编造；身份证、准确出生时地、私聊、Safety/审核档案严禁流出。以服务端断言覆盖资料页/旧URL/通知/搜索/媒体可能的旁路；包含先撤权COMMIT后被阻塞读者恢复的MariaDB RR确定性测试，防止R1同类竞态。本人取消分享、任何一方结束/暂停、过期/撤销认证、Block都fail-closed；不能承诺已经下载的客户端旧像素远程抹除。

**B8：APP与Web真实可操作旅程。** 保留四顶层`Home | Progress | Messages | Me`，以现有页面为入口：Home静态少量下一步；Progress明确准备→匹配→连接→关系，清楚显示状态、双方各自决定、等待、空/失败/撤回/过期；Messages绝不提前开放；Me显示本人可控深资料及预览。同步改造`MatchRoundContractView`和历史只读canonical状态表现；旧开发synthetic Home投影与真实服务端投影并列时必须明确身份，不能合成假授权。Web后台仅具名轮次/失败/审计管理、普通角色拒绝，**不得提供代双方确认恋爱或冒真实身份的管理按钮**。

## C. 开发环境与数据安全（先于任何测试）

本版**只允许独立的本地、虚构数据开发库**：
- 默认DB名 `elitesync_v10_1_2_dev`，独立新Docker容器/卷，建议loopback端口43323，若已占用则查明归属后另选并如实登记。
- Laravel API建议本地8015，WS8016，Web可复用安全开发路由；仅确认为本任务所有的loopback资源，不开放公有端口。
- 首次迁移前必须检查实际`APP_DB_CONNECTION`、`DB_CONNECTION`、host/port/db、URL/socket、APP_ENV、容器/卷身份、库是否完全本版新建且无历史记录；做必要备份/恢复标记。继承v10.1.1的测试护栏，尤其`Tests\TestCase`对持久库必须在RefreshDatabase前fail closed。
- `phpunit.xml`和普通Feature tests继续强制SQLite `:memory:`；真实MariaDB并发由独立受控脚本和明确库名执行。禁止对任何已有v10.1.1开发库、恢复库、旧试点、真实库`migrate:fresh`、`db:wipe`、seed或无备份覆盖。
- 旧v10.1.1误清开发库及31表恢复回执完整保留。不要为了便捷迁移旧真实记录或事故夹具；本版只造虚构A/B/C等账号。
- 可启动明确属于本版的服务/容器、执行必要本地迁移/seed、Web/APK/AVD测试并收尾；不可碰阿里云、生产、裸公网IP、第三方身份/Push/支付、系统权限、真实电话/摄像头/麦克风/UDP、防火墙/UAC或任何费用。
- APK使用v10.1.2专属dev身份，记录applicationId、versionName/versionCode、ABI、签名、SHA、构建源码对象及获准AVD安装/pull，避免覆盖被接受的v10.1.1 APK。若需真实手机或改变Android全局工具版本/网络，暂停该子项请求Owner明确授权。

## D. 验收及测试必须对应冻结AC-01～12

一次综合实现完成后，在本版受控环境逐条跑正负案例，不将单元、Widget和端到端/重启数量相加冒称唯一通过率：

1. 三类准备用户（未完成、运营资格通过、已禁用）×报名/暂停/退出/恢复，草稿与revision在重登重启后准确。
2. 两人真实轮次从Web准备→匹配consumer→受控Reveal→APP真实投影；无轮次、零候选、匹配失败、超时重试和关闭作为不同事实。
3. 一个未决候选上限；两人各自回应、拒绝、过期、撤回、重放、同时接受、错误actor/旧token，数据库真实约束和用户权限返回明确。
4. 旧v1 match endpoint与新生命周期一致，不能绕过同意/揭晓/到期；v2 synthetic-only接口不可暴露为正式用户写入。
5. 双方相互接受但不允许发送消息/呼叫；另行CN、MC双同意才成功；Block及撤权后旧媒体/WS/RTC拒绝。
6. 正式关系以两人TEST_ONLY有效实人断言与双方明确确认在隔离环境进入ACTIVE；所有伪造/旧凭据/单方/非dev环境拒绝。运营审核绝不直接当实人认证。
7. 并发双申请及同一人两个候选关系激活只允许一个成功，失败无半成品；终结、暂停、认证过期/撤回后立即降权，复验需双方重新确认。
8. 字段级分享前后响应真实值、缺省和遗漏；陌生人/普通好友、任一方未认证、撤回受众、Block、注销等无敏感正文。旧路径/缓存/延迟及RR两连接确定性竞态均拒绝新无权读取。
9. Home/Progress/Messages/Me与独立Web真实操作→API→数据库→重新读取/容器服务受控重启后仍准确。Session epoch、跨号晚响应、网络错误与NO_CANDIDATE区分。
10. 关键静态/并发/身份/迁移安全回归。复用已接受原算法和v10.1.1R1证据，不重做无关星盘/RTC长测，但凡本版改变的权限链必须实际验证。
11. APK与最终源码严格绑定：发布前固定产品源码，然后构建/安装/设备读回；若后续改业务源码必须重建或清楚列NOT_MATCH，不用老APK证明新实现。
12. 依AC逐项标`PASS/FAIL/PARTIAL/NOT_RUN`并给证据指针，运行结果与exit、stdout、持久DB/HTTP、Android/Web/真人设备类型分层，不编造测试成功。

## E. 发布与审阅证据

- 只在独立候选分支开发，**未获Astra接受前禁止合产品main、清理原分支、开始v10.1.3**。
- 最终交付一个`docs/versions/v10.1.2/IMPLEMENTATION_REPORT.md`及必要的制品manifest/经过安全审查的证据索引。报告必须列产品源码Commit/Tree、apps/services、源码冻结后APK包/签名/哈希与安装身份、迁移、API路由、数据库schema/受控持久读回、Web与APP实际旅程、分角色负例、测试命令exit、原失败/修复、新失败、独立非作者复核结论和所有外部门禁。
- 必要最小的脱敏原始stdout/stderr、并发屏障、截断/遮蔽脚本副本按`TEMP_REVIEW_EVIDENCE_PROTOCOL`在短期独立审阅分支发布；不合main。公开GitHub严禁上传私密表、真实用户资料、token/JWT、DB/APK实体、原始设备日志、秘密配置。执行原件与脱敏副本SHA分别标明。交付前由非作者复核关键Match/Relationship权限/读写锁与证据、不是新增多轮盲审。
- 本版专属服务/DB容器/AVD启动的资源最终归还停止，不删除卷/本地恢复点/原证。保留每个失败及纠正经过，不得因最后PASS抹掉事故和初始错误。
- 普通non-force发布候选、远端Commit/Tree/apps/services/manifest回读，并提交Owner供Astra独立验收。若main在开发期间变化，候选不覆盖main；若来源对象或保护条件不明，只阻断对应危险子项而非创建另一轮无目的preflight。
- v10.1.1既有功能和集成接受保留。v10.1.0整版及AC-10.1-08依旧PARTIAL。未获取真实实人供应商，必须明确`REAL_IDENTITY_PROVIDER_PENDING`。

**正常出口：V10.1.2_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / REAL_IDENTITY_PROVIDER_PENDING / V10.1.3_NOT_STARTED。**

如果范围内本版仍有阻断，诚实交`PARTIAL/CHANGES_REQUIRED`及集中缺口；Codex不能自给`ACCEPTED`。本次不授权产品main集成、公众运营、支付/核验采购、云端网络变更、真实线下活动、第三方AI外传或审阅证据自动清理。
