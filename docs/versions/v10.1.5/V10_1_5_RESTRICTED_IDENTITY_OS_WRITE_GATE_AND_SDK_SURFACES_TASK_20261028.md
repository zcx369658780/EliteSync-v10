# EliteSync v10.1.5｜主线：受限执行身份与OS写入隔离门禁＋SDK剩余写面综合验证任务

**状态：OWNER_APPROVED_FOCUSED_OS_ISOLATION_QUALIFICATION / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / ZERO_GRADLE_AND_ZERO_G2_CLAIM / D_DRIVE_CLEANUP_DEFERRED**

日期：2026-10-28（Asia/Singapore）
权威仓库：`zcx369658780/EliteSync-v10`

## 0. 唯一授权、目标与强停止出口

Owner在Astra对候选`76e46d99`的单Seed/D盘盘点完成独立审查后，明确同意**优先推进EliteSync v10.1.5主线**。本次仅授权一份有界的 Windows **受限执行身份/OS写入隔离资格**综合实施任务，并在同一任务内定点覆盖 Flutter/Android SDK/NDK和插件剩余的真实配置期写入风险。D盘旧219目录已完成只读盘点，本轮**不继续其清理、筛选或迁移**，不将磁盘副线与主线混合。

主要任务：在Windows上针对**本任务新创建的微型fixture和可审阅的本地进程沙箱原型**，证明是否存在不需提权、不持久变更系统安全设置、且可安全退出/撤销的受限身份机制，使执行器具有对受信任只读Seed、SDK及历史保护输入的读取资格，却无法改变其ACL/owner、利用父目录delete/rename或重定向写穿这些输入；写入仅能发生在任务独有writable目录。**优先验证由受限token/受限完整性级别等用户态机制构造的最小可撤销原型**，但方案必须服从本机权限和来源证据；不能先认定restricted token低权限就必然隔离，不能把DACL单文件拒写当全环境隔离。

本任务允许有限、明确且可记录的**Windows OS专用fixture实验**（只运行不加载Gradle/SDK/JVM的微型、可审核Python/Windows API sandbox子进程）；任何需要管理员授权、Windows系统配置、创建持久用户/服务、永久AppContainer/全局Policy或改共享ACL的步骤必须停止、报告需要的具体后续Owner决策，不得自行执行。可在范围内自主修复静态/fixture脚本和重测模拟，禁止将真实Gradle调用作为诊断手段。

**结果分类：**
- `BOUNDED_RESTRICTED_IDENTITY_FIXTURE_GATE_SUPPORTED`：至少在任务独有小型fixture中，受限身份在可追溯token/进程身份下可读许可源、可写私有目录，同时不能写/改ACL/owner/rename/delete受保护模拟Seed，父目录及别名攻击路径也已按**有界**清单测试；这是**fixture OS门**，不代表Gradle运行期隔离或完整SDK写面闭合。
- `RESTRICTED_IDENTITY_GATE_BLOCKED`：必要的token创建/launch权限、有效访问、父目录/Owner/WRITE_DAC绕过或fallback风险无法安全消除；如实记录阻断，不提权不变更系统安全配置。
- `OS_QUALIFICATION_PARTIAL_WITH_UNRESOLVED_SDK_WRITES`：局部权限实验可用但SDK/插件动态写面或执行器身份绑定仍缺证据；仍不放行真实工程。

无论结果，硬状态**`G2_READY_FOR_POPEN=FALSE / INVENTORY_RUNTIME_CLOSURE_NOT_PROVEN / GRAPH_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN`**不变；本次交付后先由Astra独立验收，再由Owner决定是否恢复现有受控G2合同，不能本轮直接进入G2。

## 1. 冻结预算及允许/禁止的OS行为

**工程运行预算均为0：** 真实Gradle 8.14（包括`--help`、`--version`、`--dry-run`、Wrapper/init）、Java/JVM、Flutter/Dart、AGP/Kotlin、G2启动/claim、AAR/POM/APK、ADB/RTC、真实G2 runner/observer/Job采样、真实网络/socket、Gate2/Writer/Serializer/DB/Push/生产全部0。旧APK=1/1耗尽、旧G=1/1耗尽、旧A=NOT_RUN_GATE_CLOSED；历史另授权的G2上限1次据上轮Codex LOCAL_ONLY为0/1且claim absent，本轮只能**只读确认**，绝不创建/修改该claim或新ledger。

