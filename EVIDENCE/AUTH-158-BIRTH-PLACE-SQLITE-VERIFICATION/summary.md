# AUTH-158｜进程内 SQLite 定向验证回执｜2026-09-27

**作者结果：目标 Feature 文件在限定内存 SQLite 环境下断言通过，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty 工作区保留，本任务仅新增本摘要，未修改测试或生产代码。

## 预检

| 门 | 只读结果 |
| --- | --- |
| `AuthPasswordApiTest.php` SHA-256 等于固定值 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B` | **true** |
| `services/backend-laravel/bootstrap/cache/config.php` 不存在 | **true** |
| `phpunit.xml` 的测试 `DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:` | **true** |
| `config/database.php` 优先读取 `APP_DB_CONNECTION`，SQLite URL 读取 `DB_URL`；需要显式覆盖 | **true** |

AUTH-157 审查保留同账号两处出生地点冲突的 synthetic 测试候选，其旧首跑在 MariaDB 初始化阶段失败，6 errors/0 assertions，旧预算没有复用。上述预检满足本任务一次新预算的前置条件。未读取 `.env` 或其他环境变量值。

## 唯一运行

工作目录：`services/backend-laravel`。在本次独立 shell/测试子进程内执行以下**非秘密测试覆盖**并运行唯一目标文件：

```powershell
$env:APP_DB_CONNECTION='sqlite'; $env:DB_CONNECTION='sqlite'; $env:DB_DATABASE=':memory:'; $env:DB_URL=''; php vendor\bin\phpunit tests\Feature\AuthPasswordApiTest.php
```

运行 **1/1 次，无复跑**。退出码 **0**；PHPUnit 11.5.55 / PHP 8.5.3；**6 tests、29 assertions**，均无失败或错误；同时报告 **2 deprecations**，故原始状态为 `OK, but there were issues!`，不记为无警告 PASS。输出未出现非 SQLite 或非内存数据库连接迹象；本次没有更改持久连接配置或创建磁盘数据库的操作。弃用提示未在本任务预算内进一步调查。其他 PHPUnit 文件、完整套件及代码修复均 `NOT_RUN`。

本回执仅证实当前本地 synthetic Feature 中：同一账号 `users.private_birth_place` 与 `user_astro_profiles.birth_place` 均非空且不同，基础资料和登录响应按已核定顺序选择前者；原有空值回退等目标文件用例也完成断言。它不证明两份备份库字段或跨库来源优先级、真实账号、旧哈希兼容、迁移、生产 DB 或发布就绪。真实数据/备份/密钥、SSH/云/生产 API、解密/恢复、提交/pull/push 均 `NOT_RUN`。

回退仅撤回本摘要；AUTH-157 候选及其他工作区内容不因本任务回退而改动。作者不自行 ACCEPT 或启动后继，停 Work LEVEL 2 独立 ACCEPT/REJECT。
