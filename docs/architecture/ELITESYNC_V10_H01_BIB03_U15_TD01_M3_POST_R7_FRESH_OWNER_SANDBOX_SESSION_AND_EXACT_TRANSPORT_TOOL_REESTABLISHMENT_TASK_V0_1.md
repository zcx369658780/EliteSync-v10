# EliteSync v10｜H01-BIB03-U15-TD01 M3 Post-R7 Fresh Owner Sandbox Session + Exact Transport/Tool Re-establishment Task v0.1

Status: `PUBLISHED TASK SHEET — OWNER ACTIVATION REQUIRED — SESSION/TRANSPORT/TOOLS ONLY — NO FLUTTER-TOOLS PUB — NO M3 — NO AAR PROBE — NO M2`

日期：2026-09-10（Asia/Singapore）。

## 1. Authority、角色与唯一目标

仓库：`zcx369658780/EliteSync-v10`。

本任务发布基线必须为：

`16e78e668db360a2313db068aa19e7c5ec59800d`

该 accepted main 的 exact tree：

`a8641905221ab52f653640cc1b04f8aeef453e71`

任务作者仅发布本任务；执行者不得把任务分支当作 main authority，不得自行接受自己的执行候选。

本任务的唯一实质目标是：在 R7 已接受的 `EXPECTED_OWNER_SANDBOX_SESSION_NOT_AVAILABLE` 之后，由 Owner 明确激活一次新的、fresh Windows Sandbox session，并重新建立后续 R7 continuation 所需的 **task-owned evidence transport、System guest、PowerShell/ExecutionPolicy/PATH/network-isolation evidence，以及 Flutter / Android SDK / JDK / Git / Pub cache / Gradle cache / fixed module copy 的精确可用输入**。

本任务是 **A 任务**。它只重建 execution substrate，不恢复 R7 的 Flutter-tools offline context，不运行任何 M3 build，也不做 M2。

`SESSION RE-ESTABLISHMENT != R7 CONTINUATION`

`TOOL INPUT ESTABLISHED != FLUTTER-TOOLS CONTEXT ESTABLISHED`

`NO ACTIVE ADAPTER / NO DEFAULT ROUTE EVIDENCE != GENERAL NETWORK IMPOSSIBILITY CLAIM`

`TASK SUCCESS != M3 SUCCESS`

## 2. 必须首先读取的精确文档

执行开始后，按以下顺序进行，禁止用仓库/目录枚举替代：

1. fresh-fetch remote `main`，必须确认仍为 `16e78e668db360a2313db068aa19e7c5ec59800d`；若变化，立即 `STOP — MAIN AUTHORITY CHANGED`，只报告新 SHA，不继续本任务。
2. FIRST 读取：
   `docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
   固定 blob：`18485c95262051e43892436fb52413132c5ee626`。
3. 读取本任务文件。
4. 为恢复 R7 所需精确工具/路径上下文，只允许按需读取以下已知精确对象；不得扩大为目录搜索：
   - `docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`
   - `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_EXECUTION_TASK_V0_8_R6_R4_R7.md`
   - `docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_DIRECT_FLUTTER_TOOLS_SNAPSHOT_AND_EXECUTION_RESULT_V0_8_R6_R4_R6.md`
   - 若且仅若上述对象明确引用一个为恢复固定工具 source/path/hash 所必需的**精确路径**，可读取该单一精确引用；每次引用必须记录“为何必要”。不得沿链递归展开。

若精确历史文档不足以确定某个工具输入，不得猜路径、不得搜索宿主磁盘；对该输入记录 `REESTABLISHMENT_INPUT_NOT_PROVEN`，并按 §10 停止依赖该输入的后续步骤。

## 3. 永久边界与本任务明确非授权

继续保持：

- README documentary budget exhausted；
- FD02 永久排除；
- 不进行 repo-wide / directory-wide enumeration、filename search、code search、recursive discovery；
- 不访问旧 `D:\EliteSync` 或 `zcx369658780/EliteSync`；
- 不检查、修改、unstage、reset、clean、覆盖、提交、总结或使用无关 protected staged/index state；
- 不运行默认 `git status`，不以整仓 clean 作为本任务条件；
- D-02=`D02-DURABLE-UNKNOWN-01`；U-14 exclusion；U-12 exact-scope target；`TP-SOURCE-CLASS-01`、`TP-TARGET-01` 保持；
- Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`；DB `0/8`；PUI deferred；`PUI-PREREQ-12=0`；
- accepted legal / Safety / no-processing 边界保持；LC-03 / LC-04 / Phase36 未授权；产品实现未授权；
- v9 仅是 legacy functional evidence，不是 v10 architecture authority；默认不访问旧仓库；
- 不自动调用辅助 agents；模型选择不构成 authority。

