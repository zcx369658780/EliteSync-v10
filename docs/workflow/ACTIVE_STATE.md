# 当前入口｜2026-11-12 持续完成v10.1.5软件侧

Owner已要求恢复自动化工程，完成v10.1.5软件侧后停下通知，由Owner协助实机验收。长期普通工程授权继续有效。11月11日停止回执及[交接](V1015_RTC_CAPTURE_SUSPEND_HANDOFF_20261111.md)保留历史身份，当前工程状态为 **SOFTWARE_COMPLETENESS_IN_PROGRESS**。

## 当前代码与候选

- 产品根 `D:\EliteSync-v10-product-v1015-20261101`，分支 `codex/v10.1.5-software-continuation-20261101`，origin沿用EliteSync-v10 SSH remote。APP运行代码94fd9aeb，测试入口整理提交b4ed8fb202fd25bcf33f37c2ec49471189a449cd。后端源码25bc01f7保持。
- 当前候选APK SHA256 `6886a54ec1818f38a9da5ebdc1fa51de90bd8dfc067b99b21b70e23e084ef36f`，154215309字节，离线48.349秒/退出0。包为com.elitesync.v1015dev、10.1.5-dev/1010501、arm64 Debug，签名及身份已核。两端安装与同候选运行验证正在进行，以私有运行回执为准。
- 沿用私有开发根 `C:\Users\zcxve\EliteSyncDev\v1015-current-dev`、稳定构建根 `C:\Users\zcxve\EliteSyncDev\v1015-source-debug-workspace` 及固定构建回执。DB/API/WS/SFU四个自有开发容器已恢复，原两个AVD保留。5580实际B/user2，5582实际A/user1。专用ADB5038保持USB排除，5037和手机保留。

## 已完成与实际失败

04873候选将停止轨道恢复和切摄像头改为显式创建、登记、发布与代次清理。call15普通Home后的原生操作曾停止，返回前台出现再次active，稍后才关闭。同期日志缺页面生命周期事件，不能指定唯一原因。此前SDK重连时间早于该次Home，不能据此归因。

94fd修复将inactive纳入暂停，新增页面与采集暂停日志及用户恢复提示。持续保存本服务轨道的Room/采集代次归属，覆盖SDK重连清空publication的窗口。暂停停止并移除本地发布，迟到发布按轨道自身归属清理，明确启麦不放行旧摄像头。108项RTC/来电定向检查通过，四文件analyze无问题，非作者静态复核无剩余确定P1/P2。实际同包后台、明确恢复、切摄像头和断线验证继续进行。

昨日未知POST/pending跨冷启与原UUID幂等重试证据仍限定在3c/65db候选，唯一消息104。既有文字、媒体、通知权限与缓存子链按各自候选保留，详见[版本进度](../versions/v10.1.5/PROGRESS.md)。call15已正常挂断，房间0、双方采集均停止。

## 当前剩余与出口

继续同候选RTC停媒/权限/并发、可信15/30边界与原生清理多故障、最终APP/API/MariaDB/独立Web受控重启旅程，完成唯一实施报告及manifest。硬件密钥、实际音质/AEC和真实Push按真实条件记录，待Owner实机协助与供应商条件分别处理。

冻结AC保持 **10 PARTIAL / AC05 OPEN / G2 false / 真实Push PENDING**，工程完成后交候选，最终产品接受由Owner保留。保护原主库dirty/index、无关目录、历史STOP及已耗预算。不合main、不发布、不启动v10.1.6。私有凭据、SQL、APK、截图和许可证只留本地。
