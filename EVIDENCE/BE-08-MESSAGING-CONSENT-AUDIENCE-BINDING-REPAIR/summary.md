# BE-08 作者候选回执｜待 Work LEVEL 2 独立审查

本地 `D:\EliteSync-v10`、`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。保留 BE-07 被 REJECT 的未提交 adapter/test 为修复起点；本轮只修改任务允许的两份 PHP 与本回执，保留全部无关 modified/untracked，未提交或推送。

## 精确差异

- `MessagingConsentPersistenceApplicationAdapter.php` 的 synthetic 请求现在必须含非空字符串 `protected_audience`；CN 和 MC 两份 `required_bindings.audience` 各自与该值严格相等后才构造记录。目标缺失、错误类型、任一来源错配、两份来源互不相同均在提交前 fail closed。既有一次提交、精确读回、幂等、失效目标检查和权限字段恒 false 保持。
- `MessagingConsentPersistenceApplicationAdapterTest.php` 固定正例的 synthetic audience，新增上述六种负例；每例均断言关联不可用、SQLite 未写入且非权限字段为 false。

目标 audience 是调用方在本地 synthetic 请求中声明的绑定值，不证明来源签发者可信，不建立真实来源认证或 live-read/live-send 权限。

## 验证及预算

在 `services/backend-laravel` 对本轮修改的两份 PHP 各运行一次 `php -l`，均无语法错误。本轮**新** PHPUnit 预算中，新 adapter test 首跑 `5 tests/134 assertions PASS`；随后 `MessagingConsentPersistenceFamilyTest.php` 首跑 `8/103 PASS`，`PersistenceBoundaryApplicationInterfaceIntegrationContractTest.php` 首跑 `9/709 PASS`。合计三文件 `22 tests/946 assertions PASS`，未使用失败复跑预算。BE-07 的旧三文件 `21 tests/904 assertions PASS` 与其预算耗尽事实保留，不由 BE-08 重置或追认接受。

当前 SHA-256：adapter `573E1147BBEBF92E574F5C61667A003314C6C97EAA1B4E515F288A8F9922C506`；Unit test `D23938C52865E2D82FFBACBBE55658AAFA06A0BE385EB252672A28C1C277F17B`。

`NOT_RUN`：其他测试、Composer、Artisan、Docker、构建、Web/模拟器、SSH、真实 DB、备份/解密/恢复、UAC、Git commit/pull/push。未访问旧 `D:\EliteSync`、GitHub、`.env`、真实账号、私钥、业务行或日志。

## 边界和停点

`correlation_usable=true` 仅表示 synthetic 来源关联与精确读回一致；`source_authority`、`permission`、`live_read_allowed`、`live_send_allowed`、`message_sent` 恒为 false。真实 MC writer、transition 结果、使用点双输入 live gate、账号和生产 DB 仍 `NOT_READY`。如 Work 审查拒绝，回退为不接入此 adapter，保留 BE-05 已接受的 repository-only family。作者现在停在 Work LEVEL 2 独立审查，不自接受、不派发后继。
