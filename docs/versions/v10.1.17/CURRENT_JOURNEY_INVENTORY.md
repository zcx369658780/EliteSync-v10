# v10.1.17 当前旅程入口与权限盘点

状态：`SOURCE_INVENTORY_ONLY`。本文件记录现有源码中的入口、重复路径、状态来源与权限门，供B3操作成本基线及目标信息架构使用。它不是九项旅程的操作成本测量，也不表示B3功能已实现、测试已通过或运行态已验收。

## 1. 四个主入口与路由骨架

`apps/flutter_elitesync_module/lib/app/router/app_shell.dart:140-185,277-292` 将底部导航固定为首页、进展、消息、我的四项；shell分别显示对应导航分支页面。`app/router/app_router.dart:470-555` 以四个 `StatefulShellBranch` 注册 `/home`、`/progress`、`/messages`、`/me` 及次级入口。未见第五个底部入口。

全局路由守卫位于 `app/router/app_router.dart:82-120`：启动初始化时回到Splash；除Splash、登录、注册和受限开发fixture外要求登录。匹配相关入口在通常构建下会因Readiness未建立而转到 `/me/readiness`。兼容别名 `/match` 转 `/progress/match`、`/profile` 转 `/me`（`app_router.dart:462-468`）。

| 目标 | 当前入口或路径 | 当前页面/保护 |
|---|---|---|
| 首页 | `/home` | 由Home分支承载；页面内部成本与状态展示需在另行的基线审计中记录。 |
| 进展 | `/progress`、`/progress/match`、`/progress/connection` | 连接路径在 `restorationLocalBuild` 下进入 `LiveConnectionPage`，其他构建进入 `ConnectionPage`；匹配路径在本地恢复构建下进入 `SlowDatingJourneyPage`，其他构建进入Match shell（`app_router.dart:482-500`）。 |
| 消息 | `/messages`、`/messages/chat/:chatIdentity` | 消息列表按本地恢复构建选择常规或Live实现；会话经typed canonical route状态解析，并由会话访问门再次判权（`app_shell.dart:277-285`、`app_router.dart:243-264`）。 |
| 我的 | `/me` 及其private-identity、matching-inputs、readiness、showcase、privacy-settings子路由 | 页面由Me shell承载；可选入口组受 `restorationLocalBuild` 条件影响（`app_shell.dart:287-292`、`features/me/presentation/pages/me_landing_page.dart:44-183`）。 |

## 2. Journey、准备与偏好的重复入口

- 慢约旅程至少可从 `/progress/match` 的本地恢复分支和 `/me/readiness` 到达：前者路由在 `app_router.dart:489-492` 指向 `SlowDatingJourneyPage`；后者进入 `ReadinessPurposePage`，该wrapper目前直接返回同一旅程页（`app_router.dart:529-541`、`features/me/presentation/pages/me_purpose_pages.dart:24-33`）。因此这是同一整页的两个到达入口，非两套参与状态。
- `MeLandingPage` 将“匹配输入”指向 `/me/matching-inputs`；`MatchingInputsPurposePage`直接承载 `MatchingInputPage`。Journey页面自身也有“我的匹配输入”入口，进入相同 `MatchingInputPage`（`features/me/presentation/pages/me_landing_page.dart:58-64`、`features/me/presentation/pages/me_purpose_pages.dart:21-23`、`features/slow_dating_v1012/slow_dating_journey_page.dart:88-109`）。目前是重复导航入口，共用同一输入页；并非源码证据所示的重复表单。
- Lifestyle Discovery可由Me入口、Journey页提示入口和直接路由 `/lifestyle-discovery` 打开（`me_landing_page.dart:65-71`、`slow_dating_journey_page.dart:126-158`、`app_router.dart:127-130`）。完成状态会进入偏好摘要；摘要各维度可返回相应场景编辑，再回摘要（`features/lifestyle_discovery/lifestyle_page.dart:108-114,410-441`）。这提供修改能力，但具体导航/输入操作数须在九项成本基线中实测记录。
- `SlowDatingJourneyPage` 当前还承载参与、轮次、提案摘要，以及状态与自动化、匹配历史、问卷、Buddy、社区等次级入口。来源见 `features/slow_dating_v1012/slow_dating_journey_page.dart:80-158,164-285`。状态/自动化亦可从Me的状态条目打开 `/user-state`；这是当前可见的入口重复项之一（`me_landing_page.dart:73-77`）。

