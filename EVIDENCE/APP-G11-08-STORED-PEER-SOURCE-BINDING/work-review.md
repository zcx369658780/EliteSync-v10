# APP-G11-08 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受本地人工 stored 列表项的 peer 来源绑定。** Work 核对四个允许文件当前 SHA-256 与作者摘要一致，并审阅源码和测试差异。`ConversationDto.fromJson` 对明确 `stored_conversation` 只接收正的显式 `peer_user_id`，缺失或无效时保留 null；`ChatRouteState.fromConversation` 对同类 Entity 不再从数字 `id` 回填 peer，缺失或非正 peer 抛 `ArgumentError`。正 peer 和 conversation ID 可形成 stored route；未声明 stored 的旧数字 peer fallback 及 APP-G11-06 的类别/会话 ID 一致性仍保留。

作者指定双文件 Flutter 测试首跑退出 0、28/28 通过；四文件格式写入和只读复核均退出 0，`git diff --check` 退出 0。Work 依据一次性预算未复跑。测试覆盖人工 JSON→DTO→Entity 和直接 Entity 的正反例，但没有本任务的列表点击 widget 回归。

这只证明人工本地数据下的解析与路由转换，不证明真实列表兼容、Conversation consent/read/send 或 actor/audience 权限。APP-T12 G-11 其它债、G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证、隔离恢复与账号回填不变。旧预算耗尽且不重置；本地 main HEAD 未移动，无提交、pull、push 或受保护动作。
