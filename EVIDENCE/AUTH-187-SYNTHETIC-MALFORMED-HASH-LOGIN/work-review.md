# AUTH-187 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受当前本地人工异常哈希的登录失败关闭修复。** 作者交付后哈希：`AuthController.php` `B62A4E30430F95604B355FF492B8E68CFE46AA913A3EAAA29497016A0E45B85D`，`AuthPasswordApiTest.php` `2701921141D2E0F608F4800DFFBB5282CDEC4B1B2AF7842FC7F2AB03B96D442C`，`summary.md` `61FE15BB3039F1794C72E15F1155903344CC4B478FAC7AA5B35FD286D0136378`；Work 独立核对当前文件与哈希。保留 AUTH-157/159 已接受的旧差异，新测试用人工截断及不支持格式哈希断言统一 422、无 token/敏感输出/哈希改写，另保留正常 bcrypt 与禁用账号对照。

作者首跑 10 tests / 45 assertions，新增两例因 `BcryptHasher` 的精确 `RuntimeException` 失败；仅在 `login` 的 `Hash::check` 边界把消息 `This password does not use the Bcrypt algorithm.` 映射到原统一凭据错误，其他 `RuntimeException` 重抛。修复后第二次定向测试 10 tests / 61 assertions、退出 0、0 failures/errors；PHPUnit 报 2 条 deprecations，不能写成无警告。Work 核对命令均固定进程内 SQLite `:memory:`、空 `DB_URL` 且无配置缓存；语法检查两个目标文件各 1 次退出 0，测试预算 2/2 已耗尽，Work 未复跑。此字符串匹配绑定当前 Laravel 实现，升级框架后须重新核对；本接受不证明真实旧库哈希算法/兼容、最终账号模型或生产登录就绪。

未运行真实备份/DB、SSH、云、GitHub、全量测试或部署；未提交、pull 或 push。AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B 与真实回填 `NOT_READY`；旧预算不重置。
