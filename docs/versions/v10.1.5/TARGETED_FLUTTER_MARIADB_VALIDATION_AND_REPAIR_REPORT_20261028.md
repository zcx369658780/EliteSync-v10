# v10.1.5 定向 Flutter / MariaDB 验证：环境受阻集中交付

任务冻结日：2026-10-28。实际只读核验与交付日：2026-10-29（Asia/Shanghai）。

**DELIVERED_PARTIAL_WITH_EXPLICIT_ENV_OR_TEST_BLOCKERS / AWAITING_ASTRA_INDEPENDENT_REVIEW。** 本轮没有启动Dart/Flutter、Laravel测试、数据库或HTTP API服务，也没有修改业务源码。没有获得新增功能运行PASS。两个运行门均未满足，按合同交付真实受阻结果并STOP。

## 1. 权威与固定来源

- 唯一正式任务：`V10_1_5_TARGETED_FLUTTER_MARIADB_SOFTWARE_VALIDATION_AND_BOUNDED_REPAIR_TASK_20261028.md`，Blob `2bc7369a4c52afc687a5de79697ba9ee48214afa`，已fresh按路径全文读取并核对。
- 开工live main `2696cfe1d85fbbb32babb6d07d8a4596030be832` / Root `fa349b132764d15a4fa7985c26c41690859d8504` / ACTIVE_STATE `a8a7284dca7823251c93adeb1af5c48f6f26887e`；协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`；冻结plan `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- 唯一待验证源码、唯一新候选Parent `e22581525a934377e094820e57bfc608ecdfc395` / Root `573382c8bca9c9d84e8a85bb72135399ced5b3e6`。e225前轮报告 `b7b79462fea3f860dfe6c1685f641cdab8eb6529`、manifest `ecee2e5abfe41ac31758999ea589ce4a8714d528`、Astra源码审查 `ebab2e765a88f900c8fd66ae13f8a18f495a7b25`均直接读取。e225仅获得有界源码交付接受，未获整版功能接受。
- e225 apps `61c0dd9a70fcd56af00053f1d055884cecf052f0`（729 Blob）、services `cc61686579f4a89ac092f3f557ba1f8191471528`（711 Blob）均完整递归回读、未截断。此次候选完整产品树保持这两个固定身份不变，新增仅本报告及脱敏证据索引。
- main唯一已接受产品仍v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，开工main Root的两项直接匹配。未合main。

## 2. 持久账本与工作面

在首个显式工具Popen前，以CreateNew创建本任务唯一task root和`execution_ledger.jsonl`，FileStream.Flush(true)持久化。task_id=`V1015_TARGETED_FLUTTER_MARIADB_20261028`，attempt_id=`attempt-0001`，固定task Blob和e225 Parent。再次接续必须读取同一根/ledger；不能换根、换attempt或重新计服务次数。

显式工具启动按PREPARE（命令/二进制hash、类型、时间）→STARTED（pid/实例）→ENDED（exit/stdout/stderr hash）追加；Python文档/元数据助手也登记，原生PowerShell只读文件/监听元数据与GitHub读取保留于工具原证，**不是测试运行**。无MariaDB/API PREPARE事件，因此跨本任务累计均0/2，余量各2但门仍关闭；不将余额解释为可启动授权。

本地受保护对象库没有e225：唯一具名`git cat-file -t e225...`退出128，错误原证保留。没有重复lookup、fetch到旧管理区或复制旧大workspace。由于运行门同时关闭，本轮未物化完整待运行产品工作面、未下载源码归档、未声称已建立可运行review环境；新工作面只含ledger、核验记录与新文档。完整源码身份通过GitHub固定双Tree核验，候选以e225 Root为base保留全部产品。此限制是受阻交付的一部分。

## 3. Flutter / Dart：NOT_RUN_ENV_GATE_CLOSED

只读取现有工具文件、版本JSON、stamp及解析路径：Flutter元数据3.41.7，frameworkRevision `cc0734ac716fbb8b90f3f9db8020958b1553afa7`，Dart版本文件3.11.5；**没有通过运行 --version 确认引擎身份**。SDK/工具hash见索引，原始本机路径仅LOCAL_ONLY。

具名启动器`bin/internal/shared.bat`第31行把stamp置于SDK bin/cache，第55行使用重定向打开`flutter.bat.lock`，第79行按Git revision和参数构造compile key，第183行有snapshot重建时的`dart pub upgrade`路径。设置HOME/TEMP/PUB_CACHE或`--no-pub`不能消除前面的共享锁/快照写面。既有flutter_tools.stamp只有5字节，未将其当成与当前编译键匹配的可信证明，也未启动检查其后果。

