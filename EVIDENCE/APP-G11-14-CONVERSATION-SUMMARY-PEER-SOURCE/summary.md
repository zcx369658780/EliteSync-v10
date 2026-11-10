# APP-G11-14｜Stored 摘要 peer 来源候选

状态：Codex 本地候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。全部既有 dirty/untracked 保留；无提交、pull、push。

| 允许文件 | 输入 SHA-256（与任务单一致） | 最终 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9` | `0062AE186BDC6701F387947AD13AC6644ACC4CB1D883ADA3B4862A66CBAB68E6` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102` | `8200E7878852A0EE4DABFB8FFC102B5852C8EA8BFBD164FC7B7887A32950EB03` |

目标差异：`summarizeConversation` 只选当前未离开的非查看者成员作为 peer，去掉“找不到对端就回退查看者”逻辑。对端缺失或已离开时，`peer_user_id` 为 null，`id` 保持原有 room key 回退，不成为查看者 ID；没有从 room key 或数字 `id` 补造 peer。正常双成员摘要、`stored_conversation` 类别、`conversation_id`、eligible 路径和 APP-G11-13 控制器过滤未改。测试在现有 Feature 文件增加一个人工场景，依次核对当前对端、仅查看者成员、已离开对端的 peer 与 `id`。

编辑前核对了两文件 SHA-256、本地 PHP、`vendor/autoload.php`、`phpunit.xml` 内存 SQLite 声明和不存在的 config cache。定向测试只在一次性命令进程设 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`；未改持久配置、启动数据库服务或接触真实数据。

| 本任务验证 | 结果 | 新预算 |
| --- | --- | --- |
| 两文件各一次 `php -l` | 均退出 0，无语法错误 | 各 1/1 |
| 两文件一次 `git diff --check` | 退出 0，无空白错误输出 | 1/1 |
| `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php` | 首跑退出 0；10 个用例、95 个断言；PHP 8.5 `PDO::MYSQL_ATTR_SSL_CA` 弃用提示，无断言失败 | 1/1；未修复复跑 |

测试文件仍有既存 `withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class)`，因此通过只证明人工内存 SQLite 下的内部合同，不能推论当前 live GET 可达。当前 live middleware 仍先行 404；真实 Conversation consent/read/send、actor/audience 或账号兼容均未验证。回退仅撤销本任务服务 peer 选择差异、测试新增场景和本摘要，保留 APP-G11-11/12 stored 类别、APP-G11-13 过滤及全部其它工作区。G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
