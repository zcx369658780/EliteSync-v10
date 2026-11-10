# EliteSync v10.1.4｜Astra独立功能审阅与单次R1集中返修

2026-10-21，Astra（EliteSync GPT顾问）。**V10.1.4_CHANGES_REQUIRED / NOT_ACCEPTED / SAFETY_INTAKE_AND_CASE_CONTINUITY_P1 / R1_TASK_ISSUED / OWNER_MANUAL_DISPATCH_PENDING / MAIN_PRODUCT_UNCHANGED / V10.1.5_NOT_STARTED**。

本文件是Astra独立源码审阅裁决及一次集中返修合同，**不是Codex自行验收**。本次直接复核了GitHub源码、历史Owner合同、冻结AC、报告、实际Git对象及39件短期脱敏证据中的代表性业务与并发结果。Astra**未操作本地Windows/MariaDB/AVD**，因此下述B1/B2为可从已发表源码确定的控制流反例；未宣称已在本地实测其HTTP及具体业务副作用，更无真实用户事件证据。Codex R1须先补可核实的前后对照而非臆造红测。

## 1. 固定源对象与保留的已证成果

- 实时main（审阅时）`b7d04f73b60b60baf2ff6e45d8a72d353d96aa01`，仍为独立接受的v10.1.3产品。
- 唯一候选产品Commit`e7e246dc70f72846a05a31e022efadee0838ab83`；Root Tree`e9ca41a1347fdeebdedca18de6f8eed767b59d5c`；apps Tree`b502d776c8e5f916f2d4074b90a39d0547b896fa`；services Tree`45869d8b765ca8c645a04f747bb67be03a5bd632`。
- 完整交付Commit`4f303bc3674edc599c9602e6704a97deb6dce4ba`，Root Tree`d9358d829c8c93eccbbec9320dc2f45a597d1241`；唯一实施报告Blob`17b859acf31c6ab5e63200fec3ecff5aaea3691b`；artifact_manifest Blob身份从原GitHub内容再读取、不要重写原manifest。
- 39份短期脱敏审阅材料Commit`8e639a3f22fe85eaf267f518c7205e4973dd5092`，Tree`3e861c30fabf147b3bc0f1dd69443887f0526b66`，目录`docs/_temporary_review/v1014-20261021/`。39/39 manifest的path及Blob和固定Git树一致，36个变更产品路径的path、mode、Blob与候选源码Tree一致，候选源码基于接受main正常前进5个提交，交付后只补正式报告/manifest。
- 冻结plan`docs/versions/v10.1.4/plan.md` Blob`6f4157eeee47bc8d2fc4bbda5767025de0691347`，任务`task_order.md` Blob`67f01f8841a7882a907d1782136ff520caed977c`。优先参考AC-05～09、Owner PD-1019-04/05/06/07/09。不得倒改冻结版本承诺。
- 候选已完成的成果均保留：51 scoped backend tests/1182 assertions/exit0，Flutter scoped30/exit0；两组MariaDB RR具名reader/writer（活动资格撤权220/219，旧session撤权226/225）锁等待、非授权返回404/401；同库Web/APP/API多角色活动、模拟预算、人工处罚与精确sanction申诉；87表重启值哈希一致；候选实际APP APK`com.elitesync.v1014dev`，`10.1.4-dev/1010401`，本地安装回取SHA256`250497191485fff57eea7eb5f287f69562d07011e726043f272b7f680bd252b7`，apps来源相同且最后服务端修复未重编APK。这些运行仅为`CODEX_REPORTED/LOCAL_ONLY`；不能因本次审阅把其他原有效测试归零。
- 扩展旧共享回归44 tests/387 assertions/5 failures/exit1与已接受基线同源同断言；2+2 deprecation、早期原始失败、误脚本、APP初始路径/截图失败保留。v10.1.0整版PARTIAL/NOT_ACCEPTED、v10.1.1开发库误清/恢复、旧RTC/通知完整GUI限制、实名供应商PENDING和旧项目源原ZIP镜像PENDING保持不变。

## 2. B1（P1）：合法退出后无法提交活动安全报告

