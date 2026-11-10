# EliteSync v10.1.5｜启动器环境回执因果纠正＋单次30配置离线解析｜Codex综合长任务

日期：2026-10-23，Asia/Singapore。

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / PRELAUNCH_CAUSE_UNKNOWN / FORMAL_RESOLVE_BUDGET_NEW_0_OF_1_PENDING_DISPATCH / NO_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_R2 / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. Authority与任务目标

Owner此前要求“Astra验收后继续推进”，Astra已完成本轮正式阻断交付独立复审。**本文件是供Owner手动派发的单一有界长任务；GitHub发布本身不代表本地执行授权，也不表示已经查明启动器原因。** Owner若决定派发，Codex可以在下面严格的D0→D4阶段门内自主完成本任务，不再拆成多个先只读后修复的微任务。

唯一目标：**查明并在任务自有LOCAL_ONLY Python启动器中正确处理上轮新增的跨进程完整环境摘要断言失败；只有根因明确、原环境安全约束仍可证明且静态/fixture门PASS时，最多一次运行真实离线`resolvePinnedDebugInputs`，对15模块×2配置尝试真正的`Configuration.resolve()`**。正式30配置运行在本任务前尚未进行；上轮Python exit1不消费上轮Gradle 0/1预算，但也不自动将上轮许可顺延到本任务。Owner手动派发本任务才启用**新的一次**受限Gradle解析预算。

禁止对旧失败做猜测后直接解除校验、隐藏环境差异、随意排除变量、打印环境值、改变依赖或升级工具。**如果无法识别差异或证明修复前置条件，停在有界诊断交付，不为达到正式resolve而放宽门禁。**

## 1. 先读固定来源与不得变化的身份

