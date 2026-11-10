# BE-15｜匹配轮次投影撤销未经证实的消息能力声明

状态：`ISSUED`；风险 LEVEL 3；派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`。唯一主要结果是 `match-rounds/current` 后端投影及其定向测试的本地候选，交付后停 Work 独立 LEVEL 3 审查。

## 固定入口与范围

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`、dirty 工作区与当前任务；读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能、BE-12/14 的 `work-review.md` 与 BE-14 摘要、Owner-accepted Conversation live-gate 技术设计相关条款。只读 `routes/api.php`、`ConversationCapabilityService.php`、Flutter `match_round_projection.dart` 以确认旧来源与 nullable 客户端合同；不改这些文件。

仅允许修改以下三文件并新增本目录 `summary.md`：

- `services/backend-laravel/app/Services/MatchRoundProjectionService.php`，修改前 SHA-256 `1828A95DC0E5CC2E57D0DB5996D4D75B692DC455D82DACE77C81C61561B76C48`。
- `services/backend-laravel/tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php`，`EC9CACAE888CC7FE0B821B64FC9E4FECC1201E5ABE4AB5E2B7563D3F20BAFE0C`。
- `services/backend-laravel/tests/Feature/C2LocalRuntimeIntegrationTest.php`，`657FA60F017362A45A64E0707DB48D15CBACE0840EF8178F8AC1311CD5532E17`。

固定未改保护输入：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`，BE-12 `MessagingLiveGateFailClosedRouteTest.php` `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。任一固定哈希不符即停 Work 核对，不覆盖其他编辑。

## 候选行为

当前 `MatchRoundProjectionService` 在 revealed 时仍以旧 match 能力产生 `conversation_capability.can_create/can_send`，并据此给 `user_action=open_messages`；closed 状态还无条件给 `view_messages`。BE-12 真实消息/会话入口均 fail closed，且产品决定 `Match != Connection != Conversation`，故此投影不能宣称尚未建立的 live 权限。保留已核验的 revealed `result`、伙伴身份、状态、时间及其他 match 字段；将消息能力投影维持已有 nullable 合同（`conversation_capability=null`），revealed 和 closed 的 `user_action` 改为不宣称私密消息可用的现有安全动作 `refresh`。不把 `refresh` 写成授权，也不新增权限来源或自行创造 `CN_ACTIVE/MC_ACTIVE`。未揭晓/失败/no-candidate 等既有路径不改变。

更新两个指定 Feature 测试：revealed 仍核对匹配结果，但消息能力为 null、动作安全；closed 同样核对安全动作，必要时在 C2 场景断言。保留 MatchingTruth 中对真实会话路由 opaque 404 与零写入的断言；BE-12 保护测试仍不绕过 guard。不得改 `ConversationCapabilityService` 的历史内部用途、Flutter、路由、guard、消息 controller/writer、DB schema/数据或其他测试。

## 验证预算与停点

预检 `bootstrap/cache/config.php` 不存在、PHPUnit SQLite `:memory:`、`APP_DB_CONNECTION` 优先级及 `DB_URL` 风险；不符即停。三份修改文件各一次 `php -l`。在独立 shell/子进程里显式设 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空），分别首跑四份 Feature：`MatchingTruthSliceIntegratedSmokeTest.php`、`C2LocalRuntimeIntegrationTest.php`、未修改的 `MatchRoundApiFoundationTest.php`、未修改的 `MessagingLiveGateFailClosedRouteTest.php`。仅可因本任务代码/断言缺陷修正后对失败文件复跑最多一次；环境/其他失败如实记录并停审。完整套件 `NOT_RUN`。对三份允许文件运行 `git diff --check`。

`summary.md` 记录前后哈希、精确差异、各定向测试实际退出码/tests/assertions/deprecations/复跑、旧投影与 BE-12 真实入口的界线、回退范围。回退仅撤销三文件本次差异及摘要。不访问旧 `D:\EliteSync`、SSH、云/生产 API、真实消息/数据库、备份/密钥/恢复；不提交、拉取或推送 Git。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
