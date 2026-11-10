# EliteSync v10.1.5｜Aggregate来源追踪与条件式SDK任务

日期：2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / TARGET_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_AUTHORIZED_UNTIL_WRITER_PASS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**

## 0. 目标与停止门

Astra已复审候选0ef15686104e0260c3abb34071b8c731f577094a。原aggregate对象未保存。唯一受限合成诊断约0.641秒，观察8节点、0循环、0条目标PSParameterizedProperty边、3处截断，未证明原故障路径。上一轮Writer suite失败保持有效。

本任务仅在Owner手动派发后执行。先沿原fixture源代码静态追踪aggregate body每个字段的来源/类型，尤其PSParameterizedProperty如何可能进入Serialize($body)。只有源级证据证明目标字段/对象链，才允许同源最小复现和primitive-only投影。若证据不足，标SOURCE_PROVENANCE_INSUFFICIENT并STOP；不得运行定点aggregate测试、完整37案例suite或Sandbox。

若来源路径明确，才可按以下顺序继续：同源最小复现及投影（最多一轮、15秒）→定点aggregate正负例（一次、15秒）→完整37案例suite（一次、60秒）→非作者前置复核→新独立禁网Sandbox（最多一次）→真实Flutter Debug Producer（最多一次）→真实30配置解析（最多一次）。任何阶段失败立即STOP，不重跑已消费预算。

## 1. 固定authority

- 仓库zcx369658780/EliteSync-v10。开工fresh只读核live main、Root和完整apps/services Tree。任务签发前main为531ec9c22f471fecd030380120551e4bd3bc8f73，Root为94df5664928cb6b82dee9bc830dd3adfd9a32d2e。main唯一接受产品仍v10.1.4，apps Tree 3468a3dd97da7accfda2539a0f8d8f68931a6110、services Tree 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 唯一连续候选起点0ef15686104e0260c3abb34071b8c731f577094a，Root 89e21c47f10451b63883ea68ea9e11fc62578dee，sole Parent d0c1a00218ca68b92c6acf3338e292f956b023cf；待验apps Tree 785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree 1e1e20bb3500bedb1a521e5f2ddeece915d09424不变。
- 最新Astra复审aggregate_cycle_path_not_proven_independent_review_20261024.md Blob daa51c855078bed5f97b7a9c1839d926fbb38e43；上一报告Blob f843b20b3483cd7ab77c8150bf5717309c800880、Manifest Blob 1bf3d2ebd04fde5c61df15ac777b96a62dc1494b；上一任务Blob 8292d6ae1281852bb6dedd46d602456d40e45ab1、上一复审Blob 0bea4cea935de96c8471997142df3ce31eb0d999。
- 诊断pins：SafeAggregateGraph.cs 4e0eac0b810b6b1e845cb21f3547d4212e6514db49d70a89b34f014015e8a536；diagnose_once.ps1 cbd898fd1ea71516bbd56881bd91ffe6e24f96cbf35b5ccef697e07b07e3b621；run_diagnosis_once.py ff981c09fb24c1758ddf73c7c9644334f3b6686b41f7069b243c474cb42565e0。Writer失败pins与历史失败证据均只读，所有修改只在本任务新副本中进行。
- 固定产品诊断源码commit 1522466faf798b719ccff281de7584f043946437、app Gradle Blob bdb8e241d3e0defd1793c90b5f730c2facd7433d只读。工具版本、50键环境Hash及53键精确Git子进程环境Hash沿用正式复审与任务原值，不能混称；ANDROID_PREFS_ROOT任意大小写键必须缺失，ANDROID_USER_HOME归属不变。
- 已验证DAG为:flutter:compileFlutterBuildDebug→:flutter:packJniLibsflutterBuildDebug。旧DAG targetPath=lib/main.dart、dartDefines=null，因此ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN保持。历史600秒截止、迟到PSInvalidCastException、Decimal保存回放与本轮aggregate诊断分别保留，不推断同因。OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS保持。

## 2. D0-A：静态来源追踪，不运行writer或Sandbox

1. 读取fixture.ps1第95–96行、body构造helper、New-ReceiptParser、Serialize调用前对象建立代码和37案例结果组装代码。按字段记录路径、源表达式、生产者、可证类型、运行时类型是否实际观测、是否可能为PowerShell运行时对象及能否安全投影。
2. 追踪PSParameterizedProperty的具体创建点/来源表达式及进入body的赋值链。必须给出文件、行范围和变量赋值链；不得从类型名称猜测来源。不得执行未知getter、调用ToString、序列化任意body或扩大通用对象图遍历。
3. 原fixture-body.json与fixture-body.tmp未保存，标ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED。上一受限合成图8节点、0循环、3处截断不证明原图无循环。若源级证据不足，SOURCE_PROVENANCE_INSUFFICIENT / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN并立即停止。

