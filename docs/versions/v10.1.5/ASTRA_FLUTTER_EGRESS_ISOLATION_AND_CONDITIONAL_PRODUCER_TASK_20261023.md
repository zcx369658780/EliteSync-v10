# EliteSync v10.1.5｜既有本地进程树离线隔离确认→完整SDK绑定→条件式Debug Producer／30配置解析｜Codex单一综合长任务

日期：2026-10-23（Asia/Singapore）。

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / NETWORK_EGRESS_GUARD_UNPROVEN / CONDITIONAL_PRODUCER_BUDGET_0_OF_1 / CONDITIONAL_FORMAL_RESOLVE_BUDGET_0_OF_1 / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. 单一目标、权限与确定性停止

Owner此前要求独立复审后继续按**综合长任务**推进。本任务由Astra正式发布，Owner只有在**手动把启动Prompt交本地Codex**时，才授权本任务的受限本机操作；文档发布≠本机自动启动。

本次只解决一个**已明确且不能用推测跳过**的前置门：**已批准的Windows用户权限与既有可信本地工具内，是否能对Flutter CLI、Dart、Gradle及其全部真实子/孙进程提供有效、可验证且失败即关闭的外联拒绝？** 此门仍`UNPROVEN`，不允许以`--offline`、空白HTTP日志、文件URL、代理变量或程序没有调用网络等同于整个进程树已隔离。

若存在**早已安装、可确认权限边界、无需提升权限/系统改动**的可信执行隔离能力，在**LOCAL_ONLY合成无害网络探针**上通过子进程与孙进程外联拒绝的实际验证、不会改系统/共享缓存/他人服务，且可证后继producer整个进程树确实运行于同一隔离之内，则按D0-D1一次完成离线闭包。若不存在这类机制，或任何必要方案需要管理员权限、安装/启用虚拟化、修改Windows防火墙/代理/hosts/路由/全局网络、系统服务、第三方未知软件或下载，**立即STOP**，以`OWNER_NETWORK_ISOLATION_DECISION_REQUIRED`为唯一明确决策门，不能为了证明可靠外联拒绝继续无界调研或试错。

仅上述门PASS，才有条件使用已核同版同engine真实本地`flutter_gpu`包，在**新本任务自有可写、完整且可执行的Flutter SDK Stage**中建立真实包与版本/缓存身份，不允许改旧历史Stage或原始SDK。之后在同一受控离线进程树中可运行**最多一次**已通过DAG的Flutter module Debug真实producer；只有真生成的`libs.jar`通过当次来源、Hash、JAR内容/ABI验证，才可运行**最多一次**真正的`resolvePinnedDebugInputs` 15模块×2配置离线解析。任何中途新缺项立即STOP，绝不自动重试。

**绝对禁止**：任何外网下载或未授权网络访问、系统防火墙/代理/hosts/UAC/提权/网络配置、安装容器或隔离工具、升级/替换Flutter3.41.7/Gradle8.14/AGP8.11.1/Kotlin2.2.20/JDK17、变更锁文件、修改共享Flutter SDK/Pub/Maven/旧Gradle home、跟踪apps/services或build.gradle.kts、宿主APP assemble/安装/ADB/手机/RTC/SFU/DB/API、历史清理、产品main集成/R2或v10.1.6。不能创建空`flutter_gpu`目录、空JAR、旧工件替身或以文件存在绕过真实性检查。

## 1. 固定Authority与连续交付身份

