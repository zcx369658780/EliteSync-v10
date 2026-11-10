# APP-G11-10｜Conversation 响应身份来源静态映射（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；既有 dirty/untracked 保留。没有运行测试、构建或网络调用。

## 两轮来源与入口边界

1. 第一轮：用本仓已索引代码图谱定位，并以当前文件正文核对 `services/backend-laravel/routes/api.php:81,126-133`、`app/Http/Controllers/Api/V1/ConversationController.php:13-29,63-77`、`app/Services/ConversationDomainService.php:125-217`，以及 Flutter 的 `chat_remote_data_source.dart:51-98`、`conversation_dto.dart:23-59`、`chat_mapper.dart:12-23`、`chat_route_state.dart:92-135`。图谱只用于定位，结论取自文件正文。
2. 第二轮：沿第一轮直接调用者和定向测试，核对 `DenyUnverifiedMessagingLiveAccess.php:11-16`、`ConversationCapabilityService.php:60-92`、`ConversationCapabilityFoundationTest.php:108-174`、`chat_repository_impl.dart:21-26`、`chat_providers.dart:47-81`、`conversation_list_page.dart:72-84`，并核对 APP-G11-08/09 的 Work review。一次搜索输出被截断，已在同一轮对定位文件定点读取；未开启第三轮。`rg` 用于代码/文档字符串和文件定位。

两条 GET 路由在 `auth:sanctum` 组内，且都挂 `DenyUnverifiedMessagingLiveAccess`。该中间件当前直接返回 404，不调用 `$next`。下表的控制器和服务行为均是**被当前 live 门阻断的静态潜在路径**，不是当前真实 GET 成功或授权证明。旧 `ConversationCapabilityFoundationTest` 中 `assertOk` 与字段断言是代码中的测试期望，本任务未执行；不能据此覆盖当前路由门。

本轮关键输入文件 SHA-256（仓库相对路径）：

| 文件 | SHA-256 |
| --- | --- |
| `services/backend-laravel/routes/api.php` | `6E1769E4728F8E1E703EDD432457CCD6F608E24AD7ABAA14892CA13FD15A0675` |
| `services/backend-laravel/app/Http/Middleware/DenyUnverifiedMessagingLiveAccess.php` | `A1AF329F4A5E4B9326AE92235BD8D974E373B004045B512E9E084C7B9414552D` |
| `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php` | `E302A5DDFF313C8B56BE4D5A444AF26446B4B9DAE4EF9FC7210E4EB780D99678` |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `70B071A91C130C70194982F873E21C478E1BA6EBE17069C69BC03FBE8F635588` |
| `services/backend-laravel/app/Services/ConversationCapabilityService.php` | `60916527E110104038713B5F1E15489D7AC2EDCB7F36424232690F1D88B7209A` |
| `apps/flutter_elitesync_module/lib/features/chat/data/datasource/chat_remote_data_source.dart` | `00DA3C0A8F4D8460D2139057425255C6FAE7245BEA992FB41B1A6C261D4BA9A4` |
| `apps/flutter_elitesync_module/lib/features/chat/data/dto/conversation_dto.dart` | `CA6501FBAF63CBB9598F3C103E562E3D80F4161A4EADAE18C88EF79A01B7B8AE` |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `6433BB886773453D049C6A1F8A78D1CECC54011A90AD7CE31C772B14B90D91EA` |

## 响应字段到 Flutter 消费

