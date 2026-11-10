# APP-G11-06 作者候选摘要

状态：候选已交付，待 Work 独立 LEVEL 2 审查；未自接受。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动；无提交、pull、push。

## 局部改动

`ChatRouteState.fromConversation` 仅在 `entryKind == 'stored_conversation'` 且 `conversationId` 为正时生成 stored route state。明确 stored 但 ID 缺失/无效，或非 stored/缺省类别却带 ID，均抛 `ArgumentError`，由现有列表入口的 `ArgumentError` 处理显示安全提示。有效 `eligible_match` 且无会话 ID 的转换，以及无会话 ID 的旧 peer fallback 保留。未改列表 UI、DTO、provider 或实际 router。

目标 Unit 测试新增有效 stored、stored ID 为 null/0/-1、legacy/eligible/unknown 类别携带 ID，以及 eligible 和旧 peer fallback；冲突项不能升级为 stored。

## 验证与预算

- 指定 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart`：首跑 **1/1、退出 0、12/12 通过**；修正复跑 **0/1**。
- 两文件各一次 `dart format` 写入（均退出 0），各一次 `dart format --output=none --set-exit-if-changed` 只读复核（均退出 0、0 changed）；格式后只调整排版，未复测。
- `git diff --check -- <两目标文件>` 退出 0。未运行完整套件、设备、网络、后端或真实数据验证。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `4FC2409759CC340B5A7E3BBE27DA1B89FA7150D32B0AB40F219E66A35B1C8CE6` | `6F48C4977726A7E5CF23F85BE2153C709997710A254D669BCF29326F12360675` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `EC60001B8ECAA973DC228B43E386B08F5B2CD0FCA912C7114195F143C7CC905F` | `7307C99F730DDF0534FE3077FAA66886EDFA89FD14A18FF1F1DF4D0E7EDF2D7D` |

回退仅撤销本任务上表两文件差异及本摘要，保留 APP-G11-01～05 和全部无关 dirty/untracked。其他 eligible/legacy/unknown 兼容归类策略未全面重写。此人工 Unit 结果不建立真实 Conversation consent、read/send 或 actor/audience 权限；G-11 其余债、G-08、AUTH-170、AUTH-155 Phase B、账号与恢复门不变。
