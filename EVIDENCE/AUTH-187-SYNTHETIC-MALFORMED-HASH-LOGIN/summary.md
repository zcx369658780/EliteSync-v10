# AUTH-187｜人工异常哈希登录失败关闭候选

**作者结果：定向修复后通过，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；只在任务允许的两个后端文件改动并新增本摘要。既有 dirty/untracked、AUTH-157 出生地点回归和 AUTH-159 人工 bcrypt 用例均保留。

## 差异与哈希

| 文件 | 本任务修改前 SHA-256 | 本任务修改后 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` | `E5389E0FF7DDB21B2C89AAF40741881376EBB889C1657E82E679704D03EE34B1` | `2701921141D2E0F608F4800DFFBB5282CDEC4B1B2AF7842FC7F2AB03B96D442C` |
| `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` | `460ABC3314521AC1BF12278C738887CCAD0F93B54D595A81335E27EE4DF84551` | `B62A4E30430F95604B355FF492B8E68CFE46AA913A3EAAA29497016A0E45B85D` |

测试新增人工截断 bcrypt、人工不支持格式哈希和禁用账号三个用例。异常哈希以测试进程内 SQLite 的 `DB::table('users')` 写入人工行，断言统一 422、无 token/计数增量、响应无哈希或内部异常细节、原哈希字节不变；原有人工 bcrypt 正确/错误口令回归保留。禁用账号仍为 403 且无 token。

首跑负例证明当前 `Hash::check` 对两种人工异常格式在 `BcryptHasher` 核验处抛出 `RuntimeException`，消息精确为 `This password does not use the Bcrypt algorithm.`；两例未走原有返回 false 分支。控制器只在 `login` 的 `Hash::check` 边界捕获 `RuntimeException`，**仅该精确消息**转成现有统一凭据错误；其他 `RuntimeException` 原样抛出。未捕获 `Throwable`，未变更注册、改密、token refresh、算法选择、重哈希或真实旧库兼容策略。

## 预算内验证

- 固定本地来源/代码核对：**2/2 轮**。修改前目标测试文件哈希等于 AUTH-159 接受值；`bootstrap/cache/config.php` 不存在，`phpunit.xml` 指定 SQLite `:memory:`，应用默认连接优先读取 `APP_DB_CONNECTION`，SQLite URL 读取 `DB_URL`，目标 PHPUnit 可执行文件存在。
- `php -l tests/Feature/AuthPasswordApiTest.php`：1/2 次，退出码 `0`；`php -l app/Http/Controllers/Api/V1/AuthController.php`：1/2 次，退出码 `0`。
- 两次定向测试均在各自单一命令环境中显式固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL`，并在运行前拒绝配置缓存。目标命令：`php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php`。
- 首跑 **1/2**：退出码 `1`，10 tests / 45 assertions / 2 failures / 2 deprecations；两项新增异常哈希用例均因上述明确核验异常失败。旧用例未报告失败。首跑后仅做上述局部控制器修复。
- 修复后复跑 **2/2**：退出码 `0`，**10 tests / 61 assertions**，0 failures/errors，另有 2 deprecations；原始 PHPUnit 结语为 `OK, but there were issues!`。不称无警告 PASS，不调查弃用来源，不做第三次运行。

本回归只证明当前本地 PHP/Laravel 与人工哈希、内存 SQLite 条件下的行为；不证明两份真实备份的算法、参数、编码、全部账号可登录或 v10 最终 auth/schema。真实账号、备份、密钥、生产 DB、SSH/云/API、GitHub、Docker/WSL、全量测试/build 均 `NOT_RUN`；未提交、pull 或 push。回退仅撤销本任务在两文件的新增差异及本摘要，保留之前已接受的测试和全部无关工作区内容。作者不自接受或派发后继，停 Work LEVEL 2 `ACCEPT/REJECT`。
