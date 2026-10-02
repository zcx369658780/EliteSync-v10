# BE-16 作者交付｜2026-09-27

**本地后端候选已交，待 Work 独立 LEVEL 3 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；本任务仅修改指定的投影服务与两份 Feature 测试，不改变 BE-15 已接受的匹配结果、`conversation_capability=null` 或 revealed/closed `user_action=refresh`。

## 固定输入与候选哈希

| 文件（`services/backend-laravel/` 下） | BE-16 修改前 SHA-256 | 候选 SHA-256 |
| --- | --- | --- |
| `app/Services/MatchRoundProjectionService.php` | `AF4C6A35FBA03D071D82270E3D5854806209BFF33AECEFA13E09571D39734F06` | `00C1EBE0DD724AE678BE9E407B9EADE7AEBEF53891A5697B0BD45DFF2F9A828E` |
| `tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php` | `F422FE7D6FC381D99E036096F27B005A1D180F87B758996D900853C67B619ABE` | `FC6FC8E6D7D5698326DA3C1E54D92F92E6EB6343F2C340150108E346C0FC148A` |
| `tests/Feature/C2LocalRuntimeIntegrationTest.php` | `8C1F2F558498C834C6A00658B49B82C55A09ADFEAF028360B0507219E0CB9D6E` | `E0C97A1E33A03474C01237C5C095A30D4765277F9E9DC2A3F60616E76A4373FF` |

固定保护输入未变：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`；未旁路的 `tests/Feature/MessagingLiveGateFailClosedRouteTest.php` SHA-256 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。

## 公开投影与存储边界

`match-rounds/current` 的 `next_action_code` 只在公开状态为 revealed 或 closed 时返回 nullable 合同的 `null`；其他状态沿用原规则。没有修改 `DatingRoundUserState.next_action_code`、`conversation_eligible`、写入服务或数据库结构。Synthetic revealed 响应的 `next_action_code=null`，对应存储值仍是 `open_conversation`；synthetic closed 响应也为 `null`，对应存储值仍是 `return_home`。两份指定 Feature 测试核对这些区分；MatchingTruth 仍核对匹配结果、真实会话入口的统一 opaque 404 和零会话/消息写入。

该过滤只约束本公开投影；旧存储动作码不授予消息权限，也不能宣称已迁移或净化。BE-12 七条私密入口仍在 controller 前默认拒绝。其他可能读取旧 `next_action_code` 或 `conversation_eligible` 的公开出口未在本任务的定向范围内逐项审计，状态为 `NOT_CHECKED`；本候选不声明全系统消息能力已就绪。

## 有界验证

预检 `bootstrap/cache/config.php` 不存在；`phpunit.xml` 为 SQLite `:memory:`；`config/database.php` 由 `APP_DB_CONNECTION` 优先选择连接，SQLite `DB_URL` 可覆盖地址。三份修改 PHP 各一次 `php -l`，均退出 0。四份 PHPUnit 分别在独立子进程设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）。

| 定向 Feature 文件 | 首跑退出码 | Tests | Assertions | Deprecations | 复跑 |
| --- | ---: | ---: | ---: | ---: | ---: |
| `MatchingTruthSliceIntegratedSmokeTest.php` | 0 | 1 | 33 | 2 | 0 |
| `C2LocalRuntimeIntegrationTest.php` | 0 | 6 | 83 | 2 | 0 |
| `MatchRoundApiFoundationTest.php`（未修改） | 0 | 7 | 83 | 2 | 0 |
| `MessagingLiveGateFailClosedRouteTest.php`（未修改） | 0 | 2 | 24 | 2 | 0 |

合计首跑 **16 tests / 223 assertions**，无失败、错误或复跑。`git diff --check` 仅对三份允许文件执行，退出 0。完整套件、真实读发、生产 DB/API、SSH、备份、部署均 `NOT_RUN`。

回退仅撤销三文件的 BE-16 差异及本摘要，保留 BE-12/14/15 和其他工作区内容。未提交、拉取或推送 Git；停 Work 独立 LEVEL 3 审查，不自接受或启动后继。
