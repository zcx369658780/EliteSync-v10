# EliteSync-v10｜v10.0.5 事实复盘

日期：2026-10-14。对应 [Astra 独立验收](acceptance.md) `ACCEPTED/CLOSED WITH OBSERVATIONS`。本复盘不修改 [冻结计划](plan.md) 的 Blob `fd490f9204869504a17ae5b4263bc25e7a5a6f74`，也不启动 v10.0.6。

## 1. 冻结目标与实际交付

| 目标 | 实际成果 | 保留边界 |
|---|---|---|
| Progress 从静态入口增加阶段摘要 | 一个 Progress 源文件改为 ConsumerWidget，复用既有 Home 聚合器，显示 Readiness/Match/Connection 三域与来源 | 未建立第二套权威 provider，未显示 Conversation 第四域或复制 Home 的消息 nextDecision |
| 未知与失效不制造结论 | 未建立/未知/空/未识别代码显示“当前无法确认”；Match 六类负向条件清除旧提案；Connection 暂停/关闭替换 active | 不区分来源没有提供的 noCandidate/noRound 细节，不新增正式Readiness、撤销或身份政策 |
| 真实导航与页面可用 | 保留两个原入口/key/go；新增既有 Readiness push/返回；真实 AppShell/Router 状态变化和 Guard 回退、320px/2倍字滚动后可点击 | Widget模拟环境，不等于实机或Profile/Release |
| 有限回归和安全 | 新19项 + 相关旧32项 = 最终51/51 PASS；两文件分析明确No issues found、exit0；新增19项受控哨兵含卸载后检查 | 零调用证据不等于所有旧测试、全应用或OS的全局审计 |
| 独立交付 | 固定候选 8ff52dd6ef56d25e575aba10e109c1ab03ef2a6c，sole parent 4a7091b580977044861ae50ff9b404842ed68283；23项payload Git Blob逐路径核验一致 | 原Windows工作树保护为Codex回执，网页未本机重跑 |

## 2. 本版出现的问题与处理

1. **新增内容影响了既有入口可点击性。** regression-01 的旧真实Router用例期望进入 `/progress/match`，实际停在 `/progress`；日志显示点击位置在首屏外。作者没有改旧测试或屏蔽点击告警，而是把原入口保持在摘要前方。
2. **懒构建和测试滚动定位不匹配。** progress-01 为18 PASS/1 FAIL，combined-02 为46 PASS/5 FAIL。最终有限内容改为 SingleChildScrollView/Column，新增测试定位前重置其 viewport，并真实检查 hitTestable/tap。测试级滚动重置不是产品强制丢弃滚动历史。
3. **分析退出码不充分。** analyze-01 的 exit0 仍附一项 prefer_initializing_formals；作者已在交付前修成 `this.textScale` 初始化，并按最终文件身份重跑51项及分析。最终stdout为No issues found，避免了v10.0.4需要终验后R1返修的同类误报。
4. **隔离须涵盖卸载阶段。** 最终新增19项在业务期间以及 Widget 卸载、ProviderContainer dispose 后检查受控外部provider/存储写入，HTTP内层zone先做拒绝探针再检查业务计数0。源代码、测试和日志支持这一有限证明。

所有运行尝试和旧lint输出在固定候选中保留。原始本机流和已发布路径脱敏流分别有SHA256，不能混称相同字节；网页独立审查的是可访问的发布证据，不是未公开的本地raw副本。

## 3. 可核数量与未知

最终五份测试文件：Progress19、synthetic Home loop11、动态Guard15、synthetic Connection lifecycle4、Connection page2。测试命令、退出码、时间和最终两个文件SHA见候选 `evidence/run-receipts.json`；完整开发时间、额度/token、不可观测的等待成本 UNKNOWN，不从几秒运行时间推算整体开发效率。

候选相对父提交24个变化路径（包括manifest自身），manifest payload23项。产品源变更统计受LF→CRLF影响，不能把Git逐行重写计数当作功能规模；实际业务变更限Progress消费与展示。旧源、旧测试和业务权限未随本版修改。

保护回执记录10份既有工作树HEAD/index/status前后一致、109项具名文件不变；该报告并非全量历史EVIDENCE或全部本机文件审计。新候选CLEAN由Codex回报。

## 4. 工作流与后继

本版完成一次冻结范围内的自主实现、布局修复、分析lint自纠正与集中交付；Astra 首轮终验无需追加R1。核心工作流无需再增加审批、固定测试配额或新的治理角色。

按已批准K08，验收后仅定点集成两个接受的代码/测试Blob，候选完整原证留固定引用；Owner手动转交Codex建立或无损接续新的干净隔离开发基线并运行本版五文件51项和两文件分析。远端集成、本地CLEAN与集成后真实运行分别登记，原脏主树不动。

正式业务状态源、Readiness集合、身份保证与准入仍UNKNOWN；全应用、后端/BE-12 Feature、Android/设备、Profile/Release、生产与真实账号均NOT_RUN。BE-12默认拒绝和V57/H1/H2/D0、M6边界保持。**未启动v10.0.6。**
