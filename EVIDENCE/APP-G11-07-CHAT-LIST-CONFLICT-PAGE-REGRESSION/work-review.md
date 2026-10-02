# APP-G11-07 Work 独立审查｜2026-09-29

**LEVEL 2 ACCEPT，限定接受本地人工列表矛盾身份点击后的 widget 失败关闭回归。** Work 核对唯一测试文件当前 SHA-256 `2D4D2664C4A97571FEBC87E1CCCACF68FA298408DE52C55DA48AB95F36B89935`，差异仅新增四个参数化负例，共 87 行；已有有效 stored typed-route 正例保留。负例覆盖 legacy、eligible、缺省类别携带会话 ID 和 stored 缺失 ID，核对安全提示、仍在列表、未构建 Chat 目标/未传 typed extra、目标私密占位文案未显示。

作者首跑退出 1，原因是新增夹具根页面缺少 `Scaffold`，使安全提示无处显示；仅在新夹具补 `Scaffold` 后唯一复跑退出 0、20/20 通过。最终 `git diff --check` 退出 0。格式写入及只读复核曾退出 0，但随后为收窄差异恢复了既有排版；**最终文件格式工具复核未建立**，该限制保留。本任务格式与测试预算已耗尽，Work 未补跑，也不把格式状态写成通过。最终差异的新增测试经人工审阅与空白检查，没有改产品代码。

这只证明人工列表与本地 router 夹具下的点击行为，不证明真实 Conversation consent/read/send、真实列表兼容或生产行为。APP-G11-06 的 Unit 接受与旧预算不重置；G-11 其它债、APP-T12 G-08、AUTH-170 `UNAVAILABLE/NOT_CHECKED`、AUTH-155 Phase B 与 CMS 认证/隔离恢复及账号回填不变。既有工作区保留，无提交、pull、push 或受保护动作。
