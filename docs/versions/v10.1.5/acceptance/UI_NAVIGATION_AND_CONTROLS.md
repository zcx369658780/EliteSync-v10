# v10.1.5 UI 导航与控件清单

本文供项目源 GPT 顾问总验收使用，按注册路由、主导航和已核实控件回调整理。源码存在不等于运行通过；本清单不替代逐页实机走查。当前代码阅读基于本地产品根 `apps/flutter_elitesync_module/lib/app/router/app_router.dart`、`apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`、`apps/flutter_elitesync_module/lib/app/router/app_shell.dart` 及对应页面实现。当前源码候选 APP 为 `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e`，后端为 `6549f028`。较早源码 `5e023b...` 中未变化页面的截图仍按原身份保存；新通知页面截图必须绑定当前候选身份。

状态标记：`SRC_ONLY` 表示从源码核实入口、条件或回调，不代表运行或实机通过。实机通过仅对明确写出的流程、设备和候选身份有效。

## 导航层级

### 启动与全局门控

启动默认进入 `/splash`。`SplashPage` 在引导状态恢复后，未登录转 `/auth/login`；已登录但准备状态未建立时转 `/me/readiness`；其余按环境初始路由进入，默认 `/home`。这是启动页自己的分流。另有全局路由重定向：未登录访问受保护路径转登录；已登录访问登录/注册转首页；准备状态不足时，仅匹配相关入口在非恢复本地构建中转 `/me/readiness`。恢复本地构建让匹配页展示服务端实际资格/拒绝结果。无效路径显示恢复页，可重试或回首页。

### 四个底栏分支

| 底栏位置 | 路径 | 页面/子层级 | 导航行为 |
|---|---|---|---|
| 首页 | `/home` | 首页 | 切换分支保留其它分支的导航栈；再次点当前项回该分支初始位置 |
| 进展 | `/progress` | `/progress/match`、`/progress/connection` | 匹配、连接分别作为进展分支子页；具体页由构建环境选择 |
| 消息 | `/messages` | 会话列表；会话页由授权会话路由进入 | 会话内容按身份和访问状态解析，失效身份进入无效会话恢复页 |
| 我的 | `/me` | `/me/private-identity`、`/me/matching-inputs`、`/me/readiness`、`/me/showcase`、`/me/privacy-settings` | 从“我的”进入个人身份、匹配输入、准备状态、展示和隐私页面 |

底栏由 `AppShell` 驱动 indexed-stack 分支。当前项再次点击传入 `initialLocation: true`。中心操作未配置（label 与 callback 均为空）；四项图标和标签由 `FloatingDockBottomBar` 提供。是否显示底栏取决于当前路由是否处于 shell 分支。

### 已注册的非底栏路由

| 路由 | 页面/用途 | 条件、重定向或返回关系 |
|---|---|---|
| `/splash`、`/auth/login`、`/auth/register` | 启动、登录、注册 | 受全局登录重定向控制 |
| `/verification/status`、`/verification/submit` | 资格状态、提交 | 登录后页面 |
| `/questionnaire`、`/questionnaire/result`、`/questionnaire/history` | 问卷、结果、历史 | 登录后页面；从页面自身操作进入相邻流程 |
| `/messages/chat/:chatIdentity` | 正式构建会话页 | 解析有效的临时路由状态或已存会话 ID；无法解析时进入无效会话页 |
| `/live-chat/:peerId` | 恢复本地构建会话页 | 仅 `restorationLocalBuild` 时注册，使用显式对端 ID 进入 `LiveChatPage` |
| `/rtc/call/:callId`、`/rtc/incoming/:callId`、`/rtc/result/:callId`、`/rtc/permission` | 通话、来电、结果、权限 | 常规会话通话页返回消息；来电/结果页按状态可查看结果或返回消息；权限页返回原通话页 |
| `/status/square`、`/status/author/:userId`、`/notifications`、`/social-baseline` | 动态广场、作者、通知、社交基线 | 登录后页面；由页面控件进入详情或返回来源 |
| `/content/:contentId` | 内容详情 | 使用内容 ID；返回来源页 |
| `/profile/edit`、`/profile/settings`、`/profile/settings/password`、`/profile/settings/privacy`、`/profile/settings/about` | 编辑资料、设置、密码、隐私、关于 | 登录后页面；页面返回其入口 |
| `/profile/mbti`、`/profile/showcase`、`/profile/astro`、`/profile/astro/overview`、`/profile/astro/bazi`、`/profile/astro/natal`、`/profile/astro/advanced`、`/profile/astro/ziwei`、`/profile/astro/chart-settings` | MBTI、展示与星盘页面 | 从个人资料/展示入口进入；返回来源页 |
| `/admin/dashboard`、`/admin/moderation`、`/admin/verification`、`/admin/users`、`/admin/matching-operations`、`/admin/moderation/reports/:reportId` | 管理仪表盘、审核、用户、匹配运营、举报详情 | 权限与数据以服务端为准；详情返回审核列表 |
| `/inner-test/feedback` | 问卷/内部测试反馈 | 接收 `category`、`source` 查询参数；返回来源 |

