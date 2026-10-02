# APP-G11-03｜Chat 通知的已存会话身份绑定

状态：`ISSUED`；风险 `LEVEL 2`（通知路由身份/私密导航边界）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。候选交付后停 Work 独立 LEVEL 2 审查。

## 目标与精确范围

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 全部保留。先读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 workflow/runtime 技能，APP-G11-02 的 `work-review.md`、APP-T12 重审结果 G-11，并只读核对 `ChatRouteState`、`conversationDetailProvider` 与 `ConversationEntity` 的直接合同。

只允许修改 `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart`（输入 SHA-256 `82CA6139C3F0385D51F259F6AE531E8ADD35250D2AAF40FB96AB9A5E0C6D0457`）及 `apps/flutter_elitesync_module/test/features/notification/presentation/pages/notification_center_page_test.dart`（输入 SHA-256 `A715A72DE92BAC3D9B7760379B583A2A46EFC42613D598D7D9E12C234E394CC2`），另新增本目录 `summary.md`。不改 ChatRouteState、provider、API/DTO、路由表或其它代码。

当前 `_openNotification` 的 `chat_room` 分支读取通知携带的正 `conversation_id`，再解析 `ConversationEntity`；现有检查只拒绝非空且不相等的返回 ID，随后会将通知参数构造成 `ChatRouteState.stored`。本任务要求仅在解析结果**明确是** `entryKind == 'stored_conversation'`、返回 `conversationId` 为正且与通知 ID 完全相同、`peerUserId` 为正时构造该路由身份并打开。结果缺失 ID、不同 ID、非 stored entry kind（含 legacy/eligible/unknown）或解析失败时，给现有安全提示、不导航、不自动标记已读，不能从通知参数补造 stored identity。保留正常 stored 例与现有 `status_author` 失败关闭。测试使用人工通知与 provider override，核对成功路径及至少缺失 ID、不同 ID、非 stored kind 的负例；不得让 raw payload/name 透出。

## 新一次性验证预算与停点

编辑前只读核对两输入哈希、`.dart_tool/package_config.json` 及本地 `dart`/`flutter`。编辑后只运行 `flutter test --no-pub test/features/notification/presentation/pages/notification_center_page_test.dart` 首跑一次；仅本任务两文件内夹具/实现缺陷可修后复跑该文件一次。所有必要编辑后两文件各最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；格式若未改语义无需复测。对两目标文件运行 `git diff --check`。不扩成完整套件、设备、网络或后端验证。

`summary.md` 记录两文件前后哈希、成功/负例结果、测试数与退出码、格式/空白检查、预算消耗和回退范围。回退只撤销本任务两文件新增差异及摘要，保留 APP-G11-01/02 和无关工作区。若合同/行为与预期冲突或预算内不能通过，保存事实并停，不扩大范围或自验收。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push 或启动后继。此任务不建立真实 Conversation 权限，G-11 其他债、G-08、AUTH-170、AUTH-155 Phase B 和账号/恢复门不变。
