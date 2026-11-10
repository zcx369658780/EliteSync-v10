# EliteSync v10.1.5｜Owner正式选定Laravel13/PHP8.4＋旧开发版本本地核验备份＋一次性安全集成｜Codex综合任务

**状态：OWNER_APPROVED_LARAVEL13_PHP84_DEV_BASELINE / PREMIGRATION_LOCAL_BACKUP_REQUIRED / ONE_CONSOLIDATED_SAFE_INTEGRATION_TASK / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NOT_EXECUTED / NO_DELETION_AUTHORIZED / NO_PRODUCTION_MIGRATION**

签发：2026-10-30（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。本任务是**备份→差异归属→隔离集成→相关回归→候选交付→Astra独立集成验收**的一份综合任务，不是重跑Windows DLL问题，也不是将v10.1.5整版补签为FUNCTION_ACCEPTED。

## 0. Owner已定方向与权限
Owner对Astra已独立有界验收的`9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`候选明确确认：**Laravel 13 + PHP 8.4 正式成为EliteSync后续开发技术基线**。Owner另提出“在本地硬盘上备份一下当前旧版本内容，如果迁移新版本成功后再删除（多一道保险）”。现予落实为**必须先形成本地具名备份、核验完整性和可恢复性，后进入任何旧版本替换；删除列为受条件限制的未来清理，不属于本任务授权**。这不批准升级生产服务器、变更Windows全局软件/环境或删除原生旧版本、历史证据、旧DB、镜像、worktree。Owner不担任日常消息总线，**仍由Owner手动派发Codex**；Astra负责最后独立验收。

必须区分：`OWNER_SELECTED_DEVELOPMENT_BASELINE`、`SOURCE_INTEGRATION_CANDIDATE`、`MAIN_PRODUCT_INTEGRATED`、`LOCAL_DEV_BASELINE_ACTIVE`、`RUNTIME_VERIFIED`、`V10.1.5_FUNCTION_ACCEPTED`、`PRODUCTION_DEPLOYED`为不同事实。Owner已选择方向，但**main产品、当前本机旧版本、生产及AC05并未随本文件自动变动**。

