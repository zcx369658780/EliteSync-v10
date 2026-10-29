# EliteSync v10.1.5｜955307d8 Flutter与MariaDB定向验证：环境阻断｜Astra独立验收

日期：2026-10-29（Asia/Singapore）。

**正式裁决：`955307D8_BOUNDED_ENV_GATE_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`。**  
**执行结果：`FLUTTER_TOOLCHAIN_ISOLATION_BLOCKED / MARIADB_ENV_GATE_BLOCKED / ALL_TARGETED_TESTS_NOT_RUN / ZERO_NEW_SOFTWARE_RUNTIME_EVIDENCE`。**

本裁决仅接受符合原冻结任务STOP要求的**有据可查、未越权的环境受阻交付**。不接受任何Flutter编译、Laravel/MariaDB Feature/API/持久化/并发、实际15/30天或v10.1.5整版软件功能PASS。本轮不能称为测试通过、实际OS隔离通过或新增产品功能实现。

## 一、GitHub对象与范围核验

- 唯一Owner任务：`docs/versions/v10.1.5/V10_1_5_TARGETED_FLUTTER_MARIADB_SOFTWARE_VALIDATION_AND_BOUNDED_REPAIR_TASK_20261028.md`，Blob `2bc7369a4c52afc687a5de79697ba9ee48214afa`。允许在可信私有Flutter写入/依赖闭包与独立MariaDB合成实例资格成立后定向运行，并允许同任务有界软件修复；资格不成立必须`NOT_RUN_ENV_GATE_CLOSED`、不能替换旧DB/共享SDK/引擎。任务新服务预算MariaDB/PHP API各最多2次Popen，跨所有恢复会话持久计账，任何失败启动也占额。
- 开审fresh main `2696cfe1d85fbbb32babb6d07d8a4596030be832`，Root `fa349b132764d15a4fa7985c26c41690859d8504`；`ACTIVE_STATE` Blob `a8a7284dca7823251c93adeb1af5c48f6f26887e`。main唯一接受v10.1.4产品apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- Codex候选 `955307d8c1cd95897e5af0f19a347c6fa4e77ff1`，sole Parent `e22581525a934377e094820e57bfc608ecdfc395`，Root `10ea9f401291983ac7abc45e7497411471bb4c32`。GitHub compare e225→9553为ahead1/behind0，严格仅新增2份docs，零产品源码差异、零源码修复。GitHub递归Root共6263项，`truncated=false`；其完整apps `61c0dd9a70fcd56af00053f1d055884cecf052f0`（729 Blob）、services `cc61686579f4a89ac092f3f557ba1f8191471528`（711 Blob），与e225原候选完全相等。
- 报告 `docs/versions/v10.1.5/TARGETED_FLUTTER_MARIADB_VALIDATION_AND_REPAIR_REPORT_20261028.md`，Git Blob `56eb994c71df95077e1c74b74371f7d75d070184`，Tree bytes 12912，mode `100644`；索引 `docs/versions/v10.1.5/targeted_flutter_mariadb_validation_evidence_index_20261028.json` Blob `e290ba53e472c87c0538de0c550d43b64fdcf648`，Tree bytes 11490，mode `100644`。两份按固定commit路径读取、索引成功JSON解析，Git Tree Blob身份一致；Astra没有重算本地报告自申报的SHA256或接触本机LOCAL_ONLY原始回执。
- 公开索引合同共14条F1/F2/F3场景，全为`NOT_RUN`；Flutter列出11个具名测试路径及Blob，但**文件存在≠测试已执行**。报告/索引一致保留0运行、无API/DB/事务/迁移结果、无代码修复，未合main。

## 二、Flutter阻断：写入/依赖资格未闭合

Codex只读报告当前可见Flutter元数据3.41.7、Dart版本文件3.11.5；未运行实际`--version`核证。现有`shared.bat`读取显示共享SDK cache stamp、`flutter.bat.lock`重定向写、snapshot/compile key与潜在`dart pub upgrade`路径；这使简单设置`HOME/TEMP/PUB_CACHE`或`--no-pub`**不能自动证明SDK共享写面已被隔离**。已存在的170项`package_config`来自旧dirty根并引用共享包缓存，不能代表e225固定候选的一份真实已闭合的私有依赖图。

报告列举私有执行所需部分目录容量，却没有证明“任何合法最小私有子集必然超本任务1GiB预算”；不得把此推断补成确定事实。**真实阻断是缺少可验证的私有SDK启动/engine/snapshot/plugin/依赖闭合与写入隔离**。不启动Flutter/Dart测试、analyze、help、pub或build是合同要求下合理STOP；不得把11份测试源码计作运行数。

