# EliteSync v10.1.5｜Windows具名OS目录签名与最小原生依赖、PHP Probe、Laravel12 Composer及API/DB贯通｜Owner正式综合任务

**状态：OWNER_APPROVED / MINIMAL_OS_CATALOG_TRUST_AND_CONDITIONAL_L12_RUNTIME / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_SYSTEM_INSTALL_OR_MAIN_INTEGRATION**

日期：2026-10-30（Asia/Singapore）；仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner授权与一次性完成目标

上一研发候选`14e6cde7`已由Astra独立有界接受：中央VC v14受支持Windows信任证据获得Codex本机通过，真正PHP Native加载**工具接线源码**已实施，但实际PHP尚未Popen。阻断发生在预启动`NATIVE_OS_IMPORT_NOT_QUALIFIED:iphlpapi.dll`，另有`wldap32.dll`、`secur32.dll`、`normaliz.dll`的现有embedded-signature/链/时间证据不足。Owner同意Astra建议的**一个集中后续任务**：只对已具名且真正必要的OS导入核支持的catalog成员签名与可信时间，收紧递归/延迟导入集合；若资格完整成立，在同一任务内继续PHP实际能力、Laravel12真实Composer锁、Feature以及独立MariaDB/API业务验证。禁止反复纯环境微任务、重复下载已经核验的PHP、重装VC、或“签名有误所以删除守卫”。

此次交付分级：`OS_CATALOG_AND_MINIMUM_IMPORT_PROVEN`≠`PHP_NATIVE_LOADED`≠`COMPOSER_LARAVEL12_LOCK_RESOLVED`≠`LARAVEL12_SYNTHETIC_API_DB_OBSERVED`。条件不合格时按正确的安全STOP提交单一PARTIAL候选，不伪造更高状态。业务版本仍不获整版接受。

## 1. 固定Authority与不可变来源

开工fresh读取实时`main`及Root Tree、`docs/workflow/ACTIVE_STATE.md`、本任务全文/Blob、`docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、现有AC矩阵及15场景。

**唯一研发Parent**：`14e6cde7b714c5bacdeedeb87233345d36a435c5`；Root `d716ca18fac3ea2e992346355eabf64b4bfb4043`；apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`、services `4dbf710d64cf12ca513c4747bf53b7d73d5cfe1a`。该候选Parent是`28994ea486eccc5191985c57952a61f6f7ab3d38`。最新Astra审查：`astra/v10.1.5-14e6cde7-vc-trust-loader-independent-review-20261030:docs/versions/v10.1.5/14E6CDE7_CENTRAL_VC_TRUST_AND_NATIVE_PRESTART_ASTRA_INDEPENDENT_REVIEW_20261030.md`，Review Commit `7dc4eb8e4d75e1b6f4c383ec9b5b0556bc2e208f`、Blob `4393e0bb295884d6882be16da163e2c63854282b`。原交付报告Blob `7f77e16bdf0f9ead67ef0d67eccdb9881868e210`、Manifest Blob `e9ecedab8ffc373b3ecdb842429225882a93f859`，本轮不得修改历史结果。审查分支不是研发Parent。

发布前main HEAD `fb04ac80863bae9b2a9c2c00ea7eb11d4015f107`；唯一已接受产品v10.1.4：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。签发将推进**文档main**，不等于v10.1.5产品已集成。

保留上一候选确切能力边界：central vcruntime140.dll版本`14.51.36247.0`、本机Codex reported static SHA `d1f4225df2cd877dbf130d5668a021dce3f94118455ff5ec952061c30afc9ce7`，有界信任PASS**不是**PHP已运行；PHP8.5.12-1官方ZIP SHA `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`与exe SHA `5ee83565e8095339936bfead69b50830c85cda422ab18cbdf7a9982f43070e65`属上一任务实际读取的LOCAL_ONLY证据，新根需再核具名文件字节。旧`composer.lock` Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍Laravel11.48.0，Laravel12 lock与vendor未取得。本任务不是上一STOP任务的续跑，任何旧剩余额度都不迁移。

## 2. A｜最小必要导入、真实catalog/嵌入签名和可信时间戳

