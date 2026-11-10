# v10.0.7 版前可行性与推荐冻结方案｜2026-10-15

**K08_INTEGRATION_COMPLETE / V10_0_7_FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED**。

推荐按真实用户链冻结：**账户/资料/问卷 → 实际匹配任务和发布 → 独立Connection → 独立消息同意 → 合法聊天与本地媒体**，成组补齐状态、站内通知、既有设置和本地算法展示。不能把目录、接口、synthetic合同或旧测试当成软件已经恢复。RTC及紫微/西占完整排盘存在独立服务与算法标准选择，须具名处理，不能静默删掉或用估计输出冒充完成。本文件仅推荐；原草案Blob保持 `bd549ec08b806e3c5dbf06a6e72db8f850c83c11`，没有创建正式plan。

## A. K08与调查证据口径

已接受候选 `08ce3571ce02af3dea5960705b72cd9737dccb95` / Tree `0cfae117b88a3313b854ecc9a7739b303c06e0f3`。产品集成 `78aba03a68cb5dcc0302ea7e9c20ff783f5169d5` / Tree `c027d70c37b353d3e37c3570b23f673c1033dd0f`，普通推送到实际main并回读；其后K08文档登记 `8c6a939d4793449db36f727c6e74fb8f4b34e0a4` / Tree `dbe9080a4deee142f66d12dd16b1c1a670d54a5f`。复用原专用树和 `codex/k08-v1006-integration`，没有新工作树。详见 [K08登记](../v10.0.6/integration.md)。v10.0.6保持Astra ACCEPT WITH OBSERVATIONS。

以下v10路径均绑定产品commit `78aba03a...`；后续仅文档变化。图谱 `D-EliteSync-v10`/`D-EliteSync`仅用于定位：前者指原dirty根，非本专用基线，必须回到具名当前文件核对；未重新索引其它目录。两名只读辅助分别核A04/A05及A06/A08，主代理核A07、旧来源身份并形成建议。阶段二无产品编辑、服务启动、数据库写入或模型/算法/测试执行；所有新增功能 **RUNTIME_NOT_RUN**。

路径简称：`features/...`以`apps/flutter_elitesync_module/lib/`为根；PHP Controller/Service/Domain/config/迁移以`services/backend-laravel/`为根。后端短文件名可在该固定commit唯一定位；行号是本次静态读取位置。

必要旧资产只读取 `D:/EliteSync` 的具名源码/题库结构，实际HEAD `0f06e895a89629a7f4f0cf0c62b784446ecf515a`。已核旧题库和下述算法文件工作内容与HEAD Blob相同；这可确定**源码实现的存在与来源**，不证明旧版本实测可用或Owner已选定完整恢复基线。没有读取SQL gzip/VHDX、真实账号数据、凭证或私聊。

## B. 功能状态、源码链与缺口

### A04：账户、资料、问卷

