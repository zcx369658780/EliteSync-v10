# v10.1.5 Init仓库DSL修复及单次离线解析交付

2026-10-23。**PARTIAL / GRADLE_INIT_DSL_FIXTURE_PASS / TARGET_RESOLUTION_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本轮LOCAL_ONLY仓库DSL修复经真实Gradle8.14离线fixture首次8/8通过。唯一正式预检已经越过旧仓库闭包错误，实际进入`:flutter:debugCompileClasspath`的`Configuration.resolve()`，因两个同engine debug架构工件未缓存而exit1。BEGIN=1、OK=0、PASS=0；其它29个配置未开始。没有重试、下载或APK构建。**不将fixture成功等同15模块依赖图通过**。

| 身份 | 固定值 |
|---|---|
| 正式任务Blob | `21b547a3c846326019f5662db984d328f9a34153` |
| Astra上轮复审Blob | `4283ac288b31fdbd2513cccf8f8d3223ad0a687a` |
| 签发后及开工live main | `b13bdf188e6f6e1b6af7d98289f4bf2bf1d11814` |
| 唯一候选起点／本轮docs唯一Parent | `7f059385f5fc4f6d17a87ce421e0ed4b3d976cc4` |
| 起点Root Tree | `3d62ff21846396a34be63b605e9b4dc3425b6f1c` |
| 固定Gradle诊断构建源码 | `5354ba679e24dbf972cea74e8fd0f60c51a2eca0` |
| 固定源码Root | `766b43530a606a60e1e55f7f4721857c14d5a28a` |
| build.gradle.kts Blob，未变 | `d588562d5fce8a161c2bef8c879a2597b940010f` |
| 完整apps Tree，未变 | `8011c1909444c689c45a23d4c20e1bef85694966` |
| 完整services Tree，未变 | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |

正式任务和上轮Astra复审全文已读；固定main raw HTTP字节的Git Blob逐项匹配。任务内部“签发前main”和Owner给出的“签发后main”分开记录，未用main覆盖候选。连续工作树开工干净，从起点新建`codex/v10.1.5-init-repository-dsl-fix`，本轮只新增这两份正式docs，不改apps/services、旧报告、ACTIVE_STATE、冻结AC或任何跟踪源码。

## G0：保护、工具和配置态副本

本轮重新建立68303个唯一文件的bytes/SHA256基线，包含上轮所有35685份文件、继承登记原证与原工具/Pub/SDK/Gradle输入；不以旧1531登记数冒充当前数量。497个旧refs、五历史根HEAD/branch/index/status和第一根153条原长路径warning均快照保留。旧临时init及完整stdout/stderr/result原位不改，在新任务目录另存原字节副本。

