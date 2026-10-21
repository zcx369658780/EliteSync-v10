# EliteSync v10.1.4｜平台虚构活动＋内部Safety闭环｜Codex唯一综合长任务

2026-10-21 Astra签发。**V10.1.4_LONG_TASK_READY / OWNER_ENTER_VERSION_APPROVED / MANUAL_CODEX_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED / V10.1.5_NOT_STARTED**。

本任务基于Owner已批准进入v10.1.4，**只有Owner把本任务完整转交本地Codex，才授予冻结开发范围的一次性连续执行权限**；本次仅发布工作任务，不自动启动服务、合产品main、采购或生产部署。不再恢复GitHub微任务人工message bus、无边界考古或重复版前规划。Codex范围内可自主调查、编码、必要修复、受控测试、非作者一次集中审查、脱敏证据发布和候选交付，不需要逐命令审批。

## A. 第一时间固定权威与真实工程对象

完整读取：
1. 唯一冻结计划`docs/versions/v10.1.4/plan.md`，**Blob `6f4157eeee47bc8d2fc4bbda5767025de0691347`**；本任务所有范围与AC-10.1.4-01～12以该固定计划优先。不回写或修改plan、Owner已确认决定及前版验收。
2. `docs/workflow/{ACTIVE_STATE.md,CURRENT_WORKFLOW.md,ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md,TEMP_REVIEW_EVIDENCE_PROTOCOL.md}`；`PRODUCT_DECISIONS.md`及2026-10-19 Owner决定/路线图§6.4；`docs/versions/v10.1.3/{acceptance.md,integration_acceptance.md,integration.md}`。
3. 定点读：`Admin/ReportOperations,UserGovernance,OperationAudit`；`SanctionAppeals`和现行本人申诉APP；`ModerationController,StatusCommentController,BuddyService,SocialPolicy,LiveConsentService`；现行`admin/reports`与真实RBAC/CSRF；必要数据库迁移和TestCase/phpunit防误清门。仅为本版实施服务，不开额外全仓考古。

已接受main前置基线产品：
- v10.1.3 apps Tree `d4569b330629d74c6e5f3ee1d6438245d7bfd024`；
- v10.1.3 services Tree `4d637a3fd827e00974887d9ce515a1833a8f3a8a`；
- Astra独立集成时main `cb0cad401955d537b9899a89b533941058d8de1a`；本计划签发后的纯文档提交可能更新HEAD，**开工实时GET origin/main、Root Tree及两子Tree后**再安全建候选，保留全部合法后继。

始终分别记录`SOURCE_AUTHORITY / GITHUB_ACCEPTANCE / CODEX_REPORTED_LOCAL_RUNTIME / EXTERNAL_GATE`。不得把运营审核标成实名、规则建议标成人工结论、预算草案标成真实付款或将用户举报原文输出给其他用户。

## B. 全版一次实施（真实用户旅程，不是Mock）

**B1 官方活动真实写入及预算模拟**：在现有独立Laravel/Web之上建立PlatformEvent聚合，不重命名/覆盖Buddy。Web具名管理员创建虚构城市/公共venue、时间/8席以内容量、内部模拟预算分类与整数金额、Revision、模拟批准/作废；具名权限、CSRF、审计、预算无实际支出含义。APP只有本人受控邀请及已参与活动，不建立全站公开活动列表、IP定位、真实预订/补贴/交易回执。保守可定点将内部预算界面仅给具名管理员，用户端显示虚构活动信息及`DEV_SYNTHETIC_EVENT`而不泄露内部成本。

**B2 报名/候补/名额公平**：客户端取得用户主动可见的官方活动卡，用户分别报名/撤回；主办方管理员确认名单、有人取消后候补按服务端时间顺序受控提升、关闭/取消/完成。至多一条每用户对每活动的活动参与事实，活动2–8受控席位。事务/唯一性保证真正MariaDB并发不超量；请求带actor/context、revision、可用幂等键，不能重复通知或改变别人报名。无票时可按能力返回WAITLISTED/NO_CAPACITY而不是假定已确认。主办方处理名额不等于强制参加、双方正式恋爱或真实签到；两人确认到场可自愿填`SELF_REPORTED`测试项，不能因拒填被记过。

**B3 内部Safety案卷与授权证据**：复用既有ModerationReport、UserGovernance、SanctionAppeals、OperationAudit，增量建立`SafetyCase/CaseEvidence/CaseDecision/CaseReview`等必要事实，明确报告与Finding不能同表同状态冒充。活动参与者对当前属于自己的真实合成活动可提出纠纷/安全报告；“未到场”“取消”“不回复”“拉黑”并不等于违规。证据只存必要来源ID、类型、版本/哈希及合法访问上下文；不要将完整私聊、证件、照片、精确位置、他人评分复制到平台活动表或长期AI数据包。匿名、跨账号、跨活动、已撤权/伪造证据指针必须fail-closed。保留现有旧举报/举报人异议等原合同，不让新`CaseAppeal`取代被处罚者的具名SanctionAppeal。

