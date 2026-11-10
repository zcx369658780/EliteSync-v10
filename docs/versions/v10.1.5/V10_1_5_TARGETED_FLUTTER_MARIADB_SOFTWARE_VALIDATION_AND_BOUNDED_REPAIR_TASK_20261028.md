# EliteSync v10.1.5｜Flutter/Dart 与独立 MariaDB/Laravel 定向真实软件验证及同版有界修复——Owner综合任务

**状态：OWNER_APPROVED_TARGETED_SOFTWARE_RUNTIME_VALIDATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_G2 / NOT_GRADLE / NO_REAL_DEVICE_OR_PROVIDER / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-28（Asia/Singapore）。权威仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner授权、长任务终点和权限分层

Owner在接收Astra对软件候选`e2258152`的独立有界源码验收后明确同意继续下一门：**可信、隔离工具链上的Flutter/Dart定向检查与测试＋独立合成MariaDB/Laravel Feature/API持久、撤权和并发验证**，并允许在同一综合任务内进行必要同版源码/测试修复和集中重新验证。此授权**只**适用于本任务定义的安全本地工具与合成数据测试面；不包括任何旧ACL、OS隔离、G2、Gradle/Android构建、APK/真机、真实Push、共享开发库或生产资产。

**执行合同优先级**：Owner决定→正式本任务全文及本轮冻结范围→Astra固定源码裁决→Codex本地实际证据。Codex由Owner手动派发；发布不等于执行。对普通程序测试/代码bug可在单任务内部自行修复与定向复测；对缺少安全运行条件的分支标`NOT_RUN_ENV_GATE_CLOSED`，继续其它合法工作，不以此自动开后继微任务。

本轮目标不是整个v10.1.5功能接受，而是给此前静态候选添加**真实运行证据**并修复实际暴露的软件缺陷，形成一份可独立审查的集中新候选。不得在证据不足时用“理论可行”替代实际运行。

## 1. 必须 fresh 读取的权威身份和固定源码

1. 开工前从GitHub重新读取live main、Root Tree、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文与Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`，核实所有受保护资产/原历史预算合同与当前已接受产品树。任务发布前main HEAD `6a90c05538d1de8d648e645693ef9b1bf23b78f0`、Root `f5ac305a5f9eaa04bf2346322811909ff00ef047`仅为起始锚，非发单后最终值。
2. 唯一**已接受的产品main**仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。v10.1.5尚`PARTIAL_NOT_ACCEPTED / AC05_OPEN`。
3. 本轮**定向验证和同版修复的唯一源码候选Parent**为`e22581525a934377e094820e57bfc608ecdfc395`，sole Parent `6a90c05538d1de8d648e645693ef9b1bf23b78f0`，Root `573382c8bca9c9d84e8a85bb72135399ced5b3e6`，完整apps `61c0dd9a70fcd56af00053f1d055884cecf052f0`、services `cc61686579f4a89ac092f3f557ba1f8191471528`。这是**已接受有界源码交付、未接受整版功能、未集成main**的开发审阅候选，**从这个固定候选建立独立安全review/repair分支**，不是把它merge至main，也不重做此前60条源码继承。
4. 读取`docs/versions/v10.1.5/SOFTWARE_INTEGRATION_IMPLEMENTATION_REPORT_20261028.md` Blob `b7b79462fea3f860dfe6c1685f641cdab8eb6529`及`software_integration_artifact_manifest_20261028.json` Blob `ecee2e5abfe41ac31758999ea589ce4a8714d528`；最新Astra独立报告`astra/v10.1.5-e2258152-software-source-review-20261028:docs/versions/v10.1.5/E2258152_SOFTWARE_INTEGRATION_ASTRA_SOURCE_REVIEW_20261028.md` Blob `ebab2e765a88f900c8fd66ae13f8a18f495a7b25`，审查分支归档HEAD `5c6a1fc49bf282077cfd29ac9506935f80a7c790`。冻结功能计划`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`仍权威，不因本轮缩窄运行而降低其它AC标准。
5. 旧ACL事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`为Owner明确归档、停止继续调查：A/B两新树、6后代、父DACL变更/恢复各2次，违反旧合同。旧18件、实验根及原失败证据、122原证/五根/527refs/3183旧Seed、旧claims/ledger全部不可修改清理。旧APK/G预算1/1耗尽、旧A gate关闭；G2即使之前报告0/1且无claim，本次也是**0许可**。

