# EliteSync v10.1.5｜AGP Android Preferences单变量环境修复与HOST轻量配置 Astra独立复审

日期：2026-10-23（Asia/Singapore）。评审Authority：EliteSync GPT/Astra。

**INDEPENDENT_REVIEW_COMPLETE / AGP_PREFS_TEST_ONLY_ENV_FIX_SUPPORTED_CODEX_LOCAL / HOST_LIGHT_CONFIG_PASS_SUPPORTED_CODEX_LOCAL / SOURCE_UNCHANGED_GITHUB_DIRECT / FORMAL_DEPENDENCY_RESOLUTION_NOT_RUN / NO_DIAGNOSTIC_APK / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / OWNER_DECISION_REQUIRED_FOR_NEXT_RUNTIME / NO_AUTO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

本轮接收的是**诊断专属子进程环境变量冲突修正、25项fixture和单次Android HOST轻量配置**的有界证据；不把该门PASS扩张为完整依赖图、APK产物或RTC媒体安全验收。

## 1. 固定授权、Git对象与独立核验

- Owner唯一正式授权：`docs/versions/v10.1.5/OWNER_APPROVED_AGP_PREFS_ENV_SINGLE_VARIABLE_FIX_TASK_20261023.md`，Git Blob **`8afbe615e7c3be2322917bf6d2fa30a986db0fe7`**；上轮Astra对最深`com.android.prefs.AndroidLocationsException`取证独立复审Blob **`1a1fdb8b18854ccd3b1c37358b2f85bae8e2dab1`**。本轮仅允许修复LOCAL_ONLY test-only子进程helper并最多一次原`:app:verifyIcePathDebug`轻量配置。
- 复审前live `main` = **`60a19ded09de5df8f84bffcb4808e84ca5729b3d`**，仍是v10.1.4已接受产品及顾问文档；待验v10.1.5没有合入main。
- 最终候选Commit **`e24b6d5db8063e1207e9939612352c0f1d8c9bdf`**，唯一Parent **`a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`**，Root **`10cc07ef2589b2bed72fb6dde3cb6cf11525ee5f`**。GitHub Compare对父ahead1/behind0，仅新增：
  - `docs/versions/v10.1.5/AGP_ANDROID_PREFS_ENV_SINGLE_VARIABLE_FIX_REPORT.md`，Blob **`64303ab064e2e081aa8946f52c6a1d9426ecd714`**；
  - `docs/versions/v10.1.5/agp_android_prefs_env_single_variable_fix_manifest.json`，Blob **`9bb27ca6da2b1af6d3a1b5ec71bd8f2a49110282`**。
- Astra直接读取两份Git Root Tree：候选与Parent的完整apps Tree均 **`785822ca072943c5bfefa3ccc37ede01c2af5164`**，services Tree均 **`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**，只docs子Tree发生变化，`SOURCE_UNCHANGED`属于**ASTRA_GITHUB_DIRECT**。本版已审诊断构建source仍`1522466faf798b719ccff281de7584f043946437`，`build.gradle.kts` Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`，本轮未改。
- GitHub报告及manifest原文由Astra独立读取并交叉核对。Astra**不能**访问Owner Windows真实Python helper、环境字典、原始Gradle stdout/stderr/daemon、223580份本地保护原件，也没有亲自执行fixture或Gradle，因此该类结论仅能列`CODEX_REPORTED_LOCAL_ONLY_WITH_NAMED_EVIDENCE`。从报告/JSON交叉吻合不能升级为Astra独立设备实测。

## 2. D0/D1：精准的诊断子进程环境修正

旧具名LOCAL_ONLY helper `runner.py` 原字节SHA256 **`4a40266ae988fbeaa079892aa0654f3555f62f415391463f5d13e3cebd846a8a`**，新**任务专属副本**SHA256 **`1be8f3bbf89fe6d9f2d4fc1168afb85bef286af8d30648c79daff3399a0f013d`**。Codex报告新副本既删除显式赋值，也按Windows不区分大小写的环境变量名规则，从最后要交给子进程的有效字典中完全删除任何`ANDROID_PREFS_ROOT`别名，**不是将键设为空值**；原`ANDROID_USER_HOME`目录身份和值保留，其它已消费的子进程环境值不变。原helper和父进程的Process/User/Machine环境未被修改，普通APP/旧runner仍按原本实现存在。

Codex报告4类输入场景（普通继承、冲突父值、空值、大小写别名）共**25项fixture检查PASS**，包括真实Python子进程对有效环境的读回，以及实际专用调用入口绑定到新helper的身份核验。第一次24项fixture后追加真实子进程/非恒真父字典回执，全部在HOST前完成，不能简写为“25个独立Android Gradle构建”。对直接脚本调用者做了具名定点审查，但未声称全盘调用者穷尽；因为原共享文件未改，未见普通产品源因该修复而变动的Git证据。

**D1限定结论**：`TEST_ONLY_CHILD_ENV_SINGLE_VARIABLE_FIX_SUPPORTED`。这是Codex提供回执的环境控制证明，不是全局系统环境已改变，也不能保证未来其它runner都不发生Prefs多源配置。

## 3. D2：真实HOST轻量配置PASS，但不包含正式依赖解析

