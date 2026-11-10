# EliteSync v10｜既有 R4 Share 目录桥接、固定模块续行与条件式 M3 v0.8-R6-R3

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO NEW WSB SHARE — NO ARCHIVE EXTRACTION — DIRECT DIRECTORY BRIDGE ONLY`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `dcebc45e95bb53235ba2bd89b81fb40b56a6cccb`。该 main 已接受 R6-R2 候选的精确 tree：R4 existing writable evidence bridge 可达；guest.started、PowerShell 5.1、Process/effective RemoteSigned、Security 系统路径、活动网卡0、默认路由0与 ordinary/batch dispatch 冒烟均 PASS。R6-R1 fixed main/module object 与宿主物化也已接受：module tree=`e369db9c603838182d29ae501a77f1afe56b6086`，宿主固定模块 `W/input-r6-r1/apps/flutter_elitesync_module` 为527文件、301目录、3234145 bytes、reparse=0，manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

R6-R2 唯一新阻塞是 guest 中固定 `Expand-Archive` 无法加载 `Microsoft.PowerShell.Archive`。本任务不修复、不导入、不替换 PowerShell Archive 模块，也不依赖任何 ZIP 解压 API。

本任务唯一目标：**把已经物化并验证过的宿主模块目录本身复制进一个全新的 R4 evidence bridge 子目录，通过 R4 已存在 writable mapping 直接暴露给 guest，再按既有 copy/robocopy 合同复制到新 guest 工作目录；模块 cwd 建立后继续 R4 工具/cache 精确复用、真实 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R3 任务；允许仅在旧 R4 host evidence 根 `W/evidence/resume-r4` 下新增精确子目录 `r6r3-bridge`，并把已验证的 `W/input-r6-r1/apps/flutter_elitesync_module` 目录、冻结 dispatch/copy 与本轮 bootstrap 复制到该子目录；严禁修改、覆盖、删除旧 R4/R6-R2 既有条目。不得执行新的 `wsb share`、不得使用 Expand-Archive 或其他 archive 解包流程、不得 stop/close/reset/kill Owner Sandbox。仅在任务专用 guest PowerShell 进程使用进程级 RemoteSigned。guest 隔离、派发与目录桥接模块建立后，允许真实 Git/Java、一次 offline pub 及条件式一次 M3。不联网补包、不写原仓库/默认 index/working tree/宿主 SDK/cache/产品源码，其余边界保持。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 v0.8-R6-R3。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始时只通过 GitHub 远端核验：
1. `refs/heads/main` 必须精确为 A=`dcebc45e95bb53235ba2bd89b81fb40b56a6cccb`。
2. FIRST：A 中 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺少 task ref/object 不构成 blocker。
4. task commit 唯一父必须为 A；相对 A 必须 ahead=1/behind=0 且只新增本任务文件。
5. A 中 R6-R2 result blob 必须为 `6c96210e66f11f0618032503f8873ca9ed9812b4`。
6. A 中 CURRENT_CONTEXT 必须为 R6-R2 状态，blob=`679fc67469c18fb6dc2a63f700910f77731ef2d1`。

仅远端 authority 失配才 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。不得访问 README/FD02/旧仓库，不得仓库枚举/搜索，不访问默认 index 或受保护 staged state。

## 3. 固定本地来源与新桥目录

固定工作区：`W=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读绑定：
- `SRC=W/input-r6-r1/apps/flutter_elitesync_module`：必须存在、Container、reparse=0、非空；只允许复核已接受统计与 manifest。
- 已接受 SRC manifest SHA-256=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。
- `W/scripts/dispatch.ps1` SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`。
- `W/scripts/copy.ps1` SHA-256=`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`。

R4 host evidence根：`R4E=W/evidence/resume-r4`。只允许精确 Test-Path/Container，不得枚举或修改旧条目。

新桥：`B=R4E/r6r3-bridge`。新 canonical evidence：`E=W/evidence/resume-r6-r3`。

B 与 E 开始时必须均不存在；任一已存在 STOP `R6R3_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除、清理或复用。

创建 B 后，仅允许在 B 内新增：
- `B/module/apps/flutter_elitesync_module`：由 SRC 精确复制；
- `dispatch.ps1`、`copy.ps1`；
- `guest-r6r3.ps1`、`probe-r6r3.ps1` 与必要 synthetic batch fixtures；
- 本轮 host/guest evidence。

严禁写 R4E 其他相对路径，也不得修改旧 `r6r2-bridge`。

## 4. 宿主目录桥接复制与字节一致性

从 SRC 到 `B/module/apps/flutter_elitesync_module` 使用已接受 copy/robocopy 参数与退出分类；不得重新设计复制算法，不得从其他路径补文件。

复制后只允许对 SRC 与新 B/module 根做 task-owned manifest 比较。要求：
- 目标 exists/Container；
- file_count=`527`；
- directory_count=`301`；
- total_bytes=`3234145`；
- reparse_count=`0`；
- 按相对路径+SHA-256计算的 manifest 必须精确=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

任一失配 STOP `R6R3_HOST_DIRECTORY_BRIDGE_MISMATCH`。不得改用 ZIP 或搜索替代来源。

## 5. 现有 Sandbox 与 R4 mapping 可达性门

本任务只允许调用：`wsb --version`、`wsb list --raw`、`wsb exec`。**禁止 `wsb share`、`wsb stop` 与新建 Sandbox。**

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 => STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 => STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

