# EliteSync v10.1.3｜独立搭子与好友可见社区｜冻结功能计划

2026-10-21｜Astra功能规划。**V10.1.3_FROZEN_FUNCTIONAL_PLAN / OWNER_CONDITIONAL_ENTRY_AUTHORIZED_AND_CONDITION_SATISFIED / CODEX_MANUAL_DISPATCH_PENDING / IMPLEMENTATION_NOT_STARTED**。

## 1. 产品目标与接受出口

Owner已确认长期恋爱是主目标、**搭子是独立的吃饭／学习等共同活动业务**，不要求Match或恋爱意图；好友社区的动态只在作者明确授权的当前好友上下文显示，陌生人不是无界Feed的读者。2026-10-21 Owner进一步条件批准“v10.1.2独立安全集成通过且无需返修即可进入v10.1.3”；Astra已直接独立验收v10.1.2功能与安全集成`ACCEPTED_WITH_OBSERVATIONS`，因此允许冻结本版及准备一次Codex综合任务，**不自动授予本地执行权**。

本版结果为：**未报名慢约会的虚构A/B真实通过现有社交/邀请权限，在Android APP发起吃饭或学习搭子，收件人受控参与、创建人确认，能随时撤回/取消/结束；同一APP好友动态正文／图片、点赞（复用）、一级评论（新增）可真实读写、隐藏/撤回/举报；所有状态跨Laravel API、独立MariaDB、APP重新登录与服务/数据库受控重启一致，Web运营仅必要只读/具名审核。** 最终在获准开发AVD生成并实装可回读的v10.1.3开发APK。纯Mock/UI静态卡片、SQL fixture写库或只测Controller不能冒作完整软件链。

本版不做全国陌生人目录、大众广场无限流、群聊/群组、群活动、线上真实支付/订座、平台出资活动、真实地图定位、Push供应商、真实实名、心理服务、排行榜或AI亲自配对。四顶层导航`Home | Progress | Messages | Me`不变；Buddy在Home次级入口/Progress独立模块，社区在好友关系上下文，不增加第五Tab。

## 2. authority、冻结源码和不能改变的事实

- Owner负责产品取舍、真实数据/费用、陌生人公共发现字段、新外部API和重大不可逆操作；Astra负责本版冻结与独立验收；Codex只有Owner**手动派发**综合任务后才连续自主执行。
- 后继正式起点为v10.1.2**已安全集成的main产品**，应用完整apps Tree `365810451b6faad98e041835be6c86f4f81be0a9`，services Tree `96b2972a19ec49108cf5c11d144179e5693570a9`；接受功能源码 `88ffeccce4042f13ce4edccf7604b835b06c8f2d`，集成主对象 `418dd43acb2ef7a3bd279c40fc3821c4a0a234e2`。后续纯文档提交不改变接受产品身份，开工前实核真正live main。
- 独立验收已由Astra归档 `docs/versions/v10.1.2/acceptance.md` 与 `docs/versions/v10.1.2/integration_acceptance.md`；前版原失败、B1/B2修复过程与受控R1都保留。工作流 `docs/workflow/CURRENT_WORKFLOW.md`、`ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md`、当前入口`ACTIVE_STATE.md`生效。
- 继承2026-10-19 Owner决定PD-1019-02/03/04/06/07/08/09/14/15：`Buddy ≠ Match ≠ Friendship ≠ Connection ≠ Messaging Consent ≠ Conversation ≠ formal Relationship`。搭子成立、共同吃饭、好友或评论都不自动解锁私人生日/生辰时地/原问卷/星盘/身份证/风险档案，也不自动发普通消息、附件、通话。
- 本版**缺乏Owner对面向陌生人的开放发现字段/地点公开细则的具体确认**；因此采用下述最小保守**开发默认合同**，不是推定Owner永久审批的全民广场。任何向未知第三方的公开目录/精确地址/开放邀约须停在单独产品门禁，不得因技术实现容易就默许。

## 3. 定点源码事实（签发时已直接阅读）

