# APP-HM-08 Codex 候选摘要｜2026-09-29

状态：候选完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。

唯一修改 `apps/flutter_elitesync_module/test/features/home/presentation/pages/home_page_test.dart`。输入 SHA-256 `3709AC2EE75CBC6A4D1273E7540985695739AAE86BEA08A15F87A6244FC9AF47`；最终 SHA-256 `A68DF195F0212A95D748891532911E0B5F358B2FE7114CBF3BC17406D365F3B7`。执行前确认输入哈希匹配、`.dart_tool/package_config.json` 存在，`dart`/`flutter` 本地命令可用；未运行 `pub get`。

原有七条页面用例及默认静态投影夹具保留。另以显式 dev synthetic Home 环境、ready navigation 和本地虚构 `MatchRoundProjection` 的 `failed`、`closed` 各新增一条 widget 用例。这两条只覆盖环境、navigation 与 Match 输入，**没有覆盖 `calmHomeProjectionProvider`**；由真实 synthetic Home provider 计算投影并交给 `HomePage`。两种状态的页面均显示 `UNKNOWN`、“查看进展”，不显示“当前没有可用的匹配提案”；唯一 `FilledButton` 主按钮进入已有 `PROGRESS ROUTE`，未进入 Readiness 或 Privacy 测试路由。

| 验证 | 本任务预算消耗 | 回执 |
| --- | --- | --- |
| `flutter test --no-pub test/features/home/presentation/pages/home_page_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0；9/9 tests passed（原七例加新增两例） |
| `dart format` 目标文件 | 写入 1/1，测试后执行 | 退出 0；仅排版，无语义修改 |
| `dart format --output=none --set-exit-if-changed` | 只读复核 1/1，最终格式写入后执行 | 退出 0；0 changed |
| `git diff --check --` 目标文件 | 1 次 | 退出 0；仅 Git LF/CRLF 提示，无空白错误 |

未运行完整套件、设备/模拟器、网络、后端或真实数据检查。此结果仅证明本地虚构 Match 状态经 synthetic provider 到 HomePage 的展示和测试路由，不建立 APP-T12 G-08 真实 Home/Match 来源、真实 CN/MC 权威、设备构建或生产行为。回退只撤销 APP-HM-08 在该测试文件上的新增差异及本摘要，保留 APP-HM-01～07 和全部无关工作区内容；旧预算不重置。
