# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Owner-Declared Fixed-Input Source Verification + Remaining A Re-establishment Task v0.1

Status: `PUBLISHED TASK SHEET — OWNER EXACT SOURCE DECLARATION REQUIRED — REMAINING A ONLY — NO B — NO FLUTTER-TOOLS PUB — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Singapore）。

## 1. Authority 与本任务目的

仓库：`zcx369658780/EliteSync-v10`。

本任务发布基线：

`e2a4cbb6bc4747f4c867a3ff7a6c74708e6259e6`

该 main 接受 A2 的唯一结论是：现有仓库历史证据不足以恢复 Android SDK、JDK、Git、Pub cache、Gradle cache 与 fixed module 的当前 literal host source authority；A 仍未完成，B/M3/M2 均未授权。

本任务只解决这个已证明的新缺口：由 Owner 在启动时明确提供六类**当前宿主 literal source path**，执行者只对这些精确路径做 bounded existence / identity / read-only source verification，并在 A1 Sandbox 仍唯一存在时完成剩余 A materialization。

本任务不再继续挖历史 blob，不允许把旧 guest 路径提升为 host source，也不允许宿主搜索。

`OWNER DECLARED PATH != VERIFIED IDENTITY`

`VERIFIED SOURCE != A SUCCESS UNTIL MATERIALIZED AND RECHECKED`

`A SUCCESS != B AUTHORITY`

## 2. 必须首先执行的 authority 门

1. fresh-fetch remote `main`；必须仍为：
   `e2a4cbb6bc4747f4c867a3ff7a6c74708e6259e6`。
   否则立即：`STOP — MAIN AUTHORITY CHANGED`。
2. FIRST 读取固定转型 handoff：
   `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
   blob=`18485c95262051e43892436fb52413132c5ee626`。
3. 读取本任务文件。
4. 读取 A2 result：
   `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FIXED_INPUT_SOURCE_RECOVERY_AND_REMAINING_A_REESTABLISHMENT_RESULT_V0_1.md`
   blob=`bf9126e06c329c62151f3360dc01db8c754a21d5`。

不得做 repository-wide / directory-wide enumeration 或搜索。

## 3. Owner 启动声明是强制输入

执行者在任何宿主 source access 前，必须从 Owner activation prompt 得到以下六个**完整 literal absolute host paths**：

- `ANDROID_SDK_SOURCE=<absolute path>`
- `JDK_SOURCE=<absolute path>`
- `GIT_SOURCE=<absolute path>`
- `PUB_CACHE_SOURCE=<absolute path>`
- `GRADLE_CACHE_SOURCE=<absolute path>`
- `FIXED_MODULE_SOURCE=<absolute path>`

要求：

- 不允许 `%VAR%`、`$env:VAR`、`~`、相对路径、`W/...`、glob、wildcard；
- 不允许只给父目录然后让执行者搜索；
- 不允许旧 guest `C:/M3R4/**`；
- Owner 可以给目录根或精确 executable/source root，但必须足以让本任务按下述固定检查定位对象；
- 若任一项缺失或非 literal absolute path：
  `STOP — OWNER_EXACT_SOURCE_DECLARATION_INCOMPLETE`。

Owner 声明只创建访问这些精确路径的任务权限，不自动证明这些 source 与历史固定输入相同。

## 4. 永久边界与明确禁止

继续保持 README budget exhausted、FD02 排除、D-02 durable UNKNOWN、U-14、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01、Backend 0/10、DB 0/8、PUI deferred、PUI-PREREQ-12=0、legal/Safety/no-processing 边界、LC-03/LC-04/Phase36 未授权、产品实现未授权、v9 非 v10 architecture authority。

不得：

- 检查/修改/unstage/reset/clean/提交无关 protected staged/index state；
- 运行默认 `git status`；
- 搜索 drives、Program Files、Users、PATH、registry、environment、package manager 安装记录；
- 在 Owner 声明路径之外探测候选 SDK/cache/source；
- 网络访问、下载、安装、补包；
- Flutter-tools Dart pub、`flutter pub get`；
- coverage/code_builder diagnosis；
- M3、AAR probe、M2；
- 修改宿主 SDK/cache/source；
- stop/close/reset/kill Sandbox；
- 创建第二个 Sandbox。

## 5. A1 Sandbox continuation gate

fresh：

`wsb --version`

`wsb list --raw`

唯一允许状态：恰好一个 running Sandbox，ID：

`0087a898-5221-41df-a33d-65045ffea69a`

若 0 个：`STOP — A1_SANDBOX_NO_LONGER_RUNNING`。

若不是唯一该 ID：`STOP — A1_SANDBOX_NOT_UNIQUELY_AVAILABLE`。

不得创建新 Sandbox。

然后最小复核 A1 substrate：SYSTEM、PS5.1、Process/effective RemoteSigned、Security machine PATH、active adapter=0、default route=0、A1 manifest SHA=`A41FD0A5EA1598688AD50CD398EAF190EE42204B29105AE688D1C7281405AB88`、Flutter Dart/pubspec/snapshot 三项 SHA。若任一漂移：`STOP — A1_SUBSTRATE_IDENTITY_DRIFT`。