现有模块的package_config有170项，引用共享Pub缓存及SDK；它来自dirty根，只用作定位写面风险，**未作为e225的可信依赖闭合证明或迁移到新工程**。e225的pubspec/lock已GitHub读取，未解析成新的私有闭合图。定点只读容量观测：Dart SDK583,336,938 bytes，Flutter packages74,045,629 bytes，Windows engine目录402,875,098 bytes；另一具名Flutter安装全目录约3.124GB。完整目录总量不等于已证明的最小运行子集下界，**本轮没有证明一个完整私有子集必然超限**；实际阻断是尚无可信且完整的私有启动、engine/snapshot/plugins/依赖/锁写面闭合。没有复制整套SDK或共享cache，也没有试启动缺件子集来触发下载/共享写。

因此`FLUTTER_TOOLCHAIN_ISOLATION_BLOCKED / FLUTTER_DART_TEST_NOT_RUN`。11个合同推荐测试均在e225 Tree中各存在一次，路径/Blob逐项写入索引；analyze、--help、test、pub和build均未启动，测试总数/exit/CPU/失败栈为null/NOT_RUN，不能把文件数当测试数。已完成的静态助手核对不构成Flutter编译或测试PASS。

## 4. MariaDB / Laravel / API：NOT_RUN_ENV_GATE_CLOSED

PATH中具名数据库可执行文件的PE产品是**MySQL Server 9.6.0.0**，55,393,920 bytes，SHA256 `c4489d69b1997bfe1508aab311a9b1a4d4097e4bd3970a5e24a7d3cbdbaeaac2`，不是MariaDB。对工具安装根、两个Program Files根及另一常规工具根只查顶层名称匹配的MariaDB安装目录，没有找到。此结论限于这些具名位置及PATH，**不是全盘无MariaDB证明**。未读取旧库、数据目录、凭据、SQL或注册系统服务。不能以MySQL、SQLite或纯PHP契约冒充MariaDB结果；没有下载或安装替代数据库。

只读检查固定43329/43339的监听表，观测无listener；端口空闲不能证明存在独立MariaDB/datadir/schema/权限。因此尚未建立新实例/配置/空合成库`elitesync_v1015_verify_20261028`，也没有datadir/instance identity/测试DB selector的运行证明。数据库前后表数、事务、HTTP状态均为**未测**，不是0或PASS。端口3306、43316、43317–43328未连接，未探测其数据库。

PHP PE元数据8.5.3；现有Laravel vendor和默认phpunit配置只做具名读取，默认sqlite=:memory:并不符合本合同，未bootstrap、未执行。没有copy vendor、修改.env、migration、Feature或API请求。因为MariaDB基础门关闭，API预算也没有占用：`DB_ENV_GATE_BLOCKED / MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED`。

## 5. F1 / F2 / F3 运行矩阵

| 场景 | 预期需验证的事实 | 本轮结果 |
|---|---|---|
| F1-IDEMPOTENCY | 同key同payload原消息/附件/通知唯一；异payload409 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F1-CONCURRENT | 两个连接并发同键、唯一约束与锁顺序 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F1-LOST-RESPONSE | 真实提交后丢响应，再同key确认与DB前后计数 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F1-REVOCATION | Block/Connection/MC/退出成员/token撤销前后权限 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F1-ATTACHMENT | ready转failed后仍回读原提交事实 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F1-CLIENT | 未知结果同key、旧会话响应与WS失效信号 | FLUTTER_DART_TEST_NOT_RUN |
| F2-T0 | 真实持久T0、register/旧family/失败登录不能伪造 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F2-REFRESH | refresh不续期、15天合成边界、session/family撤销 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F2-QUEUE | 登出/切号及两类异步凭据晚写与清理失败 | FLUTTER_DART_TEST_NOT_RUN |
| F2-OFFLINE | 只读、合成15/30天、损坏密文、异常时钟/重启锁定 | FLUTTER_DART_TEST_NOT_RUN |
| F3-PREFS | 账号分类/静默偏好及过期/类别关闭当前presentation | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F3-DEVICE | TEST_ONLY token hash/device/session/generation、换号与revoke | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F3-CLICK | 旧通知owner-only GET、撤权/禁用/换号、隐私最小正文 | MARIADB_LARAVEL_REAL_TEST_NOT_RUN_ENV_GATE_CLOSED |
| F3-ASYNC | 旧通知当前鉴权与异步导航切号阻断 | FLUTTER_DART_TEST_NOT_RUN |

