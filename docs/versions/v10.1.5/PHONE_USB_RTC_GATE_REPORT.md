# v10.1.5 单真机 USB RTC 专项执行报告

2026-10-22。**PARTIAL / PHONE_PREFLIGHT_PARTIAL / NETWORK_MEDIA_PATH_BLOCKED / SOURCE_UNCHANGED / AC05_DUAL_APP_STILL_OPEN / AWAITING_ASTRA_INDEPENDENT_FUNCTION_REREVIEW**。

真机已安装、启动并成功登录固定 R1 开发包；手机到受保护 SFU 的信令成立，但 WebRTC ICE 媒体连接超时。未证成真实采音、音频 publish、远端接收、同 call 媒体重连或撤权 COMMIT 后媒体停止≤5秒。没有第二个音频 APP；未启动 AVD。保持 v10.1.5 PARTIAL，未自行 ACCEPTED、集成 main、开启 R2/v10.1.6。

## 固定权威与源码

- 唯一任务 `OWNER_APPROVED_SINGLE_PHONE_USB_RTC_TASK_20261022.md`，Git Blob `b4d048ac931d66500e8d312fb7d80eb790121216`，完整读取并按原始 Git blob bytes 重新计算身份一致。
- 冻结 plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；方案 A Blob `a5a0ab1f99e0fd76365820e51af6ac3f83bb9a43`；环境独立复审 Blob `0a603a8803995ec3217053fd73a14229e44a00df`。未改变 AC。
- 实时 main 核验 `d161388a53b06bd71b33f85a9fe1df7b110bfba1`，其 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；它们不反向覆盖 R1 产品。
- 固定 R1 产品源码 `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`；apps `0784c8aa7b0915a04b83693a45401197e31d93a2`，services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。
- 本候选连续派生父提交 `7a5dc0d85ef82fdfc5db4a098ae4150164e2b999`，父 Root `129c35a9163f68991dcc7e862e027f571438b13a`；分支 `codex/v10.1.5-phone-usb-rtc`。只新增本报告和 `phone_usb_rtc_gate_manifest.json`。最终候选 SHA/Root/两份文档 Blob 由发布后本地身份与 GitHub 固定 SHA 回读回执给出，避免文档自引用哈希。

## P0—P5 逐门结果

| 门 | 结果 | 实测与限制 |
|---|---|---|
| P0 归属、兼容、安装 | PASS（限这些子项） | 唯一 Owner USB 手机匿名 PHONE_A，ADB device；Windows USB PnP 对精确选定设备匹配。Android16/API36、arm64-v8a、mic feature=true、安装前无同包，/data 可用255720680KiB。首次安装被手机拒绝；Owner明确允许重试一次后成功。 |
| P1 受控信令与路径 | PARTIAL | 真机 APP 登录成功；USB reverse 仅8031、8032、7894、7891，后端及 SFU host 端口仅loopback。SFU观察到一名 JOINED 参与者，业务 accept/heartbeat成功。手机 shell 对7891/7894的空输入TCP connect均exit0，不能替代 WebRTC ICE。 |
| P2 真机采音与媒体 | ENV_BLOCKED | Owner明确音源/安静条件就绪，并亲自在Android提示允许RECORD_AUDIO。call3 Room.connect约30秒后MediaConnectException；SFU connectionType=unknown、参与者未建立连接、音轨为空。没有确认真实采集帧、已发布音轨或可归属音频RTP。 |
| P3 重连、旧JWT、5秒撤权 | NOT_RUN | 尚无合法流动音轨，未执行媒体重连、旧RTC JWT首次/重新入房或撤权媒体停止测试。正常end的HTTP200/ended不作为撤权或5秒停止证据。 |
| P4 有界修复与复核 | SOURCE_UNCHANGED | 修正自有启动入口/工作目录、配置本次内部观测；未改产品源码，无APK重建、整版回归或第二端媒体尝试。非作者结果见下。 |
| P5 集中交付与停用 | PASS（本次资源停用） | 正常end call3、force-stop本测试包，移除本次四条reverse；停止本次PHP/WS/observer/bridge/logcat与SFU、R1专用DB，保留容器、volume、手机安装与APP数据及ADB/Docker工具。保护终检见下。 |

## APK与设备授权身份

