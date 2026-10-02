# APP-G11-14｜Stored Conversation 摘要不以查看者补造 peer

状态：`ISSUED`；风险 `LEVEL 2`（Conversation 响应身份来源）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确目标与路径

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-G11-10/12/13 的 Work 审查，并核对 `ConversationDomainService::peerUserId` 与 `summarizeConversation` 当前对端成员选择。仅允许修改：

| 文件 | 输入 SHA-256 |
| --- | --- |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102` |

另允许新增本目录 `summary.md`。只收紧 stored `summarizeConversation` 的 peer 选择：必须来自**当前仍在会话的非查看者成员**；对端缺失或已离开时 `peer_user_id` 保留 null，不把查看者本人当对端，也不从 room key 或数字 `id` 补造。保持正常双成员正例、已接受的 `stored_conversation` 类别、`conversation_id`、eligible 路径与 controller 过滤。用人工内存 SQLite 测试覆盖当前对端、仅查看者成员和已离开对端，核对 peer 与 `id` 不被自我身份补造。不要改 schema、权限、消息或其它服务。

## 本任务新一次性预算与停点

编辑前核对两输入哈希、本地 PHP/vendor、`phpunit.xml` 与 config cache。必要编辑后，两文件各一次 `php -l`，两文件一次 `git diff --check`。只在子进程作用域设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`，执行一次 `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php`；仅本任务两文件的实现/夹具缺陷可修后额外复跑同一命令一次。任务外失败即停，不改配置或启动服务。旧预算不重置。

`summary.md` 记录前后哈希、差异、测试数/断言/退出码、预算、静态检查、兼容局限与回退范围。回退只撤销本任务两文件新增差异及摘要，保留 APP-G11-11/12 的 stored 类别、APP-G11-13 过滤和其它所有既有工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或启动后继。当前 live middleware 仍 404；真实 Conversation read/send、actor/audience、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门不变。
