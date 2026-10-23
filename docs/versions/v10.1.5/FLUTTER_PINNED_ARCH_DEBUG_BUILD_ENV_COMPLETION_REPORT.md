# v10.1.5 同engine Debug架构工件与诊断隔离环境交付

2026-10-23。**PARTIAL / PINNED_ARCH_OFFICIAL_ARTIFACTS_VERIFIED / SDK_STAGE_OR_DIAGNOSTIC_PATH_BLOCKED / NO_APK / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

两个指定工件已从唯一获准Flutter官方Maven根取得并核验；诊断路径修订的47项真实Gradle fixture正负例通过。隔离SDK静态输入及Flutter启动身份通过，但真实宿主轻量配置在Android插件创建目录服务时exit1。依照新真实阻断即停，未重跑、未运行正式依赖解析或assembleDebug。**不能宣称SDK_BUILD_READY、30配置通过、实际宿主诊断guard通过或APK已生成。**

## 固定权威和源码候选

| 项目 | 固定身份 |
|---|---|
| 正式任务Blob | `4ec703b39207324d7e13cc3cb176eaa7ed406937` |
| 上轮Astra复审Blob | `c61e6635c3a50dcbcebad25f1ae8e5152a81b02d` |
| 签发后／执行时live main | `7f65d792bc0732f7a09f836ae7349e07343334c4` |
| 唯一起点／本轮source唯一Parent | `294c19f296b4b872dd7da8800d1901c08d209e51` |
| 起点Root Tree | `069b16e6e42c9a011804814ea31a62cc061561d4` |
| 固定先前Gradle源码 | `5354ba679e24dbf972cea74e8fd0f60c51a2eca0` |
| 原构建文件Blob | `d588562d5fce8a161c2bef8c879a2597b940010f` |
| 本轮source Commit | `1522466faf798b719ccff281de7584f043946437` |
| 本轮source Root Tree | `09a4041a7bdca9eb0ffd9e92a724fe8eeb0d17cf` |
| 本轮构建文件Blob | `bdb8e241d3e0defd1793c90b5f730c2facd7433d` |
| 完整apps Tree | `785822ca072943c5bfefa3ccc37ede01c2af5164` |
| 完整services Tree，保持 | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |

任务和上轮复审全文已读取，保存raw字节的Git Blob精确匹配。任务正文记载的签发前main与Owner提供的签发后main分开，不用main产品源码覆盖候选。连续工作树起点干净，使用`codex/v10.1.5-pinned-arch-debug-build-env`。本轮source只改`apps/android/app/build.gradle.kts`（71行增加／21行删除）；Flutter模块完整Tree和services未变。其后的交付docs commit唯一Parent为上述source，仅新增本报告及同名manifest；实际docs Commit/Root/两文档Blob由发布后回读回执记录，避免文档自引用。

## G0：保护、时窗和预算

开始登记118721份具名保护文件，其中上一任务全部50417份；498条旧refs、五历史根HEAD/branch/index/status及原153条长路径warning。当前唯一受权构建文件从immutable集合单列，保留原SHA256。既有dirty根、SQL/APK/备份、私密配置、旧候选及缓存不清理、不覆盖。

网络获取窗仅用于两个精确官方坐标，无Gradle/Flutter子进程；获取收口后才复制和运行完全离线工具链。只调用经Hash核验的Gradle8.14本地bin；本轮Wrapper调用0。Gradle以`--offline --no-daemon`及隔离home运行，SDK/Pub URL设任务内file URI失败关闭，禁Android SDK自动下载，清理子进程外来Java/Gradle/Flutter注入变量，固定engine；没有修改全局网络或SDK。该组合是执行约束及日志证据，**没有抓包，不能称系统级全网络流量已证明为零**。

