# EliteSync v10.1.5｜Owner批准 AGP AndroidDirectoryCreator 限定因果取证｜Codex唯一长任务

日期：2026-10-23，Asia/Singapore。

**OWNER_APPROVED_AGP_DIRECTORY_SERVICE_CAUSE_FORENSIC / PREEXISTING_LOGS_FIRST / CONDITIONAL_ONE_HOST_CONFIG_STACKTRACE / DIAGNOSTICS_ONLY / TASK_READY / OWNER_MANUAL_CODEX_DISPATCH_PENDING / EXECUTION_NOT_STARTED / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 0. Owner授权与本轮明确上限

Owner在Astra对上一 Flutter 同engine 双架构 Debug 工件与隔离构建环境候选 `98c2e4e9f548ee924f4e244e23e7b307fb3afe72` 独立复审、建议“先读已有AGP完整异常链，必要时最多一次`--stacktrace`轻量宿主配置”后，明确回复“可以我同意，请继续”。

本次只允许**对既有`AndroidLocationsBuildService.AndroidDirectoryCreator`创建失败做有界诊断取证**，不授权任何修复行为。采用唯一受控任务，顺序是：

1. **优先只读**核验上一轮属于本项目的真实 `host-config-diag` stdout/stderr、result、daemon Gradle日志、首失败执行参数、`host-config-check.gradle`及合法隔离SDK/Gradle配置快照，辨认**最深`Caused by`和首个能解释失败的系统/文件路径/异常类型**；如果现存证据已足够，**不重新执行任何Gradle**。
2. 仅当全部旧证据确实没有可归因的最深异常时，准许**一次**对**同一诊断测试Android宿主轻量配置目标**（仅`:app:verifyIcePathDebug`）做`--stacktrace`增强的**有界复现**；除了`--stacktrace`和必要的LOCAL_ONLY stdout/stderr完整归档，不改变构建目标、flags、来源、工具链、配置、SDK/项目源码、路径、权限和网络。
3. 只交付客观异常链/因果边界与**最多两个**最小后续“候选处理项”，均须标为**建议，未经本轮授权实施**。如果仍不能定位，诚实给出`ROOT_CAUSE_UNDETERMINED`，不为了发结论做第二次试验。

**不授权**再次运行`resolvePinnedDebugInputs`、Flutter AAR编译或`:app:assembleDebug`，也不允许增加`--debug`/`--scan`、Gradle build scan上传、遥测报告、第三方诊断插件、全设备抓包、管理员/root、任何SDK/Maven/JDK/Gradle下载或版本升级、增量复制新SDK、修改产品/构建源码、工程settings、`gradle.properties`、内层Wrapper、全局缓存、反复刷新依赖或网络代理。**本轮不安装APK、不操作手机/模拟器/ADB、数据库、API、Laravel、guard、SFU、Room.connect、麦克风或音视频；不改LAN/UDP/TURN、防火墙/UAC、RTC安全硬门、v10.1.4 main产品。**

GitHub允许本项目正常的**文档任务/回执**读写，不据此扩大本机依赖源下载权限。

## 1. 固定Authority／已审状态

