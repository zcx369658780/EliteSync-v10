# EliteSync v10.1.5｜DAG观察器同名声明修正→真实Flutter Debug生产者→条件式30配置解析｜Codex唯一综合长任务

2026-10-23（Asia/Singapore）。

**ASTRA_NEXT_TASK_ISSUED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / FIX_NOT_YET_RUN / NEW_DAG_BUDGET_0_OF_1 / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Scope、Owner授权点与目标

Owner此前要求验收后持续按综合长任务推进；本任务由Astra核上轮阻断后发布。**只有Owner把本文件的完整启动Prompt手动派发给本地Codex，才授权此次三个严格条件递进的运行预算。** 发布GitHub docs本身不启动程序。任务不再拆成单独“先修一个观察器、再追加新任务”的微循环；Codex在同一次授权中尽量推进到有根据的最深安全证据点。

本轮首先修正**仅任务LOCAL_ONLY** Groovy观察器的顶层`moduleRoot`重复声明，保留原继承init的全部安全guard和其他变量。经任务开始前完整拼接源码静态门及非作者一次有界复核通过，允许最多**一次**真实 Gradle`--dry-run`任务图诊断，只验证候选producer `:flutter:packJniLibsflutterBuildDebug`以及`:flutter:compileFlutterBuildDebug`和全部必要上游action是否安全属于已批准的Flutter模块Debug范围。**仅实际完整DAG PASS、依赖图不含越权宿主APK/release/profile/下载/网络/设备权限时**，可最多一次执行该具名真实Flutter Debug生产者任务及必要依赖；**仅真正由该任务生成并验证**本运行副本`.android/Flutter/build/intermediates/flutter/debug/libs.jar`后，可最多一次执行此前受阻的真实30配置离线`resolvePinnedDebugInputs`。三个预算互相独立、逐门许可、任一新阻断即STOP，不能把过去未执行的预算偷搬过来。

若完整DAG证明最小生产者需要**模块内部Debug AAR链**，必须先具体列出task/action/写入边界；仅当其完全属于Flutter模块debug、无宿主APK和无额外系统/网络/SDK权限时，才可将这些实际依赖计入**同一次producer预算**。不能预设一定需要AAR。禁止为了使libs.jar出现而新造空JAR、复制老版、运行宿主`:app:assembleDebug`、删掉artifact校验或改变产品实际构建源。

绝对不授权：编辑跟踪`apps/services`源码、真实产品`build.gradle.kts`、全局/用户环境、Gradle/Flutter/AGP/Kotlin/JDK/SDK/锁依赖版本；联网或SDK/Pub/Maven下载；任何Wrapper；宿主APK构建安装/ADB/真机、RTC/SFU/数据库/API/云端/公网、防火墙/UDP/LAN/TURN；身份/Push/付费真实供应商、历史备份/工作树清理、产品main集成、R2及v10.1.6。

## 1. 首读真实authority及连续候选

