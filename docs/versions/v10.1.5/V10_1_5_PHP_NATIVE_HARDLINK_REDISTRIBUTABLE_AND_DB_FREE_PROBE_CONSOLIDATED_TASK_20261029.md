# EliteSync v10.1.5｜PHP原生映像Hardlink／微软运行库来源／无DB探针三项合并解除阻断｜Owner正式任务

**状态：OWNER_APPROVED_THREE_ISSUE_CONSOLIDATED_UNBLOCK / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NAMED_READONLY_OS_DIAGNOSTICS_AND_CONDITIONAL_DB_FREE_PHP_PROBE / NO_LARAVEL_MARIADB_API_E2E_FLUTTER_G2_APK_DEVICE_RUNTIME / NO_PRODUCT_MAIN_INTEGRATION**

签发：2026-10-29（Asia/Singapore）。Authority：`zcx369658780/EliteSync-v10`。

## 0. Owner最新决定与目标

上一集中受控运行任务中，Codex按合同因本地Windows原生映像观察器遇到`HARDLINK_REJECTED`而STOP阶段A，未启动PHP/API/DB；阶段C使用本任务私有patched Runner真实执行11/11 Widget，Flutter新3/3已耗尽、analyze未运行。Astra在固定GitHub证据上有界接受该Widget结果和安全STOP，不将观察器拒绝伪称PHP自身出错。

Owner现明确同意**同一份集中任务**解决Astra建议的三个相互关联的问题：

1. **准确定位Hardlink拒绝源并有界修正系统映像只读观察语义**。必须取得真实被拒路径及FileId/Volume/链接数/来源分类的本地原证，区分Windows受信系统模块（可能被NTFS/WinSxS硬链接管理）与私有可写二进制；仅对严格具名、已独立确认的系统映像只读观察建立专用资格规则，不许全局关闭hardlink拒绝。
2. **厘清现有Microsoft签名的运行库候选究竟能否合法用于本项目的app-private PHP闭包**。验证确切文件名/版本/架构/Hash/签名、原始软件授权、许可及适用的REDIST条目、上游发行包身份/组件版本、PHP 8.5.3 NTS x64 ABI与PE import依赖；Microsoft签名只证明签名事实，**不证明单独再分发许可或兼容性**。优先具名、已有、允许读取的合法来源；无证据即标记NOT_QUALIFIED并提供精确下一决策要求，不拷贝运行库凑PASS。
3. **把不连接数据库的PHP能力探针与真正的MariaDB/Laravel E2E实例资格解耦**。在相同源Hash、`-n`、扩展来源、manifest、native PID/nonce/镜像收据和新Owner授权下，Probe的资格不应被`new_instance_qualified`、schema/datadir、DB用户名/口令、空库迁移和seed过早阻断；真正DB/API/seed入口反而必须**保留并继续强制全部原实例资格**。禁止借此减弱常规Laravel/生产业务鉴权。

本轮是一次产品开发受阻的有界恢复，不是重建Hook、DLL权限、ACL历史审计、批量系统扫描或另一轮微任务。源修复、纯测试、授权的当前控制进程只读观察及**条件成立时最多一次真实PHP无DB能力Probe**在同一任务内连续完成；不要求每个普通代码改动都另问Owner。

## 1. 固定Authority、源码与历史接受

执行前fresh读取live `main`/Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文及Git Blob、`docs/workflow/CURRENT_WORKFLOW.md`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结 `docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。

**唯一研发Parent：** `3bed366233a39472f8a9e905021788b8d29e12b3`；Root `ce901ec23e06e29552677afe34abe257012cdf89`；apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`；services `eb47fe58d1167b1795224d4c748fb046042b9c92`。该Parent sole Parent为`ad25903e05ab5c0a4d88fe96c41df7963b565c1c`。**不要**以main、ad259、Astra审查分支或旧dirty树代替研发Parent。

