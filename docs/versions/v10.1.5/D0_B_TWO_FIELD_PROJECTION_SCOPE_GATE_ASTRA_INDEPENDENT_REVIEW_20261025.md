# EliteSync v10.1.5｜D0-B 两字段投影 Gate 1｜Astra 独立复核

日期：2026-10-25（Asia/Singapore）

**D0_B_GATE1_ACCEPTED_STATIC_ONLY / AWAITING_OWNER_DIRECTION_FOR_GATE2 / TARGETED_FIXTURE_NOT_RUN / WRITER_RUNTIME_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED**

## 1. 复核范围与证据层级

Astra直接读取GitHub候选Commit、候选报告/Manifest、临时审阅分支中的原始/修订PowerShell源码、最小diff、schema、plan、STATIC_SOURCE_EVIDENCE及非作者复核JSON；同时核验候选与前驱的Git身份及产品Tree。没有加载、编译或执行PowerShell源码，没有重跑D0-A或任何fixture。

- 复核时live main：`b101bf9680b5b46eda3c66ed93780af1ee5bc9d5`；Root Tree：`3fd90baf39bddd4e87d1213af565bc0994be0ece`。
- Gate 1候选Commit：`5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`；Root Tree：`260d7d0ef1586016105c7c9509089bd6c6956d94`；唯一Parent：`a9bb54d78e357ce15bf673a654baa849e264a32f`。
- GitHub compare确认候选相对唯一Parent ahead 1 / behind 0，只新增：`D0_B_TWO_FIELD_PROJECTION_SCOPE_GATE_REPORT.md`（Blob `7631bb4ede14f894e20f33f55acef53fdd769334`）与`d0_b_two_field_projection_scope_gate_manifest.json`（Blob `218a5270e9566e63a6fef5ea4ee41939f88181b9`）。
- 临时审阅分支Commit：`841555d5e9f3314098190198d89ab2044c9b2cd9`，Root Tree：`401bb07a553931dbeb5b19ac29b04039cf3af3dc`，唯一Parent为`a9bb54d78e357ce15bf673a654baa849e264a32f`。递归Tree中包含11份审阅材料Blob，路径集中在`docs/_temporary_review/v1015-d0-b-projection-scope-gate-20261024/`。该分支未合入main或产品候选。
- 当前main接受产品仍为v10.1.4：apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`，services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。Gate 1候选的apps/services Tree分别为`785822ca072943c5bfefa3ccc37ede01c2af5164`和`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，与其前驱保持一致，且不等于当前接受产品Tree。

## 2. 实际源码与调用链复核

审阅包中的原/新源码及`minimal.diff`支持以下静态事实：

1. `revised/fixture.ps1:8`通过原有同目录dot-source加载`receipt_writer.ps1`；没有新增C#编译/加载链。
2. `fixture.ps1:95`仍构造原有13字段ordered body；第96行唯一调用变化是从直接`(New-ReceiptParser).Serialize($body)`改为`Write-Aggregate $body`。
3. `receipt_writer.ps1`只在原9326字节前缀后追加`Write-Aggregate`函数。函数枚举的路径字面量仅为`$.started`与`$.finished`；缺字段、null、非String或非String BaseObject均在Serializer调用前抛出明确错误。
4. 两个字段均通过类型验证后，函数仅调用两次`set_Item`写回强类型字符串；其他11个顶层字段及`cases`不被遍历、转换或重新赋值。
5. 同一body随后直接进入既有`New-ReceiptParser().Serialize($body)`；没有通用递归投影、随意`ToString()`转换或孤立C# helper依赖。
6. `receipt-schema.json`与`fixture-plan.json`的原/新SHA-256相同，文件字节数也一致。原Writer前9326字节保持不变。旧`AggregatePrimitive.cs`草稿被保留，但不在新调用链内。

因此，之前Gate 1的两个阻断点——投影作用范围未限定、投影未接入实际Writer调用点——已由可读取源码和最小diff闭合。

## 3. 非作者复核与Astra独立判断

临时审阅包中的`NON_AUTHOR_STATIC_REVIEW.json`绑定本次源码Hash；七项审查均为PASS：两字段范围、其他字段/案例不变、schema及业务合同、实际Writer调用链、原生加载与类型边界、最小diff及产品隔离、公开审阅包安全性。Astra已独立读取同一组源文件与diff，未发现足以阻断静态Gate 1的额外问题。

**裁决：接受D0-B Gate 1的静态交付。** 该接受只表示静态范围、字段保留和实际调用链证据通过，不代表投影后的运行时类型已观察，不代表Serializer实际运行成功，也不代表Writer fixture通过。

## 4. 明确未证明及未授权事项

- D0-A没有重跑；仍仅有原15次Serialize/约0.688秒的源同构最小重建证据。
- 原始37案例aggregate对象未恢复；历史`PSInvalidCastException`根因仍UNKNOWN。
- 新投影未编译、未执行，投影后运行时类型NOT_OBSERVED。
- 15秒定点aggregate正负例、60秒完整37案例suite、Sandbox、Flutter/Gradle/Producer、`libs.jar`验收和30项`Configuration.resolve()`均为NOT_RUN。
- 不将Gate 1静态PASS写成Writer运行PASS、SDK READY、产品安全认证或v10.1.5版本接受。

本专项任务到Gate 1为止。后续阶段必须依据原正式任务单的逐级门禁另行放行；本复核不自动启动Gate 2，也不创建新的Codex任务。

## 5. 保留状态

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

产品源码未修改、未合并候选到main。短期审阅分支仍保留；本次不删除分支或历史Git对象。