- 已接受运行结果只有0.6城市保存、登录、禁用/失效及重启读回。现有Flutter `features/profile/presentation/pages/profile_page.dart`、`edit_profile_page.dart` 经 `features/profile/data/datasource/profile_remote_data_source.dart:22/34/47/69` 调summary/detail/city/basic保存；Laravel `app/Http/Controllers/Api/V1/ProfileController.php:484/512/591` 有读、出生资料重算及城市保存。其余完整资料/注销/恢复流程不能继承城市的运行PASS。
- `features/questionnaire/presentation/pages/questionnaire_page.dart` 经 `data/datasource/questionnaire_remote_data_source.dart:19/39/51/88` 调实际HTTP；`services/backend-laravel/routes/api.php:62-72` → `QuestionnaireController.php:66/343/437/473/489`。答案 `QuestionnaireAnswer::updateOrCreate`、attempt与profile快照有持久业务代码，不只是UI。基础表见迁移 `2026_03_11_144712_create_questionnaire_questions_table.php`、`...144713_create_questionnaire_answers_table.php`、`2026_04_18_000070_create_questionnaire_attempts_table.php`。
- **题库缺失是实际恢复依赖**。`database/seeders/QuestionnaireQuestionSeeder.php:78-119` 先读根 `question_bank/question_bank_*.json`，无拆分库才读 `dating_question_bank_v_1.json`，两者都缺即抛错。当前产品树两类资产均无。HTTP题目只取DB启用项；答案ID必须存在。不能靠fixture题目假装完整答卷恢复。
- 旧库可复用源码资产：core50、extended30、research20、docx_scored57、legacy100题，schema_version2.0，题项version2。不是合计257个唯一题，也不意味着所有research题都适合开放。规范字段有question id/source_question_no、category/subtopic、answer_type/options、acceptable_answer_logic、dimension_weights、active/version/recommended_bank。Seeder将source_question_no规范为Q_DOCX_V2_###；`PersonalityProfileService.php:87-105/150-190`消费维度权重，`MatchingEngineService.php:1202-1262`消费回答/可接受答案/重要性/category。正式实现应确定加载顺序、唯一键/重复策略和用户开放库，优先复用原seed规则，不自行创造问卷或心理准确性结论。

五项保留错误见固定 `docs/versions/v10.0.6/evidence/php-feature-03.stdout`，均为 `question bank json files not found`，不是本次重跑：

1. `AdminApiTest::test_dev_matching_and_release_drop_flow`。
2. `test_dev_matching_handles_multiple_chunks_without_key_error`。
3. `test_dev_matching_can_toggle_synthetic_user_inclusion`。
4. `test_question_quality_stats_endpoint_returns_reason_breakdown`。
5. `test_prune_low_drop_questions_supports_dry_run_and_apply`。

前3项直接关联A05运行初始化；后2项是题库运营的同源依赖，运营面板仍属0.8。正式0.7应修复共同资产依赖、重验相关用例，原exit2及安全流不重写，不能仅跳过错误宣称全部通过。

### A05：Match、任务、Connection及Relationship

- Flutter `features/match/presentation/pages/match_portal_page.dart`、`data/datasource/match_remote_data_source.dart:25/112/126/148/178/388`已有API请求。`routes/api.php:111-117` → `MatchController.php::current:650/confirm:718/history:819`；current需要问卷资格与released match，confirm写like_a/like_b，互相like发通知/进入chat的提示，**不等于Connection授权**。
- `MatchingRunService`有prepare/claim/heartbeat/finalize持久化；`app/Console/Commands/ExecutePendingMatchingRunCommand.php:17-57`有 `app:matching:execute-pending --once` consumer，不是只有任务stub。`config/matching.php:4-12`默认关闭execution等开关；`MatchingEngineService::buildPairs`、`PersonalityProfileService::buildForUser`及 `ProfileReadinessService::eligibleUsersQuery`有业务链，现场任务调度/输出均NOT_RUN。
- `ProfileReadinessService.php:14-40`排除disabled和is_synthetic账号、要求答案数量/启用题。0.6三个虚构账号实际标 `is_synthetic=true`（`V1006DevelopmentSeeder.php:25/41`），不能拿它们自动作真实consumer候选，更不能翻改原验收数据。建议新隔离恢复库内创建标注为开发虚构、但可进入本地资格计算的具名账号，严格守住local数据库/环境边界。
- Flutter `features/connection/presentation/providers/connection_presentation_provider.dart:6-50`在普通态无真实writer，主要为本地合同/synthetic。已有 `app/Domain/ProductConnectionStateTransitionEvaluator.php` 与 `ProductConnectionPersistenceApplicationAdapter.php`可复用合同，但后者接口明确evaluate*Synthetic且authority字段为false，**不是live持久writer已接通**。
- `RelationshipController.php::store:42-72`仅追加event_type/status至 `UserRelationshipEvent`；不构成校验双方、合法转移、当前revision的Connection状态机。Relationship依旧是后续独立阶段，不用关系日志代替Connection/消息同意。

