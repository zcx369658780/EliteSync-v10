# APP-HM-06 Codex 候选摘要｜2026-09-29

状态：候选完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 modified/untracked 保留。

在显式 dev synthetic Home 分支，已返回的 Match `failed` 经既有 adapter 得到 `transportUnavailable`，`closed` 得到 `closedWithoutCompletionEvidence`。Home 对这两类不确定 condition 输出 Match summary `authority=unknown`、`stateCode=null`，不发布 synthetic `authoritativeNextDecision`，沿用“查看进展”安全回退，不再声称“当前没有可用的匹配提案”。已明确分类的 `noCandidate` 仍保留 synthetic Match 摘要和“查看匹配”导航；原八条测试及 revealed/active 主循环保留。没有编辑 adapter、产品状态词、后端、路由或 writer。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `ACCB6E0BD61CCAEF00FEB33C8CEF6E1E23EF19999DDF347695A843B487A7BBD4` | `7D2ADCACF09866B6130EAB543DBC82611D2B752841BB1CB0BC0EA12D55D4042B` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `12B6810CD661AA1ED1D38601332CD17D30C0F27FB04270948C14430591F5E593` | `1CAAA927E3A7C369D2E37038AFB3398B7E0D0E11DD2D90F63EA99AAFD1F9034A` |

执行前只读确认两文件输入哈希匹配、`.dart_tool/package_config.json` 存在，`dart`/`flutter` 本地命令可用；未运行 `pub get`。

| 验证 | 本任务预算消耗 | 回执 |
| --- | --- | --- |
| `dart format` 两文件 | 每文件写入调用 1/1 | 退出 0；两文件被排版 |
| `dart format --output=none --set-exit-if-changed` 两文件 | 每文件只读复核 1/1 | 退出 0；0 changed |
| `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0；11/11 tests passed（原八条与新增三条） |
| `git diff --check --` 两文件 | 1 次 | 退出 0；仅 Git LF/CRLF 提示，无空白错误 |

未运行完整套件、模拟器、设备、网络、后端或真实数据检查。此候选仅证明本地人工演示的展示边界，不建立 APP-T12 G-08 真实 Home 活态来源、真实 Match/CN/MC 权威、设备或生产行为。回退只撤销 APP-HM-06 在两文件上的新增差异及本摘要，保留 APP-HM-01～05 已有候选和全部无关工作区内容；旧预算不重置。