## 1. 固定Git Authority和唯一集成Parent
- 现行已接受并main集成的产品仅v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`；services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。本任务发布前main `e5d37a99813ff88adbbadb5d329711f3e8c2c406`、Root `06e704afa63c4b7c1892137ee1211d26c163d694`，后续纯文档发布会推进main。**集成候选唯一sole Parent必须为Codex开工时fresh读取的最新main**（包含本任务及ACTIVE_STATE）、且其apps/services双Tree必须仍与上述已接受主线一致；记录确切Parent Commit与Root，不能使用旧e5d作为可覆盖实时main的借口。并发main产品变化则STOP冲突部分，不force/rebase/盲merge。
- 有界接受的Laravel13候选固定Commit `9b74ca6fef89e2507f966870c1f0d04f4fe09ba6`、Root `3b9690c1cdd6313d8f192c0ca4105352b8b40188`、apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`、services `9427d6deba3be2d44fce94122661a21668976e20`；唯一研发Parent `debe4a11d19f25179efef1d90d04e346980c2867`。Result Blob `f7e83f4062f49def6e86cc4fc88a1026dbd1eb63`、Manifest Blob `500e4c78f6876f048b138e0c223b6288b376e70e`。
- Astra独立有界审查文档在审查Commit `9026a5bb04bbb23358eb8c6f61afba66ae4f2318`、Blob `456c8d47ec98e815c467e9d5f38ea3b4ddf12680`；`LARAVEL13_LINUX_BACKEND_SYNTHETIC_API_DB_CANDIDATE_ACCEPTED_WITH_OBSERVATIONS`。此Review Commit和前轮Codex候选都**不作为本次集成候选Git Parent**，只是明确允许选择性接入的源码依据。
- 开工fresh读取`docs/workflow/ACTIVE_STATE.md`、`CURRENT_WORKFLOW.md` Blob`42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob`0f62532a71fb9753811fafa9e03819a46422f4bf`、`docs/versions/v10.1.5/plan.md` Blob`7d3466b3be67135dc641cfee7c7faef78937ba03`及原AC01–11、上轮报告/Manifest和审查，核候选源码/正式产品双Tree/路径归属。
- 当前候选services相对正式main services存在**52项不同文件**，包含前轮未整版接受的v10.1.5 F1/F3/F4、运行资格工具、迁移与测试。必须逐条分层：`ACCEPTED_L13_TOOLCHAIN_AND_REQUIRED_FRAMEWORK_COMPAT` / `ALREADY_ACCEPTED_MAIN` / `UNACCEPTED_V1015_FUNCTIONAL_CODE` / `TASK_ONLY_E2E_OR_WINDOWS_TOOLING` / `UNKNOWN`。只精确引入Laravel13开发必需的composer.json/lock、兼容源码、必要测试与无凭据的工具链定义；不可直接覆盖完整services Tree、盲合全部候选、删除main原有业务或把未接受的v10.1.5业务逻辑暗接入main。若必要框架切换依赖未接受的业务改动，必须构造**独立、可审查的集成候选**并把该部分标BLOCKED/PROPOSED，不将其当正式接受；必要时完整main产品集成暂停，保留已经通过的本地开发分支与报告。原AC不因版本号倒改。

## 2. 第一阶段强制：本地旧版本备份（先验、先存、先验真）
1. **只读inventory**本机当前真正使用的EliteSync-v10开发版本/源码根、现有运行依赖版本和Git HEAD/branch/dirty/index/untracked/ignored/本机workspace身份、现有明确归属的开发配置。不能假定`D:/EliteSync-v10`是可清理目录；`D:/EliteSync`旧仓、原dirty、历史保护root及其它项目均不得盲pull/reset/stash/clean/prune/移动/覆盖。Owner所谓“旧版本”优先指**本次迁移将实际替换/接续的可识别旧开发代码与版本依赖元数据**，不是所有旧历史资产或生产数据。先形成`OLD_VERSION_BACKUP_SCOPE_INVENTORY`，列source、身份、范围、排除项、数据敏感等级、预计字节与实际剩余磁盘空间。
2. 在**Owner本机磁盘上新建具名日期+精确Git身份的隔离备份目录**（在只读确认可用分区/空间与ACL后确定绝对路径；不得提前假设某路径存在）。备份至少包含**集成前v10.1.4 accepted main的完整apps/services代码快照及Git来源**、composer.json/旧composer.lock、相关无敏感版本配置/manifest、当前本地确实使用且本次可能受影响的开发代码和可合法复制的自有未提交修改（要明确区分clean/dirty，不覆盖/消化原未提交改动）。仅复制实际与此次切换相关的文件，尽量hardlink-free、只读原件→新路径复制，不用move/rename/覆盖原件；为可恢复性额外记录文件路径、mode、Git Blob/Source SHA256、文件长度与源/目标hash一致的Manifest。备份完成后重新打开随机/必要全量文件做读回，并至少通过一条**不触碰原工作树**的隔离恢复试读验证可还原Git/依赖元数据与关键配置。保存备份目录本机真实FileID/Volume、文件数、体积、保留清单和回滚步骤。
3. **敏感/数据分层**：`.env`、DB密码、token、私有证书、私聊/出生资料、原始设备日志、密钥、真实旧数据库卷或备份、旧ledger与LOCAL_ONLY原证不复制到GitHub，也不以普通压缩包混入公开目录。需要保留本机开发环境私有配置时，仅在归属已确认且已有本机安全机制的**LOCAL_ONLY、受限访问、必要时加密**备份副区中最小化复制并核验，不在公开Manifest写值、绝对私人路径或可逆凭据；若无法安全备份该类文件，停此部分并报告“RESTORE_NEEDS_PRIVATE_CONFIGURATION”，不擅自读旧真实用户数据库。旧数据库/生产实例**本轮只保护，不迁移/清理/删除**，新测试必须新空库。备份代码≠实际数据库全恢复能力，明确写明。
4. 备份源与目标不得与同一worktree/旧任务root/共享Docker volume相互覆盖；避免目录循环、symlink/reparse、hardlink误判、无界扫描、磁盘快满。先探测所需空间，采用明确上限。**备份失败或核验不完整立即STOP集成阶段**，不以GitHub备份代替本机这份额外保险。备份只LOCAL_ONLY，不上传公共GitHub/ChatGPT Project；GitHub仅存脱敏大小/hash/是否restore-check通过及归属分类。
5. 备份完成即锁定`PREMIGRATION_LOCAL_BACKUP_VERIFIED`回执；原旧版本始终保留。允许在一份新隔离代码工作树中尝试迁移；不得原地覆盖当前dirty环境，也不许删除旧PHP/Composer/旧Docker镜像/原vendor、旧worktree/数据库/证据以腾空间。若现有磁盘不够，STOP并列出备选分区/容量，不得“先删除旧版再备份”。

## 3. 第二阶段：来源精确的Laravel13安全集成
- 从当前fresh main独立干净集成工作树/普通non-force候选开始，以**选定的产品与Laravel兼容改动**的路径+Git Blob+mode清单做精确接入；旧main已有页面/服务逻辑保持，v10.1.5历史未接受的消息、通知、登录、安全业务代码默认不随Laravel升级自动接受。改动清单逐项对比候选9b74、正式main及需要的测试，说明引入、保持、不引入和原因。切勿整树替换、Git全分支merge、覆盖已有主线代码、静默改变已接受AC。
- 严格保留`laravel/framework v13.39.0`、PHP8.4家族和前轮已签范围的Composer新lock（Blob`e236fbc960c1dd08c1fecb9aeed4926b4cab3933`）、composer.json（Blob`130793decf84ff8ab93faa0300117b7fab9d1826`）作为**目标身份**；不能只改声明，不手造锁。前轮task-owned供应镜像、vendor、DB卷、账本虽保留但已STOP，不直接复用/修改其私有任务根或隔离数据库；可以在新的独立验收环境合规获取/安装依赖并核Digest/执行路径。
- 真实合成主线差异回归所需代码可在当前新任务内有界修复，包含session配置/CSRF/PHPUnit12、Sanctum登录与撤权、CN/MC/Block/幂等消息、F3 T0、F4通知、私人媒体、内部Safety与v10.1.4虚构活动保护。**不得为了让测试变绿放宽授权、删除负例或把新业务逻辑冒称既有main已接受**。若恢复v10.1.4功能依赖某个尚未接受的v10.1.5改动，需另标`INTEGRATION_SCOPE_CONFLICT`，先STOP相关正式产品合入而不是偷渡。
- 旧Laravel11 cookie及登录会话兼容**只获合成PHP序列化夹具证据**，未证明旧11二进制实际生成的cookie；本任务若只能做合成安全回归，必须继续标`REAL_LEGACY_L11_COOKIE_NOT_PROVEN`，不能无授权读取真实旧用户Session、密钥、生产DB或输出原始cookie。

## 4. 第三阶段：有界联动回归与本地连续基线
- 本任务如具现成合法Docker Linux Engine，仅可在**新task-owned隔离环境**运行相关真实PHP8.4/Laravel13/Composer validate和`composer install --no-scripts --no-plugins`，独立新空MariaDB10.11、虚构数据、回环HTTP，核选择性集成后的安全负例与关键持久读回；不要求再次全量重跑旧258 tests，可按差异定向运行。若没有现成合格Engine或官方来源/请求字节计量/依赖闭包不合格，STOP动态并集中说明，不自行重新启动Docker/WSL或绕过预算。若任务需再真实求解依赖，不能静默改已接受Lock，留为`LOCK_REQUIRES_NEW_DECISION`阻断，不盲降Laravel12。
- 真正`MAIN_PRODUCT_INTEGRATED`仅在**Owner本轮批准的、满足备份、来源选取和必要验证**情况下按受控安全集成候选交付，先不要自写`ACCEPTED`。Codex候选STOP后Astra独立验收，Astra确认新的main产品双Tree精确符合目标且无未接受业务偷渡，才签`INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`或更低状态。若差异风险尚未关闭，**不提交到main产品**，报告阻断并保留候选；Owner不用在普通任务内部当message bus。
- 本地可用连续代码基线应与**实际独立集成后经Astra接受的main产品**精确比对；若集成待接受，不把未合main候选当已正式生效的本地默认开发版本。备份不影响旧工作树；本地可用新版若须切换路径，以新工作树/明确映射、安全入口为先，不自动覆盖D:/EliteSync-v10 dirty。

## 5. 旧版本保留/删除的最终双重门禁（不可跳过）
- **本任务绝不删除**旧开发目录、旧PHP/Composer/vendor、Docker image/volume、过期分支/worktree、旧数据库/备份、原始失败、历史保护root、原证/密钥、LOCAL_ONLY文件。Owner“迁移成功再删除”是清理时序方向，**不是对未识别路径的现时批量删除授权**。
- 最早可讨论清理旧版本：先具备`BACKUP_VERIFIED_AND_RESTORE_CHECK_PASS`、Laravel13安全集成的Astra独立接受、目标本地新版实际可用、持久化/旧版本回滚演练可行、且明确任何仍运行项目或历史证据不依赖旧版本；再列出每个候选删除项的绝对路径或包标识、大小、FileID/Volume、hash、归属/依赖、是否可逆、备份覆盖与回滚计划及至少一次冷启动/恢复证据。
- 该清理清单提交**Owner再作明确的按项删除确认**，不得自动发清理任务或执行；即使Owner后续同意也不得删除历史冻结账本、原证、dirty、数据库真实备份、可核历史事故或非本项目资产。用户可选择更长保留期。仅保留在相同物理硬盘的备份不是磁盘硬件故障的冗余；若有第二磁盘可另外复制一份，但不作为未授权外传借口。

## 6. 新任务独立预算、路径与隐私
- 新task_id：`V1015_LARAVEL13_MAIN_SAFE_INTEGRATION_AND_BACKUP_20261030`，唯一新task-owned根、attempt-0001、持久ledger；从首次建立单调计时。文件源扫描限上述具名v10根/关联代码，禁止跨项目全盘搜旧源。单调窗口≤240分钟，task+backup总新分配 logical和allocated各≤16GiB（检查真实源大小并保留自由空间；若拟备份超过即STOP，不假定历史旧资产需复制）。
- 如涉及新供应/隔离运行：下载响应体≤2GiB、可计供应请求≤500、OCI Digest≤8、Docker build≤2、真实Composer solver**0**（不重解锁）、vendor install≤1、受控服务组≤2、PHP CLI≤100、Feature/Unit≤3批、回环业务HTTP≤120、全新空库migration/seed各≤1。所有失败/超时/重试计数；成本前`PREPARE`+`fsync`并在唯一ledger封存；禁止复用上轮STOP剩余额度或占用历史固定端口43349/43359。环境容量不足暂停，不为腾空间清除旧资产。
- 默认无任何Windows全局安装/升级/改PATH/UAC/VC/Hyper-V、无生产SSH/数据库写入、无真实供应商或费用。Flutter、Gradle、G2、APK、ADB、真机RTC/AEC、真实Push、物理15/30天均不在此范围。没有授权读取/上传真实私人聊天或证书；无原生产端运行。
- 永久保留四门：`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`、`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN`、`RESTRICTED_IDENTITY_GATE_BLOCKED`、`OS_ENFORCEMENT_NOT_PROVEN`；历史Windows`E_NOTIMPL`不因Linux接受而改写，早期`EARLY_READONLY_RECEIPT_GAP_NOT_RECONSTRUCTED`原样保留。

## 7. 唯一候选、报告与Astra独立出口
- Codex只提交**一个普通non-force候选，sole Parent为开工fresh main**，基于独立干净集成树，不得同时更动生产或让候选自行进入main。候选可含严格必要后端/测试/新安全部署配置与本任务脱敏报告。整版v10.1.5仍`PARTIAL_NOT_ACCEPTED`、AC01–11=10 PARTIAL/1 OPEN、AC05 RTC/AEC OPEN、G2 false、REAL_PUSH_PROVIDER_PENDING、v10.1.6 NOT_STARTED；不得把安全集成当整版通过。
- 必交：`docs/versions/v10.1.5/LARAVEL13_SAFE_INTEGRATION_AND_LOCAL_BACKUP_RESULT_20261030.md`、`docs/versions/v10.1.5/laravel13_safe_integration_and_local_backup_manifest_20261030.json`、`docs/versions/v10.1.5/LARAVEL13_SOURCE_SELECTION_AND_DIFF_MAP_20261030.md`。附`LOCAL_ONLY`备份Manifest/恢复试读与hash/ACL、旧开发源保护快照、实际备份目标、受控候选路径/mode/Blob、所有测试原始退出/报告、旧版本删除禁止清单和未来需Owner确认的精确候选删除范围。GitHub公开只存脱敏结论与SHA/体积、不得上传绝对私人路径/数据库/凭据/原始文件。
- 明确状态分类：`SAFE_INTEGRATION_CANDIDATE_AWAITING_ASTRA_REVIEW`、`BACKUP_GATE_BLOCKED`、`INTEGRATION_SCOPE_CONFLICT`、`LOCAL_RUNTIME_NOT_RUN`等，并分`DIRECT_GITHUB_OBJECT`/`CODEX_REPORTED_LOCAL_TEST`/`LOCAL_ONLY_RAW`/`NOT_RUN`/`NOT_PROVEN`。提交后fresh GitHub读取候选Commit、唯一Parent、Root、完整变更path/mode/Blob及apps/services双Tree和live main，STOP交Astra；**Codex不能自签接受或删除旧版本**。
