# EliteSync v10.1.5｜D0-B 两字段投影范围与实际调用点门禁修复任务

日期：2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / SAME_TASK_FOCUSED_CONTINUATION / D0_A_BUDGET_CONSUMED_NOT_RESET / D0_B_GATE1_ONLY / TARGETED_FIXTURE_NOT_AUTHORIZED_IN_THIS_TASK / NO_SANDBOX / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN**

## 0. 任务目的与终点

本任务是Owner明确同意的、针对既有阻断点的一次聚焦续接。只解决原正式任务中的 D0-B / Gate 1 静态范围与实际调用点问题，不重置项目、不重做诊断、不自动推进后续阶段。

唯一目标：在任务自有的 LOCAL_ONLY 续接副本中，形成一个可审查的最小修订，并用源代码与调用链证据证明：

1. 投影严格限定在源同构最小重建中已定位的两个字段 `$.started` 与 `$.finished`；
2. 其他字段不会被通用解包、转换或重写；
3. 投影确实位于当前 Writer 的真实 aggregate 序列化边界，且实际 `WriteAggregate` 调用路径确实调用该投影；
4. 所有必需字段及既有 schema/业务语义保持；
5. 非作者静态复核能够基于可读取的准确源码和最小 diff 确认上述条件。

**本任务到 Gate 1 为止。不得在本任务内运行定点 fixture、完整37案例 suite、编译/执行新投影、Sandbox、Flutter/Gradle、Producer 或30项配置解析。** Gate 1 候选交付后停止，等待 Astra 独立复核；后续阶段必须按原正式任务单的门禁另行放行。

## 1. Authority、正式来源与新鲜状态核验

- 原正式任务：`docs/versions/v10.1.5/ASTRA_SOURCE_FAITHFUL_AGGREGATE_SERIALIZER_DIAGNOSTIC_AND_CONDITIONAL_SDK_TASK_20261024.md`，Blob `009a12cae75ef3b714f0156d4edbca2db1660719`。
- 前置 Astra 复审：`docs/versions/v10.1.5/aggregate_source_provenance_insufficient_independent_review_20261024.md`，Blob `7eae0044f8c1621a5e6fdf8a8f637462b1596385`。
- 前次阻断交付候选：`a9bb54d78e357ce15bf673a654baa849e264a32f`，唯一 Parent `0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5`，Root `fd3c38b1d5e8a11b2ae5f31f33a2d52437a8d7b0`。该候选只增加报告与Manifest；不是产品接受或main集成。
- 前次 Codex 报告：`docs/versions/v10.1.5/AGGREGATE_SOURCE_FAITHFUL_SERIALIZER_REPORT.md`，Blob `6dcf99aa2ab42c44a37e96fd72fb911f72a37c9b`；Manifest Blob `12127deed43fad11ed5b045c34c53ceb7b6e1d8f`。
- 前次 Astra 阻断复核：`docs/versions/v10.1.5/D0_B_STATIC_SCOPE_BLOCKED_ASTRA_REVIEW_20261024.md`，Blob `8f627cf0d442f935f756435d4d7d97890bcfdb71`。
- Owner 提供的本地证据索引：`C:/Users/zcxve/.codex/v1015-source-faithful-serializer-conditional-sdk-20261024/AGGREGATE_PRIMITIVE_CONTINUATION_INTAKE.md`。此路径仅为 Owner/Codex 报告的本地位置，Astra 不声称可直接访问。
- 开工时重新只读核验 live main、Root Tree、当前任务单与前次候选分支 head。SHA仅为已核验时点身份，不得假定永远不变。不得 force push、reset、clean、stash、prune 或覆盖历史候选。
- 发行时 main 参考为 `1dadff67edea9533cb012caffb7d142589c29686` / Root `73c965e94aedc9a778ca1c53e0ed6777ff642dae`；开工必须重新核验。当前接受产品仍为 v10.1.4 apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。

## 2. 不重置预算与证据事实

