# APP-HM-09｜Synthetic Match 加载与读取失败经 Home provider 到页面的回归

状态：`ISSUED`；风险 `LEVEL 2`（Home 展示/导航边界，test-only）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 目标与精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`，以及本地 workflow/runtime 技能、APP-HM-03 和 APP-HM-08 的 `work-review.md`。既有工作区保留。APP-HM-03 只证明 provider 层的 Match `AsyncLoading`/`AsyncError` 未知回退，APP-HM-08 只证明 `failed`/`closed` 经过真实 provider 到页面；本任务补两种异步状态的页面接线证据。

只允许修改 `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`，输入 SHA-256 `A68DF195F0212A95D748891532911E0B5F358B2FE7114CBF3BC17406D365F3B7`；另新增本目录 `summary.md`。不得修改任何产品代码、provider、路由源文件或其他测试。

在同一 widget 测试文件中用显式 dev synthetic Home、ready navigation 与人工 Match future，分别使 `matchRoundProjectionProvider` 保持加载及抛出人工异常。两条用例必须经实际 `calmHomeProjectionProvider` 到 `HomePage`，不得直接 override 它。核对页面的 Match `UNKNOWN`、主按钮“查看进展”、不存在“当前没有可用的匹配提案”；点击唯一主按钮后到已有测试 Progress 路由。失败 future 要有受控的异常消费；加载 future 要在测试结束时安全完成或清理，避免遗留异步错误。保留现有九条用例。

## 新一次性验证预算和停点

编辑前只读核对输入哈希、`.dart_tool/package_config.json`、`dart`/`flutter` 可用性；不运行 `pub get` 或下载。编辑后运行 `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` 首跑一次；仅本任务测试夹具或断言缺陷可修后额外复跑同一文件一次。所有必要编辑完成后，对唯一测试文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`。格式写入若未改语义，无需额外测试。对目标文件运行 `git diff --check`。不得扩成完整测试、设备、网络或后端验证。

`summary.md` 记录输入/最终哈希、两种异步用例结果、目标文件测试数/退出码、格式/空白检查、预算消耗和未证明的真实来源。回退仅撤销本任务在目标测试文件的新增差异及摘要，不碰 APP-HM-01～08 和无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。旧预算不重置。真实 APP-T12 G-08、AUTH-170、AUTH-155 Phase B、CMS 认证/隔离恢复及账号回填状态不因本任务改变。
