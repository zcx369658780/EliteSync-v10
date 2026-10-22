# v10.1.5 Flutter Debug Embedding精确依赖与诊断构建门报告

2026-10-22。**PARTIAL / V10.1.5_DEBUG_EMBEDDING_STILL_BLOCKED / NO_APK / PHONE_RUNTIME_NOT_RUN / AC05_OPEN / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_REVIEW**。

官方精确embedding的POM/JAR已经取得并核验；**隔离依赖解析和诊断APK正向构建未完成**。实施者在缓存复制完成尚未确认前启动了解析，Wrapper触发本任务外的Gradle分发下载，立即具名终止并按任务停止条件不再重试。诊断APK正向构建 **0次**，新诊断APK **未产出**。这属于实施顺序/工具引导错误，不是官方embedding不可得，也不是RTC产品故障。未安装APK、操作设备或启动服务。

## S0. 权威、固定源码与保护基线

唯一任务固定Blob `38d83feca11946685d42c9f75b15ad8d207692c5`，从签发后main固定路径全文读取，并对raw原字节重算Git Blob匹配。Astra独立复审Blob `6c736933e96e32b25e57a4318aa760049e5ed758`同样全文读取和核验。实时main核实为 `0cb38cce0625319a113f043c63b8462dda699e90`，Root `f4be4a11b140bc2a92a8c0b3468e934cbc5f0569`。main不是本轮诊断产品源码，未用其覆盖连续候选。

| 对象 | 身份 |
|---|---|
| 固定诊断source commit | `24ddf05875d8d4abad7a6b473f882698c9885c2a` |
| Source唯一Parent | `62f0cd6d6df80f2f22855c0f75fd67ff52c753a7` |
| Source Root | `2c656957e1c229ca30f7c07b173bcb1062310d2c` |
| apps Tree | `72c617cf86d5c653dd722accde340b51d2e085eb` |
| services Tree | `1e1e20bb3500bedb1a521e5f2ddeece915d09424` |
| 本轮文档候选唯一Parent | `8bee827c20c26c4ec954b774c011f09238ec59b3` |
| 继承交付Root | `81aad417e50f6d7a180135248ccdd73da9b69c6f` |
| 原报告 / manifest Blob | `18ef944586765231ca7b003d50e15ad3165271de` / `bae88478daa065c16b8fd5b69caf4c90240a7359` |

候选分支 `codex/v10.1.5-ice-debug-embedding` 从干净8bee连续建立。**SOURCE_UNCHANGED**：本轮只新增本报告和manifest，不修改业务代码、构建源码、SDK lock、冻结AC、ACTIVE_STATE、旧报告或Astra裁决。

SDK直接读取现有engine.version及flutter.version.json：Flutter **3.41.7**、Dart **3.11.5**、engine **59aa584fdf100e6c78c785d8a5b565d1de4b48ab**、framework revision `cc0734ac716fbb8b90f3f9db8020958b1553afa7`。lock确认LiveKit2.10.0、flutter_webrtc1.6.0、webrtc_interface1.5.1。已有工具Gradle8.14、AGP8.11.1、Kotlin2.2.20；没有下载/升级Flutter SDK、切换engine或改锁文件。

原确证错误仍为 `:connectivity_plus:extractDebugAnnotations` 离线缺 `io.flutter:flutter_embedding_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab`。定点读取原Gradle io.flutter下载缓存，同精确debug坐标目录不存在；没有将SDK flutter.jar复制、改名或重包冒充Maven工件，也没有全磁盘搜索或覆盖原缓存。

## S1. 官方精确工件与供应链证据

允许源根且实际成功请求的工件源：`https://storage.googleapis.com/download.flutter.io`。

精确路径前缀：`io/flutter/flutter_embedding_debug/1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab/`。下载器拒绝重定向，POM/JAR均HTTP200、无重定向；只访问该坐标POM、POM声明的二进制和相应SHA256 sidecar，每URL一次、未重试或切镜像。完整URL、响应类型、ETag、存储校验值及退出状态在manifest中。

POM的group/artifact/version精确匹配；**packaging=jar**，因此正式下载的是JAR，**AAR不适用**。本轮不编造一个AAR坐标。JAR为436个条目的完整ZIP，CRC检查通过，包含 `io/flutter/embedding/engine/FlutterEngine.class`。未擅自下载POM声明的第三方依赖；尚未进入解析，不能推断依赖图已完备或额外缺项是什么。

| 官方文件 | HTTP | bytes | 实算SHA256 |
|---|---|---|---|
| flutter_embedding_debug-1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab.pom | 200 | 2542 | `437cf27a8aa1829c07f81f43e0468a5fa05cef7dc21451cabd51b7a6914341ff` |
| flutter_embedding_debug-1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab.jar | 200 | 1541793 | `f6cb78578df77875f18f4d6c3bd29066288109935007e59d83e53ec85a8ce745` |
| flutter_embedding_debug-1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab.pom.sha256 | 404 | — | NOT_AVAILABLE |
| flutter_embedding_debug-1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab.jar.sha256 | 404 | — | NOT_AVAILABLE |

