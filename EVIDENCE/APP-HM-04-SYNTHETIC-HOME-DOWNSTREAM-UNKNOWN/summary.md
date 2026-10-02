# APP-HM-04 Codex 候选摘要｜2026-09-29

状态：候选已完成，停 Work 独立 LEVEL 2 审查；未自验收、提交、pull 或 push。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。既有 dirty/untracked 内容保持。

## 候选行为与边界

显式 synthetic Home、readiness `ready`、Match 已取得且可用时，Connection 若无 synthetic development 状态，Home 保留其 `notYetEstablished` 摘要，不再推断“连接尚未激活”；Connection 已知为 synthetic `CN_ACTIVE` 而 Conversation 无 synthetic development 状态时，保留 Conversation `notYetEstablished` 摘要，不再推断“消息同意尚未完成”。两处均不发布 `authoritativeNextDecision`，只使用既有“查看进展”/Progress 安全导航回退。

新定向测试分别构造本地虚构 Connection、Conversation 未建立状态，并核对已知 ready/Match、摘要、无已判定下一决定和回退文案。原六例保留，包括已知 synthetic `CN_NONE`、`CV_LOCKED` 的 ready 主循环，以及 APP-HM-01～03 的 unknown 边界。未把本地 mock、路由或状态当成真实同意/权限；真实 CN/MC/Home 活态权威和 APP-T12 G-08 仍未建立或验证。

回退仅撤销本任务对下列两文件的新增差异及本摘要，保留 APP-HM-01～03 和全部无关状态。

## SHA-256

| 文件 | 输入 | 最终 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/home/presentation/providers/calm_home_projection_provider.dart` | `0218B56F900C4A9BB34C7AF7E592EC65FFC10A2B4F8318FC7FF09F50C2A812F3` | `18338B3D5EDF4EDA86AAB9C3B19DAC68FD8CFB65726EE9D73518D028475580F3` |
| `apps/flutter_elitesync_module/test/synthetic_home_main_loop_integration_test.dart` | `EECFF7B123DC8F794555D7AAD98E1D9AB5C835E90159D4200F3BE83D0C823778` | `3D3DFD34D1009A8AB6D88BD496D6377F151A23B8632956800256482AF94F9640` |

执行前已只读确认 `.dart_tool/package_config.json` 存在，`dart`/`flutter` 本地命令可用；未运行 `pub get`。

## 新一次性验证回执

| 检查 | 消耗 | 结果 |
| --- | --- | --- |
| `dart format` 两文件 | 各写入 1/1 | 退出 0，两文件排版 |
| `dart format --output=none --set-exit-if-changed` | 各只读复核 1/1 | 各退出 0、0 changed |
| `flutter test --no-pub test/synthetic_home_main_loop_integration_test.dart` | 首跑 1/1；修正复跑 0/1 | 退出 0，8/8 tests passed |
| `git diff --check --` 两文件 | 1 次 | 退出 0；仅 Git LF/CRLF 提示，无空白错误 |

未运行全套测试、模拟器、设备、后端、网络或真实数据检查。旧任务预算未重置。
