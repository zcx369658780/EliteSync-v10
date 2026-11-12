# APP 功能说明

当前 APP 源码 `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e`。本文按当前代码整理的功能目录，供项目源 GPT 顾问总验收使用。源码中的入口和行为不等同于最终实机验收。当前已完成的实际候选证据、待验项与证据归属见[实施报告](../IMPLEMENTATION_REPORT.md)和[版本清单](../artifact_manifest.json)。

## 功能目录

| 功能组 | 用途和入口 | 主要代码位置 | 行为与权限边界 | 当前证据情况 |
|---|---|---|---|---|
| 首次使用、登录、注册 | 恢复现有账户或创建账户。启动时显示登录状态及首次使用引导。 | apps/flutter_elitesync_module/lib/features/auth/presentation/pages/；app/router/app_shell.dart | 启动恢复完成后，登录状态决定进入目标页或认证页。未登录访问受保护页面会转登录。 | 既有同候选虚构账号与会话证据可沿用。最新截图索引待补。 |
| 身份资格和问卷 | 提交资格信息，完成或更改匹配问卷，查看结果和历史。 | features/verification/presentation/pages/；features/questionnaire/presentation/pages/ | 报名和匹配入口受当前资格与准备状态约束。页面展示不能替代后端决定。 | 问卷持久化和账号隔离已有具名证据。最新完整 UI 流程待复核。 |
| 首页与内容详情 | 浏览首页内容并进入内容详情。 | features/home/presentation/pages/home_page.dart；content_detail_page.dart | 详情依据内容标识加载现有内容，使用原有访问控制。 | 最新候选流程和页面截图待补。 |
| 进展、匹配、连接 | 查看参与进度、匹配或连接入口及当前状态。 | features/progress/presentation/pages/progress_page.dart；features/match/presentation/pages/match_portal_page.dart；features/connection/presentation/pages/connection_page.dart | 匹配入口受到准备状态门控。连接基于各自现有授权流程。 | 相关后端流程的虚构账号证据沿具名候选保留。最新页面和返回路径待整理。 |
| 好友、搭子和正式关系 | 使用已有好友、搭子、连接和正式关系入口。 | features/buddy_v1013/buddy_page.dart；features/slow_dating_v1012/formal_relationship_page.dart；features/relationships_v1011/ | 几种关系有各自的授权和状态，页面之间不默认互相授权。 | 需将本版复用的现有流程同路线图条目对应，补最新候选截图。 |
| 消息、会话和媒体 | 查看获准会话，读取历史，发送文字、图片和短视频，处理失败和重试。 | 正式构建：features/chat/presentation/pages/conversation_list_page.dart、chat_room_page.dart；恢复本地构建：live_conversation_list_page.dart、live_chat_page.dart；features/chat/domain/entities/chat_route_state.dart | 打开会话时校验权限。成功状态以服务端确认为准。附件依消息和媒体授权读取。恢复本地构建的在线核验、加密缓存、离线只读和操作条件与正式构建会话实现不同，不能相互代证。 | 文字、媒体、持久化、重试已有按候选区分的实际证据。当前候选需按冻结验收表核定哪些路径无需复测。 |
| 语音、视频与通话权限 | 从会话呼叫或接听，结束通话，管理麦克风/相机权限和听筒/扬声器选择。 | features/rtc/presentation/pages/；features/rtc/domain/services/rtc_livekit_service.dart | 当前 Room 和 callId 决定媒体操作归属。后台暂停采集后，用户明确操作才恢复。 | 最新 call44 双向清晰由 Owner 确认。异常提示/重试已有软件注入和 UI 行为验证。实际新音轨事件证据 UNKNOWN。蓝牙与路由故障注入 NOT_RUN。 |
| 通知和提醒 | 查看站内通知、已读状态和通知设置。 | features/notification/presentation/pages/notification_center_page.dart；notification_preferences_page.dart | 点击目标前重验当前账户、通知权限及目标权限。Push 真实供应商沿冻结计划为 PENDING。 | 主代理在Owner测试手机上经正常UI实测通知静默/消息类别切换、后端读回、重新进入保持及恢复原设置（截图005/006/007）。通知中心闪烁修复另由Owner手动确认页面正常、不再闪烁且按钮可用。真实Push仍PENDING。 |
| 个人资料、展示与隐私 | 管理头像、本人资料、展示内容、隐私受众和参与准备状态。 | features/me/presentation/pages/；features/profile/presentation/pages/；features/profile/avatar/avatar_management_page.dart | 头像按 Owner 决定只显示在获准好友、邀请、会话上下文，并遵循拉黑限制。私密资料不会因上传而自动公开。 | 头像可见边界已有具名证据；主代理在Owner测试手机上经正常UI实测昵称独立保存、重新进入、恢复原名且其它资料值不变。其它资料/设置/展示页面仍按同候选逐项验收。 |
| 设置和账号安全 | 管理主题、性能模式、浏览偏好、通知设置、隐私、安全、密码、首次引导及退出。 | features/profile/presentation/pages/settings_page.dart；change_password_page.dart；privacy_settings_page.dart；features/relationships_v1011/account_security_page.dart | 本机偏好由本机存储保存。缓存清理作用于缓存。登出把本机退出与服务端撤销状态分别处理。 | 源码 callback 已定位。最新候选逐项实测待补。 |
| 动态、社交和作者页 | 浏览现有动态、作者和社交基线入口。 | features/status/presentation/pages/；features/social/presentation/pages/ | 依据当前内容与账户授权读取。 | 逐页入口、空态和结果待补。 |
| MBTI 与星盘 | 进入可选 MBTI、本人出生资料、本命盘、八字、紫微及动态盘。 | features/profile/presentation/pages/mbti_center_page.dart；astro_profile_page.dart；astro_overview_page.dart；dynamic_chart_page.dart 等 | MBTI 不作心理诊断。星盘使用本人资料或明确手填对象，不自动取得他人账号出生资料。 | 实机页面和完整操作状态待整理。 |
| 管理面板 | 管理员查看用户、资格、审核、举报、匹配运营。独立 Web 面板提供后端管理页面。 | features/admin/presentation/pages/；services/backend-laravel/resources/views/admin/ | APP 管理入口按管理员权限或受控后端管理权限显示。Web 写操作需按现有后端授权运行。 | 此轮未重跑 Web 页面。顾问资料是否需要 Web 实截图需按其验收方式附入。 |