兼容路由 `/discover`、`/match`、`/profile` 分别保留；`/match` 重定向到进展匹配，`/profile` 重定向到“我的”。`/match/countdown`、`/match/result`、`/match/detail`、`/match/intention`、`/match/feedback` 重定向到 `/progress/match`。`/buddy-v1013` 与 `/formal-relationship` 路由已注册，普通用户入口按页面状态控制。`/live-connection`、`/live-chat/:peerId` 仅恢复本地构建注册；若干 `/debug/...` fixture 按开发条件注册，不作为普通用户入口。通知合成回跳路由仅在对应开关启用时注册。

页面跳转不全由 GoRouter 管理：头像管理、账号状态、好友/账号安全、通知偏好、关系隐私、部分动态/MBTI/星盘页使用 `Navigator.push(MaterialPageRoute)` 或根 navigator。它们按入口和系统返回回到来源页，不对应上表中的路径。验收截图索引应同时记录 named route 与 MaterialPageRoute 入口。

## 已核实控件逻辑

以下是源码控件回调及状态门控，不代表本清单已逐个在设备上操作。明确的运行/Owner结果见[实施报告](../IMPLEMENTATION_REPORT.md)。

### 会话列表和聊天

`restorationLocalBuild` 下 `/messages` 显示 `LiveConversationListPage`，会话行进入 `/live-chat/:peerId` 的 `LiveChatPage`。正式构建下 `/messages` 显示 `ConversationListPage`，会话详情经 `/messages/chat/:chatIdentity` 进入 `ChatRoomPage`。下表前半的刷新/隐藏与离线只读行为属于恢复本地构建实现；不得据此推断正式构建具有相同控件或回调。正式构建页面的实际控件仍需逐项对照其页面源码与最终候选截图。

| 控件 | 显示/启用条件 | 行为与结果 |
|---|---|---|
| 刷新会话 | 请求未忙 | 在线请求会话并核验登录及对端身份，成功后更新列表并保存加密离线副本；仅传输故障时可只读展示仍有效的已核验副本；权限拒绝、响应无效或缓存过期按实现撤销/锁定 |
| “查看我隐藏的会话”开关 | 非忙、非离线只读且可信上下文未锁定 | 切换可见/隐藏过滤并重新读取；隐藏列表不等同于撤销关系授权 |
| 会话行 | 可见列表且在线可写 | 打开 `/live-chat/:peerId`；离线只读时不开放新会话 |
| 行菜单/在线长按 | 有有效会话 ID 且在线 | “仅对我隐藏”或“找回会话入口”向服务端更新可见性；成功后失效旧授权 epoch 并重新读取 |
| 刷新对话 | 聊天页 | 重新读取最近消息，刷新头像及会话数据，并按当前在线授权更新加密副本；授权失效会撤销副本并锁页 |
| 语音/视频通话 | 非忙且非草稿处理；需当前登录、在线和有效会话 | 创建通话，按返回状态进入 `/rtc/call/:callId` 或 `/rtc/result/:callId`；失败在页面显示提示 |
| 发送文字/图片/短视频 | 无忙任务、离线只读、锁定、待确认消息或待处理媒体；消息文本上限 5000 字符 | 媒体先重验会话权限，再上传并发送；待确认 POST 以同一 client message ID 显式重试，未知结果不自动换 ID；成功后清理输入/草稿并刷新 |
| 保存/清除草稿 | 当前在线授权已核验，无忙或待确认发送 | 草稿加密保存在本机，不发送消息；清除仅删除本地草稿 |
| 重试上传/发送附件、移除附件 | 存在待处理媒体且满足在线与非忙状态 | 重试沿用当前媒体及会话授权；移除清除待处理附件 |
| 图片缩略图、私有视频、加载更早消息 | 图片已获授权并在内存；有视频附件；或在线且存在更早页 | 图片打开同页预览，返回只清预览态；视频打开播放器对话框；分页按 before ID 读取，授权错误撤销缓存并锁定 |

### 首页、进展、慢约与关系入口

