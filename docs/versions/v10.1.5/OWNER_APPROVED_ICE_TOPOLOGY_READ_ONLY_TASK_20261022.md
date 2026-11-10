# EliteSync v10.1.5｜Owner批准的ICE Candidate及USB/SFU网络拓扑只读审计｜Codex唯一综合任务

日期：2026-10-22（Asia/Singapore）。
**OWNER_APPROVED_READ_ONLY_ICE_AUDIT / PLAN_A_RETAINED / ONE_BOUNDED_LONG_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_PENDING / NO_RUNTIME_OR_NETWORK_CHANGES / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / MAIN_PRODUCT_NOT_INTEGRATED**

## 一、任务批准与唯一目的

在Astra完成`phone_usb_rtc_independent_review.md`（以下简称“真机复审”）后，Owner明确回复“可以我同意，请继续”，批准**上一轮建议的仅一次只读ICE Candidate／网络拓扑与既有SFU配置证据审计**。该批准不包括再次连接/控制手机、启动新的SFU/APP/DB/RTC通话、重新打包、创建ADB reverse、试连候选端口、修改本机网络、防火墙、UDP/TURN、Docker端口或产品代码；无采购、真实用户或生产环境权限。此前Owner方案A仍生效，冻结AC-10.1.5-05不改变。

唯一目标：使用**已有固定源码、配置与上一轮LOCAL_ONLY原始证据**，在不启动任何服务/手机/网络探测的条件下，解释为什么“Phone APP已合法登录并完成保护信令，Room.connect约30.224秒超时、未形成ICE媒体”。形成可审的**信令与ICE相互独立的拓扑／Candidate对照表**，识别已经有直接证据支持的配置矛盾、仍不确定的环节、无需新权限的理论可行路径，以及各项实测需要何种最小新权限。绝不可把推测冒称根因或成功连接。

## 二、冻结真值及上位证据（开工重新GET）

- 仓库：`zcx369658780/EliteSync-v10`；任务签发前live main `195f1087d2f5ac7c0c4648f0211a0034a58c71c8`。本任务签发后可能有纯文档后继，开工重新核当前main，但**不得把main当v10.1.5产品开发基线，也不得用reset/pull覆盖现有R1候选**。
- Owner选择方案A文档`docs/versions/v10.1.5/OWNER_PLAN_A_PHONE_TEST_DIRECTION_20261022.md` Blob `a5a0ab1f99e0fd76365820e51af6ac3f83bb9a43`；既有单真机任务`OWNER_APPROVED_SINGLE_PHONE_USB_RTC_TASK_20261022.md` Blob `b4d048ac931d66500e8d312fb7d80eb790121216`。
- 单真机最终交付：`fe2e4397e4db894257276238c1a3118ba3c6a5f9`，Parent `7a5dc0d85ef82fdfc5db4a098ae4150164e2b999`；`PHONE_USB_RTC_GATE_REPORT.md` Blob `bf936c300d6b12b0f4ecae0b083dca277035f784`；`phone_usb_rtc_gate_manifest.json` Blob `d2e0f15623e7f1a05513f4ae2286f396db523a0c`。
- Astra独立真机复审`docs/versions/v10.1.5/phone_usb_rtc_independent_review.md`，Blob `fcd62d873ead2ac5e9884ecf2a6db654c138dff4`；关键结论`PARTIAL / NOT_ACCEPTED / ICE_MEDIA_PATH_BLOCKED / AC05_OPEN`。
- 原R1固定源码Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`，apps `0784c8aa7b0915a04b83693a45401197e31d93a2`，services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`；冻结plan`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`，AC-05四硬门不变。
- 本次固定已知事实：**一部Android真机APP＋一个HTTP-only peer**；后者没有LiveKit SDK、不采集/接收音频；本版此前不启动第二AVD；USB reverse仅TCP 8031/8032/7894/7891并已撤除；SFU/保护gateway与Docker端口均host loopback；Phone到7891/7894的空TCP connect测试exit0，**不等于ICE握手成功**；Call3的`Room.connect`约30.224s后`MediaConnectException`；SFU观察一个JOINED参与者、`connectionType=unknown`，60条**具有显式tracks字段**的样本全空，另655条样本无此字段，不能误计为“655条无track”。音频权限granted不等于采集已开始，当前代码是Room.connect成功后才启麦。四硬门双端有效媒体、same-call重连、旧JWT拒绝、撤权COMMIT后≤5秒停止均`NOT_VERIFIED/NOT_RUN`。
- 旧v10.1.4 main接受产品不变；v10.1.5产品本轮只读，不得到新功能接受或main集成。

## 三、严格的只读权限边界

**准许**：读取源代码与当前归属本项目的历史LOCAL_ONLY日志/配置/观测/既有命令回执；必要时离线计算SHA、对已完成采样计算数量/分组/隐私白名单摘要，查看Git对象与已退出容器的**历史只读元数据**（非启动容器、非启动DB）；在原有安全范围内借助现成解释器解析JSON/ICE候选格式；一次有界非作者只读审查。允许对**既有本地原件的私密候选地址**作只读比较，但原始IP/设备标识/内网结构仅留在已归属LOCAL_ONLY安全证据里。

