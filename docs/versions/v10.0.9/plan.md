# EliteSync-v10｜v10.0.9 正式冻结计划｜受控双端RTC、撤权安全与私有短视频

2026-10-15。**FROZEN_PLAN / OWNER_D4_D5_D6_APPROVED / OWNER_MANUAL_DISPATCH_PENDING / IMPLEMENTATION_NOT_STARTED / AC-09-01～AC-09-08 IMMUTABLE**。

Astra依据Owner明确“D4～D6三项按建议批准”、固定v10.0.9版前可行性、现行工作流及已接受v10.0.6～0.8基线冻结。**本文件仅是不可变开发合同；发布文档不是执行授权**。由Owner手动将本计划固定Git Commit/Blob交给Codex并明确“正式执行v10.0.9”，才一次启动第5节严格限定的本地环境/设备/网络/实现权限。未派发前不得启动LiveKit、下载新镜像、开放端口、修改产品代码或新数据库。

## 一、不可替代的Authority、来源与代码起点

- 唯一仓库`zcx369658780/EliteSync-v10`；Owner是产品取舍、额外不可逆风险和费用Authority；Astra负责版本冻结、独立终验和复盘；Codex在已派发的冻结版本内自主连续实现、诊断、修复、测试和证据封存。无需逐文件、逐命令审批，不恢复旧Work/dot实时监督、强制每版新worktree/单commit/全历史审计。
- **实施产品技术起点**：v10.0.8 K08完成的GitHub main `3a8f7989aa208285b885f1c80f4365f38488ac54`，Tree `95fadde468d8a21b39c544fdb74093dd35184717`；产品集成锚 `4f1b3c52d09346cf831249ee7e8186f2679b2217`，Tree `8088a870c979d8697aa781456d994076a158d799`。已独立核实K08正式[登记](../v10.0.8/integration.md)；原0.8接受R1是`d37121eb11d3cc845f1606a631d17ca01fe6105a`。本版文档编制前main `1aeb4249bcf324c87cbbf197693f6b4f133cf138`，Tree `44ca3e68be590d90b943bf7684f2b485717465fe`，新Owner D4～D6提交`4bda572e225b64a3b4d826ae75e355e958251c58`只改产品决定；产品apps/services/question_bank对象未改变。**后续计划和动态目录纯文档提交不成为新产品代码起点**，执行前应核live main及专用本地HEAD。
- Owner正式[D4～D6批准](../../../PRODUCT_DECISIONS.md)：Commit `4bda572e225b64a3b4d826ae75e355e958251c58`，Git Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`。D1～D3继续生效。v10.0路线仅有“可用完整APP/后端/DB恢复＋独立Web管理”两核心目标，主要原版能力须在内测前交付，不用旧MVP Later静默删减。
- 固定版前来源：[FEASIBILITY_RECOMMENDATION.md](FEASIBILITY_RECOMMENDATION.md) Commit `1aeb4249bcf324c87cbbf197693f6b4f133cf138`、Blob `1b72c61d4fbcd179d89b357062dc1715372fd7b4`；[唯一版前提案](PLAN_PROPOSAL_V0_1.md) Commit `8847624120aab5de0ac90e05c7e80ea53c65f2d6`、Blob `fbb060fc9a4b79a9e7075809e961a9d258455f83`。[CURRENT_WORKFLOW](../../workflow/CURRENT_WORKFLOW.md)、[恢复台账](../../architecture/RESTORATION_CAPABILITY_MATRIX.md)、[原批准路线](../../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)均保持适用；旧报告的原样索引是源码/风险依据，静态调查不是RTC已运行。
- v10.0.6、v10.0.7、v10.0.8各自**ACCEPT WITH OBSERVATIONS且K08完成**；不反复验证历史任务或强制压回原dirty根。旧Flutter带同次PHP fixture全量821通过/3项既有展示与导航失败exit1、0.8全量未重跑，K08空白检查exit1、PHP vendor弃用与设备构建警告保留；本版实际影响相关代码的必要回归另做，绝不谎称旧套件全绿。

## 二、D4～D6正式产品界限：功能恢复优先于假联合验收

**D4：本版一组真实用户能力，而非Token或页面展示。**

1. **双端语音**：两名具名开发虚构用户各自在真实可安装EliteSync Android APP内，基于当前独立Connection及Messaging Consent合法资格，请求、响铃、接受或拒绝、进入同一受控LiveKit通话，双方麦克风采集/发布、订阅、播放辨认得到声音，结束、忙线、超时、网络中断与权限拒绝均有真实可观察结果。
2. **双端视频**：Owner明确批准**补建**原有“视频预留”的新可操作能力；Android运行时摄像头权限、视频采集与发布/订阅、双方APP真实可辨视频画面及麦克风、切换摄像头/静音/关闭视频、拒绝权限和通话结束均须真实实现。不能把旧UI占位或SDK存在宣称原版视频早已实现。
3. **私有短视频附件**：已有用户侧video picker及media模型可复用，本版选定**MP4/H.264视频＋AAC音频（无音轨样例亦应有明示处理）**，建议受控工程限值单文件**≤25MiB、≤30秒**。真实APP选择测试视频→受控上传与内容/类型/时长校验→必要处理与可证的ready/失败状态→绑定本次双方有权消息→接收者APP授权播放（需要时含Range分段）→持久重读/重启，撤权后媒体/封面/Range均拒绝。Codex可针对已知锁和可用依赖在范围内确定播放器、元数据检测及容器内工具；不得把更广格式转码、全量媒体云平台或录音消息偷渡进范围。若需要未批准的系统级新工具或有争议的编码/许可，暂停该子能力并报告具体选择，继续其余无风险工作。
4. 原v10.0.7真实文字/私有图片、CN/MC状态机、v10.0.8 Web处罚/审核/举报、站内通知与申诉只作受影响的真实回归，不重新实现原版B01～B06。

**D5：允许一套严格本地SFU/信令与撤权设施。** 使用固定官方LiveKit版本＋不可变Digest，隔离Docker/受限本地网络、虚构开发账号/媒体、两台经核归属的真实APP测试端。默认只配置能经有权信令入口接入的私有SFU，不允许匿名/直达原生SFU WebSocket绕过Laravel当前资格检查，不能凭短TTL/踢人/客户端leave单独声称旧JWT立即失效。相应第5节的精确本地权限**只在Owner派发后生效**；不涉及公网开放、LiveKit Cloud、付费服务或生产。

**D6：剩余用户恢复与最终联合验收的排程。** 本版不伪称已完成完整紫微/西占、Buddy/Social、地图、系统Push、录音消息、历史真实业务数据与附件。完整A07算法需独立非fixture oracle/许可后恢复，A08 Buddy/Social需确定真实旧源或Owner单项批准新增真实业务合同；其它已选原版媒体及地图/Push也须具名确认。此前暂定“v10.0.9联合验收”**经Owner批准顺延到主要用户能力恢复后**，下一包具体名称/版本号今后另决策，不自动启动v10.0.10。最终软件及Web联合验收与公开/内测运营分开，全部主要功能必须先于内测交付。

## 三、RTC真实权限架构与撤权行为（本版必须实现）

本版不可把`released DatingMatch`、对话列表、旧Relationship事件或历史只读权当作RTC发起许可；同一用户对须严格按既有**Match → CN_ACTIVE → 双方当前MC_ACTIVE (LIVE_READ、LIVE_SEND) → 独立来电接听**来获取新实时互动。RTC是否建立/加入按当前安全使用点复核，而不是客户端自报两个MC或借本地`useLiveKitRtc`开关放行。D1仅约束新匹配，不自动删除合法历史CN/MC；D2 restrict即使允许合法历史只读，仍禁止发起/加入实时RTC。banned/disabled、block、stale、withdrawn/revoked、declined、非参与者或生产/未知环境一律fail-closed。

1. **共享可信授权**：扩展`RtcSessionService::canCall/create/accept/connect/heartbeat/show/list`与`RtcController::livekit`及必要LiveKitTokenService，通过Laravel当前认证用户、双方状态、CN/MC最新revision、有效call状态和具名设备/角色，必要DB事务/锁下校验。参与者只在合法`calling→ringing→accepted/connecting→in_call`内转换；拒接、忙线、超时和旧call terminal不能复用。独立接听动作不能由MC同意自动代替。后台Web正常ban/restrict及用户block/撤销须使未执行的RTC权限失效；具体停止行动可用可信事件/队列有限重试，不新增第二业务事实库。
2. **逐call权限身份**：各通话单独高熵room/epoch和用户参与身份，令牌仅对当前call/room/participant、媒体模式、必要发布/订阅track最小授权，有限TTL上限并避开任何原始token日志。新通话不得复用同一用户对旧room；旧JWT跨call/epoch必拒。入房令牌只有通话必要状态、当前双方授权与受限0.9环境均成立时产生，签发及刷新不能跳过实时规则。
3. **旧JWT和直连防护**：受控信令入口对**每次首入/重新连接和需要的token刷新路径**通过可信服务端重新核当前call epoch、参与身份、CN/MC、block/restrict/disabled；SFU原始信令/API仅隔离内部可达，无未受控第二入口。即使拥有初次获发的未过期JWT，也不得在撤权/终止后重新入房；必须实测直接绕过代理的旧URL/新IP、WS重连和SFU自动token刷新，而不是只测试Laravel拒发新JWT。未知或DB不可读时拒绝新join。
4. **已入房媒体强制终止**：end、拒绝、call终态、CN/MC撤销、block、restrict或ban后，服务端持久失效及call终态，向SFU执行踢出/结束对应房间，记录ack及失败重试；不依赖APP自愿断开或JWT自然过期。**受控测试中撤权后不得再新join，双方仍在流动的有效媒体须在5秒内停止**；若SFU/网关/worker故障无法证明安全界限，只能记录明确阻塞并暂停受影响RTC，不得降低AC或改成“等待TTL到期”。SFU异常不应让未撤权数据被静默开放。
5. **私密派生输出**：RTC来电通知/历史call列表/设备日志只提供当前有权者必要信息，不能通过旧通知title/route、撤权后缓存、未授权媒体URL或JWT调试输出泄露私信、身份和密钥。保留原0.7 R1通知内容最小化，禁止向GitHub保存SFU secret、完整JWT、真实音视频及家庭网卡/私有网络敏感信息。

## 四、消息视频附件与已接受业务协同

- APP入口复用当前`chat_media_gateway`视频选择，但状态必须对应实际HTTP、服务器素材ID、处理任务和最终可播放资源；录音消息暂无经核原实现，明确`NOT_IN_SCOPE`。
- 0.9新增专用private media disk与独立media/job/消息附件关联：不将公开URL、客户端任意storage_key或外部文件路径提升为授权对象；上传时核MIME、容器/codec、时长与容量，状态失败给明确错误，幂等/取消/处理异常不产生可假读的READY。若采用现有处理器仅能校验不能转码，应只承诺经明确输入契约实际可播放的结果，不能把挂“ready”当完成。
- 同一`conversation_id/message_id/media_asset_id`双方可追溯，发件人需有当前live_send，收件人附件播放、内容读取/Range与封面每次重核live_read、账号状态、block、当前协议；撤权、restrict/banned对新发送及附件保留/拒绝依既有D2与历史只读边界，不因“媒体缓存”绕过。视频对旧合法历史的只读与新互动禁止须与实际当前权限一致，不为媒体扩大旧访问。
- 对照0.7已接受图片/文本链、0.8处罚与申诉/Web限制、同库站内通知；既有权限fail-closed、原隐私限制、消息审计与APP受限提示不得退回。

## 五、Owner手动派发后一次生效的受控本地环境及权限

### 5.1 代码、镜像与依赖

- 继续复用K08专用工作树`C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，执行前核实际HEAD与live main；允许本版分支、连续提交、跨Flutter/Android/Laravel/数据库迁移/RTC网关/SFU集成/媒体worker/测试与脚本相关改动，按既有Flutter SDK、JDK17、Gradle及composer/pubspec锁依赖编译。不得盲目pull/reset/clean/stash原dirty根、不能把其它项目文件或LOCAL_ONLY混入提交。
- 使用**官方LiveKit Server固定v1.13.10作为首选兼容候选**；其是否适合本机镜像平台与现有`livekit_client 2.10.0`、`flutter_webrtc 1.6.0`，须在获取前核架构/许可证/SDK可兼容。**第一次pull/run前先从可信官方源解析不可变manifest digest、核实际镜像ID、登记sha256和许可证/NOTICE；禁止latest、未固定digest和不明镜像**。若锁版本与固定候选不兼容，不能悄悄升级整个客户端或换另一发行版；按同一版本的最小可兼容、经官方来源锁定方案提出具体变更依据，超出本条授权则报Owner。LiveKit Server自身许可证不自动覆盖新编解码/代理/第三方工具依赖。所有密钥本地私配，不入日志/仓库。
- 允许在本0.9隔离项目/容器中实现必要**RTC信令入房鉴权代理、SFU admin control/踢房、失效事件与队列worker**及合法锁定的小型依赖；不允许系统级/UAC安装、全局SDK/代理改动、付费Cloud、域名购买或生产HTTP/RTC开关。仅用于本地短视频必要且许可证可核的已安装或项目隔离元数据/播放工具可复用；要新系统级工具/商业编码依赖时只暂停该视频子项并请求具名决定。

