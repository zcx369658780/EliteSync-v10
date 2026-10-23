# EliteSync v10.1.5｜Owner批准 Flutter Debug同engine架构工件＋诊断隔离构建环境补全｜唯一长任务

日期：2026-10-23（Asia/Singapore）。
**OWNER_APPROVED_PINNED_ARCH_DEBUG_AND_BUILD_ENV_COMPLETION / ONE_BOUNDED_LONG_TASK / CODEX_MANUAL_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PLAN_A_RETAINED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0｜授权和单任务成功上限

Owner在Astra正式审查前轮`294c19f296b4b872dd7da8800d1901c08d209e51`后明确表示“可以我授权，请继续”，授权本轮**一次长任务、三个既知构建阻断同时处理**：
1. 在Flutter**官方**Maven仓库只验证、必要时下载**两个已被真实Gradle错误证实缺失的精确同engine架构debug工件**；
2. 只为`ELITESYNC_ICE_DIAG_TEST_ONLY=true`有界修正已追踪`apps/android/app/build.gradle.kts`的**旧任务Root/Home硬编码路径身份**问题，保持路径归属、工具Hash、diagnostic-only安全门及正常版构建行为不变；
3. 仅从Owner本机**已经拥有、可信并可hash验证**的Flutter/Android SDK、Pub包、Gradle和Android工具复制**诊断debug编译真正必需的组件**到任务独立目录，使构建环境能够有依据地进入真正离线依赖解析及条件APK构建。

上述不是RTC产品改版，不授权反复试错。允许在指定网络获取阶段访问**唯一Flutter官方Maven根** `https://storage.googleapis.com/download.flutter.io` 的两个**精确Artifact+Version**的POM及从POM可核的发布二进制和已存在的校验sidecar；任何第三方域、镜像、不同engine、插件预取、通用`flutter precache`、整体SDK升级、Gradle分发下载和实际新第三方依赖均**不授权**。发现可信本地同坐标同Hash的现成原件则优先复用不新下载。允许HTTP请求实际数据文件，但只有正式官方精确来源、没有不明域重定向、大小与对象格式经验证才能进入隔离缓存。**不因为本任务已有抓取授权就允许Gradle在构建时联网**。二进制真实格式、Hash、官方发布可得性以本次现场证据为准，未核前`UNKNOWN`，不得发明`aar/jar`、发布者签名或版本Hash。

Owner特批只允许一处跟踪源码修改：`apps/android/app/build.gradle.kts`中的**诊断test-only路径身份逻辑**。不允许触碰Flutter/Dart RTC功能源码、Laravel/SFU/guard、普通R1、release/profile/retention产品构建语义、`pubspec.lock`、Flutter Gradle插件或`.android`生成态脚本本身。若确实需要第二个跟踪代码路径或改gradle SDK固定版本才可继续，按权限阻断停止，不能悄悄扩大。

**本轮严禁**：安装APK、手机/模拟器/ADB、启动SFU/API/Laravel/DB、创建合成call或`Room.connect`、麦克风摄像头/音频、修改USB reverse/Docker/SFU监听、防火墙/UAC、LAN/UDP/TURN、公网/真实用户；不得改CN/MC/JWT/撤权COMMIT后≤5s标准，不得合并产品main、启动R2/P2/v10.1.6。构建成功仅为**诊断工具APK身份门通过**，不是v10.1.5功能验收。

## 1｜固定Authority与已证明的三处阻断

