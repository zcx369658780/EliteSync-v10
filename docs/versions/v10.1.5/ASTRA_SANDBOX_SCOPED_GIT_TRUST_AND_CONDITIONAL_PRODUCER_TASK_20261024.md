# EliteSync v10.1.5｜Sandbox定点Git信任→SDK运行READY→真实Flutter Debug Producer→30配置离线解析｜Codex唯一综合长任务

日期：2026-10-24（Asia/Singapore）。
状态：**ASTRA_TASK_ISSUED / OWNER_CONTINUATION_DIRECTION_RETAINED / OWNER_MANUAL_CODEX_DISPATCH_REQUIRED / LOCAL_EXECUTION_NOT_STARTED / CONDITIONAL_SDK_INSTANCE_0_OF_1 / CONDITIONAL_PRODUCER_0_OF_1 / CONDITIONAL_RESOLVE_0_OF_1 / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED**。

## 0. 本任务准确目的、Owner权限与强制STOP

Astra已独立复审上轮`dd9b4eb9df9101adf4c0d980135081fd902c656a`的**新SDK Sandbox禁网PASS、JDK/Dart/Gradle实际版本PASS但Git dubious ownership exit128**。此前Owner明确允许长任务有界连续推进和定点Sandbox清理；本文件是下一份供Owner**手动转发给本地Codex**的唯一长任务，GitHub发布本身不自动启动本机行为。

**唯一目标**：在一个新的、已受控`Networking Disable`的Windows Sandbox实例内，**只为那个Git所有权因guest SYSTEM与WDAGUtilityAccount不一致、但原件身份可信的Flutter framework仓库配置临时、精确、进程作用域的`safe.directory`豁免**。先要求从不可变原证直接确认固定Git仓库内容、真正映射路径和安全控制；然后尝试一次Git HEAD读回：必须等于冻结框架`cc0734ac716fbb8b90f3f9db8020958b1553afa7`。明确不得用`safe.directory=*`、通配子目录、`git config --global/--system`、写`.git/config`、改ACL/owner、禁用Git安全功能或忽略HEAD不符。

此后才可在**同一个实际认证断网的guest**继续Flutter CLI版本/cache readiness、真实`:flutter:compileFlutterBuildDebug→:flutter:packJniLibsflutterBuildDebug` producer最多一次；其实际`libs.jar`产物来源／ZIP/JAR结构／JNI payload／ABI合格后，最多一次真正`resolvePinnedDebugInputs`验证15模块×2配置。**任一级门失败即停止**，不重复开Sandbox、不自动寻找下一组修复、不网络获取。

本任务仅放行本版**任务自有LOCAL_ONLY**源、入口和极窄运行时Git信任覆盖，以及已有隔离SDK输入在全新guest私有盘内的正常复制和派生输出。绝不授权：修改Git跟踪`apps/services`、正式build.gradle.kts/Flutter源码、Gradle/Flutter/AGP/Kotlin/JDK/SDK/锁依赖版本、宿主/共享Git config和权限、系统策略/防火墙/网络/hosts/路由/账户、提权、Sandbox/Hyper-V服务重启、任何新下载、`flutter precache/pub get`、Wrapper、宿主APK build/install、ADB/真机、RTC/SFU/DB/API、main产品集成、R2或v10.1.6、重置/清理历史资产。

## 1. Git固定authority与继承不重跑对象

