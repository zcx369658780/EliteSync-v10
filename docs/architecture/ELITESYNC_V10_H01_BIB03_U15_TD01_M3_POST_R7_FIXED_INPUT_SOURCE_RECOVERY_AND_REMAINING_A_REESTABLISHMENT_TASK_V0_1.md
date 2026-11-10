# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fixed-Input Source Recovery + Remaining A Re-establishment Task v0.1

Status: `PUBLISHED TASK SHEET — A2 ONLY — RECOVER EXACT HISTORICAL SOURCE AUTHORITY + COMPLETE REMAINING A INPUTS — NO B — NO FLUTTER-TOOLS PUB — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Singapore）。

## 1. Authority 与唯一目标

仓库：`zcx369658780/EliteSync-v10`。

执行基线必须 fresh-fetch 并确认：

`8d66887fca4374377b448d942e1fde3d85f4b390`

该 accepted main exact tree：

`94e227bd49881713c4e1d6af057bf9a273219397`

A1 已接受结果为：

`REESTABLISHMENT_INPUT_NOT_PROVEN`

A1 candidate/result commit：

`be8e24290102181d47e5b7dda402a15fd0df139b`

result blob：

`9e80595d58baefdd9e2eb9fa940d5e1b204ee696`

A1 fresh Sandbox ID：

`0087a898-5221-41df-a33d-65045ffea69a`

A1 已建立 Flutter、transport、SYSTEM、PowerShell 5.1、RemoteSigned、Security PATH、adapter=0、route=0；但 Android SDK、JDK、Git、Pub cache、Gradle cache、fixed module copy 的 host source exact path / accepted identity 未由当时允许的文档证明。

本 A2 的唯一目标：

1. 仅从本任务列明的 exact historical blobs 恢复这六类 fixed inputs 的历史 source/path/identity authority；
2. 若且仅若这些 exact blobs 足以证明具体宿主 source path 与必要 identity，则在仍运行的 A1 Sandbox 中 materialize/verify 剩余 A 输入；
3. 若任何必需 source/path/identity 仍不能由精确证据证明，则停止为：

`FIXED_INPUT_SOURCE_AUTHORITY_NOT_RECOVERED`

本任务不进入 B。

## 2. FIRST 与允许读取的 exact GitHub 对象

开始顺序：

1. fresh-fetch `main`，必须仍为 `8d66887fca4374377b448d942e1fde3d85f4b390`；否则 `STOP — MAIN AUTHORITY CHANGED`。
2. FIRST 读取：
   `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
   固定 blob=`18485c95262051e43892436fb52413132c5ee626`。
3. 读取本任务。
4. 读取 A1 result blob=`9e80595d58baefdd9e2eb9fa940d5e1b204ee696`。
5. 为恢复 fixed-input authority，只允许读取以下 exact historical blobs，不得搜索仓库或目录：
   - R6-R4-R6 result=`56d530e1010db57bfa2dabb27f337e083ef5a844`
   - R6-R4-R5 result=`2450f706cd1ac7602f632f1e85b4019d6a9963ef`
   - R6-R4-R4 result=`f2d1024e316e096385bf1645af74788bd1554ce4`
   - R6-R4-R3 result=`3a856692e3a2eeb7c7068c28debef20f0c88b319`
   - R6-R4-R2 result=`03720d5499fca33f837abedd79871c740a0906bf`
   - R6-R4-R1 result=`06abaa8b4efcd717e35f5b2981bf098be4e8358f`
   - R6-R3 result=`33613af1985b340c01b984cb6109b19ba6932ab9`
   - R6-R2 result=`6c96210e66f11f0618032503f8873ca9ed9812b4`
   - R6-R1 result=`b47be1a5c33c7499e14678a0dc842e6d8dc5cf09`

只允许从这些对象中提取与以下六类输入直接有关的 source/path/hash/version/manifest/identity：Android SDK、JDK、Git、Pub cache、Gradle cache、fixed module。

不得沿引用链继续读取新的 blob/path；如以上对象仍不足，停止，不补授权。

## 3. 永久边界与明确禁止

继续保持：README budget exhausted；FD02 excluded；无 repo/dir-wide enumeration/search；不访问旧仓库；不检查/修改 protected staged/index state；Backend 0/10、DB 0/8、PUI deferred、PUI-PREREQ-12=0；D-02 durable UNKNOWN、U-14 exclusion、U-12 exact-scope、TP-SOURCE-CLASS-01、TP-TARGET-01；legal/Safety/no-processing；LC-03/LC-04/Phase36/产品实现未授权。

明确禁止：

- 搜索宿主磁盘、盘符、Program Files、用户目录或环境变量来猜 source；
- repo-wide/file-name/code search；
- 网络访问、下载或补包；
- 新建第二个 Sandbox；
- stop/close/reset/kill 任何 Sandbox；
- Flutter-tools Dart pub；
- `flutter pub get`；
- coverage/code_builder 诊断；
- M3；
- AAR probe；
- M2；
- 写宿主 SDK/cache/source；
- 修改 Sandbox Flutter source/pubspec/snapshot/package context。

## 4. Fresh Sandbox continuation gate

先 fresh：

