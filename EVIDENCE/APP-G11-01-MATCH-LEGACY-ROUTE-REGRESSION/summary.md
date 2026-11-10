# APP-G11-01 Codex 候选与失败停点｜2026-09-29

状态：新增 test-only 候选，**定向测试首跑失败，停 Work 独立 LEVEL 2 审查**；未自验收、提交、pull 或 push。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。

只新增 `apps/flutter_elitesync_module/test/app/router/match_legacy_redirect_regression_test.dart`。只读输入哈希：`lib/app/router/app_router.dart` 为 `B74A099A2E056ACA938BFD706807281885DED2A7293D1A4C3C98D804203DB9EB`，`lib/app/router/app_route_names.dart` 为 `FCABD90DE3634E1D72C9783C86A29104D428858F046C95C2D413F99F6F0395C5`，均与任务单一致。新测试文件 SHA-256 `67C26750AB91C0CF33E5F7021E611B735E4139A61B8EBC19F6A863938494E37F`。执行前 `.dart_tool/package_config.json` 存在，`dart`/`flutter` 本地命令可用；未运行 `pub get`。

测试以 dev/mock、认证、人工 ready navigation、已完成 first-use 和本地 Home 夹具启动**实际** `appRouterProvider`，检查最终 URI 与可见 `MatchShellPage`，并单列未建立 readiness 的负向用例：

| 入口 | 人工 ready 时首跑结果 |
| --- | --- |
| `AppRouteNames.match` (`/match`) | `/progress/match`，可见 Match portal，PASS |
| `matchCountdown` (`/match/countdown`) | 同上，PASS |
| `matchResult` (`/match/result`) | 同上，PASS |
| `matchDetail` (`/match/detail`) | 同上，PASS |
| `matchIntention` (`/match/intention`) | 同上，PASS |
| `matchFeedback` (`/match/feedback`) | 同上，PASS |

第七条以 `/match/result`、已认证但 `readinessState=unknown` 启动，预期安全转向 `/me/readiness`；首跑实际 URI 为 `/progress/match`，断言失败。`app_router.dart` 的全局 readiness guard 明确检查 `path == AppRouteNames.progressMatch`，而别名各有 route-level redirect；这次运行表明**不能把别名重定向本身当成 guard 已生效**。在本任务只准新增测试文件的范围内，不能修改路由以消除该差异，也不能将失败断言改成通过来宣称安全。此处只报告实测路径，不断言所有入口或所有运行条件下的机制。

| 验证 | 新预算消耗 | 回执 |
| --- | --- | --- |
| `flutter test --no-pub test/app/router/match_legacy_redirect_regression_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 1；六条 ready 用例通过，一条 readiness 负例失败（`+6 -1`）。失败不是可归因于本任务夹具/断言编辑的缺陷，因此未使用复跑预算 |
| `dart format` 新文件 | 写入 1/1，在首跑后 | 退出 0，0 changed |
| `dart format --output=none --set-exit-if-changed` | 只读 1/1 | 退出 0，0 changed |
| `git diff --check --` 新文件 | 1 次 | 退出 0；文件未跟踪，Git 没有覆盖其内容 |
| 未跟踪文件空白核对 | 1 次，本地 `Select-String` 行尾 `[ \\t]+$` | `trailing_whitespace_lines=0` |

未运行完整套件、设备/模拟器、网络、后端或真实数据检查。G-11 兼容债仍在；本轮只证明六个别名在人工 ready 条件下的收敛，同时记录一项未通过的 guard 边界。没有从别名取得 Connection/Conversation 权限的证据；真实 Home G-08、账号/恢复门不变。回退只撤销本任务新测试文件与本摘要，不碰 APP-HM-01～10 和无关工作区；旧预算不重置。