- 仓库`zcx369658780/EliteSync-v10`。开工fresh核当前GitHub main/Root/完整apps/services；任务签发前main `9e69b78aff49f1712a0184e65d82f2eab31e391f`，Root `e738c45e3b1eae8f9aedd0c3216b5b3924500714`（后继docs会前移）。main仅为v10.1.4接受产品 apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`／services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`，不得覆盖未接受v10.1.5候选。
- 唯一连续待验候选起点`dd9b4eb9df9101adf4c0d980135081fd902c656a`，Root`57ec12b1cc0aca1aebf4eb92da6c5f3a80f65243`，sole Parent`7292a8c39cec2e0bbb611436686828263129614b`；受保护候选apps Tree`785822ca072943c5bfefa3ccc37ede01c2af5164`／services Tree`1e1e20bb3500bedb1a521e5f2ddeece915d09424`。固定产品诊断源码`1522466faf798b719ccff281de7584f043946437`，app构建Blob`bdb8e241d3e0defd1793c90b5f730c2facd7433d`；本轮两Tree与产品源不变。
- 最新[Astra独立审查](sandbox_git_ownership_block_independent_review_20261024.md)，**Git Blob `46dc2cc3633ba0f732c7decce9e74ee3a1b23e5d`**；上一Codex[报告](OWNER_SANDBOX_SCOPED_SESSION_CLEANUP_AND_SDK_PRODUCER_REPORT.md) Blob`5394eecac87e07fa6a19c1f26ce65f567a5960c7`；[Manifest](owner_sandbox_scoped_session_cleanup_and_sdk_producer_manifest.json) Blob`6f6c690be9bf99ebce2116dc083fa68e7ea09779`；其task Blob`ce270b0ffe1e95eb5f63a628eb9429fefd66c081`。优先读这些固定证据和`ACTIVE_STATE.md`新首段，勿重开旧HOST/fixture/DAG审计。
- 上轮实际Sandbox **1/1**，自身无外联adapter/default route且父子IPv4/v6端口连接均拒绝；实际Java17.0.18、Dart3.11.5、Gradle8.14 exit0，Flutter CLI未跑、Git HEAD未取得。guest原`framework-head` exit128，owner SYSTEM/current WDAGUtilityAccount；**未改safe.directory、ACL、原.git或共享配置**。上轮SDK源/映射与guest私有文件初始Hash可复用，但不能将旧guest视为还可重复启动或原网络检测覆盖本次guest。
- 原Flutter framework HEAD应为`cc0734ac716fbb8b90f3f9db8020958b1553afa7`，Flutter3.41.7/Dart3.11.5/engine`59aa584fdf100e6c78c785d8a5b565d1de4b48ab`；Gradle8.14可信binSHA256`af54a72a16af280335da698b17e61c850100bacbc425519b97527ed6d9ad19ab`，JDK17.0.18.8、AGP8.11.1/KGP2.2.20仍冻结。50键sealed环境原Hash`78b730a3ddbdfda3a908138fc67a0352ba80bb9d0bb14ad4c0e684309c64db52`，任何大小写`ANDROID_PREFS_ROOT`必须不存在，`ANDROID_USER_HOME`原批准归属与guest私有backing须核。
- 真正Flutter Debug DAG已在先前证实：`:flutter:compileFlutterBuildDebug → :flutter:packJniLibsflutterBuildDebug`，目标本版`.android/Flutter/build/intermediates/flutter/debug/libs.jar`；先前实际`targetPath=lib/main.dart`和`dartDefines=null`，所以**`ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN`**保持。已有正式严格resolver init SHA256 `2e97394f0dffd7818058e587cda8eaf0ec5ff747198d6a60e9872b14b96e1a6f`／artifact policy `bfb7633a037f84e7e7c41060563841add01648387ecafbd34a7e7d8e142e5c58`不改。

## 2. D0｜无需新Sandbox的短静态门