- 仓库：`zcx369658780/EliteSync-v10`。本次任务签发前 live main **`ec9fc59260502a3d8d5c8801e1356164bd781593`**；它是**已接受的v10.1.4产品＋顾问文档**，不可用其产品代码覆盖待验v10.1.5候选。
- 唯一**本版候选继续点**：上轮最终交付Commit **`98c2e4e9f548ee924f4e244e23e7b307fb3afe72`**，Root **`bba25cedc58a57c174ae241f0a9aa1b36d26e350`**，唯一Parent为固定source **`1522466faf798b719ccff281de7584f043946437`**，source Root **`09a4041a7bdca9eb0ffd9e92a724fe8eeb0d17cf`**。固定完整apps Tree **`785822ca072943c5bfefa3ccc37ede01c2af5164`**，services Tree **`1e1e20bb3500bedb1a521e5f2ddeece915d09424`**。
- 上轮报告：`docs/versions/v10.1.5/FLUTTER_PINNED_ARCH_DEBUG_BUILD_ENV_COMPLETION_REPORT.md` Git Blob **`6c490497e5d5804e6d3b3c48676be4b784a608bf`**；manifest：`flutter_pinned_arch_debug_build_env_completion_manifest.json` Blob **`da2c2a82a6d9500597beb1aa18365b2390dc21e0`**。
- 上轮Astra正式复审：`docs/versions/v10.1.5/flutter_pinned_arch_debug_build_env_independent_review.md`，固定Blob **`4bb7d44c1e4dcba291ce0752fefb5c8ff883be1a`**，裁决`AGP_ANDROID_DIRECTORY_CREATOR_HOST_CONFIGURATION_BLOCKED / ROOT_CAUSE_UNDETERMINED / TARGET_RESOLVE_0 / DIAG_ASSEMBLE_0 / NO_APK / AC05_OPEN`。
- 仅本轮已核的Gradle诊断构建源码文件`apps/android/app/build.gradle.kts` Blob **`bdb8e241d3e0defd1793c90b5f730c2facd7433d`**。诊断路径源码fixture47/47、普通路径6类**静态对照**，不是Android宿主真实config PASS。此轮不得编辑本文件。
- Flutter **3.41.7**／Dart **3.11.5**／engine **`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`**；Gradle **8.14**、JDK **17.0.18.8**、AGP **8.11.1**、项目Kotlin **2.2.20**。已有官方同engine`flutter_embedding_debug`／`x86_64_debug`／`arm64_v8a_debug` POM/JAR从原LOCAL_ONLY文件复用；未验出版方SHA sidecar/签名。
- 上轮受控诊断场所: OWNER LOCAL_ONLY project-copy+`GRADLE_USER_HOME`+`sdk-stage`（约64864件/7.034GB）及独立可信Gradle8.14分发。**这些阶段的项目日志和cache属于LOCAL_ONLY原证，Astra没有在此聊天直接访问其真实文件路径**。不能根据GitHub文档猜测绝对Windows路径或直接操作用户Windows。
- 旧**唯一**轻量宿主配置`:app:verifyIcePathDebug`：约20.044秒、exit1，报错在`com.android.application`插件应用/AGP `AndroidLocationsBuildService` provider创建，最深已**公开**摘要为：
  ```text
  Build file <HOST>/app/build.gradle.kts line: 9
  Failed to apply plugin 'com.android.internal.application'
  Failed to create service AndroidLocationsBuildService
  Could not create provider for value source AndroidLocationsBuildService.AndroidDirectoryCreator
  ```
  原错误中`com.android.tools.build:gradle:null`只是一段展示，**不证明AGP版本真为null**。
- 上轮LOCAL_ONLY原始证据索引（文件名/Hash为Codex报告）：`host-config-check.gradle` 1822B / SHA256 **`32adbf68a6a7d2e20880ba1c95b601b57d8d38fcfd42b9e3b508b7448ddbc9b6`**；`host-config-diag.stdout.txt` 913B / **`eea59d430e3242d9e455976178f3f5c12f11838441880523f6933173a9111e8a`**；`host-config-diag.stderr.txt` 1014B / **`59c8df2eb881e321015bcfb3974faed470102c966c71ed4d061e961b5ddde326`**；`host-config-diag.result.json` 2549B / **`82a177f2c9ff446513078ccdbff0fb026e2d5de041bf63dbdefcf99ae346f22d`**；原raw Gradle daemon日志按当前LOCAL_ONLY manifest/原证清单只读查找，不臆造已登记SHA。**旧文件不可修改或替换**。
- 上轮主实施者报告保护**118721件具名文件**、**498** old refs／5历史根，第一根153条Windows长路径warning；未经授权旧`gradle-8.14-all.zip.part` 38302288B、SHA256 **`f99db8eee2a185748c33851b09225335a0f3d040fdd3123468e805074414e53e`** 需继续原位保护、绝不作为构建输入。
- 冻结AC-10.1.5-05四硬门：两实际媒体APP双向音频、同call重连、旧RTC JWT首入/重入拒绝、撤权COMMIT后真实流动媒体≤5秒停止，全部`OPEN/NOT_RUN`。本次完全不是这些媒体门的实测授权。

## 2. D0—D5唯一综合执行链

### D0｜保护和静态起点

