# EliteSync v10.1.5｜Owned AAR Init Context + Observer Fail-Closed 综合源码加固任务

**状态：OWNER_APPROVED_BOUNDED_SOURCE_HARDENING / READY_FOR_OWNER_MANUAL_CODEX_DISPATCH / ZERO_GRADLE / ZERO_AAR_APK / ZERO_DEVICE / ZERO_GATE2 / NOT_A_RUNTIME_ACCEPTANCE**

日期：2026-10-27（Asia/Singapore）  
仓库：`zcx369658780/EliteSync-v10`

## 0. 权限、目标与非目标

Owner刚刚明确批准Astra在已接受的 `ba77a3c8` 定点只读根因调查基础上继续，执行**一份综合、局部、零Gradle的源码加固任务**。Astra负责本任务冻结和后续独立验收；Codex仅在Owner通过本地工作流**手动派发正式任务**之后执行。一份任务内可自主进行定点实现、必要静态/mock测试、缺陷修正与一次集中候选交付；不要求Owner转发微任务。

**唯一目标：** 将方案一的项目自有Flutter AAR init作用域守卫调整为既能对普通R1根构建严格校验，又能在确定属于受信任Flutter plugin included-build上下文时安全运行；并增强受控Windows observer及任务拥有runner，使 image path失败前能记录必要的API阶段/错误/实例身份，仍然**任何未知或失败一律fail-closed**。不宣称历史G唯一根因已经证明，也不尝试本轮实际Gradle验证。

成功终点：`SOURCE_HARDENING_CANDIDATE_DELIVERED_FOR_ASTRA_REVIEW`，不等于`G_PASS`、`GRAPH_SUPPORTED`、`AAR_POM_PASS`、`DOKKA_NOT_SELECTED`、`TCP_ROOT_CAUSE_FIXED`、`AC05_CLOSED`或整版v10.1.5接受。

本次总运行预算：Gradle启动**0**；JVM/Gradle/Kotlin DSL真实配置**0**；Flutter CLI build**0**；新G/A**0**；外层完整APK**0**；设备/ADB/RTC**0**；Windows真实观察器、进程树模拟或真实socket探测**0**；Gate2/Writer/Serializer**0**；真实Push、数据库、云端及生产**0**；下载安装升级与缓存删除**0**。可运行**有界Python静态、单元及完全mock测试**，其安全审计不得触发真实工程进程/网络/加载系统DLL。无新增费用、提权或系统/全局安全改动。

## 1. 必须fresh核验的GitHub authority与原始基线

Codex先从远端重新GET并按实际身份复核，不将以下SHA当实时可变分支值：

