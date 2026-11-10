# BE-11｜本地旧消息/会话路由与双输入 live gate 静态审计（作者候选）

**判定：本地源码存在已注册的旧消息/会话路径；其静态调用链未实现已接受的当次 `CN_ACTIVE` + 独立对应 purpose `MC_ACTIVE` 双证据门。真实运行、线上部署及真实账号影响均 `UNKNOWN/NOT_CHECKED`。** 这是 docs-only LEVEL 3 审计候选，待 Work 独立 ACCEPT/REJECT；不把代码可达性表述为生产暴露。

## 来源、预算与证明层级

工作目录 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`，既有 modified/untracked 保留。`TASK_CURRENT.md` 为本任务 `ISSUED — DOCS-ONLY`；唯一新增本 `plan.md`。固定来源静态核对 **2/2 轮**：第一轮仅在任务单列出的路由、两控制器、三个服务、两 Feature test 和接受文件中定位入口/方法；第二轮精读同一固定集合内的关键分支和私密构造/写入点。未搜索其他代码、旧仓库、索引或服务器。

下表三个层级分开：`routes/api.php` 的注册文本为**本地路由事实**；路由到方法和服务的关系为**静态可达路径**；请求实际执行、路由缓存、部署版本、线上配置和账号影响均 **`NOT_CHECKED`**。这些 v1 路由处于 `auth:sanctum` 组内；这只表明本地路由声明有身份中间件，不等于新 v10 auth/session 或 live consent 权威。

## 路由到保护点矩阵

| 本地路由（均 `/api/v1`） | 控制器 → 服务／数据动作的静态路径 | 旧判断与双证据缺口 |
| --- | --- | --- |
| `GET /messages?peer_id=…` | `MessageController::list` → `ConversationCapabilityService::canRead` → 先批量改 `ChatMessage.is_read/read_at`、`ConversationDomainService::markReadForPair`，再查询消息并用 `shapeMessage` 返回 `content` 与附件。 | `canRead` 只看会话或已释放 `DatingMatch`，缺 read-purpose CN/MC 当次来源；**读回前和已读副作用前**均无可信双输入。 |
| `POST /messages` | `MessageController::send` → 可先 `ConversationAtomicSendService::replay` 返回既有消息，经 `sendResponse/shapeMessage` 带出内容/附件；非重放再预检媒体，进入 `send()` 的 DB transaction。事务内 `authorizeSend(..., true)` 后创建/关联 `Conversation`、`ChatMessage`、附件、成员/事件，继而构造通知标题与正文。 | 重放分支在授权前；事务内授权只用 `DatingMatch`、block、synthetic 与离开成员。**提交前**无 send-purpose CN/MC 当前双证据；通知正文可取消息文本，缺该门也影响通知前边界。现有事务/行锁不等于新权威来源与原子门。 |
| `POST /messages/read/{messageId}` | `MessageController::markRead` → 先按 ID 取 `ChatMessage` 并核对 receiver，再 `canRead`，最后保存 `is_read/read_at`。 | 旧 `canRead` 可由会话或 match 成立，无 read-purpose 双证据；已读写入前缺门。 |
| `GET /conversations` | `ConversationController::index` → **先** `ConversationDomainService::listForUser`：读取会话、`summarizeConversation` 取最近 `ChatMessage`/附件、生成 `last_message` 预览、未读数，并拼接 match fallback；**后**按旧 `canRead` 过滤及附 capability。 | 私密预览和未读数**构造早于过滤**；过滤本身也没有 CN/MC。对 `peer_user_id` 为空的条目，过滤表达式直接保留，具体可出现条件 `NOT_CHECKED`。match fallback 的展示/权限分类需单独确认，不能借它放行私密会话。 |
| `GET /conversations/{conversationId}` | `ConversationController::show` → `findConversationForParticipant`/peer → 旧 `canRead` → `summarizeConversation` 返回预览、未读等。 | 成员绑定和旧 `canRead` 不是当前 read-purpose CN/MC，也不是撤销后的历史读取许可。 |
| `POST /conversations` | `ConversationController::store` → `findDirectConversation`；已有对象用旧 `canRead` 后 `summarizeConversation`，否则用旧 `canCreate` 后 `eligibleMatchForPeer` 返回候选。 | 已有对象可构造私密摘要但无双证据；新对象分支当前代码只返回候选、未见此方法创建会话行，却仍把 released match 当会话资格。是否可保留非私密候选须先分类，不得让它携带私密摘要或授权语义。 |
| `GET /conversation-peers/{peerUserId}` | `ConversationController::showPeer` → 旧 `canRead` → `findDirectConversation`，存在时 `summarizeConversation`，否则 `eligibleMatchForPeer`。 | 旧 `canRead` 可能仅因 released match 成立；存在对象的预览/未读回传前缺 read-purpose 双证据。非私密 fallback 与私密数据必须分开。 |

任务要求以外的 `GET /messages/ws/{userId}` 在同一固定路由文件中可见，但本轮没有将它作为真实 websocket gateway 审计；控制器是 `websocketStub`，默认配置分支返回 503，另一分支返回 501。其实际部署/实时推送路径仍 `NOT_CHECKED`，不从 stub 推断安全或暴露。

## 旧判断与已接受合同逐项对照

`ConversationCapabilityService::evaluate` 的 `can_read = conversation !== null || releasedMatch`，即使 block 存在仍可读；`can_create/can_send` 依赖未 block、非 syntheticDenied 与 released match。`authorizeSend` 在事务中锁最新 released `DatingMatch`，检查双向 block、synthetic 标志和已离开成员。这些是**旧代码事实**，有一定身份、opaque denial、幂等和写入一致性保护，但没有读取 Product Connection 当前权威证据、独立 Messaging Consent 当前权威证据，也没有检查 evidence 的 aggregate/context、participant、audience、read/send purpose、revision、freshness、supersession、来源可信性。`MessageApiTest` 与 `ConversationCapabilityFoundationTest` 的旧正例建立 released `DatingMatch` 即读发；后者还明确测试 block 后保留历史读取。测试证明的是旧行为预期，不能证明新双输入门。

**已接受设计**（BA-05 技术设计接受、Owner D-02/03、BE-09 审查）：在线 read 前须当次取得当前有效 `CN_ACTIVE` 和独立 read-purpose `MC_ACTIVE`；send 在提交点重新取得对应 send-purpose 双输入，不能沿用 read、旧会话、match、缓存或重放结果。来源还须绑定当前 Connection、参与者、受众、用途，满足修订/新鲜度/撤销关系；缺失、冲突、过期或不可比均 fail closed。私密列表/详情/消息/草稿/实时数据在 read 门前不得构造；撤销、pause/close/Block 后历史只读默认不可用，另立历史权威前不能由 `Conversation` 行恢复。旧 `block` 后 `can_read=true` 的测试与此新默认存在语义冲突，不能把旧测试通过当新授权。

**BE-10 已接受范围**只是纯内存预置虚构快照后的 sentinel 顺序探针，没有可信来源签发/获取、auth/session、真实内容或 writer。这里七条路由没有调用该探针；即便调用，synthetic gate true 也不能授予真实读发。`ConversationAtomicSendService` 的 DB transaction 有行锁与回滚路径，但其授权谓词仍是旧 match/capability；不能以事务存在推论 CN/MC 与消息/通知的原子提交边界已建立。

## 最小后继代码任务候选（**未派发**）

可信 CN/MC 来源签发及当次获取接口尚不存在时，保护性入口的最小安全停点是 fail closed：在任何私密摘要、未读、消息/附件读取、已读写入、重放内容响应、媒体预检、消息/事件/通知提交前拒绝或返回不泄漏存在性的统一响应；不要先构造再过滤。后继任务须明确只对上述七条 `/api/v1` 路由的私密 Conversation/Message 分支生效，保留认证/请求格式错误和其他不相关路由的既有行为；`eligible_match` 是否属可保留的非私密候选须独立划界，不能默认为历史/实时许可。不能通过切换配置、沿用 `DatingMatch`、旧会话或 BE-10 sentinel 把 deny 改为 allow。

建议后继精确影响文件：`MessageController.php`（重放、列表、已读的门前顺序）、`ConversationController.php`（列表构造前及详情/peer/store 分支）、`ConversationCapabilityService.php`（旧 canRead/canSend 不再作为新 live authority）、`ConversationAtomicSendService.php`（事务提交点及通知前 fail closed）、`ConversationDomainService.php`（避免在无门时生成 preview/unread）；`routes/api.php` 只需核对路由覆盖，是否编辑由后继审查决定。建议只在 `MessageApiTest.php`、`ConversationCapabilityFoundationTest.php` 的另发定向预算中改写/新增负例：无 CN、无 read/send MC、purpose/audience/participant/context 错配、旧 revision 或撤销、来源超时、read 后 send 前变化、重放绕门、列表过滤前私密构造、mark-read 副作用、通知与消息写入 0、旧 block 历史读取不得自动保留。后继必须说明已有客户端的会话/消息功能可能被统一拒绝的兼容风险，并给出撤回该新保护切片且不动既有无关状态的回退；绝不能以兼容性理由静默放宽双证据门。

真正恢复受保护路径还需要**独立合同和任务**：可信 CN/MC 来源签发/获取、auth/session 主体与设备绑定、操作时重取及 revocation 传播、消息与通知的原子提交/失败回退、历史内容单独访问权威及用户可见的拒绝/恢复体验。上述候选不自行决定这些来源、API、schema 或生产切换。

本轮差异仅新增本 `plan.md`；对该路径执行的 `git diff --check` 退出 0，但该命令不覆盖未跟踪新文件，作者已单独读取并哈希本交付。`NOT_RUN`：PHPUnit、Composer、Artisan、DB、SSH、云/生产 API、真实消息/媒体、备份/解密/恢复、部署、提交/pull/push。作者两轮静态预算用尽，停 Work LEVEL 3 独立 ACCEPT/REJECT，不修改真实路由、服务或测试，不启动后继。