1. 核本地唯一连续候选worktree实际HEAD等于`98c2e4e9...`、独立历史5保护根HEAD/branch/index/status、真实old refs及dirty/untracked状态、原证、备份/SQL/APK、全部正在受保护的Pub/Maven/Gradle/Flutter/Android工具缓存与private env。按**当前实数**登记，不自动将旧118721当全资产上限。禁止`reset/clean/stash/force/prune/rebase`及修改原historic dirty根。
2. 定点核验上轮完整已登记host配置原始stdout/stderr/result、daemon日志、真正调用参数和工具身份的原字节/Hash，以及前轮全部Flutter engine/Gradle锁定。若任一关键身份证据缺失，标`EVIDENCE_IDENTITY_MISMATCH`停止，不自行拉远端包或重新生成旧工具目录。
3. 本任务归属输出目录仅存新取证、脱敏白名单和后续证据manifest。不得覆盖旧std*.txt、原cache/POM/JAR或已验证Sdk-stage。未授权旧`.part`不得触及。
4. 确认当前仍无可用debug诊断APK实物及手机媒体验证许可，不能误用普通R1 APK代替诊断包。

### D1｜首先只读查已有异常因果链

1. 读取原 `host-config-diag.stderr.txt`、`stdout.txt`、`result.json`、所属Gradle daemon日志中**相关PID/时间戳及本任务独有request id**（若确有登记），必要的本地`AndroidLocationsBuildService`调用路径/真实`gradle.properties`只读配置；只对已登记归属文件做精确`find`/grep，不对Owner全盘递归搜索。不可展示完整私密绝对路径或读取无关用户凭据。
2. 构建层级化异常链：`outer exception→Gradle service→AGP BuildService→AndroidDirectoryCreator→deepest Caused by`，逐层注明**有实际文字/堆栈证据**还是`UNKNOWN`，记录最深cause的**异常类、明确直接message、相关只读调用处与最早可定位故障操作类型**。如只得到调用链没有下层cause，标为`CHAIN_INCOMPLETE`，不能推测SDK损坏、权限不足、`gradle:null`、JDK不匹配或版本冲突。
3. 若旧本地日志足以具体定位直接根因，将D2的新版Gradle调用标**`NOT_RUN_SUFFICIENT_OLD_EVIDENCE`**，直接到D3/报告；不因为一次许可就无谓重跑相同命令。

### D2｜仅在D1缺证时的一次Stacktrace宿主轻量配置

1. 运行前验证**确切旧隔离任务的身份与状态**，仅从不可修改的可信SDK/Gradle/POM/JAR和之前固定project/Gradle user home场所复用原已审核的诊断环境；不得建立新Root并改test-only路径校验、不得绕过原Gradle path/SDK identity guard、不得复制更大的SDK/重拉依赖、不得执行旧未经授权的部分ZIP。如原受控目录已有产物或锁会受覆盖，应停止报`NONDESTRUCTIVE_RERUN_NOT_SAFE`，不能自行清理。
2. 仅允许**一次**命令，完整保留上一轮的原宿主目标`:app:verifyIcePathDebug`、`-I host-config-check.gradle`、Gradle8.14直接`bin/gradle.bat`、`--offline --no-daemon --console=plain --max-workers=2`、`relationshipDualDeviceBuild=true`、严格三个test-only Dart flags以及上轮四个`iceDiag*` path properties/对应GRADLE_USER_HOME与SDK环境；**唯一增量参数为`--stacktrace`**。如某些路径不再成立导致必须修改它们，STOP而非新开另一个构建测试。
3. 只执行宿主配置目标；不得添加`assembleDebug`、`resolvePinnedDebugInputs`、Flutter AAR构建任务、Gradle`--debug`/scan/refresh-dependencies、任务名变体、`--continue`或自动重试。若见任何非授权远程请求、缓存身份变化、全局资源操作或新权限提示，停止只属于本任务的进程并保留错误，不以“成功取证”名义自动放开。
4. 把完整原`--stacktrace` stdout/stderr/exit和对应Gradle daemon日志（仅归属PID/时窗）保存在**LOCAL_ONLY**；外部GitHub只可写异常**结构化脱敏摘要**，不含完整用户绝对路径、机器登录名、用户环境、proxy/token/SDK路径、Maven secret或完整堆栈原文。工具进程完成后确认本版无后台遗留进程，不停止所有Gradle或全局Docker/ADB/JDK。
5. 若新trace只有service层，依然`ROOT_CAUSE_UNDETERMINED`；如揭示权限/路径/元数据/AGP行为某一直接异常，须按**见到的最深cause**写`OBSERVED_DIRECT_CAUSE`，而不是凭最内层一帧推断完整外部责任。不可现场修复、更改参数或再次验证“修复后能否成功”。

