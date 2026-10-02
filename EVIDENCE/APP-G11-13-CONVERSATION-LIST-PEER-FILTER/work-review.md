# APP-G11-13 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受人工控制器列表的正 peer 与 `canRead` 双重过滤。** Work 核对 controller SHA-256 `8E051D29E99C8BBC7D2ED13463E614944CCFD4860198DB14B6A5158BFA9F40BC`、新 Unit SHA-256 `A3356D6FACA07D19B1434E2E0A2AB7D6838B21E3A790B5366A1C81868A871739` 与作者摘要一致。差异只在 `index` 拒绝缺失、非正或非整数 peer，且保留通过 `canRead` 的项附加 capability；没有从旧 `id` 补造 peer。人工 Unit 覆盖无效/被拒/有效 stored 和 eligible、`items` 与 `total`。

作者新测试首跑退出 0，2 tests、19 assertions，另有 PHP 8.5 弃用提示；两文件语法检查、已跟踪差异空白检查及新文件行尾空白检查退出 0。Work 未复跑。直接控制器调用没有请求 live 路由或真实 DB；`DenyUnverifiedMessagingLiveAccess` 仍先行 404。本结论不证明真实 consent/read/send、actor/audience 或账号兼容。

G-11 其它债、G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填不变。旧预算不重置，本地 main HEAD 未动，无提交、pull、push。