| 动作 | 实际次数／上限 | 结果 |
|---|---:|---|
| 独立Guard fixture | 1次 | exit0，47/47 |
| Flutter启动身份预检 | 1次 | exit0 |
| 真实宿主轻量配置 | 1次 | exit1，新阻断即停 |
| 正式15模块依赖解析 | 0/1 | NOT_RUN |
| 正向诊断assembleDebug | 0/1 | NOT_RUN |
| 设备、安装、ADB、DB、SFU、Room.connect | 0 | NOT_RUN |

## G1：官方精确工件

固定版本`1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`。三处具名本地缓存均未发现可复用的这两个坐标后，才访问`https://storage.googleapis.com/download.flutter.io`的两个精确目录。无其它Maven来源、engine、第三工件、SDK或Gradle下载。

| 坐标（group=io.flutter） | POM bytes／SHA256 | 二进制实际格式／bytes／SHA256 |
|---|---|---|
| x86_64_debug | 505／`ed88c05320bc7ec975800e358dae9b437b0c2e106c871a78efcb494fef50f466` | JAR／112731041／`4c61bc7c2a7c0eee6d9c9ec2ea3175f6c246fad3034f009aa5badd56c1e5912a` |
| arm64_v8a_debug | 508／`85bd902880a1efcb252c8c0698740c129007dc2feccd75efbe172468b2a6ec7b` | JAR／170897085／`01b643c934dd9d8703ee148043d5950369aa85181d338f2eacd8b16787a4a9a2` |

POM精确g:a:v、packaging=jar；HTTP200、最终URL仍在原官方目录，Content-Length、TLS默认验证、存储CRC32C与本地值匹配；ZIP逐项CRC通过，实际libflutter.so为ELF64（x86_64 machine62／arm64 machine183）。记录ETag与本地MD5匹配；未取得Google MD5 header。POM/JAR的SHA256 sidecar均404，**PUBLISHER_SIGNATURE_NOT_VERIFIED**，本地SHA仅字节身份，不能当发布者签名。完整URL/状态/headers校验结论见manifest，原始工件LOCAL_ONLY，任务Maven完成目录只读。

已有embedding POM/JAR只本地复用，分别2542／1541793 bytes，SHA256 `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff`／`f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745`；未再次获取，签名边界不变。取得工件不等于项目已实际解析成功。

## G2：唯一诊断源码改动和验证层级

新增`iceDiagTaskRoot`、`iceDiagTrustedGradleRoot`，同原bin/home properties共同强制绑定当前批准容器的`build-run`、可信Gradle目录、隔离home、宿主/module与Flutter SDK。先比较归属再访问文件，要求Windows绝对规范路径、无链接或canonical重定向；外层实际Gradle home、环境与project须一致。保留Gradle8.14、offline、bin/CLI/core三个固定SHA、三项原诊断flags及仅debug门。属性缺失、旧任务根、任意目录、Wrapper别名、错误Hash等均拒绝。

`syncFlutterAar`原命令编排、离线参数、诊断Dart入口、defines、两ABI、AAR digest版本和preBuild顺序不变。新属性只在diagnostic分支读取。真实抽取源码的Gradle fixture exit0／47项，包含路径正例、版本/online/工具/Root/Home/SDK环境负例、普通R1与retention参数对照、禁用flag、release/profile及混标志拒绝。另有7项静态源码隔离断言及6类普通构建对照（R1、retention、release、profile、无flag debug、v10.1.4），**六类对照是源码等价性，不是六次实际APK构建**。普通宿主真实配置原计划在diag正例后执行，因首个宿主配置失败而NOT_RUN。

夹具原命令的脱敏形式为`<TRUSTED_GRADLE>/bin/gradle.bat verifyGuardsDebug --offline --no-daemon --console=plain --max-workers=2 -PfixtureContainer=<TASK>`；exit0，stdout含`GUARD_TEST_TOTAL 47`及`BUILD SUCCESSFUL in 21s`，原Kotlin非空断言/unused和Gradle弃用warning仍在LOCAL_ONLY stdout中保留。

