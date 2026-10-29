# v10.1.5 Hook原始SHA-256权威勘误及非生产锁定修复

状态：**ERRATUM_PUBLISHED / LOCK_FIELD_CORRECTED / PURE_TEST_PASS / PATCH_INPUT_NOT_QUALIFIED / PREPARE_NOT_RUN / EXECUTE_NOT_RUN**。
本轮完成后来Owner授权的单字段锁更正、相关说明和42项Python纯逻辑检查。没有真实准备SDK或运行Flutter/Dart/数据库/API。交付上限是 **V10.1.5_HOOK_HASH_ERRATUM_LOCK_CORRECTED_AWAITING_ASTRA_REVIEW**，不表示真实补丁/Runner资格或整版功能接受。

## 1. Fresh Authority及唯一候选来源

正式任务 `a0eec472b58d53bc25084a395efc0748779d73f8`：`V10_1_5_HOOK_SOURCE_SHA256_AUTHORITY_ERRATUM_AND_NONPRODUCTION_LOCK_CORRECTION_TASK_20261029.md`，已在GitHub按路径fresh读取全文和准确Blob。开工main `7b33f685df3704a384a3cf1f34c3f810e741aeac`，Root `fc5ef9921d954ac4cd0ffc75cf698efe5a1318ed`，ACTIVE_STATE `5d86c737194c7cc07521b690465a6a24f8eb645f`；协议 `0f62532a71fb9753811fafa9e03819a46422f4bf`。main产品仍v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

唯一研发Parent `fd85ac2546afab61aaf51cdfac796cfb9bed31ac` / Root `2aee0011e6279a44bdf71063edd659cb58a718b7`，来自Astra有界接受的非生产工具交付。Astra本轮前置审查 Blob `fefc0efb9c826e8136dfdf94f2fef08d4e1b8fc8`、fd85原报告 `c736354f6d9f574fdce9fd5a908a70c46eea1ed0` 与Manifest `6a24e9fc084f58ba94499fca4199f5976e444cfa`均直接读取。候选apps保持 `798049a15eb33fec16acdd37d83a07af0ed181b5`（729 Blob），services保持 `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 Blob）。不采用审查分支为Parent，不将候选产品合main。

## 2. 只覆盖一个规范Hash字段

历史错误原合同 Blob `0854b37fdc9f11c55088ed2d2f93816a27bc2fa9` 与fd85锁 Blob `130b9fe79d326ae701bc0fad27096e6413508a6d`的原值：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`（62位）。该值仍被拒绝，原合同/报告/Matrix/Manifest/Astra裁决均不修改。

