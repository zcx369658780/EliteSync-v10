# EliteSync v10｜任务自有 Git Object 精确拉取、模块物化与条件式 M3 v0.8-R6

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — ONE BOUNDED NETWORK FETCH TO TASK-OWNED BARE REPO — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、R5停止事实、激活与唯一目标

当前 main `c1a8dbc9dacbf78ba078a9d873d8b6835d982801` 已接受 v0.8-R4。已接受事实：八项精确 host locator 8/8 PASS；Owner现有Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；guest preflight/禁网隔离、ordinary native、batch pub/M3 shape 与 exit37 PASS；八项只读share与copy合同PASS。七项工具/cache已实际复制到该仍运行Sandbox的guest内部R4目录；第1项旧`W/input`为空，故固定module cwd缺失。真实Git/Java/pub/M3未运行，AAR=NOT_CHECKED，M2 deferred。

随后Owner批准的R5按固定停止规则执行，但没有GitHub候选：本机`D:/EliteSync-v10`的Git object database不含固定main `c1a8dbc9...`，首个`git cat-file -e <main>^{commit}`失败并分类`FIXED_MAIN_GIT_OBJECT_NOT_AVAILABLE_LOCALLY`。R5未fetch/pull、未读默认index/working tree、未触碰Sandbox。其唯一证据文件为`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008/evidence/resume-r5/fixed-main-object-gate.txt`，Owner报告SHA-256=`28CBC7E302B32BD715D88AC66C6D9B1814F28B2E0BFDB3F7C58AA3A6BDE4AB67`。本任务可只读验证该精确文件/hash，但不把R5伪造成已发布候选。

本任务不再向原仓库`.git`补对象。唯一目标是：**在task-owned目录创建全新的bare Git repository，进行一次有界HTTPS fetch，只取远端`refs/heads/main`的浅层对象到task-owned ref；验证SHA精确等于固定main；从该task-owned object store只读archive唯一授权路径`apps/flutter_elitesync_module`到`input-r6`；随后复用现有Owner Sandbox与R4 guest内部工具/cache副本，尝试真正运行Git/Java、一次offline pub、条件式一次M3与精确AAR。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R6任务；允许在task-owned `W/object-r6.git`创建bare Git repository，并仅向`https://github.com/zcx369658780/EliteSync-v10.git`进行一次`git fetch --depth=1 --no-tags --no-write-fetch-head --no-auto-maintenance`，源仅为`refs/heads/main`、目标仅为task-owned `refs/r6/fixed-main`。该网络权限只用于补齐固定main的Git对象，不授权浏览网页、包下载、依赖联网或访问其他remote。不得写`D:/EliteSync-v10/.git`、默认index或working tree。验证fetch到的SHA精确为固定main后，只允许archive `apps/flutter_elitesync_module`到task-owned `input-r6`。允许继续使用当前唯一Owner Sandbox，不得stop/close/reset/kill；仅在task-owned guest PowerShell进程使用进程级RemoteSigned。模块物化与隔离/派发门通过后，允许真实Git/Java、一次offline pub及条件式一次M3。不联网补包、不写宿主SDK/cache或产品源码，其余边界保持。

无批准仅报告`WAITING OWNER ACTIVATION`。该网络与RemoteSigned权限只限v0.8-R6，不自动续期。

## 2. 固定 GitHub 入口

仓库：`zcx369658780/EliteSync-v10`。开始实时读取GitHub main，必须恰为A=`c1a8dbc9dacbf78ba078a9d873d8b6835d982801`。

FIRST主动读取A中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob=`18485c95262051e43892436fb52413132c5ee626`。

随后核验本任务ref/commit/blob、唯一父A、相对A仅新增本任务文件。失配停止依赖动作，不自行换基线。

