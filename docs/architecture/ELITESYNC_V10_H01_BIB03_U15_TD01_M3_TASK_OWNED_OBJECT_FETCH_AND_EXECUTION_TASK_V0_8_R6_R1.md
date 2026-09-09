# EliteSync v10｜远端权威门修正、任务自有 Git Object 拉取与条件式 M3 v0.8-R6-R1

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — REMOTE GITHUB AUTHORITY GATE ONLY — ONE FRESH TASK-OWNED FETCH AFTER GATE`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 背景、已接受事实与本轮唯一目标

当前权威 main 为 `ac14a7ccac09fa6117936f133b50593bd5023c1d`。该提交是对错误接受树 `c1a8dbc9dacbf78ba078a9d873d8b6835d982801` 的精确 tree-repair：恢复已接受 R4 候选 `a57df45da3dd0f98c6fc400851afb4de3ad7c51b` 的 tree `2f9bbf436d9364f70a5ddbcfe4cb7c55130fa309`，不改写 R4 内容。R4 已接受事实：八项精确 host locator 8/8 PASS；唯一 Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；guest preflight/禁网隔离、ordinary native、batch pub/M3 shape 与 exit37 PASS；八项只读 share 与 copy 合同 PASS；工具/cache 七项已复制到 R4 guest 目录；固定 `W/input` 为空，导致 module cwd 缺失；Git/Java/pub/M3 未运行，AAR=NOT_CHECKED，M2 deferred。

旧 R5 无候选。旧 R6 task `33372484a0e4745bad9ef5503945790b6ba3824c` 绑定错误 main `c1a8...`，执行者在本地 task ref/object 验证缺失后停止，无候选。该旧 R6 只完成一次 task-owned fetch：`W/object-r6.git` 中 `refs/r6/fixed-main`=`c1a8...`；证据 `W/evidence/resume-r6/r6-authority-gate.txt` SHA-256=`5F3C63947DFCA25C950C3F67B64B6AD5C64A82BDA7A60AAA9FE136948B524876`。旧 object store / evidence 必须保留，只读，不再作为当前权威模块来源。

本轮唯一目标：**先完全通过 GitHub 远端数据核验本任务权威，不要求本机存在本任务 commit/ref/object；随后在全新的 task-owned bare repo 中进行一次新的有界 fetch，取得修复后的当前 main `ac14...`；只读 archive 唯一授权路径 `apps/flutter_elitesync_module` 到新 input；再沿用现有 Sandbox 与已验证 guest/tool 链，尝试真实 Git/Java、一次 offline pub、条件式一次 M3 与精确 AAR。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R1 任务；任务 authority 只以 GitHub 远端 main/task commit/blob/parent/compare 为准，本地没有 task ref/object 不构成阻塞。远端 authority 全部匹配后，允许在新 task-owned `object-r6-r1.git` 中仅向 `https://github.com/zcx369658780/EliteSync-v10.git` 做一次浅层 fetch，源仅 `refs/heads/main`，目标仅 task-owned `refs/r6r1/fixed-main`；必须验证 SHA 精确等于 `ac14a7ccac09fa6117936f133b50593bd5023c1d`。不授权第二次 fetch、pull、clone、包下载或依赖联网。允许从该 object store archive 唯一模块路径到 task-owned `input-r6-r1`。允许继续使用当前唯一 Owner Sandbox，但不得 stop/close/reset/kill；仅在任务专用 guest PowerShell 进程使用进程级 RemoteSigned。模块物化、guest 隔离和派发门通过后，允许真实 Git/Java、一次 offline pub 及条件式一次 M3。不写原仓库、默认 index、working tree、宿主 SDK/cache 或产品源码，其余边界保持。

无批准只报告 `WAITING OWNER ACTIVATION`。上述网络与 RemoteSigned 权限只限本任务。

## 2. 固定 GitHub 远端权威门 —— 不得改用本地 task ref/object

仓库：`zcx369658780/EliteSync-v10`。

