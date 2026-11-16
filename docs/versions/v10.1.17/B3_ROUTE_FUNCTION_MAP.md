# v10.1.17 B3 路由与功能地图

当前为 `IMPLEMENTATION_MAP`。本地图按当前源码记录四个底部入口、主要功能目的地及各自的权威来源/权限门，供顾问和 Owner 验收导航整合。它不把页面可达性当作权限，也不代替 API、运行态或 Owner 实机验证。

## 四个底部入口

| 入口 | 实现与主要功能 | 状态来源及权限边界 |
|---|---|---|
| 首页 `/home` | `apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart` 在 `ELITESYNC_V1017_LOCAL_BUILD` 下承载 `JourneyOverviewPage` 首页模式；读取聚合状态并提供一个可识别的主要下一步，同时保留 Buddy、好友社区和合成活动入口。 | `JourneyOverviewPage` 从 B2 `GET /user-state` 读取状态和服务端排序的 `next_actions`，只映射已知 action code。客户端导航不判定参与资格；Buddy、社区和活动继续走各自 API/页面权限。普通构建分支可能呈现其他 Home 实现。 |
| 进展 `/progress` | 同一 `JourneyOverviewPage` 的详细模式把慢约准备和关系旅程放在一个页面；可进入慢约详情、匹配输入、Lifestyle、自动化、连接/消息许可及正式关系。 | 聚合状态来自 `/user-state`；详细模式另外读取 `/journey`、当前 peer 的 `/connections/{peer}`、`/conversations`、`/formal-relationships`。每个域单独展示。提案、Connection、Messaging Consent、Conversation、Relationship 不合并为单一状态；操作仍由原服务端合同判定。 |
| 消息 `/messages` | `MessagesShellPage` 按运行配置呈现 `ConversationListPage` 或 `LiveConversationListPage`。本地恢复构建沿既有 Live 会话入口，typed canonical chat 路由继续服务原有消费者。通知中心为单独目的地 `/notifications`，在适用的本地恢复构建中也可从 Me 到达。 | 列表入口、通知和已读状态彼此独立。`ConversationAccessGate`、canonical route 绑定、当前账号及会话权限复核仍有效；Connection 或通知本身不会授予对话访问权。 |
| 我的 `/me` | `MeLandingPage` 把资料与偏好、隐私与账号、参与记录、自我了解工具分组；直达原有私密资料、展示资料、Lifestyle、匹配输入、隐私、设置和可选工具页面。 | 各编辑器/API仍是对应资料、偏好和隐私的权威写入入口。`/user-state` 是状态与自动化规范页面；Me 摘要或链接不代表授权。自我了解工具保持自愿，不作为匹配硬门槛。 |

底部导航由 `apps/flutter_elitesync_module/lib/app/router/app_shell.dart` 固定为首页、进展、消息、我的四项。没有新增第五个主入口。

## 独立能力与兼容路径

| 能力 | 规范入口/兼容路径 | 交互和权限约束 |
|---|---|---|
| 慢约详情与匹配 | `/progress/match`；旧 `/match` 重定向至该路径 | 资格、参与及提案决定沿用慢约服务端接口和 revision/idempotency 合同。浏览或打开提案不接受候选。 |
| 连接与消息许可 | `/progress/connection`、peer 连接详情 | Connection 与 Messaging Consent 分开读取和决定；已有合法会话仍须会话访问门复核。提案变化不会客户端自动清除已成立的连接或会话事实。 |
| 用户状态/自动化 | `/user-state` | B2 只读聚合用于状态摘要。授权、暂停、恢复和撤销走原自动化服务与明确授权流程；页面打开不提交命令。 |
| Lifestyle Discovery | `/lifestyle-discovery`，可从 Me 或相关旅程进入 | 原偏好服务和场景编辑器负责读写、revision及保存；修改已有偏好不要求重填其他场景。 |
| Buddy | `/buddy-v1013` | 与恋爱匹配参与及状态独立；联系前继续要求对应双方同意。旧 `/buddy` 继续 fail closed。 |
| 好友社区 | `/status/square`、作者页 `/status/author/:userId` | 保留好友范围、作者身份和内容权限校验；这是有限社区场景，不变为无限陌生人 Feed。发布对象与受众仍需用户明确选择。 |
| 通知 | `/notifications` | 通知与聊天分别呈现及处理已读。由通知打开的聊天仍重新验证当前 conversation 与访问权限。 |
| 资料别名 | 旧 `/profile` 重定向至 `/me`；`/me/private-identity` 与 `/me/showcase` 保留 | 别名只兼容导航，不改变私密资料与展示资料之间的授权边界。 |

## 账号切换、失败和未知状态

Journey Overview 复用 `SessionBoundPage`，并在页面离开、后台及会话变化时使旧请求失效；读取前后核对当前 session。读取失败、未授权或返回不完整时应呈现“暂未确认/请刷新”，不得改写成“无关系”“已完成”或授予动作。Progress 补充读取 `/journey` 等来源时，如果某来源不可用，其他状态仍各自标记来源与未确认状态。

## 验收边界

相关源码如下。

- `apps/flutter_elitesync_module/lib/features/journey_integration/journey_overview_page.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_router.dart`
- `apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
- `apps/flutter_elitesync_module/lib/features/chat/presentation/widgets/conversation_access_gate.dart`
- `services/backend-laravel/routes/api.php`

本文件是实现导航与合同地图，不单独证明所有路由均已运行、设备行为已通过、测试已通过或 Owner 已验收。Owner 整体实机检查安排在 B1+B2+B3 完成后，见 [Owner 实机检查表](OWNER_DEVICE_CHECKLIST.md)。
