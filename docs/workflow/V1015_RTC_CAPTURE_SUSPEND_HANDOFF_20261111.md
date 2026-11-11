# v10.1.5 停下交接｜2026-11-11

Owner要求准备停下任务流程，明日继续。当前为 **PAUSED_FOR_OWNER_MANUAL_HANDOFF**。长期普通工程授权保留，下一次收到继续指令后恢复。

## 代码与候选

- 产品根 `D:\EliteSync-v10-product-v1015-20261101`，分支 `codex/v10.1.5-software-continuation-20261101`，origin为既有EliteSync-v10 SSH remote。
- 最新APP源码 `a819e935314cef96a5930955b1f05dfbb8bbd2c8`。更正源码的APK构建、安装与双模拟器验证均 **NOT_RUN**。后端源码继续为 `25bc01f7d6ce848f5fe964bbc544e9be87325a0e`。
- 两端最后安装包属于先行源码 `744d94898174755041d790f8fe127fe36ad22bf3`，APK SHA256 `6aaae9e459ed07b5400f96d128df83b8dd9b3d8d36c9efadec067c6a9b4883e4`，154207727字节。离线构建41.227秒、退出0，签名、包身份、arm64 Debug及新代码标记通过。
- **744d候选有已知回归**。call12正常双端视频建立，双方原生麦克风和摄像头均运行，生成画面可见。B进入后台后直接leave，网关随后以 `sfu_removed` 结束整场通话，返回时重连入口失效。该包仅保留其限定证据，后续恢复以a819更正源码为起点。
- 最终本地/GitHub保存HEAD以私有 `final-local-github-rtc-suspend-receipt-20261111-private.json` 为准。此前4e7a与日期化保存回执保留各自交接时身份。

## 本轮完成与修复

未知POST跨冷启实际子链已在既有3c2f5b16/65db候选B完成。正常APP一次TEST_ONLY发送，服务端成功确认被本机代理替换为503，真实保存消息104。离线冷启隐藏内容，在线同会话核验和当前peer读取后恢复只读pending与原编号入口。一次手动重试返回同client UUID、同server ID及幂等重放，数据库唯一加密行104。确认后再冷启草稿为空，自动POST计数为0。sessions/tokens/T0、users/media/CN/MC和原1–103不可变字段摘要保持。代理关闭，精确直连映射恢复，截图已查看。

验证工具的漏放会话核验、pending只读控件识别及对端显示名旧假设均已纠正，原失败回执保留。实际新消息发送一次。当前对端标签来自当前获准会话读取，5580实际B看到Current Dev A，5582实际A看到DevUser-B。

RTC定向回归复现后台迟到读取仍连接、麦克风权限迟到继续请求相机、断开失败跳过dispose、显式重连GET跨后台往返后迟到成功，以及麦克风旧发布清理与新启麦交叠。原始RED保留。先行744d方案在实际网关暴露上述通话终止回归，Owner停下前已更正为a819源码。

a819在后台同步失效独立采集代次，并行mute与stop当前及待发布轨道，维持既有room和heartbeat。返回后由用户明确启麦或开相机，断线仍通过既有当前授权重连。麦克风和摄像头分别串行整个权限、创建、发布及过期清理。显式创建的音视频轨道在发布前登记归属，失败、迟到和切摄像头后均清理并保留muted状态供明确恢复。真正leave仍先停本地轨道，再处理信令与独立dispose，并等待旧teardown完成后建立新room。播放与诊断异步回调检查room归属。新摄像头的位置状态取自实际captureOptions。

## 实际检查

- 最终 **108项** 受影响RTC、权限、会话隔离与来电检查通过。覆盖suspend下挂起权限、摄像头创建/发布/切换迟到、muted保持及明确再开恢复，麦克风发布仍挂起时suspend完成即停止模拟采集，以及旧操作清理后新启麦恢复。
- 最终四文件analyze为No issues。扩大检查发现两份旧测试fixture的异步build签名与当前同步SessionNotifier不符，仅修正签名，原失败保留。
- 非作者Sol/high静态复核当前源码未发现剩余确定P1/P2。最终fake publication泛型修正后108项已重新通过。静态审查与测试结果各自记录。
- a819实际构建和原生行为待验证。744d的Home请求起点到B两项AppOps均停止的单一主机时钟观察上界为8.172秒，保留原样。该次观察随后出现通话终止回归，不能据此关闭完整停媒标准。

私有根 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`。关键回执为 `pending-post-cold-completion-after-observer-fix-private.json`、`rtc-background-after-peer-label-fix-runtime-private.json`、`owner-stop-resources-20261111-private.json`。最终定向检查日志为 `rtc-capture-owner-stop-final-tests-private.log`，最终静态检查为 `rtc-capture-owner-stop-analyze-clean-private.log`。APK、截图、原生日志、凭据、SQL和许可证仅本地保留。

## 停下时的资源

- 四个自有DB/API/WS/SFU容器保持运行。停止前SFU房间0，call1–12均已结束。
- 5580实际账号B，仍安装744d/6aaa先行包，进程运行。停止前原生CAMERA和RECORD_AUDIO均未运行。
- 5582实际账号A，为更正构建资源已正常暂停，保留AVD、登录及同744d/6aaa包。尚未开始更正构建。
- 专用ADB5038保留USB排除过滤。资源观察保存在上述日期化私有回执，恢复时重新核实。
- 虚构开发库保持4用户、104消息、7媒体，原消息和保护数据摘要保持。MC仍generation7。
- 稳定构建目录 `C:\Users\zcxve\EliteSyncDev\v1015-source-debug-workspace` 仍准备744d源码。其固定 `state/current-functional-build.json` 也仍指向744d，明日需按a819增量prepare后构建。

## 明日恢复

1. 先核产品Git根、remote、分支、HEAD、工作区/index。读取产品AGENTS、ACTIVE_STATE、CURRENT_WORKFLOW与本交接，再读新的私有日期化保存回执和current-engineering-node-private.json、runtime-private.json。保留原主库dirty/index及无关目录。
2. 增量准备a819源码，沿用稳定离线工具与资源门限构建，核验APK身份和关键采集代码。按实际状态恢复必要双模拟器并使两端使用同一更正候选。
3. 优先验证后台两项原生采集停止且通话维持，返回后保持设备关闭，用户明确启麦/相机可以恢复。再验证切摄像头紧接后台、信令中断下停采集、权限拒绝/撤销及真正挂断清理。定时观察统一使用单一主机monotonic时钟。
4. 根据实际新修改、失败或具体未解决风险继续定向工程与最终同候选旅程。15/30天实际边界、原生存储末步/多故障、硬件密钥库和完整权限/并发/停媒仍开放。

仍 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**。Owner保留重大方向、架构、版本、真实/生产数据、外部供应商与费用、新法律条款、提权、main集成和发布决定。手机由Owner使用，5037保留。历史STOP及已耗预算保持历史身份。
