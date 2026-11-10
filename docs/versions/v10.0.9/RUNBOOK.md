> 2026-10-17 K08接续说明：本版已由Astra接受（保留观察），见 [acceptance.md](acceptance.md)；本次集成见 [integration.md](integration.md)。以下为接受候选的历史运行手册，旧状态、设备、PID、命令和窗口不能作为当前运行依据。一次性UAC/网络授权已消费；本次服务、DB、SFU、设备和业务重跑均NOT_RUN。不得依据本手册自动init/seed、恢复服务或开启真实网络窗口。既有持久卷、私配、媒体和原证保留；以后运行须具名授权并先核实时资源。原RUNBOOK完整对象在候选70612d36652660e8bdd9d12017c1254ada686298中保留。

# R1最终环境状态（2026-10-16）

四条本v10.0.9临时WLAN规则已获当前Owner“我在”及一次UAC具体批准后精确删除，读回0；旧段落“保留四条规则”现仅为历史。DB/SFU/服务继续停止，持久卷/媒体/证据及Owner既有AVD保留。R1未启动设备或任何新窗口；以后不得据旧规则或旧窗口自动恢复网络，须Owner新授权。R1只文档/既有证据与sqlite内存定点测试，无新包或安装。详见[R1报告](R1_REPORT.md)。

# v10.0.9 受控开发复现说明

## 最终候选运行说明（2026-10-16，覆盖后文历史）

最终源码/测试锚e0eb86ada8f8dff95a7b384969ace058385e2c37，Tree a6be76c7963fcd2cff42e207660503c3b0856424；冻结plan与8AC不改。最终包APK SHA256 77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca，AAR dd1e869f34eea40693793871e03de895cc4a50d3f131255b9edd9e2d05642d9e；双ABI，两端安装实读hash一致，数据保留。Android显示版本仍0.08.04，独立包com.elitesync.v1009test。本地大包在本会话version-regression/provider-fix-artifacts，不入Git。

1. 当前0.9 DB/SFU、五个服务、relay及两端测试APP已停止。保留elitesync-v1009-db-data、私有媒体/凭据/原证、Owner现有AVD和四条旧防火墙；不是全资源关闭。不得盲按已停止receipt的旧PID操作。恢复前先核当前端口、命令、容器image与volume；仅恢复本0.9，不init/seed，不碰旧库/生产/原dirty根。
2. 私有配置仍在既有Q/secrets，所有token、网关密钥、设备serial与真实IP只能本机读，不打印或提交。source run tools的公开参数不是授权。最终运行receipt在本会话version-regression/owned-services-after-joint.json，最终关闭receipt为rotation-final-resource-stop.json；进程已停止，receipt仅用于归属追溯，不能作为再次kill依据。
3. 若获新一轮许可恢复，顺序为DB健康→API/front/authority/bridge/worker→authority成功预热→固定SFU；不要先冷启SFU触发看门狗。固定自建image仍32d59377b1bd55507719fced7c63efaf441423ab208fc080af0e17bdcfe7276e，原官方tag/digest/license继续见既有记录。禁止latest、重seed或替换原持久卷。
4. 每轮临时TCP须Owner独立批准，最长1200秒自动截止，可完成后提前收口，不续时。每次手机安装必须当次准备确认，失败不自动重试；当前最终包无需重装。每次视频入口必须先弹窗取得当次准备确认；按当次只前置/遮挡许可，不自动后置。原音源工具不重装，不盲重复gRPC注入。
5. 最后call61由真实APP挂断并保持终态；MC当前仍active（call61未撤MC），CN2 active，原CN1 CLOSED rev3保留。任何新互动仍先实读当前CN/MC及独立接听；不复活旧call/room/JWT。最后AVD旋转及自动方向设置已恢复，APP后台关闭摄像头/麦克风，前台不自动恢复采集，必须用户显式开启。
6. 真实私有视频为原5秒合成MP4，原APP picker/asset1/message关联已保留；最终包联合重启后完整播放，2.333秒中帧及4.933秒片尾原图具名保存。ready仅为合法格式验证后passthrough，不声明转码/封面/录音消息。超25MiB、超30秒、伪/损坏MP4、非本人asset、重复/幂等冲突等正确拒绝；无公开fallback。
7. 必须保留观察：PHP全套仍4errors/12failures，最终仅相关37/325通过；RTC Flutter32通过而非全套。有限死锁重试不保证1.5秒总时限；raw framework日志可能含SQL，LOCAL_ONLY。Android原生最终音频处理UNVERIFIED。front串行是本地开发适配，有队头等待及既存短body风险，不是公网生产方案。

