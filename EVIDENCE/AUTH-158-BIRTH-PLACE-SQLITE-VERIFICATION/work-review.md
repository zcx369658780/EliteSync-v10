# AUTH-158 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅限当前本地 synthetic Feature 回归。** 本审查同时确认 AUTH-157 保留的单个冲突测试候选在 AUTH-158 新隔离验证预算下已运行通过；AUTH-157 原首跑的 MariaDB 环境失败和旧预算耗尽仍保持历史事实。

Work 对照 Owner 决定与当前 `AuthController::userPayload`、`ProfileController::basic`，核对测试 diff：同一虚构账号的 `users.private_birth_place` 与 `user_astro_profiles.birth_place` 均非空且不同；基础资料、登录响应都断言前者。目标测试文件 SHA-256 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`，与任务预检固定值相同；AUTH-158 摘要 SHA-256 `2905FF9553ADFF8704685C61867B3A0D42424FC0C9521DB647491B99A505DEE8`。`git diff --check` 对目标文件退出 0，本审查未复跑测试。

作者回执显示配置缓存不存在，`phpunit.xml` 指向 SQLite `:memory:`，并在单个 shell 内覆盖 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL`。唯一目标文件测试退出 0，6 tests/29 assertions，无失败或错误，另有 2 deprecations，故不称无警告 PASS。没有非 SQLite/非内存连接迹象；本验收只接受记录所能证明的本地行为。弃用来源未在本轮预算内调查。

此接受**不**确定两个备份数据库间的来源优先级、账号集合、逐对象结构、旧密码哈希兼容或最终 v10 auth/account schema，也不放行 AUTH-153/154/155 Phase B、真实数据读取/迁移或生产 DB。未提交、拉取或推送；原有工作区内容保留。
