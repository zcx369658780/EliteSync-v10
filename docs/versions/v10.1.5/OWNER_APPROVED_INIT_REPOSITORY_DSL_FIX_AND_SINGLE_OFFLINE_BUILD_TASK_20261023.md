# EliteSync v10.1.5｜Owner批准临时Gradle Init仓库DSL修正、一次真实离线解析及条件诊断APK构建

日期：2026-10-23（Asia/Singapore）
**OWNER_APPROVED_LOCAL_INIT_REPOSITORY_DSL_FIX / BOUNDED_FIXTURE_FIRST / ONE_REAL_RESOLUTION / CONDITIONAL_ONE_DIAG_APK_BUILD / CODEX_MANUAL_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PLAN_A_RETAINED / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_AUTO_R2 / NO_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Owner授权的准确解释

Owner在Astra接受`7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`的Gradle诊断构建链源码范围、但认定唯一真实预检`INIT_GROOVY_REPOSITORY_CLOSURE_RUNTIME_BLOCKED`之后，明确表示“可以我同意，请继续”。本任务**只批准修LOCAL_ONLY临时Init Groovy仓库DSL调用与定向fixture**；fixture能以真实Gradle 8.14证明本地仓库注册和exclusive filter行为后，允许**一次**正式独立的离线依赖图预检；仅该预检真正通过并且现成工具与隔离构建门完整时，才允许**最多一次**诊断APK正向构建。

这是本版的单一长任务，不是重做Flutter升级、RTC架构、更换网络、开放任何云资源、任意依赖下载或无限试错。准许当前任务自己的**新临时本地解析脚本**在归属工作目录内小范围修正，不授予修改`apps/android/app/build.gradle.kts`、`apps/flutter_elitesync_module`业务/测试源码或工程settings/Gradle wrapper/Flutter源码的权限。上轮诊断专属内层Gradle调用修正**已经有固定source**，本轮只读复用，不再修改它。若任何新源码修改不可避免，停止并申请Owner新的授权。

**明确禁止**联网下载或升级Flutter、Dart、Gradle、AGP/Kotlin/JDK、任意AAR/POM/JAR或镜像；禁用Wrapper、`gradlew.bat`和未验本机Gradle；不得改Windows防火墙/UAC、代理/证书信任或全局Gradle/Maven/Pub缓存；不得操作手机/ADB/模拟器、安装APK、运行数据库/Laravel/guard/SFU/Room.connect、麦克风/摄像头或外部RTC端口；不得改CN/MC/JWT／≤5秒撤权冻结标准、版本计划或main产品。历史未经授权下载的`.zip.part`继续原位保留、不使用/覆盖/静默清理。**本轮授权不含任何第二设备或真实媒体验收**。

## 1. Fixed authority 与必须保留的历史

