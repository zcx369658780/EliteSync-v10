# EliteSync v10｜新版本 APP 功能设计基线

项目源版本：2026-09-27。完整正式设计及 Owner 接受记录见本包 `06_新版本APP功能设计正文_已接受.md`、`07_新版本APP功能设计Owner接受记录.md`。本摘要只帮助导航，不替代原文、实时产品决定或工程任务。

目标体验是 calm, consent-sequenced relationship decision support：**状态清楚 → 权限清楚 → 下一步清楚 → 原因清楚 → 退出路径清楚**，不是最大化匹配、消息或停留时间。MVP 顶层 `Home | Progress | Messages | Me`。Profile 目的分为 Private Identity、Matching Inputs、Readiness、Showcase；不默认全球公开。Readiness 使用可解释的 named checklist，不用关系价值黑箱分数；MVP 不采用单一权威 Compatibility 总分。

Match、Connection、Conversation、Relationship 各有独立生命周期与授权。Match 不自动创建 Connection，Connection 不自动开放 Conversation，Conversation 行为不自动判定 Relationship。在线消息 read/send 需当前有效 Connection 和独立消息同意；本地缓存/旧测试/投影不是 live 权限。Relationship 支持留在 Phase 2，AI 为可选解释/反思辅助，不裁定事实、过错或 Safety finding，也不默认读取完整私密对话。

MVP 主循环是 Onboarding → Readiness → canonical Match → Connection → Conversation；Calm Home、Privacy/Settings、Explainability、privacy-minimal notifications 与 legacy Match 的有门槛迁移/cutover 随之推进。Phase 2 包含 Explore/Support Library、Relationship support 及更复杂的共享内容权利；Later/Optional 才讨论 AI private reflection、personality/astrology 等信号。旧 participant-linked Match 不因新目标设计直接删除，需先完成消费者盘点、替代合同及回退/cutover 门。

Owner 后续明确的离线方向：按账户加密的已保存私密内容可在条件满足时离线只读，包含已保存会话、消息、媒体和草稿；离线不得发送。在线登录期 15 天；从最后一次成功在线登录算起满 30 天未再次登录则清理相应加密私密内容。自动 Token 续期不重置该计时，可靠时间无法判断时先锁定。具体凭据、撤权传播和清理能力仍待合同与实现。

当前本地后端候选、备份、数据库恢复、APK/签名/部署的状态必须分别核验；正式产品设计不证明其中任何一项已完成。精确执行状态始终从仓库根 `CURRENT.md`、`TASK_CURRENT.md` 和相应 `EVIDENCE` 审查读取。旧 Owner Review Draft 仅为历史草稿，不能覆盖正式设计与接受记录。
