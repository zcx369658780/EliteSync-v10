# EliteSync v10.1.5｜D0-C Aggregate Failure Fallback 接线｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**D0_C_FALLBACK_WIRING_STATIC_ACCEPTED / GATE2_NOT_RUN / GATE2_BUDGET_UNCONSUMED / AWAITING_OWNER_DIRECTION**

## 1. 复核范围与证据层级

Astra直接读取并复核GitHub候选Commit、正式报告/Manifest、临时审阅包中的原始与修订Writer、最小diff、fixture/schema/plan、静态合同证据和非作者七项复核。未加载、编译或执行PowerShell；未调用Serializer；未运行任何fixture。结论仅为静态调用链验收，不声称failure receipt、异常传播或原子I/O已运行观察。

- 复核前live main：`f4f1227be892292a10e6490b866d49f8501d18d9`；Root `5f68df5a1816a2a09a753a8a14601b4b38e97b2f`。
- 候选Commit：`7b8b9959c9e53994ec5c52736d1fb3ca00ba4239`；唯一Parent `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`；Root `8b51a383eebfc60e221b6b2936d17f398bb61e16`。
- GitHub compare确认候选相对唯一Parent ahead 1 / behind 0，只新增报告和Manifest两份文档，没有直接修改产品源码。
- 正式报告Blob `ab359238eed516374396a52db972a18eb6e220de`；Manifest Blob `a22a6c5880a5c0bd6f2cf4d994c2bb9c033b25f1`。
- 脱敏审阅包Commit `5bd6963ef58cd91401cd980bcb2775412cf70b7e`；Root `3d8062fb8e33e5d886d0c11d611017e58232d890`；含原/新Writer、未改fixture/schema/plan、最小diff、静态证据、清单、README及非作者复核材料。审阅包中修订Writer Blob `a521201e2274927ebf0743c4d79811bb7ecf27ba`，原Writer Blob `ce0a03e965be56a6b2c0c62025de010ee41369ae`，diff Blob `444ef18a15a5215c41aae24c1849cc9f130da51e`，非作者复核Blob `d7413755b5891b0508ab608d897248fdfac590bc`。
- 当前main接受产品仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。候选的apps/services Tree分别为`785822ca072943c5bfefa3ccc37ede01c2af5164`与`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，与Gate 1候选保持一致，不是main产品Tree；未集成main。

## 2. 静态差异与调用链

最小diff仅把`Write-Aggregate`原有`New-ReceiptParser().Serialize($body)`语句包在try/catch中。两字段投影、类型拒绝及其之前的代码保持逐字节不变；fixture、schema和37案例plan逐字节不变。

真实静态调用链为：`fixture.ps1:8` dot-source Writer → `fixture.ps1:95` 建立原13字段body → `fixture.ps1:96` 调用`Write-Aggregate` → `receipt_writer.ps1:145` 原Serializer → `:146-151` 捕获实际Serializer异常并调用既有`Write-IndependentFailure('fixture-body.json', originalExceptionType)` → 既有独立JSON构造与`Write-AtomicReceiptJson` → 重新抛出原异常。

## 3. Fallback合同核验

1. **真实接线：PASS（静态）**。catch围住真实Writer Serializer调用，不是测试harness补造。
2. **独立、不递归：PASS（静态）**。fallback手工构造独立failure JSON并调用既有原子发布器；它只用`DeserializeObject`校验，不再次调用aggregate Serializer、`Write-Aggregate`或相同body的`Write-Receipt`。
3. **失败状态与元数据：PASS（静态）**。沿用`RECEIPT_SERIALIZATION_FAILURE`、`ready=false`、`control.runId`、aggregate根字段`$`、实际aggregate dictionary类型、原异常类型及metadata SHA-256。fixture绑定的control.runId与body.runId保持一致。
4. **原子发布合同：PASS（静态）**。fallback沿用现有`Write-AtomicReceiptJson`，包括严格UTF-8、schema与Run ID/metadata hash校验、读回Hash、同目录原子Move及发布后Hash核验。原子I/O本次没有运行观察。
5. **fallback成功后失败仍不被吞：PASS（静态）**。fallback发布成功后，`Write-Aggregate`执行bare `throw`，不返回aggregate成功。
6. **fallback自身失败：PASS（静态合同）**。内层catch构造`AggregateException`，`InnerExceptions[0]`保留原aggregate异常，`[1]`保留fallback异常；没有成功返回。实际双重失败未运行观察。
7. **范围与合同保持：PASS**。`$.started`/`$.finished`投影及类型拒绝代码不变；其他11字段、cases、13字段body、schema、37案例plan和正常Receipt路径未修改。

非作者七项静态审查均PASS，审阅包清单所列9个审阅文件的Hash/字节与远端Blob身份匹配。Astra独立静态复核未发现足以阻断此接线修复的源码问题。

## 4. 独立裁决

**接受D0-C fallback wiring静态交付：`D0_C_FALLBACK_WIRING_STATIC_ACCEPTED / GATE2_NOT_RUN / GATE2_BUDGET_UNCONSUMED / AWAITING_OWNER_DIRECTION`。**

接受范围仅为静态接线和合同审查。没有证明实际异常一定按预期传播、failure receipt在运行时有效、原子I/O成功，或正例aggregate序列化成功。Gate 2的15秒正负例预算仍未消费。

## 5. 下一步与停止门禁

可以由Owner决定是否重新放行一次15秒定点aggregate正负例。当前没有自动授权：Astra独立静态接受不等于Owner放行。未经Owner明确确认，不运行正负例；不运行完整37案例suite、Sandbox、Flutter/Gradle、Producer、libs.jar或30项Configuration.resolve()。不重跑D0-A、不重置预算、不修改产品源码、不合并main、不清理审阅分支或历史refs。

## 6. 永久保留状态

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。