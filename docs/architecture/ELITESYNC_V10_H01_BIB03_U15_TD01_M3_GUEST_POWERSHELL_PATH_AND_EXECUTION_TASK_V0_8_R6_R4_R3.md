# EliteSync v10｜Guest PowerShell PATH 修复、Offline Pub 续行与条件式 M3 v0.8-R6-R4-R3

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — PROCESS-LOCAL PATH FIX ONLY — ONE OFFLINE PUB ATTEMPT — CONDITIONAL ONE M3`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `93a5466b57a99dcc10a369cd005bbe7953ce38a4`。该 main 已接受 R6-R4-R2 候选精确 tree `4468f2948aac29d8971345f9d69a29b9a652b7e1`。

R6-R4-R2 已接受：
- current-view helper SHA-256=`6ECA7C8ADF8AF51CD2CAE08E736595F4BA4C9324F891AF80DE604A1A3DC6311D`，fixture selftest PASS，helper纠正0/2；
- SRC/B3 及 guest current-view 均为527 files / 301 dirs / 3234145 bytes / reparse=0，TSV size=69676，SHA-256=`4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`；
- 唯一 observable probe `00/10/20/30/40/90` 全部 PASS；
- Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；guest PowerShell 5.1、Process/effective RemoteSigned、Security系统Path、活动网卡0、默认路由0均 PASS；ordinary/batch/exit37 PASS；
- 固定 guest module cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module` 已建立并通过 current-view；
- R4七项工具/cache全部直接复用，fallback=0；Git `2.53.0.windows.1` exit0；Java Temurin `17.0.18+8` exit0；
- 唯一真实 `flutter pub get --offline` 已启动，但 Flutter 入口返回 exit=1：`PowerShell executable not found. Either pwsh.exe or PowerShell.exe must be in your PATH.`；这不是 offline 依赖不足证据；
- pub exit 已可靠落盘后，旧 guest 脚本另有次要语法错误 `throw'OFFLINE_PUB_EXIT_NONZERO'` 被解释为命令；该错误不改变首要 pub 失败，但本轮必须消除；
- M3 NOT_RUN，AAR=NOT_CHECKED/probe=0，M2 deferred/NOT_RUN。

本任务**不重跑** helper fixture、SRC/B3 host current-view、observable probe、module copy/current-view、ordinary/batch smoke、Git或Java。它们作为已接受证据只读绑定。

本任务唯一目标：**在同一现有 Owner Sandbox 中，以新的 task-owned guest 控制进程验证系统 `powershell.exe` 的精确路径，并只对该进程及其子进程临时补齐 PATH；随后对已接受 module cwd 执行一次新的 `flutter pub get --offline`。pub成功才执行一次 M3；M3实际启动后才做一次精确AAR检查。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R4-R3 任务；允许仅在 `W/evidence/resume-r4` 下新增 `r6r4r3-continuation` 并新建 canonical evidence `W/evidence/resume-r6-r4-r3`。仅在本任务专用 guest PowerShell 进程使用进程级 RemoteSigned；允许只对该进程及其子进程临时调整 PATH，优先加入 Windows 系统 PowerShell 目录与本任务已接受工具目录，不修改 Machine/User/注册表/组策略或持久环境变量。允许一次新的 `flutter pub get --offline`；仅其 exit=0 后允许一次 `flutter build aar --no-debug --no-profile --no-pub`。不得联网补包、不得新 `wsb share`、不得新建/stop/close/reset/kill Sandbox、不得重跑已接受 helper/observable/module-copy/dispatch-smoke/Git/Java、不得执行M2或产品实现。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 R6-R4-R3。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始仅通过 GitHub 远端核验：
1. main=A=`93a5466b57a99dcc10a369cd005bbe7953ce38a4`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值；只从 GitHub 远端验证，本机缺 task ref/object 不构成 blocker。
4. task commit 唯一父必须=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A 中 R6-R4-R2 result blob 必须=`03720d5499fca33f837abedd79871c740a0906bf`。
6. A 中 CURRENT_CONTEXT blob 必须=`10595ef7ae958da0324b60b4650933067ac2e065`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不仓库枚举/搜索、不访问旧仓库/default index/受保护 staged state。

## 3. 固定本地/guest输入与新 evidence bridge

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

