# EliteSync v10｜Direct `flutter_tools.snapshot` 条件式 M3 与精确 AAR v0.8-R6-R4-R6

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — BYPASS FLUTTER.BAT BOOTSTRAP ONLY — ONE M3 ATTEMPT — NO M2`

日期：2026-09-09（Asia/Singapore）。默认执行模型：GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。

## 1. 已接受事实与本任务唯一目标

当前权威 main=`35667044e94c51f3f100d03a8da81cb83202691f`。该 main 已接受 R6-R4-R5 候选精确 tree=`21065e9aa18f8a96bed23f99dac4357c40b0a768`。

已接受：
- direct Dart `pub get --offline` 在固定 module cwd 上 exit=0，约2秒完成，stdout包含 `Got dependencies!`，无 URL/socket/DNS 诊断；因此该 module dependency graph 可以从固定本地 Pub cache 由 Dart 直接离线解析；
- Dart exact executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`，版本=`3.11.5 stable windows_x64`；
- `code_builder` cache有界命中=`code_builder-4.11.1`；
- 随后唯一 `flutter.bat --no-version-check build aar --no-debug --no-profile --no-pub` 实际启动，但 Flutter 仍从 pub.dev 查找 `coverage`，exit=69；
- 精确 AAR NON-HIT/probe=1；M2 deferred/NOT_RUN；
- Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`，RemoteSigned/Security/禁网/PATH/固定路径均已建立。

官方 Flutter 当前 Windows 启动脚本行为与本轮证据一致：`flutter.bat` 会先 CALL `bin/internal/shared.bat`；该 shared 脚本在 snapshot/stamp/engine/timestamp 条件不满足时进入 `do_snapshot`，并执行 Flutter tool 自身的 `dart pub upgrade`，该路径不受项目命令的 `--no-pub` 约束。随后 `flutter.bat` 才调用现成的 `bin/cache/flutter_tools.snapshot`。本任务不修 shared.bat、不改 Flutter SDK；只绕过该 bootstrap 层，直接调用已存在 snapshot。

本任务唯一目标：**复用已接受 direct-Dart 后的 task-owned module state，验证 Flutter tool snapshot 与其 package_config 精确存在，然后用 Dart 直接执行现成 `flutter_tools.snapshot --no-version-check build aar --no-debug --no-profile --no-pub` 一次。若 snapshot 本身不再触发网络，则得到真正 M3 结果；实际启动后只检查唯一精确 AAR。**

发布不等于激活。Owner须批准：
> 批准固定 v0.8-R6-R4-R6；允许在现有 Owner Sandbox 中，仅通过 Flutter SDK 内置 Dart 直接执行既有 `bin/cache/flutter_tools.snapshot` 一次 M3。允许只写 task-owned module copy 正常 build 输出；不得修改 Flutter SDK、shared.bat、snapshot、package_config、宿主 cache、原仓库或持久环境。不得联网、不得重试、不得执行 M2。

## 2. GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。

开始仅通过 GitHub 远端核验：
1. main=A=`35667044e94c51f3f100d03a8da81cb83202691f`。
2. FIRST `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，先读取。
3. 本 task branch/commit/path/blob 使用启动 prompt 固定值，仅远端核验；本机缺 task ref/object 不是 blocker。
4. task 唯一父必须=A；相对 A ahead=1、behind=0，且只新增本任务文件。
5. A 中 R6-R4-R5 result blob=`2450f706cd1ac7602f632f1e85b4019d6a9963ef`。
6. A 中 CURRENT_CONTEXT blob=`3e4f0591a3f84fd166b68eb6f27dce7d709ee6d8`。

失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。README预算耗尽、FD02永久排除；不得仓库枚举/搜索，不访问 default index、受保护 staged state 或旧仓库。

## 3. 新 evidence 与固定 guest 输入

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

新 host bridge：`B=W/evidence/resume-r4/r6r4r6-direct-snapshot`。
新 canonical evidence：`E=W/evidence/resume-r6-r4-r6`。

B/E 开始必须不存在；任一存在 STOP `R6R4R6_TASK_OWNED_PATH_ALREADY_EXISTS`，不得删除/清空/复用。

固定 guest 路径：
- module cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- pubspec=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/pubspec.yaml`
- package config=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/.dart_tool/package_config.json`
- Dart=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- Flutter snapshot=`C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`
- Flutter tools package config=`C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`
- Flutter root=`C:/M3R4/t/f`
- Android=`C:/M3R4/t/a`
- JDK=`C:/M3R4/t/j`
- Git=`C:/M3R4/t/g/cmd/git.exe`
- Pub cache=`C:/M3R4/p`
- Gradle home=`C:/M3R4/h`
- PowerShell=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

只允许精确 `Test-Path -LiteralPath`；不得搜索替代路径，不重新枚举/哈希 module，不重新 direct-Dart pub。

