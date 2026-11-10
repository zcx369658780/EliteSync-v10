# AUTH-159｜synthetic bcrypt 登录探针作者摘要｜2026-09-27

**候选定向验证通过，待 Work 独立 LEVEL 2 审查；作者未 ACCEPT。** 本地 `D:\EliteSync-v10` 的 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，原有 modified/untracked 保留，未提交、拉取或推送。

## 固定预检与差异

修改前 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` 的 SHA-256 为 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`，与 AUTH-158 接受值一致；`bootstrap/cache/config.php` 不存在；`phpunit.xml` 指定 `DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`。`config/database.php` 对默认连接优先读取 `APP_DB_CONNECTION`，SQLite URL 可由 `DB_URL` 覆盖，因此测试进程显式固定这两项。全部前置条件为 **true**。

唯一代码修改是目标 Feature 文件新增 `DB` facade 引用及一个 synthetic 用例。用例建立虚构账号，在测试进程内以 `password_hash(..., PASSWORD_BCRYPT)` 生成哈希，用内存 SQLite 的 `DB::table('users')` 直接写入以绕过模型 `hashed` cast；检查错误虚构密码返回 422、响应无 access token 且 token 数不增加，正确虚构密码登录成功，并核对前后持久哈希字节保持一致。没有输出合成哈希正文，也未读取真实哈希。保留 AUTH-157 已接受测试及所有其他差异。修改后目标文件 SHA-256：`E5389E0FF7DDB21B2C89AAF40741881376EBB889C1657E82E679704D03EE34B1`；对目标文件 `git diff --check` 退出 0。

## 预算内验证

工作目录 `services/backend-laravel`：

| 检查 | 实际运行 | 结果 |
| --- | --- | --- |
| 语法 | `php -l tests\Feature\AuthPasswordApiTest.php`，1 次 | 退出码 0；无语法错误。 |
| 定向 PHPUnit | 单个测试 shell 内覆盖 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），再运行 `php vendor\bin\phpunit tests\Feature\AuthPasswordApiTest.php`；首跑 1 次 | 退出码 0；**7 tests / 37 assertions**，0 failures、0 errors，另有 **2 deprecations**；原始状态 `OK, but there were issues!`。 |

复跑 **0 次 / NOT_RUN**；无非 SQLite 或非内存连接迹象，未修改持久配置或运行磁盘数据库。弃用提示未在本任务内调查。完整套件、其他测试、真实数据/备份/密钥、SSH、云、生产 API/DB、解密/恢复/迁移均 `NOT_RUN`。

此结果仅证明人工生成的 bcrypt 哈希在当前本地测试环境可经现有登录路径验证，且本用例观察到登录未静默改写它；不证明主库或 2.6 备份的实际算法、参数、编码、全部账号可登录、旧哈希迁移可行或生产就绪。回退只撤销本次新增 import、单个用例和本摘要，保留 AUTH-157 测试及所有无关工作区内容。交付后停 Work LEVEL 2 ACCEPT/REJECT，不启动后继。
