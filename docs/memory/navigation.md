---
title: navigation
type: note
permalink: elitesync-v10-local/navigation
---

# EliteSync-v10 记忆导航

## 最近检查点：路线同步完成，v10.0.6等待集中执行方案

2026-10-14，Codex执行并由Owner回报：专用clean基线C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10，分支codex/baseline-v1005-be0636e，已fast-forward到3a78c2c81859db682369fd6e03f6d98a3c2bbeb2，Tree 59969abfc9d04185769b22af5f7ea5d629007a33，CLEAN，九份路线文档相同，没有新worktree。D:/EliteSync-v10启动根八份正文一致，AGENTS保留仍适用的本地补充；原HEAD/index不变，九份文档之外状态及105项保护不变。本机receipt.json尚未由网页读取，以上本地信息属于CODEX_REPORTED。

同步完成，不重复派发九文档同步或基线维护。接下来按[v10.0.6版前方案](../versions/v10.0.6/PLAN_PROPOSAL_V0_1.md)集中确认真实开发服务/数据库、APP安装及首个Web管理操作的执行方案；尚未冻结或派发实现。当前精确状态与证据范围见[CURRENT_STATE](../../CURRENT_STATE.md)，后续纯文档提交不会自动移动此本地HEAD。

## Owner现行决定：恢复APP与独立Web管理

v10.0只优先完成**EliteSync APP前端、后端、数据库及选定原版主要功能恢复＋真正可用的独立Web管理面板**。准确方向见[PRODUCT_DECISIONS](../../PRODUCT_DECISIONS.md)、[路线图](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[恢复台账](../architecture/RESTORATION_CAPABILITY_MATRIX.md)。

此决定替代旧“不逐项复现9.x/重新设计优先”、长期小页面/synthetic演示优先及忽略后台的排程。原版已实现且选入恢复基线的功能不能因旧Later标签被排除，未实现设想后置。原源码及具名备份副本按恢复任务读取，不再作为全面禁区，也不得无限考古、覆盖原件或擅自接受全部LOCAL_ONLY。

独立Web界面复用现有后端与数据库，管理员权限由后端执行，不在普通APP塞满管理功能，不并行重造桌面客户端。五个功能包仍为v10.0.6运行恢复＋首个管理闭环、0.7原APP功能、0.8后台模块、0.9联合验证、0.10软件交付和说明。具体版本需冻结后手动派发，约5～8迭代是初估，不是公开运营日期。Owner计划的半年至一年内测运营在完整软件交付后单列。

Astra规划/独立终验，Codex冻结范围内自主实现，Owner手动派发和重大取舍；旧Work不恢复。K08版后接续保持但不强制每轮新建worktree、重读全历史或复制完整快照。[CURRENT_WORKFLOW](../workflow/CURRENT_WORKFLOW.md)是现行执行规则，knowledge.md中旧K08～K12只按时点作历史，不覆盖本次方向。

## 当前读取入口

[动态目录](../../DOC_INDEX_CURRENT.md) → 当前状态 → 当前路线/台账及本版计划。旧算法、领域与环境只在需要时读[knowledge.md](knowledge.md)、[environment.md](environment.md)、[archive说明](archive-20261012.md)。不全量复审旧接受、不重建session或图谱库。v10.0.0～0.5原限域测试和集成事实保持，不据此宣称真实服务/数据库恢复已通过。

## 已有本地检索路由（保留，不要求本轮重配）

以下来自既有记忆记录，不表示本轮重新验证工具版本或覆盖。Markdown直接读取可作回退，索引未命中不等于源码不存在。

- Basic Memory：项目elitesync-v10-local，使用--project elitesync-v10-local --local；既有进程配置BASIC_MEMORY_CONFIG_DIR=D:/EliteSync-v10/.local-memory-state/basic-memory，BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false。只覆盖部分历史归档，不是现行规则完整镜像，不切换共享default_project或下载模型。
- QMD：独立named index与collection均为elitesync-v10-memory；显式--index elitesync-v10-memory及-c elitesync-v10-memory。既有索引针对原docs/memory，不假定随worktree自动同步，不为这次版本协商重建。
- 代码图谱已有D-EliteSync-v10历史入口；未命中时直接读指定工作树。无新增插件、全量sessions扫描或recall索引建设，不涉及其它项目。

[调整前完整记忆导航](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/docs/memory/navigation.md)保存旧身份、路径与检索经验。旧Work/Builder、V212和任务不自动激活。新恢复目标不追认SOURCEONLY为实际APP/数据恢复，也不解除原始敏感备份、生产和不可逆操作保护；网页没有C:/D:直接访问能力。
