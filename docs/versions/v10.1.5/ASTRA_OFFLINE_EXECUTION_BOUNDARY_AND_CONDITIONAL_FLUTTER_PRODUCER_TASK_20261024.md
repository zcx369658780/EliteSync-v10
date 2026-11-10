# EliteSync v10.1.5｜真实离线执行边界→可运行SDK任务副本→条件式Debug Producer与30配置解析｜Codex唯一长任务

日期：2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / PROCESS_TREE_NETWORK_DENIAL_NOT_YET_PROVEN / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. 任务权限与目标

本任务只有在Owner**手动派发给本地Codex**时才进入执行；发布文档并非实际运行。为避免连续微任务和反复搜旧来源，综合目标是：**只在Owner设备上已存在、无需新系统授权的条件下**，验证一个真实可复现、对Flutter CLI及其子进程树有效的**无外网执行边界**；边界已被拒绝测试证明且确认不覆盖历史时，才用已确认的同版本本地Flutter GPU源组件完成**新任务独立可运行SDK副本**，继而按已有实测DAG有条件执行真实Debug producer最多一次；产物`libs.jar`结构/同源身份/实际ABI和来源核验全PASS后，才最多一次运行30配置真正`resolvePinnedDebugInputs`。每一级STOP停止整个本任务，不拆分新任务或偷续上轮剩余预算。

**绝对禁止**：自动安装或启用Windows Sandbox/Hyper-V/Docker/WSL新功能，新建需要提权的网络或安全设置；改系统/用户防火墙、代理、hosts、路由、网卡状态、注册表、策略、系统服务或共享SDK；使用真实公网取得任何新Flutter/Pub/Maven/SDK包，`flutter precache`、`pub get`、Wrapper、工具升级、未知二进制；修改Git跟踪`apps/services`、正式`build.gradle.kts`或锁文件；宿主`:app:assembleDebug`、APK安装、手机/ADB、RTC/SFU/DB/API、网络端口/外部供应商；删除或重置原dirty/历史树；main产品集成、R2、v10.1.6。**不存在合法既有外联隔离手段就如实报告，交给Owner做一次明确权限决策，不为此发无止境的纯取证任务。**

## 1. Authority与固定候选

- GitHub仓库`zcx369658780/EliteSync-v10`；开工fresh只读核main Commit/Root/apps/services。main仍只有已接受v10.1.4产品 apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`、services`0cb1f9d19659291a462488b3686fd0a07a6698ac`，**不要用main产品树覆盖尚未接受的v10.1.5候选**。
- 唯一连续候选起点`c1a6cba30f7c18ad8d0f5252436a40ea760437d6`，sole Parent`df2bf34302fd65d0f69c0ea34a269eba03dc6a67`、Root`e30e58438b8e6b78fa33a62fa5d9cf9b96eef19c`。候选apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，两个完整Tree不可变。产品诊断源码Commit`1522466faf798b719ccff281de7584f043946437`与`apps/android/app/build.gradle.kts` Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`不修改。
- 最新正式Astra独立复审`docs/versions/v10.1.5/flutter_gpu_local_component_and_cli_closure_independent_review.md`，**启动时先读取并按GitHub实际Blob核验**；本次候选报告`FLUTTER_OFFLINE_GPU_CACHE_CLOSURE_AND_CONDITIONAL_PRODUCER_REPORT.md` Blob`0b9dff16f6258cecf3d9532dd7a0e9b3062215bd`、Manifest`flutter_offline_gpu_cache_closure_and_conditional_producer_manifest.json` Blob`bc49c555992c5633860fcfa286fe0862989fab47`；旧Astra复审Blob`5210b59f3ef9edb5299c95ccb7fa0a755f167da3`、前轮正式任务Blob`9e6e4a16c5d3d8d05f9701c601901f897e58f424`。优先读上述正文和`ACTIVE_STATE.md`当前首段，旧历史FAIL保留，不重新规划方向。
- 前轮有界确认：原SDK同版本engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`的`flutter_gpu` cache 34文件162666B，逐固定Git Blob核对由Codex回执支持；新独立**仅组件Stage**共39文件163391B（34包+5真实meta）；现有Gradle producer实际仍指向缺包的**旧可运行SDK Stage**，组件Stage本身**不可执行Flutter CLI**。任何D2前必须重验并衔接真实可运行SDK的来源、路径和完整性，不可把组件目录直接指定为FLUTTER_ROOT。
- 已审Flutter Debug真实DAG上一轮`--dry-run` 1/1 exit0：`:flutter:compileFlutterBuildDebug→:flutter:packJniLibsflutterBuildDebug`；output`project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar`；DAG本次**不重跑**，无证据时只在已有受控task graph正文定点读取。前次`targetPath=lib/main.dart`、`dartDefines=null`，**不是ICE诊断flags已通过**。
- 工具冻结：Flutter3.41.7/Dart3.11.5/engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、Gradle8.14 bin SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`、JDK17.0.18.8/AGP8.11.1/Kotlin2.2.20。50键sealed环境canonical SHA256`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；`ANDROID_PREFS_ROOT`任何大小写键不得出现，`ANDROID_USER_HOME`保留原批准归属。正式解析既有严格init SHA256`2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、policy`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`，不可放宽依赖选择或跳过文件验证。