## 三、MariaDB阻断：产品身份不符且私有实例不存在

Codex定点只读观察PATH中`mysqld.exe` PE产品为**MySQL Server 9.6.0.0**（报告固定binary hash `c4489d69b1997bfe1508aab311a9b1a4d4097e4bd3970a5e24a7d3cbdbaeaac2`），不是MariaDB；对具名安装根的有限查找未发现可核验MariaDB。**这是边界内未发现，不是全盘不存在MariaDB的证明**。不得在没有新Owner授权和测试合同变更情况下用MySQL/SQLite替代MariaDB。

43329/43339未见监听，只证明此时无监听者；不证明空私有datadir、独立配置、权限、DB selector或可用Laravel环境。实际MariaDB/PHP API的Popen均**0/2（CODEX_REPORTED_LOCAL_LEDGER）**，独立合成DB实例/连接/迁移/Laravel Feature/HTTP/并发一律`NOT_RUN`。没有执行旧数据库任何操作。本轮不消耗条件性余额，也不将未使用余额说成运行门自动开放。

## 四、执行账本、范围保留与质量分级

- Codex报告在首个具名显式工具Popen之前通过CreateNew生成task-owned root与持久ledger；固定`task_id=V1015_TARGETED_FLUTTER_MARIADB_20261028`、`attempt_id=attempt-0001`；公开记录checkpoint SHA256 `25f71325dced1b2469f7817fd09d9391ea60cf6957989c913992153da304af13`和6234 bytes，明确其不是最终ledger SHA。Astra没有直接读原Windows账本，不将`0`升级为全机器进程排除证明。
- 报告原本地Git对象库对`e225`的定点`git cat-file`为exit128，证据未覆盖；没有因此对保护Git目录fetch/clean/reset或创建新引用。正因两环境门均未闭合，本轮**未物化完整e225测试工作面**；这也是下一次合法运行前必须补齐的输入，不能伪称已有可测源码目录。
- 本轮各项实际运行测试=0，源码变化=0，修复=0；不是找到产品Bug，也不是证明代码无Bug。当地环境只读准备命令出现lookup/展示/工具缺失回执，原失败均保留，不作为软件测试失败。私有task根检查点logical 140742 / allocated 151944 bytes，低于1GiB，最终占用仍应以LOCAL_ONLY completion receipt为准；不是连续峰值。
- 保护观测只读：527refs、43 tracked dirty及已知本地HEAD；未重新逐件核旧18、122原证、五保护根、3183 Seed，故对应当前OS身份检查为`NOT_VERIFIED_THIS_TASK`。历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`按Owner决定永久封存，A/B实验两树、旧18、claims/ledger/Seed及旧失败原证保留，未授权清理、退款或重试。
- 本轮 `CODEX_REPORTED_LOCAL_TEST` 明确为**NONE**；`DIRECT_GITHUB_OBJECT`仅负责仓库文件、提交、Tree与索引；`LOCAL_ONLY_RAW`为本机ledger/工具Hash、路径/环境元信息；`NOT_RUN/NOT_PROVEN`真实矩阵不能由GitHub证明成PASS。

## 五、Astra独立裁决与下一步

**`955307D8_BOUNDED_ENV_GATE_BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS`**：接受按冻结任务进行有限资格预检、零环境越权真实执行及零产品源码改动的受阻报告，诚实保持所有`NOT_RUN`。该裁决不改变上一轮`E2258152_BOUNDED_SOURCE_DELIVERY_ACCEPTED_WITH_REQUIRED_VALIDATION`的有界源码状态；没有新增Flutter/Laravel真实运行证据，不能签发v10.1.5功能接受或AC05关闭。

**下一次建议不是盲发相同测试任务：** 先由Owner选择一个具名可信MariaDB来源（可核验已安装的准确二进制或另行审批获取/安装）、以及一份不会写保护SDK/cache的Flutter运行隔离方案，并确认任务自有e225源码工作面准备路径。可信输入就绪后，才能以单一新冻结合同有界重用未测F1/F2/F3正反例；当前GitHub没有本机环境的真实安装事实，不可声称这些条件已满足。

旧APK/G预算1/1耗尽、旧A关闭；G2额度以前Codex回执0/1但本任务没有授权；Gradle/JVM/Android/APK/设备/RTC/真实Push/第三方供应商与生产DB均不开放。`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN_FALSE / AAR_POM_RUNTIME_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / RTC_AEC_NOT_CLOSED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / V10.1.6_NOT_STARTED`全部持续。

**STOP，等待Owner对具体环境来源与下一步权限的决定；不自动创建后继、安装软件、放行G2、重跑旧ACL、合main或进入v10.1.6。**
