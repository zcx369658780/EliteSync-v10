# EliteSync v10.1.5｜Owner批准旧Sandbox归属进程有界收口→新隔离SDK→Debug Producer→30配置解析｜Codex唯一长任务

日期：2026-10-24（Asia/Singapore）。
状态：**OWNER_AUTHORIZED_BOUNDED_CONTINUATION / ASTRA_TASK_ISSUED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 0. 新Owner授权及关键原则

2026-10-24，Owner收到此前`hcsdiag list`返回`0x8037011B`且无guest清单的报告后明确：“**可以请继续，下个任务单你可以要求codex先关闭还存在的guest进程。**”这一决定取代前轮`OWNER_MANUAL_CONFIRMATION_REQUIRED / NO_SUCCESSOR`的**派发限制**，但**不是**Owner证实先前guest已结束，不抹去`GUEST_STATUS_UNKNOWN`证据。

Owner手动将本任务交给本地Codex后，才授权：**单次定点识别及有界收口已知EliteSync无凭据Windows Sandbox探针留下的确切自有实例或guest进程**；在不误伤任何其他用户任务的条件下，可继续**一次**新的独立禁网SDK映射Sandbox实例；新实例实际READY且工具/缓存/离线/安全前置全过后，最多一次Flutter Debug producer；本次真`libs.jar`验收通过后，最多一次正式30配置离线解析。**所有预算条件递进，发现新阻断立即STOP，不多轮重复规划与试错。**

旧会话`hcsdiag list`缺有效清单、独立原始空进程快照缺失是历史`UNKNOWN`，不可凭零进程摘要宣告guest已关闭。**Owner允许绕过的是“必须拿到旧guest关闭证明才允许考虑新隔离实例”的硬阻断，而不是允许盲杀或带着已知资源冲突强行启动。** 新实例必须使用任务独立WSB、唯一目标映射/可写根、证明没有已知活跃重叠实例/资源冲突，并在**该新实例自身**重新证实禁外网。

### 可关闭的对象与禁止事项

只在**当前真实可见且多因素精确匹配**先前专用无凭据Sandbox探针的guest实例/关联RemoteSession时行使关闭权限：核PID+创建时间+进程路径/签名+任务专用WSB文件与启动归属+guest/compute ID（如可安全取得）及实际资源归属。严禁用历史PID反查后直接终止当前PID、凭通用`vmwp.exe`/`vmmem`名称批量终止或凭`hcsdiag`错误码猜进程身份。

**优先一次正常关闭**该唯一确切归属实例/进程，并有界等待及只读回验。如果正常退出没有确认，只有在能证明目标为**唯一、本次任务独占、无其他用户工作/生产数据且该进程确属可单独结束的沙盒guest进程**时，才允许**最多一次定点终止这个单独进程**，留执行前后完整身份/影响证据。若只能识别共享Hyper-V/HCS/vmcompute服务、系统托管或其他用户任务的宿主进程，**即使Owner授权关闭guest，也不允许强制终止它们**。任何guest归属不可确定、数据/持有句柄可能误伤、需提权/重启服务或多guest操作时`UNSAFE_OR_UNKNOWN_OLD_GUEST_STOP`并STOP；不偷偷更换平台、重启Windows或绕过保护。正常关闭失败不能自动升级为全局kill。

**绝对不授权**：安装/启用Sandbox/Hyper-V/WSL/Docker功能、UAC提权、停止/重启HCS/Hyper-V/vmcompute服务、全局杀Docker/Java/ADB/VM、修改宿主防火墙/代理/网卡/路由/hosts/注册表、网络下载或SDK/Pub/Maven新获取、`flutter precache/pub get`、Wrapper、升级工具/SDK/依赖、修改跟踪`apps/services`或正式build.gradle.kts/锁文件、宿主APK build/install、设备/RTC/SFU/DB/API、真实外部供应商、历史资产清理/force Git、R2或v10.1.6及main产品集成。

## 1. 固定authority及身份