本任务**明确禁止**：

- 任何互联网访问、联网安装、在线补包、`pub.dev` / GitHub / Maven / Gradle online resolution；
- 运行 `flutter pub get`；
- 在 `packages/flutter_tools` 运行任何 Dart pub；
- 读取/诊断 `coverage-*` 或 `code_builder-*` package availability；该工作保留给 B 任务；
- 运行 `flutter build aar`、direct `flutter_tools.snapshot build aar`、任何 M3；
- exact AAR probe；
- M2 / Android host Gradle targeted resolution；
- 修改宿主 Flutter SDK、Android SDK、JDK、Git、Pub cache、Gradle cache 或 module source；
- 修改 Sandbox Flutter SDK 副本中的 `.dart` / `.yaml` 源码、snapshot 或 package context；
- stop / close / reset / kill 任何既有 Sandbox；
- 把旧 Sandbox ID `68ece109-c661-420c-9899-02b1e9518036` 当作存在性证据；
- 假定旧 guest `C:/M3R4/**` 仍存在。

本任务仅授权在 fresh Sandbox 内建立新的 task-owned 副本/路径，以及在宿主**仓库之外**建立本任务自己的临时 evidence transport。不得向宿主 SDK/cache/source 写入。

## 4. Owner activation 与 Windows Sandbox 创建门

执行者必须在启动报告中明确记录：

`OWNER ACTIVATION = PRESENT FOR ONE FRESH SANDBOX CREATION UNDER THIS TASK`

然后严格执行：

1. fresh `wsb --version`；记录完整版本输出与 exit code。
2. fresh `wsb list --raw`；保存原始输出与 exit code。
3. 若发现任意 running Sandbox：
   - 不进入、不停止、不关闭、不重置、不 kill；
   - 不猜哪个是 Owner session；
   - 立即 `STOP — PREEXISTING_RUNNING_SANDBOX_PRESENT`。
4. 只有 initial list 明确为 `0 running Sandbox` 时，才允许创建**恰好一个** fresh Windows Sandbox。
5. 创建后再次用 `wsb list --raw` 精确记录新 session，并绑定本任务唯一 Sandbox ID。
6. 若无法唯一确定新 ID：`STOP — FRESH_SANDBOX_ID_NOT_UNIQUELY_BOUND`。
7. 本任务不授权创建第二个 Sandbox，也不授权 stop/close/reset/kill；若 fresh session 后续失败，保留该 session 并报告 ID 与失败点。

必须证明：

`NEW_SANDBOX_ID != 68ece109-c661-420c-9899-02b1e9518036`

但不得仅凭不同 ID 推断任何旧 guest 状态已恢复。

## 5. Task-owned evidence transport

在宿主创建一个**仓库外**、本任务独占的临时 transport root；优先使用宿主 `$env:TEMP` 下带随机 nonce 的目录，例如：

`$env:TEMP\EliteSync-v10-M3A-<nonce>`

要求：

- 路径必须不位于 `D:\EliteSync-v10` 仓库内；
- 只保存本任务 controller/helper、输入材料化副本（若必要）、guest 输出和 evidence；
- 不把宿主 SDK/cache 本身变成 writable share；
- 不修改任何源 SDK/cache；
- transport nonce、host path、guest-visible mapping/path 全部记录；
- transport 必须绑定本任务 fresh Sandbox ID；
- 不复用旧 R4/R7 share 名称或旧 guest path 作为存在性假设。

如果 CLI/宿主能力无法建立新的 task-owned writable evidence transport：

`STOP — FRESH_TASK_OWNED_EVIDENCE_TRANSPORT_NOT_ESTABLISHED`

不得退回旧 share、旧 Sandbox 或仓库目录充当 transport。

## 6. Guest identity 与安全前置证据

在 fresh Sandbox 中建立一次 task-owned guest execution channel，并证明以下条件；每项均记录命令、stdout/stderr、exit code 与关键值：

1. guest principal / effective identity = `NT AUTHORITY\SYSTEM`（run-as System）。
2. PowerShell = Windows PowerShell 5.1；记录 `$PSVersionTable.PSVersion`。
3. Process scope 与 effective execution policy 均为 `RemoteSigned`；只允许设置**guest process/session**所需范围，不得改宿主策略。
4. guest effective `PATH` 必须使用 Security/system Path 基线，再做本任务必要的进程级 tool path prepend；不得修改宿主系统 Path。
5. active network adapter count = `0`。
6. default route count = `0`。