POM content-type为application/octet-stream，JAR为application/java-archive。实际 `x-goog-hash` 提供 **CRC32C**，两份文件均按字节计算匹配；ETag字符串也与所算MD5一致，但不把ETag或CRC32C解释为发布者签名。两份SHA256 sidecar均HTTP404，记 **PUBLISHER_HASH_NOT_AVAILABLE**；自算SHA256只固定本次下载字节身份。没有发布者签名验证结论。此前进度中将响应校验泛称MD5的表述不精确，此处以实际CRC32C响应和独立计算结果为准。

所有工件保存在 **LOCAL_ONLY本任务专属official-maven目录**。没有上传JAR/POM二进制、APK或私密配置到GitHub；公开仅源URL、精确坐标、文件大小与校验摘要。

## S2. 隔离环境、实际命令与停止原因

任务专属Gradle用户目录通过**普通文件复制**继承已存在的依赖缓存和Gradle8.14分发，不使用指向原缓存的可写链接。复制任务原退出0。本轮原始全局依赖缓存3184个文件、约1.362GB，已做前后hash与文件集合比对。

专属init脚本只为Gradle启动后的settings/project repositories添加同engine `io.flutter` exclusiveContent，指向下载的正式本地Maven目录，不生成POM、不替换二进制、不修改工程或用户全局配置。计划顺序为：复制并验证现有工具 → 固定依赖本地解析 → 唯一诊断debug正向构建。**实际执行顺序有误：解析在复制完成尚未确认前即启动。**

唯一实际依赖预检命令（LOCAL_ONLY模块.android目录，环境变量仅当前子进程）：

```text
GRADLE_USER_HOME=<task-isolated-home>
FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com
gradlew.bat resolvePinnedDebugInputs --offline --console=plain --no-daemon
```

**原exit=1**。任务拟定的resolvePinnedDebugInputs不会调用assembleDebug/Room.connect，但Wrapper引导发生在Gradle/init脚本之前，`--offline`不能约束Wrapper本身。stdout实际出现：

```text
Downloading https://services.gradle.org/distributions/gradle-8.14-all.zip
```

具名本次进程线程栈为 `org.gradle.wrapper.Download.downloadInternal` → `Install.createDist`，**没有进入本轮依赖解析任务**。因此不能声称exclusive repo已被执行验证、同engine传递依赖已解析或离线完整性PASS。该URL不属于本任务准许下载的官方Flutter Maven根。发现后先核对进程归属，仅终止本次Wrapper进程；未停止全局Java、Gradle、ADB、Docker或其他用户进程，亦未更换下载源再试。

隔离目录中保留 **38,302,288字节zip.part**，SHA256 `f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`，源于未批准的Wrapper尝试，**不作为可信输入、不执行、不删除**。不能称“零下载”；最终重定向主机未观测，不能猜测。另224,116,304字节完整ZIP与原有分发缓存SHA256一致，属于继承复制，不将它计为新获批准的下载。新增文件及原件均保留。

准确分类：**OTHER_BUILD_FAILURE_WRAPPER_BOOTSTRAP_OUTSIDE_ALLOWLIST / STOPPED_NO_RETRY**。官方embedding本身可取得，尚无证据证明依赖图需要未授权第三方来源。任务的唯一诊断 `assembleDebug` 正向构建实际 **0/1**，不是“构建exit1后再补包重跑”。没有新的诊断APK，故没有可供核验的诊断packageId、versionName、debuggable、签名或hash。

原拟正向命令仅记录为 **NOT_RUN**：

```text
gradlew.bat :app:assembleDebug
  -PflutterDartDefines=ELITESYNC_ICE_DIAG_TEST_ONLY=true;ELITESYNC_V1015_LOCAL_BUILD=true;ELITESYNC_V1015_R1_LOCAL_BUILD=true
  -PrelationshipDualDeviceBuild=true --offline --console=plain --no-daemon
```

其中defines应作为单一引用参数传入。未为绕过阻断改debug为release AAR，也未调整任何诊断隔离构建源码。

## S3. 产物、最小验证与普通包保护