- 仓库`zcx369658780/EliteSync-v10`；本轮以实际开工时fresh GitHub main Commit/Root/apps/services为实时参考，**main产品始终仅可认已接受v10.1.4**：apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`／services`0cb1f9d19659291a462488b3686fd0a07a6698ac`，不要拿main代码覆盖未接受v10.1.5。
- 连续候选唯一技术起点`8861c30464893f11968465fee365e5e5471fa773`，Root `d1112b5f89a969a466612f85d40e0c623f80d9b5`，sole Parent `5653baf6c07f27ea11217edd1bd50f47acb5621f`；整个候选apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`必须保持不变。固定诊断产品source `1522466faf798b719ccff281de7584f043946437`，跟踪app Gradle Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读。
- 最新Astra正式独立复审`docs/versions/v10.1.5/flutter_producer_dag_observer_block_independent_review.md` Git Blob **`f98867b3450e6fda65e4623aec82df83d2160aab`**。前轮Codex报告`FLUTTER_LIBS_JAR_PRODUCER_AND_SINGLE_RESOLVE_REPORT.md` Blob `ca72fa08a712d88e29ac2b2982769862ecb50ebf`、Manifest`flutter_libs_jar_producer_and_single_resolve_manifest.json` Blob `387b2a448d3b25cd81dd72d8ee0d43b52a0f9b51`。历史Flutter libs.jar首阻断复审 Blob `1646e3fe9c32e7f294e9e838c65cec9f2745e655`。首先读取这些固定原文及本项目`ACTIVE_STATE.md`，不要重开整仓考古。
- 前轮唯一task DAG尝试 **1/1 exit1 4.3015秒**：属于本任务新增observer与继承init顶层Groovy `moduleRoot`重复声明，物理观察者脚本第29与121行、编译报line79（注意拼接映射可能不同）；**DAG没有实际构成**，未执行producer/resolve，也未运行observer真正的安全guard。历史脚本固定SHA256 `7a22825edceaf8658df54571ea2452d865503b647512e4e8ddff2768e85270db`，历史组合init SHA256 `c5e5293aadd3738d751f492b46bb6d00a237df7b60b7f5c251f6533d84c14175`，原stdout 510B SHA256 `3d7b47392621fad0d6cb99c585e5d738f2aa590710e26e4623b217d519c7d1e4`、stderr 868B SHA256 `a3ecbdaf40d5c6c58f0cc054196723adb3ef2b1322ce87a44349a74f1617ca4f`均仅LOCAL_ONLY。
- 固定Flutter源码候选身份：`FlutterPlugin.kt` SHA256 `1eeb49a1e17859b150e8ed5109c9af0932fafacb06810d2a02bc688a69387313`、`BaseFlutterTaskHelper.kt` SHA256 `81bfe154b078bd6e3603720e6d147396c81f1012c72633b590f04b42265d2730`。静态链 `:flutter:packJniLibsflutterBuildDebug` (Jar) `dependsOn(:flutter:compileFlutterBuildDebug)`，目标 `project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar`；**必须实际DAG+输出再确认**，不能从名字判定可安全运行。
- 工具冻结：Gradle8.14 bin SHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`、Flutter3.41.7、Dart3.11.5、engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、AGP8.11.1、Kotlin2.2.20、JDK17.0.18.8。50键sealed有效环境原Hash`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`；`ANDROID_PREFS_ROOT`大小写别名必须始终缺失，`ANDROID_USER_HOME`保留批准的既有目录。前轮严格`android-classes-jar` init和policy SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f` / `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`继续保留，不重新发明依赖图语义。

## 2. D0｜只修本任务Groovy观察器，先拦截同类低级错误（不启动Gradle）

1. 定点只读核**真正原始拼接前缀与后缀、作用域/变量符号表**，不是根据行号猜测如何删除。修复只在**新任务独占的LOCAL_ONLY init或observer副本**进行：引用继承前缀的同一个`moduleRoot`，不二次`def`声明；不得随意删除/重写前缀或掩盖原始变量指向。核对所有顶层符号/方法与闭包捕获不存在重复、shadowing、不同root重绑及不安全副作用；静态文本合成后检查完整源码，而不是仅单独lint新后缀。新实际组合文件逐字节保存Hash/来源映射，与旧文件的唯一定点差分可审。
2. 用受控静态/现成离线Groovy解析器或脚本层检查完整拼接体，可验证语法及重复声明、root/cache/cwd/target与安全guard的代码存在和原语义；**不是要求额外Gradle真实运行**。对人为再加`moduleRoot`或taskRoot换位的负例需明确拒绝，避免相同bug消耗下一次任务图预算。不能将字符串出现次数作为充分的Groovy静态证明；若静态门不能充分保证作用域正确，用单次下阶段Gradle`--dry-run`实际结果作为最终事实，任何失败即STOP。
3. 旧311653具名文件/504 refs/五历史根/153旧warning、此前init/env/src Hash、原dirty/SQL/APK/保留卷/隐私日志/旧未授权`.zip.part`和所有失败保留。采用当前已核隔离运行副本与受控Gradle home，避免重复制7.3GB SDK、无界探测其他项目或把历史全目录重新当成每轮必须完整hash的固定数量门。每轮按实际触及清单做具名前后Hash与新派生文件归属。原Observer、stdout/stderr、daemon、保护首次错误不得改写。

## 3. D1｜一次真实Gradle Task DAG诊断（独立新预算1/1）

前置静态/离线安全门、固定工具/有效环境/插件源和非作者**前置**有界复核通过后，才允许最多一次使用**可信Gradle8.14本地bin直接调用**、`--offline --no-daemon --console=plain --max-workers=2 --dry-run`，目标严格`:flutter:packJniLibsflutterBuildDebug`，原三诊断flags、四iceDiag路径属性、双平台`-Ptarget-platform=android-x64,android-arm64`、已审核`-I`本任务完整拼接init。拒绝Wrapper、`--refresh-dependencies`、联网、SDK自动获取、改工具/环境/锁与跟踪源码。该dry-run虽不执行producer仍可能在隔离目录生成Gradle配置/daemon缓存，须如实审计。
 
