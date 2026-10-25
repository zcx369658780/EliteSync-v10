# EliteSync v10.1.5｜D0-C Aggregate Failure Fallback 接线修复与静态门禁任务

日期：2026-10-25（Asia/Singapore）

**OWNER_AUTHORIZED_FOCUSED_SOURCE_FIX / STATIC_GATE_ONLY / NO_RUNTIME_TEST / AWAITING_ASTRA_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 0. 任务性质与授权边界

Owner已明确同意先修复 aggregate failure fallback 接线缺口，再由非作者静态复核和Astra独立复核。此任务只授权在任务自有LOCAL_ONLY副本内进行一项范围极窄的Writer源码修改、脱敏审阅包、非作者静态审查和普通non-force证据发布。

本任务**不授权Gate 2运行测试**。15秒定点aggregate正负例仍未运行，预算未消费；只有本任务通过非作者与Astra独立静态复核、Owner再次明确放行后，才能恢复一次15秒定点测试。不得把本任务解释为允许重跑D0-A、执行fixture、完整37案例suite、Sandbox、Flutter/Gradle、Producer、libs.jar或30项Configuration.resolve()。

## 1. 权威来源与开工核验

- 仓库：`zcx369658780/EliteSync-v10`。
- 开工必须fresh只读核验live `main`、Root Tree、`docs/workflow/ACTIVE_STATE.md`、本任务Blob、原综合任务Blob及连续候选分支远端HEAD；不得假定历史SHA仍为当前值。
- 原综合任务：`docs/versions/v10.1.5/ASTRA_SOURCE_FAITHFUL_AGGREGATE_SERIALIZER_DIAGNOSTIC_AND_CONDITIONAL_SDK_TASK_20261024.md`，Blob `009a12cae75ef3b714f0156d4edbca2db1660719`。
- Gate 1专项任务Blob：`38667356cb487acc4d8fc0994f894eabf3fb82e0`。
- Gate 1 Astra独立复核：`docs/versions/v10.1.5/D0_B_TWO_FIELD_PROJECTION_SCOPE_GATE_ASTRA_INDEPENDENT_REVIEW_20261025.md`，Blob `d377b19756eebeaf4f01c3f69d6fd2326ed89780`。
- Gate 2启动前阻断复核：`docs/versions/v10.1.5/D0_C_GATE2_PREFLIGHT_AGGREGATE_FALLBACK_BLOCKED_ASTRA_REVIEW_20261025.md`，Blob `b4e640323bf73985872dcb95ff9cc6f00d691e0d`。
- 当前Gate 1候选Commit：`5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`，Root `260d7d0ef1586016105c7c9509089bd6c6956d94`，唯一Parent `a9bb54d78e357ce15bf673a654baa849e264a32f`。此SHA为已接受Gate 1证据基线，不代表当前远端分支HEAD；开工时必须重新核验。
- 已审阅修订Writer Blob `ce0a03e965be56a6b2c0c62025de010ee41369ae`；修订fixture Blob `0eaf0f7c3a79ef89530d051de14a811cb61b8b04`；审阅包Commit `841555d5e9f3314098190198d89ab2044c9b2cd9`、Root `401bb07a553931dbeb5b19ac29b04039cf3af3dc`。这些是审阅证据身份，不可代替任务工作副本中的实际路径与Hash。

## 2. 已确认缺口

- `Write-IndependentFailure`会生成独立failure receipt，并使用`Write-AtomicReceiptJson`完成UTF-8、schema、Hash读回、Run ID、`ready=false`及原子发布；但当前可见源码仅在`Write-Receipt`的catch中调用它。
- `Write-Aggregate`只对`$.started`和`$.finished`执行限定投影，随后直接调用`New-ReceiptParser().Serialize($body)`；该序列化异常没有连接到独立fallback。
- `fixture.ps1`在suite构建的try/catch之后直接调用`Write-Aggregate`，其异常不会进入`Write-Receipt`的fallback路径。
- 因此当前Gate 2的负例合同无法满足。不能通过在测试harness中手工生成failure receipt来掩盖生产Writer调用链缺口。

## 3. 唯一目标

在任务自有LOCAL_ONLY工作副本内，将`Write-Aggregate`的序列化失败处理明确接入独立failure fallback，使真实Writer失败路径形成可审查闭环。仅处理这个接线缺口；不得重写整个Writer、改动通用Receipt行为或扩大到产品代码。

### 必须满足