### A06：聊天、消息、媒体、RTC

- `routes/api.php:121-132/185-188`七条peer/conversations/messages读写已挂 `DenyUnverifiedMessagingLiveAccess.php:9-15`，固定404。底层已有真实消息/会话业务；其用例有绕过该middleware的内部验证，不能证明HTTP恢复。`messages/ws`另为501/503的stub/能力响应，不是现成可用WS。
- `ConversationCapabilityService.php:15-87`主要查released DatingMatch、block、membership/departed/synthetic；未完整要求Connection及消息同意。RTC `RtcSessionService::canCall`同样不能仅靠released match判合法。直接删除404门会放大权限，正式恢复必须接入当前双方状态及使用点的权限判断。
- 同意合同**已经有代码**：`app/Domain/MessagingConsentConversationLiveGateEvaluator.php`（MC_NONE/PENDING/ACTIVE/DECLINED/WITHDRAWN/REVOKED及LIVE_READ/SEND，evaluateLiveGates）；`app/EliteSync/ConversationQualification/ConversationUsePointQualifier.php`、synthetic persistence/use-point及相关测试。当前固定HTTP门未注入它们。推荐复用已接受语义，补live writer、DB读回、参与者/预期revision/撤销传播及逐使用点授权，不重造或合并阶段。
- 核心完成顺序是 Match → 独立Connection → 独立Messaging Consent → Conversation及每次消息使用点；单边like、单方Connection请求、未给消息同意、stale/revoked/blocked/disabled均不得获得读发或媒体/RTC权限。
- 图片/语音/视频需分别核上传、所属账号、processing/readiness、消息附件、下载授权。现有media表/jobs和服务可复用，不把file upload成功当作聊天附件可用；具名路径及外部依赖补充见本节附录。
- RTC客户端已有LiveKit接入，后端token需要真实SFU URL/key/secret；0.6不包含该服务。AVD单端不等于双端音视频传输已证。需正式计划选择受控本地SFU或具名服务和第二端、最小麦克风/摄像头权限及费用上限；本次未安装、启动、取token或外联。

### A07：MBTI、八字、紫微、西占和解释

| 能力 | 当前与旧源码实际事实 | 可行性与完成限制 |
|---|---|---|
| MBTI | `MbtiProfileController.php:42/71/119/207`有quiz、score、attempt与users.public_mbti事务写入；config/mbti.php有Lite3/5题。旧仓同名业务存在。`config/features.php:4-5`默认关闭，Flutter `mbti_center_page.dart:20-45`明确“2.5关闭”，matching.php及MatchingEngineService把人格/MBTI权重关掉。 | 属已有业务但UI/配置关闭，不能只开开关算恢复；正式计划需明确恢复测评展示是否保持不参与排序，不能自动改变匹配权重。可选评估而非资格强制，结果非客观人格真值。 |
| 八字 | `BaziCanonicalService`选择lunar/legacy；`LunarPhpBaziEngine.php:12/30-48`实际调用6tail/lunar-php计算四柱、五行、大运/流年，缺输入/异常明确fallback；当前vendor中Solar.php实在，composer依锁。`ProfileController.php:44-149`重算并存UserAstroProfile/users镜像。 | 首选现有本地实现，正式版需已知日期/跨日、时区/真太阳时、缺坐标反例和APP/API/DB同源。存在实现不等于本轮计算已运行，更不证明预测有效。出生位置处理在BirthLocationSolarTimeService:55-99为经度/均时差估计，固定Shanghai假设须标明。 |
| 紫微 | `ZiweiCanonicalService.php:160/234`默认seed估计及具名样例，标not_validated/display_only/excluded_from_core_matching。`:310`有iztro shadow/local/app_visible路径；config/ziwei.php默认off，runner.mjs与package-lock存在，iztro2.5.8实际node_modules未装。 | 默认seed不是真正完整排盘。现有local候选可在正式授权后安装固定依赖/核许可证并验证非样例随机输入、子时跨日/闰月/时区；保持外部oracle/评分限制。飞星等字段明确not_implemented，不能从fixture扩称完整原功能。 |
| 西占 | `LegacyInputWesternNatalEngine.php:17/36-42`太阳历法＋CRC seed月亮/上升；AppServiceProvider.php:38-56始终legacy，即使选择高精度名字也没有PHP高精度实现。AstroProfileController.php:252/292/330经PythonAstroRenderService调用pair/transit/return，缺服务503。当前仅Laravel services，没有旧services/api。 | 旧 `services/api/app/services/astro.py`真实调用Kerykeion5.12.7实现本命/合盘/行运/返照，提供timezone/coordinates/engine provenance；旧 `routers/astro.py:148-208`有无DB的计算接口。可具名恢复为受控loopback计算服务，不整体导入旧认证/业务DB。当前API默认8002，但该服务未运行/未进入树。 |
| 解释 | MbtiCompatibilityService、AstroCompatibilityService及MatchingEngineService存在规则、分量与模板，不只是文本占位。StandardAstroEngineAdapter/StandardWesternCompatibilityEngine明确standard_stub_v1；紫微种子排盘不应参与核心评分。 | 建议原规则解释随真实服务结果复用，保留缺资料/降级/来源/置信度，核API、匹配记录和APP显示一致。当前未找到需要LLM才能完成该规则链的依据；不自动启动付费AI或发送出生数据。高级AI解释/商业精度认证未获授权。 |

