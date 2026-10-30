# EliteSync v10.1.5｜Laravel12/PHP8.5可信依赖供给、真实Composer锁及受控API—MariaDB验证｜Owner正式综合任务

**状态：OWNER_APPROVED / FORMAL_TASK_PUBLISHED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / PRIVATE_SUPPLY_AND_CONDITIONAL_TEST_ONLY / NO_GLOBAL_INSTALL / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-30（Asia/Singapore），权威仓库：`zcx369658780/EliteSync-v10`。

## 0. 本任务的Owner决定和可观察目标

Owner选择方案B，已批准集中完成：官方PHP 8.5维护版本、合法的Microsoft VC运行依赖与Laravel12 Composer包的来源核验与受控私有取得，真实生成Laravel12锁文件；在新依赖与运行资格均满足后，执行无DB PHP Probe、Laravel12 Feature及独立MariaDB/API合成业务回归。**本文件是一次综合授权，允许范围内普通代码与测试问题集中修复；供应链或安全资格失败则STOP对应风险阶段，不为了取得PASS修改或规避保护门。**

固定版本目标：Laravel `^12.0` + PHP `~8.5.12`，首选官方Windows VS17 x64 NTS `8.5.12-1`发行包。Laravel13仅评估、不实施。最高证据层级仅为可信依赖、真实lock及`SYNTHETIC_LARAVEL12_API_DB_RUNTIME_OBSERVED`，不得等同APP→API→DB真实设备贯通、RTC、Push、物理15/30天或整版功能接受。

## 1. 唯一authority与不可变身份

