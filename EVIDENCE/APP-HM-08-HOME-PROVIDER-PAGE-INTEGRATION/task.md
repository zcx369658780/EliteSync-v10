# APP-HM-08｜Synthetic Match 不确定状态经 Home provider 到页面的回归

状态：`ISSUED`；风险 `LEVEL 2`（Home 展示/导航边界，test-only）；派发新 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 目标与唯一允许路径

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能及 APP-HM-06/07 的 `work-review.md`。APP-HM-06 证明 synthetic provider 对 `failed`/`closed` 的 unknown 映射；APP-HM-07 只证明页面消费手工注入的投影。本任务验证**实际 provider → HomePage** 的本地人工链，不建立真实 Home/Match 来源。

只允许修改 `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`，输入 SHA-256 `3709AC2EE75CBC6A4D1273E7540985695739AAE86BEA08A15F87A6244FC9AF47`；另新增本目录 `summary.md`。不修改 Home provider、页面产品代码、Match adapter、路由源文件或其他测试。

在同一测试文件构造显式 dev synthetic Home、ready navigation 和虚构 `MatchRoundProjection`，分别以 `MatchRoundBusinessState.failed` 与 `closed` 让真实 `calmHomeProjectionProvider` 参与 `HomePage` widget 树；不得以 `calmHomeProjectionProvider.overrideWithValue` 替代这两条集成用例。每条核对页面可见 `UNKNOWN`、“查看进展”、没有“当前没有可用的匹配提案”，点击唯一主按钮进入已有测试 Progress 路由。现有七条页面用例及默认静态投影夹具保持；不引入网络、真实账号或任何 writer。

## 新一次性验证预算

执行前只读核对输入哈希、`.dart_tool/package_config.json` 与 `dart`/`flutter` 可用；不运行 `pub get` 或下载。编辑后运行 `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` 首跑一次；仅本任务测试夹具/断言缺陷可修后额外复跑该文件一次。所有必要编辑完成后，对唯一测试文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；若格式写入未改语义，无需额外测试。对目标文件运行 `git diff --check`。不跑完整套件、设备/模拟器、网络、后端或真实数据。

`summary.md` 记录输入/最终哈希、实际 widget 用例数/退出码、两种状态文案和路由、最终格式复核时点与空白检查、未证实权威及回退范围。回退只撤销本任务测试文件新增差异及摘要，保留 APP-HM-01～07 和无关状态。不得访问旧 `D:\EliteSync`、SSH、云/生产 API、真实 DB/备份/密钥；不得提交、pull、push、自验收或启动后继。旧预算不重置。
