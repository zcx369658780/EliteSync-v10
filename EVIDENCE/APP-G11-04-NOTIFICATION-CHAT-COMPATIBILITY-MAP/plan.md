# APP-G11-04｜通知名称与 Chat 身份兼容边界映射（作者候选）

状态：docs-only 候选，待 Work 独立 LEVEL 2 审查。实时仓库 `D:\EliteSync-v10`，本地 `main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`。下文只描述当前本地代码与已接受局部审查，不将路由或人工夹具当作真实权限。

## 两轮静态预算

1. **第 1 轮（1/2）**：只读根 `AGENTS.md`、`CURRENT.md`、`PRODUCT_DECISIONS.md`、`TASK_CURRENT.md`、`REVIEW_GATE.md`、本地 `elitesync-local-workflow`，APP-G11-01～03 的 `work-review.md`，以及 APP-T12 重审结果的 G-11。结论：APP-T12 的 G-11 仍是 `COMPATIBILITY DEBT / NO`，覆盖 Match 路由别名、通知 payload 名称、Chat 身份及更低层混合债；APP-G11-01 的首跑失败与 REJECT 保留，APP-G11-02 已限定接受 Match 别名 readiness 守卫，APP-G11-03 已限定接受人工通知 `chat_room` 的已存会话身份绑定。参考 `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md:35-37,99-111` 和三份独立审查。本轮未重用任何旧测试预算。
2. **第 2 轮（2/2）**：先用当前仓库的 codebase-memory 图谱定位 `ChatRouteState`、`ConversationDto`、`chatRouteStateFromPath`、`NotificationCenterPage`；图谱只能定位符号，随后回退到任务固定的当前文件与直接定义/定向测试作逐行核对。直接来源包括通知实体/页面、全局 router、Chat route state/DTO/列表/房间、其直接 provider 定义，以及 `test/app/router/chat_route_state_router_test.dart` 和通知页面测试。发现见下文。未运行测试、构建或运行时命令。

## 通知名称与参数：当前位置，不是投递权威

`NotificationItemEntity.fromJson` 从 `payload.route_args` 取参数，`route_name` 优先取顶层、再取 `payload.route_name`；缺失变为空字符串。原始 `title`、`body`、`payload` 仍在实体中，但不能因此视为可信路由身份或可显示私密内容（`notification_item_entity.dart:40-55`）。通知页对 `routeName` 做 trim，按固定字面量分支；成功打开才经 `_openAndMarkRead` 自动标记已读（`notification_center_page.dart:96-102,206-223`）。

| `routeName` 当前分支 | 实际使用的身份或目标 | 当前边界 |
| --- | --- | --- |
| 空值 | 无 | 仅提供手动标记已读，自动打开返回 false（通知页 97-100、218-223）。 |
| `chat_room` | `routeArgs.conversation_id` 的正整数 | 经 `conversationDetailProvider(id)` 解析，要求 `entryKind == stored_conversation`、返回正 `conversationId == id` 和正 `peerUserId` 才建 stored 路由；失败安全提示、不导航、不自动标记已读（102-143）。这是 APP-G11-03 已接受局部修复，不是新缺口。 |
| `status_author` | 不读取 `user_id`、name 或其它 payload 身份 | 固定安全提示并返回 false（144-147）；APP-T12-B01 与 APP-G11-03 审查保留此失败关闭。 |
| `match_detail`、`match_result`、`match_intention` | 不用通知参数，统一去 `progressMatch` | 页面分支 148-153；全局 router 的六个历史 Match URL 与 canonical 路径 readiness 守卫已由 APP-G11-02 限定接受（`app_router.dart:88-98,163-182`）。这不证明真实 readiness 来源。 |
| `questionnaire_history`、`settings`、`social_baseline` | 固定本地目标 | 分别 go/push 固定路由（154-157、194-200）。 |
| `content_detail` | `routeArgs.content_id` 非空字符串 | 直接拼接内容目标；缺失则提示并返回 false（158-166）。内容受众权限不由参数证明。 |
| `rtc_call` | `routeArgs.call_id` 正整数；kind 决定来电/结果/普通通话页；title 来自参数或通知 title | 这是当前兼容分流（167-193），不在本次 Chat/通知权威审定范围。 |
| 其它字面量 | 无 | 安全提示并返回 false（202-204）；定向测试含 `legacy_unknown`。 |

这里列的是**当前消费者认可的名称**；没有固定来源证明历史生产 payload 的完整名称清单、生成者、OS 交付保证或受众绑定。G-11 的通知 payload 名称及较低层混合债仍保留；APP-T12 G-13 对通知后端/OS 权威仍为 `NO`。不能因页面已有某个分支就宣布该兼容债整体结清。

