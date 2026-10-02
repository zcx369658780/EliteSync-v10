# APP-G11-06 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受 `ChatRouteState.fromConversation` 的本地 stored 类别/ID 一致性修复。** Work 核对两允许文件当前 SHA-256：源码 `6F48C4977726A7E5CF23F85BE2153C709997710A254D669BCF29326F12360675`、定向测试 `7307C99F730DDF0534FE3077FAA66886EDFA89FD14A18FF1F1DF4D0E7EDF2D7D`，与作者摘要一致。明确 `stored_conversation` 且正 ID 才构造 stored；stored 缺失/无效 ID、非 stored 或缺省类别携带 ID 时抛 `ArgumentError`。有效 eligible 与无会话 ID 的旧 peer fallback 未改，列表 UI/DTO/provider/router 未改。

作者目标 Unit 文件首跑退出 0、12/12 通过；两文件最终格式复核和 `git diff --check` 退出 0。Work 未复跑或重用新旧一次性预算。现有列表入口捕获 `ArgumentError` 并显示安全提示的代码已静态核对，但本任务没有新增实际列表点击的 widget 证据。

这只证明人工 `ConversationEntity` 的本地转换，不证明真实列表数据兼容、Conversation consent/read/send 或 actor/audience。G-11 其余债、APP-T12 G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B 与 CMS 认证/隔离恢复及账号回填不变。工作区与旧预算保留，无提交、pull、push 或受保护动作。
