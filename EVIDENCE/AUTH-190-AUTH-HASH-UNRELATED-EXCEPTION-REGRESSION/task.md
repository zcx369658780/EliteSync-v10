# AUTH-190｜无关核验异常不得被统一凭据错误吞掉

**2026-09-27 Work 派发；LEVEL 2，仅本地 synthetic 测试。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-189 的 helper 只允许把精确 bcrypt 格式异常转为 false；本任务测试另一个 `RuntimeException` 应原样抛出，防止今后把数据库/配置/其它故障误报为密码错误。

## 精确范围

先核对根规则、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、Git HEAD/dirty、AUTH-187/188/189 的 `summary.md`/`work-review.md`。唯一允许修改 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`，唯一允许新增本目录 `summary.md`；不改控制器或其它代码。用人工账号和 `Hash` facade 的局部 fake/mock，使 `check` 在登录时抛出**与已接受精确 bcrypt 消息不同**的人工 `RuntimeException`；直接断言该异常仍传播且未新增 token。测试不得输出真实/模拟密码或把异常作为 HTTP 422 凭据错误。避免 mock 污染后续用例；若框架测试设施无法可靠局部隔离，记录 `NOT_FIXED`，不改生产代码兜底。

## 预算与停点

最多 2 轮固定本地来源/代码核对；测试文件最多 1 次 `php -l`；在单一命令环境固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 且确认无配置缓存，定向 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php` **1/1 次**。失败即停，不复跑或扩大修改；最后 1 次允许文件路径/差异/哈希/格式核对。不得运行全量测试/build/Docker/WSL，不访问真实密文、密钥、账号值、DB、SSH/云/API、GitHub 或旧 `D:\EliteSync`，不得提交、pull 或 push。保留无关 dirty/untracked，旧预算不重置。作者交付 `summary.md` 后停 Work 独立 LEVEL 2 审查，不自接受或派发后继。
