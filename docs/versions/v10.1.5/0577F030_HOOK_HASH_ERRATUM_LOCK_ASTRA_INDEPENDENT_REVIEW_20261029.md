# EliteSync v10.1.5｜0577f030 Hook SHA-256权威单字段勘误＋非生产锁定修复｜Astra独立审查

日期：2026-10-29（Asia/Singapore）。

**正式裁决：`0577F030_BOUNDED_OWNER_HASH_ERRATUM_AND_NONPRODUCTION_LOCK_ACCEPTED_WITH_RUNTIME_GATES_RETAINED`。**

接受唯一候选准确的Git身份、锁定文件的**一个字段**更正、42项纯合成逻辑检查的有源Codex本地回执、旧62位输入负例与未来运行门禁保持；**不接受**“真实私有Hook source/patch已资格化、SDK已经prepare、Flutter execute已测、Windows系统shell全面安全、标准Flutter开发环境全恢复或v10.1.5功能已接受”。本轮整体保持`PARTIAL`及`AC05_OPEN`，不授权main集成/G2/Gradle/设备。

## 1. Authority、候选与GitHub身份

- Owner唯一正式任务：`docs/versions/v10.1.5/V10_1_5_HOOK_SOURCE_SHA256_AUTHORITY_ERRATUM_AND_NONPRODUCTION_LOCK_CORRECTION_TASK_20261029.md`，Git Blob **`a0eec472b58d53bc25084a395efc0748779d73f8`**。新发布Owner勘误仅覆盖旧正式合同中`hooks_runner 1.0.1`原source SHA-256单字段；旧任务Blob `0854b37fdc9f11c55088ed2d2f93816a27bc2fa9`、错误锁Blob `130b9fe79d326ae701bc0fad27096e6413508a6d`和以前的Astra审查原件不修改。
- 开审fresh main **`7b33f685df3704a384a3cf1f34c3f810e741aeac`**，Root **`fc5ef9921d954ac4cd0ffc75cf698efe5a1318ed`**，main `ACTIVE_STATE` Blob **`5d86c737194c7cc07521b690465a6a24f8eb645f`**。其唯一已接受产品为v10.1.4：apps Tree **`3468a3dd97da7accfda2539a0f8d8f68931a6110`**，services Tree **`0cb1f9d19659291a462488b3686fd0a07a6698ac`**。
- Codex唯一候选 **`0577f030f6e3bbecae611433daa226719a7cc4b0`**，sole Parent **`fd85ac2546afab61aaf51cdfac796cfb9bed31ac`**、Root **`4d024bb4d931a346f237614efa7940451a39678e`**。GitHub compare 为ahead1/behind0；**恰8项文件**：`tools/v1015/flutter_widget_test_entry/`内6个非生产锁/入口/测试/说明文件，以及2份新报告与Manifest。没有app/services生产或测试源码变更，没有修改`core.py`、`runtime.py`、历史正式任务、产品`pubspec.lock`。
- 候选Root递归**6290项、truncated=false**；apps Tree **`798049a15eb33fec16acdd37d83a07af0ed181b5`**（729 Blob）、services Tree **`9bba2938aa41ad3eaee501ef88bfeecdee797591`**（716 Blob）与fd85候选完全相等，不是main集成。GitHub `manifest.files`中8项`path/mode/blob`与Root真实Tree全部匹配；Manifest自引用条目`final_blob=null`，自身由按路径读取Git Blob **`9f9c43efc6fddc50a468c51ea4f7e9d00514d0c2`**独立固定，避免循环签名。
- 实施报告 `docs/versions/v10.1.5/HOOK_SOURCE_HASH_AUTHORITY_ERRATUM_AND_LOCK_CORRECTION_REPORT_20261029.md` Git Blob **`0291ea5b873e0bef0c9798eee8ef8e8d74c1b29d`**，脱敏证据索引Manifest `docs/versions/v10.1.5/hook_hash_erratum_lock_correction_manifest_20261029.json` Blob如上。文件身份、源码与JSON字段属于`DIRECT_GITHUB_OBJECT`；Codex的本地测试exit和历史私有输入属于不同证据等级。

## 2. 单字段更正经Astra直接核验