可信Gradle8.14完整ZIP224116304B SHA256 `efe9a3d147d948d7528a9887fa35abcf24ca1a43ad06439996490f77569b02d1`、bin `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`、launcher `3e21380f278d069ec1fc706b1a3b075250a00d6366dccc1fcf343838a494f20b`、core `36ee23fbf4082131bbf8758603a7a2019be60f47bc033b283447e107c578427d`已核。直接使用该bin；既有版本回执复用，没有单独重跑--version，fixture输出真实Gradle8.14。JDK17.0.18.8／Flutter3.41.7／Dart3.11.5／engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`／AGP8.11.1／项目Kotlin2.2.20及锁文件均未升级。

新目录复用并逐文件核对28558份既有配置态副本，包含modules-2、项目、Flutter Gradle插件、Pub插件及已批准的Android组件；不增加SDK组件。两个local.properties及Android插件生成路径仅在本次无.git执行副本重定位，工程settings/Wrapper和跟踪源码未改。原全局缓存/Pub/SDK及上一任务副本不作为可写构建输出。配置态Flutter副本未被称为完整APK工具链。

新正式项目home与空的fixture home分开，未把fixture的合成对照工件/缓存混入正式项目。启动子进程清除Java/Kotlin注入、CLASSPATH及Gradle属性/只读缓存覆盖，再显式指定可信JDK、专属home/temp/SDK路径；无全局环境修改。

## G1：仓库接收对象修复和真实离线fixture

只改新LOCAL_ONLY init仓库声明中的`forRepository { maven { ... } }`为`forRepository { repos.maven { ... } }`，明确让RepositoryHandler接收maven调用；另将该脚本的任务归属根重定位到新目录。反向还原这两处即得到旧原字节，未改15模块列表、两个debug配置、准确group/artifact/version exclusive filter、实际resolve()调用、计数、首失败停机或target-platform门。

| 脚本／夹具 | bytes | SHA256 |
|---|---:|---|
| 旧失败init原件副本 | 3366 | `bca437d1a485a81981df14e97bea478f7615193789795377d2d0a8034031b1f9` |
| 本轮新init，fixture与正式运行绑定 | 3362 | `5dad6fe912efab85e20b8c1fe2d0b3b81c3984dc68a1ef6704496a94288fa43b` |
| fixture build.gradle | 4362 | `73fde4374c74d343c5e5d0f9dad92286a812fbc420e6779a1e04482bf65866d1` |
| fixture settings.gradle | 85 | `a7dec1cdcf57fd581db35ba53b73b20c687f6b42814b94f5405640523303b606` |

最小fixture不使用Android/Flutter插件、没有任何远端仓库声明；从空的隔离Gradle home启动，使用候选同一仓库helper（换行归一后抽取，**不是两个文件字节完全相同**）。仅为精确工件测试关闭transitive，正式15模块配置未关闭transitive。实际执行：

```text
<TRUSTED_GRADLE>/bin/gradle.bat verifyRepositoryDsl --offline --no-daemon --console=plain --max-workers=2
```

首次fixture exit0，用时5.665秒，`FIXTURE_PASS_TOTAL 8`。未使用允许的第二次同类闭包修订预算。八项直接运行结果：

1. 运行版本确为Gradle8.14。
2. 注册得到真实MavenArtifactRepository，名称和file URL匹配；创建者明确为RepositoryHandler。
3. 实际resolve精确embedding JAR，SHA256匹配。
4. 实际resolve精确POM，SHA256匹配。
5. 非Flutter组被同一exclusive filter拒绝。
6. 独立未过滤对照成功解析该负例工件，证明拒绝原因不是文件不存在。
7. fixture中重现旧错误接收对象片段，明确抛出maven/ExclusiveContentRepositorySpec错误；原完整旧脚本没有被执行或覆盖。
8. 缺失RepositoryHandler明确异常，不吞错。

第5/6项合成对照为`fixture.denied:repo-probe:1.0`，仅存在于fixture镜像；其POM明确标注LOCAL_ONLY synthetic，JAR字节复用可信旧原件，仅作排除测试，不假冒官方坐标、不进入正式repo或真实依赖图。

精确官方工件仍为`io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`，POM packaging=jar：2542B／SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`；JAR1541793B／SHA256 `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`。全部是旧官方来源字节复用，没有本轮下载；发布者签名/官方SHA sidecar仍NOT_VERIFIED。fixture只能证明这一仓库DSL和原件解析，不能证明全部传递依赖。

## G2：唯一正式项目解析，真实缺项后停止

fixture通过、28558份复制校验结束后，确认正式安装init与已测候选bytes/SHA相同，且正式repo只有既有官方io.flutter原件，没有fixture.denied。直接可信Gradle8.14、独立home、隔离module cwd，命令为：

```text
<TRUSTED_GRADLE>/bin/gradle.bat resolvePinnedDebugInputs --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64
```

正式执行1次，96.498秒，exit1。工具插件4项编译/打包任务完成，随后真实运行解析任务；stdout关键原文：

```text
> Task :resolvePinnedDebugInputs FAILED
PINNED_RESOLVE_BEGIN :flutter:debugCompileClasspath
```

stderr明确：

```text
Could not resolve all files for configuration ':flutter:debugCompileClasspath'.
No cached version of io.flutter:x86_64_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab available for offline mode.
No cached version of io.flutter:arm64_v8a_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab available for offline mode.
BUILD FAILED in 1m 36s
```

准确分类为`MISSING_DEPENDENCY_COORDINATE`。stderr的Initialization script line37是`config.resolve()`调用位置，**不是旧仓库DSL再次失败**。两个坐标来自锁定engine和本轮真实错误，不是猜测：

- `io.flutter:x86_64_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`
- `io.flutter:arm64_v8a_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`

预期发布方为Flutter官方Maven（既有配置来源`https://storage.googleapis.com/download.flutter.io`）；本轮没有访问它们的远端坐标，不推断发布可用性、POM packaging、二进制扩展名、bytes、hash或其它尚未暴露缺项。错误中同坐标重复是多个离线仓库结果的聚合，不是多次正式预检。

