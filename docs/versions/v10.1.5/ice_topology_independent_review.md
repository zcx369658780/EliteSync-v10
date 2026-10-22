# EliteSync v10.1.5｜Astra ICE Candidate／USB-SFU拓扑只读审计独立复审

2026-10-22（Asia/Singapore）。评审者：Astra／EliteSync GPT顾问。
**READ_ONLY_AUDIT_SCOPE_ACCEPTED_WITH_OBSERVATIONS / SOURCE_UNCHANGED / NO_VERIFIED_ICE_MEDIA_PATH / AC05_OPEN / V10.1.5_PARTIAL_NOT_ACCEPTED / OWNER_DECISION_REQUIRED / NO_R2 / MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED**。

**独立裁决分层**：此次只读调查作为受限**技术证据整理和方案筛选**的交付予以`ACCEPTED_WITH_OBSERVATIONS`，不授予其`ACTUAL_ICE_PATH_VERIFIED`、`RTC_MEDIA_PASS`、v10.1.5整版`FUNCTION_ACCEPTED`或任何网络改动／集成权限。以下Astra直接读取的固定GitHub对象、源码、清单矩阵属于`ASTRA_GITHUB_DIRECT`；上一轮Codex在Windows/Android/SFU产生并由本次Codex本地只读分析的**LOCAL_ONLY原始日志、私密ICE Candidate、SFU秘密配置和907个保护文件**没有被Astra亲自读取或实地重算，仍为`CODEX_REPORTED/LOCAL_ONLY`。不存在Astra现场重新执行的设备/ICE/网络实验。

## 一、身份与范围独立核验

