# v10.0.9 一次性版前可行性与冻结建议

2026-10-15。**FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED**。本报告只交付具名源码调查及推荐，不是正式plan、环境授权或验收结论。

## 1. 结论与固定依据

推荐下一功能版交付 **RTC双端语音/视频及当前权限撤销闭环＋已有视频选择入口对应的私有短视频附件链＋已接受图片链的定点回归**。语音消息未在本次具名旧聊天入口证实，不能冒称已实现待接通；如要加入录音消息，须Owner明确批准该补建范围。完整紫微/西占、Buddy/Social及其它欠账保留在完整内测前收口，不能因本版优先RTC而删除。

本地受控LiveKit有可行部署路线，但**当前源码不能直接安全启用**：RTC没有复用当前CN/MC权限；自托管SFU移除参与者不会撤销其旧JWT；视频模式目前主要为预留界面。冻结必须覆盖这些实际实现差异，不能只开配置或签token就交付。

| 身份 | 本轮实际核对 |
|---|---|
| GitHub main | `82bb35b90e238431b058de70c2c2a86164af4143`，已fetch及再次ls-remote一致 |
| 产品技术起点 | `3a8f7989aa208285b885f1c80f4365f38488ac54`，Tree `95fadde468d8a21b39c544fdb74093dd35184717` |
| 唯一版前提案 | `8847624120aab5de0ac90e05c7e80ea53c65f2d6:docs/versions/v10.0.9/PLAN_PROPOSAL_V0_1.md`；Blob `fbb060fc9a4b79a9e7075809e961a9d258455f83`，已读全文与核对象 |
| 当前入口 | main的CURRENT_STATE、CURRENT_WORKFLOW、PRODUCT_DECISIONS、现行路线图及单份RESTORATION_CAPABILITY_MATRIX已读；D1/D2/D3继续有效 |
| main相对技术起点 | 仅CURRENT_STATE、DOC_INDEX_CURRENT、versions/README及0.9提案文档变化；apps/services/question_bank无差异 |
| 专用工作树 | `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`；复用，文档分支`codex/v10.0.9-feasibility`从实际main接续 |

下文当前源码事实统一固定在上述技术起点，目录缩写：`B=services/backend-laravel`，`F=apps/flutter_elitesync_module`。引用行号供定位，固定commit与完整路径共同构成证据。旧源码只读`D:/EliteSync`的固定commit `0f06e895a89629a7f4f0cf0c62b784446ecf515a`具名Git对象，不把旧仓版本当成现行架构或原APP完整运行证明。专用基线没有适用的现成代码图谱，本轮使用固定Git对象、具名文件和rg，不重建全仓图谱。

v10.0.6～0.8的限定接受/K08不重开；原始失败不改写。本轮没有产品运行结论。

## 2. RTC：已有实现与具体缺口

### 2.1 APP与原版来源

| 层 | 源码证据 | 可以确认／不能确认 |
|---|---|---|
| Flutter客户端 | F/lib/features/rtc/domain/services/rtc_livekit_service.dart:126、539、698、720、762 | 有真实LiveKit连接、音轨发布/订阅、播放、RTP诊断、5秒心跳和离房代码；没有摄像头发布或实际视频渲染链的同等实现 |
| 用户页面 | F/lib/features/rtc/presentation/pages/rtc_call_page.dart:132、219；rtc_incoming_call_page.dart、rtc_permission_page.dart | 有呼叫、来电和结果状态页面；video显示“视频预留”，不能称原视频通话已实现 |
| 权限/宿主 | F/lib/features/rtc/domain/services/rtc_permission_service.dart:5–45；apps/android/app/src/main/AndroidManifest.xml:3–10 | 运行时只请求麦克风；宿主声明网络、麦克风、摄像头。声明CAMERA不等于运行时授权/捕获/传输已完成；音频路由、拒绝权限及视频权限须真机/AVD验证 |
| 配置 | B/config/livekit.php:4–8；F/lib/app/config/app_env.dart:9；F/lib/main_prod.dart:123 | 后端默认off、TTL默认600秒；AppEnv默认false，但main_prod实际为`useLiveKitRtc: !restoration`，已接受restoration构建关闭RTC。不可笼统说所有构建都关闭 |
| 旧源码对照 | 旧RTC service Blob `5b6bacacba2860c1ef6349e9aacc068cf859b22d`；当前 `ec34e5e0c7264f7d9534f1306d430007660da82a` | 旧文件也有room.connect与setMicrophoneEnabled，旧rtc_call_page同样“视频预留”；支持原语音实现来源，未证明旧版真实两端已通或视频已完成 |

