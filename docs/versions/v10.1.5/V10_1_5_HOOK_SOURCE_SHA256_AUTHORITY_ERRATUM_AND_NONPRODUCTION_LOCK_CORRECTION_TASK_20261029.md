# EliteSync v10.1.5｜Hook 原始SHA-256权威勘误与非生产Flutter工具锁定修复｜Owner正式任务

**状态：OWNER_APPROVED_ZERO_RUNTIME_AUTHORITY_ERRATUM / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / AUTHORITATIVE_CORRECTION_FOR_ONE_HASH_FIELD_ONLY / PURE_LOGIC_TESTS_ALLOWED / PREPARE_EXECUTE_RUNTIME_NOT_AUTHORIZED / NO_PRODUCT_MAIN_INTEGRATION**

日期：2026-10-29（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。

## 0. Owner决策与唯一精确勘误

Owner在接收Astra对`fd85ac25`的独立裁决后，明确回复“可以我同意，请继续”，批准建议中的**一次零真实Flutter/数据库/设备启动的权威Hook原Hash勘误、工具锁定字段集中修复与独立复核**。本任务是对已定位合同数据错误的**明确纠错授权**；不是软件性能/功能重新开发、源工具链的实际运行放行、AC功能接受、旧预算退款或新版本启动。

**错误的历史原文/字段（62个十六进制字符，不是合法SHA-256值）：**

- 旧正式任务 `docs/versions/v10.1.5/V10_1_5_REPRODUCIBLE_FLUTTER_TEST_ENTRY_AND_AC_GAP_CLOSURE_TASK_20261029.md` Git Blob **`0854b37fdc9f11c55088ed2d2f93816a27bc2fa9`** 在“受控输入”段写的`hooks_runner 1.0.1`原source SHA-256：
  `f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`（**62位，REJECTED_HISTORICAL_CONTRACT_VALUE**）。
- `fd85ac2546afab61aaf51cdfac796cfb9bed31ac:tools/v1015/flutter_widget_test_entry/locks.json` Blob **`130b9fe79d326ae701bc0fad27096e6413508a6d`** 中的`hook_original_sha256`继承该62位错误，原工具如实`CONTRACT_SOURCE_HASH_MALFORMED / PATCH_REPRODUCTION_BLOCKED`。

**已核实的正确参考值（64个十六进制字符，仅适用于同一原文件版本及相同原字节）：**

`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`

Astra已直接核对该值同时出现在前轮`5aa3fc63`索引 `docs/versions/v10.1.5/flutter_windows_hook_safe_widget_evidence_index_20261029.json` Blob **`657deb5e748a7d0d216b5b1c589ed3b86254734f`** 的`privateRunner.beforeSha256`、Astra前轮报告 Blob **`715bc340042675df86a0c791c49eb1852bb9b5ce`**，以及`fd85`工具锁的`accepted_reference_original_sha256`。此64位值是**待验证输入的规范参考Hash**，**不**代表Astra亲自重新hash了用户LOCAL_ONLY原文件。

**本新正式任务作为后发布Owner勘误合同，仅覆盖前述旧任务的那一个原Hook source SHA-256字段**；旧正式任务、旧`fd85`报告/Manifest、Astra审查与错误证据必须原样保留。不得原地改写旧任务或其Git Blob以抹除历史。旧任务其他冻结安全/功能边界全部继续有效；本任务范围更窄时以本任务约束为准。

此勘误**授权在新候选中修复正确的锁定字段及相关自检、使用说明/脱敏记录**，但不将已失效的历史权威伪装成初始无错合同；只能写明`SUPERSEDED_BY_OWNER_ERRATUM_FOR_HOOK_SOURCE_SHA256_ONLY`，通过本任务新Blob提供可追溯依据。修正后不能仅凭Hash长度匹配称补丁已可运行；必须有真LOCAL_ONLY源文件/正确canonical LF diff且符合全部Hash链才能说`SOURCE_AND_PATCH_INPUT_QUALIFIED`，本轮**不做真实prepare**。

## 1. Fresh Authority、固定Parent与禁止继承

Codex执行前fresh GitHub读live main/Root、`docs/workflow/ACTIVE_STATE.md`、本任务完整正文和实际Git Blob、`docs/workflow/TASK_DISPATCH_CLOSURE_PROTOCOL.md` Blob `0f62532a71fb9753811fafa9e03819a46422f4bf`、旧任务/报告/两份Astra裁决及锁定源码：

