# EliteSync v10｜M3 R6-R4-R7 执行中｜当前会话交接 v0.1

Status: `CURRENT SESSION HANDOFF — R7 IN FLIGHT — DO NOT TREAT HANDOFF BRANCH AS MAIN AUTHORITY`

日期：2026-09-10（Asia/Singapore）。

## 1. 交接目的与权威规则

本文件用于在当前长会话结束前固化连续性信息。它不是新的产品、法律、Safety、架构或实现授权，也不替代 GitHub `main`、已发布 task sheet、候选结果或 Owner 明确授权。

本 handoff 所在分支仅为文档连续性载体：

`handoff/current-session-r7-in-flight-v0-1`

该分支从当前已接受 `main`：

`a41158c93c134d8f53db11c90c2f5461ba0523d1`

分出。**不得因为读取本 handoff 就把该 handoff branch 当作 repository authority。** 下一会话必须 fresh-fetch GitHub `main`，并根据 Owner 提供的 R7 执行结果先完成 R7 fresh independent review / ACCEPT or REJECT。

FIRST 文档继续为：

`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`

固定 blob：

`18485c95262051e43892436fb52413132c5ee626`

README documentary read budget 已耗尽；FD02 永久排除；不得默认做 repo/directory-wide enumeration/search。

## 2. 当前已接受 main 与接受树防回退规则

当前已接受 `main`：

`a41158c93c134d8f53db11c90c2f5461ba0523d1`

该接受提交对应 R6-R4-R6 结果，精确 tree：

`e846e3413a6a336dc84665c06df6e8ea65fb2d60`

R6-R4-R6 candidate：

`8abf79cc7800a73d425b7ea6664773a084422f7e`

R6-R4-R6 result blob：

`56d530e1010db57bfa2dabb27f337e083ef5a844`

R6-R4-R6 CURRENT_CONTEXT blob：

`d25c5d86bdb1aafed4c48e1283f2337a454e2088`

### Mandatory acceptance-tree safeguard

该项目历史上发生过 acceptance commit 使用错误旧 tree、导致 main 内容回退的事故，因此每次接受候选都必须执行完整防回退流程：

1. fresh-fetch candidate commit metadata。
2. 记录 candidate exact tree SHA。
3. create acceptance commit：`parent=candidate`，`tree=EXACT candidate tree`。
4. **立即 fetch acceptance commit**，在更新 main 前验证：
   - sole parent = candidate；
   - acceptance tree = candidate exact tree。
5. fresh-fetch current main，必须仍等于预期旧 authority。
6. `update_ref(main, acceptance, force=false)`。
7. 再 fetch final main ref 和 final main commit，验证：
   - final main SHA = acceptance；
   - final main tree = candidate exact tree。

不得省略第 4 步，也不得依据旧 tree、父提交 tree 或记忆推测 candidate tree。

## 3. 当前永久边界与不可变约束

以下边界跨会话继续有效，除非 Owner 后续明确改变：

- 不接触、检查、unstage、reset、clean、commit、引用或利用无关受保护 staged/index state。
- README documentary read budget exhausted。
- FD02 permanently excluded。
- 不做 repo/directory-wide enumeration/search，除非精确 task 另行授权。
- 保留 D-02 unresolved / `D02-DURABLE-UNKNOWN-01`。
- 保留 U-14 exclusion。
- 保留 U-12 exact-scope target rules。
- 保留 `TP-SOURCE-CLASS-01`、`TP-TARGET-01`。
- Backend `0/10 NOT INSPECTED / NOT AUTHORIZED`。
- Database `0/8 NOT INSPECTED / NOT AUTHORIZED`。
- PUI deferred，`PUI-PREREQ-12=0`。
- 已接受法律 / Safety / no-processing 边界不重开。
- LC-03、LC-04、Phase 36 未授权。
- 产品实现未因当前技术任务自动获得授权。
- 法律问题当前不是关键路径。
- v9 legacy 仅是 functional engineering evidence，不是 v10 architecture authority；默认不访问旧 repo。
- 不因模型选择自动增加治理或授权。
- Owner 现有 Windows Sandbox 不得 stop / close / reset / kill，除非 Owner 单独明确授权。
- M2 仍 deferred；只有 exact AAR 成立并通过 fresh review 后才发布 targeted Gradle host-resolution task。

## 4. M3 当前技术路线与已闭合问题

### 4.1 固定 M3 方法

选定 M3 方法族仍是 Flutter module release-only AAR：

`flutter build aar --no-debug --no-profile`

当前连续任务中为了避免 Flutter wrapper / bootstrap 网络行为，已逐步验证 direct Dart / direct snapshot 路径；这些是 M3 诊断与执行方式，不改变产品架构。