旧 R6-R4-R2 host evidence/bridge只读；不得覆盖或复用旧 task 文件。

新 host bridge：`B=W/evidence/resume-r4/r6r4r3-continuation`。
新 canonical evidence：`E=W/evidence/resume-r6-r4-r3`。

B/E 开始必须均不存在。任一存在 => STOP `R6R4R3_TASK_OWNED_PATH_ALREADY_EXISTS`；不得删除、清空或复用。

创建 B 后仅允许写 B 内的本轮 controller/preflight/evidence。B 位于已接受 R4 writable evidence mapping 源下，对应 guest 根：`C:/M3R4/evidence/r6r4r3-continuation`。禁止调用新的 `wsb share`。

只读绑定 guest 精确路径：
- module cwd `C:/M3R6R4R2/w/apps/flutter_elitesync_module`；
- Flutter `C:/M3R4/t/f/bin/flutter.bat`；
- Android SDK `C:/M3R4/t/a`；
- JDK `C:/M3R4/t/j`；
- Git `C:/M3R4/t/g/cmd/git.exe`；
- Pub cache `C:/M3R4/p`；
- Gradle home `C:/M3R4/h`，其中 caches=`C:/M3R4/h/caches`、wrapper dists=`C:/M3R4/h/wrapper/dists`。

本轮只允许对这些精确路径 `Test-Path -LiteralPath`；module cwd仅额外精确检查 `pubspec.yaml` 存在。不得重新枚举/哈希模块，不重新复制模块，不搜索替代路径。

## 4. 脚本语法门与失败路径要求

新的 `guest-r6r4r3.ps1` 在执行前必须通过 Windows PowerShell 5.1 parser gate。

硬规则：
- 所有 `throw` 若存在，必须写成 `throw 'TEXT'` 或 `throw "TEXT"`，禁止 `throw'` / `throw"`；
- 对预期工具非零退出，优先持久化 classification/exit/stdout/stderr 后使用明确 `exit` 或正常 return，不允许后续脚本语法错误遮蔽首个失败；
- 布尔代码仅 `$true/$false`；
- 仅检查本轮 task-owned 脚本，不搜索仓库或旧证据。

若 parser/static gate 不通过，只允许最多1次定点修正；仍失败 STOP `R6R4R3_GUEST_CONTROLLER_PREFLIGHT_FAILED`。修正后冻结脚本 SHA。

## 5. 现有 Sandbox、最小 fresh guest preflight 与 PATH 修复

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止 `wsb share`、`wsb stop`、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个或ID变化 => STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 => STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

同一ID、run-as System 执行本任务 guest controller：Windows PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

fresh preflight 只验证本轮必须重新成立的条件：
- controller started + 新 nonce=`M3-ISO-V02-008-R6R4R3-<random>` + Sandbox ID；
- Process/effective=`RemoteSigned`；Security module精确系统Path；
- 活动网络适配器=0；默认路由=0；
- 上述 module cwd/`pubspec.yaml`/Flutter/R4七项精确路径仍存在。

不重跑 ordinary/batch smoke、helper、observable、module current-view、Git/Java。

系统 PowerShell 固定候选路径：
`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`。

必须：
1. `Test-Path -LiteralPath` 为 true；否则 STOP `GUEST_SYSTEM_POWERSHELL_EXACT_PATH_MISSING`。
2. 记录 `FileVersionInfo.FileVersion`、Length、SHA-256；若当前 controller process path 可取得，记录 `(Get-Process -Id $PID).Path`。
3. 保存原始 `$env:PATH` 到 evidence，不持久化。
4. 仅对当前 controller 进程设置临时 PATH：把下列目录按此前顺序前置，再追加原始 PATH：
   - `C:/Windows/System32/WindowsPowerShell/v1.0`
   - `C:/Windows/System32`
   - `C:/M3R4/t/f/bin`
   - `C:/M3R4/t/g/cmd`
   - `C:/M3R4/t/j/bin`
5. 同一进程执行 `Get-Command powershell.exe -ErrorAction Stop`；其 Source 必须精确解析到上述系统 PowerShell 路径（路径大小写/分隔符规范化后比较）。
6. 同一进程执行 `C:/Windows/System32/where.exe powershell.exe`；exit必须0，输出必须包含上述系统路径。
7. 再用 `C:/Windows/System32/cmd.exe /d /s /c "where powershell.exe"` 验证 batch/cmd 子进程也继承相同 PATH；exit必须0。
8. 最后通过 PATH 解析名 `powershell.exe` 启动一次 `-NoProfile -NonInteractive -Command "exit 0"`，要求 exit=0。

