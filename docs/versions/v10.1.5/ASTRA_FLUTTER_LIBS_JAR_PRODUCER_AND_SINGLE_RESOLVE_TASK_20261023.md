# EliteSync v10.1.5｜Flutter派生libs.jar真实生产者与有界生成＋唯一离线30配置解析｜Codex综合长任务

日期：2026-10-23（Asia/Singapore）。

**ASTRA_TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / EXECUTION_NOT_STARTED / PRODUCER_UNKNOWN_PENDING_LOCAL_VERIFICATION / CONDITIONAL_DEBUG_PRODUCER_BUDGET_0_OF_1 / CONDITIONAL_FORMAL_RESOLVE_BUDGET_0_OF_1 / NO_HOST_APK / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_PRODUCT_MAIN_INTEGRATION / V10.1.6_NOT_STARTED**

## 0. 本次唯一目标与Owner可见的新许可

本任务供Owner**手动派发本地Codex**。发布GitHub文档本身不能启动本地执行。Owner手动派发本任务时，才授权以下严格受限、合并在一份综合长任务中的下一步：

**先真实确定Flutter模块的`Flutter/build/intermediates/flutter/debug/libs.jar`由什么受控task产生，是否必须先执行编译/打包才有权要求`Configuration.resolve()`返回它；若独立静态/task-graph前置均PASS，允许在本任务隔离LOCAL_ONLY现成工具和副本中最多一次执行产生这一真实Flutter debug类库文件的**具名官方生产者task及其必要依赖链**。如果官方producer证据表明它必须通过**Flutter模块内部Debug AAR**链才能生成，可在任务图明确限定Flutter模块debug、产物仅在任务自有root、无宿主APP APK、无release/profile、无下载和无额外环境权限时，将这条debug AAR生产链计入同一**producer 1/1**许可。此为**新增、有条件的Debug产物生成授权**，不得把前轮“禁止AAR”倒改为当时已经授权，也不允许扩展到真实设备。**

只有确实生成了正确归属的`libs.jar`、做完有界结构/Hash/正反输入核验、且producer无新的失败时，才可再执行**最多一次**原`resolvePinnedDebugInputs`正式15模块×2配置离线解析。任何一级失败立即STOP；不为保证成功预先修复未知缺项。**哪怕30项全部PASS也要停，不得自动构建宿主APK或开启RTC实验。**

绝对排除：修改任何Git跟踪`apps/services`、Flutter/Gradle/AGP/Kotlin/JDK/Android SDK版本或锁文件；公网/支付/Push/正式身份；新Maven/SDK/Pub下载、网络依赖、Wrapper；宿主APP的`:app:assembleDebug`或`flutter build apk`；设备/ADB/AVD、麦克风/摄像头、SFU/RTC/DB/API、LAN/UDP/TURN/防火墙；历史清理、main产品集成、R2与v10.1.6。不能伪造空JAR、复制另一个版本JAR、关闭transform/忽略缺文件、跳`:flutter`模块、用graph-only替代文件解析。

## 1. 固定Authority、Git身份与证据

