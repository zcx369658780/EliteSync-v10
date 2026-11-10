# EliteSync v10.1.5｜Owner批准的Gradle诊断专属构建链修正与离线APK验证｜唯一综合长任务

日期：2026-10-23（Asia/Singapore）。
**OWNER_APPROVED_DIAGNOSTIC_GRADLE_ORCHESTRATION_FIX / SINGLE_LONG_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_PENDING / RUNTIME_NOT_STARTED / PLAN_A_RETAINED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / NO_R2 / V10.1.6_NOT_STARTED**

## 一、授权、目标和严格不变边界

Owner在Astra完成`gradle814_local_offline_bootstrap_independent_review.md`复审后明确指示：**“可以我同意，请先修正gradle问题”**。此处授权一次完整、有界的**本地Gradle构建编排修正**，同时解决**（A）可信的临时动态Gradle依赖解析入口没有得到上一任务的执行授权**和**（B）外层使用可信Gradle8.14时，`syncFlutterAar`的`Exec`仍会调用内层`gradlew.bat`**两处已证障碍。允许Codex在单一连续任务内按下面门禁审查已有临时init脚本、修订本版本**诊断专属**的最小构建脚本、运行定向负例与离线依赖预检，在这些门全通过后**最多一次**正向诊断`assembleDebug`，以得到实际debug APK或准确的缺项/故障证据。

**授权仅限测试专属构建编排，不是修改产品RTC逻辑、改变安全合同、添加SDK或升级依赖。** 不允许更改`rtc_livekit_service.dart`、`rtc_ice_diagnostic.dart`、业务后端、普通R1/release/profile主链的构建语义、任何安全阈值、`flutter.version`/`engine.version`/`pubspec.lock`、项目Kotlin/AGP/Gradle版本。保留原debug隔离包名、三项Dart flag、AAR debug target、AAR版本digest、Dart target、ABI与构建参数。若确需超出**仅诊断build**的修改方能成功，明确阻断并再交Owner，不自动拓展授权。

**禁止所有新下载及外网依赖解析**：不请求`services.gradle.org`、`storage.googleapis.com`、`mavenCentral`、Google Maven、Aliyun或其它域（哪怕原source包含仓库声明）；不重下官方工件；不运行`gradlew.bat`或内层Wrapper；不安装/升级Flutter、Gradle、AGP/Kotlin/JDK/SDK、新工具；不修改受保护的全球Gradle/Maven/Pub缓存、原始ZIP/Flutter engine或Gradle Wrapper。现存完整ZIP/JAR/POM/私有原证仅复用经核实的副本。

**不得操作手机/ADB/模拟器、安装APK、启动Laravel/guard/SFU/DB或`Room.connect`、麦克风/摄像头、任何网络监听/防火墙/LAN/UDP/TURN、公网/账号/真实用户。** 构建成功不等于ICE成功，不签AC05任何硬门。GitHub仅文档和必要的狭小构建源变更，APK/POM/JAR、原始日志和密钥仅LOCAL_ONLY。

## 二、需先重验的固定Authority与本地证据