- 本任务发布前main `bbac0d177fa1db5962bf2f08325731fa4bbfb72d`、Root `a53db9f1da1a6a5503079df416eaf92e2a5df6f9`，只是签发时点；必须用开工时live main重新核定其产品双Tree。
- 本轮唯一普通non-force研发候选Parent **`fd85ac2546afab61aaf51cdfac796cfb9bed31ac`**，Root **`2aee0011e6279a44bdf71063edd659cb58a718b7`**；候选apps `798049a15eb33fec16acdd37d83a07af0ed181b5`（729 Blob）、services `9bba2938aa41ad3eaee501ef88bfeecdee797591`（716 Blob），不得把审查分支当研发Parent。**不合main**，主线已接受产品保持v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 最新Astra审查 `astra/v10.1.5-fd85ac25-tooling-ac-gap-independent-review-20261029:docs/versions/v10.1.5/FD85AC25_REPRODUCIBLE_FLUTTER_ENTRY_AND_AC_GAP_ASTRA_REVIEW_20261029.md`，Blob **`fefc0efb9c826e8136dfdf94f2fef08d4e1b8fc8`**，审查HEAD `4b6af5ff39344bce2f962c0ec023ff96991b63e0`。
- `fd85`综合报告 Blob `c736354f6d9f574fdce9fd5a908a70c46eea1ed0`，工具Manifest Blob `6a24e9fc084f58ba94499fca4199f5976e444cfa`；冻结 `docs/versions/v10.1.5/plan.md` Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`、AC11矩阵Blob `4d3593925d3676722f59d29c324963842a217eb5`。原F1消息/F2 RTC/F3离线/F4通知/F5旧资产编号不能改。
- 历史ACL事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`按Owner封存；旧18件、两ACL实验根、122原证、五根、527refs、3183 Seed、旧失败、原账本、原dirty工作树不可写、移动、删减、复做检查或退款。旧APK/G各1/1耗尽、旧A关闭、G2条件历史余额无本任务运行授权。

## 2. 唯一实现范围：锁定值更正＋安全纯逻辑回归

仅允许在`fd85`衍生的**全新task-owned私有源码工作面**中修改：

1. `tools/v1015/flutter_widget_test_entry/locks.json`：将唯一规范运行输入`hook_original_sha256`从62位错误改为本合同正确**64位**；保留`accepted_reference_original_sha256`原64位以及`hook_target_sha256=7d04fa44ccd94549ea2011997d3b1053ae6e72716e9b9fc0cc4d7c7e202244bc`、`patch_diff_sha256=9d7f7883e34bbe451d364b89b03d4acab6c30d00d1f4d9081f562708b6e7f119`、历史CRLF原diff Hash、原source apps Tree/Flutter/Dart/hook版本、旧闭合task IDs、全部脚本守卫及未来批次安全上限。可增加独立明确的历史错误字段，但**不要**从错误内容推断新的真实工具补丁。
2. `tools/v1015/flutter_widget_test_entry/test_entry.py`、`README.md`、`config.example.json`、`receipt.template.json`与必要的非生产入口代码：只为使纯合成测试与用户文档**显式区分错误旧合同、这份新勘误、合法Hash长度、缺失LOCAL_ONLY补丁、无当前运行授权**而做最小改动。原来`test_strict_contract_and_no_reference_hash_substitution`与`test_default_inspect...`应改为验证**正确勘误的64位键被接受，同时错误62位输入仍坚决拒绝**。保留其它负例和全部已存在的38项测试函数/断言语义，增加必要真实“错误值被拒”的纯测试而不是删掉拒绝。
3. 新增一份明确的勘误执行/纯逻辑证据报告及最小Manifest，例 `docs/versions/v10.1.5/HOOK_SOURCE_HASH_AUTHORITY_ERRATUM_AND_LOCK_CORRECTION_REPORT_20261029.md`、`docs/versions/v10.1.5/hook_hash_erratum_lock_correction_manifest_20261029.json`，原合同和两版本Hex的source/Blob及复核层级必须清楚。
4. 如果按源Hash校正仍出现真实不闭合（缺LOCAL_ONLY raw补丁、无法核canonical LF diff、实际工具版本不同、私有进程guard未被新的真实测试验证），必须分别保留`PRIVATE_PATCH_SOURCE_NOT_AVAILABLE`、`SOURCE_BYTES_NOT_VERIFIED_THIS_TASK`、`RUNTIME_NOT_AUTHORIZED`和`EXECUTE_DISABLED`；**不能**把`validate_pins`静态成功升级为`PREPARED`或`RUNNER_READY`。保持`execute`只有未来单独、明确、可核的Owner运行授权及预算才能启动。