网络证据只允许通过本地系统状态检查完成，不得通过访问互联网、DNS 名称、socket 探测第三方服务来“证明离线”。

若 active adapter 或 default route 任一不为 0：

`STOP — SANDBOX_NETWORK_ISOLATION_PRECONDITION_NOT_MET`

不得自行禁用网卡、删除路由或修改宿主/guest 网络配置来修复。

## 7. 精确工具与固定输入的重新建立

旧 guest `C:/M3R4/**` 已不存在，不得复用其存在性断言。本任务必须在 fresh Sandbox 下建立新的 task-owned root，例如：

`C:\M3A\`

实际路径可以不同，但必须是**新 session 内新的、明确记录的固定路径**。

需要重新建立并验证以下九类对象：

1. Flutter SDK 副本；
2. Android SDK 副本/可用固定输入；
3. JDK 副本/可用固定输入；
4. Git 副本/可用固定输入；
5. Pub cache 副本/固定只读来源对应的 guest-local 可用输入；
6. Gradle cache 副本/固定只读来源对应的 guest-local 可用输入；
7. fixed Flutter module copy；
8. task-owned controller/helper；
9. 与上述对象绑定的 evidence manifest。

对每个对象都必须记录：

- host source exact path（若有）；
- host source 的已接受 identity/hash 依据来自哪个精确文档/记录；
- guest destination exact path；
- materialization/copy 方式；
- 可用于后续任务稳定定位的关键文件 exact path；
- 对关键 executable / snapshot / manifest / module archive 或其它固定 identity object 的 SHA-256；
- 工具 version/identity 输出（Flutter、Dart、Java、Git、Android/Gradle 仅做**不会触发网络/解析/build**的 bounded identity check）。

禁止为了“算整个 SDK hash”递归枚举整棵目录。目录型 SDK/cache 的 identity 应使用已接受固定 source identity + bounded 关键文件 hash/version + materialization evidence，而不是 repo/host-wide traversal。

### 7.1 Flutter

至少证明并记录：

- Flutter root；
- bundled Dart executable exact path + SHA-256 + version；
- `packages/flutter_tools/pubspec.yaml` exact path + SHA-256（**本任务不解析 coverage/code_builder 条目**）；
- `bin/cache/flutter_tools.snapshot` exact path + SHA-256；
- Flutter SDK 副本 writable，但本任务不得改其中 package context/source/snapshot。

### 7.2 Android SDK / JDK / Git

只做 bounded identity/availability：

- Android SDK root 及后续 Flutter build 所需已知固定 tool root；不得运行 build、dependency resolution 或在线 sdkmanager。
- JDK `java.exe` exact path + SHA-256 + `java -version`。
- Git `git.exe` exact path + SHA-256 + `git --version`；不得 fetch/pull/ls-remote。

### 7.3 Pub / Gradle caches

本任务只建立 cache root 与 transport/materialization identity：

- 记录 Pub cache guest root；
- 记录 Gradle cache guest root；
- 证明两者来自固定 host source 的只读读取/materialization，不写宿主 cache；
- 不枚举 package names；
- 不检查 `coverage-*`、`code_builder-*`；
- 不执行 pub/gradle resolution。

### 7.4 Fixed module copy

重新建立 fresh guest module copy，并记录：

- module source identity 的精确历史依据；
- guest module root；
- task-owned module copy/materialization hash/manifest；
- 关键 `pubspec.yaml` exact path + SHA-256；
- 不运行 module pub；
- 不生成/检查 `.android`；
- 不 build。

若任何工具/source 只能通过修改宿主 SDK/cache 才能建立：

`STOP — HOST_TOOL_OR_CACHE_WRITE_REQUIRED`

不得执行该写入。

## 8. 最小验证，不跨入 B 任务

A 任务的验证终点只包括：

- WSB version 已记录；
- initial list = 0；
- 恰好一个 fresh Sandbox 已创建并唯一绑定；
- new task-owned evidence transport 已建立；
- SYSTEM / PS5.1 / RemoteSigned / Security Path 已证明；
- active adapter=0、default route=0；
- Flutter / Android / JDK / Git / Pub cache / Gradle cache / module copy 均有新的 guest exact path 和 identity evidence；
- Flutter-tools snapshot SHA 已记录但未修改；
- 没有运行 Flutter-tools pub；
- 没有运行 M3；
- 没有 AAR probe；
- 没有运行 M2；
- 没有联网；
- 没有写宿主 SDK/cache；
- 没有访问原仓库 index/staged state。

允许使用的最终成功分类仅为：

`POST-R7 OWNER SANDBOX SESSION + EXACT TRANSPORT/TOOL RE-ESTABLISHMENT ESTABLISHED — READY FOR FRESH REVIEW BEFORE R7 CONTINUATION TASK`

该分类**不**授权执行 R7 continuation；必须先形成 result candidate 并由独立 fresh review 接受。

## 9. 执行产物与 candidate

执行成功或硬停止后，执行者必须在**新的执行 candidate branch**上仅提交必要文档产物，不修改本 task branch 内容。

允许新增：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_POST_R7_FRESH_OWNER_SANDBOX_SESSION_AND_EXACT_TRANSPORT_TOOL_REESTABLISHMENT_RESULT_V0_1.md`

