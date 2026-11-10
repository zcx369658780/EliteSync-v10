# EliteSync v10｜M3 离线隔离准备、条件式一次生成与证据任务 v0.1

Status: `TASK ONLY — OWNER APPROVED OPTION 1 — BOUNDED WINDOWS SANDBOX PREPARATION + CONDITIONAL ONE-SHOT M3 + FRESH EVIDENCE — NO EXTERNAL NETWORK — NO ORIGINAL-WORKTREE WRITE — NO PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-07（Asia/Singapore）。执行者使用简体中文。Owner 在当前会话明确批准 M3 readiness 报告 §4 的**选项1：无外部网络的隔离证据范围**。本任务落实该批准；不是再次询问同一范围，也不是恢复旧 `8b640576822b01ae00bb04b9b5deaa75db53365c` 任务。

## 1. 固定基线与入口

仓库：`zcx369658780/EliteSync-v10`。

执行开始先实时读取 GitHub `main`，必须恰为：

`fd4355a29b912280c46dc5391e9bacf66be45d84`

FIRST 主动读取：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

要求 blob：`18485c95262051e43892436fb52413132c5ee626`。

随后读取并绑定：

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md`，要求 blob `9466dba2800e12bf1f17414606e34af452134741`；该报告的技术判断被此前 ChatGPT 验收，Owner 随后批准其选项1。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，要求 blob `7468db2388ee69b77fbfcd3c6cd7ec38d1ee98c6`。
- 当前 `apps/android/app/build.gradle.kts`，固定 main blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516`；只用于解析 Flutter module 路径、Flutter SDK选择顺序、`flutterDartDefines` 解析合同和 direct AAR command family。
- 当前 `apps/android/gradle.properties`，固定 main blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`；只用于确认项目级 Gradle property，不扩展相邻文件读取。

随后读取本任务不可变 commit/blob；由启动 prompt 给出。任务 commit 必须唯一父为上述 main，并且只新增本任务路径。

若 main、固定 blob、task commit/blob、sole parent 或任务变更范围不匹配，停止依赖它的后续动作；不自行换基线、rebase 或猜新任务。

## 2. 本轮唯一目的与完成判定

在不修改 `D:\EliteSync-v10` 工作区内容、不读取默认 index/受保护 staged state、且 M3 进程树无外部网络的前提下：

1. 解析一组最小、具名的本机工具/缓存输入；
2. 创建专用 Windows Sandbox 隔离合同；
3. 若所有硬前置条件闭合，执行**一次且仅一次** direct Flutter AAR release-only 生成；
4. 收集与该 attempt 绑定的结构化结果和新鲜生成产物证据；
5. 发布一份结果报告并更新 `CURRENT_CONTEXT` 的 M3 状态。

本任务不保证构建成功。前置条件不足、离线缓存不足或工具不兼容都是有效结果，不自动授权下载或重试。

固定 attempt ID：

`M3-ISO-V02-001`

固定宿主隔离根：

`D:\EliteSync-M3-readiness-v02`

固定 guest 工作根：

`C:\M3`

如果宿主隔离根在开始前已存在，**不要删除、覆盖或复用**；记录 `M3 ISOLATION ROOT CONFLICT` 并停止隔离物化/执行，但仍可发布结果报告。

## 3. 新增授权范围：精确、本轮有效

### 3.1 原仓库只读与 Git 对象快照

对 `D:\EliteSync-v10` 只允许：

- `git -C D:\EliteSync-v10 rev-parse --show-toplevel`
- `git -C D:\EliteSync-v10 rev-parse HEAD`
- `git -C D:\EliteSync-v10 remote get-url origin`
- 若本地对象缺少固定 main，可只 fetch `refs/heads/main` / 固定 commit 到一个显式临时 ref；禁止 checkout、merge、reset、pull、stash、clean、worktree 创建。
- 使用固定 commit `fd4355a29b912280c46dc5391e9bacf66be45d84` 的 Git 对象，对**精确路径** `apps/flutter_elitesync_module` 做工具级 `git archive`/等价只读快照物化到专用隔离根；这是构建输入复制，不授权 agent 搜索、总结或枚举该模块源码。