`M3 success != M2 success`。

M3 失败不自动否定 Android 集成架构；M3 exit0 也不等于 exact AAR proof。

### 4.2 已接受的宿主与 Sandbox 事实

当前 Owner Sandbox 固定 ID：

`68ece109-c661-420c-9899-02b1e9518036`

WSB CLI：

`0.8.107.0`

已反复建立：

- Windows PowerShell 5.1；
- Process/effective `RemoteSigned`；
- Security module system path PASS；
- 活动网卡 0；
- 默认路由 0；
- Owner Sandbox 生命周期始终由 Owner 控制；
- 未新建/stop/close/reset/kill。

R4 已复制并持续复用的 guest 工具/cache：

- Flutter：`C:/M3R4/t/f/bin/flutter.bat`
- Flutter root：`C:/M3R4/t/f`
- Dart：`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe`
- Android SDK：`C:/M3R4/t/a`
- JDK：`C:/M3R4/t/j`
- Git：`C:/M3R4/t/g/cmd/git.exe`
- Pub cache：`C:/M3R4/p`
- Gradle home：`C:/M3R4/h`
- Gradle caches：`C:/M3R4/h/caches`
- wrapper dists：`C:/M3R4/h/wrapper/dists`

系统 PowerShell exact path：

`C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe`

其 PATH 解析问题已闭合；当前只在 task controller/child processes 临时设置 PATH，不持久修改系统。

### 4.3 固定 module 来源与 cwd 已闭合

通过 task-owned Git object fetch，已从修复后 main 精确物化 module tree：

`e369db9c603838182d29ae501a77f1afe56b6086`

宿主 materialization 已接受统计：

- files = 527
- directories = 301
- bytes = 3,234,145
- reparse = 0

legacy manifest SHA-256：

`6D4EAE63074EAF59BDE32F1C09446F3E996C4E02DAEB7BBBBBD1C9B5DB3798EB`

current-view TSV：

- size = 69,676
- SHA-256 = `4F869B12B5F466E35326966272F13BEA6EBABC69A631200E26F8F8E3D382DD2E`

固定 guest module cwd 已建立：

`C:/M3R6R4R2/w/apps/flutter_elitesync_module`

其 module copy/current-view 已经通过，后续任务不得无故重做来源定位或模块搜索。

### 4.4 已闭合的 dispatch / bridge / PATH 问题

已接受 dispatch SHA-256：

`2C0ACFEE0795B891A9331DFF97703D862052E3C7FFCAF3CF135D70063C4D8846`

copy SHA-256：

`C5386290A1ADF6BCA5BF3A41CD75963BEFD336061BC397A8D74580421E01BADC`

已接受：

- ordinary native smoke PASS；
- batch pub/M3 shape PASS；
- exit37 原样传播；
- R4 existing writable evidence bridge 可用；
- direct directory bridge/current-view 可观测性已闭合；
- guest PowerShell PATH exact resolution 已闭合。

这些门不应在下一任务里重复成为主工作量，除非 fresh preflight 发现实际状态改变。

## 5. R6-R4-R2 → R6-R4-R6 的关键技术证据链

### R6-R4-R2

真实 `flutter pub get --offline` 首次达到 Flutter 入口，但 guest PATH 无 PowerShell，失败：

`OFFLINE_PUB_POWERSHELL_EXECUTABLE_NOT_FOUND_IN_GUEST_PATH`

之后已通过 process-local PATH 修复闭合。

### R6-R4-R3

PATH 门 PASS 后，`flutter pub get --offline` 真实运行；Flutter tool 先执行：

`git fetch --tags` → GitHub

并访问 pub.dev。最终：

`OFFLINE_PUB_FLUTTER_TOOL_NETWORK_ATTEMPT_BLOCKED`

结论：不是 PATH，也不能推断为 project cache miss。

### R6-R4-R4

加入全局：

`--no-version-check`

后 GitHub `fetch --tags` 消失，但 `flutter --no-version-check pub get --offline` 仍访问 pub.dev 查 `code_builder`。

最终：

`OFFLINE_PUB_NETWORK_ATTEMPT_PERSISTS_AFTER_NO_VERSION_CHECK`

### R6-R4-R5 — 当前最重要突破

直接使用 Flutter SDK 内置 Dart：

`C:/M3R4/t/f/bin/cache/dart-sdk/bin/dart.exe pub get --offline`

在 module cwd 运行：

- exit = 0
- duration ≈ 2.044s
- stderr empty
- stdout contains `Got dependencies!`
- 无 URL / socket / DNS / network attempt

Dart identity：

`3.11.5 stable windows_x64`

这已经证明：**EliteSync module 自己的 Dart dependency graph 可以在固定 Pub cache 下完全离线解析。**

