# EliteSync v10｜既有 R4 Share 桥接、固定模块续行与条件式 M3 v0.8-R6-R2

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO NEW WSB SHARE — EXISTING R4 MAPPING BRIDGE ONLY`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `ec16e067b80671a2c9bfeb957a7acc709d9fb78e`。该 main 已接受 R6-R1 候选的精确 tree `95fae43dcfb9c1b8bc8a49a62bb9883c22f03896`：GitHub 远端 authority、唯一 task-owned fetch、fixed main=`ac14a7ccac09fa6117936f133b50593bd5023c1d`、module tree=`e369db9c603838182d29ae501a77f1afe56b6086`、固定 ZIP 与模块物化均 PASS；物化模块为 527 文件、301 目录、3234145 bytes、reparse=0，manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

R6-R1 在唯一 Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036` 上的第一项新 `wsb share` 返回 exit=`-2147024809`（0x80070057 / E_INVALIDARG，`Value does not fall within the expected range.`），因此 guest 未启动。该失败不证明 Sandbox 不可用，也不推翻 R3/R4 已通过的 existing-session、guest.started、禁网隔离、dispatch 冒烟或 R4 内部工具/cache 副本。

Microsoft 官方 CLI 合同允许 `wsb share` 将一个已存在 host folder 映射到 Sandbox 中的现有或新 folder；当前没有足够证据把 0x80070057 归因为路径长度、share 数量上限或其他具体根因。本任务**不重开新 share 根因调查，也不调用任何新的 `wsb share`**。

本任务唯一目标：利用 R4 已存在且曾实测成功的 writable evidence 映射作为一次性传输桥，不新增 runtime share；把 R6-R1 已验证模块 ZIP 与本轮 bootstrap 放入该桥，重新建立 guest 证据链；复用 R4 现有 guest 工具/cache，展开固定模块到新的 guest 工作目录，运行真实 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR。M2仍不执行。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R2 任务；允许仅在旧 R4 host evidence 根 `W/evidence/resume-r4` 下新增一个精确子目录 `r6r2-bridge` 作为传输桥，严禁修改、覆盖、删除该根中任何既有文件/目录。允许把 R6-R1 已验证模块 ZIP、冻结 dispatch/copy 与本轮 bootstrap 复制到该新子目录，并通过 R4 既有 writable share `C:/M3R4/evidence` 访问。不得执行新的 `wsb share`，不得 stop/close/reset/kill Owner Sandbox。仅在任务专用 guest PowerShell 进程使用进程级 RemoteSigned。guest 隔离/派发门与固定模块建立后，允许真实 Git/Java、一次 offline pub 及条件式一次 M3。不联网补包、不写原仓库/默认 index/working tree/宿主 SDK/cache/产品源码，其余边界保持。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 v0.8-R6-R2。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始时通过 GitHub 远端核验：
1. `refs/heads/main` 必须精确为 A=`ec16e067b80671a2c9bfeb957a7acc709d9fb78e`。
2. FIRST：A 中 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺少 task ref/object 不构成 blocker。
4. task commit 唯一父必须为 A；相对 A 必须 ahead=1/behind=0 且只新增本任务文件。
5. A 中 R6-R1 result blob 必须为 `b47be1a5c33c7499e14678a0dc842e6d8dc5cf09`。
6. A 中 CURRENT_CONTEXT 必须为 R6-R1 状态，使用 A 中实际 blob 作为本轮候选更新基底。

远端 authority 失配才 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。不得因此访问 README/FD02/旧仓库，不得仓库枚举/搜索，不访问默认 index 或受保护 staged state。

## 3. 固定本地输入与桥接边界