西占许可/运行边界是具体已有门：`config/astrology_dependency_gate.php`对Swiss/pyswisseph/Kerykeion默认blocked，`AstrologyDependencyGateService`研究模式也不能被当作本次已批准；Python HTTP路径也不能绕开该项目许可政策。正式plan须具名批准使用范围/许可路线，并保留生产门。旧astro.py以online=False计算；用户手动输入日期/坐标可避免新地理服务，但缺坐标不得用默认地名冒称真实宫位。地图/SMS等第三方能力另外处理，不作为所有本地功能的阻塞。

### A08：社交、搭子、状态、通知、设置

已核当前Buddy候选 `_mockCandidates`、本地草稿/举报，SocialBaselinePage为静态流；具名旧Flutter同样为mock/静态，不能算原真实双端业务已实现。该源码范围内搭子真实候选、服务器发布/搜索/举报闭环属于**缺业务实现**；其它未读原版变体仍UNKNOWN，不据此替Owner排除整个搭子/社交目标。

StatusPost有API/DB及Flutter远端链，失败时StatusMock回退必须在恢复合同里明确测试并停止冒充真成功。Notification有站内列表/未读/已读持久化，系统push和跨设备设置同步未发现完整供应商链；Settings中的push/performance本地持久化不等于服务端投递配置。具体入口与依赖见附录。推荐优先恢复已有动态/站内通知/本地设置真实链，Buddy/Social需Owner确认是否将占位产品扩为完整新实现或指定其它旧实现作为恢复来源；不是按旧Later排除。

## C. 推荐冻结组合与AC

附录：A06/A08具名入口（均在产品固定commit `78aba03a...`）

