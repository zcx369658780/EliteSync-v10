# EliteSync v10.1.5｜微软签名链修复、中央VC真实加载接线、Laravel12依赖与API/DB贯通｜Owner正式综合研发任务

**状态：OWNER_APPROVED_CONSOLIDATED_TRUST_REPAIR_AND_CONDITIONAL_SOFTWARE_RUNTIME / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_WINDOWS_VC_INSTALL_OR_REPAIR / NO_PRODUCT_MAIN_INTEGRATION**

签发：2026-10-30（Asia/Singapore）。Authority仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner当次授权、真实目标和不得混淆的等级

Owner阅读Astra对28994ea4的独立验收后，明确同意“优先修正中央VC信任证书链的取证，随后完成中央VC真正的PHP加载资格接线；证据合格后集中继续Composer锁、PHP Probe和Laravel12/独立MariaDB API验证”，指示继续。这是**同一综合任务内**的授权；普通受影响源码/安全工具/依赖/测试失败可集中修复，不拆微型任务。**本次明确不授权**运行Microsoft VC installer/repair、UAC提权、全局Windows/System32/注册表/ACL/PATH/php.ini修改，或通过app-local复制vc DLL规避缺口。如现有中央运行库无法合法合格，停止动态和供应相关分项，交出准确的单次Owner追加许可说明，不伪造PASS。

本任务的可交付高度分层：可信签名链与系统文件只是`CENTRAL_VC_EVIDENCE_QUALIFIED`，本机PHP真正加载此路径并通过nonce/进程镜像守卫才可称`CENTRAL_VC_PHP_LOADED_OBSERVED`；真实Composer solver生成Laravel12 lock且vendor来源一致才可称`LARAVEL12_LOCK_RESOLVED`；真正HTTP→Laravel12→隔离MariaDB的业务回执才可称`SYNTHETIC_API_DB_EVIDENCE_OBSERVED`。这些均不等于APP→API→DB设备E2E、RTC/AEC/Push、物理15/30天或v10.1.5整版功能接受。

## 1. 唯一研发Authority与固定源

开工前fresh读取 live main/Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文及Git Blob、`docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、冻结AC01–11和原15 E2E场景。

**唯一研发Parent `28994ea486eccc5191985c57952a61f6f7ab3d38`**，Root `ad7150eeb6996adbdf22ea4f4560d58afb9c71d4`；apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services Tree `4c01326cbf44b4705548e97221e3336e0448406f`。它的唯一Parent `f16d4cda817282d935cb53ce399d26a7850381a1`。Astra最新独立裁决在 `astra/v10.1.5-28994ea4-central-vc-independent-review-20261030:docs/versions/v10.1.5/28994EA4_CENTRAL_VC_PUBLISHER_EVIDENCE_ASTRA_INDEPENDENT_REVIEW_20261030.md`，审查Commit `72cede0f7658b2dc7f5bb8fe0ac472641f69a357`、报告Blob `c3af499789923013c7237bdeb81ff291a6059c9c`；该审查分支不是研发Parent。

源证：28994报告Blob `aa732ad41990d310c71e991ddaba01cadee5ce30`、Manifest Blob `432a57f8d6d34e167f3240777bfa2b273f864cc6`；上轮任务Blob `d048f7f8fee97a93f8bf8c52293f60762fff0bda`。已见central `vcruntime140.dll` FileVersion 14.51.36247.0，SHA256 `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`，两次只读观测各占2/2；WinVerifyTrust cache-only成功，但显示名为 `Microsoft Windows Software Compatibility Publisher`，检查器错误地要求等于`Microsoft Corporation`，且未记录合格发布者信任链。**不得假定系统损坏、必须重装或PHP确已成功动态加载**。

PHP官方8.5.12-1 VS17 x64 NTS ZIP历史Hash `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`；官方包内php.exe SHA256 `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`，旧只读可信LOCAL_ONLY字节新任务可以核Hash后复制到新私有根，原根不改。旧`composer.lock` Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍为Laravel11.48.0，`LOCK_RESOLUTION_PENDING`；旧Composer/vendor/PHP真实运行次数不得继承。

任务签发前main `d499658e0104960ebf270dbffb57a02ae86c36ee`，Root `239193ba375666ba1a8c74aadea0e32dcffdcecb`；main唯一已接受产品v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`，不会因main文档任务发布而自动接受v10.1.5。