## 现有功能范围

v10.1.5冻结计划含消息可靠性、RTC现有链路加固、可信15/30天边界与加密离线只读、通知隐私及 Push 预留、有界旧资产来源判断。每项状态与限制以版本实施报告、manifest 和具名证据为准。真实 Push 供应商待定时标记 PENDING。

提交顾问总验收前，为每项列出最终候选、实机步骤、结果、截图索引和未覆盖条件。源码功能目录不代替行为验收。

当前源码候选 APP `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e`、后端 `6549f028`。`restorationLocalBuild` 下 `/messages` 使用 `LiveConversationListPage`，会话进入 `/live-chat/:peerId` 的 `LiveChatPage`；正式构建使用 `ConversationListPage` 和 `/messages/chat/:chatIdentity` 的 `ChatRoomPage`。原 `5e023b...` 中未变化页面的截图继续绑定原身份；新通知中心截图绑定 `e5aa6a29...`。不能把恢复构建专有交互概括为正式构建全部行为。

个人资料编辑页把界面“昵称”映射到资料 API 的 `name` 字段；读回 DTO 兼容把 `name` 映射到客户端昵称。MBTI 为可选页面，不作心理诊断、不用于匹配排序。星盘和关系盘入口按用户明确提供或本人已确认资料读取；界面控件说明与盘面计算正确性分别验收。

主代理在Owner测试手机上经正常UI完成昵称独立保存、离开再进入、恢复原昵称的往返；其它资料值保持完全相同。此结论只覆盖该资料保存流程，不记作Owner亲自操作或接受。