| 子功能 | 前端、后端与存储证据 | 实际缺口 |
|---|---|---|
| 聊天/附件 | `features/chat/data/gateway/chat_media_gateway.dart`→`/api/v1/media`；`MessageController.php:101/176/228`、`MediaController.php`、`MediaAssetService::registerUploaded`；conversations/conversation_members/chat_messages/media_assets/media_processing_jobs/message_attachments迁移（2026_03_12与2026_04_18批） | 实际处理worker、附件可用状态和授权下载需新计划验证；MessageApiTest.php:33绕过消息middleware。Profile的`profile_header.dart`仍固定头像图标，provider有avatarUrl映射并不代表头像上传/用户记录接通。 |
| RTC | `features/rtc/presentation/providers/rtc_providers.dart`、`domain/services/rtc_livekit_service.dart`；`RtcController`、`RtcSessionService.php:41-60`、`LiveKitTokenService`与`config/livekit.php` | 默认useLiveKitRtc=false；缺运行服务/第二端，未接独立同意。麦克风/摄像头按冻结通话类型授权；token或session状态不证明媒体传输。 |
| 状态 | `features/status/data/datasource/status_remote_data_source.dart`；`StatusPostController.php:220/253/322/397/474/521`；`2026_04_09_130000_create_status_posts_table.php`及like/cover/report关联迁移 | 真实publish/like/report/delete需APP+DB证明；读取失败的mock回退不得伪装服务成功。 |
| 通知 | `features/notification/data/datasource/notification_remote_data_source.dart`；`NotificationController`、`NotificationService`；`2026_04_18_000060_create_notifications_table.php` | 站内链可恢复；FCM/APNs设备注册、发送/偏好服务未证明。 |
| 设置 | `features/profile/presentation/pages/settings_page.dart`、`privacy_settings_page.dart`与LocalStorageService | push/performance/content排序是本机偏好；不宣称服务端设置同步、真实系统push或所有privacy切换均有后端效果。 |
| 搭子/社交 | `features/buddy/presentation/pages/buddy_companion_page.dart:72/233/609/929`、`features/social/presentation/pages/social_baseline_page.dart` | 当前及旧具名页mock/静态。旧Android的具名ApiService缺对应Buddy/Social接口，仅此范围内结论，不覆盖其它旧变体。 |
| 地图 | 旧Android `apps/android/app/src/main/java/com/elitesync/repo/AppRepository.kt::searchPlaces/reverseGeocode`及`network/BaiduMapApiService.kt` | Baidu LBS SDK/HTTP与BuildConfig.BAIDU_MAP_AK；当前0.6本地宿主禁止Baidu bootstrap，Buddy地点为本地文本。未读key/配额或外联；手工坐标可用于本地出生输入但不冒称地图恢复。 |

**推荐0.7一个跨端功能包**：A04完整资料/真实题库答卷与恢复；A05真实consumer/round结果、发布、用户读取和双方兴趣表达；复用既定合同补Connection与Messaging Consent持久writer；A06合法文本聊天和现有本地媒体闭环；A07现有八字与规则解释，MBTI测评展示/iztro本地候选按下节明确决定纳入；A08既有动态、站内通知及设置。允许Flutter/Android/Laravel/迁移/任务/测试一起修改，不拆环境版或单文件小版。

这已经包含三条相互依赖的真实链和缺失live consent接线。完整RTC SFU/第二端、Python西占服务/许可、以及Buddy/Social从静态补业务，均是可独立显著增加工程量的能力。**建议**：若相应选择不能在0.7冻结前明确，将RTC＋完整西占＋确认需新增的Buddy/Social具名放入0.8用户恢复并行包，0.8原Web管理目标仍保留；0.9做所有包联合重启/权限/失败验证，0.10交付完整材料。此为推荐路线调整，须Owner/Astra批准，不能自行减项或默认视为已后置；若Owner要求全部0.7纳入，应扩大正式plan到上述服务/数据/第二端范围并按功能链排序实现，不以假输出压缩工程量。工期/额度未实测，不报完成百分比。

建议AC（不是已冻结验收标准）：

