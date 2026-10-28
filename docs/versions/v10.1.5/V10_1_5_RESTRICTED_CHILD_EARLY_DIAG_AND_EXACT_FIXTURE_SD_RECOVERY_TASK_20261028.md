# EliteSync v10.1.5｜受限子进程启动期只读取证与18份Fixture安全描述符精确恢复——主线综合返修任务

**状态：OWNER_APPROVED_BOUNDED_EARLY_STARTUP_DIAGNOSTIC_AND_FIXTURE_SD_REPAIR / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / ZERO_RESTRICTED_CHILD_LAUNCH / ZERO_GRADLE / ZERO_G2_CLAIM / NO_SDK_OR_GLOBAL_SECURITY_CHANGE**

日期：2026-10-28（Asia/Singapore）
权威仓库：`zcx369658780/EliteSync-v10`
Owner最终决定与不可逆变更；Astra Planner/Independent Reviewer；Codex必须由Owner在本地手动派发。**发布任务不等于已派发、已实施或任何OS门通过。**

## 0. 授权目标、不可隐含解锁的权限

Owner在Astra对`8186cebc`的有界失败交付验收后明确同意下一阶段**仅集中解决两个阻断**：
A. 受限子进程`0xC0000142`的**启动期早期诊断和未来回执捕获设计**，只可利用既有原始日志/系统中本来存在且可合法只读的同期事件及Windows/pywin32固定来源，不启动任何新的受限子进程；
B. 本任务自己新建可丢弃fixture先验证`SECURITY_DESCRIPTOR_CONTROL`（包括`0x0400 SE_DACL_AUTO_INHERITED`）的可逆原字节/精确语义恢复，再在**严格具名与限次门禁**下对上一任务`8186`留下的18个**历史task-owned fixture对象**作一轮有限、可审计的定点权限描述符恢复。此项例外绝不授权修改其它历史任务结果或证据、原Seed/共享缓存、用户根或系统权限。任何安全/来源/身份不闭合即STOP，仅交付调查和恢复提案，不触碰原18项。

本次零工程运行：真实Gradle/JVM/Flutter/Dart/AGP/Kotlin、G2 Popen/claim、AAR/APK、ADB/RTC、工程observer/Job/Socket及真实网络实验、Gate2、数据库/生产均**0**；Windows restricted child `CreateProcessAsUser`/`CreateProcessWithToken`/等效调用、新普通token对照child或“重试一次”均**0**。可执行已有本地Python进行纯静态/mock、精确只读Windows Event Log API取证（若系统允许）及**本任务拥有fixture的ACL恢复实验**；不得运行外部程序来完成DLL或token试验，不使用D盘根全盘目录或进程扫描。只有后续Owner独立授权才考虑新的受限子进程尝试。

**最重要的不可变端点：`RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / G2_READY_FOR_POPEN=FALSE / INPUT_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`。** 不可因测试/恢复成功宣称有受限child访问回执或完成14项矩阵。

本任务新Owned文件/日志/fixture与任何隔离副本的总逻辑与实际file-allocation预算**≤64MiB（67,108,864 bytes）**，按首/中/末记录；**不复制旧1.3GiB Seed或整套SDK**。历史APK/G各1/1耗尽，旧A门禁关闭，G2前轮本地报告0/1无claim仅为条件余额，**本任务不得消费、创建、修改任何预算claim/ledger**。

## 1. Fresh authority和必须按来源分级的固定输入

在启动任何修改前，fresh GET live main、Root/`docs/workflow/ACTIVE_STATE.md`、本任务全文及Blob、2026-10-28 Astra独立裁决、8186完整报告/索引、原冻结G2及6ca源码接受合同、保护规则；比对候选Parent/Tree。

- 发布任务前main `34b06e3c6dd9ae09cd767468052f1828a5a5ced0`、Root `0c54cb1201afe960fd8d8007db2f37849a44a86c`；唯一已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本轮修复的**未接受固定候选** `8186cebc94661bcdc229ee5b62b31871dc784a4c`，唯一Parent `76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7`、Root `1d9ec83dbfe6c211d95f713d5aa4ab93f69d8bf7`，apps `5af7a9d0042be19437616e969e260658b67e9353` / services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`，不等于main产品。8186报告 Blob `e773c0139dc4c0d6c91abad7553508382975d4e0`、脱敏索引 Blob `0cfc46b50f092b5c1c10df7ea4e065af3141144a`。
- Astra审查 `astra/v10.1.5-8186-restricted-identity-blocked-review-20261028:docs/versions/v10.1.5/8186_RESTRICTED_IDENTITY_OS_GATE_ASTRA_REVIEW_20261028.md`，Blob `a6a01ad4d56633cf2ab0aeed66658067c2fc42ed`，审查HEAD准备时 `b2a554990bf6ca7424df3b49b85acf67b2a75f41`。
- 上游76e独立Seed报告/证据及OS权限`NOT_PROVEN`不可改写；原G2 dry-run合同 Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`；历史旧APK/G claims、原gradle下载partial、受保护五根/527 refs、SQL/APK、日志与旧Seed均维持不可更改。历史partial `7,941,328 bytes/SHA256 b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`、旧APK claim `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`，原A/G2 claim此前不存在。只要求本轮具名只读首尾证明，不冒充全量复算。