不运行 `git status`，不读写默认 index，不检查 untracked 或 dirty state，不把本地 HEAD 等同于远端 main。

### 3.2 仅用于解析工具路径/参数的定点本地读取

允许读取以下**精确键/路径**；不要输出同文件其他配置、凭据或无关环境变量：

Flutter SDK 路径按当前 `build.gradle.kts` 的顺序解析：

1. `D:\EliteSync-v10\apps\flutter_elitesync_module\.android\local.properties` 中仅键 `flutter.sdk`；
2. `D:\EliteSync-v10\apps\android\local.properties` 中仅键 `flutter.sdk`；
3. 环境变量 `FLUTTER_HOME`；
4. 若前三项都没有，允许 `Get-Command flutter.bat`（或 Windows 上实际 Flutter executable）一次，仅取得 executable path。

Android SDK 路径按：

1. `D:\EliteSync-v10\apps\android\local.properties` 中仅键 `sdk.dir`；
2. `ANDROID_SDK_ROOT`；
3. `ANDROID_HOME`。

Java 路径按：

1. `JAVA_HOME`；
2. 若缺失，允许 `Get-Command java.exe` 一次并取得其路径；
3. 解析后允许一次 `java.exe -version`，仅用于记录 Java major/version；不得安装或切换 JDK。

pub cache seed：

- `PUB_CACHE`；若缺失则只采用 `%LOCALAPPDATA%\Pub\Cache` 这一官方默认候选并做存在性/目录类型检查。

Gradle seed：

- `%USERPROFILE%\.gradle\caches`
- `%USERPROFILE%\.gradle\wrapper\dists`

只做存在性和目录类型检查；不得读取 `%USERPROFILE%\.gradle` 其他内容、credentials、init scripts 或无关配置。

`flutterDartDefines` 解析顺序：

1. 环境变量 `ORG_GRADLE_PROJECT_flutterDartDefines`；
2. `%USERPROFILE%\.gradle\gradle.properties` 中仅解析键 `flutterDartDefines`，不得输出/引用任何其他行；
3. 当前项目 `apps/android/gradle.properties`（已固定 blob）中的同名键；
4. 若以上均不存在，按当前 `build.gradle.kts` 的 `.orEmpty()` 合同记录 `flutterDartDefines = EMPTY`，direct command 不添加 dart-define 参数。

不要从 shell history、IDE history、聊天记录、旧仓库或仓库搜索中寻找参数。

### 3.3 Windows Sandbox 能力检查

允许一次只读查询 Windows Sandbox feature，例如：

`Get-WindowsOptionalFeature -Online -FeatureName Containers-DisposableClientVM`

若查询需要权限但无法完成，或 feature 不可用/未启用：记录 `M3 PRECONDITION BLOCKED — WINDOWS SANDBOX UNAVAILABLE`；**不安装/启用 Windows feature**，不改系统配置，不尝试 Hyper-V/容器替代方案。

## 4. 隔离物化合同

仅当 §3 所需路径都能解析且隔离根不存在时，创建：

- `D:\EliteSync-M3-readiness-v02\input`
- `D:\EliteSync-M3-readiness-v02\evidence`
- `D:\EliteSync-M3-readiness-v02\m3.wsb`
- 本任务生成的 guest 启动脚本/manifest 文件。

允许写入仅限上述专用根。不得写 `D:\EliteSync-v10` 源/生成状态、宿主 pub/Gradle/Flutter caches 或用户主目录。

Sandbox 配置必须至少：

- `Networking = Disable`；
- source snapshot、Flutter SDK host path、Android SDK、Java/JDK、pub cache seed、Gradle caches seed、Gradle wrapper/dists seed全部以**只读 mapped folder**提供；
- `evidence` 为唯一可写宿主 mapped folder；
- clipboard 及无关音视频/打印重定向在平台支持的配置项中关闭；
- 不映射整个 `D:\EliteSync-v10`、整个 `%USERPROFILE%`、旧 `D:\EliteSync` 或任何真实数据目录。

