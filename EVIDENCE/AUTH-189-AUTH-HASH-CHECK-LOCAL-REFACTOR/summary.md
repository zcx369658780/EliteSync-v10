# AUTH-189｜三处哈希核验处理的控制器内局部收敛

**作者结果：行为保持重构通过定向验证，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅修改任务允许的 `AuthController.php` 并新增本摘要，保留全部既有 dirty/untracked 与 AUTH-157/159/187/188 差异。

## 精确差异与哈希

- `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`：修改前 SHA-256 `4E8AC36780B504DBABC115FD6B186455F35526A819F9ABE4A90F3DF38D30063E`，与 AUTH-188 Work 接受值相同；修改后 SHA-256 `CCBC5806FB990D43E02308CE496BF40EACB668053D3D7B1B3CAE4101A004DA21`。
- 未修改的 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`：SHA-256 仍为 AUTH-188 接受值 `B2BD5AD9B5742C223676A1E6D040A85C242684B5795C34D879DDF93BB0C29A60`。
- 新增控制器私有 `passwordMatches(?User $user, string $password): bool`：缺用户返回 `false`；正常返回 `Hash::check` 的布尔结果；仅精确消息 `This password does not use the Bcrypt algorithm.` 的 `RuntimeException` 返回 `false`，其他 `RuntimeException` 原样重抛。三处调用点仅改为调用 helper；各自现有 422 字段与错误文本、token 创建顺序、密码保存及 synthetic 删除权限/副作用均保留。未捕获 `Throwable`，未改算法策略、测试、依赖、配置或 schema。

## 预算内验证

- 固定本地来源/代码核对：**2/2 轮**；控制器修改前哈希与已接受结果一致，现有三处处理逐项相同。运行前 `bootstrap/cache/config.php` 不存在，`phpunit.xml` 指向 SQLite `:memory:`，应用默认连接优先读取 `APP_DB_CONNECTION`，SQLite URL 读取 `DB_URL`，目标 PHPUnit 可执行文件存在。
- `php -l app/Http/Controllers/Api/V1/AuthController.php`：**1/1 次**，退出码 `0`。
- 在单一命令环境中明确固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 并拒绝配置缓存后，运行 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php`：**1/1 次**，退出码 `0`，**12 tests / 80 assertions**，0 failures/errors，另有 **2 deprecations**；原始结语为 `OK, but there were issues!`。未复跑或扩大测试。

这只证明当前本地人工数据、PHP/Laravel 与内存 SQLite 条件下的回归行为。精确异常消息绑定当前框架实现，框架升级后须重新核对；真实旧哈希兼容、最终账号 schema、生产登录或账号回填仍未证。真实备份、密钥、账号值、生产 DB、SSH/云/API、GitHub、全量测试/build/Docker/WSL 均 `NOT_RUN`；未提交、pull 或 push。回退仅撤销本任务对控制器的私有 helper 与三个调用点改动及本摘要，保留前序接受差异和无关工作区内容。作者停 Work LEVEL 2 `ACCEPT/REJECT`，不自接受或派发后继。
