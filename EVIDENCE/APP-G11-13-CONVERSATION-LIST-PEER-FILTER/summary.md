# APP-G11-13｜Conversation 列表 peer 过滤候选

状态：Codex 本地候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。其它既有 dirty/untracked 保留；无提交、pull、push。

| 允许文件 | 编辑前 | 最终 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php` | SHA-256 `E302A5DDFF313C8B56BE4D5A444AF26446B4B9DAE4EF9FC7210E4EB780D99678`，与任务单一致 | `8E051D29E99C8BBC7D2ED13463E614944CCFD4860198DB14B6A5158BFA9F40BC` |
| `services/backend-laravel/tests/Unit/ConversationListPeerFilterTest.php` | 不存在，与任务单一致 | `A3356D6FACA07D19B1434E2E0A2AB7D6838B21E3A790B5366A1C81868A871739` |

目标差异：仅 `ConversationController::index` 要求列表项显式 `peer_user_id` 为正整数，且 `canRead(actor, peer)` 返回真；通过过滤的项才附加原有 `conversation_capability`。缺失、null、0、负数、数字字符串、浮点数、布尔值和数组不再经 `empty(...)` 放行，也不从 `id` 或 room key 补造 peer。保留有效 stored/eligible 项、`items`/`total` 与原 note 计算；`store`、`show`、`showPeer` 未改。

新人工 Unit 直接调用 controller，用 mock service/capability 检查上述无效 peer 被排除、正 peer 根据 `canRead` 保留或排除、只有保留项执行 `evaluate` 并附加 capability，以及空列表 `items`/`total` 一致。测试未请求路由、未旁路或修改 live middleware，也未使用真实数据库。

| 本任务验证 | 结果 | 一次性预算 |
| --- | --- | --- |
| `php artisan test tests/Unit/ConversationListPeerFilterTest.php` | 首跑退出 0，2 个用例、19 个断言；PHP 8.5 的 `PDO::MYSQL_ATTR_SSL_CA` 弃用提示，无断言失败 | 1/1；未修复复跑 |
| controller 与新 Unit 各一次 `php -l` | 均退出 0，无语法错误 | 各 1/1 |
| 两目标路径 `git diff --check` | 退出 0；新文件尚未跟踪，不由 Git 此项覆盖 | 1/1 |
| 新未跟踪 Unit 行尾空白检查 | 退出 0，无行尾空白 | 1/1 |

本结果只证明人工输入下的控制器内部过滤合同。当前 `DenyUnverifiedMessagingLiveAccess` 仍先行返回 404；不能据此宣称 live GET 可达、真实 consent/read/send、actor/audience 或账号兼容。回退只撤销本任务 controller 的过滤差异并移除新 Unit 与本摘要，保留先前已接受的 stored 类别等所有其它工作区内容。G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。