- D0-A 已消耗：一次诊断、15次 Serialize、约0.688秒，子进程退出已确认；不得重跑 D0-A 或用新的诊断代替本次修复。
- 已有证据只支持 SOURCE_FAITHFUL_MINIMAL_RECONSTRUCTION 中 `$.started` 与 `$.finished` 分别触发同类异常。原始37案例对象未恢复，历史 `PSInvalidCastException` 的根因仍 UNKNOWN。
- `AggregatePrimitive.cs` 上一版为 LOCAL_ONLY 草稿，SHA-256 `c6469958b98b50c9f6d4e07b2cbce3ac5987ced635306e3d6d612b6047353c83`，12489 bytes；未编译、未执行、未接入调用点。先保存原始草稿及其 Hash，不覆盖或删除。
- 原任务的15秒定点 fixture、60秒完整37案例 suite、Sandbox、Producer、libs.jar与30项解析预算均未消费；但它们在本专项任务中仍关闭，不得因为预算未消费而自动启动。

## 3. 允许的写入范围

仅允许在任务自有 LOCAL_ONLY 续接副本内修改为解决 Gate 1 所必需的 helper/writer harness 副本和必要的源清单。原始草稿、失败证据、旧报告/Manifest、原正式任务单、ACTIVE_STATE、AGENTS、apps/services 产品源码均保持不变。

可以保留、修订或弃用 `AggregatePrimitive.cs`；文件名本身不是验收目标。验收目标是最小、路径明确、实际被 Writer 调用的两字段投影。先确认实际运行语言和现有 helper 的加载方式：

- 若已有受支持的 C# 编译/加载路径，可在静态源码中证明它被当前 Writer 调用；不得在本任务内编译或执行。
- 若没有现成的 C# 加载路径，不得假定孤立 `.cs` 文件会自动生效，也不得新建宽泛的编译/工具链路径。优先在任务副本中对现有 Writer 的原生调用边界作最小、静态可审查的改动。
- 如必须改变既有正式 schema、字段含义、公共产品代码、SDK/系统配置或超出 LOCAL_ONLY 范围，停止并报告，不得自行扩大授权。

## 4. Gate 1 修复要求

### A. 两字段严格限定

投影必须显式识别完整路径 `$.started` 和 `$.finished`，且仅在这两个路径上执行指定的字符串 wrapper 解包。不能以“所有 PSObject 的 BaseObject 若为 String 就统一解包”作为通用规则。

- 对这两个字段，先做安全类型检查；只有已证明的字符串基础对象才可投影为 primitive string。
- null、非字符串、未知包装或意外类型必须走显式失败路径，不可默认成功、丢弃值或随意调用 `ToString()`。
- 其他11个已通过的单字段集合以及 cases/摘要字段不得被本投影重写；保持其原有对象和值语义。
- 保留13个顶层必需字段和原 schema。不得通过删字段、改 expected/actual count、缩小 cases、伪造 PASS 或修改序列化器配置掩盖失败。

### B. 证明真实调用链

静态交付必须明确展示并引用：

1. 当前 Writer 中 `WriteAggregate`（或等效实际函数）的真实定义与文件相对路径；
2. 该函数如何构造/接收 aggregate body；
3. 两字段投影的唯一入口和路径条件；
4. 投影结果如何成为 `New-ReceiptParser().Serialize(...)` 的实际输入；
5. helper 若独立存在，其加载/调用路径为何真实有效；若没有有效加载路径，应将 helper 接入现有 Writer 原生调用点，而不是仅添加一个未使用的类。

只存在方法定义、注释、文本搜索命中或一个未被引用的 `.cs` 文件，均不构成调用点证据。不得用未执行的推测冒充运行证明；本任务只要求静态证明调用链，不要求执行。

### C. 最小差异与静态验证

提供修改前后逐文件 diff、原稿与新稿 SHA-256、必需字段清单及投影前后类型合同。静态核对必须证明：

- 唯一语义变化是对 `$.started` 与 `$.finished` 的受限投影及其必要的显式失败处理；
- 其他字段、schema、Run ID、expected/actual count、cases、fallback、UTF-8、Hash读回和原子发布合同没有被删减或放宽；
- 新代码真实连到序列化边界，没有绕过原有失败处理或将非法对象标记为 READY/PASS；
- 未修改产品 apps/services，也未改系统网络、全局 Git、ACL/owner、共享 SDK、未知 guest 或历史资产。

## 5. 非作者复核与可读证据