## 2. Phase A｜证书信任与中央VC系统文件同源资格（核心纠偏）

只用**新任务根、旧LOCAL_ONLY具名原证的只读访问**和最多**3次本轮具名只读系统模块观察**。每次包括失败、准备和重试，预先写持久ledger。必须先将上轮两次被拒绝位置及其完整LOCAL_ONLY原证整理成新任务只读输入，不抹除旧失败。只针对Windows API定位的具名System32 `vcruntime140.dll`，不得遍历全System32/WinSxS或任意进程，也不得用`LoadLibrary`主动载入待验证文件来制造PASS。

- 按微软2026-08官方新一代代码签名兼容指南修改**非生产**信任检查器。删除把预设显示名、固定证书subject/issuer/thumbprint/serial、固定CA与签名算法当作唯一PASS/FAIL条件的行为；但仍要求调用受支持Windows Authenticode/证书链API来做实际可信链、代码签名用途、时间/吊销策略及Microsoft发布者归属的**可核来源**判定。推荐`WinVerifyTrust(WINTRUST_ACTION_GENERIC_VERIFY_V2)`＋必要的`CertGetCertificateChain/CertVerifyCertificateChainPolicy`；区分API调用成功、返回trust状态、`dwError`与撤销未查询。不得根据字符串包含Microsoft、合成布尔`publisher_verified=true`、自填64字符Hash或WinVerifyTrust cache-only exit0单独把文件判成“发布者证据合格”。
- 在受信的本机Windows证书验证接口下取得签名者链/签名用途/验证策略结果、版本和实际被校验的文件句柄身份的绑定；必要时对微软根/受支持发布者声明进行官方来源核查，但**不硬钉单个老证书或老CA**。任何不支持的政策路径、缺字段、签名用途不明、cache-only吊销信息不足均明确分级`NOT_PROVEN`或按安全政策fail-closed，不能悄悄关闭吊销要求。发布者链及证书全部原件留LOCAL_ONLY；GitHub仅脱敏分类和摘要Hash。
- 同时要求目标FileId/Volume、canonical直接System32父目录、无reparse/alias、readonly handle、links、x64、文件实际Hash `d1f422...c9ce7`、版本14.51.36247.0均与旧证据交叉核验，发现变化STOP而非改固定pin；不把普通OS映像、任意其它系统DLL、同名私有DLL纳入中央专用例外。中央v14兼容最低版本需用真实PHP官方构建资料和同版PE导入/exports/运行结果分层支持；PE linker14.44不是独立完整MSVC最低工具集证明。
- 在真正调用新观察前先做覆盖证书不同显示名但OS链通过、假Microsoft名称但信任失败、发行来源不符、wrong EKU、离线撤销未知、路径/Hash/版本/FileId/签名调包、私有/OS跨类、时序身份变动的纯合成负例。**不得“先观察再修正”反复耗尽配额**；将字段捕获与实际判定设计成一次完整观察可回放的LOCAL_ONLY收据。

## 3. Phase B｜实现真正的中央VC模块加载资格，不止纯输入合同

本轮必须在`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`的非生产运行入口**实际打通**三种身份边界：`TASK_PRIVATE_BINARY`（PHP/扩展及任务私有DLL，严格拒绝symlink/reparse/hardlink/路径越界）；`WINDOWS_SYSTEM_IMAGE`（原已接受的受信系统核心模块只读映像）；`MICROSOFT_CENTRAL_V14_RUNTIME`（仅已核具名System32 vcruntime140.dll，显式独立source_class/Hash/系统信任资格）。`php_runtime.validate_manifest`目前对所有非OS imports要求private闭包，`php_native`当前也没有中央v14分支，**不能只添加另一份静态规则就交付已接线**。

