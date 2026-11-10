# EliteSync v10.1.5｜Owner批准Gradle 8.14可信本地离线引导与诊断APK构建门｜Codex唯一综合长任务

日期：2026-10-22（Asia/Singapore）。
**OWNER_APPROVED_GRADLE814_LOCAL_ONLY_BOOTSTRAP / PINNED_EMBEDDING_REUSE / BUILD_ONLY / MANUAL_CODEX_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PLAN_A_RETAINED / SOURCE_UNCHANGED_TARGET / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_INTEGRATION / NO_R2 / V10.1.6_NOT_STARTED**。

## 一、唯一目标与准确授权

Owner在Astra对上轮`73b3b753225f99824081d312a25a7deb170c62d3`受阻候选独立复审后，明确同意继续上一结论提出的**最小本地执行**：先验证已经拥有且可核实的可信Gradle **8.14**分发能在本任务隔离目录**完全离线启动**；再用现有官方同Flutter engine的POM/JAR及可信已缓存依赖完成一次有限的Gradle依赖解析；若依赖就绪，**最多一次**诊断`assembleDebug`正向构建与APK身份证据。

**这不是第二轮随意尝试或网络许可扩大。** 本轮**禁止一切新依赖下载**，特别是`services.gradle.org`及其重定向目标、Google Maven、Maven Central、第三方镜像、代理变更。只允许读取/复制**先前已核的本地工件及其SHA**，在隔离的、普通本地路径生成私有Gradle构建缓存与输出。本轮的“本地离线”包含：不能只依赖`--offline`承诺；必须让**Gradle启动前的Wrapper**不会自行触发联网。为避免复发，**本任务不要调用`gradlew.bat`，无论是否携带`--offline`；只能在通过可信分发完整性门后调用其中实际可执行的`bin/gradle.bat`，并保持`--offline`与隔离`GRADLE_USER_HOME`**。如该方案行不通，就报STOP，不切回Wrapper或改发行版。

不授权下载/升级Flutter、Gradle、AGP、Kotlin、JDK/SDK、pubspec锁定包、SDK镜像或其它外部工件；不授权修改源代码/构建脚本/gradle-wrapper.properties/全局Gradle缓存、环境信任设置、Windows防火墙/UAC、LAN/UDP/TURN、Docker/SFU/RTC监听、业务功能、安全规则/5秒撤权。**不操作手机、ADB、API、数据库、服务、麦克风、RTC合成call、Room.connect、模拟器。** 不能把APK构建或缺依赖归结成ICE根因。

## 二、冻结真实身份与失败历史

