# EliteSync v10.1.5｜Owner方案B：Laravel 12＋PHP 8.5兼容迁移与同源运行资格恢复｜正式综合研发任务

**状态：OWNER_SELECTED_PLAN_B / LARAVEL_12_PRIMARY_TARGET / LARAVEL_13_EVALUATION_ONLY / SOURCE_MIGRATION_AND_OFFLINE_COMPATIBILITY_WORK_AUTHORIZED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_NEW_EXTERNAL_DOWNLOAD_INSTALL_GLOBAL_SYSTEM_CHANGES / NO_UNQUALIFIED_PHP_API_DB_DEVICE_RUNTIME / PRODUCT_MAIN_NOT_INTEGRATED**

日期：2026-10-30（Asia/Singapore），仓库 `zcx369658780/EliteSync-v10`。

## 0. 本次Owner决定、核心问题与完成目标

Owner在Astra只读兼容性审查中明确选定**方案B**：“Laravel 12或13兼容迁移＋官方维护中的PHP 8.5＋适配的VC运行库、cURL及其它扩展依赖”，并指示“请继续”。鉴于项目既有技术选型Laravel12优先、Laravel13待评估，**本次实际源码迁移目标冻结为Laravel 12；Laravel 13只做新版本差异及迁移成本评估，不自动将真实项目升为13**。不要再围绕不匹配的14.38 DLL或旧Laravel11反复进行纯环境微任务；在一个综合任务内形成真正有改动的后端兼容源码候选、可核依赖闭包与明确测试结果。

**重要产品寿命事实（2026-10-30官方资料）**：Laravel 11 PHP支持8.2–8.4且安全维护已于2026-03-12结束；Laravel12支持8.2–8.5但其安全支持止于**2027-02-24**；Laravel13支持8.3–8.5，安全维护止于**2028-03-17**。Laravel12是**当前受限迁移桥梁**，不是永远的商用最终框架。另将Laravel13后续准入的时间/验收建议列为Owner待决定，不把它伪称已批准实施。

本轮要同时回答：
1. 在固定v10.1.5候选源上能否将Laravel11.48.0依赖与确证受影响代码完整迁移到Laravel12，并保留安全/消息/同意/设备会话/通知/离线原行为；
2. PHP8.5 Windows VS17 x64 NTS当前维护版、cURL等官方扩展及受支持v14 VC运行库如何形成来源可核的**版本一致**私有闭包；既有`vcruntime140.dll 14.38.33126.1`不再是动态执行默认候选，不能仅凭17个导出符号匹配放行；
3. 在无外部供应链权限情况下能实际完成哪些源码/本地离线Composer依赖闭包、纯契约回归和独立安全测试；剩余包或许可如何合并成下一次**一次性**Owner批准需求，而不是一串微任务；
4. 后续Laravel12同源PHP/API/MariaDB真实验证应怎样复用已审的E2E场景语义，但必须取得新预算且不得伪装本轮运行。

## 1. 唯一Authority与版本基线

执行前fresh读取live main/Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文与Git Blob、`docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`，以及当下可确认的已接受和受保护对象。

**本次唯一研发Parent（不是main、旧3bed或Astra审查分支）**：`be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`，Root `db2725ee513816f430002265e19c0f96ec21325f`，apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services Tree `dd552af956733514977cdd4bc82207c062792a96`。该Parent唯一上一提交`3bed366233a39472f8a9e905021788b8d29e12b3`。

Astra上一独立代码裁决：`astra/v10.1.5-be7ebd1f-three-issue-independent-review-20261030:docs/versions/v10.1.5/BE7EBD1F_NATIVE_THREE_ISSUE_ASTRA_INDEPENDENT_REVIEW_20261030.md`，Blob `e918c651b7c44b83c1a60e979aad065ac30e7632`。Astra新静态兼容研究：`astra/v10.1.5-php85-laravel11-msvc-compatibility-review-20261030:docs/versions/v10.1.5/BE7EBD1F_PHP_LARAVEL_MSVC_STATIC_COMPATIBILITY_REVIEW_20261030.md`，Blob `fc96469622517436d1d7a316dff7545e1dc912a9`；其C-01～C-07是本任务问题清单、非额外运行授权。

目前main最后核查HEAD `1e00aa6229ef13f26eaec7594b24f8303afac8d2`，Root `e83fe18d2c6a8edf313d9146e98c56eb6d24bd50`，正式接受产品仍**v10.1.4**：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。main文档推进后此HEAD变化，开工要重新读live，但不能将文档main等同v10.1.5已合并。