服务端旧源与当前的RtcSessionService Blob均为`c2492f6597a7883ad41723e64853195403318978`，LiveKitTokenService均为`e004d4ac3e05f98251d70447b93b9da8db578231`。说明当前仍继承这两份旧实现，而非已接入0.7/0.8权限的新RTC闭环。

### 2.2 当前服务端权限与状态

| 使用点 | 实际检查与风险 |
|---|---|
| create | B/app/Services/RtcSessionService.php:41–60、91–118：只校验ID、双向block、released Match；没有当前CN/MC、restrict、双方disabled、具名开发环境门。room_key仅为排序后用户ID对，跨通话复用 |
| accept/connect | 同文件:160–202：participant、callee、非terminal检查；没有重新验证CN/MC/双方处罚。connect不要求严格accepted状态，旧状态转换和并发需补约束 |
| heartbeat/show/list | 同文件:63–88、204–225、271–411：参与者查询、心跳与超时；没有当前隐私授权门。30秒来电/断线超时靠访问触发刷新，不是服务端持续撤权机制 |
| JWT | B/app/Http/Controllers/Api/V1/RtcController.php:150起livekit方法：先findForUser；B/app/Services/LiveKitTokenService.php:13–70：配置有效即可签roomJoin/publish/subscribe JWT；不校验accepted/terminal、CN/MC、处罚或最新block，亦未先refreshExpiredSession |
| end/revoke | RtcSessionService.php:250–268只更新DB、事件、通知；未调用SFU移除参与者/关闭房间。应用token撤销不是SFU JWT撤销 |
| 路由 | B/routes/api.php:82、162–181：RTC在auth:sanctum组，未附account.active或消息live gate。正常共享禁用会撤token，但这不覆盖对端禁用、已签JWT、已建立SFU媒体或所有可信身份注入场景 |
| 邀请隐私 | RtcSessionService.php:144、437–456保存来电者名字/导航；NotificationService.php:18–29的R1投影只识别私信通知，不涵盖rtc_call_invite。RTC恢复需连同来电列表/通知当前授权最小化，保留已有R1消息保护 |

可复用权威为B/app/Services/LiveConsentService.php:16–28、32–60、110–141：本地精确DB/端口门、双账号/block、独立product_connections与messaging_consents及revision、restrict拒绝新的live_send。**RTC应增加实时互动用途判断，不能拿历史live_read_allowed作为呼叫授权，也不能把Match当Connection。** D1资格变化不自动撤销历史CN/MC；D2 restrict即使保留历史只读，也必须拒绝新的RTC收发。

现有B/tests/Feature/RtcApiTest.php:26–106、150–211以released Match fixture验证状态流、签token和非参与者拒绝；B/tests/Unit/LiveKitTokenServiceTest.php验证签名合同。均不证明真实媒体、当前CN/MC或撤权有效，本轮未运行。

### 2.3 JWT与撤权的推荐方案

当前TTL为`max(60, configured TTL)`，默认600秒；没有上限、通话epoch或服务端JWT拒绝表。用户ID对复用房间及稳定identity扩大旧token跨通话风险。客户端心跳错误只记录，只有收到terminal才主动离房，不能信任客户端完成强制断开；`_maskToken`还会对长度≤16的异常token原样返回，未来应完全移除token日志而非依赖遮盖。

LiveKit官方说明：JWT过期主要影响首次连接，服务端可向已连接客户端刷新token；**self-hosted移除参与者或改权限不会使旧token失效**。因此短TTL、DeleteRoom、客户端leave或拒发新JWT各自都不能证明撤权后立即不能重入。

