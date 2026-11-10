# EliteSync v10.1.5｜G2最小闭合依赖Seed与SDK剩余写入边界——定向静态决策任务

**状态：OWNER_APPROVED_FOCUSED_OFFLINE_DEPENDENCY_CLOSURE / PUBLISHED_FOR_OWNER_MANUAL_DISPATCH / ZERO_GRADLE_ZERO_G2_CLAIM / CAP_UNCHANGED / NO_G2_RUNTIME_RELEASE**

日期：2026-10-27（Asia/Singapore）
权威库：`zcx369658780/EliteSync-v10`

Owner：最终产品方向、重大不可逆及新运行预算authority；已明确授权本次聚焦的定向任务。Astra：Project Lead/Planner/Orchestrator/Independent Reviewer/Current-state Manager，负责正式下达与之后独立验收。Codex：Owner在本地Work→Codex工作流**手动派发后**于隔离工作面自主实施；任务公开发布不等于已派发、已执行。

## 0. 唯一目标、阶段停止与预算硬边界

前一轮`68feee04`已把共享缓存/SDK写隔离问题从广谱调查收敛到7项未解决集合。**本任务不能再重复一轮18族广谱mock普查**，须集中交付以下两种实际决定所需的可审阅证据：

A. 利用**已存在、已pin的Gradle 8.14源码/本地离线metadata/artifacts和冻结6ca G2配置合同**，计算一个能覆盖`assembleAarRelease --dry-run`配置与插件task-graph解析需求的**最小可证明闭合`modules-2`只读依赖seed**：包含恰当module坐标、版本、变体属性、Gradle Module Metadata/POM/BOM/parent、transitive边、artifact文件、plugin marker/implementation和必要索引，给出精确Hash清单、闭合证据、大小/峰值；若真实静态解析不足，必须写出缺口和保守容量上界，不得声称已实现Gradle实际变体解析。
B. 对真正可能妨碍G2的**剩余Flutter/Dart/Android SDK/NDK及插件隐式写入**做有源码依据的定点closure/risk-map，明确在原有512MiB上限内是否可构造可审查的私有写面与OS只读源方案，若不能则提交**一份带容量数字和独立OS隔离条件的备选决策包**给Owner。

**本任务执行预算绝对为0**：真实Gradle（包括`--version`、`--help`、`--dry-run`/Wrapper/init）、JVM/Java、Flutter/Dart/AGP/Kotlin执行、真实Windows observer/Job/进程/网络试验、G2 Popen或G2.claim创建与改写、AAR/POM/APK/ADB/RTC、Gate2/Writer/Serializer、Push/后端/DB/生产全部0。可以做带范围的**只读文件/Hash/JAR ZIP中央目录或XML/JSON/POM/module元数据静态解析、Python纯静态/mock、任务私有小型输入副本**，绝不加载/执行Jar/Gradle/插件字节码；不可联网补依赖、删除/更新缓存、下载/升级软件、调整系统安全配置。

**磁盘cap不因本轮授权改变：** 任务新私有**逻辑文件与可测分配空间**以原有512MiB为上限（536,870,912 bytes），任务执行前、重要副本前及尾部均记录已拥有目录逻辑量、实际allocated可取信息和卷可用空间，说明外部并发活动/测量误差。超过上限或物理增量不明时STOP，**不要为了凑齐所有modules-2而直接复制现有1.36GB cache**。可以仅只读分析大于cap的已有完整原件，不复制。只有Owner对具名容量新上限另行批准，才能设计需要超过cap的后继实际seed实施。旧G2已有最多1次授权，**按上一份LOCAL_ONLY报告仍为0/1、claim不存在，但本任务绝不可使用**；需从本地只读fresh核实，不能把远端报告当实时账本。旧APK=耗尽1/1、旧G=耗尽1/1、旧A=NOT_RUN_GATE_CLOSED、Gate2未授权，均永久保持。

本任务成功交付应是**静态依赖/空间决策包**，不是`G2_READY_FOR_POPEN`。完成后Codex停止等待Astra验收，不自动回原G2跑图，不自动建后继任务或合main。

## 1. Fresh authority与固化源身份

