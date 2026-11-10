# EliteSync v10｜Flutter `--no-version-check` 离线续行与条件式 M3 v0.8-R6-R4-R4

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — NO VERSION CHECK ONLY — ONE OFFLINE PUB ATTEMPT — CONDITIONAL ONE M3`

日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。ChatGPT负责整体规划与独立验收。

## 1. 已接受事实、激活与唯一目标

当前权威 main 为 `9a415997405314fc6e047f47f238cfd6f8de1ef4`。该 main 已接受 R6-R4-R3 候选精确 tree `fae56dad002235033b94482629ce3be69ed1c87f`。

R6-R4-R3 已接受：
- Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；WSB CLI=`0.8.107.0`；
- controller process/effective RemoteSigned、Security系统Path、活动网卡0、默认路由0均 PASS；
- fixed module cwd 与 R4 Flutter/Android/JDK/Git/Pub/Gradle精确路径存在；
- 系统 PowerShell exact path=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`，进程级 PATH 四门 PASS；
- PowerShell PATH 只在 controller/子进程临时调整，未改 Machine/User/注册表/组策略/profile/持久环境；
- 唯一真实 `flutter pub get --offline` 已启动，exit=69；首个诊断是 Flutter 工具执行 `git fetch --tags` 访问 `https://github.com/flutter/flutter.git/`，随后报告 pub.dev socket error；
- 该结果不授权联网，也不证明 cache 不足；
- M3 NOT_RUN，AAR NOT_CHECKED/probe=0，M2 deferred。

本任务不重跑 helper fixture、SRC/B3 current-view、observable probe、module copy/current-view、ordinary/batch smoke、Git、Java、PowerShell完整四门。它们作为已接受证据只读绑定。

本任务唯一目标：**在同一现有 Owner Sandbox 中，用新的 task-owned controller 复用已接受进程级 PATH 与固定 guest 路径，只对 Flutter 命令新增全局 `--no-version-check`，执行一次新的 `flutter --no-version-check pub get --offline`。若其 exit=0，立即执行一次 `flutter --no-version-check build aar --no-debug --no-profile --no-pub`；M3实际启动后才做唯一精确 AAR 检查。**

发布本文件不等于执行授权。Owner须直接批准：
> 批准固定 v0.8-R6-R4-R4 任务；允许仅在 `W/evidence/resume-r4` 下新增 `r6r4r4-no-version-check` 并新建 canonical evidence `W/evidence/resume-r6-r4-r4`。仅在本任务 guest controller 及其子进程使用进程级 RemoteSigned与临时 PATH；不得修改持久环境。允许一次新的 `flutter --no-version-check pub get --offline`，仅 exit=0 后允许一次 `flutter --no-version-check build aar --no-debug --no-profile --no-pub`。不得联网补包、不得新 `wsb share`、不得新建/stop/close/reset/kill Sandbox、不得重跑已接受 helper/observable/module-copy/smoke/Git/Java、不得执行M2或产品实现。

无批准只报告 `WAITING OWNER ACTIVATION`。本授权仅限 R6-R4-R4。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。开始仅通过 GitHub 远端核验：
1. main=A=`9a415997405314fc6e047f47f238cfd6f8de1ef4`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，并先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺 task ref/object 不构成 blocker。
4. task commit 唯一父必须=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A 中 R6-R4-R3 result blob=`3a856692e3a2eeb7c7068c28debef20f0c88b319`。
6. A 中 CURRENT_CONTEXT blob=`2c0e9353b7ccfde07c0787247a113805a3f9a440`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不仓库枚举/搜索、不访问旧仓库/default index/受保护 staged state。

## 3. 新 evidence bridge 与固定 guest 路径

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

新 host bridge：`B=W/evidence/resume-r4/r6r4r4-no-version-check`。
新 canonical evidence：`E=W/evidence/resume-r6-r4-r4`。

B/E 开始必须均不存在；任一存在 STOP `R6R4R4_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除、清空或复用。

创建 B 后只允许写本轮 controller/preflight/evidence。B 位于既有 R4 writable evidence mapping 源下，对应 guest 根：`C:/M3R4/evidence/r6r4r4-no-version-check`。禁止新的 `wsb share`。

只读绑定 guest 精确路径：
- module cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`；
- pubspec=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/pubspec.yaml`；
- Flutter=`C:/M3R4/t/f/bin/flutter.bat`；
- Android SDK=`C:/M3R4/t/a`；
- JDK=`C:/M3R4/t/j`；
- Git=`C:/M3R4/t/g/cmd/git.exe`；
- Pub cache=`C:/M3R4/p`；
- Gradle home=`C:/M3R4/h`；
- PowerShell=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`。

只允许对这些精确路径 `Test-Path -LiteralPath`；不得重新枚举/哈希模块，不重新复制模块，不搜索替代路径。

## 4. Controller 静态门

新 `guest-r6r4r4.ps1` 执行前必须通过 Windows PowerShell 5.1 parser/static gate。