- 仓库`zcx369658780/EliteSync-v10`。任务发布前live`main` **`0bd3471ab7e1a14293a3817b172049469d448d60`**；main仍只含接受产品v10.1.4及顾问文档，不可用main代码覆盖本版。
- **本次唯一候选起点**：前轮docs交付 **`294c19f296b4b872dd7da8800d1901c08d209e51`**，Root **`069b16e6e42c9a011804814ea31a62cc061561d4`**，唯一Parent `7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4`。固定先前Gradle诊断build源 **`5354ba679e24dbf972cea74e8fd0f60c51a2eca0`**，其`apps/android/app/build.gradle.kts` Blob **`d588562d5fce8a161c2bef8c879a2597b940010f`**。起点完整apps Tree **`8011c1909444c689c45a23d4c20e1bef85694966`**／services Tree **`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**。
- 上轮最终报告`docs/versions/v10.1.5/ICE_INIT_REPOSITORY_DSL_OFFLINE_RESOLUTION_REPORT.md` Blob **`a6261459a7dcbff49411c496101392713e74a493`**，清单`ice_init_repository_dsl_offline_resolution_manifest.json` Blob **`6956357f1ba8a6a8890dfb74ce07b5fd480d2132`**。Astra审查`ice_init_repository_dsl_offline_resolution_independent_review.md` Blob **`c61e6635c3a50dcbcebad25f1ae8e5152a81b02d`**；先前Groovy DSL和最小fixture边界已由上轮记录，**不再重做同一旧失败**。
- Flutter **3.41.7**／Dart **3.11.5**／engine **`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**；本机Gradle **8.14** ZIP 224,116,304 B SHA256 **`efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`**，可信`bin/gradle.bat` SHA256 **`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`**；JDK 17、项目AGP8.11.1、Kotlin2.2.20、LiveKit2.10.0/flutter_webrtc1.6.0/webrtc_interface1.5.1全部保持。
- 早前已获同engine官方Flutter `flutter_embedding_debug` POM packaging=jar，POM 2542B SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`、JAR 1,541,793B SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`；只是**现有字节身份**，不是发布者签名通过。本次只补另外两项。
- 上次真正`resolvePinnedDebugInputs`只到**`:flutter:debugCompileClasspath`**，BEGIN1/OK0/PASS0，离线明示缺：
  - **`io.flutter:x86_64_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**；
  - **`io.flutter:arm64_v8a_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**。
  剩余29个目标配置`NOT_RUN`，故**不能声称只有这两个工件缺失**。它们的官方可获得性、packaging/bytes/hash上轮均`UNKNOWN`，应现场核而不是猜。
- **`BUILD_PATH_IDENTITY_BLOCKED`**：固定`build.gradle.kts`的`validateIceDiagnosticGradle`绑定旧诊断任务Root/Home及旧可信Gradle位置，导致不同新隔离任务Root无法通过；原test-only bin/launcher/core hash验证、内层禁Wrapper、全部fail-closed必须继承。
- **`SDK_STAGE_INCOMPLETE`**：前轮复制的Flutter/Android副本只证明可做Gradle配置，未证明完整Dart/AAR/APK编译所需engine/gen_snapshot/dart/asset/build-tools、Pub包配置等齐备；不得仅因已启动Gradle就写SDK`READY`。
- 未经授权的原`gradle-8.14-all.zip.part` 38,302,288 B SHA256 **`f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`**，必须原位保留、不得复制使用/执行/清理。前轮本地登记**68303件具名文件**、497 old refs/五历史根/153条既有Windows长路径警告；本轮重新按真实基线保护，不伪称全面全盘。
- 冻结`AC-10.1.5-05`四硬门：**双独立APP真实双向流动媒体、same-call媒体重连、旧JWT首入及重入拒绝、撤权COMMIT后流动媒体≤5秒停止**全`OPEN/NOT_RUN`。主线仅v10.1.4已接受，方案A继续。

## 2｜唯一集中G0—G7执行

### G0 只读当前态、隔离保护和一次性执行预算

1. 从`294c19f2...`在清晰归属、干净单一工作树开展；重核Git HEAD/唯一Parent、5历史保护根HEAD/branch/index/status、old refs、dirty/untracked、既有SQL/APK/备份/private env、SDK锁、未受权part及原全局Gradle/Maven/Pub caches字节/Hash。**不reset/clean/stash/prune/rebase/force、不碰历史dirty树**；只将所需现有资产普通复制到本次任务新根并在复制前后核Hash，不用指向原缓存的可写symlink/junction。
2. 清晰建立两个互不混淆的时窗：
   - **网络获取窗**：只准检索、必要时下载**上述两个精确官方Flutter架构工件**，无Gradle/Flutter构建子进程，不运行SDK自动预取；
   - **完全离线构建窗**：网络获取窗收口并核验缓存后，Gradle8.14与Flutter构建只使用任务专属缓存及`--offline`；明确**不调用任何`gradlew.bat`/Wrapper**、不在构建阶段联网。
3. 明确预算：**本任务唯一正式项目依赖解析最多1次；唯一诊断`assembleDebug`最多1次（前置全PASS方可执行）**；为修诊断路径的静态测试/负例和独立轻量配置fixture可有限反复，但不能冒充正式依赖解析、重命名新任务偷跑。保留失败原证。非作者Review至少一次，发现高危修改则停止修正后可再作一个聚焦复核，不无限回圈。

### G1 官方精确双工件供应链验证与有限获取

