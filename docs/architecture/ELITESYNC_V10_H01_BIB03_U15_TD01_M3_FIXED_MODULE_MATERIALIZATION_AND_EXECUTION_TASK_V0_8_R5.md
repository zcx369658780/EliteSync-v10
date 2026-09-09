# EliteSync v10｜固定模块精确物化与现有 Sandbox 条件式 M3 v0.8-R5

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — EXACT MODULE MATERIALIZATION AUTHORIZED — NO LOCAL EXECUTION BEFORE SECTION 1 APPROVAL`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前 main `c1a8dbc9dacbf78ba078a9d873d8b6835d982801` 已接受 v0.8-R4。已接受事实：八项精确 host locator 8/8 存在、Container 且可读；唯一 Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；R4 guest preflight/禁网隔离、ordinary native、batch pub/M3 shape 与 exit37 均 PASS；八项只读 share 8/8、guest copy 合同 8/8 PASS。工具/cache 七项实际复制成功；第1项 `W/input` 可访问但 source_objects=0，导致固定 cwd `C:/M3R4/w/apps/flutter_elitesync_module` 不存在。真实 Git/Java/pub/M3 未运行，AAR=NOT_CHECKED，M2 deferred。

本任务不搜索替代模块位置。唯一目标是从当前已接受 main 的精确 Git commit 对象中，**只读、非 index、非 checkout 地物化唯一授权路径 `apps/flutter_elitesync_module`** 到新的 task-owned 输入根，再沿用已通过的 existing-Sandbox/dispatch/copy/tool链继续真实 Git/Java、一次 offline pub、条件式一次 M3 和精确 AAR。

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定v0.8-R5任务；允许对本机 `D:/EliteSync-v10` 仅使用不读取默认index/working-tree内容的精确 Git object 命令，确认当前 main commit 对象并用 `git archive <fixed-main> -- apps/flutter_elitesync_module` 只读物化到 task-owned `input-r5`。不得 status/diff/checkout/reset/stash/clean，不得读取或改变受保护 staged/index 状态。允许继续使用当前唯一 Owner Sandbox，但不得 stop/close/reset/kill。仅在任务专用 guest PowerShell 进程使用进程级 RemoteSigned。物化与guest隔离/两类冒烟通过后，允许八项输入准备、Git/Java验证、一次 offline pub及条件式一次M3。不下载、不联网补包、不写原仓库或宿主SDK/cache，其余边界保持。

无批准仅报告 `WAITING OWNER ACTIVATION`。本批准仅限v0.8-R5。

## 2. 固定 GitHub 入口

仓库：`zcx369658780/EliteSync-v10`。开始实时读取 main，必须恰为 A=`c1a8dbc9dacbf78ba078a9d873d8b6835d982801`。

FIRST主动读取A中的：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`，要求blob=`18485c95262051e43892436fb52413132c5ee626`。

随后核验本任务ref/commit/blob、唯一父A、相对A仅新增本任务文件。失配停止依赖动作，不自行换基线。

