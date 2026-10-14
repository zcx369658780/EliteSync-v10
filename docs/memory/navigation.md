---
title: navigation
type: note
permalink: elitesync-v10-local/navigation
---

# EliteSync-v10 记忆导航

## 2026-10-14 Owner现行决定：恢复APP与独立Web管理

Owner已明确提出并批准：v10.0只优先完成**EliteSync APP前端、后端、数据库及选定原版主要功能恢复＋真正可用的独立Web管理面板**。批准将方案写入仓库并让Codex同步；本轮不启动实际开发。准确方向见[PRODUCT_DECISIONS](../../PRODUCT_DECISIONS.md)、[路线图](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[恢复台账](../architecture/RESTORATION_CAPABILITY_MATRIX.md)。

此决定替代旧“不逐项复现9.x/重新设计优先”、长期小页面/synthetic演示优先及忽略后台的排程。原版已实现且被选入恢复基线的功能不能被旧Later标签排除；未实现设想后置。原源码与数据库备份可按具名恢复任务定点读取，不再作为全面禁区，也不得无限考古/覆盖原件。

独立Web界面复用现有后端业务服务和数据库，管理员权限独立；不在普通APP塞满管理功能，不并行重造桌面管理客户端。五个建议功能包为v10.0.6运行恢复＋首个管理闭环、0.7原APP功能、0.8后台模块、0.9跨端联合验证、0.10完整交付和算法/使用说明。具体包尚未冻结，5～8迭代是初估而非运营日期。Owner计划半年至一年内测运营应在完整软件交付后另行安排，不能据开发版本数承诺公开运营。

Astra规划/独立验收，Codex冻结版本内自主实现，Owner手动转交和关键取舍；旧Work不恢复。K08版后集成与本地接续顺序保留，但不再强制每轮新建worktree、重读全部历史或复制整篇快照。[CURRENT_WORKFLOW](../workflow/CURRENT_WORKFLOW.md)是现行执行规则，knowledge.md中K08～K12及旧Sources仅在其时点范围作历史，不覆盖本次方向和前瞻流程。

## 当前需要读取的少量正文

[动态目录](../../DOC_INDEX_CURRENT.md) → [当前状态](../../CURRENT_STATE.md) → 当前路线/台账和本版计划。相关旧算法、领域与环境才按需读[knowledge.md](knowledge.md)、[environment.md](environment.md)、[archive说明](archive-20261012.md)。历史冻结接受不重写、不全量复审，不重建session/图谱数据库。

最近Codex回报的干净开发基线：C:/Users/zcxve/.codex/worktrees/elitesync-main-be0636e/EliteSync-v10，HEAD be0636eec52baa180ac98b94a94223a2e9f9eb2f、CLEAN；限定51项和分析通过，原证LOCAL_ONLY。原D:/EliteSync-v10脏主树与旧工作树受保护。网页只核过远端对象，不直接访问这些Windows路径；本轮文档发布不代表本地已同步。实际状态仍以CURRENT_STATE和本地回执为准。

## 已有本地检索路由（保留，不要求本轮重配）

以下来自既有记忆记录，不表示本轮重新验证工具版本/覆盖。Markdown直接读取始终可作为回退，索引未命中不代表源码不存在。

- Basic Memory：项目elitesync-v10-local，使用--project elitesync-v10-local --local；既有进程配置BASIC_MEMORY_CONFIG_DIR=D:/EliteSync-v10/.local-memory-state/basic-memory，BASIC_MEMORY_SEMANTIC_SEARCH_ENABLED=false。只覆盖部分历史归档，不是现行规则的完整镜像，不切换共享default_project，不下载模型。
- QMD：独立named index与collection均为elitesync-v10-memory；显式--index elitesync-v10-memory和-c elitesync-v10-memory。现有索引针对原docs/memory目录；不假定自动跟随新worktree，也不为本轮文档同步重建全量索引。
- 代码图谱已有D-EliteSync-v10历史入口；未命中时按指定实际工作树直接读源码。本轮不安装插件、不重扫所有sessions、不重建recall共享索引，不涉及HANK/Zotero/其它项目。

## 原始记忆与证据

[调整前完整记忆导航](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/docs/memory/navigation.md)保留旧身份、版本、路径、检索经验和迁移规则原字节。该历史导航提到的旧Work/Builder、镜像目录、V212和任务状态不应自动激活。新恢复目标不追认旧SOURCEONLY测试为真实APP/数据恢复，也不解除原始敏感备份、生产数据、真实用户隐私和不可逆操作保护。
