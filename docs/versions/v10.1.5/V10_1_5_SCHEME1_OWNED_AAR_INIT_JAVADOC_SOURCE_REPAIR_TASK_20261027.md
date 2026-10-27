# EliteSync v10.1.5｜方案一：项目自有Flutter AAR init来源级最小修复

**状态：OWNER_APPROVED_SCHEME1_SOURCE_REPAIR / READY_FOR_MANUAL_CODEX_DISPATCH / STATIC_AND_ISOLATED_TESTS_ONLY / REAL_BUILD_BUDGET_ZERO / GATE2_NOT_AUTHORIZED**

日期：2026-10-27（Asia/Singapore）
Owner：产品方向及重大不可逆事项的最终authority
执行者：本地Codex（Owner手动派发后）；Astra负责后续独立验收

## 0. 唯一目标和授权边界

Owner已明确接受方案一，授权在**项目拥有、来源/许可/哈希可追溯的Flutter AAR init副本**中，**仅对v10.1.5普通R1本地runtime AAR路径**有条件去除`withJavadocJar()`请求，以便从发布变体创建阶段避免主动配置Javadoc发布产物。保留 `withSourcesJar()`、必要runtime AAR、插件AAR、发布/POM、`from component`和必需的模块元数据/依赖，且不触碰共享Flutter SDK。

这是一个**实施、静态验证、隔离回归、文档候选集中交付**的任务，不只是再写诊断报告。授权在项目自有代码/任务拥有隔离目录内完成必要最小修复及回归测试。**不授予新的真实Gradle/APK构建、Gradle task graph、--dry-run、Flutter/AAR/Kotlin运行或设备测试授权**。此前真实构建预算1/1已耗尽，剩余0。禁止借此启动旧单次构建入口、清除claim、改变目录重试或默默放宽网络强停止。

当前根因仍为 `ROOT_CAUSE_NOT_PROVEN`；静态候选机制不能被当作Dokka引发原TCP的证明，修复完成也不能宣称消除了该TCP或构建已通过。

## 1. Fresh权威恢复与代码来源

仓库 `zcx369658780/EliteSync-v10`。开工前读取live main及Root、本任务单、`docs/workflow/ACTIVE_STATE.md`、冻结`docs/versions/v10.1.5/plan.md`、最新AAR/Dokka静态报告`AAR_DOKKA_STATIC_DEPENDENCY_REVIEW_20261027.md`、Astra接受报告`AAR_DOKKA_ASTRA_REVIEW_20261027.md`、前TCP只读报告、历史实施报告/Manifest与保护证据索引。