**B4 无外部LLM的辅助分类与人工判定**：采用固定可复核小型本地规则词表/事件状态校验产生`ADVISORY_ONLY`，记录规则版本、类别、解释边界、不确定性；不调用外部模型或用分数定罪。Web后台人工TRIAGE/INVESTIGATE/DISMISS/SUBSTANTIATE等需具名reviewer、reason、当前revision、权限及审计；重大restrict/banned严格调用已接受`UserGovernance`具名处罚和Account门禁，不能让Safety case状态自动颁发独立封号能力。管理员拒绝规则建议应可记录，但不能删原报告或历史证据。

**B5 真实本人申诉→复核→纠错**：已受限用户在Me现有申诉卡或同权限合理入口读取本人最小Sanction事实并提交申诉。授权Web管理员看到必要限域解释及状态、可UPHELD/OVERTURNED/CORRECTED、有版本/身份/理由的复核事务并通知本人。推翻仅恢复对应原`admin_sanctions`，由`UserGovernance::restore`处理其它独立生效禁令，保证恢复不会替用户重开Block、旧CN/MC、历史正式Relationship/Buddy或已撤销聊天权利。对举报方“不满意处理结果”的原API继续按它的报告归属，不能代替被处罚用户自动解禁。无需真人人工审核：**使用授权虚构Web管理员完成实际人工选择的开发演练**；不能仅靠测试脚本把`reviewer_id`直接写库模拟Web处置。

**B6 APP/Web一致**：Home/Progress平台活动次级入口，Me或当前Safety组件本人结果／申诉，四Tab不变；原Buddy和慢约会入口仍真实可操作。所有显示/按钮状态来自实时受控API，离线/切号晚到/无资格/候补/取消应区分，不能把假活动/AI说明冒充已经确认的线下见面。Web活动／预算／Safety审计使用现有auth:web/account.active/admin.phone+CSRF及必要角色守护，不提供APP内管理员页、普通用户无限审阅或安全案件全库下载。

## C. 先于任何测试的环境及不可变保护

- 本版只建新归属本地MariaDB `elitesync_v10_1_4_dev`、新独立volume与loopback端口建议43325，API8019，WS8020仅真的需要才开。必须确认确属本版空库/端口没有占用；事前DB连接有效`APP_DB_CONNECTION`优先、DB_CONNECTION/URL/socket/host/port/db/APP_ENV、PHPunit `testing/sqlite/:memory:`防误清及TestCase前置fail-closed。新空库迁移前建立恢复点，完成也另留恢复点。不得`migrate:fresh`旧v10.1.1事故库、v10.1.2/v10.1.3库、阿里云生产或未知3306。
- 原dirty `D:/EliteSync-v10`、旧`D:/EliteSync`及各已归属的功能/集成worktrees/原本untracked/ignored成果、APK、SQL、审阅分支、历史失败及备份/卷**不得盲动**。当前有干净连续开发树则优先复用，必要时一个隔离树；不乱pull/reset/rebase/stash/clean/prune/force。最低必要保护哈希、HEAD/index/status事前事后对照，原历史测试失败不能删除或改名假PASS。
- 可在获准受控AVD演练新的v10.1.4开发APK，包括构建、安装、pull SHA、与同版本API/独立DB实际贯通；不代表授权真实手机/麦克风/相机、UDP/防火墙、UAC、全局SDK安装、真实线下活动，亦无许可联系真实场地。若确需外部供应商/费用/新系统权限，**只暂停涉及的风险子项并报Owner**，不反向停全版。
- 不对外实名招募、不花真钱、不得生成实际付款流水/虚假官方订单/真实保险或安全保障声明。无需真实地图经纬度、身份供货商、系统Push、外部LLM、企业备案、云端公网/平台客服履约，也不启动v10.1.5。
- 公开GitHub仅源代码、合成示例与最小脱敏证据。SQL备份、真实令牌/联系方式、模拟账号token、APK、设备原始截图/原始日志仅LOCAL_ONLY，不把已有2026-10-21原项目源ZIP镜像缺口扩成新的治理长任务。

## D. 最终验证：冻结AC-01～12逐项有证据

**AC-01** 真实已接受v10.1.3完整产品基线，新独立库/卷/备份及有效DB选择guard；测试事故防护不能靠记忆猜测。

**AC-02** 有权Web管理员实际创建、审阅、关闭活动及预算模拟记录；普通用户、CSRF缺失、错revision不可写。数据库版本/审计/金额整数/币种与Web展示一致；没有真实支付API调用。

