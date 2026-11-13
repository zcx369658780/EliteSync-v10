# APP 功能说明

本文件保留2026-11-12原验收包及原候选范围。2026-11-13当前修复、普通功能补证和限制见 [R1补充结果](../supplement-r1-20261112/README.md)，当前完成度以其AC表与manifest为准。

当前手机安装源码 `0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f`；后端源码 `6549f02880968f99ae3f45439d15a37c1b3d5251`。当前安装与manifest已对齐，历史证据逐项保留其原候选。源码中的入口和行为不等同于最终实机验收。候选与证据归属见[实施报告](../IMPLEMENTATION_REPORT.md)和[版本清单](../artifact_manifest.json)。

## 功能目录

| 功能组 | 用途和入口 | 主要代码位置 | 行为与权限边界 | 当前证据情况 |
|---|---|---|---|---|
| 首次使用、登录、注册 | 恢复现有账户或创建账户；符合本机首次使用条件时由主 Shell 弹出引导，可在设置中重播。 | apps/flutter_elitesync_module/lib/features/auth/presentation/pages/；apps/flutter_elitesync_module/lib/features/onboarding/presentation/first_use_onboarding_page.dart；app/router/app_shell.dart | 启动恢复完成后，登录状态决定进入目标页或认证页。未登录访问受保护页面会转登录。引导完成/跳过只写本机首次状态，不代表账号准备状态完成。 | bd4c模拟器B正常UI退出并服务端撤销读回、再登录并打开已有A对话；注册只看过表单，注销处理回执只读取空态。重播5步引导并完成回首页。 |
| 身份资格和问卷 | 提交资格信息，完成或更改匹配问卷，查看结果和历史。 | features/verification/presentation/pages/；features/questionnaire/presentation/pages/ | 报名和匹配入口受当前资格与准备状态约束。页面展示不能替代后端决定。 | bd4c手机20题逐题正常提交，结果和两条历史读回。此前账号隔离证据保留原候选。 |
| 首页、发现与内容详情 | 浏览首页及 Discover 兼容直达页，并进入内容详情。 | features/home/presentation/pages/home_page.dart；features/discover/presentation/pages/discover_page.dart；content_detail_page.dart | `/discover` 不是底栏页；详情依内容标识加载，稍后查看不持久化书签。 | 当前首页已采手机截图。Discover兼容入口与内容详情仍按构建/内容条件标记SRC_ONLY。 |
| 进展、匹配、连接 | 查看参与进度、匹配或连接入口及当前状态。 | features/progress/presentation/pages/progress_page.dart；features/match/presentation/pages/match_portal_page.dart；features/connection/presentation/pages/connection_page.dart；恢复构建使用 features/slow_dating_v1012/slow_dating_journey_page.dart 与 features/connection/presentation/pages/live_connection_page.dart | 正式构建匹配页主要展示 canonical 状态/候选；常规 ConnectionPage 默认是非权威示范态。当前 dev 候选开启恢复本地构建，使用慢约旅程与服务端 LiveConnection；不可混为同一运行流程。 | 已对首页/进展/匹配/连接等页面拍摄。平台A没有访问权、连接页无当前匹配对象；当前只记观察范围，不声称这些业务链完成。 |
| 好友、搭子和正式关系 | 使用已有好友、搭子、连接和正式关系入口。 | features/buddy_v1013/buddy_page.dart；features/slow_dating_v1012/formal_relationship_page.dart；features/relationships_v1011/ | 几种关系有各自的授权和状态，页面之间不默认互相授权。 | 搭子、社区、正式关系等空态/入口已采集；受限于状态无数据的页面仅记录观察范围。 |
| 消息、会话和媒体 | 查看获准会话，读取历史，发送文字、图片和短视频，处理失败和重试。 | 正式构建：features/chat/presentation/pages/conversation_list_page.dart、chat_room_page.dart；恢复本地构建：live_conversation_list_page.dart、live_chat_page.dart；features/chat/domain/entities/chat_route_state.dart | 打开会话时校验权限。成功状态以服务端确认为准。附件依消息和媒体授权读取。恢复本地构建的在线核验、加密缓存、离线只读和操作条件与正式构建会话实现不同，不能相互代证。 | 当前26手机实测双向文字120/121、图片122/asset17、视频123/asset18发送成功，手机预览播放到0:02；A/B既有会话读取与服务端链路按原证据分别归档。 |
| 语音、视频与通话权限 | 从会话呼叫或接听，结束通话，管理麦克风/相机权限和听筒/扬声器选择。 | features/rtc/presentation/pages/；features/rtc/domain/services/rtc_livekit_service.dart | 当前 Room 和 callId 决定媒体操作归属。后台暂停采集后，用户明确操作才恢复。 | call44双向清晰Owner反馈保持原5e身份。26c实际发现call45并暴露过期页停留。最终0bad已通过46自然过期自动终态、47正常拒绝，完整长时/复杂路由矩阵待完成。 |
| 通知和提醒 | 查看站内通知、已读状态和通知设置。 | features/notification/presentation/pages/notification_center_page.dart；notification_preferences_page.dart | 点击目标前重验当前账户、通知权限及目标权限。Push 真实供应商沿冻结计划为 PENDING。 | 主代理在Owner测试手机上经正常UI实测通知静默/消息类别切换、后端读回、重新进入保持及恢复原设置（截图005/006/007）。通知中心闪烁修复另由Owner手动确认页面正常、不再闪烁且按钮可用。真实Push仍PENDING。 |
| 个人资料、展示与隐私 | 管理头像、本人资料、展示内容、隐私受众和参与准备状态。 | features/me/presentation/pages/；features/profile/presentation/pages/；features/profile/avatar/avatar_management_page.dart | 头像按 Owner 决定只显示在获准好友、邀请、会话上下文，并遵循拉黑限制。私密资料不会因上传而自动公开。 | 头像可见边界已有具名证据；主代理在Owner测试手机上经正常UI实测昵称独立保存、重新进入、恢复原名且其它资料值不变。其它资料/设置/展示页面仍按同候选逐项验收。 |
| 设置和账号安全 | 管理主题、性能模式、浏览偏好、通知设置、隐私、安全、密码、首次引导及退出。 | features/profile/presentation/pages/settings_page.dart；change_password_page.dart；privacy_settings_page.dart；features/relationships_v1011/account_security_page.dart | 本机偏好由本机存储保存。缓存清理作用于缓存。登出把本机退出与服务端撤销状态分别处理。 | 手机已完成主题切换并恢复夜间；空密码触发本地校验。未修改密码，成功路径未测。账号B登出/撤销及重新登录结果见认证项。 |
| 动态、社交和作者页 | 浏览现有动态、作者和社交基线入口。 | features/status/presentation/pages/；features/social/presentation/pages/ | 依据当前内容与账户授权读取。 | 首页/进展/搭子/社区等空态及入口已采集；平台A无访问权等限制单独保留，当前只计观察范围。 |
| MBTI 与星盘 | 进入可选 MBTI、本人出生资料、本命盘、八字、紫微及动态盘。 | features/profile/presentation/pages/mbti_center_page.dart；astro_profile_page.dart；astro_overview_page.dart；dynamic_chart_page.dart 等 | MBTI 不作心理诊断。星盘使用本人资料或明确手填对象，不自动取得他人账号出生资料。 | bd4c手机正常UI完成MBTI三题提交并读回ENFP；20题逐题提交后读回结果与两条历史（非debug路径）。本人虚构出生快照三盘保存1/1、呈现4柱/12宫/10主体；两个本人虚构Synastry快照保存1/1、44相位，peer历史一致。物理手机只测Synastry；其他盘型沿用历史5a762582截图/模拟器证据，源码页与service保持一致。 |
| 内测反馈草稿 | 从设置、版本、资料、社交或星盘页面带来源进入反馈页，生成并复制本地反馈草稿。 | features/feedback/presentation/pages/inner_test_feedback_page.dart | 页面仅在本机组织草稿并调用剪贴板；不提交服务端、不自动发送。 | SRC_ONLY；尚无逐态实机截图记录。 |
| 管理面板 | Flutter 管理入口查看概览、用户、资格、举报和匹配运营；Laravel Web 面板提供独立管理流程。 | features/admin/presentation/pages/；services/backend-laravel/resources/views/admin/ | Flutter 路由受页面/服务端权限控制；Web 管理路由在登录、账户有效和管理员中间件下开放，写操作依原有 reason/confirm/capability 校验。 | 主代理在真实Chrome读登录、10个管理页和正常登出；4个长页有完整截图。管理写操作仅沿用具名历史范围，本轮不据只读浏览扩大验收。 |

