# EliteSync v10｜Flutter-tools Offline Context 修复、Direct Snapshot M3 与精确 AAR v0.8-R6-R4-R7

Status: `PUBLISHED TASK — AWAITING OWNER ACTIVATION — GUEST FLUTTER-TOOLS OFFLINE CONTEXT ONLY — CONDITIONAL ONE DIRECT-SNAPSHOT M3 — NO M2`
日期：2026-09-09（Asia/Singapore）。默认执行模型：Owner 在 Codex 界面选择 GPT-5.6 Sol，推理强度 Medium；不修改模型配置、不默认调用辅助代理。

## 1. 已接受事实与唯一目标

当前权威 main 为 `a41158c93c134d8f53db11c90c2f5461ba0523d1`。该 main 已接受 R6-R4-R6 候选精确 tree `e846e3413a6a336dc84665c06df6e8ea65fb2d60`。

已接受事实：
- Owner Sandbox ID=`68ece109-c661-420c-9899-02b1e9518036`；
- guest RemoteSigned / Security 系统 Path / 活动网卡0 / 默认路由0；
- fixed module cwd 与 R4 Flutter/Android/JDK/Git/Pub/Gradle 路径存在；
- module 直接 `dart pub get --offline` 已 exit=0 且无网络行为；
- 直接 Dart 加载既有 `flutter_tools.snapshot` 的 M3 仍在 `build aar --no-pub` 路径尝试从 `pub.dev` 查找 `coverage`，exit=69；精确 AAR NON-HIT；
- 因 direct snapshot 已绕过 `flutter.bat/shared.bat`，剩余网络尝试属于 Flutter tool/build 路径，而非 Windows wrapper bootstrap；
- Flutter 当前公开 `packages/flutter_tools/pubspec.yaml` 固定依赖 `coverage: 1.15.1` 与 `code_builder: 4.11.1`。

本任务不修改宿主 Flutter SDK，也不修改仓库产品源码。唯一目标：**确认 guest 固定 Pub cache 是否具备 Flutter-tools 的精确 `coverage-1.15.1`；若具备，则仅在 Sandbox 内 R4 Flutter SDK 副本的 `packages/flutter_tools` 上执行一次 direct Dart `pub get --offline`，修复/刷新 Flutter-tools 自身 package context；该步骤成功且全程无网络后，重新执行一次 direct `flutter_tools.snapshot build aar --no-pub`。**

发布本文件不等于执行授权。Owner 须直接批准：
> 批准固定 v0.8-R6-R4-R7。允许仅在现有 Owner Sandbox 内的 R4 Flutter SDK 副本 `C:/M3R4/t/f` 写入 direct Dart offline pub 对 Flutter-tools 自身正常产生/更新的 package context（仅 `packages/flutter_tools` / Dart workspace 正常 pub 元数据，如 `.dart_tool/package_config.json`、workspace package config / lock 相关元数据；不得修改源码、snapshot、Flutter binaries、宿主 `D:/flutter` 或宿主 Pub cache）。允许一次 `dart pub get --offline` 用于 Flutter-tools context；仅该命令 exit=0 且无网络行为后允许一次 direct-snapshot M3。不得联网补包、不得重试、不得执行 M2。

无批准只报告 `WAITING OWNER ACTIVATION`。

## 2. 固定 GitHub 远端 authority

仓库：`zcx369658780/EliteSync-v10`。

开始只通过 GitHub 远端核验：
1. main=A=`a41158c93c134d8f53db11c90c2f5461ba0523d1`。
2. FIRST：`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md` blob=`18485c95262051e43892436fb52413132c5ee626`，先读取。
3. 本 task branch/commit/path/blob 使用启动 prompt 固定值，只从 GitHub 远端验证；本机缺 task ref/object 不构成 blocker。
4. task commit 唯一父必须=A；相对A ahead=1、behind=0且只新增本任务文件。
5. A 中 R6-R4-R6 result blob=`56d530e1010db57bfa2dabb27f337e083ef5a844`。
6. A 中 CURRENT_CONTEXT blob=`d25c5d86bdb1aafed4c48e1283f2337a454e2088`。

仅远端失配 STOP `REMOTE_TASK_AUTHORITY_MISMATCH`。
README 预算耗尽、FD02 永久排除；不得仓库枚举/搜索，不访问旧仓库/default index/受保护 staged state。

## 3. 新 evidence bridge 与固定 guest 输入

固定 W=`D:/EliteSync-M3-readiness-v02/attempts/M3-ISO-V02-008`。

