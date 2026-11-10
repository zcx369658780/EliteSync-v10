# APP-G11-07｜Chat 列表矛盾身份点击的页面失败关闭回归

状态：`ISSUED`；风险 `LEVEL 2`（Chat 列表到路由的私密导航，test-only）；派发 Codex 会话 `01a0eca1-785a-78d2-8623-7e88e1c125d2`。交付后停 Work 独立 LEVEL 2 审查。

## 唯一允许路径与目标

唯一实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 dirty/untracked 保留。先读根五文档、本地 workflow/runtime 技能、APP-G11-06 `work-review.md`；只读核对当前 `ChatRouteState.fromConversation` 与 `ConversationListPage._openConversation`。只允许修改 `apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart`，输入 SHA-256 `8851A2D8E4F1E097C27A72CFC06BDFA834A521F85A1A58DC4702FE1C85274515`；另新增本目录 `summary.md`。不改产品代码、DTO、provider、路由表或其它测试。

复用该测试文件的本地人工列表与 router 夹具。保留现有有效 stored 的 typed route 正例，在人工列表项 `entryKind`/`conversationId` 矛盾（至少 legacy/eligible/缺省类别携带 ID，以及 stored 缺失 ID）时点击，核对 `ConversationListPage` 只显示现有安全提示、不进入 Chat route、不把私密文案带到目标页或触发 writer。测试只针对 APP-G11-06 已接受的本地转换与页面消费；不要覆盖 `ChatRouteState.fromConversation` 或把 mock access 当真实 consent。若现有夹具无法在唯一测试文件内可靠覆盖，记录精确停点，不扩范围。

## 新一次性预算与停点

编辑前只读核对输入哈希、`.dart_tool/package_config.json` 与本地 `dart`/`flutter`。编辑后只运行 `flutter test --no-pub test/features/chat/presentation/pages/conversation_list_page_test.dart` 首跑一次；仅本任务测试夹具/断言缺陷可修后复跑该文件一次。所有必要编辑后目标文件最多一次 `dart format` 写入、一次只读 `dart format --output=none --set-exit-if-changed`；仅排版无需复测。运行目标文件 `git diff --check`。不扩成完整套件、设备、网络或后端命令。

`summary.md` 记录输入/最终哈希、实际用例/退出码、预算、格式/空白检查和未证实权限。回退仅撤销本任务在目标测试文件新增差异及摘要，保留 APP-G11-01～06 与无关工作区。不得访问旧 `D:\EliteSync`、真实 DB/备份/密钥、SSH、云/生产 API；不得提交、pull、push、自验收或启动后继。真实 Conversation read/send、G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B 和账号/恢复门不变。
