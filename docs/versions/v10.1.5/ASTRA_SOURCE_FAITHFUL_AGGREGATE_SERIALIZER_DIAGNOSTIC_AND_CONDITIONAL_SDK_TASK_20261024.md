# EliteSync v10.1.5｜源同构Aggregate Serializer诊断与条件式Writer/SDK任务

日期：2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / ORIGINAL_AGGREGATE_OBJECT_NOT_PERSISTED / SOURCE_FAITHFUL_RECONSTRUCTION_NOT_RUN / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_AUTHORIZED_UNTIL_WRITER_PASS / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**

## 0. 目标和总门禁

Astra复审上一候选0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5：13个body字段和9种case摘要字段的静态来源已记录，但PSParameterizedProperty创建/发现点到aggregate的完整赋值链未证明。原fixture-body.json与fixture-body.tmp未保存；前轮受限合成图8节点、0循环、3处截断不能证明原对象无循环。SOURCE_PROVENANCE_INSUFFICIENT成立，上一轮正确停止。

本任务是新的、有界LOCAL_ONLY预算：用固定源码的实际字段生产表达式和New-ReceiptParser工厂，建立明确标记为SOURCE_FAITHFUL_MINIMAL_RECONSTRUCTION的最小body，再用同一个JavaScriptSerializer进行逐字段与整体序列化对照。它不是原始37案例现场对象，不能声称原对象已复现。目的是判断固定源码表达式生成的最小对象是否足以产生同类PSParameterizedProperty/循环错误，并在能复现时定位最小失败字段集合。

若15秒内最小重建未复现同类错误，或虽复现但无法在限定尝试中隔离最小失败字段集合，立即停止并保留根因UNKNOWN。只有同源最小body确实复现并定位具体字段/字段组合，才可在任务新副本实施有证据的primitive投影，随后逐门执行定点aggregate正负例、完整37案例suite、非作者复核、最多一次新Sandbox、Producer和30配置解析。任一级失败立即STOP，不重跑已消费预算。本任务不授权完整原fixture、Git/Flutter/Gradle/Sandbox在D0-A期间运行。

## 1. 固定authority

- 仓库 zcx369658780/EliteSync-v10。开工fresh核live main、Root及完整apps/services Tree。任务发布前main a812da146cb1a83042841ccf9fc1abd7247cd70b，Root e11e6d1764f5f83cc66c110edb2ff90d3cad0e73；唯一接受产品仍v10.1.4，apps Tree 3468a3dd97da7accfda2539a0f8d8f68931a6110、services Tree 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 唯一连续研发起点 0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5，Root bba458cf1f054276f6ee519ceede25f0636ec8ea，sole Parent 0ef15686104e0260c3abb34071b8c731f577094a；待验apps Tree 785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree 1e1e20bb3500bedb1a521e5f2ddeece915d09424必须保持。
- 最新Astra复审 aggregate_source_provenance_insufficient_independent_review_20261024.md Blob 7eae0044f8c1621a5e6fdf8a8f637462b1596385；上一Codex报告Blob e780aada0ede8430afed81d2a48c02b0eb88c42a、Manifest Blob e5b5c00096d82b1b43b8d269533fc4198bd6d84b；前一复审 aggregate_cycle_path_not_proven_independent_review_20261024.md Blob daa51c855078bed5f97b7a9c1839d926fbb38e43。
- 固定源fixture.ps1 SHA256 146d2e159dcac6bc773fffe4571d6ec5ec5729ad365e3e4118a2f4e4cea86c61；fixture-plan.json bc9f413fa6f612687762b6419217623e4b83818225080feebf6608b576f26b5e；receipt_writer.ps1 8930af018f129f00ac27cc141df5e7f662a77c2d88f5a61dd7ed9a330e74ba1a；receipt-schema.json 1d0f85833a30bac04e1647b4ba66e560794932872bed7d6bf9e091bb3edba652。仅在本任务新副本工作，不覆盖失败原件。
- 源结构：fixture.ps1第95行建立13字段ordered body，第96行调用(New-ReceiptParser).Serialize($body)，第97–99行只在序列化成功后写/读回/Move；New-ReceiptParser在receipt_writer.ps1第31–34行创建JavaScriptSerializer并设置长度/深度。原live body不存在；前轮合成图观察到$.started/$.finished为PSObject包装String，但不是原现场类型证据。
- 历史Writer失败：fixture.ps1:96报告PSParameterizedProperty循环引用，原对象图未保存。Decimal保存回放的$.seconds:System.Decimal是独立事实；历史SDK 600秒截止与约269秒后迟到PSInvalidCastException也分别保留，不推断同因。
- 固定工具继承值：Flutter3.41.7/Dart3.11.5/engine 59aa584fdf100e6c78c785d8a5b565d1de4b48ab、framework HEAD cc0734ac716fbb8b90f3f9db8020958b1553afa7、Gradle8.14 bin SHA256 af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab、JDK17.0.18.8、AGP8.11.1、KGP2.2.20。base50环境Hash 78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52；增加三个精确Git子进程键后的runtime53 Hash 6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723，不能混称。ANDROID_PREFS_ROOT任意大小写键必须缺失，ANDROID_USER_HOME批准归属不变。
- 已验证DAG :flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug。旧DAG targetPath=lib/main.dart、dartDefines=null，因此ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN保持。正式resolver init与artifact policy从最新正式Manifest读取精确原值，不得从摘要猜测。