Codex开工先fresh核live main/Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文/Blob、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md`、冻结`docs/versions/v10.1.5/plan.md`，以及原15场景、AC矩阵。

**唯一研发Parent：`e93ef51401f4e25916149cca104f09debc32bc78`**，Root `5941573199ea340a11691ce45cf3ed96282ab5a1`，apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services Tree `91611699217d6e9fae7b2ebe03e6023c90e23bbc`。Parent为`be7ebd1faa0fd3cb45bd88bd24af15ea9e805631`；不可改用Astra审查分支或产品main。

Astra上一轮独立审查：`astra/v10.1.5-e93ef514-laravel12-php85-independent-review-20261030:docs/versions/v10.1.5/E93EF514_OWNER_B_LARAVEL12_PHP85_ASTRA_INDEPENDENT_REVIEW_20261030.md`；审查Commit `1c91ad4f20aeded44ebe5433b734d0271ab6b9b3`，Blob `158659dc0b0f6b08caeb49dc7978cc298afd23ea`。此前任务Blob `1ade4e5a89116eeba329311ed274229823aafd17`；`composer.json`已声明Laravel12/PHP8.5/cURL，但现存`composer.lock` Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍是Laravel11.48.0，标记`LOCK_RESOLUTION_PENDING`。不得冒称已安装Laravel12。

发布前main `be2204a7513145af2e764e6a36e63950aa3739b2`、Root `593fa732e1048df479fadb068e66d455f579f992`；main唯一接受产品v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。后续文档commit会改变main HEAD，必须fresh读取，不得因此把v10.1.5合入main。

## 2. A：官方依赖来源与私有供给

在唯一新task-owned根内进行有限、逐来源核验的下载和私有解包；绝不更改全局安装、PATH、php.ini、System32、WinSxS、注册表、安全策略或旧受保护资产。每个网络请求与文件写入预记持久ledger，记录来源、真实字节、Hash、失败、重定向与回执。遇到证书/来源/签名/版本不符STOP，不能根据猜测更换URL或Hash。

1. **PHP官方发行包**：`php-8.5.12-1-nts-Win32-vs17-x64.zip`最多1次，≤64MiB；官方release/SPDX/CDX校验资料额外≤3次小请求。仅使用php.net官方认可的下载端点。历史报告ZIP SHA256 `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`须同官方当次发布记录及所获文件重新核验，变化即STOP。ZIP SHA与`php.exe` SHA不同；私有解包须逐成员校验路径、文件Hash、PE架构、扩展与实际原生依赖，不执行归档内脚本。
2. **Laravel12 Composer依赖**：仅允许Packagist与其登记的可信包源码/发行端点，精确冻结包身份及每个重定向host；最多256MiB包/元数据、240次HTTP请求（包含失败/重定向）、Composer求解最多2次、仅1次任务私有vendor安装。必须关闭Composer scripts/plugins，严禁触发artisan/迁移或共享Composer cache、PHP安装根写入；如果合法官方包或所需依赖缺失，保留`LOCK_RESOLUTION_PENDING`。真正`composer.lock`必须由Composer求解器生成，禁止手动更改锁文件、content-hash或虚构Laravel版本。
3. **Microsoft VC v14 x64**：只允许从微软官方最新Visual C++ Redistributable网页指向的官方发行来源最多取得1个原始包（≤64MiB）。下载前后核对应版本、架构、发布者签名与合法许可、实际PHP目标MSVC工具链最低版本。**取得官方安装包不等于授权执行安装或擅自拆出单DLL**；仅在可证明允许的许可和app-local部署权、符合版本及文件来源链时，才准在本任务私有根放置具名未修改DLL并留Hash。未经证明则`REDISTRIBUTABLE_NOT_QUALIFIED`，禁止系统安装、System32写入及用第三方14.38 DLL替代。

外网下载总字节≤384MiB，所有网络使用只限上述经证实官方host及其逐跳受控分发源；不向外发账户、凭据、项目私有数据或原始日志。禁止自动安装、升级、费用及额外主机访问。新二进制/vendor文件`LOCAL_ONLY`，不推送GitHub。

## 3. B：Laravel12锁定、源码/原生依赖同源绑定

- 根据固定Parent的Laravel`^12.0`、PHP`~8.5.12`，真正求解版本约束并生成一致lock；验证Sanctum、Tinker、Pail、Collision、Carbon3、Workerman、lunar-php、PHPUnit与扩展兼容。真正求解成功才能更新`composer.lock`。失败时仍可完成合法、独立的源检查，不得伪造。
- 在新lock生成后同步重建`tools/v1015/mainline_e2e/php_requirements.json`中`source_documents`的真实lock/composer SHA、`composer_evidence`的真实锁包、vendor源身份、PHP executable/extension/DLL Manifest、CLI/API source-binding；归档Hash和exe Hash分别记录。现有旧11.48包证据不能作为已解析新lock。
- 供应阶段需要Composer PHAR及PHP：可在本任务明确的**SUPPLY_ONLY_COMPOSER**有限模式下使用经来源及Hash资格的独立PHP/Composer CLI完成求解和私有安装，而非先要求Laravel12 lock已存在。该模式不得加载Laravel业务/vendor插件及scripts、访问业务API/数据库。尚缺合规原生运行库时，PHP供应执行也必须STOP，不能通过绕过native守卫制造锁文件。
- 无DB PHP Probe不要求MariaDB已启动或实例资格，但必须有合法PHP/VC闭包和独立授权；真正Laravel/seed/API则要求真实lock、vendor及严格DB实例身份资格。保留`php -n`、CLI/API一致Manifest、Windows系统映像只读与私有硬链接严格隔离、PID/nonce/Hash、未授权运行fail-closed。
- 仅在真正有证据的兼容失败时对Laravel12相关源、依赖及测试做有界修复。F1不可变消息重试、CN/MC/Block、账号和旧JWT撤销、F3可信T0/离线密文、F4通知隐私、私有附件现行边界及负例不能弱化。

## 4. C：独立、条件式真实软件回归

仅当合法依赖/许可证、完整PHP+VC native闭包、真实Laravel12 lock/vendor、私有写/子进程资格、受控实例与新预算均合格后，才可启动：

- **无DB PHP能力Probe**≤2次，每次≤30秒，真实核PHP版本、cURL、mbstring、fileinfo、openssl、PDO/mysql、函数类、native映像/PID/nonce；不得连接Laravel/数据库/HTTP。
- **Laravel12 Feature/Unit**≤3批，复核新Laravel12兼容用例、消息幂等/撤权、登录refresh/T0、私有存储及通知；只有具名隔离testing DB/SQLite :memory:且有效配置证明成立才能执行，绝不误连真实旧库。
- **MariaDB 10.11.19**仅具名合格已有私有服务来源，最多启动2次，127.0.0.1:43349，新空库`elitesync_v1015_mainline_e2e_20261029`、最小权限账号`v1015_e2e@127.0.0.1`和本任务独立datadir/server_id。PHP回环API最多2次启动，监听127.0.0.1:43359，Laravel实际业务HTTP≤160次；全部PHP CLI探针/Feature/fixture/迁移合计≤60次，合成迁移≤1次、seed事务≤1次，10个虚构普通账号/5组独立关系。错误、超时和重启均耗次。
- 每个DB动作事前校验有效`APP_DB_CONNECTION`优先、`DB_CONNECTION`、URL/socket/read-write、actor/port/datadir/server_id/GRANT/空库身份；非本任务对象或旧/生产库立即停止，不删除或迁移旧库。
- 原15场景重点验证真实Laravel12 API→DB消息同键回放与异内容409、CN/MC/Block撤权、T0/refresh、私有媒体与通知最小披露及重新读取。记录真正的HTTP状态/DB唯一性/退出；未获合法短视频H264源则该项NOT_RUN，不伪造206。真实APP UI、物理网络、Keystore、RTC、Push、15/30天设备清理依旧未运行。若API/DB有界通过，可记`SYNTHETIC_API_DB_PASS`但绝不能签`SAME_SOURCE_APP_API_DB_E2E_PASS`。

**不授权**Flutter/Dart/Widget/analyze、G2/Gradle/JVM/APK/ADB/AVD/真机、RTC/AEC/真实Push/公网API、生产与真实用户数据。历史Flutter6/6和3bed3/3、MariaDB2/2、G/APK1/1等已耗预算不继承或退款。

## 5. 总预算、保护、交付和STOP

本任务仅1个新私有工作根、task_id `V1015_L12_PHP85_SUPPLY_AND_API_DB_20261030`、attempt-0001及唯一持久执行ledger；新根logical与native allocated分别≤8GiB（8589934592 bytes），单调运行窗口≤120分钟（自首次创建根/ledger起）；跨会话不能重建任务根或刷新用量，所有有代价动作写前PREPARE+fsync，失败与取消消耗预算。新依赖包数量/空间/请求次数不够，立即保留失败并提交集中缺口，不私下扩额。
 
不可修改受保护旧18、两ACL实验树、122原证、五根、527 refs、3183 Seed、所有历史失败/SD/ledger/claims/dirty，保留`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。旧软件、SDK、Redist/Composer安装及原数据不得清理替换。原始路径、私有凭据、PHP/VC二进制、vendor/库、DB dump与原始执行数据只留`LOCAL_ONLY`，不能上传公开GitHub。

