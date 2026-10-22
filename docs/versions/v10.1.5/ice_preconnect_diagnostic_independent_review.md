# EliteSync v10.1.5｜ICE连接前诊断能力 Astra 独立源码复审

日期：2026-10-22（Asia/Singapore）。评审者：EliteSync GPT/Astra产品与安全顾问。

**`ICE_DIAGNOSTIC_SOURCE_REVIEWED_WITH_OBSERVATIONS / PARTIAL / POSITIVE_DEBUG_BUILD_BLOCKED / PHONE_RUNTIME_NOT_RUN / AC05_OPEN / V10.1.5_NOT_ACCEPTED / OWNER_DECISION_REQUIRED / NO_AUTOMATIC_R2 / NO_MAIN_PRODUCT_INTEGRATION`**

**审查范围分层**：这次对**有限诊断源码方案、Git提交身份和已交付报告的真实性**进行独立审查。不能将`20+93`本地测试、普通APK成功、五个拒绝构建负例改称“诊断debug APK已正向构建并在Android验收”；它没有产出，本版安装0次、call0次、Room.connect0次。报告中的所有Windows/Gradle/Flutter命令、1332份原证及设备未操作情况均属于`CODEX_REPORTED/LOCAL_ONLY`，而GitHub对象、八个真实源码文件及有限源码逻辑属于`ASTRA_GITHUB_DIRECT`。完整冻结AC-10.1.5-05和Owner方案A不变。

## 1. 固定authority／发布身份

- 复审前live `main` = `0c118ac9ba5b6c275101d63880152f5826330d4e`，产品仍为已接受v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。此main不是待验v10.1.5源码。
- 唯一Owner任务`docs/versions/v10.1.5/OWNER_APPROVED_ICE_PRECONNECT_DIAGNOSTIC_TASK_20261022.md` Blob `45b885c88af755b166c899b1c6a1432b778a413c`。之前P1独立复审Blob `2df373a6151d11c68d639ea6669345e22f846093`，固定R1源Commit `1c5cd2bb7919c435e8486a76959db75e9ccc367f`。
- 本轮**固定诊断源码**Commit `24ddf05875d8d4abad7a6b473f882698c9885c2a`，唯一Parent `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7`，Root Tree `2c656957e1c229ca30f7c07b173bcb1062310d2c`，完整apps Tree `72c617cf86d5c653dd722accde340b51d2e085eb`，完整services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。
- 最终文档交付Commit `8bee827c20c26c4ec954b774c011f09238ec59b3`，唯一Parent即固定诊断源码，Root Tree `81aad417e50f6d7a180135248ccdd73da9b69c6f`。GitHub比较原P1→源码：ahead1/behind0、**仅8项apps源码/测试变动**；源码→最终交付：ahead1/behind0、**仅2个新增docs**；完整apps/services子Tree从源码到最终交付完全相同。
- 报告`ICE_PRECONNECT_DIAGNOSTIC_IMPLEMENTATION_REPORT.md` Blob `18ef944586765231ca7b003d50e15ad3165271de`；manifest`ice_preconnect_diagnostic_manifest.json` Blob `bae88478daa065c16b8fd5b69caf4c90240a7359`。Astra直接读取。八个manifest中的源码path/mode/Blob与真实递归Git Tree **8/8一致**，不是仅信任Codex提供的SHA。
- 固定源码新增`rtc_ice_diagnostic.dart` Blob `6bad6b77b6ee112ce7adeb18f339ddd38be4782e`、修改`rtc_livekit_service.dart` Blob `66053d78a15a6a28311083bd99c83e6bb1331777`、独立入口`dev/v1015_ice_diag.dart` Blob `49e607ba3697f9b72865e677d037aef76a547e51`；Android构建/宿主身份和两测试文件在八项清单中。全部冻结R1以前的产品和此前审阅文件未被修改。

## 2. 源码逻辑独立复核

**连接前采样挂载：SUPPORTED_AT_SOURCE。** 原R1 `_startAudioStatsTimer`仅在成功`await room.connect`、启麦后运行，因历史30秒连接失败无实时统计；新版诊断分支先创建`IcePreconnectObserver`，再通过`observer.during(() => room.connect(...))`包裹真实连接操作。两侧publisher/subscriber使用当前`pc.getStats()`读已创建PeerConnection；空PC记`NOT_INITIALIZED`，不是ICE失败。此接线由固定源码直接读取。

**边界和迟到结果：SUPPORTED_WITH_TEST_LIMITATIONS。** 每秒触发、整个诊断30秒截止、单个read750ms等待上限；`_pendingReads`保留尚未真正完成的native未来请求，避免超时后同side叠加getStats；`isCurrent`绑定dispose、`_connectionGeneration`、当前Room及远端session current。stop取消本端Timer，迟到结果不再输出；失败仅记录`terminalSnapshot=NOT_CAPTURED`及最近真实样本年龄，未伪造“失败瞬间采样”。原异步底层getStats调用无法被`Future.timeout`物理取消，这个事实仍成立；如果native永远不完成，当前策略是本会话不重叠读取，不代表释放原生资源或已现场验证性能。**实际Android连接中是否稳定采到字段尚未验证。**

