# APP-G11-05 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受无 typed extra 的本地 stored Chat 直达 URL 身份绑定。** Work 核对 router 当前 SHA-256 `88659FA22A70432031594AA660171A4AC253B11C301FFF4B7FBADFE866FA0F81` 与新增测试 SHA-256 `E4A57BB5B3B8C325B1B84A9E616108A2A1B68F986DD707DE956EC7B9CB5134E7`，均与摘要一致。router 仅在 `_StoredConversationRoutePage` 要求详情明确为 `stored_conversation`、返回正会话 ID 与 URL ID 相同、peer ID 为正；由返回 ID 构造 route state。原有 access 先行检查、typed extra 与整数 legacy 分支未改。

作者目标文件首跑退出 1，原因是新测试夹具把实际 `/messages/chat` 前缀写成 `/chat`，8 例均未进入目标路由；只在新测试文件修正后，唯一复跑退出 0、8/8 通过。有效详情进入本地 Chat room；五类身份异常及读取失败停安全页、不显示 raw 私密文案；access 未建立时不读取详情。两文件最终格式复核、router 空白检查和未跟踪测试行尾空白检查通过。Work 未复跑或重用一次性预算。

这只证明人工详情及人工 access override 下的本地导航边界，不证明真实 Conversation read/send、actor/audience、设备或生产行为。G-11 其它混合身份债、APP-T12 G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B、CMS 认证/隔离恢复与账号回填不变。旧预算不重置，工作区保留，无提交、pull、push 或受保护动作。
