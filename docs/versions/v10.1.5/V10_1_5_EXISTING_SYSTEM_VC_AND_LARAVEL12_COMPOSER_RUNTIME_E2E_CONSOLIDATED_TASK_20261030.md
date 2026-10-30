# EliteSync v10.1.5｜现有Microsoft v14系统运行库资格、Laravel12真实Composer锁与同源API/DB综合验证｜Owner正式任务

**状态：OWNER_APPROVED_CONSOLIDATED_CONDITIONAL_SOFTWARE_WORK / EXISTING_INSTALLED_VC_FIRST / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_SYSTEM_VC_INSTALL_AUTHORIZED / NO_PRODUCT_MAIN_MERGE**

2026-10-30（Asia/Singapore）；权威仓库：`zcx369658780/EliteSync-v10`。

## 0. 方向、授权解释与真实目标

Owner在Astra独立验收`f16d4cda`后，对“集中解决VC合法部署路线、Composer真实锁和动态PHP/API/DB”表示同意并要求继续。**不从这个概括性同意推导出运行Windows官方VC安装器、提权、改全局系统或从安装器拆DLL的授权。** 在此唯一长任务内优先审查机器**已经安装的受信Microsoft v14 x64 central runtime**：这是既有运行库的只读使用资格，不是软件再分发，也不需要把DLL提取到应用私有目录。如果已存在、版本/签名/加载链完整合格，才按预算继续真正Laravel12依赖和软件验证；不存在或条件不合格则STOP风险项，集中提出一次准确的Owner安装选择，不擅自改变全局环境或反复发环境微任务。

核心验收目标：(1) 审查实际系统v14与官方PHP8.5.12-1 NTS x64的受控运行条件；(2) 新任务内取得/验证可信Composer PHAR与Laravel12依赖，**真正生成**新Composer锁文件与vendor；(3) 在来源和闭包全部成立后真实PHP无DB能力Probe、Laravel12 Feature以及独立合成MariaDB/API/HTTP测试。不得将依赖文件下载、合成132/132、原Flutter11/11冒称新框架业务通过。Laravel13只是未来评估，真实目标固定Laravel12、PHP8.5.12。

## 1. 固定Git Authority（开工仍须fresh回读）

**唯一研发Parent**：`f16d4cda817282d935cb53ce399d26a7850381a1`；Root `eb4045b343749b7f3fceb46121100fa946b92329`；apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`；services Tree `120177c9f35905190972be7bbcb3dfdda95ba776`。Parent sole Parent=`e93ef51401f4e25916149cca104f09debc32bc78`。

最新Astra独立审查：`astra/v10.1.5-f16d4cda-private-supply-independent-review-20261030:docs/versions/v10.1.5/F16D4CDA_L12_PHP85_TRUSTED_SUPPLY_ASTRA_INDEPENDENT_REVIEW_20261030.md`，审查Commit `0aec79a8a336708ddfdefc3217e28e33a0c877df`、Blob `34e2f0d6a80109188cc32fa85b34d0a2574c70c1`。原任务Blob `5f1c709e31af0d4f2c1c93363c147942db7116c5`、原交付报告Blob `917baca1de522e0e8c1fa57e5c67232c974f7922`、Manifest Blob `7fec479f5b902da6b69fd3d3ba4b41164fc9c25c`不修改；Astra审查分支不能作为研发Parent。

签发前live main `06af7fb2e7a7db2953cefeefcfb819eb81d02ac2`、Root `7bb00f0130255cb355ff602e9dad8290baa4342b`；已接受产品仅v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。Codex开工须重新读取live main、Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文与Blob、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`、`docs/versions/v10.1.5/plan.md`及冻结AC/15场景。任务发布推进main文档HEAD不意味着产品candidate已集成。