随后 M3：

`flutter.bat --no-version-check build aar --no-debug --no-profile --no-pub`

仍访问 pub.dev 查 `coverage`，exit69，AAR exact NON-HIT。

### R6-R4-R6

为了排除 `flutter.bat/shared.bat` bootstrap，直接运行：

`dart.exe --packages=<flutter_tools package_config> flutter_tools.snapshot --no-version-check build aar --no-debug --no-profile --no-pub`

身份绑定：

- `flutter_tools.snapshot` Length = 43,747,920
- snapshot SHA-256 = `E494C265BA9C38A6A5679842703D3041DF0D2D86C83BFC55DF56C3BD0DF8E808`
- Flutter-tools package_config Length = 21,503
- package_config SHA-256 = `354D6C66AB147E9DD5C65ADD67A34252739723FBF9084A6541F099CC0D584BB7`

结果：

- process_started = true
- exit = 69
- 首个诊断仍为：`Got socket error trying to find package coverage at https://pub.dev.`
- exact AAR NON-HIT / probe=1

结论：**剩余网络尝试不在 Windows wrapper bootstrap；它发生在 Flutter tool / build path 自身。**

Flutter 当前公开 `packages/flutter_tools/pubspec.yaml` 固定：

- `coverage: 1.15.1`
- `code_builder: 4.11.1`

## 6. 当前正在执行的 R6-R4-R7

R7 task branch：

`task/h01-bib03-u15-td01-m3-flutter-tools-offline-context-v0-8-r6-r4-r7`

Task commit：

`0a88b97502931c50ae2f22c0a1a9d07f6ae3e635`

Task blob：

`5d89617efb19b6ed873213e99aba02961126598c`

Task path：

`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_EXECUTION_TASK_V0_8_R6_R4_R7.md`

Task sole parent：

`a41158c93c134d8f53db11c90c2f5461ba0523d1`

Task compare：ahead=1 / behind=0，且只新增 task 文件。

### R7 目的

先确认固定 guest Pub cache 是否包含：

- `coverage-1.15.1`
- `code_builder-4.11.1`

如果 `coverage-1.15.1` 不存在：

`FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS`

不联网、不补包。

如果存在，则仅在 **Sandbox 内 R4 Flutter SDK 副本**：

`C:/M3R4/t/f/packages/flutter_tools`

执行一次：

`dart.exe pub get --offline`

只允许写 Sandbox 内 Flutter-tools / workspace 正常 pub 元数据；禁止修改 `.dart/.yaml` 源码、snapshot、Dart SDK、Flutter binaries、宿主 `D:/flutter`、宿主 Pub cache。

成功后必须：

- Flutter-tools package_config 中 `coverage` 指向本地 `C:/M3R4/p/hosted/pub.dev/coverage-1.15.1`；
- snapshot SHA 与写前完全一致；
- 然后才允许唯一一次 direct-snapshot M3。

R7 candidate branch 固定：

`review/h01-bib03-u15-td01-m3-flutter-tools-offline-context-v0-8-r6-r4-r7`

候选须一个 commit、sole parent = R7 task commit，恰好两个路径：

1. 新增：
`docs/architecture/ELITESYNC_V10_H01_BIB03_U15_TD01_M3_FLUTTER_TOOLS_OFFLINE_CONTEXT_AND_EXECUTION_RESULT_V0_8_R6_R4_R7.md`

2. 更新：
`docs/architecture/ELITESYNC_V10_CURRENT_CONTEXT_V0_1.md`

CURRENT_CONTEXT 只允许更新页首、§1、§4、§5；§2/§3/§6/§7逐字保留；UTF-8、无 mojibake。

## 7. 下一会话第一动作：R7 fresh independent review

Owner 下一次提供 R7 执行结果后，下一会话必须先：

1. fresh-fetch GitHub main；初始预期为 `a41158c93c134d8f53db11c90c2f5461ba0523d1`，但若当前会话在交接前已完成 R7 验收，则以 Owner 提供的新 accepted main 为准。
2. 验证 main commit exact tree；不要只看 ref。
3. 验证 R7 task commit：
   - `0a88b97502931c50ae2f22c0a1a9d07f6ae3e635`
   - task blob `5d89617efb19b6ed873213e99aba02961126598c`
   - sole parent = `a41158c...`
   - ahead=1/behind=0，仅 task 文件。
4. 若 candidate 存在：
   - fresh-fetch candidate commit；
   - sole parent 必须为 R7 task；
   - compare ahead=1/behind=0；
   - 恰好 result + CURRENT_CONTEXT；
   - fetch exact candidate tree；
   - fetch result / context blobs；
   - 验证 context 只改允许章节、UTF-8/no mojibake。
