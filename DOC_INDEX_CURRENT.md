# EliteSync-v10 动态总目录

这是 `zcx369658780/EliteSync-v10` 的当前导航，发布分支main。每次立版、验收、跨会话恢复实际读取此目录及相关正文，记录读取提交；上传索引不会自动同步，也不授予仓库或本机访问。普通现状读当前页，冻结版本按固定提交的计划验收。

|逻辑槽位|现存正文与用途|
|---|---|
|v10.0.5 独立验收及远端集成完成|[冻结计划](docs/versions/v10.0.5/plan.md)、[独立终验](docs/versions/v10.0.5/acceptance.md)、[事实复盘](docs/versions/v10.0.5/retrospective.md)、[定点集成](docs/versions/v10.0.5/integration.md)：Progress三域只读摘要ACCEPTED/CLOSED；51项测试PASS、分析No issues、23/23 payload身份匹配。两项接受代码已进GitHub，最新本地基线和集成后重测仍待Owner手动交Codex；不启动v10.0.6|
|v10.0.4 五阶段收口（本地限定重验已回报）|[冻结计划](docs/versions/v10.0.4/plan.md)、[R1终验](docs/versions/v10.0.4/acceptance.md)、[复盘](docs/versions/v10.0.4/retrospective.md)、[定点集成](docs/versions/v10.0.4/integration.md)、[当前状态](CURRENT_STATE.md)、[记忆K12](docs/memory/knowledge.md)：两个接受Blob进main；Codex报告新干净基线与集成后13项测试PASS/两文件分析No issues，旧dirty root保留；完整平台/生产仍NOT_RUN|
|工作方式与角色|[当前工作流](docs/workflow/CURRENT_WORKFLOW.md)、[生效AGENTS](AGENTS.md)：网页Astra规划/独立验收/复盘，Codex自主实现；**2026-10-13 Owner追加版后安全集成+本地隔离开发基线接续的长期授权**（不自动派单、不覆盖脏main）|
|现状、在途、暂停|[CURRENT_STATE](CURRENT_STATE.md)：本地/远端差异、当前接受与未知；[迁移交接](docs/migration/ASTRA_HANDOFF_20261012.md)；[本轮更新前完整状态快照](https://github.com/zcx369658780/EliteSync-v10/blob/e8f3a2f8893e380bb766c8583ed182d5b62f655c/CURRENT_STATE.md)按原字节保留历史|
|第二阶段本地接收与手动交接（已完成）|[Codex本地交接及启动Prompt](docs/migration/CODEX_LOCAL_HANDOFF_20261012.md)：保留历史现场/检索结果；Owner已确认继任会话入场，“待接收”仅是当时快照；`projectId=null`不等于已证明上下文不可用|
|知识与环境|[记忆导航](docs/memory/navigation.md)、[关键知识K08～K12](docs/memory/knowledge.md)、[环境记录](docs/memory/environment.md)、[归档说明](docs/memory/archive-20261012.md)。版本最新接受与基线以CURRENT_STATE和版本登记为准，不由历史记忆推出实时状态|
|产品定义与决定|[产品边界摘要](docs/gpt-project-sources/02_产品架构与不可变边界.md)、[正式功能设计](docs/gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[Owner接受](docs/gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)、[PRODUCT_DECISIONS](PRODUCT_DECISIONS.md)|
|v10.0.1 独立验收与复盘|[冻结计划](docs/versions/v10.0.1/plan.md)、[验收](docs/versions/v10.0.1/acceptance.md)、[复盘](docs/versions/v10.0.1/retrospective.md)：PHP→JSON→Dart synthetic诊断ACCEPT/CLOSED；必要代码[定点集成](docs/versions/v10.0.1/integration.md)，原候选历史未整体合并|
|v10.0.0 最终验收与复盘|[冻结计划](docs/versions/v10.0.0/plan.md)、[独立验收](docs/versions/v10.0.0/acceptance.md)、[复盘](docs/versions/v10.0.0/retrospective.md)：ACCEPTED/CLOSED（synthetic/dev-test），接受测试Blob已纳入GitHub main；历史候选整体未merge|
|已接受代码定点整合|[v10.0.0+v10.0.1集成回执](docs/versions/v10.0.1/integration.md)14项；[v10.0.2](docs/versions/v10.0.2/integration.md)3项；后续各版集成分别见对应integration.md。回执中的本地未对齐/运行NOT_RUN按当时具体基线理解，不覆盖后来独立回报|
|v10.0.2 独立验收与复盘|[冻结计划](docs/versions/v10.0.2/plan.md)、[独立验收](docs/versions/v10.0.2/acceptance.md)、[复盘](docs/versions/v10.0.2/retrospective.md)：Debug/Test synthetic只读Widget ACCEPTED/CLOSED；[必要代码已集成](docs/versions/v10.0.2/integration.md)，历史候选未整支merge；非Debug/设备/完整Feature仍无本版运行证明|
|本地隔离开发基线的历史接续|[项目知识K09～K12](docs/memory/knowledge.md)保留2175dd6、64a098f、d49c308各次具名基线回报；[当前状态](CURRENT_STATE.md)给出最近可用基线及本次待接续目标。原`D:/EliteSync-v10` dirty main持续独立保护，不能视为已全量同步|
|v10.0.3 接受、远端集成与本地基线接续完成|[冻结计划](docs/versions/v10.0.3/plan.md)、[终验](docs/versions/v10.0.3/acceptance.md)、[复盘](docs/versions/v10.0.3/retrospective.md)、[集成回执](docs/versions/v10.0.3/integration.md)、[本地回报](docs/memory/knowledge.md)：Router修复和测试Blob进入GitHub；Codex报告对应隔离基线42/42 PASS，旧dirty根未动|
|路线图与版本登记|[原路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[版本登记入口](docs/versions/README.md)：路线图旧阶段记录不是自动执行授权；各版Acceptance、具名GitHub集成、本地基线及目标重测分别记录|
|计划、结果、验收与复盘|按版本登记定位；[历史stage-e2e-v2摘要及验收转录](docs/migration/ASTRA_HANDOFF_20261012.md)；[证据/契约索引](docs/architecture/ELITESYNC_V10_CURRENT_EVIDENCE_AND_CONTRACT_INDEX_V0_1.md)只解释其具名历史提交|
|历史归档及LOCAL_ONLY|[archive指南](docs/archive/README.md)、[重置交接](docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)、归档说明与迁移交接中的未覆盖资料。本轮前[完整版本登记快照](https://github.com/zcx369658780/EliteSync-v10/blob/e8f3a2f8893e380bb766c8583ed182d5b62f655c/docs/versions/README.md)不改写|

分支页面是动态入口，不能充当固定验收依据。正式计划、候选代码、实际证据/验收登记commit与必要blob/hash；版本验收和集成状态独立记于版本登记，依Owner既有K08权限执行有界安全收尾，不能从验收通过推定本地已同步。旧Sources、Work/Builder和旧任务为上传或历史快照，不覆盖新流程；产品正式接受保留。

GitHub不可读或文件未发布时如实报告具体path/ref缺口。LOCAL_ONLY正文不给假远端链接，网页不能直接读D:/、C:/、QMD或Basic Memory。没有实际正文访问就不能声称已读。