先**仅用上轮已归档LOCAL_ONLY资料和固定PHP官方PE内容**构造最小闭包，再允许新OS读取：
- 将需启动`php.exe`及具名必需5扩展所用普通PE imports、递归实际加载所需模块，与delay-import/可选未加载模块**明确分列**；仅对证明是当前PHP prestart必须的具名OS文件建立受控静态pin，保存包中导入路径链，不得沿旧105候选或40未合格文件清单无限递归。遇未在合同内的真实模块仍须在**post-Popen**由实际镜像观察严格拒绝，绝不以`delay`名义放过实际已加载文件。
- 优先精准审查`iphlpapi.dll`、`wldap32.dll`、`secur32.dll`、`normaliz.dll`四个已观察缺口；其它仅在从具名PHP必需PE普通导入证实确有关系后纳入同一额度，不能目录遍历、通用全系统信任或查其它进程。
- 支持两种独立验证路径：真正嵌入Authenticode签名，以及**具名文件Hash到catalog条目再到受信catalog签名**。使用微软公开的`CryptCATAdminAcquireContext2`、`CryptCATAdminCalcHashFromFileHandle2`、`CryptCATAdminEnumCatalogFromHash`及`WinVerifyTrust` catalog选项/受支持证书链策略，或**当前已存在且自身可信**的SignTool只读`verify /a`作为交叉证据。必须核实际指定文件的只读句柄/FileId/Volume/Size/SHA和catalog成员Hash归属、catalog文件及发布者链、正确代码签名政策、可信签名时间或可信时间戳策略、撤销状态与本机cache-only限制；不能把普通文件Hash、catalog文件合法、签名时间字符串分别当成整体PASS。每个嵌入/catalog方法及策略返回错误单列证据。
- 错误`0x800B0100`、`0x800B0101`及过期/撤销不明要分别解释并保留；只有真正受支持的时间戳/链策略能重新资格，不允许`ignore expiration/revocation/test-root`、`VERIFY_CATALOG_UNSUPPORTED`、签名显示名白名单或把System32目录自动视为信任。禁止`signtool catdb`、CatalogAdd/Remove和安装驱动、系统更新。调用现有只读catalog数据库索引不等于授权修改该数据库。
- **在第一次本轮OS观察前**完成最小依赖集合和纯合成正负例：错catalog成员Hash、错系统路径、证书链失败、无可信时间/过期、无撤销资料、可选delay冒充强制、真实动态模块不在pin、私有同名DLL、错误签名策略、时间/文件身份交换，均拒绝。将一次完整证书/目录/文件结果写入任务本地可重放的raw收据，避免反复用贵重观察额度试错。
- 新任务限定最多**2次具名Windows OS来源观察**，包括失败、准备、重试；只对上面确切必要的文件集合/从当前PHP已固定导入链证实的成员查询，所有旧OS观察2/3与更早2/2均保留不退款。若需要额外系统来源、未知Windows自动签名更新或线上撤销查询，停止并合并一次Owner决策，不扩权限。

## 3. B｜使已有Native启动路径真正符合最小闭包，且不削弱原保护

- 仅修改必要`tools/v1015/mainline_e2e`和`services/backend-laravel/tests/E2E`资格工具、当前任务绑定、测试/文档。延续`MICROSOFT_CENTRAL_V14_RUNTIME`具名受信中央DLL、`WINDOWS_SYSTEM_IMAGE`独立只读目录验证、`TASK_PRIVATE_BINARY`私有13官方PHP成员与不可变hardlink/reparse严格隔离；不可全局跳过OS签名、不把central vcruntime加入通用`os_import`、不提取/复制VC DLL。
- `current_native_task.execution_gate`先校真正必需且已合格的直接OS导入；对optional/delay-import不假装已加载，启动后必须从**真实子进程**API抓所有已加载的模块并强制闭包身份。握手PID/进程创建代际/原child handle/nonce/source/Manifest/代码源Hash/真实退出都保留，任何未知OS/额外VC、路径变化、私有同名DLL、加载失败或不一致必须STOP并保存实际stdout/stderr，不可修改测试期望/Hash来伪造结果。
- 现有`windows_vc_trust.py`第二次观察成功的中央VC证据已获有界审查；不要重复该已完成调查，也不得把旧证据升级为实际PHP加载。若中央VC当前字节与信任pin不符，只报新阻断并停止，不自行重装Windows。所有缺少的PHP/Composer启动接口只能在当前任务获得的确切新授权动作下运行。

## 4. C｜条件式Composer真实求解与PHP/Laravel12—MariaDB

