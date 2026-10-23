# v10.1.5 Gradle诊断构建链修正交付

日期：2026-10-23。结论：**PARTIAL / V10.1.5_BUILD_CHAIN_OR_GUARD_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本轮交付了诊断专属的内层Gradle入口修正，通过31项定向fixture和6项源码隔离比对。唯一真实离线预检在临时init的仓库闭包调用处失败，exit1，未进入目标配置的`resolve()`；不得称依赖图通过，也没有证实任何新缺失坐标。`assembleDebug`为0/1，保持NOT_RUN。静态审查未提前识别该工具错误；原失败原样保留，不将失败尝试清零或改名后重跑。

`PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。本报告不是Astra ACCEPTED。

## 固定权威与源码

| 对象 | 固定身份 |
|---|---|
| 正式任务Blob | `f69ea6325c309fbfacd397bd9abfaf2183d29616` |
| 上轮Astra复审Blob | `7e379354cc4f31074597a431941f233d804f2085` |
| 开工及源码发布后live main | `f011cac7a097c834308f30ee4bb63acd718cda1c` |
| 唯一起点／本轮source唯一Parent | `76a7542d9c9121051b55251fda198e568a8d0aa5` |
| 本轮source Commit | `5354ba679e24dbf972cea74e8fd0f60c51a2eca0` |
| source Root Tree | `766b43530a606a60e1e55f7f4721857c14d5a28a` |
| apps Tree | `8011c1909444c689c45a23d4c20e1bef85694966` |
| services Tree，未变 | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |
| 唯一变更源码 | `apps/android/app/build.gradle.kts` |
| 变更前／后Blob | `5a08d63f5f95155ca1f346f9809683f6f35ac7e0` / `d588562d5fce8a161c2bef8c879a2597b940010f` |
| Flutter模块Tree，未变 | `ce77296255d1439a38bb17287c7b35dcd830a820` |
| 固定原诊断源码 | `24ddf05875d8d4abad7a6b473f882698c9885c2a` |

任务和复审全文已读，保存的原字节经`git hash-object --no-filters`匹配以上Blob。正式任务中的main为发布前身份；Owner给出的签发后main与实读一致。候选分支为`codex/v10.1.5-gradle-diagnostic-chain-fix`。保留连续worktree；未用main重置候选。

## G0：身份、版本和隔离

复用既有可信Gradle8.14分发与上一轮固定`--version` exit0回执，本轮没有仪式性重跑版本命令。再次核SHA256：完整ZIP224116304B为`efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`；bin为`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`；launcher JAR为`3e21380f278d069ec1fc706b1a3b075250a00d6366dccc1fcf343838a494f20b`；core JAR为`36ee23fbf4082131bbf8758603a7a2019be60f47bc033b283447e107c578427d`。JDK17.0.18.8固定输入未变。

Flutter3.41.7／Dart3.11.5／engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`及锁文件不变。宿主Android与生成态`.android`为不同Gradle root，两者项目AGP8.11.1、Kotlin2.2.20。SDK插件自身Kotlin1.9.20／内部依赖1.8.0另属工具实现，没有被误当项目版本漂移。本轮真实预检已执行该插件的compileKotlin、pluginDescriptors、processResources和jar四项任务；这只支持该工具插件能在当前Gradle编译，完整Android项目兼容性仍未验证。

同engine官方embedding为`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`，POM packaging=jar，未伪造AAR：POM2542B／SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`；JAR1541793B／SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`。均复用此前从官方Maven取得的原件并核副本；本轮没有获取外部工件，发布者签名和官方SHA sidecar仍NOT_VERIFIED。

执行目录为本任务专属LOCAL_ONLY副本，不含Git仓库。项目／modules-2／Flutter Gradle插件／15个Android Pub插件／官方工件共8723个复制记录，Android既有组件22185个及额外默认build-tools35.0.0的170个记录；每份复制完成后逐字节SHA验证，再启动工具链。两个生成态local.properties指向本轮SDK副本；原全局SDK/Pub/Maven不作为可写Gradle项目。旧插件输出的任务内副本另处保留、不参与本次执行，AAR输出起点为空。仅在执行副本添加禁止SDK自动下载、Kotlin in-process等本地属性；不改原SDK、Flutter插件源或Wrapper。

