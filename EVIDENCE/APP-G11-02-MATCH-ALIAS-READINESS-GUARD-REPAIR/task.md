# APP-G11-02｜历史 Match 别名的 readiness guard 修复

状态：`ISSUED`；风险 `LEVEL 2`（兼容路由与准备状态守卫）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确范围与目标

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根规则五文档、本地 workflow/runtime 技能、APP-G11-01 的 `task.md`、`summary.md`、`work-review.md`。APP-G11-01 的失败测试是保留候选，旧预算不重置。只允许修改 `apps/flutter_elitesync_module/lib/app/router/app_router.dart`（输入 SHA-256 `B74A099A2E056ACA938BFD706807281885DED2A7293D1A4C3C98D804203DB9EB`）和 `apps/flutter_elitesync_module/test/app/router/match_legacy_redirect_regression_test.dart`（输入 SHA-256 `67C26750AB91C0CF33E5F7021E611B735E4139A61B8EBC19F6A863938494E37F`），另新增本目录 `summary.md`。不改 route names、Match 页面/provider、readiness provider、其他测试或权限代码。

目标：已认证但 readiness 未建立时，`/progress/match` 与六个现存历史 Match 别名均由本地 router 安全导向 `/me/readiness`；人工 ready 时六别名仍到 `/progress/match` 且渲染统一 Match portal。路由守卫只作导航，不写 readiness、Match、Connection 或 Conversation 状态，不把别名当授权。优先在现有全局 guard 上对六个别名作显式精确路径判断，保持现有 route-level 重定向；不要用宽泛 `/match*` 前缀或引入新产品策略。测试保留 APP-G11-01 的失败负例并覆盖其余别名的 unknown readiness；若因夹具导致误判，仅修本文件夹具并据实报告。

## 新一次性验证预算和停点

执行前只读核对两份输入哈希、`.dart_tool/package_config.json` 与 `dart`/`flutter` 可用。编辑后仅运行 `flutter test --no-pub test/app/router/match_legacy_redirect_regression_test.dart` 首跑一次；若失败可在本任务两文件范围内修正一次并复跑该目标文件一次，之后停止，不扩大测试。所有必要编辑后两目标文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；格式若仅排版无需复测。对已跟踪 router 运行 `git diff --check`，对未跟踪测试文件另做行尾空白检查。

`summary.md` 记录两文件输入/最终 SHA-256、首跑/复跑实际结果与预算、ready/unknown 的精确路由、格式/空白检查、回退范围和保留 G-11 债务。若无法在预算内使守卫与测试一致，保留失败和精确停点，不宣称通过。回退仅撤销本任务 router 改动和测试新增改动，保留 APP-G11-01 原失败证据及其它工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。真实 Home G-08、AUTH-170、AUTH-155 Phase B 与恢复/账号门不变。