只有A/B真实资格合格才执行。若OS catalog未闭合，Composer/DB不得启动，独立合成源码成果仍可形成一个PARTIAL候选。
- 使用前轮已验证的PHP官方ZIP与其13具名必需成员，**只读原件经Hash匹配后复制到新任务私有root**，不重新下载PHP或VC安装器。独立`SUPPLY_ONLY_COMPOSER`不依赖尚未存在的Laravel12 lock，但必须先合格PHP、中央/OS全部必需Native、可信Composer PHAR和task私有进程/网络守卫。
- 允许官方Composer PHAR最多1份≤8MiB，具名`getcomposer.org`官方发布来源及Hash/签名核验；Packagist和实际声明的可信包dist来源，逐跳登记host和包身份，合计HTTP≤**240次**、真实response body≤**256MiB**。Composer解算≤2次、私有vendor install≤1次，`--no-scripts --no-plugins`，完全禁止Laravel/bootstrap、post-autoload artisan、全局Composer home/cache、旧vendor及真实数据库。真实solver产出与Laravel`^12.0`＋PHP`~8.5.12`一致的新`composer.lock`；失败不得伪造content-hash或只改`RESOLVED`字段。成功后同步重冻`php_requirements.json`中的`source_documents.composer.lock`及`composer_evidence`、vendor来源、PHP/VC/OS Manifest和CLI/API source-binding。
- 独立无DB PHP Probe≤**2次、每次≤30秒**，观察版本/NTS、curl、fileinfo、mbstring、openssl、pdo_mysql及全量native PID/nonce/真实加载；无DB探针不先要求new_instance_qualified、不得连DB/Laravel/API。随后仅在新合法lock/vendor/测试DB selector完全成立时，Laravel12 Feature/Unit≤**3批**，含新3项Feature、消息同键重试/授权撤销、T0/refresh、私有媒体/通知安全回归。
- MariaDB10.11.19必须是已经有合法具名来源的**全新隔离**实例；回环127.0.0.1:43349，新空库`elitesync_v1015_mainline_e2e_20261029`、最小权限`v1015_e2e@127.0.0.1`、本任务独立datadir/server_id；MariaDB启动≤2、PHP API127.0.0.1:43359启动≤2、总PHP CLI包括Probe/Composer/Feature/迁移≤**60 Popen**、真实HTTP≤160、迁移≤1、合成seed事务≤1、10虚构账号/5独立关系。每次执行前核端口、actor、GRANT、数据库空状态、APP_DB_CONNECTION有效值、URL/socket、实际datadir/实例身份；任何旧/生产库风险立即STOP。
- 用原冻结15场景记录真实HTTP→Laravel12→MariaDB：F1同键重试/冲突，MC/CN/Block撤权、旧Token拒绝、T0/refresh、私有附件/通知最小披露、重启持久读取。没有受许可的H264合成视频就该场景NOT_RUN，不伪造206。成功最高`LARAVEL12_SYNTHETIC_API_DB_OBSERVED`，**绝非**真实Flutter/设备APP同源E2E及整版接受。

## 5. 总授权预算、保护、交付和STOP

一个新task-owned私有根：`V1015_OS_CATALOG_MINIMAL_IMPORT_L12_E2E_20261030`、attempt-0001及一份持久ledger。logical和native allocated分别≤**8GiB（8589934592 bytes）**；从首次新根/ledger建立起的单调总窗口≤**120分钟**，不可跨任务/会话重建或刷新计数。新OS具名观察≤2，Composer PHAR/HTTP/解算/vendor、PHP Probe/CLI、Feature/MariaDB/API/HTTP/迁移/seed次数按A/C限定，失败、取消、超时和重定向照扣。**每个成本动作前PREPARE+fsync**，必须记录实际执行/返回码/原stdout-stderr Hash，且保留正确的未运行分类。

保留旧18、两ACL实验树、122原证、五根、527refs、3183 Seed、所有历史失败/ledger/claims/dirty；旧Flutter6/6及3bed3/3、MariaDB2/2、G/APK1/1与历次中央/OS观察费用均不退款。永久保留`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`。本轮绝不授权VC installer/repair/UAC提权、Windows更新、ACL/注册表/System32/WinSxS/PATH/php.ini/全局安全设置写入、Flutter/Dart/Widget/analyze、Gradle/JVM/G2/APK/ADB/真机/RTC/AEC/Push、外网公开服务、真实用户/生产数据或费用。证书/目录签名原件、系统FileId/PID/用户名、vendor/二进制、私有日志及DB dump只留LOCAL_ONLY，公开GitHub只交脱敏摘要和必要代码。

一次性输出**一个非force研发候选**，sole Parent精确为`14e6cde7b714c5bacdeedeb87233345d36a435c5`，只修改任务所需`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`、合法生成的composer.lock/受影响Laravel12源码及本轮报告/Manifest。建议报告`docs/versions/v10.1.5/OS_CATALOG_MINIMAL_IMPORT_L12_API_DB_RESULT_20261030.md`和Manifest`docs/versions/v10.1.5/os_catalog_minimal_import_l12_api_db_manifest_20261030.json`。按`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN_GATE_CLOSED / NOT_PROVEN`分级；所有失败、OS信任/时间戳/当前加载、Composer包及业务测试状态明确列入，不强行标PASS。

完成后fresh GitHub回读候选Commit/sole Parent/Root/每项变更path+mode+Blob/apps与services双产品Tree和最新main，**STOP等待Astra独立验收**；不得自动合并产品main、签整版FUNCTION_ACCEPTED、关闭AC05（RTC仍OPEN）、放行G2或启动v10.1.6。若OS证据仍缺则`PARTIAL_WITH_EXPLICIT_OS_CATALOG_OR_NATIVE_GATES`，不能继续等待或重复启动。原AC01–11仍10 PARTIAL/1 OPEN。**任务发布不等于派发或执行，Owner手动派发才生效。**

## 官方只读证据

- https://learn.microsoft.com/en-us/windows/win32/seccrypto/using-signtool-to-verify-a-file-signature
- https://learn.microsoft.com/en-us/windows/desktop/seccrypto/signtool
- https://learn.microsoft.com/en-us/windows/win32/api/mscat/nf-mscat-cryptcatadmincalchashfromfilehandle2
- https://learn.microsoft.com/en-us/windows/win32/api/mscat/nf-mscat-cryptcatadminenumcatalogfromhash
- https://learn.microsoft.com/en-us/windows/win32/secbp/understanding-pe-signatures