推荐冻结以下同一RTC功能内的实现责任：

1. 用事务锁与当前CN/MC revision校验create/accept/connect/join/renew/heartbeat；每次独立通话使用不可复用的随机room/epoch，token绑定call、participant、mode和授权revision，最小音/视频track grant。来电接受仍是独立动作，不由MC自动接听。
2. 本地SFU所有客户端信令入口通过**可验证的入房授权边界**；新连及重连均核当前DB、call epoch和terminal。可采用受控信令反向代理＋Laravel内部授权检查，SFU原始信令端口仅内部可达；既有刷新token也不能绕过检查。非纯“只代理发token”方案。需在正式实施中验证所锁定SDK/SFU的所有WS/重连路径，未知或DB不可用拒绝入房。
3. end、CN/MC撤销、block、restrict、disabled的共享服务产生持久失效事件，停止签发并使call terminal，服务端调用SFU移除双方/关闭房间，失败进入有限重试及审计；worker故障期间不得继续发放授权。对已入房媒体明确最大断开时限，建议AC要求提交撤权后≤5秒内双端停止有效媒体、立即拒绝其后新join；此数值是待冻结目标，本轮没有性能实测。
4. 不可仅靠入房代理保证已建立媒体中断，必须同时做第3项SFU控制及失败处置。若锁定版本无法证明“撤权后缓存/自动刷新JWT不得重入”，该AC不能降成“等TTL后拒绝”，应在同版修复授权边界或向Owner报告具体设施阻塞。不要将Cloud-only token revocation误用为本地已有能力。

这些是必要安全实施差异，并非本轮已搭建的新通知架构或全局服务改造。

## 3. 本地SFU、第二端和最小授权