新 host bridge：`B=W/evidence/resume-r4/r6r4r7-flutter-tools-offline-context`。
新 canonical evidence：`E=W/evidence/resume-r6-r4-r7`。

B/E 开始必须均不存在；任一存在 STOP `R6R4R7_TASK_OWNED_PATH_ALREADY_EXISTS`。不得删除、清理或复用旧证据。

固定 guest：
- module cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`
- module package config=`C:/M3R6R4R2/w/apps/flutter_elitesync_module/.dart_tool/package_config.json`
- Flutter root=`C:/M3R4/t/f`
- Flutter-tools dir=`C:/M3R4/t/f/packages/flutter_tools`
- Flutter-tools pubspec=`C:/M3R4/t/f/packages/flutter_tools/pubspec.yaml`
- Flutter-tools package config=`C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`
- Dart=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- snapshot=`C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`
- Android=`C:/M3R4/t/a`
- JDK=`C:/M3R4/t/j`
- Git=`C:/M3R4/t/g/cmd/git.exe`
- Pub cache=`C:/M3R4/p`
- Gradle home=`C:/M3R4/h`
- PowerShell=`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

不得搜索替代路径。

## 4. 现有 Sandbox 与 fresh 最小 preflight

仅允许 `wsb --version`、`wsb list --raw`、`wsb exec`。禁止新 `wsb share`、`wsb stop`、新 Sandbox。

`wsb list --raw` 必须恰好一个 running Sandbox，ID=`68ece109-c661-420c-9899-02b1e9518036`。0个/ID变化 STOP `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE`；多个/歧义 STOP `SANDBOX_SESSION_HANDLE_AMBIGUOUS`。

controller：run-as System；Windows PowerShell `-NoProfile -NonInteractive -ExecutionPolicy RemoteSigned`。

fresh 只重验：
- controller started + nonce=`M3-ISO-V02-008-R6R4R7-<random>` + Sandbox ID；
- Process/effective RemoteSigned；Security module 系统 Path；
- 活动网卡=0；默认路由=0；
- §3 必需固定路径存在；
- `dart.exe --version` exit=0。

不重跑 helper/current-view/observable/module copy/smoke/Git/Java/module direct Dart pub/R3 PowerShell四门。

进程级 PATH 仅前置：
`C:/Windows/System32/WindowsPowerShell/v1.0;C:/Windows/System32;C:/M3R4/t/f/bin;C:/M3R4/t/g/cmd;C:/M3R4/t/j/bin`，再追加原 PATH。
只做最小 `Get-Command powershell.exe` 精确门。

## 5. Flutter-tools `coverage` 有界 cache/context 诊断

在任何写入前，仅允许：

1. 精确读取 `C:/M3R4/t/f/packages/flutter_tools/pubspec.yaml` 中：
   - `coverage:` 一行；必须解析为 `1.15.1`；
   - `code_builder:` 一行；必须解析为 `4.11.1`。
2. 对 `C:/M3R4/p/hosted/pub.dev` 仅两条过滤：
   - `Get-ChildItem -LiteralPath 'C:/M3R4/p/hosted/pub.dev' -Directory -Filter 'coverage-*'`
   - `Get-ChildItem -LiteralPath 'C:/M3R4/p/hosted/pub.dev' -Directory -Filter 'code_builder-*'`
   只记录匹配目录名，不得列出其他 package。
3. 若 Flutter-tools package config 存在，仅对该精确文件搜索 package names `coverage` 与 `code_builder`，记录对应 rootUri/packageUri；不得输出其他 package。
4. 记录 Flutter-tools package config 与 snapshot 当前 Length/SHA-256。

若 `coverage-1.15.1` 不存在：STOP `FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS`。不得联网、不得复制或补齐 package。

## 6. 唯一 Flutter-tools direct Dart offline context repair

仅在 controller/子进程设置：
- `FLUTTER_ROOT=C:/M3R4/t/f`
- `PUB_CACHE=C:/M3R4/p`
- `JAVA_HOME=C:/M3R4/t/j`
- `ANDROID_HOME=C:/M3R4/t/a`
- `ANDROID_SDK_ROOT=C:/M3R4/t/a`
- `GRADLE_USER_HOME=C:/M3R4/h`
- `HOME=C:/M3R6R4R7/home`
- `USERPROFILE=C:/M3R6R4R7/home`
- `TEMP=C:/M3R6R4R7/tmp`
- `TMP=C:/M3R6R4R7/tmp`
- `PUB_ENVIRONMENT=flutter_tools:elitesync_m3_r6r4r7`