## 现有功能范围

v10.1.5冻结计划含消息可靠性、RTC现有链路加固、可信15/30天边界与加密离线只读、通知隐私及 Push 预留、有界旧资产来源判断。每项状态与限制以版本实施报告、manifest 和具名证据为准。真实 Push 供应商待定时标记 PENDING。

提交顾问总验收前，为每项列出最终候选、实机步骤、结果、截图索引和未覆盖条件。源码功能目录不代替行为验收。

当前手机安装 APP 源码 `0badb31c38db63fe0fb1b5fcbfb43e5cb4e68d3f`、后端 `6549f02880968f99ae3f45439d15a37c1b3d5251`。当前APK身份与manifest一致。当前 dev 候选的 `restorationLocalBuild` 下 `/messages` 使用 `LiveConversationListPage`，会话进入 `/live-chat/:peerId` 的 `LiveChatPage`；正式构建使用 `ConversationListPage` 和 `/messages/chat/:chatIdentity` 的 `ChatRoomPage`。旧截图/运行结果仍绑定其原候选，不能把恢复构建专有交互概括为正式构建全部行为。

个人资料编辑页把界面“昵称”映射到资料 API 的 `name` 字段；读回 DTO 兼容把 `name` 映射到客户端昵称。MBTI 为可选页面，不作心理诊断、不用于匹配排序。星盘和关系盘入口按用户明确提供或本人已确认资料读取；界面控件说明与盘面计算正确性分别验收。

主代理在Owner测试手机上经正常UI完成昵称独立保存、离开再进入、恢复原昵称的往返；其它资料值保持完全相同。此结论只覆盖该资料保存流程，不记作Owner亲自操作或接受。

手机、模拟器与Chrome共120张截图已逐张索引，执行设备、路径和源码/APK来源各自绑定。来电过期缺陷的最终同包实际结果已补齐，整体冻结验收仍含未完成条件。
