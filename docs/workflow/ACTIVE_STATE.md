# 当前入口｜2026-11-11 持续工程进行中

Owner已明确恢复全自动持续工程；普通工程长期授权保留，功能优先，随后安全封装和集中验收，直到Owner明确叫停。手机不连接、读取或操作；不复活旧STOP，不合main、不发布、不启动v10.1.6。

**当前节点：LiveKit2.13.2 / WebRTC1.6.3配套升级已完成离线接入、合包与双模拟器短通话核心验证。** 网络日志脱敏已合包并实测，Android已知缓存原生清理与正常UI登出子范围通过；通知权限同账户晚回覆盖撤销及重复请求问题已用4例RED复现并修复；32项定向检查/analyze通过，尚待合包后做一次系统权限拒绝/撤销验证，不重复已过的主链。

- 产品根 `D:\EliteSync-v10-product-v1015-20261101`，分支 `codex/v10.1.5-software-continuation-20261101`；原主库dirty/index与无关 `%SystemDrive%/` 保留。资产清理已结束，不重新盘点或复制SDK/AVD。
- 当前APK源码 `bfbbe4eda27423acf25fdf48eb2b763102650b13`，SHA256 `4211c5a1e2adf60570c6e87605805ce85bee098f8e831aeb41c04f275a4dfbef`，154157018字节；35.397秒构建、退出0，签名/身份/功能标记通过并安装两端。新日志在Android实际失败/成功登录中只含固定元数据，未附原始异常/堆栈。此前6343候选的RTC原生比对与短通话证据单独保留，不冒充本次重测。
- 6343候选已在两个自有模拟器完成call8语音双方双向RTP及原生聚合波形活动已证，UI挂断到房间不存在上界0.907秒。call9双方音频RTP、视频编码/解码和本地/远端生成画面已证；发起端一次自动重连后恢复，UI挂断上界1.422秒。自身进程快照未见Concurrent modification、Unhandled Exception或Visualizer失败。call1–9均ended，房间为空；不称连续无中断质量、AEC/听感或完整≤5秒停媒已通过。
- 自有SFU/WS/API/DB四容器与专用ADB5038运行；模拟器5580已恢复user1正常登录，5582为节约内存暂停，AVD/已安装新包保留，后续确需双端时再恢复。沿用原数据卷/AVD，不重迁移或复制。Docker引擎恢复后，首次冷启动鉴权超时令网关按设计fail-closed；API就绪后只重启原SFU即恢复，私有恢复工具补充真实鉴权就绪检查，未放宽watchdog。默认ADB5037及手机未触碰，相机为生成画面。
- 精确资源与私有证据在 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`：`runtime-private.json`、`webrtc-150-apk-native-private.json`、`webrtc-163-two-app-runtime-private.json`、`network-android-logging-receipt-private.json`、`cache-android-cold-local-cleanup-private.json`、`cache-android-ui-logout-private.json`；临时Flutter调试工具与精确debug forwards已关闭，固定构建回执在 `v1015-source-debug-workspace/state/current-functional-build.json`。原证、APK、截图、凭据、许可证和SQL不上GitHub。
- 原文字/图片/短视频/通知/确认丢失后原UUID幂等重试等有效节点按各自身份保留。TLS/同源、RTC URL和统一transport-only重放已在当前APK。Android离线冷启动缓存/时钟仍锁定，现有AuthLocalDataSource清理方法真实删除1个已知旧对象与索引；另经正常设置UI确认登出后，4个已知对象、索引/定位键及token/refresh/resume均不存在。前者是调试器调用当前既有生产实例，后者是UI链，分开记录；未知副本不扫描，硬件密钥特性/真实故障矩阵与真机仍未核实。
- 仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING。15/30天边界、Android硬件密钥特性/清理故障矩阵、完整权限/并发/旧JWT、通知与RTC质量矩阵、剩余安全封装和最终集中验收未完成。UI最后按我的/设置→消息列表/聊天→首页/导航；独立管理面板目标保留。

[Owner长期授权](../decisions/OWNER_FUNCTION_FIRST_ASSET_CLEANUP_20261110.md) · [工作流](CURRENT_WORKFLOW.md) · [进度及证据边界](../versions/v10.1.5/PROGRESS.md) · [上次手动交接](V1015_CONTINUOUS_ENGINEERING_HANDOFF_20261110.md)