最终集中结果与8AC原证映射见EXECUTION_REPORT，安全资料见evidence/20261016-*.json与五张AVD截图；完整手机/摄像头图及原始日志不公开。候选提交不等于ACCEPT，终点为Astra独立终验；禁止自动合main/K08/后继版本。

## 以下均保留原时点，不能当当前事实

## 17:53最新资源状态

0.9 DB/SFU及五个owned服务、relay和两测试APP已停止，卷/媒体/证据保留；Owner现有AVD及四条原防火墙保留，不能声称全资源关闭。新窗口及新视频准备正在等Owner弹窗回答，不能复用旧窗口。当前源码e0eb86a，最终包hash仍77d4b021...，手机无需重装。仅剩AVD视频旋转/前后台有效证据及最终候选封存；之前call39不足，不能算通过。

## 17:30最新覆盖

最新包已双端安装并实读相同SHA256：77d4b0215d710a3a749814d386059d4763eaefa73101d9b31bc14b8ba7bca5ca，见本会话version-regression/provider-fix-final-package-manifest.json。原第三版构建保留为历史；AEC/NS/AGC源未改。新call provider错误不额外自动重试，页原poll保留。最后call59因MC撤销终态，新call须真实request/accept恢复MC。双方权限及flags、AVD Wi-Fi及两reverse通道已恢复；无需重装。17:29:52.503窗口实际自动停止，当前无新授权。视频入口仍须当次Owner准备确认；新包视频及最终封存未完成。其余历史段不能当实时状态照抄。

## 2026-10-16 当前运行接续说明

下文为原2026-10-15时点，设备、包及服务状态已变化，不能照抄为当前事实。当前使用Owner具名手机与AVD_MANUAL、第三版双ABI包（APK SHA256 904efe1429740b2a435c511343586b4d9e5b4a1f7f5d84e37bdaa3b642cb20bd），无需重装。新安装仍须每次取得Owner准备确认、失败不重试。每次视频拨打前必须另行弹窗确认；不得借用前次身体准备许可。只拍合成图，切换手机两镜头须两侧安全构图/遮挡许可。

本会话本地证据根：C:/Users/zcxve/.codex/visualizations/2026/10/16/01a14250-b40a-7410-ac1d-61dde1ec0644/version-regression。先读CONTINUATION_RESULT_20261016.md及owned-services-after-joint.json，再核实际PID命令/容器/volume，不能按旧receipt杀进程。已有0.9 DB和SFU运行，禁止init/seed；四条原临时防火墙保留。每次临时TCP窗口须Owner独立授权、最多1200秒自动停止、不续时；relay-final-camera已实际于17:06:58.579自动停止；当前无新窗口授权。

本地front针对Windows PHP单worker串行提交完整上游请求，客户端收体及回包在锁外。它不提升生产能力；大请求仍有队头等待风险，不通过延长超时掩盖。当前活跃APP负例已422，通话中必要回归未完成。原音频注入失败不重做；设备声音已Owner实听通过。整体仍NOT_CANDIDATE_DELIVERED / NOT_ACCEPTED，按EXECUTION_REPORT最新区继续。

## 以下保留原时点

当前为部分实现/验证状态，**不是完成候选**。先读 [EXECUTION_REPORT](EXECUTION_REPORT.md) 与固定plan；受阻语音不得通过降低AC或真实个人麦克风绕过。

专用树：`C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`。Q为报告中的本0.9证据目录。原dirty根及0.6～0.8库/卷不动。Q/secrets包含本地配置、虚构账号、API token、网关密钥和设备发现资料；只本机读取，禁止打印或上传。工具均从本目录定位代码，不从原dirty树运行。

## 恢复既有环境

