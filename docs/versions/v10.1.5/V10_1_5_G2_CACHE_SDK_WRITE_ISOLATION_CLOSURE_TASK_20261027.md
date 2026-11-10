# EliteSync v10.1.5｜G2 前置闭合：Gradle Cache / Flutter SDK 可写域隔离综合任务

**状态：OWNER_APPROVED_BOUNDED_WRITE_ISOLATION_CLOSURE / TASK_PUBLISHED_FOR_OWNER_MANUAL_DISPATCH / STATIC_AND_FULL_MOCK_ONLY / G2_NOT_RUN / NO_GRADLE_OR_RUNTIME**

日期：2026-10-27（Asia/Singapore）
项目：`zcx369658780/EliteSync-v10`
最终重大决策authority：Owner；正式任务发布和交付后独立审查：Astra；本地执行者：由Owner手动派发的Codex。

## 0. 目标、授权和不能隐含增加的预算

Owner在Astra对`286eb20d`的 G2 输入闭合受阻交付作出`G2_PRECHECK_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`独立裁决后明确同意：继续**一份聚焦共享Gradle缓存/Flutter SDK可写面分离的静态证据、隔离准备及完全mock综合任务**。本任务不得凭借Owner“继续”自动重试/执行G2；也不得偷换成新完整构建工作或反复启动新的G/A。

**本次唯一目的：** 识别G2真实命令下受信任输入的实际消费映射，与配置阶段所有可能修改的Gradle user-home、Gradle依赖/编译缓存、Flutter tooling included build根内`.gradle`、buildOutputCleanup与lock、Flutter SDK产物输出、module `.android`以及插件/Android/Pub生成状态；设计、必要时在**任务自有小范围副本**构建并静态核验**最小、可追溯、可回滚的写入隔离合同**。目标是为现存G2前置库存闭合提供可供Astra判断的证据，而不是宣称已经实跑成功或自动放行。

**本轮一律运行预算0**：真实Gradle（含`--version`、`--help`、`--dry-run`、Wrapper、init配置）0；Java/JVM/Flutter CLI/Dart/AGP/Kotlin实际执行0；G2 Popen 0；G2.claim创建/改写0；AAR/POM、外层APK/设备/RTC、真实observer/Windows native/Job/socket探测、Gate2/Writer/Serializer/Push/DB/生产均0。允许定向只读文件/Hash/路径/目录/缓存元数据核验，Python stdlib静态程序、AST、局部fixture与完全mock测试、在新任务拥有目录内构造**可重建的小体积**私有写面；不得触发受审工程、Gradle或真实网络访问。

**预算冻结：** 历史完整APK=1/1已耗尽；历史G=1/1已耗尽；旧A=NOT_RUN_GATE_CLOSED；已有独立`G2 MAX1`由先前正式任务授权、Codex上次报告`reservedStarts=0 / Popen=0 / claim不存在`，本次应fresh只读检查，**不得创建claim或消耗其额度**。未来只有在本任务独立接受、原G2合同重新fresh核验、包含完整runtime preflight与Owner新明确执行决定后，才考虑调用已存在的G2预算；本次交付本身不构成下一轮自动派发。绝不通过复建目录、复制runner、删除ledger或增加新claim“恢复”任何预算。

## 1. 权威输入与来源精确身份（开工必须fresh GET）

