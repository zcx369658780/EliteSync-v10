# APP-G11-17｜G-11 剩余兼容债当前代码复核（候选）

状态：Codex docs-only 候选，待 Work 独立 LEVEL 2 ACCEPT/REJECT。本地仓库 `D:\EliteSync-v10`，`main` HEAD `cf8bfaa4a03b8c9a682105617b185141904413be`；全部既有 dirty/untracked 保留。仅新增本文件；没有运行测试、构建、设备、网络、DB 或生产命令。

## 两轮来源与证据层级

1. **第一轮（1/2）**：读取 `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md:99-120` 的 G-11、APP-G11-04 接受映射，以及 APP-G11-01～16 各自 `work-review.md` 的独立结论。原 G-11 为 `COMPATIBILITY DEBT / NO`，列出 Match 路由别名、通知 payload 名称、Chat 身份和下层混合旧债；此分类未被局部修复自动改写。APP-G11-01 首跑失败/REJECT 保留，02 对六个 Match 别名守卫限定 ACCEPT；03 对人工 `chat_room` 通知的 stored 身份绑定限定 ACCEPT；04 仅接受静态映射；05～09 分别局部接受无 typed extra 的 stored 直达、stored 列表类别/ID、页面矛盾负例、stored peer 显式来源与页面负例。10 仅接受静态来源映射；11 因迁移阶段 MariaDB 连接失败而 REJECT 为已验证完成，12 在**新预算**内接受固定 stored 类别候选的人工内存 SQLite 验证；13～14 分别限定接受列表正 peer/`canRead` 过滤与摘要不把查看者补为 peer；15～16 分别限定接受 eligible 缺失/非正 match ID 的本地失败关闭与列表点击回归。各结论均不建立真实数据兼容或权限。
2. **第二轮（2/2）**：只读当前 `app_router.dart:193-213,485-555`、`chat_route_state.dart:92-145`、`chat_route_state_router_test.dart:241-265`、通知实体/页面及定向测试、Laravel 通知/Conversation 控制器与服务、Flutter Conversation DTO/datasource/list/provider、`routes/api.php` 和 `DenyUnverifiedMessagingLiveAccess.php` 的直接代码段。使用本仓 `rg` 定位字符串与调用点，再以文件正文核对；未把 APP-G11-04 的历史计划文字当作现状，也未开启第三轮或重用旧预算。

当前第二轮关键文件 SHA-256（仓库相对路径）：

| 文件 | SHA-256 |
| --- | --- |
| `docs/architecture/ELITESYNC_V10_APP_T12_MVP_INTEGRATION_ACCEPTANCE_RERUN_RESULT_V0_1.md` | `F2127D3420D06DB466752DA6187F4F21D85A0996E080561B681A096E36C301A8` |
| `apps/flutter_elitesync_module/lib/app/router/app_router.dart` | `88659FA22A70432031594AA660171A4AC253B11C301FFF4B7FBADFE866FA0F81` |
| `apps/flutter_elitesync_module/test/app/router/chat_route_state_router_test.dart` | `E8B4608B87D233E4F8B80C13D6B259F041A86698ED2D6106D9072360674BA8D9` |
| `apps/flutter_elitesync_module/lib/features/chat/domain/entities/chat_route_state.dart` | `8E764F99E20BC5A5E0A878F014D28FADC5E225112A715A9AAAC3588883233758` |
| `apps/flutter_elitesync_module/lib/features/chat/data/dto/conversation_dto.dart` | `CA6501FBAF63CBB9598F3C103E562E3D80F4161A4EADAE18C88EF79A01B7B8AE` |
| `services/backend-laravel/app/Http/Controllers/Api/V1/ConversationController.php` | `8E051D29E99C8BBC7D2ED13463E614944CCFD4860198DB14B6A5158BFA9F40BC` |
| `services/backend-laravel/app/Services/ConversationDomainService.php` | `0062AE186BDC6701F387947AD13AC6644ACC4CB1D883ADA3B4862A66CBAB68E6` |
| `apps/flutter_elitesync_module/lib/features/notification/domain/entities/notification_item_entity.dart` | `CD5699822AC066A2E0F93CFA170A2A2366127785B83AC6892F1CFD706DFBF872` |
| `apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart` | `EF06A8D40544338DB51C3DC3EDB1CD208D7D1FA54BFE703F1F722640869E69CE` |
| `services/backend-laravel/app/Http/Controllers/Api/V1/NotificationController.php` | `1B71C21C116949302AE5F761EC60F4BB45F76FC85D9A46D6DB2D34C1720B4469` |

## 已局部修复与当前剩余边界