## 3. D0-B至D0-D：有条件的最小复现与Writer验证

只有D0-A证明目标字段链后，才可用同一生产者/赋值路径做最小同源复现。不能手工注入自引用冒称复现。若只能模拟类型，标SYNTHETIC_TYPE_ONLY_NOT_SOURCE_REPRODUCTION并STOP。

目标链路确证后才可投影到显式primitive-only schema（string、finite number、boolean、null、受限数组/字典）。不得将PSParameterizedProperty、ScriptProperty、ErrorRecord、Job或任意PowerShell运行时对象交给JSON serializer；不得用ToString硬转复杂对象或删必需字段。未知类型走独立失败路径，投影需限制深度/大小并检测循环。

定点aggregate正负例一次，硬时限15秒；验证正常primitive aggregate及明确拒绝的运行时对象/循环负例。正常与失败回执都须UTF-8、schema/Hash读回、同目录原子发布；失败fallback必须独立于同一writer。任一失败立即STOP。

只有定点正负例全PASS且非作者前置复核支持，才允许一次完整37案例suite，整体硬时限60秒。必须有37项逐例BEGIN与真实终态、expected=actual=37、每例状态/耗时/receipt Hash/退出结果。正负例、fallback、UTF-8/schema/hash、原子发布、run绑定和进程收口全PASS才可标WRITER_FIXTURE_PASS。body或aggregate缺失、任何FAIL/NOT_RUN、循环、退出不明或超时即STOP，Sandbox预算保持0。不得重跑上一轮失败suite。

## 4. D1-D3：条件式SDK、Producer与30配置

只有完整37案例suite全PASS且非作者复核通过，才允许最多一次新独立Windows Sandbox SDK实例。新实例自身重新证明Networking Disable、父子IPv4/v6拒绝、无外联网卡/默认路由、唯一映射与只读源；精确Git信任只限Flutter framework root，冻结HEAD须为cc0734ac716fbb8b90f3f9db8020958b1553afa7。分阶段原子回执验证工具、SDK/cache和Flutter CLI实际运行；600秒截止不自动延长，迟到回执不倒填PASS。禁止下载、工具升级、共享SDK改动或系统网络修改。

仅SDK READY后，最多一次执行:flutter:packJniLibsflutterBuildDebug及已验证compile依赖。核当次真实libs.jar任务来源、路径、Hash、ZIP/CRC/entry、JNI内容与x86_64/arm64-v8a ABI；首阻断停止，不重试。

仅本次libs.jar全PASS后，最多一次运行resolvePinnedDebugInputs，真实调用15模块×debugCompile/debugRuntime共30项Configuration.resolve()。逐项记BEGIN/OK/首FAIL/NOT_RUN；首阻断停止，不重试、不下载、不自动修复。30/30通过也不等于宿主APK、ICE诊断或RTC安全通过。

## 5. D4：保护、交付和终态

- 一次非作者有界复核覆盖源字段追踪、同源复现、投影、定点正负例、完整suite及后续条件门。不要重做Decimal、Git trust、GPU、DAG、HOST或历史SDK 600秒任务。
- 开工核验并保留21,999份具名原件、513条引用、五历史根、dirty/SQL/APK/备份/私密日志/SDK及全部失败。仅对具名对象和选定只读源保护，不声称全盘或活DB审计。禁止系统网络、全局Git、ACL/owner变更、下载或未知进程清理。
- 从候选0ef15686104e0260c3abb34071b8c731f577094a作为唯一Parent建立安全后继，只新增两份docs：AGGREGATE_SOURCE_PROVENANCE_AND_CONDITIONAL_SDK_REPORT.md及aggregate_source_provenance_and_conditional_sdk_manifest.json，路径均在docs/versions/v10.1.5/。
- 不修改apps/services、旧报告、ACTIVE_STATE、AGENTS或main产品。普通non-force发布，回读Commit/sole Parent/Root、两Blob、原UTF-8字节和完整产品双Tree。私密脚本、日志、路径、PID、环境、SDK/JAR/APK仅LOCAL_ONLY。
- 终态按事实选择SOURCE_PROVENANCE_INSUFFICIENT / AGGREGATE_CYCLE_PATH_NOT_PROVEN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；AGGREGATE_TARGETED_FIXTURE_FAILED / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN；SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN；SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN；REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER；或REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS。

统一保留OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW。交付后立即停止，等待Astra验收，不自动启动后继任务。