官方PHP8.5.12-1 ZIP在前轮本地核对：SHA256 `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`，`php.exe` SHA256 `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`，存放在前轮LOCAL_ONLY，不是允许改旧根；微软官方x64 VC原包14.51.36247.0下载Hash `843068991daaa1f73ad9f6239bce4d0f6a07a51f18c37ea2a867e9beca71295c`，离线签名成功但**没有**DLL拆出或新PHP实际加载。旧`composer.lock`仍是Laravel11.48.0 Blob `66327f584d3961c2b53391bb012047dda9cc9d23`。前轮锁、PHP/VC license/native和API/DB均未获得动态资格；旧任务和账本已经STOP，不能退款复用。

## 2. S1｜真实已安装v14系统运行库只读资格，避免app-local许可循环

- 新单一task-owned工作根中，**仅对具名`vcruntime140.dll`及实际PE依赖证明所需的同系列模块**，定点只读核已安装的central v14运行库。可信系统目录从Windows API而非硬编码PATH取得；验证System32直接路径与真实文件句柄规范路径、FileId/Volume、SHA256、version、Microsoft数字签名与发布者、Win32/AMD64、加载进程已固定身份、模块本身可用的exports和PE普通/delay-import；若有现成安装登记，可只读辅助交叉核验，不执行安装。已存在System32里`vcruntime140.dll`不自动算合格；非系统、同名私有、硬链接/别名/签名不明一律STOP。最多**2次具名本机只读系统模块观察**，仅当前控制进程或本任务获准子进程，**不得扫描全部System32或任意进程**。
- 这是central installed runtime的**只读使用证据**，不是已授权app-local部署。更新非生产`os_images.py`、`php_native.py`、`php_runtime.py`等必要资格源时，将`MICROSOFT_CENTRAL_V14_RUNTIME`与原`WINDOWS_SYSTEM_IMAGE`及严格`TASK_PRIVATE_BINARY`分开。Microsoft v14系统运行库的准入须有具名完整pin/签名/版本/散列/直接系统父目录/OS加载映像对应证明，且加载范围仅列必要DLL；不得把`vcruntime140`加入泛化`os_import`绕开验证，不允许从系统目录复制到private目录，也不得扩大普通System32只读例外为私有硬链接放行。缺证据则`CENTRAL_VC_NOT_QUALIFIED`。
- 官方Microsoft说明：最新v14可供VS2017–2026 MSVC v14应用使用，安装版本应不少于目标构建工具版本。PHP官方发布“VS17”与PE linker 14.44提供线索，**不是精确编译器工具集版本证明**。对运行库是否满足下限采用来源、版本、导出和真正受控PHP动态加载分级判定，不将链接器字段或签名本身标为全量ABI证明。仅Windows OS与官方PHP版本条件均通过才允许动态验证。
- **不得运行`vc_redist.x64.exe`、调用MSI安装/repair、提权、改系统ACL/注册表/PATH/php.ini/System32/WinSxS/服务配置**，也不从旧官方安装包提取vcruntime.dll做app-local。若已安装central runtime不合格，终态一次列清安装所需版本、官方来源Hash、回退/恢复方法及额外Owner确认问题；即便旧包已取得也不能擅自系统安装。

## 3. S2｜合格供应源、Composer真实求解与vendor

