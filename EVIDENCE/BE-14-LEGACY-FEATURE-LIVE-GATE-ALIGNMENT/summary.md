# BE-14 作者交付｜2026-09-27

**候选已完成，待 Work 独立 LEVEL 3 ACCEPT/REJECT。** 本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；仅修改任务单允许的四份 Feature 测试。本任务未修改生产路由、middleware、服务、模型或迁移。

## 固定输入与候选哈希

| 文件（`services/backend-laravel/` 下） | 修改前 SHA-256 | 候选 SHA-256 |
| --- | --- | --- |
| `tests/Feature/DomainSkeletonApiTest.php` | `2B8002BBE185B23E33E7562A092E08D6776A2D9063C4082A93B7B173AF823CBC` | `545744E7338BDFC5D5A7C4751D37A34F43E11349E7168F78B7BB689A43B942EF` |
| `tests/Feature/NotificationApiTest.php` | `67119E72423765DE0B5A8B287D6BA2CDDFD939F13E4FF8C38DDC2F3E14E44F98` | `F86E19B7B5C6212FBEC14AA1A45480CAA67211869621C3B885E04052334C96CE` |
| `tests/Feature/MatchingTruthSliceIntegratedSmokeTest.php` | `95A1E035D7DA20781AB0568A686BD57F6B7CE98FFBB71E4E72AF9365E365E806` | `EC9CACAE888CC7FE0B821B64FC9E4FECC1201E5ABE4AB5E2B7563D3F20BAFE0C` |
| `tests/Feature/ModerationApiTest.php` | `F671D2DBDF5E6A536E02D7D20A93EB7ABEE7DE031EC1FE439AF53CE4BF1DEB73` | `63B8F61A6CB224DF1C7258B45E3D6CAA74C93250A4458752A2FF4E757A5F9817` |

保护输入保持固定：`routes/api.php` SHA-256 `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675`；未旁路的 `tests/Feature/MessagingLiveGateFailClosedRouteTest.php` SHA-256 `43CEA0249D53A525A9B0A0DC5A0C49558EF3A538F12DE8B72C66B73CE00728A8`。

## 候选边界

- `DomainSkeletonApiTest` 的单个历史 skeleton 用例、`NotificationApiTest` 的单个旧消息通知重放用例，只在各自用例内按 `DenyUnverifiedMessagingLiveAccess::class` 隔离 middleware；原有旧内部行为断言保留，其他通知用例没有旁路。这些测试不证明 v10 live 权限。
- `MatchingTruthSliceIntegratedSmokeTest` 没有旁路 guard，保留 match 投影断言；no-round、revealed 后的会话列表与创建、outsider peer 入口均核对统一 opaque `404 {"message":"conversation unavailable"}`，并核对没有会话/消息写入。旧投影的 `conversation_capability.can_create` 不被解释为 live 许可；投影语义是否需要产品调整仍是后续议题。
- `ModerationApiTest` 保留 block 流程，发送改为核对统一 opaque 404 与零消息写入。由于路由 guard 在旧内部 block gate 前拒绝，该用例不证明内部 block gate 已执行。

## 有界验证

预检 `bootstrap/cache/config.php` 不存在；`phpunit.xml` 使用 SQLite `:memory:`，`config/database.php` 优先读取 `APP_DB_CONNECTION` 且 SQLite 可读取 `DB_URL`。五份 PHPUnit 均在各自独立进程显式设置 `APP_DB_CONNECTION=sqlite`、`DB_CONNECTION=sqlite`、`DB_DATABASE=:memory:`、`DB_URL=`（空）。四份修改测试分别 `php -l` 一次，均退出 0。

| 定向文件 | 首跑退出码 | Tests | Assertions | Deprecations | 复跑 |
| --- | ---: | ---: | ---: | ---: | --- |
| `DomainSkeletonApiTest.php` | 0 | 1 | 40 | 2 | 0 |
| `NotificationApiTest.php` | 0 | 3 | 24 | 2 | 0 |
| `MatchingTruthSliceIntegratedSmokeTest.php` | 0 | 1 | 30 | 2 | 0 |
| `ModerationApiTest.php` | 0 | 3 | 18 | 2 | 0 |
| `MessagingLiveGateFailClosedRouteTest.php`（未修改） | 0 | 2 | 24 | 2 | 0 |

合计首跑 10 tests / 136 assertions；没有失败、错误或复跑。`git diff --check` 仅针对四份允许测试检查，退出 0。完整套件 `NOT_RUN`；真实读发、生产 DB/API、SSH、备份、部署均 `NOT_RUN`。BE-12 保护测试仍独立核对真实七条私密路由的默认拒绝，不能由历史用例的局部隔离推断真实入口放行。

回退范围仅为四份测试的本次差异和本摘要，保留 BE-12/13 已接受候选及其他工作区内容。未提交、拉取或推送 Git；停 Work 独立 LEVEL 3 审查，不自接受或启动后继。