- 仓库`zcx369658780/EliteSync-v10`，本次任务签发前live main`8fd52f6a2b9fc8c8c145fbd3abf896f8d1b29ddf`，Root`b8fabbbca6cf4c8ee8201fc123e41cbf81b2f687`；**启动时重新只读核实际main**。main唯一接受产品仍为v10.1.4，apps Tree`3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree`0cb1f9d19659291a462488b3686fd0a07a6698ac`，不是v10.1.5代码authority。
- 最新未接受候选唯一连续起点`7292a8c39cec2e0bbb611436686828263129614b`，Root`270adcd0c7934b974be7f820f1fd063a52e63285`，sole Parent`29eced7453d876ca3d229341241b518e80b82635`；固定候选apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`不变。固定诊断源码`1522466faf798b719ccff281de7584f043946437`、app构建Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`不改。
- 前轮Astra独立复审`docs/versions/v10.1.5/sandbox_session_guest_state_unknown_independent_review_20261024.md` Git Blob `c9bcb7f019acfcba9a5f7c468323da2100d47dcd`；本轮固定前证`SANDBOX_SESSION_CLOSE_AND_SDK_RUNTIME_RESULT.md` Blob`8a0c00e8bab4e2eed85df5a824e8e2ea185b9ba2`、`sandbox_session_close_and_sdk_runtime_manifest.json` Blob`0698c26e0bad31900eab7e224a59c28c50e7153b`；前轮任务Blob`e30a0e1e35d5f39c6e0f77bfa9fa8e2f8d7574df`。原`hcsdiag list`唯一`0x8037011B`、stdout0、raw空进程快照未生成；不得将本轮新观察倒填原始回执。
- 已审独立无凭据Sandbox`Networking Disable`探针只对旧实例PASS，新实例必须重证。上一轮已准备约17907件／1.63GB独立SDK来源和22条映射、旧SDK输入与flutter_gpu本地真源已核；无需重新整套复制或GPU搜源。工具固定Flutter3.41.7、Dart3.11.5、engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、Gradle8.14 bin SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`、AGP8.11.1/Kotlin2.2.20/JDK17.0.18.8。50键sealed env Hash `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；禁用任意大小写`ANDROID_PREFS_ROOT`、保持`ANDROID_USER_HOME`批准归属。
- 实际Flutter Debug生产DAG上轮PASS：`:flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug`，预期模块debug`libs.jar`。此前`targetPath=lib/main.dart`、`dartDefines=null`；继续`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`，不将标准debug JNI产物冒作ICE诊断版。严格解析init SHA256`2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、artifact政策SHA256`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`。
- 下一任务**不重复**GPU Hash全量复审、前轮HOST/25/38/11 fixture、旧`--dry-run`DAG或已接受单实例探针。保护旧508 refs、五历史根/dirty/SQL/APK/密钥/恢复备份/私密日志/旧未授权part，具体数量以开工真实清单核，不把固定历史文件数当必须重扫全盘。

## 2. D0｜Owner新授权的精确旧guest进程处置（新SDK实例0次）

1. **先生成并保留一份本轮独立原始进程快照**（即使空也保存可核原始格式、查询时间、查询命令、范围），覆盖当前用户可见Sandbox/RemoteSession及相关虚拟机进程；按当前PID+创建时间+签名/路径/任务WSB来源与LOCAL_ONLY旧身份关联。前轮缺原始空清单的问题不要重复。允许仅**一次**有界既有guest清单查询作为辅助；若再现`0x8037011B`或无可用清单，将它标为**UNKNOWN**，不能写“guest0”；不要进入HCS修复/提权。
2. 若精确找到**独占旧探针guest/RemoteSession**，按第0节关闭预算先正常关闭；如确切证明可安全精准单进程终止且正常关闭失败，可用**一次**有界单进程终止；记录匹配字段、操作、结果和资源归属、无关用户任务保护。绝不全局杀系统托管服务、泛名`vmwp/vmmem`或任何归属不明guest。目标不存在时**不发空操作**，保持`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`而不是伪造关闭回执。
3. 对是否允许新实例给出一个**独立安全准入**：即使HCS旧guest列表不可用，只要当前原始进程快照**无可归属旧活跃guest/进程**、旧任务写入根与新实例完全隔离、WSB/映射身份唯一、无已知锁/占用/guest重叠或资源冲突，Owner本次授权**允许一次全新独立SDK Sandbox启动尝试**，并保留“旧guest无法从HCS最终确认”警示；这个准入是`NEW_INSTANCE_ISOLATION_PRECONDITION_PASS`，**不是`OLD_GUEST_CLOSED_PASS`**。有活跃但无法安全关闭的旧进程、共享服务冲突、锁占用或任何无损隔离无法证成，立即STOP，不强启。
4. 不要反复查询HCS、关闭同一窗口或重复启动实例来换取PASS。新实例启动前核原宿主网络状态/原SDK/映射read-only与任务自有root，保证不用对已有系统/旧主工作树写入。

## 3. D1｜只允许一次新的SDK映射Sandbox实例