- 在资格成立的**新私有运行面**内，从前轮已经取得的官方PHP8.5.12-1 ZIP和经过SHA256核对的已具名来源**只读复制/安全解压**到本任务根；只使用符合当前Owner操作范围的文件，旧源副本不可改。对PHP/extension/VC中央runtime以及必要Composer PHAR分别记录SHA256、架构、来源/签名、PE导入图、加载目录和所需权限；不沿用旧PHP8.5.3或第三方14.38的可执行资格。
- 供应启动器必须有单独`SUPPLY_ONLY_COMPOSER`允许动作：**不要求Laravel12锁文件先存在**，但要求合法PHP exe、已安装合格central v14及Native加载、受信Composer PHAR来源、task-root/窗口/ledger/网络身份。只准执行Composer元数据解析及私有vendor安装，禁止`scripts`、`plugins`、`artisan`、业务Laravel/bootstrap、数据库和公网API。现有`supply_preconditions.py`只有纯输入合同，实际安全启动器/child/网络守卫须在本长任务实现并按授权回执核验，**不可把合成true/Hash字符串当防伪许可**。
- 允许一次具名Composer PHAR可信官方取得≤**8MiB**，优先精确官方`getcomposer.org`且验证发布Hash/签名或官方核验机制，若已有合法同版文件可只读复用；不自动安装至系统、不改全局Composer home。Laravel12依赖仅`repo.packagist.org`与其锁定包预登记的可信官方dist源，重定向逐次验证真实host与包出处，禁止不受信Git hooks。包/元数据真实响应体总≤**256MiB**、最多**240 HTTP请求**（含metadata/redirect/失败）、**Composer求解最多2次、vendor安装最多1次**；每次预记ledger，必要执行PHP/PHAR子进程计入下述CLI预算。若出现未授权外部host、自动脚本、无限依赖、包签名/源码身份缺口、超过预算，STOP相应供应项，不放松白名单。
- Composer真实生成Laravel12 `composer.lock`（`^12.0`，PHP`~8.5.12`），完整核所有传递依赖、Sanctum、Carbon、Workerman、lunar-php、dev工具；禁止手工改lock/content-hash或拿旧vendor冒充。真正求解后更新`php_requirements.json`中的`source_documents` lock SHA、`composer_evidence`真实包版本、vendor源身份、private PHP/VC/OS Manifest与CLI/API源码绑定，不得只把PENDING字符串改为RESOLVED。普通Laravel12源码兼容失败在本任务有界修复，必须保留CN/MC/Block/Token、F1消息不可变重试、F3 T0/离线安全、F4通知私密、真实私有媒体权限与原负例。

## 4. S3｜资格成立后的PHP/Laravel/MariaDB/API真实合成回归

必须先证明合法来源、PHP及native本机已加载版本/OS映像可核、Composer12真实lock/vendor、进程与磁盘/隔离授权及Ledger资格，才准在本任务内启动：
- **DB-free PHP Probe ≤2次、每次≤30秒**，真实核`PHP_VERSION`、NTS/ABI、mbstring/openssl/curl/fileinfo/PDO+pdo_mysql、函数与类、PID/nonce/module/Manifest；无DB Probe不要求`new_instance_qualified`和Laravel12 Feature已运行，但不加载业务vendor、DB或HTTP。成功只标`PHP_DB_FREE_CAPABILITIES_OBSERVED`，不直接签Laravel通过。
- **Laravel12 Feature/Unit最多3批**，全部来自新vendor、测试入口绑定新源码：新Laravel12三项兼容回归、消息同键/错误payload和授权撤销、F3刷新T0、F4通知最小披露等。要执行真实PHP Feature前先验证有效database selector、test环境和任何SQLite `:memory:`隔离；若任何旧库/外部库会被触碰立即STOP。
- 仅确认已合法具名的MariaDB10.11.19私有二进制可用，才允许独立新回环数据库实例`127.0.0.1:43349`、新空库`elitesync_v1015_mainline_e2e_20261029`、`v1015_e2e@127.0.0.1`、专属datadir/server_id。MariaDB启动≤2次、Laravel PHP API启动≤2次，PHP全部CLI含探针、Composer、Feature、迁移/fixture≤**60进程启动**，真实HTTP≤160次，迁移1次/合成seed事务1次，使用10虚构账号、5组独立关系。每次启动/HTTP/DB操作前都核`APP_DB_CONNECTION`、URL/host/socket、GRANT、端口/PID/进程绑定、actor/数据库和datadir，端口被占、非空/旧/生产数据库一律STOP；**禁止重置、删除、连接历史MariaDB或生产**。
- 在固定15个场景中优先真实HTTP→Laravel12→MariaDB验证F1消息回放/异内容冲突、MC/CN/Block/禁用撤销、登录T0与refresh、附件私有读取、通知最小披露和重启后持久读取，留真实状态码、DB行数、exit和负例。没有合规H264视频则只标该分项NOT_RUN。即便API/DB各项通过，依然**不是APP→API→DB真实UI E2E**，不可关闭RTC/AEC、Push、物理15/30天。
- 本轮**完全不授权Flutter/Dart/Widget/analyze、G2/Gradle/JVM/APK/ADB/AVD/真机、RTC/Push、系统安装、外网公开服务或真实用户数据**。