- 仓库：`zcx369658780/EliteSync-v10`。签发前live`main`：**`09f76ad8df009fbd0cad00b5cdb1abeb8aaf0206`**，该分支仍为已接受v10.1.4产品及顾问文档。Codex开工须重新只读核当前main SHA，但不得reset/rebase/pull main覆盖正在审查的v10.1.5候选。
- 唯一连续候选起点：**`7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`**，Root`3d62ff21846396a34be63b605e9b4dc3425b6f1c`；sole parent固定诊断构建链source **`5354ba679e24dbf972cea74e8fd0f60c51a2eca0`**（Root`766b43530a606a60e1e55f7f4721857c14d5a28a`，apps Tree`8011c1909444c689c45a23d4c20e1bef85694966`，services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`）。正式Gradle诊断链报告Blob **`03bca438980001908e594a9c9f48002a941be629`**、manifest Blob **`2b40f1e1d8c2c6b9ddca8b0aebf6336ebcfa4617`**；不可改写。
- Astra独立复审：`docs/versions/v10.1.5/gradle_diagnostic_build_chain_fix_independent_review.md`，固定Blob **`4283ac288b31fdbd2513cccf8f8d3223ad0a687a`**。裁决`DIAGNOSTIC_GRADLE_SOURCE_FIX_REVIEWED_WITH_OBSERVATIONS / GRADLE_INIT_RUNTIME_BLOCKED / PINNED_DEPENDENCY_GRAPH_UNVERIFIED / NO_APK`。
- Flutter **3.41.7**、Dart **3.11.5**、engine **`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**，Gradle **8.14**、AGP **8.11.1**、Kotlin项目插件 **2.2.20**；`livekit_client 2.10.0`、`flutter_webrtc 1.6.0`、`webrtc_interface 1.5.1`。不改SDK或锁文件。
- 可信完整Gradle8.14 ZIP **224,116,304 B / SHA256 `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`**，`bin/gradle.bat` **`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`**，core／launcher JAR锁定Hash继承上轮。已证直接本地`--version --offline`exit0，可复用该证据，不重做无意义启动。之前未授权`gradle-8.14-all.zip.part` **38,302,288 B / `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`**，禁用。
- 官方精确Flutter debug embedding旧同enginePOM：**2,542 B / `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`**；JAR：**1,541,793 B / `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`**，`io.flutter:flutter_embedding_debug:1.0.0-<engine>`／`packaging=jar`。全部仅本地旧原件校验复用，发行者官方SHA sidecar/签名未证，不得宣称已验。
- 上轮动态init（LOCAL_ONLY，**不是Git跟踪源码**）执行版 **3,366 B／SHA256 `bca437d1a485a81981df14e97bea478f7615193789795377d2d0a8034031b1f9`**，本地`gradle-user-home/init.d/exact-flutter-repo.gradle`；发生在line9的真实错误：`Could not find method maven() on DefaultRepositoryHandler$ExclusiveContentRepositorySpec`。`PINNED_RESOLVE_BEGIN/OK/PASS=0`，目标15个模块的`debugCompileClasspath/debugRuntimeClasspath`尚未进入`resolve()`，**不是新missing dependency**。本次禁止覆盖此错误原件，必须保留旧文件并在**新任务目录**写新候选init。
- 历史保护下界为上轮登记**1531**具名资产、**3253**工具链/cache记录（含**3184**原全局Maven文件）、**496**个旧refs、五个历史根与第一根153条Windows长路径warning；开工以真实数重新划定，不将上轮数字当完整磁盘总量。
- 冻结AC-10.1.5-05双独立APP双向真实媒体、same-call重连、旧RTC JWT首入/重入拒绝、撤权COMMIT后真实流动媒体≤5秒停止全部仍`OPEN/NOT_RUN`。v10.1.4为main已接受产品，v10.1.5未接受。

## 2. G0—G5唯一定向长任务

### G0｜只读当前真值与保护基线

1. 只在Owner本版单一干净候选工作树上核继承`7f059385...`、全部历史工作树HEAD/branch/index/status和已有dirty内容、493/494/495/496延续后的真实refs、原证、私密env、SDK/lock、global Maven/Gradle/Pub与本任务独立输出根。严禁reset/clean/stash/prune/rebase/force以及覆盖旧报告/manifest或已保留的旧临时脚本/未受权part。
2. 固定local Gradle8.14可执行本体路径、版本/Hash及新的隔离`GRADLE_USER_HOME`和含必须Gradle插件/Android构建缓存的**已准许本地副本**。完整项目SDK工具环境在上轮只用于配置，尚**未证完整debug APK编译可用**；如进入构建前仍缺有界许可的既有工具/本地复制要求，报告并停止，不擅自扩大SDK复制或新下载。
3. 精确读取旧临时init内容与line9失败上下文，记录sha及闭包接收对象、仓库白名单：只将`io.flutter`的同engine工件映射至可信本地official-maven，剩余依赖只走可信既有隔离缓存，不允许`mavenCentral()`/Google/Aliyun等触发联网。官方Gradle文档中的`exclusiveContent/forRepository`示例是**参考**，必须以**本机Gradle8.14实际Groovy执行接收对象**为准；不能只做源码词法替换即签PASS。

### G1｜LOCAL_ONLY Groovy仓库接收对象的定点修正

