# v10.0.8 版前可行性与推荐冻结组合

2026-10-15。**V10.0.8 FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED**。

建议以一个版本交付 **B01～B05 的独立Blade运营闭环＋B06已有版本发布元数据管理**，同版补齐用户端审核状态读回、举报处理后动态可见性、匹配发布后的APP结果和权限负例。技术栈和持久化底座可以复用；真正缺的是Web页面、若干共享写服务、当前权限一致性及跨端闭环，不需要第二个后台、第二套业务数据库或逐页面微版本。封禁恢复、资格含义和题库变更对历史资格的规则需要Owner定案后才能冻结，本文的候选规则不是实施授权。

## 1. 实际依据与调查口径

| 对象 | 本次核验身份 |
|---|---|
| 实际远端main／本次源码阅读快照 | `6e6cd469f90d2b15680dd40c97c3811becc5cc6b` / Tree `e2ca3830d45276de4d1bad3426273d3e3f3b1f8a`，执行前ls-remote、fetch及本地对象读取一致 |
| 已完成K08技术起点 | `a75b8d4061ae012937ef4823120b396f257d3aec` / Tree `89637891276cdf4280f918ccad7eb4c5030f55be` |
| 唯一草案固定Commit | `407c6b652086610075b2aa53ae3e750225062afc` |
| 草案路径／实际Blob | `docs/versions/v10.0.8/PLAN_PROPOSAL_V0_1.md` / `a1b380521ac8b6fffb1b06a17f759e8755671cc8`，已读取全文并核对 |
| 产品身份不漂移 | main相对a75b8d4的apps/services/question_bank及根题库差异为空，纯文档更新不改技术起点 |
| 原专用树 | `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，本次分支`codex/v10.0.8-feasibility`，无新worktree |

已实际读取草案、CURRENT_STATE、DOC_INDEX_CURRENT、CURRENT_WORKFLOW、PRODUCT_DECISIONS、现行路线图及单份RESTORATION_CAPABILITY_MATRIX，并定点检查下列源码、迁移、Flutter参考页和既有测试。v10.0.7的ACCEPT WITH OBSERVATIONS与K08均保持关闭，不重做验收/集成。台账顶部2026-10-15接续结论优先于底部旧“消息404／MBTI关闭／题库缺失”快照，旧0.7版前报告仅作为来源记录，不作为当前能力判断。

本次仅静态源码和已发布材料核验，**浏览器、APP、API、DB、consumer、测试、构建和环境启用均NOT_RUN**；任何“可复用”不表示0.8已经运行。现有知识图谱仅指向原dirty根，不代表本专用树，故尝试图谱定位后回退当前固定文件读取/rg；未重建任何图谱、未进行备份考古。两项只读辅助分别提供用户欠账和Flutter Admin/测试映射，主代理核对当前源码并纠正旧状态线索。

以下源码引用统一绑定**a75b8d4技术起点**，与本次实际main产品对象一致；`Sxx`表给固定GitHub行号，文中路径不是运行完成声明。本文自身最终提交/Blob以GitHub发布回读及Owner集中回报固定，避免文件自引用自身SHA。

权威文档固定入口：[当前状态](https://github.com/zcx369658780/EliteSync-v10/blob/6e6cd469f90d2b15680dd40c97c3811becc5cc6b/CURRENT_STATE.md)、[Owner决定](https://github.com/zcx369658780/EliteSync-v10/blob/6e6cd469f90d2b15680dd40c97c3811becc5cc6b/PRODUCT_DECISIONS.md)、[现行工作流](https://github.com/zcx369658780/EliteSync-v10/blob/6e6cd469f90d2b15680dd40c97c3811becc5cc6b/docs/workflow/CURRENT_WORKFLOW.md)、[路线图](https://github.com/zcx369658780/EliteSync-v10/blob/6e6cd469f90d2b15680dd40c97c3811becc5cc6b/docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[单份台账](https://github.com/zcx369658780/EliteSync-v10/blob/6e6cd469f90d2b15680dd40c97c3811becc5cc6b/docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)。

## 2. B01～B06 实际能力与缺口矩阵

| 台账 | 现有独立Web | 共享业务／持久化现状 | Flutter参考与既有测试 | 推荐0.8闭环与主要补齐 |
|---|---|---|---|---|
| B01 用户查询、安全管理 | `/admin/login`、`/admin`用户分页搜索、普通用户禁用、logout；仅layout/login/users三份Blade模板。0.6已接受的范围可沿用，不能推成整个后台已完成 | Web使用AdminAccess＋DisableUser；users、Sanctum tokens、sessions同Laravel库。Web禁用要求确认且拒绝自己/管理员目标；API disable调用同服务却没有同等目标约束。现有用户API无分页且投影过宽，不能直接当Web安全数据源 | AdminUsers有批次/状态/资格等过滤参考；V1006AdminWebTest覆盖名单、角色、真实CSRF强制、旧会话/令牌失效；AdminApiTest有API投影与普通用户拒绝 | 扩当前Blade导航、筛选、最小化详情、明确状态、统一Web/API目标约束；所有禁用入口共享事务和审计。同ID用户APP失效，控制用户正常。不要复制cleanup_token或无关私有画像到管理表格 [S01–S04,S14] |
| B02 资格/验证审核 | 没有Blade队列、详情、审核写入口 | `AdminController::verifyQueue/updateVerify`仅列非approved并写users.verify_status；没有审核证据源、决策流水、并发版本或业务资格接线。realname_verified是另一个字段，注册时由用户accepted请求置true，不能当已核身份；readiness/真实consumer当前不看verify_status | AdminVerification明确“列表/状态，未接完整认证”；Flutter Verification远端请求`/verification/status`与`/verification/submit`，Laravel当前无对应路由/Controller。AdminApiTest只验字段更新/队列，不证明APP资格变化 | Owner先确定此字段是运营准入还是身份审核；再做Web队列＋决策原因/审计＋真实用户状态API/展示，连接被选定的资格使用点，拒绝伪造/并发旧决定。不能仅新增绿标或把不存在的verification接口当读回成功 [S05–S07,S14,S16] |
| B03 举报、内容处理 | 无Blade列表/详情/操作 | ModerationReport有举报者、目标用户/消息/动态引用及最后处理人/备注；reportAction直接改用户字段，未用共享DisableUser、未整体事务、无每次动作追加审计；目前没有真正按举报删除目标动态的操作链。Status已有管理员软删，但其admin能力只看role，未复核管理员名单 | Flutter Moderation/ReportDetail提供action/note参考；ModerationApiTest只验banned/restore字段与举报/block/appeal基础；StatusPost测试可复用作者/非作者、删除及可见性 | Web按举报范围展示必要元数据，公开动态有权预览/软删，共享用户禁用一致性；同报告状态、处罚、审计同事务。APP举报→Web处理→同ID动态不可见/账号失效。私信不做全文浏览器、不开放被撤销消息，不因管理员role绕开白名单 [S08–S11,S14] |
| B04 匹配运营 | 无Blade轮次/执行/发布页 | MatchingRoundService、MatchingRunService、round/channel/user state、候选、append-only operation audits完整基础；API有prepare/execution-request/reveal/retry/close及state_version/幂等/确认。execution-request明确返回pending＋background_started=false，配置布尔不证明worker存活；consumer目前只有CLI `app:matching:execute-pending --once` | Flutter MatchingOperations页参考操作能力、版本和确认头；MatchingFoundationServiceTest、OperationalTruthLoop、0.7真实consumer原证可复用，均非本次运行 | Web操作必须驱动真实run消费到终态，再公布/重试/关闭，浏览器和同账号APP读取相同round/run/match。补受控run级dispatch、实际worker可用性、重复/并发/断电恢复证据，不能展示“成功”但只有pending [S12,S13,S15] |
| B05 问卷运营 | 无Blade页面，Flutter六份Admin页中也无问卷页 | quality-stats按启用题聚合质量标签；prune默认dry_run=true，非干跑只把enabled low_drop题置false，可按reason筛。不会删除answers或attempt，也不升级bank/question版本；没有变更审计/预览绑定/并发保护。启用题、历史答卷、画像和匹配资格口径存在差异 | AdminApiTest有统计、干跑/实际停用；V1007QuestionnairePersistenceTest覆盖保存/草稿/版本拒绝。现有prune测试未证明历史attempt、APP草稿与consumer冻结输入的联动 | 统计→具名预览影响→带确认且版本受保护的停用/必要撤销操作→审计；同一APP已答/未答/草稿/历史结果与后续匹配状态符合Owner选定规则，不删原答案或重seed。低drop可在0.8虚构夹具验证，不能为按钮效果破坏0.7验收题库 [S17–S20,S14] |
| B06 必要版本、通知、配置 | 无Blade写页和对应admin发布API | 不是完全缺业务：AppReleaseVersion与app_release_versions表已有；AppReleaseUpsertCommand在事务内停用同platform/channel活跃行，再upsert版本元数据；公开version/check实际优先读表，异常fallback config。NotificationService已有站内事件/未读/已读及R1最小化；没有证据支持现成的批量公告/系统Push管理。匹配/题库/许可配置主要为部署配置，不是可随意编辑的DB键值 | AppVersionApiTest和About/Settings版本检查测试；通知R1权限/计数测试可复用。CLI命令不等于可审计Web操作 | 推荐纳入Android开发channel的版本元数据创建/激活/停用和已存在站内事件的必要只读排障；共享版本写服务，Web审核输入和审计，真实APP检查版本结果。配置仅显示必要非敏感状态、在B04/B05管理具名业务参数，不做任意.env/密钥编辑、手工私信通知/群发或新Push平台 [S21–S23] |

## 3. 必须在实现中收口的具体安全与一致性问题

### 3.1 举报处罚绕过共享禁用，且可误解禁

`AdminController::reportAction`的restrict（约305–312行）与restore（322–328行）均直接`disabled=false`；banned（314–320行）只写disabled和moderation_status。它们未调用`Accounts/DisableUser`，也未写account_status/visibility/eligibility字段、轮换remember_token、删除tokens和sessions。于是字段间可冲突；restrict可解除别的入口已有禁用，restore后旧token/session若未撤销可再次成为凭据。此为**静态可达的安全缺口，未在本任务实际攻击重现**，不是已接受R1通知投影退回。

共享DisableUser已用users行锁事务同时更新状态并撤销凭据，但尚无业务审计。推荐把处罚、受控恢复和审计放同一Laravel应用服务，Web及旧API同时接入，继承已接受的禁用语义。不能只修新Blade却留下旧reportAction旁路。账号恢复不得还原旧token/session，不能自动改写REVOKED的Connection/MC、清block或重新授予消息权；仍ACTIVE的旧同意在恢复后是否要求重新同意，列Owner政策决定。所有恢复须知道当前禁用原因/版本，不能用一个false清掉其它处罚。

### 3.2 管理权限、Web session与CSRF

已有Web结构合理：Web session认证、登录regenerate、退出invalidate/regenToken、每请求AdminAccess检查非disabled＋admin role＋管理员名单；空名单拒绝。模板含@csrf，未见web CSRF豁免；`V1006AdminWebTest`还显式覆盖强制CSRF而非依赖测试默认关闭（69–77行）。这只是复用基础，不声称0.8新页面已实测。

缺口：`EnsureMatchingOperationPermission`单独检查role/名单/feature开关，未复用AdminAccess的disabled检查；StatusPostController的include_hidden与destroy管理分支只认role。API disable与Web目标约束不同。需要在所有被复用的管理入口和使用点统一授权，不能依赖菜单隐藏、APP Bearer或“token通常已删”来弥补。普通作者删除自己动态仍是用户能力，不能因统一管理员门被误封。

推荐新Web路由显式绑定web guard，独立0.8 session cookie、APP_SESSION_DRIVER=database及正确APP_SESSION_CONNECTION；只在新库验证，不能读取/重用旧cookie。管理名单/角色改变、管理员禁用、登出后的旧session、缺失/错误CSRF、伪造目标ID和重复提交都要真实浏览器/直接请求负例。HTTP loopback只用于获批开发；生产或未配置仍fail closed，不以本版扩大消息/RTC的生产权限。

### 3.3 审核字段不等于资格，更不等于身份已认证

目前updateVerify允许pending/approved/rejected，存一个字段即返回ok；真实`ProfileReadinessService`只按disabled、synthetic、题量/答卷判定匹配，consumer调用该query。用户profile/basic和auth payload主要给realname_verified而非verify_status；Flutter独立Verification接口没有Laravel落点。注册accepted置realname_verified不构成外部认证证明。也不能把Personal Showcase的内部审核/发布audit当身份审核：其命令明确无route/UI/provider/评分影响。

推荐Owner选择“运营参与资格审核”还是“具有具名材料的身份审核”。前者可以在同版补可观察的资格原因与APP状态；后者缺真实材料来源/合法处理边界，不能从手机号和自我勾选捏造身份认证，更不能为此擅自收集证件或购买认证服务。即使选运营准入，也需明确pending/rejected影响哪些操作、已有匹配/同意是否保留。相应APP读模型、consumer候选query和最终提交时复核须一致，不能只在展示层检查。

### 3.4 匹配按钮必须实际消费，并保留并发保证

当前consumer本身可执行：--once→claimNext→冻结候选与fingerprint→heartbeat→buildPairs→finalize；失败fail/expireLease，非只存在空方法。request/retry只建pending，现有命令claimNext按全局pending最小ID领取。API执行/重试的state_version部分检查位于Controller读后、服务加锁前，需用并发测试核对并把预期版本检验置于共享事务内，不能把页面版本检查当强一致。

推荐同版复用现有MariaDB jobs/failed_jobs和Laravel database queue（已有迁移/驱动），为指定run在提交后派发受控任务，复用consumer执行内核，领取限定run并维持lease/fence/幂等；不从表单拼接shell、不新增第二个调度业务后端。正式环境授权需包含本版专用worker的启动/停止与故障恢复。worker未启用时界面真实显示待处理/不可执行，不能只按manual_consumer_configured=true显示正在执行。重试需新attempt lineage；重放不能重复pair/通知。关闭/发布不得代替双方CN/MC。

现有legacy `/admin/dev/run-matching` 和 `/dev/release-drop` 是另一套直接操作DatingMatch的入口，不作为新运营主流程，也不能继续给旧入口留下绕过state_version/audit的通道；在正式范围中按具名开发用途限制/统一服务，非全局删保护。compensation当前403，0.8不擅自启用补偿/回填旧轮次。

### 3.5 prune不删数据，却会改变用户可操作性和未来算法输入

停用题不会删除answers/attempts；attempt存提交快照和三个版本，历史history读取快照。但是：

- 新题/换题筛enabled；草稿恢复/保存也要求题仍启用，停用会导致旧草稿失效或提交422。当前提交的题版本/启用校验在写事务之前，需覆盖prune与提交并发，不能认为已有事务已保护两者顺序。
- readiness按**所有历史distinct答案**计阈值；PersonalityProfileService只计算**当前enabled题**，其complete可能变false。同一用户可能被readiness称eligible却在重新计算画像称不完整。这不是数据库丢答案，也不是可以忽略的“纯运营”变化。
- prune不变更bank_version/question version，前端缓存版本不能准确反映题集合变动。MatchingRunService fingerprint包含题enabled/version/updated_at及配置，冻结后变更会触发input_changed；需要保留失败、给出可理解重试，并以新attempt重跑，不能悄悄修旧run。

推荐具名预览列题ID/数量、相关历史答案/attempt/草稿用户数、可用题下限、活跃run影响和版本，apply与预览绑定、事务内再核、具名reason/确认/审计；保留历史attempt且不覆盖已发布Match。题目启停规则、历史资格计数及必要重新作答须Owner选定（第8节）。本版不扩成题库编辑器、物理删除器或任意调权平台；如需恢复被本版停用题，须可定位本版变更并按同一版本规则操作。

### 3.6 内容与通知的最小访问，审计不是敏感全文副本

现举报list/detail返回reporter/target电话、detail/appeal_note等，列表还未分页；不能直接逐字段搬到Web。举报创建只验证目标message/post的存在，没有充分证明消息属于举报人与被举报人或目标动态归属；需补当前可见性/参与者/目标绑定，避免伪造关联。用户申诉当前按reporter_id归属，不能擅自把它扩为被处罚人申诉政策。

默认Web列表仅举报号、类别、状态、目标最小身份/引用；受限详情按个案授权展示用户自行提交的必要说明，模板转义、防XSS，访问留痕且不在请求日志中复制内容。只对具名公开动态提供所需预览/软删，个人举报说明和私密资料不出现在全局表格。当前reportDetail本身没有私信全文加载；0.8不得以“补详情”为由添加全会话或解密消息浏览。没有明确内容审查法律/同意政策时，消息举报按元数据和用户主动提交说明处理，不突破MC撤销/禁用/未知权限fail closed。

R1 `NotificationService::presentationForUser`及新通知最小存储必须完整保留；不能通过管理通知、旧payload、后台日志、审计before/after或导出重建撤销后的正文/敏感对方身份。可复用matching append-only审计模式；普通request trace只有actor/path/status等，不能冒称已存在所有管理业务审计。新增审计是本版各业务动作的同库记录，不是另建通知/治理架构。

### 3.7 B06版本元数据是现有业务，配置管理须具名

AppReleaseUpsert已有事务和唯一版本约束，但未提供Web鉴权/审计；当前命令下载URL仅检查非空，SHA格式/URL方案及并发唯一active语义还需补验证/锁。推荐抽共享release写服务，使Web与原CLI同规则，不在Web调用任意命令。只管理测试channel和本地受控包链接，不上传公开商店、不强制升级真实用户、不把包版本与后端v10迭代号强行相等。APP version/check有DB异常时config fallback，验收要核实际release行被读取，而非仅看某条返回值。

必要通知以已接受事件、未读/已读、安全导航和本版操作可解释反馈为主；没有证据支持必须新建批量广播/系统Push、任意手工私信或任意配置编辑。本版业务配置仅处理冻结列明的轮次、题库和发布参数；密钥、许可门、.env、生产开关只显示必要“已配置/未配置”，不返回值、不允许Web编辑。需要公告新业务时应明确新增范围，不把空按钮列为B06完成。

## 4. 推荐冻结组合与候选AC（未冻结）

建议整体纳入B01～B05与上述B06发布管理，并包含共享安全修正、必要APP资格读回接口/展示、举报后动态效果及匹配结果通知。它们共用用户身份、同一数据库、处罚/资格/题库/轮次服务，拆成逐页版本会留下不一致入口。允许Blade、Laravel、Flutter必要接口、迁移、任务和测试同版修改。

下列仅供Astra冻结，名称`AC候选08-x`不表示已冻结或已完成：

| 候选AC | 可观察完成标准 |
|---|---|
| 08-1 独立Web认证与审计 | 真实浏览器登录session轮换、有效CSRF；普通用户、role-only、名单-only、空名单、disabled、退出/降权后的旧session均不能查询/写管理数据；直接伪造请求同样拒绝。每项被选定管理写操作有可信actor、目标、理由、版本和必要前后摘要，成功与业务同事务、失败不留半成品，审计不存正文/凭据 |
| 08-2 B01跨端安全管理 | Web查询/筛选/详情最小投影；禁用普通测试账号共享DisableUser，API及报告处罚入口无旁路；DB token/session撤销，目标APP旧凭据/refresh/重登失败、对照账号正常；恢复按Owner规则，新登录也不能让已REVOKED CN/MC或旧凭据复活 |
| 08-3 B02真实资格审核 | Web队列→版本受保护的approve/reject/pending决定及原因/审计→MariaDB→同一测试账号APP刷新/重登看到真实审核状态及所选业务资格变化；consumer候选与APP原因一致，不能只assert字段或绿标。未接真实身份材料时界面不得称“已实名认证” |
| 08-4 B03举报/内容处理 | 同一用户APP提交具名动态/用户举报，浏览器定位/分诊/处置，DB报告与处罚/动态软删/audit一致；APP动态列表/详情与账号状态体现结果，非参与者伪造目标、非管理员role/旧session拒绝。既有私信/媒体合法访问与撤销404、R1通知最小化正反例保持，不提供无限聊天查看 |
| 08-5 B04真实轮次运营 | 浏览器prepare→请求执行→受控consumer实际领取并完成→reveal→同用户APP读取同round/run/Match与站内通知；另做零候选、具名失败、重试新attempt、close。幂等重放、旧state_version、并发操作/worker重启/lease过期均有可核结果；关worker不能冒称执行成功，Match不授予CN/MC |
| 08-6 B05题库变更兼容 | Web统计及具名dry-run→带确认apply→DB题enabled/变更版本/audit；已有答案/attempt不改写，新答题不出停用题，草稿给可恢复的失效说明；旧/新用户资格与Owner计数政策一致。与提交/匹配冻结并发时要么完整提交，要么明确拒绝/新attempt重试，不能半写或篡改旧run |
| 08-7 B06版本与必要状态 | Web在开发channel创建/激活/停用release元数据，DB单一有效发布与审计可核；真实APP About/Settings版本检查展示相同版本说明、最低支持/可更新状态；非法URL/SHA/并发重复拒绝或按合同幂等；旧合法站内事件/计数/已读仍正常。没有外部Push/任意配置编辑/生产发布 |
| 08-8 持久与交付 | 在独立0.8 MariaDB持久卷、同一组虚构账号及受控浏览器/AVD中做管理员与用户联合操作，重启Web/Laravel、DB、worker及APP后审核/处罚/举报/题库/round/release等状态可读回；保存安全原始流/退出码/少量截图、版本与包身份、失败修复及NOT_RUN。若改Flutter/Android产品源，最终源重建并安装AAR/APK，否则按固定子Tree证明可复用旧包，不能冒称新安装 |

工程量判断：B01扩展较小；B02政策/消费者接线、B03事务与权限、B04真正dispatch和故障恢复、B05历史兼容是主要成本；B06已有持久源，适合与本包一起收口。**一版可成组实施但属较大跨端功能版；未实测工时，工期/费用UNKNOWN，不给页面数或日数承诺。**目前无源码证据要求强制分裂版本；若Astra决定调整组合，应显式列仍保留功能、服务依赖和后续位置，由Owner取舍，不能由实现者私自删除B02/B03难点。

## 5. 用户主要功能欠账：当前来源、耦合及内测前安排

0.7已经接受：完整资料/问卷、真实matching、双方独立CN/MC、文本/本地私有图片、八字/可选MBTI、动态/站内通知和本地设置。本次不会重新安排这些已完成链；下面仅为未恢复部分。后续包是依赖排序建议，**不是自动启动的0.9/0.10任务，也不把功能默认推迟到内测以后**。

| 仍欠功能 | 当前实际源码／来源判断 | 与0.8共享及具名后续安排 |
|---|---|---|
| RTC双端音视频 | RtcSessionService::canCall仍依赖block＋已发布DatingMatch，未接LiveConsent；LiveKitTokenService要求URL/key/secret；Flutter有LiveKit服务，但restoration main_prod关闭useLiveKitRtc。会话/JWT存在不证明音视频连通 [S24] | 不把它作为0.8管理按钮顺带“恢复”。接在同一账户/处罚/CN/MC服务上安排“RTC同意与双端音视频”包：明确受控SFU部署、第二端、设备/摄像头麦克风、拒接/挂断/撤销和重连。SFU、本地网络与设备权限在该包正式授权；本次不启动或购买 |
| 完整紫微 | ZiweiCanonicalService有seed approximate_not_validated/display-only，iztro候选默认off，候选输出也不等于验证完整；当前八字成功不覆盖紫微 [S25] | “完整紫微来源与准确性恢复”包，核实际算法依赖、跨时区/边界与非样例排盘输出，APP限制说明；未验证部分不进权威评分。与0.8仅共享资料和后台非敏感状态，不因后台界面存在就认为计算完成 |
| 完整西占 | LegacyInputWesternNatalEngine对部分点位仍用CRC seed，实际provider回退该引擎，代码明确non-legacy适配尚未实现，不能以放开许可门代替引擎实现；Swiss/pyswisseph/Kerykeion默认blocked。已知旧Python算法来源见0.7来源记录，不把存在当已许可可运行 [S26] | “西占许可＋真实排盘/合盘恢复”包；先决定具名引擎/许可路线，再验证计算服务及可信输出。若需商业许可/第三方API单项决策，本任务不解冻 |
| Buddy/Social真实业务 | 当前Buddy候选为_mockCandidates；SocialBaselinePage是仅编辑预览、不公开发布、不更改真实资料的本地页面。所查具名来源未证明另一套原版真业务；不是可以标完成的后台列表 [S27] | “搭子/社交真实来源与发布互动”包：优先Owner指出已有真实原版来源；若确为未实现设想，再明确新增产品规则。与0.8共享举报/动态/处罚服务；不为赶后台擅自设计撮合、支付或社交运营政策 |
| 原版其它媒体 | MediaAssetService可识别audio/video/file，但当前live私有上传只允许图片≤5MB，文本/图片之外的附件端到端未验 [S28] | “原版音频/视频等附件恢复”包先核所选原版实际类型与处理工具，再接同一media ready/附件授权/撤销下载；不因枚举值宣称所有类型支持，也不擅装系统转码器 |
| 地图、系统Push与必要设置 | 当前Android仍有AppRepository/BaiduMapApiService来源及地图凭据依赖；当前设置本地存储不等于地图或系统通知投递，未证FCM/APNs设备注册/发送全链 [S29] | “地图/系统投递及设置”包明确供应商、平台/设备、许可费用与凭据用途，复用0.8审核/处罚后的必要事件，不新增第二套通知事实源；若本地设置须跨设备同步，具名补服务合同，不能把本地开关当Push成功 |
| 历史业务数据与附件 | 台账A03仍UNKNOWN；本次未读SQL gzip、VHDX、原3306或媒体原件；迁移结构与题库恢复不等于真实历史数据恢复 | “获准副本的数据/附件关联恢复”包，需要Owner指明来源副本、用途及隔离目标后才能读取；保留原件、核记录关联与媒体引用。可与其它恢复包并行准备具名授权，**不是等内测后再找数据**；无来源仅阻塞该包，不扩成全项目暂停 |

推荐顺序：0.8先收管理与现有用户链共享服务；随后在联合验收之前按RTC/媒体、完整算法、Buddy/Social和地图/Push的具体依赖并行或成组恢复；数据/附件来源授权应提前获得并在完整交付前收口。原路线0.9联合验收、0.10软件材料是目标分包，不足以自动吞掉未恢复功能；如果这些欠账无法在其前完成，应由Owner/Astra把具名恢复包排在联合验收和内测之前，可调整功能迭代数量而非把“联合验收”当功能开发替代。未证明原版实现的Buddy/Social或系统Push，要先分清真实欠账与新设想，仍保持具名跟踪，不随意取消。

## 6. 建议正式计划一次性明确的环境与验证权限

以下只是建议，**本次没有创建、启动或写入这些资源**：

- 复用同一专用树、锁定PHP/Composer/Flutter/Android依赖、MariaDB10.11镜像和既有构建链；另建`elitesync-v1008-db`、库`elitesync_v1008_dev`、volume`elitesync-v1008-db-data`，建议loopback43318（正式实施前核空闲），绝不挂载/seed0.6的43316卷、0.7的43317验收卷、原3306或备份。
- 采用新具名虚构管理员、普通已通过/待审/拒绝用户、举报人/被举报人、role-only/名单-only/disabled对照。全部新密码和token私存；Web管理员与APP用户可共享同一users事实身份，但Web只用独立session，APP只用各自token。数据从获准题库和新虚构夹具建在0.8库，不导出0.7私密库作为seed。
- 新媒体区、runtime/cache/log/证据目录和session cookie，不复用原owned-processes/PID。可复用8000前端/8001 Laravel及AVD `elitesync_v1007_api36`、ADB serial5582，但启动前核归属/端口，授权后APP只指向新0.8服务，新构建确认元数据，不wipe无关AVD；也可由正式计划指定另一具名AVD，非强制新建。
- **需同版改窄环境门，而非临时复用0.7库绕过**：LiveConsentService::enabled当前硬编码库名`elitesync_v1007_dev`并检查loopback/端口，0.8新库会fail closed。冻结计划须具名允许增加0.8隔离库/端口配置白名单及测试，保留local/testing、排除3306/0.6、未知/生产拒绝；同步核0.7 start/build脚本具名约束，不直接修改原验收脚本去覆盖旧环境。这是本版联合功能链必要接续，不另立环境治理版 [S07,S30]。
- 浏览器建议复用已可用的受控Chromium/Edge或内置浏览器，独立管理员上下文和普通用户/退出后的对照上下文；真实填表、确认、刷新和重登，取安全截图、网络状态码及同一行DB读回；测试也需缺失CSRF/旧session直接请求，不能仅看浏览器隐藏按钮。不因调查安装浏览器扩展/系统组件。
- worker建议为0.8新库专用Laravel database queue，限定匹配队列和run；正式授权覆盖启动、停止、断开恢复、失败重试及媒体处理所需既有工具，不启动SFU/地图/外部算法。不得执行表单提供的任意命令。所有持久读回/重启验证同时识别round/run/user/version/audit，不用curl或Widget数量替代浏览器＋APP闭环。

## 7. 回归选择、原证和未运行事项

0.8实施后应按实际改动选择V1006AdminWebTest、AdminApiTest、ModerationApiTest、StatusPost相关测试、MatchingFoundationServiceTest/OperationalTruthLoop、V1007QuestionnairePersistenceTest、AppVersionApiTest，以及R1通知/LiveConsent/PrivateMedia等权限回归，并新增真实Web业务和会话/并发/审计负例。跨端实际成果应有浏览器→同库→APP正反例及必要重启，测试只能辅助。

旧Flutter三项失败是ConversationAccessGate文案、Match headline及synthetic UNKNOWN导航合同；两诊断测试另需同次PHP fixture。B04/资格APP展示可能触及Match/路由读模型，届时对实际修改的合同定点处理；不因纯Blade增加就重验所有历史，也不预先删除/skip旧测试或下调断言。若修改它们所覆盖的产品合同，不能继续笼统贴legacy标签逃避回归。基线仍记录普通793/5、带fixture821/3均exit1、全域Dart无问题exit0，**本次没有复跑或声称全绿**。

本次没有PHP/Flutter测试、静态分析、构建、安装、浏览器、API、consumer、数据库或重启实测，没有查看/导入历史备份或额外第三方服务。旧通知开发库明文、vendor弃用、Android strip警告保留其原报告事实；不得把调查或Web管理作为历史通知清洗/数据迁移的自动授权。时间/成本/完整APP恢复比例UNKNOWN。

## 8. 仅需Owner决定的实质问题（冻结前集中解决）

| 决定 | 冲突与推荐方案（均未执行） |
|---|---|
| D1 审核到底审核什么、影响什么 | 当前verify_status只是管理字段，realname_verified又是自我accepted，缺真实身份材料。**推荐将本版定位运营参与资格审核**，给APP明确状态/理由，按选定规则控制未来matching准入，不冒充法定实名认证；需Owner确认pending/rejected是否阻止新匹配、现有用户/已发布结果是否保留，以及是否确实另有应恢复的具名认证材料流程。没有材料授权时不采集证件/购买认证 |
| D2 restrict、banned、restore的范围 | 当前restrict/restore会清disabled，而共享禁用还设隐藏/资格/凭据字段。**推荐banned统一已有禁用事务；restrict不得解除已有禁用；restore只解除自身可追溯的处罚，旧凭据永久失效，不复活已撤销CN/MC或block**。需要Owner明确限制哪些发布/匹配/聊天能力、谁可恢复以及恢复后仍ACTIVE的旧同意是否需重签；不能由Codex自行赋予新处罚政策 |
| D3 prune对历史资格和未完问卷的语义 | 当前全历史答案计资格、启用题算画像存在冲突。**推荐保留历史attempt/答案与已完成证据，变更只影响新题集合且显式处理未完草稿；不自动撤销已建立CN/MC或改写旧Match**。需要Owner明确未来新轮次资格保留历史完成还是仅认启用题并要求补答，再由Astra冻结统一计数/版本规则。没有该决定不能把一次prune当无业务影响按钮 |

B06推荐已有开发channel发布元数据、现有站内事件排障与具名配置状态，不增加广播平台；若Owner确需原版公告群发，请明确具名功能边界后再冻结，不为无证据需求阻塞其它后台。RTC SFU/第二端、西占许可、地图/Push供应商、Buddy真实来源、历史备份副本是**后续具名恢复包的决定清单**，本次不一并申请费用/生产/系统权限，也不需要为调查逐项回答。

## 9. 固定源码索引（用于独立复核）

下列均为技术起点a75b8d4固定对象；文中每个S编号包含关联方法/行号。现行状态/Owner决定以本次main6e6cd46文档为准。行号是定位，不是运行证明。

| 编号 | 固定源码／关键定位 |
|---|---|
| S01 | [web.php](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/routes/web.php#L5)、[Web AdminController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Web/AdminController.php#L20)：session、查询、目标约束；resources/views/admin/{layout,login,users}.blade.php为仅有三模板 |
| S02 | [AdminAccess](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/Accounts/AdminAccess.php#L9)、app/Http/Middleware/{EnsureAdminPhone,EnsureAccountActive}.php；config/{auth,session}.php，session driver第21行、cookie约134行、same_site204行 |
| S03 | [DisableUser](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/Accounts/DisableUser.php#L14)：事务行锁、字段、remember_token、tokens/sessions删除 |
| S04 | [API AdminController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AdminController.php#L67)：users67、verify129/147、disable164、reports170/224、reportAction277、prune539；[管理路由](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/routes/api.php#L237) |
| S05 | [ProfileReadinessService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/ProfileReadinessService.php#L14)：eligibleUsersQuery14、forUser28；ProfileController basic投影约528/608 |
| S06 | [AuthController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php#L85)：register accepted及realname_verified；app/Models/User.php字段与isAdminRole；migrations/2026_03_12_021000_add_verify_fields_to_users_table.php |
| S07 | [LiveConsentService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/LiveConsentService.php#L16)：16–29具名库/端口门、32起disabled/block、110起gates，独立CN/MC |
| S08 | [reportAction](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AdminController.php#L277)：305–328直改disabled，340附近保存report，未用共享DisableUser |
| S09 | [ModerationController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/ModerationController.php#L21)：report存在验证/创建、appeal按reporter、block/unblock；Models/ModerationReport.php与2026_04_06_120200_create_moderation_reports_table.php、2026_04_19_000120_add_target_status_post_id_to_moderation_reports_table.php |
| S10 | [StatusPostController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php#L112)：143 includeHidden、index约223、report约464、destroy521–555；role-only管理授权与软删除 |
| S11 | [EnsureMatchingOperationPermission](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Middleware/EnsureMatchingOperationPermission.php#L11)；RequestTraceMiddleware.php:15与EventLogger.php:8不是业务处罚audit |
| S12 | [AdminMatchingController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AdminMatchingController.php#L47)：executionRequest59–75、reveal78、retry98、close114、compensation132 |
| S13 | [MatchingRunService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/MatchingRunService.php#L27)：request/retry/claim76、freeze97、finalize115、fingerprint204；MatchingRoundService.php:21/49；Models/MatchingOperationAudit.php:14 append-only |
| S14 | [V1006AdminWebTest](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/tests/Feature/V1006AdminWebTest.php#L29)：47/56/69/80/112；AdminApiTest.php:24/364/388/406/438；ModerationApiTest.php:119；MatchingFoundationServiceTest.php:62/83/106/129/138/152/168；AdminMatchingOperationalTruthLoopIntegratedSmokeTest.php:17。均本次NOT_RUN |
| S15 | [ExecutePendingMatchingRunCommand](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Console/Commands/ExecutePendingMatchingRunCommand.php#L14)；config/queue.php:16/37/43；database/migrations/0001_01_01_000002_create_jobs_table.php及2026_07_12_000100_create_match_round_foundation_tables.php |
| S16 | [AdminVerificationPage](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/apps/flutter_elitesync_module/lib/features/admin/presentation/pages/admin_verification_page.dart#L46)；features/verification/data/datasource/verification_remote_data_source.dart:25/39与status_dto.dart:14；api.php没有对应两路由。profile_page.dart:139读readiness |
| S17 | [pruneLowDropQuestions](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AdminController.php#L539)：dry-run默认、reason、enabled停用；config/questionnaire.php:4三个版本、质量过滤 |
| S18 | [QuestionnaireController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/QuestionnaireController.php#L66)：questions enabled/草稿169、submit360/校验390/事务402/attempt444、history470；QuestionnaireDraftController.php:19–36 |
| S19 | [PersonalityProfileService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/PersonalityProfileService.php#L15)：enabled选题、complete57；ProfileReadinessService.php:17/31不同答案计数 |
| S20 | [QuestionnaireAttempt](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Models/QuestionnaireAttempt.php#L10)；2026_04_18_000070_create_questionnaire_attempts_table.php:11–29；V1007QuestionnairePersistenceTest.php |
| S21 | [AppReleaseUpsertCommand](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Console/Commands/AppReleaseUpsertCommand.php#L27)：69–104事务；Models/AppReleaseVersion.php；migrations/2026_03_22_070000_create_app_release_versions_table.php |
| S22 | [AppVersionController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/AppVersionController.php#L49)：读表65、fallback77、出参100；config/app_update.php；tests/Feature/AppVersionApiTest.php |
| S23 | [NotificationService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/NotificationService.php#L25)：presentationForUser当前权限、新存储63、计数125/已读133/150；V1007R1NotificationPrivacyTest.php、V1007LiveConsentTest.php、V1007PrivateMediaTest.php |
| S24 | [RtcSessionService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/RtcSessionService.php#L41)；LiveKitTokenService.php:13；features/rtc/domain/services/rtc_livekit_service.dart:30；Flutter main_prod.dart:121的useLiveKitRtc开关 |
| S25 | [ZiweiCanonicalService](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/ZiweiCanonicalService.php#L160)：216/235–239、312–334 iztro候选与限制 |
| S26 | [LegacyInputWesternNatalEngine](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Services/LegacyInputWesternNatalEngine.php#L17)：36–43 CRC；Providers/AppServiceProvider.php:38–56；config/astrology_dependency_gate.php:8；旧Python具体来源Blob见已发布0.7 FEASIBILITY_RECOMMENDATION.md来源表，未重新处理备份 |
| S27 | [Buddy页面](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/apps/flutter_elitesync_module/lib/features/buddy/presentation/pages/buddy_companion_page.dart#L72)：929 mock；features/social/presentation/pages/social_baseline_page.dart:47预览文案 |
| S28 | [MediaController](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php#L35)；MediaAssetService.php:165类型；MessageController.php:103–148附件preflight |
| S29 | [原生AppRepository](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/apps/android/app/src/main/java/com/elitesync/repo/AppRepository.kt#L80)：searchPlaces/reverseGeocode155；network/BaiduMapApiService.kt；Flutter features/profile/presentation/pages/settings_page.dart本地push/performance保存 |
| S30 | [0.7运行说明](https://github.com/zcx369658780/EliteSync-v10/blob/a75b8d4061ae012937ef4823120b396f257d3aec/docs/versions/v10.0.7/RUNBOOK.md#L9)：隔离端口、AVD5582、start-local/build-local的具名环境约束。仅作为复用来源，本次未执行 |

## 10. 发布与保护结论

本次唯一发布文件为本报告；草案、冻结计划、验收、复盘、工作流、台账、CURRENT_STATE及产品源码不改写。原dirty根只做前后保护快照，原HEAD/index/status及43项实际具名hash前后核对均一致；不声称历史105/109项重验。专用树无无关LOCAL_ONLY进入提交。只作普通non-force文档发布及GitHub回读；本机调查收据保存在 `C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1008-feasibility`，不发布密码、.env、token/cookie或真实用户数据。

**终点：V10.0.8 FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED。等待Astra正式冻结plan及Owner手动派发；不启动0.8环境、产品实现、后继版本或生产操作。**
