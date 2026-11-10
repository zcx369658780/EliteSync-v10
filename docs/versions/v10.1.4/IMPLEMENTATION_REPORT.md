# EliteSync v10.1.4 实施报告

2026-10-21｜Owner手动派发的冻结综合版本。**V10.1.4_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / SYNTHETIC_PLATFORM_EVENTS_ONLY / NO_REAL_PAYMENT / V10.1.5_NOT_STARTED**。本报告是 Codex 实施与物理执行回报，不是 Astra 接受或生产许可。所有 APP/Web/API/MariaDB 物理原证均为 **CODEX_REPORTED / LOCAL_ONLY**。

## 1. 固定权威与交付对象

| 对象 | 固定身份 |
|---|---|
| 冻结 plan Blob | `6f4157eeee47bc8d2fc4bbda5767025de0691347` |
| 冻结 task_order Blob | `67f01f8841a7882a907d1782136ff520caed977c` |
| 开工及发布前 live main | `b7d04f73b60b60baf2ff6e45d8a72d353d96aa01` |
| 基线 Root | `a6e207f8a9c9d0a3dfb7e70cde74b988e3388409` |
| 接受基线 apps / services | `d4569b330629d74c6e5f3ee1d6438245d7bfd024` / `4d637a3fd827e00974887d9ce515a1833a8f3a8a` |
| 唯一候选源码 Commit | `e7e246dc70f72846a05a31e022efadee0838ab83` |
| 源码 Root Tree | `e9ca41a1347fdeebdedca18de6f8eed767b59d5c` |
| 源码 apps Tree | `b502d776c8e5f916f2d4074b90a39d0547b896fa` |
| 源码 services Tree | `45869d8b765ca8c645a04f747bb67be03a5bd632` |
| 候选分支 | `codex/v10.1.4-platform-events-internal-safety` |
| 独立临时审阅分支 | `review/temporary-evidence-v1014-20261021` |
| 审阅 Commit / Tree | `8e639a3f22fe85eaf267f518c7205e4973dd5092` / `3e861c30fabf147b3bc0f1dd69443887f0526b66` |