## 2. D0｜现成隔离能力的短决策门：不得安装/提权/改系统

1. 仅对**Owner电脑已经安装且可用、前轮有据记录的隔离技术**进行定点可用性核验，例如已经可直接使用的禁网络虚拟机/Windows隔离沙盒/容器或可证明所有后代进程不可外联的同等级边界；示例不是对其存在的断言。**不安装任何缺失组件、不要求提权、不调用全局安全开关**。必须给出隔离与实际Gradle/Flutter/JDK/Dart原件的兼容性、运行目录/写入归属、完整子进程树网络封闭的真实证据。只有环境变量设置虚假代理、file URI、Gradle`--offline`或静态阅读Flutter源码，不足以单独证明子进程树外联被可靠拒绝。
2. 如已存在隔离能力，先用**不涉及Flutter/产品/任何真实凭据的独立安全负例**证明被隔离测试进程**及其创建的一个子进程**均被禁止向外网发起实际连接；仅测试预先安全、已获准、不包含对外私密流量的最小网络端点，并保留规则生效范围、隔离内外状态、无系统修改记录。不能因为DNS失败、HTTP代理失败或一个请求错误就夸成所有出口协议的形式化覆盖；必要时采用已证断网虚拟网络接口、无网络命名空间等隔离级保证。未能验证即`NETWORK_ISOLATION_NOT_PROVEN`立即STOP。
3. **如果本机没有这种可用且无需提权/系统变更的既有隔离能力**，直接给Owner明确选择：A）单独批准具名系统层隔离或离线VM配置变更后再运行；B）另行明确审定具名Flutter缓存/下载来源与网络范围。Codex本任务不得自行执行A/B，也不得暗改原严禁联网边界；不要因此重复整仓/SDK/任务图审计。

## 3. D1｜SDK真实可运行任务副本和诊断来源门（Producer 0次）

1. 仅在D0 PASS且隔离能实际访问本任务已获准的Gradle/Flutter/JDK缓存时，在本任务LOCAL_ONLY独立可写SDK Stage内**定点并按原source Hash**装入已验证的同版34个flutter_gpu真实文件和必要同源metadata；如果原Stage缺可运行所必需的其它已批准组件，仅使用已有合法本机来源，有Hash/目录/版本证据时定点复制必要文件，不能盲重复制7.3GB或在原Stage原地补包。对复制动作先做旧Stage/原SDK保护，再核新Stage完整工具与source/engine identity，绝不人为生成stamp或删除cache-check。
2. 用Flutter3.41.7官方原源码和实际隔离手段验证bootstrap/universal/platform/Pub分支可能的缓存/下载输入；即使某分支尝试访问网络，也必须只能在**被证明禁外联**的执行环境中失败并保留证据，不能产生全球缓存/共享SDK污染。仅在已有本地输入闭合、无可预见必然失败且非作者一次有界前置复核支持时放行下一步。任何欠缺真实packages、可信Git身份或隔离边界失效即STOP。
3. **ICE参数归属**：前轮真实FlutterTask`targetPath=lib/main.dart`、`dartDefines=null`。核此处普通Flutter Debug classpath产物是不是后续正式30配置解析所必需、允许的先行物；允许清楚标注`STANDARD_DEBUG_LIBRARY_ONLY`继续做构建环境验证，但**不得声称ICE_DIAGNOSTIC_FLAGS_PASS**，不得用误配置产物开启后续诊断APK或RTC。不能通过任务私有绕过安全限制伪造正确诊断Dart入口；如真正producer合同要求ICE flags一致才能放行，则STOP并提出单一具体差异给Owner。

