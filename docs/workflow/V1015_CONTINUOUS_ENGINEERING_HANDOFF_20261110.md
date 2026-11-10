# v10.1.5 持续工程手动交接｜2026-11-10

Owner 因会话过长要求保存并停下。当前为 **PAUSED_FOR_OWNER_MANUAL_HANDOFF**，不是开发完成；后续 Owner 发出继续指令后按长期授权持续工程，不为普通修复、重编或双模拟器重启重复审批。上下文压缩不表示停止，Owner 明确停止才收尾。实际账号额度不可由工程文档保证。

## 身份与资产

- 产品根：`D:\EliteSync-v10-product-v1015-20261101`。
- 分支：`codex/v10.1.5-software-continuation-20261101`；origin：`git@github.com:zcx369658780/EliteSync-v10.git`。
- 收尾前 HEAD：`4d8044972fc3e1da5a28765710c18337f663045d`，此前最后已确认推送 `a2487847d9df679c585aacb2cc598995eaa3dcba`。本文件与依赖变更随后另作普通提交和推送；最终完整 HEAD、远端核对及状态以私有 `final-local-github-receipt-private.json` 为准，避免文件自指提交哈希。
- 本次只保存两份依赖文件和具名文档；无关 `%SystemDrive%/` 保留，原主库 `D:\EliteSync-v10` main@`4bebc8f394248e254c1368a06fbdee5d2c883301`、原255项状态/index不动。
- 资产清理已完成：331本地分支、635远端分支名、229目录及10副本，约39GiB；摘要见 [版本索引](../versions/ASSET_VERSION_SUMMARY_20261110.md)，不重新盘点、复制或清理。

## Owner决定及工作流

以完善APP和真实前后端/持久化功能为主线，随后安全封装（含通讯加密），集中验收；管理面板仍在目标内。UI最后按我的/设置→消息列表/聊天→首页/主要导航处理。

普通工程长期授权包括APP/API/必要数据库工程、定向检查及必要构建、本机独立服务与虚构数据、双模拟器、已有许可的免费官方依赖及常规Git。普通可恢复错误自主修正，按风险做最小必要验证；不重建冻结case、复制SDK/AVD、反复全量回归或逐动作申请。授权和后续持续运行方式已写入AGENTS、CURRENT_WORKFLOW及Owner决定。

手机由Owner使用，不连接、读取或操作。真实用户/生产数据、付费/新供应商服务、提权、重大方向/架构/版本、合main及发布不在本授权内。旧STOP和已耗记录不追溯改写、不退款、不复活旧执行器。不pull/reset/rebase/stash/clean/prune/force；不启动v10.1.6。私有原证、APK、截图、素材、凭据、许可证及SQL不上传GitHub。

## 本会话产品进展

完整细节与历史身份见 [PROGRESS](../versions/v10.1.5/PROGRESS.md)，这里仅保存接续所需事实：

- 已实现聊天历史、原消息UUID重试、断网恢复、附件上传恢复、通知分页/偏好、消息列表更新、图片完整预览、短视频进度/重播及通话恢复。
- 两模拟器真实完成虚构账号登录、文字双向发送、图片选择/上传/对端预览、短视频选择/发送/原生播放到末尾。message15确认丢失后用原UUID重试，返回原server ID，真实数据库仅一条；临时代理已停、reverse已恢复。
- 通知单条标已读：未读5→4；静默设置经APP保存、重开读回及恢复原值。真实Push仍PENDING。
- RTC保留renderer/滚动位置，退出延迟释放；波形使用官方聚合Visualizer，移除widget原始PCM采样。视频双方生成画面/编解码、一次自动重连恢复已证。call7首次实际观察到聚合波形活动，语音双方RTP、UI挂断到房间消失上界0.938秒；call6正常撤MC后房间消失0.297秒。只代表房间清理子证据，不等于完整停媒、AEC或音质验收。call1–7均ended，房间为空，MC已正常恢复generation3。
- 重启后登出/换号缓存精确清理已修复，固定owner locator仅定位删除，不恢复读授权；21项缓存和5项auth检查及非作者复核通过。Android真实密钥库/底层清理未独立核验；未知旧未索引副本不扫描、不宣称全清。
- API默认HTTPS、凭据读取前同源验证、禁redirect，正式Bootstrap拒绝外部端点覆盖；Android主资源禁明文，Debug仅精确本机例外。RTC URL在权限/Room创建前校验；GET重试/401刷新重放统一transport-only客户端，保留会话末端检查，不重入Auth/Retry/Logging。相关定向检查与非作者复核已通过，已进入下列APK。

当前已安装候选仍是源码 `a2487847d9df679c585aacb2cc598995eaa3dcba`，APK SHA256 `9b87b8580d792b16bcb2c4d772a42f7c368488cd9f5da8ea176c4ca8341f0972`，154104232字节，35.709秒构建。包 `com.elitesync.v1015dev`，版本10.1.5-dev/1010501，arm64-v8a/Debug；签名、身份及新JIT标记通过。本次新依赖尚未进入此APK。

