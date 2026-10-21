# EliteSync v10.1.4｜平台活动软件与内部Safety闭环｜冻结功能计划

签发：2026-10-21｜Astra。**V10.1.4_FROZEN_FUNCTIONAL_PLAN / OWNER_APPROVED_ENTER_VERSION / CODEX_MANUAL_DISPATCH_PENDING / IMPLEMENTATION_NOT_STARTED / V10.1.5_NOT_STARTED**。

## 1. Authority和版本目标

Owner于2026-10-21明确批准**进入v10.1.4**；即授权本版有界版前冻结和任务准备，**不等于Codex已获直接启动权限**。Owner之后将唯一综合任务手动交付Codex，才授权按本版冻结边界自主实施。Owner保留真实招募/场地/预算支付、企业/备案、生产环境、真实用户、第三方模型/供应商、系统级变更及不可逆资产的最终权限；Astra冻结并独立验收，Codex一版一次综合开发与集中交付。

本版本同时完成两个彼此独立又可联动的真实链：

**平台活动**：具名Web管理员用虚构地区/咖啡厅场所和预算草案建立活动→定向受控邀请→合成用户在Android APP查看本人获准活动、主动报名→容量占满时候补→管理员确认名额/关闭→参与者取消/退出→活动完成或取消→状态、预算与操作审计在真实Laravel/MariaDB/Web/APP间持久一致。

**内部Safety**：合成用户对确实与其有关的活动/用户/既有内容提出具名举报→后台按权限查看最小必要证据并记录访问→辅助规则提出非裁决分类→人工明确核查/决定→通知本人必要的受限结果→当事人自主申诉→授权管理员复核/纠错/撤销具名处罚→APP当前资格/可用操作正确同步，历史审计与合法业务退出权益保留。

**开发结果终点**：可安装的v10.1.4 Android开发APK＋实际本地Laravel API/既有独立Web管理端＋本版本独立持久MariaDB＋复核的真实正反例及恢复点，非纯Widget、脚本打印成功或静态样图。本版不对外招募、订场、支付或实际线下到场；没有平台实际支出、用户失约统计或真实Safety事实。

## 2. 已接受的基线与来源

- 2026-10-21独立验收后的GitHub main：`cb0cad401955d537b9899a89b533941058d8de1a`，Root Tree需开工时再次读取。已接受完整apps `d4569b330629d74c6e5f3ee1d6438245d7bfd024`、services `4d637a3fd827e00974887d9ce515a1833a8f3a8a`，源于v10.1.3接受源码`e27db2012e2c57390c4da179330552a6b64a728d`。
- 独立验收 `docs/versions/v10.1.3/{acceptance.md,integration_acceptance.md}`。上一版处于`FUNCTION_ACCEPTED_WITH_OBSERVATIONS / INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`；受限APP通知GUI点击、RTC/AEC及真实身份provider仍为观察。
- 长期Owner决定 `docs/decisions/OWNER_PRODUCT_DECISIONS_20261019_LONG_TERM_RELATIONSHIP_V1_0.md` Blob `636990f86fc63e9aa33fb4ac80d5c267ce6b10e6`，重点PD-1019-03～09、13～16。已有10.x路线 `docs/architecture/ELITESYNC_10X_POST_RESTORATION_ROADMAP_20261019_V1_0.md` Blob `d8d34ccf229254e7e064be00590ba509071cf749` §5/§6.4；路线为历史规划，不能据它宣称v10.1.4已有实现。
- 现行`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`、2026-10-21轻量工作流补充。原2026-09-12目标IA四Tab `Home | Progress | Messages | Me` 不变；平台活动次级进入Home/Progress，Safety申诉在Me/相关活动状态中，没有第五Tab。

## 3. 定点源码观察：优先复用而非重建

Astra于版前读到的接受main：
- `services/backend-laravel/app/Services/Admin/{ReportOperations.php,UserGovernance.php,OperationAudit.php}` 已有report `triage/investigate/dismiss/close/restrict/banned/restore`、带版本与原因的人工处理、用户账号禁用/恢复及明确的管理员审计，**不可**另建不一致的真正处罚写源。
- `services/backend-laravel/app/Services/SanctionAppeals.php` 与 `SanctionAppealController` 有本人`restrict`处罚申诉，旧Web可读且审计；既有`ModerationController`兼有用户举报、对举报的申诉等入口。两种申诉**是不同对象**，本版要明确活动个案及处罚复核所依据的权威归属，不把举报人异议当被处罚人申诉。
- `moderation_reports`、`admin_sanctions`、`sanction_appeals`、`admin_operation_audits`已有数据库合同，Status/Comment举报与Buddy是前版接受事实。新活动Safety应记录独立case/关联report、evidence references和decision lifecycle，不复制未授权消息正文到新表或新管理员UI。
- `services/backend-laravel/routes/web.php`已有`/admin/reports`、`/admin/audits`，账号管理使用auth:web/account.active/admin.phone及具名操作；要复用真实RBAC/CSRF和Account/SocialPolicy当前判断，不凭隐藏UI按钮放权。
- 尚无已接受的**平台出资活动管理员创建→APP报名候补→预算草案真实链**或与活动争议绑定、人工分级/申诉纠错的完整Safety Case。已有独立Buddy MEAL/STUDY不能改名为官方平台活动；活动报名不自动变成Buddy/CN/MC/恋爱关系。

