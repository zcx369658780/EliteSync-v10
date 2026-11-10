# EliteSync v10.1.5｜Owner批准的单真机USB＋真实麦克风RTC专项长任务

2026-10-22（Asia/Singapore）。
**OWNER_AUTHORIZED_ONE_ANDROID_PHONE_USB_AND_TEST_APP_MIC / PLAN_A_RETAINED / MANUAL_CODEX_DISPATCH_AND_DEVICE_CONNECT_PENDING / ONE_BOUNDED_PHONE_TASK / NO_AUTO_R2 / V10.1.5_PARTIAL_NOT_ACCEPTED / NO_MAIN_INTEGRATION**

## 一、授权解释与唯一目标

Owner本轮明确：“我有一台，并且可以通过USB连接的同时使用真机麦克风接受合成测试音。请继续下达任务单，后续我会连入手机让codex操作。”

这构成**对一台Owner实际连接且同意调试的安卓实体手机**的有限使用授权：可在Owner物理连接设备、确认USB调试授权后，使用现有ADB工具读取必要非敏感设备兼容性信息、以受控独立包安装/启动本版开发APP、按Android自身权限模型允许该**测试APP**在短时间内使用手机真实麦克风采集**合成测试音**，并验证已有本地合法RTC软件通路。手机麦克风采集的是外部播放的合成测试音，不是ADB数字PCM注入，也不授权录制Owner的真实谈话或隐私声音。

**未授权**真实手机摄像头、宿主电脑麦克风、无关APP或手机资料访问、手机数据抹除/恢复出厂/卸载其他APP、系统ROOT、无线ADB监听、宿主公网/LAN监听扩面、UDP/防火墙/UAC修改、新SDK/镜像/付费服务、Production、真实账户数据或不可逆设备修改。只允许按需临时创建/删除**本设备、本任务具名ADB TCP reverse**，不改系统级网络安全配置。凡超出此范围立即停相关分项向Owner单独申请，不因“请继续”作宽泛推定。

**唯一目标：** 绕开旧AVD Emulator Controller的合成音频RPC死锁/阻塞，以手机自己的真实麦克风采集离线生成或已有设备扬声器播放的低音量440/880Hz短合成音，验证“手机APP录音采集→当前合法身份/RTC guard→隔离SFU→可观察到的音频媒体”是否建立；在已证真实流动媒体的前提下尽可能进行严格撤权、旧JWT和重连证据补充。鉴于只有**一台真机**，第二端如仍是媒体不通的AVD，**不能把单真机采集、SFU单向track、headless合成订阅者或控制端点成功写成“双端APP音频PASS”**。没有第二个真正有权、可用且独立的APP端时，冻结AC-10.1.5-05完整四硬门仍可能保持OPEN；这是允许的诚实出口，而非本版自动接受。

## 二、固定真值（开工重新读实时对象）

仓库 zcx369658780/EliteSync-v10，签发任务前main为 bb33953fef32a3327113798e33094dfdef6d7098，仅文档，开工重新GET精确main和产品Tree；不要从main反向覆盖已交付的v10.1.5 R1产品。

- 方案A Owner决定：docs/versions/v10.1.5/OWNER_PLAN_A_PHONE_TEST_DIRECTION_20261022.md；Blob a5a0ab1f99e0fd76365820e51af6ac3f83bb9a43。
- 最新RTC环境独立复审：docs/versions/v10.1.5/rtc_env_gate_independent_review.md；Blob 0a603a8803995ec3217053fd73a14229e44a00df。
- RTC环境最终未接受交付Commit：7a5dc0d85ef82fdfc5db4a098ae4150164e2b999；此前两份RTC诊断文档固定且源码SOURCE_UNCHANGED。
- v10.1.5 R1固定源码Commit：1c5cd2bb7919c435e8486a76959db75e9ccc367f，Root Tree 165eb1f362db533ca94bfe1db677ff6f7bd477ed，完整apps 0784c8aa7b0915a04b83693a45401197e31d93a2，services 1e1e20bb3500bedb1a521e5f2ddeece915d09424。
- 冻结plan：docs/versions/v10.1.5/plan.md Blob 7d3466b3be67135dc641cfee7c7faef78937ba03；正式AC-10.1.5-05与v10.0.9 RTC fail-closed安全边界不变。R1初次/环境诊断和原有独立评审全部保留。

定点读源码：Flutter RtcLiveKitService/rtc_remote_data_source/RTC Screen，Laravel RtcController/RtcGuardController/RtcAuthorityService/RtcSessionService/LiveKitTokenService，原隔离SFU/guard/bridge以及实际Android开发包的版本、包名、ABI及127.0.0.1 API配置。不要开展大范围考古或另写多份规划。