## 2. 独立工作面、跨恢复预算账本与硬性安全门

- Codex必须在**新建且身份明确的task-owned独立安全工作面**中开展验证/修复；初始完整源码必须确认为e225固定Tree/Blob，不可对已有dirty或保护工作树reset/clean/rebase/stash、强制移动旧branch/refs或把旧大体积workspace复制到新根。若Git工作树新建会影响现存refs/管理区，先证明相关写入仅对本任务新分支/私有目录且无保护副作用；否则使用安全的固定GitHub源码归档作为初始工作面。main不写产品。
- 在**第一次启动任何工具或数据库**之前，创建任务私有持久`execution_ledger`：固定task Blob、源码基线、`task_id`、`attempt_id`、启动类型、pid/明确进程实例、命令hash、输入源/SDK版本与本次及历史同任务已用次数、开始与结束/退出回执、预算使用/写入范围与最终Hash，写入且flush。每一次可能产生副作用的启动先占用持久序号，再实际Popen；即使启动失败或模型生成中断，**预算不得退款或自动重试**。重新进入会话先读任务根/历史ledger/receipt，发现同一任务已消费动作必须继续其原对象或STOP，不得另建任务根/重新计数。多处日志冲突直接标`EXECUTION_LEDGER_CONFLICT`，停止相关启动，不自行用覆盖历史获得通行。
- 本轮可创建**一套**全新空的合成数据库环境，仅task私有本机目录/身份；可运行**最多2次独立 MariaDB server process Popen（累计，含失败启动）**，仅为了允许1次首次启动与1次本任务范围内有证据的普通重启；一个任务私有PHP本地loopback API server最多**2次Popen累计（含失败）**。严禁后台守护自动重启、反复调参试错、同时多实例/不计入账本的子进程。合法Laravel/PHPUnit进程按测试清单和真实exit保留，不以另起数据库实例作为重试。
- 初始任务新增产物/源码副本/独立DB数据目录/日志及私有包缓存的**logical及allocated上限各1GiB（1,073,741,824 bytes）**；每个中间节点及最终回执量化，预警不足立刻STOP对应写入。该上限是本任务全新授权，不返还此前256MiB/32MiB/2GiB或其它历史预算。禁止复制整套Android/Flutter SDK、旧1.36GiB Seed、旧数据库快照或任何受保护历史运行目录；只可使用已经存在且可只读核源/锁版本的工具与必要独立安全缓存，不下载安装依赖或发起互联网网络请求。
- **严禁**修改系统/全局防火墙、ACL/UAC、Windows账户或服务、系统时钟、共享SDK内cache/bin/lockfile、共享PUB_CACHE/HOME、旧SQL、旧localhost DB、旧服务/端口、现网DNS/代理；不得访问生产、真实账号、用户数据或外部供应商。仅合成匿名账户/设备、随机任务自有密文与本机受控环回；不要写敏感数据到公开GitHub。预启动固定保护清单首尾按具名Hash/元数据有界只读核查，无权访问即`NOT_VERIFIED`，不扩大扫描。

## 3. Flutter/Dart可信工具链门和定向测试

**此门本轮得到新的条件性执行授权，不再默认`0`，但不是可绕过SDK写面/依赖闭合的许可证。**