真实宿主尚未越过app插件应用，故没有在实际宿主中执行validator或输出断言。不能用47项独立fixture覆盖这一未验证层级，也不声称整个正常产品构建运行通过。

## G3：已有SDK隔离复制和诚实就绪状态

仅复制已拥有的同版本组件；64864份文件、7033931236 bytes逐源／副本Hash核对。包含可信Gradle、既有modules缓存、Flutter启动脚本及真实Git身份、Dart/compiler、现有engine/assets、必要Pub包、Android平台36、build-tools35/36、NDK28.2.13676358及许可。工具链Flutter3.41.7／framework`cc0734ac716fbb8b90f3f9db8020958b1553afa7`／Dart3.11.5／engine59aa…／JDK17.0.18.8／AGP8.11.1／Kotlin2.2.20未变。两份package_config合计272 entries（102＋170），root与pubspec均落在任务副本；原锁文件不改，任务内生成metadata与local.properties重绑。构建文件最终overlay另核SHA256 `676bc8af598166b17c6dfb1790a074156066430ef0f467938386df658c189298`，不把早先复制的旧执行脚本冒充最终版本。

复制按已有组件目录粒度进行，`windows-x64`目录随必要frontend compiler一同带入既有桌面DLL/PDB等伴随文件，完整Gradle分发也含文档；上述总文件数／体积包括它们，不代表每个文件都是Android debug必要输入或被执行。附带文件未执行，复制清单完整保留，不以删除副本掩盖此范围精度限制。

保留两类审计发现与修正：初版审计错假定FlutterTask.kt直接位于kotlin目录，实际固定SDK位于kotlin/tasks；8个资源/原生包源与副本本来都没有lib目录，root/pubspec及内容哈希真实齐备。原失败sdk-audit.json未覆盖，纠正回执与最终静态清单分别保存；未借此下载或改SDK。非作者指出`stat()`会跟随链接，追加对源、复制件及各祖先逐`lstat`审计168220路径，reparse=0；原stage helper未改写，不应绕过此审计直接复用。全量复制Hash无漂移。

真实`<SDK_STAGE>/flutter/bin/flutter.bat --version --machine --suppress-analytics` exit0，stdout JSON的frameworkVersion=3.41.7、dartSdkVersion=3.11.5、engineRevision=59aa…固定值，stderr为空；原launcher/shared/update-engine脚本Hash保持，未伪造或手工改写stamp（launcher正常校准任务副本engine stamp），清空revision/Flutter工具注入，未出现snapshot/pub upgrade或下载。该轻量启动证明其已执行分支可用；**尚不证明AAR/APK编译就绪**。静态组件齐备和启动预检PASS与当前`SDK_BUILD_READY_NOT_ESTABLISHED`并存。

## G4–G5：真实阻断、原命令及未执行项

前轮8/8 Groovy仓库fixture按任务要求复用，不重做。LOCAL_ONLY init保留已通过的receiver语义，只重绑当前Root并精确增加两项获准同engine includeVersion，共3个精确GAV；原SHA `5dad6fe912efab85e20b8c1fe2d0b3b81c3984dc68a1ef6704496a94288fa43b`，本轮SHA `454fad91b345a4524e55bbde8a1126725fcd3ea7bcf88a9bb8fe51c1f464d339`。

真实宿主轻量配置（别名已脱敏；每个property作为单独argv传入）：

```text
<TRUSTED_GRADLE_8_14>/bin/gradle.bat :app:verifyIcePathDebug
  -I <TASK>/host-config-check.gradle --offline --no-daemon --console=plain --max-workers=2
  -PrelationshipDualDeviceBuild=true
  "-PflutterDartDefines=ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true"
  -PiceDiagTaskRoot=<RUN> -PiceDiagTrustedGradleRoot=<TRUSTED_GRADLE_8_14>
  -PiceDiagGradleBin=<TRUSTED_GRADLE_8_14>/bin/gradle.bat
  -PiceDiagGradleUserHome=<RUN>/gradle-user-home -PexpectedDiag=true
exit=1; seconds=20.044; target-resolution=NOT_RUN; syncFlutterAar=NOT_RUN
```

