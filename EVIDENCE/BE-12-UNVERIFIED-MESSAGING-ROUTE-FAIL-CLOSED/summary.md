# BE-12｜七条消息/会话路由默认拒绝候选｜2026-09-27

**作者结果：本地 fail-closed 候选的定向测试通过，待 Work 独立 LEVEL 3 审查；未部署、未建立真实 live 权限。** 本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，原有 modified/untracked 保留，未提交、拉取或推送。

## 精确差异和预检

修改前 `services/backend-laravel/routes/api.php` SHA-256 为任务固定值 `B267673F89D9BD4A804A7A19F3C1917C8CCB0D3B21861856270F77DFE11D9365`；`bootstrap/cache/config.php` 不存在；`phpunit.xml` 指定 SQLite `:memory:`；`config/database.php` 的默认连接优先读取 `APP_DB_CONNECTION`、SQLite URL 可读 `DB_URL`。四项前置条件均满足。

| 允许路径 | 本次差异 | 最终 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php` | 新增无放行分支的 middleware；始终返回同一 `404 {"message":"conversation unavailable"}`，不使用 request/header/config、旧 match/会话或 BE-10 synthetic sentinel 授权。 | `A1AF329F4A5E4B9326AE92235BD8D974E373B004045B512E9E084C7B9414552D` |
| `services/backend-laravel/routes/api.php` | 只为七条目标路由绑定上述 middleware；保留外层 `auth:sanctum`、原 throttle、参数约束和 `/messages/ws/{userId}` stub。 | `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675` |
| `services/backend-laravel/tests/Feature/MessagingLiveGateFailClosedRouteTest.php` | 新增虚构旧 match/会话/消息 fixture 和保护性负例；检查八次请求覆盖七条路由（含 keyed replay），统一 opaque 404、消息/事件/通知/已读状态不变；另检查 ws stub 仍 503。 | `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8` |

七条覆盖：`GET /api/v1/messages`、`POST /api/v1/messages`、`POST /api/v1/messages/read/{messageId}`、`GET /api/v1/conversations`、`POST /api/v1/conversations`、`GET /api/v1/conversations/{conversationId}`、`GET /api/v1/conversation-peers/{peerUserId}`。拒绝发生在各 controller 调用之前，因而旧预览/未读构造、自动已读、重放内容响应、附件预检、消息/事件/通知提交路径均无法由这些入口继续到达。测试响应是精确单字段 JSON，不含正文、预览或附件。本候选没有启用 CN/MC 来源或真实 read/send。

## 预算内验证

在 `services/backend-laravel` 对 middleware、`routes/api.php`、新 Feature 文件各执行 `php -l` **一次**，三项均退出码 0、无语法错误。对新 Feature 文件仅首跑 **一次**：在单个测试 shell 中覆盖 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），执行 `php vendor\bin\phpunit tests\Feature\MessagingLiveGateFailClosedRouteTest.php`；退出码 **0**，**2 tests / 24 assertions**，0 failures、0 errors，另有 **2 deprecations**，原始状态 `OK, but there were issues!`。复跑 **0 次 / NOT_RUN**，没有非 SQLite 或非内存连接迹象。`git diff --check -- routes/api.php` 退出 0；它不覆盖两份未跟踪新 PHP，作者另作语法检查、读取和 SHA-256 核对。

`MessageApiTest.php`、`ConversationCapabilityFoundationTest.php` 和完整套件均 **NOT_RUN**。它们的旧 released `DatingMatch` 即可成功发/读、会话可见、block 后仍可历史读等正例与当前七路由统一拒绝相冲突；不能把旧套件称为通过，也不得为满足旧期望恢复私密访问。后继若处理这些测试，须另发任务、明确新历史权威与新测试预算。

**兼容/部署风险**：若未来部署，现有客户端的这七条私密路由会统一得到 404，消息读发、会话列表/详情、已读更新都不可用；本地测试不能证明线上路由缓存、部署版本、真实用户影响或产品恢复路径。真实可信 CN/MC 签发与当次获取、auth/session、原子 writer 和历史访问仍需独立合同。回退仅撤销本任务 middleware、七处绑定、新 Feature 文件及本摘要；保留 BE-10/11 与全部原有脏工作区。真实消息、DB、SSH/云/生产 API、备份/解密/恢复、部署均 **NOT_RUN**。作者停 Work LEVEL 3 独立 ACCEPT/REJECT，不启动后继。