- GitHub `zcx369658780/EliteSync-v10`；本任务发布前`main` = **`14bb4902802e141c9ab4cb522c506b0f2c6b8e1d`**，主线只包含已接受v10.1.4产品与顾问治理文档。开工重新只读核main，不得用main重置当前候选代码。
- 唯一新任务源码起点：上轮正式交付 **`76a7542d9c9121051b55251fda198e568a8d0aa5`**，Root `8f313834c39075d0f56d89639fac787c8e3aa034`，唯一Parent `73b3b753225f99824081d312a25a7deb170c62d3`；上一轮报告 `docs/versions/v10.1.5/GRADLE814_LOCAL_OFFLINE_BOOTSTRAP_REPORT.md` Blob `cdbd97a2e66bfa03d5db8f001c7f862396266795`；manifest Blob `16fce32045039f336ee5d224f1d4714604b41d29`。
- Astra该轮独立复审 `docs/versions/v10.1.5/gradle814_local_offline_bootstrap_independent_review.md` Blob **`7e379354cc4f31074597a431941f233d804f2085`**，认定 `GRADLE814_LOCAL_BOOTSTRAP_PASS / RESOLUTION_VERIFICATION_TOOLING_BLOCKED / NO_APK / AC05_OPEN`。本次**新授予**定点修正权限，替代上一任务关于“动态init工具必须STOP、不能改diagnostic内层Exec”的限制；旧负例和执行回执仍原样封存。
- 已审ICE诊断应用源码Commit **`24ddf05875d8d4abad7a6b473f882698c9885c2a`**，完整apps Tree `72c617cf86d5c653dd722accde340b51d2e085eb`、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。旧Gradle `apps/android/app/build.gradle.kts` Blob **`5a08d63f5f95155ca1f346f9809683f6f35ac7e0`**；其`preBuild→syncFlutterAar`在R1诊断分支通过`Exec`调用`apps/flutter_elitesync_module/.android/gradlew.bat`，参数包括SDK既有`aar_init_script.gradle`、`-Ptarget=lib/dev/v1015_ice_diag.dart`、`-Pdart-defines`、`assembleAarDebug --offline`。
- Gradle **8.14**完整可信ZIP **224,116,304 B** SHA256 `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`；上轮本机复制与22,425文件核对、直接`<trusted Gradle>/bin/gradle.bat --version --offline` exit0为Codex LOCAL_ONLY回执。Gradle启动入口`bin/gradle.bat` SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。不得将启动exit0冒充Gradle项目解析PASS。
- Flutter **3.41.7**／Dart **3.11.5**／engine **`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**；锁定`livekit_client 2.10.0`、`flutter_webrtc 1.6.0`、`webrtc_interface 1.5.1`；同engine官方Flutter embedding `io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`已于前前轮本机下载校验（POM packaging=jar）：
  - POM **2,542 B** SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`;
  - JAR **1,541,793 B** SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`.
  本轮不得重新联网，发布者签名/官方SHA sidecar仍`NOT_VERIFIED`。
- 未授权Wrapper残留`gradle-8.14-all.zip.part` **38,302,288 B** SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`：**只记录、保留与隔离，禁止解压/执行/作为可信依赖**；先前发生授权边界事件的事实永不擦除。
- 旧保护最低已登记：**1,483**具名原证、原全局Maven缓存**3,184**项、工具链/env/lock/cache**3,193**记录、五历史根、495原refs及153条Windows长路径警告；本轮以真实新快照确定数量，不承诺覆盖未登记目录。
- 冻结AC-10.1.5-05四硬门全OPEN：双独立APP双向流动媒体、same-call真实媒体重连、旧RTC JWT首入与重入拒绝、撤权COMMIT后流动媒体停止≤5秒。Owner方案A保持，v10.1.4才是main接受产品。

## 三、唯一集中执行G0—G6

### G0：隔离、保护及现成Gradle真值（先于任何源码改动和启动）

1. 仅在清晰归属的**单一干净本版隔离worktree**从`76a7542d...`连续开展；冻结主线、旧P1/诊断源、全部历史dirty/untracked工作树不动，不运行`reset/clean/stash/prune/force`。记录Head/tree/index/status/refs/私密env、全部已登记历史原件字节Hash、SDK/engine/lock/原全局Gradle与Maven缓存前快照。保护范围与长路径warning应如实分层。
2. 同上轮Gradle8.14可信分发副本、官方固定POM/JAR和旧`.zip.part`做精确SHA核对；后者**不能**进入任何classpath/repository/path/依赖解析。若可信Gradle8.14分发不存在或身份不符，`LOCAL_GRADLE_IDENTITY_BLOCKED`立即停，不自动下载。已证的`--version`可直接复用旧固定回执，除确实必要外不重复仪式性启动。
3. 审查两个Gradle工程的**真实根与版本一致性**：宿主`apps/android`与Flutter模块本地生成的`apps/flutter_elitesync_module/.android`是否为不同Gradle root；`.android`可能是生成态、并非Git跟踪来源，因此开工只能按本机可读固定当前快照核准，不得假定GitHub存在其`settings.gradle`；如内层工程Gradle/AGP/Flutter插件与本任务可信Gradle8.14不兼容，写出原证并STOP，不升级版本掩盖。
4. 保证项目与脚本在此任务独立目录执行，构建若必须生成临时Flutter AAR输出仍要证明不覆盖已存在受保护的缓存、包、SQL或旧fixture；**不允许用指定的旧cache路径覆盖未核身份产物**。不准修改被保护的普通用户Flutter、Pub、Maven全局缓存。