5. 核验实际执行证据是否严格符合 R7 task：
   - coverage/code_builder 固定版本和 cache 有界过滤；
   - coverage exact cache miss 则不得运行 pub/M3；
   - 若 cache hit，则 Flutter-tools direct Dart offline pub 仅一次；
   - 不得联网；
   - 仅允许 guest Flutter SDK pub 元数据写入；
   - snapshot SHA 写前/写后不变；
   - 只有 pub PASS + coverage context established 后才 M3；
   - M3 仅一次；
   - AAR 仅 exact path probe；
   - M2 never runs；
   - Owner Sandbox 不被 stop/close/reset/kill。
6. 若 compliant，严格执行 acceptance-tree safeguard 后更新 main。

## 8. R7 后的技术分支决策

### A. `FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS`

含义：module 自身 offline graph 已 PASS，但 Flutter-tools 自己固定依赖 `coverage=1.15.1` 不在当前 frozen cache。

下一任务应该是**窄范围 tool-cache provenance / authorized acquisition 设计**，而不是重新折腾 module pub、PATH 或 Sandbox。

不得自动开放 guest 网络；是否允许 task-owned、宿主受控的一次 package acquisition 需要新的 Owner 授权与明确证据边界。

### B. Flutter-tools direct Dart offline pub exact cache miss（其他 package）

下一任务只针对首个精确 package/version/constraint；不要枚举全 cache 或批量补包。

### C. Flutter-tools direct Dart offline pub PASS，但 M3 仍 `coverage + pub.dev`

这将说明 package context 已建立但 M3 内部仍存在另一个触发路径。下一步应做 Flutter tool / Gradle 子进程 provenance 诊断，不再修改 package context。

### D. Flutter-tools context PASS，M3 转为 Gradle/Android error

这是好进展。按首个真实 Gradle/Android 错误发布窄修复任务；不再回退到 pub 诊断。

### E. M3 exit=0 + exact AAR HIT

立即进入 fresh review，接受后发布 **M2 targeted Android host Gradle resolution** task。

不要做全局 technical-design gate，不要执行产品实现。

### F. M3 exit=0 + exact AAR NON-HIT

发布 exact output/provenance task；不得搜索替代 AAR 路径。

## 9. M2 之后的预定路线

一旦 exact AAR 成立并 M2 targeted resolution 通过，当前规划路线仍是：

1. narrow code delivery；
2. Android Owner-installable demo；
3. registration / profile / match / conversation vertical slice；
4. minimal internal candidate；
5. testing；
6. 再逐步恢复更高效率的 Docker / Android emulator / physical device / test backend 联调环境。

Windows Sandbox 当前定位是 **构建实验室 / reproducibility boundary**，不是永久产品运行环境。后续产品联调应转回更适合的 Docker + 模拟器/真机 + 后端环境，但前提是 M3/M2 证据链先闭合。

## 10. v9 legacy 可继承的工程证据

历史 v9 已存在 Android host + Flutter + Laravel + FastAPI，且有 auth/profile/match/conversation/RTC/notification/block/report/admin/update 等工程证据；Match→Conversation 曾通过 mutual/released match 链路。HTTP conversation chain/tests 较强，RTC runtime 未充分证明，安装/更新不完整，backend 有重复实现。

这些只作为后续工程参考，不自动成为 v10 architecture authority。

v10 继续坚持：

`Match ≠ Connection ≠ Conversation ≠ Relationship`

默认不访问旧 repo，除非具体 task 明确授权。

## 11. 模型与协作方式

- ChatGPT：roadmap、task decomposition、architecture、fresh independent review、acceptance。
- Codex：执行固定 task sheet。
- Codex 默认模型：GPT-5.6 Sol，Medium。
- 模型选择本身不产生额外 authority。
- 不默认调用 auxiliary agents。

标准工作流：

1. ChatGPT 发布精确 task branch/document。
2. Owner 运行 Codex。
3. Owner 返回结果/candidate。
4. ChatGPT fresh independent GitHub review。
5. compliant 才创建 exact-tree acceptance 并 non-force 更新 main。
6. 然后发布下一 task 或进入会话交接。

## 12. 下一会话启动要求

下一会话不要从头复述项目，也不要重新审查已经闭合的历史门。第一条实质动作应围绕 **R7 fresh review** 或（若本会话已完成 R7 acceptance）围绕最新 accepted main 和 R7 后决策。

必须用简体中文沟通。

交接时优先读取：

1. FIRST system-transition handoff；
2. 本 handoff；
3. fresh current `main` / `CURRENT_CONTEXT`；
4. R7 task/result；
5. 只在需要时读取更早 R5/R6 结果。

不要读取 README。

---

`END OF CURRENT SESSION HANDOFF — R7 IN FLIGHT`