旧composer.json Blob `64af0a69ce68e0d4c1b1213cd6efb1acdfb080a1`，Composer约束`php:^8.2`、`laravel/framework:^11.31`；旧composer.lock Blob `66327f584d3961c2b53391bb012047dda9cc9d23`，Laravel11.48.0。R1私有PHP扩展政策在`tools/v1015/mainline_e2e/php_requirements.json`，旧PHP8.5.3 VS17 NTS；它仍缺Laravel官网部署必需的cURL完整资格。现有PHP8.5.3参考文件PE linker=14.44，旧vcruntime140.dll14.38不足以取得官方版本下限证据且缺再分发许可来源。

## 2. 阶段A：Laravel12真实源迁移（主工作包）

在**一份全新、隔离、task-owned私有工作面**完成固定Parent的具名源码导入、Git Blob一致性核验及Laravel11→Laravel12官方升级差异审阅，然后**实际修改候选源码**，不只产出建议性Markdown。

- 优先更新`services/backend-laravel/composer.json`的`laravel/framework`到`^12.0`，核对Sanctum、Tinker、Pail、PHPUnit、Collision、其它锁定扩展与Laravel12/PHP8.5之间的真实约束。PHP最终应锁定官方8.5维护版/兼容区间，避免仅改框架约束就宣称成功。除非可在本任务允许的**已存在且具合法来源的离线可信包闭包**中安全求解并生成真正一致的`composer.lock`，否则**不手工伪造锁文件**；保留旧锁作为明确`LOCK_RESOLUTION_PENDING`证据，隔离尚未解决的安装环节。
- 有界分析并修复Laravel12升级影响：模型UUIDv7/HasVersion4Uuids、依赖容器可空参数、文件系统local默认根、验证器SVG安全变化、route precedence、请求合并、Carbon3/PHP8.5、配置缓存/数据库选择优先级、MariaDB锁/事务/通知会话。在当前业务路径中有证据才改，不套用新Laravel starter模板覆盖现有服务。
- 安全原则：Match、Connection(CN)、Messaging Consent(MC)、Conversation、Block、账号禁用、正式关系与平台Safety分层不变；F1不可变`client_message_id`/同键重试、旧授权/旧token/旧media/通知失效、T0不被refresh重置、F3加密缓存和F4最小通知payload保持。严格保留旧Feature/Unit/Widget负向断言，只增有界契约回归；不得将授权拒绝改成200以通过新框架。
- 仅`services/backend-laravel/`和`tools/v1015/mainline_e2e/`中必要的依赖/配置/测试工具及新增本任务报告可变；`apps/flutter_elitesync_module/`原F1修复及已获有界接受的3bed测试finder**不得改动**，也不需要重跑11/11。
- **Laravel13对照仅分析**官方13 Upgrade Guide：最低PHP8.3、tinker3、phpunit12、缓存/会话序列化、CSRF中间件、MariaDB 10.11涉及的`DELETE JOIN ORDER BY/LIMIT`等语义，输出哪些关键路径需要单独重测、迁移预计影响及建议的后续日期；禁止本次将实际Composer升到13或迁移真实session。

## 3. 阶段B：PHP8.5/微软VC/cURL官方来源与版本锁定

- 官方PHP Windows当前可见`8.5.12-1`（2026-10-26）VS17 x64 NTS，是本轮**目标候选版本**而非已校验可执行字节；运行前必须另核发行时间、官方包确切URL/SHA256、签名/来源、扩展和动态依赖，不能沿用8.5.3 exe Hash/Manifest。若未来有更高的新维护补丁，先准确取证，保留Owner当次版本冻结，不自动切换下载。
- 与Laravel12官方Deployment清单比对，**cURL是要求的扩展**，连同Ctype、DOM、Fileinfo、Filter、Hash、Mbstring、OpenSSL、PCRE、PDO、Session、Tokenizer、XML及本项目`pdo_mysql`、dev工具依赖分开核算；同步更新测试配置与`php_requirements`源契约，列新增native DLL的闭包/来源/Hash/架构；不得把纯Python HTTP驱动不使用cURL作为跳过PHP官方要求的理由。
- MSVC v14 runtime以微软**官方适用的x64版本≥经核实的PHP构建工具版本**为下限；现有第三方附带`14.38.33126.1`不得因Microsoft签名、17导出匹配就私自复制。核官方REDIST发行许可、使用权、官方资产以及适配PHP包的PE import和依赖。优先已经存在且已获许可的本机**具名可读**可信字节。没有完整合法来源时`REDISTRIBUTABLE_NOT_QUALIFIED`，不伪造本地redist source receipt。
- **本任务明确授权源码与本地只读调查，但新外网下载0、软件安装/升级0、Windows全局环境变量/ACL/System32/WinSxS/注册表/安全策略写0，第三方商业软件许可购买0**。在已有可核本地依赖足够时可继续合法的私有源/配置候选；若不足，记录**一次合并的`NEXT_OWNER_SUPPLY_CHAIN_AUTHORIZATION_SPEC`**：官方PHP8.5包、Laravel12 Composer包/锁定版本、官方VC x64 Redist、cURL/native文件准确许可/预计大小/Hash取得途径与可回退规则。此单一后继授权材料不是自动下载或派发。
- 不把`STATIC_PRECONDITION_OK`、Composer约束可解、离线镜像候选写入升级为`OFFICIAL_RUNTIME_QUALIFIED`；更不能把原be7的96/96纯检查继承成新框架运行结果。

