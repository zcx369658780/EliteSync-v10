# EliteSync v10.1.5｜Aggregate来源链不足｜Astra独立复审

日期：2026-10-24（Asia/Singapore）

**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / SOURCE_PROVENANCE_INSUFFICIENT / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN / SDK_NOT_READY / PRODUCER_NOT_RUN / FORMAL_RESOLVE_NOT_RUN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 1. 固定Git对象与产品边界

- Codex候选Commit 0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5，Root bba458cf1f054276f6ee519ceede25f0636ec8ea，唯一Parent 0ef15686104e0260c3abb34071b8c731f577094a。GitHub compare ahead1/behind0，仅新增报告和Manifest两份docs。
- 报告 AGGREGATE_SOURCE_PROVENANCE_AND_CONDITIONAL_SDK_REPORT.md Blob e780aada0ede8430afed81d2a48c02b0eb88c42a；Manifest aggregate_source_provenance_and_conditional_sdk_manifest.json Blob e5b5c00096d82b1b43b8d269533fc4198bd6d84b。
- Astra直接读取Commit、报告、Manifest、compare和候选/Parent完整Tree。候选与Parent apps Tree均785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree均1e1e20bb3500bedb1a521e5f2ddeece915d09424。复审开始时main d3fe0afddef6d58ea35a5b95489bcbaa7766b71c、Root 5acf1b884b5ecd8b4daf9e94203f3529dc060d43，产品仍为v10.1.4已接受apps 3468a3dd97da7accfda2539a0f8d8f68931a6110／services 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 本任务固定Astra复审 aggregate_cycle_path_not_proven_independent_review_20261024.md Blob daa51c855078bed5f97b7a9c1839d926fbb38e43，前任务Blob 9bf4c9d1ee603a58ab8f9f029050aff4d4d89e81，前报告Blob f843b20b3483cd7ab77c8150bf5717309c800880／Manifest Blob 1bf3d2ebd04fde5c61df15ac777b96a62dc1494b。

## 2. 本轮真实进展与停止是否正确

- 本轮仅对固定源文件做静态文本、已保存JSON及Hash核对。原 fixture-body.json、fixture-body.tmp 与原活对象图没有保存，继续标记 ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED。未运行原代码、serializer、getter、ToString、对象图遍历或新的PowerShell对象采样。
- 报告对 fixture.ps1 第95–96行作了源级梳理：第95行直接建立ordered aggregate body；第96行直接调用 (New-ReceiptParser).Serialize($body)；第97–99行只在序列化成功后才写入/读回/Move临时文件。可见代码未将aggregate body先送入 Copy-ReceiptValue 或 Write-Receipt。receipt_writer.ps1 第32–34行仅显示创建并返回 JavaScriptSerializer、设置长度/深度，未包含该serializer的property discovery或PowerShell适配器实现。
- 报告记录13个顶层body字段和9个case摘要字段的来源。可见摘要来自显式ordered字典、字面量、字符串/hash/数值与Boolean等；负例中的原始 $v/$x 或ErrorRecord未在可见摘要literal中直接赋值。但这只能证明可见赋值表达式，不足以排除运行时wrapper、外部serializer行为或间接引用。
- 先前受限合成图观察到 $.started／$.finished 为 PSObject包装String，另有3处截断；这不是原37案例对象的runtime type snapshot，也没有建立从任何字段到 PSParameterizedProperty 的目标赋值链。不能将日期字段直接宣布为根因。
- 报告没有越过门禁：同源复现0次、投影未实施、定点aggregate fixture 0/1、完整37案例suite 0/1、Sandbox/Flutter CLI/Producer/正式解析全部0次，30配置NOT_RUN。没有产品源码变化。非作者审阅为只读源核对，不是运行时复验。

## 3. 独立裁决

**BLOCKED_DELIVERY_ACCEPTED_WITH_OBSERVATIONS / SOURCE_PROVENANCE_INSUFFICIENT / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS**。

接受该停止交付。字段来源表是有用的静态证据，但不能补齐外部 JavaScriptSerializer 对PowerShell runtime wrapper/成员的实际行为，也不能证明原对象的具体循环链路。原对象缺失与运行时对象链未知是事实，不应被一般推断填补。此时不应直接实施投影或启动Sandbox。

## 4. 下一步建议：一次源同构的最小serializer复现

仅静态文本追踪已到达其证据边界；下一份任务应转为一个明确授权的、LOCAL_ONLY、有界的源同构最小运行实验，而不是继续扩大通用对象图遍历。

1. 从固定 fixture.ps1 第95行构造逻辑与 New-ReceiptParser 实际工厂建立最小aggregate body。保留13个顶层字段的同源生产表达式，并用一个按源结构建立的有序case summary代表 cases；明确标 SOURCE_FAITHFUL_MINIMAL_RECONSTRUCTION / ORIGINAL_OBJECT_NOT_PERSISTED，不得宣称重建了原37案例运行对象。
2. 仅在新任务的临时副本中，记录每个顶层字段与summary字段的安全类型元数据，然后用同一 JavaScriptSerializer 对每个已知字段单独序列化，再对完整最小body执行一次序列化。通过受限的字段删减/组合对照，在同一总预算内找出最小失败字段集合；不执行未知getter、不调用ToString、不递归序列化ErrorRecord，也不运行完整37案例fixture、Git/Flutter/Gradle/Sandbox。
3. 若确实复现相同 PSParameterizedProperty/循环异常，记录最小字段集合、真实字段类型、异常类型与安全摘要，之后才可设计最小primitive-only投影；若单案例body不复现，明确 MINIMAL_RECONSTRUCTION_DID_NOT_REPRODUCE，保留原根因UNKNOWN，不可凭此宣称原故障不存在。
4. 该诊断是新的LOCAL_ONLY执行预算，只允许一次，整体硬时限15秒含启动、逐字段对照、完整body尝试、结果落盘与子进程退出确认。任何不明异常、超时或无法确定退出立即STOP；不得再扩大对象图访问或运行后续fixture。
5. 只有最小复现确实定位了可修字段/对象包装，才可在后续Owner手动派发的任务里批准投影与Writer验证；本任务本身不授权投影、完整suite、Sandbox、Producer或30配置解析。

最终继续保持 OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED。