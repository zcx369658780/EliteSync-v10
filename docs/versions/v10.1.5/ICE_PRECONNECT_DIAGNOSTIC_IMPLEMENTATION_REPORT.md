# v10.1.5 ICE preconnect诊断能力实施报告

2026-10-22。**PARTIAL / DIAGNOSTIC_APK_BUILD_BLOCKED / DIAGNOSTIC_BUILD_GUARD_OPEN / PHONE_RUNTIME_NOT_RUN / AC05_OPEN**。

本轮完成连接前诊断源码、隔离构建门、定向测试及一次非作者静态复核。诊断debug APK因已安装工具的离线Maven缓存缺项未产出，不能把源码/fixture通过称为真机诊断能力已验证。本轮安装0次、合成call 0条、Room.connect 0次；手机及数据库、Laravel、guard、SFU均未操作/启动。本轮没有修改RTC网络，也没有获得新的ICE运行时结果。

## 1. 权威与连续源码

唯一任务固定Blob `45b885c88af755b166c899b1c6a1432b778a413c`，Astra前轮复审Blob `2df373a6151d11c68d639ea6669345e22f846093`，均按固定GitHub路径全文读取，LOCAL_ONLY原字节重新hash匹配。实时main及发布后读回均为 `0c118ac9ba5b6c275101d63880152f5826330d4e`；main相对前P1 main只有授权文档变化，产品仍为v10.1.4。未将main产品覆盖候选。

| 对象 | 固定身份 |
|---|---|
| 本轮source commit | `24ddf05875d8d4abad7a6b473f882698c9885c2a` |
| 唯一Parent（上一P1交付） | `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7` |
| Source Root Tree | `2c656957e1c229ca30f7c07b173bcb1062310d2c` |
| apps Tree | `72c617cf86d5c653dd722accde340b51d2e085eb` |
| services Tree（与R1一致） | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |
| 固定R1源码 | `1c5cd2bb7919c435e8486a76959db75e9ccc367f` |
| R1 Root / apps | `165eb1f362db533ca94bfe1db677ff6f7bd477ed` / `0784c8aa7b0915a04b83693a45401197e31d93a2` |
| 原rtc_livekit_service.dart Blob | `6495fc64ef49a914ba548142f14f23429a536984` |

连续工作树：`C:/Users/zcxve/.codex/worktrees/elitesync-main-v1013-20261021/EliteSync-v10`。新候选分支 `codex/v10.1.5-ice-preconnect-diagnostic`。source为一个直接继承62f0的提交，其后交付提交仅新增本报告与manifest。未重写首轮/R1/P1原件、冻结plan、AC或Astra裁决。

## 2. D0 SDK与字段能力矩阵

