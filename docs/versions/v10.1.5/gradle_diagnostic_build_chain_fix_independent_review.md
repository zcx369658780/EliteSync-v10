# EliteSync v10.1.5｜Gradle诊断专属构建链修正 Astra独立复审

日期：2026-10-23（Asia/Singapore）。独立评审者：Astra／EliteSync GPT顾问。

**INDEPENDENT_REVIEW_COMPLETE / DIAGNOSTIC_ONLY_GRADLE_SOURCE_FIX_SUPPORTED_WITH_OBSERVATIONS / INIT_REPOSITORY_CLOSURE_FAILURE / PINNED_DEPENDENCY_GRAPH_NOT_RESOLVED / NO_DIAGNOSTIC_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTOMATIC_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 评审对象、Git身份、真实证据级别

本次审查直接使用GitHub Connector逐项获取**最终提交、源码提交、相对父提交比较、真实build.gradle.kts、正式报告、清单、Git根Tree**。Astra没有在Owner Windows中执行Kotlin/Gradle/SDK、读取私有动态init脚本原始文件、31项fixture原stdout或1531份本地保护原证；据此**Git对象/源码逻辑可标ASTRA_GITHUB_DIRECT**，Windows工具、测试、私密运行、复制及停机只能标`CODEX_REPORTED_LOCAL_ONLY`。

- 上位唯一Owner批准任务：`docs/versions/v10.1.5/OWNER_APPROVED_GRADLE_DIAGNOSTIC_BUILD_CHAIN_FIX_TASK_20261023.md`，Blob **`f69ea6325c309fbfacd397bd9abfaf2183d29616`**；上一轮Astra Gradle专项复审Blob **`7e379354cc4f31074597a431941f233d804f2085`**。
- 此次审查前live main **`f011cac7a097c834308f30ee4bb63acd718cda1c`**，仍是已接受的v10.1.4产品+顾问文档，未纳入v10.1.5候选。
- 源码候选Commit **`5354ba679e24dbf972cea74e8fd0f60c51a2eca0`**，唯一Parent **`76a7542d9c9121051b55251fda198e568a8d0aa5`**，Root **`766b43530a606a60e1e55f7f4721857c14d5a28a`**。Git Compare ahead1/behind0，**只修改`apps/android/app/build.gradle.kts`一个跟踪源文件**，Blob由`5a08d63f5f95155ca1f346f9809683f6f35ac7e0`变为**`d588562d5fce8a161c2bef8c879a2597b940010f`**，69处行级改动。
- 最终交付Commit **`7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`**，唯一Parent为该固定source，Root **`3d62ff21846396a34be63b605e9b4dc3425b6f1c`**；相对source仅增加`docs/versions/v10.1.5/GRADLE_DIAGNOSTIC_BUILD_CHAIN_FIX_REPORT.md`（Blob **`03bca438980001908e594a9c9f48002a941be629`**）和`gradle_diagnostic_build_chain_fix_manifest.json`（Blob **`2b40f1e1d8c2c6b9ddca8b0aebf6336ebcfa4617`**）。
- GitHub真实Tree显示源码提交和最终docs提交完整**apps Tree均为`8011c1909444c689c45a23d4c20e1bef85694966`，services Tree均为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**，只有docs不同；Flutter源码自身不变的具名子树`ce77296255d1439a38bb17287c7b35dcd830a820`由Codex报告与Git身份支持。**SOURCE_DELTA_NARROW / PRODUCT_MAIN_UNCHANGED**；不能说`apps`与旧基线相等，因为此次确实修了诊断构建脚本。
- 报告与manifest均直接读取。后续本地主动保护统计应以Codex实际回执为准，不将本轮Github核Tree等同为实机全盘hash验收。

## 2. 诊断专属Gradle源码复审

直接读取新版`build.gradle.kts`：