其他GitHub只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 使用A中实际blob作为候选更新基底。
- R4结果 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EIGHT_INPUT_LOCATORS_AND_EXECUTION_RESULT_V0_8_R4.md` blob=`cf05d81944aac7f14e49f99207a34d45834df171`。
- R4任务 blob=`e72500c1130d871d9b1d98e4ebeee0233c33064d`，仅沿用existing-Sandbox、guest、locator、copy、工具与生命周期合同。
- R3结果 blob=`24909ebac92e7c88f3159df4e3a8a3b84d8d7704`，仅沿用官方WSB CLI/session控制合同。
- `apps/android/app/build.gradle.kts` blob=`a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob=`f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。

README预算耗尽、FD02永久排除；不读取旧仓库，不仓库枚举/搜索，不访问默认index或受保护staged state。

## 3. task-owned object store 与唯一网络调用

固定工作区W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。新增证据仅写`W/evidence/resume-r6/`。新对象仓固定：`O=W/object-r6.git`；新模块输入固定：`I=W/input-r6`。

开始要求`O`和`I`均不存在；若已存在，不删除、不清空、不复用，STOP并分类`R6_TASK_OWNED_PATH_ALREADY_EXISTS`。旧`W/input`、`input-r5`（如存在）及resume-r1..r5均不得覆盖或清理。

允许精确执行：
1. `git init --bare O`。bare repo只有Git管理对象，没有working tree；此动作仅写task-owned O。
2. **唯一一次网络fetch**：
   `git --git-dir=O -c gc.auto=0 fetch --depth=1 --no-tags --no-write-fetch-head --no-auto-maintenance https://github.com/zcx369658780/EliteSync-v10.git refs/heads/main:refs/r6/fixed-main`
3. 不执行`ls-remote`、第二次fetch、pull、clone或访问其他URL/remote。

网络fetch失败即STOP，分类`R6_FIXED_MAIN_FETCH_FAILED`，记录native exit/stdout/stderr；不重试，不改remote。

fetch成功后只在O中执行精确Git object命令：
- `git --git-dir=O rev-parse refs/r6/fixed-main^{commit}`，必须精确等于A。
- `git --git-dir=O cat-file -t refs/r6/fixed-main`，必须为commit。
- `git --git-dir=O rev-parse refs/r6/fixed-main:apps/flutter_elitesync_module`，记录module tree SHA。
- `git --git-dir=O cat-file -t refs/r6/fixed-main:apps/flutter_elitesync_module`，必须为tree。

任何SHA/类型失配=>STOP `R6_FETCHED_AUTHORITY_OBJECT_MISMATCH`。不得换ref、猜路径或读取原仓库working tree。

## 4. 精确模块 archive 与物化

只从O生成：
`Z=W/evidence/resume-r6/module-fixed-main.zip`

精确命令：
`git --git-dir=O archive --format=zip --output=Z refs/r6/fixed-main -- apps/flutter_elitesync_module`

记录archive exit、Z size与SHA-256。使用Windows PowerShell内置`Expand-Archive -LiteralPath Z -DestinationPath I`解包；不得解包到原仓库或旧input。

物化后唯一允许枚举/统计的是新task-owned `I/apps/flutter_elitesync_module`。必须验证：exists、Container、reparse_count=0、file_count>0、total_bytes>0；记录file_count/directory_count/total_bytes及一个按相对路径+SHA-256生成的task-owned manifest hash。该统计权限不扩展到O以外Git历史、原仓库或其他宿主目录。

若模块路径缺失/0对象/reparse非0，STOP `FIXED_MODULE_MATERIALIZATION_INCOMPLETE`。不得搜索替代位置。

## 5. 现有Sandbox重新绑定与R4工具副本复用

模块物化成功后执行一次`wsb list --raw`。要求恰好一个running Sandbox且ID仍为`68ece109-c661-420c-9899-02b1e9518036`。0个或ID变化=>STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义=>STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。本任务不新建Sandbox，不stop/close/reset/kill Owner会话。

新share：
- `W/evidence/resume-r6` -> `C:/M3R6/evidence`，允许write。
- `W/evidence/resume-r6/bootstrap` -> `C:/M3R6/bootstrap`，不加allow-write。
- `I` -> `C:/M3R6/s/in`，不加allow-write。

