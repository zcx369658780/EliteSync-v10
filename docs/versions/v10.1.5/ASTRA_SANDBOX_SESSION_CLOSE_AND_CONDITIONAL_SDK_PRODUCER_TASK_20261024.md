# EliteSync v10.1.5｜Sandbox探针实例收口→条件式SDK运行→Flutter Producer→30配置解析｜单一Codex长任务

2026-10-24（Asia/Singapore）  
**TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_STARTED / NEW_RUNTIME_BUDGET_UNSPENT / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**

## 0. Owner派发边界与任务目的

Owner手动派发本任务方可启动；本文件发布不等于任何本地进程已改变。本轮不再重复前面已通过的Windows Sandbox独立禁网探针、Flutter GPU本地源码核验、Gradle DAG、25/38/11项历史fixture，也不再启动独立“调查一下”微任务。

**首先安全判明上轮唯一无凭据Sandbox探针关联RemoteSession是否已自然退出。** 如果仍存在且仅需归属明确的普通窗口收口，本任务**额外授权一次**精准PID、创建时间和本任务WSB来源核验后的`CloseMainWindow`非强制正常关闭请求；仅等待有界退出回执，不能扩大成强制杀进程、系统重启、虚拟机服务终止或批量关闭。若无确切归属、guest状态未知或本次仍未确认退出，**立即STOP**，只向Owner报告单一需其本人操作/批准的旧实例处置选择，不得重复尝试关闭或启动新SDK实例。

只有旧实例/关联资源安全收口且后续所有阶段门实际通过，才使用前轮已准备且未启动的22条映射/任务自有SDK副本，最多一次启动新Windows Sandbox SDK映射实例，**在新实例自身**复核禁网及父子进程外联失败、实际Flutter/JDK/Gradle/SDK来源可用，再最多一次既定Flutter Debug producer；只有当次同源`libs.jar`真实生成并核结构、Hash、ABI通过，才最多一次正式30配置离线`resolvePinnedDebugInputs`。无论成功/失败均不自动宿主APK、设备RTC或main集成。

本次绝对禁止：force kill/kill-tree、Stop-Process -Force、taskkill /F、重启、安装/启用Sandbox/Hyper-V/WSL/Docker、提权、关闭/修改系统防火墙/代理/hosts/网卡/网络规则、任何下载、SDK升级、`flutter precache/pub get`、Wrapper、改产品跟踪`apps/services`或锁文件、Flutter额外AAR/宿主APK构建、ADB/真机、RTC/SFU/DB/API/云端、主线产品集成、R2或v10.1.6。所有运行须以当前用户已安装既有Windows Sandbox及`Networking Disable`任务自有配置为限。

## 1. 固定来源

