# EliteSync v10.1.5｜同源PHP–MariaDB–API受控真实验证＋定向Flutter回归｜Owner正式综合任务

**状态：OWNER_APPROVED_CONTROLLED_SOFTWARE_VALIDATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / NEW_BOUNDED_SYNTHETIC_SOFTWARE_RUNTIME_AUTHORIZED_WITH_PRECONDITIONS / NO_APP_APK_DEVICE_G2_GRADLE_RTC_PUSH_AUTHORIZATION / NO_PRODUCT_MAIN_INTEGRATION**

签发：2026-10-29（Asia/Singapore）。Authority仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner的本次决定、目标与范围分层

Owner在Astra独立接受`ad25903e` PHP E2E入口R1源码并建议“结束纯源码纠正，进入受控真实软件验证，先处理缺失的私有PHP原生依赖，再验证同源Laravel API和独立MariaDB，之后开展定向Flutter/APP测试”后明确答复“可以，请继续”。本任务把该同意**一次性冻结为下述A/B/C有硬门的综合软件运行预算**，不表示Astra本次已启动任何程序，亦不代表批准未具名外部下载、系统DLL修改或APP设备构建。

真正目标：在单一受保护新工作面内，验证已完成的R1 PHP扩展/原生闭包能否真实加载和在正确隔离实例中启动Laravel；随后用当前同一产品源码运行部分实际HTTP→真实MariaDB持久化/撤权场景，以及在独立资格成立时运行受影响Flutter Widget回归。需要的普通本版源码/测试脚本缺陷集中修复，**不拆成逐项微任务**。先有合法来源/资格、再真实运行；不因无法启动某分项而把其他独立且获准的工作全改成又一份纯计划。

**本次允许的运行证据上限**：`CONTROLLED_API_DB_RUNTIME_OBSERVED`与`TARGETED_FLUTTER_TEST_OBSERVED`，分别需真实exit/raw/源码绑定和有效负例；没有真实Android APK及APP操作不能升级为`SAME_SOURCE_APP_API_DB_E2E_PASS`；没有物理15/30天、RTC/AEC和真实Push不能关闭原AC。

## 1. 必须fresh核Authority和唯一研发Parent

执行前读live main/Root、`docs/workflow/ACTIVE_STATE.md`、本任务全文与Blob、`docs/workflow/CURRENT_WORKFLOW.md`和`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结`docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、原AC矩阵Blob `4d3593925d3676722f59d29c324963842a217eb5`（其真实位置在固定候选历史，而非main）。

**唯一研发Parent** `ad25903e05ab5c0a4d88fe96c41df7963b565c1c`，Root `1ef1269c72a708155acc9ab1a00985819244bc71`；完整apps `03ba3602a7dc807bf963264e24f33eed01c231c8`；services `eb47fe58d1167b1795224d4c748fb046042b9c92`。Parent为`0d28e89f71c9a4ea15d8fd5fdb33bc7b9fdd0e6f`。最新Astra独立审查报告固定于`astra/v10.1.5-ad25903e-php-e2e-r1-independent-review-20261029:docs/versions/v10.1.5/AD25903E_PHP_E2E_BOOTSTRAP_R1_ASTRA_INDEPENDENT_REVIEW_20261029.md`，Blob `89c1fa6f42f5b1d215532acff69180aa11e902fc`、审查HEAD `9e59f9364a6a879885dfde2fba4bf77cef8ce64d`；**审查分支不是研发Parent**。

源锁与输入：原主线任务Blob `1db7fc7eaadcea172cc52016904836bd71a0b90d`；原`FOLLOWUP_OWNER_AUTHORIZATION_SPEC_20261029.md` Blob `4d468c7f54b35f85fff67e0190f7b97e9ca491e8`仅是建议，上述旧预算直到本新合同才被部分具名授权；新合同取代其中与范围不一致的草案许可，不倒改原文件。R1候选已有`tools/v1015/mainline_e2e/`、`services/backend-laravel/tests/E2E/`、15场景JSON与APP人工观察协议。最初开工main固定快照 `8ac81fb16f2493b957eaf716fc3821f03d037385` / Root `5bfc8dbd90329b719cdcf02404a118d733e8934c`；任务发布后的live HEAD必变，开工重新读取。