源码相对实时基线仅36个产品路径，逐项mode/Blob见manifest与[变更清单](https://github.com/zcx369658780/EliteSync-v10/blob/8e639a3f22fe85eaf267f518c7205e4973dd5092/docs/_temporary_review/v1014-20261021/candidate-changed-paths.json)。原main所有文档、冻结计划、Owner决定、v10.1.3接受/集成原件未改。源码候选由Git SSH普通non-force发布；GitHub独立HTTPS回读核完整Root/apps/services、36路径mode/Blob及39份公开审阅文件字节一致，main仍为上述固定值。首次匿名REST限流403/exit1保留；使用既有已登录gh客户端访问REST后成功，没有导出认证令牌。

本报告与manifest为后续纯文档交付提交，不改变上述源码产品树；最终交付Commit/Root和文档Blob由发布后远端回读与最终答复固定，避免自引用提交号。未合main，未自签ACCEPTED。

## 2. 实际实现和合同

**平台活动**独立于Buddy。Web创建 `TEST_ONLY ` 名称/虚构城市/公共场所、UTC排程、2–8容量；保守过滤联系方式、精确地址与坐标。状态 DRAFT→OPEN→CLOSED→COMPLETED，取消/时钟过期分别为CANCELLED/EXPIRED。COMPLETED仅表示平台排程完成；已有参与者仍可自主退出，保留COMPLETED和审计。

预算为CNY非负整数模拟值：DRAFT→REVIEWED→APPROVED_FOR_DEV_SIMULATION，可VOID；venue/materials/travel/total和revision完整记录。主链实际Web保存1000+250+0=1250。APP不返回内部预算；没有真实支付、订单、预订或付款成功状态。

定向邀请或48小时单次高熵凭据（只存SHA256），无全站目录。每活动/用户唯一参与行：INVITED→APPLIED或WAITLISTED→人工CONFIRMED；APPLIED预留容量，WAITLISTED按服务端顺序人工提升。本人CANCELLED_BY_USER、主办CANCELLED_BY_ORGANIZER、EXPIRED分别保留。revision与actor/幂等键防重放；请求不会建立好友、Buddy、CN、MC或正式Relationship。自愿到场仅UNVERIFIED→SELF_REPORTED，无GPS、他人未回复推定或自动处罚。

**Safety**复用ModerationReport/UserGovernance/SanctionAppeals/OperationAudit。报告提交仅OPEN／报告事实；规则 `DEV_RULES_20261021_1 / ADVISORY_ONLY` 保留类别、版本和不确定性，无外部模型。状态 OPEN→TRIAGED→INVESTIGATING→SUBSTANTIATED→ACTIONED→CLOSED；可DISMISSED，复核可CORRECTED。CONDUCT认定要求两个不同举报者对同一合成活动/subject的当前来源、有理由的证据访问审计、显式人工判断与确认。它只演练软件人工流程，不证明真实线下事实。未到场报告、自愿取消、担忧安全、未回复或拉黑本身不形成Finding。

人工处罚由既有UserGovernance具名restrict/banned入口写入；本人提交精确SanctionAppeal后，Web具名UPHELD/OVERTURNED/CORRECTED。推翻/纠错只恢复对应sanction，其它active限制保持，原社会权限不复活。退出后原举报陈述/证据404；具名申诉最小工作台仍只按精确case/sanction/appeal核查，不能读回原指控。旧举报、用户详情、旧审计和旧restore入口已对新Safety域封口；旧非Safety合同保留。

### 迁移及逐字段受众

唯一增量迁移 `2026_10_21_190000_create_platform_events_safety.php`：12张新表，sanction_appeals新增revision/review_outcome/reviewed_at。外键restrictOnDelete；down显式拒绝无授权销毁，未执行回滚或erasure worker。

| 数据 | 写源与受众 |
|---|---|
| platform_events（id/organizer/title/city/venue/time/capacity/state/revision） | 当前具名Web管理员写；仅当前受邀/参与合成账号可读活动投影。 |
| budgets（3分类/total/CNY/state/revision） | 当前Web管理员内部读写；用户APP完全不下发。 |
| grants（recipient/token_hash/state/expires） | 服务端/管理员限域；一次原凭据只显示当次，库只hash；APP仅必要操作。 |
| registrations（event/user/grant/state/revision/wait_order/attendance） | 服务端当前授权写；本人完整参与状态；其它参与者仅最小registration_id及合成标签，无账号/联系方式。 |
| commands/audits/admin_sessions | 幂等指纹/结果版本、具名审计、Web session hash与撤销事实，仅服务端及限域管理员；不进入APP公开资料。 |
| safety_cases / moderation_reports | 独立报告和案卷；举报者仅本人当前有权最小状态；被处罚者仅本人sanction/appeal；无公开负面档案。 |
| evidence（type/source_id/revision/hash/scope） | 当前有权具名管理员、理由及访问审计；只活动参与事实指针，不复制私聊、证件、照片或精确位置。 |
| advisories / decisions | 规则辅助事实与人工reviewer/action/reason/expected_revision分开存；管理员限域，用户仅必要结果，不输出举报人陈述或人工内部理由。 |
| reviews / sanction_appeals | 精确本人申诉与人工结果，版本/理由/时间/处罚关联；本人最小结果，当前具名复核者必要限域。 |
| notifications | 通用“状态更新”与资源ID/revision，点击前服务端当前预检；撤权后隐藏，不能复用缓存正文或越账号迟到响应。 |

入口：APP `/api/v1/platform-events` 列表、UUID详情、`redeem`、UUID `/actions`、UUID `/reports`；本人 `/api/v1/safety/own`及详情；复用`/moderation/sanctions/{id}/appeals`。Web `/admin/platform-events`及`/admin/safety-cases/...`，auth:web/account.active/admin.phone/CSRF加当前合成管理员角色和注册Web session撤权事实。

### 锁与当前授权

活动事务外只发现organizer定位；事务内按既有协调合同（管理员需要时先CurrentQuestionnaire）→排序用户锁→重新核对当前账号/角色/phone权限/设备或Web session→event current read→registration/grant/current audience。Safety再核case身份及相关当前证据/申诉/处罚。定位身份锁后复核，授权读取使用FOR UPDATE，未降低RR或修改全局隔离级别。Block、禁用、注销、角色/会话撤销与业务共享协调用户锁。

受限或源角色失效而仍有active参与者，仅可拿本人 `exit_tickets` 的id/revision/registration_state/cancel，不含活动标题、地点或其它人。本人退出与拉黑/解除好友/登出/注销独立，不归并为同一动作。

## 3. 环境、APK和实际旅程

本版新库 `elitesync_v10_1_4_dev`，容器 `elitesync-v1014-buddy-db`、卷 `elitesync-v1014-buddy-data-20261021`（名字含buddy但确为本版新资源），MariaDB10.11、`127.0.0.1:43325`，实测REPEATABLE-READ。API仅8019；WS8020未启动。有效APP_DB_CONNECTION=mysql，本版local、无URL/socket且具名库/端口guard；PHPUnit先验证testing/sqlite/:memory:/空URL，TestCase与phpunit.xml事故防护未改。迁移前空库恢复点保留；未触碰任何旧库内容。

| APK项 | 结果 |
|---|---|
| 应用 | `com.elitesync.v1014dev`，`10.1.4-dev / 1010401` |
| 构建源码 | `3e5afb33c87812ffa2970741c4ea97a4c649da91`，Root `a1984f36c0b95d1d78f6c34e06937850972b3ebb` |
| APK apps Tree | `b502d776c8e5f916f2d4074b90a39d0547b896fa`，与最终源码逐对象相同 |
| 最终运行后端 | `e7e246dc70f72846a05a31e022efadee0838ab83` / services `45869d8b765ca8c645a04f747bb67be03a5bd632`；后继仅后端/Feature修复，未冒称重新构建APK |
| ABI / 签名 | arm64-v8a + x86_64 / 开发签名 |
| signer SHA256 | `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09` |
| 文件bytes | `411786303` |
| APK SHA256及安装pull | `250497191485fff57eea7eb5f287f69562d07011e726043f272b7f680bd252b7`，原文件与AVD安装回取相等 |

离线构建 `assembleDebug -PflutterDartDefines=ELITESYNC_V1014_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain`；构建、badging、签名、安装、pull核验均exit0。APK仅LOCAL_ONLY，未传GitHub。只获准既有受控AVD安装，摄像头/音频关闭；未碰接入的真实手机或更改系统SDK。

**实际联合链**：具名合成管理员在真实Web创建/审批/开放主活动，定向邀请A/B/C/D；A/B在同一最终APK主动报名，Web确认；C在APP候补1，D经真实HTTP候补2（不冒称D为APP GUI）。A在APP自愿SELF_REPORTED；A/C分别APP提交独立CONDUCT合成报告；D经HTTP的未核实ATTENDANCE报告由Web人工驳回，未处罚。

Web对主案triage/investigate，先分别有理由访问A/C的当前证据，再明确人工判断、substantiate、调用既有restrict。B的完整活动卡变最小退出票；B从Me实际打开Safety并提交本人申诉；WebUPHELD，B在APP读回。Web另行普通restrict作为独立处罚。B在APP主动退出后旧活动卡消失，Web原证据404；Web最小申诉工作台OVERTURNED，B在APP读回推翻结果，独立限制仍在。

数据库sanction1 inactive、sanction2 active；原REVOKED好友、CN_CLOSED、MC_REVOKED和block全值hash复核不变，无权限暗复活。Web越序提升D返回409，业务表全值不变；之后按序提升C，C在APP读CONFIRMED。WebCLOSED和COMPLETED均由C实际APP读回；完成后本人仍可退出。

受控停止API时APP刷新清除旧活动卡、显示Connection error。受控重启本版数据库/API和APP后，初始错误/错误路由截图保留；导航回Home平台入口后成功读COMPLETED。C实际点击取消→确认，卡消失；DB仍COMPLETED、C=CANCELLED_BY_USER、grant=REVOKED，decision/review/sanction完整值未变。真实HTTP再验本人列表200、旧UUID404。管理端重启后读同一完成状态和1/2确认席，最后正常退出。

## 4. 冻结AC逐项结果

下列PASS仅为Codex在冻结合成开发范围的回报；Astra尚未独立验收。证据别名的原件均LOCAL_ONLY；可公开摘要在[审阅目录](https://github.com/zcx369658780/EliteSync-v10/blob/8e639a3f22fe85eaf267f518c7205e4973dd5092/docs/_temporary_review/v1014-20261021/README.md)，逐文件映射/哈希见manifest。

| AC | Codex结果 | 实际结果与边界 | 证据别名 |
|---|---|---|---|
| AC-10.1.4-01 基线与隔离 | PASS_IN_CONTROLLED_SCOPE | 已接受v10.1.3两产品子树；仅新具名库/卷；测试防误清门未改。 | `baseline.json; test-env-guard.json; runtime_bootstrap.php; empty-backup.json` |
| AC-10.1.4-02 Web活动及模拟预算 | PASS_IN_CONTROLLED_SCOPE | 实际Web创建/审批/开放/关闭/完成/取消；缺CSRF419、错revision409。 | `web-created.private.ax; web-event-ready.private.png; api-web-negatives.summary.json; Feature` |
| AC-10.1.4-03 APP邀请/报名/候补 | PASS_IN_CONTROLLED_SCOPE | 同一最终APK，A/B报名及Web确认；C候补后获人工提升；拒绝未邀请/旧凭据/伪actor。 | `app-A/B/C XML+PNG; web-confirm-A/B.private.ax; api-web-negatives.summary.json` |
| AC-10.1.4-04 名额及取消并发 | PASS_IN_CONTROLLED_SCOPE | MariaDB两独立服务进程抢最后席200/409，fresh retry候补；Web越序提升409且无业务写入。 | `capacity-summary.json; fifo-web-negative.summary.json; Feature; completed-exit-db-verification.json` |
| AC-10.1.4-05 排程/自述/费用真实性 | PASS_IN_CONTROLLED_SCOPE | SELF_REPORTED不代表核验，完成不证明出席；预算仅整数模拟；本人取消无Finding或处罚。 | `app-A-self-reported*; app-C-restart-platform*; final-persistent.json; Feature` |
| AC-10.1.4-06 举报及证据授权 | PASS_IN_CONTROLLED_SCOPE | APP真实提交两个独立合成CONDUCT报告；D经HTTP提交未证ATTENDANCE报告并Web驳回；最小指针/当前授权/审计。 | `app-A/C-report*; web-D-dismissed.private.ax; api-web-negatives.summary.json; Feature` |
| AC-10.1.4-07 规则辅助与人工决定 | PASS_IN_CONTROLLED_SCOPE | 固定规则ADVISORY_ONLY；Web明确证据勾选/具名理由/人工判断/版本；调用既有UserGovernance。 | `web-A/C-current-evidence.private.ax; web-A-substantiated.private.ax; web-A-restrict-actioned.private.ax` |
| AC-10.1.4-08 申诉复核和有界纠错 | PASS_IN_CONTROLLED_SCOPE | B实际APP申诉，Web维持后推翻；仅sanction1失效，独立sanction2仍active；CN/MC/block/好友事实全值不变。 | `web-B-appeal-UPHELD/OVERTURNED.private.ax; app-B*; social-before/after.json; legacy-restore.summary.json` |
| AC-10.1.4-09 撤权及精确RR | PASS_IN_CONTROLLED_SCOPE | 实际HTTP reader与独立真实service writer；两组users PRIMARY等待/COMMIT顺序；404/401且无越权副作用。 | `rr3-event-revoke.summary.json; rr3-safety-logout.summary.json; permission-matrix.summary.json; role-after.summary.json` |
| AC-10.1.4-10 APP/Web/API/DB真链 | PASS_IN_CONTROLLED_SCOPE | 获准AVD与同本地Laravel/MariaDB；实际多角色链、离线旧卡清除、受控重启后APP读回并退出。 | `APK manifest; multi-role XML/PNG and Web AX; app-C-restart-platform*; completed-exit-db-verification.json` |
| AC-10.1.4-11 持久性与相关回归 | PASS_WITH_HISTORICAL_OBSERVATIONS | 87业务表全值哈希和行数重启前后相等；51/1182定点通过；旧共享套件5失败基线同现，未删除或弱化。 | `restart-result.json; durability-before/after.json; feature-candidate-fixed; baseline-shared-regression-v2` |
| AC-10.1.4-12 固定交付与资源终态 | CANDIDATE_PREPARED_FOR_INDEPENDENT_ACCEPTANCE | 源码/39份公开审阅副本已普通发布并独立回读；正式报告/manifest随后同分支发布回读；所有私密原证仅LOCAL_ONLY。 | `artifact_manifest.json; non-author-review.md; command-exit-index.json; protection-result.json; resource-final-state.json` |

### 精确RR与容量原证

| 场景 | reader / writer连接 | 次序（Unix秒，原样保留） | HTTP及副作用 |
|---|---|---|---|
| 活动资格撤销 | 220 / 219 | writer锁1792572824.732963 → locator首次读取1792572824.893353 → users PRIMARY等待1792572825.159487 → 撤权COMMIT1792572825.225224 → 请求完成1792572825.2433732 | 404，无私密响应；无越权report/notification/sanction写入 |
| Safety旧设备会话 | 226 / 225 | writer锁1792572826.564215 → locator首次读取1792572826.660364 → users PRIMARY等待1792572826.883845 → 撤session COMMIT1792572826.912883 → 请求完成1792572826.914648 | 401，无私密响应；只会话/token预期撤销 |

两组实测REPEATABLE-READ，事务外locator transaction_level=0；实际HTTP带正常产品middleware，writer独立进程走真实服务。第一组允许Sanctum正常last_used_at/updated_at更新，逐字段剥除后其它token值相同；其它业务写变化仅writer撤权/审计。脚本和摘要均公开，带私密响应/全表值的原件不公开。500/死锁/观察器失败不算权限拒绝。

RR运行源为`7d4bfb1cdd681c056ca3b434fc6178c17928e8f6`，其后`e7e246dc`只扩大COMPLETED本人退出的三个状态guard与对应Feature，RR定位/当前读/锁序未改，精确区分复用来源。容量原证为两个独立MariaDB服务进程：capC200、capB409，败者fresh revision重试WAITLISTED，预留2/容量2；**不冒称双HTTP容量测试**。

真实负例还覆盖anonymous401、未邀请404、伪actor422、伪证据422、旧revision409、缺CSRF419、跨案404；Block提交后两侧旧活动/报告/证据404，通知列表200但旧私密通知不可见，unblock不重新授权；真实治理禁用/注销请求后旧tokens401、重新登录403（注销仅DELETION_PENDING，无擦除）；主办role降user后用户404、旧Web403，finally恢复合成管理员role；旧Web cookie logout后401。自然12秒过期首个用户HTTP404，同时DB event/registration EXPIRED、grant REVOKED，未借后台预读生成终态。

## 5. 必要回归、非作者复核与原失败

- 最终固定源码PHPUnit定点：**51 tests / 1182 assertions，exit0**；含平台18项及已接受Buddy/Community、Social、旧申诉和Web相关测试。保留2个PHP和2个PHPUnit deprecation，不写成完全无警告。
- 最终平台/通知Flutter测试 **30 tests / exit0**；定点analyze exit0；最终36变更路径中的22个PHP语法检查exit0。
- 扩展旧共享回归44 tests/387 assertions/5 failures/exit1，接受基线隔离archive同5项同断言数：V1007旧同意fixture四个404，V1008旧publish fixture一个422。没有删断言、改skip或追改无关历史。全仓Flutter旧8条info保留，作者2条大括号info已修；无重跑全部算法oracle。

一次有界非作者集中静态复核由独立helper完成，含同组问题修复关闭检查，不是作者自审，不代替Astra。原发现保留：P1旧audits/user详情泄漏新Safety理由/关联；P1旧restore绕过CaseReview；P2到期404回滚终态；P2受限用户缺退出入口。均已补实现及回归，并有实际旧restore422/无持久副作用、角色撤销404/403、自然过期和APP最小退出验证。作者实际发现主办role失效仍返回200的缺口另保留原失败并修复。末次非作者确认e7e完整身份及COMPLETED仅放开本人退出，无剩余静态阻断；复核者未独立执行DB/API/设备/测试。

原始失败、stdout/stderr/exit保留并公开[最小退出码索引](https://github.com/zcx369658780/EliteSync-v10/blob/8e639a3f22fe85eaf267f518c7205e4973dd5092/docs/_temporary_review/v1014-20261021/command-exit-index.json)、[失败摘要](https://github.com/zcx369658780/EliteSync-v10/blob/8e639a3f22fe85eaf267f518c7205e4973dd5092/docs/_temporary_review/v1014-20261021/original-failures.json)，无截断原件追绿：

| 原失败 | 后续及准确边界 |
|---|---|
| Docker不可用exit1 | 正常启动已安装Desktop后新环境v2成功；无WSL修复/UAC。 |
| Feature首轮15项14失败、v2四、v3一 | Cookie前置及evidence_checked条件修复，v4过；原件留存。 |
| HTTP session初配置错误、v2路径断言错误 | 正确ADMIN_PHONES后真实登录；v2实际登录成功但脚本错期待/admin/users，v3过。 |
| Widget首轮1/11失败 | 输入后pump并断言按钮enabled；结果断言保留，最终30过。 |
| 基线依赖symlink WinError1314 | 无提权，复制依赖后基线历史5失败同现。 |
| Windows CRLF whitespace exit2 | 命令局部识别既有cr-at-eol后exit0；无全局Git更改。 |
| RR观察器拼接错误/500、barrier timeout | 不计拒绝；观察器修后rr2实际404，harness漏认证时间字段仍exit1；raw verifier及最终rr3两组exit0。 |
| 主办role撤销前真实200/403、exit1 | 当前source authority锁后复核，真实重测404/403。 |
| ADB一次截屏exit4294967295、嵌套页导航错误 | 私密stderr保留；正常定点导航与截屏后续成功，无清APP数据。 |
| 活动名称V1014被保守数字过滤422 | 改合法合成名称成功；原错误截图留存。 |
| 继续会话PowerShell未引号Git revision解析错误 | 仅只读命令失败；后续参数数组固定完整对象，无Git修改。 |
| 交付材料生成校验两次exit1 | 首次浏览器证据写到本版证据目录相邻的精确具名位置，原件保留并按字节相同复制归位；第二次隐私检查误将https URL识别成Windows路径，修检查表达式后通过，未放宽账号/token/个人路径排除。 |
| 首次发布回读匿名GitHub REST403/exit1 | 限流；既有gh认证REST及独立raw HTTPS回读成功，原失败保留。 |

已知观察：Web409为标准冲突页，需返回刷新再操作；本版平台通知的实际GUI点击未单独完成，Widget导航/当前权限API已验证，不能升级为GUI已证。APK是开发包、仅AVD；未证明真实活动现场、到场真实性或生产稳定性。

## 6. 重启、备份、保护和资源终态

受控重启前后**87张业务持久表**（包括全部新表、accounts/tokens/device sessions、reports/sanctions/appeals/notifications/audits和旧业务）行数及full_value_SHA256逐表完全一致。仅排除cache/cache_locks/sessions；Web实际使用file sessions。重启后C合法退出、鉴权时间与Web正常logout属于后续操作，另记`final-persistent.json`，不强求其与重启前一样。

最终SQL恢复点：244218 bytes，SHA256 `42d921b9af23a7525c3ef1109561c6fdf686838a34cd937d63074a91f4d45cf2`，dump exit0。迁移前空库及pre-restart备份均保留；恢复到另一库演练NOT_RUN，不冒称备份已复原验证。

五保护根（原dirty根、旧仓及三个前序专用树）HEAD/branch/status/index/.env哈希前后完全一致；前版证据顶层metadata清单及6件旧SQL/APK哈希一致。未reset/stash/clean/prune/删分支或旧工作树。29个旧容器ID/名称/image/state/mounts/ports/labels稳定元信息相等，未打开旧数据库计算内容hash，不把元信息比较冒称旧库全值核验。

本版最终API **STOPPED**、新DB容器 **EXITED**、持久卷 **RETAINED**、AVD **STOPPED**、本版reverse8019 **REMOVED_VERIFIED**；loopback8019/8020/43325均关闭。Docker Desktop/全局ADB/WSL及其他服务未停；所有本版原始证据/私密账号/SQL/APK和旧资产保留。主候选工作树用于连续接续，无另建清理任务。

## 7. 公开审阅范围及NOT_RUN

39份最小公开副本在独立临时分支，不合产品分支或main。每件公开Git Blob、SHA256、bytes，原件前后映射在manifest和[redaction-map](https://github.com/zcx369658780/EliteSync-v10/blob/8e639a3f22fe85eaf267f518c7205e4973dd5092/docs/_temporary_review/v1014-20261021/redaction-map.json)。脚本不含私密fixture，只有http_front个人路径替换为环境选择；原字节/转换后hash均登记。实际SQL、APK、原始截图、cookies/tokens、随机合成账号、原始响应/日志和个人路径保持LOCAL_ONLY，未冒称Astra直接读取这些物理原件。

NOT_RUN / NOT_AUTHORIZED：真实手机安装/双端通话/麦克风/摄像头；RTC/WS/UDP/防火墙/DNAT/UAC/系统升级；云端阿里试点、公网、证书、备案；真实招募/场地预订/GPS签到/费用或支付；真实实人provider/外部AI/外部Safety供应商；正式Push/真实线下履约；backup restore演练、迁移down、实际账号擦除；所有无关算法oracle；main集成/独立接受/旧资产清理/v10.1.5。

保留前版边界：v10.1.0整版PARTIAL/NOT_ACCEPTED和AC-10.1-08 PARTIAL；v10.1.1误清事故/恢复原证，v10.1.2/1.3原失败；真实身份PROVIDER_PENDING、RTC/AEC和前版通知GUI观察不清零。2026-10-21原项目源ZIP原字节镜像仍BYTE_MIRROR_PENDING，本轮未获得原ZIP、未扩大搜索或重造，未阻断功能交付。最终交付后停止，等待Astra独立功能验收。


## R1｜历史最小报告受理与内部案卷连续性（2026-10-21追加）

**V10.1.4_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / MAIN_PRODUCT_NOT_INTEGRATED / V10.1.5_NOT_STARTED / NOT_YET_ACCEPTED**。本节仅处理Astra所列B1/B2，原报告正文和历史结果逐字保留；原结论中“旧报告/所有证据404”的自测只证明社交撤权，不能再当作Safety连续性通过。以下是Codex执行回报，不构成Astra接受。

### R1固定身份

| 对象 | 身份 |
|---|---|
| 唯一R1任务 | `ASTRA_REVIEW_AND_R1_TASK_20261021.md`，Blob `36d6b3549e0fd1dff2fc44f6db72ac62c7d4f0fa` |
| 本轮live main（开工及源码发布回读） | `c6ef1fef6d03bfaefc9f334b3b5a6c362dc07e01`，Root `14fbc6db1d25c134531daf82d2cfaf796f8580cb`；产品仍为接受v10.1.3，未合本候选 |
| 原源码／完整交付 | `e7e246dc70f72846a05a31e022efadee0838ab83` / `4f303bc3674edc599c9602e6704a97deb6dce4ba` |
| 唯一R1源码Commit | `1062603bfd5866eb4c40b4773657343a1eca2af7` |
| R1源码Root Tree | `aa4c47569d60a5e5638c25e9b0e3c0d7e1760da5` |
| R1 apps Tree | `3468a3dd97da7accfda2539a0f8d8f68931a6110` |
| R1 services Tree | `0cb1f9d19659291a462488b3686fd0a07a6698ac` |
| R1候选分支 | `codex/v10.1.4-r1-safety-continuity` |
| R1独立审阅Commit／Tree | `d59cb76d41a0a0d81947d584ac6228554c82fda0` / `b1cae2fbc0cc813bf2f2e63e2322b2a41d59004b` |
| R1审阅分支 | `review/temporary-evidence-v1014-r1-20261021` |

相对原完整交付仅9个产品路径，mode/Blob见新增`artifact_manifest_R1.json`；原`artifact_manifest.json` Blob仍为`107817209f195d183392f3a6fda96d456fd5059f`，未重写。原报告Blob `17b859acf31c6ab5e63200fec3ecff5aaea3691b`作为本文件不可变前缀。源码及36份最小审阅副本已普通non-force发布，并通过独立GitHub REST元信息＋raw HTTPS字节回读。原候选分支仍在4f303bc、原39份审阅分支仍在8e639a3f，均未移动。正式追加报告与R1清单随后只做文档提交，最终交付Commit/Root/文档Blob由发布后回读及最终答复固定。

### B1/B2修复前后真实对照

| 问题 | 原源码真实HTTP／DB反例 | R1结果 |
|---|---|---|
| B1先安全退出再报告 | A/B/C经真实服务受邀并实际HTTP报名；A主动取消后私有GET404，最小报告POST也404（期望201）。原报告/证据/决定/通知/处罚/访问审计无新增。 | 同一既有参与事实，退出并被B拉黑后，受限report-only入口POST201；仅OPEN、两条本案最小来源封存，无Finding/制裁。旧私有GET保持404。 |
| B2既有案卷调查断路 | A合法提交case，具名Web证据GET200；B经实际Block入口拉黑A后，原活动GET404且具名Web证据也404（期望受限调查200）。 | 原已收案可由当前具名管理员读取本案历史最小来源、审计、triage/investigate/dismiss；普通活动、旧资料和私信等权限不恢复。历史来源不足时不能substantiate/restrict。 |

原反例保存在`baseline-HTTP.private.json`；`baseline-summary.json`标明 **BASELINE_FAIL**，runner exit0只表示如实复现404，不表示产品已通过。随后单独两请求前后数据库完整值核验：仅正常Sanctum时间字段可能变，report/evidence/decision/sanction/notification/audit写入均0；无500、死锁或进程异常冒充拒绝。[公开摘要](https://github.com/zcx369658780/EliteSync-v10/blob/d59cb76d41a0a0d81947d584ac6228554c82fda0/docs/_temporary_review/v1014-r1-20261021/baseline-summary.json)／[数据库差异](https://github.com/zcx369658780/EliteSync-v10/blob/d59cb76d41a0a0d81947d584ac6228554c82fda0/docs/_temporary_review/v1014-r1-20261021/baseline-DB-delta.json)。

### 用途、来源与时间合同

**B1：`DEV_SAFETY_HISTORY_7D_V1 / REPORT_ONLY`。** 新SafetyParticipation从服务端既有`apply`审计的actor、registration_id、state及审计顺序重建真实合成参与；只受邀、客户端伪造APPLIED行、任意UUID或他人注册ID均不构成证明。双方必须在同一活动有可证重叠参与。窗口取本人退出／受影响撤权／活动完成或结束等已发生边界与event.end_at的较早值，再加7天，使用服务器时间；后续操作不重开窗口。这只是本版受控合成默认，不是Owner永久运营或法定保留政策。

新撤权审计精确记`affected_registration_ids`或`revoked_grant_id`，只影响对应参与事实；C/D之间Block不截断仍合法的A/B或后来同场参与者。旧无scope的审计不推定全体结束；仅已终止且缺精确收据的本行可按其updated_at保守设界，不能证明的同时间戳重叠拒绝，未撤权的当前参与者不被截断。

`GET /platform-events`增量下发`report_contexts`：仅本人已证范围的event指针、REPORT_ONLY/policy/deadline和同史目标registration_id＋不含身份资料的合成标签，无title/city/venue/头像/账号/媒体/关系。APP历史入口与普通活动卡并存，退出目标不因完整卡仍在而不可选；两种表单状态隔离。POST复用原`/platform-events/{id}/reports`，锁后复核actor/session/event/subject身份与参与来源，严格白名单类别/最小陈述/幂等。重复相同键仅同一case；冲突409，无法通过key跨活动或代替别人写。

**B2：`CASE_INVESTIGATION_ONLY / HISTORICAL_AUTHORIZED_FACT`。** 唯一R1迁移`2026_10_21_200000_add_safety_case_source_seals.php`只对原`safety_case_evidence`增3个nullable字段：`source_fact`、`fact_hash`、`retain_until`，不新增另一个处罚源。收案锁内只封存case/event/registration、内部身份绑定、参与起点apply审计、当时state/revision、捕获时间及用途版本；不复制私聊、证件、照片、精确位置或档案。Web返回还裁掉内部user_id，不向普通用户开放封存事实。

三十天是**合成开发存证读窗**（自原捕获时间），不是自动删除或真实法律保留期限；原记录和审计继续保留。过期、hash不符、跨案替换等只返回`CURRENT_SOURCE_UNAVAILABLE / INSUFFICIENT_EVIDENCE`且无source_id/historical_fact，当前有权管理员仍可进行最小程序性处理。可用封存明确标历史，live来源另标CURRENT_SOURCE_AVAILABLE/UNAVAILABLE，不冒称当前有效参与或危险行为证明。旧case仅在原source_hash可由确切原revision/state/attendance重构，并有服务端apply审计时补封；匹配不了就不造事实。包括SELF_REPORTED的旧hash正向重建已逐条验证，但输出到场仍UNVERIFIED，不证明现实出席。

当前管理员role/phone/account/Web session、case版本和访问理由在事务内复核；访问与理由进入OperationAudit。B1定位仍只在事务外取得身份线索，用户按协调顺序加锁后复核event/registration/audits及当前session，未降低RR。本人case所有权只保留OPEN/调查/驳回等最小收据及申诉，不能拿它读取旧活动、举报原文或他人资料。处罚/申诉原合同独立；历史参与、两条指控或规则建议不直接形成Finding；历史-only来源使认定/处罚返回422，允许具名调查或证据不足驳回。

### 定向执行与实物链

- 新增10项R1 Feature，连同直接相关原平台Safety18项：**28 tests / 1644 assertions / exit0**；原2个PHP和2个PHPUnit deprecation保留。定向平台页面 **15 Widget tests / exit0**，包括历史目标在完整卡旁可选、跨会话晚到不可回填；两文件analyze exit0，7个相关PHP文件lint exit0。没有重跑完整原51后端、原30 Flutter、Buddy/社区、全算法或整套真实预算流程；旧结果保留。
- 真实HTTP验证B1受理201、相同键同case、冲突409、陌生人/跨活动/随机指针404、客户端source_fact422；旧A/B活动GET仍404、本人最小收据200、陌生人case404。B2历史来源200，具名调查及驳回；同活动两条历史指控不能认定（422）。管理员降普通角色403并finally恢复，真实C设备session撤销后401。所有原sanction完整值不变，原关闭好友/CN/MC/Block事实逐行未变，无正式关系或Buddy复活。
- 同本版既有独立库`elitesync_v10_1_4_dev`及原专用volume，先留R1前恢复点再迁移；有效APP_DB_CONNECTION及testing/sqlite/:memory:/空URL guard先核，TestCase/phpunit.xml未改。没有初始化其它库或运行migrate:fresh。
- 最终源码精确RR组：reader **99** / writer **98**，REPEATABLE-READ，locator transaction_level0；writer锁用户`1792577383.69972` → 实际Web首次case读取`1792577384.088857` → users PRIMARY等待`1792577384.310063` → 真实revokeAdminSession COMMIT`1792577384.332325` → HTTP401完成`1792577384.3653078`。只精确Web session撤销表变化，无泄漏及越权report/evidence/audit/notice/sanction副作用。原中间77/76组保留，最终99/98组绑定1062603源码，观察器随后移除。
- 仅十张直接相关参与/Safety持久表作本轮受控DB/API重启核验，行数与full_value_SHA256完全相等；原87表证明保留，不冒称本轮又验收全部历史功能。重启后的合法APP/Web操作单独记最终快照。
- R1新APK从固定1062603源码离线重建、签名核验、AVD安装并pull一致。A在APP登录后只见历史report-only入口，无原活动卡；选择原B参与指针并提交实际最小陈述，MariaDB形成精确原event/subject的OPEN case与两条封存，Block仍在，无处罚。Me本人Safety卡读“报告已登记，尚未形成认定”；APP冷启后再次读回。Web实际GUI另开历史案卷，读到用途限制与CURRENT_SOURCE_UNAVAILABLE，填写具名理由完成TRIAGE→INVESTIGATE并读回，audit/reviewer落库。

| R1 APK | 身份 |
|---|---|
| appId／版本／ABI | `com.elitesync.v1014dev` / `10.1.4-dev / 1010401` / arm64-v8a＋x86_64 |
| 构建源 | `1062603bfd5866eb4c40b4773657343a1eca2af7`，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，同提交services组合 |
| 文件bytes | `411786303` |
| 新APK及安装pull SHA256 | `76e43dc2b9f187ec2824bbc636ae42b32cf30b95c90ea66158b1550182938eec`，二者一致 |
| 开发签名certificate SHA256 | `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09` |
| 原APK | `250497191485fff57eea7eb5f287f69562d07011e726043f272b7f680bd252b7`，保留未覆盖 |

APK、原图/XML、SQL、cookies/tokens、随机合成账号和原始HTTP/日志都保持LOCAL_ONLY，未上传二进制或私密材料。

### 非作者复核、原失败与剩余限制

一次有界独立非作者静态复核及同组关闭检查：原P1“无关撤权误截断所有人”、P1“完整APP卡遮掉历史目标”均修复；对应定向测试及旧hash两来源/SELF_REPORTED、篡改、跨案封存检查已补。复核者只读核对最终Commit/Root/apps/services，无剩余静态阻断；未自行运行测试或物理环境，结论不替代Astra。[完整最小复核记录](https://github.com/zcx369658780/EliteSync-v10/blob/d59cb76d41a0a0d81947d584ac6228554c82fda0/docs/_temporary_review/v1014-r1-20261021/non-author-R1-review.md)。

本轮原失败全部保留：首次26项4失败exit1（旧404合同断言、窗口测试混入仍合法的早期context、多余user_id），实现与断言按新合同修正且加强泄漏断言；新增测试漏必需phone的fixture错误exit2；最后加强来源检查时误用不存在的PHPUnit方法exit2，改为排序后assertSame；最终28/1644过。审阅材料准备已生成独立commit后，误用临时审阅index检查产品状态，导致元信息断言exit1；独立核实际产品index干净、审阅全部字节一致，未重复创建或移动原引用。UTF8逐行显示/具名只读路径查询和旧Git长路径警告均为工具层记录，未作产品权限结果。原首轮及历史5失败等不删除、不改成绿。

七天/三十天边界使用Feature服务器测试时钟验证，**未实际等待七天或三十天**。旧无scope且同时间戳不能证明重叠的历史严格拒绝，未补造过去事实。完整通知GUI、真实手机/摄像头/麦克风、RTC/UDP/防火墙/DNAT/UAC、真实身份/供应商/AI/付款/招募/场地、云试点、公网、全预算实物旅程、备份恢复演练、migration down、账号实际擦除均NOT_RUN或NOT_AUTHORIZED。原ZIP镜像PENDING及真实运营Safety／法定保留／严重事件处置能力未开放。

### R1保护、资源与交付

五保护根HEAD/branch/status/index/配置哈希一致；原v10.1.4证据文件metadata清单、关键两APK及SQL、原候选和原39份review引用均一致。29个其它旧容器稳定元信息未变，未打开其数据库；本版专用MariaDB只在原授权合成范围迁移/写入。最终恢复点`final-r1-backup.private.sql`：285881 bytes，SHA256 `e03e4dc54e63148835c64adc9fc35b4215b85859f6e5e4d461694efad8030576`，dump exit0，未做restore冒称。

本版API STOPPED、DB容器EXITED、volume RETAINED、AVD STOPPED、reverse8019 REMOVED_VERIFIED；8019/8020/43325关闭，WS未启动。全局ADB/WSL/Docker Desktop、真实手机和其它服务未停。所有旧资产、本版恢复点与失败原件保留，无清理。

36份公开安全副本在独立短期review分支，逐件远端raw字节已核，原件／副本bytes和SHA256映射见`redaction-map.json`；本地物理证据仍CODEX_REPORTED。报告只追加本节，原manifest保留，新清单为`artifact_manifest_R1.json`。发布候选与文档后独立回读；不合main、不自接受、不启动v10.1.5，完成后停止等待Astra针对B1/B2独立终验。

R1交付元信息补记：首次追加材料脚本已生成两份文件，但末尾对Git status使用strip裁掉了状态列前导空格，路径断言exit1；保留原失败后以原样porcelain重新核验，确认只追加报告／新增R1清单，未重复生成正文或触碰产品。
