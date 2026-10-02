# AUTH-189｜三处认证哈希核验处理局部收敛

**2026-09-27 Work 派发；LEVEL 2，行为保持的本地重构。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-187/188 已独立接受当前 Laravel 下人工异常哈希的精确失败关闭处理；`login`、`changePassword`、`deleteSelf` 三处存在相同的 `Hash::check` 异常处理。本任务只在同控制器中减少重复，保持行为与对外响应不变。

## 精确范围

先核对根规则、`CURRENT.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、Git HEAD/dirty、AUTH-187/188 的 `summary.md`/`work-review.md`。唯一允许修改 `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`；唯一允许新增本任务目录 `summary.md`。把三处相同的验证语义提取到控制器私有 helper：缺用户返回 false，正常 `Hash::check` 结果原样返回，**仅**消息为 `This password does not use the Bcrypt algorithm.` 的 `RuntimeException` 返回 false，其他异常原样抛出。保留三个调用点现有 422 字段、token 顺序、密码保存和删除权限/副作用；不更改测试、依赖、配置、schema、算法策略或任何真实数据行为。

## 预算与停点

最多 2 轮固定本地来源/代码核对；控制器最多 1 次 `php -l`；在同一命令环境固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 且确认无配置缓存后，定向 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php` **1/1 次**。若失败，不复跑或扩大修改，记录停点等待新审查。最后 1 次允许文件路径/差异/哈希/格式核对。不得运行全量测试/build/Docker/WSL，不访问真实密文、密钥、账号值、DB、SSH/云/API、GitHub 或旧 `D:\EliteSync`，不得提交、pull 或 push。保留无关 dirty/untracked，旧预算不重置。作者交付 `summary.md` 后停 Work 独立 LEVEL 2 审查，不自接受或派发后继。
