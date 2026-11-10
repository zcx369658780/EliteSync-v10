# BE-12 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅限本地七条 `/api/v1` 私密路由的默认拒绝保护；不代表真实读发或部署。** 审查对象 SHA-256：`routes/api.php` `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`、新 middleware `A1AF329F4A5E4B9326AE92235BD8D974E373B004045B512E9E084C7B9414552D`、新 Feature test `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`、作者摘要 `C4AA0FE1AA28708D8A8F33E46AB1C98361F97188D2837C3AE0F7CDD1281CB8DE`。

Work 核对路由 diff，仅将 `GET/POST /messages`、`POST /messages/read/{messageId}`、`GET/POST /conversations`、`GET /conversations/{conversationId}` 和 `GET /conversation-peers/{peerUserId}` 七条绑定新 middleware。middleware 无放行分支，固定返回单字段 opaque 404，发生在控制器调用前；既有外层 `auth:sanctum`、参数约束、throttle 与 `/messages/ws/{userId}` stub 未被编辑。虚构 fixture 同时具备旧 released match、会话、未读消息及带 key 的重放消息；测试八次请求覆盖七路由与重放，均返回相同 404，消息/事件/通知计数及已读状态不变，stub 仍 503。没有引入 CN/MC 自报、BE-10 sentinel 或旧能力绕过。

作者三份 PHP 语法检查各退出 0；单个新 Feature 文件在显式限定内存 SQLite 后首跑退出 0，**2 tests/24 assertions**，无失败/错误，另有 2 deprecations。`git diff --check` 对跟踪路由文件退出 0；Work 单独读取并哈希两份未跟踪新 PHP。本审查未复跑测试。

**集成限制**：两个既有 Feature 文件的旧正例与新路由默认拒绝冲突，本任务按预算 `NOT_RUN`，故不能称相关完整套件通过。下一独立任务须保留对旧服务/持久化行为的历史测试覆盖，同时让真实路由的拒绝测试成为 v10 权限判据；任何测试隔离仅可在测试进程内绕过这个 middleware，不能改生产路由或暗示旧 match/会话拥有 v10 live 权限。若未来部署，本保护会使现有客户端七条路由不可用；上线、恢复真实读发、用户提示和可信 CN/MC 来源仍需独立任务与风险门。

本地代码未提交、拉取或推送；未访问 SSH、生产 DB、真实消息、备份/密钥或执行恢复。旧 BE/AUTH 预算不重置。