- 仓库`zcx369658780/EliteSync-v10`。开工fresh核live main Git Commit/Root及完整apps/services；main产品仍以独立接受v10.1.4为准：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。不把main源码回写v10.1.5待验候选。
- 连续待验候选sole base **`c1a6cba30f7c18ad8d0f5252436a40ea760437d6`**，Root **`e30e58438b8e6b78fa33a62fa5d9cf9b96eef19c`**，sole parent `df2bf34302fd65d0f69c0ea34a269eba03dc6a67`。候选完整apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`必须本任务保持不变。固定诊断源码`1522466faf798b719ccff281de7584f043946437`及受控app build Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读。
- 最新独立复审 `docs/versions/v10.1.5/flutter_gpu_component_stage_offline_closure_independent_review.md` Git Blob **`554542aac64de7173454640f7fce8e4e28011b88`**；Codex上轮报告`FLUTTER_OFFLINE_GPU_CACHE_CLOSURE_AND_CONDITIONAL_PRODUCER_REPORT.md` Blob`0b9dff16f6258cecf3d9532dd7a0e9b3062215bd`，Manifest`flutter_offline_gpu_cache_closure_and_conditional_producer_manifest.json` Blob`bc49c555992c5633860fcfa286fe0862989fab47`。原任务Blob`9e6e4a16c5d3d8d05f9701c601901f897e58f424`。先完整读取固定正文、`ACTIVE_STATE.md`和最少相关前证，不重复无关旧审计。
- 原Flutter3.41.7 framework Git `cc0734ac716fbb8b90f3f9db8020958b1553afa7`，engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`；34个`flutter_gpu`源文件162666B经Codex LOCAL_ONLY回执对应固定Git Blob，清单SHA256 `417491e869a583b46e6c4782656d47ac5fd13a07ba89b2a9775127a28e23696c`。后续追加5份真实元数据成为39件/163391B**组件Stage**，仍非完整可运行SDK；原两旧执行Stage缺包且受保护，绝不能从新Stage存在倒认它们已补齐。
- 既有Gradle8.14 `--dry-run` DAG 1/1 exit0，`:flutter:compileFlutterBuildDebug→:flutter:packJniLibsflutterBuildDebug`，真实目标`project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar`。原DAG`targetPath=lib/main.dart`、`dartDefines=null`，**保留`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`**；不重新运行已通过DAG。Gradle bin SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`；原50键sealed env canonical SHA256 `78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`，任何大小写`ANDROID_PREFS_ROOT`都必须缺失，`ANDROID_USER_HOME`旧批准值保留。现存严格30配置解析器init SHA256`2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、policy SHA256`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`。

## 2. D0｜短而确定的本机隔离能力门（0次Producer/Resolve）

1. 仅检查本机**已有且已获准使用**的隔离/沙箱功能，不新安装、不启用系统特性、不修改防火墙/代理/全局hosts/路由/服务。给出一个**具名、可证明权限的可用机制**，说明其是否真能将`gradle.bat→Gradle JVM→Flutter .bat→Dart/Flutter CLI→native hook`的**全部衍生进程**置于同一个无外联受控边界；也要防止进程从继承句柄/代理或脱离进程树逃逸。不能把job object单纯进程归属/kill-on-close直接当网络deny证据。
2. 若找到机制，先做**任务自有、本地合成、不涉及产品或凭据的负例探针**：无害父进程以及至少一层子/孙进程尝试触达一个**不可传送任何用户数据**的固定外联测试目标；必须记录确定的`DENIED_BY_ENFORCEMENT`而非DNS失败、目标无响应、现有网络中断或仅stderr无消息，并验证同机制下正常本地文件/进程/Flutter工具调用可执行。若无法不访问公网就构造可鉴别的拒绝测试，证明等级仍`UNPROVEN`并STOP，不授权真实网络试探。探针仅可使用已批准本机工具与受控本地资源，原始证据/地址只留LOCAL_ONLY。严禁通过临时放行公网或发送实际应用负载测试。
3. 除真实拒绝，还需验证边界的**fail-closed可靠性与可继承性**、项目子进程实际绑定及退出清理不会留下常驻服务/全局更改。任何需要管理员权限、UAC、系统安装或安全配置新授权即`OWNER_NETWORK_ISOLATION_DECISION_REQUIRED`并STOP；不能调用升级方案“先做一次看看”。

## 3. D1｜真实完整可用本地SDK绑定与离线缓存门

**仅D0全部PASS后**，在本任务可写独立LOCAL_ONLY完整Flutter SDK Stage中复用此前实际已获准的同版本字节和39份组件；只允许对本任务自己的Stage进行源Hash已核的增量填充/路径绑定，禁止修改旧执行Stage、原SDK、旧Gradle用户目录、原global Pub/Maven cache。若完整可执行Stage尚未安全准备，应采用既有获证逐文件原字节/受控复制目录进行**必要最小化构建**，不无理由再全拷贝7GB；但复制未具名来源、越界reparse point、覆盖旧原证、缺关键构建组件时必须STOP，不能因成本避开真实性。

读回`flutter_gpu`的34源码+5 metadata真字节、引擎和Flutter3.41.7、launcher/tool/package_config/pub/engine与其他Android required artifacts的实际存在性及版本契约；只使用原有受控SDK工具和现成缓存，不执行`flutter precache`、新`pub get/upgrade`或网络获取。确认producer中的Flutter CLI确实绑定当前新完整Stage及该离线边界；若需调整原50键sealed环境，应**在本任务自有新回执中显式核差异与全部安全变量**，不能偷偷沿用旧Hash宣称绝对无变化。原受保护原值与旧启动证据须留存。
 