- `validateIceDiagnosticGradle`只在`isIceDiagnosticBuild`条件下触发。该验证要求Windows、Gradle8.14、明确传入`iceDiagGradleBin`和`iceDiagGradleUserHome`的绝对路径；用canonical path和固定任务归属核查原分发bin与isolated-home，并确认`gradle.gradleUserHomeDir`及本次进程`GRADLE_USER_HOME`一致，核SHA256的`bin/gradle.bat`、CLI main JAR和Gradle core JAR。违例`ICE_DIAG_GRADLE_GUARD_REJECTED`，未见诊断模式静默回退Wrapper的分支。
- `syncFlutterAar`在`isIceDiagnosticBuild`时使用`iceDiagnosticTooling!!.first`作为内层命令、同一个`GRADLE_USER_HOME`、`--offline --no-daemon`；其他路径仍沿用既有`gradlew.bat`／Flutter `build aar`方案。`-Ptarget`仍为`lib/dev/v1015_ice_diag.dart`；诊断构建仍`assembleAarDebug`、固定两个ABI、原Dart defines编码、r1Digest、诊断专用AAR路径和宿主`preBuild→syncFlutterAar`，未借机替换release AAR或移除前置构建。
- 上述是**源码逻辑层级的有界支持**，并不证明全部实际Gradle配置能被加载：报告中的31项测试属于**从实际Kotlin函数及命令表达式提取的fixture**，6项隔离比对属于源码对照；没有真实宿主`:app`完整debug Gradle配置/构建。在这次单轮source改动之内，Astra没有直接发现必须打回的高置信产品安全P1，但仍保留`FULL_ANDROID_HOST_CONFIGURATION_NOT_RUN`与未来APK正向产物门。
- 固定路径严格指向本任务归属的本地工具目录，构建源码具有测试运行环境耦合；**不要直接照搬到生产/普通包**，接受条件应为test-only完整正向build和普通R1/release/profile隔离实测。仅当前静态核查无法证明未来其他机器的可移植性，且无此需求。
- 以前诊断产品源码`24ddf05875d8d4abad7a6b473f882698c9885c2a`的测试无音频/安全白名单仍按上轮review的冻结边界保留；本轮没有实际真机验证。

## 3. 实际G0–G4证据与中止点

| 门 | 裁决 | 证据等级／限制 |
|---|---|---|
| G0可信工具和资产 | `CODEX_REPORTED_SCOPED_PASS` | Gradle8.14 ZIP/hash、本地bin/JAR、Flutter3.41.7及engine、精确`flutter_embedding_debug`官方POM/JAR均为从可信存量复制的本地回执；SDK副本起初只适于Gradle配置，**不是完整构建可用工具链**。 |
| G1临时动态解析入口 | `STATIC_CODE_PREPARED_RUNTIME_INIT_BLOCKED` | LOCAL_ONLY init脚本登记了准确的15个模块debugCompile/debugRuntime解析目标并有`resolve()`调用逻辑，但失败发生在仓库DSL配置期；Astra没有亲自读原临时Groovy字节，主要依据是报告/manifest及脱敏原错误。 |
| G2诊断内层Gradle修正 | **`SOURCE_IMPLEMENTATION_SUPPORTED_WITH_OBSERVATIONS`** | GitHub直接核唯一路径diff和安全校验条件；仅诊断标志下改变Exec命令。未经完整Android配置/diagnostic debug AAR构建，不能升为`END_TO_END_BUILD_CHAIN_PASS`。 |
| G3安全测试与非作者 | `CODEX_REPORTED_31_FIXTURE_PASS / 6_ISOLATION_CHECK_PASS` | 测试包含property缺失/版本Hash/Wrapper别名/路径、普通路径与diag变体，突变测试正确拒绝。静态非作者复核发现的target-platform与启动环境问题据Codex回执修正；**该审查没有预见真实init Groovy closure错误**，不自动等于全链无故障。上轮20诊断和93回归为`REUSED_VALIDATION`，不是此次重新运行。 |
| G4真实预检 | **`EXIT1_AT_INIT_REPOSITORY_CLOSURE / TARGET_RESOLVE_CALLS_0`** | 运行40.733秒，包含Flutter工具插件4个构建任务；因此不应说进程“完全没有任何依赖活动”，但专门要验证的`debugCompileClasspath/debugRuntimeClasspath`的`resolve()`为0，目标依赖图`NOT_VERIFIED`。 |
| 诊断APK | **`NO_APK / POSITIVE_ASSEMBLE_DEBUG_0_OF_1`** | 不曾触发真实AAR/宿主APK构建，因此versionName、应用包名、签名、debuggable、产物ABI及Flutter诊断入口未经过产物证明。 |
| 安全停机与保护 | `CODEX_REPORTED_PASS_WITH_LIMITATIONS` | 不联网抓依赖，不调用外/内Wrapper，不动手机/DB/API/SFU；152?等旧计数不可虚构，实际本轮为1531份具名原证、3253条工具链/cache记录、496 refs／5根，第一历史根153条Windows长路径warning，未登记目录不宣称覆盖。 |