## 3. 通知、Buddy、社区与特色工具

- 通知中心有独立路由 `/notifications`（`app_router.dart:273-276`），Me landing仅在 `restorationLocalBuild` 中提供“站内通知”入口（`me_landing_page.dart:112-128`）。通知跳转按routeName与受控kind分派；chat通知需重新读取并验证当前conversation后才打开，受控Buddy/社区内容也需当前身份及权限核验（`features/notification/presentation/pages/notification_center_page.dart:271-280,402-560`）。
- Buddy V1013页面路径为 `/buddy-v1013`（`app_router.dart:131-134`）；旧常量 `/buddy` 未注册且已有fail-closed路由测试（`app/router/app_route_names.dart:34-38`、`test/app/router/buddy_route_exclusion_test.dart:77-110`）。Buddy也从慢约旅程、受控通知等路径可达；Buddy自身受众与报名不属于恋爱匹配参与状态。
- Community的根路由为 `/status/square`，作者页为 `/status/author/:userId`（`app_router.dart:267-271,337-344`）；Me动态广场入口受本地恢复构建门控制（`me_landing_page.dart:130-140`）；慢约旅程亦提供社区入口。入口可重复，但权限仍由对应社区页面/API控制。
- Me本地恢复构建下另显示MBTI、三盘本命、动态星盘与关系盘、已存八字等“自我了解工具”组（`me_landing_page.dart:143-173`）。这些是可选工具路径，不构成匹配参与或Readiness门槛。旧 `/profile` 根路径转至Me，但独立的 `/profile/mbti`、`/profile/astro...`等工具路由仍存在（`app_router.dart:449-468`）。

## 4. 状态权威来源

| 状态域 | 可核验的当前来源 | 展示边界 |
|---|---|---|
| 聚合本人状态及下一步 | `GET /api/v1/user-state`：在 `routes/api.php:76-85` 注册至 `UserAutomationController::state`；服务 `UserStateService::read` 返回 `user_state_v1`、`domains` 与 `next_actions`（`app/Http/Controllers/Api/V1/UserAutomationController.php:10-16`、`app/Services/UserStateService.php:11-61`）。Flutter `UserStatePage` 读取 `/user-state` 并拆分domain卡片（`features/user_automation/user_state_page.dart:15-18,69-75`）。 | 聚合API适合作为统一状态摘要和下一步来源；不把客户端摘要、路由守卫或本地演示状态提升成服务端权限判定。 |
| 隐私与资料受众 | `PrivacySettingsPage`本身明确标注按用途展示现存控制及未建立能力；具体资料受众/本人预览由其子页`RelationshipPrivacyPage`读取`/privacy`并提交对应命令（`features/profile/presentation/pages/privacy_settings_page.dart:15-20,30-47`、`features/slow_dating_v1012/relationship_privacy_page.dart:9-31,120-157`）。聚合状态中的privacy域来自服务端 `privacy_preferences` 修订（`app/Services/UserStateService.php:19-22,52-55`）。 | 隐私摘要不证明导出、删除、撤回等全部控制可用；逐用途控制仍由所属页面/API执行。 |
| Lifestyle偏好 | `GET/PUT /profile/lifestyle-discovery`，服务端端点使用当前用户及私有响应中间件（`routes/api.php:88-89`）；前端完成/答案/摘要读取 `LifestyleDiscoveryPage`控制器与provider（`features/lifestyle_discovery/lifestyle_page.dart:11-18,108-114`）。 | 展示衍生偏好摘要，不公开原始答案；修改走既有场景选项和保存命令。 |
| 匹配输入 | `GET/PUT /matching-inputs`（`routes/api.php:153-156`）；Flutter `MatchingInputPage.resource`为 `/matching-inputs`，从API读当前修订并在保存时提交revision及confirm（`features/slow_dating_v1012/matching_input_page.dart:29-36,83-118`）。 | 页面就绪/已确认文案是服务端投影；是否参与仍须单独行动。 |
| 慢约参与、轮次、提案 | `GET /journey`、`PUT /journey/participation`、提案decision等路由（`routes/api.php:153-164`）；`SlowDatingJourneyPage.resource`为 `/journey`，页面根据返回的participation/readiness/round/proposal分别呈现（`features/slow_dating_v1012/slow_dating_journey_page.dart:36-42,68-78,164-285`）。 | ACTIVE/暂停、匹配轮次和提案是不同业务状态；参与与提案决定不由聚合摘要推断。 |
| Connection与消息同意 | `LiveConnectionPage`先读取当前匹配，再按已确认peer读取 `/api/v1/connections/{peer}`；后续动作带expected revision/对象ID并重新读取确认（`features/connection/presentation/pages/live_connection_page.dart:62-109,120-141`）。响应分开校验`connection`与`consent`，页面分别渲染（`:98-109,293-303`）。 | Connection、Messaging Consent和Conversation彼此独立。进入聊天还需服务端当前gate允许。 |
| Conversation内容 | `ConversationAccessGate`根据当前 `ConversationAccessSnapshot` 决定可见内容/操作（`features/chat/presentation/widgets/conversation_access_gate.dart:5+`）；列表进入的会话由canonical route与权威detail复核（`app_router.dart:243-264,573-617`）。 | 不以已有Connection、缓存或通知route替代会话访问权限。 |