## 4. D2｜只有D0/D1通过才允一次实际producer

1. 使用已有已证的真正`:flutter:packJniLibsflutterBuildDebug`及其`:flutter:compileFlutterBuildDebug`依赖链，最多**一次**，直接可信Gradle8.14 bin；原`--offline --no-daemon --console=plain --max-workers=2`、双ABI、合法三诊断flags及四路径属性仍按本任务来源精确复用。执行必须处于已证明禁外联的隔离边界内，所有归属写入局限新任务可写目录，旧SQL/APK/SDK、原带dirty工作树、各类历史失败和未经许可的`.zip.part`不变。若isolated runner无法承载Windows/Flutter工具、需要系统网络规则修改或任务超出Debug生产者闭包，立即STOP，不重试、不更换目标/版本/依赖。
2. producer exit0后必须证明**同一producer真正生成**正确路径的`libs.jar`：运行前不存在/有基线，之后实物bytes/SHA256、可读取ZIP/JAR的CRC/entry、真实内容与期望ABIs `x86_64`和`arm64-v8a`的源关系/任务文件映射；它可能是JNI打包Jar而不是class Jar，不能因缺Java.class武断失败，也不能批准无来源的空Jar占位。输出若未生成、格式异常或来源无法核，STOP，不允许从原SDK旧产物复制凑数。
3. 原Flutter SDK本体及共享cache不变，任务自有合法cache/daemon派生写入分类Hash；不据producer一次成功推断30配置或host APK已经成功。

## 5. D3｜生产者实物验证PASS后才允一次正式30配置解析

最多一次真正`resolvePinnedDebugInputs`（15模块各debugCompileClasspath/debugRuntimeClasspath），沿用严格`android-classes-jar`规则，真实`Configuration.resolve()`，在**同一隔离环境、相同SDK与生成输出路径**消费本轮`libs.jar`。命令仍为固定Gradle8.14 `--offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`及既有`-I`、三flags四路径属性。首个新缺失坐标/variant/transform/文件/环境问题即STOP、其余NOT_RUN，不下载/不改产品源/不重试；30/30实际OK才称PASS。

无论D2/D3结果如何，**宿主APK build、Flutter额外AAR/安装、手机ADB、RTC/SFU/DB/API、网络服务、main集成与后续v10.1.6均禁止**。保留冻结AC-10.1.5-05四项真实RTC硬门OPEN。

## 6. D4｜单一报告＋Manifest＋远端回读

- 不再额外安排多轮非作者/全盘历史考古。一位非作者只做一次有界前置离线安全审查并在同一任务复核后续实际产物/阻断证据；不能把源代码静态意图当真实网络隔离PASS。历史864关键原件、506 refs/5根、各任务原证及先前首次失败保留。只对任务触及具名对象核before/after，不虚报全盘零变动。
- 唯一连续候选从`c1a6cba30f7c18ad8d0f5252436a40ea760437d6`作为sole Parent建立干净后继，**Git只新增两份docs**：
  - `docs/versions/v10.1.5/FLUTTER_OFFLINE_EXECUTION_BOUNDARY_AND_PRODUCER_REPORT.md`
  - `docs/versions/v10.1.5/flutter_offline_execution_boundary_and_producer_manifest.json`
- 不在main产品集成、不改`ACTIVE_STATE.md`、旧审查和源码。普通非force提交、远端核Commit/sole Parent/Root/2 docs Blob/完整apps与services Tree和docs原字节后STOP。原二进制/SDK/完整日志/真实路径/环境及私有数据仅LOCAL_ONLY，不上传Github。
- 真实终态择一：`NETWORK_ISOLATION_NOT_AVAILABLE_OR_NOT_PROVEN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`ISOLATED_SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`ISOLATED_PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN / NO_APK`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLVE_FIRST_BLOCKER / NO_HOST_APK`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS / NO_HOST_APK`。并明确附`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`（若未解决）。
- 所有情况继承`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。无可用隔离时由Owner下一轮决定是否扩大具体环境权限，**不是自动发布另一个相同“离线安全诊断”任务**。