D0新实例准入PASS后，可用原已审但**此前未真正启动**的22条隔离映射与SDK准备资产，在唯一新任务root启动**最多一次**Windows Sandbox SDK实例。需要同时满足：
- 该实例配置`Networking Disable`，在**实例内部**证实无可用外联网络适配器/默认路由，父/子进程对固定无凭据字面IPv4/IPv6端点作一次最小负例并失败，不能用旧探针PASS替代此实例实测，也不发送产品或凭据数据。
- Guest内按本机固定来源核Flutter3.41.7/Dart3.11.5/engine、JDK、Gradle8.14/AGP/Kotlin、SDK cache readiness、隔离Flutter CLI工具/Gradle/SDK输入闭包和各写入根归属；只允许任务根派生写入、共享源read-only。安装/下载/改全局环境、系统网络或旧Stage均不允许。
- 探针失败、实例UI异常、SDK缺项/工具源漂移或任何越权副作用就STOP，不更换VM、不重启/强杀系统服务、不重复启动。普通Debug`targetPath=lib/main.dart`/`dartDefines=null`不等于ICE诊断FLAG通过；如仅可证明标准Debug类库输入，标`STANDARD_DEBUG_LIBRARY_ONLY`。

## 4. D2｜条件式真实Debug producer最多一次

只有D1全部PASS且一次非作者有界前置核验支持后，才可在该全程禁外联的Sandbox内最多一次运行前轮已验`:flutter:packJniLibsflutterBuildDebug`及其compile依赖。不得额外宿主APK/AAR、联网下载、Wrapper、变更依赖/SDK。确认前置无实物JAR，再核生成任务链、产物路径`.android/Flutter/build/intermediates/flutter/debug/libs.jar`、before/after、Hash、JAR ZIP结构/CRC、真实JNI payload/两ABI来源，不能用旧Jar/空Jar占位。producer失败/产物来源不明即STOP，不重复修调。

## 5. D3｜产物全PASS才允真实30配置解析最多一次

仅当同任务实物`libs.jar`与解析器source/SDK路径同源且实测有效，才允许在同一Sandbox内一次`resolvePinnedDebugInputs`，真正遍历15模块×debugCompile/debugRuntime的`Configuration.resolve()`，保留可信Gradle8.14`--offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`、原三flags/四iceDiag属性、严格init与artifact policy。逐项标BEGIN/OK/首FAIL及余项NOT_RUN，缺GAV/variant/文件/网络权限即停不重试；30/30实测OK才可称`OFFLINE_30_CONFIG_RESOLUTION_PASS`。不把其提升为host APK、ICE真机/RTC或AC05接受。

## 6. D4｜集中交付与合法终态

- 一份有界非作者审查覆盖D0归属、正常/有界终止影响、新实例网络安全、D1工具缓存、D2产物和D3计数（未发生的部分只标NOT_RUN），不强制重复旧受理综检。旧SQL/APK/备份/私密env/历史失败与先前Owner停门记录保留；Cache/daemon正常派生和少量受控写入如实归类，关键具名对象按before-after Hash核，不能声称全盘无漂移。
- 在连续候选`7292a8c39cec2e0bbb611436686828263129614b`之后新建无污染任务分支，**只新增两份docs**：
  1. `docs/versions/v10.1.5/OWNER_SANDBOX_SCOPED_SESSION_CLEANUP_AND_SDK_PRODUCER_REPORT.md`
  2. `docs/versions/v10.1.5/owner_sandbox_scoped_session_cleanup_and_sdk_producer_manifest.json`
- 产品`apps/services`完整Tree原样，旧docs/ACTIVE_STATE/AGENTS/main不变；Git仅普通non-force，远端回读唯一Parent/Root/两Blob、完整apps/services映射与原文字节。原始PID、WSB路径、完整SDK/env/Gradle/Sandbox logs、JAR/APK、密钥与私密数据仅LOCAL_ONLY，不上传GitHub/Project。
- 合法终态从实测选择：`UNSAFE_OR_UNKNOWN_OLD_GUEST_STOP / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`NEW_SANDBOX_INSTANCE_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`ISOLATED_SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`ISOLATED_SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLVE_FIRST_BLOCKER`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS`。遇旧guest无法从HCS证实关闭，必须继续报告`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`，即便新隔离SDK独立通过，也不可倒填`OLD_GUEST_CLOSED_PASS`。
- 所有终态统一继承`NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`（除非另有独立实证）／`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。交付即STOP，不能自行在后继文档下连续开新任务。