### D3｜取证归因、边界与非作者复审

- 制作匿名因果树，报告旧日志和（如执行）新stacktrace的**连续性**与有无不同错误路径，区分`EXACT_SAME_FAILURE_CHAIN`、`DIFFERENT_FAILURE`、`OLD_LOGS_SUFFICIENT`、`INCONCLUSIVE`。说明是否真到`validateIceDiagnosticGradle`、目标30配置`resolve()`、`syncFlutterAar`及任何APK任务；不能把Gradle项目插件配置`exit1`当APK构建失败。
- 仅提出**最多两项**后续可能修复选择，每项具名源、必要Owner权限、对普通APP是否有风险、回滚方案与最小测试；必须严格标**`PROPOSAL_NOT_AUTHORIZED`**，不擅自编辑配置、工具缓存或代码。
- 进行一次有界**非作者静态复核**，仅阅读脱敏因果证据、日志归属/Hash、调用计数与保护摘要；不得伪装为非作者复现Gradle或动真机。若发现异常摘要误判，修正报告（保留草稿/失败），无需额外运行。

### D4｜历史保护及所有运行资源收口

- 开工/结束明确检查旧LOCAL_ONLY原证未改，旧五历史根HEAD/branch/index/status和old refs、私密env、全局缓存、Flutter engine、两个官方下载架构JAR/POM、未授权`.part`原Hash不变；**如产生新的任务cache/debug日志，只在任务自有位置标明正常新增，不冒称整磁盘零写入**。
- 如果未运行D2，不能写任何`NEW_RUNTIME_OBSERVED`或“已启动后停止服务”。如果D2有一次，区分Gradle自己的daemon/缓存合法变化与旧证被覆盖；只退出当前任务启动的进程。手机、SFU、数据库、RTC不接触也不宣称现场验证。
- 保留之前所有失败历史，第一根153条Windows长路径warning不称覆盖全部缓存目录。

### D5｜只发布docs／精确终态

只允许新增：
- `docs/versions/v10.1.5/AGP_ANDROID_DIRECTORY_CREATOR_CAUSE_FORENSIC_REPORT.md`
- `docs/versions/v10.1.5/agp_android_directory_creator_cause_forensic_manifest.json`

Codex继续从交付`98c2e4e9f548ee924f4e244e23e7b307fb3afe72`的单一干净候选创建普通non-force**仅两docs**交付；GitHub最终Commit的sole parent为该固定候选，完整apps Tree必为`785822ca072943c5bfefa3ccc37ede01c2af5164`、services必为`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。普通非force发布后必须回读Commit/sole parent/root/两docs Git Blob及完整apps/services Tree。不上载LOCAL_ONLY raw stacktrace、SDK/POM/JAR/APK、privileged日志与机密路径，不改`ACTIVE_STATE`、既有Astra review或原历史候选。
 
真实终态只可从以下选择：
- `AGP_OLD_LOGS_CAUSAL_CHAIN_SUFFICIENT / NEW_GRADLE_RUN_NOT_NEEDED`
- `AGP_ONE_STACKTRACE_CAPTURED / DIRECT_CAUSE_OBSERVED / NO_FIX_PERFORMED`
- `AGP_ONE_STACKTRACE_CAPTURED / ROOT_CAUSE_STILL_UNDETERMINED`
- `AGP_FORENSIC_PRECONDITION_BLOCKED / NO_NEW_GRADLE_RUN`。

所有出口统一 **`AWAITING_ASTRA_INDEPENDENT_REVIEW / PRODUCT_V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / DIAGNOSTIC_APK_NOT_BUILT / TARGET_RESOLUTION_NOT_RUN / PLAN_A_RETAINED / NO_AUTO_R2 / NO_P2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED`**。

**这是因果取证任务，执行完立即停止，等待Owner转交Astra独立复审。未经新Owner批准不得进行任何修复、项目依赖解析、SDK补全、APK build或真机ICE媒体测试。**