在 guest 内：

- 只读 source snapshot复制到 `C:\M3\work\apps\flutter_elitesync_module` 后作为可写构建副本；
- Flutter SDK只读 seed复制到 `C:\M3\tools\flutter`，允许其内部 cache/tool state 在 guest 内写；
- pub seed复制到 `C:\M3\pub-cache`；
- Gradle `caches` 与 `wrapper\dists` seed复制到新的 `C:\M3\gradle-home` 对应位置；不得复制宿主 Gradle properties/credentials/init scripts；
- `GRADLE_USER_HOME=C:\M3\gradle-home`；
- `PUB_CACHE=C:\M3\pub-cache`；
- `JAVA_HOME`、`ANDROID_HOME`/`ANDROID_SDK_ROOT` 绑定到 guest 只读工具映射；
- `TEMP`/`TMP` 使用 guest 内 `C:\M3\temp`；
- 可在 guest-local Gradle home 创建最小 `gradle.properties` 仅包含非敏感执行控制（例如禁用持久 daemon），不得导入宿主配置。

所有源、cache、SDK 复制都是隔离准备；不允许 agent 用这些副本进行额外源码/缓存内容分析。

## 5. 条件式执行：只允许一次

只有以下全部成立才进入 M3 attempt：

- 固定 main/task/blob 门通过；
- Sandbox feature 可用；
- Flutter SDK、Java、Android SDK、pub seed、Gradle cache seed、wrapper/dists seed均解析并存在；
- sandbox config被定点复读，确认 `Networking=Disable`、只读输入和唯一可写 evidence 映射；
- source snapshot成功物化；
- 不存在任何需要覆盖宿主既有隔离根的情况。

### 5.1 guest 离线 pub 前置

在 guest 模块副本内，只允许一次：

`<guest dart.exe> pub get --offline`

使用 guest `PUB_CACHE`。最长 10 分钟。它可以写 guest 模块的 `pubspec.lock` / `.dart_tool` 和 guest cache；不得写宿主原模块。

若非零、超时或必要包缺失：分类 `M3 PRECONDITION BLOCKED — OFFLINE PUB INSUFFICIENT`，不要运行 M3，不下载、不联网、不重试。

### 5.2 唯一 M3 命令

若离线 pub 前置成功，执行一次：

`<C:\M3\tools\flutter\bin\flutter.bat> build aar --no-debug --no-profile --no-pub [resolved --dart-define args]`

工作目录：

`C:\M3\work\apps\flutter_elitesync_module`

顶层 M3 attempt 最长 30 分钟，无自动/人工重试。

整个 Flutter→Dart→Gradle→wrapper 子进程树必须处于 Networking=Disable 的 Sandbox 内。不能以运行失败为理由临时放开网络、下载依赖或调用宿主 tool daemon。

## 6. Fresh M3 证据与保留产物

本次 evidence root：

`D:\EliteSync-M3-readiness-v02\evidence`

它是新 attempt 的证据根，不回填历史 `D:\EliteSync-v10` M1 lane。

至少写出：

- `M3-ISO-V02-001-result.json`：前置项、命令是否启动、exit code、timeout/interrupt、结果分类、关键解析路径的**非敏感标识**；不得写 secret/property其他值。
- `M3-ISO-V02-001.log`：本次 guest 准备和工具 stdout/stderr；如日志意外包含凭据/secret，最终 GitHub 报告只记录存在该风险，不复制 secret；本地 evidence 不自动上传。
- 若 `build\host\outputs\repo` 在本次 attempt 后存在，允许将该**生成型 Maven repo subtree**复制到 `evidence\maven-repo` 作为后续 M2 的本地输入候选；这不是 M2 执行。
- 对 exact locator：
  `build\host\outputs\repo\com\elitesync\flutter_elitesync_module\flutter_release\1.0\flutter_release-1.0.aar`
  进行一次与本 attempt 绑定的存在性检查；命中时允许记录 size 与 SHA-256，并复制该生成产物；未命中只记录 NON-HIT。