- `apps/flutter_elitesync_module/lib/features/buddy/presentation/pages/buddy_companion_page.dart`已有学习/电影/吃饭/健身设计雏形，但`_mockCandidates`、本地手动聊天草稿、举报提示不入服务端；`test/app/router/buddy_route_exclusion_test.dart`保留此前禁止误开放mock路由的基线。不能将此页现状说成真实搭子业务已恢复。
- `apps/flutter_elitesync_module/lib/features/social/presentation/pages/social_baseline_page.dart`是本地表达预览，不是独立社区数据库。
- `services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php`已有`SELF/FRIENDS`受众、图片封面、本人删除、点赞/取消、举报、基础分页；`status_posts/status_post_likes`已有迁移。应在这套接受的权威之上补一级评论与好友受众一致性，不另建一个混乱的Community动态真值。
- `services/backend-laravel/app/Http/Controllers/Api/V1/SocialController.php`已有受控好友邀请token、好友关系、请求开关、限额与拉黑；`SocialPolicy`、`LiveConsentService`沿用v10.1.1/1.2接受门禁。需要拓展搭子独立申请事实与受控可达性，而非复用恋爱提案同意或MC权限。
- 无独立的可确认真实Buddy参与者状态机及好友评论全链。旧status内容字段还有`visibility=private`历史语义；本版不能用隐藏表面控件来绕过实际audience和media read校验。

## 4. 冻结的最小开发合同

### 4.1 Buddy独立受控发现（两人、吃饭／学习）

- 首包只`MEAL / STUDY`；每张活动卡有服务器UUID、创建人、type、简短主题（例如100字内）、general_city（可选，仅城市字符串）、`place_kind`枚举`ONLINE / PUBLIC_PLACE_UNSPECIFIED`、时间段start/end（UTC及显示时区）、可选预算**区间档位**（`UNSPECIFIED / LOW / MID / HIGH`而非实名交易或精确付款），状态、revision及创建时间。**禁止**精确经纬度、住宅/单位地址、电话号码、真实身份证件、生辰、直接联系方式或任意自由文本地点字段；主题/备注应做长度/内容类别保守限制并审查持久化与输出。
- 默认卡片仅本人可见。**当前有权好友**且收件方明确开启Buddy申请的场景，可由创建人点对点发邀请；**非好友**只能通过创建人明确生成的随机、单次、有限期、可撤销的高熵capability邀请凭据由持有人手动兑换，再由创建人明确确认，不走全站搜索／通过数值ID扫描别人活动。默认邀请码48小时、单次有效，撤销与泄漏后必须失效；如需再邀请，新token＋新生命周期。
- 有限状态：`DRAFT → OPEN → REQUESTED → CONFIRMED → COMPLETED`，另有`CANCELLED / DECLINED / WITHDRAWN / EXPIRED`分支。单活动**最多2名参与者（创建人＋一位明确同意的搭子）**，同一个人同时最多3个未结束搭子活动（当前开发保守默认，可配置/有界更改，不是永久运营政策）；不能靠客户端计数实现，需事务与DB唯一性。对不同活动允许并发独立。
- 发起、申请、收件决定、取消、撤回、完成要求请求者身份、强身份绑定、current revision、可选幂等key，并有清晰的谁能操作什么；结束不互相处罚、正常爽约主观评价不自动创建Safety Finding；关闭或撤回后旧token、旧链接、迟到APP响应拒绝。
- 未参加慢约会、无恋爱Match、无正式Relationship的A/B可成功完成真实正例；Block、账号禁用、注销、请求关闭或source撤销时不可接受新申请、不可获取受控卡片，也不能因解除Block自动复活搭子。已确认双方的历史活动记录保留最小审计并按合法权限投影；不自动把双方加入好友，也不生效CN/MC。
- 仅发送站内**最小元数据**提醒（“有搭子请求／状态已变更”），绝不把原正文、地点或身份信息拼进未授权通知/Push。真实系统Push属于1.5。

### 4.2 好友受众社区（复用Status + 一级评论）

