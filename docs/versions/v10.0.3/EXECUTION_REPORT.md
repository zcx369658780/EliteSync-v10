# v10.0.3 执行交付：真实 Router 动态 Guard

**AUTHOR_VALIDATION_COMPLETE — AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE**

唯一计划：[`1ed7880a5843d2f1fe31b9d1ba254bf2792cc244/plan.md`](https://github.com/zcx369658780/EliteSync-v10/blob/1ed7880a5843d2f1fe31b9d1ba254bf2792cc244/docs/versions/v10.0.3/plan.md)，Blob `4472647408af1f972e365ac66cd8c42d127fff34`。已完整读取；导航勘误 `7feea5130dc0adcbb91391d99c5c723f46786c10` 只解释历史接受记录的链接。

候选唯一父提交 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`，父 Tree `a25fc46be72056b4940923c45fab81367f17fd2a`。候选身份以本报告所在的固定提交/tree及 Owner 交付回执为准，不在提交内容中循环自引用自身 SHA。独立候选分支 `codex/v10.0.3-guard-refresh`；没有合并 main。源码/测试及必要证据的 Git Blob、SHA256 见 [manifest](manifest.json)。

## 实际缺陷与修复

修复前使用真实 `appRouterProvider + MaterialApp.router + GoRouter + StatefulShell/AppShell`，同一挂载动态注入虚构 Guard。run-03、run-04-baseline 均 2 PASS / 5 FAIL。后者明确观察到无关 Guard 更新把 `/progress` 重置为 `/home`，Match 深路径失去 Readiness 后也回到 `/home`，未到既有 `/me/readiness`；多个用例同时确认 Router 被替换。不是仅凭源码推定缺陷。

仅修改 `lib/app/router/app_router.dart`：用 provider-owned ChangeNotifier 刷新桥监听 Guard，GoRouter 通过 `refreshListenable` 对当前路径重新执行原 redirect；不再因 Guard 更新重建 Router。Provider 销毁时先 dispose Router、再释放刷新桥；Riverpod 关闭该 provider 的 Guard 订阅。原 redirect、路由拓扑、产品权限和领域政策全部保留。刷新桥采用本文件私有子类，遵守 ChangeNotifier 的 protected API。

只新增指定 `test/app/router/home_progress_guard_refresh_test.dart`。15 项真实组件测试覆盖：

- UNKNOWN/setupRequired 初始 Match 禁止绕过；已挂载 Match 深路径变为这两种状态即回退 Readiness，恢复 Ready 不自动跳回受限路径。
- 合法 Progress 的 query、AppShell State 与页面 Element 保持；真实 Home dock → Progress → Match/Connection；Guard 更新后 Connection 保持，pop 返回 Progress，Home 下一步实际导航到 Connection。
- Auth loss 从 Connection 进入实际登录页面；连续 12 次 Guard 更新使用同一 Router。
- unmount 后显式 provider invalidation 释放旧实例；旧 refresh 计数不再变化；替换实例重新挂载后仍能执行 Match → Readiness。容器销毁后 RouterDelegate 拒绝新增监听，证明已释放；无双释放异常。
- 同次挂载 Home 的 Match loading/error/failed/closed/noCandidate 清除旧“查看连接”CTA；切页返回仍消费当前状态。Connection paused/closed 清除既有 synthetic mutual consent，消息 CTA 立即消失。UNKNOWN Readiness 显示准备入口，未擅自撤销已成立 Connection。

## 实际运行与失败保留

最终 **run-12-isolation-final：42/42 PASS，exit0**，新测试15 + 既有直接相关测试27；只运行以下四个文件：

```text
flutter test --no-pub --reporter expanded
  test/app/router/home_progress_guard_refresh_test.dart
  test/app/router/match_legacy_redirect_regression_test.dart
  test/app/router/first_use_onboarding_router_integration_test.dart
  test/features/home/presentation/pages/home_page_test.dart
```

run-13-analyze-final：只分析修改源码和新增测试，`No issues found!`，exit0。测试及分析 receipt 中的最终源码/测试 raw SHA256 与 manifest 一致。已有 Home 主循环接受仅沿用 `EVIDENCE/APP-INT-05/summary.md` 的固定 Blob `d488e1aee6080420d3694d80fe7aaea088c6ce73`；不把历史证据说成本版运行。

| 尝试 | 实际结果与处理 |
|---|---|
| run-01 | 编译前缺 package_graph.json，exit1；补用既有干净基线相同依赖图，未下载。Flutter 自动 crash/doctor 报告仅本地保留，远端为明确标记的有限故障摘要及原字节哈希。 |
| run-02 | 新测试未导入 Riverpod 3 legacy StateProvider，编译 exit1；修正测试 import。 |
| run-03 / run-04-baseline | 原 Router 2 PASS / 5 FAIL；第二次将路径断言提前，取得具体错误路径证据，产品源码未改变。 |
| run-05-fix | 修复后相同7项 PASS，exit0。 |
| run-06-expanded | 扩展回归13 PASS / 2 FAIL：测试 Future.error 在消费者订阅前报告未处理错误；UNKNOWN Readiness 的测试预期与既有准备入口不符。改用已订阅 Completer 交付错误，并据已读原 getter 断言“前往准备状态”；未修改 Home 或减弱冻结标准。 |
| run-07-expanded / run-08-final | 15项 PASS / 联合42项 PASS，exit0。 |
| run-09-final | ChangeNotifier 私有刷新桥后联合42项 PASS。 |
| run-10-analyze / run-11-final | 窄分析exit0无问题；联合42项 PASS。 |
| run-12-isolation-final / run-13-analyze-final | 改用内层 Zone HTTP 哨兵，最终联合42项PASS及最终分析exit0。 |

附加窄分析首次产生6项 protected/visible API warning（exit1）：直接 notifyListeners 改为私有子类公共刷新方法；测试不再读取 protected hasListeners，使用实际 callback 停止和已销毁 delegate 的公开操作异常断言。首次输出来自工具回执，非独立 raw 文件，未伪装为原始流。一次 Python 日志显示/编辑遇到 Windows GBK 解码错误，均在写入前失败，改用 UTF-8；测试原始文件与流未损失。

## 安全隔离与保护

新测试使用虚构 Guard/Match 输入，保留真实 Home、Progress、Match、Connection 展示、Connection/Conversation synthetic controller 和 Router；没有 stub Router。内存 storage 完整覆写读写接口，写入 fail-fast；HTTP client、Dio/API、secure storage、Match remote provider 都设置拒绝哨兵/访问计数，RTC watcher 显式 false，AppShell warmup 由 memory performanceLiteMode 停止。HTTP 使用内层 `HttpOverrides.runZoned`，每项先用构造探针证明拦截有效（一次预期拒绝，无网络连接），再清零并断言整个测试 body 零调用；早期仅全局 HTTP override 的计数不作为最终 HTTP 隔离证明。新测试每项断言 external provider attempts=0、HTTP client attempts=0、storage writes=0；正常聊天页/消息读发未进入。既有27项使用原有 mock/内存 harness，Flutter widget test 自带 HTTP 隔离；新增精确零计数证明范围是新15项，未声称全机或所有历史测试都有相同计数器。

复用此前干净基线已存在的 package_config 与 package_graph，只在候选忽略的 `.dart_tool` 中重映射本包 root；SDK/cache未升级、pub get未运行。Flutter3.41.7、Dart3.11.5、GoRouter16.3.0、Riverpod3.3.2，pubspec.lock不变。初次 Flutter 自动 crash diagnostics 的平台/设备/网络清单不公开，也不构成产品访问或运行授权；后续无主动 doctor/设备命令。

保护回执：[protection.json](evidence/protection.json)。原 dirty root `D:/EliteSync-v10` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`、index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`、status SHA256 `a00c2102dde4c87579208cf8479086674fa4eba2e082910f7463eb59eac6cf65` 均保持；staged0、tracked43、untracked normal208。109项具名文件零变化。此前干净开发基线 HEAD `2175dd62d9384efa05dd6b5201f58c5282379fbb`、index SHA256 `abf3fd0cc96b43daed0bfc98e5d38cb3144f10fc8392cb631f3aa8fb82066251` 保持，仍 CLEAN。仅新 worktree 登记变化，未清理旧 worktree、未触碰旧 EVIDENCE。

原 Router Blob含 CRLF。本版保留该字节惯例，`git -c core.whitespace=cr-at-eol diff --check` 检查代码；默认检查将新增行的 CR 当作 trailing whitespace，不据此改变整份既有源码或 raw 证据。源码暂存保持原换行惯例，manifest 使用实际 Git Blob与原始字节哈希。

所有 run receipt 与安全日志见 `evidence/run-*/`。除 run-01 明确摘要外，其余完整 stdout/stderr 只替换本机绝对路径为占位符；保留失败、栈、退出码和计数。receipt 同时记录本地原流与发布流 SHA256。没有认证数据、真实账户/消息或私密数据进入证据；有限 manifest 不覆盖巨量历史 EVIDENCE。

## AC 映射、保留缺口和停止

| AC | 本地作者证据 / 状态 |
|---|---|
| AC-01 | 单父固定、基线对象表、两树与109文件保护回执；未重做 Home 主循环。 |
| AC-02 | 新15项真实 Router/页面测试及run-12-isolation-final；同次 mount 动态 Guard、真实入口与深路径回退。 |
| AC-03 | path/query/page/state/pop保持、Auth/Readiness回退、连续更新、旧实例释放与replacement刷新。 |
| AC-04 | Home/Match保守CTA、Connection pause/close清除synthetic同意；原政策未改。 |
| AC-05 | 最终42项exit0，相关2文件分析exit0；失败全部保留，新增精确外部哨兵断言。 |
| AC-06 | 固定候选源码/测试、manifest、脱敏原流、receipt及保护回执供网页读取。 |
| AC-07 | **PENDING_ASTRA**：未自接受、未合入main、未建立后继版本或恢复暂停项。 |

`NOT_RUN`：PHP/DB/BE-12 Feature、Android/设备、Profile/Release、全应用测试、正式生产资格；不是本版覆盖范围。`UNKNOWN/NOT_PROVEN`：真实 auth/readiness 撤销来源、业务 stale/revoke writer、正式 Connection 撤销政策、跨后端真实消息权限、平台运行资格。测试注入不证明真实服务状态传播。

下一步仅由 Astra 对固定计划 AC-01～AC-07 独立验收/复盘，Owner 决定安全接续。BE-12真实消息仍默认拒绝，V57/H1/H2/D0未激活。

**V10.0.3 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE — NO MAIN MERGE / NO V10.0.4**
