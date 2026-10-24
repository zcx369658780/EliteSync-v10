# EliteSync v10.1.5｜Receipt拒绝类型捕获→完整Writer fixture→条件式SDK Sandbox→Producer与30配置解析

2026-10-24（Asia/Singapore）

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / RECEIPT_WRITER_NOT_PROVEN / SANDBOX_NOT_AUTHORIZED_UNTIL_D0_PASS / CONDITIONAL_SANDBOX_0_OF_1 / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN**

## 0. 目标与预算

Astra已复审候选 f3fbc2c58615095a9065afd11cc2369f7241343f：唯一完整fixture suite 1/1 exit1，终态 RECEIPT_TYPE_REJECTED（receipt_writer.ps1第27行），但具体被拒类型未捕获；三份合成正例不构成完整writer PASS，没有aggregate结果、完整负例或有效failure receipt。上一轮已停止，未启动Sandbox、Flutter CLI、Producer或正式30配置解析。

本任务是新的独立预算，只有Owner手动派发后才执行。先捕获具体类型并通过完整writer fixture，再考虑新Sandbox；不猜类型、不覆盖旧失败、不把当前fixture错误倒填为历史PSInvalidCastException根因。任一级失败立即STOP。

## 1. 固定authority

- 仓库 zcx369658780/EliteSync-v10。开工fresh核验live main、Root及完整apps/services。任务签发前main e2d8b1fa18fb9524a9c92bcf87b59547a36c3a02、Root 778ad830858a5dd1d2363cc09e5f68321228ccfa；main唯一接受产品为v10.1.4，apps Tree 3468a3dd97da7accfda2539a0f8d8f68931a6110、services Tree 0cb1f9d19659291a462488b3686fd0a07a6698ac。
- 连续候选起点 f3fbc2c58615095a9065afd11cc2369f7241343f，Root 07f5e2fd381f16862bdf43eef306b23096290042，sole Parent a219fbb45edd0c746dce92af2f6abf661091bab4；候选apps Tree 785822ca072943c5bfefa3ccc37ede01c2af5164、services Tree 1e1e20bb3500bedb1a521e5f2ddeece915d09424必须保持不变。固定诊断源码 1522466faf798b719ccff281de7584f043946437与app构建Blob bdb8e241d3e0defd1793c90b5f730c2facd7433d只读。
- Astra独立复审 sandbox_sdk_receipt_fixture_type_rejection_independent_review_20261024.md Blob 75f63bb7ccdba7b92a74ab55d4fc852a614ced6d；上轮报告Blob a13a2e18b8628a7d63e9595184d68438fbfb0546、Manifest Blob e3f72ccd6141dcb3031b8a3fe3883e6af9ae8856；原任务Blob 8ec8ad6c1d76de7bd295101ffebe5e3ea69e15aa。先读取这些固定证据和ACTIVE_STATE最新首段，不重做旧Git信任、GPU、DAG、HOST或历史fixture。
- 失败候选本地脚本pins：receipt_writer.ps1 SHA256 f9318882881b2058cada4e923354198d41b812a3f6d34ecced6b3ed0996ca024；receipt-schema.json d6d6838fdc7e7b6cd6416bbb351a16bdeb5d24b4eb836efc00c7bd4ae31173b5；fixture.ps1 1f3dc2ff3814f6dbdc4da175cdfdfc8aa5221d3b619c34443e3dcd75bbcff468；guest_runtime_driver.ps1 65a56d01efbc000b8de83867f767e9f3c627420ee2c89daf0433be097eea14ed；driver.diff.txt 1a51bc84547f87a73c6c3830b6c6364906e2e4cf1a8a450424a56f8aa4aa9cbe。均为失败候选，只可在本任务独立副本修改。
- 历史600秒截止 2026-10-24 15:13:39.026 +08，迟到异常 15:18:08.1167661 +08；PSInvalidCastException发生于framework-identity的Write-Receipt/ConvertTo-Json，具体旧输入类型和延迟原因UNKNOWN。历史单仓Git trust与冻结HEAD cc0734ac716fbb8b90f3f9db8020958b1553afa7实测PASS，不能替代本轮writer或SDK READY。
- 固定Flutter3.41.7/Dart3.11.5/engine 59aa584fdf100e6c78c785d8a5b565d1de4b48ab、Gradle8.14 bin SHA256 af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab、JDK17.0.18.8/AGP8.11.1/KGP2.2.20。50键env Hash 78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52；添加3个精确Git子进程键后的53键Hash 6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723，不能混为相同环境。任意大小写ANDROID_PREFS_ROOT必须缺失，ANDROID_USER_HOME批准归属不改。
- 已验证DAG为 :flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug，目标模块debug libs.jar。旧DAG的 targetPath=lib/main.dart、dartDefines=null，因此 ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN持续。严格resolver init SHA256 2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f、artifact policy SHA256 bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58固定不变。OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS继续保留。

## 2. D0-A：捕获实际拒绝类型（不启动Sandbox）

1. 在新任务独立LOCAL_ONLY副本中读取完整writer/schema/fixture/调用点及原始失败回执。明确区分当前RECEIPT_TYPE_REJECTED和历史PSInvalidCastException，不假设同因。
2. 在拒绝动作发生前增加独立类型诊断，只记录字段名、输入GetType().FullName、null/数组/字典/标量类别、预期schema类型、失败阶段、run ID与异常类型；不记录敏感值。诊断使用UTF-8纯文本或其他不调用同一JSON writer/Copy-ReceiptValue的通道，不递归序列化ErrorRecord。
3. 仅运行一次定点负例，整体硬时限15秒。不得使用未证明有界的PowerShell Job收尾链。若使用子进程，记录PID、创建时间、可执行路径、命令行及run ID；超时停止后续，只有对精确匹配的本任务fixture进程才允许一次正常关闭，不碰未知进程。
4. 如果仍无法捕获具体类型，终态 RECEIPT_REJECTION_TYPE_CAPTURE_FAILED / WRITER_NOT_PROVEN，立即STOP；不跑完整suite、不启动Sandbox。捕获成功后，只按证据对输入做最小primitive-schema归一化，保存源diff和Hash，不覆盖历史失败。