**main唯一已接受产品仍v10.1.4**：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services `0cb1f9d19659291a462488b3686fd0a07a6698ac`；v10.1.5仍10 PARTIAL、1 OPEN（AC05 RTC），产品未合main。

## 2. 阶段A｜私有PHP来源封闭与真实资格（可执行但不能绕过前提）

- 只为**本任务**创建一个唯一新task-owned运行根`v1015-mainline-live-<OwnerID>-20261029`（其中OwnerID为不含隐私信息的本地任务标识，具体绝对路径由执行前资格化）；单一持久ledger跨中断及会话保留，旧任务没有迁移/退款，不能用第二根重置计数。新根中复制获授权、已核Hash的源闭包、PHP8.5.3 NTS x64私有exe/扩展/DLL、vendor、可用工具和新数据，原LOCAL_ONLY来源只读；主工作区与旧实验根不做写面。
- 上一R1报告指出**8个具名参考PHP文件仍缺1项私有原生依赖**。先对已具名、可追溯且可合法复用的**现有本地可信安装包或受控私有来源**作定点只读来源/版本/PE-import/Hash比对。若同版本同架构的合法字节确实已在允许读取的来源中存在，且没有跨项目受保护写面，可把**该具名文件的受控副本**写到新task-owned根，并记录src/dst hash、来源、许可和保护前后身份。不准从`System32`、PATH搜索结果、其它项目依赖或无来源DLL复制凑齐；不准修改原始安装目录/系统目录，不准自签未经验证的provenance。**本次下载0次、安装/升级0次、全局环境变量/ACL/防火墙变更0次**。若缺字节或证据不足，标记`PRIVATE_PHP_DEPENDENCY_MISSING / PHP_NATIVE_GATE_CLOSED`，该阶段不得Popen，集中提供精确的`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`（文件用途、来源候选、大小、Hash/签名、最小复制/下载条件），但保留其它已授权且独立可做的工作；不得自动授权下载。
- 对同源R1的`php_requirements.json`、私有Manifest、`php_runtime.py`、`php_native.py`、`PhpRuntimeQualification.php`进行静态配置/hash/路径/ACL保护资格检查；所有PHP extension和依赖必须来自允许的冻结私有闭包，`-n`无全局php.ini，CLI/API共用参数和Manifest，PHP内部函数、实际加载模块、SAPI/ABI、PID/nonce及父原生映像观测一致。任何守卫拒绝即STOP本分项；不能改策略或用另一路旧运行器绕过。
- 仅在上述来源、权限、任务唯一运行root、native路径/子进程/写入闭包、进程观察权限与账本预算均先满足后，才准**在新私有PHP目录实际运行一次有界受控能力探测**，最多2个单独探针PHP进程启动（每次含失败计数，且计入下述48次PHP总操作预算）。探针严禁连接旧DB、生产/云或做隐私处理。真实probe失败保留退出码/stdout/stderr与进程映像；不得报PASS或自动升级/下载修补原位。

## 3. 阶段B｜同源Laravel API＋MariaDB真实合成业务验证（仅A成功后）

