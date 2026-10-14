# EliteSync-v10 动态总目录

2026-10-14：现行目标为**完整APP前后端/数据库恢复＋独立Web管理面板**。路线同步及Codex集中执行方案已接收；v10.0.6正式计划已冻结，等待Owner手动派发，尚未实施。上传Sources不自动同步，先读当前入口及必要正文并记录实际Git提交。

| 当前入口 | 正文与用途 |
|---|---|
| v10.0.6 正式冻结计划 | [城市持久化＋Web管理禁用闭环](docs/versions/v10.0.6/plan.md)：固定代码起点3a78c2c；APP真实城市写库/重启读回、Blade管理员禁用、旧token及非法角色拒绝；专用Docker/DB/AVD/依赖安装权限随Owner派发一次生效。不是只读或mock交付 |
| 版前来源 | [原草案](docs/versions/v10.0.6/PLAN_PROPOSAL_V0_1.md)保留历史；Codex反馈及现行取舍已收敛至正式计划，不再按草案另开环境治理版本 |
| Owner决定 | [PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md)：恢复两目标、原版功能优先、独立Web、内测与公开运营分开 |
| 路线图 | [当前交付路线图](docs/architecture/ELITESYNC_V10_CURRENT_DELIVERY_PLAN_AND_ROADMAP_V0_1.md)：v10.0.6～10功能包；未来包不是已派发任务 |
| 单份功能台账 | [恢复能力矩阵](docs/architecture/RESTORATION_CAPABILITY_MATRIX.md)：源码/前端/API/数据库/管理员操作逐项落实；历史备份只知元数据不等于数据恢复 |
| 当前现场 | [CURRENT_STATE.md](CURRENT_STATE.md)：代码起点、本机环境的Codex回报、待Owner派发与尚未运行范围；本地路径不能作为网页读证 |
| 启动与长期工作方式 | [AGENTS.md](AGENTS.md)、[CURRENT_WORKFLOW.md](docs/workflow/CURRENT_WORKFLOW.md)：功能模块内跨端自主实施，Astra集中终验；不强制每轮新worktree或重验全历史 |
| 版本计划与接受 | [版本登记](docs/versions/README.md)：前六版限定接受及v10.0.6冻结状态，原计划/接受/失败不重写 |
| 记忆与环境 | [记忆导航](docs/memory/navigation.md)、[历史主题知识](docs/memory/knowledge.md)、[环境记录](docs/memory/environment.md)：新目标和正式计划优先，旧索引仅按需读取 |
| APP与后端资产 | [Flutter](apps/flutter_elitesync_module/)、[Android宿主](apps/android/)、[Laravel](services/backend-laravel/)、[API路由](services/backend-laravel/routes/api.php)：复用现有工程，不另造Hello World |
| 管理资产 | [Flutter Admin](apps/flutter_elitesync_module/lib/features/admin/)、[AdminController](services/backend-laravel/app/Http/Controllers/Api/V1/AdminController.php)、[AdminMatchingController](services/backend-laravel/app/Http/Controllers/Api/V1/AdminMatchingController.php)：已有代码线索，未证明独立Web各模块可用 |
| 保留产品原则 | [原功能设计](docs/gpt-project-sources/06_新版本APP功能设计正文_已接受.md)、[Owner接受](docs/gpt-project-sources/07_新版本APP功能设计Owner接受记录.md)：隐私和独立同意保持，恢复优先级按10月14日新决定 |
| 历史交接 | [旧重置交接](docs/ELITESYNC_V10_ARCHITECTURE_RESET_HANDOFF.md)、[迁移交接](docs/migration/ASTRA_HANDOFF_20261012.md)、[Codex交接](docs/migration/CODEX_LOCAL_HANDOFF_20261012.md)：旧Work/微预算/不得恢复9.x不作为新功能版默认限制 |

## 历史与证据

[冻结前目录](https://github.com/zcx369658780/EliteSync-v10/blob/98649e89e223b92c5e7817b8f0f0361242c6c476/DOC_INDEX_CURRENT.md)和[路线调整前完整目录](https://github.com/zcx369658780/EliteSync-v10/blob/db1300bb19182f2de46b4ff5b1f7d9b947907b69/DOC_INDEX_CURRENT.md)保持历史入口。冻结plan/acceptance/rejection/raw不追改，不扫描所有Markdown或sessions。

正式计划冻结与Owner派发、实际运行及最后接受是不同事实；本轮没有启动服务、数据库或设备。原3306、生产服务、历史敏感备份、真实账号和不可逆操作不在默认授权内。已允许的本版开发链需真实执行，不能以旧全局禁令替代实际操作或用模拟输出冒充通过。
