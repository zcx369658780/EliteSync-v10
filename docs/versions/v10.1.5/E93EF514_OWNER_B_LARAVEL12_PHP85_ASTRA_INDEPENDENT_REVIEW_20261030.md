# EliteSync v10.1.5｜e93ef514 Owner方案B Laravel12 / PHP8.5 Astra独立验收｜2026-10-30

**正式有界裁决：`E93EF514_BOUNDED_LARAVEL12_PHP85_MIGRATION_PREPARATION_SOURCE_ACCEPTED_WITH_OBSERVATIONS / LOCK_RESOLUTION_PENDING / FRAMEWORK_RUNTIME_NOT_ACCEPTED / V10.1.5_PARTIAL_NOT_ACCEPTED`。**

本次Astra只通过GitHub固定对象独立核验源码和脱敏报告，没有执行Owner Windows本地Python/PHP命令、Composer、Laravel、MariaDB、Flutter、APK或设备；不能把源级检查升级为运行PASS。既不合并产品main，也不自动发布下一个任务。

## 1. Authority与完整Git证据

- 原Owner正式任务：`docs/versions/v10.1.5/V10_1_5_OWNER_B_LARAVEL12_PHP85_COMPATIBILITY_MIGRATION_AND_E2E_PRECONDITION_TASK_20261030.md`，Blob `1ade4e5a89116eeba329311ed274229823aafd17`；该任务明确只允许源码兼容迁移、有限静态检查，未经新授权不得下载、PHP/Laravel/DB真实运行。
- 研发候选 `e93ef51401f4e25916149cca104f09debc32bc78`，**sole Parent** `be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`，Root `5941573199ea340a11691ce45cf3ed96282ab5a1`，compare单父ahead1/behind0，变更11个文件。
- apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，与Parent完全相同；services Tree `91611699217d6e9fae7b2ebe03e6023c90e23bbc`。11项变更路径与Manifest逐项一致，10项非自引用文件的final Git Blob经固定候选路径读取10/10一致；Manifest自身Git Blob `dbd2ef6d369bb0cfa644c97ec6c74388bad41341`，其内部自引用字段明确留待发布回读。
- Codex报告 `docs/versions/v10.1.5/OWNER_B_LARAVEL12_PHP85_COMPATIBILITY_MIGRATION_RESULT_20261030.md` Blob `10a098f9829008aff9c76170f298f004a9ffc81e`，Manifest `docs/versions/v10.1.5/owner_b_laravel12_php85_migration_manifest_20261030.json` Blob `dbd2ef6d369bb0cfa644c97ec6c74388bad41341`。
- 审查时main仍`be2204a7513145af2e764e6a36e63950aa3739b2`，Root `593fa732e1048df479fadb068e66d455f579f992`；唯一已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本Astra审查分支不是后续研发Parent。

## 2. 已接受：Laravel12/PHP8.5迁移准备源码及有界安全门

- `services/backend-laravel/composer.json`由Laravel `^11.31`改为`^12.0`、PHP由`^8.2`改为`~8.5.12`，在root明确声明Laravel部署官方扩展集合和项目`ext-pdo_mysql`，保留此前Composer scripts/plugins配置（没有运行）。此举是版本约束的真实源码变化，不是已安装Laravel12。
- `tools/v1015/mainline_e2e/php_requirements.json`规定PHP8.5.12 NTS x64维护目标，curl不再optional；`required_shared_modules`包括curl、fileinfo、mbstring、openssl、pdo_mysql，并明确所需`curl_init/curl_exec/curl_version`能力。新exe `reference_executable_sha256=null`、VC来源`NOT_QUALIFIED`、composer_lock `PENDING`，没有冒用旧8.5.3 exe Hash或旧`vcruntime140.dll 14.38`。
- `PhpRuntimeQualification::assertRuntimePolicy`以及Python`migration_contract.require_runtime_policy`对未解锁的Composer、未钉住的实际exe SHA、未核实VC来源/许可证实施fail-closed。CLI/API资格路径在读取当前新Policy后先阻断，不能把合成静态通过变成真实运行资格。
- 新`Laravel12CompatibilityTest.php`有3条待运行Feature测试，检测框架major=12、当前明确存储根与业务私有disk、F1四个不可空授权/通知依赖、SVG不被image验证默认放行。Astra核对`config/filesystems.php`以及`ConversationAtomicSendService`构造器，未见这些测试目标与当前静态源直接矛盾；测试未在真实Laravel12执行，不能宣称这些断言已动态证明。
- 对Laravel13仅提供未来风险/迁移成本分析，未变更为13；Flutter原F1修复及3bed的11/11定向Widget有界旧证据原样保留，不能当作本PHP框架新运行成果。

## 3. 保留的迁移阻断和需注意的后续条件

