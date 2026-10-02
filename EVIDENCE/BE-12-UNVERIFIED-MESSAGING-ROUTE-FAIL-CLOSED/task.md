# BE-12｜未取得真实双证据前的消息路由入口保护

状态：`ISSUED`。风险 LEVEL 3（私密消息/会话路由保护性行为变更）；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果是七条路由的本地默认拒绝候选；交付后停 Work 独立 LEVEL 3 审查。此任务不发布、不连接真实 CN/MC 来源，也不使消息功能可用。

## 固定来源与允许路径

先核对 `D:\EliteSync-v10` 的本地 `main`/HEAD、dirty 工作区与 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、`.agents/skills/elitesync-local-workflow/SKILL.md`、`.agents/skills/elitesync-runtime-slice/SKILL.md`、`EVIDENCE/BE-11-LEGACY-MESSAGING-ROUTE-LIVE-GATE-AUDIT/{plan,work-review}.md`、BE-10 `work-review.md`、`services/backend-laravel/routes/api.php`、`services/backend-laravel/app/Http/Controllers/Api/V1/{MessageController,ConversationController}.php`、`services/backend-laravel/app/Services/{ConversationCapabilityService,ConversationAtomicSendService,ConversationDomainService}.php`、`services/backend-laravel/tests/Feature/{MessageApiTest,ConversationCapabilityFoundationTest}.php`、`services/backend-laravel/phpunit.xml`、`services/backend-laravel/config/database.php`。花括号表示该处列出的两个或三个精确文件，不授权目录枚举。

写入仅限：

- `services/backend-laravel/app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php`（新文件）；
- `services/backend-laravel/routes/api.php`（仅七条目标路由的 middleware 绑定）；
- `services/backend-laravel/tests/Feature/MessagingLiveGateFailClosedRouteTest.php`（新文件）；
- `EVIDENCE/BE-12-UNVERIFIED-MESSAGING-ROUTE-FAIL-CLOSED/summary.md`（新文件）。

不得修改两个旧 Feature 测试或任何 controller/service/model/migration/config。`routes/api.php` 修改前 SHA-256 必须为 `B267673F89D9BD4A804A7A19F3C1917C8CCB0D3B21861856270F77DFE11D9365`；不符即停并报告。保留全部其他 modified/untracked。

## 代码候选与负例

建立明确的**无可信 live evidence 时默认拒绝** middleware，固定返回不透露账号、会话或消息存在性的 404 JSON；不接受 request/header/config/测试标志传入“已授权”布尔值，不读取 BE-10 synthetic sentinel，也不尝试降级用 `DatingMatch`、已有 `Conversation`、缓存或旧 token 当 CN/MC 来源。入口在 controller 调用**之前**拒绝，避免私密预览、已读副作用、发送重放、媒体预检、消息/事件/通知提交。仅对以下七条已注册 `/api/v1` 路由绑定：`GET /messages`、`POST /messages`、`POST /messages/read/{messageId}`、`GET /conversations`、`POST /conversations`、`GET /conversations/{conversationId}`、`GET /conversation-peers/{peerUserId}`。`GET /messages/ws/{userId}` stub 和其他非目标路由不变。保留外层 `auth:sanctum`；不要宣称此 guard 提供真实 live-read/live-send 许可。

新增一个内存 SQLite Feature 测试文件，用虚构用户及必要的虚构旧 match/会话/消息 fixture 验证：七条目标路由在没有可信 CN/MC 来源时均为同一 opaque 404、响应不含正文/预览/附件；尤其覆盖带 `client_message_id` 的重放请求、列表已有私密消息时的响应、已读状态、消息/事件/通知计数不变。可用若干测试方法，不要求七份重复 fixture。验证 `/messages/ws` stub 未被此 middleware 意外覆盖。对原旧正例测试的预期冲突仅在摘要列为后继测试迁移缺口，本任务不得为旧测试恢复私密访问。

## 验证预算和停点

只读预检 `bootstrap/cache/config.php` 不存在、`phpunit.xml` 测试 DB 为 SQLite `:memory:`、应用默认连接优先读取 `APP_DB_CONNECTION` 且 SQLite URL 可读 `DB_URL`；不符则停。每个新/改 PHP 文件允许一次 `php -l`；新增 Feature 文件定向 PHPUnit 首跑一次，若仅本任务自身缺陷失败，可在允许路径修复后最多复跑一次同一文件。测试子进程显式设 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）；若出现非内存或非 SQLite 连接迹象立即停。两个旧 Feature 文件及完整套件本轮 `NOT_RUN`，摘要须明确这两个旧正例与新保护行为冲突，不得称整体测试通过。回退仅撤销本任务 middleware、七处绑定、新测试及摘要，不动原有候选。

`summary.md` 记录改动、七路由覆盖、lint/定向测试实际次数与退出码、tests/assertions、旧测试预期冲突、部署/兼容风险和 `NOT_RUN`。不运行真实消息、数据库、SSH、云、生产 API、备份/解密/恢复，不提交、拉取或推送；任何错误、路由覆盖不完整或私密数据泄出即停 Work 审查，不自接受或继续后继。AUTH/BE 旧预算不重置。