## 三、Codex连续执行六门（不逐步索取重复授权）

**P0｜等待可见的Owner连接；设备归属与非侵入保护**

本任务下发时手机可能尚未插入。Codex真正执行前应检查ADB设备列表，**仅有Owner已USB连接、已在手机端亲自确认调试信任且状态为device的实体手机**方可操作；若未连接/unauthorized/offline，则报告READY_AWAITING_OWNER_DEVICE，停止在门前，不假装已连接、不尝试远程无线配对/修改手机设置。所有ADB必须指定确切选定设备序列号且不得打印、上传或在公共报告展示完整序列号/手机号/联系人等隐私；不盲选其他已连AVD和用户手机。可以读取必要Android版本、API level、ABI、音频输入可用性、存储空间、受控包名状态。不得访问DCIM、通讯录、短信、账户、相册、私人应用、备份或系统隐私日志；只保存匿名、最小RTC相关摘要。

安装前确认测试包名是否与用户既存APP冲突：优先复用已构建的v10.1.5 R1专用开发包身份 com.elitesync.v1015r1dev / versionCode 1010511；先核APK SHA256 2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466、ABI、包签名及该手机现有包状态。若已安装同包且含个人/非测试数据，不覆盖、不执行adb uninstall/pm clear；可在已接受隔离编译条件下创建另一个专属测试applicationId候选，但需先验证签名/依赖/作用域且不能清其他APP。使用Android提示取得仅测试包RECORD_AUDIO授权，Owner可随时撤回。不要默认摄像头、位置、照片、文件或其它运行权限。测试生成的音频短、音量适度，不采人声；未经Owner实际提供可用音源时不得虚构麦克风收到440Hz。

**P1｜最低网络路径核验（USB只证明ADB，不证明WebRTC）**

验证USB端设备调试链后，先以只读请求确认原本精确归属的本地Laravel/guard和已有受控SFU监听端口及其所有者、有效APP_DB_CONNECTION/DB_CONNECTION/URL/host/port/DB name/APP_ENV与旧资源恢复点。仅在已有loopback接口与明确本任务服务归属匹配时，允许创建**最少命名的adb reverse tcp映射**，用于手机到受控本地API/guard的TCP传输；所有映射具名、检查占用、保留前后清单，只删除本次创建的映射。不要因ADB reverse成功就宣告SFU信令或ICE成功。

分别检查 (a) 实际APP返回的SFU/guard WebSocket地址与phone侧可达性、(b) 服务端向手机发送的ICE candidate/媒体路由与所用TCP/UDP、(c) 是否经现有保护代理受权进入而非直通raw SFU。LiveKit存在WebSocket信令与独立ICE UDP/TCP媒体端口，本机127.0.0.1在不同设备有不同意义；对不可达的candidate必须给出实际trace和精确限制，**不允许**自动暴露LAN、公网、开启UDP/防火墙、修改NAT/TURN或关闭auth gate。若ADB仅能达HTTP而不能建立受控ICE媒体，停在NETWORK_MEDIA_PATH_BLOCKED并列明Owner下一次需要选择的具体最小方案。不得把无JWT的403写成旧RTC JWT拒绝PASS。

**P2｜手机真实采集与最小隐私音频证据**

仅在P1合法可达且Owner能提供已有扬声器播放的短合成音时，从真机专用包中实际进入已授权的RTC音频功能。验证手机硬件mic权限/SDK采集事件、可关联的音轨 publish attempt、SFU参与者/track状态与实际media统计。优先采用现有媒体/日志接口，不需要对整个设备录音或公开音频文件。若需要短时诊断捕获，仅合成音且LOCAL_ONLY，原始波形不上传GitHub；采集到的APP设备/网络摘要统一匿名化。

证明“PHONE_MIC_CAPTURE_SUPPORTED”需要真实APP/SDK采集行为；“PHONE_PUBLISH_REACHES_SFU”需要SFU实际track/RTP/字节等可交叉校验；“REMOTE_RECEIVE_SUPPORTED”还需第二个合法媒体接收端实际收到（AVD必须真的有媒体能力，或者本地已有且无需新增SDK的受控headless接收器）。headless订阅者不能冒称第二APP；只有合成音源本地播放、SDK麦克风授权或站内room建立，都不能代表远端媒体已到达。

**P3｜一台手机条件下尽可能验证RTC安全**