1. 核实所有容器名称、volume和loopback端口所属；当前0.9库/卷已存在，**不要执行dev-runtime init/seed**。先启动 `elitesync-v1009-db`，等待数据库就绪。
2. 在专用树用 `python docs/versions/v10.0.9/dev-runtime.py Q start` 启动8000→8001 API；`authority` 启动8002独立授权监听；`bridge` 启动私有文件桥；`worker` 启动database queue的v1009-matching具名worker。每个动作记录owned-*.json，重复启动前先核现有进程，不能按旧PID盲杀。
3. 当前正常SFU容器已保留且停止；可启动 `elitesync-v1009-rtc`。若代码变化需重建，先保存其logs与安全inspect身份，确认是本0.9容器且不挂DB卷后，只替换这个临时SFU容器。`prepare-sfu.py Q build/start`使用已核官方digest，未固定新版本不得直接pull。最终组合image ID见manifest。
4. 正常配置不含RTC_GUARD_TEST_STALL。`start-stall-test`仅供明确本地故障诊断部署，`watchdog-proof.py`会向其发送SIGUSR1模拟10秒主循环阻塞；它不是正常启动流程。故障后必须保留失败原件并恢复无测试flag的正常容器。
5. 两个既有专用AVD为elitesync_v1009_a/b，serial5584/5586，gRPC8556/8558，Android36.1 x86_64。按Q/owned-avds.json核实际设备归属后启动，不wipe、不使用其它设备、不加allow-host-audio；每端仅reverse API8000及受控RTC7884。
6. 当前音频注入路径已证实不稳定，**不要盲目重复media-proof**。等待Owner依plan5.2具名指定替代测试端或另行授权隔离替代运行时。

## 包与APP操作

最终物理包在Q/artifacts/fourth-*，来源产品Commit c2ba84cc50a1946e697a8e94e50181201304bb12，hash见manifest。之后29ebda1只改SFU与诊断工具；如再改Flutter/Android产品源码，重新构建/安装/hash。

构建使用JDK17.0.18.8-hotspot、既有D:/flutter、现有锁依赖，Android任务assembleDebug并传 `-PflutterDartDefines=ELITESYNC_V1009_LOCAL_BUILD=true`；任务自动构建x64 release AAR。现有0.6 Gradle缓存只复用，不清理其原证。

APP：以本地私配中的alice/bob分别实际登录→消息→具名对方→语音/视频；被叫明确按接听，不自动接听。摄像头/麦克风按场景实际许可/拒绝；只用模拟图/虚构音。显式重新连接会先查询当前session再请求新Join；权限未知时保持关闭。

私有短片：已有Q/fictional-media/v1009-fictional-5s.mp4为合成图和合成音；经本版AVD MediaStore选取→发送短视频→对方播放私有视频。服务器依本地MEDIA_FFPROBE_PATH使用已核LGPL共享ffprobe；ready代表真实验证后原样保存，不能声称已转码或生成封面。

## 当前数据与必要核验

- 已存用户2/3、Match fixture1、CN revision2；MC历经重新双方明确授权及撤销。不能重复首次consent命令或假设revision0。`runtime-client.py Q renew`只在当前CN_ACTIVE且MC终态时发起新一代独立请求/接受。
- Bob3目前restrict sanction3、本人申诉1；恢复必须由真实Blade针对该条处罚受控restore，随后再次满足当前双方授权。旧token不复活，APP如仍持旧凭据先按正常登录入口重新登录，不能把API准备token注入APP存储。
- 视频asset1/message1/attachment1、文本message2、图片asset2/message3保留；ID只适用于此0.9库。`snapshot.php`硬限制local+精确库/端口/host，仅输出受控测试状态；先后比对不seed。
- `rtc-probe.py`只将原JWT写Q/secrets，公开输出status/时间；`media-probe.py`输出授权状态与字节/hash，不输出私密内容；两者是补充HTTP证据，不能替代APP。
- `revocation-observe.py`只能针对已经实际APP建立的call观察有限窗口；记录主机收到媒体/生命周期事件的时间，勿混用AVD漂移时钟。Web动作通过隔离Edge真实表单/CSRF，由browser-action执行，不直接改处罚字段。

## 停止与证据

结束前保存stdout/stderr/真实退出码与JSON回执。失败helper即使退出0但receipt含RPC/SQL错误，也按语义失败处理，不覆盖旧文件。只以具名原证索引发布安全摘要；登录截图、完整logcat、JWT/URL/私配、大包、虚构原媒体继续LOCAL_ONLY。

核当前PID/命令归属后停止本0.9 PHP/front/authority/bridge/worker；停止本0.9 SFU与DB容器、两本版AVD，保留所有volume与media。SFU的显式SIGTERM退出1是开发监督进程的停止结果，docker stop命令本身exit0要分别登记。禁止clean/prune/reset/stash原dirty根或删除其它资源。