## 当前任务：官方RTC依赖配套升级，合包尚待完成

依赖提交 `2dfe1182` 已将 `livekit_client` 固定为2.13.2、`flutter_webrtc`固定为1.6.3。旧LiveKit2.10.0精确锁WebRTC1.6.0，因此使用官方配套，不添加dependency_overrides；离线pub get仅改变这两个锁定依赖，无传递依赖变化。两包许可证与旧版字节相同，私有保留。Flutter3.41.7/Dart3.11.5满足最低要求，宿主compileSdk36/minSdk26不变。

75项定向检查通过（service16、page23、wave7、endpoint29），相关analyze无问题；非作者静态复核无剩余P1/P2。原生AAR合包、安装及新依赖运行验证 **NOT_RUN**，不将源码检查当运行通过。

官方Maven原生包 `io.github.webrtc-sdk:android:150.7871.04` 已完整下载，49,068,339字节，SHA256 `1872dda4e3bf7d6ea6f7c6e11861332081c57081a1e62fc82fab72415c69c84c`，POM无额外依赖。首次下载超时后续传成功，未保留多个完整AAR。回执 `webrtc-150-artifact-private.json`。Pub包归档hash在pubspec.lock中。

### 下次直接接续

1. 先核产品根、remote、分支、HEAD、工作区/index，读AGENTS、ACTIVE_STATE、CURRENT_WORKFLOW及本交接。无需重读case05或重扫旧SDK/AVD。
2. 私有构建 `Control/current-functional.init.gradle` **尚未增加** 本次Maven目录。仅添加 `C:/Users/zcxve/EliteSyncDev/v1015-current-dev/maven`，content仅 `includeVersion('io.github.webrtc-sdk','android','150.7871.04')`，metadataSources用mavenPom/artifact；保持现有`--offline`硬约束和其余固定仓库，不关闭旧guard。
3. `prepare-current-functional-build.py` 增量同步当前已提交tracked输入，不复制SDK。工作区应只剩无关 `%SystemDrive%/`。
4. 在私有构建模块重新执行其Flutter3.41.7 `pub get --offline`，临时使用全局Pub缓存 `C:\Users\zcxve\AppData\Local\Pub\Cache`、PUB_HOSTED_URL=https://pub.dev。私有workspace/PubCache为空，现package_config指向全局缓存；必须重生成指向1.6.3/2.13.2，不能只复制pubspec而误编旧包。
5. `run-current-functional-build.ps1` 按现有离线配置构建，`verify-current-functional-apk.py`核验；再按精确资源清单恢复本机开发服务和双模拟器、安装新包，做一次必要短语音/视频及挂断。无需重做已过的文字、通知和媒体主链；普通兼容失败就地处理，不新建审批链。
6. 完成后更新单一当前入口和必要进度，普通提交/推送，继续已授权功能/安全缺口。可选后续为LoggingInterceptor日志脱敏，当前仅发现完整URI/原始异常日志风险，未确认具体敏感调用、未修改；不把它扩展成阻断性全面审计。

## 本地固定资源与停止状态

私有根：`C:\Users\zcxve\EliteSyncDev\v1015-current-dev`。`runtime-private.json`是准确资源清单，`credentials-private.json`及`fixture-private.json`含虚构账号秘密，不打印、不上传。

两个自有模拟器emulator-5580/5582及专用ADB5038已停止；不触碰默认5037或USB手机。SFU→WS→API→DB四个自有容器已按ID核对并停止，数据卷、AVD及共享Docker引擎保留；未删除容器或数据库。私有停止回执 `owner-stop-handoff-20261110-private.json`。后续不是自动续跑；收到Owner继续后才按清单恢复。重启API时先停SFU，再API，再SFU，避免watchdog按设计撤销媒体。

稳定构建根：`C:\Users\zcxve\EliteSyncDev\v1015-source-debug-workspace`；APK固定落点 `ApkOutput/app/outputs/apk/debug/app-debug.apk`，固定回执 `state/current-functional-build.json`，历史摘要 `state/functional-build-history.jsonl`。工具统一在 `C:\Users\zcxve\EliteSyncDev`，不调用退役case执行器。下载已结束，无构建或新动态测试在运行。

本次停止前开发库为虚构user1/2，15条消息、4媒体，MC generation3；历史操作回执保留，不重做或改写。未经恢复和检查不把历史运行状态当作当前服务可用。

## 未完成与结论边界

仍10 PARTIAL、AC05 OPEN、G2 false、真实Push PENDING、真机缓存UNKNOWN。15/30天边界与清理、完整权限/并发及旧JWT、通知、RTC/AEC/听感/完整撤权停媒、其余功能缺口及最终集中验收未完成。不宣称整体通讯加密、端到端加密或整版PASS；UI最终收尾与管理面板目标继续保留。