执行前重新GET正式任务、live main/Root、`docs/workflow/ACTIVE_STATE.md`、冻结v10.1.5 plan、原G2合同及执行预算、286 G2 preflight、68fe写隔离报告/索引及Astra独立验收、6ca源级接受及完整Git Tree；复核SHA/Parent、保护根/claims和旧证据，而非把下列prepare时身份误称实时值。

- 本任务发布前main：`fdf7812d07006503b81a88020e4d7f03a6b33743` / Root `4a4ca4a1328f97baa3b21510aefd7e8a4a73e456`；仍已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 最新待续**未接受候选**：`68feee0443991696385337c318348ead5306e1ef`，唯一Parent `286eb20d1d6af2e76423cfbd3253880f47c9ae16`，Root `93fc0d1837ff807bf40fc6c4cb55e9d8bb89b847`，完整apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。68fe新增报告Blob `8b75df6af8560b846f57661dcce144d22d9f3100`，索引Blob `a5c2129376299126a1d0ede52f2616b74cd0c3d2`，两份静态政策/mock源Blob `7fc97fe09a5949f3e46c25365e87e3aea6c24c7f` / `92b61b90fcc6f153280b3657031ed081f91ab539`。
- Astra最新裁决`68FEEE04_BOUNDED_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`，审查文件`astra/v10.1.5-68feee04-write-isolation-review-20261027:docs/versions/v10.1.5/68FEEE04_G2_WRITE_ISOLATION_ASTRA_REVIEW_20261027.md`，Blob `40a772e4a86f248b04b49bfb245d8f671e3ec751`，该审查分支prepare时HEAD `7a99bc408e1de7c9bca43508917061f6c001509f`。
- 唯一先前Owner批准的受控实际G2`assembleAarRelease --dry-run`合同：`docs/versions/v10.1.5/V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md`，Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`。**本轮只是该合同的先决证据工作，不复活/改变其执行权。**
- 6ca独立`SOURCE_LEVEL_ONLY`接受的源码commit`71ab58533270dd8b3a1270a3452a82b4f426e361`；最终候选`6ca09a66c0ef9619df7a3d7d4b089516f409954f`。精确owned init schema2、7项REQUIRED_PROJECT_INPUTS、Gradle8.14、Flutter3.41.7、tooling pin、插件/source SHA是冻结消费合同。缓存及SDK现值与旧pin需**分出immutable源码、mutable runtime state及未审字段**。
- 原68fe结果是：本地只读报告称18族矩阵和107份状态分类，1098份独立副本共8,277,854 bytes，完全mock 56项通过；老sealed `modules-2` **3183份、stat合计1,362,106,905 bytes**，大于512MiB；空readonly-seed占位符，精简依赖闭合未知，Android/Flutter SDK隐式写入未知，原整轮allocated增量未知。数字仍属`CODEX_REPORTED_LOCAL_ONLY`，如需引用需当前具名复核，不得提升为Astra本地证明。

## 2. A：最小闭合seed——精确静态求解，而非简单JAR筛选

应先对**真实G2离线配置入口**列出固定源集合：普通R1 Kotlin CLI参数、`.android/settings.gradle`与pluginManagement includeBuild、Flutter loader、gradle.properties/catalogs、buildscript/plugins、module+14 native Android plugin的实际build文件、source/vendor/local plugin路径、AGP/Kotlin/Groovy/plugin marker及锁定声明（若存在）。只读工具可访问**已pin离线原件**，不得以网络、执行Gradle或臆测版本补足。找不到必需源则`DEPENDENCY_CONFIG_SOURCE_NOT_PINNED`并阻断对应闭合断言。

1. **构建解析边/来源账：** 从实际脚本声明及离线`modules-2`metadata识别根到transitive节点；记录`group:module:version`、plugin marker→implementation、Gradle variant attributes/capabilities、module metadata variant选择、POM父继承/BOM/dependencyManagement、Maven exclusion/optional/relocation、平台约束/动态范围、artifact type/classifier、repository identity、离线可命中位置。为每条边注明来源文件Hash、原文中允许安全公开的坐标、方法及`PROVEN_STATIC/INFERRED/UNKNOWN`；循环与多版本选择要有确定性规则或保持UNKNOWN。版本或variant由代码执行/Gradle内部规则才能决定时**不要假定算法一致**。
2. **必需字节闭包：** 区分`metadata needed for resolution`与`artifact bytes needed for config/selected task registration`、`possible task-action dependency`。若无法预知被选task，不得因为本次只是`--dry-run`就删去配置期间可能需要的classpath/plugins资源；相反不能把全库无关文件都错误提升为必要。提供逐节点配置依赖拓扑、包括Gradle module metadata、POM、artifact及Gradle缓存索引格式能否安全在新root重建的证据。
3. **大小上下界：** 分别输出按已证闭合节点的**下界**、为消除UNKNOWN所需的**保守上界**、候选最小集合SHA256清单和精确逻辑字节、额外复制+元数据+inode/文件分配+回滚双存的**预估峰值**。将已有1,362,106,905 bytes作为全sealed集合的比较上界而非“实际必须复制量”；必须说明是否包含目录开销、Windows file allocation与RO权限设置，不能以`os.stat().st_size`推断真实peak。
4. **静态检查方法：** Python只读解析XML/JSON/ZIP元数据可以；只允许在任务拥有的小型fixture做确定性求解器与mock负例，绝不执行Gradle、Jar类加载、Java或Flutter。应新增测试验证：缺失plugin marker、POM父层/BOM、classifier/variant不确定、transitive缺口、版本冲突、cache索引缺失、可写/RO层fallback、SHA漂移、路径重定向、磁盘超cap/peak超cap均明确BLOCKED。
5. **结果不得自我提升：** 若静态证据充分，可报`MINIMAL_SEED_STATIC_CLOSURE_CANDIDATE`，但必须标`GRADLE_RESOLUTION_RUNTIME_NOT_PROVEN`；若不充分报`MINIMAL_SEED_CLOSURE_NOT_PROVEN`且给精确未证边集合和新cap选项。**不得以空seed占位符、提案Hash或mock绿灯宣称已可运行G2。**

## 3. B：SDK与隐式写入只补实际关键UNKNOWN

复用68fe已审18族矩阵而**不再重新枚举全部大类**，重点在当前G2配置下可能写保护根的少数机制：

- `FlutterPluginUtils.forceNdkDownload`、Android SDK manager/NDK/cmake/stamp/metadata的条件触发（查实际SDK是否已pin、条件及写入目标），`Gradle offline`和JDK autodownload关闭是否足以限制相关插件配置副作用；若不足则UNKNOWN/STOP，不通过改防火墙/共享SDK或假定无需NDK绕过。
- Flutter SDK bin/cache、tooling source和included build的实际解析输入闭包、Flutter/Dart工具读取路径以及项目`flutter-root`新外形骨架与原固定pin一致性；小型SDK模板已知仅partial，不把符合三件tooling源码pin当成完整SDK目录。
- 14个具名native plugin源码的build输出/自定义目录操作与实际247+ package引用路径；对未证明的插件构建script动态逻辑、默认HOME/AppData/temp/ANDROID_USER_HOME/PUB_CACHE路径给出**具名可能写入路径→隔离到任务私有根**的源码证据或精确`UNRESOLVED`。
- **OS enforcement方案**只作静态可行性评估：Windows canonical path/file-id/hardlink/reparse/ACL有效只读对象、权限不足时保守stop，临时只读seed与私有写根、对共享目录写保护的路径级审核。不得在本任务真实变更受保护共享目录的ACL、测试探针写入，或启动进程实验。方案需解释TOCTOU和不可观察写入风险，不能把Python policy当OS防护。

对每个旧UNKNOWN输出`CLOSED_BY_PINNED_SOURCE`（仅静态）、`CLOSURE_REQUIRES_RUNTIME_OBSERVATION`或`UNRESOLVED`三类；不拿“无异常日志”填关闭。出具最小输入变化集合及后续G2真正运行前**必须的**预检清单。

## 4. 资源范围与复用规则

采用从68fe提交派生的**单独、有来源的轻量受控候选**与任务独有outbox，尽可能重用上轮已有任务私有隔离骨架做**只读参照**，不在历史dirty根、68fe原任务目录和共享SDK/缓存上写入；不可重建完整SDK或盲目拷贝modules-2。允许按上限在新任务私有目录构建小型JSON/CSV edge清单、离线静态解析器、fixture及极少量**独立字节**种子候选验证；原cache/user-home只读。以文件Hash、实际file-id和link count确认私有副本不是可写硬链接；如需在任务源中展示片段，避免机密/路径/许可证侵犯。

本次不得删除任何旧文件，包括旧下载partial（7,941,328 bytes / SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`）、旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`，也不改历史A/G2 claims、账本、旧logs、SQL/APK、5保护根、refs与旧输出。若被使用中的本地文件发生变化，记录并区分旧sealed与当前runtime state，不能改旧Hash“修复漂移”。

**允许多agent静态/离线交叉评审**，但输出不得暗示多agent已代替Astra或证明真实Gradle运行。避免对上轮已经稳定的56/140项mock再全量重跑；测试聚焦新的闭包解析和剩余SDK路径假设。

## 5. 最终交付合同与成功/阻断状态

集中交付一份
`docs/versions/v10.1.5/G2_MINIMAL_DEPENDENCY_SEED_DECISION_REPORT_20261027.md`
以及最小脱敏结构化索引
`docs/versions/v10.1.5/G2_MINIMAL_DEPENDENCY_SEED_EVIDENCE_INDEX_20261027.json`。
必要时附本任务**唯一最小**静态解析器和测试（只限安全源码，不用“为了规模”多建文件）；本地完整真实路径、live进程/文件身份/IP/PID/socket/环境绝对目录、SQL/APK、旧失败logs及大体积目录清单留`LOCAL_ONLY_RAW`。

报告必须一目了然包含：
1. 权威Commit/唯一Parent/Root/完整apps/services Tree、正式任务Blob、新旧baseline及GitHub固定源码身份；全部变更path/mode/Blob/原字节和真实变更范围。
2. 最小modules-2闭包的**确切已证依赖边**、未知边、plugin marker/metadata/variant/BOM/parent解析合同、node/artifact/metadata Hash统计、精确字节总数与peak上下界、可复用旧输入/必须私有复制集合；不允许凭“缓存文件总数”当依赖闭包。
3. 完整seed直接复制1.36GB超原cap的事实与一个或多个**量化可选策略**：≤512MiB精简闭包如果静态可证；否则若确实需要>512MiB可陈列具名1.5GiB/2GiB等**待Owner批准**的空间上限建议，注明额外目录、回滚共存、系统可用空间和不可保证项，**不要自行改cap或开始复制**。没有数据支撑时只写待定，不造预算数。
4. Flutter/Android/NDK/plugin仍未闭合的具体动态写入点，附源码/HASH行号与后续验证手段；RO依赖层不能覆盖的写面和OS read-only隔离资格。不以静态合同为真实安全证明。
5. 新静态/mock运行实际exit/数量、outbox大小与全轮物理allocated前后测量及局限；历史未重跑对象明确标`NOT_RUN`。若违反任何运行禁令或路径保护门则`PROTECTED_INPUT_DRIFT_OR_SAFETY_STOP`并停止。
6. `G2.max=1`、本地fresh只读`claimExists`/reservedStarts/Popen（不等于Astra核验），仍未执行；旧APK/G耗尽、旧A闭门；`DOKKA_TASK_SELECTED_NOT_PROVEN / GRAPH_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED`。
7. 一页**Owner决策建议**：是否已有充分证据支持在原cap继续；若没有，是依赖seed容量、metadata闭合、SDK隐式写入、还是OS隔离哪项真正挡住G2；提出一个最窄的下一授权选择，不自动下达。

分类以`MINIMAL_SEED_STATIC_CLOSURE_CANDIDATE_WITH_OBSERVATIONS`（不授权G2）或`MINIMAL_SEED_CLOSURE_NOT_PROVEN`、必要时`BLOCKED_DISK_OR_ISOLATION`为准；即使全部静态任务通过，仍然`G2_READY_FOR_POPEN=FALSE`、`INVENTORY_RUNTIME_CLOSURE_NOT_PROVEN`，交给Astra独立判断。

候选通过普通非force GitHub文档/安全源码分支，以68fe为唯一来源Parent；回读Commit、唯一Parent、Root、全部新Blob/原字节和**完整**apps/services Tree，对照live main已接受v10.1.4两个子Tree。不得把未接受的6ca/68fe产品代码合进main。只有本次单一候选集中交付后STOP；不运行G2、不复用剩余A额度、不启动v10.1.6、不自动开启后继任务。
