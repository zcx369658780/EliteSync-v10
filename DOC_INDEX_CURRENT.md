# EliteSync-v10 动态总目录

这是 `zcx369658780/EliteSync-v10` 的当前导航，发布分支main。每次立版、验收、跨会话恢复实际读取此目录及相关正文，记录读取提交；上传索引不会自动同步，也不授予仓库或本机访问。普通现状读当前页，冻结版本按固定提交的计划验收。

|逻辑槽位|现存正文与用途|
|---|---|
|工作方式与角色|[当前工作流](docs/workflow/CURRENT_WORKFLOW.md)、[生效AGENTS](AGENTS.md)：网页Astra规划/独立验收/复盘，Codex自主实现，Owner方向决定|
|现状、在途、暂停|[CURRENT_STATE](CURRENT_STATE.md)：本地/远端差异、历史通过与未知；[迁移交接](docs/migration/ASTRA_HANDOFF_20261012.md)|
|第二阶段本地接收与手动交接（已完成）|[Codex 本地交接及启动 Prompt](docs/migration/CODEX_LOCAL_HANDOFF_20261012.md)：保留历史现场/检索结果；Owner 后续已确认继任会话入场，交接文档中的“待接收”仅是当时快照；`projectId=null` 不等于已证明上下文不可用|
|知识与环境|[记忆导航](docs/memory/navigation.md)、[关键知识](docs/memory/knowledge.md)、[环境记录](docs/memory/environment.md)、[归档说明](docs/memory/archive-20261012.md)|
|产品定义与决定|[产品边界摘要](docs/gpt-project-sources/02_产品架构与不可变边界.md)、[正式功能设计](docs/gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[Owner接受](docs/gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)、[PRODUCT_DECISIONS](PRODUCT_DECISIONS.md)|
|v10.0.1 独立验收与复盘（已关闭）|[冻结计划](docs/versions/v10.0.1/plan.md)、[验收](docs/versions/v10.0.1/acceptance.md)、[复盘](docs/versions/v10.0.1/retrospective.md)：PHP→JSON→Dart synthetic诊断 ACCEPT/CLOSED；隔离候选未合 main，真实消息权限未开启|
|v10.0.0 最终验收与复盘|[冻结计划](docs/versions/v10.0.0/plan.md)、[独立验收](docs/versions/v10.0.0/acceptance.md)、[复盘](docs/versions/v10.0.0/retrospective.md)：Acceptance **ACCEPTED/CLOSED**（仅 synthetic/dev-test），Integration **NOT_MERGED**；C 另版|
|路线图与版本登记|[原路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[版本登记入口](docs/versions/README.md)：v10.0.0 已终验，等待 Owner 决定后续版本/整合|
|计划、结果、验收与复盘|版本登记入口按具名冻结版定位；[历史stage-e2e-v2安全摘要及验收原文](docs/migration/ASTRA_HANDOFF_20261012.md)；[现有证据/契约索引](docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md)只解释其具名历史提交|
|历史归档及LOCAL_ONLY|[archive指南](docs/archive/README.md)、[重置交接](docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)、归档说明与迁移交接中的私有资料/未覆盖历史说明|

分支页面是动态入口，不能充当固定验收依据。正式计划、候选代码、实际证据/验收应登记 commit 与必要 blob/hash；版本验收和集成状态独立记于[版本登记](docs/versions/README.md)，验收通过不自动合并代码。旧Sources中的CURRENT、Work/Builder路由及任务是上传快照，不覆盖新工作流/现状；旧产品正式接受保留。

GitHub读取不可用或文件未发布时如实报告具体path/ref缺口，请Owner提供对应快照。LOCAL_ONLY正文不给远端假链接；网页不能直接读D:/、C:/、QMD或Basic Memory。没有访问正文就不能声称已读。
