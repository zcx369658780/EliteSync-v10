# v10.0.4 Readiness 来源解释与安全恢复交付

**AUTHOR_VALIDATION_COMPLETE — AWAITING_ASTRA_INDEPENDENT_ACCEPTANCE**

唯一执行计划：[固定 plan.md](https://github.com/zcx369658780/EliteSync-v10/blob/ecfd8b4dae4139991a425e426e988d6aa8ba4385/docs/versions/v10.0.4/plan.md)，commit `ecfd8b4dae4139991a425e426e988d6aa8ba4385`，Blob `e70ca5ef3d96a8086555586239a998227575e01e`，已完整读取并实际核对。独立候选唯一父提交 `5728251c6345ba17524fb323dac8a02573d8d8c6`；未改用之后的文档 main。分支 `codex/v10.0.4-readiness-explanation`。本报告和 [manifest](manifest.json) 所在的固定 GitHub 提交确定候选 commit/tree；不循环自引用自身 SHA。

## 范围与实际实现

产品改动仅限 `apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_purpose_pages.dart` 的 ReadinessPurposePage 与专用私有辅助。父 Blob `614d412f417d7ce2e6385ac5324c4fd79660b788`；其它 Me 用途类、共用兼容页面类及 imports 与父对象 **逐字节相同**。新增产品测试仅 `test/features/me/presentation/pages/readiness_purpose_page_test.dart`；其余新增物均在本版本目录。

- 原 Me→Readiness 中新增“当前状态来源”与“正式准备条件尚未确定”解释。UNKNOWN 不表示用户不合格，setupRequired 不指认缺少哪项；正式准入、验证、问卷完成与有效准备状态分别判断。
- 只在 `ready && env.isDev && explicit synthetic flag` 显示醒目 Synthetic/开发演示/不是正式资格。非 Dev 或 flag关闭的异常 READY 改为“准备状态来源未确认”，移除无依据的“已由权威来源确认”。没有修改 Guard 的值或权限。
- 两个原按钮/路由保持；增加“兼容验证状态查看”“兼容问卷继续设置”的用途提醒。旧验证页要求不能作为正式条件。问卷既有草稿恢复由原流程判断；本版不读草稿、不实现新恢复系统、不提交资料或同意。
- Readiness ListView 底部留112px，避免 AppShell 浮动 dock 遮挡恢复按钮；大字体下仍可滚动读取和定位按钮。没有修改 AppShell 或 Router。
- 没有新增 required/optional 成员、百分比、身份等级、准入门槛、有效期、真实用户状态源、HTTP消费者或新的业务存储。

## 实际验证及证据边界

最终 **run-07-final-bytes：13/13 PASS，exit0**：新8项 + 已接受 synthetic Readiness/Match 2项 + 必要 first-use Router 3项。最终 **run-08-analyze-final：两文件窄分析 No issues found，exit0**。最终 receipt 中源码/测试 raw SHA256 与 manifest 对应对象相同。

```text
flutter test --no-pub --reporter expanded
  test/features/me/presentation/pages/readiness_purpose_page_test.dart
  test/synthetic_readiness_match_integration_test.dart
  test/app/router/first_use_onboarding_router_integration_test.dart

dart analyze
  lib/features/me/presentation/pages/me_purpose_pages.dart
  test/features/me/presentation/pages/readiness_purpose_page_test.dart
```

新测试的7项使用真实 `appRouterProvider + MaterialApp.router + AppShell`，由真实 MeLandingPage 点击进入 Readiness；没有替代 Router。另1项仅为未登录 Readiness 文案的明确展示层补证：真实未登录 Router 会去 login，不能冒称绕过该规则进入页面。

实际覆盖：生产 UNKNOWN；生产/Dev关flag异常 READY；Dev开flag Synthetic READY；同一挂载 READY→UNKNOWN/setupRequired 后旧成功说明消失且页面 Element/Router保持；Auth loss 到真实登录页；原验证/问卷目的页及 pop 返回 Readiness，注入 Guard 同对象且 canChat=false；320×640、两倍字体下说明和两个按钮可滚动到且 hitTestable，无布局异常。大字体用例不声称验证旧兼容目的页的大字体布局；两个目的路由的实际点击/返回由正常尺寸用例证明。

新测试使用虚构 Guard 和虚构目标页 provider。Readiness 阶段断言验证/问卷 provider 读取次数均0；用户点击后每个目标虚构 provider读取1次，返回不改变 Guard。内存 storage 的写方法全部拒绝；API/Dio/secure storage设置拒绝哨兵；RTC watcher关闭，performanceLiteMode停止 warmup。每项以 **内层 HttpOverrides.runZoned** 抢占 Flutter test 自身 override，先进行一次预期拒绝的 HttpClient 构造探针（未联网），再清零并断言正式 body 的 HTTP=0、external dependencies=0、storage/business writes=0。问卷原页面的 entry telemetry 被本地 fixture消费，不构造传输服务，其它 telemetry 调用拒绝；不是发往真实服务。

这些0值只证明新8项的受控配置与依赖路径，不是全机出站监测，也不是生产 Guard/身份/资格验证。旧5项使用原有 mock/test harness，不宣称它们具有同等新增哨兵。

## 原始失败与修复序列

| 运行 | 原始结果及后续处理 |
|---|---|
| run-01-baseline | 原页面下新8项均失败，exit1；包含确实缺少的新说明、异常READY旧文案，以及测试 harness 的按钮基类定位/滚动问题。不是8项产品缺陷；日志保留。 |
| run-02 | 修改后联合11 PASS/2 FAIL，exit1。按钮点击落入浮动dock；大字体Me入口尚未滚动到。补Readiness底部空间及实际可点击的滚动定位，不修改Router。 |
| run-03 | 联合12 PASS/1 FAIL，exit1。真实 push目的页已经进入，但测试误读不反映 imperative push的 routeInformationProvider URL。依已安装GoRouter公开API改用 `router.state.uri.path`，仍断言实际目的页类型与返回，不更改产品路由规则。 |
| run-04 | 联合13 PASS，exit0。 |
| run-05-final / run-06-analyze | 补窄屏按钮及无虚构百分比/身份证要求断言后13 PASS、窄分析exit0。 |
| run-07-final-bytes / run-08-analyze-final | 保持父对象LF换行，逐字节确认其它Me类未改；最终提交字节对应13 PASS与窄分析exit0。 |

另外，定位时尝试读取不存在的 `verification_status_entity.dart`，随后从已读 import 找到真实 `verification_state_entity.dart`；没有执行或写入。一次其它Me类的原始字节比较因候选Windows CRLF与父Git LF不同而失败；确认文本无其它改动后保留父LF，重新字节核验及最终测试，未降低断言。辅助只读代码审查未发现必改问题；其未独立运行测试，不替代 Astra。

完整安全 stdout/stderr 与退出码在 `evidence/run-*/`。本地原始字节保留；发布副本仅替换绝对本机路径并规范化文本换行，receipt同时记录原流与发布流SHA256。没有删去失败/栈/退出码，没有上传账号、凭据、真实用户数据或历史私密EVIDENCE。

## 源与保护身份

[baseline-identities.json](evidence/baseline-identities.json) 记录父Tree、冻结计划、当前规则和关键源Blob，以及依赖图来源。复用 `baseline64` 既有 `.dart_tool/package_config.json` / `package_graph.json`，只在候选忽略目录重映射本包root；pubspec.lock相同。Flutter3.41.7、Dart3.11.5、Riverpod3.3.2、GoRouter16.3.0。未运行pub get、未下载或升级SDK/依赖、未启动生产或设备。

[protection.json](evidence/protection.json) 前后核验：

- 原 `D:/EliteSync-v10` HEAD `4bebc8f394248e254c1368a06fbdee5d2c883301`；index SHA256 `2be660029a2e2c2578f5193bc050dee35be3e71ce941460a42331babf577e716`；status SHA256 `a00c2102dde4c87579208cf8479086674fa4eba2e082910f7463eb59eac6cf65`。staged0、tracked43、untracked normal208保持，109具名文件零变化。
- `baseline2175` HEAD `2175dd62d9384efa05dd6b5201f58c5282379fbb`、index `abf3fd0cc96b43daed0bfc98e5d38cb3144f10fc8392cb631f3aa8fb82066251` 保持，CLEAN。
- `baseline64` HEAD `64a098f88543efa44b499d04cb91d4c7c4290238`、index `73b7843f7c6217fec8055f5e4f5bdc38ef89c32285be860b25d6fdf8374086ee` 保持，CLEAN。

仅登记新候选worktree；未清理旧worktree、未吸收旧LOCAL_ONLY、未改变原root/默认index/历史EVIDENCE。未修改任何Guard/Router/Home/Progress/验证/问卷业务源码、后端或Chat权限。有限manifest不重验巨量历史资产。

## AC映射与保留缺口

| AC | 本地作者交付依据 |
|---|---|
| AC-01 | 固定单父、源身份、三树HEAD/index/status与109文件保护；无LOCAL_ONLY复制。 |
| AC-02 | 原用户页新增动态来源/正式条件未知解释及兼容恢复用途；其它Me类字节不变。 |
| AC-03 | UNKNOWN不合格区分、Synthetic显著标识、异常READY降级、动态旧成功清除、无成员清单或资格写入。 |
| AC-04 | 真AppRouter/AppShell入口、真实目的页/pop、公开路由state断言、320px/2倍字可读与可点击定位；受控依赖0外部/0写。 |
| AC-05 | 最终13项测试exit0、两文件窄分析无问题exit0；失败序列原样保留。 |
| AC-06 | 固定GitHub candidate/tree及有限manifest、代码/测试、安全日志、receipt与保护对象可读取。 |
| AC-07 | **PENDING_ASTRA**；未自接受、未合并main、未自动开始v10.0.5或集成后继。 |

`NOT_RUN`：PHP/DB/BE-12 Feature、完整Router42、全App、Android/设备、Profile/Release、生产/真实用户操作。`UNKNOWN/NOT_PROVEN`：正式required/optional成员、最低身份保证/准入、真实Readiness撤销/过期来源、成员时效、真实数据权限、旧问卷草稿恢复完整行为。本版不把后端synthetic五字段接入客户端，也不把Dev READY称生产资格。旧兼容验证页文案未重写，恢复入口明确限定用途。

**V10.0.4 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE — NO MAIN MERGE / NO V10.0.5**

BE-12默认拒绝、V57/H1/H2/D0暂停及正式运行/真实数据边界保持。验收后的安全定点集成与新本地基线按独立K08流程接续，不由本交付自接受或立即执行。