- 本版一个有限**好友上下文**入口：作者显式选择`FRIENDS`才向当前有效好友显示，`SELF`只本人；按服务端当前好友、Block、禁用及作者账户状态与内容审计判断。保留旧Status正当内容与LIKE合同，新建**一级评论（无嵌套、无引用私聊）**的持久身份、本人删除/tombstone、作者对自己文章的评论管理及已授权举报。建议新评论最多280 Unicode字符、同用户10分钟5次、每页<=20条，限域本版开发配置；链接/媒体/附件不作为评论能力，不能绕过消息请求/MC。
- 评论的创建、读取、删除、点赞历史、通知以及附件/封面媒体必须使用**同一当前Post受众服务端判定**。作者撤回`FRIENDS→SELF`、删除帖子、解除好友、Block、账号禁用/注销后，旧postId/commentId、列表分页、个人动态、媒体URL、旧JWT、缓存刷新或晚到请求均fail-closed，不能使受众缩减前的正文或评论继续向旧好友公开。
- 现有`StatusPostController`权限下的新旧读写点不得因为了新增评论而重新引入v10.1.1 R1的MariaDB`REPEATABLE-READ`旧快照授权竞争；需要精确reader/writer行锁等待、撤权COMMIT后读者恢复的本版真实测试。通知不得含已撤权的私密评论正文；旧通知点击时服务端重新鉴权。保留内容被真实客户端下载之后无法追溯抹除的物理限制。
- 互动首包为已有点赞＋**新增评论**，不含收藏、转发或多级回复；不强制设计大广场/无限Feed，不暗开陌生人作者搜索。对朋友动态采用有限分页/一次明确加载更多，UI显示空态、网络失败、审查隐藏和重试，而非永远显示Mock卡。

### 4.3 APP／Web／后台与合规

- Home次级入口与Progress独立模块接入真实Buddy；好友/关系上下文接入有限动态+评论。旧BuddyMock页或局部表达预览可保留为具名**历史展示**或改造为真值入口；绝不把虚构候选或按钮当真实可邀请账号。Messages入口只有CN+MC独立同意才真通信，Buddy无独立即时群聊。
- Web后台复用现有角色/CSRF，具名阅读搭子审计／举报、动态评论审核的必要操作；只能按已有Moderation处置权限执行，不能手动替双方“确认搭子”、代发私聊/开放陌生人动态或借admin公开用户私密资料。若实际需要增加表与管理API，只实施本版最小链。
- 不构建平台活动报名／会场预订／补助/支付或真人入场验证；这些分别属v10.1.4+和未来外部授权。测试城市是合成普通城市字符串，不是真实个人GPS/精确位置。

## 5. 开发环境、隔离与交付门

- 复用已接受v10.1.2产品main代码，**独立新建本版本合成MariaDB**，建议`elitesync_v10_1_3_dev`、新Docker volume、本地loopback43324；API建议8017、WS8018，所有端口先确认无人使用。不接旧v10.1.2数据库/事故恢复卷，不改变生产、阿里云/公网/防火墙/UAC、真实身份/Push/支付供应商。
- `APP_DB_CONNECTION`优先于`DB_CONNECTION`必须在任何迁移/RefreshDatabase之前核对effective连接；普通PHPUnit在testing/sqlite/:memory:隔离，真实MariaDB专项显式新库且运行前备份和归属确认，不能migrate:fresh旧库、抹除历史账号/卷。
- 有权既有AVD可在原授权界限内用于新APP开发演练；未获手机/相机/麦克风、全局SDK、系统网络的新一次授权不得沿用旧宽泛权限。若模拟器实际应用要用图片封面，采用本版本合成图片/私有Media通路，不上传真实用户图片到GitHub。
- 任务发布后只有Owner**将任务手动交Codex**才开工。范围内Codex连续实施、必要修复、真实正反例、非作者有界复核，最终固定候选Commit/Tree/apps/services，APK/hash/readback及独立DB/APP/Web证据；正常non-force发布**候选分支**，不自行合产品main、宣布Astra接受、清旧审阅资产或启动v10.1.4。

## 6. 冻结验收 AC-10.1.3-01～12

