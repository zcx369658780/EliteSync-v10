# EliteSync v10.1.5｜隔离Linux统一工具链＋Laravel批量迁移＋真实API/DB回归｜Owner综合任务

**状态：OWNER_APPROVED_ONE_SHOT_DEV_TOOLCHAIN_MIGRATION / LINUX_RUNTIME_FIRST / LARAVEL13_CANDIDATE_NOT_FINAL_PRODUCT_DECISION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NO_GLOBAL_INSTALL / NO_MAIN_INTEGRATION**

2026-10-30 Asia/Singapore；唯一权威仓库 `zcx369658780/EliteSync-v10`。

## 0. Owner新决定及本轮优先级改变

Owner在Astra独立审查 `89413238` 后明确提出：“软件兼容问题还没彻底解决；推荐将开发软件一次性升级到相对稳定版本，然后让Codex批量迁移，不要一个一个试错”，并授权继续。**这意味着开发策略从Windows原生PHP/VC/API-set按DLL逐项研究转为一次性隔离后端工具链迁移与批量兼容修复。** 此综合任务允许在已存在的受控Linux容器/WSL用户环境中部署任务私有开发依赖、真实求解依赖并批量修复源码，先完成后端开发可用性；不授予在Windows宿主安装/启用WSL、Docker、Hyper-V、VC、Windows更新或改变全局安全配置/生产服务器的权限。

**目标分层：**
A. 统一可靠的Linux PHP/Composer/MariaDB测试工具链实际启动；
B. 在一个批量迁移矩阵中解决Laravel依赖/源兼容，真正生成lock及vendor；
C. 真实PHP→Laravel→独立MariaDB持久化API回归；
D. Astra独立验收，才可能决定是否接受特定Laravel13方向或将候选产品合入main。

本轮不以完成Windows PHP Native兼容为前提。此前Windows API-set `E_NOTIMPL`及原生关闭门属于历史证据，**不删不改不声称已修好**；Linux为独立的可核运行剖面，不能靠修改Windows旧测试期待制造PASS。

## 1. 固定 Authority、产品及旧风险门

**唯一研发Parent `8941323808ce0cdfc68b9f0c3796f86400a75d43`**，Root `6808c706f4b2f03b641975f71315c241ce6e435a`，apps Tree `8cd9b6df8e744c8fc9d4217412edce31795a318d`，services Tree `521cafbb463e0099271618c22cafd1ed6218bea2`；Parent的唯一Parent为`d33845e62f1aa5eb82e0a4bf443b0396f2eb8b1a`。Astra最新审查：`astra/v10.1.5-89413238-api-set-raw-first-independent-review-20261030:docs/versions/v10.1.5/89413238_API_SET_RAW_FIRST_E_NOTIMPL_ASTRA_INDEPENDENT_REVIEW_20261030.md`，Review Commit `483d66326fb5f5c13e23bafb519c9aba99d38f9e`，Blob `c1b5577728f16077b416c73d82901ba94fa43335`。审查分支不可作为Parent。

