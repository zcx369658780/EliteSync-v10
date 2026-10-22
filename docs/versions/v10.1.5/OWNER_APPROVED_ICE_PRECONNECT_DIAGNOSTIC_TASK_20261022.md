# EliteSync v10.1.5｜Owner批准的ICE连接前最小诊断能力补充（唯一综合任务）

2026-10-22，Asia/Singapore。
**OWNER_APPROVED_ICE_PRECONNECT_DIAGNOSTIC_CAPABILITY / SAME_VERSION_BOUNDED_TASK / CODEX_MANUAL_DISPATCH_PENDING / PLAN_A_RETAINED / NO_PRODUCT_MAIN_INTEGRATION / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_AUTOMATIC_R2 / V10.1.6_NOT_STARTED**。

## 一、Owner批准范围和唯一目标

Owner在Astra完成P1 USB/ICE最小动态观测独立复审后，对“**极小范围的ICE诊断能力补充**，连接前／失败时取得`tcpType`、候选对检查、STUN和DTLS状态，再判断是否需要调整网络方案”的建议明确回复“可以我同意，请继续”。

**批准的是一次同版、定点的诊断能力补充及相应有界验证，不是反复拨号直到连接成功。** 方案A和冻结AC-10.1.5-05不变。优先复用**已经存在于锁定Flutter源码/依赖中的`RTCPeerConnection.getStats()`、PeerConnection事件和可用统计字段**，使现有仅在`Room.connect`成功后才执行的媒体观察能在`Room.connect`**进行期间**安全采样。**先核真实锁定的livekit_client/flutter_webrtc及其实现；不能假定官方较新版本一定在此环境提供`tcpType`、STUN统计或DTLS字段。**

*允许*从已交付v10.1.5候选延续，进行一次有界的**仅开发构建可达的ICE统计观察器**源码修改、针对性单元/Widget测试、最小隔离APK构建与产物身份验证。若当前已授权的同一台Owner安卓手机USB在场、Android弹窗许可由Owner现场给予、诊断构建不覆盖含个人数据的现有APK且发布/签名隔离可靠，则可在**同一受保护USB+host loopback+原SFU/guard与合成DB网络条件下最多一次**诊断性`Room.connect`，用于观察上述字段。若设备不在或安装将覆盖真实/未知数据，不执行设备阶段，仅交付已验证诊断能力和明确后续门禁。不后台等待、轮询手机、不自己产生新的使用授权。

不允许：修改生产或公共网络环境、改SFU`node_ip`／`bind_addresses`／Docker发布端口、开放LAN/UDP/TURN、修改防火墙/UAC、获取管理员/root、下载/升级SDK或镜像、添加真实第二设备、改变业务RTC安全逻辑、绕过CN/MC/device/JWT/5秒撤权合同、启用摄像头、实际录制声音、访问手机个人数据、删除已装APP或其数据、集成main、启动R2/v10.1.6。**本任务不授权任何原始个人音频、JWT、SFU secret、raw ICE/SDP、ICE源地址/手机号/设备序列号进公共报告/模型会话。**

## 二、固定项目对象与基线

GitHub：`zcx369658780/EliteSync-v10`。任务签发前live `main` = `270723d48105f05b5b21ba5e87a36b9d1b894b3d`，它是**已接受v10.1.4产品+顾问独立文档**，绝不从此main覆盖v10.1.5候选。开工须重新GET main和本任务Git Blob，记载是否只有授权文档变化。