非作者必须审查实际源文件及调用点，而不只是审查作者撰写的结论。

按 `docs/workflow/TEMP_REVIEW_EVIDENCE_PROTOCOL.md` 的现行协议，建立一个独立、短期的审阅分支：

`review/temporary-evidence-v1015-d0-b-projection-scope-gate-20261024`

仅放入完成独立审查所必需且经过公开资料标准脱敏的最小材料：修订后的 helper/writer 副本、实际调用点、必要的静态检查源码/清单、最小 diff、SHA-256清单与简短审阅说明。不得上传个人绝对路径、PID、环境快照、密钥、真实业务数据、私密日志或原始LOCAL_ONLY intake全文。删除分支不能保证清除 Git 历史，因此上传前必须检查实际内容。

若不能安全脱敏或发现源文件含不可公开内容，停止远端上传并交付明确阻塞原因；不要通过上传完整LOCAL_ONLY目录来绕过问题。

非作者复核必须逐项给出 PASS / FAIL / NOT_PROVEN：字段范围、其他字段不变、schema/必需字段保留、Writer真实调用链、helper加载路径、最小diff与无产品源码变化。Gate 1 只有所有必需项 PASS 才能交 Astra；任何 FAIL/NOT_PROVEN 均保持阻断。

## 6. 明确禁止的执行

- 不重跑 D0-A，不重新运行15次 Serializer 诊断。
- 本任务不编译、不执行投影、不运行任何 fixture；定点正负例与37案例 suite 均 NOT_RUN。
- 不启动/查询/关闭/终止 Sandbox 或未知 guest，不运行 Flutter/Gradle/Producer，不生成或验收 libs.jar，不运行30项 Configuration.resolve()。
- 不下载、升级或安装工具/依赖，不联网获取 SDK，不修改系统网络、防火墙、hosts、全局 Git、ACL/owner 或共享 SDK。
- 不修改 apps/services，不合并候选到 main，不接受 v10.1.5，不进入 R2，不启动 v10.1.6。
- 不覆盖或删除旧草稿、失败证据、原始38份JSON、历史 refs、五个历史根、dirty root、SQL/APK/备份或任何未知资产。
- 不把平台 UI 的 Daybreak/“无法显示此内容”提示当作运行失败；只有实际命令/工具拒绝才可记录为环境阻断。不得申请额外权限或规避安全机制。

## 7. 交付与终态

Codex须集中交付：

1. LOCAL_ONLY 完整 intake 更新或新增报告，含实际路径、原/新 SHA-256、最小 diff、真实调用链、字段类型合同和所有未完成项；
2. 非作者静态复核结果及对应审阅分支 Commit/Tree/文件 Hash；
3. 在原候选分支 `codex/v10.1.5-source-faithful-serializer-conditional-sdk` 上，从当前远端分支实际 HEAD 创建普通 non-force 后继，只新增：
   - `docs/versions/v10.1.5/D0_B_TWO_FIELD_PROJECTION_SCOPE_GATE_REPORT.md`
   - `docs/versions/v10.1.5/d0_b_two_field_projection_scope_gate_manifest.json`
4. 回读并报告候选 Commit、唯一 Parent、Root、两文档 Blob/原UTF-8字节、apps/services完整Tree与非作者审阅分支身份；候选仍不得合并main。

候选基线预期为前次远端分支 HEAD `a9bb54d78e357ce15bf673a654baa849e264a32f`，但必须开工fresh核验；若分支已前移、出现额外提交或身份不一致，不要覆盖或强行重置，停止并报告。

终态只能按证据选择：

- `D0_B_GATE1_PASS / AWAITING_ASTRA_INDEPENDENT_REVIEW / TARGETED_FIXTURE_NOT_RUN`；或
- `D0_B_STATIC_SCOPE_BLOCKED / AWAITING_OWNER_DIRECTION`。

即使 Gate 1 PASS，也不得在本任务中继续 Gate 2。立即停止，等待 Astra 独立审查与后续明确放行。

## 8. 永久保留的产品门禁

`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`。

本任务仅修复静态范围和调用点证据，不代表历史根因已全部证明，不代表Writer运行通过，不代表SDK READY，不代表APP或版本已接受。