`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`为独立门禁：必须保留实际FlutterTask`targetPath=lib/main.dart`、`dartDefines=null`的历史证据。可提出所需诊断build合同变更，但本任务不能因此改产品源码或声明ICE_DIAG可安装APK；如果当前标准Debug产物只能用于classpath实体前置核验，应明确局限，允许继续的只是已冻结30配置的工具级解析，而非ICE媒体实验。

由同一次非作者有界复核对D0+D1隔离、SDK归属、数据/历史保护及隐私给出**无must-fix**的前置确认；失败或未证明即STOP，Producer 0次。

## 4. D2｜最多一次真实Debug producer（条件式）

仅D0+D1实证PASS且同一进程树隔离生效才可执行一次实际`:flutter:packJniLibsflutterBuildDebug`及其必要`:flutter:compileFlutterBuildDebug`依赖。通过可信Gradle8.14、`--offline --no-daemon --console=plain --max-workers=2`、受控双ABI与三flags/四路径属性，禁止Wrapper/新下载或其它目标。若隔离拒绝新获取行为、Flutter CLI实际缺包、Bootstrap触发权限阻断或producer exit非0，立即STOP，报告精确最深证据，不开外网、换SDK或再次尝试。
 
producer成功仍须验证**本次同源实际生成**的`.android/Flutter/build/intermediates/flutter/debug/libs.jar`，真bytes/SHA256/JAR CRC及非占位内容、正确Flutter3.41.7 / source / task identity / ABI输入，注意该Jar可能是JNI包而非Java class库，不得对空native payload伪造PASS。无合法JAR即`PRODUCER_OUTPUT_UNVERIFIED`并STOP。

## 5. D3｜条件式最多一次真实30配置离线解析

仅Producer产物通过，按原已批准Gradle8.14严格`android-classes-jar`选择策略，在同一被隔离环境运行**一次**`resolvePinnedDebugInputs`，15模块×`debugCompileClasspath/debugRuntimeClasspath`共30个真实`Configuration.resolve()`，逐配置记BEGIN/OK及首个真实错误；若出现新缺GAV/transform/文件/变体异常即STOP，剩余NOT_RUN，无一律补齐、重试或下载。只有30/30真实OK方能标`OFFLINE_30_CONFIG_RESOLUTION_PASS`。无论结果如何，**绝不构建宿主APK、启动安卓设备、Room.connect/RTC、DB/API/SFU或产品main集成**。

## 6. D4｜一个版本报告、一次非作者复核、停止

- 将核实的外联隔离**真实等级**与未授权机制、实际SDK来源/任务拥有的目录、旧39组件身份、ICE诊断flags局限、实际producer与30配置计数分层写明。严格区分“完全没运行”与“工具启动失败”、Windows证据仅`CODEX_REPORTED_LOCAL_ONLY`，Astra不亲自重跑。原用户隐私、stdout/stderr、Gradle daemon、完整系统环境、网络探针详细信息、包源码/二进制、旧SQL/APK仅存LOCAL_ONLY，不上传GitHub。
- 不要再做整套历史工作树的无边界Hash考古；按具名触及文件、旧归属根、旧refs和5历史root前后比较，保留旧错误与所有未授权`.zip.part`。运行Gradle时合法产生的派生缓存/daemon/锁另列变化及Hash，不能报“零写入”或为了clean而删文件。
- 在独立干净后继分支以`c1a6cba30f7c18ad8d0f5252436a40ea760437d6`为sole Parent，**只新增两份docs**：
  1. `docs/versions/v10.1.5/FLUTTER_EGRESS_ISOLATION_AND_CONDITIONAL_PRODUCER_REPORT.md`
  2. `docs/versions/v10.1.5/flutter_egress_isolation_and_conditional_producer_manifest.json`
  不改Git跟踪`apps/services`、旧报告或`ACTIVE_STATE`，不合main。普通non-force发布，回读最终唯一Parent/Root、两文档Blob及原始字节、完整apps/services Tree，交付后停等Astra。
- 终态只能依据真实对象选：`OWNER_NETWORK_ISOLATION_DECISION_REQUIRED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`OFFLINE_SDK_OR_GUARD_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`EGRESS_GUARD_PASS / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN / NO_APK`；`REAL_DEBUG_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_APK`；`REAL_DEBUG_JAR_VERIFIED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_APK`。即使有成功也附`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`直到独立合同后证据能证明已消除。

共同固定`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。如无用户权限级可用隔离机制，**立即列一个明确Owner权限选择并STOP，不再为同一前置无限重复派发。**
