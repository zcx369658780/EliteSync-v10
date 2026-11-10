# 当前入口｜2026-11-11 持续工程进行中

Owner已明确恢复全自动持续工程；普通工程长期授权保留，功能优先，随后安全封装和集中验收，直到Owner明确叫停。手机不连接、读取或操作；不复活旧STOP，不合main、不发布、不启动v10.1.6。

**当前节点：LiveKit2.13.2 / WebRTC1.6.3配套升级已完成离线接入、合包与双模拟器短通话核心验证。** 网络日志脱敏已合包并实测，Android已知缓存原生清理与正常UI登出子范围通过；通知权限竞态修复已合包，系统拒绝/允许/撤销重启后状态、消息可用和本人安全入口可达已验证；权限及选择标记已恢复。旧通知当前授权子范围已记录，点击处理器执行未独立确认；RTC系统采集停止子范围已补证，当前网关的未过期旧JWT在撤销和新代同意后均拒绝已验证；下一项验证聊天历史分页与读取失败恢复，不重复已过主链。

- 产品根 `D:\EliteSync-v10-product-v1015-20261101`，分支 `codex/v10.1.5-software-continuation-20261101`；原主库dirty/index与无关 `%SystemDrive%/` 保留。资产清理已结束，不重新盘点或复制SDK/AVD。
- 当前APK源码 `81f9abfc08283fecc254257b0aca395cc9dea4c7`，SHA256 `ed01b528e09f726e907027d43cae1ce7d13648aee8b9697a30ae26e34a84c3cb`，154151779字节；38.993秒构建、退出0，签名/身份/标记核验并更新5580。两端现均为同一ed01候选。此前6343的RTC与4211的日志/缓存证据各按身份保留，不冒充新包重测。
- 6343候选已在两个自有模拟器完成call8语音双方双向RTP及原生聚合波形活动已证，UI挂断到房间不存在上界0.907秒。call9双方音频RTP、视频编码/解码和本地/远端生成画面已证；发起端一次自动重连后恢复，UI挂断上界1.422秒。自身进程快照未见Concurrent modification、Unhandled Exception或Visualizer失败。call1–9均ended，房间为空；不称连续无中断质量、AEC/听感或完整≤5秒停媒已通过。
- 自有SFU/WS/API/DB四容器与专用ADB5038运行；两模拟器均运行同一ed01候选，5582为本次必要原生采集验证恢复并重新正常登录user2。沿用原数据卷/AVD，不重迁移或复制。Docker引擎恢复后，首次冷启动鉴权超时令网关按设计fail-closed；API就绪后只重启原SFU即恢复，私有恢复工具补充真实鉴权就绪检查，未放宽watchdog。默认ADB5037及手机未触碰，相机为生成画面。
- 通知权限：4例RED复现的旧响应覆盖撤销/重复请求已修复，32项定向检查与最终analyze通过。当前包实际系统弹窗拒绝、设置允许与撤销后冷启动读回均正确；OS撤销会杀进程，同进程晚回仅有组件证据。拒绝权限后实际进入聊天，本人安全入口可见可点击，未操作Safety记录；服务端偏好不变、原OS权限与flags精确恢复，真实Push仍PENDING。
- 旧通知14：正常MC撤销后服务端清空路由/参数/payload；第一次UI刷新先移除按钮，未实际点到；一次对刚观察位置的点击未进入聊天，read_at未变，但未见反馈提示，处理器执行未独立确认，保留PARTIAL。两段原证分开，双方经正常request/accept恢复MC generation4、5，该节点恢复到5；当前采集验证后MC为6、call1–10均ended、房间为空。
- call10原生采集：同候选两端CAMERA/RECORD_AUDIO在撤权前均由Android AppOps确认running；正常MC撤销后最晚3.484秒（单一主机monotonic、ADB收到观察的保守上界）四项均inactive，恢复第6代同意后仍未重启。撤权前SFU快照仅1参与者，日志虽证双方音视频RTP及编码/解码、一次重连恢复，仍保留非稳定双向基线限制；不代表网络停包/AEC或完整AC05通过。私有 `rtc-native-capture-stop-private.json`。
- 网关JWT子范围：正常API call11两参与者JWT先均200，坏签名403；正常撤MC后两个未到exp的旧JWT均403，双方恢复新MC generation7后仍403。仅API＋真实本机网关validate，没有启动本次SDK媒体。当前call1–11均ended、房间为空，双方APP为该隔离接口验证临时force-stop，AVD/数据保留；必要时正常恢复。私有 `rtc-old-jwt-guard-private.json`，原JWT只私有。
- 精确资源与私有证据在 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`：`runtime-private.json`、`webrtc-150-apk-native-private.json`、`webrtc-163-two-app-runtime-private.json`、`network-android-logging-receipt-private.json`、`cache-android-cold-local-cleanup-private.json`、`cache-android-ui-logout-private.json`、`notification-permission-runtime-private.json`；临时Flutter调试工具与精确debug forwards已关闭，固定构建回执在 `v1015-source-debug-workspace/state/current-functional-build.json`。原证、APK、截图、凭据、许可证和SQL不上GitHub。
- 原文字/图片/短视频/通知/确认丢失后原UUID幂等重试等有效节点按各自身份保留。TLS/同源、RTC URL和统一transport-only重放已在当前APK。Android离线冷启动缓存/时钟仍锁定，现有AuthLocalDataSource清理方法真实删除1个已知旧对象与索引；另经正常设置UI确认登出后，4个已知对象、索引/定位键及token/refresh/resume均不存在。前者是调试器调用当前既有生产实例，后者是UI链，分开记录；未知副本不扫描，硬件密钥特性/真实故障矩阵与真机仍未核实。
- 仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING。15/30天边界、Android硬件密钥特性/清理故障矩阵、完整权限/并发/旧JWT、通知与RTC质量矩阵、剩余安全封装和最终集中验收未完成。UI最后按我的/设置→消息列表/聊天→首页/导航；独立管理面板目标保留。

[Owner长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md) · [工作流](CURRENT_WORKFLOW.md) · [进度及证据边界](../versions/v10.1.5/PROGRESS.md) · [上次手动交接](V1015_CONTINUOUS_ENGINEERING_HANDOFF_20261110.md)