受控本地部署**技术可行、尚未运行证明**。优先现有Windows/Docker能力运行官方LiveKit单节点，正式计划固定release/digest及许可证清单，不用latest或公开dev凭据。官方server当前许可证Apache-2.0允许按条款使用；最终镜像、SDK、编解码及传递依赖仍须对所锁版本核NOTICE/许可，不能把server许可代替全栈核验。不需要LiveKit Cloud账号或付费API，不录制真实个人音视频。当前pubspec.lock实际锁定livekit_client 2.10.0、flutter_webrtc 1.6.0，不以pubspec的范围表达代替锁版本。本轮只读GitHub release元数据得到官方server候选[v1.13.10](https://github.com/livekit/livekit/releases/tag/v1.13.10)；未拉取镜像、未核digest或与现有SDK兼容性。建议正式plan锁此候选及实际digest后做C1～C4兼容验证，不自动升级Flutter依赖。

| 项目 | 建议正式冻结环境；本轮均未创建/启动 |
|---|---|
| 数据/媒体 | 新`elitesync_v1009_dev`、`elitesync-v1009-db`、volume`elitesync-v1009-db-data`，建议loopback43319（未探测可用性）；独立私有媒体目录及队列。0.6/0.7/0.8卷原样保留 |
| 后端/任务 | 复用Laravel与锁依赖、Blade管理员/同库虚构双人及无权对照；localhost HTTP、database queue、具名RTC失效及媒体worker。仅正式授权后扩展精确DB/port live门，生产和未知环境继续拒绝 |
| 两个真实客户端 | 首选两台专用AVD运行最终同源Android包、两个独立虚构账号。若已有AVD的麦克风/摄像头模拟能力不足，改为AVD＋Owner指定无真实账号的测试Android设备；不wipe个人设备、不用脚本token客户端代替第二APP |
| 媒体输入 | 可辨认的虚构测试音/视频，验证双向收发、静音/摄像头开关、拒绝权限。AVD合成摄像头只证明可传输测试帧，不证明真实硬件摄像头质量；真机指标另记未验 |
| 信令 | 对客户端开放受控授权入口；SFU API/原始WS通常7880仅内部/loopback，不能留下绕过授权代理的第二入口。API与WS经ADB reverse可辅助HTTP，但ADB reverse不解决UDP/ICE媒体 |
| ICE媒体 | 按官方配置二选一：UDP Mux 7882，或默认UDP50000–60000范围（每参与者两端口）；推荐本地单节点Mux最小暴露。TCP7881作回退，须分别验证，不因WS成功推定媒体畅通 |
| 地址/防火墙 | AVD到宿主地址与Docker NAT广告candidate必须可达，127.0.0.1不是另一设备的宿主。正式计划限定绑定网卡、来源设备IP及生命周期，不开公网；本轮未探测/改防火墙或端口 |
| ICE/TURN | 同宿主可达候选先测直连SFU，不预设必须TURN。跨NAT/UDP受阻才选择受控TURN；可选3478/UDP，TURN/TLS5349或部署要求的443需证书/域名/许可及额外授权。没有TURN测试不能声称跨任意网络可用 |

官方依据（2026-10-15只读）：[端口/防火墙](https://docs.livekit.io/transport/self-hosting/ports-firewall/)、[本地运行](https://docs.livekit.io/transport/self-hosting/local/)、[token生命周期及self-hosted限制](https://docs.livekit.io/frontends/reference/tokens-grants/)、[server许可](https://github.com/livekit/livekit/blob/master/LICENSE)。文档会变化，实施时应与锁定版本核对。这里的端口是方案，未获开端口授权；不引用或发布任何本机密钥。

## 4. 媒体逐项状态及同版推荐

| 能力 | 当前/旧具名证据 | 真实状态与缺口 |
|---|---|---|
| 私聊图片 | F/lib/features/chat/data/gateway/chat_media_gateway.dart:1–146；B/app/Http/Controllers/Api/V1/MediaController.php:33–63、121–188；docs/versions/v10.0.7/EXECUTION_REPORT.md:53–59 | 0.7已验APP picker→上传→message附件→对端授权读取→DB重启，非参与者及撤权拒绝。属于历史接受证据，本轮没有重跑 |
| 视频附件 | 同gateway的image/video枚举、pickVideo；旧同路径Blob `a9c87a7372a0c161204c05b55bac01fc850e0131`:6、61–67同样存在 | 原版有真实picker/上传代码，但当前live MediaController只允许image≤5MB。不能称整条原视频业务已通；推荐0.9明确选定MP4/H.264＋AAC短视频上传、元数据/缩略图、消息绑定、播放及撤权链，格式/大小/时长在plan冻结 |
| 语音消息 | B/app/Services/MediaAssetService.php:165–179可分类audio；config/media.php:8–12默认image/video | 未在该具名旧/现聊天gateway发现录音或音频picker；audio分类不是实际语音消息实现。其它未查来源仍UNKNOWN，不推断全仓绝不存在。默认不作为“已实现原媒体”纳入推荐AC；Owner若要求录音消息，应明确批准补建与录音/播放依赖 |
| 处理任务 | B/app/Jobs/ProcessMediaAssetJob.php:27–86；B/app/Console/Commands/MediaProcessQueueCommand.php:8–72 | 当前校验MIME、推进processing/ready与缓存，queue command自称skeleton；没有实际音视频转码/缩略图。不能将ready当已编码/可播证明 |
| 消息关联 | B/app/Services/ConversationAtomicSendService.php:57、168、229、273；B/app/Models/MessageAttachment.php:15–36 | 复用原子发送、可信asset关联、附件权限；新类型必须校验归属/ready及当前live_send，不允许任意URL/storage_key注入 |
| 私有读取 | MediaController.php:121–188；LiveConsentService.php:110–141 | 现有v1007私有disk分支按账号、附件及当前live_read允许读取，private/no-store/nosniff；旧public分支不能作为新私有视频合同。Range、缩略图、下载及播放均要复核当前权限 |
| 展示占位 | F/lib/features/chat/presentation/widgets/attachment_upload_card.dart:42–48、135–169；message_attachment_shelf.dart | “图片附件”卡包含手动状态chip，不能用该展示状态替代真实上传/worker结果。新视频应接实际状态和错误，不复制演示控件作为完成证据 |

推荐图片不重建；视频采用受控格式，优先复用已有选择/上传入口和设备可播放格式，不默认引入全格式转码系统。正式实施若采用ffprobe/ffmpeg、额外播放器/thumbnail插件，应先列已可用锁定工具及其具体构建许可证/编解码范围；本轮未探测工具安装状态，不能默认许可完备或允许系统安装。若必须新引入工具，随正式plan一次具名批准，拒绝付费/全局安装。处理失败、伪MIME、超限、取消、重复提交、跨用户asset及撤权后的Range请求都需可观察拒绝。0.7消息通知R1最小化继续复用，不把附件URL和私密摘要放到站内通知。

## 5. 紫微与西占：计算、oracle和许可分开

| 维度 | 紫微 | 西占 |
|---|---|---|
| 当前实际计算 | B/app/Services/ZiweiCanonicalService.php:160–203以生日/时刻/locationShift及`crc32(position_signature)`参与seed并旋转星曜；234–240明确approximate_not_validated；761–823 fallback也是seed | B/app/Services/LegacyInputWesternNatalEngine.php:17–78日期取太阳星座，月亮/上升以时间/坐标CRC seed取模；不是天文星历 |
| 可用引擎候选 | tools/ziwei/iztro-runner/package.json固定iztro2.5.8；ZiweiCanonicalService.php:534–594现适配只14主星严格子集，自标oracle未验证；默认config/ziwei.php:4–15 off，可fail-open | 现provider没有实现高精engine，AppServiceProvider.php:38–56即使选非legacy也可能回落legacy；旧Python `services/api/app/services/astro.py`具名Blob `0a10c0a1cfcf7d7a5bf52e13cd4e676277d75c1c`有Kerykeion工厂及真实计算调用线索，不在当前Laravel运行链 |
| 输入 | B/app/Support/Ziwei/ZiweiInputPolicy.php:14–49指出民用出生日期/时间、性别、时区、经纬度/地点及边界契约尚未完整 | 旧Python Blob:441–475元数据含时区/经纬/引擎/SHA256输入签名，527–541以online=False构造subject，旧构造器有Asia/Shanghai默认值；建议冻结时要求日期/时刻/坐标和IANA timezone明确，不能把地名猜测作为确定坐标 |
| 业务范围 | 当前种子/14主星适配不能冒完整排盘；辅星、四化、飞星、强弱等未闭环 | 旧Blob:20、129、202、277、307有本命、synastry/comparison、transit、return调用；当前AstroProfileController.php:259–360有接口合同，服务缺失可503，不证明计算可用 |
| 非fixture oracle | 未取得通用可信oracle。tests/Unit/ZiweiOracleFixtureHarnessTest.php:13–30、88–135仅有限fixture A；B/C明确oracle gap且禁止作为产品输出。iztro自身输出不是独立oracle | 本轮未取得与锁定引擎独立的精确星体/宫位/相位oracle；旧调用、接口测试、同引擎快照均不算独立正确性证明 |
| 许可 | 上游iztro **2.5.8** LICENSE为MIT，允许按条款闭源复用并保留版权/许可；这不证明所有传递依赖/资料许可都已核，也不证明排盘正确 | config/astrology_dependency_gate.php:8–23将Swiss/pyswisseph/Kerykeion默认blocked；上游Kerykeion **v5.12.7** LICENSE实读为AGPL-3.0。未来闭源整体是否合规不能直接宣称；须选定依赖组合、分发/网络方式及商业授权或合规开源路线 |

旧Pythonrouter Blob `9017f55d5470df65a25ab33624017b2ffc1f7405`与上述service来源已由0.7具名报告记录，本轮辅助只读核service Blob，不运行历史依赖。源码范围不是当前部署范围。

建议算法独立紧接恢复：先固定太阳/阴历、子时换日/闰月、时区/DST、是否真太阳时、坐标精度/缺出生时刻降级标签、星历与宫制版本及规范化输入签名；以可追溯的独立排盘资料/人工复核边界例和独立天文参考数值比较，冻结误差/比对字段。当前具体非fixture oracle来源和合法使用权**尚未落实，是完整算法AC的实质前置缺口**，不能承诺用fixtures填充。结果需APP可见真实来源、精度/缺项及输入签名，失败显式不可用，不fail-open至CRC充数；未经验证不进入核心权威评分，MBTI不参与排序。

上游许可实读：[iztro 2.5.8 MIT](https://github.com/SylarLong/iztro/blob/2.5.8/LICENSE)、[Kerykeion v5.12.7 AGPL](https://github.com/g-battaglia/kerykeion/blob/v5.12.7/LICENSE)。MIT本身没有要求整个产品开源；AGPL不能因单独Python进程或research_mode便认为闭源许可已解决。B/app/Services/AstrologyDependencyGateService.php:10–26虽有research_mode例外，本任务不启用。Swiss商业许可是否已获、pyswisseph/星历数据最终条款和可替代商业授权组合仍UNKNOWN；买Swiss许可不自动覆盖其它AGPL组件。没有安装或调用任何blocked依赖。

不推荐在RTC安全/双端/网络与短视频链尚未实测时，再将完整紫微与西占作为0.9无条件并列AC：它们没有共享SFU/媒体依赖，oracle/历法/法律决策独立，强行组合只会令“完整算法”名实不符。Owner可批准iztro路线后将具名紫微恢复并行纳入，但必须新增真实完整字段与非fixture oracle AC，不能用当前14星子集替代完整紫微。

## 6. Buddy、Social与剩余完整交付安排

当前F/lib/features/buddy/presentation/pages/buddy_companion_page.dart:65–72、580–653使用_mockCandidates，本地/mock需求不发布；F/lib/features/social/presentation/pages/social_baseline_page.dart:42–68明确编辑预览，不公开或改变资料。

旧固定源对应Buddy Blob `24f802a8d341787aef800e81fb9961020e5937a5`:72、200、232–233、609、647、929同样为mock、草稿、不提交举报/拉黑；Social Blob `5f9efca478c3a603ecc2fd1521d13dfa5fcb8ef6`:47、112、122–150、190、339–341同样为预览，不做真实动态/关注/自动代聊。已核具名页面没有被遗漏的真实双端服务。**不能据此断言所有旧资产绝无实现**；其它来源UNKNOWN。本版不再广扫旧仓，Owner若掌握另一个具体真实实现来源，可具名指定；否则Buddy/Social从预览补成业务属于新增产品合同，需决定参与/公开范围、同意与举报规则后冻结，而非自动照页面造社交系统。

| 具名后续包（次序建议，不创建版本任务） | 联合验收前要解决的结果 |
|---|---|
| RTC/私有视频恢复（首推0.9） | 两端媒体、当前同意与撤权、可播放私有附件、同库与重启证据 |
| 完整A07算法恢复 | 合规引擎＋非fixture oracle＋完整紫微/西占选定本命/合盘/行运/返照输出；APP及输入持久签名。任何裁减由Owner决定 |
| A08具名功能收口 | Buddy/Social真实旧来源或新增合同决定；地图、系统Push及必要设置逐项确认。手工坐标/站内通知/本地设置可复用，不能称地图供应商、后台系统推送或跨设备设置同步已恢复 |
| A03历史数据/附件 | Owner批准具体副本、用途和脱敏/关联范围后才隔离恢复；原SQL gzip/VHDX与真实用户本轮未读取。缺备份只阻塞该项，不用空开发库冒恢复 |
| 完整APP/Web联合验收与材料 | 各主要包恢复或Owner明确排除后，同套最终APP/Laravel/Blade/持久库/worker跨端测试，包含权限、管理员影响用户、失败/重启及安装部署说明；对齐真正分发APK的URL/hash |

已接受B01～B06保持接受，不重新调查。0.8 development release元数据仍指初始包而R1物理APK有不同SHA，最终分发需明确对齐，不在本轮写库。现在不能宣布完整联合验收：RTC与其它用户能力尚未交付，算法许可/正确性与历史资产仍有具体缺口；0.6～0.8局部闭环不能替代全功能联合结果。建议Owner批准把暂定0.9“联合验收”顺延到主要功能收口之后，保留该交付门，**本报告不修改路线图、不自定0.10或后续编号**。

## 7. 推荐候选AC与集中Owner决定

以下8项只是建议，等待Astra冻结与Owner手动派发。不是正式AC编号，也不表示环境已批准。

| 候选 | 可观察完成标准 |
|---|---|
| C1 当前RTC权威 | 同一隔离MariaDB中独立Match/CN/MC事实；合法双方才能创建/接受/入房。无CN、单方MC、stale/revoked、block、restrict、disabled、非参与者及未知环境在每个使用点拒绝；历史只读不提升为RTC授权；不改变D1/D2/D3 |
| C2 双端语音 | 两个真实APP同call/room，呼叫→响铃→独立接受→双向可辨音频、RTP/媒体计数增长及播放→挂断；拒接、忙线、超时和麦克风拒绝有正确结果，不能只出JWT/状态 |
| C3 双端视频 | 最终包实际申请摄像头、发布/订阅并显示双方可辨测试画面；摄像头/麦克风开关、权限拒绝、前后台/旋转及结束行为明确。记录这是预留video模式补完，不伪称旧实测视频已复现 |
| C4 撤权与缓存JWT | APP/Web触发撤MC/CN、block、restrict/banned/end后数据库和SFU对应同call；建议≤5秒双端媒体停止，旧JWT及SFU自动刷新JWT不能新入/重入，跨call/epoch不能用；服务/worker异常、DB未知不得授予。生产默认fail-closed，邀请/通知不泄露撤权后敏感身份 |
| C5 私有短视频 | APP实际选择受控视频→可信上传→真实metadata/缩略图或明确限定处理→消息附件关联→另一APP授权播放/Range→DB与存储读回；超限/伪MIME/处理失败/非本人asset/取消/重复有确定结果，撤权后文件/缩略图/Range拒绝 |
| C6 已接受能力回归 | 真实图片和文本、CN/MC撤回404、R1通知最小化；Web同库restrict/banned/本人申诉及合法历史只读仅跑受影响链，审核变化不静默撤旧CN/MC；不重验所有B01～B06 |
| C7 断线与持久性 | 重启后端、database queue worker、独立DB及SFU前后，call终态/失效事件/附件/审计持久一致；断线重连只在当前有权时成功，不重用终态房间。SFU重启不是恢复授权；失败控制/重试有原始证据 |
| C8 最终软件与证据 | 最终Flutter/Android源码构建AAR/debug APK并两端安装，记录commit/tree/hash、权限与媒体正反例、原始stdout/stderr/exit、定点自动测试和分析、服务/存储/资源状态及runbook；历史Flutter3失败/exit1与vendor弃用照实保留，未运行明确NOT_RUN |

**仅需Owner集中决定三组事项：**

1. 是否批准0.9优先上述RTC（含明确补完预留视频）＋原有视频picker对应私有附件，而完整联合终验在主要功能恢复后；默认不把未证旧实现的录音消息偷渡进恢复范围。若要求录音消息，同次明确其产品及依赖范围。
2. 是否随正式plan一次批准锁定官方LiveKit镜像/许可证、入房授权与失效控制所需本地组件、独立0.9库/媒体/worker、指定第二AVD或测试Android设备、最小UDP/TCP与网卡来源范围及测试媒体权限；推荐零第三方付费、不公网、不录制个人内容。TURN/证书或新媒体工具若实际必要，应具名列入，未批准不得扩大。
3. 完整紫微/西占的非fixture oracle及合规路线如何落地（MIT iztro与AGPL/商业组合分别处理），Buddy/Social是指定另一真实旧源还是批准新增业务合同；地图/Push/历史数据各具名范围仍要在完整内测前决定。只暂停相应风险，不以算法许可拖住已授权RTC实施。

## 8. 固定证据索引与本轮未运行

以下链接均锚定产品技术起点，避免后续main变动混淆：

| ID | 固定源码/证据 |
|---|---|
| S1 | [RtcSessionService](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/RtcSessionService.php#L41)，[RtcController](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Http/Controllers/Api/V1/RtcController.php)，[LiveKitTokenService](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/LiveKitTokenService.php#L13) |
| S2 | [Flutter RTC服务](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart#L539)，[通话页](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_call_page.dart#L219) |
| S3 | [LiveConsentService](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/LiveConsentService.php#L110)，[通知R1投影](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/NotificationService.php#L18) |
| S4 | [MediaController](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Http/Controllers/Api/V1/MediaController.php#L33)，[处理Job](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Jobs/ProcessMediaAssetJob.php#L27)，[0.7真实图片原报告](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/docs/versions/v10.0.7/EXECUTION_REPORT.md#L53) |
| S5 | [旧聊天gateway](https://github.com/zcx369658780/EliteSync/blob/0f06e895a89629a7f4f0cf0c62b784446ecf515a/apps/flutter_elitesync_module/lib/features/chat/data/gateway/chat_media_gateway.dart)，[旧Buddy](https://github.com/zcx369658780/EliteSync/blob/0f06e895a89629a7f4f0cf0c62b784446ecf515a/apps/flutter_elitesync_module/lib/features/buddy/presentation/pages/buddy_companion_page.dart)，[旧Social](https://github.com/zcx369658780/EliteSync/blob/0f06e895a89629a7f4f0cf0c62b784446ecf515a/apps/flutter_elitesync_module/lib/features/social/presentation/pages/social_baseline_page.dart) |
| S6 | [ZiweiCanonicalService](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/ZiweiCanonicalService.php#L160)，[ZiweiInputPolicy](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Support/Ziwei/ZiweiInputPolicy.php)，[oracle harness](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/tests/Unit/ZiweiOracleFixtureHarnessTest.php) |
| S7 | [许可门配置](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/config/astrology_dependency_gate.php)，[旧计算源定位](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/docs/versions/v10.0.7/FEASIBILITY_RECOMMENDATION.md#L60)；旧Python具名Blob见第5节 |
| S8 | [西占legacy引擎](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Services/LegacyInputWesternNatalEngine.php#L17)，[provider](https://github.com/zcx369658780/EliteSync-v10/blob/3a8f7989aa208285b885f1c80f4365f38488ac54/services/backend-laravel/app/Providers/AppServiceProvider.php#L38) |

本轮：Git对象、报告文本与安全上游资料只读核验；部分路径定位尝试曾返回不存在/Windows glob错误，已按实际文件定位，不计测试FAIL/PASS。一个上游许可URL带v前缀404，改用实际iztro `2.5.8` tag读到MIT；LiveKit文档旧URL不可达，改读官方当前tokens-grants页。助手一次将旧源仓库误用为D:/EliteSync-v10，对象读取失败，随后从正确D:/EliteSync固定对象读取成功；错误读取没有修改原树。

**NOT_RUN**：Flutter/PHP测试与分析、构建/安装、APP/浏览器业务、HTTP/数据库读写、RTC/SFU/ICE/TURN、算法及oracle执行、媒体转码/播放、性能和重启。没有拉取新镜像/依赖、开端口、创建数据库、seed、启动任何服务或处理历史备份。本轮不重新实测/声称保护卷停止状态；未操作其生命周期或数据。

本次只提交本报告；冻结计划、Owner政策、现行状态/路线/台账及旧证据字节不改。专用树原有`?? %SystemDrive%/`不处理、不stage。原dirty根仅做保护性只读Git身份/状态核对，不吸收其改动；前后HEAD均4bebc8f394248e254c1368a06fbdee5d2c883301、index SHA256均2BE660029A2E2C2578F5193BC050DEE35BE3E71CE941460A42331BABF577E716，可枚举status摘要SHA256均AD96CE5B9BD2F6ABA58737CF1A8B57078C62A15C33474F132121368FE98C4A06。长路径状态枚举有warning，不能声称全量109项文件内容重验。报告空白检查exit0，仅为文档检查，不是产品测试。发布身份由最终回执给出，不以报告自引用制造commit hash。

终点：**V10.0.9 FEASIBILITY_READY / NOT_FROZEN / NOT_IMPLEMENTED**。等待Astra及Owner最终范围和权限决定；不实施0.9、不启动0.10。