可对当前锁定的已知正确参考Hash做**严格的纯合成内存/字符串/格式检查**，保留边界/负向fixture验证；对具名LOCAL_ONLY历史补丁只允许有必要的**只读Hash及内存复现**，不复制原私人目录/日志到GitHub、不写旧工作面、不放开系统shell。工具包/源码版本升级及第三方完整patch上传一律不包含。

## 3. 一次性预算、验证与保护

- **新真实Flutter/Dart/analyze/test批次0；MariaDB/PHP API启动和连接0；Gradle/JVM/G2 Popen/claim 0；APK/ADB/设备/RTC/Push及其它生产/云服务0**。旧`V1015_WINDOWS_HOOKS_WIDGET_RECOVERY_20261029` Flutter6/6、旧MariaDB2/2、旧API1/2继续原账，未用API不能转成本任务新权限。绝不从任务名“修工具”推导真实运行权。
- 允许现有可信Python3.11（如已具名）在**本任务独立cwd/HOME/TEMP与拒绝外部网络/进程的纯自检环境**对新工具执行定向纯逻辑回归和AST/JSON语法检查；任何子流程有真实Flutter/Dart/vendor进程或需要系统权限时停止相关运行。合成文件只在本任务新根写入，不扫描/复做旧ACL或Windows restricted身份实验。
- 新任务logical与allocated各≤**256MiB（268435456 bytes）**，每项写入前建立`task_id=V1015_HOOK_HASH_AUTHORITY_ERRATUM_20261029`、唯一root/attempt、持久flush的`execution_ledger`，记录前后Hash、版本及成功/失败；任何生成中断先读此task旧根/账本并继续同一attempt，不重计次数、不为了报告漂亮而移除失败。当前任务没有SDK复制、Flutter批次、DB实例或设备输出预算。
- 在闭合条件可用时核对修改前后`locks.json`的Git blob和JSON字段，新增纯自检真实执行exit、测试数量、错误/负例，检查`inspect`默认无执行副作用，`prepare`在没有授权/补丁时仍拦截，`execute`在没有新Owner运行许可/资格证明时仍拒绝。若无法独立严格测试某一运行保护，记`NOT_RUN/NOT_PROVEN`。
- 禁止恢复/重试历史ACL、改UAC/组策略、系统时钟/防火墙/全局PATH/共享SDK，禁止旧源码工作树reset/clean/rebase/force、旧refs改动、个人凭据/绝对路径/原始LOCAL_ONLY日志外传；旧18/Seed/数据库等不可成为“纯自检”真实夹具。

## 4. 交付、独立审查与STOP

- **一份**固定Parent `fd85ac2546afab61aaf51cdfac796cfb9bed31ac` 的普通non-force候选；仅改非生产锁/文档/纯自检和两份新证据报告，不改生产apps/services、不合main、不重写历史合同/审查报告、不“代替Owner”发布实际Flutter运行资格。
- 结果须分别报告：`ERRATUM_PUBLISHED`（本正式任务已发布）、`LOCK_FIELD_CORRECTED`（仅当新候选Git实际更正64位）、`PURE_TEST_PASS/FAIL/NOT_RUN`、`PATCH_INPUT_NOT_QUALIFIED`、`PREPARE_NOT_RUN`、`EXECUTE_NOT_RUN`；成功上限状态 **`V10.1.5_HOOK_HASH_ERRATUM_LOCK_CORRECTED_AWAITING_ASTRA_REVIEW`**，受阻`DELIVERED_PARTIAL_WITH_EXPLICIT_PATCH_OR_TEST_BLOCKERS`。只有Astra后续独立接受，才能继承新源身份；不得自行上调功能验收。
- Manifest列出候选每项变更path/mode/Parent Blob/final Blob、原/目标Hash、工具测试回执和历史引用；当前task文件本身不修改。候选发布后fresh回读Commit/sole Parent/Root、每条变更Blob/mode、完整apps/services Tree、两份文档和最新main身份；原始本地运行日志/ledger不上传。
- **STOP等待Astra独立验收**，不自动另发工具运行/AC测试任务，不放行Flutter真正execute、MariaDB/Gradle/G2/设备，不撤销`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED / G2_READY_FOR_POPEN_FALSE / V10.1.6_NOT_STARTED / PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT / OLD_FIXTURE_EXACT_SD_RESTORATION_NOT_PROVEN / RESTRICTED_IDENTITY_GATE_BLOCKED / OS_ENFORCEMENT_NOT_PROVEN / REAL_PUSH_PROVIDER_PENDING / RTC_AEC_NOT_CLOSED / ELAPSED_TIME_AND_PHYSICAL_CLEANUP_NOT_PROVEN`。