## 4. 阶段C：本任务可执行的有界检查与报告

- 本任务只要完成A中的必要源码改动就应跑有界的可信现有**纯静态/合成回归**：JSON/Composer schema、PHP语法（已有无需扩展的可信纯lint可用且符合私有路径约束才执行）、依赖版本上下限、禁止的变更路径、固定业务负向契约、SAPI/扩展策略、只读Linux/Windows兼容性原语。允许离线Composer对**事先已具名且未修改的本地包索引/缓存**作最多2次解析操作；如果涉及脚本执行、插件启动、vendor代码加载则必须另资格化，不得偷偷进入artisan/DB/PHP业务执行。
- 新单根预算：logical及native allocated分别≤**4GiB (4294967296 bytes)**，总工作窗口≤**90分钟**，一份持久ledger，全域操作前PREPARE/flush、失败也记账，同根续做不可重建退款。合成/纯检查总共最多**8批**，其中可信PHP`-n -l`命令最多**12次**，离线Composer resolution最多2次，失败亦计数；禁止用此预算重跑历史Flutter/数据库真实测试。
- 若完整合法的PHP8.5官方私有闭包、Laravel12匹配vendor与全量权限/路径/OS native握手和隔离同源均已在本任务**无需下载/安装且可以独立资格化的全新根**内成立，可提出真实无DB能力probe/Feature测试的精确后续需求，但**本任务不自动Popen PHP扩展加载、Laravel/bootstrap、MariaDB、API/HTTP服务**，也不继承be7之前0/1 probe或旧0/48操作许可。不能使用旧外部第三方安装的DLL代替。
- 不打开G2、Gradle/APK/设备/RTC/AEC/Push，严禁实际个人数据、生产数据库或任何云端业务写入。旧18、两ACL树、122原证、五根、527 Git refs、3183 Seed、旧所有错误/ledger/claims/dirty根永不清理，不回访历史ACL安全事故。

## 5. 交付、Astra独立验收与终态

创建**唯一一次集中非force研发候选**，sole Parent必须精确是`be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`；不能以main或Astra review分支为研发Parent。候选需包含有实际源码改动（至少Laravel12准备与受影响PHP依赖政策及必要回归）、新的
`docs/versions/v10.1.5/OWNER_B_LARAVEL12_PHP85_COMPATIBILITY_MIGRATION_RESULT_20261030.md`
和
`docs/versions/v10.1.5/owner_b_laravel12_php85_migration_manifest_20261030.json`。报告必须说明：Laravel11→12涉及的真实改动和旧/新依赖冲突、composer.lock是否真正离线解析、php8.5/VC/cURL供给门、Laravel13分析、源保护与A/B/C测试真实exit/日志Hash、所有`NOT_RUN`及最小合并后续授权事项。不能无运行证据就写`FRAMEWORK_UPGRADE_RUNTIME_PASS`。

Codex完成后按GitHub独立回读候选Commit、sole Parent、Root、每条变更path/mode/Blob、完整apps/services Tree与最新main，产品main仍仅v10.1.4。对源码完成但合法依赖缺口仍在的情况，终态`OWNER_B_LARAVEL12_SOURCE_MIGRATION_CANDIDATE_DELIVERED_WITH_DEPENDENCY_GATES / AWAITING_ASTRA_REVIEW`；如依赖离线完整但未运行则`SOURCE_AND_LOCK_CANDIDATE_DELIVERED_RUNTIME_NOT_RUN`；若关键源码因不可突破的依赖无法修复则`PARTIAL_WITH_EXPLICIT_BLOCKERS`。无论何种终态均**STOP等待Astra独立验收**。

维持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`，旧历史Flutter6/6和3bed3/3、MariaDB2/2、G/APK1/1仍耗尽，OS_ENFORCEMENT_NOT_PROVEN和ACL历史事故永久保留。**本次任务的Owner手动派发才是Codex可执行的起点；创建本文件不等于执行任何程序。**

## 6. 官方法规/版本参考（只读）

- https://laravel.com/docs/releases （Laravel11/12/13支持PHP及2027/2028支持终点）
- https://laravel.com/docs/12.x/upgrade （官方11→12升级差异）
- https://laravel.com/docs/13.x/upgrade （未来12→13对照，非本次实施）
- https://laravel.com/docs/12.x/deployment （cURL及其它PHP必需扩展）
- https://www.php.net/downloads.php?os=windows&version=8.5 （官方8.5 Windows NTS）
- https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist （MSVC最低运行库版本要求）
- https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files （合法再分发的实际许可条件）