1. 先具名读取实际本地Flutter/Dart SDK版本、来源、依赖解析器、package lock与`.dart_tool/package_config.json`等必要输入；所有候选命令使用锁定Git源码/本地已具包，不做`pub get`联网/升级、flutter doctor的潜在全局改动或构建Android任务。用任务私有HOME/TEMP/PUB_CACHE以及**真实有效的只读SDK或完全隔离的任务自有SDK写面**，证明`flutter`启动、snapshot、engine artifacts、plugins、lockfiles不会写共享SDK/cache/旧项目；不能仅通过环境变量名字推定写隔离。
2. 只有门控成立时运行与F1/F2/F3有关的有界`dart analyze`/`flutter analyze --no-pub`与`flutter test --no-pub`或等价**不下载依赖、无需Gradle/JVM**的指定Dart/widget测试；以实际所装版本的`--help`只读核实合法参数，若`analyze --no-pub`不受支持必须换本版合法且同等隔离的命令，不可试启动未知写面去撞门。记录完整exit、stdout/stderr、原始测试数、失败栈、CPU/超时与工具进程清单。
3. 推荐范围：`private_cache_service_test.dart`、`auth_local_data_source_test.dart`、`auth_private_storage_test.dart`、`v1015_late_response_test.dart`、`v1015_socket_contract_test.dart`、`v1015_live_chat_reliability_test.dart`、`conversation_private_cache_test.dart`、`live_conversation_private_cache_test.dart`、`notification_center_page_test.dart`、`platform_notification_navigation_test.dart`、`session_rejection_test.dart`（路径与当前真实存在性必须以Git Tree为准）。不跑全app历史测试大盘、真实设备、RTC/Android插件原生初始化或全部Flutter build。
4. 重点验证真实测试框架下的未知结果保持同key、响应身份/会话epoch、晚WS、换号与旧缓存不回填；安全存储/退出队列与失效credential晚写、T0及15/30边界的合成时钟分支、损坏密文与删除失败、重启锁定；旧通知当前owner/permission/presentation和异步换号阻断。模拟时钟**不是实际15/30天经过**，Flutter单测不证明设备keystore/物理清理。
5. 若没有无外部下载、独立写面、可信引擎/依赖图的条件，**不运行**该分支，记录`FLUTTER_TOOLCHAIN_ISOLATION_BLOCKED / FLUTTER_DART_TEST_NOT_RUN`；继续获准的Laravel分支及源码级修复，不能擅改Flutter SDK配置/安全策略/旧Pub缓存求绿灯。

## 4. 独立合成 MariaDB、Laravel Feature与loopback API门

本轮仅批准完全独立于历史/共享/生产数据库的新task-owned合成测试环境，不允许连上旧`3306`、`43316`、历史`43317–43328`及任何已有MariaDB服务/DB。**唯一首选隔离监听端口`127.0.0.1:43329`，仅在未占用且新进程、本机回环、任务独立datadir和独立配置经先验核实时启用**；若不可使用则此DB分支`DB_ENV_GATE_BLOCKED`，不要扫描其他端口或改系统服务。单一数据库名`elitesync_v1015_verify_20261028`，只能建在本任务自己刚初始化的空数据目录/实例，不得用共享数据库的同名表“代替”。另允许单一PHP测试API回环端口`127.0.0.1:43339`，若占用同样STOP此子项。

