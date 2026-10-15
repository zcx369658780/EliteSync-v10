# v10.0.9 执行记录：实现与部分实链完成，语音设备验证阻塞

2026-10-15。**IMPLEMENTATION_IN_PROGRESS / AUDIO_DEVICE_VALIDATION_BLOCKED / NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED**。

本报告不宣告8项AC完成。双端视频、私有视频消息、部分真实撤权及持久化链已有实证；最终包的双端可辨虚构语音播放仍缺证据。当前Android Emulator原生音频注入多次退出或挂起，不能用静音RTP、JWT、API状态或Widget测试替代AC-09-03。冻结计划、Owner D4～D6和已接受0.6～0.8均不改写。

## 1. 固定身份与权限

- 计划Commit `68d57f755d0091bc15cb867b96d3a21caee83690`，Blob `042cf7298b75169a89b1dcd7c9fb113f6ddd72e3`；Owner决定Commit `4bda572e225b64a3b4d826ae75e355e958251c58`，Blob `85dd5f9b88840104b0d5c26ba57d96fad4a17f11`。
- 产品技术起点 `3a8f7989aa208285b885f1c80f4365f38488ac54` / Tree `95fadde468d8a21b39c544fdb74093dd35184717`；本次实际回读main `03c7de98d79c3075d4b3adb93a9b383dd342377f`。未合main、未执行K08。
- 当前实现锚 `29ebda1ba71bdcb17d260cceec616031f1360ca6` / Tree `13910eac5c882e21cb76156a28ce2cef891d71be`。此后报告/证据提交不是新的产品源码起点，也不是完成候选。
- 专用树 `C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，分支 `codex/v10.0.9-rtc-media`。当前任务环境thread ID `01a13afa-b74f-7c11-b7e0-01a04335168d`，未借用来源会话ID。
- 本地原证根Q：`C:/Users/zcxve/.codex/visualizations/2026/10/14/01a13afa-b74f-7c11-b7e0-01a04335168d/v1009`。GitHub仅含经过筛选的安全摘要；Windows原流/设备/数据库属于 **CODEX_REPORTED / LOCAL_ONLY**，不能冒称Astra亲自运行。

## 2. 已实现的模块

| 模块 | 具体源码与行为 |
|---|---|
| 当前RTC权限 | `services/backend-laravel/app/Services/RtcAuthorityService.php`、`RtcSessionService.php`：每call绑定独立随机room、参与者identity及当前CN/MC revision签名；create/accept/connect/heartbeat/join/sweep重读当前状态，双向block、restrict、disabled及未知环境拒绝；临近邀请期限独立接听后有新的30秒连接期限 |
| 入房与失效 | `LiveKitTokenService.php`、`Http/Controllers/Api/V1/RtcGuardController.php`、`Http/Middleware/RtcTransaction.php`、`config/rtc_guard.php`、`routes/api.php`：短期JWT不替代当前授权；内部可信门与用户身份分开；生产/未知环境不开放 |
| SFU边界 | 本目录 `rtc-gateway.py`、`rtc-watchdog.py`、`authority-bridge.py`、`Dockerfile.rtc`：受控7884入口，原SFU7880不发布；每次validate/WS重新授权；失效DeleteRoom，控制失败停止SFU；独立进程通过匿名pipe监督成功授权脉冲，避免网关主循环阻塞导致看门狗失效 |
| APP通话 | `apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart`、`presentation/pages/rtc_call_page.dart`、`rtc_incoming_call_page.dart`：显式接听/拒绝、真实发布订阅与视频渲染、静音/摄像头/切换、当前授权失败关闭媒体；显式重连先重新读取服务端session及Join信息，无自动接听或无限重试 |
| 私有视频 | `PrivateVideoValidator.php`、`MediaController.php`、`ConversationAtomicSendService.php`、`config/media.php`：MP4/H.264（可选AAC）、25MiB/30秒、真实ffprobe校验；ready为validated passthrough，**未声称转码/生成封面**。私有存储、消息附件关联、当前权限及Range读取 |
| APP视频附件 | `features/chat/presentation/pages/live_chat_page.dart`、`widgets/private_video_player.dart`：实际picker、上传、附件发送、认证原生播放器；播放前及每2秒当前权限检查，撤权/会话变化/后台关闭播放器，无公开URL fallback |
| 测试与复现 | RTC/媒体/权限PHP及Flutter窄测试；本目录具名运行、UI、浏览器、数据库快照、授权探测和看门狗诊断工具。私配、token、设备发现秘密及物理包均未入Git |

## 3. 真实链结果与AC当前状态

| AC | 已有实证 | 尚未完成的部分 |
|---|---|---|
| 09-01 | 独立0.9 MariaDB/volume、两台专用AVD、官方固定镜像及实际image ID；最终APK两端安装hash一致；原dirty根HEAD/index/status摘要前后一致 | 版本尚未形成完成候选 |
| 09-02 | alice2/bob3独立CN/MC；真实APP创建/独立接听/连接/Join；真实HTTP Match alone403、非有效处罚状态拒绝；PHP针对当前revision/撤销/超时/未知环境断言通过 | 完整实链状态矩阵及最终设备重连仍待收口，不能由单测替代 |
| 09-03 | call7真实两APP语音发布/订阅、双方RTP增长及非零解码音频帧；初始虚构音注入有completed回执 | **BLOCKED**：最终包的双方同时可辨虚构音与对应播放证据不足；后续多种注入使原生模拟器退出/挂起。拒接/忙线/权限拒绝/重连的完整真实语音矩阵亦未完成 |
| 09-04 | call8、10、最终包call11真实双端视频；摄像头运行时许可、前后摄像头切换、本地与远端虚构测试图；两端视频framesEncoded/framesDecoded/RTP增长 | 旋转、完整前后台、摄像头拒绝、静音及重连的所有实际操作尚未完成，不登记整项PASS |
| 09-05 | call7真实Web restrict、call10真实MC revoke、最终包call11真实Web banned；SFU删除对应room、当前Join404、保存的**尚未过期**JWT validate403、原7880/7881宿主不可达。call11两端room_disconnected/leave_complete均在真实处罚表单提交后约1.2秒内 | CN close/block/end逐个双端媒体停止、SDK自动刷新/真实断线重入的完整矩阵未完成。最后独立进程看门狗修复只重测了故障停服，不冒称其后又完整跑双端媒体 |
| 09-06 | 真实APP选择5秒虚构MP4→真实ffprobe→MariaDB asset1 ready、message1 attachment1→Bob APP打开并启动原生播放；owner/receiver完整200、Range206；匿名/非参与者404；MC revoke后所有完整/Range404；重启同asset/关联/hash存在 | 播放截图为起播帧，不冒称完整5秒已播放完毕；撤权时已缓冲播放器的实际销毁、失败类型/重复绑定的全实链矩阵待收口（相关单测通过） |
| 09-07 | APP真实文本message2、私有图片asset2/message3；Blade restrict/banned/restore；受限用户真实HTTP历史读200、新私信404、新RTC403、本人申诉201且申诉后仍403；恢复不复活旧token，明确新登录才200 | 本轮申诉是定点HTTP回归，未冒称重做0.8整套APP/Blade验收；通知安全实际依赖相关PHP回归，未重做所有后台链 |
| 09-08 | 四轮AAR/APK构建及最终双端安装、当前源码分析/相关测试；API/授权监听/worker/DB/SFU与APP已有重启；同库持久记录比对一致 | 不是完整最终联合验收；语音与其相关失效/重连门未通过，因此不提交完成候选 |

安全摘要与少量图片见 [evidence](evidence/)。逐原证hash/退出码见 [manifest](manifest.json)。

### 3.1 已观察的真实撤权时序

- call10 MC撤销HTTP响应 `1792072931.3405583`，SFU room_removed `1792072931.6365023`，约0.296秒；观测窗口内后续媒体样本停止。旧JWT于 `1792072938.51225` 再验证403。不能把删除房间单独当作整个09-05完成。
- call11 Blade banned表单提交 `1792073476.809656`，响应 `1792073477.5018787`，room_removed `1792073477.33057`。主机实时收流记录Bob断开/释放约 `1792073477.893`，Alice约 `1792073477.955`，均在表单提交后约1.2秒内。两APP在操作前有实际双端视频RTP/解码增长。设备时钟曾与宿主差约18～21秒，**未直接混用设备epoch与宿主epoch求差**。
- 当前阶段只声明这些具名序列；不外推生产、网络全故障或尚未实测的所有撤权种类。

## 4. 镜像、网络与包

- 官方LiveKit v1.13.10索引：`sha256:89ca9ce0791e18d6e03bf6e2c49ceb27e1c754eae8bd50c989386c1a5963791a`；amd64 manifest `sha256:e96a42b8623f738919a3f2006d433aeb19d0f3c67ce11eb986ea20e2cf65fbf5`。首次pull前保留Registry原文、digest与许可证。客户端锁仍为livekit_client2.10.0/flutter_webrtc1.6.0，未升级。
- Python官方基镜像digest `sha256:d9368b3a5ac59afea7b5d4f2e2aea0941dbf9fdee9c369c5bec00b98244bc929`。最终组合镜像image ID `sha256:32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e`。后者包含最后独立进程看门狗，实际运行读回一致。
- 宿主仅发布 `127.0.0.1:7884/TCP`、`127.0.0.1:7882/UDP`；7880/API仅容器loopback；AVD ICE地址10.0.2.2。无公网/TURN/收费Cloud，无全网卡防火墙修改。
- 数据库 `elitesync_v1009_dev`，容器 `elitesync-v1009-db`，volume `elitesync-v1009-db-data`，`127.0.0.1:43319`。API8000→8001，独立同代码同DB的授权监听8002，均loopback。
- Android包源码锚 `c2ba84cc50a1946e697a8e94e50181201304bb12` / Tree `d15e2023bd7492684f88d1529fb105a178145886`；之后实现锚29ebda1只修改本地SFU/诊断工具，无Flutter/Android/PHP产品变化。
- AAR：`Q/artifacts/fourth-flutter_release-1.0.aar`，4,451,332 bytes，SHA256 `a621e4989c39e34af5df0b54bb1e18b90ce77e8c2f8966bb824e074cc9d7c4c8`。
- debug APK：`Q/artifacts/fourth-app-debug.apk`，223,877,338 bytes，SHA256 `3358c629a9884e433cb501d02b364e2aea4c2354f33cd3b5003817d4cd8674cc`。`emulator-5584`/`emulator-5586`安装base.apk回读均同hash；两AVD名分别elitesync_v1009_a/b。大包不发布GitHub，未写development release或生产分发。

## 5. 自动验证与原始失败

| 验证 | 实际结果 |
|---|---|
| `integrated-php-first` | exit1，39通过/1失败、399断言；过期call旧测试要求新增heartbeat，修为不得复活，失败原件保留 |
| `integrated-php-final` | exit0，46项/372断言；RTC、私有视频、原私有媒体/R1通知隐私、0.8申诉和处罚；vendor弃用及旧doc-comment提示保留 |
| `accept-deadline-final` | exit0，15项/113断言；首轮测试假设修正的exit1亦保留 |
| `flutter-related-final` | exit0，38项；RTC及真实聊天/私有播放器相关测试 |
| `dart-full-final` | 全范围No issues found，exit0 |
| `reconnect-tests-first` / `audio-diagnostic-tests-first` | 11项/7项，均exit0；独立接听前的红测/Scaffold失败原证保留 |
| `build-first`～`build-fourth` | 均exit0；前面包不是当前物理包，不能混淆hash。第四轮最终安装两端exit0 |
| 全Flutter/全PHP历史套件 | **NOT_RUN**；历史0.7三项既存Flutter失败与原exit1不改写，本轮不称全套通过 |
| 辅助语法检查 | Python与PHP最终分别exit0；一次误把PHP交给Python的helper-compile-first SyntaxError/exit1保留 |

其它语义失败：初次fixture week_tag过长时CLI曾exit0却含SQL错误，按失败保留，修正后仅向本0.9库写具名fixture；该fixture不是matching consumer实证。早期音频注入helper曾exit0但receipt有RPC失败，**这些是失败，不是PASS**；helper现已按receipt异常返回非零。原始stdout/stderr/exit与结构化回执共同判断。

内部只读窄审查发现共享事件循环watchdog风险后已修为独立进程。首轮独立进程诊断的容器退出观察约11.3秒/断言失败保留：SFU先被杀，但namespace PID1不接收内部未处理SIGKILL；补明确SIGTERM处理后，`process-watchdog-final` exit0，阻塞10秒的测试中宿主观测容器约4.714秒内退出。此为故障停服测试，未把它冒充带双端媒体的完整09-05。

## 6. 最小具体阻塞及下一门

现有官方Android Emulator36.4.10（build15004761）、Android36.1 x86_64两专用AVD在gRPC injectAudio/streamAudio方案下，多次出现UNAVAILABLE/10054、DEADLINE_EXCEEDED、QEMU退出/ADB挂起。试过先前并发采集、仅注入、24/48k、实时/缓冲和禁用宿主音频后端；未安装驱动、未打开宿主真实麦克风。Windows具名事件记录有 `qemu-system-x86_64-headless.exe` / `combase.dll` / `0xc0000602`。**不能把所有退出都归因为同一个已证明根因**，但当前路径不能稳定取得最终双端虚构音播放证据。

仅暂停受影响的真实语音/关联媒体验收子项。计划5.2明确：现有AVD不可用时，只能使用Owner另行具名指定的无真实账号测试设备。因此最小Owner决定为：具名指定受控替代Android测试端，或明确授权一个项目隔离、官方固定版本的替代emulator runtime验证方案（不改全局SDK、不装系统音频驱动）。决定前不接入个人设备、不升级系统、不降AC。

恢复后仍须按原8AC补齐：最终双端可辨语音及播放、拒接/忙线/权限/断线重连、各具名撤权及旧/刷新JWT实链、短视频完整播放与撤权缓存销毁、最后看门狗版本下必要媒体回归。不能仅因本报告已发布转入Astra最终接受或K08。

## 7. 保护与资源最终状态

原dirty根D:/EliteSync-v10的HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、index SHA256及normal status SHA256与本轮起点完全一致。没有重做历史109项全量验证。旧LOCAL_ONLY、`%SystemDrive%/`、工作树缓存及其它未提交成果未清理/未混入提交。

0.6/0.7/0.8数据库容器继续停止、各持久volume保留，未重seed；0.9持久业务记录也未重seed。只在本0.9首次开发库创建虚构账号/题库及具名已发布Match测试fixture。

本0.9 SFU/数据库容器、Laravel/front/授权监听/bridge/worker和两专用AVD已停止；volume、media、私配和原始失败保留。当前Bob3保留受限处罚3及申诉1，旧处罚1/2已受控restore；CN/MC/账号状态以Q/before-owned-stop.stdout为准，不能盲目从初始fixture重置。恢复运行说明见 [RUNBOOK](RUNBOOK.md)。
