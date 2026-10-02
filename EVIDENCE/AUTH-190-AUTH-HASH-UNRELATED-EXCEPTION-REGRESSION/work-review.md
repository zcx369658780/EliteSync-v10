# AUTH-190 Work 独立审查｜2026-09-27

**LEVEL 2 ACCEPT，仅接受本地人工无关 `RuntimeException` 的测试回归。** 唯一修改 `AuthPasswordApiTest.php` SHA-256 `8E8C7DB35F506918CED1F01425960A13D1C63D4879750BB30DB771CC39A938EB`，回执 `summary.md` SHA-256 `AED8501E45174D7C9D295F0CD8DB7E678A63764946D5472A3632A475CFC8533C`；生产 `AuthController.php` 未变，仍为 AUTH-189 接受哈希 `CCBC5806FB990D43E02308CE496BF40EACB668053D3D7B1B3CAE4101A004DA21`。Work 核对测试：人工账号建立后局部 mock `Hash::check` 抛出与 bcrypt 消息不同的固定人工异常，断言该异常传播且 token 计数不变，`finally` 恢复原 Hash facade；后续定向用例仍通过。

作者测试文件语法 1/1 退出 0，固定进程内 SQLite `:memory:`、空 `DB_URL`、无配置缓存的定向测试 1/1 退出 0、13 tests / 84 assertions、0 failures/errors，另有 2 条 deprecations。Work 未复跑。此接受不证明所有运行故障类别或真实旧库哈希兼容。真实备份/DB、SSH、GitHub、全量测试或部署均未运行；AUTH-170 `UNAVAILABLE/NOT_CHECKED`，AUTH-155 Phase B 与真实账号回填 `NOT_READY`。未提交、pull 或 push，旧预算不重置。