开始时通过 GitHub 远端读取并核验：
1. `refs/heads/main` 必须精确为 A=`ac14a7ccac09fa6117936f133b50593bd5023c1d`。
2. FIRST：A 中 `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob 必须为 `18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 给出的固定值；必须从 GitHub 远端读取 task commit metadata、task file blob 和 compare，不从本机 repo/object store验证。
4. task commit 唯一父必须为 A；相对 A 必须 ahead=1/behind=0 且只新增本任务文件。
5. A 中 R4 result 路径必须存在且 blob=`cf05d81944aac7f14e49f99207a34d45834df171`。
6. A 中 CURRENT_CONTEXT 必须为 UTF-8 R4 状态，blob=`54169e894e8acec881344a9b2cf86c06c5523956`。

**明确规则：本机 `D:/EliteSync-v10`、其 local refs、origin-tracking refs、object database、旧 `W/object-r6.git` 都不是本任务 authority gate。缺少本任务 local ref/object 是预期可接受状态，不得据此 STOP。**

只有 GitHub 远端权威门失配才 STOP：`REMOTE_TASK_AUTHORITY_MISMATCH`。远端权威门完成前不得执行任何新的 Git fetch、Sandbox、物化或工具动作。

其他 GitHub 只读输入仅限 A 中：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- R4 task blob `e72500c1130d871d9b1d98e4ebeee0233c33064d`，仅沿用 locator/share/copy/生命周期合同。
- R4 result blob `cf05d81944aac7f14e49f99207a34d45834df171`。
- R3 result blob `24909ebac92e7c88f3159df4e3a8a3b84d8d7704`，仅沿用 WSB CLI/session 合同。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅 direct AAR/defines 合同。

README预算耗尽、FD02永久排除；不读取旧仓库、不仓库枚举/搜索、不访问默认 index 或受保护 staged state。

## 3. 旧 R6 只读绑定与新 task-owned 路径

固定工作区 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

只读验证旧 R6 evidence：
`W/evidence/resume-r6/r6-authority-gate.txt`，要求 SHA-256=`5F3C63947DFCA25C950C3F67B64B6AD5C64A82BDA7A60AAA9FE136948B524876`；只记录旧 R6 fetch 成功取得 `c1a8...` 且第二次 fetch=0，不把旧对象当当前 authority。

旧路径只读保留：
- `W/object-r6.git`
- `W/evidence/resume-r6/`
- `W/input-r6`（如不存在也不创建/复用）

本轮新路径：
- evidence `E=W/evidence/resume-r6-r1`
- bare object store `O=W/object-r6-r1.git`
- module input `I=W/input-r6-r1`

开始时 O、I、E 必须不存在。任一已存在不得删除、清空或覆盖，STOP `R6R1_TASK_OWNED_PATH_ALREADY_EXISTS`。

## 4. 唯一新的 Git 网络 fetch

远端权威门通过后：
1. `git init --bare O`。
2. 仅一次网络 fetch：
   `git --git-dir=O -c gc.auto=0 fetch --depth=1 --no-tags --no-write-fetch-head --no-auto-maintenance https://github.com/zcx369658780/EliteSync-v10.git refs/heads/main:refs/r6r1/fixed-main`
3. 不执行第二次 fetch、`ls-remote`、pull、clone、submodule update 或其他 remote/URL。

fetch 失败即 STOP `R6R1_FIXED_MAIN_FETCH_FAILED`；不得重试。

成功后只在 O 精确验证：
- `rev-parse refs/r6r1/fixed-main^{commit}` 必须精确为 A。
- `cat-file -t refs/r6r1/fixed-main` 必须 `commit`。
- `rev-parse refs/r6r1/fixed-main:apps/flutter_elitesync_module`，记录 module tree SHA。
- `cat-file -t refs/r6r1/fixed-main:apps/flutter_elitesync_module` 必须 `tree`。

任何失配 STOP `R6R1_FETCHED_AUTHORITY_OBJECT_MISMATCH`。不得换 ref/path，也不得访问 `D:/EliteSync-v10/.git`、working tree、默认 index 或 staged state。

## 5. 精确 archive / 物化

从 O 生成 `Z=E/module-fixed-main.zip`：
`git --git-dir=O archive --format=zip --output=Z refs/r6r1/fixed-main -- apps/flutter_elitesync_module`

记录 exit、zip size、SHA-256。仅用 `Expand-Archive -LiteralPath Z -DestinationPath I` 解包。