## 2. D0-A｜一次源同构最小重建与Serializer对照（总时限15秒）

1. 只在任务独立LOCAL_ONLY临时目录中建立最小body，保留第95行13个字段的同源生产表达式：typed RunId、固定plan的expected count、List[object].Count/ToArray、Get-Date -Format o两处、Stopwatch.Elapsed.TotalSeconds、currentCase、failureType/failureCode变量形状及两个整数literal。cases使用一个按固定源结构建立的有序summary，覆盖9种摘要字段；用安全合成值并明确actualCount=1。必须标SOURCE_FAITHFUL_MINIMAL_RECONSTRUCTION / ORIGINAL_OBJECT_NOT_PERSISTED，不得声称是原37案例body。
2. 调用固定New-ReceiptParser工厂并保留同样JavaScriptSerializer设置。只对已知字段值逐字段Serialize，再对完整13字段最小body Serialize。最多32次序列化尝试，全部计入同一15秒预算；不得执行fixture.ps1本体、37个case、未知getter、ToString、ErrorRecord序列化、任意DLL反编译或通用递归对象图walk。
3. 每次序列化前只记录GetType().FullName/null与明确的基础/容器类型，不写实际字段值。捕获异常仅记录异常类型、安全摘要、字段/组合与阶段。若完整body失败但单字段都通过，可在同一预算内对已知字段组合做有限对照；不得超过32次Serialize或15秒。
4. 只有实际观察到与历史同类PSParameterizedProperty/循环异常，且单字段或有限组合对照定位最小失败字段集合，才标SOURCE_FAITHFUL_REPRODUCER_IDENTIFIED。即便如此也必须注明是源同构重建，不是原37案例对象。
5. 若未复现、无法定位、超时、子进程退出未确认或需访问未知getter，立即STOP，标MINIMAL_RECONSTRUCTION_DID_NOT_REPRODUCE或MINIMAL_SERIALIZER_FAILURE_PATH_NOT_ISOLATED；不得投影、运行aggregate正负例或完整suite。

## 3. D0-B｜仅在复现并定位后投影

只有D0-A实际复现同类错误并定位最小失败字段/字段组合，才可在任务副本对该字段实施primitive-only投影。使用显式白名单schema（string、finite number、boolean、null、受限数组/字典），保留必需字段；不将PSParameterizedProperty、ScriptProperty、ErrorRecord、Job或任意运行时对象交给serializer，不用ToString硬转复杂对象、不删字段掩盖失败。未知类型走独立失败路径。记录最小diff和before/after Hash；若字段来源仍不能解释，STOP。

## 4. D0-C/D｜定点与完整Writer验证