新nonce。R6 guest preflight通过同一Sandbox ID以run-as System执行任务专用Windows PowerShell，Process/effective必须RemoteSigned，Security模块系统Path通过，活动网络适配器0、默认路由0；guest.started须绑定nonce和Sandbox ID。加载既有dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`，完成ordinary native参数冒烟、batch pub shape、M3 shape及exit37。不得重跑host 4+6。

优先复用同一Sandbox中R4已复制的guest内部工具/cache，仅对以下精确路径做`Test-Path -LiteralPath`，不得枚举搜索：
- Flutter `C:/M3R4/t/f/bin/flutter.bat`
- Android SDK root `C:/M3R4/t/a`
- Java `C:/M3R4/t/j/bin/java.exe`
- Git `C:/M3R4/t/g/cmd/git.exe`
- Pub cache root `C:/M3R4/p`
- Gradle caches `C:/M3R4/h/caches`
- Gradle wrapper dists `C:/M3R4/h/wrapper/dists`

七项全部存在=>直接复用，不重新复制几十GB工具/cache。若任一精确R4 guest路径缺失，只允许针对缺失项使用R4已接受的精确host locator重新建立只读share并复制该项；不得寻找替代路径。所有fallback逐项记录。R4已有路径不得因复用而改写host源。

第1项新模块使用`C:/M3R6/s/in`，按既有copy/robocopy合同复制到`C:/M3R6/w`。复制后必须存在`C:/M3R6/w/apps/flutter_elitesync_module`且非空；否则STOP `FIXED_MODULE_CWD_MISSING_AFTER_TASK_OWNED_FETCH`。

## 6. 真实工具、offline pub、M3与AAR

前置全部PASS后，真实运行一次：
- `C:/M3R4/t/g/cmd/git.exe --version`（如Git项fallback到R6内部副本，则使用任务记录的固定fallback目标）。
- `C:/M3R4/t/j/bin/java.exe -version`（同上）。

记录RunNative收到参数、`override_present=false`、最终Arguments、actual executable、stdout/stderr、exit。任一失败立即停止，不重找工具。

设置guest环境只指向guest内部副本：Flutter/Android/JAVA/Pub/Gradle/HOME/USERPROFILE/TEMP/TMP均不得写回host seed。cwd固定`C:/M3R6/w/apps/flutter_elitesync_module`。

一次真实pub：`C:/M3R4/t/f/bin/flutter.bat pub get --offline`（如Flutter fallback到R6副本则使用固定fallback路径），最多10分钟。只有真实诊断支持时才分类OFFLINE_PUB_INSUFFICIENT；非零不得自动归为缺包。不联网补包、不下载、不改SDK/Wrapper/产品源码、不重试。

仅pub exit=0后，一次M3：同Flutter执行`build aar --no-debug --no-profile --no-pub`，defines当前接受为EMPTY则追加0个dart-define参数，最多30分钟。不重试。

仅M3实际启动后一次检查：
`C:/M3R6/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录size/SHA-256；未启动保持NOT_CHECKED/probe=0；不搜替代。M2不执行。

## 7. 生命周期、网络边界与候选

网络仅§3唯一Git fetch；之后所有Flutter/pub/M3必须保持离线。不得浏览网页、curl/wget、包管理下载、GitHub API手工下载或访问其他remote。task-owned bare repo O、zip、input-r6和resume-r6可保留为证据，不写原仓库。

Owner现有Sandbox不得stop/close/reset/kill。task-owned guest进程按既有Job/PID归属正常收尾。WSB CLI无unshare则share保留并报告。

候选分支：`review/h01-bib03-u15-td01-m3-task-owned-object-fetch-v0-8-r6`。

一个candidate commit，唯一父为本任务commit，恰好两路径：
1. 新增`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_TASK_OWNED_OBJECT_FETCH_AND_EXECUTION_RESULT_V0_8_R6.md`。
2. 更新`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从固定main A中的正常UTF-8版本开始，发布前检查无mojibake。报告必须区分：R5无候选的本地object gate停止；R6唯一network fetch；task-owned object/物化证据；fresh Sandbox/preflight/dispatch；工具复用/fallback；真实Git/Java/pub/M3/AAR。

发布后核验candidate、sole parent、ahead/behind、两路径、两个blob。执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。

## 8. 不变边界

README预算耗尽、FD02永久排除、旧仓库/全仓枚举、受保护index/staged state、legal/Safety/no-processing、D-02/U-14/U-12/TP、Backend/Database/PUI、LC-03/LC-04/Phase36及产品实现边界保持。除本任务具名唯一Git fetch与guest RemoteSigned外，不扩大网络、写入、生产或系统配置权限。