**允许的独立OS实验：** 在本任务新建的fixture根执行Python stdlib静态/mock以及有界Windows API读取token、SID/privilege、file identity、ACL有效访问、ancestor identity；可调用用户态`CreateRestrictedToken`/等效无提权用户受限身份机制、必要的最小进程启动接口，**只启动预先Hash审核的任务私有、固定操作集的无网络无SDK文件访问fixture**，记录短时PID/子进程身份和退出/句柄清理。Windows受限进程只能尝试任务fixture路径中的读、任务私有write、拒绝写/改ACL/owner/rename/delete的负例；即使测试拒绝失败（意外允许写）也须立即STOP，将任何改变恢复到任务fixture初始Hash，且不触及旧Seed或protected root。可以选择完全不启动进程并`BLOCKED`，不能为了成功改用高权限身份重跑。不要使用AppContainer持久profile、计划任务、服务或新增Windows帐户来绕过受限进程launch失败。

**严禁：** UAC提权、管理员token、`takeown`、系统或共享路径`icacls`授予/拒绝变更、修改Windows全局安全策略/防火墙/代理/VPN、真实网络、下载新tool、升级/清理缓存、改变旧任务Seed/共享SDK/Gradle-home/NDK/Pub/JDK的ACL或内容；拒绝后不可调整执行策略、临时关闭保护、跨另一个账户偷偷启动。不可在D盘旧目录做任何写探针，也不可删除、移动、重命名任何历史目录、refs或旧原证。可只读引用历史单Seed及旧完整目录Hash证据，但**不得就地对原Seed做拒写实验**，以任务独有微型同构fixture替代。

**容量**：新任务独有全部源码/日志/fixture/报告/候选实物保守上限**256MiB=268,435,456 bytes**（本次不复制既有1.3GiB Seed，不重新占用/改动原2GiB任务的配额，也不暗中延伸原2GiB许可）。前/中/末记录真实FILE_STANDARD_INFO allocated及logical、峰值估算、卷free局限、工作树与protected路径差异；超cap即停止。

## 2. 开工fresh authority与固定输入

读取当前live main、Root、`docs/workflow/ACTIVE_STATE.md`、本正式任务全文与Blob、冻结v10.1.5 plan、旧G2合同、最新Astra 76e独立裁决和76e候选报告/索引、6ca源级候选及其账本/保护规则。