无软件问题被真实复现，因此不改业务实现、测试负向断言、身份约束、两项migration或配置来获得绿色结果。e225先前31项PHP纯检查/23项lint只属于前轮历史，未在本轮复跑，也未作为MariaDB或Flutter替代品。没有新HTTP、DB计数、事务回执或工程测试exit；这些均NOT_RUN。真实Push的客户端device_id不构成物理持有证明这一Astra观察继续保留。

## 6. 原失败、预算与保护

环境准备原证保留：只读Git对象lookup exit128（源对象库未有e225）；可选工具发现命令因若干名称不存在返回1；只读助手缺少ConvertFrom-Yaml。另有一次PowerShell summary对ordered dictionary使用Select-Object显示null，已直接解析保存的JSON确认metadataOnly=true、170项、MariaDB未找到和固定端口无listener；该显示错误不是测试失败或服务启动。上述错误均未计作测试PASS，且没有消耗MariaDB/API启动预算。

保护观测：任务内只读Git元数据refs 527，tracked dirty 43，local HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`；原始列表与敏感路径LOCAL_ONLY。SDK具名文件hash/mtime会在最终回执复核。未再次枚举旧18件/ACL事故树/122件binary或整个Seed，五历史根等未重新做全量身份认证，相关历史对象本轮为NOT_VERIFIED，不能因此声称恢复或OS隔离通过。没有向保护根或旧Git管理区写入。

当前空间观测logical `140742`、allocated `151944` bytes，分别低于1,073,741,824；allocated为FileStandardInfo.AllocationSize只读核算，文件无hardlink/reparse。最终receipt另记录发布/回读后的观测；本报告数值是检查点，不是连续峰值监测。无源码大副本、SDK/cache/vendor副本或DB datadir。原始ledger/命令/路径/日志只留LOCAL_ONLY；公开索引保留脱敏摘要、hash与不可变来源。

| 运行/操作 | 本任务累计 |
|---|---:|
| MariaDB server Popen（含失败） | 0 / 2 |
| PHP API server Popen（含失败） | 0 / 2 |
| Flutter/Dart analyze/test/help、Laravel Feature、migration、HTTP请求 | 0 |
| 数据库实例/合成库创建、DB连接 | 0 |
| ACL/DACL/SACL、新fixture、restricted/对照child、14矩阵 | 0；14项NOT_RUN |
| G2/claim、历史账本、Gradle/JVM/Android/APK/AAR/POM/ADB/RTC/Push | 0 |
| 产品main集成、后继任务/v10.1.6、历史清理 | 0 |

账本检查点为 `25f71325dced1b2469f7817fd09d9391ea60cf6957989c913992153da304af13`，bytes=6234；以不可变副本保存，终态ledger含文档助手退出等后续事件，最终hash另在LOCAL_ONLY完成回执。检查点不是覆盖或重置账本，服务累计计数跨所有续接保持。

## 7. 证据分层、交付与STOP

- `DIRECT_GITHUB_OBJECT`：实时main/Root/ACTIVE、任务/协议/Astra裁决、e225 commit/Parent/Root、完整双产品Tree与目标测试路径/Blob。最终候选和两新增文档按路径及原字节回读。
- `CODEX_REPORTED_LOCAL_TEST`：**本轮无实际测试结果**；本地版本/PE/hash/解析路径/监听/容量只是只读环境观测，不提升为运行证据。
- `LOCAL_ONLY_RAW`：原始ledger、错误、命令/进程回执、本机路径、解析器配置与保护元数据。不上传凭据、token、原始数据库或OS权限原值。
- `NOT_RUN / NOT_PROVEN`：所有定向运行合同均未执行；并发/持久化/撤权/Flutter编译、物理密文/删除、设备/Push未证明。

唯一新研发候选以e225为sole Parent，仅新增报告及`targeted_flutter_mariadb_validation_evidence_index_20261028.json`；完整apps/services保持e225不变，未把源码提前合入main。最终候选Commit/Root及两文档Blob由提交后GitHub回读与完成回执固定，不在自身Blob中循环声明。

进一步运行需要先获得可信的**现有具名MariaDB二进制锚**及可闭合的Flutter私有运行面证据；这不是本轮自动安装/改SDK/改安全策略或新任务授权。未创建后继任务，未要求用新attempt重算服务预算。无本任务服务需要停止；运行写入面保持封闭。

**STOP等待Astra独立验收。** 保持`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`。