**唯一真正的新阻断非常具体**：临时`exact-flutter-repo.gradle`中的仓库`exclusiveContent`闭包把`maven()`调用送到了`ExclusiveContentRepositorySpec`接收对象，出现`Could not find method maven()`，在init脚本第9行结束。该脚本为本轮LOCAL_ONLY临时工具，非Git跟踪生产源码；**不等于新Flutter依赖坐标缺失，更不是ICE媒体根因**。报告和清单支持`PINNED_RESOLVE_BEGIN/OK/PASS=0`、target resolution0、APK构建0/1。静态审查遗漏运行时DSL行为是**本轮真实预检发现的有效限制**，不可改写为“Gradle链已全部修好”。

Codex仍报告各次命令使用`--offline`、无新外网包/SDK下载、先前未经授权`gradle-8.14-all.zip.part`未使用；这属于具名本地回执，未有全宿主网络抓包证明绝对无网络。没有重复构建或把一次失败重命名为另一次试验，遵守本轮单次执行门。普通APP源码和main没有改动。

## 4. 裁决与后续建议

**独立裁决：`DIAGNOSTIC_GRADLE_SOURCE_FIX_REVIEWED_WITH_OBSERVATIONS / GRADLE_INIT_RUNTIME_BLOCKED / PINNED_DEPENDENCY_GRAPH_UNVERIFIED / NO_APK / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

保留本轮固定source和独立报告作为**部分有效的诊断专属构建改造证据**，**不签完整Gradle构建可用、不签诊断APK身份、也不签v10.1.5功能ACCEPTED**。没有理由凭该构建错误去开放UDP/LAN/TURN、重改SFU bind或推翻前期ICE产品安全决策。

若Owner以后明确继续，建议只批准对LOCAL_ONLY init脚本**仓库DSL接收对象**的定点修正，在不改产品源码/SDK版本/受保护缓存或下载外网依赖的前提下，先用一个最小离线Groovy/Gradle fixture测试仓库DSL是否能真正完成注册与仓库闭包解析，再使用可信Gradle8.14在当前隔离环境**进行一次**受控同版本依赖预检。只有真正进入并通过目标`resolve()`后才考虑上轮保留的一次`assembleDebug`预算，先核全构建SDK组件是否就绪，且禁止未授权SDK新拷贝/网络/运行机动作。如遇新真实缺失坐标、非诊断代码变更或构建root不兼容，停并请Owner重新决定；不能为省流程反复失败。**本次没有签发新的Codex任务，Owner尚未授予新的真实预检/构建预算。**

整个项目继续方案A、已接受v10.1.4主线、未接受v10.1.5、AC05四媒体硬门OPEN。任何本轮纯源修正不得通过无真实功能证据的“形式接受”让产品状态升级。
