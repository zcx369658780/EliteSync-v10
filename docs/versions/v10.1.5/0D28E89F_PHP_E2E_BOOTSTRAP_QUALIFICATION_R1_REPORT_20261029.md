# v10.1.5｜0d28 E2E PHP依赖资格同版R1交付

状态：**V10.1.5_R1_E2E_PHP_ENTRY_SOURCE_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW / R1_DELIVERED_PARTIAL_WITH_EXPLICIT_RUNTIME_GATES**。
R1-01的源码资格缺口已补齐：仍使用`-n`，在CLI/API共用的私有依赖清单、参数和环境下先做静态闭包核验，未来实际进程再验证模块/函数/类及进程绑定native映像回执，失败不得进入Laravel/PDO。当前只完成源码和纯检查，**不是E2E_HARNESS_RUNTIME_READY**。

持续：`PHP_LARAVEL_BOOTSTRAP_NOT_RUN / ACTUAL_EXTENSION_LOAD_NOT_RUN / E2E_NOT_RUN_GATE_CLOSED / FLUTTER_WIDGET_NOT_RUN_GATE_CLOSED`。

## 1. Fresh Authority及固定来源

正式任务 `a307391e3872ff5367d84ddb7da86e53e531445e` 已按GitHub main路径fresh全文读取；开工main `8ac81fb16f2493b957eaf716fc3821f03d037385`，Root `5bfc8dbd90329b719cdcf02404a118d733e8934c`，ACTIVE_STATE Blob `36c5cf5b2f1851f4dd8014b15f75e2831c4e6441`。CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03` 均fresh读回。

Astra `0483e621b2f233cee26a151d01536af8911b7bb2` 正式裁决只接受0d28 F1源码并要求本R1修E2E PHP入口；R1-01为未来运行缺口，**不是**已观察的Laravel实际故障。原主线报告 `91cbf415d7a3cf5b94dd9ae2dc624a23d983037a`、Manifest `05d4569f25da87d963bd946cb77994449e2867ee`、矩阵 `09a67c280c9d7c77e9a18ef91c12383a9b025e80`、后续许可规格 `4d468c7f54b35f85fff67e0190f7b97e9ca491e8` 已直接按固定候选路径读取，不覆盖其历史原件。

唯一研发Parent `0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`，Parent Root `c6898b86dd1e286967b952b2ac9cb764f4b0ff6d`；Parent apps `03ba3602a7dc807bf963264e24f33eed01c231c8`、services `32229dce88cf497fea43904fea3dbb69a9410b8f`。仅导入具名工具、测试bootstrap、Composer和必要纯fixture源码，逐Git Blob匹配；未复制完整产品树、SDK、vendor、DLL或datadir。原F1产品修复/3项Widget源随整个apps Tree原样保留，原15场景与原纯契约断言原字节保留。

main唯一已接受产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` /services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；本候选不合main。

## 2. R1-01前后与依赖来源

| 项目 | 0d28 | R1源码 |
|---|---|---|
| PHP启动 | `-n`只显式pdo_mysql、openssl | 保留`-n`；同一参数构造器使用受Hash冻结的绝对扩展路径、私有include/write目录、禁dl/auto-prepend/append |
| 需求依据 | 未将真实Laravel需要与入口绑定 | `php_requirements.json`绑定composer.json/lock原字节及具名调用，选定PHP8.5.3 NTS x64与固定exe Hash |
| 文件/依赖 | 仅exe/script Hash | 所有私有exe/DLL密封清单、来源inventory、SHA256、AMD64 PE32+、普通和delay-import、私有应用目录原生依赖闭包；缺失/越界即停 |
| CLI/API一致性 | 未冻结共同扩展闭包 | 两端必须同Manifest raw Hash、政策Hash、源候选/Composer身份；API显式入口同构argv/env |
| 真能力 | 纯14项不能证明模块已加载 | 未来PHP在PDO/Laravel之前核version/ABI/SAPI、无ini、实际模块集合/函数/类/PDO驱动；当前未调用 |
| 本机来源 | 纯检查未证真实映像 | 未来Windows父观察器＋PHP PID/nonce/profile绑定回执；当前观察器未运行，不称OS隔离通过 |

