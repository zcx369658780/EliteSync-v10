# EliteSync v10.1.5｜双架构Debug官方工件与隔离构建环境 Astra独立复审

日期：2026-10-23，Asia/Singapore。Reviewer：EliteSync GPT/Astra。

**INDEPENDENT_REVIEW_COMPLETE / PINNED_ARCH_ARTIFACTS_SUPPORTED_FROM_CODEX_RECEIPTS / DIAGNOSTIC_BUILD_GUARD_SOURCE_SUPPORTED_WITH_LIMITS / AGP_ANDROID_DIRECTORY_CREATOR_HOST_CONFIGURATION_BLOCKED / DEEPEST_CAUSE_UNKNOWN / TARGET_DEPENDENCY_RESOLUTION_NOT_RUN / NO_DIAGNOSTIC_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / OWNER_DECISION_REQUIRED / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本轮允许保留已限定证实的**官方依赖获取与诊断构建安全路径候选成果**；**不批准整条Android构建链验收、不批准诊断APK实物身份、更不批准RTC媒体AC05验收**。必须严格区分Astra GitHub直接可核事实、Codex在Owner Windows本地完成的实验回执和未知底层根因。

## 一、权威来源与GitHub对象

- 唯一Owner批准任务：`docs/versions/v10.1.5/OWNER_APPROVED_PINNED_ARCH_DEBUG_BUILD_ENV_COMPLETION_TASK_20261023.md`，Git Blob **`4ec703b39207324d7e13cc3cb176eaa7ed406937`**。上一轮Astra审查 `ice_init_repository_dsl_offline_resolution_independent_review.md` Blob **`c61e6635c3a50dcbcebad25f1ae8e5152a81b02d`**。
- 复审前main：**`7f65d792bc0732f7a09f836ae7349e07343334c4`**，仍为已接受v10.1.4产品+顾问治理文档，不含v10.1.5候选代码。
- 本次固定源码Commit **`1522466faf798b719ccff281de7584f043946437`**，唯一Parent **`294c19f296b4b872dd7da8800d1901c08d209e51`**，Root Tree **`09a4041a7bdca9eb0ffd9e92a724fe8eeb0d17cf`**。GitHub Compare ahead1/behind0且唯一源码变更 **`apps/android/app/build.gradle.kts`**，Blob从`d588562d5fce8a161c2bef8c879a2597b940010f`变为 **`bdb8e241d3e0defd1793c90b5f730c2facd7433d`**；既有Flutter业务/RTC源与services均未被改写。
- 最终交付Commit **`98c2e4e9f548ee924f4e244e23e7b307fb3afe72`**，唯一Parent为上述源码，Root Tree **`bba25cedc58a57c174ae241f0a9aa1b36d26e350`**。比较source→交付ahead1/behind0，只新增：
  - `docs/versions/v10.1.5/FLUTTER_PINNED_ARCH_DEBUG_BUILD_ENV_COMPLETION_REPORT.md` Git Blob **`6c490497e5d5804e6d3b3c48676be4b784a608bf`**；
  - `docs/versions/v10.1.5/flutter_pinned_arch_debug_build_env_completion_manifest.json` Git Blob **`da2c2a82a6d9500597beb1aa18365b2390dc21e0`**。
- Astra分别读取源码/交付/父提交Git Root：**本轮源码与交付的完整apps Tree均`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree均`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**。仅docs子Tree在交付时变化，说明文档交付没有覆写源码；与上轮相比apps因唯一受控build.gradle.kts变化而变化，不能错误标记整个apps源“未变”。Git对象/Changed files/官方公开文档两正文是`ASTRA_GITHUB_DIRECT`。
- Astra**没有**在Owner本地真实下载并hash该两份官方JAR/POM、复核118721件保护文件、运行Gradle、Flutter启动或验证Android APK。所有二进制HTTP200、fixture47/47、复制文件hash、终检、停机为`CODEX_REPORTED_LOCAL_ONLY`，可以与manifest/report交叉核一致性，但不是Astra独立Windows运行通过。

## 二、双架构官方固定工件：有限支持，不是APK或供应链签名接受