`wsb --version`

`wsb list --raw`

要求 running Sandbox 恰好一个且 ID 精确为：

`0087a898-5221-41df-a33d-65045ffea69a`

若为 0：

`STOP — A1_SANDBOX_NO_LONGER_RUNNING`

若出现其它或多个 running Sandbox：

`STOP — A1_SANDBOX_NOT_UNIQUELY_AVAILABLE`

不得创建新的 Sandbox，不得控制其它 Sandbox。

## 5. A1 substrate preservation check

只对 A1 已建立对象做最小复核：

- SYSTEM guest；
- PS5.1；
- process/effective RemoteSigned；
- Security/system PATH；
- active adapter=0；
- default route=0；
- `C:/M3A/tools/flutter` 存在；
- Dart SHA=`44328B98B6BF981D8307F72EF38ACBB37B8067394916953CAA48B8B444525152`；
- flutter_tools pubspec SHA=`6E31FF00AC4441294B60F20A71DCE2777CC80EB33663E6621DAE38C2391DB0EA`；
- snapshot SHA=`E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`；
- task-owned transport/evidence manifest 可达。

任一失败：`STOP — A1_ESTABLISHED_SUBSTRATE_NOT_PRESERVED`。

不因此重做 Flutter materialization。

## 6. Historical fixed-input recovery table

对六类对象逐项建立表格：

| class | historical exact source/path evidence | accepted identity evidence | sufficient? |
|---|---|---|---|
| Android SDK | | | |
| JDK | | | |
| Git | | | |
| Pub cache | | | |
| Gradle cache | | | |
| fixed module | | | |

规则：

- guest-old path（例如 `C:/M3R4/...`）本身不等于当前 host source path；
- 历史“存在”不等于当前 host source 仍存在；
- 只有 exact historical object 明确绑定的宿主 source/path/identity 才可进入 host existence/hash check；
- 若只证明 identity 但未证明 host source path，保持不足；
- 若只证明 host path 但没有足够 identity 绑定，保持不足；
- 不允许通过 PATH、registry、where、Get-Command、env、磁盘搜索来反推宿主 source。

若六类中任一不足：

`FIXED_INPUT_SOURCE_AUTHORITY_NOT_RECOVERED`

停止，不进入 materialization。

## 7. 仅在六类 source authority 全部恢复后：host bounded verification

只访问恢复出的六个 exact host source roots/objects；不得扩大。

允许：

- `Test-Path` exact source；
- 对历史已绑定的关键 executable/archive/manifest 做 exact SHA-256/version；
- 对目录型 SDK/cache 仅做历史定义的 bounded identity，不做全目录 hash/enumeration；
- 对 fixed module 使用历史冻结 manifest/count/bytes/reparse 或已绑定 ZIP identity；
- 所有 host source 只读。

任何 exact source 不存在或 identity mismatch：

`STOP — HISTORICAL_FIXED_INPUT_SOURCE_CURRENTLY_NOT_MATCHED`

不得寻找替代安装。

## 8. Remaining A materialization

仅在 §7 全部通过后，materialize 到 fresh A1 guest-local task-owned paths，例如：

- Android: `C:/M3A/tools/android`
- JDK: `C:/M3A/tools/jdk`
- Git: `C:/M3A/tools/git`
- Pub cache: `C:/M3A/cache/pub`
- Gradle cache: `C:/M3A/cache/gradle`
- module: `C:/M3A/work/apps/flutter_elitesync_module`

实际路径可不同，但必须记录 exact path 并保持 guest-local。

要求：

- 不写 host source/cache；
- Git `--version` only；
- Java `-version` only；
- Android 只做 bounded identity/existence，不运行 sdkmanager/build；
- Pub/Gradle cache 只做 root/materialization identity，不枚举 package names、不做 resolution；
- module 必须匹配历史 fixed identity（527 files / 301 dirs / 3234145 bytes / reparse=0 / manifest `6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`，若该 identity 由允许的 historical blobs 确认）。

## 9. 成功条件

只有以下全部成立时，A 才首次完成：

- A1 Sandbox 仍唯一运行；
- A1 substrate preserved；
- Flutter preserved；
- Android SDK established；
- JDK established；
- Git established；
- Pub cache established；
- Gradle cache established；
- fixed module established；
- evidence manifest 更新并绑定全部 fixed inputs；
- no network；
- no host SDK/cache writes；
- no B / Flutter-tools pub / coverage/code_builder / M3 / AAR probe / M2。

成功结论精确为：

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

即使成功，也不得在同一任务执行 B。

## 10. 结果 artifact 与停止

创建且仅创建新的 bounded A2 result 文档；可在任务明确需要时对 CURRENT_CONTEXT 做最小状态更新，否则不改。

候选分支应从本 task commit 创建；结果 candidate sole parent 必须是本 task commit。

执行者不得自我接受，不更新 main。

结束时记录：

- fresh main/task identity；
- WSB initial/final raw；
- Sandbox ID；
- historical blobs actually read；
- 六类 source recovery table；
- host exact verification；
- guest materialization paths/identity；
- final classification；
- 明确 NOT_RUN 列表。

到达首个停止条件即结束。