仅D0-B投影通过非作者前置静态复核后，才允许一次定点aggregate正负例，总时限15秒。正例验证primitive aggregate的UTF-8、schema、Hash、run ID、expected/actual count、逐项状态和同目录原子发布；负例注入非法运行时对象/循环，明确拒绝且不产生READY/PASS，并由独立fallback写出有效failure receipt。任一失败、回执缺失、schema/hash错误、退出未确认或超时即STOP。

只有定点正负例全PASS且非作者前置复核支持，才允许一次完整37案例suite，总硬时限60秒。必须有37项逐例BEGIN与真实终态、expected=actual=37、每例状态/耗时/receipt Hash/退出结果；正负例、fallback、UTF-8/schema/hash、原子发布、run绑定及进程收口全部PASS才标WRITER_FIXTURE_PASS。任何FAIL/NOT_RUN、body/aggregate缺失、循环、退出不明或超时即STOP，Sandbox预算仍0。不得重跑上一轮失败suite。

## 5. D1-D3｜条件式SDK、Producer与30配置

仅完整suite全PASS且非作者复核通过后，才允许最多一次新独立Windows Sandbox SDK实例。启动前记录进程快照和资源冲突；旧guest状态仍UNKNOWN，不循环查询故障HCS接口、不结束未知进程。新实例自身重新证明Networking Disable、父子IPv4/v6拒绝、无外联网卡/默认路由、只读映射与guest私有写入边界；精确Git信任仅限Flutter framework root，实际HEAD须为cc0734ac716fbb8b90f3f9db8020958b1553afa7。分阶段原子回执核工具、SDK/cache和Flutter CLI真实运行；600秒预算不自动延长，迟到回执不倒填截止PASS。禁止下载、工具升级、共享SDK或系统网络修改。

仅SDK READY后最多一次执行:flutter:packJniLibsflutterBuildDebug及compile依赖。核当次真实libs.jar的任务来源、路径、Hash、ZIP/CRC/entry、JNI内容和x86_64/arm64-v8a ABI；首阻断即STOP。

仅本次libs.jar全PASS后最多一次执行resolvePinnedDebugInputs，真实调用15模块×debugCompile/debugRuntime共30项Configuration.resolve()。逐项记BEGIN/OK/首FAIL/NOT_RUN；首阻断停止，不重试、不下载、不自动修复。30/30通过不等于宿主APK、ICE诊断或RTC安全通过。

## 6. D4｜保护、交付与终态

- 一次非作者有界复核覆盖源同构重建、字段隔离、投影、定点正负例、完整suite及后续条件门。不要重做Decimal、Git trust、GPU、DAG、HOST或历史SDK 600秒任务。
- 开工核验并保留22,094份具名原件、514条引用、五历史根、dirty/SQL/APK/备份/私密日志/SDK及所有失败。仅保护具名对象和选定只读源，不声称全盘或活DB审计。禁止系统网络、全局Git、ACL/owner变更、下载或未知进程清理。
- 从连续候选0d18a2362cedfc545c17bf4c4bc207a8cbb2cfc5作为唯一Parent建立安全后继，只新增AGGREGATE_SOURCE_FAITHFUL_SERIALIZER_REPORT.md和aggregate_source_faithful_serializer_manifest.json，路径均在docs/versions/v10.1.5/。
- 不修改apps/services、旧报告、ACTIVE_STATE、AGENTS或main产品。普通non-force发布并回读Commit/sole Parent/Root、两Blob、原UTF-8字节与完整产品双Tree。私密脚本、日志、路径、PID、环境、SDK/JAR/APK仅LOCAL_ONLY。
- 终态按事实选择：MINIMAL_RECONSTRUCTION_DID_NOT_REPRODUCE / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；MINIMAL_SERIALIZER_FAILURE_PATH_NOT_ISOLATED / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；AGGREGATE_TARGETED_FIXTURE_FAILED / WRITER_FIXTURE_NOT_PASS / SANDBOX_NOT_RUN；WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN；SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN；SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN；REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER；或REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS。

统一保留OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW。完成后立即停止，等待Astra验收，不自动启动后继任务。