**硬冻结实例**：
- 新MariaDB官方10.11.19私有实例，`127.0.0.1:43349`，唯一空库 `elitesync_v1015_mainline_e2e_20261029`，账号 `v1015_e2e@127.0.0.1`，专属datadir/server_id、权限最小化；不连接3306/旧43329/现网。每次DB读写前验证有效`APP_DB_CONNECTION`优先、`DB_CONNECTION`、URL/socket/读写replica、host/port/actor/datadir及只有新库的有效GRANT。禁止全局权限、PUBLIC test权限、GRANT OPTION；若源DB已存在非空或身份不能证明为本版新实例，STOP，不清理/迁移它。
- **MariaDB独立服务启动最多2次**（包括初始化/bootstrap失败与重试，每次预先持久记账）；**PHP回环API服务启动最多2次**，固定`127.0.0.1:43359`。不得自动重启，端口被占/监听身份不符/检测到非本任务进程立即停此项。真实PHP CLI探针/fixtures/观察/迁移的进程启动**总计最多48次**（包括失败及阶段A最多2次探针），HTTP请求操作总计**160次**（包括错误、409及未获响应的请求）；库迁移**最多1次**，合成seed事务**最多1次**，使用10个虚构普通账号/5组独立关系，不伪装实人认证、不假造正式关系。若驱动自身发现重复attempt/ledger冲突、非当前源或退出码不符，STOP并保留。
- 软件运行新根logical与native allocated各≤**8GiB=8589934592 bytes**；执行窗口最多**90分钟**（真实开始时刻/消耗单调记录；不能以暂停或新工作根重置）；新运行根安全本地磁盘预算与原证保护核验，不允许删旧SQL/APK/日志/证据腾空间。新root内临时缓存/新库可以按本任务恢复协议处理，但不能批量`clean/prune/reset`。
- 真正执行`tools/v1015/mainline_e2e/run.py`受控`execute`（在真实新授权Context通过后）；真实`services/backend-laravel/tests/E2E/server.php`和`bridge.php`必须先通过被Astra有界审过的testing-only资格，不更改生产`public/index.php`或CN/MC/Block/Token服务端授权。实际HTTP认证/refresh T0不续期、消息同键/异payload 409、持久DB消息/通知/附件唯一性、Block/MC/CN/禁用后旧token/媒体/通知拒绝、偏好和最小披露逐项附原始状态、时序、DB计数和真实错误/exit；任务内可修复有证据支持的受影响F1/F3/F4代码及测试工具普通问题，整批完成，不因一个ordinary failure开新任务。负例不通过不得改测试期待制造PASS。
- `PNG`仅task-owned合成一像素样本，短视频需额外已核合法来源且≤128KiB的合成H.264 MP4及Hash；无合规源、编解码器未资格化时短视频分项保留`NOT_RUN`，不得伪造200/206或`ready`。HTTP驱动模拟ACK丢失不当作物理丢包，API/DB成功不冒充APP实际点击/WS真实连通，最终E2E总状态仍`e2e_pass=false`直到Astra按冻结AC另作实物裁决。

## 4. 阶段C｜定向Flutter纯软件Widget（条件独立，不构建APP）

- 在同一综合任务内，仅当**全新独立私有Flutter3.41.7/Dart3.11.5 SDK/Pub闭包**、历史LOCAL_ONLY Hook原字节/补丁资格、原64位Hash、task-owned patched runner、Windows子进程/路径与写入边界均已按新任务自己验证，允许真实Flutter test/analyze**合计最多3批**（包含失败、crash和重复）。仅运行上轮新增3个消息可靠性Widget回归及实际受影响的少量原用例，不重新运行所有77项制造进度。不得写共享SDK/Pub、升级/下载、跳过Hook安全守卫或改系统shell策略。
- A阶段因私有PHP依赖STOP，不自动取消C阶段**独立**可验证的资格；但C不因A获授权自动越过自己的先决条件。若新私有SDK闭包超过本任务8GiB或本机来源不合格，C直接`NOT_RUN_GATE_CLOSED`；不要新建不受控镜像/变更上限。原Flutter6/6历史账本持续耗尽，不作为本批权限。
- **不授权**Android构建/Gradle/G2、APK/签名/安装、ADB/AVD/真机、网络媒体RTC/Push/Keystore实际设备、长达15/30天物理观察。APP端仍是人工观察协议及明确的后续独立Owner许可，不用Widget模拟代替。

## 5. 全阶段共用执行约束、保护和失败处理