必读Astra最新独立验收：分支`astra/v10.1.5-3bed3662-controlled-runtime-independent-review-20261029`的`docs/versions/v10.1.5/3BED3662_CONTROLLED_RUNTIME_ASTRA_INDEPENDENT_REVIEW_20261029.md`，审查Commit `7e11cabb7a9be8374ee8f5d5aeece80153057c13`、Blob `940d82b4367b75f81f5fd0555775a14e881b1b49`。前轮运行报告Blob `e6477d07fe98de86d8a07a6555801c0abf180c6f`、证据JSON Blob `5b1338d0abc4f1a902372b6d49622abd973d16c4`、Manifest Blob `726c3ff999f16ff05602278d6a8922a9729fcbf7`。原下一步授权建议在原报告与LOCAL_ONLY原文，本任务不要求上传私有绝对路径、硬件身份、DLL图或凭据。

此前`ad259`版本的PHP要求`php_requirements.json`、`php_runtime.py`、`php_native.py`、`contracts.local`、`php_runtime_probe.php`、`MainlineEnvironment.php`、`PhpRuntimeQualification.php`是真正受影响路径，冻结已接受v10.1.5 F1消息不可变重试及3bed Flutter finder修正。

main唯一正式接受产品仍v10.1.4，apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；v10.1.5仍**10 PARTIAL/1 OPEN（AC05 RTC）**，不可合产品main。

## 2. 第一工作包：追踪实际Hardlink及窄范围安全修复

- 在本轮单独小型task-owned受控根内，先用**最多2次有界只读观察**定位**当前Codex控制进程自己的PID**中观察器发生Hardlink拒绝的精确目标；只读观察系统API返回的具名已加载模块，不启动PHP、不扫描系统目录树、不追查历史ACL。输出LOCAL_ONLY原证包括具体失败路径、原始路径/规范路径、Volume+FileId、link count、module basename、SHA256、签名验证结果、系统目录身份以及调用栈/拒绝类型。公开回执只给脱敏类别、Hash和拒绝位置；不知道路径就必须标`PATH_NOT_PROVEN`，不能拿另外一个links=2的已知OS模块冒充真正触发对象。
- 仅在独立证据支持时，设计并落实 **`task_owned_private_path`（严格无reparse/symlink/hardlink）与`qualified_readonly_os_image`（已知Windows System32根、只读打开、具名系统API规范路径、固定Hash/签名/文件身份、限定模块来源、不得写入）两种分离规则**；不得把OS例外植入所有`contracts.local`调用、`php_runtime.validate_manifest`私有文件、PHP文件资格或写面，不允许OS文件混入私有扩展闭包。其他目录、系统API未明确认可的别名、WinSxS路径绕道、私有DLL link count>1仍拒绝。
- 针对同一个异常路径返回可审的`HARDLINK_REJECTED_PRIVATE`、`OS_IMAGE_SOURCE_NOT_QUALIFIED`等分类，不泄漏私有绝对路径到GitHub。Windows确认需实际系统身份和允许目录层级，不能单凭“basename像kernel32”放行。检查TOCTOU与源重读/静态Hash差异，若无法在本任务只读范围内证明，STOP，不改全局权限或系统文件。
- 增加纯合成负例：private DLL hardlink、OS路径伪装、OS文件签名无效或Hash不符、系统根错误、非预期loaded module、link异常、symlink/reparse逃逸、跨卷路径和未知进程，确保所有旧拒绝边界仍fail-closed；允许的仅受信具名OS映像只读例外且不应用于写入。

## 3. 第二工作包：Microsoft运行库许可、来源与ABI

