# BE-14｜剩余旧 Feature 测试与消息 live gate 对齐

状态：`ISSUED`。风险 LEVEL 3。派发 Codex 会话 `01a0ddd0-bab2-7673-bf5b-03dbfbc066e4`；该会话当前 21 个实际 turn、idle，未达 30 条交接阈值。唯一主要结果是四份指定 Feature 文件的测试候选；交付后停 Work 独立 LEVEL 3 审查。

## 固定入口与允许范围

先核对 `D:\EliteSync-v10` 本地 `main`、HEAD、dirty 工作区及 `TASK_CURRENT.md`，读取根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能、BE-12/13 `work-review.md` 与 `summary.md`，再读取下列四文件、`routes/api.php`、`DenyUnverifiedMessagingLiveAccess.php`、BE-12 新保护测试、`phpunit.xml` 和 `config/database.php`。HEAD 预期 `cf8bfaa4a03b8c9a682105617b185141904413be`；不符即停 Work 核对，不自行改基线。

仅允许修改：

- `services/backend-laravel/tests/Feature/DomainSkeletonApiTest.php`（修改前 SHA-256 `2B8002BBE185B23E33E7562A092E08D6776A2D9063C4082A93B7B173AF823CBC`）
- `services/backend-laravel/tests/Feature/NotificationApiTest.php`（`67119E72423765DE0B5A8B287D6BA2CDDFD939F13E4FF8C38DDC2F3E14E44F98`）
- `services/backend-laravel/tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php`（`95A1E035D7DA20781AB0568A686BD57F6B7CE98FFBB71E4E72AF9365E365E806`）
- `services/backend-laravel/tests/Feature/ModerationApiTest.php`（`F671D2DBDF5E6A536E02D7D20A93EB7ABEE7DE031EC1FE439AF53CE4BF1DEB73`）
- 新增本目录 `summary.md`。

保护输入固定：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`；BE-12 新保护测试 `MessagingLiveGateFailClosedRouteTest.php` SHA-256 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。任何固定哈希不符即停，不覆盖他人变化。

## 候选行为

`DomainSkeletonApiTest` 的单个历史 skeleton 用例及 `NotificationApiTest` 的单个旧消息通知重放用例可在**各自用例内**仅对 `DenyUnverifiedMessagingLiveAccess::class` 调用 `withoutMiddleware`，保留原有旧内部断言；其他通知用例不得被扩大旁路。明确注释历史 controller/service/storage 回归不代表 v10 live 权限。不得无参数全局关闭 middleware、关闭 `auth:sanctum`、跳过测试或改旧正例以遮盖失败。

`MatchingTruthSliceIntegratedSmokeTest` **不得绕过 guard**：保持 `match-rounds/current` 的既有投影断言，但将 no-round、revealed 后的会话列表/创建，以及 outsider peer 入口均核对为真实路由的统一 opaque 404 `conversation unavailable`；补充必要的无会话/消息写入断言。即便投影仍显示旧 `conversation_capability.can_create`，也不得把它解释为 live 许可；若此投影语义需要产品改变，只记录缺口，不能在本任务改生产代码。`ModerationApiTest` 保持 block 流程及发送 404，旧 `chat unavailable` 响应文本改为新 guard 的 `conversation unavailable`，并核对未写入消息；不因 block 用例通过而宣称验证了内部 block gate。

不得改生产路由、guard、服务、模型、迁移，不能使真实读发成功。BE-12 新保护测试必须保持未旁路状态并继续验证真实入口。

## 有界验证与停点

预检 `bootstrap/cache/config.php` 不存在、PHPUnit SQLite `:memory:`、`APP_DB_CONNECTION` 优先级及 SQLite `DB_URL` 风险；不符即停。四份修改文件各一次 `php -l`。四份修改 Feature 文件加 BE-12 新保护测试**各首跑一次**，分别在单个 shell/子进程内显式设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）。仅当失败可明确归因于本任务的测试编辑时，可修正后对该失败文件最多复跑一次；其他失败如实记录并停审，不扩大到生产代码。完整套件 `NOT_RUN`。运行 `git diff --check` 仅对允许的四份测试。

`summary.md` 记录固定输入与修改后哈希、逐文件 tests/assertions/退出码、弃用提示、任何失败/复跑、guard 是否仍作用于真实入口及历史测试隔离边界。回退只撤销四份测试的本次改动和摘要，保留 BE-12/13。不得访问旧 `D:\EliteSync`、SSH/云/生产 API、真实消息/数据库、备份/密钥/恢复；不得提交、拉取或推送 Git。作者停 Work LEVEL 3 ACCEPT/REJECT，不自接受或启动后继。
