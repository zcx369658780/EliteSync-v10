# APP-G11-01｜历史 Match 路由进入统一入口的本地回归

状态：`ISSUED`；风险 `LEVEL 2`（兼容路由/导航边界，test-only）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 目标与精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能，`docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` 的 G-11、`app_router.dart`、`app_route_names.dart` 和现有 router 测试夹具。路由源文件当前 SHA-256 分别为 `B74A099A2E056ACA938BFD706807281885DED2A7293D1A4C3C98D804203DB9EB`、`FCABD90DE3634E1D72C9783C86A29104D428858F046C95C2D413F99F6F0395C5`；仅作为只读输入，不修改。

只允许新增 `apps/flutter_elitesync_module/test/app/router/match_legacy_redirect_regression_test.dart` 和本目录 `summary.md`。用本地 dev/mock、已完成 first-use 的人工夹具，核对 `AppRouteNames.match` 及 `matchCountdown`、`matchResult`、`matchDetail`、`matchIntention`、`matchFeedback` 六个历史入口在实际 app router 中收敛到 `AppRouteNames.progressMatch`；按现有 readiness guard，若人工 actor 未建立准备状态，允许进一步安全转向 readiness，但测试须明确区分别名重定向与 guard，不能把受 guard 拒绝误报为到达 Match。优先使用人工 ready navigation，检查最终 canonical 路由/可见 Match portal；不访问真实服务，不通过别名获取 Connection/Conversation 权限。若现有 router 夹具无法在不改其他文件或引入网络的情况下可靠验证，保留失败与精确停点，不扩大路径。

## 新一次性预算

编辑前只读核对上述源哈希、`.dart_tool/package_config.json`、`dart`/`flutter` 可用。新文件完成后只运行 `flutter test --no-pub test/app/router/match_legacy_redirect_regression_test.dart` 首跑一次；仅本任务夹具/断言缺陷可修后复跑同一文件一次。所有必要编辑后最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`，以及目标文件 `git diff --check`（新未跟踪文件须另做空白核对并说明方法）。不运行 `pub get`、完整套件、设备/模拟器、网络或后端命令。

`summary.md` 记录精确六入口结果、源/新文件哈希、测试数与退出码、格式/空白检查、预算消耗和保留的 G-11 兼容债。回退只撤销本任务新增测试及摘要，不碰 APP-HM-01～10 或无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。旧预算不重置，真实 Home G-08、账号/恢复门不变。