1. `$.started`与`$.finished`投影范围保持原样，不增加任何其他被投影、遍历或重写的字段。
2. 其余11个顶层字段、`cases`、13字段body构造、原schema、37案例plan、Run ID和业务合同保持不变。
3. Aggregate序列化异常由`Write-Aggregate`的实际调用路径处理，生成独立failure receipt；fallback不得递归调用失败的aggregate serializer，也不得依赖`Write-Receipt`再次序列化相同aggregate body。
4. 失败回执必须保留独立的确定性失败语义：`status=RECEIPT_SERIALIZATION_FAILURE`、`ready=false`、Run ID绑定、字段/输入类型/异常类型等既有最小元数据及其Hash；写入路径必须继续经过既有`Write-AtomicReceiptJson`的UTF-8、schema验证、Hash读回、同目录原子发布及发布后Hash核验。
5. Aggregate正常序列化路径、两个字段的类型拒绝行为、现有receipt fallback和正常receipt行为不得被削弱。若fallback自身失败，必须清楚保留双重错误/首因信息并fail-closed；不得伪造fallback成功。
6. 不允许通过移除必需字段、吞掉异常、静默返回空aggregate、设置PASS/READY、宽松schema、通用`ToString()`转换或仅由harness手写receipt来通过静态审查。
7. 保留原有源码快照、Gate 1 Hash、失败证据及历史资产。先生成最小diff，再进行复核。

## 4. 本任务允许执行的工作

- 在任务自有LOCAL_ONLY副本读取并Hash核对当前固定Writer、fixture、schema和plan。
- 修改任务副本中的Writer失败路径；如确有必要修改fixture调用边界，必须证明是闭合真实错误路径所必需的最小变化，并解释为什么不改变原合同。优先保持fixture不变。
- 进行只读静态检查、最小diff/调用图审查、schema与字段合同比对、源码Hash及审阅包字节校验。
- 生成不含个人绝对路径、凭据、真实PID、环境快照、私密日志、控制文件或运行输出的最小脱敏审阅包。
- 邀请非作者基于固定的原/新源码、diff、schema、plan和Hash进行静态复核；七项复核结论必须绑定精确Hash。
- 在原连续候选分支上普通non-force发布证据，并通过GitHub只读回读核对Commit、sole parent、Root、报告/Manifest Blob及字节。若分支HEAD已漂移或保护对象不匹配，停止并报告，不强行改写历史。

## 5. 严格禁止

- 不运行任何PowerShell源文件，不编译、加载或执行新Writer，不调用Serializer验证修复。
- 不运行15秒定点正负例；不运行完整37案例suite；不重跑D0-A，不重置或重新解释已消费预算。
- 不启动/查询/关闭Sandbox guest，不运行Flutter/Gradle/Producer，不生成或验收`libs.jar`，不运行30项`Configuration.resolve()`。
- 不修改`apps/services`产品源码、系统网络、全局Git配置、ACL/owner、共享SDK、未知guest或其他系统状态。
- 不下载工具，不结束未知进程，不清理任何历史分支、refs、protected files、日志、SQL、APK或旧资产。
- 不创建后继版本，不合并到main，不自动进入Gate 2。

## 6. 静态验收门禁

必须由非作者审查并逐项给出PASS/FAIL/NOT_PROVEN及证据行号/Hash：

1. **真实错误接线**：从`Write-Aggregate`实际Serializer异常到独立failure fallback的调用路径闭合；不存在仅harness模拟的替代。
2. **不递归**：failure fallback不再调用`Write-Aggregate`、失败的aggregate Serializer或相同失败body的`Write-Receipt`。
3. **两字段隔离**：`$.started`和`$.finished`投影范围及类型拒绝语义不变。
4. **字段与合同保留**：其他11字段、cases、schema、37案例plan、Run ID与业务合同不变。
5. **失败回执完整性**：failure receipt使用既有独立发布函数，保留`ready=false`、状态、元数据Hash、UTF-8/schema/Hash读回/原子发布及发布后Hash校验；fallback失败时不伪造成功。
6. **最小diff与资产隔离**：所有源码变更路径有解释；无产品源码、全局配置、SDK或历史资产变更。
7. **脱敏与可复核性**：审阅包源码、diff、schema/plan、清单和Hash相互一致，无敏感本地执行信息。

若任何一项FAIL、关键证据缺失、源码Hash漂移、必须扩大范围或需要运行代码才能判断，停止并报告阻断，不运行测试。

## 7. 发布与终态

本任务只允许普通non-force发布脱敏审阅材料和任务报告/Manifest；不得把Gate 1或本任务文档提交误认为产品接受。发布后进行远端回读，并将准确身份保存到LOCAL_ONLY回执。

成功终态：`D0_C_FALLBACK_WIRING_STATIC_PASS / AWAITING_ASTRA_INDEPENDENT_REVIEW / GATE2_NOT_RUN`。

阻断终态：`D0_C_FALLBACK_WIRING_STATIC_BLOCKED / GATE2_NOT_RUN / AWAITING_OWNER_DIRECTION`。

交付完成后立即停止等待Astra独立验收。即使非作者静态复核全部PASS，也不允许自行恢复Gate 2。Gate 2需Astra独立复核此修复并由Owner另行明确放行。

## 8. 永久保留状态

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

当前15秒Gate 2预算未消费；D0-A既有诊断预算不重跑、不重置。