| AC | 可观察完成标准 |
|---|---|
| 07-01 固定来源/隔离 | 固定集成源码commit/tree与具名题库/算法来源；新恢复库/volume、开发虚构账号、媒体目录与旧0.6卷隔离，真实服务而非mock；依锁和端口/资源归属可核。 |
| 07-02 账户资料问卷 | APP注册/指定开发登录、编辑完整资料、载入固定题库、答卷保存/续答/历史读回；API与DB同ID及版本/答案一致；无效答案/越权/禁用拒绝；重进、重登及服务/DB重启保持，原city/ban回归。建议正式plan限定为开发密码，不默认真实SMS。 |
| 07-03 匹配真实消费 | 具名资格账号→prepare→consumer claim/execute/finalize→reveal→APP current/history/explanation同一结果；零题/不完整/禁用/未发布拒绝；重复执行不产生重复配对，失败/lease恢复路径有证据。Match不授予Connection/私信。 |
| 07-04 独立同意与权限 | 双方Connection请求/接受、单方拒绝/撤回按既定合同持久化；Messaging Consent另行处理；第三人、单边意向、未知/stale/revoked状态、block/disabled读发/RTC均拒绝；Relationship日志不能替代前阶段。 |
| 07-05 合法聊天媒体 | 已获双阶段授权的双方APP实际读发/列表/未读/已读、重发幂等和重启读回；图片/语音等冻结类型经实际upload→processing→attachment→授权读取，不默认成功；撤销后旧请求/下载被拒。按7条路由逐一验证合法成功与否定例，保留内容保护及密钥隔离。HTTP轮询可作为正式具名实现选择，不能声称已有WS；WS若要求则实测consumer/transport。 |
| 07-06 算法来源/输出 | 对正式冻结纳入的模块适用：APP出生资料/测评→服务实际输出→profile/attempt持久化→重启读回；每模块engine/version/input signature/fallback/限制可见。八字独立样例；紫微若纳入，验证非fixture输入与跨日政策；西占若纳入，验证真实服务/坐标/时区/precision。无法满足或未纳入的模块具名单列缺口，seed或503不算完整恢复。未验证输出不得擅入核心评分。 |
| 07-07 动态通知设置 | APP实际状态发布/读回/冻结交互→DB→重启、删除/举报/越权反例；任务通知由实际匹配/授权事件触发，站内已读持久化；用户设置作用于已定义功能，通知关闭不得谎称系统push已配置。 |
| 07-08 安装与交付 | 与最终源一致AAR/APK，相关自动回归＋真实APP/HTTP/DB/重启及截图安全证据，明确原失败、修复后结果、未运行模块；不靠API单独成功或mock投影满足APP AC。原受保护资产和0.6原证不动。 |

RTC若纳入，加具名两端同房间实际音频/视频、拒接/挂断/超时、未同意/第三人/撤销后token拒绝；地图若纳入，加具名供应商/虚构地址权限正反例。不能用token签发/SDK导入代替媒体传输。

## D. 少数实质决定与环境权限建议

1. **恢复组合/原版选择**：推荐以上0.7主链；确认是否要求RTC、完整西占及Buddy/Social真业务同版。旧已核源码中的Buddy/Social为占位，需指定其它已实现来源或明确批准新业务，而不是让Codex猜原版功能。
2. **MBTI与算法标准**：推荐恢复可选测评展示但继续不用于匹配排序，保留人格非客观真值限制；是否恢复其排序影响须单独明确。紫微是否按现有iztro候选＋未校验声明恢复，还是要求外部校验准确排盘；西占是否批准具名Kerykeion loopback计算/许可路线，不能称商业高精度已接受。八字可先用现有依锁本地链。
3. **RTC/地图/系统push**：RTC选择受控本地LiveKit SFU或具体服务（费用上限、凭据用途/第二端）；地图选择现有供应商或手工坐标，系统push是否是本轮必需。推荐先不产生真实费用、不调用真实SMS，不发送真实个人信息。这些只影响对应功能，不阻断资料/问卷/匹配/站内通知。

建议正式plan一次授权：复用现有Flutter/JDK/Android SDK/AVD及Docker MariaDB镜像与锁缓存；**另建**具名0.7 DB/container/volume和媒体区，避免覆盖原0.6验收卷，端口冻结前核可用性；Laravel loopback/现有转发器；新的local虚构资格账号；有限matching consumer、消息/媒体本地worker和具体端口；需要的固定依赖补齐。若算法/RTC纳入，再具名8002计算服务/Node iztro、SFU/WS/第二端和相关最小权限。不改全局SDK/代理，不解冻原3306、SQL/VHDX、生产或原真实账号。

