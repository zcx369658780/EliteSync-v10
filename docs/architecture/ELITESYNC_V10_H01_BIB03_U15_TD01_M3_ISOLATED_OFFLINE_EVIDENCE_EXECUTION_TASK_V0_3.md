# EliteSync v10｜M3 隔离离线证据与条件式一次执行任务 v0.3

Status: `TASK ONLY — OWNER APPROVED OPTION 1 — BOUNDED HOST EVIDENCE + ISOLATION PREP + CONDITIONAL ONE-SHOT M3 — NO PRODUCT IMPLEMENTATION AUTHORITY`

日期：2026-09-07（Asia/Singapore）。Owner 已明确选择上一轮 M3 readiness 报告 §4 的选项1：**无外部网络的隔离证据范围**。

## 1. 固定入口

仓库：`zcx369658780/EliteSync-v10`。

执行时先实时读取 GitHub `main`，要求恰为：

`fd4355a29b912280c46dc5391e9bacf66be45d84`

FIRST 主动读取：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

要求 blob：`18485c95262051e43892436fb52413132c5ee626`。

随后读取并绑定：

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXECUTION_READINESS_DECISION_V0_2.md`，要求 blob `9466dba2800e12bf1f17414606e34af452134741`；
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`；
- `AGENTS.md`；
- 本任务。

旧 `8b640576822b01ae00bb04b9b5deaa75db53365c` 继续不得恢复。

## 2. Owner 选项1的精确授权

允许本任务一次完成：

