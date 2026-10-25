# EliteSync v10.1.5｜D0-C Gate 2 定点 Aggregate 正负例测试任务

日期：2026-10-25（Asia/Singapore）

**OWNER_AUTHORIZED_ONE_SHOT_GATE2 / HARD_LIMIT_15_SECONDS_TOTAL / POSITIVE_AND_NEGATIVE_TARGETED_FIXTURE_ONLY / NO_FULL_37_CASE_SUITE / AWAITING_ASTRA_REVIEW / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 0. 授权与范围

Owner已明确重新放行一次15秒定点 aggregate 正负例测试。本任务是原综合任务Gate 2的受限续接，不是新版本，不重跑D0-A，不重置任何已消费预算。此次15秒预算此前未消费；本次最多消费一次，硬时限从定点测试启动前按原任务定义开始计时，总计不得超过15秒。

仅允许：在任务自有LOCAL_ONLY副本中，对Gate 1与D0-C静态复核已接受的Writer修订执行一次定点aggregate正例和一次定点aggregate负例，并采集原始、可复核的结果回执。不得运行完整`fixture.ps1`主流程（该流程可能触发37案例suite）。

## 1. 权威来源与开工前核验

- 仓库：`zcx369658780/EliteSync-v10`。
- 原综合任务单：`docs/versions/v10.1.5/ASTRA_SOURCE_FAITHFUL_AGGREGATE_SERIALIZER_DIAGNOSTIC_AND_CONDITIONAL_SDK_TASK_20261024.md`，Blob `009a12cae75ef3b714f0156d4edbca2db1660719`。
- Gate 1专项任务Blob：`38667356cb487acc4d8fc0994f894eabf3fb82e0`。
- Gate 1 Astra静态接受：`docs/versions/v10.1.5/D0_B_TWO_FIELD_PROJECTION_SCOPE_GATE_ASTRA_INDEPENDENT_REVIEW_20261025.md`，Blob `d377b19756eebeaf4f01c3f69d6fd2326ed89780`。
- D0-C fallback wiring Astra静态接受：`docs/versions/v10.1.5/D0_C_AGGREGATE_FAILURE_FALLBACK_WIRING_ASTRA_INDEPENDENT_REVIEW_20261025.md`，Blob `f8ce12a81bf303cf5fba37bb708927a3e2791b4b`。
- Gate 2启动前阻断复核（已由D0-C修复静态闭合）：`docs/versions/v10.1.5/D0_C_GATE2_PREFLIGHT_AGGREGATE_FALLBACK_BLOCKED_ASTRA_REVIEW_20261025.md`，Blob `b4e640323bf73985872dcb95ff9cc6f00d691e0d`。
- Gate 1代码基线Commit `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`，Root `260d7d0ef1586016105c7c9509089bd6c6956d94`。
- D0-C静态修复候选Commit `7b8b9959c9e53994ec5c52736d1fb3ca00ba4239`，唯一Parent `5dabe5de0a3a7f37ae0aa4e9a0ccf3e250b64298`，Root `8b51a383eebfc60e221b6b2936d17f398bb61e16`。
- D0-C脱敏审阅包Commit `5bd6963ef58cd91401cd980bcb2775412cf70b7e`，Root `3d8062fb8e33e5d886d0c11d611017e58232d890`；修订Writer Blob `a521201e2274927ebf0743c4d79811bb7ecf27ba`，最小diff Blob `444ef18a15a5215c41aae24c1849cc9f130da51e`。
- 开工必须fresh只读核验live main、Root Tree、ACTIVE_STATE、原综合任务正文/Blob、Gate 1/D0-C复核正文，以及连续候选分支当前远端HEAD。以上SHA是固定历史证据，不代表远端HEAD永不变化。确认实际待测Writer的路径和SHA与已接受D0-C源码一致；不一致即STOP。

## 2. Gate 2唯一目标

在总计15秒硬时限内，各执行一次正例和负例，证明已接受的真实Writer修订在最小aggregate输入上同时满足成功序列化与失败闭环合同。正负例必须走实际`Write-Aggregate`调用路径；不得通过直接调用helper或在测试harness中手工生成成功/失败receipt替代真实Writer行为。

### 正例必须证明