核验后记录参考SHA（执行前必须fresh GET）：
- main：`4df2e7f0f36cc7b80258faa73e80dad682cff6c5`；Root：`03b0ecfcc360e38a462539dd50690c64b663a21e`。
- 最新静态诊断候选：`3d0c656d59e8621ffa6a935313b5cd4c860a16b1`；Parent：`7abea213feacc52a1e43c6ed58a40c83009c74df`；Root：`5f0dbe066ba64b1b8ab05c1698a9c48c19fb9553`。
- 新增静态诊断报告Blob：`96b7bc41e10eeed1ce385c218b4038ca280bf5c2`。
- Astra静态复核Blob：`74b369ee8d64de9db72651e005484a5b0c5271f8`。
- 冻结plan Blob：`7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 近期构建执行源码 `12d4e284feea609935eab12c973f5fd2efbc2992`；候选apps Tree `cea01309fa9da5f99ccc9829654c6ec279c8c343`；services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。
- 接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本任务绝非产品main集成。

从原任务已有可信库存/原字节定位本次安装Flutter SDK的`packages/flutter_tools/gradle/aar_init_script.gradle`。上轮只读分析记录该源SHA256：
`b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`。
本任务须重新以原文件字节只读Hash验证；不匹配或来源/版本/许可不清则停止源码实施，报告`SOURCE_IDENTITY_MISMATCH`，不得从网络下载替换内容或以相似源偷换。

来源代码关键路径以实际字节为准：
- SDK init约`:113-115`为项目应用maven-publish；
- 约`:117-147`的受条件限制`singleVariant`配置请求`withSourcesJar(); withJavadocJar()`（无flavor路径约140-142）；
- 约`:87-105`为AAR task/publication/finalizedBy publish；
- 约`:150-187`为Flutter与插件AAR依赖。

仓库`apps/android/app/build.gradle.kts`约245-272行的普通R1路径会直接执行本地Gradle，当前`-I=<Flutter SDK>/.../aar_init_script.gradle`后面又加载`-I=<项目>/scripts/offline_debug.init.gradle`；约302-303行`preBuild.dependsOn(syncFlutterAar)`。仓库`apps/android/scripts/offline_debug.init.gradle`仅过滤MavenPublication的javadoc artifact，不消除SoftwareComponent中此前请求的文档变体。后续改动只针对**本任务批准的普通R1 runtime AAR**，不能改变ICE diagnostic或其他版本的构建路径。

## 2. 方案一的实现合同

### 2.1 可重复、可追溯的项目自有来源副本

在仓库项目自有`apps/android/scripts/`邻近位置设立有清晰名称、来源说明、受控补丁或生成器、独立Hash的副本；可采用下面两种等价落地方式，**仅择一并记录理由**：

A. 若源文件许可证允许且遵守其声明，在仓库跟踪一个项目自有`aar_init_script`衍生副本，保留原版权/许可/来源、原始SHA256、修改范围及diff。

B. 如果完整上游源码复制到Git仓库存在许可/体积/治理障碍，则在仓库跟踪**确定性的最小补丁/生成器+来源和Hash声明**，于任务拥有的ignored隔离目录从**已验证原字节**生成项目自有执行副本。生成器应具有确定性的输入输出Hash和 fail-closed 行为。生成器生成副本必须是**纯本地文件操作**，不得调用Gradle、Flutter、JVM、网络或共享工具，不得修改SDK原件。此方案必须保证实际嵌套执行入口使用的是这个有Hash核验的项目拥有生成副本；不是仅在文档中说已替换。

不得发布未经核验的第三方源代码或捆绑字体/凭据/个人数据；保留所适用的源许可证/NOTICE。原Flutter SDK和缓存文件在实施前后字节不变，必须有Hash证明。

### 2.2 最小内容差异

从源头`singleVariant`发布变体配置里**仅针对普通v10.1.5 R1 runtime AAR路径**去掉`withJavadocJar()`的请求。需要区分有/无flavor、多个buildTypes、是否已配置singleVariants等分支，不允许靠全局正则盲删所有文本。优先在已验证原字节上使用准确上下文定位+唯一匹配断言；每个实际生效分支应有明确测试覆盖，并保留其余源字节/语义。

必须保持：
- `withSourcesJar()`和经批准的sources行为；
- Flutter/插件的AAR任务注册、组装、`finalizedBy publish`和需要的`from component`；
- runtime/AAR变体、POM和依赖模型、Module Metadata中必要的运行时依赖；
- `assembleAarRelease`任务选择器及其插件AAR关联；
- 当前普通R1本地Gradle8.14/offline/无Wrapper fallback/Java工具链禁下载规则；
- ICE diagnostic、retention probe、其他版本/产品build路径保持原入口，不因本次复制替换全部Flutter AAR init。

不能通过`tasks.named("javaDocReleaseGeneration").enabled=false`、关闭`GenerateModuleMetadata`、禁用所有publish或删除plugin/runtime AAR来“修复”；这会掩盖任务依赖/缺失产物问题。现有`offline_debug.init.gradle`的artifact过滤可保留作为防御，但不能继续把它单独视为任务注册源头修复。

### 2.3 被消费的路径必须真实切换

项目的嵌套`syncFlutterAar`调用，应在**普通R1 + 非ICE + 非retention**条件下明确使用经过Hash验证的项目自有init执行副本，并仅在允许条件内传入；其它已有分支维持原SDK init不变。

进入执行路径前，校验原源Hash、衍生副本/补丁输出Hash及有效标志。若项目副本缺失/Hash不符/补丁定位不唯一或未获许可，必须fail-closed，不得暗中退回共享SDK原路径，也不得自动从互联网更新。

若Gradle脚本需要引用任务拥有副本路径，必须校验其位于受控root且不含不安全路径穿越/符号链接；静态测试需明确证明普通R1路径切换、其他模式不切换。

## 3. 零构建的隔离验证

本任务**可以运行本地Python只读/生成器隔离测试、纯静态/文本/字节断言与临时文件Hash校验**；不得运行Gradle/Flutter/JVM、任何AAR/APK构建、`--dry-run`、`gradle tasks`、`dependencies`、设备/网络观察器，亦不得调用系统全局服务。

至少在隔离测试中验证：
1. 可信原源Hash匹配时，生成/副本字节与记录Hash确定、只修改批准位置；相同输入得到同一输出。
2. 原源Hash变更或目标定位不唯一时，预检阻断；不修改共享源、不下载、不降级fallback。
3. 被授权的ordinary R1路径不再请求Javadoc；其他构建模式/分支使用原受控SDK init路径。
4. 无flavor及有flavor分支中的`withJavadocJar`请求覆盖得到明确记录；不能因只测单分支就宣称全部分支PASS。
5. 仍有`withSourcesJar`、`maven-publish`、`from component`、AAR/publish/finalizer/插件依赖等必要逻辑；**静态文本存在不等于运行依赖图已PASS**。
6. 模块运行时AAR/POM/Module Metadata未被项目源码主动关闭或删除；没有动态产物验收，不得声称真实产物Hash/依赖解析通过。
7. fail-closed阻断旧Wrapper/bootstrap、工具下载fallback、未受控init源。
8. 单元测试进程不得产生真实外部Popen、socket、ctypes DLL/JVM加载事件；使用显式mock/隔离审计。
9. 两项历史`NON_LOOPBACK_TCP_ENDPOINT_OBSERVED`、UDP分类语义、真实单次预算1/1和claim状态都不能被此次修复修改或重置。
10. 修改后的项目代码与字节清单全部可独立review，`git diff --check`和适用的静态解析通过。

测试发现新缺陷时仅在上述批准路径及本地隔离范围内修复、再次跑**隔离测试**；不通过/源不可信时停止并报告，不能通过一次真实Gradle构建定位问题。

## 4. 路径白名单与停止条件

优先将变更限制在：
- `apps/android/app/build.gradle.kts`（仅必要的`syncFlutterAar`入口条件分流与来源校验）；
- `apps/android/scripts/`下新建的项目自有受控init副本或确定性补丁/生成器、相关隔离测试与README/来源许可声明；
- 如果构建入口`offline_debug.py`的预检/输入inventory必须包含新受控输入，允许**最小**更新该项目自有文件及对应mock单测。

严禁更改APP Dart、LiveKit vendor SDK、Laravel后端、token/consent/Upgrade、Gradle/Flutter共享安装、根Gradle依赖版本、系统策略或冻结plan。若无法在此白名单内做到，停止并提交局部结果/缺口给Owner，不自行扩大范围。

特别注意：现有构建库存是旧输入合同；新init与调用脚本改变后必须标记`NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY`。**不得复用旧库存Hash就声称构建输入已验证，亦不得创建新真实构建预算、清除旧claim或执行普通离线构建。**

## 5. 历史原证、环境和费用

严禁reset/amend/force/stash历史根、改写受保护dirty tree、清理旧refs/SQL/APK/LOCAL_ONLY目录/部分Gradle下载文件。保留历史7,941,328字节partial、原SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、两次构建停止的原始stdout/stderr/JSONL、既有守卫/停止记录和旧原始Manifest。

不启用网络、系统防火墙/代理/VPN/执行策略改变，不提权、不下载新工具或依赖、不接入生产服务/真实Push、不使用真实用户、不产生新增费用。普通只读GitHub发布按既定治理允许，不等于允许本地构建联网。

Gate2新启动/Writer/Serializer必须0，历史WinPS/PS7两次预算已消费；37套件、条件Sandbox SDK、Producer/libs.jar、30配置解析继续NOT_RUN。v10.1.5整版与AC05保持开放，AEC、最后可闻波形、native handle完整普查、实际15/30天与物理30天清理、真实Push仍未证明。

## 6. 交付、独立审查与停止

保留冻结计划原字节。集中交付一次普通non-force**同版本代码+报告候选**，仅对允许的源码路径做最小改动，追加`IMPLEMENTATION_REPORT.md`与一个`artifact_manifest.json`而不覆盖历史章节；注明这是源级修复候选，**未运行真实Gradle/Flutter/AAR、未生成/安装新APK，尚未验证真实发布任务图、TCP与Dokka问题是否解决**。

交付至少包括：
- live main/Root、前候选和源码、最新Commit/唯一Parent/Root、apps/services完整Tree及全部变更Blob/SHA256；
- SDK上游原件的来源/许可/Hash、本地衍生副本或确定性patch+生成器Hash、授权与未授权模式差异；
- 所有静态/隔离测试命令、case数、RED/GREEN、退出码/stdout/stderr Hash及审计0结果；
- 只改项目拥有路径、共享SDK原字节与历史备份保护范围；
- `SOURCE_LEVEL_JAVADOC_REQUEST_REMOVED_BOUNDED`、`PUBLISH_GRAPH_NOT_EXECUTED`、`AAR_POM_RUNTIME_NOT_PROVEN`、`ROOT_CAUSE_NOT_PROVEN`、`ACTUAL_BUILD_NOT_COMPLETED`分别标记；
- 唯一实际构建授权仍耗尽`1/1`；当前新构建预算为0；
- LOCAL_ONLY原始数据不出库，非作者审查仅限静态，不宣称他人运行过测试/设备。

发布候选后，按实时GitHub原始字节回读Commit/Parent/Root、报告Manifest Blob、产品双Tree与具名保护refs。Codex停止等待Astra独立验收；不自行决定新真实构建预算、执行新的Gradle、创建后继任务、合并产品main或启动v10.1.6。

**最终状态继续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。**