### 5.2 完全隔离的开发数据库、服务与设备

- 允许新建**仅0.9** MariaDB10.11容器`elitesync-v1009-db`、volume`elitesync-v1009-db-data`、库`elitesync_v1009_dev`；建议宿主`127.0.0.1:43319`，执行前查实际端口占有者，若冲突改用另一空闲loopback并在Manifest统一记录。独立媒体磁盘/queue/RTC事件、必要迁移和具名虚构账户，幂等且最终断线/重启不reseed。绝不修改0.6/0.7/0.8验收volumes、原3306真实库、历史SQL gzip/VHDX/真人账号或私聊。
- Laravel/Web、必要MySQL队列和工作脚本可使用已验证loopback8000→8001，冲突先核所属进程；本版新增精准`elitesync_v1009_dev`/绑定端口的live consent/media/RTC local gate，同时保留原0.7/0.8本地已接受门与生产未知默认拒绝。**不得把0.9数据库假冒0.7库名或全局关闭DenyUnverifiedMessagingLiveAccess安全门**。
- LiveKit原生7880/TCP(信令/API)仅SFU内部容器网或受控localhost可达；APP面向的是有当前授权验证的受控信令入口（其具体本地服务端口/WS地址由运行时核验并固定Runbook），代理前不得让旧JWT直接访问SFU原生入口。ICE建议使用Mux `7882/UDP`，精确到经核网卡/两个受控测试端的来源且不暴露公网；确需TCP媒体回退可限域`7881/TCP`并单独记录理由。**不授权开启50000–60000整段UDP、公共0.0.0.0外网可达策略、整机防火墙提权或改变无关端口占有进程**。容器内部绑定0.0.0.0若协议需要，应以宿主防火墙/端口发布严格限域且验证从非测试端不可达；需管理员提权才能做到最小安全网络策略时，停止该设施部分征询Owner。TURN/STUN外部服务、3478/5349/443、域名/证书及第三方访问没有默认批准。
- **两个真实APP端**：优先经核现有Windows Android SDK中的两个专用Android36.1 x86_64 AVD，若资源/摄像头不可用，则只能使用Owner另行具名指定的无真实账号测试设备，不得接入/wipe个人设备。允许创建新专用AVD、仅重置**本版新建**虚构环境APP数据，指定serial分别ADB reverse到本地API/授权入口；Android宿主麦克风/摄像头运行时许可按实际测试请求/拒绝，测试媒体必须虚构且无真人图像/声音，UI、RTP和播放回执需一致。不得把两个独立mock、token脚本或两个假用户请求替代双端APP。
- 所有本地HTTP/WS/UDP/媒体数据传输只在受控开发设备与宿主范围使用，测试完成后关闭仅本版的容器/端口/服务/AVD，保留卷、必要私配/失败原证，不自动删除此前验收资源。实际运行时网络/RTC/设备属于Owner已批准的**本地0.9限定授权**，不授予任何云端SSH或对外业务访问。