硬规则：
- `throw` 必须有空格：`throw 'TEXT'`；禁止 `throw'` / `throw"`；
- 布尔仅 `$true/$false`；
- 真实工具非零退出必须先落盘 classification/stdout/stderr/exit/timing，再正常 return/exit；
- 只检查本轮 task-owned 脚本。

若静态门失败，只允许1次定点修正；仍失败 STOP `R6R4R4_GUEST_CONTROLLER_PREFLIGHT_FAILED`。通过后冻结 controller SHA。

## 5. 现有 Sandbox 与最小 fresh preflight

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止 `wsb share`、`wsb stop`、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

同一 ID、run-as System 执行本任务 controller：`-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

fresh preflight 只重验：
- controller started + nonce=`M3-ISO-V02-008-R6R4R4-<random>` + Sandbox ID；
- Process/effective RemoteSigned；Security module系统Path；
- 活动网卡=0；默认路由=0；
- §3所有精确路径存在。

不重跑 helper/current-view/observable/module copy/smoke/Git/Java。

仅对当前 controller/子进程设置临时 PATH：
1. `C:/Windows/System32/WindowsPowerShell/v1.0`
2. `C:/Windows/System32`
3. `C:/M3R4/t/f/bin`
4. `C:/M3R4/t/g/cmd`
5. `C:/M3R4/t/j/bin`
6. 再追加原始 PATH。

只做一个最小 PATH 解析门：`Get-Command powershell.exe -ErrorAction Stop` 必须解析到固定系统 PowerShell。失败 STOP `GUEST_POWERSHELL_PATH_RESOLUTION_NOT_ESTABLISHED`。不得重跑 R3 的 where/cmd-where/child-powershell 四门。

## 6. task-only 环境与唯一新的 offline pub

仅在 controller及其子进程设置：
- `JAVA_HOME=C:/M3R4/t/j`
- `ANDROID_HOME=C:/M3R4/t/a`
- `ANDROID_SDK_ROOT=C:/M3R4/t/a`
- `PUB_CACHE=C:/M3R4/p`
- `GRADLE_USER_HOME=C:/M3R4/h`
- `HOME=C:/M3R6R4R4/home`
- `USERPROFILE=C:/M3R6R4R4/home`
- `TEMP=C:/M3R6R4R4/tmp`
- `TMP=C:/M3R6R4R4/tmp`
- PATH保持§5临时值。

创建 task-owned home/tmp 后，执行**唯一一次新的 pub**：

- executable=`C:/M3R4/t/f/bin/flutter.bat`
- cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- args=`--no-version-check pub get --offline`
- 最长10分钟。

必须确认最终 batch command 的语义顺序是：
`flutter.bat --no-version-check pub get --offline`

记录 process_started、收到参数、最终 batch Arguments/command、stdout、stderr、exit、开始/结束时间。

禁止联网、禁止重试、禁止改 Pub cache/Flutter SDK/产品源码。

若 pub 非零：
- 先完整落盘真实诊断；
- 如果仍出现 Flutter `fetch --tags` / github.com 访问，分类 `OFFLINE_PUB_VERSION_CHECK_NETWORK_ATTEMPT_PERSISTS`；
- 如果不再出现版本检查，但 pub 仍尝试 pub.dev/socket，分类 `OFFLINE_PUB_NETWORK_ATTEMPT_PERSISTS_AFTER_NO_VERSION_CHECK`；
- 如果明确报告某个 package 不在本地 cache，分类 `OFFLINE_PUB_EXACT_CACHE_MISS` 并记录精确 package/version/诊断；
- 其他错误按首个真实诊断给最窄分类。

不得自动推断 cache 不足。pub 非零时 M3=`NOT_RUN`、AAR=`NOT_CHECKED`、probe=0。

## 7. pub成功后的唯一 M3 与精确 AAR

只有 pub exit=0 才允许一次 M3：

- executable=`C:/M3R4/t/f/bin/flutter.bat`
- cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- args=`--no-version-check build aar --no-debug --no-profile --no-pub`
- defines=EMPTY，追加0个 dart-define；
- 最长30分钟；不得重试。

必须记录完整 command/args/stdout/stderr/exit/timing。

M3实际启动后才检查一次唯一 AAR：
`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

HIT：记录 size/SHA-256。
NON-HIT：如实记录，不搜索替代路径。

即使 AAR HIT，本任务也不得执行 M2。

## 8. Evidence、Sandbox 生命周期与候选合同

任务结束后 host 完整复制 B→E，要求 task-owned manifest一致。B保留，不删除。

final `wsb list --raw`只记录状态。不得 stop/close/reset/kill Owner Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-flutter-no-version-check-v0-8-r6-r4-r4`。

一个 candidate commit，sole parent为本 task commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_NO_VERSION_CHECK_AND_EXECUTION_RESULT_V0_8_R6_R4_R4.md`
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

CURRENT_CONTEXT 只更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8、无 mojibake。

返回：candidate commit、sole parent、两个 blob、controller SHA/nonce、fresh Sandbox/隔离、临时 PATH 与 PowerShell解析门、真实 pub command/exit/诊断、若pub PASS则M3 command/exit与唯一AAR状态/size/hash、B→E manifest、Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。完成后停止。