## 4. 冻结开发默认合同（非Owner永久运营政策）

### 4.1 官方平台活动（受控、虚构、非收费）

- 管理员具有审核权限才可建立`PlatformEvent`，具有唯一UUID、virtual region/city、**仅合成/明确标注测试**venue name与`PUBLIC_VENUE_UNVERIFIED`标识、活动说明、时间（UTC与展示时区）、参与上限、已确认数量/候补序号、版本revision及审核轨迹。城市/虚构公共场所描述不能包含真实家庭住址、个人定位、持续轨迹、身份证/联系电话、真实咖啡厅预订码或地图坐标。
- 开发默认每活动**2–8个已确认席位**（可在受控配置变更；不是Owner对将来全国活动永久限制）；每人对同活动最多一条当前报名事实。活动只有`DRAFT → OPEN → CLOSED → COMPLETED`或`CANCELLED`；时间自然过期要有明确`EXPIRED`或可辨的不可报名终态，并保持历史。
- 活动默认不出现在全站陌生人公开目录；具名管理员向指定虚构开发用户发受控邀请或签发高熵单次48h可撤销活动邀请凭据，持有人主动兑换后才能取得卡片必要详情。不允许用递增userId、eventId全站枚举或旧token绕开邀请；活动邀请与此前Buddy邀请各自独立，不能把“有官方活动”变成好友或普通消息能力。
- 状态建议：`INVITED → APPLIED → WAITLISTED → CONFIRMED → CANCELLED_BY_USER / CANCELLED_BY_ORGANIZER / DECLINED / EXPIRED`；事件关闭、取消与完成以服务端权威决定。报名是用户自愿；管理员基于名单容量确认是**活动名额管理**，不是双方恋爱关系确认、真实出席事实或个人免责保证。
- 名额释放后候补采用**明确、受控的候补转正**（默认按服务端入队时间，固定tie-break），不自动替候补用户建立他原本没有确认的真实服务关系。候补取消、重试、审计、名额double booking以有序事务锁、唯一约束、revision及幂等覆盖；跨角色旧版本/并发请求不得超容量。
- 参与者可随时取消/退出，不因反悔、不回复、主动Block、安全感下降而自动形成处罚或Safety Finding；活动`COMPLETED`仅是平台排程完成，不代表任何人已实际到场。允许双方自愿提交“我已到场”的测试态声明，但若不能独立验证，必须标`SELF_REPORTED / UNVERIFIED`，不得把另一方未确认自动转为缺席/违规，也不得GPS强制签到。
- Web预算只为**预算草案与审批模拟台账**：建议字段`currency_code`、每类预计费用的整数最小单位、总额和Revision、`DRAFT/REVIEWED/APPROVED_FOR_DEV_SIMULATION/VOID`，最终不得把`APPROVED_FOR_DEV_SIMULATION`表述成真钱付款、供应商结算或Owner财务批准。严格无支付API/余额/交易回执/发票或真实供应商联系；管理员修改预算具名原因、角色、预期版本与审计，用户侧不泄露内部成本细项。

### 4.2 内部Safety Case，不等于举报本身