**历史失败真相：** 一次`CreateRestrictedToken`与`CreateProcessAsUser`据Codex成功；真实受限child exit `0xC0000142`、controller 90，无child stdout/stderr、无首事件、14项权限矩阵全部`NOT_RUN`；不是自动证明某DLL、桌面、profile或SeIncreaseQuota因果。18个旧fixture原始/恢复后SECURITY_DESCRIPTOR_CONTROL分别`0x8404`/`0x8004`（异或`0x0400`）；规范ACE、owner/group、FileId及内容据上轮相同，**精确描述符18/18失败**。必须核对**本地原始SDDL、对象身份与捕获原件**；只有GitHub摘要不构成修改许可。

## 2. 工作A：启动期最小只读取证，零新进程启动

1. 在8186已有原始`LOCAL_ONLY`的只读归档中核对真实命令/受限token flags/SID + attributes、暂停创建/线程恢复时序、`STARTUPINFO` / standard handles/env/currentDir/loader DLL search、Python `-I -S -B`、profile/desktop、运行时文件访问是否本来就有记录；不得凭0xC0000142反填未记录的DLL名、先前不存在的stderr或事件。
2. 可对本机**既有只读**Windows Event Log Application或相关系统错误报告，按已知事发时间+可确认的**那一次child进程身份**定点查询（例如已存在的EventID/模块资料）；查询必须有明确时间上限且不能读取不相关应用/用户事件正文。没有可匹配的事件写`NO_CORRELATED_EVENT_AVAILABLE`，拒绝查询写`EVENT_LOG_READ_BLOCKED`；不得提权、改日志设置、清日志、启用新ETW provider、安装ProcMon/调试器、重新运行受限child或发起网络请求。事件时间和同名进程**不足以单独证明**同一失败实例，必须证据分级。
3. 根据Windows已固定接口/本地已有可信来源设计未来必要的**启动期最早回执机制**（受限child进入Python之前的DLL loader诊断、早期Win32/NTSTATUS、可flush的任务私有stderr/file/ETW既有被动事件、token/进程identity标识及其局限），输出**提案和有界mock**，不执行新launch。若无法提供真实同实例事件，保持`CHILD_INIT_ROOT_CAUSE_NOT_PROVEN`。不可把source级`STATUS_DLL_INIT_FAILED`错误类别升级成具体DLL根因。

## 3. 工作B：安全描述符原状精确恢复，一次性可丢弃新Fixture先行

**禁止先修改8186旧18对象。** 先只读建立这18项**精确恢复前登记表**，至少有路径别名、Task-root来源、原始及当前SDDL原字节/控制字段、FileId/VolumeId/link/reparse/祖先身份、owner/group、DACL/SACL可见性、content hash、父目录delete/rename边界、是否另被引用。真实SID/路径一律LOCAL_ONLY，任何对象不是旧任务独有fixture、身份变动或原描述符无法可信还原则**全部停止旧对象恢复**。

然后在**全新可销毁的本任务fixture**测试同形态`0x8404→0x8004`问题，精确研究`SE_DACL_AUTO_INHERITED`如何由Windows SetNamedSecurityInfo/SetSecurityInfo/SetSecurityDescriptorControl/pywin32当前版本/继承保护规则表示与恢复。要区分真正可写回的control位、由OS派生的只读/自动继承位、DACL ACL revision/inheritance flag、SACL获取权限不足和SDDL字符串视图差异；**不能仅改断言、只比较ACE就宣布原样恢复**。新fixture只执行原始descriptor捕获→一次明确变更→一次精确恢复→原始和恢复后的原字节/可取得字段、FileId、owner/group、ACE、control和文件内容逐项验证，并保留失败回执。可定向重复纯mock，但真实新fixture变更/恢复流程**最多2个独立fixture、各1轮**，失败不得连续试不同权限设置求绿灯。系统可能规范化control时，如无法在非提权下原样恢复，记录`CONTROL_BIT_NOT_RESTORABLE_UNDER_CURRENT_API`，不得伪造精确PASS。