- 原任务`docs/versions/v10.1.5/OWNER_APPROVED_ICE_TOPOLOGY_READ_ONLY_TASK_20261022.md` Blob `994fdb154c898faf7e6f55f85c5dbd86ff603612`；旧方案A`a5a0ab1f99e0fd76365820e51af6ac3f83bb9a43`与冻结plan`7d3466b3be67135dc641cfee7c7faef78937ba03`继续生效。
- Astra本次复核前live main `51154041ed10da582c962c86b30d554cfcd1bb86`，仅已接受v10.1.4产品：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。旧v10.1.5 R1源 `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，完整apps `0784c8aa7b0915a04b83693a45401197e31d93a2`／services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。
- 审计交付Commit **`7fd2b9f205df7edcf4f713d1374e924e6a6caad6`**，Root Tree **`fd50d00e817ceabdbd5fc35b84ebd0dba55cc5a1`**，唯一Parent `fe2e4397e4db894257276238c1a3118ba3c6a5f9`，GitHub compare ahead1/behind0：仅新增`docs/versions/v10.1.5/ICE_TOPOLOGY_READ_ONLY_AUDIT.md`（Blob `bffb7d1fb520fdd5da6e7e24a9b9a06a6c237971`）和`ice_topology_read_only_manifest.json`（Blob `cbbe7ff5c61a0f66b1dee7674f6c5b20bff98b3d`）两份文档。
- Astra直接GET提交与父提交的Git Tree：**完整apps和services子Tree在两次提交间逐一精确相等**，只docs子Tree不同；因此`SOURCE_UNCHANGED`直接成立，不需要把本次审计说成新增RTC源码。
- 直接读取固定源码中的`RtcLiveKitService.ensureConnected`连接选项及启麦位置、`RtcController::livekit`和`RtcAuthorityService`：当前客户端尝试`room.connect`并在成功后才`setMicrophoneEnabled(true)`，源内连接超时配置为30秒。信令JWT发行与current authority使用点仍在既有保护链，但**静态读取并不证明真实ICE握手、旧JWT失败或撤权5秒停止**。

## 二、审计矩阵独立一致性检查

- `artifact_manifest`内有7组Candidate，全部存在Task要求的16个字段。Astra根据`candidate_matrix[].record_count`独立汇总为**20条快照记录**（publisher 9／subscriber 11），其中SFU本地TCP **2**、Phone侧UDP **12**、Phone侧TCP **6**，与`candidate_counts`及正文数字一致。P9/S11是SFU publisher/subscriber记录，不得说成两份真人或两APP媒体验证；phone的18次回调未含逐条匹配identity，不能强行一一关联。
- `M01` SFU IPv4 loopback TCP 7891与报告保存的旧配置、USB reverse、host→Docker发布**端口号和协议相符**，但手机/宿主/容器三个不同命名空间的同一个loopback字面地址不等于实际选中/连通。**不存在可从GitHub直接确认的实际容器ICE listener接口、TCP active/passive/tcptype、STUN检查或selected pair**。
- Phone UDP记录在已有的**TCP-only** USB反向映射中没有对应UDP通路；这不能推断全部candidate都是UDP，亦不能推断USB TCP方案原理上失败或“必须开放UDP”。Phone TCP记录端口是LOCAL_ONLY观测值，`tcpType`缺失，因此不能凭高端口推断主动或被动角色及OS端口分配来源。
- 之前真实APP `Room.connect`约30.224秒后失败的本机运行证据由报告引用，非本轮重新执行；715条观测记录中**仅60条含显式tracks字段，均无音轨；其余655条无该字段**，不能改写为715条都证明零轨。generic packet计数缺codec/track归属，不是媒体RTP PASS。SFU `JOINED`不等于ICE selected pair、DTLS connected、mic采集／publish或远端接收。
- 同一设备自身的start/fail间隔可记录，但Android/容器/host未进行可信跨钟校准，**无撤权COMMIT→真实流动媒体停止≤5秒**可测。正常HTTP end及控制面授权不能代替RTC实物。
- 清单`sources`中S1～S5源Blob、RTC媒体后启麦时序、静态授权实现经过有界GitHub对照。E01～E20原始证据仅由Codex声称在归属目录可读，带hash/bytes；`907/907`旧证据和489 refs/5根/私密env保护仍为Codex本地回执，Astra不假装已本机哈希核对。

## 三、结论分类与方案裁决

| 判断 | Astra裁决 |
|---|---|
| 既有信令业务授权、手机APP到受保护gateway信令成功 | `SUPPORTED_BY_PREVIOUS_CODEX_LOCAL_RECEIPTS`，非本轮ICE验证 |
| SFU本地TCP7891候选与reverse、Docker转发协议/数字一致 | `SUPPORTED_BY_AUDIT_SOURCE_MATRIX`，不等于listener/握手可达 |
| 实际ICE/TCP selected pair、STUN和DTLS | `MISSING / UNKNOWN` |
| Phone UDP通过原有USB TCP reverse | `NO_RECORDED_UDP_TUNNEL`；不能据此定唯一根因 |
| ICE失败的特定原因 | **`ROOT_CAUSE_UNDETERMINED`** |
| 手机采音、音频发布与远端接收 | `NOT_VERIFIED` |
| 双端APP媒体、同call重连、旧JWT及≤5秒真实媒体撤权 | `AC05_OPEN / NOT_RUN` |
| 本次只读审计和有限方案分析 | **`ACCEPTED_WITH_OBSERVATIONS`** |

两条纸面路线均具名且没有实施：
- **P1（优先的最小诊断方向）**：保持当前USB＋host loopback＋隔离ICE/TCP思路，先在将来获准的受控运行窗口查`tcpType`／candidate pair与**实际容器监听/ICE帧**，再决定既有路径是否能成立；目前`WITHIN_EXISTING_PERMISSION_THEORETICAL / NO_VERIFIED_PATH`。这既非自动重试授权，也非宣布USB路径完全可用。
- **P2（备选）**：针对已有手机的单私网接口隔离LAN ICE/TCP，仅在Owner以后明确批准设备、接口、7891/TCP临时bind/publish、候选宣告及必要具名防火墙策略后考虑；目前`NEEDS_OWNER_EXPLICIT_PERMISSION`。不得自动开启LAN、UDP、TURN、新SDK/设备、公网监听或绕开raw SFU防护。

**额外边界**：当前只有一台实际Android APP，另一端是`HTTP_ONLY`控制peer；即便单手机网络ICE成功，仍不满足“两份独立真实APP双向媒体”冻结要求。这个阻断必须与网络ICE分开管理。

## 四、下一门禁与项目处置

本次已完成**审计流程**，不是完成**RTC功能**。不自动派发R2或新的实测任务，不再重复同样的USB空TCP探测，不改冻结AC、不集成产品main、不启动v10.1.6。Owner此前方案A不改变：v10.1.5继续`PARTIAL / NOT_ACCEPTED / RTC_ICE_MEDIA_UNVERIFIED`，已验消息、加密缓存、私有媒体、通知等限定成果继续保留。

建议Owner未来优先决定是否批准**一次更小的ICE观测补证任务**：只使用当前已拥有的一台真机、已隔离开发SFU/guard与合法账号，在不更换网络方案的前提下，以短时有界观测拿到`tcpType`、candidate-pair checking/nominated、STUN请求响应及容器内**实际ICE listener绑定**。只有这些数据显示既有路径不成立，才考虑P2；如任何观测涉及新的原始ICE外传、网络监听面、设备权限或SDK，必须分别授权并做停止/回滚。不把这段建议当本轮已获准执行的任务。

**最终**：`V10.1.5_ICE_READ_ONLY_AUDIT_INDEPENDENTLY_ACCEPTED_WITH_OBSERVATIONS / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTOMATIC_R2 / MAIN_PRODUCT_NOT_INTEGRATED`。历史候选与私密原证不清理。
