# EliteSync v10.1.5｜Flutter离线universal缓存闭包与条件式Debug生产者＋30配置解析｜Codex综合长任务

日期：2026-10-23（Asia/Singapore）。

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / OFFLINE_GPU_CACHE_SOURCE_UNKNOWN / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Owner手动派发才生效的授权

Astra已对上一候选实际Flutter Debug DAG PASS及离线缓存闭包阻断独立复审。本任务是下一份**唯一综合长任务**，Owner手动把启动Prompt交本地Codex后才可执行；仅创建GitHub文档不是本地任务运行或新费用／下载许可。

**任务目标**：在保留既有已证`compileFlutterBuildDebug→packJniLibsflutterBuildDebug`真实DAG、Flutter3.41.7及Gradle8.14版本、50键sealed env和原资产的前提下，定点解决 producer 进入Flutter CLI时可能触发自动缓存获取的**离线前置安全闭包**。首先审核隔离`sdk-stage/flutter/bin/cache/pkg/flutter_gpu`缺失及实际cache更新分支，再查找是否已有**可信且授权使用的本机同版、同engine、非污染Flutter SDK本地原件**可仅在任务自有SDK Stage内补齐；同时证明CLI运行中所有潜在网络/SDK/Pub/Gradle获取路径被fail-closed。如果没有可信本地原件、包内容/归属不明或CLI更新分支仍无法关闭，**只报告阻断并STOP**，不得继续producer/resolve。

**新权限严格仅限**：在确有证据且隔离安全时，可以从Owner电脑已经存在的、可核字节和版本的同源Flutter3.41.7离线本地原件，**复制真正需要的`pkg/flutter_gpu`文件及必要同源元数据到本任务独立LOCAL_ONLY sdk-stage**，逐文件核Hash/目录、记录before-after。**不允许**修改全局Flutter SDK、系统/用户环境、原保护SDK、原有Pub/Maven缓存；没有任何新网络获取、SDK下载、`flutter precache`、`flutter pub get`、插件/依赖升级或人工占位目录权限。若需要线上获取包/全新的源码库/改Flutter内核代码或工具配置来跳过检查，本任务不执行，集中向Owner报告最小精确来源和新权限需要。

只有D0-D1闭包全部PASS，才允许**最多一次**已由前轮DAG实证的真实Flutter模块Debug producer及必要依赖任务；只有真实生成并验证同源非占位`libs.jar`后，才允许**最多一次**既有严格`resolvePinnedDebugInputs`正式30配置解析。两个实际预算各自0/1、条件递进，任一新阻断立即STOP、不重试。即使30/30 PASS也绝不自动构建宿主APK、RTC或main集成。

## 1. Authority与历史已证对象

