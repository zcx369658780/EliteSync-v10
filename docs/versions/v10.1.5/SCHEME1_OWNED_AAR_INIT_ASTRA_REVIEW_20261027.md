# EliteSync v10.1.5｜方案一项目自有Flutter AAR init修复｜Astra独立验收

日期：2026-10-27（Asia/Singapore）

**SOURCE_LEVEL_JAVADOC_REPAIR_ACCEPTED_WITH_OBSERVATIONS / SOURCE_LEVEL_JAVADOC_REQUEST_REMOVED_BOUNDED / PUBLISH_GRAPH_NOT_EXECUTED / AAR_POM_RUNTIME_NOT_PROVEN / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED**

## 1. 独立验收范围及证据等级

Astra直接使用GitHub连接器读取最终候选与源码Git Commit/唯一Parent/完整递归Root Tree、代码差异、11个修改/新增源文件、受控Flutter AAR init副本、来源/许可/UPSTREAM.patch、Python验证函数与测试定义、最新实施报告/Manifest、前一版报告/Manifest及冻结计划。候选仅在源码Commit上追加报告与Manifest；旧报告正文是新报告的精确前缀，Manifest中的 `previousDelivery` 对象与旧Manifest一致。

Astra未在本轮运行本地Python、Gradle/Groovy/Kotlin/Flutter、APK/设备、RTC、网络观察器或Gate2；也没有直接读取或重算共享本地Flutter SDK的原始Hash、LOCAL_ONLY证据、测试stdout/stderr或保护文件全量原证。应严格区别：
- `ASTRA_DIRECT_GITHUB_STATIC`：GitBlob/源代码/条件分支、受控副本中两处移除、来源和许可材料在仓库中存在、提交及Tree不变、历史文档在远端的继承关系。
- `CODEX_REPORTED_LOCAL_EXECUTION`：37项和44项隔离测试的退出码/日志Hash、进程/socket/DLL审计0、共享SDK原字节不变、历史资产和资源终态。
- `LOCAL_ONLY_RAW`：Flutter安装源、实际本地许可/版本回执、测试stdout/stderr、保护文件/旧claim/旧APK/SQL/下载partial。

本裁决只接受**源码级有界修改**，不等于本地Jar/Gradle原证独立复算或产品整版接受。

## 2. 交付身份与保护边界

