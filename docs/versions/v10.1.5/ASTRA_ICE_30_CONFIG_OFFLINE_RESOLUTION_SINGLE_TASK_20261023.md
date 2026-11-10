# EliteSync v10.1.5｜ICE 15模块×2配置正式离线依赖解析｜单一有界Codex长任务

日期：2026-10-23（Asia/Singapore）。
状态：**ASTRA_NEXT_TASK_ISSUED / OWNER_DIRECTION_CONTINUE_AFTER_REVIEW / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / RUNTIME_NOT_STARTED / APK_BUILD_NOT_AUTHORIZED / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_MAIN_PRODUCT_INTEGRATION**。

## 0. 本次指令的精确权限

Owner在收到AGP Preferences单变量修复结果后要求“验收后请继续推进”。截至发布时，Astra对**同一候选**的独立复审已在GitHub正式归档，本任务不再次复审、不重跑25项环境fixture或HOST轻量配置。本任务是供Owner**手动派发**本地Codex的下一份唯一长任务；发布文档不是后台执行授权或真实运行回执。

**本任务的唯一运行目标**：在已经通过的AGP Preferences清洁诊断子进程环境、固定同版离线依赖及隔离SDK中，最多**一次**执行真实 Gradle `resolvePinnedDebugInputs`，对目标15模块各`debugCompileClasspath`、`debugRuntimeClasspath`共30个配置实际调用`Configuration.resolve()`，形成逐项BEGIN/OK/PASS或首失败明确阻断证据。禁止用Gradle HOST配置、dry-run、空任务、fixture或缓存清点冒充30项真实resolve。**只允许这一个正式解析目标；即使30/30 PASS，也必须停止，等待下一次Owner明确授权APK构建。**

本次绝对不允许：任何`assembleDebug`、`syncFlutterAar`、Flutter AAR正向构建、APK安装/ADB/AVD/真机操作、RTC/SFU/Room.connect/媒体实验、Laravel/API/数据库、LAN/UDP/TURN/防火墙修改、生产/云端/公网、SDK/AGP/Kotlin/Gradle/Flutter/JDK升级、网络获取/下载/Wrapper、外部供应商/真实Push、R2、main产品集成、v10.1.6或历史清理。若单一正式解析在现环境无法安全启动，报告STOP而非擅改这些边界。

## 1. 精确身份、权威与不可倒退状态

