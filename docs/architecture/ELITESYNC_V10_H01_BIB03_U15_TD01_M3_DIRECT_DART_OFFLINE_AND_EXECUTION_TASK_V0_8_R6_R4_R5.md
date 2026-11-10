# EliteSync v10｜Direct Dart Offline 诊断、条件式 M3 与精确 AAR v0.8-R6-R4-R5

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — DIRECT DART OFFLINE ONLY — CONDITIONAL ONE M3`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。

## 1. 已接受事实与本任务唯一目标

当前权威 main 为 `fd447ca5cf3c8e7407a3a65bee144b6257a317c5`。该 main 已接受 R6-R4-R4 候选精确 tree `3ecc16d0e471639f21a76ece632acda49df6b0fe`。

已接受：
- Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；
- guest RemoteSigned / Security 系统路径 / 活动网卡0 / 默认路由0；
- 固定 module cwd 与 R4 Flutter/Android/JDK/Git/Pub/Gradle 路径存在；
- 进程级 PowerShell PATH 门已闭合；
- `flutter --no-version-check pub get --offline` 已真实执行一次，Flutter 版本检查的 `fetch --tags/github.com` 已消失；
- 但 pub 仍尝试 `https://pub.dev`，首个诊断为 `code_builder` socket error，exit=69；该证据不等于 exact cache miss；
- M3 NOT_RUN，AAR NOT_CHECKED/probe=0，M2 deferred。

Dart 官方当前文档规定：`dart pub get --offline` 在 offline 模式中只查看本地 package cache。Flutter 官方文档也区分 Flutter CLI 与 Dart CLI。因此本任务唯一目标是：**绕过 Flutter wrapper 的 pub 入口，使用固定 Flutter SDK 内置 Dart 执行一次真正的 `dart pub get --offline`；若成功，立即执行一次 Flutter M3；若失败，以 direct Dart 的首个真实诊断确定 cache/solver/network 分类。**

发布本文件不等于执行授权。Owner 须直接批准：
> 批准固定 v0.8-R6-R4-R5 任务；允许仅在 `W/evidence/resume-r4` 下新增 `r6r4r5-direct-dart` 并新建 canonical evidence `W/evidence/resume-r6-r4-r5`。允许在现有 Owner Sandbox 的 task-owned module copy 上，使用 Flutter SDK 内置 Dart 执行一次 `dart pub get --offline`，并允许该命令仅在 task-owned module copy 内写入其正常生成的 `pubspec.lock`、`.dart_tool` 及相关 pub 元数据。不得联网补包、不得写原仓库或宿主 cache。只有 direct Dart pub exit=0 后，允许一次 `flutter --no-version-check build aar --no-debug --no-profile --no-pub`。不得执行 M2。

无批准仅报告 `WAITING OWNER ACTIVATION`。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。

开始只通过 GitHub 远端核验：
1. main=A=`fd447ca5cf3c8e7407a3a65bee144b6257a317c5`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，先读取。
3. 本任务 branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺 task ref/object 不是 blocker。
4. task commit 唯一父必须=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A 中 R6-R4-R4 result blob=`f2d1024e316e096385bf1645af74788bd1554ce4`。
6. A 中 CURRENT_CONTEXT blob=`e611420974d5bbcab20de9b0c4aaa59226133ba1`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。
README 预算耗尽、FD02 永久排除；不得仓库枚举/搜索，不访问旧仓库/default index/受保护 staged state。

## 3. 固定本地与 guest 输入

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

新 host bridge：`B=W/evidence/resume-r4/r6r4r5-direct-dart`。
新 canonical evidence：`E=W/evidence/resume-r6-r4-r5`。

