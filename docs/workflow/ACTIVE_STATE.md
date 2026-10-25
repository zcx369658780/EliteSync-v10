# EliteSync-v10｜唯一当前状态入口

**2026-10-25最新状态：V10.1.5_CANDIDATE_DELIVERED / ASTRA_BOUNDED_RTC_FIX_ACCEPTED_WITH_OBSERVATIONS / OVERALL_PARTIAL_AC05_OPEN / PRODUCT_MAIN_NOT_INTEGRATED。** Astra已独立复核候选 `c445554f01fbd8c9aef641302f3f090900703786` 中的RTC连接取消、迟到诊断endCall及旧heartbeat竞态修复，接受此范围内的源码逻辑与定向单测报告。整版仍未接受，AC05仍OPEN；当前候选未集成main。

**Astra裁决：** [D0-C RTC取消/迟到回调竞态独立复核](../versions/v10.1.5/D0_C_RTC_CANCELLATION_RACE_FIX_ASTRA_REVIEW_20261025.md)，Blob `d66c5b0ce1c4999698e56d2075e9f43b23d698c5`。本次接受仅限RTC竞态修复，不代表新APK、真实SFU媒体、物理AEC或整版功能已接受。

**当前候选与交付：** [Commit c445554f](https://github.com/zcx369658780/EliteSync-v10/commit/c445554f01fbd8c9aef641302f3f090900703786)，唯一Parent `67f83b053096b181ff64366f3eaad0e5e44815f8`，Root `a964881253000ed86601978d136dfba5820606fc`。候选apps Tree `e9ed3a1dee4c892840831b0e31f6f96669fa17d5`，services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`；报告Blob `521b1d5e7851a40e98361887b8fe8117a51c5305`，Manifest Blob `90a0da0c305016be742d8a131356b368fab10121`。Dart源码Blob `1abe844a83eb6f48e0718ac361778df73127ca00`，RTC测试Blob `e23a875d0a04044c4c0227868b0f46f8e86b5a14`，ICE诊断测试Blob `6a125584204890209f60716b8264c9f7710d92f6`。

**测试证据等级：** Codex报告RTC/路由普通测试95项通过、ICE诊断开关11项通过、三文件分析exit0；四项在普通与诊断运行间重叠，不重复计数。Astra直接静态核验attempt身份、generation/Room/callId heartbeat guard与迟到诊断endCall清理条件；未直接执行本地测试、未构建/安装当前APK，未运行真实SFU媒体或物理AEC。AC-10.1.5-05保持`PARTIAL_CORE_OPEN`。

**Gate 2仍阻断：** 最近报告的PowerShell 7启动在Writer调用前因`System.TypeLoadException`缺少`System.Web.UI.WebResourceAttribute`失败，耗时0.390秒；旧Windows PowerShell执行策略拒绝耗时0.375秒。两次预算都保持已消费；正负例、Writer、Serializer、fallback均`NOT_RUN`，无receipt。不得重试原入口、修改系统策略或绕过限制。完整37案例suite、Sandbox SDK、Producer、`libs.jar`与30项`Configuration.resolve()`均未运行。

**当前唯一综合任务单：** [v10.1.5 task_order.md](../versions/v10.1.5/task_order.md)，Blob `d737c3a813d81ada7a9ca9a60aa310e9e14e0960`。继续遵循一份长任务单＋中途无监督模式：Codex可在冻结范围内推进与Gate 2无依赖的功能、测试与普通修复；Astra在整版集中交付时一次性验收。不创建重复微任务、不自动集成main、不启动v10.1.6。

**产品基线保持：** 已接受产品仍v10.1.4，apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110`、services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。v10.1.5仍`PARTIAL_NOT_ACCEPTED`，AC05 `OPEN`；ICE诊断标志未证明、旧guest状态未知、无当前候选APK验收、无main产品集成、v10.1.6未启动。

**写入前live main：** `62413870a36b878f7da77f1f28f83078c30ae504` / Root `477e9a02edc7b52146a82164261d247516993c84`。本次ACTIVE_STATE更新会推进main；最终live身份以本轮最后一次回读为准。

## 已独立核验的产品和集成

- **v10.1.2已完成双重接受**：[Astra功能独立验收](../versions/v10.1.2/acceptance.md)＋[Astra单次安全集成独立验收](../versions/v10.1.2/integration_acceptance.md)。B1未受控正式关系请求、B2退出/换代际旧提案两个P1在同版R1关闭；无需R2与另一次集成。
- 受控开发接受源码Commit `88ffeccce4042f13ce4edccf7604b835b06c8f2d`，Root Tree `42052f5f9ee596f82cf525884e1f77256fc7727b`；**v10.1.2历史main接受产品apps** `365810451b6faad98e041835be6c86f4f81be0a9`，**services** `96b2972a19ec49108cf5c11d144179e5693570a9`。产品集成Commit `fe8081d4de906018736d026bde1a40d956ab223e`，唯一Parent `87fcbc63c5703a20892177183d723640ca894171`。独立集成验收使用的最终main `418dd43acb2ef7a3bd279c40fc3821c4a0a234e2` / Tree `15ec973a95106cfbda7d297e9a2e6aa805b55fce`；该版本之后的历史文档与接受原件保留。
- 47个产品变更path/mode/Blob完整匹配，集成后继仅18个文档路径。Astra直接核GitHub对象/源码与正式文档；**LOCAL_CODE_BASELINE**由Codex回报本地干净/HEAD相等（`CODEX_REPORTED / LOCAL_ONLY`），**RUNTIME**本轮未重新启动DB/API/APK/RTC，不能宣称重新验收物理运行。
- 原正式报告与manifest见[集成报告](../versions/v10.1.2/integration.md)。v10.1.0整版`PARTIAL/NOT_ACCEPTED`及AC-10.1-08 PARTIAL，v10.1.1误清库/恢复历史、v10.1.2原失败、RTC/AEC与外部Web缺口保留。`REAL_IDENTITY_PROVIDER_PENDING`，合成`TEST_ONLY`不代表真实实人。

## v10.1.3 功能及安全集成均已独立接受

**两道Astra裁决：**[v10.1.3功能接受](../versions/v10.1.3/acceptance.md) `V10.1.3_FUNCTION_ACCEPTED_WITH_OBSERVATIONS`；[v10.1.3单次安全集成接受](../versions/v10.1.3/integration_acceptance.md) `V10.1.3_INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`。冻结MEAL/STUDY独立搭子、好友动态一级评论与相关隐私使用点在受控开发范围正式收口；**不等于生产、实名供应商、真实手机或公网已验证**。

- 唯一接受源码Commit `e27db2012e2c57390c4da179330552a6b64a728d`／Root `cf670270aaac7d641d58939eaea7737c23b89417`；最终main完整apps `d4569b330629d74c6e5f3ee1d6438245d7bfd024` 与services `4d637a3fd827e00974887d9ce515a1833a8f3a8a`。产品集成Commit `3f1c29e56b8d68ebda56c3564f9d4fceb907fd07`，唯一Parent `05a88fde79a5849d57378d3d701732afe13190fc`，34条产品path/mode/Blob全部一致。独立集成验收核验的最终main `cd5d76a400c19223ca8a6aee60b5947695a81c56`／Tree `fb4e965061cec3933a0920bcefcd5fefc8560087`，其后仅正式Astra验收与短状态文档前进，实时HEAD仍须重新查询。
- [唯一集成报告](../versions/v10.1.3/integration.md)／[原实施报告](../versions/v10.1.3/IMPLEMENTATION_REPORT.md)／[制品清单](../versions/v10.1.3/artifact_manifest.json)归档原字节。Codex本地代码树HEAD与交付main一致且干净、五保护根和六件SQL/APK不变为`CODEX_REPORTED/LOCAL_ONLY`；本次DB/API/APP/APK/RTC功能重新运行均`NOT_RUN`。
- 保留真实通知点击GUI未单独验证、Buddy双进程并发不等于双HTTP、原MariaDB旧失败和其他历史限制。v10.1.0 PARTIAL、v10.1.1事故恢复、v10.1.2两P1修复、真实实人供应商PENDING均不清零。

## v10.1.4 功能和安全集成都已获Astra独立接受

**Astra直接归档[v10.1.4独立功能验收](../versions/v10.1.4/acceptance.md)：`V10.1.4_FUNCTION_ACCEPTED_WITH_OBSERVATIONS`，R1_B1/B2均CLOSED。** 冻结平台虚构活动／预算模拟及内部Safety报告→具名调查→申诉复核功能在受控开发范围成立，非真实线下活动/生产/资金/实名/外部模型授权。

- 接受唯一R1源码Commit `1062603bfd5866eb4c40b4773657343a1eca2af7`、Root Tree `aa4c47569d60a5e5638c25e9b0e3c0d7e1760da5`、**apps** `3468a3dd97da7accfda2539a0f8d8f68931a6110`、**services** `0cb1f9d19659291a462488b3686fd0a07a6698ac`，最终交付 `01622dfffc48649911fd88f0cd0a9ed340260d37`。原首轮源码、实施报告前缀、原／R1清单及39+36件短期脱敏审阅全部保留，本次产品集成提交 `759015ad0c897c92516531c2f3a94a3a7ff77c02` 的唯一Parent为执行前live main `6b2cd44065830fb7b38bfaa36a168989da0fb248`，完整接受apps/services已精确接入；最终发布身份与回读见[唯一集成报告](../versions/v10.1.4/integration.md)。**Astra已直接复核并归档[本版安全集成独立验收](../versions/v10.1.4/integration_acceptance.md)：`V10.1.4_INTEGRATION_ACCEPTED_WITH_OBSERVATIONS`。** 集成交付main `1390772c8fee62509504b90b5f702582cdc39c4a`／Tree `7be2f9a80e68909d807ae4950ff7d574123555ef`，产品提交的唯一Parent为实时执行前main；39/39路径/类型/mode/Blob和完整1420产品文件的两子Tree经GitHub直接核验。后继只改5份文档；此验收后仅新的Astra正式归档与状态文档前进，产品代码不变。
- B1：本人已真实参与原虚构活动且安全退出/被Block后，7天`REPORT_ONLY`内可提交最小Safety投诉，旧活动详情仍404，举报不自动Finding。B2：已合法收案只封存本案最小历史参与事实，内部授权Web理由访问/审计/分流/调查/驳回可继续；历史记录不等于实人线下事实，纯历史下认定/处罚422，旧私人资料没有恢复。
- R1 9/9改变产品path/mode/Blob与接受源码Git Tree逐一精确，36/36R1审阅Git Blob与清单一致。定向backend28/1644、Flutter15、精确MariaDB RR99/98撤权401、相关10表重启一致、重建APK安装回取hash均由Codex受控执行，Astra只读源码及脱敏摘要（`CODEX_REPORTED/LOCAL_ONLY`）。原51/1182＋Flutter30＋87表恢复证据保留，没有在本轮全量重跑。原历史5失败、2+2告警与以前事故继续保留。
- 7天`REPORT_ONLY`、30天`CASE_INVESTIGATION_ONLY`是**TEST_ONLY开发默认，非真实投诉/证据保留法律规定**；真实严重单案、实人认证供应商、活动/支付/外部AI/公网/手机RTC、通知GUI仍有明确外部或测试门禁。

**唯一下一门**：v10.1.4的功能与单次安全集成两道独立裁决均已完成，Codex原集成报告为[固定原件](../versions/v10.1.4/integration.md)。本轮只重新核验GitHub精确对象，DB/API/Web/AVD/APK/RTC等`NOT_RUN`；本地连续代码基线与保护资产`CODEX_REPORTED/LOCAL_ONLY`，并不等于生产运营许可。

**v10.1.5目前NOT_STARTED且无Owner授权**，只有Owner另行批准才能冻结新计划和派发Codex；7天报告/30天存证仍是TEST_ONLY开发默认，真实运营、支付、场地、实人供应商、事故审核及法定保留期都未获批。不清理历史候选、审阅分支、数据库或APK。

## 项目源与工作流分层

- 2026-10-21 ZIP原件SHA256 `6781b7e8319037770780cfb202b6f37071031d8c9cec0bb969e39cf082c65c6f`：Astra本轮可直接读取，并验证内部MANIFEST及五篇正文与README的字节hash均匹配。上次Codex本地未获得，所以`docs/gpt-project-sources/20261021_v1012/`只有**语义候选**，**原ZIP精确GitHub镜像仍PENDING**，不影响已接受产品或新版本开发。本次Owner已经报告**ChatGPT项目源手动更新完毕**；GitHub同步与账户Memory、当前Project附件是真正不同的状态，不反向假定仍未上传。
- 受控原ZIP精确镜像可在本版综合任务里、当Codex实际获得原文件时完成；不为了缺Zip重开集成或另办治理长任务。原20261019资料、06/07设计接受、08 Owner决定、09路线和全部原证仍保留。
- [当前工作流](CURRENT_WORKFLOW.md)及[轻量治理补充](ACCEPTANCE_INTEGRATION_SOURCE_SYNC_20261021.md)仍生效。Owner对产品/真实数据/费用/系统不可逆操作最终决定，Codex收到手动任务后在冻结范围内自主实施，Astra独立验收。临时Review分支、SQL/本地APK及原dirty根不因文档更新而自动清理。