### G1：修正动态解析入口的授权工具门（先静态验证）

1. **Owner已明确授权使用经审查的临时、LOCAL_ONLY、只读的`resolvePinnedDebugInputs`动态init**，无需把任务本身加入生产Gradle源码。先静态读取脚本、计算bytes/SHA，确认其只做`rootProject.tasks.register`与预期**确切配置/依赖集合的解析**，无`afterEvaluate`未授权写操作、外网回调、下载/版本fallback、广域删除/复制、改变正式插件仓库解析或转移产物。可在本任务自有目录做最小安全修订，但审计版hash与修订前后字节必须记录。脚本必须**明确证明实际触发`resolve()`或相当的依赖图解析**，不能仅注册任务/运行`--help`就计PASS。
2. 注意固定`apps/android/app/build.gradle.kts`对`ELITESYNC_ICE_DIAG_TEST_ONLY=true`有“所请求Gradle任务名称只允许debug”的产品门禁；不能用任意`resolvePinnedDebugInputs`任务名配diag flag后再删除安全校验。若解析宿主Android工程，需要设计只在此诊断任务特定、严格本地的预检入口进行**无产品逻辑更动**的合法任务命名/执行（例如`resolvePinnedDebugInputs`的严格debug专用版本），或者先在Flutter模块工程对其真实debug依赖解析；从头证明不是绕过build guard。**如果实现该点必须改超出下文G2测试专属脚本的其它产品代码，先STOP并报告。**
3. POM`packaging=jar`，必须按真实POM/JAR解析，不伪造AAR。不假定Flutter module debug依赖和Android宿主debug AAR发布是一个任务：先明确**内层Flutter AAR依赖→生成诊断debug AAR→宿主debug变体依赖**顺序；未构建的诊断AAR可能导致宿主`debugRuntimeClasspath`报未找到本任务尚未产出的artifact，这不能直接伪装为远端缺项。
4. 仅在G0可信Gradle可用、脚本定点验收和test-only构建策略设计通过后，才准进行**一次有界、真正离线的依赖解析**；若发现可信cache未覆盖的**具体真实** Maven坐标，标`MISSING_DEPENDENCY_<group/artifact/version>`并STOP，**不允许新下载**。如果解析任务仍不能在原产品安全门内合法运行，报`RESOLUTION_TOOLING_NOT_SAFE`，不贸然运行。

### G2：唯一诊断专属内层Wrapper改造（仅最小可审核源码）

