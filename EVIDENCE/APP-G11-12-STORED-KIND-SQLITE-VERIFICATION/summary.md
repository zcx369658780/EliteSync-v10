# APP-G11-12｜固定候选的内存 SQLite 验证回执

状态：Codex verification-only 回执，待 Work 独立 LEVEL 2 审查；不自接受 APP-G11-11 候选。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。本任务没有修改源码、测试、配置或持久环境；只新增本摘要。全部既有 dirty/untracked 保留，无提交、pull、push。

| 固定候选文件 | 执行前及执行后 SHA-256 |
| --- | --- |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9` |
| `services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` | `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102` |

只读前置核对：`phpunit.xml:27-28` 声明 `DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`；`config/database.php:20` 默认连接优先取 `APP_DB_CONNECTION`，`:35-38` 的 sqlite 数据库值取 `DB_DATABASE`；`bootstrap/cache/config.php` 不存在；本地 `vendor/autoload.php` 和 PHP 可用。未读取 `.env`，未输出凭据或连接字符串。

| 本任务检查 | 实际结果 | 预算 |
| --- | --- | --- |
| 两文件分别 `php -l` | 各退出 0，均无语法错误 | 各 1/1 |
| 两文件 `git diff --check` | 退出 0，无空白错误输出 | 1/1 |
| `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php` | **退出 0；9 个用例完成，85 个断言，首个失败：无。** 输出将 9 个用例标为 `DEPR`，原因是 PHP 8.5 下 `PDO::MYSQL_ATTR_SSL_CA` 弃用提示；不是测试断言失败。 | 1/1，未复跑 |

定向测试由一次性命令进程设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:` 后启动；该环境仅作用于此次 shell/其 PHP 子进程，未写配置或持久环境。结合无 config cache、配置优先级和测试完成回执，本次已避开 APP-G11-11 首跑所见的 `mariadb` 连接阻断；未启动数据库服务或容器。旧 APP-G11-11 的 `9 failed / 0 assertions` 及其预算保持历史事实，不被本回执改写。

测试文件既有 `withoutMiddleware(DenyUnverifiedMessagingLiveAccess::class)`，所以本次验证的是人工数据下的内部 stored/eligible 响应合同与相关负例；即使其路由断言返回 200，也不证明当前 live GET 可达。当前 live middleware 仍先行 404；真实 consent、read/send、actor/audience、账号兼容及生产行为均未验证。空 peer 过滤、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填门不变。固定代码候选是否接受由 Work 独立裁决。