- 在静态PE普通/delay import解析时，针对确切需要的`vcruntime140.dll`允许**具名已资格的中央模块依赖**，而不是把`vcruntime140`加入泛化`os_import`或`manifest.files`中的伪private副本。所有其它非OS依赖仍须私有闭包；系统其它同类VC DLL若确实出现须具名另证或STOP，不可扩大。
- 对PHP CLI和API原生观察、握手及PHP侧`PhpRuntimeQualification::nativeReceipt`完成三类统一验证：启动前只校源与预期；实际Popen后由受控父进程持有原句柄/创建代际、检查真实已加载镜像的绝对canonical路径/FileId/Volume/Hash/签名链/nonce/Manifest；凡中央v14不在经核System32或出现私有同名DLL、不同版本/Hash、缺镜像、重启替换或单个额外native镜像则fail-closed。即使启动了PHP也只有观察receipt/退出/负例支持时才能升格动态PASS。
- **避免资格循环**：独立的`SUPPLY_ONLY_COMPOSER`受限PHP/Composer启动许可不要求已解析Laravel12 lock，但必须有实际合格中央VC、PHP exe/基础依赖/私有根、可信Composer PHAR以及全路径观察守卫；无DB`php_native_no_db_probe`不要求MariaDB`new_instance_qualified`；真正Laravel12 Feature/API/seed必须有新lock/vendor、隔离DB和原使用点CN/MC/Block/Token守卫。不要仅更改`RESOLVED`或`QUALIFIED`字符串绕过未验证的来源。
- 保留全部原负向契约和F1消息不变payload/key、F3可信T0/refresh、F4通知隐私及实际服务端撤权，不改真实用户权限或生产业务路由；支持同一综合任务内对普通确定性代码问题有界修正。

## 4. Phase C｜条件式真实Composer、PHP及Laravel12/API—MariaDB验证

**仅在Phase A真实发布者证据及Phase B现行系统VC加载闭包/运行守卫通过后**，才允许开始新实例软件运行；如果没有合格中央DLL，则保持`CENTRAL_VC_NOT_QUALIFIED`并终止PHP/Composer业务阶段，不能补用旧第三方14.38或执行VC installer。

- 冻结官方PHP8.5.12-1来源，只读核旧包Sha后复制到**新任务私有根**，不重新下载PHP ZIP/VC installer；Composer PHAR最多1份≤8MiB，可从具名`getcomposer.org`官方发行入口取得并验证发布Hash/签名，已有合法文件可复用。Laravel12 Packagist官方元数据及逐包锁定可信发行端点≤**240次HTTP请求、响应体总≤256MiB**（失败/redirect计入），Composer solver**最多2次**、`--no-scripts --no-plugins`的私有vendor安装**最多1次**，无artisan/bootstrap/数据库/系统global Composer写入。独立私有Composer home/cache，禁止自动下载/插件脚本/未知仓库执行；包来源、许可、版本、真实lock Hash、vendor树绑定全部保留。
- 真实生成与Laravel`^12.0`、PHP`~8.5.12`相容的`composer.lock`（当前仍旧Laravel11.48.0），有冲突在剩余2次求解范围内集中修正，绝不手工伪造lock/content-hash，更新PHP policy中的lock来源字节、composer_evidence、新vendor/PE/VC/CLI/API绑定。此后的业务运行仍须合格的 Laravel12 新vendor，不借旧历史。
- 独立**无DB PHP Probe≤2次、每次≤30秒**，真实核PHP版本/NTS/extension_loaded curl、fileinfo、mbstring、openssl、pdo_mysql，功能类、native进程/PID/nonce/中央DLL映像及source Manifest；不能连接MariaDB、Laravel/bootstrap或对外HTTP。动态模块结果与Laravel12业务运行结果严格区分。
- **Laravel12 Feature/Unit≤3批**：新框架兼容Feature三项、原消息/授权负例、Token撤销、T0/refresh、私有存储/通知。必须证明有效`APP_DB_CONNECTION/DB_CONNECTION`及`:memory:`或合成隔离库，防止测试误连旧库；失败不能改测试期待。
- 独立已有合法来源的MariaDB10.11.19私有实例服务启动≤2次，固定`127.0.0.1:43349`、全新空库`elitesync_v1015_mainline_e2e_20261029`、最小权限actor `v1015_e2e@127.0.0.1`、本轮独立datadir/server_id；PHP回环API≤2次，`127.0.0.1:43359`，真实HTTP≤160，PHP CLI（含供应PHP/Composer/Feature/Probe/fixtures）总Popen≤60，数据库迁移1次/合成seed事务1次，10虚构账号/5独立关系。每次执行前核datadir/actor/port/GRANT/selector/非旧库；旧DB或生产数据永不动。按冻结15场景验证同键重试与异payload 409、Block/MC/CN撤权、刷新不改T0、附件隐私、通知最小披露及重启持久结果。无合规≤128KiB H.264素材则视频场景NOT_RUN，不编造206。
- 获得上述PHP/API/DB的真实回执最多只允许称`LARAVEL12_SYNTHETIC_API_DB_OBSERVED`；仍**禁止**Flutter/Dart/Widget/analyze、Gradle/G2/JVM/APK、ADB/真机、RTC/AEC/真实Push/公网服务/实人数据/物理15或30天、系统VC install/repair/重启/UAC/安全策略/防火墙/ACL/注册表/全局PATH/php.ini/System32/WinSxS写入。