- 仓库：`zcx369658780/EliteSync-v10`。开工重新只读核实际GitHub main/Root/apps/services，main仍以v10.1.4接受对象（apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`／services`0cb1f9d19659291a462488b3686fd0a07a6698ac`）为唯一接受产品。不要从main替换连续未接受v10.1.5开发源码。
- 唯一候选基点：`29eced7453d876ca3d229341241b518e80b82635`，Root`925fa111a5b81f25780b59137a9889b9d4097a82`，sole Parent`c1a6cba30f7c18ad8d0f5252436a40ea760437d6`；apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`不可变；固定产品诊断source`1522466faf798b719ccff281de7584f043946437`及跟踪app构建Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读。
- 最新[Astra独立复审](isolation_probe_pass_sdk_runtime_block_independent_review.md) Git Blob `c716c8cb5f42b6ef0da019c6cfc8042fc9c5a181`。本次前置Codex[报告](FLUTTER_OFFLINE_EXECUTION_BOUNDARY_AND_PRODUCER_REPORT.md) Blob `7ffae2f037509b827b734f4d0d6e213358f2048d`、[Manifest](flutter_offline_execution_boundary_and_producer_manifest.json) Blob `6ec1483a4f4fdeb813ee90969547cba0bf3160d9`。已有D0无凭据网络隔离实证1次PASS，但仅该实例；其RemoteSession在正常CloseMainWindow后10秒未确认退出，最后观察仍在，**此后当前状态UNKNOWN，不能当作仍运行或已退出**。
- 已准备SDK任务副本源文件约17907件／1.63GB以及22条隔离映射，但SDK映射实例启动0次，真实缓存/版本运行NOT_VERIFIED。冻结Flutter3.41.7/Dart3.11.5/engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、Gradle8.14 bin SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`、AGP8.11.1/Kotlin2.2.20/JDK17.0.18.8。50键sealed env canonical SHA256`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；弃用`ANDROID_PREFS_ROOT`必须不含任何大小写键，`ANDROID_USER_HOME`归属不变。
- 已接受真实producer DAG：`:flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug`；预期模块`.android/Flutter/build/intermediates/flutter/debug/libs.jar`，不重新跑DAG。严格resolver init SHA256`2e97394f0dffd7818058e587cda8a3e285c865d57c8eba8edb946506bdead2198be6cc72041`? **禁止凭此疑似值作身份门**：最终运行以已有前轮Manifest精确固定SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f` 为准；artifact policy SHA256`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`。前轮`targetPath=lib/main.dart`、`dartDefines=null`，因此`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`持续。
 
## 2. D0｜旧实例单次有界收口（不启动SDK/Flutter/Gradle）

1. **只读**核上次任务唯一探针WSB来源、RemoteSession PID/创建时间、父launcher和当前同源窗口/guest/进程状态；原`owned-boundary-ui-close.json`未确认退出及最后仍在的事实永不覆写。不要把过去的进程ID直接视为当前同一PID；用创建时间/可验证运行归属防PID复用。只读检查是否有旧关联Sandbox guest仍占用且可能与下一实例冲突。没有可判定信息即STOP。
2. 如已自然退出且无guest残留：D0 PASS，不再调用任何关闭函数，保留实际观察时间；如仍有**精确同源、有窗口且正常关闭不会覆盖受保护数据**的进程，允许额外**仅一次**`CloseMainWindow`与有界WaitForExit/只读回读，要求确证退出及关联guest安全收口。不能`CloseMainWindow`反复点击，不允许强制结束、服务重启、系统进程kill或以UI消失冒充guest已关闭。
3. 若仍未退出/无法核关联guest，终态`OWNED_SANDBOX_SESSION_NOT_CONFIRMED_CLOSED`，SDK启动0次、producer0、resolver0。报告Owner明确需要其人工查看/关闭哪一个**已具名独立沙盒窗口或同源会话**（机器绝对路径/进程号保持LOCAL_ONLY），无自动清理或重试。不要为了规避生命周期门而换另一个Sandbox/VM或复制SDK。

## 3. D1｜条件式一次新SDK映射Sandbox实例

只有D0 PASS，才依据已有任务私有受保护映射、只读原件及SDK复制回执实施**一次**新的SDK映射Sandbox启动；不得覆盖前轮复制来源或反复复制SDK。需在**这个新实例自身**核同样`Networking Disable`实际生效（至少一次独立父子进程字面IPv4/IPv6 TCP负例、无外网接口和默认路由），同时核预先批准的guest独立任务写入目录/只读映射、真实Flutter/Dart/JDK/Gradle版本和cache readiness，外联任何未授权来源严格FAIL。新实例若未启动、未认证禁网或SDK缺少具名缓存，STOP，不运行producer，不下载。
 
ICE诊断参数独立：实测`targetPath`与`dartDefines`，若仍为普通Debug，允许明示`STANDARD_DEBUG_LIBRARY_ONLY`的前置编译，但仍`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`，不以此批准ICE诊断APK/RTC。严禁静默更改真实产品脚本或伪装已传递。

## 4. D2→D3｜条件式唯一producer及30配置解析

D1全PASS并完成一次非作者有界前置复核后，才允许**最多一次**真实Flutter Debug生产者 `:flutter:packJniLibsflutterBuildDebug`及其真实compile依赖，受控完全断网沙盒、本地冻结工具和现有输入，不得调用Wrapper、SDK/Pub/Maven下载或额外宿主APK构建。producer失败或未真生成JAR即STOP，不自动修复/重试。必须核同次`libs.jar`的before/after、生成任务、实际字节Hash、ZIP结构CRC及真实JNI内容/目标ABI。不得补空文件或复制别版cache。
 
只有producer输出真实合格且当前Sandbox/SDK与resolver读取路径同源，最多再调用**一次**真实`resolvePinnedDebugInputs`遍历15模块×debugCompile/debugRuntime的`Configuration.resolve()`；首缺GAV/variant/transform或安全问题STOP。逐项记录BEGIN/OK/NOT_RUN，30项实际OK才`OFFLINE_30_CONFIG_RESOLUTION_PASS`。无论如何不自动Flutter新AAR、宿主APK、设备/RTC/SFU/DB/API或main集成。

## 5. D4｜保护、单次复核和统一交付

- 原关键990具名文件、20226复制及只读来源、507旧refs、五历史root/原dirty/SQL/APK/备份/私密env/旧.zip.part、所有历史fail/截图/回执保留；仅核本任务真实触及的原件和合法新派生写入，勿重复全盘扫描。一次非作者有界复核既覆盖D0关键进程归属和D1安全边界，亦覆盖后继如发生的运行结果，不新增漫长多模型循环。
- 连续候选从`29eced7453d876ca3d229341241b518e80b82635`作为sole Parent新建安全后继；Git**只新增**两份docs：
  - `docs/versions/v10.1.5/SANDBOX_SESSION_CLOSE_AND_SDK_RUNTIME_RESULT.md`
  - `docs/versions/v10.1.5/sandbox_session_close_and_sdk_runtime_manifest.json`
  严禁合main产品、改apps/services/旧报告/AGENTS/ACTIVE_STATE。
- 公开只给裁决性证据与Hash/脱敏进程状态，真实PID/私有路径、环境、SDK/JAR/APK和stdout/stderr/guest映射仍LOCAL_ONLY。普通非force发布、完整Git soleParent/Root/新docs Blob/两产品Tree和原文字节回读后STOP。
- 合法结果按事实选`OWNED_SANDBOX_SESSION_NOT_CONFIRMED_CLOSED / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`、`ISOLATED_SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`、`SDK_RUNTIME_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN`、`REAL_DEBUG_LIBS_JAR_VERIFIED / RESOLUTION_FIRST_BLOCKER`或`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIG_RESOLUTION_PASS`。统一追加`NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`与尚未证明的ICE flags。

本任务不假定RemoteSession当前仍存或已退出；D0以当次只读事实为准。失败即终止，避免再次进入长期临时环境治理循环。