## 5. 身份、授权与权限门

- Flutter全局router对非公开页面要求登录；后端本人状态接口位于 `auth:sanctum`、`account.active`、`JourneyPrivateResponse`组（`app_router.dart:88-97`、`services/backend-laravel/routes/api.php:76-89`）。
- Journey/隐私类页面复用 `SessionBoundPage`：身份或authority epoch变化清空旧投影、使迟到请求失效；mutate后触发authority刷新（`features/relationships_v1011/session_bound_page.dart:7-64,94-105`）。`LiveConnectionPage`另绑定当前session、取消旧请求并用会话守卫重验（`features/connection/presentation/pages/live_connection_page.dart:34-60,152-170,249-266`）。
- 匹配访问的Readiness redirect是导航引导，不替代后端参与资格复核；匹配输入保存、opt-in、提案decision、Connection和Messaging Consent仍须各自走对应API与revision/权限检查。
- OS运行时权限、账户隐私分享、自动化授权及关系状态属于不同许可面；本盘点不把任一状态卡或route可达性解释成已授权。

## 6. 盘点边界与待基线化事项

本文件的依据是当前可见Flutter/Laravel源码路径与已具名测试，不是运行态证明。没有运行App、API或DB；当前部署权限状态、数据迁移状态及服务运行状态均未由此文件断言。此处不记录跳转数、点击/输入/确认数或成本达标结果；九项旅程必须在 `B3_OPERATION_COST_BASELINE.md` 单独采集。

相关既有测试锚点：

- 路由兼容与Readiness保护：`apps/flutter_elitesync_module/test/app/router/match_legacy_redirect_regression_test.dart`；
- Me Readiness入口与状态：`apps/flutter_elitesync_module/test/features/me/presentation/pages/readiness_purpose_page_test.dart`；
- Lifestyle完成/继续/改偏好：`apps/flutter_elitesync_module/test/features/lifestyle_discovery/lifestyle_page_test.dart`；
- Journey参与/页面：`apps/flutter_elitesync_module/test/features/slow_dating_v1012/journey_pages_test.dart`；
- Conversation route与保护：`apps/flutter_elitesync_module/test/app/router/stored_chat_direct_route_binding_test.dart`、`apps/flutter_elitesync_module/test/features/chat/presentation/pages/conversation_list_page_test.dart`；
- Buddy根路径拒绝与V1013入口：`apps/flutter_elitesync_module/test/app/router/buddy_route_exclusion_test.dart`、`apps/flutter_elitesync_module/test/features/buddy_v1013/v1013_root_entry_test.dart`。

本文件仅完成当前入口及权限源梳理，不表示上述测试已在本任务运行或通过。