1. **Owner特批可修改一处必要的跟踪构建源码：`apps/android/app/build.gradle.kts`**，仅在`isIceDiagnosticBuild && isV1015R1LocalBuild`为true时，让`syncFlutterAar`的`Exec`使用一个已被G0核实的**本地Gradle8.14 bin/gradle.bat绝对路径**。由**本任务专属明确Gradle property**输入该路径（名字和契约Codex可定点命名），在Gradle配置期执行存在/路径归属/确切Hash（若需要使用配置缓存则选择安全可重复的校验机制）和与已固定可信分发位置的一致性校验。**缺property、错误Hash、路径为Wrapper、系统Gradle/非Owner已验分发、非Windows/不兼容的情形应FAIL_CLOSED**，绝不静默回退内层`gradlew.bat`。
2. 非诊断模式下（普通R1、其他版本、release/profile、旧retention probe）**原有Exec调用、Dart defines、目标、输出位置和原有构建安全门保持不变**。不改变`target=lib/dev/v1015_ice_diag.dart`、`assembleAarDebug`、`aar_init_script.gradle`、`buildNumber`与r1Digest、`dart-defines`、arch、AAR coordinates和`preBuild`依赖；不要删除Flutter AAR预构建任务或改用release AAR来凑诊断包。
3. 为内层Gradle进程显式传递**同一个已核GRADLE_USER_HOME/会话内环境**和`--offline`，不要让嵌套构建在临时进程丢失隔离缓存后再次触发不受控Wrapper/网络。若需要改变**诊断专属**输出位置，只能在本任务干净worktree中记录原与新AAR仓库解析相符并写定点测试，不修改普通产品缓存坐标或旧产物。避免父Gradle持有不受控锁，必要时报告适配而非无限重试。
4. 不批准更改`.android`生成工具链中的Wrapper文件、不批准修改全局SDK Gradle脚本或Flutter插件；不批准在任何分支禁用授权gateway/诊断包test-only标记。**诊断模式工具路径修改是被接受的范围，普通产品行为改变不是**。

### G3：定向测试、保护负例与非作者代码审查（先于真实解析／构建）

- 对新构建property进行可离线验证的负例：诊断模式无属性、错误Gradle版本/Hash、Wrapper别名/未授权位置、非法Dart define组合、Release/Profile和混合v10.1.4/v10.1.2、普通R1/旧retention未提供property仍走旧原始路径、禁用test-only不会访问新可信Gradle路径。要有明确`GUARD_REJECTED`结果，不能把“任何构建exit1”当负例通过。
- 核源diff必须**仅涉及上面单个构建编排文件**（及确有必要的狭小测试脚本/fixture），绝不触碰任何RTC业务逻辑或旧独立诊断器源码。检查真实跨版本兼容性、无缓存混用、所有失败可回滚以及`gradlew`仅普通路径存在。借助已有本机测试工具跑最少构建脚本/配置负例与普通路径预检，20诊断单测＋93相关回归在**代码没有触及Flutter内容**时可直接引用前轮固定PASS回执，但不说“本轮重新跑了113项”。
- 先完成一次**非作者有界代码／权限边界静态复核**，若存在P1安全门或构建产物污染风险，在**构建前**修复狭小诊断代码并复测；必要时再做一次针对修复点的非作者静态复核（仅在发现实质阻断时，禁止无限审查）; 不能让正向构建成为第一次发现安全门不合格的实验。

### G4：真正的离线解析与最多一次诊断APK正向构建

1. 所有以上静态／隔离门通过，允许**一次**真正触发依赖图的Gradle任务预检，使用**已核本地Gradle8.14 bin/gradle.bat**、`--offline --no-daemon`、隔离`GRADLE_USER_HOME`及经审查的动态init/明确任务入口。不得调用任何Wrapper（包括内层），不得新下载。对SDK engine及Flutter embedding POM/JAR再次核坐标和SHA；把插件/模块/宿主外部依赖与**尚未构建的内部诊断AAR**分层显示。**只成功配置项目或gradle --version，不是dependency resolution PASS**。
2. 若解析真实PASS且诊断编排路径已在定向负例中经证实，再执行**最多一次**正式`:app:assembleDebug`正向构建，确保Dart编译定义只有：`ELITESYNC_ICE_DIAG_TEST_ONLY=true`、`ELITESYNC_V1015_LOCAL_BUILD=true`、`ELITESYNC_V1015_R1_LOCAL_BUILD=true`；保留原`-PrelationshipDualDeviceBuild=true`及新的严格诊断Gradle路径property（所有定义作为精确安全引用参数传入）。外层与`syncFlutterAar`内层**都使用本机已核Gradle8.14二进制**，在本任务专属目录及可信隔离缓存内执行，不得有Wrapper。
3. 如果真实构建失败，保存exit/code、时间、原stdout/stderr和明确首个阻断（依赖缺失、Flutter module构建版本不兼容、缓存布局、test entry/AAR坐标、其他），**不重复同样的assembleDebug，不循环重试/换源/改SDK或放宽flag**。第一次build失败也不能推定ICE产品缺陷。
4. 如APK真实产生，核包名`com.elitesync.v1015icediag`、版本`10.1.5-ice-diag-test`、debuggable、native+Dart gate、预期Flutter诊断入口、真实AAR debug变体而非普通release、APK ABI、包签名/cert/SHA256/bytes、权限且不会覆盖原`com.elitesync.v1015r1dev`。**不安装APK、不触碰手机、不宣布RTC已通**；build产物与依赖二进制仅LOCAL_ONLY留存。
5. 任何检测到Wrapper试图下载、不明执行路径、非授权主机网络、SDK版本漂移、修改业务配置或原缓存/旧产物，都**立即停并如实记越界回执**，不再尝试下一方案。