新Owner勘误规范参考：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`（64位）。来源直接交叉核对：

| Git证据 | 字段/含义 |
|---|---|
| `657deb5e748a7d0d216b5b1c589ed3b86254734f` | 5aa3索引 `privateRunner.beforeSha256` |
| `715bc340042675df86a0c791c49eb1852bb9b5ce` | Astra前轮Widget审查原source Hash |
| `130b9fe79d326ae701bc0fad27096e6413508a6d` | fd85 `accepted_reference_original_sha256` |
| `a0eec472b58d53bc25084a395efc0748779d73f8` | 后发布Owner单字段勘误执行合同 |

`SUPERSEDED_BY_OWNER_ERRATUM_FOR_HOOK_SOURCE_SHA256_ONLY`：此次只是后来显式纠错，不能将历史62位合同伪装成从来无误。locks只更改 `hook_original_sha256`；**键集合及所有其它值完全相同**，包括旧 `contract_blob`、source Parent、apps Tree、Flutter3.41.7/framework、Dart3.11.5、Hook1.0.1、目标Hash、canonical LF diff/历史CRLF raw Hash、所有程序Hash、closed任务列表及当前0/未来6批上限。后来勘误的Blob在说明/回执中单列，没有改写原合同身份。

## 3. 实际改动及检查

六个非生产文件变更：locks的一个字段；test_entry保留38个原函数并新增4个；entry默认inspect增加锁格式成功/输入未资格化/无运行授权的分层输出；README明确新勘误和仍关闭的门；config及receipt模板移除“当前62位格式阻断”的过时说明。`core.py`、`runtime.py`原字节不变；生产apps/services、pubspec.lock、SDK、共享Pub、原测试断言与冻结AC不修改。

最终Python3.11纯逻辑回归：**42 executed / 42 passed / 0 failures / 0 errors / 0 skipped，exit0**。38原测试函数名全保留，36方法AST逐项相同；另2项只按本次勘误改为“正确64位可静态接受＋历史62位仍拒绝”，默认inspect继续无写入/无子进程。新增4项：历史错误锁的inspect拒绝回执、缺私有patch在创建目标前拒绝、0运行预算拒绝、合法Hash格式不能把任意合成源判为已资格化。

保留原有链接/路径/UNC/重复prepare/损坏ledger/复制根/旧任务/过期grant/无授权execute/缺runtime proof/shell和参数注入/不确定启动不退款等负例。自检中Popen及socket使用拒绝真实调用的类兼容替身；system/startfile拒绝；所有模拟exe都是惯性字节，正向execute只用注入fake，合成临时文件限本任务。测试调用prepare/execute的**纯合成函数路径**不等于真正SDK准备或Windows执行。

原始失败全部保留LOCAL_ONLY：第一次Python辅助脚本在源码修改/测试前因event参数重名退出1（0测试）；随后首个42项检查因网络拒绝替身把socket类替为函数，破坏ssl/Mock标准库导入，**21通过/21错误，exit1**。修复的仅本任务辅助环境，类兼容拒绝替身继续拒绝真实网络/进程，最终42/42通过。没有删测试、降低守卫、抹去错误或重置运行预算。最初空间代理读数不当作allocated终值，最后使用本任务文件的原生AllocationSize重新计量；未改原工具的空间实现。

## 4. 尚未证明的输入和运行资格

本轮只核Git证据和纯合成字符串/文件，**没有读取或重新hash历史LOCAL_ONLY Hook/patch原字节**，也没有重新内存复现历史patch：`SOURCE_BYTES_NOT_VERIFIED_THIS_TASK / PATCH_INPUT_NOT_QUALIFIED`。fd85内存参考复现属于前轮证据，不能冒充本轮重新验证。私有补丁不在仓库中；本轮未将其提供给入口，不推断本机历史原件已经丢失。若后续调用者缺少可信原件，应 `PRIVATE_PATCH_SOURCE_NOT_AVAILABLE`；指定不存在路径会 `INPUT_MISSING` fail-closed。

Hash格式校正不意味着 `SOURCE_AND_PATCH_INPUT_QUALIFIED`、`PREPARED`、`RUNNER_READY` 或 `FLUTTER_STANDARD_RUNNER_VALIDATED`。只有以后获准核对真实源、canonical LF diff、目标Hash、完整私有依赖和守卫后，才能分别判资格；仍需新的明确Owner运行授权/预算。当前 `RUNTIME_NOT_AUTHORIZED / EXECUTE_DISABLED / PREPARE_NOT_RUN / EXECUTE_NOT_RUN`。

真实Windows Job与子进程采样/第三方Hook参数白名单未在本轮资格化；独立hook_arguments函数不是真实子进程拦截器，JSON授权不是密码学Owner身份或恶意代码容器。既有MariaDB23 Feature/152断言、私有补丁Runner11文件77/77 Widget仅为前轮有界接受事实，没有本轮重跑，也不据此关闭任何AC。

## 5. 预算、证据等级与保护

唯一task `V1015_HOOK_HASH_AUTHORITY_ERRATUM_20261029` / attempt-0001，新task-owned工作根和持久execution_ledger。关键写入先PREPARE/flush，tracked文件每次前后Hash及写后回读完整；辅助初建按一个具名预登记批次并在完成后逐文件登记Hash。Python每次启动前记录脚本/程序Hash和实际exit/log Hash。失败不删，跨会话同根不重新计数。

新增logical/allocated各≤268435456 bytes；新文件不足数MiB，精确观测和终态metadata预留见同根budget-terminal。allocated使用FileStandardInfo.AllocationSize，只有task-owned文件。离散快照不是连续峰值证明。

本轮真实Flutter/Dart/analyze/test、MariaDB/PHP API启动/连接、SDK复制/下载、G2/claim、Gradle/JVM、APK/ADB、设备/RTC/Push/生产云服务均 **0**。旧Flutter6/6、MariaDB2/2耗尽，API历史1/2余额不是许可；旧APK/G各1/1耗尽、旧A关闭。旧18、两ACL树、122原证、五根、527refs、Seed3183、失败/claims/账本/dirty根均no-touch；不复做其ACL/身份扫描，不以no-touch声称OS安全恢复。

DIRECT_GITHUB_OBJECT：本轮Authority、源锁/索引/Astra正文及候选最终回读；CODEX_REPORTED_LOCAL_TEST：本轮42纯自检及此前明确分层的运行摘要；LOCAL_ONLY_RAW：原运行日志、账本、私有路径和失败；NOT_RUN/NOT_PROVEN：真实输入重验、准备/运行及所有设备/OS/服务行为。原始日志、路径、凭据、Windows私密信息或第三方完整补丁不上传。

## 6. 交付与STOP

普通non-force候选以固定fd85为唯一Parent，仅6个非生产文件与本报告/Manifest，共8条变更。Manifest列每项Parent/final Blob、mode、原/目标Hash、检查回执及固定来源；Manifest自身最终Blob由独立回读回执解决，避免自引用Hash。候选发布后回读Commit/sole Parent/Root/全部变更原字节与完整产品Tree，fresh核main未集成；最终Commit/Root身份在交付回执中提供。

保持 `V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / V10.1.6_NOT_STARTED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN`。

**一次集中候选后STOP等待Astra独立验收；不合main、不关闭AC05、不启动真实工具、不派发后继。**
