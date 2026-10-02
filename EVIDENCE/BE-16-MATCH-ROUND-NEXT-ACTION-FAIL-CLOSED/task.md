# BE-16｜匹配投影旧消息动作码的公开边界

状态：`ISSUED`；风险 LEVEL 3；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果是 `match-rounds/current` 公开 `next_action_code` 的有界修正及定向回归；交付后停 Work LEVEL 3 独立审查。

## 固定入口与允许路径

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区和当前任务。读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能、BE-12/14/15 的审查与 BE-15 摘要；只读 `DatingRoundUserState.php`、`MatchingRoundService.php`、`C2LocalMatchScenarioService.php`、Flutter `match_round_projection.dart`、路由和 BE-12 保护测试。不得把存储中的旧 `open_conversation` 当消息权限，也不改存储语义。

仅允许修改下列三文件，另新增本目录 `summary.md`：

- `services/backend-laravel/app/Services/MatchRoundProjectionService.php`，修改前 SHA-256 `AF4C6A35FBA03D071D82270E3D5854806209BFF33AECEFA13E09571D39734F06`。
- `services/backend-laravel/tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php`，`F422FE7D6FC381D99E036096F27B005A1D180F87B758996D900853C67B619ABE`。
- `services/backend-laravel/tests/Feature/C2LocalRuntimeIntegrationTest.php`，`8C1F2F558498C834C6A00658B49B82C55A09ADFEAF028360B0507219E0CB9D6E`。

固定未改保护输入：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`，BE-12 `MessagingLiveGateFailClosedRouteTest.php` `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。任一固定哈希不符即停 Work 核对。

## 候选行为

当前 revealed/closed 公开投影不可用作会话授权，故 `next_action_code` 对这两个状态返回现有 nullable 合同的 `null`，不透传持久化的 `open_conversation` 或其他消息动作码；保持 BE-15 的 `conversation_capability=null`、`user_action=refresh`、匹配结果、状态和时间字段。其他状态的 `next_action_code` 规则不变。仅修改**公开投影**，不得编辑 `DatingRoundUserState.next_action_code` 或 `conversation_eligible`，不得声称数据库旧字段已迁移/净化。若发现其他公开出口仍读取旧字段，记录到摘要供 Work 后继处理，不自行扩范围。

在两个指定 Feature 文件用 synthetic revealed/closed 场景核对公开 `next_action_code=null`；至少一处核对存储中的原有旧值仍在，以证明只是投影过滤。保留真实会话路由统一 opaque 404 与零写入断言、匹配结果断言、BE-12 未旁路保护测试。不得改客户端、路由、guard、消息服务或 DB schema。

## 验证预算与停点

预检 `bootstrap/cache/config.php` 不存在、PHPUnit SQLite `:memory:`、`APP_DB_CONNECTION` 优先级与 `DB_URL` 覆盖风险；不符即停。三份修改文件各一次 `php -l`。在独立子进程里显式设 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），分别首跑四份 Feature：`MatchingTruthSliceIntegratedSmokeTest.php`、`C2LocalRuntimeIntegrationTest.php`、未修改的 `MatchRoundApiFoundationTest.php`、未修改的 `MessagingLiveGateFailClosedRouteTest.php`。仅对可归因于本任务编辑缺陷的失败文件允许修正后最多复跑一次；其他失败如实记录并停审。完整套件 `NOT_RUN`。对三份允许文件运行 `git diff --check`。

`summary.md` 记录前后哈希、公开值和存储值区分、各文件实际 tests/assertions/退出码/deprecations/复跑、未覆盖的其他出口、回退范围。回退仅撤销三文件本次差异与摘要，保留 BE-12/14/15。不得访问旧 `D:\EliteSync`、SSH、云/生产 API、真实消息/数据库、备份/密钥/恢复；不提交、拉取或推送 Git。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
