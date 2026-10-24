# EliteSync v10.1.5｜SDK预检回执序列化定点纠正→单次Sandbox实测→条件式Producer与30配置解析｜Codex唯一综合长任务

日期：2026-10-24（Asia/Singapore）
**ASTRA_TASK_ISSUED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / SDK_RECEIPT_CAUSE_NOT_YET_PROVEN / NEW_SDK_SANDBOX_BUDGET_0_OF_1 / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_FORMAL_RESOLVE_0_OF_1 / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Owner权限、综合目标与总停止条件

Astra已经独立核验上轮`a219fbb45edd0c746dce92af2f6abf661091bab4`：**53键任务进程级单仓safe.directory核验及真实冻结Flutter framework HEAD均PASS；此后SDK完成回执在600秒截止前缺失，约269秒后取得写`framework-identity` JSON回执时PowerShell PSInvalidCastException**。不能将晚到异常倒填600秒截止观察，也不能以“Git仍失败”重新修同一问题。

Owner采用一份连续综合长任务、手动派发Codex的现行工作流。本任务只在Owner将本文件启动Prompt手动派给Codex后生效，GitHub发布本身不触发本机代码执行。

**本任务首要目标**：在不运行新的Sandbox前，用本任务独有LOCAL_ONLY PowerShell/runner脚本对`Write-Receipt`与`framework-identity`回执建立有据的最小序列化纠正：真实读取保存的晚到异常原始脚本、类型/调用链及固定时间戳，优先重现具体错误；若无法重现，则明确`SPECIFIC_PS_CAST_MECHANISM_UNKNOWN`，只可在针对完整schema、真实值类别、负例及输出原子性的有界fixture证实后，发布**一份最小更健壮的LOCAL_ONLY writer**，不得主张历史错误根因已被精确证明。必须另做**分阶段增量回执**避免一个尾端JSON错误吞掉已有Git成功证据，并明确`SDK_READY`只有整条实际预检全PASS才可签。

此前600秒后迟到证据、Owner关闭超时窗口、guest shutdown缺独立证明都必须保留原证；本任务最多**一次**新的独立禁网SDK Sandbox实例，新实例预检及所有进程级安全门实测PASS后才最多一次真实Flutter Debug producer，再由当次有效`libs.jar`证实后最多一次真正30配置`Configuration.resolve()`。**任何门失败就停，不换沙盒、不补跑旧失败、不重启HCS、不force结束无关程序、不自动延长到新的运行预算**。

绝对禁止：改系统/User/Machine网络与代理、hosts、防火墙、服务、注册表或Hyper-V/HCS；安装新VM/WSL/Docker/Sandbox功能、UAC提权、强制批量结束进程；网络或SDK/Pub/Maven补包下载、`flutter precache`/`flutter pub get`、Wrapper、插件/Flutter/AGP/JDK/Gradle升级；变更Git跟踪产品`apps/services`、`build.gradle.kts`、锁文件；改宿主/用户/global Git配置、shared `.git`/ACL/owner；宿主APK、额外Flutter AAR、设备/ADB、RTC/SFU、DB/API、公司服务、主线产品集成、R2、v10.1.6、清理受保护历史。

## 1. Authority与不可变起点

