# EliteSync v10｜M3 隔离离线证据与条件式一次执行任务 v0.3

Status: `TASK ONLY — OWNER APPROVED OPTION 1 — BOUNDED HOST EVIDENCE + ISOLATION PREP + CONDITIONAL ONE-SHOT M3 — NO PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-07（Asia/Singapore）。仓库：`zcx369658780/EliteSync-v10`。Owner 已明确选择上一轮 M3 readiness 报告 §4 的**选项1：无外部网络的隔离证据范围**。

## 1. 固定基线与 Owner 授权

执行时先实时读取 GitHub `main`，要求恰为本任务发布时绑定的基线提交；启动 prompt 给出精确 SHA。

FIRST 主动读取：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

要求 blob：`18485c95262051e43892436fb52413132c5ee626`。

随后读取：

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md`
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`
- `AGENTS.md`
- 本任务

并核验启动 prompt 绑定的 task commit/blob/sole parent/单一路径范围。

Owner 本轮明确批准：

> 选项1 — 无外部网络的隔离证据范围。

该批准授权本任务在有限范围内：

1. 对**具名** Flutter / Java / Android SDK / pub / Gradle 相关输入执行定点、只读的路径与元数据确认；
2. 绑定 `D:\EliteSync-v10` 当前本地 Git 根与 HEAD，但不要求 HEAD=main；
3. 从**当前本地 HEAD 的已提交 Git 对象**中提取 `apps/flutter_elitesync_module/**` 作为不可变来源快照；不得读取或复制 dirty / untracked / staged 工作区内容；
4. 创建专用宿主根 `D:\EliteSync-M3-readiness-v02`，前提是该路径不存在；存在任何未知内容则停止，不覆盖；
5. 创建、读取和验证该专用根内的隔离 manifest、Windows Sandbox `.wsb` 配置与证据文件；
6. 把已批准的具名工具/缓存输入以**只读宿主输入**方式映射或复制到隔离客体内部专用可写位置；不把原仓库或用户主目录作为可写映射；
7. 外部网络授权为零。隔离客体必须禁用 Networking，并禁止用宿主 daemon / proxy / 用户目录映射绕过；
8. 只有在完整命令、输入、工具路径、隔离控制和输出 locator 全部闭合时，允许同一任务执行**一次**顶层 M3；30 分钟上限、无自动重试；
9. 在该 attempt 之后仅执行一次与新 attempt 绑定的定点产物存在性证据检查；这不是历史 M1 lane 重试；
10. 缺输入、缺工具、缺离线依赖、Sandbox 不可用或控制未闭合时，停止依赖步骤并报告 `PRECONDITION BLOCKED`；不自动安装、下载、联网、改原仓库或扩大权限。

`OWNER OPTION 1 APPROVAL != M3 SUCCESS`

`ISOLATED M3 ATTEMPT != M2 SUCCESS`

`OLD V9 ASSET RECOVERY != V10 IMPLEMENTATION AUTHORITY`

## 2. 当前允许的本地根与禁止项

### 原根

`D:\EliteSync-v10`

原根只允许：

- `git -C D:\EliteSync-v10 rev-parse --show-toplevel`
- `git -C D:\EliteSync-v10 rev-parse HEAD`
- 对本任务明确指定的已提交 Git 对象执行 `git archive` / 等价对象导出；不得从工作区复制源码。

禁止：

- `git status`
- 默认 index 读写
- staged / unstaged / untracked 检查
- `git add` / `commit` / `stash` / `reset` / `clean`
- checkout / switch / merge / rebase / pull
- 目录枚举、`rg --files`、`find`、`fd`、`git ls-files`、`git ls-tree`、`git grep`
- 原仓库 source/build/cache/.android 写入

### 专用宿主根

`D:\EliteSync-M3-readiness-v02`

仅在路径**不存在**时可创建。若已存在，报告 `HOST_ISOLATION_ROOT_CONFLICT` 并停止本任务的所有写入/执行，不删除、不改名、不覆盖。

允许创建的宿主子路径仅：

- `input\`
- `evidence\`
- `m3.wsb`
- `manifest.json`
- 为 Windows Sandbox 启动准备的最小 bootstrap 脚本（如确有需要，路径必须在 manifest 中列明）

不得创建第二个备用根。

## 3. 具名输入发现与证据合同

本任务允许以下**有限、非递归、具名**发现。不要为了“更全面”扫描磁盘。

### 3.1 Git 来源

记录：

- normalized root
- `M3_SOURCE_LOCAL_HEAD`

随后从该 HEAD 的 Git 对象提取：

`apps/flutter_elitesync_module/**`

到专用根 `input\source\apps\flutter_elitesync_module\`。

只提取已提交对象；禁止 README、FD02、旧 `D:\EliteSync`、旧仓库、受保护工作区内容。

### 3.2 Flutter

按顺序尝试：

1. 精确读取环境变量 `FLUTTER_ROOT`（若存在）；
2. 若未设置，允许一次 `where.exe flutter`；只记录返回的 executable 路径，不搜索其他磁盘位置。

从得到的 `flutter(.bat)` 路径推导 SDK root；只对该 root 做字面路径存在性/文件类型检查。

允许读取该 SDK root 下用于确定版本/来源的**精确已知元数据文件**，前提是路径从 SDK root 直接推导且不需目录枚举。若不能用明确文件建立版本，记录 `VERSION_NOT_ESTABLISHED`，不要运行 `flutter --version` 作为补救。

### 3.3 Java

按顺序：

1. 精确读取 `JAVA_HOME`；
2. 若无有效 `JAVA_HOME`, 允许一次 `where.exe java`。

只做 executable 存在性与文件版本元数据读取；不运行 Java 程序来补证明。

### 3.4 Android SDK

依次读取具名环境变量：

- `ANDROID_SDK_ROOT`
- `ANDROID_HOME`

只接受首个存在且字面路径有效的值。若均缺失，记录 `ANDROID_SDK_NOT_BOUND`，不要扫描磁盘或运行 `sdkmanager`。

### 3.5 pub / Gradle seeds

仅读取这些具名变量：

- `PUB_CACHE`
- `GRADLE_USER_HOME`
- `USERPROFILE`

允许据官方默认规则从 `USERPROFILE` 推导 pub/Gradle 的默认候选根，但只检查这些**字面候选根**存在性；不得递归列目录或输出内容。

为了无网尝试，可以把存在的具名 seed 根作为**opaque read-only seed**复制到 `input\seeds\...`，但前提：

- 不输出 seed 内容；
- 不解析凭据、用户数据或业务文件；
- 如果 seed 根不是标准工具缓存根，或发现它指向 repo / 用户自定义未知目录，则不复制，标 `SEED_NOT_SAFE_TO_STAGE`；
- 复制操作只针对最终绑定的单个 pub cache root 与单个 Gradle user home root，不额外寻找替代 cache。

### 3.6 完整 M3 参数

优先从以下**精确仓库文档**中恢复已记录的 release-only M3 参数，不搜索代码：

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ENTRY_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_TASK_V0_1.md`
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_REVIEW_V0_1.md`

如果三份固定文档仍不能得到完整命令与所有 dart-define 参数，记录 `M3_FULL_ARGUMENTS_NOT_BOUND` 并停止生成步骤；不要搜索源码、历史或聊天补全。

## 4. manifest 与隔离控制

在所有可得输入完成后生成 `manifest.json`，至少记录：

- task/base commit
- `M3_SOURCE_LOCAL_HEAD`
- source snapshot exact origin
- Flutter SDK path / version evidence state
- Java path / version evidence state
- Android SDK path
- pub seed path + staged copy path（若有）
- Gradle seed path + staged copy path（若有）
- full M3 command/args 或 NOT_BOUND
- `M3_ATTEMPT_ID`
- expected output locator
- isolation config path
- 网络授权：`ZERO_EXTERNAL_NETWORK`

### Windows Sandbox

`m3.wsb` 必须至少：

- Networking = Disable
- ClipboardRedirection = Disable
- AudioInput/VideoInput/PrinterRedirection 等无关重定向关闭（如当前 WSB schema 支持）
- 只读映射 `input\`
- 唯一允许写回宿主的映射为 `evidence\`
- 不映射 `D:\EliteSync-v10`
- 不映射用户主目录

Sandbox 客体建议路径：

- `C:\M3\input`：只读映射
- `C:\M3\work`：从只读 source snapshot 复制出的客体内部可写工作副本
- `C:\M3\tools`：从只读 SDK 输入复制出的客体内部可写工具副本
- `C:\M3\pub-cache`
- `C:\M3\gradle-home`
- `C:\M3\temp`

在启动任何 Flutter/Gradle 进程前必须验证 `.wsb` 配置文本满足上述要求，并确认 Windows Sandbox 能够被宿主启动。若本机 Sandbox capability 不可用或需要安装/启用 Windows feature，记录 `SANDBOX_UNAVAILABLE` 并停止；不得安装或启用系统组件。

禁止通过联网探测验证断网。只使用配置/宿主能力证据，不 ping、不访问外站。

## 5. 条件式一次 M3

仅当以下全部满足时执行：

- source snapshot 已闭合；
- Flutter / Java / Android 工具路径已绑定；
- 所需离线 seed 已绑定，或 manifest 明确记录不需要 seed 的依据；
- full M3 command/args 已绑定；
- Sandbox 可用；
- `.wsb` 禁网与映射配置已验证；
- evidence 映射可写且其他宿主位置不可写；
- `M3_ATTEMPT_ID` 与 expected output locator 已冻结。

执行位置只能在 Sandbox 客体内的：

`C:\M3\work\apps\flutter_elitesync_module`

执行命令类别仍为已接受的 direct release-only `flutter build aar`；是否加入 `--no-pub` 只依据已绑定输入/官方证据，不把它当作网络隔离替代品。

约束：

- 一次顶层 attempt；
- 最长 30 分钟；
- 无自动重试；
- 不清理失败状态；
- 外部网络必须保持禁用；
- 不因缺依赖而临时授权下载；
- 不运行宿主 M2；
- 不修改 v10 产品源码。

记录：

- command started / not started
- exit code（如有）
- timeout/interruption
- 与批准边界相关的日志

## 6. 一次新鲜定点产物证据

只在本次 attempt 实际启动后执行一次。

预期 locator 必须在 manifest 中先冻结，且只针对本次 Sandbox source/output layout。

允许检查：

- 一个精确 locator 的存在性布尔值

禁止：

- 目录枚举
- artifact 内容读取
- AAR/POM/checksum 内容或 hash
- 历史 M1 target 重试
- 多 locator 扫描

结果分类：

- `M3 PRECONDITION BLOCKED`
- `M3 GENERATION COMMAND SUCCESS`
- `M3 GENERATION COMMAND FAILURE`
- `M3 TIMEOUT / INTERRUPTED`
- `M3 SIDE-EFFECT / AUTHORITY VIOLATION BLOCKED`
- `M3 RESULT INDETERMINATE`

另记：`POST_ATTEMPT_LOCATOR_HIT = true/false/not-run`。

任何组合都不等于 M2 成功、App 可安装或产品实现完成。

## 7. 交付与发布

本任务执行者最终只发布**一份**结果报告：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_OFFLINE_EVIDENCE_EXECUTION_RESULT_V0_3.md`

报告必须包含：

1. 固定 GitHub 基线和 task contract；
2. 本地 root/HEAD 证据；
3. 具名工具/seed/input 绑定结果；
4. manifest 摘要；
5. Sandbox capability/control 结果；
6. M3 是否实际启动；
7. 若启动，单次结果和定点 locator 结果；
8. 没有运行的步骤及原因；
9. 下一步只给一个最小结果导向建议：M2、实现入口、或仍需补的一个具体前置条件；不要再拆同义治理任务。

候选分支：

`review/h01-bib03-u15-td01-m3-isolated-offline-evidence-execution-v0-3`

候选 subject：

`docs: record isolated offline M3 evidence execution result`

候选以本任务 commit 为唯一父；恰好一个候选 commit，只新增上述结果报告。不要修改 CURRENT_CONTEXT、AGENTS 或其他历史文档；下一轮验收者负责必要状态推进。

执行前/发布前各一次核验远端 main 与 task ref；无新差异不重复全套验证。

## 8. v9 报告的有限采用

Owner 同轮提供 `ELITESYNC_V9_LEGACY_CAPABILITY_AND_ASSET_RECOVERY_REPORT`。它已被 ChatGPT 验收为高价值的**历史功能/资产索引**，包括旧 auth/profile/questionnaire/match/conversation/RTC/update/admin/media 等跨层事实及 27 个高价值 locators。

本 M3 任务**不读取旧 `D:\EliteSync`、不访问旧仓库、不复制旧代码**。该报告仅用于后续代码规划避免“从零假设”；不改变本任务的 v10 构建证据范围。

`OLD FUNCTIONAL FACT != V10 PRODUCT DECISION`

`OLD CODE != V10 IMPLEMENTATION AUTHORITY`

`RECOVERY VALUE != RECOMMENDATION TO COPY`

## 9. 永久边界

README 预算耗尽；FD02 永久排除；旧仓库仍不直接访问；受保护 staged state 不检查、不改动。M2 deferred。implementation / LC-03 / LC-04 / Phase36 仍未授权。无真实用户、真实数据、Safety Operations、新法律研究。

Owner 允许更快推进和降低重复审核门限，但不把特殊权限扩展为无限制执行。达到本任务结果终点即停止，不自行开启下一任务。