## 4. 现有 Sandbox 与最小 fresh preflight

只允许 `wsb --version`、`wsb list --raw`、`wsb exec`；禁止新 share、stop、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

新 controller：run-as System，Windows PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

fresh 只重验：
- controller started + nonce=`M3-ISO-V02-008-R6R4R6-<random>` + Sandbox ID；
- Process/effective RemoteSigned；Security module系统Path；
- 活动网卡=0；默认路由=0；
- §3 必需路径存在；
- module `.dart_tool/package_config.json` 存在，证明 accepted direct-Dart pub 输出仍在；
- snapshot 和 Flutter-tools package_config 均存在。

不得重跑 helper/current-view/observable/module copy/smoke/Git/Java/direct-Dart pub/R3完整PowerShell四门。

进程 PATH 仅前置：
`C:/Windows/System32/WindowsPowerShell/v1.0;C:/Windows/System32;C:/M3R4/t/f/bin;C:/M3R4/t/g/cmd;C:/M3R4/t/j/bin`，再追加原 PATH。

仅做最小 `Get-Command powershell.exe` 门。

## 5. Snapshot 只读身份绑定

在 M3 前只允许对以下两个精确文件读取 Length + SHA-256：
1. `C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`
2. `C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`

并记录 Dart `--version` 一次作为 executable identity；不得执行任何 Flutter wrapper 命令、doctor、precache、update-packages、pub、upgrade 或 version check。

若 snapshot/package_config 缺失或不可读：STOP `FLUTTER_TOOLS_SNAPSHOT_IDENTITY_NOT_ESTABLISHED`。不得生成新 snapshot，不得修改 timestamp/stamp/shared.bat。

## 6. task-only 环境与唯一 direct-snapshot M3

仅在 controller/子进程设置：
- `FLUTTER_ROOT=C:/M3R4/t/f`
- `JAVA_HOME=C:/M3R4/t/j`
- `ANDROID_HOME=C:/M3R4/t/a`
- `ANDROID_SDK_ROOT=C:/M3R4/t/a`
- `PUB_CACHE=C:/M3R4/p`
- `GRADLE_USER_HOME=C:/M3R4/h`
- `HOME=C:/M3R6R4R6/home`
- `USERPROFILE=C:/M3R6R4R6/home`
- `TEMP=C:/M3R6R4R6/tmp`
- `TMP=C:/M3R6R4R6/tmp`

创建 task-owned home/tmp 后，执行唯一一次 M3：

executable：
`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`

args，顺序必须精确：
1. `--packages=C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`
2. `C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`
3. `--no-version-check`
4. `build`
5. `aar`
6. `--no-debug`
7. `--no-profile`
8. `--no-pub`

cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`。
defines=EMPTY，追加0个 dart-define。
最长30分钟；attempt=1/1；不得重试。

必须记录 actual executable、完整 args、stdout/stderr、exit、start/end、timeout、process_started。

网络分类：
- 若仍出现 `http://`/`https://`/socket/DNS/pub.dev/github.com：`DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`，记录首个目标/诊断，不联网；
- 若 snapshot/package context 错误：`DIRECT_FLUTTER_TOOLS_SNAPSHOT_CONTEXT_FAILURE`，记录首个诊断，不改 SDK；
- 若 Gradle/Android/build 错误：按首个真实诊断给最窄分类；
- exit=0 仍不等于 AAR HIT，必须继续精确 AAR probe。

## 7. 精确 AAR probe

只要上述 M3 process_started=true，不论 exit 是否0，都执行一次且仅一次：
`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

HIT：记录 size/SHA-256。
NON-HIT：如实记录，probe=1，不搜索替代路径。

若 M3 exit=0 且 AAR HIT：最终可分类 `M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`，但本任务仍不得执行 M2。

若 M3 exit=0 且 AAR NON-HIT：`M3 EXIT0 — EXACT AAR NON-HIT`。

## 8. Evidence 与候选合同

结束后 host 完整复制 B→E，要求 task-owned manifest 一致；B保留。
final `wsb list --raw`只记录状态；不得 stop/close/reset/kill Owner Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-direct-flutter-tools-snapshot-v0-8-r6-r4-r6`。

一个 candidate commit，sole parent=本 task commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_DIRECT_FLUTTER_TOOLS_SNAPSHOT_AND_EXECUTION_RESULT_V0_8_R6_R4_R6.md`
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

CURRENT_CONTEXT只更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8、无 mojibake。

返回：candidate、sole parent、两个 blob、controller SHA/nonce、fresh Sandbox/隔离、Dart identity、snapshot/package_config size+SHA、唯一 direct-snapshot M3 command/exit/首个诊断、精确 AAR probe/size/hash、B→E manifest、Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。完成后停止。