- 本任务准备时main `dfa1e7828a46284617876bbd729e8b884649039e`，Root `e8e30f90f5a7351666a01e3b06081afb8b5ffac8`，已接受v10.1.4 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services `0cb1f9d19659291a462488b3686fd0a07a6698ac`。
- 本轮唯一前置未接受候选`76e46d9966dcb29c9e7dea72f41a1cd59fe0e6d7`，唯一Parent `ba7df19accd3df22b8e06cdfd65a6466cf4ecc53`，Root `3799152e9fa348d412cabe6468a30f81f2714598`，apps `5af7a9d0042be19437616e969e260658b67e9353`、services `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`（均未集成产品main）。
- 76e综合报告 `docs/versions/v10.1.5/G2_SINGLE_SEED_2GIB_OS_QUALIFICATION_AND_D_DRIVE_INVENTORY_REPORT_20261028.md` Blob `83e9067101e60945da2db35d3829555029a74bdd`；索引 `G2_SINGLE_SEED_2GIB_OS_QUALIFICATION_AND_D_DRIVE_INVENTORY_EVIDENCE_INDEX_20261028.json` Blob `52f2f2956fa1d2cec16451570e10a261478a5c4b`。
- Astra最新验收归档在`astra/v10.1.5-76e46d99-single-seed-d-inventory-review-20261028:docs/versions/v10.1.5/76E46D99_SINGLE_SEED_OS_AND_D_DRIVE_ASTRA_REVIEW_20261028.md`，Blob `fcbfcdf0b8fd5ba941ed7d0d030efb3612019fcb`，审查分支准备时HEAD `1ee5e0e572a6624306684729ad3e284bbcb4cd69`。
- 原G2唯一已批准条件性真实dry-run合同 `docs/versions/v10.1.5/V10_1_5_CONTROLLED_SOURCE_HARDENED_GRADLE_GRAPH_G_ONLY_TASK_20261027.md` Blob `796c9ad2d5d91b3d375cea6c079e9e6121e0be4c`，保持停止；冻结plan Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。
- Codex回执：旧单Seed 3183件源/目标Hash相等、1,362,106,905 bytes逻辑量、前轮文件实际allocated `1,395,169,224` bytes，`SEED_WRITE_DAC` 当前账户可取、父delete/rename风险、fixture写拒绝error5，但 OS整体 `NOT_PROVEN`；旧G2 `reservedStarts=0/Popen=0/claimAbsent`。这属于LOCAL_ONLY，不是Astra现场证明，不可作本轮默认全部安全。
- 具名受保护原证须本地只读首尾核验：旧Gradle下载partial`7,941,328 bytes` SHA256 `b6fd9e325eaf2b1d785efdd9e32baad65e85c6a577be7c28c970a80158a679d4`，旧APK claim SHA256 `07820a04f5f7bb5fccea83a5372340af33b224269bcf89b476b637230140f8c8`、旧G claim SHA256 `0a9a2835ea4b1805977a81808ec787fa5070a35f5c4f504c69eb7b37ed091316`，旧A/G2 claim据前轮未创建；五保护根与具名refs/worktrees、SQL/APK及失败原始日志不准清理重写。只审计具名必要范围，不冒称全历史保护集合复算。

## 3. A：真实Windows受限身份资格（任务专有微型fixture）

以**一次冻结的最小测试矩阵**自主完成方案选择→token/启动条件静态验证→任务自有fixture真实操作。不能仅根据“低完整性”或“禁写DACL”就宣布完成；必须读取本机已有Windows API契约/头文件/已安装文档或可信固定证据，并将API行为与Windows系统实际返回码分层。

- 在当前token下做只读审计：existing privilege/owner/WRITE_DAC、完整性级别、可用的受限token创建与启动API、继承句柄/环境变量/用户profile、AppData/temp、文件重定向、父目录delete权限。真实SID/token和私密机器路径仅LOCAL_ONLY。
- 候选限定为**无持久对象**的受限token或可撤销用户态受限身份；如创建子进程需要的`SeAssignPrimaryToken`/`SeIncreaseQuota`等不可用，不得提升或执行外部安装，可退回API设计与mock，并明确`LAUNCH_PRIVILEGE_BLOCKED`。非管理员/不可更改系统设置为硬界。
- 微型fixture中模拟Seed只读目录、目录父层、任务私有Writable、恶意别名/链接的**安全模拟**：禁止真实建立指向共享保护目录的symlink/junction/hardlink；允许仅在任务内任意可销毁路径验证读取许可、写拒绝、`WRITE_DAC`拒绝、owner修改拒绝、DELETE/rename及父目录`FILE_DELETE_CHILD`和分区/路径逃逸拒绝，并分别记录低位Win32错误与操作前后Hash/FileId。拒绝失败时立即终止sandbox进程、保留LOCAL_ONLY失败帧并尝试恢复仅本任务fixture的原件；不可继续对真实Seed或其它全局路径探测。
- 在没有已验证的受限身份自动继承模型之前，不允许把真实Gradle二进制、Java/JVM、Flutter/Android工具进程用该身份执行，也不允许借本轮为未来G2生成可直接调用的launcher入口（`G2_READY_FOR_POPEN=FALSE`）。
- 只要所有positive/negative检查出现拒绝码、异步竞态、ACL/owner修改路径不闭合，停于`OS_IDENTITY_QUALIFICATION_BLOCKED`，并给出最低权限/最小可逆next-step选择，不触发更多OS权限动作。