| AC | 可观察的通过标准 |
|---|---|
| **01 基线/环境隔离** | 真实live main与v10.1.2接受产品起点明确；现行Owner/源、4处保护树/本地SQL卷/旧项目源保全；独立空库/volume/备份/APP_DB_CONNECTION优先门无误清。 |
| **02 非婚恋搭子可用** | 未填恋爱问卷、未参与Date Drop/Match、无正式关系的A/B，在APP→API→DB实际生成MEAL/STUDY草稿、OPEN、邀请/申请、CONFIRMED与完结；合法重启重登后相等。 |
| **03 受控可达／无枚举** | 默认SELF；好友须双方当前许可且作者点对点；非好友只可持有效一次性高熵capability主动兑换再双方确认；匿名/错误ID/过期/泄漏后撤销、Block/退出、Disabled拒绝，全部无私密输出/无骚扰通知。没有公开人员目录或陌生活动Feed。 |
| **04 状态/并发/取消** | 一个活动最多双方、当前revision+幂等拒绝重复/双提交/越权；双申请只允许一人确认，旧nonce/旧session和终态不复活；任何参与者能按合同退出且不生成处罚；持久审计和正确释放占位。 |
| **05 独立CN/MC/正式关系** | Buddy可成功但friends/CN/MC/Conversation/Relationship均不自动写入；原来合法独立CN/MC不被普通Buddy退出撤销，禁令/Block优先；请求/消息/通话不能绕过独立同意。 |
| **06 好友动态主体/受众** | 已接受Status帖子SELF/FRIENDS作者发布、修改受众、作者删除、图片封面，当前好友可见、普通陌生人404；列表、个人作者页、单帖URL与实际媒体授权一致，不能用已缓存作者字段代替权限。 |
| **07 一级评论／点赞／举报** | 好友在授权帖评论/分页读回/本人删除，原点赞/取消、原举报路径持续工作，越权评论/批量重放/垃圾内容/错误actor拒绝；评论状态及必要审核在持久数据库受控重启后可回读；评论不添加私聊附件或自动MC。 |
| **08 撤权和RR竞争** | FRIENDS→SELF、unfriend、Block、帖子删除、账户禁用/删号、旧token、评论删除后旧帖/评论/媒体/通知均按当前权限fail-closed；**至少两组实际MariaDB RR精确reader/writer INNODB锁边**（如受众撤权与unfriend），撤权COMMIT后读恢复无私密正文和越权副作用，测试含原接受v10.1.1相关媒体/点赞回归。 |
| **09 Android真实界面** | Home/Progress/好友社区入口真实操作，空/无候选/无好友/无活动/错误/离线/跨号晚响应区分，账号切换清除旧内容；开发APK明确版本、源码/ABI/签名/hash，与APP安装pull及同一后端/DB一体证据相同。 |
| **10 Web与安全治理** | 已有Admin角色/CSRF具名审核/只读审计，不可代双方确认、读取禁止字段或创造陌生人消息；举报仅形成待审核事实，拒绝/取消不算Safety Finding；已有账号限权/旧社交路径回归。 |
| **11 重启持久化和真值** | 独立MariaDB/API受控重启，Buddy生命周期、token核销/撤销、评论/动态受众、审计、通知副作用持久；正反HTTP及Flutter/AVD与表中事实一致，不用脚本打印PASS掩盖exit1/500。 |
| **12 集中候选交付** | 唯一IMPLEMENTATION_REPORT+artifact_manifest、必要脱敏审阅包/非作者有界review、冻结源码身份/应用版本/DB环境/实际exit/raw失败/本机备份保护与NOT_RUN；没有真实公开发现/支付/地图/外部身份供应商、产品main集成或下一版本启动。 |

## 7. 必须保留的观察与项目源后继

v10.1.0整体`PARTIAL / NOT_ACCEPTED`及AC-10.1-08 PARTIAL继续；v10.1.1 DB事故/恢复、v10.1.2两P1修复和未接实人供应商保持长期来源证据。独立`v10.1.3`不得改变已接受的v10.1.2正式关系的双认证/双向确认、逐字段分享、CN/MC、Block、旧token及受控邀请原语义；只有实际本版修改了对应权限使用点时才定点回归，不重做其它算法Oracle或RTC长测。

ChatGPT 2026-10-21项目源已由Owner手动更新，但仓库版本化目录尚为`SEMANTIC_CANDIDATE_ONLY`。本顾问在同一会话可直接取得原增量ZIP并核定ZIP SHA256 `6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`及内部清单，**这不代表Codex本机可读取或GitHub镜像已补**。本版Codex若可获得Owner按原hash提供的ZIP，可在不改变已冻结本版产品的前提下顺带向`docs/gpt-project-sources/20261021_v1012/original_zip/`补齐7份原字节文档，保留先前候选为历史并更新当前导航标记；不可得则单独保留`BYTE_MIRROR_UNVERIFIED`，不阻断Buddy/社区正式研发，也不再次生成全项目源ZIP。

正常交付出口：**V10.1.3_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / V10.1.4_NOT_STARTED**，正式产品接受和后续安全集成仍分别需要独立裁决。
