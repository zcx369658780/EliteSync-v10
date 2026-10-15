# v10.0.9 受控开发复现说明

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