源码依据：composer.json Blob `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`、composer.lock `66327f584d3961c2b53391bb012047dda9cc9d23`（Laravel实际锁定 **v11.48.0**，根约束^11.31），DeviceSessions Blob `03754bed3a62f58f26db2913bbb786f8775e98f7` 的真实`mb_substr`调用。requirements逐包列直接ext-require，明确区分普通packages与packages-dev。

选定with-dev锁定vendor配置要求18模块：`ctype, dom, fileinfo, filter, hash, iconv, json, libxml, mbstring, openssl, pcre, pdo, pdo_mysql, phar, session, tokenizer, xml, xmlwriter`。Laravel本身要求mbstring等，Flysystem/File MIME要求fileinfo，CSS转换包要求DOM/libxml；锁中开发工具带XML/XMLWriter/Phar，未把它们伪称每一次HTTP必调用。pdo/pdo_mysql为本MariaDB桥接的明确需求。cURL在该锁中不是硬require且HTTP驱动使用Python，因此不编造其硬依赖；如选入共享curl扩展，仍必须声明、Hash并核完整原生依赖。

`required_shared_modules`固定fileinfo/mbstring/openssl/pdo_mysql，不能把缺mbstring虚标为builtin过关。PHP版本8.5.3是原已核运行方向，当前只核同exe字节Hash和x64 PE元数据，未执行`php --version`或模块探针。

对具名历史私有PHP来源仅只读PE/Hash：**8个文件，仍有1项私有原生依赖缺失**；完整图、路径、DLL明细仅LOCAL_ONLY。没有搜系统DLL替代、下载、升级、复制、加载或修旧来源。该历史副本状态是参考材料不完整，**不是本轮真实闭包已资格化**。实际来源inventory/Windows OS映像清单、原始DLL都不上传；公开仅需求与安全摘要、空模板及程序参考Hash。

## 3. 接线、同版范围与失败保护

Python `php_runtime.py`在Driver构造和每个CLI Popen前检查同源/同闭包/Hash、固定版本架构、来源分组、全二进制清单及私有可写目录。PE文件只是静态解析，不调用LoadLibrary。不同CLI/API Manifest、未声明DLL、逃逸/reparse/hardlink、错程序/源码/候选、关闭task或无新Owner许可均拒绝。原`contracts.local`改为先lstat/拒绝reparse再resolve，避免先跟随链接探测。

`PhpRuntimeQualification.php`只在未来真实启动时检查实际PHP能力；接入MainlineEnvironment.connect的**PDO连接之前**，故bridge seed与API router都会先拒绝。PHP与Python政策统一拒绝6个已关闭零预算task Blob；正常生产public/index不加载此bootstrap，不修改业务鉴权、路由、迁移或生产配置。

新`php_api_entry.py`提供默认无副作用inspect和纯plan；真正execute需要新的显式PHP API启动上限<=2与时间上限，先flush预留再Popen，失败不退款。共享参数明确`-n`、绝对extension、私有extension/include/open_basedir、无自动prepend/append及dl；PATH不继承全局，ini目录私有且空。API与Driver分别独占`raw/api`与`raw/driver`，避免API先启动时Driver因同目录而必然失败。

未来CLI能力检查后先写nonce/PID/profile ready，等待父观察器核native映像并放行回执，之后才可能进入DB/Laravel；API显式父入口核启动映像，router每请求核同一进程回执，资格失败marker促使父入口停止。CLI不使用shell、总启动/通信超时受限。原ledger/历史attempt不被重用或清零。

限制：Source-inventory字段和本地grant是可信操作员一致性约束，**不是**发布者签名或Owner加密认证；必须在未来授权下核真实来源。PE导入图及pre-bootstrap快照不能证明所有运行时动态加载、所有后续native状态或恶意代码OS隔离。Windows模块观察器、握手/API生命周期、实际模块/函数及ABI兼容性本轮全部 **NOT_RUN**。合法合成Manifest成功上限只为 `STATIC_PRECONDITION_OK / LIVE_MODULE_LOAD_NOT_RUN`。

## 4. 真实纯检查、审查与失败