1. 只读回读上轮guest`framework-head`原stderr、现存映射源Git HEAD与`.git`原字节/owner、同SDK版本engine及任务独占的guest目标路径来源；使用已登记本地源/保护SHA核真实可信checkout。不得因一个未知owner差异就宽信任任意仓库。所有可能符号链接/Windows reparse/别名路径及`.git`实际worktree根须按guest映射策略定点确认；无法保证只信任固定Flutter仓库则`TRUST_TARGET_IDENTITY_NOT_PROVEN` STOP。
2. 选择一个**明确、最窄、可审阅**的Git runtime配置方案：优先只在单次Git调用传`-c safe.directory=<当前guest已核Flutter仓库真实规范绝对根>`；如Flutter CLI衍生Git进程必须继承，则可**仅在本任务guest与子进程的环境字典**中使用官方支持的`GIT_CONFIG_COUNT`/`GIT_CONFIG_KEY_0=safe.directory`/`GIT_CONFIG_VALUE_0=<精确root>`作用域。必须先验证本机Git确实支持该保护配置来源，计算并记录与原50键sealed env的**显式最小diff**；原50键不许被意外替换，子进程回读确认只增加本任务批准的Git scope，离开本任务后不持久保留。不能一边声称原50键全字节未变，一边暗中修改继承环境。
3. 静态安全负例：不允许`*`、`<root>/*`、空scope扩大、别的Git repo、任意动态目录、系统/用户/global/repo级配置落盘；可信source HEAD不能从未经验证的代码来源替代。若当前Git无法在不持久放宽全局的情况下精确接受该单root，STOP，不通过编辑其他目录owner、复制不完整`.git`或执行stderr建议的global命令绕过。
4. 仅核前轮准备的任务独立22映射、SDK输入/Pub/Maven cache的必要范围、旧脏工作树/SQL/APK/备份/refs/五历史根与私密原证；不得再次复制整套1.63GB宿主SDK，只在下一guest私有盘复用已批准备料。不要因历史保护计数固定而全盘扫描。一次非作者有界静态复核支持后才放行D1。

## 3. D1｜一次真正的新SDK Sandbox：隔离与单仓Git HEAD门

1. 先独立收集当前进程/guest资源归属与写根冲突的本轮原始快照，**不再无限重复`hcsdiag list`故障查询**。如发现已知共享VM/HCS冲突或上一Sandbox仍占用本轮写根/具名进程，STOP，不强制结束未知guest、不重启系统。历史状态继续`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`，不因新实例能启动而倒填旧关闭PASS。
2. D0 PASS且无已知冲突时，允许**最多一次**按受控`Networking Disable`新WSB/新任务根启动Sandbox SDK实例。在该实际guest内先验证无联网接口与路由、父子进程最小字面IPv4/v6外联拒绝，且所有共享源只读、写入仅guest私有/本任务目录。任何网络隔离失败/挂载路径漂移/不明副作用STOP，旧独立探针结果不能替代这次。
3. 校验guest中Git仓库真正绝对路径、owner和源件身份。保留反例“未经任何例外时旧Git ownership检查仍拒绝”的可验证来源，但本轮不强制重复会触发解析危险不可信配置的其他命令；先静态核已获原错误即可。只对当前精确Flutter SDK root用临时runtime config尝试**一次**`git rev-parse HEAD`等只读Git身份操作，必须exit0且HEAD等于冻结SHA；附带安全负例说明该例外不覆盖另一独立repo。若出现未知不同Git路径/无法准确确定信任范围，STOP，不新增glob。
4. 只有Git HEAD PASS才可继续一次真实Flutter CLI`--version`／最低成本必要cache identity与工具闭包验证，允许由它自然调用Git但必须沿用相同精确进程范围，不能写系统/global Git config。子进程可能正常写guest私有tool/cache与元数据，逐项分类，不得网络获取新包、安装SDK或更改冻结版本。JDK/Dart/Gradle版本前轮在另一实例已通过，本实例按任务需要定点核，不要求重复长时全量检查。Flutter`--version`失败/缓存输入缺失立即STOP；不能为了得到PASS再下载。
5. 标清本阶段只接受`ISOLATED_SDK_RUNTIME_READY_FOR_STANDARD_DEBUG`。此前DAG的`dartDefines=null`、`lib/main.dart`不能被标准Flutter版本命令改变为ICE诊断功能验收。

## 4. D2｜真实Flutter Debug producer最多一次（D1全部PASS才可执行）

按先前真实DAG，在同一禁外联guest、同一SDK/项目/Gradle home与产物root上，最多一次执行`:flutter:packJniLibsflutterBuildDebug`及其compile依赖。保留可信本地Gradle8.14`--offline --no-daemon --console=plain --max-workers=2`、双ABI、严格原SDK与50键关键环境；对继承Git trust的环境扩展保持D0最小限定，不能污染父进程/宿主。无需新DAG、旧GPU搜源、HOST或旧25/38/11 fixture。必须证明没有外联、没有新下载、SDK工具与缓存没越权写原保护路径。