**preflight必须同时证明：**
- 现存可信MariaDB/Laravel/PHP安装版本和二进制身份；能以普通用户、无需服务注册/安装/提权、无需读取旧数据库/凭据运行；数据库配置完全指向本任务唯一配置文件、PID/Socket、private datadir/log/tmp及回环43329，禁止默认配置/UNIX socket/TCP任意IP/远端连接。旧DB不可因端口错配被选择。
- 任务新库确实empty/synthetic，内部账户与privilege仅允许它自己，不能使用旧root/旧凭据。测试`.env.testing`和Laravel DB selector、所有`config:cache`/session/queue/cache/log/filesystem/attachments等侧效应目录要隔离，避免使用生产服务、真实身份Provider、通知provider、现网邮件/Redis/队列/云存储/SDK。只允许白名单测试脚本、任务私有合成手机号/账户、文件和TEST_ONLY通知token；严禁发送真实消息或对外HTTP。
- 在任何migration之前从**真实进程连接信息**复核host/port/database/datadir/本次instance identity和任务空库，保存只读pre-snapshot并证明回滚只作用本任务新库。失败不运行migration；不能用任意SQLite替代MariaDB而声称持久化/锁并发PASS。
- 如果上述门通过，允许仅在此测试库执行`2026_10_21_210000_trusted_device_login.php`、`2026_10_21_220000_create_notification_delivery_contracts.php`及本候选**实际需要的依赖migration集合**（按候选完整schema选择，用隔离新库运行，永不改旧migration/旧DB）。使用已安装Laravel代码和私有vendor包；不得运行composer install/update或网络下载。任何schema缺失/冲突/依赖不可闭合则停止数据库子项，不为修测试而假造旧生产schema事实。

**真实正反合同清单（任务内相应Feature/HTTP/持久/并发）：**
- F1：同key同payload重复只生成一条message、attachments、站内notification，异payload409；实际提交成功但HTTP返回丢失后的同key重试；相同key在并发事务/不同连接下锁顺序及唯一约束；附件由ready变failed仍可回读先前已提交事实；Block/Connection/MC/离开/失效token先后竞态的当前授权和消息读回不泄漏。至少保存前后DB计数、事务结果、response identity与真实错误域。
- F2：成功密码登录生成真正持久T0/account/device/session并有固定15/30截止；register/旧family/失败login不能构造新可信T0；refresh不续期；模拟时钟15天边界前后真实Laravel授权/旧token拒绝；同一设备跨账户family与logout/revoke顺序。使用合成时间的Laravel测试属于业务时间逻辑，不是物理经过15/30日，也不是设备本地密文被真实删除。
- F3：偏好分类/静默当前账号持久化；`TEST_ONLY` token hash/设备session/generation归属、撤权、换号/失效family、同一deviceId二账号重新绑定的限制与安全回执；通知投递attempt去重时重新验证当前owner/presentation/过期/消息同意；旧通知点击owner-only GET、Block/禁用/过期/类别关闭/换号后不得返回私密route；外层payload仅通用title/body/id，不传Safety私密数据；Provider永远`PENDING`。需要特别复核原Astra的“客户端声称device_id不等于实际设备持有证明”观察，保持外部真实Push关闭。
- 复用并修复`V1015MessagingTest.php`、`V1015TrustedLoginTest.php`、`V1015NotificationDeliveryTest.php`及必要有限相关回归；用实际Laravel Feature/HTTP响应、DB读取和相互独立的正负例证明，不以PHP纯合同代替数据库访问。可在已经启动的同一私有数据库内复测已授权软件缺陷，不重启新DB来重置预算；碰到死锁/不确定token或真实越权则保留失败并在任务内修代码/定向再测，超越权限或敏感资产即STOP对应部分。
- 若闭环安全条件不能满足：`MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED`，不启动老服务、不改旧DB、不安装系统服务，交付已通过其它部分及准确待解决的条件。真实HTTP仅允许这个task-owned`127.0.0.1:43339`，无公网，需有当前token和合成身份控制。

## 5. 允许的同版修复、跨续接保护和退出

可以修改`e2258152`已有的消息客户端/服务端、离线安全存储及登录、通知与用户权限链相关源码、两项尚未运行的migration、定向测试/最小配套配置以修**实际复现**的软件问题；普通语法、依赖导入、失败断言、逻辑bug可在冻结范围内自主修复。若运行/受测环境缺少可信工具或DB selector，**不允许修改业务权限断言、放宽安全逻辑或使用不相关数据库造PASS**；需如实记录阻断。任何新依赖、真实插件下载、OS/全局安全更改、账本/旧数据写入、真实设备、供应商/API费用要另获Owner授权。

