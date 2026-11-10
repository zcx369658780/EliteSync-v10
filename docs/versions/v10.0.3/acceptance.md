# EliteSync v10.0.3｜Astra 最终独立验收

> **ACCEPTED / CLOSED WITH OBSERVATIONS — BOUNDED SYNTHETIC REAL-ROUTER DYNAMIC GUARD FIX**  
> 2026-10-13（Asia/Shanghai）。独立验收人：Astra（与 Codex 实现人分离）。  
> **Acceptance Status = ACCEPTED/CLOSED WITH OBSERVATIONS；Integration Status（本验收归档时）= ISOLATED_CANDIDATE / NOT_MERGED_TO_MAIN。** 后续是否执行已授权的**定点代码集成**须按另份 [integration.md](integration.md) 的实际发布回执核定，不得将本历史时点当作永久状态。

## 一、冻结依据和固定候选

- 正式 [v10.0.3/plan.md](https://github.com/zcx369658780/EliteSync-v10/blob/1ed7880a5843d2f1fe31b9d1ba254bf2792cc244/docs/versions/v10.0.3/plan.md)：冻结 commit `1ed7880a5843d2f1fe31b9d1ba254bf2792cc244`、Git Blob `4472647408af1f972e365ac66cd8c42d127fff34`。仅导航勘误 `7feea5130dc0adcbb91391d99c5c723f46786c10` 不改变冻结 AC。
- Codex 固定 [候选 commit](https://github.com/zcx369658780/EliteSync-v10/commit/e2f6db455a329c59b2b4158cc50c0e18561a7c99) `e2f6db455a329c59b2b4158cc50c0e18561a7c99`，Tree `bd2d0c30cf8fc1d9efd39ffbb52481375ff8fafc`，唯一父 `fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae`，Git compare ahead1/behind0。
- 相对代码父提交仅两个 apps/ 产品/测试路径变更（已有 `app_router.dart` 21行差异，新 `home_progress_guard_refresh_test.dart` 560行新增），其他为版本有限报告/脱敏证据和验证脚本；没有改 Home/Progress/NavigationGuard/Chat/BE-12。
- [作者执行报告](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/EXECUTION_REPORT.md) Blob `19a0fd67eae50fc952e402d2e48b9d95b10567db`、[manifest](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/manifest.json) Blob `68337764a77112cdf8049a8b7c796fb9b9658886`。网页从固定 commit **逐文件回读 manifest 所列45/45 Git Blob，全部匹配**，不是单凭作者声明。
- [APP-INT-05 已接受报告](https://github.com/zcx369658780/EliteSync-v10/blob/fb8aa3527b1734ac36cf56e5a8887f52f9d5ceae/EVIDENCE/APP-INT-05/summary.md) 原 Blob `d488e1aee6080420d3694d80fe7aaea088c6ce73`，历史 ACCEPT 仅限 synthetic Home live-state 主循环；本版没有重复实现。

## 二、独立核查与故障复现

1. **原故障并非静态推论**：[run-04-baseline stdout](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/evidence/run-04-baseline/stdout.txt) 和 [receipt](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/evidence/run-04-baseline/receipt.json) 展示实际旧 Router：七项动态用例 **2 PASS/5 FAIL、exit1**；无关 Guard 更新下期望 `/progress`，实际变为 `/home`；Match 深路径失去 readiness 后期望 `/me/readiness`，实际 `/home`；Router 实例重建与状态损失亦有多个失败用例。失败原证保留，不称原始程序通过。
2. **修复源码**：从固定候选实读 `app_router.dart` Blob `2eebd3f0959414f95e2a3ec61e94d73a2779d795`。Provider 构建中不再直接 `ref.watch(navigationGuardProvider)` 导致实例因 Guard 变化重建；改为 `ref.listen(...)` 通知本文件私有 `_GuardRouterRefresh extends ChangeNotifier`，`GoRouter(refreshListenable:guardRefresh)` 对**当前路径**重评既有 redirect。Provider `onDispose` 先 `router.dispose()`、后 `guardRefresh.dispose()`；原 GoRouter topology / redirect 规则保留。没有修改 Guard 的权威/Readiness/Connection policy。
3. **同次真实 Router 测试**：新 [home_progress_guard_refresh_test.dart](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/apps/flutter_elitesync_module/test/app/router/home_progress_guard_refresh_test.dart) Blob `6811828ffc8c2c37f752902d7f91513d6c5dc478` 使用**真实** `appRouterProvider + MaterialApp.router + AppShell`，测试变动的同一个挂载/Router：合法 Progress query与 Element保持、Match 深路径在 UNKNOWN/setupRequired 安全到 Readiness、Auth loss 到 Login、Home→Progress→真实Match/Connection、pop保留当前路由、连续12次 Guard、Router invalidation/unmount 后旧监听不触发且 delegate 已释放。
4. **保守 CTA/同意**：在 same-shell 下观察 Match loading/error/failed/closed/noCandidate 的保守 Home 状态；Connection pause/close 清除 demo-local synthetic mutual consent，先前“查看消息”不残留；UNKNOWN readiness 回到准备入口，**测试特别保留既有 Connection active**，没有越权发明“Readiness丧失撤销Connection”的业务政策。
5. **最终运行原证**：[run-12-isolation-final stdout](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/evidence/run-12-isolation-final/stdout.txt) 按真实测试输出 `+42: All tests passed!`；[receipt](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/evidence/run-12-isolation-final/receipt.json) 为 exit0，15新测试+27直接相关原路由/首页测试；[run-13 analyze](https://github.com/zcx369658780/EliteSync-v10/blob/e2f6db455a329c59b2b4158cc50c0e18561a7c99/docs/versions/v10.0.3/evidence/run-13-analyze-final/stdout.txt) `No issues found!`，exit0。两份最终 receipt 对同一源码/新测试的 raw SHA-256 分别为 `0b8a26c548bfd1be86088c7e7874ff9c8e0dc8799930905df42fa68b85101a94` 和 `04cd83ef0eb814691dfbc55fd372e8fed3b1fe2554430a165ef12df483e45109`，与 manifest 相同。
6. **外部隔离为主动断言**：源码中新增测试的 `_Harness` 覆盖 memory storage、拒绝 secureStorage/API/Dio/Match remote、RTC watcher false，`HttpOverrides.runZoned` 对 `HttpClient()` 先试探拦截确实生效、重置试探计数，再断言15项用例运行后 `externalProviders=0 / network.attempts=0 / storage.writes=0`。这只证明**新增15项的这些受控出站路径**，不夸称旧27项全部同等哨兵覆盖或真实服务运行。
7. **多轮失败与修复透明**：run-01 环境缺 package graph（仅有限远端摘要，本机未公开的Flutter崩溃原报告不可由网页逐字审查），run-02 Riverpod legacy import 缺失，run-03/04原 Router 可复现失败，run-05修复后7 PASS，run-06有2个测试时序/预期问题后修复，run-07/08扩展通过，run-09～13完成 protected API、HTTP内层哨兵及最终分析。未将先前失败伪装为绿色，也未引入 SDK/依赖升级。发布日志经路径脱敏；raw哈希与已发布副本哈希**不同**且证据层级分别登记。
8. **本地保护以作者回执为准**：`protection.json` 报告原 `D:/EliteSync-v10` 脏 root HEAD `4bebc8f...`、index SHA `2be660...`、status SHA `a00c210...` 与109具名文件 `named_mismatches=[]` 前后一致；原干净开发基线 HEAD `2175dd62...`、index SHA `abf3fd...`、状态空集前后一致。网页**无法直接访问这两棵 Windows 工作树复验**，只独立读取 GitHub 提交对象与回执正文。
9. **未做测试不能冒称 PASS**：本版 PHP/DB/BE-12 Feature、Android设备、Profile/Release、全App均 `NOT_RUN`；真实 auth/readiness 失效来源、stale writer、正式 Connection撤销政策、线上 Conversation 消息权限和产品平台资格 `NOT_PROVEN`。模型化虚构 Guard 注入不证明真实生产事件传播。

## 三、冻结 AC-01 ～ AC-07 最终裁定

| AC | 独立结果 | 范围限定 |
|---|---|---|
| AC-01｜精确代码基线与去重 | **PASS** | 固定单父、历史接受、原根和干净基线保护回执；网页核 Git 身份 |
| AC-02｜真实 Router 动态验证 | **PASS** | 已挂载 `MaterialApp.router/AppShell` Guard更新与真实页面断言 |
| AC-03｜路径保持、redirect与释放 | **PASS** | 保持 path/query/page，Readiness/Auth loss 现有回退，监听停止/Router dispose |
| AC-04｜不越权且无旧 CTA | **PASS** | 仅已接受 synthetic provider 情景；不发明真实撤销来源或聊天权限 |
| AC-05｜有限回归和外部隔离 | **PASS** | 42/42 Flutter targeted、analyze exit0；新15项哨兵为0；历史失败保留 |
| AC-06｜固定独立证据 | **PASS** | 45/45 payload blobs、源码/测试/脱敏日志、run receipts、保护清单可固定读取 |
| AC-07｜独立验收与后继状态 | **PASS** | 本文与[事实复盘](retrospective.md)形成独立终裁；候选本时点未 merge、K08后续定点集成独立核 |

## 四、保留观察与终裁

- **OBS-01** 此次“真实 Router”指**真实 Flutter GoRouter/AppShell 组件的 synthetic Widget 运行**，不是可安装 Android/Release/真实用户环境；真实数据源/撤销事件未建立。
- **OBS-02** 新测试的零外部调用哨兵为受控的上述依赖和 HTTP 访问；未对整个 App/底层所有可能 OS 调用做全局运行资格审核。
- **OBS-03** Router 的资源释放已按公开行为断言，但本版不包含长时间设备驻留、热重载恢复、真实后台路径历史持久化验证。
- **OBS-04** 原脏 root 的109项保护及 clean baseline 状态源自 Codex 回执；缺少网页可直接重算 Windows 文件的能力。
- **OBS-05** 原 Flutter crash 自动诊断日志仅本地原样保留、远端提供摘要；Astra 并未读取当地未发布原件，不能称全部本地 raw 可在线复核。
- **OBS-06** 不解除 BE-12默认404、V57/H1/H2/D0暂停、`NOT_READY`、`RuntimeReady=false`、`M6 CLOSED`、`S2 unsigned` 或 `OwnerEnvironment PENDING`；不自动启动 v10.0.4。

**最终结论：`V10.0.3 ACCEPTED / CLOSED WITH OBSERVATIONS — ACTUAL DYNAMIC GOROUTER GUARD BUG REPRODUCED AND FIXED — SYNTHETIC TEST ONLY`**。