开工fresh读取main/Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文/Blob、`docs/workflow/CURRENT_WORKFLOW.md` Blob `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、AC01–11、15场景及现有composer.json/lock。签发前main `ef8ceed1a61af4c8d5b0ea1c2440fce4efa37d62`，Root `9aa5b279d1178a81323ecdd84a6b1a26ca6ddc2f`，正式接受产品只到v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。新main文档提交不会改产品双Tree。

当前composer.json Git Blob `d30ee1bb2af2bafb0416fa07b6005d53d6ab4f56`：Laravel`^12.0`、PHP`~8.5.12`、Sanctum`^4.0`、Tinker`^2.9`、Workerman`^5.1`、lunar-php`^1.4`等；旧composer.lock Git Blob `66327f584d3961c2b53391bb012047dda9cc9d23`仍锁Laravel11.48.0。无Laravel12/13真实vendor或业务runtime证据，不可只改锁状态。

永久状态：`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`；AC01–11仍10 PARTIAL/1 OPEN。历史`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`永久保留。

## 2. 一次性工具链选择（不要随意升级宿主）

**优先路线：当前已安装、只读确认可用的WSL2 Linux发行版和OCI容器引擎**（Docker/Podman已合法存在时）。先执行最多6项只读环境inventory：`wsl --list --verbose`、`wsl --version`、已有OCI引擎版本/daemon只读状态、当前Linux distro release和架构、磁盘/内存/虚拟化资格与可用文件根。不要执行`wsl --install`、`wsl --update`、启用Windows功能、安装Docker Desktop/Hyper-V或修改宿主注册表/服务；若无合格Linux执行器，**只提交一次集中`LINUX_EXECUTOR_INSTALL_AUTHORIZATION_REQUIRED`环境与许可清单并STOP动态部分**，可继续与系统无关的静态迁移预包，不得把Windows原生兼容研究作为自动后备路线。

优先采用**Ubuntu 24.04 LTS兼容的隔离Linux环境**，与已知Ubuntu生产OS代际一致，**任务私有容器/用户层**，避免宿主OS系统包大升级。需要已安装合格容器引擎；使用有版本和摘要绑定的可信官方/发行者PHP、Composer、MariaDB、Redis（仅场景必要时）镜像，固定amd64/平台、镜像Digest、供应来源、容器UID、最小权限、回环端口、专属volume/网络、只读代码输入/独立可写目录，禁止`--privileged`、host网络、Docker socket注入容器、其他宿主目录/已有容器/生产DB挂载。不得无授权拉起已有项目的共享镜像/清理全局cache。允许在**本任务独立容器内**安装经过来源Hash验证的PHP扩展与Composer包；不允许`apt upgrade`现有Linux宿主或写宿主全局PHP/Composer路径。

目标PHP：Linux官方PHP **8.4当前受支持维护patch**，按官方来源及镜像Digest实际冻结；与现有生产PHP8.4代际相符。保留PHP8.5作为**隔离兼容性副剖面**，非本轮必需默认。MariaDB **10.11 LTS**（现有私有环境如可合法使用10.11.19则固定该patch），Redis/Nginx仅按需要一致部署，不能同步升级到未知新版。Composer **官方稳定2.x**，必须验证来源及真实PHAR/镜像身份。Docker/WSL及发行版实际安装状态未知，未验证前不得称“已具备执行器”。

Framework：**Laravel13＋PHP8.4为优先的长期候选（待Owner最终接受），Laravel12＋PHP8.4为同任务明确的兼容回退**；现有Laravel12/PHP8.5约束是历史源码迁移准备，不是完整runtime已接受。第一轮真实依赖求解先试Laravel13组合，依官方13.x升级指南审计Tinker/PHPUnit/Collision、Sanctum、Workerman、lunar-php与所有transitives；若不可消除的包/业务兼容阻断，再在**同一个任务root和预算内**回退Laravel12/PHP8.4，记录原因，不混合两个框架版本的vendor或lock。任何成功Laravel13只是一份**非生产待验收候选**，不自动改变冻结Owner产品基线或线上Laravel版本；Astra审查后由Owner决定是否正式选择Laravel13作为长期基线。禁止先凭版本字符串宣布Laravel13兼容。

## 3. Codex一次批量迁移的具体交付合同

A. **工具链冻结、合法来源：** 统一形成`docs/versions/v10.1.5/`本任务专有`LINUX_DEV_TOOLCHAIN_LOCK`，包含实际Ubuntu/容器引擎版本、PHP镜像Digest+模块及扩展、Composer2、MariaDB/Redis、可信包源、环境隔离/资源容量、版本兼容矩阵；分别记录`AVAILABLE / BLOCKED / NOT_RUN`。所有有代价pull、build、vendor安装和启动在ledger PREPARE+fsync后执行；不得重复上轮Windows API-set/Catalog/VC来源调查。已有Linux无法满足，产出可供Owner一次性批准的**具体安装包、权限、许可证、变更/备份/回退/资源预算**，不要自行安装。

B. **真实Composer两段闭包：** 将`services/backend-laravel`必要代码按固定Git Parent只读导入新任务根；在新PHP Linux平台内执行真实`composer validate`、真实solver和生产/开发依赖求解、安装私有vendor，禁止scripts/plugins（尤其自动artisan、迁移及新未知插件），不要动global Composer cache。一次更新相关composer.json约束，确保PHP8.4兼容并按真实结果生成Composer.lock、content-hash和完整分发来源。Laravel13路径若失败则保留失败并同预算选择Laravel12；不允许人工构造lock、忽略platform req、虚构扩展或把旧11锁当12/13。

C. **批量源码迁移：** 不按单个API-set/DLL微任务试错；统一处理Laravel框架升级破坏面（Service Provider/bootstrap/config、路由/授权中间件、Sanctum/token与Session、队列与Redis、Eloquent/Factory、通知/私有存储、时区和日期/事务、Workerman及测试框架）并实现必要原业务不变性负例。保留F1消息同键重试/异payload冲突、CN/MC/Block撤权、旧Token拒绝、F3可信T0、F4通知最小披露、私有媒体权限与所有历史安全前置；Laravel13的可能Session序列化、缓存前缀、依赖签名变化须按真实升级指南和本项目实际代码差异检查，**不要默认改变用户会话序列化而使旧会话失效**。Flutter源码本轮默认不改，不运行Flutter新配额。

D. **真实测试：** 在完全隔离的新空数据库和虚构账号/fixture执行`php -v/-m`、`composer validate`、PHP lint、Laravel Feature/Unit与真实HTTP→Laravel→MariaDB回环API，验证空库迁移/seed、重启后持久数据、消息幂等、MC/CN/Block、T0/refresh、通知隐私、私有附件与必要错误码；无合规H264文件时视频206标NOT_RUN。以实际PHP和数据库退出状态/行数/HTTP响应证明软件恢复；Mock/纯Python契约不得冒充真实API/DB。Flutter设备、RTC/AEC/真实Push、物理15/30天和APP→API→DB真实设备贯通仍不在本次授权。

## 4. 一次性新预算、隔离和禁止事项

唯一新task_id `V1015_LINUX_TOOLCHAIN_BATCH_MIGRATION_20261030`、attempt-0001、唯一全新task-owned root与持久ledger；logical及allocated各≤**16GiB**；总单调窗口≤**240分钟**。新可信镜像/依赖网络响应体≤**2GiB**、请求≤**500**（含镜像分层、Composer/元数据、失败/重定向）；官方OCI镜像拉取≤**8个具名Digest**，Docker build≤**3**、Composer实际求解≤**3次**（优先Laravel13，必要时Laravel12回退）、vendor install≤**2次**、独立容器服务完整启动≤**4组**、PHP CLI进程总≤**120**、PHP Feature/Unit≤**5批**、HTTP业务请求≤**240**、迁移≤**2**（分离版本试验）、合成seed≤**2**，任何失败/超时消耗预算；不能建新root或跨会话退款。最大占用容器内存建议≤4GiB/服务组且只使用用户已可用资源；若实际机器资源不足STOP，不偷偷改全局WSL VM资源配置。

只允许回环/任务专属端口（从未占用区选择并在task启动时一次性固定记录），**禁止触碰历史固定43349/43359或任何已占用端口/实例**。数据库volume仅任务新目录、空库、最小权限actor和合成账号，严禁已有业务库/生产/真实用户数据、迁移旧实例/删除旧DB。不能挂载或清理现有Docker镜像缓存、旧worktree/DB、备份、SDK或同机其他项目。令牌、原始PHP/Composer/vendor、DB/日志、路径/账户与镜像凭据均LOCAL_ONLY，公开仅脱敏报告/Manifest/必要源码/lock与非敏感Digest。

禁止：自动启用/安装Windows WSL/Hyper-V/Docker Desktop/VC、Linux宿主全局apt升级或安全策略修改、UAC、注册表、System32/WinSxS/ACL/PATH/php.ini全局改动；生产服务器SSH写入、真实第三方账号/费用/公网API；Flutter/Gradle/G2/APK/ADB/真机/RTC/AEC/真实Push；任意旧证据清理和历史预算重置。既有Windows PHP阻断不被Linux PASS覆盖，旧证据永久不变。

历史旧18、两ACL实验树、122原证、五保护根、527refs、3183 Seed及所有历史账本/dirty/claims保持不变，保留四项旧事故状态。若无Linux执行器，或依赖来源/镜像权限/Composer关键包冲突不合格，做**本任务范围内一轮集中静态迁移预包和明确阻断报告**，不退回Window DLL逐项查错。

## 5. 唯一候选、结果与STOP

只在普通非force分支提交**一个sole Parent=`8941323808ce0cdfc68b9f0c3796f86400a75d43`的研发候选**；允许修改`services/backend-laravel/`实际Laravel13/12需要的composer.json/lock、后端源码/测试及`tools/v1015/`新增Linux profile/build/runner与本轮文档，禁止产品main自动merge。必须提交报告和Manifest：
`docs/versions/v10.1.5/LINUX_UNIFIED_TOOLCHAIN_BATCH_MIGRATION_RESULT_20261030.md`
`docs/versions/v10.1.5/linux_unified_toolchain_batch_migration_manifest_20261030.json`。
报告明确：已核工具链/官方来源与版本锁、primary或fallback决策/原因、Composer真实锁和vendor证据、批量源码修复、PHP lint/Feature、HTTP/API/独立DB持久回读、失败与预算账本、历史保护、哪些是`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN / NOT_PROVEN`。不要求为了填报告而重复全部历史OS/VC审查；候选若仅prepackage就如实`BLOCKED_LINUX_EXECUTOR_NOT_AVAILABLE`。

最高分类`LINUX_LARAVEL13_OR12_SYNTHETIC_API_DB_CANDIDATE_AWAITING_ASTRA_REVIEW`，不签`V10.1.5_FUNCTION_ACCEPTED`或真实APP设备E2E。候选发布后fresh GitHub回读Commit、sole Parent、Root、全部变更path/mode/Blob、完整apps/services Tree及最新main；**STOP等待Astra独立验收及Owner对Laravel13正式取舍**。不关闭AC05、不放行G2、不启动v10.1.6。任务发布不等于Owner派发或Codex执行。

## 6. 本轮已核官方资料

- Laravel13发布与支持：https://laravel.com/framework/docs/releases
- Laravel13升级：https://laravel.com/framework/docs/13.x/upgrade
- Laravel13部署PHP要求：https://laravel.com/framework/docs/deployment
- PHP支持：https://www.php.net/supported-versions.php/
- Composer官方：https://getcomposer.org/download/
- WSL查看已安装分发：https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- Docker Windows资格及许可：https://docs.docker.com/desktop/setup/install/windows-install/
- Ubuntu24.04 LTS：https://documentation.ubuntu.com/release-notes/24.04/
