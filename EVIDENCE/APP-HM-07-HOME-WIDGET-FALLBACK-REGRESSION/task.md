# APP-HM-07｜Home 页面安全回退的 widget 回归

状态：`ISSUED`；风险 `LEVEL 2`（Home 展示/导航权威边界，test-only）；派发新 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 目标与固定边界

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 modified/untracked 保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能，及 APP-HM-05/06 的 `work-review.md`。APP-HM-06 已通过 provider 定向测试 11/11；本任务仅在已有 Home 页面 widget 测试里验证用户实际看到的安全回退，不再修改 provider 或产品代码。

只允许修改 `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`，输入 SHA-256 `71A9206A6B0E3AD23A336D5F392987D92BFC445F2DCE09B9B05335B414BFEC3E`；另新增本目录 `summary.md`。允许在同一测试文件为现有 HomePage 测试补必要的 `ProviderScope` 包装/override 夹具，不改路由、主题或应用源码。

新增一条 widget 回归，用本地虚构 `CalmHomeProjection` 的 Match unknown、无 `authoritativeNextDecision` 作为输入，核对页面渲染“查看进展”、不出现“当前没有可用的匹配提案”，点击唯一主按钮仅导航至现有 Progress 测试路由。保留原有三块布局、隐私次级按钮、默认非演示内容与对比度/手机宽度测试。不要把测试夹具标成真实 Home/Match 权威，也不要从此测试宣称真实应用连接、设备构建或 G-08 已关闭。

## 新一次性验证预算与停点

执行前只读核对输入哈希、`.dart_tool/package_config.json` 及本机 `dart`/`flutter` 可用性；不运行 `pub get` 或下载。目标文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；执行 `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` 首跑一次。仅可归因于本任务测试夹具/断言编辑缺陷的失败可修后额外复跑该文件一次；其它失败记录并停审。对目标文件运行 `git diff --check`。不跑完整套件、设备/模拟器、网络、后端或真实数据。

`summary.md` 记录前后哈希、实际 widget 用例数/退出码、格式与空白检查、所见文案/路由、未证实的真实权威及回退范围。回退仅撤销本任务测试文件新增差异及摘要，保留 APP-HM-01～06 与无关状态。不得访问旧 `D:\EliteSync`、SSH、云/生产 API、真实 DB/备份/密钥；不得提交、pull、push、自验收或启动后继。旧预算不重置。