其他GitHub只读输入仅限A中的：
- `AGENTS.md` blob `f9ef1a74f25b1cdce51768e6889bec7eb61ebaa1`。
- `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 使用A中实际blob作为候选更新基底。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EIGHT_INPUT_LOCATORS_AND_EXECUTION_RESULT_V0_8_R4.md` blob `cf05d81944aac7f14e49f99207a34d45834df171`。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_EXISTING_SANDBOX_SESSION_AND_EVIDENCE_RESULT_V0_8_R3.md` blob `24909ebac92e7c88f3159df4e3a8a3b84d8d7704`，仅existing-session/share/exec/隔离合同。
- `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_ISOLATED_EXECUTION_AND_EVIDENCE_RESULT_V0_7.md` blob `6684322f5e500e5ce0dd3c0e9f81130fd0fbbe26`，仅既有复制/工具验证合同。
- `apps/android/app/build.gradle.kts` blob `a7e0f7583c801e2d56afc595d6c7bed84b5ce516` 与 `apps/android/gradle.properties` blob `f0a2e55f89e383466d2c6b481c8c468a3aa0b13d`，仅direct AAR/defines合同。

README预算耗尽、FD02永久排除；不仓库枚举/搜索、不访问旧仓库、不检查默认index或受保护 staged state。

## 3. 固定模块物化：唯一允许的本机 Git 操作

本机仓库根固定为 `R=D:/EliteSync-v10`。本任务只允许以下精确语义，不得运行 `git status`、`git diff`、`git ls-files`、`git checkout`、`git switch`、`git reset`、`git stash`、`git clean`、`git add`、`git commit`、`git worktree`、目录搜索或任何读取默认index内容的命令。

先用不依赖working tree/index的对象查询确认固定对象存在：
- `git -C R cat-file -e A^{commit}`
- `git -C R cat-file -t A` 应为 `commit`
- `git -C R cat-file -e A:apps/flutter_elitesync_module`
- `git -C R cat-file -t A:apps/flutter_elitesync_module` 应为 `tree`

若A对象或精确模块tree在本机对象库不存在，STOP：`FIXED_MAIN_GIT_OBJECT_NOT_AVAILABLE_LOCALLY`。**不得 fetch/pull/network，不得换commit，不得从working tree复制。**

新的 task-owned 物化根：
`W=D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`
`M=W/input-r5`

要求 `M` 在本轮开始不存在或为空的task-owned新目录；不得删除/覆盖旧 `W/input` 或旧证据。物化只允许：
1. `git -C R archive --format=tar A -- apps/flutter_elitesync_module` 输出到 task-owned 临时tar/管道；
2. 只解包到 `M`；
3. 不读取working tree版本，不跟随reparse到M外。

物化完成后只在 `M/apps/flutter_elitesync_module` 精确路径验证：存在、Container、非reparse；允许对**本轮刚物化的task-owned M**做递归对象计数/总字节/hash manifest，因为这些字节来自固定Git对象且不是受保护宿主状态。不得用该权限扫描R或其他目录。

记录：固定commit A、module tree SHA（由`git rev-parse A:apps/flutter_elitesync_module`或等价object查询取得）、archive命令、tar SHA-256、物化文件数/目录数/总字节、reparse count。预期应为非空；如精确cwd不存在或对象数0，STOP `FIXED_MODULE_MATERIALIZATION_INCOMPLETE`。

## 4. 现有 Sandbox 与 R5 guest preflight

新增证据仅写 `W/evidence/resume-r5/`，旧resume-r1/r2/r3/r4只读。

fresh `wsb list --raw` 必须恰好一个running Sandbox且ID仍为 `68ece109-c661-420c-9899-02b1e9518036`。0个或ID变化 => `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 => `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。本任务不新建Sandbox，不stop/close/reset/kill现有会话。

建立R5 evidence/bootstrap share：
- `W/evidence/resume-r5` → `C:/M3R5/evidence`，allow-write；
- `W/evidence/resume-r5/bootstrap` → `C:/M3R5/bootstrap`，不加allow-write。

新nonce。R5 preflight再次实测：Sandbox ID、guest.started、PowerShell 5.1、Process/effective RemoteSigned、Security模块系统Path、活动网卡0、默认路由0。随后加载同一dispatch SHA-256=`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`，完成ordinary native参数冒烟、batch pub/M3 shape、exit37。任一失败立即停止。

## 5. 八项输入：第1项替换为精确物化根

八项唯一host locator：
1. `W/input-r5`
2. `D:/flutter`
3. `C:/Users/zcxve/AppData/Local/Android/Sdk`
4. `C:/Program Files/Eclipse Adoptium/jdk-17.0.18.8-hotspot`
5. `C:/Program Files/Git`
6. `C:/Users/zcxve/AppData/Local/Pub/Cache`
7. `D:/GradleHome/caches`
8. `D:/GradleHome/wrapper/dists`

第2–8项沿R4已通过locator，不做目录发现；仍可精确Test-Path/Container复核。八项均只读 `wsb share`：
1. `W/input-r5` → `C:/M3R5/s/in`
2. Flutter → `C:/M3R5/s/f`
3. Android → `C:/M3R5/s/a`
4. JDK → `C:/M3R5/s/j`
5. Git → `C:/M3R5/s/g`
6. Pub → `C:/M3R5/s/p`
7. Gradle caches → `C:/M3R5/s/h`
8. wrapper dists → `C:/M3R5/s/d`

全部不加`--allow-write`。随后按既有copy/robocopy合同复制到guest可写：module/input→`C:/M3R5/w`；Flutter→`C:/M3R5/t/f`；Android→`C:/M3R5/t/a`；JDK→`C:/M3R5/t/j`；Git→`C:/M3R5/t/g`；Pub→`C:/M3R5/p`；Gradle→`C:/M3R5/h/...`。

八项copy后固定cwd必须存在：`C:/M3R5/w/apps/flutter_elitesync_module`。若不存在，STOP `FIXED_MODULE_CWD_MISSING_AFTER_EXACT_MATERIALIZATION`，不得搜索替代。

## 6. 真实Git/Java、pub、M3与AAR

cwd建立后先真实运行一次：
- `C:/M3R5/t/g/cmd/git.exe --version`
- `C:/M3R5/t/j/bin/java.exe -version`
记录RunNative收到参数、override_present=false、最终Arguments、actual executable、stdout/stderr、exit。任一失败即停止pub，不寻找替代工具。

成功后，所有环境变量指向R5 guest内部副本，不写host seed。cwd=`C:/M3R5/w/apps/flutter_elitesync_module`。

真实命令至多各一次：
1. `C:/M3R5/t/f/bin/flutter.bat pub get --offline`，10分钟；
2. 仅pub成功后：`C:/M3R5/t/f/bin/flutter.bat build aar --no-debug --no-profile --no-pub`，defines当前为EMPTY则追加0个参数，30分钟。

不联网、下载、安装、改Wrapper/SDK/产品源码或重试。非零按真实诊断分类，不自动归因缺包。

仅M3实际启动后一次检查：
`C:/M3R5/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`
HIT记录size/SHA-256；未启动保持NOT_CHECKED；不搜替代。M2不执行。

## 7. 生命周期与候选

不得停止Owner Sandbox。task-owned guest/工具进程按既有Job/PID规则收尾；CLI无unshare则share保留并报告。

候选分支：`review/h01-bib03-u15-td01-m3-fixed-module-materialization-v0-8-r5`。
一个commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FIXED_MODULE_MATERIALIZATION_AND_EXECUTION_RESULT_V0_8_R5.md`；
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md` 页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT从A中正常UTF-8版本开始，发布前检查无mojibake。报告必须返回：固定commit/module tree SHA、archive/tar/物化统计、R5 Sandbox ID/preflight/隔离、两类guest冒烟、八项share/copy、固定cwd、Git/Java、pub/M3/AAR、Owner Sandbox最终状态及证据限制。

执行者不自我接受、不更新main、不M2、不修改AGENTS或ChatGPT项目源。