## Chat 直接路由与身份分类

- 全局 router 的 `/chat/:chatIdentity` 先调用 `chatRouteStateFromPath(segment, extra)`；只有 typed `ChatRouteState` 的 `canonicalSegment` 与 path 完全一致才直接使用。纯正整数 path 可退化为 `legacyPeer`；未匹配的 `conversation-<正整数>` 会进入 `_StoredConversationRoutePage`；其它地址进无效页（`app_router.dart:193-213,485-505,549-555`）。`chat_route_state_router_test.dart:60-92` 只覆盖 typed 匹配、整数 legacy 与 segment 解析，不证明后续详情绑定或真实权限。
- `ChatRouteState` 构造器保持三类结构约束：stored 需要正 conversation ID；eligible match 需要正 match ID 且无 conversation ID；legacy peer 无两种 ID。`canonicalSegment` 对前者是 `conversation-<id>`，后两者是 `peer-<id>`；`grantsConversationReadOrSendAuthority` 恒为 false（`chat_route_state.dart:3-53,56-90,125-151`）。这些是身份形状，不是 consent、读取或发送授权。
- 列表的 `_openConversation` 使用 `ChatRouteState.fromConversation` 并传 typed extra（`conversation_list_page.dart:73-83`）。此转换优先用 `peerUserId`，否则尝试把 `ConversationEntity.id` 解析为 peer；任何非空 `conversationId` 都构造 stored，即使 `entryKind` 不明确；`eligible_match` 且有 match ID 才构造 eligible，其余退为 legacy（`chat_route_state.dart:92-123`）。`ConversationDto.fromJson` 读取 `entry_kind` 和正 `conversation_id`，但 `peer_user_id` 缺失时可从 `id` 退化解析（`conversation_dto.dart:23-35`）。这仍是混合身份兼容债，不能由列表项形状推断已存会话或权限。
- Chat 列表与房间都使用本地 `conversationAccessProvider`/`ConversationAccessGate`（`conversation_list_page.dart:26-40`，`chat_room_page.dart:44-67`）；房间读取请求和发送目标依赖 route state 的 peer ID（`chat_room_page.dart:109-117,273-281`；`chat_providers.dart:53-58,83-115`）。这是本地访问门与调用接线，尚无同一 actor/audience 的真实 `CN_ACTIVE`、独立 `MC_ACTIVE` 和 send 时重查证明。`PRODUCT_DECISIONS.md:10,19-26` 与 APP-T12 G-06/G-07 保留这些权威/数据权利门。
- **明确剩余局部边界**：无 typed extra 的 `conversation-<id>` 直达路径先看本地 access gate，再查询详情；详情检查仅拒绝 peer ID 缺失/非正及**非空而不同**的 conversation ID，随后使用 URL ID 构造 stored 路由（`app_router.dart:507-545`）。若详情缺失 conversation ID 或返回 `legacy_peer`/`eligible_match`/unknown kind 且 ID 相同，当前代码仍可能把该 URL 形状提升为 stored 身份。APP-G11-03 修的是通知入口，不覆盖此直达路径。typed extra 的接受分支也仅验证路径与 state 形状相符；它本身不做真实权威核验。

## 建议给 Work 的唯一后继切片（尚未发布）

**建议：无 typed extra 的 stored Chat 直达路径做详情身份绑定。** 输入限定本地人工 `/chat/conversation-41` 及 override 的详情/访问状态；候选允许文件建议仅 `apps/flutter_elitesync_module/lib/app/router/app_router.dart` 与 `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart`。在 `_StoredConversationRoutePage` 只对明确 `entryKind == stored_conversation`、返回正 conversation ID 与 URL ID 相同、正 peer ID 的详情构造 stored state；其余显示现有安全失败页，不展示私密文案，不产生消息读取/发送尝试。定向负例至少缺失 ID、不同 ID、非 stored kind（legacy/eligible/unknown），并保留正例和 access 未建立时不查询详情的检查。候选前应由 Work 固定实际测试夹具和一次性预算；本计划不授权改代码或执行测试。

该切片最多证明本地直达 URL 在人工详情下不补造 stored 身份。真实 Conversation read/send、通知生成/投递、actor/audience 绑定、产品层 legacy 退休策略和 G-11 其余兼容债继续 `NOT_READY`；APP-T12 G-08、AUTH-170、AUTH-155 Phase B、账号与恢复门不变。若后继要处理列表 DTO 混合身份或 typed extra，需各自明确来源与独立任务，不能从本建议扩展。

## 交付边界

唯一写入本 `plan.md`；两轮静态预算 2/2，测试/构建/网络/设备/DB 0。未自验收、未发布后继、未提交/pull/push。保留全部既有 dirty/untracked 与旧任务预算。
