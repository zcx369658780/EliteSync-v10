# BE-15 作者交付｜2026-09-27

**本地后端候选已交，待 Work 独立 LEVEL 3 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；本任务仅修改指定投影服务和两份 Feature 测试。BE-12 路由及保护测试未改。

## 固定输入与候选哈希

| 文件（`services/backend-laravel/` 下） | 修改前 SHA-256 | 候选 SHA-256 |
| --- | --- | --- |
| `app/Services/MatchRoundProjectionService.php` | `1828A95DC0E5CC2E57D0DB5996D4D75B692DC455D82DACE77C81C61561B76C48` | `AF4C6A35FBA03D071D82270E3D5854806209BFF33AECEFA13E09571D39734F06` |
| `tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php` | `EC9CACAE888CC7FE0B821B64FC9E4FECC1201E5ABE4AB5E2B7563D3F20BAFE0C` | `F422FE7D6FC381D99E036096F27B005A1D180F87B758996D900853C67B619ABE` |
| `tests/Feature/C2LocalRuntimeIntegrationTest.php` | `657FA60F017362A45A64E0707DB48D15CBACE0840EF8178F8AC1311CD5532E17` | `8C1F2F558498C834C6A00658B49B82C55A09ADFEAF028360B0507219E0CB9D6E` |

固定保护输入保持：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`；未旁路的 `tests/Feature/MessagingLiveGateFailClosedRouteTest.php` SHA-256 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。

## 差异与权限边界

- `MatchRoundProjectionService` 不再为 revealed 匹配调用旧 `ConversationCapabilityService::evaluate`；保留已揭晓的 match ID、伙伴身份、昵称、标题及其他既有匹配投影字段，`conversation_capability` 返回已有 nullable 合同的 `null`。revealed 和 closed 的 `user_action` 均为现有安全动作 `refresh`，不宣称可打开、查看或发送私密消息。未揭晓、失败和无候选状态的动作规则不变。
- `MatchingTruthSliceIntegratedSmokeTest` 核对 revealed 匹配结果仍在、能力为 `null` 且动作是 `refresh`；保留真实会话路由统一 opaque 404 和零会话/消息写入断言。`C2LocalRuntimeIntegrationTest` 核对 revealed 和 closed 的安全投影，同时保留原有匹配结果与其他状态断言。
- 旧 match 能力服务仍可供历史内部代码使用，本候选不修改其语义。`refresh` 只是投影动作，不授予 Conversation 权限；在线 live read/send 仍缺独立可信的当前 `CN_ACTIVE` 与 `MC_ACTIVE` 来源。BE-12 的七条私密入口仍在 controller 前默认拒绝。

**待 Work 审查的残留声明**：`next_action_code` 仍按任务单“保留其他 match 字段”的范围透传持久化值；现有 revealed synthetic 场景可给出 `open_conversation`。本候选只消除了任务单点名的 `conversation_capability` 和 `user_action` 声明，不能声称整个投影已无消息动作暗示。若该字段也需 fail closed，须由 Work 明确其范围和验证预算；本任务未自行改动或重跑。

## 有界验证

预检 `bootstrap/cache/config.php` 不存在；`phpunit.xml` 为 SQLite `:memory:`；`config/database.php` 由 `APP_DB_CONNECTION` 优先选择连接，SQLite `DB_URL` 可覆盖地址。三份修改 PHP 各执行一次 `php -l`，均退出 0。四份 PHPUnit 分别在独立子进程显式设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）。

| 定向 Feature 文件 | 首跑退出码 | Tests | Assertions | Deprecations | 复跑 |
| --- | ---: | ---: | ---: | ---: | ---: |
| `MatchingTruthSliceIntegratedSmokeTest.php` | 0 | 1 | 31 | 2 | 0 |
| `C2LocalRuntimeIntegrationTest.php` | 0 | 6 | 79 | 2 | 0 |
| `MatchRoundApiFoundationTest.php`（未修改） | 0 | 7 | 83 | 2 | 0 |
| `MessagingLiveGateFailClosedRouteTest.php`（未修改） | 0 | 2 | 24 | 2 | 0 |

合计首跑 **16 tests / 217 assertions**，无失败、错误或复跑。`git diff --check` 仅针对三份允许文件执行，退出 0。完整套件、真实读发、生产 DB/API、SSH、备份、部署均 `NOT_RUN`。

回退仅撤销三文件本次差异及本摘要，保留 BE-12/14 和其他工作区内容。未提交、拉取或推送 Git；停 Work 独立 LEVEL 3 审查，不自接受或启动后继。
