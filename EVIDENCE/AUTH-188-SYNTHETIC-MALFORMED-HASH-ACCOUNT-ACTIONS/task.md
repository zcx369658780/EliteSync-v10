# AUTH-188｜人工异常哈希下改密与 synthetic 删除失败关闭

**2026-09-27 Work 派发；LEVEL 2，仅本地 synthetic backend。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。AUTH-187 只修登录核验。`changePassword` 与 `deleteSelf` 也调用当前密码哈希核验；本任务只用人工数据验证异常格式下不会执行改密或删除。

## 精确范围

先核对根规则、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、Git HEAD/dirty、AUTH-187 `summary.md`/`work-review.md`。唯一允许修改 `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` 的 `changePassword`/`deleteSelf` 核验分支、`services/backend-laravel/tests/Feature/AuthPasswordApiTest.php` 的定向回归；唯一允许新增本目录 `summary.md`。保留现有未提交 AUTH-157/159/187 差异，不改 `login`、User、迁移、配置或路由。

用内存 SQLite 和人工异常哈希分别覆盖改密及 synthetic 账号删除：响应为原有统一当前密码错误 422，响应不得含哈希或异常细节，改密时哈希字节不变，删除时账号和 token 仍在；原有正确/错误口令及非 synthetic 403 行为保持。仅当测试证明与 AUTH-187 同一可狭义识别的核验异常，才在各方法的 `Hash::check` 边界作相同精确消息处理；其他运行异常必须重抛。不得捕获广义 `Throwable`、创建算法 allowlist、改变删除权限或支持真实旧哈希。无法确认异常来源时记录 `NOT_FIXED` 并停扩展。

## 预算与停点

最多 2 轮固定本地来源/代码核对；修改文件各最多 2 次 `php -l`；在每次命令环境中固定 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 且确认无配置缓存，定向 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php` 最多 **2/2 次**（首跑及必要局部修复后复跑）；最后 1 次允许文件路径/差异/哈希/格式核对。若内存 DB 前提不成立或需第三次运行，停止并报告。不得运行全量测试/build/Docker/WSL，不访问真实密文、密钥、账号值、DB、SSH/云/API、GitHub 或旧 `D:\EliteSync`，不得提交、pull 或 push。保留无关 dirty/untracked，旧预算不重置。作者交付 `summary.md` 后停 Work 独立 LEVEL 2 审查，不自接受或派发后继。