| 页面/控件 | 显示/启用条件 | 行为与返回关系 |
|---|---|---|
| 首页下一步按钮 | 由当前 projection 的 `nextDecision` 提供 | 标签与目标路由均取 projection；点击 `go` 至该目标；摘要只读 |
| 首页“隐私与数据设置” | 首页 | `go /me/privacy-settings` |
| 首页构建变体 | `ELITESYNC_V1014_LOCAL_BUILD` 显示 `PlatformHomePage`；V1012/V1013 本地编译标志显示 `SlowDatingHomePage`；否则显示普通状态摘要/下一步/支持 | 具体构建标志，不由路由自身推断；此摘要不写入状态 |
| 进展“匹配”“连接” | 进展页 | 分别 `go /progress/match`、`go /progress/connection`；恢复构建可落到慢约旅程/LiveConnection，普通构建使用匹配/连接页 |
| 进展“查看准备状态”“正式恋爱关系” | 进展页 | `push /me/readiness` 或恢复关系路径 `/formal-relationship`；从子页系统返回回进展页 |
| 进展“独立吃饭/学习搭子”“好友可见社区” | V1013/V1014编译标志开启对应活动区域 | 分别 push 搭子页和动态广场；不由按钮创建资格 |
| 慢约旅程顶部搭子/社区 | 恢复路径打开旅程页 | push 搭子页、动态广场 |
| 慢约旅程意图编辑/参与状态 | 意图≤1000字符；参与操作由服务端状态、准备资格和 revision 决定 | 保存草稿/报名/重新报名/暂停/退出分别 PUT journey participation；退出先确认；成功失效旧授权并刷新，失败清投影并显示错误 |
| 慢约候选提案操作 | 有有效非终态 proposal、revision/id，并由服务端标志允许 | 接受、拒绝、撤回以 proposal ID 和幂等键 POST；双方接受且连接资格/对端有效时可进入关系权限页；底部正式关系入口 push 管理页 |
| LiveConnection 刷新/连接请求 | 恢复本地构建专用页 | 刷新读取当前匹配及连接/同意状态；缺少对端先从当前匹配解析。`CN_NONE`/`MC_NONE`显示“请求连接”/“请求消息同意”；pending 时请求人可撤回、另一方可接受/拒绝；`CN_ACTIVE`/`CN_PAUSED`可关闭连接；`MC_ACTIVE`可撤销消息同意，且消息同意操作仅在连接 active 时显示。均带 revision 提交并读回；失败标记“操作未确认” |
| LiveConnection“进入消息” | 服务端 `live_read_allowed` 与 `live_send_allowed` 均为真、对端有效且非忙 | push `/live-chat/:peerId`；无门控时按钮禁用 |
| 搭子页刷新/接收请求开关 | 恢复路径 `/buddy-v1013`；状态和 revision 有效 | 刷新 GET；开关更新偏好；身份/授权变化清空页面状态与敏感凭据 |
| 搭子邀请、一次性凭据及活动动作 | 服务端 `allowed_actions`、活动 ID/revision 有效 | 邀请、创建/撤销凭据及 `open/request/confirm/decline/decline_invite/withdraw/cancel/complete` 状态动作先确认，再 POST/DELETE 并刷新；创建草稿表单检查字段后仅保存本人草稿；兑换凭据仅申请参与，不自动加入 |
| 正式关系申请/关系动作 | 登录本人、对端 ID 合法且非忙；关系动作由服务端 allowed_actions 决定 | 申请前确认双方自愿并 POST；关系确认/拒绝/撤回/暂停/结束/恢复等逐项先确认并带 revision/幂等键提交；管理字段分享入口 push 对端隐私页；普通返回回来源 |

搭子页活动动作由服务器 `allowed_actions` 控制，包含 `open`、`request`、`confirm`、`decline`、`decline_invite`、`withdraw`、`cancel`、`complete`；动作均先确认并携带 revision/idempotency key。邀请好友需输入正整数 ID 并确认；生成/撤销一次性凭据需确认，撤销后旧凭据不可恢复。草稿创建需主题≤100字符、粗略城市≤40字符，日期有效且结束晚于开始；兑换凭据最多256字符，确认后只提出参与申请。正式关系记录中的具体动作同样以服务端 `allowed_actions` 与 revision 为准，结束确认说明不可恢复。

### 问卷、头像与展示资料控件