## E. 剩余风险与未运行

题库seed输入、live同意writer与七条HTTP授权、media worker、RTC/SFU及高精度算法是实质接通工作；旧域合同通过不等于live业务已经有作者/消费者。问卷评分和玄学解释是程序输出，不证明心理/预测有效。正常APP logout全服务token撤销未由0.6证明；API/Web管理员互禁策略差异留管理包。没有读取或恢复历史业务数据/媒体附件，原版完整包可运行边界仍未全量证实。

本次未运行0.7 APP页面、任何consumer、算法、消息、media、RTC、地图、push、性能或全APP测试；未安装iztro/Python/SFU，未创建新DB、新账号、媒体资产或启动外部服务。现有自动测试仅作为后续可复用线索（AuthQuestionnaireApiTest、MatchingFoundationServiceTest/MatchingTruthSliceIntegratedSmokeTest、MessagingConsentConversationLiveGateEvaluatorTest、MediaProcessingPipelineTest、StatusPostApiTest、NotificationApiTest、AstroCanonicalApiTest/MbtiApiVersioningTest及Ziwei测试），不称本轮PASS。

终点保持 **K08_INTEGRATION_COMPLETE / V10_0_7_FEASIBILITY_READY**。等待Astra/Owner冻结具名正式plan并由Owner手动派发；不自行冻结、实现0.7或启动0.8。

## 具名旧来源校验索引

旧HEAD `0f06e895a89629a7f4f0cf0c62b784446ecf515a`，下列HEAD Blob＝工作hash-object：

| 旧仓相对路径 | Blob |
|---|---|
| question_bank/question_bank_core_v1.json | `02611e93fcb50cbe35126381cc4a79b178b2d423` |
| question_bank/question_bank_extended_v1.json | `d18a585139e7b179c670f84e9ca1f8734fa0398b` |
| question_bank/question_bank_research_v1.json | `086cceddba59704b0085e21d7e3fead8a01f7495` |
| question_bank/question_bank_docx_scored_v2.json | `6d3fb19242734dd6938979f3846e9837518be175` |
| dating_question_bank_v_1.json | `34817351b92c5b9cf1f7e363af52541f1e76aa22` |
| services/api/app/services/astro.py | `0a10c0a1cfcf7d7a5bf52e13cd4e676277d75c1c` |
| services/api/app/routers/astro.py | `9017f55d5470df65a25ab33624017b2ffc1f7405` |
| services/api/requirements.txt | `bbd43d98c799811014f3fa9d1b1f08257c6432bc` |
| services/backend-laravel/app/Services/LunarPhpBaziEngine.php | `3931d10d1560c5198690d33a720813fe98b17400` |
| services/backend-laravel/app/Services/ZiweiCanonicalService.php | `47f2cbd1f914f8bbb7424b25b44b6b45cf6d4099` |
| services/backend-laravel/app/Http/Controllers/Api/V1/MbtiProfileController.php | `eb15ba15f0bfdce5b50369dcf8672632f0a70af0` |
| apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart | `572739aa2fa834ed97ac4a1b3ddfef89448f48ed` |
| apps/flutter_elitesync_module/lib/features/buddy/presentation/pages/buddy_companion_page.dart | `24f802a8d341787aef800e81fb9961020e5937a5` |
| apps/flutter_elitesync_module/lib/features/social/presentation/pages/social_baseline_page.dart | `5f9efca478c3a603ecc2fd1521d13dfa5fcb8ef6` |
| apps/android/app/src/main/java/com/elitesync/repo/AppRepository.kt | `ee1383212c6312ac968cc7621f308368c7cae168` |
| apps/android/app/src/main/java/com/elitesync/network/ApiService.kt | `1bd42111a6ed85688e38be3396d67ec131945297` |
| apps/android/app/src/main/java/com/elitesync/network/BaiduMapApiService.kt | `9ce65ed26b48e736c6cdb7ad506734fe65c4bac7` |
