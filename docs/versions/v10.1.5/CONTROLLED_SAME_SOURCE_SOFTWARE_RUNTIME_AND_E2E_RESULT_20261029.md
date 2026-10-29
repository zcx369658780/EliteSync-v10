# v10.1.5 同源受控软件运行交付｜2026-10-29

**V10.1.5_CONTROLLED_RUNTIME_PARTIAL_WITH_EXPLICIT_GATES / AWAITING_ASTRA_INDEPENDENT_REVIEW**。

本轮真实结果：阶段A必需的原生映像观察前置检查被现有守卫拒绝，PHP没有启动，B按前提关闭。阶段C独立完成新私有环境资格、Runner真实正反行为和受影响Widget；首次11项9通过2失败，修复测试查找器后11/11通过。仅改1份测试源码，生产消息实现不改。不是SAME_SOURCE_APP_API_DB_E2E_PASS，`e2e_pass=false`。

## Authority、固定源码与证据等级

Fresh main `40657361e78e12ae0095183106159941c49ab573`，Root `3c54e2f19578557cb1b55693d037ea20fe516c52`，ACTIVE_STATE `f1ff64cc3f3bc68c18598dac24d2593bfa3691d4`；正式任务全文/Blob `128fa1f7746ee73ee6d52d2d693715b003a4ec13`、CURRENT_WORKFLOW `42ffd18810a3808c7a5852ec57e1daff5da6f9b4`、派发协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`、冻结计划 `7d3466b3be67135dc641cfee7c7faef78937ba03`、AC矩阵 `4d3593925d3676722f59d29c324963842a217eb5` 及Astra ad259审查 `89c1fa6f42f5b1d215532acff69180aa11e902fc` 均本轮直接读回。

sole Parent `ad25903e05ab5c0a4d88fe96c41df7963b565c1c`，Parent Root `1ef1269c72a708155acc9ab1a00985819244bc71`，Parent apps `03ba3602a7dc807bf963264e24f33eed01c231c8` /services `eb47fe58d1167b1795224d4c748fb046042b9c92`。从具名既有本地来源导入1,467个产品/工具文件，逐Parent Git Blob核验，不把Astra分支或dirty根当源码。最终候选apps `8cd9b6df8e744c8fc9d4217412edce31795a318d`（729 Blob），services `eb47fe58d1167b1795224d4c748fb046042b9c92`（722 Blob，完全不变）。apps仅下述测试文件改变。

Authority、源码身份、最终远端回读为DIRECT_GITHUB_OBJECT；本机执行与保护检查为CODEX_REPORTED_LOCAL_TEST；实际路径、SD、DLL细目、原始日志/进程证据和ledger为LOCAL_ONLY_RAW。未启动项为NOT_RUN_GATE_CLOSED，未证明的兼容性、物理时间及APP实物行为为NOT_PROVEN。历史48 Python/14+25 PHP、MariaDB23/152、Flutter77没有重跑或冒充本轮结果。

## A：PHP来源与原生资格，启动前STOP

只读重核8份具名PHP参考PE/Hash，仍缺1项应用私有依赖。已有Microsoft有效签名的同架构工具随附运行库候选确实存在，但没有完成其本轮合法重部署/版本兼容与PHP闭包资格，没有复制、安装、下载或动态加载它。不能说“本机不存在该DLL”，也不能把签名有效升格为PHP运行合格。

先按合同验证R1 `php_native.capture_images` 所需的进程观察能力，目标仅本轮Python控制进程PID，没有启动PHP。原观察器返回 **HARDLINK_REJECTED**。源码 `contracts.local` 对普通映像文件要求链接数1；另外定点读取的标准OS模块元数据为链接数2。原异常没有记录具体被拒映像路径，因此**不把该具名模块断言为唯一实际拒绝路径**。这是真实前置守卫拒绝，不是PHP模块加载失败、Laravel故障或拒绝读取权限的证明。

严格遵守“任何守卫拒绝即STOP本分项”：不对观察器换API重试、不放松hardlink门、不改System32/ACL/安全策略、不用系统DLL或PATH副本凑闭包。PHP探针0/2，PHP CLI0/48。`PHP_NATIVE_GATE_CLOSED / ACTUAL_EXTENSION_LOAD_NOT_RUN / PHP_LARAVEL_BOOTSTRAP_NOT_RUN`。

另保留一个尚未运行的静态接线风险：原PHP probe调用共享assertContext，而该方法要求new_instance_qualified；A先于B的阶段划分不得靠伪造实例资格标志解决。本轮A停止后不修复或运行它；源层观察不等于真实bootstrap故障。

## B：MariaDB/API/HTTP/持久化，前提未满足

MariaDB10.11.19指定43349实例、43359 PHP API、独立空库、迁移、10个合成账号seed、HTTP/DB场景均 **NOT_RUN_GATE_CLOSED_STAGE_A_PREREQUISITE**。没有连接任何旧库，也没有用历史MariaDB回执、SQLite或Mock代替。真实HTTP状态、DB表计数、事务、重启和并发业务结果均未观察，不能填0条记录冒充查询结果。

固定15场景清单保持原Blob，逐项状态在配套evidence JSON；APP人工协议、私有PNG/短视频、物理响应丢失、WS与真实token撤权链没有运行。C的HTTP替身只是Widget输入，不是本轮HTTP预算消费或API/DB成果。

## C：独立私有Flutter资格、失败、修复及复测

全新本任务根中私有复制Flutter3.41.7/Dart3.11.5 SDK18,000文件、Pub23,816文件，总原字节3,656,960,355；逐复制Hash和源身份记录。私有app/SDK resolver图分别170/102包，路径全部回绑定本任务。执行采用私有Dart直接运行flutter_tools入口、--no-pub、禁版本检查/analytics，环境/缓存/临时目录及路径均任务私有。共享SDK/Pub、产品pubspec.lock和旧私有根未写入，没有下载。

Hook原始SHA256 `f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`，既有patched SHA256 `7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc` 原字节匹配；没有改第三方runner启动保护。历史diff锁基于LF文本，而Windows原文件为CRLF，首次准备检查因此exit1。保留原失败与raw Hash；本轮重建的原始→patched统一diff在LF规范表示下精确匹配旧锁，**没有把raw Hash称为匹配**，也没有倒改旧锁/原件。完整差异表示留LOCAL_ONLY。

所有运行批次先flush同一个权威execution ledger；Hook子调用的原有flush审计是从属原始回执，不能独立领取额度。新控制器使用Windows Job及私有子程序守卫，观察存活成员与TCP，未知存活映像/回环外TCP即停止；不修改防火墙。观察不能证明连续全生命周期OS隔离或零漏采，`OS_ENFORCEMENT_NOT_PROVEN`持续。

|本轮批次|真实动作|真实结果|
|---|---|---|
|1|私有Dart Runner行为资格；保守计入3批预算|exit0，19检查；5次私有Dart子调用，10个越界负例在启动前拒绝|
|2|单文件Widget，Parent测试Blob `f7ba9db3f901ae3dc84479a7a90dbd55dcac596d`|exit1，11 executed /9 passed /2 failed /0 skipped|
|3|同文件定点修复后复测，测试Blob `36f3d7a6a260f731df068a3aed2891b51fc2510e`|exit0，11 executed /11 passed /0 failed /0 skipped|

首批Widget两个真实失败均为 `RawTooltip is not a subtype of IconButton`，位于新增两项回归的禁用媒体按钮断言。Flutter3.41 tooltip finder可能选中RawTooltip；原强转尚未到达业务期待。仅在 `apps/flutter_elitesync_module/test/features/chat/presentation/pages/v1015_live_chat_reliability_test.dart` 增加按IconButton类型和tooltip精确匹配的finder并替换3处读取；保留67个expect、10个测试声明（参数化共11个执行用例）、4个isNull和15个tap。没有删除负例、跳过测试、改变预期、改生产逻辑或Hook守卫。非作者Sol/high只读差异复核确认还原这两类改动后全文与baseline相同，没有发现语义削弱。

三项新增消息回归现在均实际通过：暂停/恢复保留同一POST重试；控制器变化不能替换未知结果的原payload/key；未知媒体结果复用同一attachment且不二次上传。其余8项为该文件内受影响有限原用例，没有重跑77项。结果严格 **TEST_PASSED_UNDER_TASK_PRIVATE_PATCHED_RUNNER**，不是标准未补丁Runner或真实APP/API/DB通过。

预算3/3包括资格1批＋Widget2批；Flutter analyze **NOT_RUN_BUDGET_EXHAUSTED**，不以Widget替代analyze。所有批次command/tool/source Hash、exit、stdout/stderr Hash见manifest/evidence，原始stdout及失败保留本地。

准备阶段的普通错误也保留：CRLF diff表示检查exit1；测试修复脚本最初将11个执行用例误作11条声明而exit1，实际为10条声明（含参数化）。修正准备计数后才写入源文件；这没有消费新Flutter批次或修改测试期待。控制器启动前只读复核补齐退出码传播、空间检查、Job观察失败和挂起进程清理，未触发任何未授权运行。

## 预算、保护与限制

唯一task `V1015_CONTROLLED_SAME_SOURCE_RUNTIME_20261029` /attempt-0001，持久ledger从新根创建后沿用，未换根退款。预算：MariaDB0/2；PHP API0/2；HTTP0/160；PHP CLI0/48，其中probe0/2；migration0/1；seed0/1；Flutter3/3。新下载/安装/ACL写入、Gradle/G2/JVM/APK/ADB/设备/RTC/Push全部0。旧Flutter6/6、MariaDB2/2、G/APK各1/1、历史API余额及ACL超额事故均不改。

90分钟窗口从本轮根创建开始，以开机单调计时累计，不暂停重置；生成本报告时已用1651.562秒，最终准确观测与结束时刻封存在本地budget-terminal。logical/native allocated上限各8,589,934,592 bytes，当前约3.8GB；前/中/后离散观测，终态含目录allocated并预留元数据。不能将离散快照称为连续峰值或文件系统MFT/journal总消耗证明。

保护范围如实分层：本轮开工/收尾8个具名根FileId/Volume及旧ledger/receipt Hash一致；18,000 SDK和23,816 Pub源文件的身份/大小/mtime未变，具名关键原字节Hash未变。原dirty43路径和527 refs前后相同。收尾122件固定历史原证Hash/大小/FileId匹配，五历史根HEAD/branch匹配。后两项是固定历史基准的终态回读，**不是本轮重新建立的全量前后SD/索引/未跟踪文件快照**。旧18与3183 Seed无写入，本轮没有重读完整SD或再hash全部Seed，也没有宣称重新验收这些历史门。旧两ACL树、claims和原失败不清理。

## 后续最小Owner决策与STOP

一次集中后续资格建议已形成LOCAL_ONLY `FOLLOWUP_OWNER_AUTHORIZATION_SPEC-LOCAL_ONLY.json`，含候选运行库精确来源/大小/Hash/签名及所需证明。公开摘要：先明确app-private Microsoft运行库的合法来源和兼容性；对原生观察器的**已固定System32 OS映像只读身份**另行冻结可接受的hardlink策略及Hash/签名约束，不能扩展为私有可写文件可hardlink、任意系统DLL加载或全局策略更改；把A无DB探针与B真实实例资格拆成明确的软件合同。当前任务守卫STOP后这些建议**未实施**，也不自行创建后继。若Owner重新授权真实A/B/C，须冻结本候选/依赖、独立次数及窗口；本轮剩余A/B额度和已耗3/3不能自动复用。

AC01–11仍10 PARTIAL/1 OPEN，AC05 RTC OPEN。真实APP操作、Keystore/物理删除、15/30天经过、RTC/AEC、Push均未闭合。保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / V10.1.6_NOT_STARTED`。

只交付一次普通non-force候选；最终Commit/sole Parent/Root/四条变更原字节/完整apps与services Tree及live main由terminal readback核对。main产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` /services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。**完成后STOP等Astra独立验收，不自签FUNCTION_ACCEPTED、不合main、不放行G2、不启动v10.1.6。**