固定工作区：`W=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读绑定 R6-R1：
- `W/evidence/resume-r6-r1/module-fixed-main.zip`，SHA-256 必须=`342F9D0BCB909CA73660FE9F98D17185F1ABD462C1B8712705DD3916E316B050`，size=966335。
- `W/input-r6-r1/apps/flutter_elitesync_module` 必须存在、Container、非空、reparse=0；只允许核对 R6-R1 已记录统计/manifest，不重新物化、不联网。
- `W/scripts/dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- `W/scripts/copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。

R4 existing writable host root：`R4E=W/evidence/resume-r4`。只允许精确 `Test-Path` / Container 检查；不得枚举或修改其中既有条目。

新桥目录固定：`B=R4E/r6r2-bridge`。新 canonical evidence 固定：`E=W/evidence/resume-r6-r2`。

开始时 B 与 E 必须均不存在。任一已存在：STOP `R6R2_TASK_OWNED_PATH_ALREADY_EXISTS`；不得删除、清理或复用。

创建 B 后，只允许在 B 内写本轮文件。严禁对 `R4E` 其他相对路径执行写、移动、删除、重命名或覆盖。

复制到 B：
- `module-fixed-main.zip`（必须保持上述 SHA/size）。
- `dispatch.ps1`、`copy.ps1`（必须保持上述 SHA）。
- 本轮 `guest-r6r2.ps1`、必要的 synthetic batch target/fixture；全部在执行前冻结 SHA-256。

因为 B 位于旧 R4 writable evidence mapping 的 host 源之下，本轮明确承认这是**桥接子目录**；它不是对旧 R4 证据正文的改写。任务结束时 B 保留，不为了“清理”修改旧 R4 根。

## 4. 现有 Sandbox 与既有 share 可达性门

只允许调用：`wsb --version`、`wsb list --raw`、`wsb exec`。**本任务禁止调用 `wsb share` 和 `wsb stop`。**

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 => STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 => STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

随后通过同一 ID、run-as System 执行一个无副作用精确 probe，仅以 exit code 判断 R4 既有映射是否仍可达：
- `C:/M3R4/evidence/r6r2-bridge/guest-r6r2.ps1` 存在；
- `module-fixed-main.zip`、dispatch/copy 的 SHA 与 host 冻结值匹配。

不得依赖 `wsb exec` stdout 作为证据（官方 CLI 当前不提供进程 I/O）。probe exit=0 才继续；否则 STOP `R4_EXISTING_EVIDENCE_BRIDGE_NOT_AVAILABLE`，不得尝试新 share 或新 Sandbox。

## 5. R6-R2 guest preflight、隔离与派发门

生成新 nonce `M3-ISO-V02-008-R6R2-<random>`。通过同一 R4 evidence bridge 运行 `guest-r6r2.ps1`，run-as System，Windows PowerShell：`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

guest 的所有本轮证据只能写：`C:/M3R4/evidence/r6r2-bridge/`。不得写旧 R4 evidence 的其他路径。

preflight 必须实际记录并验证：
- `guest.started`，nonce 与 Sandbox ID 精确匹配；
- Windows PowerShell 5.1；
- Process/effective execution policy=`RemoteSigned`；
- Security module Name 与精确系统 Path；
- 活动网络适配器=0；默认路由=0；
- dispatch/copy 字节 SHA 与 host 冻结值一致。

随后使用同一 dispatch 完成：
- ordinary native 参数冒烟，`override_present=false`，含 space 参数实际进入 OS；
- batch pub shape；
- batch M3 shape；
- exit37 原样传播。

任一失败立即停止下游并如实分类；不得重跑 host 4+6，不重新设计 dispatch/copy/策略。

## 6. 固定模块通过桥接 ZIP 在 guest 内建立

不得再 share `input-r6-r1`。guest 直接使用桥中的：
`C:/M3R4/evidence/r6r2-bridge/module-fixed-main.zip`。

先验证 SHA-256=`342F9D0BCB909CA73660FE9F98D17185F1ABD462C1B8712705DD3916E316B050`，然后只解包到新 guest task root：`C:/M3R6R2/w`。

