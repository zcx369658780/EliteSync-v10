# EliteSync v10.1.5｜Gate 2 启动前 Aggregate Fallback 阻断｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**D0_C_GATE2_PREFLIGHT_BLOCKED / POSITIVE_NOT_RUN / NEGATIVE_NOT_RUN / GATE2_BUDGET_UNCONSUMED / NO_SOURCE_CHANGE / AWAITING_OWNER_DIRECTION**

## 1. 复核范围与身份

Astra直接复读Gate 1公开审阅包中的修订源码，并与Gate 1已接受的源码Hash、调用链和原正式任务的fallback验收要求对照。Astra没有直接读取Owner提供的LOCAL_ONLY阻断报告正文/Hash，也没有执行PowerShell、fixture或任何诊断；本结论不冒称本地运行观察。LOCAL_ONLY报告为Owner/Codex提供的执行状态材料，公开源码检查则是本次独立静态证据。

- 本次复核前live main：`99c61a717860990cb3a1105ad725d036459a2487`；Root Tree：`ab230bfc13743393d089e2bd72cc30af1e76e652`。
- Gate 1候选：Commit `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`，Root `260d7d0ef1586016105c7c9509089bd6c6956d94`，唯一Parent `a9bb54d78e357ce15bf673a654baa849e264a32f`。
- 审阅包：Commit `841555d5e9f3314098190198d89ab2044c9b2cd9`，Root `401bb07a553931dbeb5b19ac29b04039cf3af3dc`。修订Writer Blob `ce0a03e965be56a6b2c0c62025de010ee41369ae`；修订fixture Blob `0eaf0f7c3a79ef89530d051de14a811cb61b8b04`。
- Gate 1 Astra复核Blob：`d377b19756eebeaf4f01c3f69d6fd2326ed89780`。原正式任务Blob：`009a12cae75ef3b714f0156d4edbca2db1660719`。

## 2. 发现：独立 fallback 确实没有接入 aggregate 序列化失败路径

修订 `receipt_writer.ps1` 的静态代码显示：

1. `Write-IndependentFailure` 存在，并通过 `Write-AtomicReceiptJson` 创建带`status=RECEIPT_SERIALIZATION_FAILURE`、`ready=false`、元数据Hash和Run ID的独立failure receipt。
2. 但该fallback只在 `Write-Receipt` 的 `catch` 中调用；这个catch覆盖 `Copy-ReceiptValue`、`ConvertTo-Json` 和 `Write-AtomicReceiptJson` 的异常。
3. `Write-Aggregate` 在完成两个时间字段的限定验证与替换后，直接执行 `return (New-ReceiptParser).Serialize($body)`。该调用没有本函数内的catch，也没有调用 `Write-IndependentFailure`。
4. 修订 `fixture.ps1` 在前面的suite构建try/catch结束后，直接执行 `$json=Write-Aggregate $body`，然后才写入`fixture-body.tmp`、读回Hash、解析并原子移动为`fixture-body.json`。aggregate调用抛出的异常不经过 `Write-Receipt` 的fallback路径。

所以，现有源码证明了字段范围与Writer调用链（Gate 1），但没有证明aggregate序列化失败会生成独立failure receipt。若Serializer在 `Write-Aggregate` 中抛出，当前可见调用路径会在aggregate文件发布前中止；不能把别处的 `Write-Receipt` fallback算作aggregate fallback。

## 3. Gate 2裁决

Owner先前授权了一次、硬时限15秒的定点aggregate正负例。但原任务要求负例必须证明真实失败路径明确拒绝、不产生READY/PASS，并由独立fallback产生有效failure receipt。当前静态调用链无法满足这一验收合同。

**裁决：`D0_C_GATE2_PREFLIGHT_BLOCKED`。** 正例与负例均为 `NOT_RUN`；15秒运行预算未消费。此状态是运行前的静态前置阻断，不是测试执行后的FAIL，不得记录为negative fixture FAIL或Writer runtime FAIL。

该阻断与平台Daybreak UI提示无关。没有证据将其归因于平台安全机制；这是可直接定位的工程调用链缺口。

## 4. 当前允许与禁止事项

- 保留Gate 1的静态接受结论；不把它升级为Writer运行PASS。
- 不重跑D0-A，不重置预算，不运行正例或负例，不启动37案例suite、Sandbox、Flutter/Gradle、Producer、libs.jar或30项解析。
- 不通过测试harness单独手工写failure receipt来假装Writer集成完成；不修改当前源码来绕过已授权的测试范围。
- 本轮不创建新的Codex任务，不修改产品源码，不合并任何候选，不清理分支、refs或历史资产。

## 5. 建议的下一步（需Owner明确授权）

应先有一个范围极窄的源码修复与静态复核阶段，将aggregate失败路径正式连接到独立fallback，同时保留：

- `$.started`与`$.finished`的两字段投影范围不变；
- 其他11个字段、cases、原schema和业务合同不变；
- failure receipt仍通过独立路径生成，不递归调用失败的aggregate serializer；
- UTF-8、schema、Hash读回、Run ID、`ready=false`、同目录原子发布与错误收口可审查；
- 正常aggregate与失败fallback的调用关系在真实Writer代码中闭合，而不是仅由测试harness模拟。

该修复应先由非作者进行静态复核，再由Astra独立审查。只有该缺口闭合并获得Owner明确放行后，才恢复一次15秒定点正负例。此次Owner原先的Gate 2运行授权不能被解释为自动授权修改Writer失败路径；本复核不创建该修复任务。

## 6. 保留状态

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。