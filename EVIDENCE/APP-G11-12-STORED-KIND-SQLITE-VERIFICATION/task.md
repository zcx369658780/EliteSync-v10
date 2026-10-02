# APP-G11-12｜Stored 类别候选的进程内存 SQLite 验证

状态：`ISSUED`；风险 `LEVEL 2`（Conversation 响应合同，verification-only）；派发既有 Codex 执行会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 固定候选与范围

唯一实时仓库 `D:\EliteSync-v10`，本地 main HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，全部既有 dirty/untracked 保留。先读根规则、当前状态、APP-G11-11 的 `task.md`、`summary.md`、`work-review.md`。**不得修改源代码、测试或配置文件**；唯一允许新增本目录 `summary.md`。

固定候选 SHA-256：`services/backend-laravel/app/Services/ConversationDomainService.php` 为 `998958689FB6A2BA2F4170BB8A53120123B273683D5AB8678D551AB49425BAF9`，`services/backend-laravel/tests/Feature/ConversationCapabilityFoundationTest.php` 为 `89B61C9F49E88020686B2E4B824FD3B4E0D0E17F600E52402BD00B283D57B102`。不符即停。只读核对 `phpunit.xml` 的 SQLite 声明、`config/database.php` 的 `APP_DB_CONNECTION` 优先级和 config cache 是否存在；不读取 `.env` 内容，不输出任何凭据或连接字符串。当前 live 404 middleware 与测试文件原有旁路保持。

## 本任务新一次性验证预算

先对固定两文件各运行一次 `php -l`，并针对这两文件运行一次 `git diff --check`。然后仅在 **子进程作用域** 明确设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`，运行一次 `php artisan test tests/Feature/ConversationCapabilityFoundationTest.php`；不得改变持久环境、`.env` 或连接 MariaDB。仅因本任务的命令包装/环境变量未传入而产生的失败，最多修正命令后额外复跑同一目标文件一次；其它失败即停，不改代码/夹具/配置或扩大测试。禁止启动数据库服务、容器、网络、真实 DB 或后台进程。

`summary.md` 记录固定哈希、静态检查和定向运行的退出码/测试数/断言/首个失败、实际预算、环境仅为进程内存 SQLite 的证据及局限。不能以测试文件旁路 middleware 的通过推论 live GET、真实 consent/read/send 或账号兼容。不得访问旧 `D:\EliteSync`、真实备份/密钥、SSH、云/生产 API；不得提交、pull、push、自接受或自行启动后继。旧 APP-G11-11 预算不重置；空 peer 过滤、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复和账号回填门不变。