- 仓库：`zcx369658780/EliteSync-v10`。启动时fresh只读核live main Commit/Root/完整apps/services。任务发布前main`e225091f2043c42cfd52e653ace67fbf0e5ed97a`、Root`8e79c42614c17fb25560d4ce3f2f50388bc6dcf0`（后续docs变化会移动）；**唯一已接受v10.1.4产品**apps`3468a3dd97da7accfda2539a0f8d8f68931a6110`／services`0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 未接受研发连续候选唯一起点`a219fbb45edd0c746dce92af2f6abf661091bab4`，Root`e1e0c3a8f7996e3d07ac4ec8960e1287f39f10c5`，sole Parent`dd9b4eb9df9101adf4c0d980135081fd902c656a`。候选完整apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`均严格不变；固定诊断产品源码commit`1522466faf798b719ccff281de7584f043946437`／跟踪app Gradle Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`只读，不用main替换候选。
- 最新[Astra独立复审](sandbox_git_head_pass_sdk_receipt_timeout_independent_review_20261024.md) Git Blob **`706ae77e7292ce104fcafc8ef0af18c72d0fb1f6`**；前轮[报告](SANDBOX_SCOPED_GIT_TRUST_AND_CONDITIONAL_PRODUCER_REPORT.md) Blob`5c8b2c71ca3a6d7b1b1f7442086d93f64ae702bd`；[Manifest](sandbox_scoped_git_trust_and_conditional_producer_manifest.json) Blob`46e8f03b06349cc22bcab2305f121d0e53e04eb0`；上一任务Blob`3cfba96e62befcc495c55279967c5c2b8a3370cd`。优先读取这些固定对象与`ACTIVE_STATE.md`当前首段，不重复整个历史HANK、Flutter GPU、旧HOST/DAG/fixture取证。
- 已支持的**上轮实测成功**：guest `Networking Disable`独立父子IPv4/v6受阻，JDK17.0.18+8/Dart3.11.5/Gradle8.14 exit0；仅当前任务单仓Git trust `safe.directory` command来源与精确framework root PASS，`git rev-parse`实际HEAD`cc0734ac716fbb8b90f3f9db8020958b1553afa7`exit0。其运行环境原50键Hash`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`，添加3个精确Git子进程键后53键Hash`6468110fb2cd275115774ae4813aa769415d2f3d14bcb297ab9d0867457a9723`；两个Hash概念不同，不能称“53键仍等于原50键”。任何大小写`ANDROID_PREFS_ROOT`必须不存在，`ANDROID_USER_HOME`批准归属不改。
- 工具冻结：Flutter3.41.7／Dart3.11.5／engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`／Gradle8.14可信binSHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`／JDK17.0.18.8／AGP8.11.1／KGP2.2.20。旧安全回执仅当前实例有效，下一guest必须自己实测。
- 既有Flutter真实DAG`:flutter:compileFlutterBuildDebug→:flutter:packJniLibsflutterBuildDebug`；模块debug`libs.jar`是真producer对象，非AAR/APK。原DAG`targetPath=lib/main.dart`、`dartDefines=null`，**`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`仍OPEN**。严格解析init SHA256`2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`，artifact policy SHA256`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不变。
- 旧HCS guest查询错误`0x8037011B`使`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`保留；上轮600秒截止、晚269秒序列化异常/Owner报告关闭提示窗口/后来进程未见各自独立，不能合并为“超时造成序列化异常”或“已证guest全部退出”。

## 2. D0｜先在LOCAL_ONLY纠正回执Writer（不运行Sandbox或产品）