## 4. B：Flutter/Android/Plugin剩余写面定点合同

本轮必须优先补掉能阻断未来G2的**少数关键未闭合写面**，不要再重复18族通用目录罗列。基于固定6ca源码和已有离线Gradle8.14/Flutter3.41.7/AGP/NDK/tooling/插件源码，从以下源到输出建立`CONFIG_PHASE_READ / CONFIG_PHASE_WRITE / TASK_ACTION_ONLY / UNKNOWN`四类，标出实际控制它们的进程身份、目录、环境和是否适合未来限制运行：

1. Flutter插件`forceNdkDownload`/NDK/CMake和SDK Manager与stamps/许可证状态、已有版本源码是否会在config阶段写入共享Android SDK（未证只能保持UNKNOWN）。
2. Flutter included tooling gradle的`.gradle/buildOutputCleanup`、编译/transform、Flutter bin/cache/artifacts/engine stamp、Gradle cache的二进制索引和read-only two-stage层（Seed快照不证明repository身份及variant命中）。
3. 14具名Android插件、module `.android`、`plugins_build_output`、native/JNI/CMake/自定义buildDir，以及静态分析已发现的dynamic脚本读写与可能启动进程；只需定点真实来源行号/Hash，若代码是动态逻辑就写`RUNTIME_UNKNOWN`。
4. HOME/USERPROFILE/AppData/GRADLE_USER_HOME/PUB_CACHE/ANDROID_USER_HOME/TEMP/TMP及默认fallback、系统SDK项目输入实际路径；明示沙箱身份与任务私有root是否一致或存在外部引用。

结论要明确指出：**OS身份/fixture即使通过，也不等于SDK和Gradle输入全闭合**。不能自动对未来实际Gradle runner打开许可。

## 5. 综合交付、空间、保护与STOP

唯一集中报告路径：
`docs/versions/v10.1.5/G2_RESTRICTED_IDENTITY_OS_AND_SDK_WRITE_GATE_REPORT_20261028.md`
与最小脱敏证据索引
`docs/versions/v10.1.5/G2_RESTRICTED_IDENTITY_OS_AND_SDK_WRITE_GATE_EVIDENCE_INDEX_20261028.json`。

允许附加极少量纯静态/fixture的安全源及mock，不得上传真实本机SID、ACL SDDL、绝对路径、token、PID、系统进程数据、保密脚本、SQL/APK和历史原证。候选必须从76e未接受文档基线以**普通non-force唯一Parent**发出；核验Commit/Parent/Root、全部新增path/mode/Blob和GitHub原字节、完整apps/services Tree，对照live main v10.1.4基线。不要改产品源码或main，仅安全报告/必要microfixture源码。

报告必须给出：真实OS身份模型与token来源/权限、受限进程是否真的创建、每项fixture read/write/ACL/owner/delete/rename的允许与拒绝及低位错误码、操作前后FileId/Hash、是否真的验证parent/ancestor、监测和清理、SDK/插件写面已证/未知矩阵、任务峰值allocated及上限、历史原证与预算首尾、G2仍为何不放行、下一步唯一最小Owner选择。各证据必须标`ASTRA_DIRECT_GITHUB_STATIC / CODEX_REPORTED_LOCAL_EXECUTION / LOCAL_ONLY_RAW / OS_FIXTURE_DIRECT / NOT_PROVEN`，把Codex本地真实实验和Astra未现场运行明确区分。

本轮不做D盘目录继续筛查或任何清理——该副线在上轮`D_DRIVE_ELITESYNC_INVENTORY_DELIVERED_READONLY / CLEANUP_CANDIDATES_ZERO`处冻结。绝不拷贝第二份Seed或运行真实Gradle。若token/fixture子进程无法安全退出或残留句柄未能确定，`FAIL_CLOSED`并报告，不能静默继续；不改变系统全局安全策略或杀死别的任务进程。

**完成一份集中候选后STOP，等待Astra独立验收。不得自动恢复G2、创建G2.claim、开始AAR/APK、Gate2、合并产品main、清理D盘或启动v10.1.6。**
