# AUTH-158｜出生地点候选的隔离测试验证

状态：`ISSUED`。风险 LEVEL 2（auth 私密资料行为验证）。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；唯一交付同目录 `summary.md`，交付后停 Work 独立 LEVEL 2 审查。

先核对实时仓库 `D:\EliteSync-v10`、本地 `main`/HEAD、dirty 工作区、`TASK_CURRENT.md`、AUTH-157 的 `task.md`/`summary.md`/`work-review.md`、目标 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`、`services/backend-laravel/phpunit.xml` 和 `services/backend-laravel/config/database.php`。可只读项目根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow 技能。不得读取 `.env`、数据库凭据或真实数据。

先只读确认目标测试文件 SHA-256 仍为 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`，`bootstrap/cache/config.php` 不存在，且 PHPUnit 配置中测试数据库为 SQLite `:memory:`；任一不符即停并记 `NOT_RUN`。还要核对应用配置的 `APP_DB_CONNECTION` 优先级和 SQLite `DB_URL` 覆盖风险。仅在这些条件满足时，于**单个测试子进程**内显式设 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），运行一次 `php vendor\bin\phpunit tests\Feature\AuthPasswordApiTest.php`。不输出其他环境变量，不改变持久配置，不创建磁盘数据库；若出现非 SQLite 或非内存连接迹象，立即停，不重试。

预算仅此一次目标文件 PHPUnit，无复跑；无需改任何代码或测试。`summary.md` 记录预检布尔结果、执行命令中的非秘密测试覆盖变量、退出码、tests/assertions、失败分类及 `NOT_RUN`，不复制敏感堆栈。结果通过也只证明当前本地 synthetic Feature 回归；不证明两份备份库的字段、账号迁移、真实哈希兼容或生产就绪。失败或环境不符时如实停 Work 审查，不自行修复或创建后继。

不得访问旧 `D:\EliteSync`、SSH/云/生产 API、备份/密钥目录、真实账号行或生产 DB；不得解密、恢复、迁移、提交、拉取或推送。AUTH-157 旧验证预算及任何既有一次性预算均不重置；保留所有无关 modified/untracked 内容。