produer（producer）失败即STOP；成功时核目标`libs.jar`真正由当次`packJniLibsflutterBuildDebug`产生，区分JNI jar非Java类jar，逐字节hash、ZIP结构与CRC、实际native条目/对应ABI`x86_64`、`arm64-v8a`来源以及task归属；空/占位/历史copy不能过门。未建立上述证据则后继正式解析0次。

## 5. D3｜真实文件解析最多一次（D2全部PASS才可执行）

在同一guest且与生产物相同绝对工程根中，最多一次执行`resolvePinnedDebugInputs`，严格保持既有`android-classes-jar` policy及`Configuration.resolve()`真实文件解析、`--offline --no-daemon --console=plain --max-workers=2 -Ptarget-platform=android-x64,android-arm64`、任务独占init/三flags/四iceDiag路径属性。记录15模块各debugCompile与debugRuntime共30项的`BEGIN`/`OK`/首FAIL及余项NOT_RUN；新首阻断立即STOP，不重试，不自动修其它插件/仓库，也不虚报成功。只有30/30真正PASS才能报`OFFLINE_30_CONFIGS_PASS`，但仍不是宿主APK、ICE诊断或RTC安全PASS。

## 6. D4｜集中交付、审阅、保护、权限边界

- 同一份综合任务做**一次非作者有界复核**：审D0 precise safe.directory和拒绝通配/全局配置、D1本实例禁网/Git HEAD及工具身份、D2真Jar和D3真实30配置计数；不能让审阅者另起运行预算。全部旧失败、HCS UNKNOWN、旧进程归属不确定性留存，不能以“成功新guest”覆盖历史。
- 受保护原件：已有509 old refs/五历史root、原dirty/SQL/APK/恢复备份/密钥/私密日志、未授权part、既有SDK/.git和当前Task的mapped readonly sources不得改动。当前新证据/合法guest派生缓存清单归类，保护Hash以**触及的具名文件**为限，不能宣称对全盘/活DB重hash。新Sandbox正常退出要记录，不能将launcher exit0直接当guest安全收口。
- 唯一候选从`dd9b4eb9df9101adf4c0d980135081fd902c656a`作为sole Parent新建有界后继，Git**只新增两份docs**：
  - `docs/versions/v10.1.5/SANDBOX_SCOPED_GIT_TRUST_AND_CONDITIONAL_PRODUCER_REPORT.md`
  - `docs/versions/v10.1.5/sandbox_scoped_git_trust_and_conditional_producer_manifest.json`
  不改`ACTIVE_STATE.md`、旧任务/审查、`apps/services`或main产品。普通非force发布并完整回读Commit/soleParent/Root/两docs Blob/完整双产品Tree和UTF-8原文字节；原始PID/SID/私有路径/Git owner信息/WSB/env/SDK/JAR/全stdout-stderr保持LOCAL_ONLY，仅发布去敏状态/Hash与证据索引。
- 终态按证据：`SCOPED_GIT_TRUST_NOT_PROVEN / SDK_NOT_READY / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`SANDBOX_SDK_GIT_IDENTITY_FIRST_BLOCKER / PRODUCER_NOT_RUN / RESOLVE_NOT_RUN`；`ISOLATED_SDK_READY / PRODUCER_FIRST_BLOCKER / RESOLVE_NOT_RUN`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_RESOLUTION_FIRST_BLOCKER`；`REAL_DEBUG_LIBS_JAR_VERIFIED / OFFLINE_30_CONFIGS_PASS`。统一保留`OLD_GUEST_STATUS_UNVERIFIED_FROM_HCS`（直至有独立实证）、`NO_HOST_APK / ICE_DIAGNOSTIC_FLAGS_NOT_PROVEN / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / PLAN_A_RETAINED / NO_R2 / NO_MAIN_PRODUCT_INTEGRATION / V10.1.6_NOT_STARTED / AWAITING_ASTRA_INDEPENDENT_REVIEW`。

**任务结束必须STOP；不得自动进入下一轮构建、产品集成或重新设计工作流。**
