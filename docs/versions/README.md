# EliteSync-v10 版本登记入口

## 当前版本：v10.0.6 正式冻结，等待Owner手动派发

2026-10-14：Astra接收Codex集中执行方案READY_WITH_FINDINGS，并发布[正式冻结计划](v10.0.6/plan.md)。**FROZEN_PLAN / AWAITING_OWNER_MANUAL_DISPATCH / IMPLEMENTATION_NOT_STARTED**；本次未运行APP、服务、数据库、构建或测试。

代码起点固定 `3a78c2c81859db682369fd6e03f6d98a3c2bbeb2`，Tree `59969abfc9d04185769b22af5f7ea5d629007a33`。继续使用Codex报告CLEAN的专用工作树，不强制新增worktree或将实现压成单一提交。独立候选与最终代码身份必须可追溯；[旧草案](v10.0.6/PLAN_PROPOSAL_V0_1.md)仅为版前来源，不能覆盖正式AC。

唯一交付：原Android APP通过真实Laravel城市接口写入users.city并重进/重启读回；独立Blade登录和用户禁用真实落库，旧token/session、refresh、新登录及本版资料访问拒绝，正常对照用户不受影响。Docker Desktop启动、专用MariaDB10.11容器/库/volume、依锁依赖补齐、专用AVD与ADB、AAR/debug APK构建安装及本地浏览器操作，由Owner手动派发时一次按计划范围授权，不拆环境/治理版本。原3306、历史备份内容、生产/真实账号和额外系统级操作排除。

## 现行方向与功能包

v10.0优先恢复选定原版APP前后端、数据库与主要功能，并交付独立Web管理面板。见[路线图](../architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)、[恢复台账](../architecture/RESTORATION_CAPABILITY_MATRIX.md)、[Owner决定](../../PRODUCT_DECISIONS.md)。不能用长期synthetic页面补齐代替真实软件，也不把原版主要功能推至内测以后。

| 版本 | 主要实物结果 | 当前状态 |
|---|---|---|
| v10.0.6 | APP城市实际持久化＋Web管理测试用户禁用与会话失效＋跨端重启验证 | [FROZEN_PLAN](v10.0.6/plan.md)；代码起点3a78c2c；AC-01～07已冻结，无候选/实施；等待Owner派发 |
| v10.0.7 | 选定原版APP主要功能成组恢复，接口/数据/必要任务接通 | 路线包，尚未立版 |
| v10.0.8 | 用户、审核、举报、匹配、问卷等确定范围的Web模块实装 | 路线包；首个Web管理闭环已纳入0.6目标 |
| v10.0.9 | APP/Web/后端/数据库联合流程、持久化及重启/失败恢复 | 路线包，未执行 |
| v10.0.10 | 完整软件包、安装/部署/恢复方式与功能/算法说明 | 路线包，不是公开运营承诺 |

五包、必要时5～8个功能迭代只是排程估计；本版Codex粗估4～7工程日不是自动时限或已测吞吐。Owner半年至一年内测运营窗口在完整交付后另列，公开运营另行决定。恢复基线已有功能不得因旧Later标签省略；本版只初始化开发库与虚构数据，历史业务数据仍是后续具名恢复项。

## 已完成版本（原限定接受保持）

| 版本 | 主要接受成果 | 固定材料入口 |
|---|---|---|
| v10.0.0 | Product Connection持久化/应用边界收口 | ACCEPTED/CLOSED WITH OBSERVATIONS；[plan](v10.0.0/plan.md)、[验收](v10.0.0/acceptance.md)、[复盘](v10.0.0/retrospective.md) |
| v10.0.1 | PHP→JSON→Dart只读synthetic诊断 | ACCEPTED/CLOSED WITH OBSERVATIONS；[验收](v10.0.1/acceptance.md)、[复盘](v10.0.1/retrospective.md)、[集成](v10.0.1/integration.md) |
| v10.0.2 | Debug只读诊断Widget | ACCEPTED/CLOSED WITH OBSERVATIONS；[验收](v10.0.2/acceptance.md)、[复盘](v10.0.2/retrospective.md)、[集成](v10.0.2/integration.md) |
| v10.0.3 | 动态Guard真实Router缺陷修复 | ACCEPTED/CLOSED WITH OBSERVATIONS；[验收](v10.0.3/acceptance.md)、[复盘](v10.0.3/retrospective.md)、[集成](v10.0.3/integration.md) |
| v10.0.4 R1 | Readiness来源解释、兼容恢复与lint误报纠正 | ACCEPTED/CLOSED WITH OBSERVATIONS；[验收](v10.0.4/acceptance.md)、[复盘](v10.0.4/retrospective.md)、[集成](v10.0.4/integration.md) |
| v10.0.5 | Progress三域只读摘要、动态清除与受限导航 | ACCEPTED/CLOSED WITH OBSERVATIONS；[plan](v10.0.5/plan.md)、[验收](v10.0.5/acceptance.md)、[复盘](v10.0.5/retrospective.md)、[集成](v10.0.5/integration.md) |

旧测试和集成不等于本版真实运行通过。[冻结前完整登记](https://github.com/zcx369658780/EliteSync-v10/blob/98649e89e223b92c5e7817b8f0f0361242c6c476/docs/versions/README.md)及各冻结原件保持；本地具体身份、环境回报和当前未运行事项由[CURRENT_STATE](../../CURRENT_STATE.md)维护，不逐版复制全部历史。

## 收尾规则

依[现行工作流](../workflow/CURRENT_WORKFLOW.md)，Codex在冻结功能/模块/数据与环境范围内连续实现，Astra按真实APP/Web/API/DB证据独立验收。验收、GitHub集成、本地基线和实际运行分别登记，可接续专用基线，不强制新worktree或因纯文档提交重跑全套测试。原dirty根、无关资产与敏感备份保护；旧V57/H1/H2/D0不自动恢复，也不是新授权开发链的默认前置。完成本版候选后停止，不自动v10.0.7或生产发布。