## 5. 一次性总体预算、保护与终态

本任务仅创建**一个新task-owned私有根**，task_id=`V1015_CENTRAL_VC_L12_COMPOSER_API_DB_20261030`，attempt-0001，单一持久ledger；logical/native allocated各≤**8GiB**，自本轮新根建立起单调窗口≤**120分钟**，不可跨会话重置时间、路径或额度。首次所有成本动作（含每次已下载源文件复制、Composer、PHP/DB/API/HTTP、OS只读观察）均写前PREPARE+fsync、失败也扣次数。下载包括Composer PHAR最多8MiB及Composer包256MiB；**本任务没有PHP ZIP或VC安装包重复下载许可**（前轮已获具名资产），所有新增外网响应体合计≤264MiB。静态/纯测试允许同预算内有界批次并保留真实exit/失败，不能把旧132/132或Flutter11/11重报为新运行。
 
历史旧18、两ACL树、122原证、五根、527refs、3183 Seed、所有旧SQL/APK/失败/claims/ledger/dirty不写不删；旧Flutter6/6与3bed3/3、MariaDB2/2、G/APK各1/1、前轮系统观察2/2、历史ACL超限均不退款。保留`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`；LOCAL_ONLY绝对路径、证书、凭据、原始日志/DB/二进制不能上传GitHub。

只提交一个在固定**sole Parent `f16d4cda817282d935cb53ce399d26a7850381a1`**上的非force研发候选，必要修改只在`services/backend-laravel/`、`tools/v1015/mainline_e2e/`及本轮结果/Manifest；报告路径建议：
`docs/versions/v10.1.5/CENTRAL_VC_L12_COMPOSER_API_DB_RUNTIME_RESULT_20261030.md`
与
`docs/versions/v10.1.5/central_vc_l12_composer_api_db_runtime_manifest_20261030.json`。
逐项分类`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN_GATE_CLOSED / NOT_PROVEN`，清楚写出既有central VC是否存在、版本/签名/OS加载与PHP最小工具链证据、合法Composer lock/vendor、PHP Probe与API/DB真实结果、所有次数/保护及未闭门禁。若缺合格已安装runtime，终态`CENTRAL_VC_NOT_AVAILABLE_OR_NOT_QUALIFIED / INSTALL_AUTHORIZATION_REQUIRED / PHP_COMPOSER_DB_NOT_RUN`；若已完成部分结果但后续失败，交`PARTIAL_WITH_EXPLICIT_GATES`；最高可标`LARAVEL12_LOCK_AND_SYNTHETIC_API_DB_EVIDENCE_DELIVERED_AWAITING_ASTRA_REVIEW`。

最终fresh GitHub回读Commit、sole Parent、Root、所有变更path/mode/Blob、完整apps/services Tree及main产品仍v10.1.4，**STOP等Astra独立验收**；不合产品main、不签整版`FUNCTION_ACCEPTED`、不关闭AC05、不放行G2、不启动v10.1.6。仅Owner手动派发Codex才开始执行；本GitHub任务发布不等于在本地启动。

## 6. 官方依据（只读核对）

- https://www.php.net/downloads.php?os=windows&version=8.5
- https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist/
- https://learn.microsoft.com/en-us/cpp/windows/choosing-a-deployment-method
- https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files
- https://laravel.com/docs/12.x/upgrade
- https://laravel.com/docs/12.x/deployment
