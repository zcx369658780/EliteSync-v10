# AUTH-159｜人工生成 bcrypt 哈希的本地登录探针

状态：`ISSUED`。风险 LEVEL 2（auth 密码哈希兼容性边界）；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果是目标 Feature 文件中的一个 synthetic 用例；交付后停 Work 独立 LEVEL 2 审查。

## 固定来源和写入范围

先核对 `D:\EliteSync-v10` 的本地 `main`/HEAD、dirty 工作区与 `TASK_CURRENT.md`。只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 `.agents/skills/elitesync-local-workflow/SKILL.md`、`EVIDENCE/AUTH-156-V10-ACCOUNT-TARGET-CONTRACT/{plan,work-review}.md`、`EVIDENCE/AUTH-158-BIRTH-PLACE-SQLITE-VERIFICATION/{summary,work-review}.md`、`services/backend-laravel/app/Http/Controllers/Api/V1/AuthController.php`、`services/backend-laravel/app/Models/User.php`、`services/backend-laravel/config/database.php`、`services/backend-laravel/phpunit.xml` 和目标测试文件。仅允许修改 `services/backend-laravel/tests/Feature/AuthPasswordApiTest.php`，新增 `EVIDENCE/AUTH-159-SYNTHETIC-BCRYPT-LOGIN-PROBE/summary.md`；保留文件内 AUTH-157 已接受的测试和所有无关工作区差异。

## 测试候选

新增单个 Feature 用例，用**虚构账号、虚构密码和运行时 `password_hash(..., PASSWORD_BCRYPT)` 生成的哈希**模拟一条外部已有 bcrypt 哈希。可先建立 synthetic `User`，再经测试进程的内存 SQLite `DB::table('users')` 直接写入哈希以绕过模型 `hashed` cast；不得用真实备份、真实哈希或账号值。断言现有 `/api/v1/auth/login` 对正确虚构密码接受、错误密码拒绝且不发 token，并核对登录前后持久哈希字节不被静默改写。只证明当前测试环境中的 bcrypt 路径；不探测或声称 2.6/主库实际哈希算法、参数、编码和全部账号可登录，不设计迁移脚本或重置密码流程。若固定代码不支持此用例，准确记录 `NOT_VERIFIED` 而不改生产逻辑。

## 有界验证与停点

先只读确认目标测试文件 SHA-256 为 AUTH-158 接受时的 `F0D9FE995012B74E30515DC527A120343C98E13C7B1449B3808D7A7F332F342B`、`bootstrap/cache/config.php` 不存在，以及 `phpunit.xml` 选择 SQLite `:memory:`；任一不符立即停。允许一次 `php -l`。定向 PHPUnit 最多首跑一次；仅因**新增用例自身**缺陷失败时，允许在同一目标文件修正并最多复跑一次，不得为环境失败或未知原因重试。每次测试须在单个子进程内显式覆盖 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）；如出现非 SQLite/非内存连接迹象立即停。

`summary.md` 仅记录固定哈希预检、实际差异、语法/测试退出码和 tests/assertions、失败分类、预算消耗、`NOT_RUN` 与边界；不要输出合成哈希正文或任何真实秘密。回退仅撤销本任务新增测试及摘要。作者交付后停 Work LEVEL 2 ACCEPT/REJECT，不自接受、不创建后继。

不得访问旧 `D:\EliteSync`、`.env`、备份/密钥目录、真实账号行、SSH/云/生产 API 或生产 DB；不得解密、恢复、迁移、提交、拉取或推送。Owner 的新 SSH 授权只供另行限定的必要核对，本任务不使用；AUTH-152～158 与 BE-01～10 的旧预算不重置。
