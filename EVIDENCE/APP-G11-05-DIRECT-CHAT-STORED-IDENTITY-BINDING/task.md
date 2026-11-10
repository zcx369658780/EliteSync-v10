# APP-G11-05｜无 typed extra 的 Chat 直达 URL 已存身份绑定

状态：`ISSUED`；风险 `LEVEL 2`（Chat 路由身份/私密入口）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 精确目标与路径

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根五文档、本地 workflow/runtime 技能、APP-G11-04 的 `plan.md`/`work-review.md`、APP-G11-03 的 `work-review.md`，并核对 `ChatRouteState`、`ConversationEntity`、`conversationDetailProvider` 与 `ConversationAccessGate` 的当前直接合同。

只允许修改 `apps/flutter_elitesync_module/lib/app/router/app_router.dart`，输入 SHA-256 `602179CB8BB0BE716FC73C5E2FFA788CC81C71C0EFF044D7C9380FB0987A8912`；新增 `apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart` 与本目录 `summary.md`。不改通知入口、ChatRouteState、provider、DTO、后端或其他测试。

`_StoredConversationRoutePage` 只在本地 access gate 允许且详情**明确是** `entryKind == 'stored_conversation'`、返回正 `conversationId` 与 URL `conversation-<id>` 完全相同、返回 `peerUserId` 为正时构造 `ChatRouteState.stored`。详情缺失 ID、不同 ID、非 stored kind（legacy/eligible/unknown）或读取失败时保留现有安全错误页，不得由 URL 补造 stored 身份、显示详情私密文案或进入 Chat room；access 未建立时仍不查询详情。typed extra 与纯整数 legacy 路径保持现状，不以 URL/extra 代替真实 consent 或 read/send authority。

新增 widget 回归用人工 dev/mock provider 与实际 app router，至少核对一个有效 stored 详情、缺失 ID、不同 ID、非 stored kind、access 未建立不发起详情读取。若实际 ChatRoomPage 使正例夹具需额外无关依赖，允许只证明已构建/进入本地 Chat room 而不测试消息内容或 writer；不得改其他文件或开启网络。负例要确认安全页、无 raw 私密文案/Chat room。若现有 app router 不能在该单文件夹具内可靠验证，保留精确停点，不扩大路径。

## 新一次性预算与停点

编辑前只读核对 router 输入哈希、`.dart_tool/package_config.json` 和本地 `dart`/`flutter`。编辑后只运行 `flutter test --no-pub test/app/router/stored_chat_direct_route_binding_test.dart` 首跑一次；仅本任务夹具/实现缺陷可修后复跑该文件一次。所有必要编辑后两目标文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；仅排版无需复测。对已跟踪 router 运行 `git diff --check`，对未跟踪新测试另作行尾空白检查并说明方法。不运行完整套件、设备、网络或后端。

`summary.md` 记录源/新文件前后哈希、实际用例/退出码、预算、格式/空白检查、回退范围及未证实权限。无法通过则记录失败，不自接受。回退只撤销本任务 router 差异、新测试和摘要，保留 APP-G11-01～04 与无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或启动后继。真实 Conversation 权限、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B 与账号/恢复门不变。
