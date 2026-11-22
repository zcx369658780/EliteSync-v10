# EliteSync V2｜P0 脱敏证据索引

逐条 SHA-256 对应本轮本机脱敏回执。源数值、会话内容、回滚原件及字段级审计仅留 root 私有取证目录。

| 回执 | SHA-256 | 证明范围 |
| --- | --- | --- |
| `02-p0-prep-backup.json` | `9056409e08f4a044ca384d807636bd0434a32a7e56fd3b24fbcc0c5cbdc8a451` | 保留首次前态查询 STOP |
| `02a-target-schema.json` | `8465c6e725102664da312d1afb7c509581b1c813f856efc079069c14e0a70a4b` | 目标实际会话表和列类型核对 |
| `02b-p0-prep-backup.json` | `bf5040dc52f1bd92c724ad01de8dc14db5fcb4b38601ea21939ed1b227bb2fdf` | 唯一源库匹配、目标备份及隔离恢复验证 |
| `02c-old-controller-contract.json` | `d1d04b8bc00d16c191d18528bb516377b628a07571a22f2ea3e603855f4a2229` | 旧接口出生时间原始输入语义 |
| `02d-p0-dry.json` | `d4663eba392d0cc9e65b18799b6e1fcb1cf7e0fa12a2aefa15e8ae0a0c153afe` | 逐字段 dry-run，8 READY、1 SEMANTIC_UNKNOWN |
| `03-p0-apply.json` | `aea0432dcff86e92bdcb722196d08e4cd71ddae7e341366cd907739ca7fce362` | 单目标事务提交，8 个字段 |
| `03b-p0-verify.json` | `2f893e7f4b3cbc7bcc674518b077be497388e2f6870438f81e34eb0825410cc1` | 进程内授权 API 回读及保护列对比 |
| `03c-p0-restart-verify.json` | `60855c230a7367e993f79c9b442fe620bfd6ab423faf56d4e322a2613a1c19f2` | 容器重启后 API 回读、保护列对比及服务健康 |
| `03d-p0-types.json` | `61941f40267312b332b4778237ddc6195a30dbf4abaaed06dea605d05c6e640a` | 保留线格式复核首次只读 STOP |
| `03e-p0-types-readback.json` | `d0f2b5cfc2cc64d88887c972700d83be63c81dab893a675898f7e0c07546b564` | 云端 API 字段 wire types，坐标为 JSON 字符串 |
| `04b-profile-shape-red.log` | `94b3e2cbd8c2a70130541dd050d9c054841364e311fb5ea8c3448a082a1bca17` | 合成同形资料复现两项旧强转 FAIL |
| `04c-profile-and-transport-green.log` | `33c7bc9733169e56d3bb29cde62f44c560eaa3b1a45a42d45a101ed4fb8a8163` | 扩围 43 PASS、6 FAIL |
| `04e-profile-baseline.log` | `f1c9824ee31fb8628a200a30a45cf67a13a5146e9942849b7fc8b232bdfbd4b5` | 独立旧基线复现同名 6 FAIL |
| `04f-named-profile-and-transport.log` | `e54acc0f87913a99f1eb3089eebdb5cae118f3993a489570bb53e6c637d8836b` | 资料 DTO、编辑和端点定向 27 PASS |

APP 页面 NOT_RUN。既有 1011808 登录证据索引见管理员恢复与账号盘点报告。 [既有实体手机回执](V2_ADMIN_TEST_01_RESTORE_AND_ADMIN_ACCOUNT_INVENTORY_REPORT_20261122.md)