**候选与脱敏：SUPPORTED_AT_SOURCE，运营隐私仍有局限。** `IceDiagnosticSnapshot.fromReports`从`StatsReport`重建白名单，输出候选`protocol/candidateType/tcpType/IP版本/loopback类别`、pair的`state/nominated/selected`及计数、transport的`dtlsState/iceRole`等，限额candidate32/pairs16/transports8。只有`transport.selectedCandidatePairId`等对应确切字段时才将某pair标记选中；不输出原始candidate/SDP、动态端口、IP、JWT或Stats ID。记录`AGGREGATE_ICE_COUNTERS_NOT_PACKET_PROOF`，请求／响应计数不自动等于真实STUN逐包复核。未知、null、字段缺失按UNKNOWN/NOT_AVAILABLE。经现场运行的SDK到底返回哪些字段仍`NOT_RUN`。

**test-only门与无音频：SOURCE_SUPPORTED/POSITIVE_ARTIFACT_UNVERIFIED。** Dart需明确诊断define、kDebugMode、local＋R1、原生`debugBuild`和`iceDiagnosticBuild`、精确隔离包`com.elitesync.v1015icediag`及本地8031入口。Android Gradle固定三标志allowlist，debug-only任务、单独诊断AAR缓存坐标、applicationId suffix最后应用；release/profile、缺父级和版本混用被Codex报告配置拒绝。诊断分支拒绝视频和手动启麦/摄像头，`autoSubscribe=false`，若连接成功则早于原产品`setMicrophoneEnabled(true)`执行合法end/leave；正常非诊断入口不改变。**正向debug AAR/APK未构建成功**，上述机制尚未在实际产物上验证；普通release AAR调试宿主的成功与字符串未发现是必要隔离观察，不是正向诊断build的证据。既有其他SDK/PID日志不在本项目白名单保护保证内，将来真实运行的原始日志必须`LOCAL_ONLY`。

**仍有证据限制**：一次非作者高思考静态复核提出并由作者修复F1构建包名覆盖、F2真正异步Future重叠、F3失败终态、F4Room身份日志问题；没有第二次非作者修复后审查，也无真机正向回归。Astra直接审阅关键源后，未看到足以据此定性为产品安全P1的新增高置信问题；并不保证无未知缺陷。

## 3. 本轮测试、构建与真机门

| 子项 | Astra证据判定 |
|---|---|
| 诊断定向Flutter20项 | `CODEX_REPORTED_EXIT0/20`；源码所测包括preconnect时序、null、selected/unknown、隐私、停止、pending及无媒体 |
| 相关普通RTC与main_prod回归93项 | `CODEX_REPORTED_EXIT0/93`；不代替其他非相关全量测试 |
| 定向Flutter analyze | `CODEX_REPORTED_EXIT0` |
| 5项Gradle拒绝负例 | `CODEX_REPORTED_EXPECTED_REJECTION`；不能替代正向构建 |
| 普通R1调试宿主＋release AAR | `CODEX_REPORTED_BUILD_PASS`，SHA256 `7131b57c6c8f755197573e791d4bfa9d5db4ce07862726d24dace445f8b904bd`，**不是诊断APK，且未安装** |
| 诊断debug AAR/APK | **`BLOCKED`**；`:connectivity_plus:extractDebugAnnotations`在离线Gradle中缺精确`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab` Maven artifact。失败exit1，没得到可签名／安装的诊断APK |
| 真机安装、call、Room.connect、ICE getStats字段 | **`NOT_RUN`**；0次安装、0次call、0次连接，不能继承上轮真机观测变成此次正向证据 |
| 历史保护 | 1332份具名原证byte/hash一致、5根/493 refs/private env及原保护状态按Codex本地回执；原Windows长路径警告153行保留，未作全部缓存逐文件证明 |

**构建阻断与RTC产品因果分离**：精确缺失Flutter debug embedding构建依赖是离线**工具链/产物门**，并不是现有Android RTC媒体失败的新根因；解决依赖也**不保证**后续ICE连通。不得用复制flutter.jar、伪造Maven元数据、降级为release AAR或关闭构建门来“获得APK”。

## 4. 正式裁决与后续Owner决策

**`DIAGNOSTIC_SOURCE_SUPPORTED_WITH_OBSERVATIONS / DIAGNOSTIC_DEBUG_APK_NOT_BUILT / RUNTIME_NOT_RUN / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`**。允许保留源码和测试作为受控候选，不签诊断设备`FUNCTION_ACCEPTED`，更不签v10.1.5整版`ACCEPTED`。

建议优先解决**单一且可核的构建门**：由Owner另行批准严格只获取与已装Flutter engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`匹配的`flutter_embedding_debug` Maven artifact及必要已证缺失的同版本依赖，从可信来源校验版本/来源/哈希后加入本任务专属缓存，再只重跑**一次**诊断debug正向构建与产物debug-only保护回读。暂不下载新SDK、不修改产品业务/RTC网络、安全门及旧缓存，不自动发起新手机连接。若需外网/下载/新产物，须Owner对精确供应来源和范围作再次授权。

在有**实际诊断APK**、正确独立packageId/签名/版本／最小测试包安全证明，及Owner当场手机安装许可之后，才讨论已有USB+隔离SFU条件下**最多一次**新ICE观察；第二个有效媒体APP、旧RTC JWT及真实媒体撤权≤5秒仍是独立未验硬门。

未授权自动R2、v10.1.6、开放UDP/LAN/防火墙、修改SFU监听、替换SDK、安装普通隔离控制包、自动合并任何产品源码到main或清理旧证据。Owner方案A保持。
