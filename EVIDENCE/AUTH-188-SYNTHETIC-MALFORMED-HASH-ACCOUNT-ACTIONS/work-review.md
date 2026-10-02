# AUTH-188 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受当前本地人工异常哈希下改密及 synthetic 自删的失败关闭修复。** 作者交付后哈希：`AuthController.php` `4E8AC36780B504DBABC115FD6B186455F35526A819F9ABE4A90F3DF38D30063E`，`AuthPasswordApiTest.php` `B2BD5AD9B5742C223676A1E6D040A85C242684B5795C34D879DDF93BB0C29A60`，`summary.md` `1328717EEE04618FFCC87984BF3D257A01EC27F6822A15AD955B7938300FCABD`；Work 独立核对文件、哈希及差异。AUTH-187 的登录边界保留；新测试分别断言异常哈希下改密不改写密码、自删不删除人工账号或已有 token，响应不含哈希或内部异常。原有正常改密、自删及非 synthetic 403 用例仍在同一定向测试文件。

首跑 12 tests / 64 assertions，新增两例因同一 `BcryptHasher` 精确 `RuntimeException` 失败；仅在 `changePassword` 与 `deleteSelf` 的 `Hash::check` 边界将该精确消息映射到原当前密码错误 422，其他 `RuntimeException` 重抛。修复后第二次定向测试 12 tests / 80 assertions、退出 0、0 failures/errors，另有 2 条 deprecations；两次均固定进程内 SQLite `:memory:` 和空 `DB_URL`，配置缓存不存在。两个修改文件语法各 1 次退出 0，测试预算 2/2 耗尽，Work 未复跑。

三个密码核验分支目前重复相同精确异常处理，可在另立有界任务后考虑行为不变的局部收敛；本 ACCEPT 不扩大真实旧哈希兼容或权限语义。该字符串匹配依赖当前 Laravel 实现，框架升级时须复核。真实账号、备份、生产 DB、SSH、GitHub、全量测试和部署均未运行；AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B 与真实回填 `NOT_READY`。未提交、pull 或 push，旧预算不重置。
