# APP-HM-09 Codex 候选摘要｜2026-09-29

状态：候选完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。

唯一修改 `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`。输入 SHA-256 `A68DF195F0212A95D748891532911E0B5F358B2FE7114CBF3BC17406D365F3B7`；最终 SHA-256 `C2E63C6E5CFD0430FBCCE3BA4307A2845DB66E393FA532DF18D905652D398A4C`。执行前只读确认输入哈希匹配、`.dart_tool/package_config.json` 存在，`dart`/`flutter` 本地命令可用；未运行 `pub get`。

原九条页面用例保留。测试夹具仅覆盖显式 dev synthetic 环境、ready navigation 与人工 Match future；加载中、人工读取异常各新增一条 widget 用例，均让实际 `calmHomeProjectionProvider` 计算后进入 `HomePage`，没有直接覆盖它。两条用例均见页面 Match `UNKNOWN`、主按钮“查看进展”，不见“当前没有可用的匹配提案”；点击唯一主按钮进入已有 `PROGRESS ROUTE`。加载 future 在测试结束前完成并被等待；失败 future 的人工异常由 `expectLater(..., throwsStateError)` 显式消费。

| 验证 | 本任务预算消耗 | 回执 |
| --- | --- | --- |
| `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0；11/11 tests passed（原九例加新增两例） |
| `dart format` 目标文件 | 写入 1/1，测试后执行 | 退出 0；仅排版，无语义修改 |
| `dart format --output=none --set-exit-if-changed` | 只读复核 1/1，最终格式写入后执行 | 退出 0；0 changed |
| `git diff --check --` 目标文件 | 1 次 | 退出 0；仅 Git LF/CRLF 提示，无空白错误 |

未运行完整套件、设备/模拟器、网络、后端或真实数据检查。此结果只证明本地虚构 Match 加载/读取失败经 synthetic provider 到 HomePage 的展示与测试路由，不建立 APP-T12 G-08 真实活态来源、真实 Home/Match/CN/MC 权威、设备运行或生产行为；AUTH-170、AUTH-155 Phase B、真实恢复与账号回填门不变。回退只撤销 APP-HM-09 在目标测试文件上的新增差异及本摘要，保留 APP-HM-01～08 与无关工作区；旧预算不重置。