`com.elitesync.v1015r1dev` / versionCode `1010511` / versionName `10.1.5-r1-dev`，416357439 bytes；SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466`。现有apksigner验证exit0，签名证书SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。手机包路径回取base.apk并重算SHA256，字节身份相同，版本也一致。

仅RECORD_AUDIO获准；包级终检CAMERA、ACCESS_FINE_LOCATION均granted=false。未启用摄像头、宿主麦克风，未读取私人应用/照片/联系人/短信/账号或全设备日志；APP日志只按本测试包PID采集。手机应用已停止，安装、数据和该麦克风授权保留，未擅自撤权或清除。

## 实际通话和媒体证据边界

采用**一个真机APP＋一个独立合成账号HTTP控制端**：前者发起call，后者经真实Laravel接口accept/heartbeat。HTTP端不运行LiveKit SDK、不加入媒体房间、不采音或接收音频，不是模拟器或第二APP。控制端成功只证明业务状态；APP UI中的in_call不能升级为音频成功。

call2在准备观测期间未接听，正常missed，保留原件。call3由真机发起并由HTTP端立即接听；APP日志Room.connect start epochMs `1792649962969`，失败/leave epochMs `1792649993193`（约30.224秒）。SFU曾观察到一个JOINED参与者、零tracks，后以SIGNAL_SOURCE_CLOSE关闭，connectionType=unknown。服务器候选是loopback TCP7891，未改LAN、UDP、NAT/TURN、防火墙或UAC。远端候选的设备网络地址仅LOCAL_ONLY，公开材料不披露。

内部SFU观测共715个样本，区间epoch `1792649874.6283958`—`1792650054.5282998`；其中60个含显式tracks字段的样本均为空，其余655个样本无该字段，未观察到已发布音轨。末态通用packet指标incoming26/4102bytes、outgoing15/3065bytes；这些未绑定音轨/codec的计数**不是已证明的音频RTP**。信令PSRPC字节也不算音频。没有声称零网络数据或麦克风已经收到440/880Hz。

离线生成12秒低幅440/880Hz WAV，未自动播放；Owner确认就绪和权限获准，未确认扬声器实际播放或手机收到测试音。依据现有调用顺序，启麦位于成功Room.connect之后；本次失败发生在此前，因此PHONE_MIC_CAPTURE_SUPPORTED、PHONE_PUBLISH_REACHES_SFU和REMOTE_RECEIVE_SUPPORTED均未证成。没有原始环境录音或公开音频波形。

## 环境、数据库和安全阈值

复用已核归属的独立库 `elitesync_v1015_r1_dev`，container ID `fa7862c5066e8b037980ce8838cec2f3cc07c0ad2022538fd3139a78e2dad407`，volume `elitesync-v1015-r1-data-20261022`，host127.0.0.1:43327。有效APP_ENV=local，APP_DB_CONNECTION/DB_CONNECTION=mysql，双套host/port/database一致，URL/socket为空；实际identity命令exit0、93张表、restoration=true。启动前核container/mount/loopback与原恢复点；无迁移、旧库覆盖或历史同意复活。

复制原恢复点SHA256 `2765cd0f6803004207cd9db2c152601b6aa448a77aaae1c0d98011aa349d8b40`。本次前后备份均exit0；前165365bytes/SHA256 `7dc8a17f29c7425dc3ec33126ee610390b691adcceedd646d4cb5b4baefaeb14`，后177609bytes/SHA256 `dae557065fbe7828216b1a7a35edc0b42b3606d3cffb817ad5fcebd78aab765a`。

仅增加本任务虚构账号7/8及合法fixture关系，通过既有LiveConsentService request/accept建立CN/MC；测试用户数据的DB is_synthetic=false，沿用R1普通身份运行链，测试issuer保持disabled，不宣称真实身份验证。增加一条setup消息、登录/同意/RTC等行；主代理的LOCAL_ONLY SQL比较回执记录原21个有数据表的178行tuple全部保留，旧6用户未改，新总数8；比较不覆盖元数据和自增计数。具体新增表计数在manifest和LOCAL_ONLY回执中，SQL不上传。

SFU只用原镜像 `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`，新专属容器 `elitesync-v1015-phone-rtc`；raw7880不发布，host只发布loopback7894/7891 TCP。本次新密钥不打印/上传；内部Prometheus7889仅docker exec读取，无新增host发布。API upstream8030、proxy8031、WS8032、guard8033均host loopback。

先guard readiness后启动SFU：两个HTTP200样本约3610ms/109ms；首个冷启动是启动前就绪探测，不放宽运行时门限。整个已采健康样本210个，最大sweep138.277ms；authority_monitor_failed=0、sfu_fail_closed=0。保留bridge1.5秒、reply200×0.01秒、入口2.5秒、watchdog3.5秒，未降fail-closed或5秒标准。这只证明本轮控制监测未复现上次故障，不证明媒体通过。

## 原始失败、命令和未验证门禁

LOCAL_ONLY保留命令stdout/stderr/exit和原失败：

- 原install exit1：INSTALL_FAILED_USER_RESTRICTED / Install canceled by user；Owner批准重试一次，retry1 exit0/Success。
- 原启动假定activity `.MainActivity` exit1；核APK manifest后改为实际 `com.elitesync.MainActivity`，launch exit0。
- 原PHP启动cwd错误导致router找不到index.php，readiness非JSON解析失败；保存stderr后仅修正自有PHP cwd为public，随后readiness HTTP200。未当作产品缺陷。
- Windows listener枚举未列出Docker映射，初次路径断言失败；随后Docker精确PortBindings加host socket connect确认loopback端口；没有修改监听/防火墙。
- call2 missed；call3实际MediaConnectException及SFU候选/无track记录保留，未自动无界重试。
- 首次保护status比较误用untracked-files=all，与原目录级基线格式不一致；按原默认格式重比通过。reverse原字串比较因CRLF序列化失败，实际mapping四条已移除，按非空条目对比基线恢复。初次SQL行解析未处理多行INSERT、错误得到0行，已明确作废，改为多行tuple解析并用旧用户6行作为非空断言；不会将空集合比较写成保护通过。

主要真实操作：选定设备的install --no-incremental、包级pm path/dumpsys和base.apk回取、指定实际activity启动、四条reverse --no-rebind与精确remove、仅测试包PID logcat、真实APP登录/发起、HTTP合成peer accept/heartbeat/end、包级权限终检、手机toybox nc、专用DB identity和前后mariadb-dump、隔离SFU内部metrics/RoomService采样。凭据及序列号参数仅LOCAL_ONLY；公开材料不复制这些参数。没有把缺JWT403或旧测试计入本轮安全证据。

冻结AC05双端音频、同call流动媒体重连、旧JWT首次/重入拒绝、撤权COMMIT后实际媒体停止≤5秒均OPEN/NOT_RUN。本次视频、人工听感和AEC质量NOT_RUN。既有消息/图片/视频/缓存/通知成果未重跑、未改写。

## 非作者有界复核与保护终检

独立非作者GPT-6.1 Sol/high完成一次有界证据/文档复核：确认源码Tree和仅两份docs变化，发现中途653样本旧快照误写为最终统计的文档阻断；已按最终JSONL修正为715样本、60个显式tracks字段总轨道0、655个无字段。主代理对修正文句和JSON重新核验。保护/SQL/停用部分的独立复核限于匿名回执，未独立读取SQL、操作设备或查询实时服务；不冒称独立功能验收。

采证筛选和审阅曾将原网络候选地址带入本地工具会话；该输出边界失误保留在本次LOCAL_ONLY记录。后续改用字段白名单汇总，公开两份docs不包含原候选、设备序列号或凭据。非作者未读取secrets/SQL/APK，未进行设备、DB/API、网络、服务或写操作。

5个历史保护根的HEAD、branch、index hash、dirty/untracked状态与开工基线一致；730份既有文件bytes/SHA256不变，原private .env不变，原306个refs目标不变。首次格式检查失败不代表资产变化，原警告/检查记录保留。未清理历史树、候选、SQL、APK、备份或原证。

本次专属资源停用回执已保存：call3正常end HTTP200；测试APP force-stop、手机安装/数据不动；四个新增reverse按精确条目移除，原列表语义一致；SFU和独立DB停止、volume保留；本次host进程均已停或有界到期。ADB server和Docker工具保留，未停止共享全局工具。

## 剩余门禁与最小下一步

已确认的故障层为**APP WebRTC ICE媒体连接未完成**；ADB、HTTP、受保护SFU信令与端口TCP可达各自有证据。尚未区分SDK候选配对、ADB TCP传输语义或其他ICE内部原因，不将环境故障直接定性为产品代码缺陷。

当前授权路径内停止媒体重试。最小未满足的技术条件是：证明一条手机WebRTC可实际使用、符合授权的受控TCP ICE候选路径；其可行实现本轮尚未确定。Owner/Astra可据此决定后续有界诊断或另选具体网络方案。若该方案需要LAN、UDP、防火墙或新增设备等权限，必须另行明确授权接口、协议、端口和回滚，本次不实施。第二个独立可用APP媒体端仍是双端AC05的独立条件，不因HTTP控制端替代而消失。不预设必须改防火墙/UDP或新增设备。

**本次交付PARTIAL；等待Astra独立复审，不签ACCEPTED，不集成main，不自动启动后继任务。**