- 仅定位**前轮已具名LOCAL_ONLY候选**及相关既有许可/发行证据，不穷举系统DLL/搜索其它项目敏感工作区。读取文件Hash、签名链验证状态、ProductVersion/FileVersion、Machine/PE imports/exports及要求的CRT族/架构；不得上传DLL或原始本地路径。**签名验证成功不是合法再分发的充分条件**。
- 对照官方Microsoft文档（“Redistribute Visual C++ files” https://learn.microsoft.com/cpp/windows/redistributing-visual-cpp-files；官方适用版本`REDIST`目录和许可条款；必要时 https://learn.microsoft.com/visualstudio/releases/2026/redistribution）。必须确认候选源的确切发行主体及是否在对应许可允许清单，并核实Owner实际持有相应许可/使用权；不是所有被Microsoft签名或由第三方工具附带的文件都自动可复制给本项目。
- 优先只读核合法现有来源。**允许的写入只限**：在许可、文件身份、版本/架构/PE依赖和Owner现有授权同时可核的前提下，将许可准许的、**未修改的具名文件**至**本轮全新私有task-owned PHP目录**作**最多1次受控副本**，记录源/目的的SHA256、FileId/Volume与保护收据，绝不修改原文件、权限或系统目录；如果任何条件不明，**不复制**，给出无敏感路径的具体缺失证明与下一步Owner决策。此授权不覆盖通过非正式第三方工具附带运行库进行不受许可的二次部署，也不授权安装或下载官方Redist。
- 运行版本固定`PHP8.5.3 NTS x64`及已核运行方向；清单中的DLL依赖闭包、Win x64兼容与ABI必须独立核对，不能因同为AMD64或签名有效即得出`PHP_RUNTIME_COMPATIBLE`。来源合法、静态兼容与实际加载三层分别记事实。

## 4. 第三工作包：无DB Probe与DB/E2E资格解耦

- 现`php_runtime_probe.php`实际调用`MainlineEnvironment::assertContext($ctx)`，该方法会核`new_instance_qualified`及datadir/数据库身份；若独立阶段A先于阶段B，应拆成严格复用的**source+runtime+task grant资格**与**DB/实例身份资格**。无DB Probe只需自己的明确动作许可`php_native_no_db_probe`及正确新任务Blob/有效期、候选/工具/manifest/权限/私有根与PID/nonce/OS原生回执，禁止回退到旧已关闭task。DB API/seed必须照旧要求`mainline_api_db_e2e`、`new_instance_qualified=true`、预先验证MariaDB10.11.19 43349/datadir/actor/schema和源绑定；不得借probe授权调用DB或伪造实例资格。
- Probe路径不得读取或连接MariaDB、Laravel/vendor/bootstrap、HTTP/网络、真实用户数据；成功不证明Laravel/DB能运行。保持`php -n`和共享CLI/API的冻结扩展Manifest/Hash、不引入生产路由或对`public/index.php`打补丁。要用相同的native观察器握手和有限进程子闭包，不以纯Mock/PHP lint当动态模块已加载。
- 必须新增独立纯测试正反例：`DB_NOT_QUALIFIED`时具名无DB动作可通过**静态**资格，错grant/旧task/过期/错源/错nonce/错依赖则STOP；对所有DB API/seed入口，即使持有无DB grant，也因`new_instance_qualified=false`被拒绝；禁止将测试模拟注入真实PHP业务授权。修复未启动的探针接线问题**不能**绕过任何现有已接受的CN/MC/Block/Token规则。

## 5. 本轮一次性预算与真实执行硬门