**AC-03** 合成用户A/B/C在同一安装Android APP读经受控邀请的活动、报名与候补，管理员Web确认，用户APP重读；未授权裸UUID/旧token/拒绝/到期/Block后无法取得别人活动信息。

**AC-04** 真实MariaDB独立会话并发争最后一席，确认席位不超上限；候补提升、多个取消/过期/重放/旧revision、管理员与用户竞态均有正确幂等与审计，不能用SQLite或全局sleep代替，所有失败无重复站内通知/处罚。

**AC-05** 排程完成和自愿到场声明严格区分；取消／担心安全／不回复不会变违规或失约Finding；预算已模拟审批不等于实际花钱，不能从这些触发支付或真实预订。

**AC-06** 具名当前有资格用户的活动报告提交后仅`REPORT_SUBMITTED/CASE_OPEN`，无Finding/制裁；第三方/过期源/错actor/裸报告ID无法枚举或读正文，管理员证据访问确实留审计且不复制私信/定位。

**AC-07** 规则候选`ADVISORY_ONLY`、rule_version/不确定性有记录，不调用LLM；Web人类角色具名决定/因由/revision/CSRF和Audit可核，不能客户端`verified`或“AI判罚”越权。

**AC-08** 完整可逆案例：无证据报告被Dismissed且不改处罚；另一个已核实合成案由管理员具名操作调用现有restrict→本人APP申诉→Web人工复核UPHELD/OVERTURNED→对应sanction有界恢复、独立其它处罚仍有效，CN/MC/Block原事实未被暗复活。旧SanctionAppeal路径正反回归。

**AC-09** 至少两组真实MariaDB `REPEATABLE-READ`精确reader/writer连接ID＋事务/行锁/撤权COMMIT时序，覆盖如活动报名资格撤销与Safety证据旧读/旧会话；撤权后404/403/401，报告/预算/通知/制裁越权副作用0。不能将500/死锁或观察器报错记为拒绝PASS。

**AC-10** APP→Laravel→独立MariaDB→Web→APP真实多角色正反链，必要受控重启，功能可从已固定开发APK重新登录读回；无伪造运营现场或设备能力。Widget/单元补回归但不替代实物链。

**AC-11** 新旧相关事件、预算、报名、报告、case、sanction、appeal、通知、审计持久表具名重启前后`full_value_SHA256`和行数相等（重启后新增合法操作单独记最终快照），Bug不能通过截断原失败或统计单元测试数遮蔽；共享Block、Buddy、Status及MC权限定点回归。

**AC-12** 单一正式`docs/versions/v10.1.4/IMPLEMENTATION_REPORT.md`和artifact_manifest、最小脱敏review包、实际命令exit/stderr/stdout索引、独立非作者有界复核、版本APK源码Commit/Tree/apps/services/签名/ABI/hash/install回读、库/卷/服务停止备份、所有保护根一致及NOT_RUN和保留缺口。发布普通non-force候选和短期独立审阅refs，不能自行ACCEPTED或合产品main。

测试/APP/Web/DB证据分别标`CODEX_REPORTED / LOCAL_ONLY`，公开副本明确裁剪前后哈希/bytes，不公开登录令牌和私密原始数据库。对于用户未给真实场地/外部身份及资金，不得编造通过证据。

## E. 候选发布、审阅与退出

- 在专用候选分支实施（建议`codex/v10.1.4-platform-events-internal-safety`），以实时main为起点，保留全部后继合法Owner/治理与v10.1.3源码；不要从未接受旧v10.1.0云端分支整包merge。可多次正常提交，不强求单产品Commit或每次分新worktree。
- 完成一轮功能开发、测试、必要修复和一次有界非作者静态安全复核，集中固定**唯一接受候选源码Commit及完整Root/apps/servicesTree**；随后追加唯一报告与manifest，普通non-force候选推送并REST核源/文档Blob。临时审阅证据只在独立短期branch，不并入main，不清原review refs/备份/SQL/APK或局部失败。
- Codex不得自己签`V10.1.4_ACCEPTED`，不得把测试字段/规则建议写成真实运营或外部AI成功，更不得把活动签到冒称GPS真实到场。原R1与历史限制持续，v10.1.0整版`PARTIAL/NOT_ACCEPTED`、AC-10.1-08 PARTIAL、真实实名`PROVIDER_PENDING`、v10.1.3通知点击GUI未单独完成和项目源ZIP byte mirror仍PENDING。
- 真实阻断才允许同版局部集中修复/补证；需要扩大用户可见活动公开范围、费用、法定保留期限、真实身份或不可逆处罚新政策时暂停该项向Owner问明，不重开全版规划。交付后停止，**正常终态**：
`V10.1.4_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / SYNTHETIC_PLATFORM_EVENTS_ONLY / NO_REAL_PAYMENT / V10.1.5_NOT_STARTED`。