**必须获得具名实际Task DAG/selected task及`:flutter:compileFlutterBuildDebug`链**，以及自有observer安全检查已实际执行的回执，逐task分类产物、入出路径、潜在网络/外部下载、target平台/ABI、只读与可能写入的归属目录。Gradle`--dry-run`任务图不一定完全证明所有任务动作运行时不会触网；对未能静态关闭的隐式下载/宿主APK/非debug/release/profile/全局SDK写入务必报告并STOP。原重复声明错误不再可接受；若DAG失败或有新证据缺口，**本任务止于报告、不绕过或重试**。不得用静态source关系冒充DAG成功。

## 4. D2｜条件式唯一真实Flutter Debug producer（新预算最多1/1）

只有D1 DAG及隔离写入边界、**实物任务图的所有依赖闭包**通过、所有潜在外联被fail-closed并由同一个非作者有界审查确认可运行时，才能**一次**真实执行确认的最小`:flutter:packJniLibsflutterBuildDebug`及其严格受控依赖链，仍直接可信本地Gradle离线、不调用Wrapper，不运行宿主APK、RTC或DB。若真实依赖闭包中不可避免出现只为Flutter**模块内部debug**的产物（包括Debug AAR），其调用/产物必须列为本次producer的一部分，不能自行多次换目标，也不能借此启动宿主`:app:assembleDebug`。
 
producer exit0也须**核验当次真生成** `Flutter/build/intermediates/flutter/debug/libs.jar`：原来是否存在需在本次运行前实核；结束后看task证据、mtime/Hash、Java ZIP/JAR格式与CRC、有效非占位条目/真实native artifacts和ABI对应关系。若本版Debug JNI源原本没有某ABI payload，不得补造、也不得草率把空内容记为PASS；明确输出契约和原因。只能在被证明属于同一任务/同一Flutter3.41.7与本版输入的受控产物情况下放行后继解析。新错/资源越界/无JAR/来源不明即STOP，不修复或重试，不拷贝旧Jar充数。

## 5. D3｜仅在producer输出通过后执行一次真实30配置离线解析

只可在同一受控隔离工程根、同一工具和sealed 50键环境下使用前轮strict `android-classes-jar`解析器及`resolvePinnedDebugInputs`，**最多一次**真正调用15模块×debugCompile/debugRuntime共30个`Configuration.resolve()`；需要 `--offline --no-daemon --console=plain --max-workers=2`、原三flags/四iceDiag属性及双平台。首个缺GAV/变体、transform、环境或文件失败立即STOP，不下载、不改缓存手工替代、不重复。
 
逐项记`BEGIN/OK/FAIL`，只有全部30真实OK才能写`OFFLINE_30_CONFIG_RESOLUTION_PASS`。`HOST_CONFIG_PASS`、`DAG_PASS`、`PRODUCER_PASS`、`RESOLVE_PASS`和`APK/RTC`仍相互独立。**即使30配置全PASS，也无任何宿主APK build、ADB、真机RTC或main安全集成许可**。

## 6. D4｜证据保护、唯一集中交付与停止

- 一次非作者有界复核覆盖D0源差分与环境负例、D1选中的实际DAG和合法写入、D2真实producer产物归属及D3真实解析计数，前后阶段在**同一次有界复核进程**内有条件回读，不强制再次全仓考古。对不确定的外部行为不能因非作者推断无害就放行。所有第一次失败、包括旧observer Groovy exit1和保护分类原证必须保留。
- 输出归属：LOCAL_ONLY独立日志、Gradle stdout/stderr/daemon、生成JAR/AAR、机器绝对路径、完整环境、旧SQL/APK等**不可上传GitHub或ChatGPT Project**。公开仅合理的Git对象身份、SHA256、脱敏任务/错误类型、调用次数、功能限制及必要相对路径，不公开用户数据和凭据。
- 从连续待验源`8861c30464893f11968465fee365e5e5471fa773`新建干净有界后继候选，仅新增两份版本docs：`docs/versions/v10.1.5/FLUTTER_PRODUCER_DAG_OBSERVER_CORRECTION_RESULT.md`与`docs/versions/v10.1.5/flutter_producer_dag_observer_correction_manifest.json`。不改任何`apps/services`、旧报告、Astra review或`ACTIVE_STATE.md`，不合产品main。普通non-force发布，回读sole Parent/Root、两docs Blob/完整两产品Tree及正文原字节。
- 任一新失败按事实选择`DAG_OBSERVER_OR_GRAPH_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`DAG_PROVEN / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN / NO_APK`；`PRODUCER_OUTPUT_UNVERIFIED / RESOLVE_NOT_RUN / NO_APK`；`REAL_FLUTTER_DEBUG_OUTPUT_VALIDATED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_HOST_APK`；`REAL_FLUTTER_DEBUG_OUTPUT_VALIDATED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_HOST_APK`。

统一附`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。**执行后必须停在候选，不自动进入下一门。**