| 页面/控件 | 条件与动作 | 证据状态 |
|---|---|---|
| 问卷题目选项 | 未忙、题库不需重载时可选；非最后题先保存当前账户草稿，成功后才进入下一题；失败留在当前题并提示 | SRC_ONLY |
| 问卷最终提交 | 最后一题选项提交；成功刷新资料/准备状态并进入 `/questionnaire/result`；失败留在本页 | SRC_ONLY |
| 问卷题库重载/错误重试 | 题库/草稿不兼容或错误时出现；提交/保存中禁用 | SRC_ONLY |
| 问卷调试填充/提交 | 仅 debug 模式，题目已加载且无提交/重载 | 源码调试入口，不是用户验收流程 |
| 问卷结果“查看匹配资格” | 重新读取资料后进入 `/profile` 兼容入口（重定向 `/me`），不直接匹配 | SRC_ONLY |
| 问卷结果/历史“查看历史”“重新作答” | 查看历史 push `/questionnaire/history`；重新作答先清答卷草稿状态再回问卷页 | SRC_ONLY |
| 头像更换 | 快照已读且非忙；原生相册只接受 JPEG/PNG 且≤5 MiB；上传后 GET 读回 revision/path 才提示确认 | SRC_ONLY |
| 头像移除/刷新 | 有头像且非忙时可移除；移除先确认，DELETE 后读取默认头像状态；刷新重读头像数据 | SRC_ONLY |
| 展示资料私有草稿 | 介绍≤500、兴趣标签/生活线索各≤10项且每项≤24、开场话题≤280；保存/重试为 PUT 草稿，错误按字段/服务状态呈现 | SRC_ONLY |
| 展示资料安全审核 | 草稿已保存、无脏编辑且状态允许时提交审核；审核状态按钮重读；清除私有草稿需确认，只删除草稿、不删除已发布版 | SRC_ONLY |
| 展示资料发布 | 仅审核通过、具备公开资格且未发布的有效草稿显示发布按钮；确认后 POST 明确公开确认值；失败不标记已发布 | SRC_ONLY |
| 展示页调试夹具 | `/debug/profile/showcase/...` 仅开发环境注册，无后端写入 | 源码调试入口，不是正式发布或实机证据 |

### MBTI 与星盘页面控件

| 页面/控件 | 条件与动作 | 证据状态 |
|---|---|---|
| 星盘主页刷新/登录 | 按 `astroSummaryProvider` 状态显示重读或去登录；下拉刷新重新读取摘要 | SRC_ONLY |
| 星盘主页输入与排盘/行星落宫/紫微/反馈 | 输入与排盘打开本地 `NatalRestorationPage` 并在返回时刷新；行星落宫和有紫微数据时的主星详情分别进入 `/profile/astro/natal`、`/profile/astro/ziwei`；反馈进带来源的反馈页 | SRC_ONLY |
| 星盘总览三个主入口 | 有效资料时“查看本命盘/八字/紫微详情”分别进入对应详情页；卡片内视觉层级项的 `onTap` 为空，不是入口 | SRC_ONLY |
| 八字页 | 下拉刷新；出生资料、五行、运势时间线等内容和展开区域只读，无写按钮 | SRC_ONLY |
| 本命盘页刷新/设置/出生资料 | 刷新读取本人排盘；设置图标按响应数据进入输入与排盘设置或盘面显示设置；“编辑出生资料”进入资料编辑。参数/星体/宫位/相位区域展开只控制本页显示 | SRC_ONLY |
| 紫微页分视图/反馈 | “三合/飞星/四化”仅本地切换视图；详情展开只读；反馈进入带类别与来源的反馈页 | SRC_ONLY |
| 动态星盘重新读取/历史选择 | 重新读取 GET 本人记录；历史项读取指定记录；有 `next_before_id` 时“加载更早历史”分页。选历史/改输入设置后隐藏旧结果并标记未保存/冲突状态 | SRC_ONLY |
| 动态星盘新建、输入和盘型 | “另建私有盘”保留表单并清当前记录身份；盘型包含合盘/比较/推运/太阳回归/月亮回归；按类型显示两盘或事件输入。来源可手填或明确读取本人已确认本命快照 | SRC_ONLY |
| 动态星盘计算设置/保存 | 选择热带/恒星黄道、宫制、相位集合、容许度与点集；保存计算在忙/冲突时禁用。POST 新建/更新后 GET 读回并比对 ID、输入和结果 revision；失败或冲突不显示旧盘 | SRC_ONLY；盘面算法/科学有效性不在此 UI 清单验收范围 |
| 动态星盘回归事件/结果展开 | 回归事件选择将所选 index 保存并读回；跨盘相位、宫位叠加是只读展开内容 | SRC_ONLY |
| MBTI 开始/重做/刷新 | 读取结果；开始或重做读取并校验题目、清旧答案；刷新重读结果 | SRC_ONLY |
| MBTI 题目与提交 | A/B 仅更新本地答案；全部作答且非忙时可提交，之后再次读回并验证结果存在。切换登录身份清空旧题目/结果 | SRC_ONLY；页面定位为可选自评，不作心理诊断或匹配排序 |