Flutter副本此时仅满足配置解析所需，**不是已验证可构建SDK**。若解析通过，仍须补齐既有执行工具与Dart包配置后方可构建；本轮解析失败后未再复制执行组件。

## G1～G2：授权工具与唯一源码修正

LOCAL_ONLY动态init限定本任务module/host root，以精确版本独占路由已有embedding_debug POM/JAR；未更换正式插件仓库或增加下载fallback。任务限定`:flutter`及14个native插件的debugCompileClasspath/debugRuntimeClasspath，代码明确调用`Configuration.resolve()`并首失败退出；不解析尚未生成的宿主内部诊断AAR，也不通过宿主diag flag绕过debug任务名门。

旧init1649B SHA256 `b77ccde95034ec94237e127d65eafb77263a2292a1672854d839cb05225be709`；最初审查版3090B SHA256 `00cf203fba429f78a7bfbe7c4294e4cd5ff1c20dc8aaed45446bd2ed66c0cc1b`；执行版3366B SHA256 `bca437d1a485a81981df14e97bea478f7615193789795377d2d0a8034031b1f9`。各原件、生成器及前后hash均LOCAL_ONLY留存。执行前锁定最终hash。

唯一跟踪源码的66行新增／3行删除，仅在ICE_DIAG_TEST_ONLY诊断路径读取`iceDiagGradleBin`和`iceDiagGradleUserHome`。配置期拒绝缺属性、相对或未授权路径、Wrapper别名、非Windows、非8.14、错误bin/launcher/core哈希、home/env不一致及非本任务工程副本。不提供静默Wrapper回退。内层Exec使用已验bin，显式同一GRADLE_USER_HOME、--offline和--no-daemon。

普通R1、retention和非R1原命令语义保持；原Dart target、三项flag、defines编码、r1Digest、AAR debug坐标、原输出相对位置、两个ABI及preBuild依赖未改。release/profile诊断拒绝规则保留。没有修改RTC/Dart、Laravel、SFU或冻结AC。

## G3：测试与非作者有界复核

测试为从真实源码提取的同一Kotlin验证函数、flag guard及Exec命令表达式的离线fixture；不是完整Android项目构建，也不是APP运行验证。

| 检查 | 实际结果 |
|---|---|
| 首轮fixture | exit1：Windows路径分隔符预期写法错误，原stdout/stderr/result保留；仅修测试预期 |
| 修正fixture预期后 | exit0，`GUARD_TEST_TOTAL 31` |
| 反转版本判断的mutation副本 | exit1，明确`ICE_DIAG_GRADLE_GUARD_REJECTED: Gradle version must be 8.14`，证明测试可捕获削弱 |
| 源码隔离比对 | 6/6 true，包括既有门、普通非R1命令、Android配置/依赖及Flutter树不变 |
| git diff --check | exit0 |
| 上轮20诊断＋93回归 | REUSED_VALIDATION；本轮未重跑113项 |

31项覆盖工具属性/位置/版本/哈希、环境及project归属、release/profile、混v10.1.4/v10.1.2、retention/未知flag、普通R1和retention无新属性、flag-off不访问新路径，以及实际命令列表中的bin/offline/home/target/ABI/defines。普通构建的完整Gradle配置仍NOT_RUN。

一次非作者GPT-6.1 Sol/high有界静态复核在真实解析前完成，读source diff、init、隔离/启动脚本与测试回执。发现P1：预检缺target-platform会隐式扩大到ARM32；已在首次真实预检前固定为`android-x64,android-arm64`，init拒绝其它值，并定点复核。P2生成器同步和启动环境前置项亦在执行前处理：同步生成器，子进程清除Java/Kotlin注入选项、CLASSPATH及外来Gradle属性/缓存覆盖。审查时没有未关闭P1源码问题，**未识别到随后发生的init闭包运行错误**，不能将静态意见称完整构建链通过。审查者未运行Gradle、网络、设备或重hash全部暂存文件；不是Astra验收。

## G4：唯一真实离线预检失败，未构建APK

使用经核验的直接Gradle8.14 bin、专属GRADLE_USER_HOME和隔离module cwd。脱敏等价命令：

```text
<TRUSTED_GRADLE>/bin/gradle.bat resolvePinnedDebugInputs --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64
```

