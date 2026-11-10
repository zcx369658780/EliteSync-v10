# APP-G11-11 Work 独立审查｜2026-09-29

**LEVEL 2 REJECT，拒绝将本候选记为已运行验证的合同对齐。** Work 核对两文件当前 SHA-256 与作者摘要一致：service `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9`，测试 `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102`。静态差异仅一处 stored 类别字面量和三处旧测试期望；测试文件原有 middleware 旁路差异保留。

指定目标文件首跑退出 1，9 failed、0 assertions；所有用例在迁移准备阶段连接 `mariadb` 被拒绝，本次字段断言未执行。任务规定非本任务原因失败即停，作者未复跑；`php -l` 与 `git diff --check` 未运行，不写成通过。候选及失败证据保留供新任务复核，不覆盖、不回退其它既有改动。检查发现 `phpunit.xml` 声明内存 SQLite，但 `config/database.php` 的默认连接优先读取 `APP_DB_CONNECTION`；此次为何实际选中 mariadb 尚未在任务预算内证实。

旧预算不重置；本审查不放行 live 404 中间件、真实 Conversation read/send、actor/audience 或空 peer 过滤变更。G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。本地 main HEAD 未动，无提交、pull、push。
