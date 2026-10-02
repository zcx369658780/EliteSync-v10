# APP-G11-02 Codex 修复候选摘要｜2026-09-29

状态：候选完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。APP-G11-01 的 `+6 -1` 失败事实、REJECT 和旧预算不重置。

仅在 `app_router.dart` 现有全局 readiness guard 上加入 `/progress/match` 与六个历史 Match 别名的**精确路径**判定；已认证但 readiness 未建立时返回 `/me/readiness`。别名原有 route-level redirect 不变，人工 ready 时仍转到统一 Match portal。守卫只控制导航，不写 readiness、Match、Connection 或 Conversation 状态，也不把别名当授权。保留 APP-G11-01 的失败断言，并在同一测试文件新增其余五别名与 canonical 路径的 unknown readiness 负例。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `B74A099A2E056ACA938BFD706807281885DED2A7293D1A4C3C98D804203DB9EB` | `602179CB8BB0BE716FC73C5E2FFA788CC81C71C0EFF044D7C9380FB0987A8912` |
| `apps/flutter_elitesync_module/test/app/router/match_legacy_redirect_regression_test.dart` | `67C26750AB91C0CF33E5F7021E611B735E4139A61B8EBC19F6A863938494E37F` | `405065F399F3DB953CD27A2630390E5317F63D13B0653B2C6B642057CEC73FBE` |

执行前确认两输入哈希匹配、`.dart_tool/package_config.json` 存在且本地 `dart`/`flutter` 可用；未运行 `pub get`。

| 条件 | 六个历史 Match 别名 | `/progress/match` |
| --- | --- | --- |
| 人工 ready | 六条各到 `/progress/match`，可见 `MatchShellPage`，无 Readiness 页 | 本任务未单列 ready canonical 测试；原目标不变 |
| 已认证、readiness unknown | 六条各到 `/me/readiness`，可见 `ReadinessPurposePage`，无 Match 页；包含 APP-G11-01 原失败的 `/match/result` 断言 | 到 `/me/readiness`，无 Match 页 |

| 验证 | 本任务新预算消耗 | 回执 |
| --- | --- | --- |
| `flutter test --no-pub test/app/router/match_legacy_redirect_regression_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0，13/13 tests passed |
| `dart format` 两文件 | 各写入 1/1，首跑后执行 | 退出 0；两文件排版 |
| `dart format --output=none --set-exit-if-changed` 两文件 | 各只读复核 1/1 | 退出 0，0 changed |
| `git diff --check --` 已跟踪 router | 1 次 | 退出 0，无空白错误 |
| 未跟踪测试文件行尾空白检查 | 1 次，`Select-String` 匹配行尾空格/Tab | `test_trailing_whitespace_lines=0`；Git diff 不覆盖未跟踪内容 |

未运行完整套件、设备/模拟器、网络、后端或真实数据检查。这只证明本地人工路由输入；G-11 的通知载荷、Chat identity 和其他历史兼容债仍未解决，真实 Home G-08、AUTH-170、AUTH-155 Phase B 与账号/恢复门不变。回退只撤销本任务 router 精确 guard 扩展、测试文件新增负例及本摘要；保留 APP-G11-01 原测试/失败证据与全部无关工作区内容。