1. 只读取上次本地`framework-identity`调用点、`Write-Receipt`及`ConvertTo-Json`周围**完整脚本和类型转换链**、固定源码Hash、异常`System.Management.Automation.PSInvalidCastException`/调用栈、截止和晚到两组实际时间戳及回执文件。重点区别Git命令实际已PASS与JSON输出失败，不再修Git信任配置、旧owner或SDK framework root。
2. 在**本任务自有新副本**提出**一项最小writer纠正**：构造明确、受控、无循环引用的`[ordered]`原始JSON schema，有限深度与有限白名单键；所有值按验证过的原始类型进行可预测序列化（包括null/数组/字典/类型不符），禁止盲目将复杂PS对象转`System.String`、递归dump整个$Error或机器env；保留真实Git root值仅LOCAL_ONLY，公开仅脱敏身份与Hash。所有回执必须先写任务拥有的临时文件、校验UTF-8 JSON可重新读回/必要字段与Hash后**原子替换**，避免半写/空回执被标PASS。对序列化失败返回显式`RECEIPT_SERIALIZATION_FAILURE`并独立保存原始异常摘要，不覆写前轮失败原证。
3. 独立**一次LOCAL_ONLY合成PowerShell fixture套件**（不创建新Sandbox、不启动Git/Flutter/Gradle或用户生产者），以真实`framework-identity`字段类型、深层/非法PS对象、错误值、字符串/路径、缺字段与转码负例检验：成功时`framework-identity.json`和另一个phase receipt具名值读回准确；发生异常时拒绝READY且独立failure receipt仍写入；没有额外env/权限/网络操作。若无法证明writer足够可靠，直接`SDK_RECEIPT_WRITER_NOT_PROVEN / SDK_NOT_RUN` STOP。不能仅通过“文本中有ConvertTo-Json”当fixture PASS，也不因fixture PASS倒称历史转换根因已找到。
4. 必须设计**小而真实的阶段进度回执**：guest准备复制开始/结束、版本工具、禁网、单仓Git trust/HEAD、Flutter CLI开始/完成、最终SDK READY；每阶段写最少必要的时间戳、状态和非敏感身份/Hash，允许host以原子读回辨识最远阶段。单份最终JSON仍不等于所有历史阶段；控制器截止时不可等待虚构的晚回执，并记录失去联络与guest shutdown未确认。避免反复新增几MB以上的全量保护扫描或在进度回执泄露PID/绝对路径/密钥。
5. 一位**非作者有界审阅者**在新Sandbox前完成静态/fixture复核，确认对旧脚本diff只影响回执与阶段证据，不删除安全断言、无新下载/宿主写入或权限放宽。D0全PASS且当前旧资源无已知冲突才允许D1；历史上轮代码、失败JSON/异常原证及SDK stage均保留，不重写。

## 3. D1｜仅一次新Sandbox SDK实例：实际阶段证据与超时保护

1. 只读收集**当次**Sandbox/RemoteSession/共享VM及本任务根资源冲突快照；此前Owner允许在没有已知活跃冲突且新写入与WSB唯一隔离时前进，但不允许假定旧guest全部安全退出。若仍有已知不可归属的资源冲突则STOP，不force kill或修改HCS；无需反复调用失败的`hcsdiag list`。
2. 从前轮已准备的真实SDK输入与22条只读映射构成**一个新的任务独立运行root**，最多启动**一次**Windows Sandbox SDK实例；不得在宿主重复制1.63GB历史SDK。新guest内重新核`Networking Disable`，父子进程向无凭据字面IPv4/IPv6端点的连接被拒绝、无外联网卡与默认路由、映射只读源与guest私有写入界限，任何新不明外联即STOP。
3. 继承前轮已支持的单仓精确`GIT_CONFIG_COUNT/KEY_0/VALUE_0`，但**只给guest当前规范真实Flutter framework root**、无通配/全局/系统配置写入；在当前guest亲自读回1条command来源且HEAD冻结SHA匹配（真实shell只读命令），验证runtime53键扩展差异。此前成功不替代当前Sandbox HEAD验证；也无需再次从头复审170份真实宿主.git/source前证。
4. 分阶段执行必要SDK/Flutter CLI最小版本及cache identity，使用新的writer和阶段回执。只有**实际Flutter CLI启动且成功**、cache/SDK identity及产物读取目录真实可用、没有下游外联/权限/数据破坏，最终`SDK_RUNTIME_READY_FOR_STANDARD_DEBUG`才能PASS。普通Debug与`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`仍分开。
5. 保留**有界600秒宿主截止**作为本轮明确运行预算，不自行无限延长。与上轮不同，截止前能从每段原子回执了解所处阶段；如在截止前没有最终READY/失败记录，立即标`SDK_READY_NOT_RECEIVED_WITHIN_BOUND`并停止放行后续阶段。**不得在host超时后自动创建新实例/重跑producer**；对仍在运行或GUI残留的guest仅记录并交Owner审核，不kill未知进程。若晚回执出现，独立记录其真实时间，不能倒补截止时点PASS。此前600秒耗时原因未证，不能仅通过增大超时冒充修复。
6. Runner中的写入/拷贝/读回需要先核PowerShell类型、返回对象与JSON schema；本轮只修任务自有代码，禁用复杂对象无界序列化。若新的错误导致某个阶段证据缺失，不得用前几轮版本命令PASS代替此实例的SDK READY。