1. 先检查任务隔离副本/历史可信缓存是否已存在这两**精确group/artifact/version**正式工件；如可信完整即复用，**不重复下载**。若缺失，仅允许访问`https://storage.googleapis.com/download.flutter.io`对应的以下目录：
`io/flutter/x86_64_debug/1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab/`
与
`io/flutter/arm64_v8a_debug/1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab/`。
先逐个读取官方POM确认groupId/artifactId/version/`packaging`及声明的发行二进制**真实后缀**，再按已证格式获取必要正式对象；不存在POM或版本不匹配立即STOP，不能根据网上例子臆断`.jar`/`.aar`、生成假的POM或复制`flutter.jar`冒充该坐标。
2. 工件接收须记录实际URL/域名/HTTP状态/重定向目标、bytes、Content-Type、独立SHA256、ZIP/AAR/JAR完整性/CRC、可用的官方sidecar或存储CRC32C/ETag校验与本地比对。**若无发行者签名或SHA sidecar，就诚实`PUBLISHER_SIGNATURE_NOT_VERIFIED`；本地计算Hash是字节身份不是官方签名。** 对不明源、TLS握手/代理错误、不完整下载及非白名单重定向，STOP而不是切中国镜像/全量SDK预取/改代理/关闭证书校验。不得按POM传递依赖自动下载其它包。
3. 下载字节仅存**当前任务专属`official-maven`只读完成目录**，Gradle离线解析时以原Maven布局读取；禁止覆盖原官方embedding、旧trust cache或现有普通R1 AAR repo。若有一个工件不可核或官方不可得，本任务可交`PINNED_OFFICIAL_ARTIFACT_BLOCKED`，无需冒险继续。
4. 外网仅用于这一获取阶段；`MavenCentral`、JitPack、Aliyun、Gradle下载URL、Flutter SDK下载器、GitHub Release及任何其它仓库下载都不在本任务许可。GitHub对受控**任务单/回执的备份读写**仍属原工作流，不授权工具链借GitHub获取二进制。

### G2 诊断only构建路径解耦（唯一被批准的跟踪源码点）