| 路径 | Laravel 静态来源：`entry_kind` / `conversation_id` / `id` / `peer_user_id` | Flutter 解析及列表路由结果 |
| --- | --- | --- |
| stored 列表或详情 | `summarizeConversation` 发 `'conversation'` / 正的会话主键 / peer ID 字符串，若无 peer 则 room key 字符串 / peer 用户 ID 或 null（`ConversationDomainService.php:145-182`）。`GET /{conversationId}` 由参与者及正 peer、`canRead` 检查后包装在 `conversation` 内（`ConversationController.php:63-77`）。 | DTO 原样保留非空类别，正数化 `conversation_id`；因为类别**不是** `'stored_conversation'`，只有 `peer_user_id` 缺失时才可能从数字 `id` 回填（`conversation_dto.dart:23-38`）。`ChatRouteState.fromConversation` 对非 stored 但带正 `conversationId` 抛错，列表点击显示暂不可打开且不导航（`chat_route_state.dart:92-124`; `conversation_list_page.dart:72-84`）。因此当前后端 stored 响应与 Flutter stored 类别合同不一致。详情 datasource 只检查请求会话 ID 与解析 ID 一致、peer 为正；它本身不检查类别（`chat_remote_data_source.dart:69-98`）。 |
| eligible Match fallback | `fallbackFromMatches` 发 `'eligible_match'` / null / peer ID 字符串 / peer ID；另有 `match_id`（`ConversationDomainService.php:185-217`）。`listForUser` 先收 stored，再按正 peer 去掉同 peer eligible 并拼接（`:125-143`）。 | DTO 取显式正 peer；若字段缺失且 `id` 为正数字，则回填 peer。非 stored 且无会话 ID、类别为 `'eligible_match'` 且 `matchId` 正，列表路由构成 eligible Match；缺 `matchId` 则落入 legacy peer 分支（`chat_route_state.dart:92-135`）。回退解析不构成 Match/Conversation 权威。 |
| legacy/无明确类别的客户端输入 | 上述两个 Laravel 生产者没有输出 `legacyPeer` 类别；这是 Flutter 保留的兼容输入路径，不能归为独立的服务器响应。 | `entry_kind` 缺失/其它值、无正 `conversation_id` 时，DTO 可从显式 peer 或数字 `id` 取正 peer；路由最后构成 legacy peer，正 peer 缺失/无效则抛错（`conversation_dto.dart:23-38`; `chat_route_state.dart:92-135`）。若未知类别却带正会话 ID，则抛错，不升级为 stored。 |

`ChatRemoteDataSource.getConversations` 从成功响应的 `items` 数组逐项转 DTO；`getConversation` 从 `conversation` 对象转 DTO并核对请求会话 ID 与 peer。`ChatMapper` 将这些身份字段原样传给 `ConversationEntity`，repository/use case/provider 再交给列表；列表点击使用 `ChatRouteState.fromConversation`。provider 的 `conversationAccessProvider.canRevealPrivateContent` 是本地 UI 前置条件，不能替代服务器权限或当前 live 门。

## 空 peer、冲突与权限限度

- `ConversationController::index` 的过滤是 `empty(peer_user_id) || canRead(...)`（`:16-20`）。所以缺失、null、0 等 empty peer 项**通过该过滤**，且 map 时不会附加 `conversation_capability`；是否实际产生此类行取决于未验证的数据。`summarizeConversation` 找不到其它成员时还会退到 viewer 成员，不能把该回退当成真实对端身份。`show` 的缺 peer 路径则返回 404（`:65-70`）。
- 有 peer 时，控制器调用 `canRead`；服务的静态 `canRead` 由已有直接会话或 released Match 决定（`ConversationCapabilityService.php:60-92`）。这不是当前可信 CN/MC live source。响应字段、`conversation_capability`、Flutter 路由 identity 以及本地人工测试均不能建立真实 read/send、actor/audience 或 consent 权限。
- `conversation_id` 是会话主键，`id` 在上述输出中通常是 peer 字符串，两者不可互换。DTO 将无效/非正 `conversation_id`、`peer_user_id` 转为 null；显式 `'stored_conversation'` 的 peer 不从旧数字 `id` 补造（APP-G11-08 限定接受）。APP-G11-09 仅证明人工 stored 缺 peer 列表项点击失败关闭，未证明当前 Laravel 响应可用。

## 建议的一张后继切片（未获授权）

建议 Work 单独下达**本地人工 Conversation 响应合同对齐**：限定 Laravel 列表/详情 stored 投影与 Flutter DTO/路由消费，统一 stored 类别字面量，并让列表空/无效 peer 在返回前失败关闭；保留 eligible Match 的独立类别、null 会话 ID 和显式 peer。用不涉及真实数据的定向负例覆盖空 peer、数字旧 `id`、类别与会话 ID 冲突，以及 stored/eligible 正例；先核对当前 live 404 门，测试夹具不能把旧 `assertOk` 误报为真实权限。范围、允许文件和新测试预算须由 Work 另行发布。

`NOT_FIXED`：本任务未修响应类别、空 peer 过滤、旧测试期望或真实权限；未验证真实数据是否含空 peer，也未证明后继改动在运行时可达。G-11 其它债、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门均未改变。停在 Work 独立 LEVEL 2 审查。