- `REPORT_SUBMITTED`只是指控；任何`Finding`须与**证据来源、发生时点、关联对象、人工判断者、版本、明确理由**分开记录。建议case`OPEN / TRIAGED / INVESTIGATING / DISMISSED / SUBSTANTIATED / ACTIONED / CLOSED / REOPENED_FOR_APPEAL / CORRECTED`，状态与可达边由Codex在实现报告精确列明；`SUBSTANTIATED`不自动执行账号处罚，必须通过既有`UserGovernance/ReportOperations`具名人类操作。
- 对活动“对方未到场/危险行为/疑似骗取资源”的举报只验证**是否具备合法活动参与或在授权上下文内报告的资格**、上传/引用证据归属、必要风险分类；一方的陈述/规则标记/未回复/取消/到场声明缺失**不足以确认为违规事实**。不能为罚分、公开信用分、兼容性排序或向未来Match/好友/伴侣展示负面记录。
- 证据最小化：保存来源表/行ID、提交时哈希/类型/具名合法访问范围和解释，不直接把完整私聊、用户证件、精确位置或未经同意媒体复制到Safety；不允许客户端提交`is_verified`/`finding=true`或指定管理员身份。管理员仅能在现行合法权限、记录访问理由和审计的前提下看必要证据；过期/已撤权的内容不是“历史上管理员可见就永久可读”。
- **规则辅助模式先实现**：固定`rule_version`、提示类别/不确定性与`ADVISORY_ONLY`状态，允许管理员不同意并留痕，不接第三方LLM，不发送个人报告给外部API；任何“AI已核实/可信度90%/自动处罚”均不允许。规则提示不得写成`Finding`。
- 人工处理须具名Web管理员、CSRF、RBAC、关联case revision及对象当前权限、明确操作理由、事务内审计；如果确实执行restrict/banned，仅调用已接受的UserGovernance规则与唯一当前用户处罚源，**不能新建一个无关的可越权账号禁令列**。正常dismiss与close不改变用户权限或已合法CN/MC。
- 当事人查看**本人可被告知的当前处理状态与申诉入口**，但不得看到举报人隐私、证据来源密钥、内部审计全文或另一个账号的处罚明细。被处罚者按已有具名sanction恢复/申诉合同申请复核；本版需扩展后端**实际可决定的申诉复核、纠错、通知**，不得停留“提交申诉后只列出待处理”假闭环。
- 复核裁决由实际授权管理员记录结果`UPHELD / OVERTURNED / CORRECTED`及理由、revision、被复核处罚的精确identity。若纠错触发恢复，按既有`UserGovernance::restore`对应具名sanction，在**存在其它合法独立限制时不减弱它们**。不能因为恢复某次Safety处罚就暗恢复曾Block、CN/MC、旧请求、正式关系/搭子或历史私密共享。
- 需提供最小受控案卷期限/复核提醒与安全审计，具体真实数据法定保留期与外部监管义务**不由本版捏造**。本版开发默认可以具名人工设置review_due_at与终态，而非不可审查永久悬置；超期只显示/催办，不自动定罪/销毁证据/解除所有限制。
- 安全通知只传最少的case/decision UUID与“状态已更新”文案，旧token/撤回后按当前权威读；严禁通过Push、锁屏、活动列表、恋爱资料或评论给第三方暴露报告/处理正文。

### 4.3 UI/真实链/权限

- Web后台新增最少平台活动、预算草案、审核、Safety Case/申诉复核工作台；现有操作审计为权威，不恢复APP管理员页或无限扩管理员后台。Android Home/Progress次级活动报名、候补/退出/取消、Me本人Safety状态及真实申诉，保持四Tab不变。
- 所有用户看见的活动和Safety状态是API当前投影，不是人工写入APP mock；真实活动为`DEV_SYNTHETIC_EVENT / NOT_REAL_BOOKING`。拒绝、Block、禁用/注销、role变更与session撤销后，旧URL、列表、卡片、消息/通知、权限缓存必须fail-closed。
- 不重做v10.1.2慢约会算法、v10.1.3 Buddy及社区，除非确实修改共享权限/通知使用点时做必要定点回归；活动、Buddy、朋友与正式关系的domain fact独立。不能因活动报名或Safety报告建立CN/MC/Conversation、恋爱关系或群聊。

## 5. 开发环境与安全门禁

- 仅使用v10.1.4自己归属的**新空独立合成MariaDB**，建议`elitesync_v10_1_4_dev`、独立新volume、loopback端口`43325`，Laravel API`8019`、必要WS`8020`（本版无WS实测必要可不启动），先检查端口/卷归属。任何创建/迁移/seed前验证effective `APP_DB_CONNECTION`优先、DB_URL/socket/host/port/db、testing与备份恢复点，沿用PHPUnit`testing/sqlite/:memory:`且TestCase在RefreshDatabase前fail closed。严禁触碰v10.1.1事故恢复库、v10.1.2/1.3旧库/卷、3306、阿里云生产或任何真实账号。
- 原dirty `D:/EliteSync-v10`、旧 `D:/EliteSync`、全部已占有工作树及版本候选/备份保持。可复用安全干净连续工作树；不盲reset/stash/clean/pull/rebase/prune、force、移除原worktree或私密原证。关键保护根及独立卷/SQL事前事后具名比较；原失败不为追绿删除。
- 仅在原有可用且受限的开发AVD进行APK build/install/pull/APP测试；**不因历史RTC/USB操作扩大新的手机、摄像头、麦克风、UDP/UAC、防火墙或云服务权限**。如测试需要真实设备或新下载/系统升级/采购，先暂停该风险子项向Owner申请。
- 真实场地订位、支付宝/微信或银行付款、平台真实预算拨款、真人报名、全国招募、面向真实用户发布、线下活动、租用场地、外部LLM/个人资料外传、正式Push、资质/备案、生产发布全部`NOT_AUTHORIZED`。成本台账只能表示模拟预算，不允许“已实际付款”的开发假状态漏到真实运营通道。