计划15模块×2配置=30；实际BEGIN=1、OK=0、PASS=0。仅`:flutter:debugCompileClasspath`开始，`:flutter:debugRuntimeClasspath`及其余14模块的28配置共29项NOT_RUN。没有声称15模块依赖图通过，没有把工具插件jar当Flutter debug AAR，也没有把尚未生成的宿主内部诊断AAR当外部缺项。

## G3：APK条件不成立，NOT_RUN

G2未通过，`assembleDebug=0/1 NOT_RUN`，没有真实build失败或APK。包名、版本、签名/cert、debuggable、ABI、权限、Dart诊断入口及flutter_debug AAR的正向实物核验全部NOT_RUN。

另有独立的静态前置限制：固定构建源码严格要求上一build-chain任务的project/home根，本轮新根无法在不改源码、不复用可写历史根的情况下满足，应记`BUILD_PATH_IDENTITY_BLOCKED`；配置态SDK也未证完整APK编译能力。本轮没有改源码、软链、伪造hash、借旧home绕过或扩充SDK。即使未来依赖问题解决，也不能凭本报告推定构建条件已经满足。

## G4：非作者复核、保护和资源

一次非作者GPT-6.1 Sol/high有界复核核实候选差异、fixture真实注册/resolve/排除对照和脚本hash、正式单次stdout/stderr/result、配置计数及G3路径限制。未发现本轮新的高置信静态P1。复核确认当前错误应归类真实坐标缺失；不能写15模块已解析，也不能据离线缺项断言官方未发布。保护摘要由主代理逐文件实测，非作者只核原证索引/回执，没有独立重hash全部68303文件或运行Gradle/网络/设备。该意见不是Astra ACCEPTED。

终检68303份登记文件bytes/SHA无变；上一任务全部35685文件不仅hash不变，清单也未增删。497个旧refs和五历史根HEAD/branch/index/status一致，原153条长路径warning保留。原global Gradle模块记录实际3185项（含锁文件；继承的旧3184工件统计另有范围），不以旧数字覆盖当前基线。范围限具名目录/文件及五根，不宣称全盘、手机或活数据库一致性扫描。

旧未经授权part38302288B／SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`原样保护，未复制、解压、执行或作为依赖。旧SQL/APK/备份/私密env及原文档、旧失败均保留。手机/ADB/AVD、数据库/API/Laravel/guard/SFU、Room.connect、麦克风、网络监听/防火墙/LAN/UDP/TURN均0操作。没有新依赖下载、版本升级、Wrapper调用或全局缓存修改；两本轮single-use daemon均有关闭标记，未停止全局Java/ADB/Docker/WSL。未做全宿主抓包，不能宣称整个电脑绝对无网络；GitHub授权发布/回读另计。

## G5：docs-only候选与停止

只新增本报告与`ice_init_repository_dsl_offline_resolution_manifest.json`，文档commit唯一Parent为固定起点7f059385…；apps/services完整Tree必须保持表中固定值，产品跟踪diff为空。普通non-force发布后，用GitHub connector核docs-only差异，因其无完整Tree入口，再用GitHub REST核commit/sole parent/root/全部产品递归映射，并通过独立raw HTTP核两docs Blob原字节。文档自身commit/Root/Blob不能循环写入自身，准确身份记于LOCAL_ONLY delivery-readback.json及最终Owner交付消息。

公开白名单仅Git身份、测试/调用计数、明确结果、脱敏命令/错误、工件坐标及hash。原init/POM/JAR/APK/ZIP、完整stdout/stderr、私密路径、设备标识/JWT/ICE/个人资料和配置均LOCAL_ONLY，不上传。manifest索引仅给相对证据名、bytes/SHA，不包含原始私密内容。

终态：**GRADLE_INIT_DSL_FIXTURE_PASS / TARGET_RESOLUTION_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。本轮不再运行Gradle，不下载缺项、不重试、不启动后继。v10.1.5仍PARTIAL_NOT_ACCEPTED，AC05四媒体硬门OPEN/NOT_RUN，PLAN_A_RETAINED；main已接受产品仍v10.1.4。无main产品集成，无ACCEPTED，无R2/P2/v10.1.6。
