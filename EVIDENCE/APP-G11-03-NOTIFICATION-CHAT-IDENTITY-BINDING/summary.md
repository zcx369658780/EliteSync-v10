# APP-G11-03 作者候选摘要

状态：候选已交付，待 Work 独立 LEVEL 2 审查；未自接受。仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动；无提交、pull、push。

## 候选

- `notification_center_page.dart` 的 `chat_room` 分支仅在解析结果 `entryKind == 'stored_conversation'`、返回的正 `conversationId` 与通知 ID 相同、`peerUserId` 为正时构造 `ChatRouteState.stored`。缺失或不一致的解析身份不能由通知参数补造；失败沿用安全提示且不自动标记已读。
- `notification_center_page_test.dart` 强化正常已存会话的路由身份断言，并新增缺失 ID、不同 ID、`legacy_peer`、`eligible_match`、unknown kind 五个负例；逐例核对不导航、不标记已读、安全提示以及 raw 私密文案不显示。既有解析失败与 `status_author` 失败关闭测试仍在目标文件内。

## 验证与预算

- 指定单文件 `flutter test --no-pub test/features/notification/presentation/pages/notification_center_page_test.dart`：首跑 1/1，20/20 tests 通过，退出码 0；修正复跑 0/1。
- 两文件各执行一次 `dart format` 写入，退出码均为 0；各执行一次 `dart format --output=none --set-exit-if-changed` 只读复核，均为 0 且 0 changed。格式写入仅调整测试文件排版；格式后未复测。
- `git diff --check -- <两目标文件>`：退出码 0。
- 未运行完整套件、设备、网络、后端或真实数据验证。

## 文件 SHA-256

| 允许路径 | 输入 | 最终 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart` | `82CA6139C3F0385D51F259F6AE531E8ADD35250D2AAF40FB96AB9A5E0C6D0457` | `EF06A8D40544338DB51C3DC3EDB1CD208D7D1FA54BFE703F1F722640869E69CE` |
| `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart` | `A715A72DE92BAC3D9B7760379B583A2A46EFC42613D598D7D9E12C234E394CC2` | `FBBBB85B857AEC6811F6C3D8DF132BA05A3E6C012914092DD3F461CBE420CE8C` |

回退范围仅为上表两文件中的 APP-G11-03 差异及本摘要；保留 APP-G11-01/02 和全部无关 dirty/untracked 内容。本地人工 provider override 的通过结果不建立真实 Conversation 权限；G-11 其他债、G-08、AUTH-170、AUTH-155 Phase B、账号与恢复门均未改变。