这是新的 fresh evidence method，不是历史 M1 retry。

结果分类至少使用：

- `M3 PRECONDITION BLOCKED`
- `M3 GENERATION COMMAND SUCCESS`
- `M3 GENERATION COMMAND FAILURE`
- `M3 TIMEOUT / INTERRUPTED`
- `M3 ISOLATION / AUTHORITY VIOLATION BLOCKED`
- `M3 RESULT INDETERMINATE`

命令 exit 0 与 exact AAR HIT 要分别报告。只有两者都成立，才可记录：

`M3 GENERATION + RELEASE-AAR PRODUCTION EVIDENCE = HIT FOR M3-ISO-V02-001`

这仍不等于 M2 宿主依赖解析成功或 App 可安装。

## 7. 禁止项与失败处理

- 外部网络/依赖下载：禁止。
- 原 `D:\EliteSync-v10` 内容写入：禁止。
- 旧 `D:\EliteSync` / `zcx369658780/EliteSync`：本任务禁止访问；旧仓库恢复报告只供 ChatGPT 后续规划，不是本 M3 输入。
- README/FD02、参与者/真实用户数据、private Conversation、Safety Operations、生产访问：禁止。
- 原工作区/generated output/cache 内容的人类分析、仓库枚举、代码搜索：禁止。
- 安装/更新 Flutter、Java、Android SDK、Gradle、Windows feature：禁止。
- 第二次 M3、第二次 pub prerequisite、换命令重试：禁止。
- 清理：不执行。专用宿主根和 evidence 保留；Sandbox guest关闭后的未导出临时状态可消失，但不得声称已保存。

如果出现不在合同内的写入/网络需求，立即停止当前执行，记录 `M3 ISOLATION / AUTHORITY VIOLATION BLOCKED`，不扩大范围。

## 8. 唯一 GitHub 候选交付

执行结果候选只允许：

1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_1.md`；
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，只更新页首/§1/§4/§5及追加本 attempt 状态；§2产品语义、§3保护边界、§6官方规范来源不因本任务改写。

结果报告必须记录：固定基线、实际 local HEAD（仅上下文）、Sandbox能力、每个输入来源（不含secret）、resolved dart-define项数量/键名可记录但敏感值不输出、离线pub结果、M3 exit、exact AAR HIT/NON-HIT、hash/size（如HIT）、evidence路径、未执行事项、下一步是否可进入M2。

如果 M3 + exact AAR HIT：下一建议为独立 M2 宿主依赖解析证据，不在本任务执行。

如果 M3 未启动或失败：报告单一主因和最小剩余决定；不得自动生成更多同义治理报告。

候选分支：

`review/h01-bib03-u15-td01-m3-isolated-execution-evidence-v0-1`

候选 subject：

`docs: record isolated offline M3 execution evidence`

候选以本任务 commit 为唯一父；一个 commit；恰好上述两路径。使用 GitHub Git Database/连接器发布，不用本地 default index，不本地 commit。

发布前一次重读 main/task ref，要求仍匹配启动时固定值；发布后一次验证 sole parent、两路径和 blobs。无新疑点不重复全套检查。

执行者发表后停止，不自我接受、不更新 main、不下发 M2、不更新/上传 ChatGPT 项目源。

## 9. 现有产品/法律/Safety边界

本任务仅扩展 M3 隔离技术证据权限。D-02 / `D02-DURABLE-UNKNOWN-01`、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、Database 0/8、deferred PUI、PUI-PREREQ-12=0、accepted legal/Safety/no-processing保持；implementation、LC-03、LC-04、Phase36仍未授权。

M2在本任务开始时仍 deferred；只有成功的新 M3 artifact evidence 才可能使下一张 M2 任务成为当前证据优先项。