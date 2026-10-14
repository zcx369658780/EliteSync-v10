# EliteSync-v10 动态总目录

2026-10-14：现行目标为**完整APP前后端/数据库恢复＋独立Web管理面板**。Codex已回报新路线及启动指导同步完成；当前进入v10.0.6版前协商，尚未冻结或派发实现。上传Sources不自动同步，先读当前入口及必要正文并记录真实提交。

| 当前入口 | 正文与用途 |
|---|---|
| v10.0.6 执行方案草案 | [运行恢复基线＋首个Web管理闭环](docs/versions/v10.0.6/PLAN_PROPOSAL_V0_1.md)：实际APP→API→持久数据库，独立Web管理员操作后APP反映；等待Codex一次集中执行方案，不另起治理版本 |
| Owner决定 | [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md)：两个核心目标、Web管理方向、原有功能优先、内测运营与公开发布分开 |
| 路线图 | [当前交付路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)：五个功能交付包，不是已冻结任务 |
| 单份功能台账 | [APP恢复与管理能力矩阵](docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)：来源、前端/API/数据现状、恢复结果与验收；原件未读和未实测均不填完成 |
| 当前现场 | [CURRENT_STATE.md](CURRENT_STATE.md)：3a78c2c专用clean基线已由Codex回报，原dirty根AGENTS保留本地补充、八份正文一致；运行恢复未启动 |
| 启动与长期工作方式 | [AGENTS.md](AGENTS.md)、[CURRENT_WORKFLOW.md](docs/workflow/CURRENT_WORKFLOW.md)：功能范围内跨端自主实施、集中终验与简化接续；保留生产与数据保护 |
| 版本计划与接受 | [版本登记](docs/versions/README.md)：前六版限定接受及v10.0.6方案状态；冻结版仍按固定原计划验收 |
| 记忆与环境 | [记忆导航](docs/memory/navigation.md)、[主题知识历史](docs/memory/knowledge.md)、[环境记录](docs/memory/environment.md)：新决定优先；网页不假定可读本地QMD/Basic Memory |
| 已有APP资产 | [Flutter](apps/flutter_elitesync_module/)、[Android宿主](apps/android/)、[Laravel](services/backend-laravel/)、[API路由](services/backend-laravel/routes/api.php)：按当前功能定点读取 |
| 已有管理资产 | [Flutter Admin](apps/flutter_elitesync_module/lib/features/admin/)、[AdminController](services/backend-laravel/app/Http/Controllers/Api/V1/AdminController.php)、[AdminMatchingController](services/backend-laravel/app/Http/Controllers/Api/V1/AdminMatchingController.php)：复用线索，不是Web后台已实装 |
| 仍适用产品原则 | [功能设计](docs/gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[旧Owner接受](docs/gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)：独立同意/隐私等保留，交付优先级按2026-10-14新决定 |
| 历史交接 | [架构重置旧交接](docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)、[迁移交接](docs/migration/ASTRA_HANDOFF_20261012.md)、[Codex历史交接](docs/migration/CODEX_LOCAL_HANDOFF_20261012.md)：旧“不恢复9.x”和Work/微预算规则不是新任务默认要求 |

## 历史与证据

[路线调整前完整目录](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/DOC_INDEX_CURRENT.md)保留原版本证据；历史plan/acceptance/rejection/raw不改写，不重新审查几千份Markdown或全量sessions。

本地源码、备份、操作回执的读取和运行状态分别报告，Windows路径不是网页可访问链接。同步本地AGENTS允许保留不冲突辅助约定，不要求因此重新覆盖；105/109等保护数量各指具体回执范围，不是每个新版本固定门。缺源只定位真正受影响项，不以旧流程禁令阻断全部恢复，也不用mock冒真实业务成功。