**直接源码：**
`services/backend-laravel/app/Services/SafetyCaseService.php`：
- `submit()`在`PlatformEventService::run`内强制`$events->readable($event,$actor)`；
- 再强制举报人的registration.state ∈ `APPLIED/WAITLISTED/CONFIRMED`，被举报人也必须当前处于相同活动状态，且两人当前`pairAllowed`。
`PlatformEventService::action(cancel)`会将举报人活动registration变为`CANCELLED_BY_USER`且旧grant置REVOKED。`PlatformEventService::readable()`同样要求当前受众合法和ACTIVE registration/grant，因此一旦先取消，`POST /api/v1/platform-events/{id}/reports`即被404拒绝。活动终止、Block或其它撤权也存在同源拒绝。
- 现有`V1014PlatformSafetyTest`覆盖了**已报告后再取消时旧报告/证据404**，但未证明**当事人先安全退出后能用最小报告入口对真实参与期间的事件提出可受理陈述**。

**冲突边界**：Owner PD-1019-06/07明确正常取消/感觉不安全/拉黑≠违规，举报与人工核查应分离；冻结版本是平台活动+内部Safety真实闭环，用户先逃离潜在不安全情况不应因此丧失针对其原参与事件的举报权。当前“关闭旧活动卡权限”可正确，但不意味着可把最小报告接收入口也永久关闭。

**R1的最小修复要求**：
- 在隔离合成开发环境，为活动当事人**曾经真实登记**的有限历史范围建立**report-only**、严格授权的安全投诉入口（建议受控开发默认活动完成/本人退出后7天内，以服务器时间；具体实际版本化，不能将其冒称Owner永久真实运营保留期限）。验证当事人身份与事件、当前会话和不可伪造参与者原身份，允许原受众失效时仅提交**最小陈述及必要身份指针**，不恢复活动title/venue、其它参与者档案、原media、正式关系或CN/MC；绝对禁止裸UUID/随机他人ID枚举和越权找对象。
- 报告必须有报告人、原始event/registration、时间与安全最小来源、指控类别；收到仅建立`REPORT_SUBMITTED / CASE_OPEN / ADVISORY_ONLY`，**绝不**自动认定事实、处罚、向被举报方发原文、重新开放Block后私人接触。
- 如果不能安全构造有限报告用途与当前身份验证，必须以具名`PARTIAL`向Owner报告，而不是把新的报告入口伪装成永久普遍查看权限。

应有的正反链：A/B在同一虚构活动曾获合法参与→A先自愿退出/拉黑或平台活动完成→A在其限定历史窗口提出报告→后端受控持久Case/APP最小状态；陌生人、另一活动、错subject、伪造历史、过期窗口、旧JWT均404/401且无副作用。

## 3. B2（P1）：撤权会使已提交Safety案卷无法继续人工调查

**直接源码：**
`SafetyCaseService::adminDetail()`调用`evidence($event,$case)`；`evidence()`拒绝以下任一情况：
- `$events->readable($event,$case->reporter_id)`不再成立；
- `SocialPolicy::pairAllowed(reporter,subject)`因Block不成立；
- 原participants某个registration从`APPLIED/WAITLISTED/CONFIRMED`转为CANCELLED/EXPIRED，或原revision/sourceHash随撤回改变。

`SafetyCaseService::decide(substantiate/restrict/banned)`也必经`evidence()`，无法再验证当前事实或完成后续人工认定。与此同时`ModerationController::block()`调用`SocialPolicy::revokePair()`；它级联`PlatformEventService::revokePair()`，撤销活动grants/registration。因此**被举报人只需拉黑举报人，或举报人退出/活动结束，即可使一个已经合法受理的Safety Case的证据访问404，无法继续调查或完成既有证明条件**。日志`permission-matrix.summary.json`在Block后确实报告`block_old_evidence=404`，但该测试只证明撤销社交读权，**不能证明内部合法Safety闭环仍可继续处理**。Astra未重新在本地执行整个现实反例，未断言实际业务已有遭遇。

**修复不等于重新开放被撤销的私密源**：
- 严格区分“旧活动用户视图应404”和“已收案的授权调查是否有可审计的最小独立历史来源”。收案时将**经当前授权校验的必要最小事实**（例如event/registration身份、参与时段与当时状态、来源指针与完整性hash）保留在受限、可审计、不可跨案重用的内部Case source record；之后Block/取消等应阻断用户互看及live原帖/附件读，但不自动擦掉合法案卷的最小存证或禁止具名管理员处理case。
- 管理员访问必须role/session、case当前revision、明确访问目的与事务内`OperationAudit`；应区分`HISTORICAL_AUTHORIZED_FACT / CURRENT_SOURCE_UNAVAILABLE`，不得把历史快照说成**当前仍有效参与**、足以证明危险行为或可恢复旧权限。既有`safety_case_evidence`的scope、revision/hash可演进成此受限来源；不得凭截图、陈述或两条独立举报就自动处罚。原“本地规则ADVISORY_ONLY+人工决定+具名申诉”边界不变。
- 让合法已收案能继续最小triage/dismiss、人类调查流程并保留申诉；若原始外部事实已经失效且没有充足证据，允许明确`INSUFFICIENT_EVIDENCE / DISMISSED`或挂起人工复核，而不是错误地输出`SUBSTANTIATED`。不自动处罚或恢复任何社交关系。