- 交付前最后main `82c19cf6a52618dff935263d296696afffec466e`，Root `693326ace9f9334024c331a560ac6eea30eec2c0`；**已接受产品仍v10.1.4** apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 最新根因报告候选 `ba77a3c840c36550a7ec3aa5a6475b69d874004f`；唯一Parent `fd0da9cce87c5eb84aec96dd11ea37aecd7aefff`；Root `8817729f4804d364e11c1ecb477e1e46a1cf9152`；**未接受候选**完整apps `e6bff4bc8e359e6afe80c02f25212ee8b6195eab` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`。ba77仅新增两份文档，本任务应从此有来源候选在新的隔离工作树/分支继续，勿从已接受main直接丢失方案一修改，也勿变更受保护dirty根。
- ba77报告 `docs/versions/v10.1.5/SCOPE_OBSERVER_ROOT_CAUSE_READONLY_REPORT_20261027.md` Blob `8c4947c5b4155ce495eae25b799b8c053a96ea94`；脱敏索引 Blob `5817f409b6d5a3cb5fa5540306135a201d9e396c`；上一正式只读任务 Blob `71d11e24c4d5b16d6d662f2684fc665750a7c154`。
- 上一轮Astra独立裁决：`astra/v10.1.5-ba77-readonly-rootcause-review-20261027:docs/versions/v10.1.5/BA77_SCOPE_OBSERVER_READONLY_ASTRA_REVIEW_20261027.md`，Blob `7f864c7e17b81acccb24cf0655de6b3a911a66f9`；审查分支历史HEAD `417c2c8d704996624afb70d0f703eb20f274c2f2`。
- 方案一源码候选 `da5ce628a499c97e916e780e2cf795353745c147` / 实际源码提交 `50d79396195ed8b4b86c218584ab59864ad600be`；Astra方案一来源/许可有界接受 Blob `1a39ba1ab5df7c69a0f6143b4734ba56b31cf134`。
- 冻结v10.1.5 `plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`；此前G/A受控验证任务 Blob `129efb748bb5a22921e756f2f829a627ceae6880`，实际G失败报告 Blob `e6f0a1f96b5d52993dfce5f31ad9456ba4d06e80` 及索引 Blob `38b20500d0e42218976a9f675607b7a5b259a7b1`。
- 本次正式任务全文、`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md`与Owner保护边界。若实时main前进，仅比较变化；若产品树/任务授权发生不可调和冲突，停止对应写操作并说明，而非强制覆盖。

**证据级别分离：** `ASTRA_DIRECT_GITHUB_STATIC`、`CODEX_REPORTED_LOCAL_EXECUTION`、`LOCAL_ONLY_RAW`、`STATIC_MECHANISM_SUPPORTED`、`HYPOTHESIS`、`NOT_PROVEN`。既有历史G只有36个有效运行样本/0个已证明选中任务，不能新补出运行证据。

## 2. 工作面与严格保护

- 仅在**本任务专属、容量受控的隔离候选/脚本副本**写入；不直接改变原受保护 `D:/EliteSync-v10` dirty根、旧 `D:/EliteSync`、旧候选树、过去LOCAL_ONLY历史G/A隔离目录、原task claim/ledger、Git refs或原始日志。创建/推送普通审阅候选必须非force，唯一Parent及两产品Tree逐路径可复核；不合并产品main。
- 原Gradle下载partial **7,941,328字节 / SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`**、旧完整APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316` 保持不变；A claim仍应不存在。保护旧SQL/APK/RTC日志/下载partial、原数据库/备份、所有具名旧refs和失败证据。
- 不修改共享Flutter SDK、共享Gradle/JDK/Android SDK、全局缓存或网络/代理/VPN/防火墙/PowerShell执行策略；不得下载升级、清空缓存、卸载软件。Owner另有**条件性受控环境维护授权**，但本轮缺具名缓存损坏/版本冲突证据，故不得据此立即动手。
- 尽量复用现有隔离输入的只读索引而非再复制巨大SDK/cache或重新哈希100453文件；新增脚本/fixture/报告使用有界空间，记录任务新增文件大小，避免无谓磁盘扩张。若无法在受控空间内安全完成，报告阻断。
- 原始私密进程PID/全路径/IP/socket/JWT/SQL、真实APK和原LOCAL_ONLY日志绝不上传GitHub；公开仅安全源码（剔除本机特定路径/隐私）、脱敏测试摘要与Hash。

## 3. A工作流：项目自有 AAR init 的精确scope合同修复

具名候选输入：
`apps/android/scripts/owned_flutter_aar_init/aar_runtime.init.gradle`、`owned_aar_init.py`、`SOURCE.json`、`UPSTREAM.patch`、`FLUTTER_LICENSE`、局部`.gitattributes`、`apps/android/app/build.gradle.kts`及`apps/android/scripts/test_owned_aar_init.py`、必要原受控`offline_debug.py`预检/关联mock测试。**只在真实依赖使用点所必需时**修改这些安全源码及相应pin；不得无理由重写整个Gradle构建架构或修改共享SDK。

1. 定点沿用ba77的`StartParameter.newBuild()`/included plugin build/static init继承发现：`-P`在根构建存在，included build可能执行同一init但项目属性不继承。首先明确能静态辨认的**根构建身份、合法Flutter tooling included build身份、来源脚本/SDK pin、项目根路径和调用授权**。历史G没有失败对象/真实scope map，因此这是需被安全修复的**候选机制**，不得写成历史唯一根因。
2. **根构建始终必须显式带准确scope** `v10.1.5-ordinary-r1-runtime`；错误scope、空值、别的R1 ICE/retention、非R1、任意普通附属工程全部拒绝。对合法Flutter tooling included/plugin build可采用具名可信上下文判断或明确安全的属性传递机制，但必须证明不可由任意相同名称/欺骗路径/重定向或其它子工程混入；身份不充分则**fail closed**。不能仅因为`projectProperties`空而放行、不能全局删除guard、不能对所有included/buildSrc都使用宽泛白名单或擅自改变Gradle全局属性。
3. 允许在任务自有副本中修改guard及其辅助校验/传参合同；保留项目自有init上游BSD许可、可追溯SOURCE/UPSTREAM.patch、受控字节推导、原始SDK/许可pin、`withSourcesJar()`、必须AAR/POM/MavenPublication与变体依赖，原两处`withJavadocJar()`继续不要求。若引入新字节，**关联更新全部准确Hash、SOURCE与验证脚本/Kotlin`validateOwnedRuntimeAarInit`、新可信库存合同的版本前置逻辑**；不得只改脚本不改消费者pin，也不得静默回退共享SDK init。
4. 明确不能通过Python字符串静态断言证明Groovy/Gradle实际配置成功。将root显式scope PASS、included合法上下文、错误/缺失scope、未知included、不可信路径/同名伪装、符号链接/reparse/非法根、无来源或pin不匹配、无许可/UPSTREAM.patch、ICE/retention不受影响等正反例纳入完全mock/纯静态验证。对不可模拟真实Gradle对象处明确标`RUNTIME_NOT_PROVEN`。
5. 若静态证据无法设计出既能辨认合法included build、又不放宽根与未知上下文的安全机制，则**不得硬改以求GREEN**；交付范围内完成可审阅的缩小方案并标`SCOPE_HARDENING_BLOCKED`，不进行Gradle试运行。

## 4. B工作流：observer失败前诊断与fail-closed不变

具名输入：Git跟踪的`apps/android/scripts/windows_build_observer.py`（当前安全源码）、本地G实际`controlled_runner.py`及`test_controlled_runner.py`（LOCAL_ONLY）、现有`offline_debug.py`/相关mock测试（如消费路径需要）。在**任务拥有副本**实施；不得更改或覆盖原G的脚本/claim/日志，不运行真实observer、OS DLL、Job或socket采样。

1. 保留Toolhelp32/归属检查、既有TCP/下载/未知进程/根实例/输入漂移等全部强停止语义。针对`OpenProcess(0x1000)`与`QueryFullProcessImageNameW`、返回空字符串、快照/查询竞态分别记录**发生阶段、即时Windows API错误码（可取得时）、当前采样时点、PID及父链、可取得的child创建时间/身份相关性、关联根Job或根进程身份**。不得为了日志成功把不可读当普通退出、以PID alone认定实例、忽略未知子孙或放行继续构建。
2. Windows API错误码须在**失败调用后立即**从正确机制取得并在随后系统调用/句柄关闭之前保存，避免丢失；验证`ctypes` last_error与API绑定使用正确，无法安全取得则标`API_ERROR_UNKNOWN`并照样强停，不编造数值。
3. 失败帧需在抛出`PROCESS_INSTANCE_PATH_UNREADABLE`前**尽力**写入任务独有的原始LOCAL_ONLY诊断事件，分开`snapshotSeen`、`imagePathQueried`、`apiFailureStage`、`apiError`、`pid/parent/creation identity availability`与失败原因；尽可能原子写入/flush/Hash并限制大小。**写日志本身失败、字段缺失或异常处理失败仍必须停止，不能回退成成功样本**。不向公共报告发布PID、用户名或实际路径。
4. 保留root Job kill-on-close、终止等待、预算claim先于Popen、A必须受G成功+图完整+可信输入门禁、零观察不能PASS等已有规则。新增runner副本若在LOCAL_ONLY不适合公开，需提交可Astra审阅的**脱敏安全源或精确补丁及静态测试定义/摘要**，同时提供LOCAL_ONLY原始SHA；绝不把新runner混写为原G执行器/原证。
5. 完全mock覆盖：OpenProcess失败、Query失败、成功但空路径、正常非空路径、即时GetLastError不可用、PID被重用但child创建时点无法校验、快照后退出、疑似未授权外部工具、日志写入异常、两种网络强停、错误先落盘后强停、Job释放、不会因异常触发G/A重试。仅**模拟**函数和Windows API返回，不真实创建受审进程、不枚举实时系统、不加载Windows DLL、不触网。
6. 诊断数据只改未来记录能力，不可能倒填旧G失败帧、当次PID或底层错误码；持续保留`OBSERVER_FAILING_INSTANCE_NOT_PROVEN`、`ROOT_CAUSE_NOT_PROVEN`。

## 5. 允许的验证方法、测试主体和硬预算

- 开工前对本任务需用的Git源码、`ba77`脱敏报告/索引及已具名本地原证做**有界**Hash/路径/来源核验；如果本地对应脚本/SDK版本有漂移先停相关动作，不以旧SHA覆盖本地差异。
- 可自主运行Python标准库静态解析、AST、unittest/pytest（如已安装且不联网），适量地在任务隔离根复验相关方案一37、offline44及本轮新增的模拟测试；只选择受影响的具名测试，不要求重跑全库。**测试必须经过审计确认不会启动真实Gradle/JVM/Flutter/ADB/网络/Windows DLL或其它受审工程进程**。原G runner可能在Windows真实功能模块导入时绑定DLL，测试需替换/mock或静态分析，禁止真实API。
- 在范围内可以多轮修改任务私有源码、重跑无副作用mock/静态测试修复普通失败；记录RED/GREEN路径、执行退出码/测试数、skip/mock占比、源与stdout/stderr SHA及缺口。**不得因mock100%通过而标`GRAPH_PASS`。**
- 预算始终`OLD_APP_APK=EXHAUSTED_1_OF_1`、`G=EXHAUSTED_1_OF_1`、`A=0_OF_1_GATE_CLOSED`、`GATE2_NOT_AUTHORIZED`。没有新的Gradle attempt、Wrapper、AAR、APK、下载、网络配置、DB/服务/手机/RTC权限。禁止通过新目录、改名、清claim/ledger恢复旧预算。
- 不在本轮更换Gradle/JDK/Flutter版本、不删缓存或旧软件；此前只读报告`CACHE_CORRUPTION_NOT_PROVEN / TOOLCHAIN_VERSION_CONFLICT_NOT_PROVEN`。未来Owner已批准的条件维护原则与本任务独立，不能改写已冻结运行授权。

## 6. 交付与Astra验收出口

一次集中交付同一v10.1.5的源码候选、`OWNED_INIT_SCOPE_OBSERVER_SOURCE_HARDENING_REPORT_20261027.md`（单份综合报告）和最小脱敏证据索引/manifest。报告至少包括：

- fresh live main、任务Blob、基线候选唯一Parent/Root、完整apps/services Tree及旧接受基线；最终源码变更清单含**每个受影响path/mode/Blob、内容/Hash**及测试/来源定位，报告文档追加Commit不得冒充源码Commit。
- scope root与included上下文安全合同、允许与拒绝路径/负例矩阵、SOURCE/LICENSE/UPSTREAM.patch/所有消费者pin的完整追溯。区分静态机制已支持与本轮实际未运行。
- observer失败阶段/API错误捕获与**失败前日志**设计、Job与A gate仍关闭；对原G没有新增真实实例证据，不回写历史失败。
- 新源/测试（含runner安全可审阅副本）的可查Blob或最小补丁；LOCAL_ONLY证据完整Hash、执行主体、mock测试/静态测试与NOT_RUN分类；关键风险需非作者静态复核但不强制多模型循环。
- 本任务改动目录/磁盘增量、旧partial/claim、具名历史原证及refs始末校验范围；不得用数量替代全部文件核验。旧本地SQL/APK、日志等任何隐私实体仍LOCAL_ONLY。
- 总状态明确`SOURCE_LEVEL_ONLY`、`GRAPH_NOT_PROVEN`、`DOKKA_TASK_SELECTED_NOT_PROVEN`、`AAR_POM_RUNTIME_NOT_PROVEN`、`AC05_OPEN`、`V10.1.5_PARTIAL_NOT_ACCEPTED`、`PRODUCT_MAIN_NOT_INTEGRATED`。

发布方式：普通非强制**独立候选分支**，只纳入本任务明确授权的源码/安全文档，最后按实际远端回读 Commit/sole Parent/Root、所有变更的Blob以及**完整apps/services Tree**，证明main的v10.1.4产品Tree仍原样。LOCAL_ONLY根绝不自动上传。若任一安全门禁无法满足，交付明确`BLOCKED_WITH_EVIDENCE`而非无证宣称成功。

**STOP：** 本任务完成后停在候选等待Astra**独立**审查。不得自动再发任务、启动新Gradle或Gate2、直接用旧A=1绕过G失败、合并main、删除历史原证或启动v10.1.6；真实G图验证必须在**后续另经Owner明确授权的新预算与新持久claim**下才可考虑。
