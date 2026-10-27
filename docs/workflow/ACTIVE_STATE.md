# EliteSync-v10｜唯一当前状态入口

**2026-10-27状态：AAR_DOKKA_STATIC_INVESTIGATION_TASK_PREPARED / OWNER_MANUAL_DISPATCH_PENDING / V10.1.5_PARTIAL_NOT_ACCEPTED / AC05_OPEN / ACTUAL_BUILD_NOT_COMPLETED / ROOT_CAUSE_NOT_PROVEN / SINGLE_REAL_BUILD_BUDGET_EXHAUSTED_1_OF_1 / GATE2_NOT_AUTHORIZED / PRODUCT_MAIN_NOT_INTEGRATED。** Owner已经同意针对 Flutter AAR / Dokka 文档生成任务的依赖链展开单次静态调查。Astra已只读检查仓库脚本：外层`syncFlutterAar`直接调用嵌套`assembleAarRelease`；当前`offline_debug.init.gradle`只移除javadoc发布artifact，不禁用Dokka task。先前历史日志出现`connectivity_plus:javaDocReleaseGeneration`，但不能据此判定Dokka发起非回环TCP。本轮没有真实构建、设备/网络观察器或源码修复授权。

**唯一静态调查任务单：** [V10_1_5_AAR_DOKKA_STATIC_DEPENDENCY_INVESTIGATION_TASK_20261027.md](../versions/v10.1.5/V10_1_5_AAR_DOKKA_STATIC_DEPENDENCY_INVESTIGATION_TASK_20261027.md)，Blob `516eb555c26a13bb82e24e16d371826170ec9559`，所在独立分支 `owner/v10.1.5-aar-dokka-static-investigation-20261027`，创建任务文档Commit `32a3ac9ff65e805ec3de4aa4ecc3858350aa5ee8`。待Owner手动派发Codex；建档不等于Codex任务已执行。本分支只含文档/状态，不合入产品main。

**上一轮已接受有界只读报告：** 文档候选 `7abea213feacc52a1e43c6ed58a40c83009c74df` / Parent `cfddecc944a043b1d85361a954a692be0dd4ce23` / Root `8a7775c97f3161f2f6f54d6499deba584349f307`。新增报告Blob `72975510872fbe3251caf1b8ddbd687761165d88`，Astra复核Blob `6a7dc815eadd6950d793727b1d2679026411d5bf`。apps Tree `cea01309fa9da5f99ccc9829654c6ec279c8c343`，services Tree `21eebf69bbc6397b1562d40f8cd9ebd7b246720f`；源码未变。冻结计划Blob `7d3466b3be67135dc641cfee7c7faef78937ba03`。上一轮live main `4df2e7f0f36cc7b80258faa73e80dad682cff6c5` / Root `03b0ecfcc360e38a462539dd50690c64b663a21e`，开工前必须fresh GET。

**当前关键未知：** 旧原证支持TCP owner PID的父链回溯构建根并连续出现，但同一进程实例/具体组件未证明；Dokka是否由Flutter AAR publication finalizer/dependency引入仍需沿实际缓存中的Gradle插件源码与任务输出做静态分析。即使发现依赖路径，也不能据此把Dokka认定为TCP发起者。

**绝对停止线：** 已用的真实构建预算1/1不重置；不运行Gradle/Wrapper/Flutter/AAR/Kotlin、`gradle tasks`、`--dry-run`、实时观察器、设备/ADB、Docker、RTC、Gate2/Writer/Serializer，也不改动源码/系统策略/依赖缓存。历史partial 7,941,328字节及Hash、旧refs、SQL/APK、LOCAL_ONLY原证保留。不得自动发布下一修复任务、重跑构建、合并产品main或启动v10.1.6。AEC、最后可闻波形、native handle普查、真实15/30天与物理30天清理和真实Push持续开放。

**产品接受基线：** v10.1.4 apps Tree `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services Tree `0cb1f9d19659291a462488b3686fd0a07a6698ac`。v10.1.5为未接受候选而非产品main。

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
