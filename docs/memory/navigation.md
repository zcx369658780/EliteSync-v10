---
title: navigation
type: note
permalink: elitesync-v10-local/navigation
---

# EliteSync-v10 记忆导航

## Owner任务单启动 Prompt 格式（2026-10-23）

Owner于2026-10-23明确要求：**每次Astra发布供Owner手动派发给本地Codex的综合任务单时，给Owner的最终回复必须同时提供一个可直接复制的Markdown代码框启动Prompt；不能只给GitHub路径或按钮。** 历史`docs/migration/ASTRA_HANDOFF_20261018_V10_0_10_K08_APPROVED_PENDING.md`已经记录原有格式偏好：**单一代码框；不用“PROMPT开始/结束”包装标记；启动Prompt内部不嵌套多重反引号代码框**。这是交付展示规则，不改变Owner/Codex实际权限。

推荐顺序：简短结果和固定Git身份／任务链接 → **一个独立的三反引号纯文本代码框**（可直接整体复制到Codex）→ 必要的停止边界提示。启动Prompt至少包括：项目与本地仓库身份、**任务单的实际固定路径与Blob**、优先完整读取的权威入口、仅执行该任务的范围／上限及STOP门禁、保护资产及不能擅自变更的权限、集中交付与等待Astra审阅。**不得把代码框中的摘要当作完整任务单**，以已发布固定Blob的任务正文为执行合同。Owner仍负责手动派发；Astra提供启动词不意味着任务已执行或获取新的系统／设备／供应商权限。新会话首读本导航时应继承该格式偏好，除非Owner明确改动。

**2026-10-21最新交接：** 当前顾问会话已封存[完整Owner决策、版本状态和下一会话入口](../workflow/SESSION_HANDOFF_20261021_V1014_ACCEPTED_V1015_PENDING.md)。v10.1.4功能及安全集成均`ACCEPTED_WITH_OBSERVATIONS`；下一版v10.1.5尚待Owner在新会话授权，**不要据旧快照重复派发验收或自动启动计划**。实时状态以[ACTIVE_STATE](../workflow/ACTIVE_STATE.md)为准。下文较早“当前”仅保留历史证据。

**2026-10-21当前里程碑：** v10.1.4[功能](../versions/v10.1.4/acceptance.md)与[单次安全集成](../versions/v10.1.4/integration_acceptance.md)双重独立`ACCEPTED_WITH_OBSERVATIONS`；已接受 apps `3468a3dd97da7accfda2539a0f8d8f68931a6110` / services `0cb1f9d19659291a462488b3686fd0a07a6698ac` 已进入main，产品集成Commit `759015ad0c897c92516531c2f3a94a3a7ff77c02`以 `6b2cd44065830fb7b38bfaa36a168989da0fb248`为唯一Parent，集成交付main `1390772c8fee62509504b90b5f702582cdc39c4a`。本轮静态集成，DB/APP/APK运行NOT_RUN；本地代码基线/保护仅CODEX_REPORTED。真实活动和安全政策、7天/30天TEST_ONLY、实人供应商及GitHub原ZIP字节镜像仍待定。v10.1.5尚未获Owner授权；首读[ACTIVE_STATE](../workflow/ACTIVE_STATE.md)，下文旧“待派发”均是形成时的历史。

**2026-10-21最新功能门：** v10.1.4首轮候选已交付但**Astra裁决`CHANGES_REQUIRED / NOT_ACCEPTED`**，两个具名Safety问题需同版R1：[正式审阅与任务](../versions/v10.1.4/ASTRA_REVIEW_AND_R1_TASK_20261021.md)。B1自愿退出后无法提交最小关联Safety报告，B2合法收案经Block/退出撤权后内部可审计最小案卷不能继续调查。两者为GitHub源码反例，Astra未在Windows本地重跑；其它51/1182、Flutter30、RR、87表及APK成果保留。v10.1.3产品仍是接受main，v10.1.4未合main、v10.1.5未启动。唯一实时入口[ACTIVE_STATE](../workflow/ACTIVE_STATE.md)覆盖历史“当前”；Owner需要手动派发R1任务。