执行一次：
- executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- cwd=`C:/M3R4/t/f/packages/flutter_tools`
- args=`pub get --offline`
- attempt=1/1
- timeout=10分钟。

允许写入仅限 Sandbox 内 Flutter SDK 副本中由该 pub 正常生成/更新的 Flutter-tools / workspace pub 元数据。禁止修改任何 `.dart` / `.yaml` 源文件内容；禁止修改 snapshot、Dart SDK、Flutter binaries；禁止写宿主 `D:/flutter` 或宿主 cache。

必须记录完整 command/args/stdout/stderr/exit/timing，以及写前/写后 Flutter-tools package config Length/SHA-256。

分类：
- 任何 URL/socket/DNS => `FLUTTER_TOOLS_DIRECT_DART_OFFLINE_NETWORK_ATTEMPT`；不得联网。
- 明确 package/version cache miss => `FLUTTER_TOOLS_DIRECT_DART_OFFLINE_EXACT_CACHE_MISS`，记录精确 package/version/constraint。
- workspace/context 非零 => `FLUTTER_TOOLS_DIRECT_DART_WORKSPACE_CONTEXT_FAILURE`，记录首个诊断，不改 workspace 源文件。
- 其他非零按首个真实诊断最窄分类。

若非零：M3=`NOT_RUN`，AAR=`NOT_CHECKED`、probe=0，停止。

pub exit=0 后必须验证 Flutter-tools package config 中 `coverage` rootUri 指向本地 `C:/M3R4/p/hosted/pub.dev/coverage-1.15.1`（规范化路径比较）；否则 STOP `FLUTTER_TOOLS_COVERAGE_CONTEXT_NOT_ESTABLISHED`。

snapshot SHA-256 必须仍精确等于写前值；若变化 STOP `FLUTTER_TOOLS_SNAPSHOT_MUTATED_UNEXPECTEDLY`。

## 7. 唯一 direct-snapshot M3

仅 §6 全部 PASS 后允许一次：

executable=`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`

args 顺序：
1. `--packages=C:/M3R4/t/f/packages/flutter_tools/.dart_tool/package_config.json`
2. `C:/M3R4/t/f/bin/cache/flutter_tools.snapshot`
3. `--no-version-check`
4. `build`
5. `aar`
6. `--no-debug`
7. `--no-profile`
8. `--no-pub`

cwd=`C:/M3R6R4R2/w/apps/flutter_elitesync_module`；defines=EMPTY；attempt=1/1；timeout=30分钟；不得重试。

完整记录 process_started、actual executable（能捕获则记录，不能则 null）、args、stdout/stderr/exit/timing。

分类：
- 再出现 `coverage` + pub.dev/network => `M3_NETWORK_ATTEMPT_PERSISTS_AFTER_FLUTTER_TOOLS_OFFLINE_CONTEXT`。
- 其他 network => `DIRECT_FLUTTER_TOOLS_SNAPSHOT_NETWORK_ATTEMPT`，记录首个目标。
- Gradle/Android/build 错误 => 按首个真实诊断最窄分类。

只要 M3 process_started=true，做一次唯一精确 AAR probe：
`C:/M3R6R4R2/w/apps/flutter_elitesync_module/build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`

HIT记录 size/SHA-256；NON-HIT如实记录；probe=1；不得搜索替代路径。

若 M3 exit=0 且 AAR HIT：
`M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`
但本任务仍不得执行 M2。

## 8. Evidence 与候选合同

结束后 host 完整复制 B→E，要求 task-owned manifest一致；B保留。
final `wsb list --raw`仅记录状态；不得 stop/close/reset/kill Owner Sandbox。

候选分支：`review/h01-bib03-u15-td01-m3-flutter-tools-offline-context-v0-8-r6-r4-r7`。

一个 candidate commit，sole parent 为本 task commit，恰好两个路径：
1. 新增 `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_EXECUTION_RESULT_V0_8_R6_R4_R7.md`
2. 更新 `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

CURRENT_CONTEXT 只更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8、无 mojibake。

返回：candidate commit、sole parent、两个 blobs、controller SHA/nonce、fresh Sandbox/隔离、coverage/code_builder固定版本与cache命中、Flutter-tools package config写前/写后SHA、Flutter-tools direct Dart offline pub结果、snapshot写前/写后SHA、若PASS则唯一M3/AAR、B→E manifest、Owner Sandbox最终状态。

不自我接受、不更新 main、不执行 M2、不修改 AGENTS 或 ChatGPT 项目源。完成后停止。