- 唯一仓库`zcx369658780/EliteSync-v10`。任务开工前fresh核GitHub main/Root/apps/services。main仅承载**v10.1.4接受产品**（apps Tree`3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree`0cb1f9d19659291a462488b3686fd0a07a6698ac`），不能覆盖未接受v10.1.5连续候选。
- 研发候选**唯一连续起点`df2bf34302fd65d0f69c0ea34a269eba03dc6a67`**，Root`1781dbbacf0f2314786cadbe853660353787f4c5`，sole Parent`8861c30464893f11968465fee365e5e5471fa773`；候选apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`不允许改变。固定产品诊断源`1522466faf798b719ccff281de7584f043946437`、跟踪app build Gradle Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读。
- 本轮[正式Astra独立复审](flutter_producer_dag_pass_offline_cache_block_independent_review.md) Blob **`5210b59f3ef9edb5299c95ccb7fa0a755f167da3`**；前轮[报告](FLUTTER_PRODUCER_DAG_OBSERVER_CORRECTION_RESULT.md) Blob **`fd3d6c6646f9f174ff5d0df52cc7e538817475fb`**、[Manifest](flutter_producer_dag_observer_correction_manifest.json) Blob **`51bec69ca8f6958cb0679795561c4444b9bb9ef7`**；前轮任务Blob`7e29ca75ed3d12d72108be45e00ca5ff7597bc82`。读取固定原文，历史未观测内容不得臆填。
- 已证真实DAG：Codex LOCAL_ONLY`--dry-run` 1/1 exit0，17.56275s；`:flutter:compileFlutterBuildDebug`依赖链进入`:flutter:packJniLibsflutterBuildDebug`，产物目标任务相对`project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar`，producer action未运行。**本轮不重跑相同DAG**。DAG时`targetPath=lib/main.dart`、`dartDefines=null`；这不等于ICE诊断入口/flags已到达FlutterTask。本轮不静默将一般debug producer成功升级声明为ICE_DIAG。
- 上轮离线安全门：隔离`sdk-stage/flutter/bin/cache/pkg/flutter_gpu`缺失，FlutterSdk universal包检查需要它；CLI`assemble`内部cache校验未由Gradle`--offline`充分约束。**实际下载／网络请求／producer报错均没有发生**，不能称已证网络失败。Windows iOS缓存项和objective_c Android no-op是独立条件，不强行视为Android实际缺项。
- 工具固定Gradle8.14／Flutter3.41.7／Dart3.11.5／engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`／JDK17.0.18.8／AGP8.11.1／Kotlin2.2.20；Gradle bin可信SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。50键sealed env canonical SHA256`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`，任何大小写`ANDROID_PREFS_ROOT`必须不存在，`ANDROID_USER_HOME`为原批准目录。前轮严格artifact policy init`2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、policy`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不重新设计或放宽。

## 2. D0｜最短安全来源检查（Gradle/Flutter producer 0次）

1. 只读核候选Commit、Git Blob、旧完整stderr/源码Hash、该隔离Flutter SDK package目录及已登记的本机Flutter来源/现存SDK Stage，查明是否存在**Owner已批准、版本/engine相符、文件内容结构完整、非模拟或残缺**的`pkg/flutter_gpu`原件。只在已经具名、允许访问的本地Flutter3.41.7 SDK副本及任务批准的包缓存范围内定点查找，不全盘搜索/新Git clone/联网找源码，也不靠文件名相似推断同源；保留包根证据/Hash LOCAL_ONLY。
2. 静态核Flutter3.41.7`FlutterSdk` universal cache readiness、`EngineCachedArtifact`、`FlutterCommand`、`AssembleCommand`、`BaseFlutterTaskHelper`以及Flutter launcher/cache初始化顺序，列出在任务既有Android/Windows/两个ABI/目标SDK下**实际可能**触发网络/更新、Pub或依赖下载的具体路径。列出并排除无关iOS平台分支；不得单凭设置`FLUTTER_STORAGE_BASE_URL` file URI或外层Gradle offline就下`NO_NETWORK`结论。没有实际网络抓包就只描述**静态阻断配置和程序控制流**的证据等级。
3. 保护旧工作树/dirty/refs、SQL/APK/数据库恢复点、原SDK/Pub/Maven缓存、旧日志、未授权part与五历史根。上一轮具名影响范围87357、旧505 refs/5根及153长路径warning只是历史回执；本任务只核现有可信读写范围、重要不变量和新源包受影响对象，避免为一个包再次复制7.3GB SDK或重复完整历史审计。不得`git reset/rebase/stash/clean/prune/force`、删除缓存/lock或者覆盖历史原证。

## 3. D1｜有界离线包闭包与诊断属性门（运行前）

1. **若无精确可信本地package源**：`OFFLINE_FLUTTER_GPU_SOURCE_MISSING / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`，本轮到此停止。Owner才可决定是否批准**另一次**定点官方获取，当前不下载、不生成空目录/占位文件、不修改Flutter源码的cache检查逻辑、不做伪离线升级。
2. **若可信源存在**：只允许复制相关同源Package目录及其真实必要内容到新任务**独立可写sdk-stage**，不改上一轮Stage或共享SDK；逐条记录来源、版本/engine、文件数/尺寸/SHA256/路径、不包含符号链接越界、copy before/after；必须用原Flutter3.41.7源码的真实cache readiness条件验证复制后的闭包，不能通过手动制造stamp或删cache检查来伪造READY。其它universal/Android必需项继续定点检查，发现下一具名缺项STOP，不自动批量下载。
3. 必须对即将由`:flutter:compileFlutterBuildDebug`启动的Flutter CLI及所用SDK/Gradle/Pub/storage离线配置做**fail-closed保证**，禁外部网络即使工具分支尝试也不获得意外访问/下载权限。仅在任务归属子进程/SDK-stage可受控的手段中实现，不能改全局代理、OS防火墙、hosts、系统环境或Flutter源码；如果无法在任务权限内可靠阻断且代码仍存在未备齐更新分支，`OFFLINE_FLUTTER_CLI_CLOSURE_NOT_PROVEN`并STOP。
4. **诊断有效性核对**：再次明确producer graph中的`lib/main.dart`与`dartDefines=null`是标准Flutter Debug还是ICE指定的test-only诊断构建要求。不得单凭外层Gradle`-PflutterDartDefines`便声称嵌套FlutterTask消费了defines。若下一步真实生成产物目标需要ICE诊断入口，而当前local-only脚本无法证实正确传递，必须在报告中给出缺口；不允许因生成标准debug的`libs.jar`就宣称正式ICE诊断产物通过，也不能无授权修改跟踪build脚本或注入不明业务开关。对正式libs.jar依赖解析可否在此条件下使用须给出有界依据。
5. 一次非作者有界静态审查须确认pkg来源真实、缓存闭包/子进程离线guard、现有Flutter/Gradle/SDK版本不变、未触及全局/历史原件、任务写入归属及诊断合同；**前置不通过则producer/resolve两预算均0次**。禁止以“修好flutter_gpu就一定能完整离线”作为替代证据。

## 4. D2｜条件式真实producer（最多1次）

仅D0-D1全部PASS才可在独立运行root用已核本地Gradle8.14 `--offline --no-daemon --console=plain --max-workers=2`、原三诊断flags/四iceDiag路径属性及两个ABI，执行**一次**前轮真实DAG已确定的`:flutter:packJniLibsflutterBuildDebug`及`:flutter:compileFlutterBuildDebug`必要依赖，沿用sealed env；不运行宿主APK、profile/release、任何真实设备、Flutter新下载或其它不相干producer。生产者若进入新不明获取/权限/依赖行为、exit非0或缺文件，STOP不重试。
 
producer exit0亦需核实同任务`libs.jar`**是否真正生成**、源/目标路径、大小/Hash、JAR ZIP CRC及真实条目、适用ABI/真实JNI来源（注意它可能是JNI打包jar，不能误作普通Java类jar），以及隔离写入、gradle task元数据。无真实内容或无法追溯，不创建替代Jar、不从旧Stage复制、不放行后继正式解析。记录`targetPath`和`dartDefines`真实消费者身份，不能夸成ICE真机可安装诊断APP。

## 5. D3｜条件式一次真正30配置离线解析（最多1次）

仅同源有效producer产物PASS后，使用前轮固定`resolvePinnedDebugInputs`严格`android-classes-jar`规则，真正依次调用15模块×debugCompile/debugRuntime的`Configuration.resolve()`，保留原task-specific完全离线、fixed init、四路径属性/三flags及`-Ptarget-platform=android-x64,android-arm64`。首缺失GAV、新变体、transform、文件或工具错误即STOP，余项`NOT_RUN`；只有30/30实际OK才叫`OFFLINE_30_CONFIG_RESOLUTION_PASS`。绝不把前轮DAG PASS、缓存READY或producer Jar存在当解析PASS。

无论D2/D3成功失败：**不执行Flutter Module Debug AAR额外任务、`:app:assembleDebug`、APK构建安装、手机/ADB、SFU/RTC/DB/API、网络/端口变更或main集成**。产物也不能自动提升冻结AC05四项真实媒体安全硬门或v10.1.5功能接受。

## 6. D4｜单一集中交付、权限边界和停止

- 在连续候选`df2bf34302fd65d0f69c0ea34a269eba03dc6a67`上安全新建后继任务分支，普通non-force只新增两份docs：
  1. `docs/versions/v10.1.5/FLUTTER_OFFLINE_GPU_CACHE_CLOSURE_AND_CONDITIONAL_PRODUCER_REPORT.md`
  2. `docs/versions/v10.1.5/flutter_offline_gpu_cache_closure_and_conditional_producer_manifest.json`
- 不改`ACTIVE_STATE.md`、旧报告/失败、GitHub accepted产品main、产品源码或构建脚本。公开只报告脱敏来源分类、证据身份/Hash、必要路径的相对称谓、真实调用计数和阻断，不上传真实SDK package、完整stdout/stderr/daemon/环境、私密文件/SQL/APK或二进制。
- 受影响保护只按具名证据和真实任务派生归属核 before/after，合法Gradle/Flutter自己的缓存metadata/daemon写入单独登记，既有首次FAIL和修正留存。不依赖全盘扫描/无穷非作者审查。一轮非作者审查用于D1前门及D4同一受限交付结论，不能替代Astra最终验收。发布后严格回读Git sole Parent/Root/两个新docs Blob/完整apps与services Tree及GitHub原文字节。
- 终态按事实选唯一一种：`OFFLINE_FLUTTER_GPU_SOURCE_MISSING / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`OFFLINE_FLUTTER_CLI_CLOSURE_NOT_PROVEN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`OFFLINE_CACHE_CLOSURE_PASS / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN / NO_APK`；`REAL_FLUTTER_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_HOST_APK`；`REAL_FLUTTER_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_HOST_APK`。若诊断Dart defines与入口不匹配，须另附`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`，即使有普通Debug Jar也不得写ICE诊断功能通过。

统一状态：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。任务结束即STOP，由Owner回传唯一候选供Astra下一轮复审。