实际启动一次，40.733秒，exit1；单次预算已消耗，不重新命名/改脚本后再次尝试。stdout显示工具插件四个任务执行及常规弃用警告。stderr首个阻断为：

```text
Initialization script '<ISOLATED_HOME>/init.d/exact-flutter-repo.gradle' line: 9
Could not find method maven() ... on object of type
org.gradle.api.internal.artifacts.dsl.DefaultRepositoryHandler$ExclusiveContentRepositorySpec.
BUILD FAILED in 40s
```

`forRepository { maven { ... } }`的Groovy闭包方法接收对象错误，发生在仓库配置期。它是临时验证工具错误，**不是新缺失依赖坐标，也不是已证明的Flutter embedding、RTC或ICE产品缺陷**。`PINNED_RESOLVE_BEGIN/OK/PASS`均为0；专属目标配置resolve实际调用0。插件构建自身依赖已参与配置/编译，不能把整次进程说成“完全没有发生任何依赖解析”，也不能说目标图已验证。

`assembleDebug=0/1 NOT_RUN`、`syncFlutterAar=0`、Wrapper调用0。没有诊断APK，包名/versionName/debuggable/签名/cert/SHA/ABI/权限/真实debug AAR和Dart入口的**正向实物身份均NOT_RUN**。普通开发包未重建、未安装。既有test-only源码隔离证据保留，但不能替代本次APK身份。

已知最小后续修正是对仓库工厂显式限定RepositoryHandler接收对象（如审查`repos.maven`用法），先做独立fixture验证，再在Owner另行授予预算后进行真实预检；此方案**本轮未实施、未验证、未自动派发**。没有再次解析或构建，也没有查找/下载更多依赖。

## G5～G6：保护、发布和停止

保护终检：1531份登记历史资产、3253条工具链/缓存记录（含3184份原全局Maven文件）、496个旧refs、五个历史根HEAD/branch/index/status全部匹配；第一根原153条长路径warning如实保留。额外31078个唯一复制来源文件的bytes/SHA保持；不把登记范围扩大成全盘扫描。未授权旧part38302288B／SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`保留，未复制、解压、执行或入classpath。

旧SQL/APK/备份/私密env和原证不清理。数据库、volume、手机及私人数据未操作，未另做数据库一致性测试。没有新SDK/外部依赖下载或外网仓库解析命令；全部Gradle调用--offline，未调用Wrapper。未做全宿主独立抓包，因此不声称整个电脑期间绝对无网络。GitHub授权候选发布/回读另计。没有ADB/AVD、DB/API/Laravel/guard/SFU、媒体或网络配置动作。四个本轮single-use Gradle daemon日志均有关闭标记，未广域停止全局进程。

source已普通non-force发布，GitHub connector回读唯一文件diff；因connector无完整Git Tree入口，进一步用GitHub REST与独立raw HTTP核commit/唯一parent/root/源码Blob，以及完整apps735文件/1133条含目录映射、services714文件/791条映射，均未截断且逐项相等。source raw字节20922B／SHA256 `037da91b2c5b17ae4dee953eced6364a09a889705d924599dab3fbb525e122b1`匹配。main未动。

本报告与manifest随后构成仅新增两文件的文档commit，唯一Parent为固定source；文档commit及两Blob在发布后按同样REST/raw和完整产品Tree流程回读，最终身份记录于LOCAL_ONLY delivery-readback.json及Owner交付消息，避免对文档自身commit作循环哈希承诺。原首轮报告/manifest未改。

终态：**V10.1.5_BUILD_CHAIN_OR_GUARD_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。本轮停止工具链执行，仅完成文档和Git交付。AC05四媒体硬门继续OPEN/NOT_RUN；保留已证消息、缓存、通知、数据库等旧版证据，不重复验收。main接受产品仍为v10.1.4；不合main、不自行ACCEPTED、不启R2/P2/v10.1.6。

公开材料仅含允许的Git身份、统计、脱敏错误与命令。日志过滤白名单：GUARD_TEST_PASS/TOTAL、明确GUARD_REJECTED、PINNED_RESOLVE标记、BUILD结果/任务计数及上述错误类型。原始路径、设备标识、JWT、个人资料、私密配置、二进制和完整原始日志均LOCAL_ONLY；不上传原始ICE。
