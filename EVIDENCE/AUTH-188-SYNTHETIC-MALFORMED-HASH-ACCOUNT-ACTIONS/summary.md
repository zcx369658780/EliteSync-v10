# AUTH-188｜人工异常哈希下改密与 synthetic 删除失败关闭候选

**作者结果：局部修复后定向验证通过，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅在两个允许的后端文件加入本任务差异，并新增本摘要。原有 dirty/untracked 与 AUTH-157/159/187 已接受差异保留；AUTH-187 的 `login` 分支未改。

## 差异与哈希

| 文件 | 本任务修改前 SHA-256 | 本任务修改后 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` | `B62A4E30430F95604B355FF492B8E68CFE46AA913A3EAAA29497016A0E45B85D` | `4E8AC36780B504DBABC115FD6B186455F35526A819F9ABE4A90F3DF38D30063E` |
| `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` | `2701921141D2E0F608F4800DFFBB5282CDEC4B1B2AF7842FC7F2AB03B96D442C` | `B2BD5AD9B5742C223676A1E6D040A85C242684B5795C34D879DDF93BB0C29A60` |

测试新增两项人工异常哈希负例：截断 bcrypt 下改密必须返回原有 422、响应无哈希/异常细节、哈希字节不变；不支持格式下 synthetic 账号自删必须返回原有 422、账号及已存在的 token 均保留，响应无哈希/异常细节。两例均以测试进程内 SQLite 人工行直接写入异常哈希并刷新模型，未读取真实哈希。原有正常改密、错误口令、正常 synthetic 删除、非 synthetic 403、AUTH-187 登录回归继续由同一目标文件覆盖。

首跑两项新增用例失败，输出出现 AUTH-187 已识别的 `BcryptHasher` 核验异常 `RuntimeException`，精确消息 `This password does not use the Bcrypt algorithm.`。随后仅在 `changePassword` 和 `deleteSelf` 各自的 `Hash::check` 边界捕获 `RuntimeException`，仅该精确消息映射为原有当前密码错误 422；其他 `RuntimeException` 原样抛出。未捕获 `Throwable`，未改删除权限、登录、算法选择、哈希重写或真实旧库兼容策略。

## 预算内验证

- 固定本地来源/代码核对：**2/2 轮**；两个文件的修改前哈希与 AUTH-187 Work 接受值一致。运行前 `bootstrap/cache/config.php` 不存在；`phpunit.xml` 指向 SQLite `:memory:`，应用默认连接优先使用 `APP_DB_CONNECTION`，SQLite URL 使用 `DB_URL`，目标 PHPUnit 可执行文件存在。
- `php -l tests/Feature/AuthPasswordApiTest.php`：1/2 次，退出码 `0`；`php -l app/Http/Controllers/Api/V1/AuthController.php`：1/2 次，退出码 `0`。
- 两次运行均在各自同一命令环境固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL`，且运行前拒绝配置缓存。定向命令：`php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php`。
- 首跑 **1/2**：退出码 `1`，12 tests / 64 assertions / 2 failures / 2 deprecations；新增两例未达预期，触发上述核验异常。首跑后只做两处分支的局部修复。
- 修复后复跑 **2/2**：退出码 `0`，**12 tests / 80 assertions**，0 failures/errors，另有 2 deprecations；原始结语为 `OK, but there were issues!`。不称无警告 PASS，不调查弃用来源，不做第三次运行。

本结果只证明当前 PHP/Laravel、人工异常哈希和内存 SQLite 下的本地行为；精确异常消息与当前框架实现绑定，升级后须重新核对。不证明任何真实旧哈希算法/兼容、账号模型、生产安全或真实回填。真实备份、密钥、账号值、生产 DB、SSH/云/API、GitHub、全量测试/build/Docker/WSL 均 `NOT_RUN`；未提交、pull 或 push。回退仅撤销本任务在两个允许文件中的新增片段及本摘要，不覆盖前序接受差异或无关 dirty/untracked。作者停在 Work LEVEL 2 `ACCEPT/REJECT`，不自接受或派发后继。