Flutter 不重做 materialization。

## 6. 六类 Owner-declared source 的 bounded verification

只访问 §3 Owner 声明的六个 exact source。

### 6.1 Android SDK

- source path 必须 exists/Container；
- 记录 literal root；
- 只允许定位**固定相对路径**（不得搜索）：若存在则记录 `platform-tools/adb.exe`、`cmdline-tools/latest/bin/sdkmanager.bat`、以及任务后续 Flutter build 已知需要的 Android SDK 根；不存在不自动失败，只保留 NOT_PRESENT；
- 对实际存在的上述固定对象记录 Length/SHA-256；
- 不运行 sdkmanager、不解析在线组件。

### 6.2 JDK

Owner 声明可为 JDK root 或 `java.exe`。

- 若 root：唯一固定相对路径 `bin/java.exe`；
- 记录 `java.exe` Length/SHA-256；
- 运行一次 `java -version`；
- 预期与历史 guest identity 相容：Temurin/OpenJDK 17.0.18+8。若版本不匹配：`STOP — JDK_SOURCE_IDENTITY_MISMATCH`。

### 6.3 Git

Owner 声明可为 Git root 或 `git.exe`。

- root 时只检查固定相对候选 `cmd/git.exe`；不得搜索；
- 记录 Length/SHA-256；
- 一次 `git --version`；
- 预期 `git version 2.53.0.windows.1`。不匹配：`STOP — GIT_SOURCE_IDENTITY_MISMATCH`。

### 6.4 Pub cache

- source path must exists/Container；
- 记录 root identity：literal path、root timestamps/attributes（若可得）、task-time bounded marker；
- **本任务不枚举 package names、不查 coverage/code_builder**；
- 为后续 materialization 允许对该 exact root 执行 task-authorized recursive copy/robocopy 到 Sandbox guest-local Pub cache。该 traversal 仅限 Owner 精确声明 root，不构成 host-wide search；
- 宿主 source 必须 read-only access；不得写 host cache。

### 6.5 Gradle cache

同 Pub cache：

- exact root exists/Container；
- 不运行 Gradle resolution；
- 允许仅对该 exact root 做 recursive materialization 到 guest-local Gradle cache；
- 不修改 host cache。

### 6.6 Fixed module

- exact root exists/Container；
- 允许使用已冻结 module current-view 合同对**这个单一 Owner-declared module root**做 recursive current-view；这是本任务明确授权的唯一 source-tree enumeration；
- 必须匹配：527 files / 301 dirs / 3234145 bytes / reparse=0；
- manifest SHA-256 必须：
  `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`；
- 不匹配：`STOP — FIXED_MODULE_SOURCE_IDENTITY_MISMATCH`；
- 不读取 `.android/**` 内容作为技术证据，不运行 pub/build。

## 7. Materialization 规则

只有 §6 六类全部通过后，才允许 materialize 到现有 A1 Sandbox。

建议 guest-local 固定布局：

- Android：`C:/M3A/tools/android`
- JDK：`C:/M3A/tools/jdk`
- Git：`C:/M3A/tools/git`
- Pub cache：`C:/M3A/cache/pub`
- Gradle cache：`C:/M3A/cache/gradle`
- module：`C:/M3A/work/apps/flutter_elitesync_module`

实际可等价调整，但必须逐一记录。

方法：host exact source 以 read-only share 或 task transport source 进入 guest，再复制到 guest-local writable destination。不得让 guest 写回宿主 source。

对 JDK/Git 复制后重做 exact executable SHA + version；module 重做冻结 current-view；Android 做固定对象 SHA；Pub/Gradle cache 记录 copy exit/统计和 guest root existence，但本任务不做 package-specific diagnosis。

## 8. A 完成条件

必须同时满足：

- A1 Sandbox/substrate 全部保持；
- Flutter 已保持；
- Android/JDK/Git/Pub/Gradle/module 六类 Owner-declared host source 都通过 bounded verification；
- 六类都 materialize 到 guest-local fixed paths；
- JDK/Git/module guest identity 复核通过；
- Android fixed objects 与 cache roots 建立；
- host source 无写入；
- 无网络；
- 未执行 B/pub/M3/AAR/M2。

唯一成功结论：

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

否则使用最窄 stop classification，不得声称 A 成功。

## 9. 结果产物与停止

创建：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_OWNER_DECLARED_FIXED_INPUT_SOURCE_VERIFICATION_AND_REMAINING_A_REESTABLISHMENT_RESULT_V0_1.md`

结果必须记录 Owner 六路径声明、source verification、materialization、guest identities、Sandbox final state、所有 NOT_RUN 项。

允许在 review branch 中只新增该结果文件；CURRENT_CONTEXT 不要求修改。

提交 candidate，sole parent 必须为本 task commit，然后 STOP。

不得 self-accept、不得 update main、不得执行 B。
