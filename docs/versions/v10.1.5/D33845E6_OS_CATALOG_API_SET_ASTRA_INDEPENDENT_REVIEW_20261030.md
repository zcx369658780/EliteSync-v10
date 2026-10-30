# EliteSync v10.1.5｜d33845e6 OS Catalog／API-set Schema Astra独立验收｜2026-10-30

**正式独立裁决：`D33845E6_BOUNDED_OS_CATALOG_AND_MINIMUM_IMPORT_SOURCE_ACCEPTED_WITH_OBSERVATIONS / API_SET_SCHEMA_RAW_NOT_ARCHIVED / API_SET_REAL_HOST_RESOLUTION_NOT_PROVEN / OS_OBSERVATION_2_OF_2_EXHAUSTED / PHP_COMPOSER_LARAVEL12_API_DB_NOT_RUN / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本次Astra通过GitHub连接器直接读取候选、Parent、Root Tree、GitHub compare、所有变更路径及非自引用Blob、源码和Codex脱敏报告/Manifest。Astra**没有**在Owner Windows主机重演catalog成员签名、API-set Schema原始字节解析、PHP Popen、Composer求解或Laravel/MariaDB业务。所有真实Windows本机观察和247个纯合成用例的退出均属于`CODEX_REPORTED_LOCAL_TEST`；本报告不把它们升级为Astra实机验证。

## 1. 固定Authority与Git对象

- Owner当前正式任务`docs/versions/v10.1.5/V10_1_5_WINDOWS_OS_CATALOG_TRUST_MINIMAL_IMPORT_AND_LARAVEL12_E2E_CONSOLIDATED_TASK_20261030.md`，Git Blob `5ac1777d3f9cac6e414208a9a9e1a9bbb36a61b0`；该任务授权定点OS来源观察2次及条件式PHP/Composer/Laravel12/API/DB，不允许Windows VC安装、System32/WinSxS/ACL/全局配置修改。
- 唯一研发Commit`d33845e62f1aa5eb82e0a4bf443b0396f2eb8b1a`，**sole Parent`14e6cde7b714c5bacdeedeb87233345d36a435c5`**，Root Tree `89665b425cd6c2bc9d32f49e300e35614abfe4e8`；compare ahead1/behind0。
- 变更共19项：17项tools/tests等源与2个结果/Manifest文档；GitHub实际变更路径与Manifest一致，**18/18非自引用文件Blob直接读回全部匹配**；Manifest自身Blob `12347128fceeb36035436323b71878df6c08d721`，不以自引用代替GitHub发布回读。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，与Parent完全一致；services Tree `bc44baa6f04ce57a8a6dc331be12c67a79e6e0da`，变更只在非生产E2E资格工具和测试，不涉及F1/F3/F4正式业务controller/routes/migrations。
- 报告`docs/versions/v10.1.5/OS_CATALOG_MINIMAL_IMPORT_L12_API_DB_RESULT_20261030.md`，Blob `a152cc65b361ef8b390188588a1807d757823903`；Manifest`docs/versions/v10.1.5/os_catalog_minimal_import_l12_api_db_manifest_20261030.json`，Blob `12347128fceeb36035436323b71878df6c08d721`。
- 审查时main HEAD `24e5a96e7b2c1fc0437aa76417ff08e6aae3ab06`、Root `3b10f72a78eb320caaf4e54c916a1eafa76dabf8`；已接受产品仅v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本Astra分支不是后续研发Parent，不合并产品main。

## 2. 有界接受的具体成果

**普通PE导入与OS签名来源分层：** `pe_dependencies.py`现在区分`ordinary_imports`与`delay_imports`且保留旧`imports`并集接口；`minimal_imports.minimum_private_graph`从官方PHP的`php.exe`和5个必需扩展出发仅递归普通私有依赖。Codex报告得到13个私有成员、13个直接普通OS种子，OS沿普通导入递归得到23个具名必要DLL；没有把405个OS delay边当成预启动强制条件。此分层**可作为静态候选闭包**，不能免除未来真实Popen后对延迟加载/未知映像的全量观察。

**Catalog成员签名：** 新`windows_os_trust.py`包含Windows受支持的CryptCATAdmin成员Hash/目录定位和WinVerifyTrust/证书链/可信时间校验路径，并对embedded与catalog成员做独立分类。Codex本机第1次观察称23件必要OS文件均通过：19件embedded、4件catalog，包含历史阻断`iphlpapi.dll`、`wldap32.dll`、`secur32.dll`、`normaliz.dll`；第4个catalog成员是`dsparse.dll`。观察报告明确绑定真实成员文件FileId/Volume/大小/Hash、规范路径、catalog member hash/tag、WinTrust catalog选项、签名者/时间戳证据及cache-only撤销。Astra从GitHub源码确认相应路径与负例存在，但证书DER、目录原字节、实际API回执留`LOCAL_ONLY_RAW`，**没有独立重算这23个文件的签名**。不能据此认定所有Windows文件、所有OS模块或PHP整体ABI通过。

**新API-set资格边界：** `api_set_schema.py`将API-set contract与真正宿主文件分开。当前`current_native_task.validate_api_set_closure`要求有签名且身份匹配的schema原始归档、具体普通导入合约映射、实际OS PE来源/Hash，重新遍历并比对声明的完整普通导入边集合；`current_native_task.execution_gate`预先检查终态STOP、时间和账本，并要求OS/中央VC与官方private文件均在独立闭包内。普通/延迟导入分离不是对已加载额外模块的豁免。PHP侧current task身份与旧关闭集合已同步更新，未改生产业务鉴权或旧安全负例。

## 3. 重要保留问题：第二次观察不是有效API-set宿主解析证据

报告中的第2/2次具名OS观察，对已命名`ApiSetSchema`本身的签名/文件身份取得本机证据，但**实际PE/schema解析在`API_SCHEMA_HOST_PATH`失败**；没有继续取得真实普通合约的宿主映射。更关键的是，**未在解析之前把当次schema原始字节持久归档**。Codex仅保留了错误/traceback、schema签名与文件Hash等收据，缺少能独立重放这次解析缺陷的确切输入字节。两个观测名额2/2用完，STOP后不能补读原文件、复用旧余额、把“已修复”作为实际新观察结果。

候选新增`archive_then_parse(pe,evidence,persist)`，已按源码顺序将`persist(pe)`放在解析之前；解析器不再针对**未选择**的schema entry预先强制`host`文件名后缀，同时对最终选择的映射继续验证非空、无歧义与安全DLL命名。这是具名**源码修正＋纯合成验证成果**。但`persist`是由外部调用方注入的回调，函数本身不证明真实OS观察入口已执行落盘、flush/fsync、写入后字节Hash核对或失败保留；该行为必须在后继真实观察的task-owned ledger与原始收据中独立证明。Astra未读取实际schema输入，**不能推定本机真实失败确由“未选中kernel宿主”引起**，也不能认定该补丁已通过真实schema。正式保留`API_SET_SCHEMA_HOST_MAPPING_NOT_PROVEN / API_SET_RAW_INPUT_ARCHIVE_MISSING`。

## 4. 测试、次数与保护

- Codex报告纯Python/AST/synthetic最终**247/247 passed、failed0/errors0/skipped0、exit0**；本任务前次224/229/236/239/241/246/246/247为同一套件的多批版本，不是独立用例累加。Astra已审源码和Manifest，**没有本机重跑这247项，也没有执行PHP源语法/lint**。
- 新OS具名观察**2/2已耗尽**；central VC重做0（保留上一有界接受的版本/信任证据），官方PHP13个private成员本轮新工作根复制，未重复下载ZIP。PHP CLI0/60、DB-free Probe0/2、Composer PHAR及包供应0、Composer解算0/2、vendor安装0/1、Laravel12 Feature0/3、MariaDB/API启动0/2、业务HTTP0/160、migration/seed0。旧Laravel11.48.0`composer.lock` Blob `66327f584d3961c2b53391bb012047dda9cc9d23`，仍`LOCK_RESOLUTION_PENDING`；不能标记Laravel12 lock或应用已经运行。
- 本任务窗口与空间消耗是Codex本地报告：单一root/attempt与ledger，elapsed 1871.453秒、logical 52,038,320 bytes、allocated 55,203,840 bytes（离散快照不是连续峰值），8GiB/120分钟上限；历史受保护dirty/527refs/旧5个具名根及收据报告未修改，Astra并未重演旧18/两ACL树/122原证/3183 Seed的逐件检查。旧Flutter6/6与3bed3/3、MariaDB2/2、Gradle/APK1/1、旧OS观察不复用/不退款。`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`保留。
- 本报告证据等级分开：`DIRECT_GITHUB_OBJECT`（SHA与正文/源码）、`CODEX_REPORTED_LOCAL_TEST`（23件Windows信任及247用例和预算）、`LOCAL_ONLY_RAW`（证书、Schema、系统路径/进程及原始ledger；本轮schema输入例外为**未持久归档**）、`NOT_RUN_GATE_CLOSED`（PHP/Composer/Laravel12/API/DB）、`NOT_PROVEN`（API-set宿主、实际Native完整闭包、PHP真实加载、RTC/Push与设备实物运行）。

## 5. 独立终态与下一门禁

**`D33845E6_BOUNDED_MINIMUM_IMPORT_AND_WINDOWS_OS_SIGNATURE_SOURCE_ACCEPTED_WITH_OBSERVATIONS / API_SET_RAW_ARCHIVE_NOT_PROVEN / API_SET_HOST_RESOLUTION_NOT_PROVEN / NATIVE_POPEN_NOT_AUTHORIZED_POST_STOP / LARAVEL12_LOCK_PENDING`**。

后续若Owner明确授权，建议只针对仍未关闭的**具名API-set schema真实输入**冻结一次有界观察，并在读取前确立完整原始字节写前PREPARE、落盘、fsync、Hash、签名及失败保留；对确切选中的普通合约实现宿主映射与身份签名，确认strict post-Popen动态镜像资格。**不要重复23个已合格OS文件的全面静态签名、既有中央VC调查、旧PHP ZIP、重装系统或历史ACL专项。** 完整原生资格成立后，才按新Owner独立预算执行PHP Probe、可信Composer/Laravel12真实lock以及隔离MariaDB/API业务回归；没有新授权前STOP，不偷用本轮剩余的PHP/Composer额度。

当前`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`仍不改变，AC01–11仍10 PARTIAL/1 OPEN。**本轮只归档Astra独立审查分支；不发布后继任务、不合并main、不签整版FUNCTION_ACCEPTED。STOP等待Owner。**