随后同一 ID、run-as System 执行无副作用 probe，只验证：
- `C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module` 存在、非空；
- guest 可计算目录 manifest，必须精确匹配上述 accepted manifest；
- `guest-r6r3.ps1`、dispatch/copy 存在且 SHA 匹配 host 冻结值。

probe exit=0 才继续；失败 STOP `R4_EXISTING_DIRECTORY_BRIDGE_NOT_AVAILABLE`。不得尝试新 share、ZIP 展开或新 Sandbox。

## 6. R6-R3 guest preflight 与派发门

生成 nonce=`M3-ISO-V02-008-R6R3-<random>`。通过同一 R4 mapping 运行 `guest-r6r3.ps1`，run-as System，Windows PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

所有本轮 guest evidence 只写 `C:/M3R4/evidence/r6r3-bridge/`。

必须实际验证：
- `guest.started`，nonce+Sandbox ID匹配；
- PowerShell 5.1；
- Process/effective=`RemoteSigned`；
- Security module Name 与精确系统 Path；
- 活动网络适配器0、默认路由0；
- dispatch/copy SHA 与 host 冻结一致。

随后同一 dispatch 完成：ordinary native 参数冒烟（`override_present=false`）、batch pub shape、batch M3 shape、exit37原样传播。任一失败停止；不得重跑 host 4+6。

## 7. guest 内直接目录复制建立固定模块 cwd

**禁止调用 `Expand-Archive`、`Import-Module Microsoft.PowerShell.Archive`、`Add-Type`/ZipFile 解包或 tar/7z。**模块只能来自既有 R4 mapping 中的新目录桥：
`C:/M3R4/evidence/r6r3-bridge/module/apps/flutter_elitesync_module`。

使用既有 copy/robocopy 合同复制到：
`C:/M3R6R3/w/apps/flutter_elitesync_module`。

复制后验证：
- exists/Container/非空；
- file_count=527；directory_count=301；total_bytes=3234145；reparse_count=0；
- manifest SHA-256 必须精确=`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`。

失败 STOP `FIXED_MODULE_CWD_MISSING_AFTER_DIRECTORY_BRIDGE`，不得搜索替代路径。

## 8. R4 工具/cache 精确复用

只执行 `Test-Path -LiteralPath`：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android SDK `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub cache `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- Gradle wrapper dists `C:/M3R4/h/wrapper/dists`

七项全部存在 => 直接复用。

若某项缺失，只允许检查其既有 R4 guest seed：`C:/M3R4/s/f`,`s/a`,`s/j`,`s/g`,`s/p`,`s/h`,`s/d`。seed存在可按既有copy合同只在guest内恢复该缺失项到新R6R3 task目录；不得新 share 或搜索。内部副本和seed都缺失 => STOP `R4_GUEST_TOOL_REUSE_NOT_AVAILABLE`。

## 9. 真实 Git/Java、offline pub、M3、AAR

前置全部PASS后，真实运行一次 Git `--version` 与 Java `-version`；记录 RunNative 收到参数、`override_present=false`、最终 Arguments、actual executable、stdout/stderr、exit。任一失败即停，不重找工具。

设置 guest 环境只指向 guest 内部副本：Flutter、ANDROID_HOME/ANDROID_SDK_ROOT、JAVA_HOME、PUB_CACHE、GRADLE_USER_HOME；HOME/USERPROFILE/TEMP/TMP 指向 `C:/M3R6R3` 内 task-owned 目录。不得写 host seed。

cwd 固定：`C:/M3R6R3/w/apps/flutter_elitesync_module`。

真实 pub 仅一次：Flutter `pub get --offline`，最多10分钟。不得联网补包、下载或重试；非零按真实诊断分类。

仅 pub exit=0 后运行一次 M3：`build aar --no-debug --no-profile --no-pub`，accepted defines=`EMPTY`，追加0个 dart-define，最多30分钟，不重试。

仅 M3 实际启动后检查一次精确 AAR：
`C:/M3R6R3/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录 size/SHA-256；M3未启动 => AAR=`NOT_CHECKED`, probe=0。M2不得执行。

## 10. evidence、生命周期与候选

任务结束后 host 将 B 完整复制到 E；对本轮 task-owned 内容计算 manifest，B/E 必须一致。B保留，不删除，不修改旧R4/R6R2内容。

不得 stop/close/reset/kill Owner Sandbox。task-owned guest/工具进程按既有Job/PID规则收尾。

候选分支：`review/h01-bib03-u15-td01-m3-existing-bridge-directory-transfer-v0-8-r6-r3`。

一个candidate commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_BRIDGE_DIRECTORY_TRANSFER_AND_EXECUTION_RESULT_V0_8_R6_R3.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT 从 fixed main A 的干净 UTF-8 版本开始；发布前检查无 mojibake。

报告返回：candidate/parent/two blobs、host bridge copy+manifest、bridge probe、guest.started/nonce、policy/Security/isolation、dispatch smoke、guest module copy+manifest、R4 tool/cache reuse/fallback、Git/Java、pub/M3/AAR、B→E manifest与Sandbox最终状态。

执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。

## 11. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36和产品实现边界保持。除本任务专用guest RemoteSigned外，不改持久策略/信任/系统配置；不联网、不下载、不真实数据、不生产访问。