必须形成且非空：`C:/M3R6R2/w/apps/flutter_elitesync_module`；统计 file_count/total_bytes/reparse_count，并与 host 物化事实在合理范围内一致。不存在或空 => STOP `FIXED_MODULE_CWD_MISSING_AFTER_BRIDGE_EXPAND`；不得搜索替代路径。

## 7. R4 工具/cache 复用，不新增 share

只对以下精确 R4 guest 内部路径做 `Test-Path -LiteralPath`：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android SDK `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub cache `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- Gradle wrapper dists `C:/M3R4/h/wrapper/dists`

七项全部存在 => 复用。

若任一不存在，只允许检查对应 R4 **已存在 guest seed mapping**：
- Flutter `C:/M3R4/s/f`
- Android `C:/M3R4/s/a`
- JDK `C:/M3R4/s/j`
- Git `C:/M3R4/s/g`
- Pub `C:/M3R4/s/p`
- Gradle caches `C:/M3R4/s/h`
- wrapper dists `C:/M3R4/s/d`

若缺失项的精确 seed 仍存在，可按已接受 copy/robocopy 合同只在 guest 内恢复该缺失项到 `C:/M3R6R2/...`；不得新 `wsb share`、不得搜索 host 或其他 guest 路径。若内部副本和对应 seed 均缺失 => STOP `R4_GUEST_TOOL_REUSE_NOT_AVAILABLE`。

## 8. 真实 Git / Java / offline pub / M3 / AAR

前置全部 PASS 后真实运行一次 Git 与 Java，使用 R4 复用路径或本轮精确 guest fallback 路径：
- Git `--version`
- Java `-version`

每次记录 RunNative 收到参数、`override_present=false`、最终 Arguments、actual executable、stdout/stderr、exit。任一失败立即停止，不重找工具。

设置 guest 环境只指向 guest 内部副本；`JAVA_HOME`、Android SDK、Pub cache、Gradle home、HOME/USERPROFILE/TEMP/TMP 均不得写回 host seed。cwd=`C:/M3R6R2/w/apps/flutter_elitesync_module`。

真实 pub 只运行一次：Flutter `pub get --offline`，最多10分钟。不得联网补包、下载或重试；非零必须按真实诊断分类，不能自动写 `OFFLINE_PUB_INSUFFICIENT`。

仅 pub exit=0 后运行一次 M3：`build aar --no-debug --no-profile --no-pub`；accepted defines=`EMPTY`，追加0个 dart-define；最多30分钟，不重试。

仅 M3 实际启动后检查一次：
`C:/M3R6R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录 size/SHA-256；M3未启动 => AAR=`NOT_CHECKED`, probe=0。M2不得执行。

## 9. canonical evidence、生命周期与候选

`wsb exec` 结束后，host 将 B 完整复制到新的 E；B 与 E 的 task-owned manifest hash 必须一致。不得删除 B。E 是本轮 canonical evidence root；B 是 existing-share transport bridge。若复制/manifest 不一致，结果必须如实标记证据限制，不得重跑 pub/M3。

Owner Sandbox 不得 stop/close/reset/kill。task-owned guest/工具进程按既有 Job/PID 规则收尾。不得调用新的 `wsb share`。

候选分支：`review/h01-bib03-u15-td01-m3-existing-share-bridge-v0-8-r6-r2`。

发布一个 candidate commit，唯一父为本任务 commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_SHARE_BRIDGE_AND_EXECUTION_RESULT_V0_8_R6_R2.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，只改页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT 从本任务固定 main A 的正常 UTF-8 版本开始；发布前检查 UTF-8/无明显 mojibake。

结果必须返回：candidate/parent/two blobs；R6-R1 ZIP/module绑定；fresh Sandbox ID；既有 R4 evidence bridge probe；bridge/bootstrap hashes；guest.started/nonce/policy/Security/isolation；派发冒烟；module cwd；R4 tool/cache reuse/fallback；Git/Java；pub；M3；AAR；B→E manifest；Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。

## 10. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护 index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36与产品实现边界保持。无新的网络权限；不修改持久策略/信任/网络/系统配置。