- 仓库`zcx369658780/EliteSync-v10`；签发前live`main` = `1eb92deb4247e98083c2a8c18c393ab4df3455f9`，仍为唯一已接受产品v10.1.4与顾问文档；每次开工重新GET，不准从main覆盖本版候选。
- 唯一连续起点：上轮发布受阻交付`73b3b753225f99824081d312a25a7deb170c62d3`，Root `6c45db667bb7a11234a72600c41f04b9432328b6`，唯一Parent`8bee827c20c26c4ec954b774c011f09238ec59b3`。源代码固定`24ddf05875d8d4abad7a6b473f882698c9885c2a`，Root`2c656957e1c229ca30f7c07b173bcb1062310d2c`，完整apps`72c617cf86d5c653dd722accde340b51d2e085eb`、services`1e1e20bb3500bedb1a521e5f2ddeece915d09424`；本轮全部不得更改。
- 上轮原报告`docs/versions/v10.1.5/ICE_DEBUG_EMBEDDING_DEPENDENCY_UNBLOCK_REPORT.md` Blob `ba2212be8342dc0e6354a70bab4a64c456e2a716`；manifest Blob `646840354b93dab3ed617e43aac89af469fa9fa5`。
- Astra独立复审`docs/versions/v10.1.5/ice_debug_embedding_dependency_independent_review.md` Git Blob **`6f7f200da8595d52f9da21ee39cd56d7b1164c27`**；认定上轮**官方同版本工件有本地回执，Wrapper越界下载事件发生，正向build 0次、APK缺、v10.1.5仍PARTIAL/AC05 OPEN**。
- Flutter`3.41.7`，Dart`3.11.5`，Flutter engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`；Gradle`8.14`、AGP`8.11.1`、Kotlin`2.2.20`；`livekit_client`2.10.0、`flutter_webrtc`1.6.0、`webrtc_interface`1.5.1。开工必须按**本地版本文件与锁**重读确认，出现差异停止。
- 上轮现有官方同engine`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`：POM(`packaging=jar`)2542 B，SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`；JAR1,541,793 B，SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`。来自官方`https://storage.googleapis.com/download.flutter.io`的证明为**Codex LOCAL_ONLY回执**，CRC32C/ETag本地对照、两SHA sidecar404，不得冒称有发布者签名。新一轮只用同名同Hash存量文件；**禁止再次网络抓取**。
- 上轮可信本地Gradle8.14完整分发ZIP快照224,116,304 B、SHA256 `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`，报告称与原有分发缓存一致；但**尚未证成隔离目录内正确解压及命令可用**，本轮必须实查。上次未经授权下载留下`gradle-8.14-all.zip.part` 38,302,288 B／SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`，绝不可作为可信输入/执行或静默删除；只隔离识别/持久保留其hash与失误史。不得把完整旧ZIP与新受权外的part混用。
- 上轮正式manifest记录原全局依赖缓存 **3184件**、SDK/env/lock/cache受保护记录 **3190件**、1441份具名历史原证、494原refs、5保护根，以及第一根153行Windows长路径warning；本轮必须重新盘点实际基线，不将旧统计当作全量上限。
- 本轮仍冻结AC-10.1.5-05：双实际APP媒体、same-call重连、旧RTC JWT首入/重入拒绝、撤权COMMIT后流动媒体停止≤5秒，全仍OPEN。当前唯一Media APP为一台真机，HTTP peer不算第二媒体APP。

## 三、唯一连续执行门 S0～S5

### S0｜归属、历史保护、完全无网基线（任何执行前）

1. 确认一个干净且归属本项目的隔离工作树，以`73b3...`为唯一源上位，所有保护根HEAD/branch/index/status、真实原refs、private env、锁文件、SDK engine、已有SQL/APK/备份/原证、全局Maven/Gradle缓存全量**已登记对象**取开工回执。不得reset/clean/stash/prune、移动他人branch或修改未知dirty根。新增构建产物只在**本轮新任务目录**，此前受保护缓存只读。
2. 给出来源分类：可信原始Gradle8.14完整ZIP／已解压分发（已核SHA、目录、Gradle libs/classes和可执行入口）；官方FlutterPOM/JAR二进制（上述Hash）；历史未批准`.zip.part`（只记录，不使用）。禁止复制任何`.part`到执行目录，旧part保持LOCAL_ONLY原位不动。完整ZIP可在**归属新目录**内安全解压（先做路径穿越、相对路径、异常符号链接检查）；或仅核实已复制、已解压并与可信原件字节相符的既有分发。不要覆盖原始解压/缓存。
3. 确定Java、Gradle8.14 bin/gradle.bat、Gradle home、project settings/插件脚本、隔离`GRADLE_USER_HOME`与之前init脚本的位置/真值；对外部网络脚本或潜在钩子有无法排除的风险，就停止，不尝试用修改系统防火墙当隔离手段。
4. 完成一份**先后顺序的闸门回执**：`COPY_COMPLETED → HASH_VERIFIED → GRADLE_BIN_READY → SAFE_OFFLINE_START_ALLOWED`，任何一步缺失不得提前启动Gradle进程。前轮原错误就是在COPY完成确认前启动Wrapper；本轮此门必须可由非作者独立辨认。

### S1｜本地Gradle8.14离线启动验证（必须先于项目解析）

1. **绝不执行`gradlew.bat`或Wrapper jar**；直接调用**在S0核定可信分发内部**的`<verified-gradle-8.14>/bin/gradle.bat --version`，仅此一个本地启动/版本检查；必要启动参数只用会话局部环境变量，不改系统或全局设置。任何出现`Downloading`、分发/代理出网迹象、未知脚本域、版本不符、class加载异常，立即结束本任务归属进程且STOP，不重试、不换工具/镜像。
2. 验证输出Gradle **8.14**，JVM与Gradle系统版本可用，真实进程/exit0/执行路径/分发Hash与S0原件绑定。注：`--offline`仅Gradle本体的解析选项，不能单独防住Wrapper；本轮通过不调用Wrapper消除该阶段下载可能。
3. 若S1无法PASS，终态`GRADLE_LOCAL_BOOTSTRAP_BLOCKED`，**不得进入S2/S3**；保留前轮不受权part，不做“最小试跑gradlew”来确认。

### S2｜既有同engine官方Maven隔离离线解析（只做一次必要预检）

1. 使用同一条真实可信的Gradle8.14本地可执行入口、同一`GRADLE_USER_HOME`、`--offline --no-daemon`；所有Flutter Maven二进制来自上轮校验的本地`official-maven`目录，其他依赖只能来自已存在、受保护快照复制到隔离空间的缓存。检查原`resolvePinnedDebugInputs`任务的定义和init脚本生效顺序，**不要在本项目源码创建这个任务或修改settings.gradle**。
2. init脚本（若已有且确认仅本项目临时作用域）限定io.flutter exact group/version的本地Maven repo，不覆写其它插件/全局仓库或用“任意版fallback”。已知POM packaging是**JAR**，不要求编造AAR。不得进入任何外部repo fetch；若Grade离线解析尝试访问非授权来源或报missing，立即以`MISSING_COORDINATE_AND_REPOSITORY`列出原始Gradle错误，停止，不补第三方依赖、不向MavenCentral/Google下载、不自动重试或切换目标。
3. 解析通过须能从Gradle**实际resolution结果**证明读到确切group:artifact:version及官方POM/JAR SHA，所要求的全部必要编译传递依赖均来自可信存量工件。若只是`gradle --version`成功、或project配置通过而没有真正resolve，不能写`DEPENDENCY_GRAPH_PASS`。
4. 离线解析最多一次完整预检（Gradle自身多任务内部依赖处理计为该次，出错不因不同报错无界重试），其后没有新增网络/依赖许可。**若真实预检没有合法解析任务**、只有动态定义或需要修改build源码，则以`RESOLUTION_VERIFICATION_TOOLING_BLOCKED`停止并交Owner，不擅自脚本修产品。

### S3｜最多一次诊断debug正向构建与包身份（须S1+S2真实PASS）

1. 同一个已认证`gradle.bat`入口直接执行`:app:assembleDebug --offline --no-daemon --console=plain`，不调用Wrapper；对`-PflutterDartDefines`作为**单一安全引用参数**只用以下三项true：`ELITESYNC_ICE_DIAG_TEST_ONLY`、`ELITESYNC_V1015_LOCAL_BUILD`、`ELITESYNC_V1015_R1_LOCAL_BUILD`，加原已批准`-PrelationshipDualDeviceBuild=true`。若项目真实引用的入口/构建目标不一致，STOP，不能改构建路径以凑PASS。
2. 正向build**最多一次**；exit1则保存原失败和本任务归属stdout/stderr/命令条件，按真实缺项分类STOP，不试新版本/新工具、不复制flutter.jar冒充POM/JAR，不将普通release AAR伪装成诊断debug AAR。
3. exit0后以**APK实物**核对applicationId须`com.elitesync.v1015icediag`、versionName`10.1.5-ice-diag-test`、debuggable=true、原生BuildConfig测试标识与Flutter诊断入口实际存在且隔离、独立debug AAR坐标及按源码明确的ABI、APK SHA256/bytes/apksigner签名/证书、可检的权限和普通R1包名不冲突；验证**普通R1旧包及缓存未覆盖**。不能只用源码中suffix声明或debug负例保证正向APK已正确。
4. 成功仅能`DIAG_APK_BUILT_IDENTITY_VERIFIED_LOCAL_ONLY`，**不得在本任务安装APK或用手机实测**。所有二进制原件、Gradle用户缓存及APK留本任务LOCAL_ONLY，不上传GitHub。

### S4｜非作者有界复核与历史保护

- 一次非作者静态审查S0隔离分发原件可信性、上轮`.part`排除、Gradle真实bin启动路径、offline解析日志、同engine精确工件来源/Hash与S3一次build、APK debug/test-only安全门。审阅者不运行网络/构建/设备、不读取原私密日志或凭据。
- 保护终检按本次真实基线核历史refs/HEAD/branch/index/dirty/status，逐hash具名原件以及原全局缓存、SDK/engine、lock、旧SQL/APK/恢复点；保留153条历史Windows长路径警告，但不得以部分cache覆盖声称全部磁盘无变化。保留先前所有failed exit/用户权限边界事件。
- 只停止本任务拥有的Gradle/Java临时进程，不停止共享服务/全局ADB/Docker/WSL，不删除隔离缓存或旧part；禁止任何真机、模拟器、DB、SFU、APP/RTC启动。

### S5｜单次集中交付与终态

本次**只允许新增两份正式docs**：
- `docs/versions/v10.1.5/GRADLE814_LOCAL_OFFLINE_BOOTSTRAP_REPORT.md`
- `docs/versions/v10.1.5/gradle814_local_offline_bootstrap_manifest.json`

如确属一次成功解析/构建，也不得修改原R1、诊断源码或构建脚本：本任务要求`SOURCE_UNCHANGED`，完整apps/services产品Git Tree与固定source `24ddf05875d8d4abad7a6b473f882698c9885c2a`相同。集中报告逐门给exit、原工件Hash/bytes、S0→S1→S2→S3真实时间排序、本地安全缓存来源、unapproved part quarantine/untouched回执、工具错因、APK身份证据（若有）、上轮20诊断+93普通回归**REUSED_VALIDATION而非本轮重跑**、独立静态复核与保护限制。不得把任何未执行门写成PASS。

从上轮交付 `73b3b753225f99824081d312a25a7deb170c62d3` 干净连续派生，普通nonforce发布候选并固定回读唯一parent/root、两docs Blob和完整apps/services Tree，私密日志、完整本地分发ZIP、POM/JAR、缓存、APK及任何凭据不上传。只发布最终报告/清单到GitHub候选分支，**不合并main、不改ACTIVE_STATE、不可自己签版本接受**。

可能出口：
- `GRADLE814_LOCAL_BOOTSTRAP_PASS / PINNED_DEPENDENCY_RESOLUTION_PASS / DIAG_APK_BUILT_IDENTITY_VERIFIED / PHONE_RUNTIME_NOT_RUN / AC05_OPEN`；
- `GRADLE814_LOCAL_BOOTSTRAP_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED`；
- `DEPENDENCY_RESOLUTION_BLOCKED_EXACT_MISSING_COORDINATE / NO_APK / OWNER_DECISION_REQUIRED`；
- `DIAG_ASSEMBLE_DEBUG_FAILED_AFTER_GATES_PASS / NO_APK / OWNER_DECISION_REQUIRED`。

所有出口统一 **`AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`**。完成当前唯一任务后停止；不得自行继续真机测试、下载、构建重试或归并。