## 6. 冻结验收 AC-10.1.4-01～12

| AC | 可观察接受条件 |
|---|---|
| **AC-01 基线/隔离** | 基于实时已接受v10.1.3产品main；旧Owner与冻结原证不改；新独立空库/卷/备份；有效APP_DB_CONNECTION安全门在任何迁移/测试前。 |
| **AC-02 Web活动/预算真实持久** | 受限管理员建合成地区/场所、时间、容量2–8与预算草案；无权限/CSRF/未审核/错revision拒绝。预算只有模拟审批、完整变化审计，零真实支付或供应商调用。 |
| **AC-03 APP受控报名/候补** | 虚构A/B/C在Android当前APK真实接收受控活动邀请并主动报名；名额有限、候补、管理员确认、用户重登/重启可查询，非受邀/失效凭据、裸UUID、旧JWT及改actor拒绝，无陌生目录。 |
| **AC-04 取消/名额并发** | 参与者可无惩罚取消、平台取消/关闭/完成；释放席位与候补转正不超额，不因数据库重试重复通知或双确认；MariaDB真实并发容量/旧revision/单人重复/过期/已取消失效。 |
| **AC-05 到场与费用真实性** | 自愿声明只能SELF_REPORTED或UNVERIFIED，不能把排程完成/另一人未答复当真实出席；无定位追踪、真实支付、真实预订或强制到场，管理员预算草案不向用户当支出。 |
| **AC-06 举报来源与证据授权** | 仅具名有权参与者可以提交关联平台活动的报告，安全详情仅本人最小状态／有权管理员最小资料；匿名/跨活动/跨用户/裸ID/伪造证据来源拒绝；报告不写Finding/禁令。 |
| **AC-07 规则辅助和人工Safety** | 具名规则版本／提示/不确定性留痕且ADVISORY_ONLY；人工独立核查/判定/处置必须明确理由、reviewer、revision与审计；无第三方AI/信用分/自动封禁。 |
| **AC-08 申诉、复核与纠错** | 本人真实提交→Web人工有权复核→维持/推翻/纠错→APP有权查询当前结果；推翻仅恢复相关具名sanction且不减弱其它限制或复活CN/MC/好友/Buddy/正式恋爱，历史case/处罚/申诉审计保存。 |
| **AC-09 撤权/RR/私密防泄漏** | Block、活动取消/退出、账号禁用/注销、role/session撤销后旧活动卡/报告/通知/证据读取拒绝；至少两组真实MariaDB REPEATABLE-READ精确reader/writer等待与撤权COMMIT时序，500/死锁不可冒充授权拒绝。 |
| **AC-10 Android与Web真链** | Home/Progress活动报名候补/取消，Me本人报告与申诉、Web运营和Safety审核/复核；实际同一个Laravel/独立MariaDB/获准AVD链，错误/离线/切号旧响应/无资格清晰区分，管理员操作有RBAC/CSRF。 |
| **AC-11 重启/复用回归** | 关键事件容量/报名/预算/case/finding/sanction/appeal/操作审计持久表受控API/DB重启前后全值哈希/计数一致；与已接受Buddy/Status/CN/MC/Block和旧申诉的共享权限有限回归，没有覆盖历史。 |
| **AC-12 固定交付** | 唯一IMPLEMENTATION_REPORT、artifact_manifest、匿名脱敏短期审阅证据、非作者有界审查、最终APK/签名/hash/安装回读、Git固定Commit/Tree/apps/services及代码和运行分层、历史失败/限制/本版资源停止与恢复点。不可自行ACCEPTED/合main/开v10.1.5。 |

## 7. 出口和不变风险

本版本若冻结范围内AC通过，Codex仅交`V10.1.4_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / NO_REAL_EVENT_OR_PAYMENTS / V10.1.5_NOT_STARTED`，由Astra独立验收；必要时一次集中R1范围内返修，再由Owner授权单次安全集成并等待Astra第二道验收。

原v10.1.0整体`PARTIAL/NOT_ACCEPTED`、AC-10.1-08 PARTIAL、v10.1.1误清库事故恢复、v10.1.2/1.3历史失败、真实实人供应商未接、APP通知点击/RTC/AEC未证及GitHub项目源原ZIP`BYTE_MIRROR_PENDING`继续明示，不作为本版自动清零。Owner已手动更新ChatGPT项目源，GitHub原ZIP镜像待补仅属独立文档事项，若不获得原ZIP就不要求Codex重建一份。

v10.1.5仍未授权、未冻结或实施。本计划不批准任何真实钱款、活动招募、真实身份供应商/AI推理采购、公网数据用途或生产数据库操作。