前轮实际`:flutter:debugCompileClasspath` resolve失败指向两个确切Flutter engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`的debug架构工件。本轮报告及manifest内部一致：

| 工件 | Codex LOCAL_ONLY POM | Codex LOCAL_ONLY发布二进制 |
|---|---|---|
| `io.flutter:x86_64_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab` | 505B，SHA256 **`ed88c05320bc7ec975800e358dae9b437b0c2e106c871a78efcb494fef50f466`** | POM`packaging=jar`；JAR **112,731,041B**，SHA256 **`4c61bc7c2a7c0eee6d9c9ec2ea3175f6c246fad3034f009aa5badd56c1e5912a`** |
| `io.flutter:arm64_v8a_debug:1.0.0-59aa584fdf100e6c78c785d8a5b565d1de4b48ab` | 508B，SHA256 **`85bd902880a1efcb252c8c0698740c129007dc2feccd75efbe172468b2a6ec7b`** | POM`packaging=jar`；JAR **170,897,085B**，SHA256 **`01b643c934dd9d8703ee148043d5950369aa85181d338f2eacd8b16787a4a9a2`** |

Codex报告两个工件来自唯一批准的`https://storage.googleapis.com/download.flutter.io`精确版本目录；POM/JAR为HTTP200，Content-Length与实物bytes、CRC32C、ZIP CRC、ETag/自算MD5匹配；所含`libflutter.so` ELF64机器类型分别x86_64与aarch64。**以上属于有具体来源与本地回执的支持**；发布者SHA256 sidecar返回404，故`PUBLISHER_SIGNATURE_NOT_VERIFIED`；自算SHA256≠官方签名，不能声称独立外部验证或“整条依赖图已PASS”。旧`flutter_embedding_debug` POM/JAR复用，没有本轮新获取；正式30配置实际解析零次，因此`ARTIFACTS_LOCAL_REPORTED`不等于`GRADLE_ARTIFACTS_RESOLVED`，也不能断言后续无新的缺项。

## 三、构建路径源码审查

Astra直接读取固定新版`apps/android/app/build.gradle.kts`及Git diff：

- 新增仅诊断标志条件下的`iceDiagTaskRoot`、`iceDiagTrustedGradleRoot`路径身份参数，连同旧`iceDiagGradleBin`/`iceDiagGradleUserHome`要求绝对规范路径，明确当前任务run-root、Flutter SDK stage、宿主/module目录、Gradle实际home和环境一致；显式要求`--offline`、Windows、Gradle8.14、三个原固定CLI/core/bin Hash。通过`checkedPath`验证路径存在、相对根关系、禁止可检测symlink，`toRealPath`反映跳转路径不符则拒绝。
- `syncFlutterAar`只有在`isIceDiagnosticBuild`时才引用上述新属性和已核可信bin，保留`assembleAarDebug`、`lib/dev/v1015_ice_diag.dart`、双ABI、Dart flags、AAR坐标与`preBuild`次序；非诊断普通R1、retention、release/profile在Git diff中没有被刻意替换为测试bin或取消原门。**这属于源码静态证明，不是实际普通APK构建负例证明**。
- Codex本地47项真实Gradle fixture exit0，对路径positive/negative、version/offline、env/Hash/flag、非诊断隔离等有覆盖；6类普通构建对照是**静态源码等价比较**，不是6次Android构建；7项静态隔离断言与前轮8/8 Groovy fixture可以保留已有回执但不能重复计入本轮新Gradle宿主测试。
- 关于路径防护：源码代码与本轮LOCAL_ONLY 168220路径的`lstat`非重解析点审计能够提供有限证据；本机未知其他路径或未来配置不由此永久保证无Windows reparse/junction风险。不能说目前已经在真实宿主中执行了完整`validateIceDiagnosticGradle`——下一节Host插件先失败。

**源码结论**：`DIAGNOSTIC_PATH_GUARD_SOURCE_SUPPORTED_WITH_OBSERVATIONS / FULL_HOST_GUARD_NOT_EXECUTED`。本轮未发现必须立刻拒绝的高置信新业务安全P1，但没有足够证据标记完整构建链`PASS`。

## 四、隔离SDK及真实AGP首个阻断

Codex报告从已拥有的本机Flutter/Android/Gradle/Pub/JDK组件普通复制**64864件、约7.034GB**到本版独立SDK stage，并以源/副本SHA及168220个路径lstat检查，不改全局SDK。两份package_config为102+170 entries且本地可解析，Flutter launcher`--version --machine` exit0，与Flutter3.41.7、Dart3.11.5、engine pinned值一致；这些是**静态/启动路径**证据，不证明Flutter module debug AAR/APK编译已就绪。非作者提出的跟随符号链接静态检查缺口在现场额外lstat回执中处理，但原staging helper未重写，未来重用时仍须按同级别审计。