唯一交付：在普通非force候选分支，以**sole Parent `e93ef51401f4e25916149cca104f09debc32bc78`**提交真正必要的后端源码、真实新Composer lock（若有）、修正资格工具、脱敏实施报告
`docs/versions/v10.1.5/L12_PHP85_TRUSTED_SUPPLY_AND_CONTROLLED_API_DB_RESULT_20261030.md`
与
`docs/versions/v10.1.5/l12_php85_trusted_supply_and_api_db_manifest_20261030.json`。
记录真实来源、签名/许可/版本/Hash、解析及每次Probe/Feature/HTTP/DB执行结果/账本、未合格/未运行项与保护状态，不把仅下载或静态PASS当成完整运行资格。

最终fresh GitHub回读Commit、sole Parent、Root、逐变更path/mode/Blob和完整apps/services Tree，确认main仍只接受v10.1.4；交付后**STOP等待Astra独立验收**。未满足来源/锁/实例门的结果必须写`PARTIAL_WITH_EXPLICIT_DEPENDENCY_OR_RUNTIME_GATES`，不签整版`FUNCTION_ACCEPTED`、不合main、不关闭AC05、不放行G2、不开始v10.1.6。

官方只读来源： https://www.php.net/downloads.php?os=windows&version=8.5；https://laravel.com/docs/12.x/upgrade；https://laravel.com/docs/12.x/deployment；https://repo.packagist.org/；https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist；https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files 。

**正式任务在GitHub发布后仍需Owner手动派发；发布本身不授权Astra自动启动Codex或任何本地执行。**