**禁止**：启动或操控手机、安装卸载包、读取手机个人资料、adb shell/port forward/reverse、开启/关闭容器/API/guard/LiveKit、实际HTTP/WS/ICE网络访问或connectivity probe、改SFU YAML/LiveKit候选地址、改Android Manifest或ICE SDK、换镜像/SDK、改防火墙/UDP/路由/TURN/代理、扫端口、创建SQL测试数据、动数据库、擅自登录账号、产生新媒体、出网查询私有候选或发送raw日志给公开模型/第三方。若必须依赖新实测才能决定，请列为`EVIDENCE_GAP`，**不要偷偷做新实验**。历史工作树/分支/SQL/APK/730份或更多已登记原证/密钥一律保持，原失败exit和负例不可改写。

证据隐私：所有公开GitHub任务报告和发给GPT的摘要只使用**类型、候选类别、协议、端口、接口/拓扑角色、匹配或失配状态**；不写手机真实序列号、MAC、SSID、私人IP具体数值、SFU secret/JWT、真实个人数据、ICE candidate原始文本、SQL或完整设备日志。可以采用稳定非可逆替代ID `PHONE_LOOPBACK`、`HOST_LOOPBACK`、`SFU_CONTAINER_PRIVATE`、`LAN_PRIVATE`、`UNKNOWN_REMOTE`，IP版本和端口可根据风险最小化显示。不得将加盐可逆映射表公开，必要原始值仅本机隔离。

## 四、唯一连续执行步骤（A0～A5）

### A0 固定原件、时间层与可读性

1. 只读确认live main及原R1/单机报告Git SHA、Source Tree、报告Blob，记录本机拥有者与候选原件的路径/hash；优先复用过去已审过的报告/manifest/源及**明确归属的上一轮LOCAL_ONLY原证目录**，只查与ICE失败相关文件，不回溯9.x全仓或重复v10.1.5接受测试。
2. 目录、数据库或日志不可用，立即在结果中标`LOCAL_EVIDENCE_UNAVAILABLE`；可用GitHub的脱敏报告继续做`DOCUMENTARY_ONLY`，但绝不假定已经看到原始candidate/pcap。
3. 单独记录各时间域（Android epoch、SDK connection clock、SFU日志、host wall/monotonic）可否对齐；保留`Room.connect`起止约30.224s的真值来源，禁止混淆HTTP超时、信令完成、ICE协商完成和媒体发布。

### A1 三平面的静态拓扑与Authority核对

只读取定点源码、受控旧部署配置/旧进程启动参数：
- **身份／业务面**：Laravel `RtcController`、`RtcGuardController`、`RtcAuthorityService`、`LiveKitTokenService`的授权、call状态、房间/epoch、SDK join信息；不读取/展示JWT或网关secret。
- **信令面**：APP `RtcLiveKitService`调用`Room.connect`前获得的SDK URL与保护gateway最终代理到的LiveKit信令入口，TLS/WS/WSS、host/端口、设备侧 `127.0.0.1` 的真实含义、ADB reverse 8031/8032/7894/7891的用途，以及host loopback与Docker NAT绑定。
- **媒体面**：历史SFU配置中的`rtc.tcp_port`、`rtc.udp_port`或port-range、`use_external_ip`/NAT候选宣告、容器/host port-binding、SFU内部候选地址与Phone可用端点；区分 raw LiveKit API/WS、受控gateway、ICE/TCP或ICE/UDP及其它relay。只引用本项目旧测试的实际配置，不将LiveKit默认端口假定为本次实际配置。
- 每处写`SOURCE_LINE/CONFIG_RECEIPT/RUNTIME_RECEIPT/UNKNOWN`及固定Git Blob或LOCAL_ONLY证据hash，不能只凭运行日志中的`JOINED`宣称有效 ICE Selected Pair。

### A2 ICE Candidate与真实连接结果对照（本任务中心）

对上一轮日志中**已经存在**的（如有）客户端local/remote candidate、server advertised candidate、selected candidate pair/ICE state、TCP connect与Docker绑定逐项比较。输出公开矩阵每行至少：
`phase, side, source_credential_boundary, candidate_type(host/srflx/relay/prflx/UNKNOWN), protocol(UDP/TCP), tcp_type(if any), address_class, advertised_port, listener_role/port, phone_reachability_class, adb_reverse_match, docker_publish_match, pair_state, recorded_error, evidence_ID, conclusion_confidence`。

若旧日志只有SFU server candidate、没有Phone local candidate/selected pair/ICE state，明确标`MISSING`，绝不可补造“失败候选对”。把`tcp socket connected`、`guard JOINED`、`ICE connected`、`DTLS connected`、`media publish/receive`区分为不同结果；一项成功不能自动推进另一项。