### 5.3 仍禁止

不开放真实生产、发布应用市场、付费/外部LiveKit Cloud、第三方真人音视频、未知系统安装/提升防火墙权限、调用Kerykeion/Swiss被许可门阻断的默认高精度算法、购买许可、访问原历史真实数据库/原dirty根隐私、引入未批准的完整Buddy/Social业务。只对阻塞部分保留风险、其它本版本获授权无风险实现可继续。**D4/D5/D6批准≠下述全部其他用户恢复包自动实施许可**。

## 六、冻结AC-09-01～AC-09-08（每项均是原目标必要门）

| 固定AC | Astra必须独立检查的实际结果 |
|---|---|
| **AC-09-01 代码/镜像/设备与数据隔离** | 可追溯固定K08技术起点、最终Candidate Commit/Tree及源码diff；LiveKit官方固定版本/manifest digest与实际运行image ID核对、许可证记录，SFU/受控信令/0.9 MariaDB和专用volume、media/worker、两台具名独立APP设备/账户实际身份可信。新环境真实服务而非mock；0.6/0.7/0.8卷、dirty根与其它设备受保护；生产/未知环境继续fail-closed。 |
| **AC-09-02 当前CN/MC及RTC调用授权** | 在真实Laravel/持久0.9 DB，以有权双账号按Match→CN_ACTIVE→双方当前MC的LIVE_READ/LIVE_SEND→独立来电应答完成create、accept、connect、join及重连；每处服务端校验当前状态/参与者/revision。只有Match、单方同意、拒绝/撤回/stale、block、restrict/banned/disabled、非参与者、错误call与数据库/权限未知环境均拒绝；RTC列表/通知/令牌及原消息历史不能侧漏或绕过当前隐私。 |
| **AC-09-03 真正双端语音媒体** | 最终同源APK在两个受控真实Android APP端安装，真实caller/callee创建→响铃→接听→双方同时可辨的虚构音频帧/播放与RTC inbound/outbound RTP或实际媒体统计增量→双方结束及正确历史/DB状态；拒接、忙线、未接、心跳/连接超时、麦克风拒绝、单端断线再连正反例成立，不能只证JWT/RTC数据库状态。 |
| **AC-09-04 真正双端视频媒体** | 实际视频通话入口不再只写“预留”；两个真实APP请求摄像头权限并发布、订阅、在两端画面看到不同虚构视频测试源及可核帧/统计，麦克风同时按实际选择工作。关闭/切换摄像头、静音、拒绝权限、前后台/旋转与结束状态可观察且无资源残留；不得把摄像头图标/本地预览算双端视频。 |
| **AC-09-05 失效传播、旧JWT重入与SFU控制** | 真实用户撤CN/MC、block、Web restrict/banned、通话end后新join/重连立即拒绝，已连接双端有效媒体在同次受控实测中**≤5秒停止**；旧未过期JWT、自动刷新JWT、原始SFU直连/bypass、跨call/epoch请求不能进入或继续受保护媒体；SFU故障/worker重试/数据库未知时fail-closed且有可查审计/有限重试/同call终态。TTL等待、客户端主动leave或只踢人不能替代有效撤权实测。 |
| **AC-09-06 私有短视频消息** | 真实APP视频picker选MP4/H.264(+AAC)短片→受控HTTP上传→可信类型/大小/时长与处理实际状态→同一有权消息附件绑定→另一真实APP可播放/必要Range→MariaDB/持久存储重启后读回；超限/伪类型/失败处理、非本人asset、重复、撤权或非参与者的文件与封面/Range请求正确拒绝，无公开fallback/猜测URL/未授权缓存继续提供私密内容。 |
| **AC-09-07 已接受功能与Web联动定点回归** | 原v10.0.7真实文本/图片有权通信、CN/MC阶段独立、撤权404、R1消息通知最小化；v10.0.8 Web restrict/ban/申诉与D1资格对当前RTC/聊天/媒体的正确使用点生效且原合法历史只读仍按政策保留。正常控制用户继续可用，不需重验整套B01～B06但绝不以模拟状态冒回归；不得把新视频附件写成系统Push或录音消息已恢复。 |
| **AC-09-08 最终包、联合运行和证据交付** | 最终源码Flutter AAR/debug APK构建/两端安装可追溯hash与版本，真实APP→Laravel/API/受控WS→LiveKit/媒体worker→持久MariaDB及重启SFU、后台worker/DB/API/APP后的call终态、失效、视频附件/审计一致；相关PHP/Flutter/分析/构建/设备/媒体命令真实stdout、stderr、exit与原失败修复均封存。提交固定独立GitHub候选的报告、Manifest、Runbook、少量关键截图/安全RTP统计和原证索引，物理大包/私配LOCAL_ONLY，未运行项NOT_RUN。Astra按原8AC独立终裁，Codex不得自称ACCEPT或直接合main/启动下一版。 |

