# AUTH-190｜无关哈希核验异常传播的本地回归

**作者结果：test-only 候选通过定向验证，待 Work 独立 LEVEL 2 审查。** 本地 `D:\EliteSync-v10`、`main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅修改 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` 并新增本摘要。原有 dirty/untracked 与 AUTH-157/159/187/188/189 已接受差异保留。

## 精确差异与哈希

- 测试文件修改前 SHA-256 `B2BD5AD9B5742C223676A1E6D040A85C242684B5795C34D879DDF93BB0C29A60`，等于 AUTH-189 接受时未改的测试哈希；修改后 SHA-256 `8E8C7DB35F506918CED1F01425960A13D1C63D4879750BB30DB771CC39A938EB`。
- 生产控制器未修改：`services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` SHA-256 仍为 AUTH-189 接受值 `CCBC5806FB990D43E02308CE496BF40EACB668053D3D7B1B3CAE4101A004DA21`。
- 新增一个人工账号登录负例：创建账号后局部 mock `Hash::check`，令其只在本次调用抛出与精确 bcrypt 格式消息不同的人工 `RuntimeException`；关闭该请求的异常转换，直接断言原异常类型和固定人工消息传播，`personal_access_tokens` 计数不增加。`finally` 恢复原 `Hash` facade；未把异常转作 422 凭据错误，也未输出测试密码。没有修改其它测试或生产代码。

## 预算内验证

- 固定本地来源/代码核对：**2/2 轮**。运行前 `bootstrap/cache/config.php` 不存在；`phpunit.xml` 指定 SQLite `:memory:`，应用默认连接优先读取 `APP_DB_CONNECTION`、SQLite URL 读取 `DB_URL`，目标 PHPUnit 可执行文件存在。
- `php -l tests/Feature/AuthPasswordApiTest.php`：**1/1 次**，退出码 `0`。
- 在单一命令环境中固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 并拒绝配置缓存后，运行 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php`：**1/1 次**，退出码 `0`，**13 tests / 84 assertions**，0 failures/errors，另有 **2 deprecations**；原始结语为 `OK, but there were issues!`。未复跑或扩大测试。后续用例继续通过，与本用例 `finally` 恢复 facade 的预期一致。

这仅验证当前本地 Laravel/PHP、人工异常与内存 SQLite 条件下“无关异常仍传播”，不证明真实旧哈希兼容、所有故障类型或生产登录。真实备份、密钥、账号值、生产 DB、SSH/云/API、GitHub、全量测试/build/Docker/WSL 均 `NOT_RUN`；未提交、pull 或 push。回退仅撤销本任务新增的 Hash facade 引用、单个测试方法及本摘要，保留所有前序接受差异与无关工作区内容。作者停 Work LEVEL 2 `ACCEPT/REJECT`，不自接受或派发后继。
