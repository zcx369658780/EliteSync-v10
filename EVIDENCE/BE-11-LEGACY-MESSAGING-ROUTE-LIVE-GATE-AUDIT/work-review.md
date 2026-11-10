# BE-11 Work 独立审查｜2026-09-27

**LEVEL 3 ACCEPT，仅接受本地源码 docs-only 缺口审计；真实部署与账号影响 `NOT_CHECKED`。** 审查对象 `plan.md` 的 SHA-256 `04B0B229F5D3A97161141E5EDCE130F9B437CAAE7CB521AF57A42104FEF25746`，作者固定来源静态预算 2/2 耗尽。Work 另核对本地路由声明、`ConversationCapabilityService::evaluate/authorizeSend`、`ConversationController::index`、`ConversationDomainService::summarizeConversation` 和 `MessageController` 到 `ConversationAtomicSendService` 的重放/发送位置；没有运行消息或数据库。

七条受保护路由的静态调用链确实仍用已释放 `DatingMatch` 或现有 `Conversation`/block 判断；未见已接受设计要求的当次、独立、按 read/send purpose 绑定的 `CN_ACTIVE` 与 `MC_ACTIVE` 来源。会话列表在旧 `canRead` 过滤前调用摘要并生成最近消息预览/未读数；带 `client_message_id` 的消息重放在当前发送授权前可返回既有消息。旧 read 判断还可在 block 后因会话或 match 成立。现有 `auth:sanctum` 只证明路由身份中间件声明，不补足 v10 live gate。BE-10 纯内存 sentinel 也不是可信来源或真实 writer。

本接受不证明这些代码在线上部署、请求实际执行、真实用户可读写或发生过泄漏；也不授予立即改生产配置。下一本地候选应先在入口处默认 fail closed，覆盖七条路由并在**控制器进入前**拒绝，使预览构造、已读写入、重放、媒体预检、消息/事件/通知提交均不可达；`/messages/ws` stub、非私密 match 展示和其他路由需保持独立边界。此保护会改变旧正例测试和客户端行为，必须在新代码任务中列出兼容影响、定向负例及旧测试处置，不能以旧测试恢复访问或假造 CN/MC 来源。可信来源签发、取得、auth/session 与原子 writer 仍需独立合同。

作者只新增 `plan.md`，未改代码或运行测试、SSH、真实 DB、备份/恢复；未提交、拉取或推送。旧 BE/AUTH 预算不重置。