**核心门：`LOCK_RESOLUTION_PENDING`。** 本候选`composer.lock` Git Blob `66327f584d3961c2b53391bb012047dda9cc9d23`未更改，实质仍Laravel `v11.48.0`与旧平台PHP `^8.2`；本次没有合法已闭合的Laravel12离线包可解，因此Composer解析0/2、没有伪造锁文件。现阶段虽然已经提交了Laravel12声明，**它不是可安装的已迁移依赖集**。任何后续真正的Composer12安装/Feature测试须先取得新有效lock和具名来源，不能用旧vendor/旧lock冒充目标框架。

需要强调的来源同步观察：`php_requirements.json`的`source_documents.composer.lock`与`composer_evidence`仍引用旧11.48.0锁文件，这是此时如实保留旧source与明确PENDING的结果，不是已成功升级。**未来若获得真实Laravel12求解结果，不仅需更新composer.lock，还需按真实字节同步重冻policy的lock SHA/source_documents和已锁包证据、runtime Manifest、vendor Hash及现行CLI/API source_binding；禁止只将`composer_lock_state`文字改成RESOLVED就放行。** 当前所有运行资格在源中是FAIL-CLOSED。

- PHP8.5.12-1官方Windows x64 NTS ZIP的URL/发布SHA256是报告声称读取的外部发行元数据，未下载并未在本轮独立哈希文件；ZIP SHA不是php.exe SHA。curl/ext及全量非OS native闭包尚无真实来源/Hash/启动回执。
- Microsoft v14 x64 Redist合适版本、合法取得与对应许可及新PHP构建工具链下限仍未证明；不能仅凭旧第三方签名DLL/ABI猜测放行。
- 新增Feature源未运行；纯Python检查能验证源码契约，不能覆盖Laravel12真实DI、迁移、Sanctum Token/Auth、MariaDB事务/撤权、私有存储与真实HTTP行为。对于没有动态测试验证的框架11→12兼容改动，其是否**足够**仍未证明。
- 源码`php_runtime.py`的拒绝条件基于可信operator/封闭Manifest的一致性模型，不是不可伪造的授权数字签名或通用OS沙箱。必要时未来运行合同要独立确保真正的Composer锁文件包版本证明和受信供应链闭包。

## 4. 测试、次数及证据分级

- `CODEX_REPORTED_LOCAL_TEST`：纯静态/合成最多8批实际用5/8；第1批UnicodeDecodeError exit1保留，第2批116/116 exit0，第3批119/119 exit0，第4批静态扫描误判HTTPS schema URL exit1保留，第5批最终制品/保护核验exit0。119是最终**本轮唯一套件用例数**，116是前次版的已通过数，不应将两批累计235称为235个独立用例。没有跳过/弱化原历史安全负例的GitHub源码迹象；Astra没亲自重跑这些Windows命令和原始输出。
- PHP`-n -l`0/12：本次未具备合格新task-owned PHP纯lint闭包，新PHP Feature源无动态语法退出证明。Composer resolution0/2，PHP扩展Probe、Laravel12 Feature/bootstrap、MariaDB、API/HTTP、Flutter新批次、G2/Gradle/APK/设备/RTC/Push均`NOT_RUN_GATE_CLOSED`。
- `DIRECT_GITHUB_OBJECT`：以上Git身份与源改动；`LOCAL_ONLY_RAW`：原始输出/exit收据、旧Windows路径与私有工具、保护台账及旧PHP/Flutter原证；`NOT_PROVEN`：应用框架真实兼容性、官方依赖/VC闭包与生产部署。
- 旧Flutter6/6和3bed3/3、MariaDB2/2、G/APK1/1预算耗尽保留，之前0/1未用Probe不自动迁移。旧ACL事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`及旧18、两实验树、122原证、五保护根、527refs、3183 Seed、所有旧账本/失败/claims/dirty保持不可变；仅按Codex既有有界证据分类，不声称Astra实机复核所有历史SD。

## 5. 独立终态

**`OWNER_B_LARAVEL12_MIGRATION_PREPARATION_SOURCE_ACCEPTED_WITH_OBSERVATIONS / LOCK_RESOLUTION_PENDING / PHP_TOOLCHAIN_SOURCE_NOT_QUALIFIED / FRAMEWORK_FEATURE_NOT_RUN / API_DB_E2E_NOT_RUN`。**

仍维持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`、AC01–11=10 PARTIAL/1 OPEN。

**下一步建议集中一次获取新官方PHP8.5维护包、Laravel12 Composer锁依赖、合法MSVC Redist/cURL闭包与独立测试权限**；官方资源及供应链的新下载/安装/系统改动与真正PHP/API/DB运行必须按Owner明确新许可冻结，不能凭本审查自动执行。将来可在同一集中任务中完成依赖解析、真实Laravel12/无DB Probe与合成MariaDB/API业务回归，但不可把此阶段再打散成旧Hook/ACL微任务。本审查文档发布后STOP，禁止自动任务签发、合main或关闭AC05。