- GitHub仓库`zcx369658780/EliteSync-v10`。发布本任务前的live main须在实际开工重新GET；它主要为已接受v10.1.4产品和后继docs，不能拿main源覆盖v10.1.5未接受连续候选。
- 本轮唯一连续起点：`d45c0fae755fb97e1df9cbdc875965725a88d969`；唯一Parent `e24b6d5db8063e1207e9939612352c0f1d8c9bdf`；Root `faba969437b7bdf2d02a0489f543fe11d8a67019`。v10.1.5 apps Tree固定`785822ca072943c5bfefa3ccc37ede01c2af5164`，services Tree固定`1e1e20bb3500bedb1a521e5f2ddeece915d09424`，均**不允许改动**。固定产品构建source `1522466faf798b719ccff281de7584f043946437`，跟踪`apps/android/app/build.gradle.kts` Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`保持。
- 最新报告`docs/versions/v10.1.5/ICE_30_CONFIG_OFFLINE_RESOLUTION_REPORT.md` Blob `7364b046472a5255624d29a65326bc76db5d6aed`；Manifest`ice_30_config_offline_resolution_manifest.json` Blob `6539b49e7766812e5a65d05368341a153a2c71a7`。**本轮Astra独立结论**：`docs/versions/v10.1.5/ice_30_config_prelaunch_block_independent_review.md`，开工应读当前固定Blob并核文内审查范围；正式原任务`ASTRA_ICE_30_CONFIG_OFFLINE_RESOLUTION_SINGLE_TASK_20261023.md` Blob `4a5d9fa5932c8ee815453ee855d7671820f56d3b`。引用旧报告时区分已取得实证与UNKNOWN。
- 之前Astra正式HOST复审 `agp_android_prefs_env_single_variable_fix_independent_review.md` Blob `fa83daeb88e55c1d549384dc970e729f0b9a9d63`。已接受的HOST 1/1 exit0及25 fixture PASS**不重跑**。受控原helper SHA256 `4a40266ae988fbeaa079892aa0654f3555f62f415391463f5d13e3cebd846a8a`，修复后任务专属helper SHA256 `1be8f3bbf89fe6d9f2d4fc1168afb85bef286af8d30648c79daff3399a0f013d`；真实正式Gradle子进程尚未使用该清洁环境。
- 冻结Gradle8.14、Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、JDK17.0.18.8、AGP8.11.1、Kotlin2.2.20。可信Gradle bin SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。已有官方同engine x86_64_debug/arm64_v8a_debug POM/JAR属前轮Codex LOCAL_ONLY已获证据，不等于其它配置的正式依赖全PASS。

## 2. D0｜有界保护与可审查启动器入口（不运行Gradle）

1. 先核远端Commit/Parent/Root/docs Blob、候选产品双Tree、当前受保护本地连续工作树；检查上轮`run_resolution_once.py`第11行原字节、实际准备回执的expected SHA256 `cc513212c588756e00e984fdbc7e443377cd3afb4dd8f6ea26413bf94e550f37`，以及所有已留存的Python exec解码回执、运行入口、环境构造函数、父子进程边界、初始化时机与静态保护记录。**上轮actual Hash和差异键原本未捕获**，必须继续标历史`UNKNOWN`；本轮从新采样生成的actual不能冒称上轮原始actual。
2. 历史已具名保护上轮224486个文件、501 refs、五历史根、153条旧Windows长路径warning、64785个已复制输入及五个已生成路径绑定文件，须按真实范围保护，不假定全电脑均做过哈希。旧dirty、未提交内容、SQL/APK、密钥、旧`.zip.part`、cache、恢复卷、SDK及所有失败原证不可盲覆盖或`reset/rebase/stash/clean/prune/force`。优先在**现存且可证无污染的任务隔离副本**上执行，不再为了启动器断言复制7.3GB或反复全仓盘点；确实无法证明复用安全则停止，不偷用历史输出。
3. 新建本任务独有的LOCAL_ONLY脚本/检查回执，不原地改上轮`run_resolution_once.py`或任何跟踪`apps/services`文件。任何私密环境值、绝对路径、stdout/stderr、完整环境字典仅本地保存，不能上传GitHub或项目源。

## 3. D1｜查明环境摘要不一致的可复现来源（Gradle新运行0次）

1. **先分析静态控制流**：expected与actual摘要分别在哪个进程/时点计算、是否使用相同排序/编码/Windows变量名大小写归一化、继承与覆盖、run-specific TaskRoot/GRADLE_USER_HOME/ANDROID_USER_HOME、新启动器自加字段和哈希范围。不得仅因存在差异就断言具体原因。
2. 在**新任务自有**、不启动Gradle/Android插件的安全Python观察fixture中至多做**一次受控对照采样**，采集两端实际hash与带归属的**差异变量名称**及必要分类（新增/缺失/值不同），不输出value、敏感路径或密钥，敏感名称也可按稳定匿名ID映射只在LOCAL_ONLY解码。原上轮actual仍UNKNOWN。确立一致的跨进程environment canonicalization；如果观察数据不足以定位实际差异，`CAUSE_UNKNOWN_STOP`，不得推定或运行Gradle。
3. 只允许在本任务局部修正**启动器回执生成/比较方式或已经证实的非安全关键环境规范化**；不能简单删除assert、无界忽略整个env、不检查真实`ANDROID_PREFS_ROOT`继承、将该键设空、改变`ANDROID_USER_HOME`已批准归属、跳过Gradle版本/固定bin/hash、放宽SDK来源/diagnostic flags/隔离目录和离线保护。若差异影响以上安全关键变量或任何未知注入，则明确报差异并STOP，不能在本轮顺带修整其它系统级环境。
4. 用同一固定fixture（无需多轮集成调度）证明：一致环境正常通过；任意大小写`ANDROID_PREFS_ROOT`再现必须拒绝；`ANDROID_USER_HOME`变位拒绝；任务Root/Home/SDK/Gradle固定身份漂移拒绝；跨进程差异能够产出**可诊断而脱敏**的证据。原断言失败和原回执原字节保留。一次非作者有界静态复核必须确认没有削弱前轮安全门。若任何一项失败，终止于`LAUNCHER_RECEIPT_DIAGNOSTIC_OR_FIX_BLOCKED`，**不运行正式依赖解析**。

## 4. D2｜单次真实离线解析（严格以前述PASS为条件）

只有D0/D1全部PASS、没有新副作用/下载风险、无历史资产覆盖或旧进程/锁冲突、真正解析器将消费**同一已验证的有效子进程环境**时，才能执行最多**一次**固定的`resolvePinnedDebugInputs`，直接调用核定Gradle8.14本地bin（禁止Wrapper），保留此前固定init、三诊断flags、四iceDiag路径属性、`--offline --no-daemon --console=plain --max-workers=2`及`-Ptarget-platform=android-x64,android-arm64`。需要绝对路径等实参时读取LOCAL_ONLY上一轮已验证argv，不从本任务文档猜编。
 
必须进入真正的`Configuration.resolve()`：按原15模块×2配置记录每一项BEGIN/OK/失败及真实exit。**30/30 OK才可写`OFFLINE_30_CONFIG_RESOLUTION_PASS`**，不能用Task Ready/HOST/fixture当PASS。首个具体坐标缺失、新插件错误或其它异常立即STOP，不重试、不下载、不改init版本/仓库/锁文件/SDK，也不因依赖缺项自动扩大为修复任务。无论解析PASS/FAIL，后续`syncFlutterAar`、`assembleDebug`、APK及手机/RTC**一律0次**。

未经另行明确授权，整个任务禁止修改Windows全局变量、联网取得Maven/SDK、运行`flutter pub get`、切换工具版本、数据库/API/SFU/RTC/ADB/模拟器、USB/防火墙/LAN/UDP/TURN、主线产品集成、正式R2或历史清理。

## 5. D3｜保护、证据分层与非作者复核

- 非作者仅一次有界复核D1修复的具体安全门、任何敏感日志泄漏、D2真实调用/配置计数及首错误归类，不重复25项历史HOST fixture或全仓源码审计。修复同任务的普通低风险本地脚本错误可在D1条件内一次修正验证，**正式Gradle预算不得因非作者意见而重置**。
- 正确记录新增任务自有工具输出/Gradle缓存元数据/锁/daemon可能变化及独立owner范围；旧保护、旧500/501 refs、五历史根、原失败和未授权partial ZIP不删不盖。受限保护证明不夸成全磁盘、数据库或真机逐byte验收。结束只关闭本次亲启进程。
- Python/D1的真实输出仅可标`CODEX_REPORTED_LOCAL_ONLY`；Astra在GitHub能独立复核固定源码/文本、Commit/Tree、脱敏摘要，但不能声明已亲自运行Gradle。

## 6. D4｜唯一集中交付、停止

连续候选必须从`d45c0fae755fb97e1df9cbdc875965725a88d969`有界新建干净后继，**仅新增docs两文件**：
- `docs/versions/v10.1.5/ICE_ENV_RECEIPT_CORRECTION_AND_SINGLE_RESOLVE_REPORT.md`
- `docs/versions/v10.1.5/ice_env_receipt_correction_and_single_resolve_manifest.json`

不得更改此前验收/失败、`ACTIVE_STATE.md`或任何`apps/services`；原始完整环境、个人路径、SDK/POM/JAR、私有stderr及APK等维持LOCAL_ONLY。普通非force提交，远端读回唯一Parent/Root/两Blob及完整apps/services两子Tree；不会在报告正文虚填尚未发生的Commit/Hash。最终结果供Astra独立审查，不由Codex自签ACCEPTED、不合产品main。

唯一终态从真实结果选择：
1. `CAUSE_UNKNOWN_OR_UNSAFE_ENV_DELTA / FORMAL_RESOLVE_NOT_RUN / NO_APK`；
2. `LAUNCHER_RECEIPT_CORRECTION_BLOCKED / FORMAL_RESOLVE_NOT_RUN / NO_APK`；
3. `LAUNCHER_RECEIPT_CORRECTED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_APK`；
4. `LAUNCHER_RECEIPT_CORRECTED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_APK`。

统一保留`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。**本任务结束即STOP，不自动启动APK构建或后继开发。**
