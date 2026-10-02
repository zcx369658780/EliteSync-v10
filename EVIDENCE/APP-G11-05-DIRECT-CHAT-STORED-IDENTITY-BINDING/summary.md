# APP-G11-05 作者候选摘要

状态：候选交付，待 Work 独立 LEVEL 2 审查；未自接受。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动，无提交、pull、push。

## 候选与行为

- `app_router.dart` 的 `_StoredConversationRoutePage` 保留先判断本地 access、再读取详情。无 typed extra 的 `conversation-<id>` 直达入口仅在详情 `entryKind == 'stored_conversation'`、返回正 `conversationId` 等于 URL ID、返回正 `peerUserId` 时，以**返回的 ID**构造 `ChatRouteState.stored`。缺失/不同 ID、非 stored kind 或详情读取失败使用既有安全错误页；typed extra 与纯整数 legacy 分支未改。
- 新增实际 app router widget 文件 `stored_chat_direct_route_binding_test.dart`：人工有效 stored 详情进入本地 Chat room；缺失 ID、不同 ID、legacy、eligible、unknown kind、详情读取失败均停安全页且不显示 raw 私密文案；access 未建立时不请求详情。mock Chat 与 provider override 不代表真实权限。

## 一次性验证预算

- 指定单文件 `flutter test --no-pub test/app/router/stored_chat_direct_route_binding_test.dart` 首跑 **1/1、退出 1**：8 个用例均未进入目标路由。夹具误用 `/chat/conversation-41`，实际 `AppRouteNames.chatRoom` 为 `/messages/chat`；仅在新测试文件修正 initialRoute。
- 同文件唯一修正复跑 **1/1、退出 0、8/8 通过**。没有运行完整套件、设备、网络或后端验证。
- 必要编辑后，router 和新测试各执行一次 `dart format` 写入（各退出 0）及一次 `dart format --output=none --set-exit-if-changed` 只读复核（各退出 0、0 changed）。格式后仅排版变化，未再复测。
- `git diff --check -- apps/flutter_elitesync_module/lib/app/router/app_router.dart` 退出 0；对未跟踪测试用 PowerShell `Select-String -Pattern '[\t ]+$'` 逐行检查，行尾空白 0 行。router 相对 HEAD 的差异还包含 APP-G11-02 已接受的 Match readiness 守卫，非本任务改动。

## SHA-256 与回退

| 文件 | 任务输入 | 最终 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `602179CB8BB0BE716FC73C5E2FFA788CC81C71C0EFF044D7C9380FB0987A8912` | `88659FA22A70432031594AA660171A4AC253B11C301FFF4B7FBADFE866FA0F81` |
| `apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart` | 不存在（本任务新增） | `E4A57BB5B3B8C325B1B84A9E616108A2A1B68F986DD707DE956EC7B9CB5134E7` |

回退仅撤销 router 的 `_StoredConversationRoutePage` 本任务局部差异并移除新测试与本摘要；保留 APP-G11-01～04 及所有无关 dirty/untracked。此候选只证明本地人工详情下的路由身份绑定，未证明真实 Conversation read/send、actor/audience、通知投递或生产行为。G-11 其他债、G-08、AUTH-170、AUTH-155 Phase B、账号和恢复门不变。
