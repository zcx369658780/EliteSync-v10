# EliteSync v10｜M3 R6-R4-R7 后当前会话收口与下一会话交接 v0.1

Status: `CURRENT SESSION CLOSED — R7 ACCEPTED — EXPECTED OWNER SANDBOX SESSION NOT AVAILABLE — NEXT SESSION MUST RE-ESTABLISH A BOUNDED OWNER SANDBOX BEFORE RESUMING M3`

日期：2026-09-10（Asia/Singapore）。

## 1. 当前权威与本交接用途

仓库：`zcx369658780/EliteSync-v10`。

当前 accepted main：`16e78e668db360a2313db068aa19e7c5ec59800d`。

该接受提交：
- sole parent=`abe7ec053d7ec47fb05542665939e1700d90e754`；
- exact tree=`a8641905221ab52f653640cc1b04f8aeef453e71`；
- 接受 R6-R4-R7 的唯一结论：初始 `wsb list --raw` 为 0 个 running Sandbox，因此按任务硬停止；未进入 guest、coverage/code_builder 诊断、Flutter-tools direct Dart pub、M3、AAR 或 M2。

FIRST 文档仍为：
`docs/architecture/ELITESYNC_V10_GPT6_ASTRA_SYSTEM_DOCUMENTATION_TRANSITION_CURRENT_SESSION_CLOSEOUT_AND_NEXT_SESSION_HANDOFF_V0_1.md`
固定 blob=`18485c95262051e43892436fb52413132c5ee626`。

本文件用于下一 GPT 会话恢复上下文；它本身不增加产品实现、M2、网络、Sandbox 或法律权限。下一会话必须 fresh-fetch GitHub main，而不是把本 handoff 分支当作仓库 authority。

## 2. 强制 GitHub 验收流程

任何后续 candidate 验收继续执行：
1. fresh-fetch candidate exact tree；
2. 创建 acceptance commit，sole parent=candidate，tree=EXACT candidate tree；
3. **在更新 main 前立即 fresh-fetch acceptance**，验证 sole parent 与 exact tree；
4. fresh-fetch main，必须仍为预期旧 authority；
5. `update_ref(main, force=false)`；
6. final fresh-fetch main ref 与 main commit，验证最终 SHA=acceptance 且 tree=candidate tree。

不得因历史信息或旧 tree 假设复用树；这是不可省略的防回退规则。

## 3. 永久/长期边界

继续保留：
- 不检查、不重置、不清理、不提交无关 protected staged/index 状态；
- README documentary budget exhausted；FD02 永久排除；
- 无 repo/dir-wide enumeration/search，除非有新的明确授权；
- D-02=`D02-DURABLE-UNKNOWN-01`；
- U-14 exclusion；U-12 exact-scope target；`TP-SOURCE-CLASS-01`、`TP-TARGET-01`；
- Backend 0/10 NOT INSPECTED/NOT AUTHORIZED；DB 0/8；PUI deferred；`PUI-PREREQ-12=0`；
- LC-03/LC-04/Phase36 未授权；产品实现仍是单独授权；
- v9 只可作为 legacy functional evidence，不是 v10 architecture authority；默认不访问旧仓库；
- 不自动调用辅助代理；模型选择不构成 authority；
- 不修改宿主 Flutter/Android/JDK/Git/Pub/Gradle SDK/cache，除非新任务精确授权；
- 不联网补包，不把 socket/DNS 错误自动解释为 cache miss；
- M3 成功不等于 M2 成功；M3 失败也不等于集成设计无效；
- M2 仍 deferred，直到 exact AAR 建立并 fresh review 后再发 targeted host-resolution task。

## 4. M3 已接受技术证据链

关键路线已经从环境问题收敛到 Flutter-tools 自身离线 context：

1. R6-R1：固定 main 模块对象 materialization 与 host module ZIP 成功；新 evidence share 失败。
2. R6-R2/R3/R4：复用旧 R4 writable mapping、建立 guest、模块目录桥、current-view、隔离与 dispatch；逐步修复 Expand-Archive、probe 与 PowerShell 5.1 helper 问题。
3. R6-R4-R2：真实 Git/Java 成功；首次真实 `flutter pub get --offline` 到达 Flutter，因 guest PATH 缺 PowerShell 失败。
4. R6-R4-R3：进程级 PATH 修复成功；Flutter wrapper 先执行 `git fetch --tags`/GitHub，再 pub.dev，证明 wrapper/tool 网络路径存在。
5. R6-R4-R4：加入全局 `--no-version-check` 后 GitHub fetch 消失，但 `pub get --offline` 仍访问 pub.dev 查 `code_builder`。
6. R6-R4-R5：直接调用 Flutter SDK 内置 Dart：`dart pub get --offline` **exit=0，约2秒，完全无网络**；项目 module dependency graph 已证明可从固定 cache 离线解析。随后 Flutter M3 `--no-pub` 仍访问 pub.dev 查 `coverage`。
7. R6-R4-R6：绕过 `flutter.bat/shared.bat`，直接 Dart 加载既有 `flutter_tools.snapshot`，仍访问 pub.dev 查 `coverage`；因此剩余网络尝试位于 Flutter tool/build path，不是 Windows wrapper bootstrap。
8. Flutter 当前公开 `packages/flutter_tools/pubspec.yaml` 固定依赖 `coverage: 1.15.1`、`code_builder: 4.11.1`。
9. R6-R4-R7 原计划：确认 guest 固定 Pub cache 的 `coverage-1.15.1`，然后只在 Sandbox 内 R4 Flutter SDK 副本 `C:/M3R4/t/f/packages/flutter_tools` 执行一次 `dart pub get --offline`，刷新 Flutter-tools package context，再重跑一次 direct-snapshot M3。
10. R7 实际未进入 guest：原 Owner Sandbox 会话已经不存在，`wsb list --raw`=0，因此停止。