- **Match 别名**：APP-G11-02 已接受六个精确旧路径的本地 readiness guard；APP-G11-01 原失败不重写。不能由导航测试推断真实 readiness 来源或所有历史客户端路径已枚举。
- **通知 Chat / 直达身份**：通知页 `chat_room` 只在正 `conversation_id` 解析成同一 stored 会话、正 peer 后导航（`notification_center_page.dart:97-143`）；无 typed extra 的 `conversation-<id>` 直达也核对详情类别/ID/peer（`app_router.dart:507-548`）。两者各受 APP-G11-03/05 的人工限定接受。当前 `conversationDetailProvider` 有本地 access 前置（`chat_providers.dart:49-60`），Laravel Conversation 路由仍挂直接 404 的 live middleware（`routes/api.php:121-133`）；这些身份检查不是 consent/read/send 权威。
- **列表/详情身份**：Laravel stored 摘要发 `stored_conversation` 与正会话 ID，只选当前非查看者且未离开的 peer；eligible 发 `eligible_match`、null 会话 ID、正 peer 与 match ID（`ConversationDomainService.php:125-217`）。列表控制器仅保留显式正整数 peer 且 `canRead` 为真，并附 capability；show 要求参与者、正 peer 与 `canRead`（`ConversationController.php:13-29,63-79`）。Flutter DTO/route state 对明确 stored 要求显式正 peer/会话 ID，对明确 eligible 要求正 match ID，列表点击 `ArgumentError` 显示安全提示（`conversation_dto.dart:23-38`；`chat_route_state.dart:92-145`；`conversation_list_page.dart:73-84`）。APP-G11-11/12～16 仅在静态或人工测试层分别接受这些局部边界。无明确类别的数字旧 peer fallback 仍按既有兼容规则保留；没有来源证明可退休。
- **通知 payload 名称仍未闭合**：当前 Laravel `NotificationController::shapeNotification` 把 payload 的 `route_name`/`route_args` 投到顶层（`:15-35`）；Flutter 实体优先顶层 `route_name`，其次 payload，参数取 payload 内的 `route_args`（`notification_item_entity.dart:40-55`）。通知页只识别 `chat_room`、`status_author`、三个 Match 名称及固定内容/RTC/设置等名称，未知名称失败提示（`notification_center_page.dart:97-204`）。现有 `NotificationApiTest` 是人工 payload 样例，不能充当历史/真实生产者完整名称清单；没有证据据此宣称 G-11 的名称兼容债结清，也不能擅自新增别名或放行私密入口。OS 交付/受众绑定另属 G-13 等权威缺口。
- **当前可证的另一处本地身份降级候选**：`chatRouteStateFromPath` 仅在 typed `ChatRouteState.canonicalSegment == segment` 时返回它；若不等，继续尝试把**数字路径**解析成 `legacyPeer`（`app_router.dart:485-505`）。因此人工输入如 `segment='23'` 且 `extra=stored(conversationId:41, peerUserId:23)` 可丢弃不匹配的 typed 身份而得到 legacy peer，页面路由随即构建 `ChatRoomPage`（`app_router.dart:193-213`）。现有 `chat_route_state_router_test.dart:241-265` 覆盖 typed 匹配、非数字的 typed 不匹配和无 typed 的数字旧 peer，却未覆盖**typed 不匹配 + 数字路径**。这是静态推导的本地兼容候选缺口，尚非实测真实权限突破；Chat 页面仍有本地 access gate，live 后端 404 不变。

## 唯一后继建议（尚未授权）

建议 Work 另立**typed Chat 路由身份不匹配失败关闭**的一张本地软件切片：只针对 `chatRouteStateFromPath` 在 `extra is ChatRouteState` 且 `canonicalSegment != segment` 时拒绝转换，保留 canonical 匹配和**没有 typed extra** 的数字旧 peer fallback。候选范围可限 `app_router.dart` 与 `chat_route_state_router_test.dart`，用人工负例覆盖 stored/eligible typed extra 配数字路径、其它不匹配路径，并保留上述正例；如需要 widget 回归，须由 Work 明列文件和独立预算。先审查是否有真实调用者依赖“丢弃不匹配 typed extra 后走旧数字路径”的行为；本计划不推断其存在或不存在，也不授权改代码。该切片不重做 APP-G11-01～16，且不涉及通知 payload 生产或真实数据。

`NOT_FIXED / NOT_PROVED`：G-11 的历史通知名称全集、下层 legacy 退休条件及真实客户端兼容仍未建立；真实 actor/audience、CN/MC、Conversation read/send、通知生成/OS 交付、产品层数据权利不由人工测试证明。APP-T12 G-11 仍为 `NO`；live 404、G-08、AUTH-170、AUTH-155 Phase B、CMS 认证、隔离恢复及账号回填门未改变。本任务两轮预算 2/2 耗尽，停止于 Work 独立 LEVEL 2 审查。
