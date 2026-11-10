# APP-G11-08｜Stored Chat 列表项的 peer 来源绑定

状态：`ISSUED`；风险 `LEVEL 2`（Chat 身份解析/私密导航）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 精确目标与路径

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。先读根五文档、本地 workflow/runtime 技能、`CURRENT.md` 顶部 Work 交接误判更正，以及 APP-G11-06/07 的 `work-review.md`。只读核对当前 `ConversationDto.fromJson`、`ChatMapper.conversation`、`ChatRouteState.fromConversation` 和列表入口的直接合同。

仅允许修改四个文件：

| 文件 | 输入 SHA-256 |
| --- | --- |
| `apps/flutter_elitesync_module/lib/features/chat/data/dto/conversation_dto.dart` | `8307925EB563016B64B731526BE96ED5FC181C4AD3219199C037A58BD2C2945B` |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `6F48C4977726A7E5CF23F85BE2153C709997710A254D669BCF29326F12360675` |
| `apps/flutter_elitesync_module/test/features/chat/data/dto/send_message_contract_dto_test.dart` | `54797FF848A5750807CB8612F9F5EFB529DD944B8A46CB7B9BD0BC40CBE6AD3A` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `7307C99F730DDF0534FE3077FAA66886EDFA89FD14A18FF1F1DF4D0E7EDF2D7D` |

另新增本目录 `summary.md`。不得改列表 UI、其他 DTO/provider、后端、真实路由或其他测试。

目标只针对**明确 `entry_kind == 'stored_conversation'`**：若返回 `peer_user_id` 缺失/无效，即使旧 `id` 是正整数，也不得把它补成 stored peer 身份；DTO 解析保留 `peerUserId=null`，`ChatRouteState.fromConversation` 对该 stored 项抛 `ArgumentError`，由现有列表安全提示处理。明确的正 `peer_user_id` 与正 `conversation_id` 正常构成 stored route。无 stored 声明的旧数字 `id` peer fallback、有效 eligible 路径及 APP-G11-06 已接受的类别/会话 ID 一致性保持。不把数字 `id` 或 route state 当作真实 consent/read/send 权限。测试以人工 JSON→DTO→Entity 和直接 Entity 覆盖正反路径，负例至少含 stored 缺失 `peer_user_id`、无效值、数字 `id` 诱导回退，及旧 peer fallback 保留。

## 新一次性验证预算与停点

编辑前只读核对四输入哈希、`.dart_tool/package_config.json` 与本地 `dart`/`flutter`。编辑后只执行一次定向 `flutter test --no-pub test/features/chat/data/dto/send_message_contract_dto_test.dart test/app/router/chat_route_state_router_test.dart`；仅本任务四文件的夹具/实现缺陷可修后额外复跑同一双文件命令一次。所有必要编辑后四目标文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；若写入只改排版无需复测。对四文件运行 `git diff --check`。不运行完整套件、列表 widget、设备、网络、后端或真实数据验证。

`summary.md` 记录四文件前后哈希、实际用例/退出码、预算、格式/空白检查、兼容局限与回退范围。若预算内无法保持旧 peer fallback 或输入合同冲突，记录失败并停，不扩路径或自验收。回退仅撤销本任务四文件的新增差异及摘要，保留 APP-G11-01～07 和全部无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或启动后继。真实 Conversation 权限、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B 与账号/恢复门不变。
