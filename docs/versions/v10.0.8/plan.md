# EliteSync-v10｜v10.0.8 正式冻结计划｜独立Blade Web管理业务闭环

2026-10-15。**FROZEN_PLAN / OWNER_MANUAL_DISPATCH_REQUIRED / IMPLEMENTATION_NOT_STARTED / AC-08-01～AC-08-08 IMMUTABLE**。

本版由Astra在Owner明确批准D1/D2/D3后冻结。版本目标是在原Laravel Blade独立管理入口内一次交付B01～B05及B06中确有既存业务服务的开发渠道版本元数据管理，同时完成与既有APP、同一业务Laravel、隔离MariaDB的一致闭环。**当前仅冻结文档，不因创建本文件自动启用Docker、数据库、浏览器、worker、AVD或修改产品代码；由Owner手动派发本固定计划后，第5节的一次性受控开发授权才生效。**不把实际存在的Flutter Admin参考页面/管理API冒称Web实装，不把未来用户功能欠账静默删除。

## 1. Authority、基线与冻结来源

- 仓库：zcx369658780/EliteSync-v10；Owner是产品方向/重要不可逆风险最终Authority；Astra规划、独立终验与复盘；Codex在Owner手动派发的冻结版内自主实现、诊断、修复、测试与提交。无Work/dot实时监督、逐步骤审批、每版新worktree和单文件限制。
- **本版实施产品代码技术起点**：已完成v10.0.7 K08的 main Commit a75b8d4061ae012937ef4823120b396f257d3aec；Tree 89637891276cdf4280f918ccad7eb4c5030f55be。对应产品集成Commit 18c1ddb67378518b6b2c3e912e1e3b2afd394051，Tree 4cde05f06079a8bd4879ae34a31db7ac0c30c625。版前实际读取main 1bb76362522876fcc9b4b45e383e905e40fdaa79、Tree 7735a1b69227d3570bac9c97a66836292c51edaf；后续Owner决策提交 cacfa889128f9a3a4b443efa87f4c347a178f1d5 仅更新PRODUCT_DECISIONS。实际核对apps/services/question_bank及根题库Blob没有漂移。冻结提交和随后纯文档提交不是重新实施0.7代码的起点，执行前仍需读取live main、核实际本地专用树。
- 权威Owner政策：[PRODUCT_DECISIONS.md](../../../PRODUCT_DECISIONS.md) 2026-10-15 D1/D2/D3，固定确认提交 cacfa889128f9a3a4b443efa87f4c347a178f1d5，Blob 4f84f1968ee2737b842f828ad2e0cbdd5c929936。**三项已由Owner明确批准，不再向Codex征求是否实施或重新设计政策。**
- 版前完整证据：[FEASIBILITY_RECOMMENDATION.md](FEASIBILITY_RECOMMENDATION.md) Commit 1bb76362522876fcc9b4b45e383e905e40fdaa79，Git Blob 4ff9535140b98fea4a9adf3d5169c69ba0af174c；[旧版前草案](PLAN_PROPOSAL_V0_1.md) Blob a1b380521ac8b6fffb1b06a17f759e8755671cc8。报告的S01～S30源码索引是具名静态调查，不是B01～B06本版已运行。
- [CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)、[当前路线图](../../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[恢复台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)保持适用。v10.0.6、v10.0.7限定验收/K08均已完成，不重复规划、重验所有历史或复活BE-12/V57/H1/H2/D0。v10.0.7既有Flutter普通793通过/5失败、带同次fixture821通过/3失败且exit1的证据不修改，也不自称全绿；R1消息通知隐私修复和原私密消息使用点鉴权必须保留。

## 2. Owner已批准的不可变业务政策

**D1｜运营参与资格审核。** verify_status仅是可核验的运营参与准入，不是法律或外部实名身份认证；不得借realname_verified自报字段冒充已认证。pending/rejected不得参与**新一轮匹配**，approved还必须满足其余问卷、状态、身份和资格合同。APP需真实展示当前运营审核状态、原因和适用范围，匹配consumer、候选快照及资格读模型使用同一有效标准；不应只在UI隐藏或只改变单个字段。历史已发布Match、已经建立的Connection和Messaging Consent不因审核调整被静默删改或自动终止；目前允许的历史私密读写仍须分别满足当前独立同意/处罚/block等使用点。现存账号不批量无声改状态；v10.0.8只在新开发库中具名登记/迁移测试账号。

**D2｜分级处罚与受控恢复。** restrict允许保持登录、当前合法许可下的历史只读和申诉，但暂停新匹配、公开动态发布及任何与受限账号关联的新私信发送/接收；restrict不得解除已有ban或其它独立处罚。banned调用共享DisableUser事务，禁用账号、轮换remember_token、删除token与持久session，并使APP旧token、refresh、新登录及本版业务拒绝。restore仅由有权管理员针对具名、可追溯且未被其它有效处罚覆盖的记录执行，不得用一个disabled=false消除无关处罚；旧token/session永不复活，原已REVOKED的Connection/MC及block不复活。处罚导致的私密权限失效不得因restore自动回授，恢复私密互动必须重新满足双方当前明确授权。处罚与撤销事件、版本、原因、前后必要状态摘要以同一事务审计；Web和既有Admin API复用同一业务服务，不留下原reportAction、旧disable或role-only入口旁路。申诉仅由合法具名入口处理，不能藉此恢复全部登录/业务能力。

**D3｜历史问卷保留，新的Matching以当前启用题的有效覆盖作资格。** 问卷停用或再启用不删除/篡改历史answers、attempt、已发布Match及原快照；新轮次只将当下enabled题及对应有效答案计入既有最小题数/画像一致的资格计算。若历史已完成者有效覆盖不足，APP显示需补问卷，合法补答后恢复**未来新轮次**准入，不回改旧结果。未完成draft须按题集合及版本提供安全续答/补答，无法直接兼容时明确失效及恢复提示，不静默消失。题启停前展示受影响题目与答卷/草稿/MatchingRun、preview绑定版本与实际事务复核、确认/理由/审计；与提交/Matching consumer并发时完整生效或明确冲突及新attempt重试，不出现半写或静默修改已冻结run。

上述三项由Owner已作最终业务取舍，不可由Codex缩减为“只给Web按钮”、恢复旧安全漏洞或擅自改回新设想；普通技术设计可在此语义内自主实现。确需新的外部身份证明、第三方合同、许可证、真实数据处理或不可逆操作时只暂停那一风险项并提出单项决定。

## 3. 本版必须交付的B01～B06真实Web管理能力

统一架构：保留/扩展 Laravel Blade + /admin 独立Web session、CSRF、AdminAccess role与显式管理员名单，沿用APP当前使用的同一Laravel业务服务与MariaDB事实源；管理Web不是Flutter Admin内嵌页、不是只读演示、不是第二套后端/数据库。需要的Flutter APP审核提示/资格反馈、举报效果/版本检查属于本版共享业务闭环的相关变更，可跨模块实施。

### B01 用户与全入口权限

沿用现有/admin/login、/admin用户查询、POST禁用与logout，增加有用的分页/状态筛选/最小化详情、明确确认、状态与审计。共享DisableUser实际事务，所有Web/API/report处罚目标规则统一（管理员/自身不得被普通管理操作禁用）。验证role-only、名单-only、空名单、普通用户、disabled管理员、退出及降权旧session、CSRF和伪造目标在实际服务端拒绝。禁止查看私人画像和会话全文以实现用户列表。

### B02 可实际生效的运营审核

建立Blade待审队列、详情最小显示、approve/pending/reject带理由及expected revision的审计写操作；APP从同一服务读回审核状态和原因，既有ProfileReadinessService、真实matching候选及最终consumer均按D1门限运行。操作必须存在真正的pending/rejected拒绝、approved合格控制和历史Match/CN不自动删除反例。verify_status不是实名授权，不使用未实现的/verification/status与/verification/submit声称身份认证，也不擅自接入证件/短信/人脸SDK。新库账号审核状态和既有账号迁移边界须明确，不能在原0.7验收库一律批量改状态。

### B03 举报、处罚、内容处理

APP虚构用户实际提交合法目标的举报；Web受限列表/详情/处理决定→同一ModerationReport、可信actor、报告版本和追加审计→对同ID user或公开动态执行具名处罚/软删→APP可观察到结果。原reportAction的restrict/banned/restore直接改user字段旁路须在Web/API共享服务中纠正，跨多行事务原子性及重复/冲突/恢复禁止反例具名验证。限制D2实际作用于APP新匹配、公开动态和私信收发，同时允许合法历史只读及既有申诉途径。举报人/目标关系、公开动态归属与授权使用点复核，拒绝伪造关联及管理员越权；列表分页、必要字段最小化、详情Web模板转义和敏感内容访问审计。不得新增任意解密私聊、消息全文管理、群发通知或通过审核工具绕开MC撤销与R1通知隐私。

### B04 匹配运营真实执行

Blade轮次列表/详情及prepare→执行请求→受控真实MatchingRun consumer/queue worker领取并运行→业务终态→确认reveal→同测试账号APP Match和站内事件读回；含零候选、失败/lease失效、重试新attempt、close。复用MatchingRoundService、MatchingRunService及已有append-only audit/idempotency/expected state_version，确保事务内状态/版本复核与特定run的受控dispatch，不凭Controller先读版本、页面按钮或配置布尔值声称并发安全；不能从表单拼接任意shell命令。worker未运行/故障时Web真实显示pending/失败并允许受控恢复，不能冒完成。legacy devRunMatching/devReleaseDrop若与新流程冲突，限定旧dev作用或通过共享运营业务服务/保护门收口，不放开其它旧渠道。Match/like不能自动授予Connection/MC，补偿路径维持原403，除非未来具名批准。

### B05 问卷质量与安全运营

Blade质量统计、低drop题目具名预览（ID/数量/历史答案、attempt、草稿、活跃轮次影响）→dry-run→确认执行可追溯的题启停→数据库题集合/版本或签名变更及审计→APP新题/需补答/草稿提示和新匹配资格响应。共享服务接旧quality-stats/prune入口，不能只修Web而留API无版本/审计旁路；默认dry-run，真实apply须显式确认并事务内再检查preview版本。确保历史答卷/attempt、已发布Match不变，开发虚构数据证明eligible/new answer与旧历史的区分；新MatchingRun若在题集合变更中冲突须给可理解失败及新attempt恢复，不悄悄更改已冻结输入。允许对**本版有审计的题目变更**安全恢复enabled状态以支持纠错；不做完整题库编辑器、任意物理删除或数学调权平台。

### B06 已存在的版本发布元数据

只交付Laravel当前AppReleaseVersion/AppReleaseUpsert真实持久业务的**Android开发channel** Blade创建/编辑/激活/停用，版本、最低支持、下载URL/哈希/文案校验、并发唯一active、确认与审计；APP About/Settings或版本检查入口从同一数据库实际读取并展示有效元数据，异常fallback需明确不冒真正DB读回。Web/CLI共享受控写服务，不调用任意控制台命令。可提供既有站内事件只读运营状态及密钥脱敏的必要配置状态，不开放任意.env/secret编辑、外部Push或公告群发。仅操作具名本地开发channel，不上传商店/生产，不实际推送或强制升级真实用户，不因字符串“版本”就强迫v10项目版本号等于APK build号。

## 4. 必须保留的权限和待恢复功能

- 当前仍为正常用户APP提供v10.0.7限定问卷/匹配、双人Connection与MC、合法文字/本地图片、动态、站内通知和本地设置；处罚/审核与问卷资格改动只收紧所需用途，不破坏其它已接受操作。原R1消息通知必须最小存储与当前授权读投影；旧本地通知明文存储仍是具名观察，未授权清洗原证/真实历史数据。
- 原BE-12、安全使用点、私密图片动态鉴权、Match≠Connection≠MC≠Conversation的层级仍成立。生产/未配置默认fail-closed；不能为了0.8在共享API中允许被禁用/未同意的聊天、媒体和通知。
- **仍待恢复、必须于软件完整内测前收口或Owner明确取舍**：RTC真实双端音视频（需SFU/设备/许可）、完整紫微与西占真实算法（含精度oracle/许可）、Buddy/Social真业务、原已实现的其它媒体能力、地图与系统Push/必要设置、历史获准数据/附件副本。见[版前具名欠账](FEASIBILITY_RECOMMENDATION.md)第5节与单份恢复台账；不以“下一版联合验收”替代功能开发，不暗中推迟到内测运营之后。0.8不自动购买/启动上述外部服务或编造新业务规则。

## 5. Owner手动派发后一次生效的环境、设备与修改授权

- **代码/工具**：复用K08专用干净工作树 C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10，允许创建0.8版本分支、连续提交，允许相关Blade/Laravel/Flutter/Android/数据库迁移/queue/测试/必要脚本成组修改。按现有锁和已安装版本使用Laravel/PHP、Flutter/Dart、JDK17、Gradle/Android/AVD/Composer；可为既有锁定依赖补齐缺失可信包。不得未经具名批准进行全栈升级、composer update/SDK升级、系统级安装/UAC/全局代理修改。
- **数据库**：为0.8**新建**独立受控MariaDB10.11容器 elitesync-v1008-db、专用持久volume elitesync-v1008-db-data、库 elitesync_v1008_dev，宿主默认127.0.0.1:43318；若被占用，先具名核占有者并改用另一个空闲loopback端口，最终报告保持一致。只允许新8版虚构用户、题库、举报、匹配run、媒体、release、Web session、审计、队列写入；本版必要迁移/seed要具名防误库、幂等，最终重启不重seed。绝不挂载/seed/覆盖0.6的43316或0.7的43317、原3306真实库、SQL gzip/VHDX或生产数据库，不从旧验收库导出用户私密数据充当新fixture。
- **Laravel/Web及worker**：复用自有loopback 127.0.0.1:8000 front→Laravel8001（或核实空闲后统一更换），独立本版 APP_SESSION_DRIVER/APP_SESSION_CONNECTION 与浏览器session cookie，不复用前版敏感私配。可启动必要Laravel database queue、具名Matching consumer/job和媒体/事件处理worker；核实run绑定、worker归属、并发/lease/故障重启。不kill无关PID、不启动SFU/新第三方服务或任何生产通道。正式用户数据不可写/不可发真实外部通知。
- **真实客户端/浏览器**：受控本地Edge/Chromium实际操作独立Blade/admin，管理员和普通用户隔离浏览器会话；虚构账号在既有Android36.1 x86_64 AVD或经核归属的指定模拟器上实际操作APP，以指定serial ADB reverse打通loopback服务。允许使用既有本地AAR/debug APK构建链；如Flutter/Android产品源码因资格/版本展示等改变，最终源须新建Flutter AAR/debug APK、安装并在最终身份下验证。不能两端mock/curl替代Web＋APP联合链。允许截图/本地虚构图像fixture与日志安全封存。无关模拟器不得wipe。
- **0.8专用local门**：目前LiveConsentService::enabled只允许准确的elitesync_v1007_dev/loopback配置。可在0.8功能代码中增加**仅具名0.8受控开发库和端口**的狭义白名单、测试及读取身份检查，同时继续允许原0.7受控环境，排除生产/未配置/其它库、3306与0.6端口43316。不通过假造v1007库名、关闭权限、修改原验收配置、生产flag或全局放行来使0.8聊天/媒体可用。每个使用点仍核当前权限。
- **审计/证据**：可新增同库有限元数据审计表、queue/jobs/失败记录、测试fixtures及必要项目级开发脚本；仅记录可信管理员ID、动作、目标、必要版本、时间与脱敏前后摘要，不存密钥、私聊、举报完整正文或其他受保护值。允许本地功能HTTP、MariaDB写和发布安全GitHub证据；私配/证件/账号token、原始私密数据、物理大包均LOCAL_ONLY。原dirty根 D:/EliteSync-v10 的HEAD/index/status及既往具名受保护文件不得覆盖，不做blind pull/reset/stash/clean/prune。
- **新增授权外**：真实身份证/证件来源、付费/商业SFU与高精占星许可证、外部地图/Push/SMS、系统级提权/设备全局安装、历史备份内容及恢复、真实账号/生产SSH或数据、生产release及外部推送、不可逆资产删除，仍须Owner对**具体一项**另作决定。普通环境/编译/权限实现问题本版本内自行修复/重测；单项真实风险只暂停相关部分，其它无风险工作继续。

## 6. 冻结AC-08-01～AC-08-08（全部必要，不作事后增删）

| 固定AC | 冻结的真实验收条件 |
|---|---|
| **AC-08-01 独立Web会话与可信操作审计** | 真实浏览器/admin以新库管理员登录并session轮换、CSRF有效、退出失效；正常管理员与普通用户、role-only、名单-only、空名单、disabled、降权旧session/伪造CSRF/目标正反例覆盖。每项实际管理写操作由同库可信actor、目标、理由、expected version、脱敏前后必要摘要产生可查审计，成功与业务同事务，冲突/失败不留半条业务修改；浏览器不是Flutter内嵌页或mock。 |
| **AC-08-02 B01用户安全管理** | Blade用户搜索筛选/详情、确认禁用走共享DisableUser及Web/API/report统一作用；同ID user tokens、持久session、visibility、match eligibility与实际disabled落库，APP旧token/refresh/登录/业务被拒，另正常账号可用。管理员、角色或白名单不足、自身/无效目标拒绝。restrict不能解ban，restore只解除有证据的本项处罚，旧凭据与已失效MC/CN/block不复活。 |
| **AC-08-03 B02运营资格审核** | Web真实pending/approve/reject及理由、expected revision/审计→same DB→APP刷新/重登读回真实运营状态及原因；pending/rejected不能进入**新**matching候选、consumer及发布，approved满足其余条件才可用。历史已发布Match/CN/MC不因状态变更静默删除，非法/过期/其它人目标及未知状态拒绝；绝不标成实名认证，不静默批量迁移既有账号。 |
| **AC-08-04 B03举报、分级处罚与动态处理** | APP具名真实举报公开动态/账号→Blade安全列表/详情/处理→同report/audit与user/status软删事务→APP同用户看见隐藏/账号受限或禁用；D2 restrict实际阻止新matching、公开发布、新消息双向读发中的**新收发**，保留合法历史只读/申诉；banned执行共享凭据撤销；restore需可信处罚归属，权限不自动复活。越权/伪造report关联/CSRF或旧session、当前MC撤销与非参与者图片等仍拒绝；Web/API不能浏览私聊全文或绕过R1通知隐私。 |
| **AC-08-05 B04匹配轮次运营** | 管理员真实浏览器prepare→request/run dispatch→受控worker实际领取/结束→确认reveal→同一组虚构用户APP读取同round/run/Match与站内通知；另覆盖零候选、故障/lease过期、幂等重放、stale版本、重复操作、worker停止/恢复及重试新attempt、close。数据库版本与audit一致，无worker不能冒已完成，已发布旧Match不因管理操作被静默改写，Match不自动建CN/MC。 |
| **AC-08-06 B05问卷运营与新轮次资格** | Web真实质量统计→显示停用题及涉及答卷/draft/运行轮次影响→默认dry-run→与版本绑定的确认执行→题集合revision、审计与DB一致；同一APP已答/未答/草稿/补答呈现符合D3，旧answers/attempt及旧发布Match不变；当前enabled有效覆盖不足时新matching拒绝并解释需补答，补答后可参加。并发prune与答题/consumer冻结输入产生完整一致的提交或明确冲突、新attempt恢复，不能仅改enabled字段并把历史资格不一致作为完成。 |
| **AC-08-07 B06开发渠道版本发布** | Web创建/激活/停用Android开发channel release、版本与最低支持及downloadURL/SHA格式校验、确认+审计；DB同平台/渠道仅一个有效版本，非法/并发/重复更改拒绝或合同幂等。同一APP版本检查从DB拿到一致有效版本、升级状态/说明且与config fallback区分；旧站内通知的权限/已读/计数保持。不能声称系统Push、外部群发、任意配置修改、真实商店更新或生产发布。 |
| **AC-08-08 最终Web/APP/DB持久交付** | 具名真实浏览器管理员与正常/待审/处罚/非管理员对照，加至少一组真实APP用户，在0.8独立库经Blade→共享业务服务→MariaDB→APP实际联动；重启Web/Laravel、DB、worker、APP后核审核、处罚、动态、题库、round/run、release、审计及旧授权拒绝一致。提交最终候选commit/tree、来源/实际模块diff、源头新AAR/APK（如客户端源码改）或固定子Tree复用包证明、实际命令stdout/stderr/exit、测试和少量业务截图、失败及修复/NOT_RUN、版本Runbook、Manifest/台账。不得以curl、Widget/SQLite双mock代替跨端事实；Astra按这8项独立终验，候选只发布独立分支，不自动merge main或启动0.9。 |

## 7. 开发/测试、候选交付与收尾

实施顺序可由Codex内部根据依赖优化：独立0.8DB/虚构账号及受控本地会话→共享处罚/审核/题库服务和审计→Blade管理入口/举报/问卷/版本→受控Matching worker/queue→APP资格/动态/Match/版本联动→两侧权限正反例、并发、重启、必要包构建/安装与安全证据封存。正常范围内跨代码文件、连续提交、调试和重测，不为每个动作询问Owner，也不拆小版本。

根据实际代码改动选择V1006AdminWebTest、AdminApiTest、ModerationApiTest、StatusPost相关测试、V1007QuestionnairePersistenceTest、MatchingRun/Foundation/OperationalTruthLoop、AppVersionApiTest、R1NotificationPrivacy/LiveConsent/PrivateMedia及Flutter受影响文件，再加新Web/queue/版本/并发测试；旧Flutter3项legacy失败和诊断必须同次PHP fixture的事实不得抹掉，若本版实际改其产品合同则针对性重验。不要用成功测试数量替代真实浏览器和APP。未运行写NOT_RUN，退出码与完整stdout/stderr一致；全范围analyze exit0也须记录真实文本与info计数。

最终在GitHub独立候选分支普通non-force发布：正式执行报告、Manifest（各源码/包哈希和本地LOCAL_ONLY路径）、Runbook、AC-08-01～08逐项真实证据/安全索引、未恢复功能台账和原失败；大型物理包/私配/原始隐私不发布。可复用K08专用工作树，不强制sole-parent等于技术起点，也不强制单一提交；候选与实际技术起点可追溯。**Codex不得自行最终ACCEPT、将代码合并main、发布生产、启动v10.0.9或更改冻结本计划。**

接收候选后由Astra独立阅读GitHub正文/源码/原证，对固定八项AC验收；原目标内缺陷集中返修，超范围优化后置。通过后按K08分别登记Acceptance、GitHub代码集成、本地连续基线与实际运行。用户功能欠账保留在同一恢复台账，后续具名计划另决策，完整主要软件交付与内测运营窗口分开。

**终点：V10.0.8 FROZEN PLAN — EIGHT AC — OWNER MANUAL DISPATCH PENDING。**