请在每段运行前都读取同一task私有持久ledger：任务审批、剩余MariaDB/PHP service启动预算、目标工具运行已消耗、错误/部分成功、以及所有正在存活的任务进程。模型停止/生成中断或Codex会话恢复时绝不“按新的attempt计数”；如果已有MariaDB/HTTP服务持有任务实例则先重用或安全停止，不创建第二套未核账实例。对普通纯测试case失败允许在同一已授权环境中多次最小范围重跑并写流水，但不能突破task空间/进程预算、不能用未批准全栈命令求绿灯。

**绝对0：** 新ACL/DACL/SACL/旧18恢复或新fixture；Windows restricted/普通对照child与14项OS隔离矩阵；G2 Popen/claim、旧APK/G账本/预算重置；Gradle/JVM/Android原生构建/AAR/POM/APK/ADB/RTC/设备；真实Push Provider SDK/密钥/后台系统投递；现网DB/生产/staging/旧Seed/共享SDK/系统全局权限/系统服务/网络策略；D盘历史目录清理或任何旧git refs/worktree归档。服务端局部实验仅可运行本任务明示的task-owned loopback进程。

## 6. 集中交付、验收与最终STOP

- 从**固定`e2258152`作为唯一Parent**提交一份普通non-force审阅候选（不要合main，也不以旧Astra独立审查分支做研发Parent）；唯一候选包含必要的源码/测试/最小migration修复和两份脱敏报告，不做重复任务分支。不得重写e225已通过的Git对象与原有报告/manifest。
- 新交付建议文件：`docs/versions/v10.1.5/TARGETED_FLUTTER_MARIADB_VALIDATION_AND_REPAIR_REPORT_20261028.md`、`docs/versions/v10.1.5/targeted_flutter_mariadb_validation_evidence_index_20261028.json`。报告至少记录：实际工具/DB进程identity、配置真值/私有写面证据、所有原命令exit/耗时与可溯Hash、合成schema/migrations、真实请求/事务/DB计数、F1/F2/F3逐项正反例与`PASS/FAIL/NOT_RUN`、Flutter/dart编译/测试结果、未修复缺陷、运行预算与累计attempt ledger、主线与历史保护状态以及未来独立需要的APP/设备/真实Push/G2门。
- 交付按`DIRECT_GITHUB_OBJECT`、`CODEX_REPORTED_LOCAL_TEST`、`LOCAL_ONLY_RAW`、`NOT_RUN/NOT_PROVEN`四级。个人路径/凭据/实际token/私密数据库、原始日志、OS权限原值不得上传GitHub，只可公开脱敏计数/Hash/固定源引用。独立纯源码审查若可用纳入同一任务，不重复烧旧OS预算。
- 完成后安全停止新私有API和MariaDB进程，保留任务自有的合成DB证据及快照（不要触碰旧数据库），封闭写入。进行候选commit/sole Parent/Root、全部修改path/mode/Blob及完整apps/services Tree、报告索引GitHub读回，同时fresh核实main仍未擅自集成产品。
- 终态只能是`V10.1.5_TARGETED_VALIDATION_CANDIDATE_DELIVERED_AWAITING_ASTRA_REVIEW`或`DELIVERED_PARTIAL_WITH_EXPLICIT_ENV_OR_TEST_BLOCKERS`。即使F1/F2/F3真实测试达到目标，**不直接升级为v10.1.5功能整版接受、AC05已关闭、可发布APK或G2可运行**。
- **STOP等待Astra独立验收和下一次Owner决定**。不得自动下发后继任务、合main、开启v10.1.6、删除旧ACL实验/旧Seed或将复测次数视为新一轮自动审批。历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`及`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`全部保持。