如果P2证成一条真实的手机→SFU流动音轨，可在同一独立合成账号会话里尝试服务端Block/MC撤销/正常结束等现有有权动作，记录确切事务COMMIT时间、SFU媒体实际停止及旧凭据重新进入的真实事实。统一时间源，测量必须把媒体仍流动的前状态和停止后的状态连上，严格解释5秒指标。不以RTC状态行ended、HTTP404、没有带JWT的403或停容器替代。若无合法正在流动媒体，则所有“媒体停止≤5秒”必须NOT_RUN；旧JWT令牌只能在隔离测试内使用并脱敏，不上传。

同call重连仅在真实媒体已经正常建立、并拥有明确相同call/epoch与可控通道的前提下执行。即使手机侧撤权效果具部分证据，若第二个真正双向媒体APP端不存在，AC-05整体验收仍然OPEN，分清SINGLE_PHONE_MEDIA_SECURITY_PARTIAL与DUAL_APP_CONTRACT_PASS。不得启用现有AVD -no-audio阻塞方案进行无界重试。

**P4｜最小定向修复与证据审查**

普通环境配置/ADB映射问题优先在本次自有、可回退的隔离资源中修复，不变更产品业务。若发现真实产品代码缺陷，允许在v10.1.5 RTC相关已冻结范围内做一个**有界修复候选**并运行相关定向测试/必要APK rebuild与同设备复测，不能更改冻结AC、绕过CN/MC/Block/旧JWT fail-closed、降低≤5秒目标或向生产引入测试开关。修复需独立非作者一次集中静态复核；若确属新设备/SDK/系统/网络权限需求，停该项报Owner，不擅自改变安全范围。

本版既有消息重试、离线密文、图片视频、通知等已审证据不重跑。RTC真实人耳AEC只在本次有合法音频流且用户愿意人工听感时作具名观察，不把测试频率识别当完整AEC质量结论；本次无摄像头许可，视频NOT_RUN。

**P5｜一次交付与归属资源停止**

唯一新报告：docs/versions/v10.1.5/PHONE_USB_RTC_GATE_REPORT.md。
唯一新证据清单：docs/versions/v10.1.5/phone_usb_rtc_gate_manifest.json。

报告含P0-P5逐项状态、手机Android/API/ABI匿名摘要、实际包/签名/Hash、ADB端口mapping及隔离网络身份、源Git SHA/Root/apps/services、所有RTC硬门与子门的PASS/PARTIAL/FAIL/ENV_BLOCKED/NOT_RUN、真实HTTP/ICE/media相互独立的观测、必要数据库与音频关联时序、非作者审阅、保护核验和停用回执。Codex本地原证归LOCAL_ONLY，GitHub仅少量匿名脱敏摘要及Git Blob清单，禁止设备序列号、真实麦克风环境音、个人数据、token/SFU secret、SQL/APK/私有录像公开上传。

如果源代码无修改，用SOURCE_UNCHANGED并保留R1接受待核apps/services Tree，候选只新增上述两份docs。若有修改，则从固定R1/RTC环境候选合法连续派生一次小范围Git提交，记录Parent/完整Tree和changed-path mode/Blob，普通非force发布，并停止等待Astra独立验收。任何候选都不得自动合main、签署ACCEPTED、删旧Review证据或开始v10.1.6。

仅停止本次实际启动的专属服务/容器/APP测试进程、移除本次ADB reverse；**不关闭整个ADB server、不删除真机APP/其他数据或旧数据库卷**。如用户需保留设备安装的测试APP，原样保留；若设备有敏感数据或清理需求，另报Owner批准。历史5保护根、旧SQL/APK/本版653份原证、原refs、原.env不动。

### 停止出口

- 如果手机尚未连接：DEVICE_NOT_PRESENT / AWAITING_OWNER_USB_CONNECTION；任何RTC实测NOT_RUN。
- 如果手机麦克风或ICE不可用：PHONE_PREFLIGHT_PARTIAL / IDENTIFIED_BOUNDED_BLOCKER；逐层列明缺口，停止。
- 如果单手机采集/流动音轨成立：SINGLE_PHONE_RTC_MEDIA_SUPPORTED（仅实测维度）/ AC05_DUAL_APP_STILL_OPEN；不得拿一台手机代表双端通过。
- 只有**两份独立实际APP**均传输真实媒体，且同call重连、旧JWT与撤权5秒等全部具合格证据时，才可标记AC05_EVIDENCE_READY_FOR_ASTRA_REREVIEW；依旧不自行签整版接受。

**明确禁止自动下一轮R2、main集成、产品发布、真实Push接入、新SDK下载/云端/费用/生产或真机系统不可逆变更。**