### 盘面设置、关系安全和本人状态入口

| 页面/控件 | 条件与动作 | 证据状态 |
|---|---|---|
| 盘面设置摘要重读 | 加载或错误时显示进度/重新读取；重读使本人星盘摘要重新加载 | SRC_ONLY |
| 原生本命设置 | 摘要含 `natal` 时显示；可进入 `NatalRestorationPage` 重新计算，回到页面刷新摘要及本命盘；“恢复展示默认”和本机显示开关不改变计算记录 | SRC_ONLY |
| 普通星盘展示设置 | 摘要不含 `natal` 时显示；路线标准/古典/现代、完整版/平衡/极简预设、黄道/宫制/角度/容许度/点位，以及摘要与图形元素和密度偏好 | SRC_ONLY；设置仅影响当前展示偏好 |
| 高级时法入口 | 盘面设置页按钮 push `/profile/astro/advanced`，正常返回设置页 | SRC_ONLY；页面交互已列于上表 |
| 账号安全页 | 设备会话撤销、退出全部设备、离线撤销补偿；账号注销需要确认和安全凭据，随后显示本地注销回执 | SRC_ONLY；没有真实账号注销验收 |
| 关系中心/对端关系页 | 请求开关、好友/消息用途授权、邀请/凭据、请求接受/拒绝/撤回、好友或邀请撤销等操作依服务端权限与状态显示；部分操作打开对端关系页 | SRC_ONLY；由关系页面提供，不能泛化为全局授权 |
| 关系隐私页 | 可由当前关系页/连接页的字段分享入口进入；根据当前关系及服务端许可提供可见字段的管理/读取 | SRC_ONLY |
| ServerPrivacyPage | 当前未找到现行调用点 | 不可达旧入口；不是 RelationshipPrivacyPage 的替代名称 |
| 本人资格/运营状态/申诉 | 仅恢复构建或指定本地构建标志显示；安全案件页仅 v1014/v1015_r1 标志显示 | SRC_ONLY；页面显示不代表真实案件或申诉已处理 |

星盘/MBTI 路由存在及页面回调只说明源码行为，不代表计算结果、心理测量或实机验收通过。

### RTC 通话、来电、权限与结果

| 页面/控件 | 状态条件 | 行为与返回关系 |
|---|---|---|
| 通话页刷新 | 通话页 | 重新读取当前 call；失败页可重试或返回 `/messages` |
| “重试声音”/“重试媒体” | Room 已连接且媒体接收失败；操作期间禁用 | 重试输出/媒体恢复；失败给错误反馈 |
| “重新连接” | 曾尝试连接但未连上且通话仍有效 | 重新读取非终态 session，离开旧媒体并使用最新加入信息连接 |
| 静音/开启麦克风 | 已连接 | 切换当前通话采集；失败有错误反馈。后台暂停采集，返回后不自动恢复，需用户再次开启 |
| 听筒/扬声器切换 | 平台支持、当前 call 已连接且非终态 | 切换系统音频输出偏好；仅切换成功后更新偏好，失败提示重试 |
| 摄像头开关/切换摄像头 | 视频通话；当前通话有效 | 切换本机视频采集或镜头；摄像头关闭时镜头切换禁用 |
| 接听/拒绝/进入通话/挂断 | 根据 incoming、canAccept、canConnect、canHangup 和终态选择显示 | 接听前检查麦克风/视频相机权限，缺失时进入权限页；成功后更新会话状态。终态提供查看结果、返回消息 |
| 来电页刷新、接听、拒绝、返回 | 来电页 | 刷新重读；查看页面不会自动接听；接听成功进入通话，拒绝成功进入结果页；始终可返回消息 |
| 结果页刷新、返回上一页 | 结果页 | 刷新事件；离开时释放当前 call 媒体；底部按钮实际返回 `/messages`。时间线、状态 chips、“回到文字/低压接续/稍后再聊”均为只读建议，不写数据 |
| 权限页刷新、申请权限、打开系统设置、返回 | 以当前可信通话和前后台状态门控 | 刷新系统权限；请求麦克风及视频所需相机；全部允许时返回原通话页并重读状态；设置页回来自动刷新；拒绝/后台不自动接听或恢复媒体 |

### 我的、资料、设置与通知控件

