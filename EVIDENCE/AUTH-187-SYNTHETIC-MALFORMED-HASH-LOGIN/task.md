# AUTH-187｜人工异常哈希登录失败关闭回归

**2026-09-27 Work 派发；LEVEL 2，仅本地 synthetic backend。** Assignee：Codex 执行会话 `01a0e08a-91d4-7442-85e4-93e56740b1ca`。依据 AUTH-186 已接受的 docs-only 切片建议，只核对现有登录遇到人工损坏/不支持格式哈希时是否失败关闭；不推断任何真实旧哈希兼容性。

## 精确范围

先核对根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、workflow 技能、Git HEAD/dirty、AUTH-159/186 `work-review.md` 和后者 `plan.md`。唯一允许修改 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`；**仅当定向负例证明现有 `Hash::check` 在特定异常格式上抛出可狭义识别的核验异常时**，才允许修改 `services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php` 的 `login` 核验边界。唯一允许新增本任务目录 `summary.md`。保留两个后端文件既有未提交差异；不得修改其他代码/配置/迁移。

用内存 SQLite 的人工账号及人工异常哈希写入测试行。覆盖损坏/截断和不支持格式，断言无 token/`personal_access_tokens` 增量、响应不含哈希或内部异常、原哈希字节不变；保留人工 bcrypt 正确/错误口令及禁用账号行为。若当前 verifier 返回 false，保持控制器不变，只交付回归测试；若抛出可识别的哈希格式/算法异常，最小范围映射为现有统一 422 凭据错误。不得捕获广义 `Throwable` 或吞掉数据库/配置故障；无法精确确认异常来源时停止代码扩展并记录 `NOT_FIXED`。不设置算法 allowlist、重哈希/重置或真实旧库兼容策略。

## 验证预算与停点

最多 2 轮固定本地来源/代码核对；修改文件各最多 2 次 `php -l`；在明确 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、空 `DB_URL` 的同一命令环境下，定向 `php vendor/bin/phpunit tests/Feature/AuthPasswordApiTest.php` 最多 **2/2 次**（首跑及必要的局部修复后复跑）；最后 1 次精确允许文件路径/差异/哈希/格式核对。运行前确认不会连接非内存 DB；如前提不成立或需第三次运行，停止并报告。不得运行全量测试/build/Docker/WSL，不访问真实备份、密文、密钥、账号值、DB、SSH/云/API、GitHub 或旧 `D:\EliteSync`，不得提交、pull 或 push。保留全部无关 dirty/untracked，旧预算不重置。作者交付 `summary.md` 后停 Work 独立 LEVEL 2 审查，不自接受或派发后继。
