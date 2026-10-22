# EliteSync v10.1.5｜RTC环境门禁执行报告

2026-10-22（Asia/Shanghai）。**SOURCE_UNCHANGED / PARTIAL / ENV_BLOCKED_OR_CORE_OPEN / OWNER_DECISION_REQUIRED / NOT_ACCEPTED / MAIN_NOT_INTEGRATED**。

## 1. 唯一权威与固定身份

Owner手动派发唯一 `OWNER_APPROVED_RTC_ENV_GATE_TASK_20261022.md`，fixed Blob `4839dc276921f36a8fbe3076b9c285fbea36811c`；从main `4080742585bfdc5a7f376ba7106ede5d05be3b04` 的fixed-SHA raw HTTP全文取回并按Git Blob字节核验。当前任务没有变成R2或新版本。Astra R1独立复审 `ff9916e0b227dc0996165b2b6d5024b6199ead17`、冻结plan `7d3466b3be67135dc641cfee7c7faef78937ba03`及原task `0df56f69712a85541b5f24bef281e2a9a61520a4`均保留。

产品源码完全未改：R1 source `1c5cd2bb7919c435e8486a76959db75e9ccc367f`，原唯一Parent `47e30a3ef5bc7aacb42b6e32b6bc822dbdbb0962`；source Root `165eb1f362db533ca94bfe1db677ff6f7bd477ed`；apps `0784c8aa7b0915a04b83693a45401197e31d93a2`；services `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本次从R1最终交付 `6da9a05156fda8b603224fd10e04ac1cc997ad79` 安全新建 `codex/v10.1.5-rtc-env-gate`，仅提交本报告及 `rtc_env_gate_manifest.json`，不改原R1报告、manifest或审阅对象。main接受产品仍是apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

全部本机运行＝`CODEX_REPORTED/LOCAL_ONLY`。GitHub脱敏材料仅供Astra独立读Git/文本，不冒称Astra亲自操作Windows、数据库或AVD。

## 2. G0：启动前保护与归属

- 连续工作树开工HEAD精确R1最终交付且干净；5历史根的HEAD/branch/index/status、全部既有heads/tags、私密.env及653个首轮/R1原证文件hash/bytes已保存，终检一致。该范围不推定所有其它历史文件均事前独立hash。
- 只复用已停止且具名的R1专用合成库 `elitesync_v1015_r1_dev` / `127.0.0.1:43327`，容器 `fa7862c5066e8b037980ce8838cec2f3cc07c0ad2022538fd3139a78e2dad407`，volume `elitesync-v1015-r1-data-20261022`。有效 `APP_ENV=local / APP_DB_CONNECTION=mysql / DB_CONNECTION=mysql`，APP/DB URL和socket均空，host/port/database精确匹配。93表；没有迁移、seed、创建新账号或恢复已撤回的MC。
- 启动前先核R1原SQL恢复点165674bytes/SHA256 `14f266cc8fb75d783eb6fe13d54ee5d37f49176fa1d86d05e531fa00d8435c4d`，原件不改；启动后写前再次dump当前库。收尾dump `165674`bytes、SHA256 `2765cd0f6803004207cd9db2c152601b6aa448a77aaae1c0d98011aa349d8b40`、exit0，前后SQL仅 `Dump completed`时间注释不同，其余字节一致；不声称实际演练restore。
- SFU只用已存在image `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`，不pull/build。新专属容器，host只发布 `127.0.0.1:7894/tcp` 和 `127.0.0.1:7891/tcp`；raw SFU不发布，内部raw监听loopback。API/guard只在既有host loopback8030/8033，启动前端口无冲突。
- 两台仅既有A/B AVD，虚拟麦克风权限沿用已批准R1包；本次 `-no-audio -camera-back none -camera-front none -no-snapshot-load -no-snapshot-save -no-window` 冷启动，保留旧snapshot，不打开宿主音频/摄像头。没有新设备、SDK或系统权限。
- 当前已装Emulator `36.4.10.0`。客户端未改、未重建/重装；B实读包 `com.elitesync.v1015r1dev / 1010511 / 10.1.5-r1-dev`，RECORD_AUDIO granted，APK SHA256 `2c54dcae8d26f85995750b2e45e8d12fa0e5f450c7747fddc76274c7a40d0466` 与R1一致。A注入后阻塞，未继续做安装包读回，不能声称本次双端新安装验证。

## 3. G1：分层诊断与准确失败范围

### a. 非音频RPC

两端先分别验证AVD归属及既有loopback gRPC，然后 `getStatus(Empty)` 均 `booted=true`，修正后的健康命令exit0。首版诊断脚本误对protobuf `hardwareConfig`消息使用len，产生TypeError/exit1；保留初版脚本及stdout，不将它当环境故障。此阶段未调用音频或产品RTC。

### b. authority monitor与SFU

在新本次诊断副本仅加入固定phase、安全原因白名单和本地耗时日志，无产品源码变化。实际首次空闲启动出现：bridge HTTP读取 `TimeoutError / http_status=null / elapsed_ms=1531`，随后gateway `phase=authority_sweep / safe_reason=authority denied` 并立即 `sfu_fail_closed`。guard首个请求的accept→closing日志约3秒，但bridge已经在1.5秒门限到期；**已确认层是authority HTTP读取/就绪延迟，不是授权成功或产品代码缺陷证据**。其底层冷启动/调度/IO原因未细分；旧R1仅RuntimeError的日志也不能追溯定性为同一根因。

普通启动顺序修正：在启动同一SFU容器前先作两次受控guard readiness检查，实得HTTP200、109ms/32ms，然后恢复同一容器。后续记录43个健康样本、跨度216.30秒，最大所采sweep 91.601ms；没有通话、allowed/room count均0。host raw7880不可达，缺JWT的gateway GET403。**只证明空闲控制链和隔离；不是流动媒体、旧JWT或5秒停止。**

原有bridge 1.5秒、reply轮询200×0.01秒、入口2.5秒新鲜度和watchdog3.5秒无pulse杀进程均保留；没有新增重试、延长门限或监听面。静态常量本身不证明严格墙钟上限或G4媒体5秒合同。

### c/d. 单机短PCM及阻塞隔离

基础只读RPC健康后，仅A送入20包、48kHz/mono/S16 LE、440Hz、`MODE_UNSPECIFIED`，生成预期长度0.4秒的有限PCM；每包实际间隔约15～32ms。只调用一次 `injectAudio`，deadline3秒；不同时调用streamAudio、不采集扬声器、不发起本次RTC call，不生成假远端媒体。

实际结果为 `DEADLINE_EXCEEDED`，命令exit1。随后A的第一项健康检查在**ADB身份查询**即 `TimeoutExpired`，尚未进入getStatus；独立直接对原gRPC endpoint再作只读调用，A `getStatus` deadline3秒仍超时，B同时 `booted=true`。A进程未证明崩溃退出，而是控制调用阻塞，最终按精确本任务PID停止。与旧R1的B退出现象不同，不能混称此次又发生B崩溃或connection reset。

**因果范围**：已把可观察失败收窄到Emulator Controller合成音频路径／运行时与当前配置组合，在无本次RTC呼叫、无并发capture的最小场景仍出现。底层实现、驱动、音频关闭策略或RPC调度哪个是根因仍UNKNOWN，不据此判产品RTC BUG。生成PCM不等于实际注入成功、播放、传输或接收。

已安装CLI帮助明确 `-no-audio` / `-audio none` 禁用全部音频支持；当前没有验证出既能维持可用音频引擎又不触碰宿主音频设备的替代配置。只读backends-help查询也未提供可用方案：首次直接运行内部binary因runtime DLL路径退出3221225781；补进程局部已装runtime路径后返回unknown option/exit1，audio-in/out help同样不支持。没有因此换用宿主backend、更新SDK或无界重试。保留这些工具查询原失败，不把查询退出归到产品。

计时明确区分：原 `grpc-single-inject.json` 的 `injection_end_epoch` 在两次后续健康检查之后生成，不能用约7.06秒差值作为RPC耗时。`expected_audio_seconds=0.4`只是输入长度。后续直接getStatus的start/end单独记录；各host/容器Unix epoch和进程monotonic来源见 `event-time-source.json`，未改系统时钟。G0记录时点取baseline证据文件写入时间；G5记录时点取owned shutdown回执写入时间，非声学测量。

## 4. G2～G4与四条硬门

| 硬门 | 本次结果 | 证据边界 |
|---|---|---|
| DUAL_APP_SFU_FLOWING_AUDIO | **ENV_BLOCKED** | 单机合成PCM前置已失败；没有合法双端新call、publish/subscribe/receive/RTP或远端样本成功回执。 |
| SAME_CALL_RECONNECT | **NOT_RUN** | 没有已流动同call，不做伪重连。 |
| OLD_RTC_JWT_DENIAL | **NOT_RUN** | 未形成新媒体call/旧JWT首入或重入演练；缺JWT403不能替代。 |
| FLOWING_MEDIA_STOP_LE_5S | **NOT_RUN** | 没有流动媒体，没有撤权COMMIT→实际媒体停止区间；ended行、HTTP404或停容器不算通过。 |

G1(c)真实合法CN/MC发起/响铃/接听状态机亦未进入：音频基础故障后已停止继续调用，未激活旧MC或生产数据来凑场景。未测试撤权种类全部UNKNOWN。`AEC_HUMAN_HEARING_NOT_RUN / VIDEO_CAMERA_NOT_RUN`；不以SDK/计数替代人耳，不启用新视频源。B1/B3、图片视频、Range、通知及旧WS exit1按上轮Astra限定结论原样继承，无关成果未重测或重写。

## 5. G5：复核、回执和保护

主要复现入口（仅说明已执行命令，不是再运行授权）：在本次LOCAL_ONLY原证目录，`python g1-rpc-isolation.py health`；`python g1-rpc-isolation.py inject`；新诊断bridge调用原guard `/api/v1/rtc-guard/sweep`。真实命令/stdout/exit、原始健康JSON、bridge/SFU/AVD日志、源码hash和SQL恢复点均保留。没有产品修改，因此PHP/Flutter全套回归、重建/双端新安装均NOT_RUN；诊断Python AST解析exit0，非作者独立比较安全门与观测结论。不存在把原版本测试搬作新媒体证明。

非作者GPT-6.1 Sol/high一次有界静态复核：未见新增放宽、监听面或secret输出；明确指出上述 `injection_end_epoch`和ADB/getStatus区别，本报告已按实际范围表述。复核没有运行设备/DB/网络，不签功能接受。原R1 object/旧报告/manifest与冻结AC保持原字节。

本次结束仅停：新SFU、本次API/guard/bridge、精确归属A/B AVD及复用R1专用DB。A阻塞时用确认command line与PID停止，B正常emu kill；没有本次forward/reverse新增，未动旧mapping或全局ADB/Docker/WSL。保留新容器、原volume、SQL和原证，未删除快照、历史树或备份。最终5保护根、653文件、旧refs和private env一致。`protection-final.json`、`owned-resource-shutdown.json`具名支持。

最小匿名脱敏审阅分支 `codex/v10.1.5-rtc-env-gate-review`，Commit `55c1c30df95918abb8b2e5fcafbafe882a3f9d78`，Root `d68bac49afa06ca3ffe776df36109a4075e06449`；6份文件path/mode/Blob见manifest。[固定审阅入口](https://github.com/zcx369658780/EliteSync-v10/tree/55c1c30df95918abb8b2e5fcafbafe882a3f9d78/docs/_temporary_review/v1015-rtc-env-gate-20261022)。diagnostic gateway/bridge为本次环境副本，SHA与部署身份分开列明，不冒称R1产品源码有新提交。原始配置、secret/JWT、设备标识、SQL、音视频/图片及私聊不公开。候选和review只普通non-force发布，fixed-SHA/Tree与raw HTTP回读由LOCAL_ONLY publication receipt记录。

## 6. 最小下一条件与停止门

需要先有**可验证的合成音频运行条件**：现有模拟器在宿主麦克风/摄像头关闭时，Controller短PCM注入能返回且AVD健康保持。可由Owner提供已知可用的现有配置；若必须修复/更换模拟器运行时或SDK，须另行明确批准具体隔离方案和版本。当前没有证据保证更新SDK、引入真机或开放宿主麦克风就能解决，不能把它们写成既定必需，更不会自动尝试。尚不需要扩大公网、UDP、防火墙、供应商或费用权限。

本次已完成有界故障层诊断及安全收尾，未关闭四条媒体硬门。**V10.1.5_RTC_ENV_GATE_PARTIAL / ENV_BLOCKED_OR_CORE_OPEN / OWNER_DECISION_REQUIRED**。等待Owner与Astra就客观环境条件取舍；不自行ACCEPTED、不合main、不自动R2或v10.1.6、不继续重试。