专门评估**假设而非预设原因**：
- 设备侧localhost仅通过已命名TCP reverse到达哪些服务？SFU ICE候选宣告的地址类别与端口是否也处于这个路径？
- 候选协议是不是UDP而现有USB reverse只有TCP？ICE/TCP候选若存在，其`tcptype active/passive`与SFU listen及Android network path是否可形成真实握手？
- 容器私网/loopback/LAN候选若被宣告，是否可从Android真实网络命名空间达？有无旧时间线内实际ICE succeeded/pair selected记录？
- 本机empty TCP connect成功但WebRTC超时是否说明`候选地址／协议／握手行为`有证据不足？
- 某候选缺失是`NOT_OBSERVED_IN_AVAILABLE_LOGS`还是`CONFIRMED_NOT_ADVERTISED`？两者不得混写。
把任何`可能`单列`HYPOTHESIS`并给具名证伪所需的**将来最小证据**。

### A3 方案比较及Owner权限门（只做纸面设计，绝不实施）

给出最多3个且确有依据的**候选网络路径**（若证据不足，可仅给1～2个或`NO_VERIFIED_PATH`）：
1. 已获准的USB+host loopback+真实ICE/TCP：能否不用新权限，仅凭静态配置和既存接口形成正确候选？若未知说明为何；不要声称“adb reverse成功因此WebRTC可用”。
2. 需要Owner**单独批准**的最小隔离LAN/ICE/TCP、ICE/UDP或类似替代路径：仅罗列具体协议/端口类型、绑定设备、隔离、回滚/风险与未来必测负例，不配置、不监听、不动防火墙；真实IP不得公开。
3. 第二独立媒体APP端可能来自另一个已拥有且确实媒体可用的设备；现在只有一个真机和HTTP peer，故**任何方案都不能直接关闭冻结AC05双APP合同**。仅说明未来作为独立门禁的所需条件，不代替Owner购买或授权第二设备。

对每方案标`WITHIN_EXISTING_PERMISSION_THEORETICAL / NEEDS_OWNER_EXPLICIT_PERMISSION / UNSUPPORTED`，并写清楚能观察到什么才会转为`VERIFY_READY`，不自行选实施方案。优先推荐**一条最小、可回退、不会暴露raw SFU或削弱RTC授权的验证路线**；如任何路径必须新端口/公网/不确定设备操作，则停在Owner门禁。

### A4 有界审查与限制

非作者一次静态复核：检查原始证据是否足以支持结论、候选端口/设备命名空间对照是否误解、控制HTTP端是否被冒称第二APP、旧RTC JWT及5秒流动媒体限制是否仍准确、是否存在隐私地址/凭据越界。必要时修正**本次新审计文档**，不得修正历史源码/冻住的AC或原失败回执。可用LiveKit官方静态技术文档作`EXTERNAL_REFERENCE_NOT_PROJECT_EVIDENCE`：`https://docs.livekit.io/transport/self-hosting/ports-firewall/`和`https://docs.livekit.io/intro/basics/connect/`；Android adb reverse参考`https://developer.android.com/develop/ui/views/layout/webapps/access-local-server`。外部说明可解释概念，**不能**覆盖实际配置和Local-only日志。

### A5 唯一集中交付与停止

本任务**仅生成**：
- `docs/versions/v10.1.5/ICE_TOPOLOGY_READ_ONLY_AUDIT.md`
- `docs/versions/v10.1.5/ice_topology_read_only_manifest.json`

两份文档中包含：固定Authority/Blob与本版产品完整Tree、A0～A4分层结论、ICE candidate matrix、每个假设`CONFIRMED / SUPPORTED / HYPOTHESIS / UNKNOWN`和有证据来源、最小将来授权提案、明确无法获得的LOCAL_ONLY原证、公开材料白名单验证、保护前后状态、非作者有界复核，以及`RUNTIME_NOT_RUN / PHONE_NOT_TOUCHED / SOURCE_UNCHANGED`。

Codex只在**单一干净且归属确定的隔离工作树**创建上述两份文档，保留原dirty根、旧候选、Review分支、所有SQL/APK/手机数据、本版数据库卷和保护对象；普通nonforce发布候选并校验最终Git SHA/Tree、两文档Blob以及相对R1固定产品**apps/services子Tree全等**。不自动更新主线已接受产品、不修改旧`ACTIVE_STATE`或冻结文档、不删除旧审阅分支、旧RTC环境/真机报告，不把PRIVATE候选值或JWT上传公开仓库。

**出口**：`V10.1.5_ICE_TOPOLOGY_AUDIT_DELIVERED / READ_ONLY / SOURCE_UNCHANGED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_RUNTIME / NO_R2`。如果依据不足，必须写`DOCUMENTARY_ONLY / MISSING_ICE_CANDIDATE_EVIDENCE`并准确给出最小需要新增的**未来**证据/权限，不能假定审计已解决ICE连接。提交后停止等待Astra独立复审及Owner明确决定；不运行媒体测试、不自行签ACCEPTED、不合main、不启动v10.1.6。