stdout到`Configure project :app`；stderr核心原文（仅删除机器路径／随机服务后缀）：

```text
Build file <HOST>/app/build.gradle.kts line: 9
An exception occurred applying plugin request [id: 'com.android.application', artifact: 'com.android.tools.build:gradle:null']
> Failed to apply plugin 'com.android.internal.application'.
  > Failed to create service 'com.android.build.gradle.internal.services.AndroidLocationsBuildService_<id>'.
    > Could not create an instance of type com.android.build.gradle.internal.services.AndroidLocationsBuildService.
      > Could not create provider for value source AndroidLocationsBuildService.AndroidDirectoryCreator.
BUILD FAILED in 19s
```

命名阻断 **ANDROID_HOST_CONFIGURATION_BLOCKED**，确认层为AGP应用插件的service/value-source创建；既有daemon日志没有更深cause。没有重新带stacktrace运行、没有修环境重试。日志中的`gradle:null`是原报错展示，**不据此断言AGP版本变成null、Gradle8.14不兼容、SDK损坏或缺新工件**；更深根因UNKNOWN。下一最小待Owner决定是允许对该目录服务创建失败做一次有界诊断并保留完整异常链，不新增SDK、Maven或网络权限；本轮未执行此后续建议。

因此正式解析0/1，BEGIN=0／OK=0／PASS=0，15模块×debugCompile/debugRuntime共30项全部NOT_RUN，逐项列在manifest。未声称“只缺两个工件”，也未证明这两项在项目目标中解析成功。assembleDebug实际0/1，**不是build exit1**。APK包名、版本、debug标记、诊断入口、AAR变体、ABI、签名与Hash全部NOT_VERIFIED；无APK可安装，也未安装任何包。

## G6：非作者复核与保护终检

一次非作者GPT-6.1 Sol/high有界只读复核覆盖源码diff、官方来源/字节校验、fixture、SDK审计、真实首失败及终态；非作者不执行工具链、不签产品ACCEPTED。指出的链接审计缺口已补实证；保留SDK误报纠正和真实宿主阻断。结论只支持集中候选交付，**不允许继续正式解析或assemble**。完整本地复核回执Hash在manifest。

终检118721份既有保护文件Hash/bytes一致、上一任务50417份文件集合无增删、498旧refs未改、五历史根HEAD/branch/index/status保持，原153条warning保留。额外36624份本轮复制来源文件核验无漂移；两个新官方POM/JAR亦保持。当前授权源码单列与最终overlay相符。范围仅为具名集合与五根，**不是全盘、手机或运行数据库无变化证明**。

未经授权的旧gradle-8.14-all.zip.part仍原位38302288 bytes，SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`；未复制、执行、解压或清理。保留前轮所有失败；结束后任务所属Java/Dart工具进程为0，不停止任何全局服务或用户任务。没有设备/ADB、SFU/API/DB/RTC、LAN/UDP/TURN/防火墙/UAC操作。

## G7：交付及停止

只提交唯一获准构建源码delta和本报告／manifest。POM/JAR/SDK、原stdout/stderr/daemon、机器绝对路径、设备标识及私密配置全部LOCAL_ONLY，公开manifest只列相对证据名、bytes与SHA；GitHub普通nonforce候选发布后核source/docs parent、Root、文档Blob、完整apps/services递归文件映射与raw字节。没有产品main集成或release。

**PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PHONE_RUNTIME_NOT_RUN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。冻结AC05双独立APP双向媒体、same-call重连、旧JWT首入重入拒绝、撤权COMMIT后媒体≤5秒停止均未因构建工具工作改变。本轮停止，等待Astra独立复审。