- 同一个`task_id`、`attempt-0001`与持久执行ledger，所有可能消耗次数的真实Popen/HTTP/数据库操作之前write+flush PREPARE，执行后写exit/stdout/stderr SHA256、来源及环境身份；失败也消耗次数，崩溃/未知状态保守记消耗。不中途重建root/ledger、以新进程/单个子任务伪装重置。开始/结束具名保护根身份核对，避免触碰旧18件、两ACL实验树、122原证、五根、527 refs、3183 Seed、旧原失败/claims/SQL/APK/ledger和保护dirty工作区。若未获批准的native child/写入、网络回环外连接、ACL/系统策略变化或真正不可逆风险出现，STOP风险项，不破坏原证，其它独立合法模块可继续。
- 仅本地可信已有来源，**无额外下载/升级/安装/系统改动**；历史工作树不得`pull/reset/rebase/stash/clean/prune/force`，不得修改旧云/生产、真实个人数据/密钥/真实用户/Push供应商，不接公开端口。新合成DB、敏感原始HTTP凭据、DB快照、设备痕迹及本地环境详细绝对路径一律`LOCAL_ONLY_RAW`，不可上传GitHub/Project。公开只可提交脱敏的功能源码、少量报告、路径/Blob/Hash、失败/预算摘要和不泄漏私密字节的测试回执。
- `PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`及`OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN`永久封存，不退款重试。旧Flutter6/6、MariaDB2/2、Gradle G1/1、APK1/1耗尽，旧API1/2未用余额不是本任务授权；**本合同是全新独立次数预算，不倒改过去**。未具名旧G2条件余额仍`G2_READY_FOR_POPEN_FALSE`。
- 可用的正常错误在任务范围内自主集中修复/有限重测；如果真实资格/安全门不能成立，报告源缺口、已消耗预算、受阻范围、最小`FOLLOWUP_OWNER_AUTHORIZATION_SPEC`，不要把环境失败说成产品功能缺失，不要因R1静态验收完成就自动签到运行PASS。

## 6. 集中交付与STOP

- 推荐统一交付`docs/versions/v10.1.5/CONTROLLED_SAME_SOURCE_SOFTWARE_RUNTIME_AND_E2E_RESULT_20261029.md`、`controlled_same_source_runtime_e2e_manifest_20261029.json`和必要受影响源码/测试工具/合成fixture/自动化入口（只有实际必要才改）。一个非force候选提交、**sole Parent必须为`ad25903e05ab5c0a4d88fe96c41df7963b565c1c`**；Astra审查分支和main都不能当研发Parent。
- 报告清楚区分A私有PHP来源/实际模块与native握手、B真实MariaDB/API/HTTP/DB、C Flutter Widget、D未来APP/RTC/Push门；所有真实执行次数/exit、未运行部分、数据库表计数、exact source_binding和精确受保护检查。原48 Python/14＋25 PHP是历史`CODEX_REPORTED_LOCAL_TEST`，不得冒称本轮已重新运行。固定原15 E2E场景与AC01–11映射；逐项`DIRECT_GITHUB_OBJECT / CODEX_REPORTED_LOCAL_TEST / LOCAL_ONLY_RAW / NOT_RUN_GATE_CLOSED / NOT_PROVEN`。
- GitHub按路径回读候选Commit、sole Parent、Root、全部变更path/mode/Blob、完整apps/services Tree及main仍v10.1.4。Codex不能自签整版`FUNCTION_ACCEPTED`、合main、关闭AC05、以同源API/DB冒充APP端到端、放行G2/Gradle/APK/设备或自动启动v10.1.6。
- 成功的上限为`V10.1.5_CONTROLLED_API_DB_AND_TARGETED_WIDGET_EVIDENCE_DELIVERED_AWAITING_ASTRA_REVIEW`；有界STOP则`V10.1.5_CONTROLLED_RUNTIME_PARTIAL_WITH_EXPLICIT_GATES`。**无论哪种终态均STOP等待Astra独立验收**。保持`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / V10.1.6_NOT_STARTED`。

**Owner手动派发本文件全文后Codex才可在上述新预算内执行；GitHub发布/文档签发不是后台运行，也不等于已消耗任何新尝试。**