并允许在必要时对：

`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

做**最小状态更新**，仅反映本任务新证据；不得重写产品/法律/Safety/路线语义，不得把 B/M3/M2 标成已授权。

result 必须包含：

- task commit 与 sole-parent 基线；
- fresh main verification；
- FIRST blob verification；
- Owner activation 记录；
- initial/final WSB raw state；
- fresh Sandbox ID；
- evidence transport host/guest paths + nonce；
- SYSTEM/PS/ExecutionPolicy/PATH/network evidence；
- 九类 fixed inputs 的 path/hash/identity 表；
- 每条实际执行命令及 exit code 的可审计摘要；
- 所有 STOP 分类（如有）；
- 明确的 NOT_RUN / NOT_CHECKED：Flutter-tools pub、coverage/code_builder cache diagnostic、M3、AAR probe、M2；
- 宿主 SDK/cache write count = 0 的任务范围证据；
- repo index/staged inspection = NOT_PERFORMED；
- 最终 classification。

candidate 作者不得自行创建 acceptance，不得更新 main。

## 10. 硬停止条件

出现以下任一条件，停止依赖步骤并提交 bounded result；不得绕过：

- `MAIN AUTHORITY CHANGED`
- FIRST blob mismatch / unavailable
- preexisting running Sandbox present
- fresh Sandbox creation fails
- fresh Sandbox ID not uniquely bound
- fresh task-owned evidence transport not established
- guest SYSTEM identity not established
- PS 5.1 not established
- effective RemoteSigned not established
- active adapter != 0
- default route != 0
- required fixed input exact source/path/identity not proven
- host SDK/cache write would be required
- any unauthorized network attempt is observed
- any command would cross into Flutter-tools pub / M3 / AAR probe / M2

对于某个单独工具 input 缺失，允许完成与其无依赖的证据收集，但不得宣称 A 成功；最终应分类为最具体的 `..._NOT_ESTABLISHED` / `..._NOT_PROVEN`。

不得把 DNS/socket error 自动分类为 cache miss，也不得通过联网尝试来验证缓存。

## 11. Fresh review / acceptance 要求

本任务执行 candidate 完成后必须停止，由**独立新会话**执行 fresh review。

若 candidate 合规，后续 acceptance 必须完整保留现行 GitHub acceptance-tree 防回退流程：

1. fresh-fetch candidate exact tree；
2. create acceptance，sole parent=candidate，tree=EXACT candidate tree；
3. 在更新 main 前立即 fresh-fetch acceptance；
4. 验证 acceptance sole parent 与 exact candidate tree；
5. fresh-fetch main，确认仍为预期旧 authority；
6. `update_ref main`，`force=false`；
7. final fetch main ref AND main commit；
8. 验证最终 main SHA=acceptance 且 tree=candidate exact tree。

绝不能凭历史 tree 假设创建 acceptance。

A fresh acceptance 完成后，才允许由 ChatGPT 发布独立 **B：R7 continuation** task，范围限定为 exact Flutter-tools pubspec确认、`coverage-*`/`code_builder-*` 有界 cache diagnosis、Sandbox Flutter-tools direct Dart offline context、snapshot不变证明、唯一一次 direct-snapshot M3 与一次 exact AAR probe。M2 仍不得与 B 同任务执行。

## 12. 任务终点

执行者在以下任一时刻必须停止并返回：

- A 成功 classification 已形成并 candidate 已提交；或
- 任一硬停止 classification 已形成并 bounded result 已提交。

不得自行继续 B、M3、AAR、M2、产品实现、Docker、Android 模拟器/真机或后端联调。

`A TASK END = EXECUTION SUBSTRATE EVIDENCE ONLY`