**八项均必需。** 真实RTC、安全撤权或双端视频任一未交付，不得用unit/widget/API mock、JWT字样或“SFU不可用”说明替代本版PASS。Codex在版本内自主解决常规锁版本/ICE/媒体/Flutter构建问题并必要重测；遇未批准的系统提权/许可证/公网或不可逆资产，仅暂停该风险子项并提交最小Owner决定，其他无风险部分继续。本版不得因R1或后续障碍事后降低5秒、直接SFU绕过、视频双端等固定门槛。

## 七、实施模式、证据、安全发布与版后顺序

按依赖建议：核镜像/许可/网络/设备与本地DB→可信RTC使用点、JWT/call epoch与授权信令入口→本地双APP语音→视频拍摄/播放→撤权强制踢房及旧JWT/rejoin竞态→短视频私有附件与Range/缩略图→原短信/图片/管理处罚必要回归→完整构建、SFU/DB/APP重启、原证封存。Codex可交错/并行多agent做确定子模块，但不得绕冻结目标、旧MC或风险门。

集中交付固定`docs/versions/v10.0.9/EXECUTION_REPORT.md`、`manifest.json`、`RUNBOOK.md`、明确AC-09-01～08逐项证据与未恢复台账更新；产物来源Commit/Tree、固定镜像Tag+Digest、SFU/端口/设备serial/配置信任边界、数据库用户/房间/call/MC revision、停止与重连时点、音视频RTP指标、短视频media asset ID/Range拒绝、测试原始exit及必要Web截图/APP两端真实截图。测试用token/音视频/隐私与真实网络/私配不得公开，必要时脱敏仅列哈希/短期受控本地原件路径，Astra未能在GitHub读取的原证只能标`CODEX_REPORTED/LOCAL_ONLY`。

最终普通non-force推送**独立候选分支**，读回Commit/Tree并集中报告 **`V10.0.9 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE`**，随后停止。**不自动合main、运行K08、修改已冻结plan/AC、启动下一版本或生产发布。** Astra独立验收/复盘后按K08分别登记Acceptance、GitHub集成、本地接续和目标运行；只有Owner手动派发后才能执行本正式plan。

**终点：V10.0.9 FROZEN PLAN — OWNER D4/D5/D6 APPROVED — EIGHT AC — OWNER DISPATCH PENDING。**