1. 仅在新任务本机目录复制**旧脚本的原始字节**后修正**仓库声明一处**：让`maven`确实由`RepositoryHandler`接收/创建，`ExclusiveContentRepositorySpec`仅负责`forRepository`关联和filter。允许采用Gradle8.14现场兼容的显式`repositories.maven { ... }`及已创建`MavenArtifactRepository`传给`forRepository`，或经fixture证明的另一等价形式；**不得预先宣称哪一写法正确**。保留group/exclusive过滤、官方坐标、任务仅在local temporary init声明、15模块debugCompile/debugRuntime目标、真正`Configuration.resolve()`的计数/返回字段、失败停机与本机脱敏。禁止改任何跟踪源码／项目仓库声明／插件版本或远端repo。
2. 在最小**独立的无Android/Flutter插件**Gradle8.14 Groovy fixture环境（只有同一可信本地Maven原件及空隔离缓存）验证**仓库DSL真执行**，不能只用`--help`或编译语法验证。至少验证：（a）固定repo正确注册，（b）exclusiveContent过滤只落于`io.flutter`，（c）另group不能偷从该repo解析，（d）测试中实际请求已经存在的精确POM/JAR并取得已验证SHA，（e）不触发Wrapper／外部下载。fixture可用复制进任务自有目录的简单Gradle settings/build及可控module dependency；不修改真实产品源码。测试缺字段／错误接收对象应fail-closed，而不是吞异常。
3. 如果第一个fixture提示语法/动态delegate仍有误，在**不运行正式15模块项目预检之前**允许修复**这一同类别Groovy闭包问题**并再执行**至多一次**修订后的fixture；两次fixture的原结果都保留。若仍失败或发生非白名单仓库/网络访问，立即STOP、不给正式预检预算。若fixture实际通过，固定新script SHA/bytes及仓库对象/真实Gradle版本输出，才可进入G2。**fixture成功只能说明最小仓库DSL成立，不能算本项目全部依赖图已解析。**

### G2｜正式同engine离线解析（一次）

1. 在G0/G1 PASS和项目真正离线可用的工具就绪前，不可运行本项目Gradle预检。其后使用已核`<Gradle8.14>/bin/gradle.bat`、严格隔离`GRADLE_USER_HOME`、`--offline --no-daemon`和同一任务脚本（保留精确hash）进行**最多一次**真正`resolvePinnedDebugInputs`。保持`-Ptarget-platform=android-x64,android-arm64`及前轮15模块、对应的debugCompileClasspath/debugRuntimeClasspath；不将未生成诊断AAR当外部Maven依赖。禁止`gradlew.bat`或后台下载。
2. 给出每组`PINNED_RESOLVE_BEGIN`、`..._OK`及`PASS`的直接运行回执，实际触发到15个模块/目标配置的`Configuration.resolve()`，列出现有artifact的证据等级及缺失/冲突坐标。**仅配置成功、插件编译四任务PASS、Gradle8.14启动成功均不能冒充目标dependency resolution PASS**。
3. 若真实预检exit1或未到`resolve()`，**用真实首阻断分类**：`INIT_DSL_OR_DELEGATION`、`PLUGIN_CONFIGURATION`、`MISSING_DEPENDENCY_COORDINATE`、`SDK_STAGE_INCOMPLETE`、`GRADLE_PATH_OR_CACHE_MISMATCH`等；保存原stdout/stderr/exit与确切未执行边界，**禁止在本轮修脚本后重做第二次正式项目预检**。如真实缺未缓存第三方坐标，仅报告来源/版本，不下载新依赖、不调整版本或更改缓存。

### G3｜条件一次诊断debug APK构建

1. 只有G2全部目标真实PASS、诊断专属Gradle入口/内层无Wrapper路径的已有安全门源码不变、当前本地SDK与AAR生成依赖可**无新下载**满足全部必要构建前置（能单独证明）时，才允许**最多一次**正式`:app:assembleDebug`。直接由可信本地Gradle8.14执行，不调用Wrapper；显式传`iceDiagGradleBin`／`iceDiagGradleUserHome`与本任务安全根且符合上一源码固定验证要求，Dart define严格为`ELITESYNC_ICE_DIAG_TEST_ONLY=true`、`ELITESYNC_V1015_LOCAL_BUILD=true`、`ELITESYNC_V1015_R1_LOCAL_BUILD=true`；保留`relationshipDualDeviceBuild=true`与测试debug AAR专用坐标、目标及ABI。**如果源码中固定路径和新任务根无法不改源码满足，那么G3应明确`BUILD_PATH_IDENTITY_BLOCKED`并停止，不能用软链接/伪造Hash/改受保护文件/扩大编辑范围来骗过工具门。**
2. 成功后从实际APK验证`com.elitesync.v1015icediag`、`10.1.5-ice-diag-test`、debuggable true、native+Dart诊断标志、目标lib/dev入口、真实`flutter_debug` AAR而非旧release AAR、ABI/权限、apksigner签名、SHA/bytes与原Owner手机已装R1包隔离；包/Gradle依赖二进制只LOCAL_ONLY保存。**不安装手机、不进行RTC**。
3. 失败则一次exit1保留原证并停止，不多次构建／再复制SDK/联网抓依赖以求“成功”；若G3前置不满足，应`NOT_RUN`而不是称构建失败。若从零实时编译需要的本地组件在上轮隔离环境里未被证明，先STOP并向Owner提交**最小确证缺口**。