Codex记录采用冻结的Gradle8.14、Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、JDK17.0.18.8、AGP8.11.1、项目Kotlin2.2.20及原Gradle隔离工程/任务Root/Home/SDK/JDK。原`:app:verifyIcePathDebug --offline --no-daemon --console=plain --max-workers=2 --stacktrace`和三个诊断Dart flags、四个`iceDiag*`路径属性保持，仅有效子进程环境的`ANDROID_PREFS_ROOT`键被移除。

**本轮唯一HOST运行`1/1`、exit `0`、约`17.112s`**。Codex manifest明确`actualTaskLines=[":app:verifyIcePathDebug"]`、`verifyIcePathDebugAction=EXECUTED_PASS`、`validateIceDiagnosticGradle=PASSED_BY_SUCCESSFUL_DIAGNOSTIC_TASK`、`androidDirectoryCreatorPassed=true`。原`com.android.prefs.AndroidLocationsException`没有再次出现，也没有新阻断；stdout **3,933B**、SHA256 **`fab183b85d0c62669e7e9234abc916e1b4f6c78347b20cd0f40ab92651fd5af2`**，stderr **0B**、空SHA256。完整运行日志仅LOCAL_ONLY。

以上支持：**先前由Prefs多源注入引发的Android HOST配置阻断，在本次限定环境和原目标下已经解除，并且轻量action确实执行成功。** 它不证明所有正式编译环境完全READY：`resolvePinnedDebugInputs`对15模块×2配置本轮**0次**，`syncFlutterAar` **0次**，`:app:assembleDebug` **0次**；诊断APK/包名/签名/ABI/Flutter诊断入口实物仍`NOT_VERIFIED`。不得将此HOST exit0写成“APK构建exit0”、“正式依赖图PASS”或“RTC真实媒体PASS”。

## 4. D3/D4：非作者审查、缓存新增分类与历史保护限制

Codex本地一次非作者GPT-6.1 Sol/high有界静态审阅，无必须修正项；所审为helper精确差分、环境继承负例、原目标CLI和新输出、受保护范围及补充缓存分类。非作者没有亲自重跑Gradle/fixture、重Hash全量本地文件或独立完成GitHub最终回读，不能称它对整个v10.1.5签了ACCEPTED。

本轮Codex报告以Windows大小写去重口径保护**223580份**具名基线文件，**500个**旧refs、五历史根HEAD/branch/index/status、SDK/Pub/Gradle/旧日志及`.zip.part`原件身份均保持，第一历史根153条既有Windows长路径warning仍在。Gradle轻量HOST运行合法产生**7项旧缓存/lock元数据变化**和**820项新派生文件**；所以不能称旧任务目录“无写入”。初次新文件分类终检因为816件Gradle Kotlin DSL生成缓存/AGP `FakeDependency.jar`空ZIP等被标未分类而exit1；Codex保留该失败、审查生成物来源、校正分类并对新增文件逐一hash；它不是修复产品源码、也不能抹掉初版FAIL。内含22B `FakeDependency.jar`属于AGP构建环境**空ZIP占位**回执，不是新增下载的正式Maven依赖，更不是可安装APK。此处来源解释由Codex的本地静态AGP class抽查支持，Astra并未亲手核二进制。

保护证明严格局限于**具名集合和五历史根**，不等于全盘、实际手机或运行中数据库逐字节无变化。曾有一次SSH读ref连接失败未被作为产品或Gradle失败，该过程没有消耗HOST预算，旧失败回执保留。本轮未联网下载、未升级SDK、没有设备/ADB/DB/SFU/Room.connect或网络设置更改的结论来自Codex本地受限执行记录。

## 5. 正式裁决、下一授权边界

**本轮独立裁决：`AGP_PREFS_TEST_ONLY_ENV_FIX_SUPPORTED_WITH_OBSERVATIONS / HOST_LIGHT_CONFIG_PASS_CODEX_RECEIPT_SUPPORTED / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。**

这是一个明确的Gradle环境阻断收口，不需要再次重复Prefs诊断或25项fixture来论证相同HOST成功结果。后续应依Owner另外授权，在**保持本次验证后的子进程环境、固定Gradle8.14及原SDK/依赖身份**条件下，执行一次**15模块×2配置**的真正离线依赖图解析，明确区分全部配置PASS、遇到新精确依赖缺项或其它运行错误；**该后继预检并未因本次HOST PASS而自动获许可**。有必要先核正式解析器采用同一清洁环境，避免子进程helper路径不同又触发旧Prefs异常；旧两架构同engine Flutter POM/JAR此前已有Codex LOCAL_ONLY获取回执，不能保证剩余29配置没有新缺项。

是否继续到APK构建必须在正式解析全部PASS及完整实际SDK/Gradle编译门验证后另行由Owner授权；此处仅提下一门建议，不创建Codex任务、不修改本地SDK或Git产品源码。

冻结AC-10.1.5-05四项硬门仍全部OPEN：双独立真实APP双向媒体、same-call重连、旧RTC JWT首入/重入拒绝、撤权COMMIT后流动媒体≤5秒停止。方案A继续，`main`仅v10.1.4产品接受，v10.1.5`PARTIAL`、无诊断APK和真机媒体证据。

**本轮仅GitHub文档复审、状态归档，不执行本地Gradle、SDK变更、依赖解析、APK构建或真机RTC。**