任一失败 STOP `GUEST_POWERSHELL_PATH_RESOLUTION_NOT_ESTABLISHED`。不得复制/重命名 powershell.exe，不修改系统 PATH、Machine/User 环境、注册表、profile或策略。

## 6. task-only 环境与唯一新的 offline pub

PATH门 PASS 后创建 guest task-owned：
- `C:/M3R6R4R3/home`
- `C:/M3R6R4R3/tmp`

仅在当前 controller 及其子进程设置：
- `JAVA_HOME=C:/M3R4/t/j`
- `ANDROID_HOME=C:/M3R4/t/a`
- `ANDROID_SDK_ROOT=C:/M3R4/t/a`
- `PUB_CACHE=C:/M3R4/p`
- `GRADLE_USER_HOME=C:/M3R4/h`
- `HOME=C:/M3R6R4R3/home`
- `USERPROFILE=C:/M3R6R4R3/home`
- `TEMP=C:/M3R6R4R3/tmp`
- `TMP=C:/M3R6R4R3/tmp`
- PATH保持§5临时值。

真实 pub 仅允许 **一次新的尝试**：
- executable=`C:/M3R4/t/f/bin/flutter.bat`
- cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- args=`pub get --offline`
- 最长10分钟。

必须记录 process_started、收到的参数、最终 batch Arguments/command、stdout、stderr、exit、开始/结束时间。

禁止联网补包、禁止重试 pub、禁止改 Pub cache/Flutter SDK/产品源码来迎合失败。

若 pub 非零：先可靠落盘所有真实诊断，然后结束 controller；按实际首个诊断给最窄分类。不得自动推断 cache 不足。M3=`NOT_RUN`、AAR=`NOT_CHECKED`, probe=0。

## 7. pub成功后的唯一 M3 与精确 AAR

只有 pub exit=0 才允许一次 M3：
- executable=`C:/M3R4/t/f/bin/flutter.bat`
- cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- args=`build aar --no-debug --no-profile --no-pub`
- accepted defines=`EMPTY`，追加0个 `--dart-define`；
- 最长30分钟；不得重试。

记录完整 stdout/stderr/exit/timing。

M3实际启动后才做一次精确AAR检查：
`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

只检查该路径：
- HIT：记录 size + SHA-256；
- NON-HIT：明确记录，不搜索替代输出。

若 M3 exit0 但 AAR NON-HIT，分类为输出/证据缺口，不得执行M2。若精确AAR HIT，也**本任务仍不执行M2**；等待 fresh 独立验收后再下发 M2 targeted Gradle host-resolution。

## 8. evidence、生命周期与候选

controller完成后，host将 B 完整复制到 E；计算本轮 task-owned manifest，B/E必须一致。B保留，不删除；不得修改旧 R4/R6-R4-R2 evidence。

final `wsb list --raw` 只作会话存在性记录。不得 stop/close/reset/kill Owner Sandbox。task-owned子进程按既有 PID/Job 规则收尾。

候选分支：`review/h01-bib03-u15-td01-m3-guest-powershell-path-v0-8-r6-r4-r3`。

一个 candidate commit，唯一父为本任务commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_GUEST_POWERSHELL_PATH_AND_EXECUTION_RESULT_V0_8_R6_R4_R3.md`。
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`，只更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留。

CURRENT_CONTEXT 从 fixed main A 的正常 UTF-8 版本开始；发布前检查无 mojibake。

报告必须返回：candidate/sole parent/two blobs；fresh Sandbox ID；guest controller SHA/nonce；系统 powershell.exe exact path/version/hash；原始与临时 PATH；Get-Command/where/cmd where/子PowerShell gate；fresh isolation；复用cwd/tools存在性；真实pub attempt/exit/stdout/stderr；若pub PASS则M3 exit及精确AAR HIT/NON-HIT+hash；B→E manifest；Owner Sandbox最终状态。

不自我接受、不更新main、不执行M2、不修改AGENTS或ChatGPT项目源。完成后停止。