## 4. D2｜仅SDK真正READY后一次producer

只有D1所有实际隔离/工具/SDK/Git/回执/非作者前置门通过才可**最多一次**调用本来已接受`:flutter:packJniLibsflutterBuildDebug`及其`:flutter:compileFlutterBuildDebug`依赖，可信本地Gradle8.14 `--offline --no-daemon --console=plain --max-workers=2`，目标双ABI `android-x64,android-arm64`，同一guest真正没有网络出口。不得执行额外Flutter AAR、宿主APK，不能暗中下载、变更工具版本/依赖锁/追踪产品源码。

本轮当次生成目标`.android/Flutter/build/intermediates/flutter/debug/libs.jar`需有producer exit0与实际文件from task证据；核新Jar的bytes/SHA256/合法ZIP与CRC/entry集合、JNI/native源及期望`x86_64`、`arm64-v8a`来源一致。不对未包含Java.class的JNI Jar无依据判FAIL，但空/历史复制/来源不明的Jar不能PASS。producer首新阻断立即STOP，不做第二轮尝试。

## 5. D3｜仅真实Jar通过后一次正式30配置解析

在与D2同一个已核隔离工程根中最多一次真正运行`resolvePinnedDebugInputs`，严格15模块×`debugCompileClasspath/debugRuntimeClasspath`共30项，必须真实`Configuration.resolve()`，固定init与`android-classes-jar` selection policy、`--offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`及前证三flags/四iceDiag属性。逐项标`BEGIN/OK/首FAIL/NOT_RUN`，首个missing GAV、变体/transform/文件/权限新阻断立即STOP，不自动补依赖、换仓库、下载或尝试下一轮。30/30 PASS也不能认为宿主APK、ICE诊断媒体或AC05真实RTC硬门已经通过。

## 6. D4｜唯一集中交付、保护及终态

- 从连续研发候选`a219fbb45edd0c746dce92af2f6abf661091bab4`建本次安全后继分支，Git**只新增两份docs**：
  - `docs/versions/v10.1.5/SANDBOX_SDK_RECEIPT_CORRECTION_AND_CONDITIONAL_PRODUCER_REPORT.md`
  - `docs/versions/v10.1.5/sandbox_sdk_receipt_correction_and_conditional_producer_manifest.json`
- 不修改`apps/services`、旧review/task/报告、`ACTIVE_STATE.md`、AGENTS、main产品或未接受旧工作树。保留历史510个refs、5历史root/dirty/SQL/APK/恢复备份/旧日志/敏感环境/SDK & Git/.git与未授权part；只对本任务实际触及具名原件做哈希保护，合法guest私有派生单列。文档区分`GITHUB_DIRECT`／`CODEX_REPORTED_LOCAL_ONLY`／`NON_AUTHOR_REVIEW`／`LATE_GUEST_EVIDENCE`／`NOT_RUN`。
- 同一非作者有界审查可前置看D0 writer与安全门并随后核D1-D3真实回执，不能代替Astra终验。只把固定对象、脱敏阶段回执、计数和证据Hash放GitHub；完整原始脚本/日志/env/WSB/SDK/JAR/私有路径/进程标识仍LOCAL_ONLY。
- 普通non-force发布并远端完整回读唯一Parent/Root、2 docs Blob、完整apps/services Tree及docs原UTF-8字节后STOP，Owner回传Astra。

合法终态依实际择一：`SDK_RECEIPT_WRITER_NOT_PROVEN / SDK_NOT_RUN / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`SDK_READY_NOT_RECEIVED_WITHIN_BOUND / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`SDK_RUNTIME_PRECONDITION_FIRST_BLOCKER / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS`。保留原late receipt与截止观察的差异，不混成单一实测原因。

所有终态继承`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`（除非特定一项有新的独立直接证据）。**发布后不得自行启动新的Sandbox、APK/RTC任务或后继版本。**