原`fd85`锁文件 `hook_original_sha256`为62位：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d08c393dad9`。

新`0577`锁文件 `hook_original_sha256`为已由新Owner任务单冻结的64位：
`f17707405ce4ba5b41feefecd5c54e9767971e27dbc0d3f5740d4d08c393dad9`。

新锁Git Blob **`8268c95fba859aed2bfd13c88fc6d000ac78f0b2`**。Astra直接解析新旧JSON并按key/value逐项比较：**仅`hook_original_sha256`值变化，键集合、`accepted_reference_original_sha256`、工具版本、目标/diff/CRLF Hash、其他可执行程序Hash、旧task关闭清单与当前/未来批次设置全部不变**。新值同时与前轮`5aa3` Git证据索引Blob `657deb5e748a7d0d216b5b1c589ed3b86254734f` 的`privateRunner.beforeSha256`、Astra审查Blob `715bc340042675df86a0c791c49eb1852bb9b5ce`以及旧`fd85`锁中已保留64位参考字段一致。

**通过的是规范值身份勘误，不是本轮读取并重hash原Windows LOCAL_ONLY源**。历史62位任务文件及其失败不覆写，标记`SUPERSEDED_BY_OWNER_ERRATUM_FOR_HOOK_SOURCE_SHA256_ONLY`；不回溯追认旧合同“从未出错”。

## 3. 42项纯测试、失败与默认门禁

- 直接读取 `tools/v1015/flutter_widget_test_entry/test_entry.py` Parent与Candidate源码：**38个原test_方法均保留**，新增四方法：`test_historical_malformed_inspect_still_reports_rejection`、`test_missing_private_patch_cannot_prepare`、`test_zero_runtime_budget_is_not_a_grant`、`test_valid_hash_format_does_not_qualify_actual_source`；前两项受勘误影响的原测试适当调整为接受合法64位、拒绝历史62位。原路径/补丁/授权/账本/进程白名单的正反测试范围保留。
- Codex报告 Python3.11**42 executed/42 passed、0 failed/errors/skipped、exit0**；Astra没有在用户Windows或其他实际执行环境现场重跑该42项，故只能标`CODEX_REPORTED_LOCAL_PURE_TEST`，**不能**标`ASTRA_REEXECUTED_PASS`。公开的42个方法与该数量一致。
- 报告如实保留最初辅助程序exit1且0测试、随后首批42项中21通过/21错误exit1的原失败；原因是本任务纯测试的网络拒绝替身与Python依赖导入接口冲突，后改用类兼容拒绝替身并得到全PASS，失败原件仅LOCAL_ONLY。不删掉负向断言、不“退款”失败预算。
- 直接审查新`entry.py`：缺输入的默认inspect返回`DRY_RUN_ONLY`、`EXECUTE_DISABLED`、`LOCK_REFERENCE_FORMAT_VALID`、`PATCH_INPUT_NOT_QUALIFIED`、`SOURCE_BYTES_NOT_VERIFIED_THIS_TASK`、`PREPARE_NOT_RUN`、`RUNTIME_NOT_AUTHORIZED`。它是**静态入口状态**，不是Windows runtime身份验证。旧`core.py`和`runtime.py`的Git Blobs分别仍为`d066d2587ba54cfa64a67de731d4cf14c3ca39f0`、`21257aaf0dfde45027b9040f975fedea168aac90`，未放松旧安全逻辑。
- **重要限制**：一般`prepare`代码路径在未来收到外部显式授权/补丁时并非从软件设计上永久禁用；`execute`也有未来资格证明/批次参数入口。这些本地JSON的一致性字段**不是独立加密Owner签名/恶意代码沙箱**。当前任务Owner**没有**发布真实prepare/execute运行许可，且缺原source/patch重新资格化，所以本轮不得调用或宣称两者PASS。未来要另由Owner明确批准新的具体测试运行预算、task-root、原件Hash验证、进程/写入闭包和安全资格，不以本次锁值通过即可自行启动。

## 4. 预算、保护与持续开放的验收条件

本轮报告仅一棵新task-owned根、独立账本、logical/allocated各≤256MiB；本地离散空间/账本回执由Codex负责保存，Astra无法独立观察连续峰值。**真实Flutter/Dart/analyze/widget、MariaDB/API、SDK复制、G2/Gradle/JVM、APK/ADB/RTC/真实Push/设备、生产服务均报告0次**。旧Flutter6/6、MariaDB server2/2耗尽，API旧任务1/2余额不等于本任务许可。旧APK/G各1/1耗尽、旧A关闭、条件G2仍`G2_READY_FOR_POPEN_FALSE`。
 
既有Owner封存事故`PRIOR_33213A77_CROSS_ATTEMPT_FIXTURE_BUDGET_NONCOMPLIANT`及旧18件、两棵实验根、122原证、五根、527 refs、Seed3183、旧失败/账本/dirty根继续no-touch；未新做其ACL/OS身份全审计，不表示历史严格SD已恢复。真实15/30天与设备Keystore/物理清理、RTC AEC/最后可闻5秒止声、真实Push供应商、同源App/API/DB与Android真实构建、AC01–11矩阵仍保持先前部分/开放，不因Hash勘误而变为PASS。

## 5. 正式裁决与STOP

**`0577F030_BOUNDED_OWNER_HASH_ERRATUM_AND_NONPRODUCTION_LOCK_ACCEPTED_WITH_RUNTIME_GATES_RETAINED`**：可接受修复后的非生产锁配置与纯测试源码/报告、完整Git对象来源、对错误旧值的拒绝以及未扩大运行权限的正确STOP。状态明确分层：

`ERRATUM_PUBLISHED / LOCK_FIELD_CORRECTED / PURE_TEST_PASS_CODEX_REPORTED`

`SOURCE_BYTES_NOT_VERIFIED_THIS_TASK / PATCH_INPUT_NOT_QUALIFIED / PREPARE_NOT_RUN / EXECUTE_NOT_RUN / RUNTIME_NOT_AUTHORIZED`

**下一建议但尚未授权**：不再围绕Hash长度反复生成任务；Owner可以依据完整AC01–11矩阵决定下一次实际软件验收与相关独立预算。若需使可复现Flutter入口达到真正`PREPARED`或真实Widget可再次验证，首先单独核验受保护的LOCAL_ONLY原Hook/diff与任务私有写入、子进程守卫和完整依赖，并给予新的**明确**Owner权限；当前这个62→64勘误本身没有授予任何执行额度。真实设备/RTC/AEC/Push、G2与产品main集成应继续独立决策，避免自动以本轮源校正越级放行。

**STOP等待Owner下一次方向；不得自动发布后继任务、合main、关闭AC05、放行G2或进入v10.1.6。**