只允许枚举统计新 task-owned `I/apps/flutter_elitesync_module`：exists、Container、file_count>0、directory_count、total_bytes>0、reparse_count=0，并按相对路径+SHA-256生成 manifest hash。不得扫描原仓库或其他宿主目录。

失败 STOP `FIXED_MODULE_MATERIALIZATION_INCOMPLETE`。

## 6. 现有 Sandbox 与 guest 链

物化通过后一次 `wsb list --raw`：必须恰好一个 running Sandbox，ID仍为 `68ece109-c661-420c-9899-02b1e9518036`。0个或ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。本任务不得新建、stop、close、reset、kill Sandbox。

新 task share：
- `E` → `C:/M3R6R1/evidence`，allow-write。
- `E/bootstrap` → `C:/M3R6R1/bootstrap`，不加 allow-write。
- `I` → `C:/M3R6R1/s/in`，不加 allow-write。

生成新 nonce；run-as System 执行 task-owned Windows PowerShell，Process/effective=`RemoteSigned`，Security module系统Path通过，活动网络适配器=0、默认路由=0，guest.started绑定 nonce + Sandbox ID。加载既有 dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`，完成 ordinary native 参数冒烟、batch pub shape、M3 shape、exit37。不得重跑 host 4+6。

优先只用 `Test-Path -LiteralPath` 复用 R4 guest 内部已复制路径：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub cache `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- wrapper dists `C:/M3R4/h/wrapper/dists`

七项全部存在则直接复用。某一项缺失，只允许按 R4 已接受精确 host locator 对该缺失项单独只读 share/copy；不得搜索替代路径或重新复制已存在项。

模块从 `C:/M3R6R1/s/in` 按既有 copy 合同复制到 `C:/M3R6R1/w`。完成后必须存在且非空：
`C:/M3R6R1/w/apps/flutter_elitesync_module`
否则 STOP `FIXED_MODULE_CWD_MISSING_AFTER_REPAIRED_MAIN_FETCH`。

## 7. 真实 Git / Java / offline pub / M3 / AAR

前置全部PASS后真实运行一次 Git 和 Java，使用 R4复用路径或本轮记录的精确fallback路径：
- Git `--version`
- Java `-version`

每次记录 RunNative 收到参数、`override_present=false`、最终 Arguments、actual executable、stdout/stderr、exit。任一失败停止，不重找工具。

设置 guest 环境只指向 guest 内部副本；不得写回 host seed。cwd固定：
`C:/M3R6R1/w/apps/flutter_elitesync_module`。

一次真实 pub：Flutter `pub get --offline`，最多10分钟。非零按真实诊断分类；不自动写缺包，不联网补包、不重试。

仅 pub exit=0 后，一次 M3：`build aar --no-debug --no-profile --no-pub`；已接受 defines=`EMPTY`，追加0个 define 参数；最多30分钟，不重试。

仅 M3 实际启动后一次精确 AAR 检查：
`C:/M3R6R1/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录size/SHA-256；M3未启动保持NOT_CHECKED/probe=0。不搜替代。M2不执行。

## 8. 生命周期、候选与停止

Owner Sandbox 不得 stop/close/reset/kill；task-owned guest/工具进程按既有Job/PID规则收尾。CLI无unshare则share保留并报告。

候选分支：`review/h01-bib03-u15-td01-m3-task-owned-object-fetch-v0-8-r6-r1`。

一个candidate commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_TASK_OWNED_OBJECT_FETCH_AND_EXECUTION_RESULT_V0_8_R6_R1.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT必须从本任务固定main A的UTF-8版本开始；发布前检查无mojibake。

报告至少返回：GitHub远端authority核验、旧R6 evidence绑定、新唯一fetch、fetched main SHA、module tree SHA、archive/hash/物化统计、fresh Sandbox ID、guest preflight/隔离/冒烟、R4工具复用/fallback、module cwd、Git/Java、pub、M3、AAR、进程与Sandbox最终状态。

执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。完成后停止。

## 9. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36、legal/Safety/no-processing及产品实现边界保持。除本任务明确的GitHub远端authority读取、一次task-owned Git fetch和guest RemoteSigned外，不扩大网络、写入、策略或实现权限。