## 5. 总体预算与历史保护

**新独立**task_id=`V1015_CENTRAL_VC_TRUST_CHAIN_L12_E2E_20261030`，唯一new task-owned root与`attempt-0001`，一份跨中断持久ledger；logical与native allocated各≤**8GiB=8589934592 bytes**，从创建root/ledger起单调执行窗口≤**120分钟**，不能重建root、延长时间或跨任务“退款”。**新Windows只读中央VC观察最多3次（本轮失败也计数）；原28994ea的2/2不重置**。网络新增最多Composer PHAR8MiB和包/元数据256MiB，无额外PHP ZIP/VC下载。HTTP请求数、Composer次数、Probe/Feature/DB/API/迁移/seed以及PHP CLI总数如上一节。任何成本动作前持久PREPARE+fsync，失败、取消、超时照常扣数；前后保护目标身份记录，未知child/写入/网络来源立即STOP。
 
历史旧18、两ACL树、122原证、五根、527refs、3183 Seed、旧SQL/APK/原错误/claims/ledger/dirty绝不更改或清理；旧Flutter6/6和3bed3/3、MariaDB2/2、Gradle/APK1/1、旧全部中央观察/HTTP/Composer余数均无本任务许可。保留`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。原始证书链、系统路径、PID/FileId、用户/网络身份、详细日志、源码私有闭包、composer vendor与DB dump一律LOCAL_ONLY，公开GitHub仅脱敏检查摘要/必要源码/新合法lock/报告/Manifest。

## 6. 单一集中交付、真实测试边界与STOP

在固定`28994ea486eccc5191985c57952a61f6f7ab3d38` sole Parent上交**一个普通非force候选**，优先只改`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`与范围内必要Composer锁/受影响Laravel12源码及下述新报告/Manifest。不要变更apps Flutter或生产鉴权默认拒绝。推荐报告：
`docs/versions/v10.1.5/CENTRAL_VC_TRUST_CHAIN_L12_COMPOSER_API_DB_RESULT_20261030.md`
和
`docs/versions/v10.1.5/central_vc_trust_chain_l12_composer_api_db_manifest_20261030.json`。

报告分列证书链OS信任原证/缓存与吊销限制、具名中央系统文件Hash和模块真正加载路径、静态与动态ABI、Composer锁/vendored依赖和真实Laravel12/DB功能、每次cost与历史保护；`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN_GATE_CLOSED / NOT_PROVEN`绝不混淆。对最终失败给出准确的下一授权依赖和本轮已消耗/未运行范围，不能把OS观察失败认定必须重装。Codex须fresh GitHub回读Commit、sole Parent、Root、全部变更path/mode/Blob、双产品Tree及main仍仅接受v10.1.4。

成功最高`CENTRAL_VC_TRUST_AND_LARAVEL12_SYNTHETIC_API_DB_EVIDENCE_DELIVERED_AWAITING_ASTRA_REVIEW`；阻断`PARTIAL_WITH_EXPLICIT_TRUST_NATIVE_OR_SUPPLY_GATES`；无论哪种**STOP等Astra独立验收**。持续`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`。本GitHub发布不等于Owner派发、不等于本地执行。

## 7. 官方法规与参考

- 微软2026-08代码签名证书轮换：https://support.microsoft.com/en-us/servicing/os/windows/docs/2026/08/next-generation-code-signing
- Windows WinVerifyTrust：https://learn.microsoft.com/en-us/windows/win32/api/wintrust/nf-wintrust-winverifytrust
- Windows证书链策略：https://learn.microsoft.com/en-us/windows/win32/api/wincrypt/nf-wincrypt-certverifycertificatechainpolicy
- Microsoft v14：https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist
- PHP8.5 Windows：https://www.php.net/downloads.php?os=windows&version=8.5
- Laravel12官方升级：https://laravel.com/docs/12.x/upgrade