- 仓库：`zcx369658780/EliteSync-v10`。任务签发依据的GitHub live main：`9ebf5cf4655839e2655016cb7bb4bcf5334db6c8`，Root Tree `f5185e842640ee37b95c25d490f8ede30f131030`。任何实际开工都须**重新只读核验**live main，不能把它当永远固定的HEAD，也不能将main覆盖待验候选。
- main已接受v10.1.4产品：完整apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`；services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。此任务与v10.1.4重新集成无关。
- v10.1.5连续待验候选基点（不得跳回更旧source）：`e24b6d5db8063e1207e9939612352c0f1d8c9bdf`，唯一Parent `a1fd57af25fd60b6656e2a262c050cb4a8e3d80d`，Root Tree `10cc07ef2589b2bed72fb6dde3cb6cf11525ee5f`。apps Tree `785822ca072943c5bfefa3ccc37ede01c2af5164`、services Tree `1e1e20bb3500bedb1a521e5f2ddeece915d09424`。本任务两Tree严格不变。
- 固定诊断构建source `1522466faf798b719ccff281de7584f043946437`；`apps/android/app/build.gradle.kts` Blob `bdb8e241d3e0defd1793c90b5f730c2facd7433d`。本任务**不修改任何跟踪apps/services代码或旧报告**。
- 正式前置Astra复审 `docs/versions/v10.1.5/agp_android_prefs_env_single_variable_fix_independent_review.md`，Git Blob `fa83daeb88e55c1d549384dc970e729f0b9a9d63`；本轮Codex报告Blob `64303ab064e2e081aa8946f52c6a1d9426ecd714`，manifest Blob `9bb27ca6da2b1af6d3a1b5ec71bd8f2a49110282`。先精确复用此前已证结果，不能再把同一回执描述成AWAITING_ASTRA_REVIEW。
- 真实环境边界：原`ANDROID_PREFS_ROOT`/ANDROID_USER_HOME冲突在**诊断专属子进程**已纠正；原helper Hash `4a40266ae988fbeaa079892aa0654f3555f62f415391463f5d13e3cebd846a8a`不变，新专用helper Hash `1be8f3bbf89fe6d9f2d4fc1168afb85bef286af8d30648c79daff3399a0f013d`。Codex报告25项fixture PASS、原HOST目标1/1 exit0；本任务仅要确认**后继正式解析器实际消费同一有效环境**，不可直接假定所有runner已自动修好。
- 固定版本：Gradle8.14、Flutter3.41.7、Dart3.11.5、engine `59aa584fdf100e6c78c785d8a5b565d1de4b48ab`、AGP8.11.1、Kotlin2.2.20、JDK17.0.18.8；经核可信Gradle bin SHA256 `af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`。已批准本地两架构同engine POM/JAR来源、缓存与诊断SDK副本可**复核并复用**，不得新下载、用旧未授权`.zip.part`补包或假定其它29配置无缺项。

## 2. D0｜短前置、保护与解析器身份（新Gradle运行0次）

1. 只读核本次候选Parent/Root/完整两子Tree、旧审阅及独立验收固定Blob。检查所用本地连续候选基线和现有受控诊断工程、工具、产物归属，保护五历史根、500旧refs、原dirty与未提交文件、原SQL/APK/私密env、恢复卷/SDK/Gradle缓存、原`.zip.part`、原日志与全部历史失败。不盲`pull/reset/rebase/stash/clean/prune/force`。上轮223580份具名文件、153条旧Windows长路径warning只是**历史登记口径**，先核具名不变量与本轮可能写入范围，不要求为纯工具诊断额外建立无限全盘考古。
2. 在**独立的新任务LOCAL_ONLY运行副本/隔离Gradle home**内复用既有可信Flutter/Android SDK、Gradle8.14和已获准的官方同engine工件；若必须复制，只复制必要且已具名可核的本地现成字节并核Hash/归属/重解析点，不触碰原保护目录。原输出/旧daemon/日志和上一轮helper必须保持可恢复，不把旧目录改作可覆写新任务。
3. 精确核原先真实`resolvePinnedDebugInputs` init逻辑的15模块×2配置、`Configuration.resolve()`及首失败STOP、`-Ptarget-platform=android-x64,android-arm64`；复用已通过的Gradle Groovy仓库receiver/独占io.flutter过滤和现有已获准POM/JAR，不能放宽transitive或变更锁文件/engine版本。历史首次解析仅BEGIN=1/OK=0，缺两架构坐标；后来两个官方同engine工件已有`CODEX_REPORTED LOCAL_ONLY`取得及Hash证据，但不是30项通过的证明。
4. **关键新门**：实际正式依赖解析的Python/Gradle子进程（而非另一旧runner）须经最终有效环境字典证明没有任何大小写形式的`ANDROID_PREFS_ROOT`键，保留上轮相同`ANDROID_USER_HOME`归属且无新偏好目录system property。验证CLI、cwd、Gradle home、隔离project、`-I`、所有原诊断flags和四个iceDiag属性与既有批准配置一致。只可在本任务专属LOCAL_ONLY入口做必需的环境/根路径绑定，严禁改Windows系统/用户环境、跟踪build.gradle.kts、Gradle版本/模块及依赖缓存真实内容。若不能安全复用或证明clean child env被实际消费，`PRECONDITION_BLOCKED`并STOP；**不重跑HOST或25项fixture**。
5. 确认无相关在运行的构建/独占锁、受控离线命令不会依赖新外部网络/Android自动下载、不会覆盖旧SDK/APK与日志。对失败先保留现场，不为凑PASS做无授权修复。

## 3. D1｜唯一真实正式依赖解析（最多1次）

D0全部PASS才允许恰好**一次**通过已核可信本地`gradle.bat`（**不用`gradlew`/Wrapper**）执行：

`resolvePinnedDebugInputs --offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`

同时使用原已审诊断脚本、三项诊断flags、四项iceDiag路径属性及任务专属clean env，准确argv从上一轮LOCAL_ONLY记录复用，不凭此摘要猜填机器路径。任何外/内层Wrapper调用、新仓库下载、`flutter pub get`、SDK自动获取均禁止。即使任务名相同，也必须实证正式`Configuration.resolve()`已被调用；仅插件配置、guard或task graph ready不是结果。

逐配置按原实际顺序记录：准确`module:configuration`、BEGIN/OK、必要去标识的缺失GAV及第一异常分类、exit与耗时；30项都真实OK才允许标`ALL_30_CONFIGS_RESOLVED`。任何一个出现缺失坐标、Android/Gradle新异常、离线缓存不足、权限或路径问题，立即按**该唯一实际运行的自然终态**STOP，列其余`NOT_RUN`；不得重试、联网、切换source/SDK/仓库、假造通过或自动下一次运行。

正式依赖解析即使PASS：`syncFlutterAar=0`、`assembleDebug=0`、`APK=NOT_BUILT`、手机RTC=0；必须完成D2/D3报告后等待Owner**新的**构建授权。严格区分`HOST_CONFIG_PASS`、`RESOLVE_PASS`、`APK_BUILD_PASS`、`RTC_AC05_PASS`四层。

## 4. D2｜本轮一次集中报告、非作者有界审阅及保全

- 仅一次非作者有界静态复核：child env是否真的被解析器消费、原init配置/固定版本是否漂移、30项计数与最深首失败、禁止的APK/网络/SDK/真机动作确实未执行、关键原证是否保持。非作者不重跑Gradle、不签v10.1.5整版ACCEPTED。
- 显式保留全部前轮失败和本轮意外日志（包括旧首轮cache分类exit1及后续纠正），区分受控Gradle自行产生的task-owned cache/daemon/lock合法派生写入与历史不变量；报告本轮实际before/after范围与限制，不把“原始保护不变”夸大为全磁盘零变化。不得删除/覆盖旧原件。仅结束本轮自己启动的进程，不全局kill。
- 原始stdout/stderr/daemon、Gradle/SDK和完整私密路径、真实环境、设备标识/凭据均`LOCAL_ONLY`；公开GitHub只交脱敏的决策性统计、错误坐标、对象Hash、证据文件相对路径与必要复现说明，不上传任何大日志或工件二进制。

## 5. D3｜唯一候选交付与停止条件

**只新增两份docs**：
1. `docs/versions/v10.1.5/ICE_30_CONFIG_OFFLINE_RESOLUTION_REPORT.md`
2. `docs/versions/v10.1.5/ice_30_config_offline_resolution_manifest.json`

在连续待验候选`e24b6d5db8063e1207e9939612352c0f1d8c9bdf`之后创建**一个独立干净的后继任务候选**（不直接在main、原保护树或旧候选上覆盖文件），无产品源码改动。所有Git操作普通non-force，只回读精确Parent/Root、两新Blob及apps/services完整Tree。需要首次建分支可创建一条，不做重复中转/新Issue。Codex仅交付执行结果与候选，Astra随后独立审阅；未经Astra与Owner后续明确审批不合main。

合法终态只选择真实一种：
- `OFFLINE_30_CONFIG_RESOLUTION_PASS / NO_APK / AC05_OPEN`
- `OFFLINE_RESOLUTION_FIRST_MISSING_COORDINATE / PARTIAL / NO_APK`
- `OFFLINE_RESOLUTION_NEW_ENV_OR_TOOL_BLOCKER / PARTIAL / NO_APK`
- `PRECONDITION_BLOCKED / FORMAL_RESOLVE_NOT_RUN / NO_APK`

共同附加：`V10.1.5_PARTIAL_NOT_ACCEPTED / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。即便30配置PASS也**不等于RTC、APK或整版功能接受**。若需新下载/供应商/网络、SDK变更、依赖修复、真实设备或下一阶段APK build，集中提出一项有据可核的Owner新门，不自行执行。

**本任务交付后停在Codex候选，不自行连续展开下一轮。**