| 页面/控件 | 条件与动作 | 证据状态 |
|---|---|---|
| 我的：设置、头像 | 设置图标 push `/profile/settings`；头像有 user ID 时打开头像管理，返回后刷新资料 | SRC_ONLY |
| 我的：私密身份、匹配输入、准备、展示、隐私 | 分别 go 对应 `/me/...` 子路由；资格/状态/申诉行仅恢复构建或指定本地构建标志显示，点击 push 账号状态页 | SRC_ONLY |
| 我的：通知、动态、MBTI、星盘 | 进入通知中心、动态广场、MBTI、本命盘/动态盘/关系盘/八字对应页面 | SRC_ONLY |
| 设置：主题、盘面、通知、好友请求、账号安全、隐私、密码、反馈、版本 | 主题开关更新主题；其它设置项分别进入现存目标页或带来源参数的反馈页 | SRC_ONLY |
| 设置：性能模式、浏览排序 | 本机保存；浏览排序变化同时清浏览缓存。开发预览仅 debug 环境显示 | SRC_ONLY |
| 设置：运营管理 | 已识别管理员或权限请求成功时显示管理组，进入各管理路由 | SRC_ONLY；权限显示不替代服务端写操作授权 |
| 设置：重播引导、清缓存、退出 | 重播引导后回首页；缓存重置/清理先确认并只处理对应偏好/缓存，不包含账号聊天记录；退出先确认，凭据安全队列入队成功后本机登出并回登录，后台撤销 session | SRC_ONLY |
| 编辑资料：昵称/城市 | 可单独保存；另一项或整体保存进行中时禁用；成功有服务端确认读回提示，异常提示未确认 | SRC_ONLY；昵称请求字段为 `name`，资料响应可由 `name` 映射到客户端昵称 |
| 编辑资料：性别、目标、生日、出生时间/地点 | 选择控件打开 dropdown/date/time picker；恢复构建可填出生地及坐标，普通构建提供搜索及最多10个结果选择 | SRC_ONLY |
| 编辑资料：保存并重算 | 与其它保存互斥；检查坐标；缺出生时间时先确认是否继续，再更新资料并说明重算/降级结果；顶部返回 pop | SRC_ONLY |
| 隐私设置：资料受众与本人预览 | 进入关系隐私页；六个有效导航控件进入私密身份、匹配输入、展示、连接、消息和设置；未建立区域显示只读状态，无写 API | SRC_ONLY |
| 关于/版本：手动检查更新 | GET `/api/v1/app/version/check`；根据平台、channel、版本展示状态，不自动下载。可用更新需先确认，校验 URL 后交系统外部打开 | SRC_ONLY；不是安装/升级验收 |
| 关于/版本：反馈、版本信息 | 反馈进入带类别/来源的反馈页；版本与资格历史只读；顶部返回 pop | SRC_ONLY |
| 通知中心：刷新、通知设置 | 图标/下拉刷新列表与未读数；设置进入通知偏好页 | SRC_ONLY |
| 通知中心：全部已读、单条已读 | 有未读时显示；成功更新计数，失败只提示，不导航 | SRC_ONLY |
| 通知中心：打开通知 | 根据隐私化动作标签点击；重新核验当前登录、authority epoch 和目标权限后才导航，并在成功打开后标已读。按通知类型进入会话、匹配、问卷、内容、RTC、设置或社交；搭子/活动/Safety/动态评论等受控资源先读取再打开。目标缺失、权限或网络错误不导航 | SRC_ONLY |
| 通知中心：稍后、加载更多 | “稍后”保留通知中心；有更早页时显示加载更多，忙时禁用，失败保留内容并显示重试 | SRC_ONLY |
| 通知偏好：系统权限 | “请求授权”请求 Android 通知权限后重读系统状态；不创建推送供应商/token 注册 | SRC_ONLY；真实 Push 仍 PENDING |
| 通知偏好：静默与消息类别 | 获取到经验证的类别配置后可切换；忙时禁用。PUT 失败显示未完成/重试；重读只刷新值，不会把失败 PUT 当成功 | SRC_ONLY；主代理在Owner测试手机的实测范围见下 |
| 通知偏好：重新读取 | 配置无法加载时显示；重新 GET 当前账户设置 | SRC_ONLY |

### 认证、资格、内容与社交控件（SRC_ONLY）