需在独立真实MariaDB/HTTP中复现和修复：A/B当前合法参与→A提交案卷（可含独立C最小佐证）→B拉黑A或A自行退出→原A/B活动私有GET/封面/邀请仍404→具名Web审核员仍能打开仅已收案的受限案卷与审计、做具名合法程序性决定；陌生人/无权管理员/过期session绝不能读证据。要特别覆盖“Block不能抹掉独立审计/举报受理”，同时不得绕过用户已撤回的私聊/证件内容访问。

**与“两举报者”硬条件相关的保留观察**：本版`decide(substantiate)`要求第二个不同reporter同活动CONDUCT case，即使有人类写了manual_finding也无其它佐证路径；这是一条**本版本仅合成演练的保守约束，不是Owner已确认的永久现实安全规则**。R1不要借本次修复放开单方指控自动定罪；如需调整未来客观证据种类或重大伤害单案处理，应独立列为Owner/真实运营门禁，不用默认两人投诉认定为事实。

## 4. 一次有界R1授权与证据要求

本任务处于`OWNER_MANUAL_DISPATCH_PENDING`；**Owner需手动把本文件交本地Codex，才授权在原v10.1.4受控开发范围内集中执行**。不要直接动main、不要启动v10.1.5。Codex允许：
1. 保护并固定原候选源码、交付、39份原审阅、36条原变化源码；受保护主dirty根、其他工作树、旧版本数据库/volume、受控v10.1.4新库恢复点和APK/私密原证保持。默认继续用具名本版隔离合成环境；禁止触碰阿里云、真实用户、外部AI、真实付款/场地、全局网络或新系统权限。
2. 先以本版合成A/B/C、真实入口、前后数据库增量与HTTP构造B1/B2反例，保留`BASELINE_FAIL`、对照原源码与实际执行exit/时序。若发现源码以其它真实可达权威路径阻止反例，给出精确且可重放的证据，不强求不存在的“红测”。
3. 仅修改B1/B2的授权域、现有Service/Controller及直接必要迁移、UI/Widget/Feature、定向真实MariaDB竞态；保留冻结计划与其余已接受功能，不扩大公开活动目录、公开安全档案、长期保留期限或真实运营。旧Block/媒体/好友/社交同意必须继续fail closed，旧已接受权限回归仅定点。
4. 关键时间竞态——撤销先COMMIT后旧读取恢复——至少1组定向真实MariaDB `REPEATABLE-READ`精确reader/writer连接ID＋锁边＋HTTP和0泄漏/副作用；如新增独立历史来源必须具名限制用途和保留，避免复制原私聊/身份证明。
5. 如apps产品字节变化，则**用最终固定apps Tree重构开发APK并在本版已获授权AVD install/pull读回**；若只改变services且旧apps Tree不动，可复用既有APK身份但要实证新后端组合。测试不得初始化任何未知持久DB或触碰原v10.1.1事故恢复卷；`APP_DB_CONNECTION`先于RefreshDatabase执行防误清检查。
6. 在原唯一`docs/versions/v10.1.4/IMPLEMENTATION_REPORT.md`后**追加**R1章节，保留先前事故/历史失败；新增具名R1 manifest、最小脱敏review证据独立短期分支，原39份review分支不移动、不合main。仅一次非作者有界复核，正常non-force推送R1候选后独立GET Commit/Tree/apps/services和报告Blob。
7. 交付`V10.1.4_R1_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE / MAIN_PRODUCT_NOT_INTEGRATED / V10.1.5_NOT_STARTED`。若证据不支持接受，准确报`PARTIAL/CHANGES_REQUIRED`，不得伪称全套回归绿或自动签`ACCEPTED`。

R1不是新版本，不重跑无关v10.1.3 Buddy/社区、整个v10.1.4预算、全套Flutter/算法/RTC或复制额外项目源ZIP。Astra对返回候选只独立复核上述两项及其必要回归。真实线下Safety政策、个人信息处理/法定保留期、严肃事故处置能力和真实人工审核仍不得因为合成开发通过而自动开放。