**2026-10-21当前后继：** [ACTIVE_STATE](../workflow/ACTIVE_STATE.md)是唯一首读事实。Owner批准进入v10.1.4，Astra已冻结[平台活动与内部Safety计划](../versions/v10.1.4/plan.md)及[Codex综合任务](../versions/v10.1.4/task_order.md)，**须Owner手动转交本地Codex才实施**。基线v10.1.3功能＋集成两道独立验收完成，main apps `d4569b330629d74c6e5f3ee1d6438245d7bfd024`、services `4d637a3fd827e00974887d9ce515a1833a8f3a8a`；本版只允许合成活动预算/报名、安全举报→人工判定→申诉纠错，真实招募/付款/外部AI未授权。历史PARTIAL/事故/供应商/ZIP镜像缺口继续保留；下方旧“当前”均是形成时快照。

**2026-10-21当前里程碑（覆盖下文旧“待集成/未派发”）：** v10.1.3[功能](../versions/v10.1.3/acceptance.md)及[单次安全集成](../versions/v10.1.3/integration_acceptance.md)均由Astra独立`ACCEPTED_WITH_OBSERVATIONS`；main接受apps `d4569b330629d74c6e5f3ee1d6438245d7bfd024`、services `4d637a3fd827e00974887d9ce515a1833a8f3a8a`。Codex本地连续代码基线及原资产保护为CODEX_REPORTED；安全集成运行NOT_RUN；GitHub原ZIP byte mirror仍PENDING，但Owner已报告手动更新ChatGPT Project Sources。下一版v10.1.4未获实施授权；当前唯一真值入口[ACTIVE_STATE](../workflow/ACTIVE_STATE.md)，下文历史快照不可据此重新派发旧任务。

## 2026-10-21 当前长期导航（新会话优先读这一段）

**当前单一状态真值：[docs/workflow/ACTIVE_STATE.md](../workflow/ACTIVE_STATE.md)**。v10.1.2功能由Astra直接接受，完整apps/services已按Owner单次任务集成main；[唯一集成报告](../versions/v10.1.2/integration.md)，仍待Astra独立安全集成验收。接受源码 `88ffeccce4042f13ce4edccf7604b835b06c8f2d`，apps `365810451b6faad98e041835be6c86f4f81be0a9` / services `96b2972a19ec49108cf5c11d144179e5693570a9`。本地仅代码基线接续，运行NOT_RUN；项目源ZIP未取得，仅[有界语义候选](../gpt-project-sources/20261021_v1012/README.md)，BYTE_MIRROR_UNVERIFIED，ChatGPT附件/账户Memory未自动修改。原v10.1.0 PARTIAL/AC08、v10.1.1事故及本版历史失败保留；v10.1.3未启动。下方旧段是历史快照，不按其过时状态重派。

---

## 2026-10-14 当前检查点：Astra换会话，v10.0.6后续在新会话终验

Owner已要求立即保存当前任务及决策，并由新Astra会话验收最近交付的v10.0.6执行Prompt的结果。[本轮交接正文](../migration/ASTRA_HANDOFF_20261014_V10_0_6.md)是最短恢复入口，不是新任务。旧Astra没有收到本版实施回执或候选；Owner转发及Codex实时运行状态UNKNOWN，若已经执行，不因换顾问中断或重复派发。当前/新Astra会话ID无法取得则UNKNOWN，不重新审projectId或旧会话全部日志。