**旧18项定点恢复是有条件、最多一次的额外授权：** 仅当新fixture与旧对象属于同类ACL/control配置、原恢复方法已在真实新fixture**严格18字段/控制位原样回读**，且18件旧对象身份/原始SDDL来源/当前状态与上轮固定证据全部逐件匹配、无别的工作引用、权限/回滚方案完整、单对象失败能即时STOP时，才允许对具名旧18项逐件最多**一次**精确descriptor恢复尝试。前后全部LOCAL_ONLY原始属性、ACL、SACL可见性、hash、操作Win32/NTSTATUS和时间需持久记录；任何失败**停止后续对象**，不能扩大ACL/继承/提权或用另一设置连试。**不得覆盖旧fixture原始失败证据**；优先将前后快照与回执写到本任务独有证据目录。恢复不成功则按`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`保留阻断，**不得为了交付成功删除旧fixture、改owner或触碰共享目录**。这不是旧任务全域写入授权。

**若新fixture无法严格恢复或看不到原18个对象真实完整SDDL，停止旧对象写入。** 已经有ACE/owner/内容相等不能代替control/SDDL严格恢复。fixture快照源不可信则只报告必要Owner下一门，不对保护根试探修复。

## 4. 测试、数据/证据边界与成功分类

- 全任务不得运行Gradle、JVM、Flutter、Dart、受限child、任何真实访问矩阵负例、G2或工程网络；只能使用当前Python本地静态/mock、已有系统日志只读查询及task-owned ACL fixture/明确有条件的18项旧task-owned恢复。**不要新增本机用户、服务、AppContainer、系统级权限或全局防火墙/代理策略**，不修改SDK、Seed或D盘历史目录。旧18项是唯一例外白名单，不准泛化。
- 预算：`NEW_RESTRICTED_CHILD_LAUNCH=0`、`GRADLE=0`、`G2_POPEN=0`、`G2_CLAIM_WRITES=0`、`NEW_DISPOSABLE_FIXTURES≤2`、`EACH_FIXTURE_REAL_ACL_ROUND≤1`、`OLD_FIXTURE_REAL_SD_RESTORE≤1_PER_OBJECT_AND_STOP_ON_FIRST_FAILURE`、`TASK_NEW_STORAGE≤64MiB`、`D_DRIVE_SCANS_OR_CLEANUPS=0`、`GATE2=0`。无隐式自动重试或改变既有old G/A预算。
- 交付分类可以是：`EARLY_STARTUP_DIAGNOSTIC_BOUNDED_NO_RELAUNCH`与`NEW_FIXTURE_EXACT_SD_RECOVERY_PROVEN`；旧18项全精确恢复才可增加`OLD_FIXTURE_SD_RESTORATION_CLOSED_LOCAL_ONLY`，否则`RESTORATION_BLOCKED_WITH_ORIGINAL_EVIDENCE`。不论结果仍`CHILD_ACCESS_MATRIX_NOT_RUN_14_OF_14`、`RESTRICTED_IDENTITY_GATE_BLOCKED`及`G2_READY_FOR_POPEN_FALSE`；别在此报告下一轮OS PASS。
- 只读/本地动作需保留有界stdout/stderr/exit与source/fixture SHA、时间、原证Hash、DACL control和错误码。对保护五根/101具名原证、旧Seed3183、527refs、G2 claim和历史账本只读具名首尾验证；若数量不同如实报告，不自动修改新基线。所有私密ACL/SDDL/SID/路径、实际pid与日志仅LOCAL_ONLY。
- 公开交付集中为`docs/versions/v10.1.5/G2_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_SD_RECOVERY_REPORT_20261028.md`与`docs/versions/v10.1.5/G2_RESTRICTED_CHILD_EARLY_DIAG_AND_EXACT_SD_RECOVERY_EVIDENCE_INDEX_20261028.json`。确有必要可发布极少脱敏静态/fixture测试源码，严禁发布host进程和安全描述符完整信息。
- 普通non-force独立候选以8186候选为唯一来源Parent发布；验证Commit/唯一Parent/Root、全部新增path/mode/Blob/Git原字节与完整apps/services Tree不变；live main仅文档权威，不集成产品main。

**最终STOP等待Astra独立验收和Owner后续新运行许可。** 不会因本任务全部fixture严格恢复即自动获得`CreateProcessAsUser`再次尝试/工程G2授权，不自动发后继任务、合main、扩大空间、删D盘目录或启动v10.1.6。
