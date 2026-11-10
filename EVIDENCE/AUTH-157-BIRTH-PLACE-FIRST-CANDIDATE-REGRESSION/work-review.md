# AUTH-157 Work 独立审查｜2026-09-27

**LEVEL 2 REJECT 作为已验证回归；保留测试候选，行为 `NOT_VERIFIED`。** 审查对象是 `AuthPasswordApiTest.php` 中新增的单个 synthetic 用例及作者 `summary.md`。目标测试文件 SHA-256 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`；摘要 SHA-256 `190FDECCB3626AB1CD2C14743D424C4E9D124EF0C6E90D0B8B17B006A8B657D5`。

差异仅新增同一虚构账号的两处不同非空出生地点，并断言基础资料及登录响应优先选择 `users.private_birth_place`。已核对 `AuthController::userPayload` 和 `ProfileController::basic` 均按这一顺序取值；测试构造和断言与 Owner 本次同账号规则一致，未把它扩展为两份备份库的优先级。`git diff --check` 对目标文件退出 0，PHP 语法检查退出 0。

作者唯一一次定向 PHPUnit 在 `RefreshDatabase` 初始化阶段遇到 MariaDB 连接拒绝，结果 6 errors、0 assertions；本次新增断言没有运行。没有证据表明测试逻辑通过或失败。作者按任务停点未复跑，也未改数据库配置。审查另发现 `phpunit.xml` 指定 `DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`，而应用配置优先读取 `APP_DB_CONNECTION`；环境来源冲突尚未证明。后继应在**新任务和新预算**下显式限定进程内 SQLite 连接，先只读核对测试环境，再运行原目标文件；若仍尝试非内存数据库则失败即停。旧 AUTH-157 作者验证预算不重置。

未读取真实账号、备份、密钥或生产 DB；未提交、拉取或推送。候选测试保留待新验证，不接受为已验证后端行为。