本轮**仅执行一次轻量Android宿主配置**，而不是正式依赖解析：`<trusted Gradle8.14>/bin/gradle.bat :app:verifyIcePathDebug --offline ...`，报告exit1／20.044秒，stdout进入`Configure project :app`后，在`plugins { id("com.android.application") }`应用阶段：
```text
Failed to apply plugin 'com.android.internal.application'
Failed to create service 'AndroidLocationsBuildService_<id>'
Could not create provider for value source
AndroidLocationsBuildService.AndroidDirectoryCreator
```
日志未给出更深根因链。此错误发生在新版诊断Guard方法调用、`syncFlutterAar`、预期的15模块×2配置`resolve()`和APK assemble之前。**不能据`gradle:null`文本断言项目AGP真实版本变null，也不能据此直接归因于Gradle不兼容、路径权限、SDK损坏、Windows锁定、缺dependency或本轮新增Guard。** 当前正确结论是`AGP_APPLICATION_PLUGIN_SERVICE_CREATION_FAILURE / ROOT_CAUSE_UNKNOWN`。若需要因果定位，须在新的Owner有界授权下先对**本次现有LOCAL_ONLY日志/错误回执静态查找更深cause**；不足时只做**一次保留完整`--stacktrace`但不改变构建目标**的轻量host配置诊断，日志LOCAL_ONLY脱敏。任何SDK修改、新下载、改Gradle/AGP版本、强行构建、数据/设备操作必须另走门。

由于这一真实首阻断，**`formalResolution=0/1 NOT_RUN`、`assembleDebug=0/1 NOT_RUN`**。这与“构建命令exit1”、“30配置执行失败”完全不同。不能把两个官方工件下载结果当30配置依赖PASS。

## 五、保护、非作者审查和独立裁决

- Codex报告历史保护基线`118721`件具名文件一致、5根HEAD/branch/index/status不变、`498`旧refs未动；第一根153条Windows long-path warning保持；本次受控source delta单列，旧`gradle-8.14-all.zip.part` 38302288B仍同Hash原位禁用；额外复制源36624件无漂移。**Astra未本地hash，保护判定仅CODEX_REPORTED_WITH_LIMITATIONS；不等于全盘/phone/active DB数据无变化**。
- 一次非作者GPT-6.1 Sol/high高思考静态复核完成，但其最终`passed=false`、明确AGP Host Config阻断，且该审阅发生在Owner本地最终保护回执形成之前；随后主代理完成保护终检。不能简写成“非作者全面PASS”。无RTC/设备/DB/SFU调用。
- 已有v10.1.5消息/缓存/通知等先前限定证据不因构建工具受阻而丧失，但同样不能推动此版接受。冻结AC-10.1.5-05四媒体门：独立两媒体APP双向流动音频、same-call实际媒体重连、旧RTC JWT首次与重入拒绝、撤权COMMIT后正在流动媒体≤5秒停止，全部依旧`OPEN/NOT_RUN`。

**正式裁决：`PINNED_DEBUG_ARCH_ARTIFACT_ACQUISITION_SUPPORTED / DIAGNOSTIC_PATH_SOURCE_FIX_REVIEWED_WITH_OBSERVATIONS / AGP_DIRECTORY_SERVICE_CONFIGURATION_BLOCKED / ROOT_CAUSE_UNDETERMINED / NO_DIAGNOSTIC_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

下步建议只处理**可观察的新障碍AGP service/value-source异常因果链**；初期不再重复二工件下载、47项fixture、Flutter版本测试、Gradle --version、复制7GB SDK、失焦的全部环境重构。若Owner具名允许，推荐第一步审阅现有本地异常全文后在仍缺cause时**最多一次只读增强的宿主轻量配置`--stacktrace`复现**，守住完全离线/无Wrapper/隔离路径/原源码不变、无APK/设备/安全外扩。只有明确真实根因和必要权限后再考虑下一个修复；不得提前切换网络或修改引擎。

**当前不自动下发下一任务，不自动引入源代码主线或R2/v10.1.6。** v10.1.4仍为已接受main产品，v10.1.5`PARTIAL`、AC05`OPEN`、方案A保留。