- 最新P1有界观测交付Commit `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`，Root Tree `146c32d866f6986e48b80f7a4e3bd8c1ccc2638a`，其父 `22844b1eaae32d08d3b53705235601696935c250`。Astra独立复审 `docs/versions/v10.1.5/p1_usb_ice_independent_review.md` Blob `2df373a6151d11c68d639ea6669345e22f846093`；P1最终报告 Blob `f3e5282d803afa5c444427de1ab0b81c691c1754`；manifest Blob `6cdb8aded51bc876588f278649c4ee35fa178150`。
- R1固定源码Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，Root Tree `165eb1f362db533ca94bfe1db677ff6f7bd477ed`，apps Tree `0784c8aa7b0915a04b83693a45401197e31d93a2`，services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本次**只允许在新有界候选中添加测试诊断能力**，不能修改旧提交、冻结计划或验收文档。
- 现有关键源码`apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart`在R1的Git Blob `6495fc64ef49a914ba548142f14f23429a536984`：`_logMediaStats`有`publisher?.pc/subscriber?.pc -> getStats()`、`transport.selectedCandidatePairId`及`candidate-pair`过滤；但`_startAudioStatsTimer`位于成功`await room.connect`、启麦之后。之前唯一P1真机call4在30.209s时报`MediaConnectException`，统计定时器从未启动。现有`_logPeerConnectionSnapshot`只记录connection/ICE/signaling的粗状态。这是本次必须先验证的**入口缺口**，不是证明底层ICE必然是某个特定错误。
- 冻结AC-10.1.5-05：双实际APP的有权双向媒体、同call媒体重连、旧RTC JWT首入/重入拒绝、撤权COMMIT后≤5秒流动媒体停止，全部依然`OPEN/NOT_RUN`。真实Push待供应商不因此失去隔离；已独立审查的R1消息、缓存、媒体和Safety证据保留。
- 上轮G1第一运行窗口的LiveKit`7891`监听为IPv6 unspecified且Docker后端普通TCP可达；G2是重启后的不同实例，没有G2同实例/proc证据。以这个约束设计本任务，不能把旧G1观察当新实例证据。
- 旧手机包 `com.elitesync.v1015r1dev` / `10.1.5-r1-dev` / SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`；旧包及数据不删不覆盖，若开发构建需安装，应另造`ICE_DIAG_TEST_ONLY`可判别包/编译标志，或先严格确认它仍是本版无个人数据的孤立测试包且取得Owner设备提示许可。**不能靠应用包名猜测数据可覆盖**。

## 三、唯一连续实施链 D0—D5

### D0：最小代码/统计能力审核，先于一切改动

1. 独立确认单一干净候选连续从`62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`起步，不能reset/pull覆盖旧tree；记录五保护根、历史dirty/index/heads、当前所有旧refs、上轮1047份具名保护资产及新增证据的归属与实际hash（具体范围实报，不保证未登记缓存目录）。
2. 定点检查该`rtc_livekit_service.dart`的`Room.connect`、`Room.events`、`_logMediaStats`、`_logPeerConnectionSnapshot`、`leave/dispose`和Android debug构建门；检查项目锁定的`pubspec.lock`/本地SDK具体版本/实际`getStats`接口和返回类型。只允许使用已安装工具和依赖。**不下载包、不改pubspec/lock、不patch系统全局Pub cache、不盲用网上新SDK示例**。
3. 出ICE字段能力清单：`transport.selectedCandidatePairId`、`candidate-pair.state/nominated/currentRoundTripTime/requestsSent/responsesReceived`、`local-candidate/remote-candidate.protocol/candidateType/tcpType`、`transport.dtlsState`、`pc.iceConnectionState`及可能提供的事件；逐项标`SDK_VERSION_SUPPORTED / RETURNED_RUNTIME / NOT_PRESENT / NOT_OBSERVABLE`。对STUN只可从安全聚合的计数字段推断“可能有ICE检查”，不能把统计计数冒充逐包STUN Request/Response。
4. 若已锁依赖本身无法在`Room.connect`未返回时暴露peerConnection或这些统计字段，必须明示机制限制。可做最小不改变产品逻辑的接入，但**不得擅自升级SDK、修改native WebRTC或再用相同不可观测工具重拨一次30s**。必要权限新申请集中写入报告并停止对应工作。

### D1：开发测试专属诊断器——最小变更

1. 优先将原`_logMediaStats`已有解析/白名单能力提炼为可注入、可单元测试的纯函数或测试级辅助函数；在`room.connect`真正await期间启一个受严格编译时本地调试开关和native debug身份双重门禁的**低频、最多覆盖现有30秒timeout的有界诊断器**，同时覆盖publisher/subscriber当前已创建的PC。PC未创建时返回`NOT_INITIALIZED`，不要假定缺数据即失败候选对。
2. 每个时点仅输出安全字段：相对毫秒时间、call的临时非敏感关联ID、publisher/subscriber、ICE/connection阶段、候选类型/IPv4-v6与loopback类别、protocol/tcpType（有则按白名单）、pair状态和nominated/selected**布尔与状态类别**、DTLS状态类别、`getStats`失败的错误类和`NOT_AVAILABLE`。不得输出原candidate、SDP、任何host IP/port动态值、JWT、完整participant identity、密钥、网络接口、SSID、设备序列号、原StatsReport/Stack trace或人声。不可公开的原件如需留存须LOCAL_ONLY最小范围，公共只放白名单摘要。
3. 入口必须在当前`Room.connect`之前启动、在成功/失败/leave/dispose/账号切换/权限撤销/连接generation变化时及时取消；不可在失去权限后继续采样。不允许无界Timer或持续运行后台日志；失败自动fail-closed，不影响正常用户通话。
4. 为诊断目的若`Room.connect`成功，**本版诊断测试包不得自动采集麦克风**：要么在debug-only诊断模式成功后先抓一次无媒体ICE统计并主动合法退出，要么在能独立验证可靠隔离的前提下对诊断模式暂抑`setMicrophoneEnabled(true)`，但绝不可影响正常产品入口和R1普通APP音频功能；报告明确`TEST_ONLY_NO_AUDIO`与原产品行为差异。摄像头一律不得打开。
5. 产品正常release/profile、R1普通开发包不得携带可到达的诊断入口/网络字段或测试凭据；新增编译标志应要求明确local+R1+host debug，非本版构建因无依赖保持原样。对构建脚本如必须有界修改，独立原产物缓存坐标/临时包名，防止测试AAR混入普通release。
6. 定向单测必须覆盖：`getStats`先于connect完成且PC晚创建、null/缺字段安全UNKNOWN、selected/nominated的不同情况、TCP角色字符串未知、不输出隐私字段、失败/leave/epoch变化自动停止、测试flag-off完全关闭、测试开关拒绝release、无源码调试后门留在正常用户路径。不能用纯fixture成功代替物理网络成功。

### D2：离线构建与受控设备门（依能力执行，不得强迫运行）

1. 先完成Flutter定向test/analyze、项目已有的最小安全集回归和debug-only构建测试；旧baseline info/失败单独保留。对测试开关在release/profile执行负向配置验收，失败应是预期`GUARD_REJECTED`而非“构建失败还算通过”。如果不能验证test-only隔离就不能安装在Owner手机，交`DIAGNOSTIC_BUILD_GUARD_OPEN`。
2. 若构建不必修改SDK，可产出带SOURCE/TREE和SHA的独立诊断APK，本地保留，不向GitHub传APK、密钥或测试私密配置。
3. **设备运行不是本任务成功的先决条件**。只有Owner**确实连接同一台手机并明确同意此次诊断包安装/必要麦克风弹窗**、隔离applicationId与签名及原APP数据保护经审核无问题、同一套既有本版数据库/本地SFU归属身份及恢复点证实，才能进入D3。若`device`不存在、apk覆盖有个人数据风险、DB/端口不明或权限需扩展，则以`DIAGNOSTIC_CAPABILITY_READY / PHONE_RUNTIME_NOT_RUN`结案，不发起网络实验、不后台监控。
4. 若需要测试设备接入，只允许此前Owner批准的同一USB设备、`adb -s`精确目标和局部`tcp:8031`、`tcp:7894`、`tcp:7891`既有host loopback映射；保留raw7880不可达、业务guard current authority及CN/MC。不得开放LAN/UDP/TURN/防火墙、增端口或用UDP尝试绕过USB。

### D3：仅当所有门满足的一次受限观测（否则NOT_RUN）

1. 若D2真正满足条件且Owner当场确认，此次仅允许**一个**合成call／**一次**`Room.connect`（原30秒时限），HTTP-only peer只用于合法accept，不能冒充第二媒体APP。采样应先于`await room.connect`开始；**同一次容器、同一次call**先后提取真实ICE listener/proc和选中pair与状态，避免再发生“第一运行窗口的listener证据冒充第二运行窗口”问题。
2. 不进行麦克风采音、音频测试、录屏、全设备抓包、旧JWT/媒体撤权5秒实测，也不尝试第二次连接。诊断器只输出聚合状态；STUN是否发生若没有可信计数或已安装无特权观测能力，标`STUN_NOT_OBSERVABLE`，**不得新装tcpdump/tshark、新建raw抓包或修改SDK**。
3. 如连接失败，保留原失败类、最末已证ICE状态和未见字段，并立即合法end唯一call；若连接成功，只标`ICE_PATH_OBSERVED_IN_DIAG_TEST_BUILD`而**不**等于原普通R1 APP的媒体真实传输或冻结AC05通过。无后续拨号或安全门升级。
4. 任何对手机的APP安装、运行、ADB reverse、服务/容器启停必须具名归属/时间限定和清理；手机测试APP的数据、旧开发APP安装/数据、历史真实个人数据不得自行抹除或卸载。

### D4：有界独立审查与分类

一次非作者有界静态复核新增的代码路径、编译/host-debug隔离、统计字段的语义、sampling cancel/epoch、隐私脱敏、是否从fixture虚构`selected`或STUN、是否仍保证原RTC fail-closed。其复核不代替Android物理试验。按实际结果给出：
- `ICE_DIAG_CAPABILITY_READY / RUNTIME_NOT_RUN`；
- `ICE_DIAG_RUNTIME_CAPTURED / PAIR_STATE_FOUND_OR_MISSING`；
- `SDK_FIELD_UNAVAILABLE / OWNER_DECISION_REQUIRED`；
- `DIAGNOSTIC_BUILD_GUARD_FAILED / STOPPED`。

对于完整AC05仍只能`OPEN`；下一步是否修ICE网络/新工具/第二端由Astra独立复审后交Owner决定。本任务**不能**直接切P2／LAN、宣布必须开UDP，也不能为诊断方便改变原冻结AC。

### D5：集中交付与保护回执

仅交付同版新增：
- `docs/versions/v10.1.5/ICE_PRECONNECT_DIAGNOSTIC_IMPLEMENTATION_REPORT.md`
- `docs/versions/v10.1.5/ice_preconnect_diagnostic_manifest.json`

代码如有变化只允许定点触及当前RTC客户端诊断所必需的源文件、严格test-only构建门和针对性测试，**无v10.1.6、无生产安全合同修改**。源码从上一P1交付Commit `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`的唯一干净连续工作树生成一个新的fixed source候选；文档随后提交且**仅docs变化**，精确列source Parent/Root/apps/services，所有changed paths/mode/Blob及普通非force Git发布后readback。不得回填/覆盖旧R1/原P1报告、旧manifest和Astra复审文件，也不能自签ACCEPTED。

正式报告必须列出：已锁SDK可观察字段矩阵、preconnect挂载点、测试包隔离证明/负例、单测与真实运行严格分级、是否只有单次新Room.connect、字段`PRESENT/NOT_OBSERVABLE/NOT_RUN`、运行前后源SHA与设备权限、原本低层ICE假设和限制、匿名本地hash原证、非作者复核与旧失败、数据库正常时间戳/新增合成数据与保护范围。此前1047份历史原证只是上轮最少数字，当前实际数应增不应凭旧数字定义全资产保护。

若D3启动，结束后只停止本次实际启动的本版APP/guard/Laravel/SFU/DB以及本次ADB reverse，保留Owner手机原有安装和数据、历史SQL/APK/volume，绝不stop global ADB/Docker/WSL或清理dirty根。若D3未启动，不能写`RUNTIME_PASS`或宣称启动后停用资源。GitHub公开仅报告/安全测试源码，绝不上交JWT、原网络candidate、手机标识、密钥、音频或私密日志；公共安全白名单先静态检查，失败不发布敏感证据。

**最终停止门：`V10.1.5_ICE_DIAGNOSTIC_CAPABILITY_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。** Codex不得自行裁决整个v10.1.5接受、自动集成main、扩大设备/网络权限、删历史保护原证或开启新长任务。