## 5. R7 已接受对象

R7 task：
- branch=`task/h01-bib03-u15-td01-m3-flutter-tools-offline-context-v0-8-r6-r4-r7`
- task commit=`0a88b97502931c50ae2f22c0a1a9d07f6ae3e635`
- task blob=`5d89617efb19b6ed873213e99aba02961126598c`

R7 candidate：
- candidate=`abe7ec053d7ec47fb05542665939e1700d90e754`
- sole parent=`0a88b97502931c50ae2f22c0a1a9d07f6ae3e635`
- candidate tree=`a8641905221ab52f653640cc1b04f8aeef453e71`
- result blob=`37bd7a4b06cdbf1fd2af15892f86f763c50fa66b`
- CURRENT_CONTEXT blob=`e22cc69b903ef852dbb558d6f3aa9d6abd08d604`

Accepted main：`16e78e668db360a2313db068aa19e7c5ec59800d`。

## 6. 下一会话第一项实质工作

不要直接重跑 R7，也不要假设旧 Sandbox ID 仍存在。

下一会话应先发布一个**新的、明确 Owner 激活的 Sandbox session re-establishment task**，目标仅是：
- fresh-check `wsb --version` / `wsb list --raw`；
- 在确认当前 0 个 running Sandbox 后，允许 Owner 创建一个新的 Windows Sandbox 会话；
- 记录新 Sandbox ID；
- 建立新的 task-owned writable evidence transport/bridge；
- 重新建立 run-as System guest、PowerShell 5.1、process/effective RemoteSigned、Security 系统 Path、活动网卡0、默认路由0；
- 重新确认所需 R4 Flutter/Android/JDK/Git/Pub/Gradle/module 固定输入是否仍可在新 Sandbox 中建立；
- **不运行 Flutter-tools pub，不运行 M3，不执行 M2**，除非同一任务被非常明确地设计为“session re-establishment + R7 continuation”并且所有 transport/tool inputs 已重新证明。

优先建议拆成两步：
A. fresh Sandbox/session + exact transport/tool re-establishment；
B. 在 A fresh acceptance 后重发 R7 continuation（coverage cache → Flutter-tools direct Dart offline context → direct-snapshot M3）。

理由：旧 Sandbox 消失意味着此前 guest 内部 `C:/M3R4/...` 工具/cache/module 副本也不能自动假设存在。必须重新建立，而不是只换一个 Sandbox ID。

## 7. R7 continuation 的既定目标

当新的 Sandbox 技术输入重新建立后，恢复以下逻辑：

1. Flutter-tools pubspec 精确确认：`coverage=1.15.1`、`code_builder=4.11.1`。
2. 固定 Pub cache 仅有界过滤 `coverage-*` 与 `code_builder-*`。
3. 若 `coverage-1.15.1` 不存在：`FLUTTER_TOOLS_EXACT_COVERAGE_CACHE_MISS`；不得联网补齐。
4. 若存在：只在 Sandbox Flutter SDK 副本执行一次 `dart pub get --offline`，cwd=`packages/flutter_tools`。
5. 必须无网络；成功后 package_config 的 coverage rootUri 指向本地 `coverage-1.15.1`，snapshot SHA 不变。
6. 然后唯一 direct-snapshot M3：Dart + flutter_tools.snapshot + `--no-version-check build aar --no-debug --no-profile --no-pub`。
7. M3 process started 后只 probe 一次 exact AAR：
`build/host/outputs/repo/com/elitesync/flutter_elitesync_module/flutter_release/1.0/flutter_release-1.0.aar`。
8. M3 exit0 + AAR HIT => `M3 EXACT AAR ESTABLISHED — READY FOR FRESH M2 TARGETED HOST RESOLUTION REVIEW`；仍不在同一任务执行 M2。

## 8. M3 成功后的路线

exact AAR 建立后：
1. fresh review/accept；
2. 发布 targeted M2 Android host Gradle resolution task；
3. M2 成功后进入窄代码交付；
4. Android Owner-installable demo；
5. registration/profile/match/conversation 纵向切片；
6. 后续恢复更高效率的 Docker / Android 模拟器或真机 / 测试后端（包括未来允许时的阿里云测试后端）做功能联调。

Windows Sandbox 只用于当前构建链隔离和证据建立，不应成为永久产品开发环境。

## 9. 下一会话启动要求

下一 GPT 会话：
- 使用简体中文；
- fresh-fetch GitHub main，必须先确认 `16e78e668db360a2313db068aa19e7c5ec59800d`，若已变化则以 fresh authority 为准并停止假设；
- FIRST 读取 GPT6/Astra 转型 handoff；
- 再读取本文件；
- 不把本 handoff 分支当作 main authority；
- 第一项实质动作是 fresh post-R7 Sandbox session re-establishment governance/task design；
- 不直接创建网络、M2、产品实现或旧 Sandbox continuation 权限。

CURRENT SESSION CLOSED.