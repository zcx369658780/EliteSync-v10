# APP-G11-11｜Codex 候选与首个停点

状态：两文件候选已写入，定向测试在任务外数据库连接阶段失败；待 Work 独立 LEVEL 2 审查，未自验收。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，无提交、pull、push；其它 dirty/untracked 保留。

| 文件 | 编辑前 SHA-256（与 task.md 一致） | 编辑后 SHA-256 |
| --- | --- | --- |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `70B071A91C130C70194982F873E21C478E1BA6EBE17069C69BC03FBE8F635588` | `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `97CD987BDA73C0FE42038D08F5FF40DEA6AF14ECEB1457F2F21EFD35868AB56E` | `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102` |

目标差异：`summarizeConversation` 的 stored `entry_kind` 唯一生产者字面量由 `conversation` 改为 `stored_conversation`；同一测试文件中三个依赖旧字面量的 stored 断言同步调整。`conversation_id`、`peer_user_id`、eligible `entry_kind`/ID、列表空 peer 过滤、控制器及 live 404 middleware 未改。测试文件原有 `withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class)` 夹具是本任务输入中的既有差异，本次保留；这些断言即使通过，也只能证明旁路后的人工内部合同，不能证明当前 live GET 可达。

验证预算：编辑前两文件哈希匹配；`services/backend-laravel/vendor/autoload.php` 存在，本地 PHP 8.5.3 可用。必要编辑后，唯一一次 `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php` 已运行，**退出 1；9 failed、0 assertions**。所有用例在迁移准备时出现 `SQLSTATE[HY000] [2002]`，连接名 `mariadb`，连接被本机拒绝；尚未进入本次响应字段断言。失败属于本任务范围外的测试数据库环境，按 task.md 停止，没有改夹具/配置，也未复跑。授权的额外复跑预算未使用，且未因环境失败启用。

由于首跑遇任务外原因后必须停止，两文件各一次 `php -l` 和两文件 `git diff --check` **未运行**；不能声明语法、空白或测试通过。当前候选的兼容效果仅有静态差异，没有本次运行证明。Work 可审查并决定后续独立任务或环境处置；Codex 不自行扩展路径或预算。

回退范围只涉及本任务新增的一处 service 字面量、三处测试期望和本摘要，须保留测试文件原有 `withoutMiddleware` 差异及全部其它工作区内容。真实 Conversation read/send、actor/audience、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