| 项目 | 本轮结论与层级 |
|---|---|
| 官方POM/JAR精确坐标、ZIP、SHA256、CRC32C | LOCAL_ACTUAL_VERIFIED；发布者签名NOT_VERIFIED |
| Flutter/engine/lock与产品Tree | LOCAL_ACTUAL_VERIFIED / SOURCE_UNCHANGED |
| Gradle同engine依赖完整解析 | NOT_RUN_BEFORE_WRAPPER_STOP |
| 诊断debug AAR/APK | NOT_BUILT；本轮正向构建0次 |
| 诊断APK `com.elitesync.v1015icediag` / `10.1.5-ice-diag-test` / debug / ABI / signer | EXPECTED_FROM_FIXED_SOURCE_ONLY，产物NOT_VERIFIED |
| 上轮诊断20项、相关普通回归93项 | **REUSED_VALIDATION**；本轮未重跑，不改称本轮通过数量 |
| 上轮5项真实Gradle负例 | **REUSED_VALIDATION**；release/profile/缺local+R1/混v1014/混v1012明确拒绝，普通包native门负例来自旧定向测试 |
| 原普通R1控制包 | **REUSED_VALIDATION**；包名com.elitesync.v1015r1dev、10.1.5-r1-dev，SHA256 `7131b57c6c8f755197573e791d4bfa9d5db4ce07862726d24dace445f8b904bd`；未覆盖/重新构建/安装 |
| 诊断与普通包实际签名对比 | NOT_RUN_NO_DIAGNOSTIC_APK；不能只凭源码包名宣称正向隔离验收完成 |
| 新测试、手机/AVD/ADB、Room.connect、麦克风/摄像头 | 全部NOT_RUN，0安装/0call/0连接 |
| DB、Laravel、guard、SFU、网络监听/UDP/LAN/TURN/防火墙 | 全部未操作/未启动 |

固定源码原白名单、30秒采样/750ms等待、epoch停止、连接前挂载、无采音、native+Dart双门、独立入口与debug AAR坐标均未修改。旧普通包、旧诊断失败、所有测试修复历史和Astra评审原件仍保留。

## S4. 一次非作者复核、保护终检与交付

独立GPT-6.1 Sol/high只读复核新来源、校验摘要、隔离脚本和Wrapper失败材料。复核确认POM/JAR坐标/bytes/SHA256与ETag对应MD5匹配；指出不能将storage metadata称签名、init脚本不能约束Wrapper前置下载、部分下载不能隐去，原20/93与五负例只能复用。复核未执行网络/构建/设备，ZIPCRC仅核对实施者回执；首次读取时终检回执尚未生成，因此**历史保护最终逐hash核验由主实施者完成，不冒称审查者重验**。没有第二次审查、没有Astra ACCEPTED。

实际保护终检：

- **1441份**具名历史原证bytes/SHA256全部一致，包含原1332及上一轮新增原证；不将旧数字当全资产总数。
- **3184个**原全局Maven依赖缓存文件hash及集合均一致；连同SDK身份文件、pubspec/lock/private env共3190条保护记录均一致。
- 五个历史根HEAD、分支、index与status一致。原Windows长路径status警告仍153行，不宣称未登记缓存或未知资产逐文件验证。
- 开工态 **494个旧refs**均未移动；新候选仅增加自己的分支。未reset/clean/stash/rebase/force/prune、未删SQL/APK/备份/volume。
- 本轮只停止了具名Wrapper临时进程；没有启动设备或产品服务，所以不虚构“服务运行后停止”的回执。

候选只新增本报告与manifest，从8bee直接演进；apps/services与固定source完全相同。普通nonforce发布后，最终commit/唯一Parent/Root、两文档Blob原字节以及完整产品Tree映射通过独立REST/raw回读，结果以LOCAL_ONLY `delivery-remote-readback.json`及用户交付固定链接为准。自包含文档不写自己的commit hash，避免循环自哈希。未集成main，未修改当前主线产品。

## S5. 剩余门与停止状态

采用受阻终态：**V10.1.5_DEBUG_EMBEDDING_STILL_BLOCKED / NO_APK / AC05_OPEN / OWNER_DECISION_REQUIRED / AWAITING_ASTRA_REVIEW**。本轮具名原因是Wrapper引导下载越出允许源的实施错误；**不把它写成官方精确embedding缺失、已定位的依赖图缺陷或RTC产品故障**。

如Owner在Astra复审后决定重派，最小后续条件是：先证实隔离目录中的现有Gradle8.14分发复制完整且可完全本地启动，确保Wrapper不再尝试分发下载；随后在新的明确有界执行授权下，完成固定官方embedding的解析与一次debug正向构建。尚未知额外缺项，不预先要求下载native engine/第三方依赖，也不需要据此扩大RTC/手机/网络权限。本轮不自动重试、不主动安装、不接续媒体测试。

**SOURCE_UNCHANGED / PHONE_RUNTIME_NOT_RUN / AC05_OPEN / NO_ACCEPTED / NO_MAIN_INTEGRATION / NO_R2 / NO_P2 / V10.1.6_NOT_STARTED**。完成集中材料后停止，等待Astra独立复审及Owner决定。