1. 对具名 Flutter / Java / Android SDK / pub / Gradle 输入做定点、只读的路径与元数据确认；
2. 读取 `D:\EliteSync-v10` Git root 与当前本地 HEAD；不要求 HEAD=main；
3. 从当前本地 HEAD 的**已提交 Git 对象**导出 `apps/flutter_elitesync_module/**`，不得从 dirty/untracked/staged 工作区复制源码；
4. 仅在不存在时创建专用根 `D:\EliteSync-M3-readiness-v02`；存在未知内容则停止，不覆盖；
5. 在专用根创建 `input\`、`evidence\`、`manifest.json`、`m3.wsb` 及一个必要的最小 bootstrap 脚本；
6. 把具名已有工具/缓存作为只读宿主输入 seed，复制到隔离客体内部专用可写位置；不输出 seed 内容，不自动安装或下载；
7. Windows Sandbox 或等价已批准 OS 隔离必须把外部网络设为零；不映射原仓库或用户主目录为可写位置；
8. 只有完整命令、source snapshot、工具路径、seed、隔离控制、attempt ID 与 output locator 全部闭合时，允许执行一次顶层 M3；30 分钟上限，无自动重试；
9. attempt 后只执行一次与该新 attempt 绑定的定点产物存在性检查；不复用历史 M1 lane；
10. 任一前置条件不满足即报告 `PRECONDITION BLOCKED`，不得联网、下载、安装、改原仓库或扩大权限。

## 3. 原根只读合同

原根：`D:\EliteSync-v10`。

允许：

- `git -C D:\EliteSync-v10 rev-parse --show-toplevel`
- `git -C D:\EliteSync-v10 rev-parse HEAD`
- 对当前 HEAD 的 `apps/flutter_elitesync_module/**` 使用 `git archive` 或等价已提交对象导出。

禁止：`git status`、默认 index 读写、staged/unstaged/untracked 检查、pull/checkout/switch/merge/rebase/stash/reset/clean、目录枚举、`rg --files`、`find`、`fd`、`git ls-files`、`git ls-tree`、`git grep`、原仓库 build/cache/.android 写入。

## 4. 具名输入发现

### Flutter

依次：

1. 读取 `FLUTTER_ROOT`；
2. 若未绑定，允许一次 `where.exe flutter`。

只记录返回的 executable 路径并推导 SDK root；不得磁盘搜索。允许读取从 SDK root 直接推导的明确版本元数据文件；无法建立版本则记 `VERSION_NOT_ESTABLISHED`，不要运行 `flutter --version` 补证明。

### Java

依次：

1. `JAVA_HOME`；
2. 若无有效值，允许一次 `where.exe java`。

只做存在性和文件版本元数据读取，不执行 Java 程序补证明。

### Android SDK

依次读取 `ANDROID_SDK_ROOT`、`ANDROID_HOME`。首个有效字面路径即绑定；均缺失则 `ANDROID_SDK_NOT_BOUND`，不得扫描或运行 `sdkmanager`。

### pub / Gradle seeds

只读：`PUB_CACHE`、`GRADLE_USER_HOME`、`USERPROFILE`。

允许按官方默认规则从 `USERPROFILE` 推导一个 pub cache 候选和一个 Gradle user home 候选，只做字面路径存在性检查。最终最多绑定一个 pub seed 和一个 Gradle seed；若路径指向 repo 或明显自定义未知目录，记 `SEED_NOT_SAFE_TO_STAGE`，不复制。

### 完整 M3 参数

只从以下精确文档恢复已记录的 release-only M3 参数，不搜索代码或历史：

- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ENTRY_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_TASK_V0_1.md`
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_AAR_GENERATION_BUILD_EXECUTION_METHOD_SIDE_EFFECT_GOVERNANCE_REVIEW_V0_1.md`

若仍不能得到完整命令和全部 dart-define 参数，记 `M3_FULL_ARGUMENTS_NOT_BOUND` 并停止生成步骤。

## 5. manifest 与 Windows Sandbox

`manifest.json` 至少记录：

- task/base commit；
- local HEAD；
- source snapshot origin；
- Flutter/Java/Android 路径与版本证据状态；
- pub/Gradle seed 绑定；
- full M3 command/args 或 NOT_BOUND；
- `M3_ATTEMPT_ID`；
- expected output locator；
- isolation config；
- `ZERO_EXTERNAL_NETWORK`。

`m3.wsb` 至少要求：

- Networking = Disable；
- ClipboardRedirection = Disable；
- 无关音视频/打印重定向关闭（如 schema 支持）；
- `input\` 只读映射；
- `evidence\` 是唯一允许写回宿主的映射；
- 不映射 `D:\EliteSync-v10`；
- 不映射用户主目录。

Sandbox 内建议：

- `C:\M3\work`
- `C:\M3\tools`
- `C:\M3\pub-cache`
- `C:\M3\gradle-home`
- `C:\M3\temp`

如果 Windows Sandbox 不可用或需要安装/启用 Windows feature，记 `SANDBOX_UNAVAILABLE` 并停止；不得安装或启用系统组件。禁止用 ping/外站请求验证断网。

## 6. 条件式一次 M3

全部前置闭合后，执行位置只能是：

`C:\M3\work\apps\flutter_elitesync_module`

命令类别仍为 direct release-only `flutter build aar`。是否加入 `--no-pub` 只能依据已绑定输入与官方证据，不能把它当网络隔离替代。

执行约束：

- 一次顶层 attempt；
- 最长 30 分钟；
- 无自动重试；
- 不清理失败状态；
- 无外部网络；
- 缺依赖不临时批准下载；
- 不运行宿主 M2；
- 不修改 v10 产品源码。

结果分类：

- `M3 PRECONDITION BLOCKED`
- `M3 GENERATION COMMAND SUCCESS`
- `M3 GENERATION COMMAND FAILURE`
- `M3 TIMEOUT / INTERRUPTED`
- `M3 SIDE-EFFECT / AUTHORITY VIOLATION BLOCKED`
- `M3 RESULT INDETERMINATE`

## 7. 一次新鲜定点产物证据

只在本次 attempt 实际启动后执行一次。expected output locator 必须在运行前冻结。

只允许检查**一个精确 locator 的存在性布尔值**。

禁止：目录枚举、artifact 内容读取、AAR/POM/checksum hash、历史 M1 target 重试、多 locator 扫描。

另记录：`POST_ATTEMPT_LOCATOR_HIT = true/false/not-run`。

## 8. 唯一交付

最终只发布：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_OFFLINE_EVIDENCE_EXECUTION_RESULT_V0_3.md`

报告至少包含：基线/task、本地 root/HEAD、具名工具/seed/input、manifest 摘要、Sandbox capability/control、M3 是否实际启动、单次结果、locator 结果、未运行步骤与原因，以及**一个**最小下一步建议。

候选分支：

`review/h01-bib03-u15-td01-m3-isolated-offline-evidence-execution-v0-3a`

候选 subject：

`docs: record isolated offline M3 evidence execution result`

候选以本任务 commit 为唯一父；一个 commit；只新增结果报告。不要修改 CURRENT_CONTEXT、AGENTS 或历史文档。

## 9. v9 旧资产报告的采用方式

Owner 同轮提供并由 ChatGPT 验收的 `ELITESYNC_V9_LEGACY_CAPABILITY_AND_ASSET_RECOVERY_REPORT` 表明旧项目已有 auth/profile/questionnaire/match/conversation/RTC/update/admin/media 等大量跨层资产与测试证据。

该报告只作为**后续 v10 代码规划的历史功能/行为索引**。本 M3 任务不访问旧 `D:\EliteSync`、不访问旧仓库、不复制旧代码。

`OLD FUNCTIONAL FACT != V10 PRODUCT DECISION`

`OLD CODE != V10 IMPLEMENTATION AUTHORITY`

`RECOVERY VALUE != RECOMMENDATION TO COPY`

## 10. 保持边界

README预算耗尽；FD02永久排除；受保护 staged state 不检查、不改动。M2 deferred。implementation / LC-03 / LC-04 / Phase36 未授权。无真实用户/数据、Safety Operations、新法律研究。

达到本任务终点即停止，不自行开启下一任务。