仅新增**一个任务私有有界工作面**（不是旧3bed的工作根），`task_id=V1015_NATIVE_UNBLOCK_THREE_ISSUES_20261029`、`attempt-0001`，logical与native allocated分别≤**1GiB=1073741824 bytes**，单一持续ledger写前PREPARE+fsync，禁止中途重建root/ledger“退款”；任务整体真实执行窗口≤**45分钟**。只读OS PID观察最多**2次**（每次失败也扣次数），只对本次控制进程，不能改成受保护旧进程、restricted身份或任意PID。PHP探针进程最多**1次、≤30秒**，**必须先满足**合法具名运行库/完整PHP私有闭包、修复的OS只读观察安全核、源/环境/Hash/授权/窗口/任务根条件；若来源不合格或者OS观察仍不确定，则0次真实PHP，最终`PHP_NATIVE_GATE_CLOSED / PHP_PROBE_NOT_RUN`。Microsoft运行库合规受控私有副本最多1次、仍按第3节全部条件许可。许可查询、GitHub只读、纯Python逻辑/AST及PHP`-l`（使用既有合格纯CLI且无扩展/vendor/DB）允许在本范围有界执行并真实记账；不重跑 Flutter Widget/analyze、旧历史feature或PHP扩展加载。失败收据不可清理；不会运行后补报“失败不计费”。
 
**本任务不授权**：新MariaDB服务、迁移、seed、PHP Laravel/API回环服务、HTTP E2E操作、Flutter/Dart/Widget/analyze（前轮3/3）、Gradle/G2/JVM/APK、ADB/AVD/真机、RTC/AEC/真实WS/Push、物理15/30天、Keystore；任何系统/全局ACL、组策略、System32、WinSxS、PATH、php.ini、注册表、安全策略写入；安装/更新/下载新SDK或Redist；公网/云/生产/真实用户数据；恶意代码/防护绕过。旧Flutter6/6、MariaDB2/2、G/APK各1/1及3bed的3/3不得退款；3bed中A/B未用预算不延续到本任务。

旧18、两ACL实验树、122原证、五根、527 refs、3183 Seed、全部历史失败/SD/claims/ledger/dirty根继续冻结；`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`及`OS_ENFORCEMENT_NOT_PROVEN`不变。只读任何受保护历史材料也只在授权和具名确有必要时，禁止借本任务重扫旧事故。LOCAL_ONLY原始PID/路径、DLL完整清单、签名证据、凭据、file IDs等不可上传GitHub。

## 6. 单一集中交付与成功/阻断出口

以**sole Parent精确为`3bed366233a39472f8a9e905021788b8d29e12b3`**发布一个非force候选，尽量只改`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`及新报告/Manifest，不改apps生产代码、旧Widget、生产Laravel授权、现网路由、数据库迁移或原任务计划。原纯测试负向断言不得删除/削弱。建议报告：
`docs/versions/v10.1.5/PHP_NATIVE_THREE_ISSUE_UNBLOCK_RESULT_20261029.md`
与配套
`docs/versions/v10.1.5/php_native_three_issue_unblock_manifest_20261029.json`。

逐问题报告：实际Hardlink拒绝位置及“系统读例外/私有严格禁止”源到测试证据，Microsoft候选法律来源/静态兼容分类和单次私有副本是否获准/实际操作，Probe从DB解耦的源码反例/是否真正PHP单次探针/进程exit、module/nonce/OS映像回执及DB零操作证明。归档`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN_GATE_CLOSED / NOT_PROVEN`；一律以真实run/exit与raw SHA为准，不以“通过纯合成”伪装真实模块加载；保留失败、受控预算、源文件/工具Hash、操作前后保护快照与三项未闭合缺口。

如三项静态＋真实探针均满足，最高可标`PHP_DB_FREE_PROBE_OBSERVED_UNDER_NEW_BOUNDARY`，**不等于**API/DB/APP E2E已运行；如果来源/路径/动态握手任一不足则交`V10.1.5_THREE_ISSUE_UNBLOCK_PARTIAL_WITH_GATES`，清楚列需要的**一次最小后续Owner许可**而不是自动重置或派发。取得候选后fresh GitHub回读Commit、sole Parent、Root、逐变更path/mode/Blob及完整apps/services Tree，并核main产品v10.1.4仍不变。

最终**STOP等Astra独立验收**。持续`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`。创建本任务≠Owner手动派发≠真实执行；Astra只做独立审阅、管理和发布，不自行启动Codex或本地测试。
