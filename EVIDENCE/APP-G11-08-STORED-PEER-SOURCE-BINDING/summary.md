# APP-G11-08 作者候选摘要

状态：候选已交付，待 Work 独立 LEVEL 2 审查；未自接受。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be` 未移动；无提交、pull、push。

## 局部结果

- `ConversationDto.fromJson` 对明确 `entry_kind == 'stored_conversation'` 的条目只从正 `peer_user_id` 取得 peer 身份；缺失、0、负数或无效值保留 `peerUserId=null`，即使旧 `id` 是正数字也不回填。非 stored 且缺失 `peer_user_id` 的旧 `id` 回退仍在。
- `ChatRouteState.fromConversation` 对明确 stored 的 `ConversationEntity` 只用 `peerUserId`；缺失/非正时沿原有 `ArgumentError` 路径失败。非 stored 的数字 `id` peer fallback、有效 eligible 与 APP-G11-06 的类别/会话 ID 一致性保持。
- DTO/Entity 人工 JSON 测试覆盖 stored peer 缺失、0、-1、无效字符串、明确正 peer，以及既有 eligible/legacy；直接 Entity 测试覆盖数字 `id` 不能补造 stored peer、明确 peer 正例及 eligible/legacy 数字 fallback。

## 验证及一次性预算

- 指定双文件 `flutter test --no-pub test/features/chat/data/dto/send_message_contract_dto_test.dart test/app/router/chat_route_state_router_test.dart`：首跑 **1/1、退出 0、28/28 通过**；修正复跑 **0/1**。
- 四目标文件各一次 `dart format` 写入（均退出 0），各一次 `dart format --output=none --set-exit-if-changed` 只读复核（均退出 0、0 changed）。格式后未改语义、未复测。
- 四文件 `git diff --check` 退出 0。未运行列表 widget、完整套件、设备、网络、后端或真实数据验证。

| 文件 | 输入 SHA-256 | 最终 SHA-256 |
| --- | --- | --- |
| `apps/flutter_elitesync_module/lib/features/chat/data/dto/conversation_dto.dart` | `8307925EB563016B64B731526BE96ED5FC181C4AD3219199C037A58BD2C2945B` | `CA6501FBAF63CBB9598F3C103E562E3D80F4161A4EADAE18C88EF79A01B7B8AE` |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `6F48C4977726A7E5CF23F85BE2153C709997710A254D669BCF29326F12360675` | `6433BB886773453D049C6A1F8A78D1CECC54011A90AD7CE31C772B14B90D91EA` |
| `apps/flutter_elitesync_module/test/features/chat/data/dto/send_message_contract_dto_test.dart` | `54797FF848A5750807CB8612F9F5EFB529DD944B8A46CB7B9BD0BC40CBE6AD3A` | `1D5B03AC9C2DDDB31063BC706BACEB757B08BADAD3BA6771A0C40A5CB18F278B` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `7307C99F730DDF0534FE3077FAA66886EDFA89FD14A18FF1F1DF4D0E7EDF2D7D` | `1A41E93C1F39C3B94F14127C1825145F65AE62EAC8E7DFA5A6721AAFBFEE0F31` |

相对 Git HEAD，`chat_route_state.dart` 与其路由测试还包含已接受的 APP-G11-06 差异；本任务回退仅撤销上述四文件的 APP-G11-08 新增差异及本摘要，保留 APP-G11-01～07 和全部无关 dirty/untracked。人工 DTO/Entity 回归不建立真实 Conversation consent、read/send 或 actor/audience 权限；G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、账号与恢复门不变。
