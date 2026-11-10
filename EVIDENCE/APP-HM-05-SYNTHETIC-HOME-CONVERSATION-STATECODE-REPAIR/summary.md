# APP-HM-05 Codex 修复候选摘要｜2026-09-29

状态：候选完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有工作区保留。APP-HM-04 独立 REJECT 及旧预算不重置。

Home 投影中，Conversation 无 synthetic development 状态时，摘要保持 `authority=notYetEstablished`，现将 `stateCode` 置 `null`，不再透出底层 `ConversationAccessSnapshot.notYetEstablished()` 内部安全默认的 `CV_LOCKED`。其内部默认、既有“查看进展”安全回退、Connection/Match/ready/路由均未改动。定向负例补断言 `stateCode=null`；已知 synthetic `CV_LOCKED` 与 `CV_ACTIVE` 的原主循环断言保留。此候选仅证明本地人工展示边界；真实 CN/MC/Home 权威、APP-T12 G-08、真实同意/权限及生产行为仍未验证或建立。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `18338B3D5EDF4EDA86AAB9C3B19DAC68FD8CFB65726EE9D73518D028475580F3` | `ACCB6E0BD61CCAEF00FEB33C8CEF6E1E23EF19999DDF347695A843B487A7BBD4` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `3D3DFD34D1009A8AB6D88BD496D6377F151A23B8632956800256482AF94F9640` | `12B6810CD661AA1ED1D38601332CD17D30C0F27FB04270948C14430591F5E593` |

执行前只读确认 `.dart_tool/package_config.json` 存在、`dart`/`flutter` 本地命令可用；未运行 `pub get`。

| 验证 | 本任务预算消耗 | 回执 |
| --- | --- | --- |
| `dart format` 两文件 | 每文件写入调用 1/1 | 退出 0；provider 被排版，测试文件 0 changed |
| `dart format --output=none --set-exit-if-changed` | 每文件只读复核 1/1 | 各退出 0，0 changed |
| `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0，8/8 tests passed |
| `git diff --check --` 两文件 | 1 次 | 退出 0；仅 Git LF/CRLF 提示，无空白错误 |

未运行全套、模拟器、设备、网络、后端或真实数据检查。回退仅撤销本任务两文件新增差异和本摘要，保留 APP-HM-01～04 及全部无关状态。
