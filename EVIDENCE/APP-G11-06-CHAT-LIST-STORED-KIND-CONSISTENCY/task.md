# APP-G11-06｜Chat 列表项转换的已存会话类别一致性

状态：`ISSUED`；风险 `LEVEL 2`（Chat 身份转换/私密导航）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 精确目标与允许路径

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根五文档、本地 workflow/runtime 技能、APP-G11-04 `plan.md`/`work-review.md`、APP-G11-03/05 `work-review.md`；只读核对 `ConversationEntity`、`ConversationDto` 和 `ConversationListPage._openConversation` 的直接合同。

只允许修改 `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart`，输入 SHA-256 `4FC2409759CC340B5A7E3BBE27DA1B89FA7150D32B0AB40F219E66A35B1C8CE6`；以及 `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart`，输入 SHA-256 `EC60001B8ECAA973DC228B43E386B08F5B2CD0FCA912C7114195F143C7CC905F`；另新增本目录 `summary.md`。不改列表 UI、DTO、provider、后端、路由表或其他测试。

仅收紧 `ChatRouteState.fromConversation` 的 **stored identity** 分支：只有 `entryKind == 'stored_conversation'` 且 `conversationId` 为正时才生成 `ChatRouteState.stored`；明确声称 stored 却缺少/无效 ID，或非 stored/缺省类别却携带 `conversationId` 时抛 `ArgumentError`，由现有列表入口安全提示处理。保留有效 stored、`eligible_match` 且无 conversation ID 的既有转换，以及无 conversation ID 的旧 peer fallback；不在本任务全面重写 eligible/legacy/unknown 的其余归类策略。测试用人工 `ConversationEntity` 覆盖有效 stored、缺失 ID、不同类别携带 ID、eligible 与旧 peer fallback，确认冲突不会被升级为 stored。不得从列表项/路由身份推断真实 consent 或 read/send 权限。

## 新一次性预算与停点

编辑前只读核对两输入哈希、`.dart_tool/package_config.json` 与本地 `dart`/`flutter`。编辑后仅运行 `flutter test --no-pub test/app/router/chat_route_state_router_test.dart` 首跑一次；仅本任务两文件的夹具/实现缺陷可修后复跑该文件一次。所有必要编辑后两文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；仅排版无需复测。对两文件运行 `git diff --check`。不运行完整套件、设备、网络、后端或真实数据验证。

`summary.md` 记录两文件前后哈希、用例/退出码、预算、格式/空白检查、兼容局限与回退范围。若预算内不能通过或现有合同证据冲突，保留精确失败，不扩大路径或自验收。回退仅撤销本任务两文件差异及摘要，保留 APP-G11-01～05 与无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或启动后继。真实 Conversation 权限、G-11 其余债、G-08、AUTH-170、AUTH-155 Phase B 和账号/恢复门不变。