## 3. D0-B：完整Writer fixture一次

仅D0-A类型捕获成功、最小修正有证据且非作者前置复核PASS，才允许一次新的完整writer suite。它是本任务新预算，不能抹除上一轮失败。

整套suite硬时限60秒，涵盖启动、全部案例、结果读回、进程收口和aggregate落盘，不能只限制某一个Wait。覆盖schema全部必需字段、实际Flutter identity三行、null/数组/字典、Unicode/Windows路径；并覆盖缺字段、错误类型、深层嵌套/循环引用、数组或字节超限、非法JSON值等负例。

正常和失败回执都必须先写临时文件，再读回UTF-8 JSON、schema及Hash，最后同目录原子Move；失败fallback必须独立于同一writer，记录run ID、阶段、输入类型、错误类型与Hash，不记录敏感值。aggregate必须列出预期/实际案例数、正负例状态、起止时间、总耗时、回执Hash及进程收口状态。三份正例或suite exit0单独均不足以PASS。

移除未证明有界的Job收尾链。60秒是整套suite硬截止；到期仍无aggregate或有未确认进程即STOP，不得将父监督器停止冒充子进程退出。任一正例、负例、fallback、schema/hash读回或总时限失败，都不得启动Sandbox。只有全套PASS并经一次非作者前置复核支持才可进入D1。

## 4. D1：条件式新Sandbox SDK实例，最多一次

仅D0-A和D0-B全PASS后，才允许最多一次新独立Windows Sandbox SDK实例。启动前记录本轮进程快照和资源冲突；旧guest状态继续UNKNOWN，不反复调用故障HCS接口、不终止未知进程。

新实例内重新验证Networking Disable、父子IPv4/v6连接被拒绝、无外联网卡/默认路由、映射只读源与guest私有写入边界；复用精确的子进程Git信任方案，实际读回冻结framework HEAD；核Flutter/Dart/JDK/Gradle和本地缓存。不得下载、升级、修改共享SDK或全局配置。

使用已通过的writer写入分阶段原子回执：guest boundary、seed/cache、toolchain、Git HEAD、Flutter CLI开始/完成、SDK READY。只有Flutter CLI真实启动、缓存及SDK身份全部PASS且最终有效回执读回，才能标SDK_RUNTIME_READY_FOR_STANDARD_DEBUG。SDK阶段硬截止600秒；迟到回执单独记录，不倒填截止PASS，不自动重试或创建第二个Sandbox。

## 5. D2：真实Producer最多一次

只有SDK READY和非作者前置门全PASS，才可最多一次执行已验证的 :flutter:packJniLibsflutterBuildDebug 及compile依赖。使用固定Gradle8.14离线参数和双ABI，不下载、不改产品源码。核本次真实生成的libs.jar来源、任务归属、路径、before/after、Hash、ZIP结构/CRC、真实JNI条目及x86_64/arm64-v8a来源。空Jar、历史复制或来源不明不能PASS。首阻断即STOP，不修复重试。

## 6. D3：真实30配置解析最多一次

只有本次libs.jar全部验证PASS，才可最多一次执行 resolvePinnedDebugInputs，实际调用15模块×debugCompile/debugRuntime的Configuration.resolve()共30项。保留严格init、artifact policy、固定工具与离线环境；逐项记录BEGIN/OK/首FAIL/NOT_RUN，遇首个新阻断立即停止，不下载、不换仓库、不自动修复。30/30实际PASS仍不等于宿主APK、ICE诊断或RTC安全通过。

## 7. D4：保护、交付与终态

- 一次非作者有界复核覆盖类型捕获、fixture总时限、fallback与原子落盘，以及条件式Sandbox/Producer/解析结果。不得重新跑旧失败或全仓考古。
- 保留21,704份具名保护原件、511条引用、五历史根、原dirty/SQL/APK/备份/私密日志/SDK与所有旧失败；数量按开工真实核验，保护只限具名对象，不声称全盘或活DB审计。不得改系统网络、安全设施、全局Git、ACL、共享.git或未知进程。
- 从候选 f3fbc2c58615095a9065afd11cc2369f7241343f 作为唯一Parent建立后继，Git只新增：
  1. docs/versions/v10.1.5/SANDBOX_SDK_RECEIPT_TYPE_CAPTURE_AND_CONDITIONAL_PRODUCER_REPORT.md
  2. docs/versions/v10.1.5/sandbox_sdk_receipt_type_capture_and_conditional_producer_manifest.json
- 不修改apps/services、旧报告、ACTIVE_STATE、AGENTS或main产品。普通non-force发布，回读Commit/sole Parent/Root、两份新Blob、原文字节和完整产品双Tree。私密脚本、完整日志、绝对路径、进程标识、环境、SDK/JAR/APK保持LOCAL_ONLY。
- 终态按证据选择 RECEIPT_REJECTION_TYPE_CAPTURE_FAILED / WRITER_NOT_PROVEN；WRITER_FIXTURE_FAILED / SANDBOX_NOT_RUN；SDK_READY_NOT_RECEIVED_WITHIN_BOUND / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN；SDK_RUNTIME_PRECONDITION_BLOCKED / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN；SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN；REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER；或 REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS。

统一保留 OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW。交付后立即停止，等待Astra验收，不自动执行后续任务。