### G4｜独立有界Review与历史保护

- 执行一次非作者静态/原证索引复核，重点核新Groovy DSL在实际Gradle8.14 fixture中可运行、没有把exclusive filter扩展为所有group、没有外域、没有抹掉旧失败、真实项目预检次数<=1、构建<=1、G3路径/SDK没有越界，以及诊断app/普通产品完全隔离。非作者不得执行本地设备、网络下载或重写任何来源。
- 终检五历史根与refs及原缓存/SQL/APK/原文档、每件登记历史原证和未经授权`.zip.part`Hash/bytes，无历史源覆盖；可用固定源码Blob Git对照确认**本轮不改apps/services任何源文件**。第一历史根长路径warning保留，不宣称全盘清单覆盖。实际文件数按本轮基线，不用旧1531冒充当前总数。
- 如果正式预检缺依赖等阻断，仍完成报告/manifest和保护回读，不自动创建下一轮或承诺后台监控；不终止全局Java/ADB/Docker/WSL，仅关闭归属本任务的Gradle进程。

### G5｜唯一交付、发布与最终STOP

仅新增两份正式文档：
- `docs/versions/v10.1.5/ICE_INIT_REPOSITORY_DSL_OFFLINE_RESOLUTION_REPORT.md`
- `docs/versions/v10.1.5/ice_init_repository_dsl_offline_resolution_manifest.json`

正式报告需区分`G1 fixture是否运行`、`G2 target resolve实际到达与否`、`G3是否真正build及APK身份`三层，不得以小fixture代替项目依赖图。逐一写出确切new init脚本Hash和测试原件Hash、`exclusiveContent`接收对象的修复证明、真实Gradle入口及所有离线参数、三处预算、退出码/首阻断、证据等级、旧失败、历史保护、来源隐私白名单、实物APK身份（若有）。

交付直接从`7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`的单一干净工作树追加**docs-only**候选，不修改Git tracked`apps/services`及之前的报告/复审；完整apps Tree应保持`8011c1909444c689c45a23d4c20e1bef85694966`、services Tree保持`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，若有差异FAIL_CLOSED。普通非force发布后做远端commit/sole parent/root及两docs Blob原字节回读、完整apps/services Tree校验。私人POM/JAR/APK/ZIP、原init、原stdout/stderr、JWT、路径、设备数据不得上传。main继续已接受v10.1.4产品，仅Astra必要状态文档可由顾问归档；Codex不改`ACTIVE_STATE`、不合main。

准确终态可能是：
- `GRADLE_INIT_DSL_FIXTURE_PASS / TARGET_RESOLUTION_PASS / DIAGNOSTIC_APK_BUILT_IDENTITY_VERIFIED / PHONE_RUNTIME_NOT_RUN`;
- `GRADLE_INIT_DSL_FIXTURE_PASS / TARGET_RESOLUTION_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED`;
- `GRADLE_INIT_DSL_FIXTURE_BLOCKED / TARGET_RESOLUTION_NOT_RUN / NO_APK`;
- `TARGET_RESOLUTION_PASS / BUILD_PRECONDITION_BLOCKED_OR_ASSEMBLE_FAILED_ONCE / NO_APK`.

统一保留 **`AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`**。

**Codex完成后立即停止；不得自行签整个v10.1.5 ACCEPTED、自动清理历史、扩大权限或发起下一任务。**
