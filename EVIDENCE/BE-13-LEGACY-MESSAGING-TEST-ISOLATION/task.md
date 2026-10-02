# BE-13｜旧消息内部行为测试与真实路由保护的隔离

状态：`ISSUED`。风险 LEVEL 3（测试是否错误地将旧 match/会话行为提升为 v10 live 权限）；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果为两个旧 Feature 文件的**仅测试进程**隔离标记；交付后停 Work 独立 LEVEL 3 审查。

## 精确范围

先核对 `D:\EliteSync-v10`、本地 `main`/HEAD、dirty 工作区与 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能、`EVIDENCE/BE-11-LEGACY-MESSAGING-ROUTE-LIVE-GATE-AUDIT/work-review.md`、`EVIDENCE/BE-12-UNVERIFIED-MESSAGING-ROUTE-FAIL-CLOSED/{task,summary,work-review}.md`，以及精确代码 `services/backend-laravel/routes/api.php`、`services/backend-laravel/app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php`、以下三份 Feature 测试、`services/backend-laravel/phpunit.xml` 和 `services/backend-laravel/config/database.php`。

仅允许修改 `services/backend-laravel/tests/Feature/MessageApiTest.php` 与 `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php`，并新增本目录 `summary.md`。修改前两文件 SHA-256 分别须为 `23B25F2953C14C67F8D0E3BA6C3DB1B2F55F210B33811545A00EC8BC4A0E0303` 与 `DEA6BEDF98D1E1CEA89C4F771227B60B9DCCA5D69A650D5FEB9BAC76AFCEA824`；BE-12 新路由保护测试须仍为 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`，路由文件须仍为 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`。任一不符即停，不覆盖其他变化。

## 候选行为

这两个旧测试文件只保留为**legacy controller/service/storage 行为回归**，其 released `DatingMatch`、旧会话或 block 后历史读正例不代表 v10 live-read/live-send 权限。可在各测试类的 `setUp()` 中于 `parent::setUp()` 之后仅调用 `$this->withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class)`，并写简短说明，令旧测试在测试进程中继续锻炼内部路径。不得调用无参数 `withoutMiddleware()`、关闭 `auth:sanctum`、修改断言以掩盖失败、跳过测试、改生产代码或把旧正例标为 v10 权威。BE-12 独立新路由测试必须继续**不绕过** middleware，证明真实注册入口仍统一 fail closed。

## 验证预算与停点

预检 `bootstrap/cache/config.php` 不存在、PHPUnit SQLite `:memory:`、应用 `APP_DB_CONNECTION` 优先级和 SQLite `DB_URL` 覆盖风险；不符即停。两份修改测试各一次 `php -l`。三个定向 Feature 文件（两个旧文件加 BE-12 新保护测试）各首跑一次，使用单个 shell/子进程内显式 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）；单文件若仅本任务新增隔离代码有缺陷，可在允许文件修正后最多复跑该失败文件一次。其他失败如实记录并停 Work 审查，不扩大到生产代码或复用旧预算。完整套件 `NOT_RUN`。

`summary.md` 记录修改前后哈希、仅测试进程旁路的精确 class、三份文件各自实际 tests/assertions/退出码、任何旧断言失败及历史/新权限边界。回退只撤销本任务两文件中的隔离标记及本摘要，保留 BE-12 guard 与新路由测试。不得访问旧 `D:\EliteSync`、SSH/云/生产 API、真实消息/数据库、备份/密钥/恢复，不提交、拉取或推送；作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