- 近期读取live main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5`，产品接受基线仍v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 最终候选 `da5ce628a499c97e916e780e2cf795353745c147`，唯一Parent `50d79396195ed8b4b86c218584ab59864ad600be`，Root `e140a196942c7b1aebf8bf90871e34afaec49501`。
- 实际源码Commit `50d79396195ed8b4b86c218584ab59864ad600be`，唯一Parent `3d0c656d59e8621ffa6a935313b5cd4c860a16b1`，Root `d3c8e2cfbe28e3a1a4e13ac217b868f5cbb7ae20`。
- 候选与源码Commit的apps Tree均为 `e6bff4bc8e359e6afe80c02f25212ee8b6195eab`，services Tree均为 `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。完整Root Tree均6631项，未截断。
- 源码相对静态诊断候选只修改/新增11个授权路径；最终候选相对源码Commit仅追加/更新 `IMPLEMENTATION_REPORT.md` 与 `artifact_manifest.json`，合计13个变更路径。
- 最终报告Blob `2f2b025d274cb79bafb89bb9b0374b4575786b06`；Manifest Blob `c56644a04b88f2f02bd7369724e4d6c7aff65637`；冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03` 未变。
- 原报告Blob `71e039051ba0c6205f496444bc466d71f11a6fff` 是完整前缀，上一版Manifest Blob `d91a50d3653ef6304b4f45e53ddb4a242dbce284` 的JSON对象作为 `previousDelivery` 精确保留。

## 3. 方案一最小源码修复

### 3.1 来源追溯

新增项目跟踪目录 `apps/android/scripts/owned_flutter_aar_init/`：`aar_runtime.init.gradle`、`SOURCE.json`、`FLUTTER_LICENSE`、`UPSTREAM.patch`及局部 `.gitattributes`。

- `SOURCE.json` 声明源文件原SHA256 `b6b870954405c5d52afea183bb51b3220100c234401142d8c1bf3e2410cee2c2`、Flutter安装版回执3.41.7、框架修订回执与BSD-3-Clause许可；这是Codex本地来源核验的声明，不是Astra重新下载/确认对应官方发布签名。
- 受控副本Git Blob `7654d90a8b2cc3fd31fafcb18fe589624486a3a2`，来源说明Blob `3a39b994c2ef705bf0247c57ae77fb331fd9b1bc`，补丁Blob `1cf1b5de415a0a9aa6190b324f9cb5ae4f1f40c3`，许可Blob `af093156acc618463cd3f5a502ec6481482897bc`。
- `owned_aar_init.py` 包含固定上游/衍生/许可Hash、双分支唯一定位、确定性字节推导、来源与许可比对和新库存合同。仓库副本的两处 `withJavadocJar()` 已移除，并保留有/无flavor两分支的 `withSourcesJar()`。
- 原 `maven-publish`、AAR注册、`from component`、发布finalizer与Flutter插件AAR关系在受控副本中没有被全局禁用。字节级存在不等于运行时发布图及AAR/POM产物已验收。

### 3.2 确认被消费者使用

直接GitHub源码查看 `apps/android/app/build.gradle.kts`：
- `ordinaryR1Runtime = isV1015R1LocalBuild && !isIceDiagnosticBuild && !isV1015R1RetentionProbe`；仅该条件下通过 `validateOwnedRuntimeAarInit` 选择项目自有固定文件，并加载 `-I=${aarInit.absolutePath}`、传 `-PelitesyncOwnedAarInit=v10.1.5-ordinary-r1-runtime`。
- 其它R1 ICE/retention分支仍使用原Flutter SDK init；非R1继续其原Flutter CLI路径。
- Kotlin静态门禁检查Flutter SDK原init及LICENSE和本地副本、LICENSE、SOURCE.json、UPSTREAM.patch的固定Hash、路径范围/符号链接/reparse条件；没有缺文件/Hash不匹配时默默回退原SDK init。
- 原Gradle8.14 / offline / 禁用工具链自动下载 / 不使用Wrapper fallback 的既定参数仍可在源码中看到。静态Kotlin文本检查不代表实际Gradle配置编译已经通过。

`offline_debug.py` 的preflight在真正的观察器或子进程之前校验 `ownedAarInitContract` 及六个 `REQUIRED_PROJECT_INPUTS` 的inventory和definitions Hash，并使用 `verify_files` 复核受控来源。原可信构建库存不能自动用来验收新构建输入：`NEW_BUILD_INPUTS_REQUIRE_NEW_TRUSTED_INVENTORY`。

以上符合Owner所授的方案一范围，未看到直接违反受控源、条件选择与禁止下载的明显新增源码问题；结论限于静态。

## 4. 测试证据与不足

Codex报告：新受控副本测试先3例RED exit1，随后37例GREEN exit0、无skip；关联离线入口44例exit0、无skip；两套测试报告的真实process/socket/native-DLL审计事件均0。Astra直接审阅测试定义：它们覆盖来源/Hash和许可、flavor与no-flavor、重复/损坏定位、符号链接和路径、受控init实际被选择的源码表达式、新库存预检及旧claim防重入、UDP/TCP分类强停止等。

但：
1. 测试采用Python字节/AST静态断言及完全mock的执行生命周期；没有执行Groovy、Gradle Kotlin DSL、Flutter AAR任务或消费真实POM。
2. 测试中的SDK源fixture是由受控副本反向复原并验固定SHA形成；这是一种有界校验策略，而不是Astra对独立本地SDK原件的亲自运行核验。
3. 新修改过的 `build.gradle.kts` 是否能在真实Gradle中完成配置，是否会遭遇task graph/AGP发布变体的其他错误，尚无运行证据。

因此接受“有界源码修改和隔离测试交付”，**不接受** `PUBLISH_GRAPH_PASS`、`AAR_POM_RUNTIME_PASS`、`DOKKA_NOT_EXECUTED` 或 `TCP_ROOT_CAUSE_FIXED`。

## 5. 历史证据与持续门禁

Codex保护报告指出开工和结束核验26784个具名历史保护文件、5历史根、524个受保护refs及52个旧根证据文件一致；共享SDK源/许可/版本回执原字节不变，旧claim Hash `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8` 不变。这是Codex本地报告的**具名范围证明**，不是Astra对整盘文件或实时运行环境亲自审计。

旧Gradle下载partial 7,941,328字节及SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、原SQL/APK、旧refs及LOCAL_ONLY日志不清理。

真实构建历史预算1/1已耗尽，当前剩余0。此候选没有实际运行Gradle/Flutter/AAR/Kotlin、APK、设备或实时网络观察器；Gate2新启动/Writer/Serializer均0。历史37套件、条件Sandbox SDK、Producer/libs.jar/30 Configuration.resolve仍NOT_RUN。真实Push、AEC、最后可闻波形、完整native handle、真实15/30天/物理30天清理、ICE诊断与旧guest等未关闭项不因本源码修复而关闭。

## 6. 最终裁决

**`SOURCE_LEVEL_JAVADOC_REPAIR_ACCEPTED_WITH_OBSERVATIONS`**：对方案一的项目自有来源、许可证/Hash记录、两个Javadoc请求的移除、普通R1构建入口的有界切换、受控预检及Codex报告的37+44项隔离检查予以局部接受。

**整版仍为** `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / PUBLISH_GRAPH_NOT_EXECUTED / AAR_POM_RUNTIME_NOT_PROVEN / BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED`。

不因静态源码调整而声称当次原Dokka调度边已确定、外部TCP已消失、发布图/依赖已正确或真实APK构建成功。任何后续Gradle构建、运行时验证、网络停止条件变更、产品main集成或v10.1.6均须Owner另行明确授权。本次不创建/派发新任务。