| 页面/控件 | 条件与动作 | 证据状态 |
|---|---|---|
| 登录表单 | 手机号、密码、协议勾选；校验失败显示错误，提交时按钮禁用/显示加载；成功设置会话并刷新资料，按初始路由或 `/home` 进入；失败由认证错误映射显示 | SRC_ONLY；运行验收按候选另记 |
| 登录次级入口 | “注册”进入注册页；“查询本机注销处理回执”用 MaterialPageRoute 打开本地回执；显示 session rejection notice | SRC_ONLY |
| 注册表单 | 手机号、密码、可选昵称、协议；成功提示注册完成并返回登录，不自动登录；失败显示映射错误 | SRC_ONLY |
| 资格状态 | 加载骨架/空态；错误时刷新重试；有状态时显示认证状态与要求；“去提交认证”进入 `/verification/submit` | SRC_ONLY；不代表真实身份审核 |
| 资格提交 | 姓名和身份证号输入；提交后读取最新状态。源码的 await 后 pop 会在页面仍 mounted 时返回状态页，包括提交错误分支 | SRC_ONLY；未实测真实身份数据 |
| 内容详情 | 按内容 ID 和可选 seed 读取；加载骨架、错误重试、正文/标签/媒体；图片加载失败占位，非图片媒体点击交系统外部打开 | SRC_ONLY；无点赞/评论控件 |
| 动态广场刷新/分页 | 顶部或下拉刷新；分页每次最多20条，可回首屏 | SRC_ONLY |
| 动态发布 | 标题、正文、城市、SELF/FRIENDS受众；可选单图封面并经媒体 API 上传。上传中/失败禁止发布；标题/正文必填；提交成功清表并刷新，失败提示 | SRC_ONLY |
| 动态帖子操作 | 点赞/取消、举报、作者入口、低压力聊天/继续了解/看资料进入作者页；“保存稍后”仅本机提示；本人帖可改受众或确认删除 | SRC_ONLY；作者页当前不读取资料 |
| 作者页 | 按 user ID 和可选名字 query 打开；当前实现固定显示受众权限未建立，不请求作者/资料数据；顶部返回 | SRC_ONLY；不是作者资料加载验收 |
| Social Baseline | 选择4类意图和4类近期计划后生成本地介绍预览；反馈选择只记录在页面 state 并提示已记录；不上传、不公开、不写正式资料 | SRC_ONLY；不是真实动态发布 |

初期共采集11张页面截图。通知偏好流程仅对应其中005/006/007三张：静默/消息类别切换、后端读回、页面重新进入后保持、恢复原设置。该流程由主代理在Owner测试手机上经正常UI实测通过；其余截图分别保留原页面/候选身份。通知中心和其它资料、设置、星盘控件不随该流程自动通过。

版本中心既有缺陷修复记录：原解析把 `10.1.5-dev` 当作 `0`，界面因此误报强制更新到 `0.07.04`。后端修复候选源码标识 `6549f028` 已本地保存，支持 legacy 字母后缀并改进 dev/metadata 版本比较；主代理提供的定向验证为9 tests / 54 assertions GREEN，真实 HTTP `has_update=false`、`force_update=false`。主代理已在Owner测试手机上使用同一安装包经正常UI复测，未再误报强制降级更新。此结果不代表下载或安装其它更新包已验收，也不记作Owner亲自操作或接受。

通知中心闪烁缺陷与修复：根因是来电扫描每2秒 invalidate 共享 UI 数据，造成通知中心列表刷新闪烁。当前 APP 源码 `e5aa6a29a76711b0e4bdb01613e269759d1ffe8e` 将后台读取独立化；通知列表 provider 采用 autoDispose，页面只读一次，不因扫描自动重读，读取失败不自动循环，用户可手动重试。主代理提供的工程证据为45项定向检查及受影响 analyze 通过，非作者复核覆盖 coordinator/provider。`8216` 包在手机上跨扫描周期滚动稳定，单条未读计数由50减至49。最终 e5 包受控503失败后保持错误页；服务恢复本身不会静默改页面，手动点击重试后恢复列表。Owner手动确认当前通知页正常、不再闪烁且按钮可用。该人工确认仅覆盖通知页当前观感/可用性，不代替整体产品验收。上述运行结果分属具名包/候选，不应互相替代。

## 截图与验收状态

当前初期共11张页面截图；通知偏好操作仅使用005/006/007三张。已有消息列表和“我的”上部截图仍绑定原采集候选；最终通知页截图按当前要求以 e5 候选采集并标注身份。整体仍没有覆盖全部注册页面、空态/错误态/加载态、菜单弹层、权限弹窗、通话状态与管理面板的完整截图索引。截图按页面记录：候选源码/APK身份、账号类型（去敏）、进入路径、状态/动作、结果、文件路径与是否仅本地。真实账号隐私信息、设备原始日志、凭据、APK 和媒体文件不得复制到公开材料。