- 正式仓库`zcx369658780/EliteSync-v10`。开工重新GET live main Commit/Root/apps/services，不能把2026-10-23编制时的纯文档main当作永远不会变化。main仍以v10.1.4完整接受产品为唯一可合状态：apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 连续未接受v10.1.5候选唯一起点：`5653baf6c07f27ea11217edd1bd50f47acb5621f`，唯一Parent `9e3333151125deb9985e86324811c1737a4fa90d`，Root `64c5166df1861ec0179cf44374224a4aee4befb5`，完整apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本任务两子Tree严格不变。固定已审诊断构建源码 `1522466faf798b719ccff281de7584f043946437`、app构建文件Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`不得改。
- 前轮受控报告`docs/versions/v10.1.5/ICE_VARIANT_SELECTION_SCOPED_FIX_AND_SINGLE_RESOLVE_REPORT.md`，Blob `2f90d937f1e00f3433c18aa2edebcad1ef51490d`；前轮manifest`ice_variant_selection_scoped_fix_and_single_resolve_manifest.json`，Blob`ec8f7db7cb6882f336174ccf5ef0ccb96624fe14`；最新[Astra独立审查](flutter_libs_jar_first_blocker_independent_review.md) Blob **`1646e3fe9c32e7f294e9e838c65cec9f2745e655`**。旧LOCAL_ONLY stdout`1478B / SHA256 4a9525b5564cdddaafd6cbcbb68981befbba5f641f16b3b0d9ab91bf2658b21b`、stderr`1202B / SHA256 bcd399d4c0a4dce460278fe29c69ab0b90311b2e57d00be491a167609ad75258`。上轮唯一真实解析1/1 exit1、`BEGIN1/OK0/29 NOT_RUN`；`IdentityTransform`要求任务相对`project/apps/flutter_elitesync_module/.android/Flutter/build/intermediates/flutter/debug/libs.jar`却不存在。前轮11项Gradle fixture与旧50键环境及HOST 1/1 PASS为继承证据，**本轮不重跑其相同项目**。
- 固定可信Gradle8.14 bin SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`；Flutter3.41.7、Dart3.11.5、engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、AGP8.11.1、Kotlin2.2.20、JDK17.0.18.8。上一轮隔离诊断解析器严格`android-classes-jar` policy的init SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`、policy SHA256`bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`，正确保留compile/runtime用途和所有传递依赖。不重建另一套解析语义。
- 原生Git仓的`apps/flutter_elitesync_module/.android/Flutter/build.gradle`未在本轮Git固定对象中获取到，此类Flutter生成目录及真正producer身份**不能凭路名发明**；应以Owner Windows LOCAL_ONLY具名工具/实际Flutter3.41.7插件和Task DAG为证。

## 2. D0｜保护、来源及真实生成者定位（实际Producer/Resolve均0次）

1. 定点只读核原报告Manifest、固定Git对象、原Flutter模块生成`.android`工程、Gradle plugin task注册/输出、`IdentityTransform`被消费的绝对路径归属，区分实际`Flutter/build/intermediates/flutter/debug/libs.jar`与宿主app或其它debug/release/profile目录的同名文件。必要时利用已有Gradle8.14的任务配置/计划诊断**最多一次**`--dry-run`或等价只读Task DAG，不执行producer、Flutter AAR或宿主APK；记录此步虽不生成产物但可能合法写入独立Gradle cache。
2. 必须找出**真实producing task + its outputs + dependency edge**，并核该task在受控项目/版本/SDK/源输入与两个debug ABI上的合同。Gradle`Configuration.resolve()`可在producer完成前触发文件transform，不能因为它失败就断言缺少外部Maven JAR。检查错误是不是“真实任务未执行导致的缺产物”，以及完成producer后既有isolated task root里会出现哪一个debug libs.jar。若无具名producer、完整task DAG包含宿主APP APK/release/profile/下载/不可控全局副作用，给`PRODUCER_UNPROVEN_OR_OUT_OF_SCOPE`并STOP。
3. 原`D:/EliteSync-v10` dirty、所有工作树/原SQL/APK/私密日志/备份/旧受控卷、旧未授权`.zip.part`、历史失败和现有隔离工程及被保护原证一律保留。上轮311141件具名保护、503旧refs/5根/153长路径warning是**历史口径**；以任务影响文件和实际读写根重新做有界原证与派生文件归属核验，不再每轮无缘由复制7.3GB或无界扫描全盘。严禁`reset/rebase/stash/clean/prune/force`。

## 3. D1｜条件式真实Flutter debug生产者预算（最多1次）

1. 先出示Owner可追溯的**唯一生产者选择**、完整必要依赖任务图与输出目标，确认它仅在独立任务运行root写入，使用已批准官方现成Flutter/Gradle/SDK/Pub/Maven缓存且**严格离线**，不会隐式调用Wrapper、下载依赖、升级SDK、操作网络或启动其他系统。若原生工具支持单目标执行优先最小Flutter debug类库/打包任务；确实只能经**Flutter模块debug AAR链**产生且前置task DAG可核安全时，允许这一次受控debug AAR产物生成，所有产物仅归属本任务，不将其作为整版可交付APK。**不允许宿主APP assemble、release/profile或端侧安装**。
2. 只有D0与一次非作者有界前置复核全部PASS才可执行一次选定producer目标（含它的真正依赖任务），不允许多个不同生产者挨个试；有新异常立即STOP，不改产品、仓库锁/工具/系统环境、host构建路径或重新下载。该producer运行预算明确独立于后继正式30配置解析预算。
3. 若producer exit0，必须再验证真实`libs.jar`在当前任务`.android/Flutter/build/intermediates/flutter/debug/`下**由本次同一source/task产生**，有原始任务/Gradle输出证据、bytes/SHA256/合法ZIP/JAR结构和实际内容、debug变体、归属路径，非历史缓存替身/零entry占位或手工copy，且不与预先存在的文件混淆。额外debug AAR如生成，记录字节与用途但不得冒称宿主APK构建完成。缺文件、尺寸异常、非法Jar或来源无法追溯，标`PRODUCER_OUTPUT_NOT_VALIDATED` STOP，后继解析0次。
4. 始终继承50键sealed env，严格拒绝任何大小写`ANDROID_PREFS_ROOT`，保留`ANDROID_USER_HOME`的已批准目录及原版本/路径/Gradle home一致性。Producer若需要修改系统/User/Machine环境、连接外网或超出isolated root，STOP。

## 4. D2｜只有生产者产物通过才运行一次真正30配置解析

- 保留已有严格`android-classes-jar`选择规则，仍要走实际`Configuration.resolve()`，不以Maven坐标/graph解析/文件路径存在假装通过。最多**一次**直接Gradle8.14 bin`resolvePinnedDebugInputs --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`及已冻结三诊断flags、四iceDiag路径属性、任务自有正确`-I`。如果发现producer产物写入与解析器读取的工程根不同，只允许定位并报告，不手工复制或重绑跟踪代码。
- 按真实顺序输出15模块×debugCompile/debugRuntime的`BEGIN / OK / first FAIL`，首个新阻断（缺GAV、新variant错、文件/transform、env或任务错误）立即STOP，剩余`NOT_RUN`。只有30/30实测PASS才标`OFFLINE_30_CONFIG_RESOLUTION_PASS`；没有合法证据不得推断真机RTC、安全AC05、Push、AEC或APK已完成。
- 不论D2成功或失败，**不执行Flutter新一轮AAR、宿主APK、assembleDebug/ADB/手机、SFU/RTC/DB/API/云端/网络/防火墙**；本次产生Flutter内部debug AAR如有，仅属受控producer回执，不能作为下一门生产授权。

## 5. D3｜非作者复核、证据分层与唯一交付

- 同一任务至多一次非作者有界复核，以producer task DAG/作用域、生成JAR来源及D2真实计数为重点；必要时把运行前静态门与运行后结论合成同一复核，不触发额外Gradle试验。旧fixture和HOST不重跑。明示历史保护初次失误、合法Gradle daemon/cache/lock写入、未核全部历史文件的局限，不把非作者审查当Astra终验。
- 原完整stdout/stderr、机器路径、SDK、二进制JAR/AAR、私密env、测试数据、旧APK/SQL均只放LOCAL_ONLY；GitHub只存脱敏证据/固定Hash及运行计数。防止公开历史设备路径、API key、JWT、私聊/证件。
- 以连续待验候选`5653baf6c07f27ea11217edd1bd50f47acb5621f`为sole parent，在干净新后继工作分支只新增：
  1. `docs/versions/v10.1.5/FLUTTER_LIBS_JAR_PRODUCER_AND_SINGLE_RESOLVE_REPORT.md`
  2. `docs/versions/v10.1.5/flutter_libs_jar_producer_and_single_resolve_manifest.json`
- 不在候选直接改`apps/services`、旧报告、Astra审查、`ACTIVE_STATE.md`或GitHub main。普通non-force提交、完整parent/Root/新docs Blob/两产品Tree/raw bytes回读后立即STOP，交Owner→Astra独立复审。

合法终态依证据择一：`PRODUCER_UNPROVEN_OR_OUT_OF_SCOPE / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN / NO_APK`；`PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN / NO_APK`；`PRODUCER_OUTPUT_NOT_VALIDATED / RESOLVE_NOT_RUN / NO_APK`；`REAL_FLUTTER_DEBUG_OUTPUT_VALIDATED / OFFLINE_RESOLUTION_FIRST_BLOCKER / NO_HOST_APK`；`REAL_FLUTTER_DEBUG_OUTPUT_VALIDATED / OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_HOST_APK`。

统一继承：**`V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`**。即使30项全PASS也要等Owner下一次明确决策。