- Python **48 executed /48 passed /0失败错误跳过，exit0**：保留原15项，加33项R1合成检查。仅惯性PE字节和临时task-owned文件；Popen/socket/system/startfile拒绝替身防误启动。覆盖缺mbstring、假builtin、漏依赖、未声明DLL、错误Hash/架构/版本/来源分组、候选与配置、路径、旧预算、两端闭包、native映像输入、API默认无副作用及raw分区。
- PHP **原14项资格＋新增25项合成能力/回执输入检查，各exit0**；**8份PHP lint均exit0**。使用`-n`且**没有extension加载参数**、无vendor、无PDO构造/连接、无Laravel bootstrap、无本机观察器；函数/模块/类事实由合成输入给出，不伪称读取真实模块。新增反例包括缺mb_substr/DOM/PDO驱动、额外模块、ini/prepend/dl、错版本/SAPI/ABI、错PID/nonce/profile、全局映像及全部6个旧task。
- 非作者Sol/high只读复核发现并集中修复raw目录冲突与双语言旧task清单不一致；最后定点复核无新增确定问题。它没有运行DLL/Windows观察器/测试，不能代替Astra。
- 首次保留的旧14项PHP纯fixture因窄源码导入未包含LiveConsentService而退出失败；复制并核对该具名原Blob作只读fixture后通过，**没有修改生产service**或跳过旧断言。原exit/stdout/stderr Hash及失败保存在本轮ledger/LOCAL_ONLY日志，不删减。没有把此准备缺项说成已复现R1-01动态加载故障。

交付打包首次脱敏扫描将纯测试中单个固定合成路径负例误识为私人路径并退出1；仅对该文件的精确合成字串作有次数断言的扫描占位，保留失败，不改测试或放宽其它路径扫描。

48是当前纯测试数、18是需求模块数，均不是功能完成率或E2E通过数。旧MariaDB23/152、Flutter77、Hook42没有重跑。

## 5. 预算及不变对象

唯一task `V1015_E2E_PHP_RUNTIME_DEPENDENCY_R1_20261029` /attempt-0001，新task-owned工作面和持久execution_ledger；写前PREPARE/flush、记录前后Hash，失败保留，中断同根继续。新增logical/native allocated各<=268435456 bytes；目前仅数MiB，精确终态观测/metadata预留在budget-terminal，离散观测不称连续峰值证明。

本轮实际共享扩展加载、PHP真实E2E/API/Laravel、MariaDB服务/迁移/事务/连接、Flutter/Dart、G2/Gradle/JVM/APK/ADB/设备/RTC/WS/Push、下载/安装/升级全部0。允许的PHP lint和无框架合成纯检查单独记账；不从旧API余额取额度。旧Flutter6/6、MariaDB2/2、G/APK各1/1以及ACL事故、旧18、两树、122原证、五根、527refs、Seed3183、旧失败/claims/ledger/dirty根均保留，不改不清理。

新apps Tree **03ba3602a7dc807bf963264e24f33eed01c231c8**（729 Blob）与Parent完全相同；新services Tree **eb47fe58d1167b1795224d4c748fb046042b9c92**（722 Blob），只允许tests/E2E非生产变更。composer.json/lock、全部生产app/routes、15场景、原测试及旧报告/Manifest/AC矩阵/许可规格均按Parent原Blob保留。只新增本R1两份文档，不覆写历史。

## 6. 下一真实门与STOP

未来须Owner另冻结当前R1候选、来源inventory、缺失私有原生依赖的合法来源、CLI/API完全相同的Manifest/版本/Hash、私有环境和Windows System32映像证据、真实probe/Observer与服务的独立预算。先完成能力/本机闭包资格再允许PDO/Laravel/E2E；不能因为纯条件通过自动运行。原FOLLOWUP_OWNER_AUTHORIZATION_SPEC只读引用，不自动变成许可，不开启新小任务。

证据等级：Authority/固定源码/最终远端对象为DIRECT_GITHUB_OBJECT；本轮纯检查为CODEX_REPORTED_LOCAL_TEST；原路径/安全DLL图/模块映像/日志/ledger为LOCAL_ONLY_RAW；动态扩展、PHP bootstrap与整链为NOT_RUN_GATE_CLOSED。本候选最终Commit/sole Parent/Root/每条变更原字节及完整双Tree/main由独立terminal readback记录，Manifest不循环自签自身Blob。

持续 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。**一次R1候选后STOP等Astra独立验收，不合main、不自签FUNCTION_ACCEPTED、不批准新运行或派发后继。**