v10.0.6唯一冻结正文：[plan固定版本](https://github.com/zcx369658780/EliteSync-v10/blob/dbe02b9ba603b79820f77ee28663787e405ccc4f/docs/versions/v10.0.6/plan.md)，冻结commit `dbe02b9ba603b79820f77ee28663787e405ccc4f`，Blob `77eee557325449543710fc4d5fe2b10aa712fa46`。代码起点仍`3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`，Tree`59969abfc9d04185769b22af5f7ea5d629007a33`；允许专用同树分支、多次提交，不把顾问归档commit当新技术起点，不重拟AC-01～07。

本版两条真实链：APP独立保存城市→users.city→重进/重登/服务与数据库重启读回；Blade管理员登录/查询/禁用→状态与token/session失效→APP拒绝，普通用户不能管理且正常对照账号不受影响。真实APP/浏览器/API/持久数据库同账号证据不能由Widget或curl替代。具体环境、权限及终验核查见固定plan和交接。

## 已批准Owner方向与长期工作方式

v10.0只有两个核心交付：**选定原版APP前端/后端/数据库和主要功能恢复＋独立可用Web管理面板**。新产品扩展和公开运营准备后置，不因旧Later标签省掉选定原版已实现功能，不再重设计优先或长期一页一版。准确来源见[PRODUCT_DECISIONS](../../PRODUCT_DECISIONS.md)、[路线图](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[恢复台账](../architecture/RESTORATION_CAPABILITY_MATRIX.md)。

Astra长期规划/独立终验/复盘；Codex手动派发后的冻结模块内自主调查、实现、普通修复和测试；Owner方向及重大取舍，旧Work/dot实时监督不恢复。按功能跨前后端/数据库/Web修改，不先开连续来源/环境审计版本。K08验收后集成与本地接续保留，现行[工作流](../workflow/CURRENT_WORKFLOW.md)不强制每轮新worktree、单提交、固定历史保护数量或纯文档更新后重复测试。

后续0.7主要APP、0.8后台模块、0.9联合验证、0.10完整软件/算法/操作说明为未冻结路线包。Owner半年至一年内测运营安排在完整交付后，不用版本数预测公开运营。已有v10.0.0～0.5限定接受保持，不重裁也不提升为完整恢复。

## 最近本地现场（CODEX_REPORTED，非网页实时磁盘检查）

专用路径`C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10`，最近版前分支`codex/baseline-v1005-be0636e`、HEAD3a78c2c、CLEAN；正式实施允许源码和HEAD正常推进。原`D:/EliteSync-v10`根保持HEAD4bebc8f和默认index，路线同步八正文一致、AGENTS保留有效本地补充、范围外105项保护不变。105/109或11树各属当次回执，不能变成未来永久门。精确进度见[CURRENT_STATE](../../CURRENT_STATE.md)，网页没有C:/D:本机访问。

版前已报Docker管道不可用、现有3306 MySQL、SDK镜像/备份元数据存在，运行与备份可恢复性仍未证明。正式派发允许已有Docker启动、独立MariaDB10.11 43316库/volume、Laravel 8000、三个虚构账号、依锁包下载、专用AVD/ADB、debug APP构建安装与本地浏览器操作；不因此允许原3306、旧SQL/VHDX内容处理、生产数据、额外系统安装/提权或升级。普通环境问题同版修复，风险只停对应部分，旧暂停任务不复活也不当新授权前置。

## 按需知识与既有检索路由

[动态目录](../../DOC_INDEX_CURRENT.md) → 本轮交接/当前状态 → v10.0.6固定plan → 当前工作流/路线和必要台账。旧算法或环境才读[knowledge.md](knowledge.md)、[environment.md](environment.md)、[archive](archive-20261012.md)；不重建全量sessions、图谱或recall库，旧K08～K12按当时范围解释。

- Basic Memory：既有 `--project elitesync-v10-local --local`；`BASIC_MEMORY_CONFIG_DIR=D:/EliteSync-v10/.local-memory-state/basic-memory`、`BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false`。部分历史覆盖，不假设完整规则镜像，不切共享default或下载模型。
- QMD：named index/collection为elitesync-v10-memory，显式指定；原docs/memory索引不假设随新树同步，不为交接重建。
- 图谱D-EliteSync-v10未命中时直接读取已确认的工作树源码，不推导文件不存在。不涉及HANK/Zotero等其它项目。

[交接前导航](https://github.com/zcx369658780/EliteSync-v10/blob/dbe02b9ba603b79820f77ee28663787e405ccc4f/docs/memory/navigation.md)保留原冻结时环境与身份；旧Astra未收到候选不证明Codex未运行。新Astra入场先确认读取，再接收Owner转来的候选或具体阻塞，不新建版本、重复同步或恢复旧监督。