1. 最小有效aggregate通过真实`Write-Aggregate`与既有Serializer成功序列化。
2. 13个必需顶层字段均保留；`$.started`、`$.finished`为预期字符串，其他11字段及`cases`语义未改变。
3. `Run ID`、expected/actual count、逐项状态、schema与来源/计划Hash符合固定合同。
4. 输出为严格UTF-8；发布前后读回字节、schema、Hash一致。
5. 通过同目录原子发布；发布后读回核验成功，成功receipt只在所有检查完成后形成。

### 负例必须证明

1. 通过真实Writer输入注入原任务规定的非法运行时对象/循环，使aggregate Serializer实际抛出异常；不得在harness中直接跳过Serializer并伪造catch分支。
2. `Write-Aggregate`捕获实际Serializer异常并调用已接受的`Write-IndependentFailure`。
3. fallback成功生成有效独立failure receipt，至少保留`status=RECEIPT_SERIALIZATION_FAILURE`、`ready=false`、正确Run ID、aggregate根字段/类型、原异常类型及metadata Hash。
4. fallback按既有路径通过UTF-8、schema/Run ID/metadata Hash校验、Hash读回、同目录原子发布与发布后Hash核验。
5. fallback成功后，原aggregate异常仍被重抛；不得返回aggregate成功或形成READY/PASS。
6. 若在本次既定负例中自然触发fallback自身失败，必须保留原异常与fallback异常；不额外构造第二个故障场景以扩张测试范围。

## 3. 时限与停止条件

- 正例与负例共用一次15秒硬时限；不得将其解释为每例各15秒，不得重试或重跑。
- 超时、任一命令退出不明、子进程未确认退出、回执缺失、schema/Hash/Run ID不匹配、原异常未传播、fallback未发布、出现READY/PASS假阳性或需要运行完整suite，立即STOP。
- 任何失败都如实报告`GATE2_FAIL`或`GATE2_BLOCKED`及真实证据；不可将未运行的检查写成PASS。不得为了赶时间删除关键核验。
- 若正例先失败，不要求继续负例；若负例前置条件不成立，不允许用mock/harness伪造fallback。记录已发生的耗时和已完成步骤，不再次启动测试。
- 保留原始stdout/stderr、退出码、开始/结束时刻、耗时、Run ID、receipt字节与SHA-256、schema/Hash读回结果、原子发布结果及子进程退出证据。所有本地原始证据留在LOCAL_ONLY；只发布最小脱敏证据。

## 4. 严格禁止

- 不重跑D0-A；不重新建立最小源同构诊断；不重置历史预算。
- 不运行完整37案例suite或`fixture.ps1`可能触发的主流程。
- 不启动/操作Sandbox、Flutter、Gradle、Producer；不生成或验收`libs.jar`；不运行30项`Configuration.resolve()`。
- 不修改`apps/services`产品源码，不集成main，不创建v10.1.6。
- 不修改系统网络、全局Git配置、ACL/owner、共享SDK或未知guest；不下载工具、不结束未知进程、不清理历史资产、保护文件或refs。
- 不申请或绕过平台额外安全权限。平台UI提示不等于运行时失败；以真实命令回执为准。
- 不因本任务完成自动放行后续门禁。

## 5. 交付与终态

交付报告需记录实际测试命令/入口、固定源码身份、正负例分别的真实结果、15秒总耗时、原始退出证据位置、receipt与Hash/schema/UTF-8/原子发布核验、fallback调用证据、工作树状态、产品Tree身份及未完成项。发布前确认脱敏，普通non-force发布后回读Commit/Parent/Root/Blob与原始字节；本任务不修改产品源码。

成功终态：`D0_C_GATE2_TARGETED_POSITIVE_NEGATIVE_PASS / AWAITING_ASTRA_INDEPENDENT_REVIEW / FULL_37_CASE_SUITE_NOT_RUN`。

失败终态：`D0_C_GATE2_TARGETED_FAIL / FULL_37_CASE_SUITE_NOT_RUN / AWAITING_ASTRA_REVIEW`。

阻断终态：`D0_C_GATE2_TARGETED_BLOCKED / BUDGET_CONSUMPTION_REPORTED / FULL_37_CASE_SUITE_NOT_RUN / AWAITING_OWNER_DIRECTION`。

无论正负例是否通过，交付后立即停止等待Astra独立验收。**60秒完整37案例suite仍未获授权**；只有Astra审查本次回执后、Owner再次明确放行，才可进入下一Gate。

## 6. 永久保留状态

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

Owner已授权的仅是一次15秒定点正负例。不得扩展为SDK或产品集成授权。