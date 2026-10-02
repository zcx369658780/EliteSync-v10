# AUTH-159 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅限当前本地 synthetic bcrypt 登录路径。** 审查对象为 `AuthPasswordApiTest.php` 中一个新增用例和作者 `summary.md`；目标测试文件 SHA-256 `E5389E0FF7DDB21B2C89AAF40741881376EBB889C1657E82E679704D03EE34B1`，摘要 SHA-256 `C11071DD675C5DA7CF5C2031665D21B6B1C9E0A5AB200E621A3599F1AA61D513`。

Work 对照任务单、现有 `AuthController::login`、`User` 的 `hashed` cast 及测试差异，确认新增用例只用虚构账号与运行时 `password_hash(..., PASSWORD_BCRYPT)` 生成的哈希，经测试进程内的 `DB::table('users')` 直接写入以绕过模型 cast；错误密码期望 422 且 token 计数不增加，正确密码期望登录成功，前后哈希保持字节相等。AUTH-157 已接受的出生地点测试保留，无认证实现、模型或迁移改动。`git diff --check` 对目标文件退出 0。

作者预检确认原目标文件哈希、无配置缓存、PHPUnit SQLite `:memory:` 与应用连接选择优先级；在单个 shell 内明确覆盖 SQLite 内存连接及空 `DB_URL`。一次定向 PHPUnit 退出 0，**7 tests/37 assertions**，无失败/错误，另有 2 deprecations；PHP 语法检查退出 0，未复跑。本审查没有重复运行测试，亦未调查弃用来源。

这证明人工生成的 bcrypt 哈希在当前本地测试环境可由现有登录流程验证，且该用例未观察到静默改写；**不**证明主库或 2.6 备份实际使用 bcrypt、参数/编码兼容、全部账号可登录、旧哈希可迁或新 v10 auth/account schema 已确定。真实备份、账号行、SSH、生产 DB、解密/恢复及迁移均未执行；未提交、拉取或推送。后续若要处理真实哈希，须先有受保护的逐对象来源事实和独立高风险门。
