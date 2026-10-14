# EliteSync-v10 动态总目录

2026-10-14：Owner已批准v10.0目标调整为**完整APP前后端/数据库恢复＋独立Web管理面板**。这是现行目录；上传Sources和历史会话不会自动更新，必须读取本页及所需正文并记录真实提交。当前仅发布文档，Codex同步与v10.0.6实施状态以CURRENT_STATE为准。

| 当前入口 | 正文与用途 |
|---|---|
| Owner决定 | [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md)：两个核心目标、Web管理方向、原有功能优先、内测运营与公开发布分开 |
| 路线图 | [当前交付路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)：五个功能交付包，不是已经冻结的版本任务 |
| 单份功能台账 | [APP恢复与管理能力矩阵](docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)：已有代码线索、未知、恢复结果与实际验收，不用mock或接口存在代替完成 |
| 当前现场 | [CURRENT_STATE.md](CURRENT_STATE.md)：最近已知GitHub/本地基线、已接受成果、恢复缺口和当前任务状态 |
| 启动与长期工作方式 | [AGENTS.md](AGENTS.md)、[CURRENT_WORKFLOW.md](docs/workflow/CURRENT_WORKFLOW.md)：功能范围内跨端自主实施、集中独立验收、简化安全接续；保留必要生产与数据保护 |
| 版本计划与接受 | [docs/versions/README.md](docs/versions/README.md)：v10.0.0～v10.0.5历史限定接受、今后功能交付包；冻结计划须读固定提交 |
| 记忆与环境 | [记忆导航](docs/memory/navigation.md)、[主题知识历史](docs/memory/knowledge.md)、[环境记录](docs/memory/environment.md)：新Owner目标优先；QMD/Basic Memory只为本地已配置路径，网页不假设可直接访问 |
| 已有APP资产 | [Flutter](apps/flutter_elitesync_module/)、[Android宿主](apps/android/)、[Laravel](services/backend-laravel/)、[API路由](services/backend-laravel/routes/api.php)：实际恢复需要时按功能定点读取 |
| 已有管理资产 | [Flutter Admin](apps/flutter_elitesync_module/lib/features/admin/)、[AdminMatchingController](services/backend-laravel/app/Http/Controllers/Api/V1/AdminMatchingController.php)：复用线索，不等于独立Web后台已实装 |
| 仍适用的产品原则 | [功能设计](docs/gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[旧Owner接受](docs/gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)：独立同意/隐私等保留，冲突的交付优先级由2026-10-14新决定替代 |
| 历史恢复与交接 | [架构重置旧交接](docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)、[迁移交接](docs/migration/ASTRA_HANDOFF_20261012.md)、[Codex历史交接](docs/migration/CODEX_LOCAL_HANDOFF_20261012.md)：旧“不逐项恢复9.x”和Work/微预算规则不是现行默认要求 |

## 历史保存和证据边界

[调整前完整目录](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/DOC_INDEX_CURRENT.md)及其中旧版本证据仍可固定读取。历史plan/acceptance/rejection/raw未重写；只在本次恢复实际需要时读取，不重新审查几千份Markdown或全量sessions。

源码位置、Git Blob、测试回执和产品恢复完成是不同事实；本地Windows路径/备份/QMD不能当作网页可读链接。缺文件或未发布资料如实标UNKNOWN，不能用索引或旧日志冒充已读/已恢复。MVP旧Later标签不自动排除原版已有功能，但旧设想也不自动成为必恢复范围。