- 本次任务和当前main/Root/`docs/workflow/ACTIVE_STATE.md`，以实际回读为准；准备任务前main `2da6cfe68a6b0f6d3227f52d8b860ad7ad34c330` / Root `dc8896144a4178a36ffe1d1a8135b1a3000f0b34`。
- 已接受产品仅v10.1.4：main apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。不可将未接受的6ca/286源码并入main。
- 交付来源应固定为`286eb20d1d6af2e76423cfbd3253880f47c9ae16`，唯一Parent `6ca09a66c0ef9619df7a3d7d4b089516f409954f`，Root `4177d75aec1eae6f33cd28ec45c88dce8496274a`，apps `5af7a9d0042be19437616e969e260658b67e9353`，services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。286只增加报告和索引，没有产品源码变更；6ca已有Astra`SOURCE_LEVEL_ONLY`接受。
- 286正式报告 `docs/versions/v10.1.5/G2_SOURCE_HARDENED_GRAPH_VERIFICATION_REPORT_20261027.md` Blob `f4c80b4bbab70485188a31daf2e36d75d0f7c7ba`；证据索引 `G2_SOURCE_HARDENED_GRAPH_EVIDENCE_INDEX_20261027.json` Blob `8850d02049255c6e566e2ae5e90a6eb66eb95515`。
- 前次G2任务合同 `V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md` Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`，**仍是将来G2运行的冻结合同**。本轮不能凭新文档改变它的budget/运行边界。
- Astra最新独立评审在`astra/v10.1.5-286eb20d-g2-precheck-review-20261027:docs/versions/v10.1.5/286EB20D_G2_INPUT_CLOSURE_ASTRA_REVIEW_20261027.md`，Blob `ce7250d9e4cfe42bd62c4607632eb84ac53bae5b`，评审分支先前HEAD `3fdf635ca73fdc911027761bb3888aa31b043155`。
- 6ca源码来源、guard、owned init和`owned_aar_init.inventory_contract()` schema2、七项`REQUIRED_PROJECT_INPUTS`与tooling固定pin仍具约束力；旧100453项全库存、新报告96736次fresh哈希、2465个复制的`.android`输入以及旧G受阻的runtime诊断只可按证据级别复用，不冒充本轮全部重跑。
- 若branch/head或本地原证漂移：记录差异、仅在明确符合任务范围与保护规则时继续，不能清洗dirty根或强制重置。精确Git原字节Hash与Windows checkout/换行转换Hash须分列。

## 2. 输入事实与优先缺口：不得用缓存损坏假设替代隔离证明

Codex前次报告（`CODEX_REPORTED_LOCAL_ONLY`，非Astra直接本地复核）：
1. `ownedAarInitContract` schema2及七份项目输入的`definitions`与`inventory`两侧通过，tooling pin/source/license/patch匹配；仅为**局部闭合**。
2. 96736件历史工具/缓存重新hash，96734旧pin匹配，差异仅Gradle cache中`fileHashes.bin`和`file-access.bin`两份**运行状态元数据**。其发生时间/主体/异常含义未证，不能直接认定缓存损坏。
3. 历史缓存文件集合外出现103个额外生成文件，含旧init的Groovy编译缓存；Flutter tooling引用根有2份此前未seal的`.gradle/buildOutputCleanup`锁/状态文件。另有272个package和74个plugin引用核对；未证明有生产plugin源码缺失。
4. 方案命令仍指向历史受保护Gradle user-home与共享Flutter SDK tooling构建根，未证明Gradle配置期写入与受保护输入彻底分离，故`globalTrusted=false`、`G2_NOT_RUN_INPUT_CLOSURE_BLOCKED`。

本任务应**解决证据缺口，而不是重做巨量全盘普查**：先分类这些状态文件及其引用、作用域、可能写入的来源，再选择安全、空间受控的读/写分离路径。若需采用Gradle原生只读dependency cache（例如`GRADLE_RO_DEP_CACHE`）或配置项目缓存目录等能力，必须先用**本机现有已pin Gradle 8.14源/文档作来源证据**解释其适用范围，尤其需要明确它**不能当然隔离**init-script编译状态、included-build`.gradle`、wrapper、daemon、本机service locks等其它写面。不得仅因为变量名出现就宣称完成闭合。

## 3. 完整读源/写面矩阵（任务最重要交付）

对未来固定G2命令（包括Gradle二进制、two `-I` init、`-PelitesyncOwnedAarProjectRoot`、`--offline`、`--no-daemon`、单`assembleAarRelease --dry-run`、`--gradle-user-home`、Flutter tooling composite/includeBuild）建立**逐族读取与可能写入矩阵**，至少覆盖：

- 旧Gradle user-home 的`caches/modules-2`依赖metadata/artifact、`fileHashes.bin`、`file-access.bin`、compiled scripts/groovy、transforms、locks、daemon/native等；区分**可共享不可变只读对象**、**必须任务私有可写对象**、**必须逐次生成的状态对象**、**未知**。
- 当前Flutter SDK `packages/flutter_tools/gradle` included build真实Root：`.gradle`、`buildOutputCleanup`、cache.properties、lock文件、build/与Kotlin/AGP配置写入、rootDir/projectDir/gradle-user-home之间的路径关系。说明`--project-cache-dir`或其它路径重定向是否覆盖included build；**源级尚未证明的写入路由应UNKNOWN**。
- 模块任务独有 `apps/flutter_elitesync_module/.android` 的settings、Plugin Loader、2465份重绑定历史文件、`.gradle` / build/ / output-dir /本地Maven repo；已固定pin消费来源、可能再生成和覆盖行为，不得因已有初始Hash就把同一路径假定为只读。
- JDK/Android SDK/Flutter工具chain、Pub cache、Native Plugins（74 plugin引用/272 package路径）的读/写边界；系统默认用户目录、环境变量（GRADLE_USER_HOME、PUB_CACHE、ANDROID_USER_HOME、TEMP、HOME或其Windows同类）在新入口下可能造成的隐式写入。保持默认禁止网络/下载。
- Windows链接类型：symlink/junction/reparse/hardlink、路径规范化、大小写、drive/volume、访问控制、hardlink同file id写穿风险；读取根与写根之间的canonical path重叠及硬链接/目录reparse逃逸。

每项矩阵必须有：逻辑作用、真实私密路径只留LOCAL_ONLY、前置文件/源Hash、版本/原报告锚点、操作的读/写类别（PROVEN_STATIC / REASONABLE_RISK / UNKNOWN）、计划私有写根、最大估计字节、如何检测任务外写入、回滚保留方式、尚缺哪个验证。不能以“没有列出某路径”证明写入不会发生。

## 4. 安全实现和容量策略（允许但范围有限）

可以在**新任务拥有且独立的隔离目录**创建有界缓存/Gradle-user-home骨架、少量已具名内容的独立字节副本、可写`.gradle`目录与Python模拟fixture、环境/命令**计划**及路径映射manifest；复制每份之前须明确owner、原Hash、目标是否真正独立file id、后续是否可能写入。**不得用硬链接、junction或目录symlink把可写副本指回历史保护输入**。不要写入、chmod/ACL修补或篡改共享Gradle/Flutter/Android/Pub/JDK/工具根、历史SDK/缓存，也不允许暂时重命名或迁移旧输入来“隔离”。

**空间上限：** 本次新增的任务自有隔离产物（除了Git正常受控checkout元数据、LOCAL_ONLY报告外）原则上**总增量≤512MiB逻辑字节与可观测磁盘增量均须分别记录**。优先**0全SDK拷贝/0全Gradle依赖库拷贝**；对缓存复用，如无法用官方已有能力安全映射到只读源，则先做最小manifest设计/计算需要峰值，不按愿望复制5GB+或整套Flutter SDK。若保证未来G2运行必须有超cap独立分层缓存或私有Flutter tooling root，**停在方案与容量证明`BLOCKED_DISK_OR_ISOLATION`**；不要为凑齐目录修改保护范围、删旧版本或无证放宽。历史受保护partial、claim、旧SQL/APK/日志、dirty根及所有ref原样不动。

**文件操作边界：** 允许对本任务自有骨架/fixture做无Gradle的Hash、目录解析、只读模拟、mock“写入会落在何处”验证。可根据本机已具名源码静态追踪正常Gradle环境变量及init/plugin来源，但不得运行 Gradle、JVM、Flutter、`gradle --version`、`gradle --dry-run`、真实observer/Job、Windows受审进程模拟或socket探测。不得测试共享环境写权限的探针写入；严格禁止更改系统代理/VPN/防火墙或下载新依赖。

## 5. 独立静态与mock验收门

Codex在一份综合任务中自主设计、实现、复查和修正合法范围内的小型preflight/fixtures；可调用多subagent作静态复核，复核不等于Astra独立验收。对任务拥有的隔离方案至少建立下列**负例与真实文件Hash定点验证**：

- 旧cache中2份mutable metadata漂移不能自动从历史pin继承；103额外文件、2份`buildOutputCleanup`状态必须分类、封存证据/显式标`VARIABLE_RUNTIME_STATE`或`UNRESOLVED`，不能静默重置pin而称`IMMUTABLE`。
- 私有Gradle-home中`caches`结构、依赖可读取映射与实际新的锁/compiled script写入目标分开；静态证明的仅标`STATIC_ROUTING_SUPPORTED`。如果官方支持的read-only依赖缓存只覆盖modules-2，要保留其他缓存未闭合的状态。
- 模块和included tooling build即使使用精确受pin SDK源码，也可能在其根内生成`.gradle/build`；mock中故意放入同名SDK根、reparse/junction/hardlink/越界和未知输出，必须拒绝。
- `GRADLE_USER_HOME`、`--gradle-user-home`、task cwd/currentDir/Flutter根、project-cache位置冲突、默认本机user-home fallback，以及新旧路径别名，mock时应被拦截；不能因“只看见私有cache”就忽略shared SDK output。
- 新命令proposal、write-roots manifest、执行preflight的静态命令Hash可计算，但必须标为`PROPOSED_NOT_EXECUTED`。禁止制造真实Gradle退出码、任务图、job-empty或observer样本。
- 形成`EXACT_READ_ONLY_PINNED_SET`与`TASK_PRIVATE_WRITABLE_SET`（如有合理静态证据）、`UNRESOLVED_WRITE_SURFACES`，并提供源代码/合同定位、目录/文件长度及hash。不能通过扩大白名单让unknown被默许。

**成功分类：** 
- `WRITE_ISOLATION_STATIC_CONTRACT_DELIVERED`：具名路径+Hash/文件身份+源依据+容量+mock负例与read/write分离设计完成，`RUNTIME_NOT_PROVEN`保留；若任何写面UNKNOWN，应同时标`G2_INVENTORY_CLOSURE_BLOCKED`，不可提升为运行许可。
- `WRITE_ISOLATION_STILL_BLOCKED`：存在无法在现有预算、磁盘上限、源边界内隔离的关键写面；提交最小未解决集合和**可验证备选方案**，不得强行补证据。
- `PROTECTED_INPUT_DRIFT_OR_SAFETY_STOP`：任何保护输入非预期变化、重定向/写越界、真实运行/API禁令触发、未知文件/旧claim异常；立即STOP并给出安全审计摘要。

重要：本次**不能自行授予 `G2_GRAPH_BOUNDED_SUPPORTED`、`INVENTORY_RUNTIME_CLOSURE_VERIFIED`或`G2_READY_FOR_POPEN`**，即使静态mock全绿亦如此。后续是否可能在**原G2有限预算**下再次实际探测，必须由Astra对本任务审查和Owner下一步明确决定，并重做强监测与完整库存最终门禁。

## 6. 集中交付及保护

一次性产出`docs/versions/v10.1.5/G2_WRITE_ISOLATION_CLOSURE_REPORT_20261027.md`及相应最小脱敏证据索引，包含实际设计的read/write矩阵、两个mutable metadata与103/2生成状态的分级、容量测算、新隔离根的输入→目标Hash、所有不受信任路径/是否任务拥有、静态+mock执行回执/失败记录（如有）、完整未闭合清单与最小下一步。已有6ca加固源码与286两文档原件不得改写。

如确有必要可在**任务自有普通非强制候选**发布最小安全静态预检源/fixtures；否则只发布报告和脱敏索引。真实本机绝对路径、PID、IP/socket、旧私密日志、SQL/APK、受保护partial等LOCAL_ONLY；公开仅脱敏标签、对应SHA256、代码定位、字节数、假设等级和停止理由。完成后按新候选唯一Parent/Root、完整apps/services Tree、所有新增Blob/路径/mode与Git原字节fresh readback，并核验main已接受产品子Tree不变。对protected input采取本任务范围**具名首尾定点只读比对**，尤其旧Gradle下载partial 7,941,328 bytes/SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`；旧A claim与G2 claim按实际只读观察仍应不存在。不能用抽查冒充26784历史保护项或旧100453库存重新全量覆盖。

持续：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / GRAPH_NOT_PROVEN / DOKKA_TASK_SELECTED_NOT_PROVEN / AAR_POM_RUNTIME_NOT_PROVEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / EDGE_NOT_PROVEN / DOKKA_TCP_CAUSALITY_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`，历史AEC、最后可闻波形、native handle、真实15/30天经过及物理30天清理等缺口不关闭。

**完成后STOP：** 当前仅是`PUBLISHED_OWNER_MANUAL_DISPATCH_REQUIRED`；Codex在Owner手动派发后自主完成有界工作并停止等待Astra独立验收，不运行/重试G2、不创建claim、不运行A/APK/Gate2、不自动派发后继、不合并main、不删缓存/下载升级、不启动v10.1.6。