仍未完成源码级逐控件清点的既有页面包括：正式构建的消息列表/聊天 (`/messages`、`/messages/chat/:chatIdentity`)；正式构建发现兼容入口及常规匹配/连接页面 (`/discover`、`/progress/match`、`/progress/connection`)；出生资料/排盘设置页 `NatalRestorationPage` 的内部控件；管理仪表盘、审核、验证、用户、匹配运营和举报详情 (`/admin/...`)。本段前面已列的登录/注册、资格、内容/动态/社交页面现有内容均为 SRC_ONLY；关系、安全、资料、通知、Home/Progress/Journey/Buddy/LiveConnection/FormalRelationship、MBTI/星盘控件也仍为 SRC_ONLY。除明确写出的 Owner 实机流程外，不据源码清单声称运行通过。截图覆盖仍需按验收目录补齐。不要把“路由存在”或 widget 测试当成控件在最终候选实机通过；修复后须在同一候选复验。

## 源码定位

- 路由名和路径：`apps/flutter_elitesync_module/lib/app/router/app_route_names.dart`
- 注册路由、重定向、身份解析：`apps/flutter_elitesync_module/lib/app/router/app_router.dart`
- 四项底栏和分支切换：`apps/flutter_elitesync_module/lib/app/router/app_shell.dart`
- 首页/进展/关系入口：`apps/flutter_elitesync_module/lib/features/home/presentation/pages/home_page.dart`、`apps/flutter_elitesync_module/lib/features/progress/presentation/pages/progress_page.dart`、`apps/flutter_elitesync_module/lib/features/slow_dating_v1012/slow_dating_journey_page.dart`、`apps/flutter_elitesync_module/lib/features/connection/presentation/pages/live_connection_page.dart`、`apps/flutter_elitesync_module/lib/features/buddy_v1013/buddy_page.dart`、`apps/flutter_elitesync_module/lib/features/slow_dating_v1012/formal_relationship_page.dart`
- 问卷/头像/展示：`apps/flutter_elitesync_module/lib/features/questionnaire/presentation/pages/questionnaire_page.dart`、`apps/flutter_elitesync_module/lib/features/questionnaire/presentation/pages/questionnaire_result_page.dart`、`apps/flutter_elitesync_module/lib/features/questionnaire/presentation/pages/questionnaire_history_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/avatar/avatar_management_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/personal_showcase_page.dart`
- 我的/资料/通知：`apps/flutter_elitesync_module/lib/features/me/presentation/pages/me_landing_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/settings_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/edit_profile_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/privacy_settings_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/about_update_page.dart`、`apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_center_page.dart`、`apps/flutter_elitesync_module/lib/features/notification/presentation/pages/notification_preferences_page.dart`
- MBTI/星盘：`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/mbti_center_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_profile_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_overview_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_bazi_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_natal_chart_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_ziwei_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/dynamic_chart_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/natal_restoration_page.dart`、`apps/flutter_elitesync_module/lib/features/profile/presentation/pages/astro_chart_settings_page.dart`
- 关系、安全与本人状态：`apps/flutter_elitesync_module/lib/features/relationships_v1011/account_security_page.dart`、`apps/flutter_elitesync_module/lib/features/relationships_v1011/relationship_center_page.dart`、`apps/flutter_elitesync_module/lib/features/relationships_v1011/peer_relationship_page.dart`、`apps/flutter_elitesync_module/lib/features/relationships_v1011/privacy_controls.dart`、`apps/flutter_elitesync_module/lib/features/slow_dating_v1012/relationship_privacy_page.dart`、`apps/flutter_elitesync_module/lib/features/me/presentation/pages/account_status_page.dart`、`apps/flutter_elitesync_module/lib/features/platform_v1014/safety_cases_page.dart`
- 认证/资格/内容/动态与社交：`apps/flutter_elitesync_module/lib/features/auth/presentation/pages/login_page.dart`、`apps/flutter_elitesync_module/lib/features/auth/presentation/pages/register_page.dart`、`apps/flutter_elitesync_module/lib/features/verification/presentation/pages/verification_status_page.dart`、`apps/flutter_elitesync_module/lib/features/verification/presentation/pages/verification_submit_page.dart`、`apps/flutter_elitesync_module/lib/features/home/presentation/pages/content_detail_page.dart`、`apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_square_page.dart`、`apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_author_page.dart`、`apps/flutter_elitesync_module/lib/features/social/presentation/pages/social_baseline_page.dart`
- 恢复本地构建会话/RTC页面回调：`apps/flutter_elitesync_module/lib/features/chat/presentation/pages/live_conversation_list_page.dart`、`apps/flutter_elitesync_module/lib/features/chat/presentation/pages/live_chat_page.dart`、`apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_call_page.dart`、`apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_incoming_call_page.dart`、`apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_call_result_page.dart`、`apps/flutter_elitesync_module/lib/features/rtc/presentation/pages/rtc_permission_page.dart`