实际pubspec.lock与package_config：LiveKit **2.10.0**、flutter_webrtc **1.6.0**、webrtc_interface **1.5.1**；不是pubspec约束下界2.7。Flutter **3.41.7 / Dart 3.11.5**，engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`。pubspec/lock、已安装SDK及全局Pub cache未修改、未下载。未为代码结构查询建立全库索引；图谱未索引时回退定点源码/字符串读取。

`RTCPeerConnection.getStats([track]) -> Future<List<StatsReport>>`，其中id/type/timestamp和dynamic values Map由Android通道透传；静态接口支持调用，**不保证每一个字段由本机native实现返回**。Room.engine.publisher/subscriber在connect等待期间按SDK实现可创建；沿用原文件已有internal-member使用边界，没有修改SDK/原生WebRTC或覆盖回调。

| 字段/机制 | 锁定SDK证据与实现 | 本轮真实RETURNED_RUNTIME |
|---|---|---|
| 当前publisher/subscriber PC、getStats | SDK_VERSION_SUPPORTED；PC晚创建记NOT_INITIALIZED | NOT_RUN |
| pc.connectionState / iceConnectionState | SDK_VERSION_SUPPORTED；白名单状态类 | NOT_RUN |
| transport.selectedCandidatePairId | SDK现有消费及dynamic Map支持；仅内部关联，ID不输出 | NOT_RUN |
| candidate-pair.state / nominated / selected | dynamic字段有则白名单消费；不从nominated+succeeded推定selected | NOT_RUN |
| requestsSent / responsesReceived / RTT | 有限非负数/整数校验；无效或缺项NOT_AVAILABLE | NOT_RUN |
| local/remote protocol / candidateType | dynamic有则消费；未知枚举UNKNOWN | NOT_RUN |
| tcpType active/passive/so | SDK未给静态必返保证；仅dynamic可选白名单消费 | NOT_RUN |
| address/IP family、loopback类别 | 内存分类后只输出类别；不输出地址、端口或ID | NOT_RUN |
| transport.dtlsState / iceRole | dynamic可选字段；缺项UNKNOWN | NOT_RUN |
| PC事件/粗状态 | SDK事件可用，保留原事件；采样不覆盖SDK callbacks | NOT_RUN |
| 逐包STUN Request/Response | 无抓包/新工具，NOT_OBSERVABLE；聚合计数不是逐包证据 | NOT_OBSERVABLE |

上轮call4的30.209秒失败、无selected/STUN/DTLS结果仍有效。本轮没有排除TCP角色/拓扑等旧假设，也没有新的证据可以定位底层ICE故障。不能从字段缺失推断没有STUN检查；不能用前轮不同实例的listener补足本轮窗口。

## 3. D1 实现与隐私边界

新增纯白名单快照与有界observer，`RtcLiveKitService.ensureConnected`在调用Room.connect closure之前启动，等待期间每秒读取两侧已创建PC。30秒deadline，单读750ms诊断超时；每侧保留真正未完成的native future，超时不取消底层请求，也不会再次叠加该侧getStats。迟到结果在stop/epoch/current边界后丢弃。leave/dispose、generation变化和远端会话isCurrent失效停止输出。诊断出错不替代connect原异常。

成功时在时限及当前会话内尝试最终无媒体快照，然后合法end/leave。失败时输出 `terminalSnapshot=NOT_CAPTURED` 及单调时钟的lastSnapshotAgeMs，不把旧周期快照改称失败瞬间快照；30秒后不追加统计读取。停止后仅连接返回时可产生一次终态元数据，仍须current有效，没有后台采样。

测试包 `TEST_ONLY_NO_AUDIO`：跳过麦克风/摄像头权限及音频引擎预初始化，autoSubscribe=false，成功退出早于setMicrophoneEnabled；公共启麦/启摄像头方法拒绝，video join拒绝。普通开关off保留原权限、音频及fail-closed路径。

新记录只用 `ICE_DIAG_TEST_ONLY` 白名单：临时diag序号、相对时间、peer类别、状态、候选类别、布尔及有依据的计数。candidate最多32、pair16、transport8，超限显式标记；每2项分块为完整小JSON，避免Android单条日志截断。未知/私密字段、原始ID/IP/port/SDP/JWT不会转发。原join元数据在诊断分支跳过，connect日志room/identity脱敏。**这不是整个PID/第三方SDK日志均已脱敏的保证**；如未来设备运行，原PID日志仅LOCAL_ONLY，公开只能用经过白名单过滤的记录。当前未采集任何设备日志、自然声音或摄像头数据。

## 4. D2 构建隔离及实际缺口

独立入口 `lib/dev/v1015_ice_diag.dart`；Dart编译flag + debug + local/R1 + native debug/diag marker + 精确applicationId + 固定本地endpoint必须同时满足。诊断定义只允许三项明确flag，混入旧版本/未知标志在Gradle配置期拒绝，诊断suffix最后设置。native门拒绝普通R1包。release/profile、缺父级或retention混用均不能打诊断包。

诊断拟定包名 `com.elitesync.v1015icediag`，versionName `10.1.5-ice-diag-test`；独立debug AAR坐标 `1.0-icediag-<source+defines digest>` 与repo路径，普通R1仍使用release AAR，避免kDebugMode实际为false或污染普通坐标。

实际离线诊断构建exit **1**：`:connectivity_plus:extractDebugAnnotations`解析 `io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`时报告 **No cached version available for offline mode**。安装SDK虽然有相同engine的flutter.jar，但不等于已有可解析Maven依赖。本轮未下载、升级、重打包SDK、伪造Maven条目或回退release AAR掩盖debug门。因此诊断APK、签名、最终包名安装实物及hash均 **NOT_PRODUCED/NOT_VERIFIED**，`DIAGNOSTIC_BUILD_GUARD_OPEN`，不安装、不运行D3。

作为flag-off隔离控制，最终普通R1 Android debug宿主＋release AAR离线构建exit0：

- applicationId `com.elitesync.v1015r1dev`；versionName `10.1.5-r1-dev`，versionCode1010511，debuggable；arm64-v8a及x86_64。
- APK bytes `416357439`，SHA256 `7131b57c6c8f755197573e791d4bfa9d5db4ce07862726d24dace445f8b904bd`。
- apksigner verify exit0，signer cert SHA256 `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09`。
- 两ABI libapp.so中均未见新增诊断marker、计数语义或READ_PENDING/lastSnapshotAgeMs字符串。结合flag-off测试与门禁源码，这是普通路径隔离证据；字符串缺失不单独当作完备形式证明。
- 此包仅本地保留为隔离控制，**未安装、不是诊断APK，不替代缺失的诊断产物**。已有Owner手机包及数据未覆盖/卸载。

## 5. 实际命令、退出码与stdout

下列均在连续工作树明确目录执行；原stdout/stderr/exit文件及SHA256列于manifest LOCAL_ONLY evidence清单。未上传APK或私密日志。

| 检查 | 实际命令/目录（省略机器绝对工具前缀） | exit与stdout |
|---|---|---|
| 最终诊断定向 | Flutter模块：`flutter test --no-pub --reporter expanded --dart-define=ELITESYNC_ICE_DIAG_TEST_ONLY=true --dart-define=ELITESYNC_V1015_LOCAL_BUILD=true --dart-define=ELITESYNC_V1015_R1_LOCAL_BUILD=true test/features/rtc/domain/services/rtc_ice_diagnostic_test.dart test/features/rtc/domain/services/rtc_ice_diagnostic_mode_test.dart` | **0，20 tests passed**；PC晚创建、隐私、selected/unknown、失败/leave/epoch/dispose、30s、分块、真实pending不重叠、成功无媒体合法end |
| 最终相关静态分析 | `flutter analyze --no-pub`后列上述2测试、rtc_ice_diagnostic.dart、rtc_livekit_service.dart、dev/v1015_ice_diag.dart | **0，No issues found** |
| 普通路径回归 | `flutter test --no-pub --reporter expanded test/features/rtc test/main_prod_internal_feature_gate_test.dart` | **0，93 tests passed** |
| 五项真实构建负例 | Android：`gradlew.bat :app:assembleRelease/assembleProfile/assembleDebug -PflutterDartDefines=<case> --offline --console=plain --no-daemon` | release、profile、missing_parent、mixed_v1014、mixed_v1012各 **1**，均明确 `ICE_DIAG_GUARD_REJECTED`，不是把任意构建失败当成功 |
| 诊断构建 | Android：`gradlew.bat :app:assembleDebug -PflutterDartDefines=ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain --no-daemon`（defines为一个引用参数） | **1**，上述离线embedding缺项；原件保留，后续未重复同一失败构建 |
| 最终普通隔离控制构建 | 同上，defines仅local=true及R1=true，dualDevice=true | **0，BUILD SUCCESSFUL in 1m 33s** |
| APK身份 | 已安装aapt dump badging；apksigner verify --print-certs | 各 **0**；身份见第4节 |
| 原空白检查 | `git diff --check` | **2**；现有CRLF约定的新增行尾被报trailing whitespace，原证保留 |
| 历史CRLF规则检查 | `git -c core.whitespace=cr-at-eol diff --check` | **0**；未全文件换行归一化 |

**原失败不覆盖**：最初helper不存在的TDD red exit1；早期analyze exit1的5个问题及后续2个lint均已集中修正；一条回归命令写错main_prod测试文件名exit1，正确文件名后最终93项通过；失败终态测试最初把tester.pump的250ms当成Stopwatch物理时间，exit1后改为检验真实单调年龄范围及NOT_CAPTURED，原stdout保留。fixture时间不是物理经历时间。旧R1/P1全部原失败仍保存。早期10/40/15/17/18及90/91项结果仅为修复过程，不代替最终20/93项。

所有测试均为单元/Widget/构建验证，**不能证明真实手机ICE/TCP、DTLS、媒体、听感、重连或5秒撤权成功**。

## 6. D3未执行与最小后续门禁

D2先决条件未关闭，故未枚举手机、未安装、未请求权限、未建立reverse、未创建合成call、未启动Laravel/guard/SFU/DB。连接预算实际使用 **0/1**，没有背景等手机或轮询，也没有本轮资源需停止。不用旧手机/麦克风批准代替本次新包安装现场许可。

若Owner在Astra复审后继续，最小先决条件为：以现有同engine可信离线Maven依赖完成诊断debug APK，或明确批准获取相同engine缺失构建依赖；不需要升级SDK/变更RTC网络。随后核验最终独立包名、签名与hash、手机在场及此次安装许可、独立DB恢复点/volume身份、既有loopback端口/权限和同一SFU实例实际listener。全部满足才可能使用正式任务最多一次连接授权；本候选交付后不自行续拨。原TCP角色、pair/STUN/DTLS均 **RUNTIME_NOT_RUN**；不据此建议必须开放UDP或切换方案。

## 7. D4非作者有界复核

一次独立GPT-6.1 Sol/high静态复核，非作者未运行设备、服务、构建或修改文件。提出：F1包名被混合flag覆盖（P1）、F2底层future超时重叠（P2）、F3失败无终态（P2）、F4旧room/identity日志隐私边界。实施者分别以精确flag allowlist/suffix最后设置、per-side真实pending、NOT_CAPTURED+单调年龄、诊断分支元数据抑制修正。新增真实配置负例及定向测试已通过。修后由实施者核验，**未宣称第二次非作者复核**。

复核意见不等于APK物理验证或Astra ACCEPTED。已知剩余阻断为debug依赖缺项、诊断APK实物身份未验、真机字段与ICE全未观测。

## 8. D5保护、发布与完整Tree回读

保护1332份已登记历史原证，逐份bytes/SHA256一致；五个历史根HEAD/branch/index/status均一致，493个原refs未移动，private环境文件hash一致。D根已有153条Windows长路径status警告前后相同，**不把具名清单外缓存或未登记历史文件宣称为完整逐字节覆盖**。没有数据库连接、迁移/写入、合成数据新增、时间戳修改或原volume操作，已有恢复点/SQL/APK/备份未清理。当前唯一连续工作树的新增构建缓存属本轮工具产物，不等同历史原证。

source已普通non-force发布至候选分支。GitHub connector读取固定source文件；独立已认证REST读取source commit/Root/parent与递归Tree、raw HTTP对8个变化文件原字节重新计算Git Blob，全部匹配。完整apps/services产品映射 **1926项（含Tree），1449个文件Blob** 的path/mode/type/object均相等；services与R1一致。未认证REST首读曾HTTP403 rate limit，原失败记录保留；改用既有认证的只读REST，不涉及权限扩大。

本报告与manifest随后以仅docs提交普通发布。交付提交的自哈希不写入其自身内容，最终HEAD/Root/docs Blob及raw回读收据保存在LOCAL_ONLY `delivery-remote-readback.json`，最终用户交付固定链接据该收据。未修改main，未创建合并/发布release。

### Source变化文件（完整）

| Path | Mode | Blob |
|---|---|---|
| apps/android/app/build.gradle.kts | 100644 | `5a08d63f5f95155ca1f346f9809683f6f35ac7e0` |
| apps/android/app/src/main/java/com/elitesync/MainActivity.kt | 100644 | `cec4d142e0cd44a7b17aa9ca02679a98f31cee9d` |
| apps/android/settings.gradle.kts | 100644 | `0239c07856447b4a30ab395f8aaec97096c80d3d` |
| apps/flutter_elitesync_module/lib/dev/v1015_ice_diag.dart | 100644 | `49e607ba3697f9b72865e677d037aef76a547e51` |
| apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_ice_diagnostic.dart | 100644 | `6bad6b77b6ee112ce7adeb18f339ddd38be4782e` |
| apps/flutter_elitesync_module/lib/features/rtc/domain/services/rtc_livekit_service.dart | 100644 | `66053d78a15a6a28311083bd99c83e6bb1331777` |
| apps/flutter_elitesync_module/test/features/rtc/domain/services/rtc_ice_diagnostic_mode_test.dart | 100644 | `f470897deeeda48468a7d4ee9167ca9da28ba7ce` |
| apps/flutter_elitesync_module/test/features/rtc/domain/services/rtc_ice_diagnostic_test.dart | 100644 | `8a309f7b73692180000bb212d64a67b4c8627c41` |

## 9. 最终门

**V10.1.5_ICE_DIAGNOSTIC_CAPABILITY_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本轮状态为源码诊断候选已验证、诊断APK构建阻断、设备实测NOT_RUN。既有消息、缓存、图片视频、通知成果及原证保留；双实际APP媒体、同call重连、旧JWT首入/重入与撤权COMMIT后≤5秒流动媒体停止均不能据本轮关闭。等待Astra独立复审及Owner后续派发。