1. 唯一允许的源文件变更`apps/android/app/build.gradle.kts`。审阅旧`validateIceDiagnosticGradle`及`iceDiagGradleBin / iceDiagGradleUserHome`与任务根、`syncFlutterAar`内层执行。目标是**不改正常构建链、不弱化认证，只消除与旧20261023任务目录绝对路径的硬绑定**。
2. 允许新增诊断专属`Gradle Property`用于**明确且可验证的当前TaskRoot与TrustedDistributionRoot**（命名由Codex在定向测试冻结），必须强制这些路径为Windows绝对、canonical、当前任务**独立批准目录的子路径**，与project/apps/android、module .android、Gradle user home、bin/CLI/core JAR **一致且都有精确SHA/Gradle8.14校验**；属性缺失、与任务Root不一致、指向历史受保护目录、Wrapper或其它未知路径必须FAIL_CLOSED。不得把路径校验改成仅`file.exists`，不得允许任意`C:\`/用户home通配路径、任意Gradle版本或旧保护root当可写当前任务根，亦不得以junction/symlink、伪造Hash/元数据欺骗身份。
3. 条件`isIceDiagnosticBuild`且三项既有debug/local/R1标志仍需成立。内层`syncFlutterAar`应继续使用**已核Trusted Gradle8.14 bin**（不碰内层Wrapper）、同一隔离`GRADLE_USER_HOME`及`--offline --no-daemon`，保持原Flutter`aar_init_script.gradle`、`target=lib/dev/v1015_ice_diag.dart`、`dart-defines`、`assembleAarDebug`、两ABI、AAR版本digest、repo相对输出、`preBuild`/Flutter模块顺序。
4. 非诊断标志下**普通R1、历史release/profile、retention以及其它各版本的原构建路径与参数语义不得变化**，也不可扩大diagnostic flag到非debug/正式入口。缺属性/错目录/错误Hash/禁用flag/release/profile混标志的明确负例必须拒绝，非diagnostic成功配置不应要求新property。若无法满足这些负例，停止且不运行正式依赖解析或APK构建。
5. 源码最多改这一个既有文件及如确需的狭小**测试fixture**；不能改SDK版本/锁、Flutter内部`.android`生成脚本/插件源码和业务RTC。变更前后的Git Blob、source diff/行数、隔离Hash记录，准许独立`source`候选审查后继续同一综合任务，**不要自动入main**。

### G3 隔离SDK/APK构建完整性预审（优先证明现有资产可用）

1. **只读列出**此Flutter3.41.7/engine构建debug AAR与宿主APK所需现成组件：Flutter bin`flutter.bat`、cache/artifacts、Dart SDK/compiler、目标debug engine/artifacts、`pubspec.lock`与`.dart_tool/package_config.json`所引用本地Pub包、Flutter Gradle插件、Android SDK平台36、build-tools/ndk/java/apksigner及宿主/module generated Android project的已存在版本。将`PRESENT_AND_HASH_VERIFIED / LOCAL_SOURCE_EXISTS_NOT_STAGED / MISSING / VERSION_MISMATCH`逐项记录；**不存在不可用时不要凭配置期Gradle成功宣布`SDK_BUILD_READY`**。
2. Owner批准将**确实需要且本机已存在、可信版本相同**的Flutter/Android/Dart SDK与Pub本地组件选择性普通复制到本任务独立`SDK_STAGE`目录，并核bytes/sha、非符号链接指向原受保护写路径、读写归属、构建输出不得落入历史缓存；仅当前任务副本可变。禁止运行会自行下载的`flutter precache`、`flutter pub get`（如会修改下载依赖/锁）或SDK自动安装来“补全”。若发现缺失必需源码/产物、路径固定涉及第二个跟踪文件或只能经公网下载，`SDK_STAGE_INCOMPLETE`并停止申请Owner，而不是扩大。
3. 针对测试debug模式的`project Root / task Root / GRADLE_USER_HOME / Flutter home`的多级路径身份在G2改后做**静态+真实无依赖/轻量fixture**的预检，核项目build outputs在本任务独立目录、普通R1旧APKs/repo不会覆写。记录真实与期待差异；任何未认证的新增Android本机工具/许可提示不得假定已有Owner授权。

### G4 定向测试/非作者Review → 唯一离线依赖解析

1. 在第一次正式解析之前完成：新Gradle路径属性的正/负fixture、旧31项构建Guard中影响范围的回归、至少6项普通路径隔离对照、Groovy init脚本前轮8/8事实复用（**无需再次重复**）、SDK_STAGE完整性Hash清单，以及一次非作者只读审查源diff/权限边界、两个官方工件字节/来源、全部预条件。避免把fixture的“成功注册仓库”当30配置完整解析。
2. 若G0-G3与Review无P1阻断且官方两个工件可信进入独立Maven目录，才准**最多一次**真正的项目离线`resolvePinnedDebugInputs`，复用上轮通过的LOCAL_ONLY Groovy init语义（已核SHA `5dad6fe912efab85e20b8c1fe2d0b3b81c3984dc68a1ef6704496a94288fa43b`，仅在新Root必要的路径重绑定变化时记录实际新Hash）、15模块×debugCompile/debugRuntime共30配置、`target-platform=android-x64,android-arm64`；直接使用经核Gradle8.14 `bin/gradle.bat --offline --no-daemon`和新隔离cache。对所有`PINNED_RESOLVE_BEGIN/OK/PASS`有原stdout与退出码。该任务如仅部分配置PASS或首失败，准确列真缺失dependency的group/artifact/version、是否当前两个工件已通过，以及未启动配置，STOP，不自动获取新依赖或再运行一次。
3. 任何`--offline`不等于绝对网络证明，Gradle或其它SDK工具若试图联系不授权域应立即按归属停止并报告；禁止外/内`gradlew.bat`、未知子进程/独立输出目录外副作用。旧保留`.zip.part`绝不能进入classpath、解压或删除。

### G5 条件最多一次正向诊断APK构建

1. 仅当G4**所有目标配置实际PASS**、G2真实build identity和G3`SDK_BUILD_READY`全PASS，才允许**一次**宿主`:app:assembleDebug`，继续指定三个确定的Dart flags`ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true`（安全引用单一参数）、`relationshipDualDeviceBuild=true`、新验证的Gradle taskRoot/home/bin properties及现成Flutter SDK路径；外层与Flutter module内层均由可信Gradle8.14直接执行并使用同一隔离cache，`--offline`、不调用Wrapper，不用release AAR代替debug AAR。**最多一次正向build；失败即STOP保存首失败，不循环重试或自动扩大下载/路径权限。**
2. 如果产生APK，必须用实际二进制而非源码标注核验：`com.elitesync.v1015icediag`、`10.1.5-ice-diag-test`、debuggable true、native/Flutter两层诊断身份、实际`flutter_debug` AAR和独立版本digest、ABI`arm64-v8a`与`x86_64`、应用权限、签名证书/sha256/bytes/与原Owner设备旧R1包不覆盖、不会采音/摄像头。查看包中诊断入口/必要字段，避免仅凭`strings` absence/presence就宣称形式证明。
3. **不安装APK、不连接手机**。可以只把APK包与所有Maven二进制保存在本任务LOCAL_ONLY。成功上限`DIAG_DEBUG_APK_BUILT_AND_IDENTITY_VERIFIED`，不是实际ICE candidate pair/STUN/DTLS已获得或RTC双端媒体验收。

### G6 实时停止、验收层级和保护

- G1出现官方版本不存在或不可信→`PINNED_ARCH_ARTIFACT_NOT_VERIFIED`，G2 path/隔离fail→`DIAGNOSTIC_PATH_GUARD_BLOCKED`，G3必需工具缺失→`SDK_STAGE_INCOMPLETE`，G4缺新依赖或实际resolve失败→`TARGET_RESOLUTION_BLOCKED_EXACT_REASON`，G5 build exit1→`DIAG_ASSEMBLE_FAILED_ONCE`。各自按原证**停止后续动作**，不把阻断重新包装成“另起项目”或“不影响功能的PASS”。
- 运行结束仅结束本任务实际启动的Gradle/Flutter临时进程，不停止全局Gradle/ADB/Docker/WSL/JDK或其他用户任务。保存所有历史固定失败、此前153条长路径warning以及新日志、未授权`.part`、旧SQL/APK/备份/volumes。按真实保护基线逐Hash旧具名文件及refs/heads/index/status、原全局Maven/Pub/SDK、私密配置和本任务需要保护的新结果；实际覆盖范围如实写，不冒称全盘/手机/运行库没有变化。
- 非作者Review只对指定源码/正式结果作有界检查，不自行签整个产品ACCEPTED。顾问Astra本轮未操作本地构建、机器或SDK，未来审核报告只依据Git直接源与本地Codex证据等级分层。

### G7 双层固定Git交付与唯一终态

- 若G2真正改了唯一受权的`apps/android/app/build.gradle.kts`，先有一个相对`294c19f296b4b872dd7da8800d1901c08d209e51` sole parent的**源码候选**，源码changed paths**仅**该一文件，Flutter业务/整services Tree不变，apps相应唯一改动。其后再有sole parent为源码候选的docs交付。若G2无源码变更，直接自唯一起点新docs-only候选，不虚构source commit。
- 仅新增以下两份正式文档，不覆盖旧报告/manifest或旧Astra复审：
  - `docs/versions/v10.1.5/FLUTTER_PINNED_ARCH_DEBUG_BUILD_ENV_COMPLETION_REPORT.md`
  - `docs/versions/v10.1.5/flutter_pinned_arch_debug_build_env_completion_manifest.json`
- 报告逐门列G0-G5真实执行记录、两个官方工件metadata与SHA和官方Hash限制、build guard路径身份的源码唯一diff/负例、SDK_STAGE组件真正READY/MISSING、30目标逐项resolve状态、唯一APK尝试预算/产物hash签名、普通构建路径隔离、非作者Review、历史保护限制、未授权旧part/所有先前失败完整保留。源和文档Blob、唯一Parent/Root、完整apps/services Tree做普通nonforce GitHub发布后readback；**不得上传APK、JAR/AAR、POM、密钥、绝对个人机器路径或raw设备日志**。保留main为v10.1.4接受产品，不在本轮合main／发release。
- 终态仅可真实选择：
  - `PINNED_ARCH_OFFICIAL_ARTIFACTS_VERIFIED / DIAGNOSTIC_BUILD_PATH_GUARD_PASS / SDK_BUILD_READY / TARGET_RESOLUTION_PASS / DIAG_APK_BUILT_IDENTITY_VERIFIED`；
  - `PINNED_ARCH_SUPPLY_OR_GUARD_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED`；
  - `SDK_STAGE_OR_DIAGNOSTIC_PATH_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED`；
  - `TARGET_RESOLUTION_BLOCKED_EXACT_MISSING_COORDINATE / NO_APK / OWNER_DECISION_REQUIRED`；
  - `ASSEMBLE_DEBUG_FAILED_ONCE / NO_APK / OWNER_DECISION_REQUIRED`。
无论何种，**`AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PHONE_RUNTIME_NOT_RUN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`**。
- Codex必须在本任务交付后立即停止；不可自主宣布v10.1.5接受或开启下一手机ICE实验。