B/E 开始必须均不存在；任一存在 STOP `R6R4R5_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除、清空或复用。

固定 guest：
- module cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- pubspec=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/pubspec.yaml`
- optional lock=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/pubspec.lock`
- Flutter=`C:/M3R4/t/f/bin/flutter.bat`
- Dart=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- Flutter root=`C:/M3R4/t/f`
- Android=`C:/M3R4/t/a`
- JDK=`C:/M3R4/t/j`
- Git=`C:/M3R4/t/g/cmd/git.exe`
- Pub cache=`C:/M3R4/p`
- Gradle home=`C:/M3R4/h`
- PowerShell=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

只允许精确 `Test-Path -LiteralPath`；不得搜索替代路径。

## 4. 现有 Sandbox 与 fresh 最小 preflight

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止新 `wsb share`、`wsb stop`、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

新 controller 使用 run-as System、Windows PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

fresh 只重验：
- controller started + nonce=`M3-ISO-V02-008-R6R4R5-<random>` + Sandbox ID；
- Process/effective RemoteSigned；Security module 系统 Path；
- 活动网卡=0；默认路由=0；
- §3所有必需固定路径存在；
- Dart exact path 存在。

不重跑 helper/current-view/observable/module copy/smoke/Git/Java/R3 PowerShell四门。

进程级 PATH 仍仅前置：
`C:/Windows/System32/WindowsPowerShell/v1.0;C:/Windows/System32;C:/M3R4/t/f/bin;C:/M3R4/t/g/cmd;C:/M3R4/t/j/bin`，再追加原 PATH。

只做最小 `Get-Command powershell.exe` 精确门。

## 5. code_builder 有界 cache/lock 诊断

在任何真实 pub 前，只允许以下精确只读诊断：

1. 若 `pubspec.lock` 存在：
   - 仅对该精确文件运行 `Select-String -Pattern '^  code_builder:$' -Context 0,8`；
   - 记录命中与紧随的 version/source 字段；
   - 不输出或总结其他 package。
2. 对精确目录 `C:/M3R4/p/hosted/pub.dev` 仅允许一条有界过滤：
   - `Get-ChildItem -LiteralPath 'C:/M3R4/p/hosted/pub.dev' -Directory -Filter 'code_builder-*'`
   - 只记录匹配目录名；不得列出其他 package。
3. 不修改 Pub cache，不复制 package，不联网补齐。

该诊断用于解释 direct Dart 结果，但不得仅凭目录名提前宣告整个 dependency graph 完整或缺失。

## 6. task-only 环境与唯一 direct Dart offline pub

仅在 controller 及子进程设置：
- `FLUTTER_ROOT=C:/M3R4/t/f`
- `JAVA_HOME=C:/M3R4/t/j`
- `ANDROID_HOME=C:/M3R4/t/a`
- `ANDROID_SDK_ROOT=C:/M3R4/t/a`
- `PUB_CACHE=C:/M3R4/p`
- `GRADLE_USER_HOME=C:/M3R4/h`
- `HOME=C:/M3R6R4R5/home`
- `USERPROFILE=C:/M3R6R4R5/home`
- `TEMP=C:/M3R6R4R5/tmp`
- `TMP=C:/M3R6R4R5/tmp`
- `PUB_ENVIRONMENT=flutter_cli:elitesync_m3_r6r4r5`

创建 task-owned home/tmp 后，先执行一次只读版本验证：
`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe --version`
记录 stdout/stderr/exit；非0 STOP `DIRECT_DART_EXECUTABLE_NOT_ESTABLISHED`。

随后执行本任务唯一一次 direct Dart pub：
- executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- args=`pub get --offline`
- 最长10分钟
- attempt=1/1

允许该命令只在 task-owned module copy 内产生/更新正常 pub 输出（包括 `pubspec.lock`、`.dart_tool`、package config）。禁止写原仓库或宿主 Pub cache。

必须记录完整 command/args/stdout/stderr/exit/timing。

分类：
- 若出现任何 `http://`/`https://`/socket/DNS 网络尝试：`DIRECT_DART_OFFLINE_NETWORK_ATTEMPT`，记录首个目标/诊断；不得联网。
- 若明确指出 package/version 不在 cache 或 offline solver 无可用版本：`DIRECT_DART_OFFLINE_EXACT_CACHE_MISS`，记录精确 package/version/constraint/诊断；不得补包。
- 若 Flutter SDK dependency 无法解析：`DIRECT_DART_FLUTTER_SDK_CONTEXT_NOT_ESTABLISHED`，记录首个诊断；不得搜索替代 SDK。
- 其他非零：按首个真实诊断给最窄分类。

若 direct Dart pub 非零：M3=`NOT_RUN`，AAR=`NOT_CHECKED`、probe=0，停止。

## 7. direct Dart pub 成功后的唯一 M3

仅 direct Dart pub exit=0 才允许一次：

`C:/M3R4/t/f/bin/flutter.bat --no-version-check build aar --no-debug --no-profile --no-pub`

cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`；defines=EMPTY；最多30分钟；不得重试。

M3 实际启动后才检查一次唯一 AAR：
`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

HIT记录 size/SHA-256；NON-HIT 如实记录，不搜索替代路径。
即使 HIT，也不得执行 M2。

## 8. Evidence、生命周期与候选合同

结束后 host 完整复制 B→E，要求 task-owned manifest 一致；B保留。
final `wsb list --raw`只记录状态；不得 stop/close/reset/kill Owner Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-direct-dart-offline-v0-8-r6-r4-r5`。

一个 candidate commit，sole parent 为本 task commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_DIRECT_DART_OFFLINE_AND_EXECUTION_RESULT_V0_8_R6_R4_R5.md`
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

CURRENT_CONTEXT 只更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8、无 mojibake。

返回：candidate commit、sole parent、两个 blob、controller SHA/nonce、fresh Sandbox/隔离、Dart exact path/version、code_builder lock/cache有界诊断、direct Dart pub真实 command/exit/首个诊断、若PASS则M3/AAR、B→E manifest、Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。完成后停止。