### G5：保护、发布和验收层级

- 先记录**源码候选Commit**（有定点改动时）相对唯一起点`76a7542d...`的唯一Parent/Root/changed paths，完整apps/services Tree；特别注明services未变、Flutter诊断源码未变，而apps中仅授权构建脚本或狭小测试变化。再新增文档交付Commit，文档Commit唯一Parent须为这个固定源码Commit。若因无法安全实施而无源码改动，则直接做docs-only交付，不伪造源码候选。
- 仅允许新增两份正式交付文档：`docs/versions/v10.1.5/GRADLE_DIAGNOSTIC_BUILD_CHAIN_FIX_REPORT.md` 和 `docs/versions/v10.1.5/gradle_diagnostic_build_chain_fix_manifest.json`。包含G0～G4全过程真实通过／失败／NOT_RUN、官方既有依赖校验、动态解析脚本Hash、内层Gradle路径与版本/Hash、debug非debug隔离负例、正向APK产物身份（如有）、历史原失败保护、三种路径是否引入新下载／网络、非作者审查、保护前后准确数量与范围、正确日志过滤白名单。
- 保留原五历史根/old refs/dirty文件、原全局缓存、SQLite/MariaDB卷、旧SQL/APK/备份、Owner手机所有数据、未经授权旧part原样不清理；仅本任务临时资源在归属明确后停止，不停止全局Gradle/ADB/Docker/WSL。GitHub普通非force候选发布后远端固定readback：Commit/Parent/Root、源码changed paths/Blob、docs blobs、完整apps/services Tree；不会把APK/JAR/POM、私密日志和本机绝对路径传GitHub。
- 本次目标至多`DIAGNOSTIC_GRADLE_CHAIN_FIXED_AND_DIAG_APK_BUILT`；它只是诊断工具阶段，不是v10.1.5功能验收。AC05四媒体硬门仍OPEN/NOT_RUN、v10.1.4继续唯一main已接受产品；不自行合产品main、不启动R2/P2、v10.1.6、不重开通话/旧JWT媒体验收。

### G6：终态、停止

只按真实结果从以下选择：
- `V10.1.5_GRADLE_DIAGNOSTIC_CHAIN_FIXED / OFFLINE_RESOLUTION_PASS / DIAG_APK_BUILT_IDENTITY_VERIFIED / PHONE_RUNTIME_NOT_RUN / AC05_OPEN`；
- `V10.1.5_GRADLE_CHAIN_SOURCE_FIXED / DEPENDENCY_RESOLUTION_BLOCKED_EXACT_COORDINATE / NO_APK / OWNER_DECISION_REQUIRED`；
- `V10.1.5_BUILD_CHAIN_OR_GUARD_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED`；
- `V10.1.5_DIAG_APK_ASSEMBLE_FAILED_ONCE / NO_APK / OWNER_DECISION_REQUIRED`；
- `SOURCE_OR_CACHE_IDENTITY_MISMATCH / STOPPED`。

无论终态，一律`AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

**任务结束立即停止，等待Owner交付候选供Astra复审。不得自行下载新依赖、重试构建、安装APK、操作RTC设备或清理历史。**
