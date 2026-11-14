# v10.1.9 集中工程交付

2026-11-14。工程自验六项 AC 通过，状态 `ENGINEERING_DELIVERED_ADVISOR_PENDING`。顾问验收与 Owner 本版最终接受为 `PENDING`。完整结构化结果见 [证据摘要](EVIDENCE_SUMMARY.json)，文件与运行身份见 [交付清单](artifact_manifest.json)。

## 身份

| 项目 | 实际值 |
|---|---|
| 分支 | `codex/v10.1.9-social-buddy-activities-20261114` |
| 已接受基线 | `be0112ac53fc0ab3d3bfaf360552b020bcca3476` |
| 固定任务提交 | `b429f5a56cb3878aad285405b9d5c3928da166ac` |
| 最终 APP 与后端源码 | `dfcef55a9801e2b2a4e80c59013f35c2f0d82ef6` |
| 最终候选 | `10.1.9-dev / 1010902`，`com.elitesync.v1015dev`，source Debug，arm64-v8a |
| APK SHA256 | `d275dacce4ade375bb209756f2b6c8c316de59ec80efea738f5dcbefc5968cd0` |
| 签名证书 SHA256 | `7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42` |
| 双端安装 | 模拟器 5580 / 用户11、5582 / 用户12，安装 APK 实读 hash 均匹配 |
| 真实开发服务 | Laravel / PHP 8.4.27、MariaDB 10.11.19、既有 WS / SFU，API `127.0.0.1:8021` |

开工已完成 `LOCAL_DOCS_SYNCED`，指定10份文档 Git Blob 与固定任务提交相等，私有落盘回执保留实际根、remote、分支、HEAD、初始空 index 及原主库保护基线。最终报告由包含它的交付提交标识，固定回读结果在最终交付回复中给出。

## 六项 AC

| AC | 工程结果 | 本版实际证据 |
|---|---|---|
| AC19-01 | PASS | 最终 APP 双端完成请求7与接受，好友4当前 ACTIVE / revision3，从好友页进入既有合法聊天。请求6撤回可读。解除好友后旧 Buddy 联系人提交404，用途列表更新，独立 CN/MC 前后相等。 |
| AC19-02 | PASS | APP 作者页读取合法动态，未发布 Showcase 返回404并独立显示。真实收藏、取消、本人列表与评论经过 APP，点赞经真实 API。动态5改 SELF 后收藏占位，详情、图片26和评论旧入口均404。账号C的收藏为空，账号B重登后读回5的占位和6的当前内容。 |
| AC19-03 | PASS | 最终 APP 创建 `4ebf8339-5f5e-4029-a91f-6094fb9b5c90` 并明确发布，账号B按线上 / MEAL 发现。发布4 / generation1，截止 `2026-11-14 04:29:17` UTC，取活动开始分支。管理员经真实 Web 撤下发布3，旧卡申请409。历史与新草稿默认私有。 |
| AC19-04 | PASS | 发现申请、作者确认、双方 APP 读回、APP 完结贯通。独立 DISCOVERY 来源与好友选择邀请来源分别成立。好友活动 `52409fb1-ef25-44dd-a594-881efb516281` 在重启后仍 CONFIRMED，随后 APP 完结。终态通知实际进入最小本人结果。 |
| AC19-05 | PASS | 两席活动 `e8cc6d1a-3d1a-4500-8dc2-a6249ee10189`，账号16/17先报名并由 Web 确认，账号18真实 APP 候补1。满额转正409，16取消释放席位后 Web 转正18，APP读回 CONFIRMED。Web关闭/完成、18个人取消与终态通知回流通过。最终17为CONFIRMED，16/18为本人取消。 |
| AC19-06 | PASS | 最终1010902贯通以上 APP/Web/API/MariaDB链。B→C→B重登、双APP冷启和一次显式DB/API/WS统一重启通过，重启前后业务事实完全相等。12份运行后端关键文件与本地源码hash相等，Git内容规范化匹配最终源码。 |

收藏与动态的测试数据由正常媒体/动态 API 建立。平台活动及零费用模拟预算审批、开放、邀请、确认和转正均由实际 Web session / CSRF 表单完成。所有参与动作来自实际 APP 或具名定向 API，请求身份与落库记录对应。

## 定向检查

| 批次 | 结果与范围 |
|---|---|
| 后端最终批次 | 41 tests / 1250 assertions，PASS。包含本版 Social、Buddy、Platform 与受影响1.3/1.4回归，SQLite内存隔离并有真实库保护断言。 |
| Flutter最终批次 | 74项，PASS。联系人、作者、收藏、Buddy、Platform及通知，共6个定向测试文件。 |
| 改动 Dart 源码 | 15份 analyze，PASS。 |
| 真实 MariaDB 并发 | Buddy两竞争者为200/409，仅一个guest。平台同一原命令并发重放200/200，revision及参与记录不增加。接收人/事件通知重复键0。 |
| 控制时间与夹具 | 3槽、5次成功申请配额、重放不重复计数、独立来源、发布到期保留既有参与、开始早于48h、扫描200个失权候选仍推进游标、候补越序与当前资格均通过。 |
| 全库静态分析 | FAIL，9个既有测试签名错误及3条既有提示。12处文件和 SessionNotifier 均与任务基线相同，清单保存在证据摘要。 |
| 全量 Widget 测试 | NOT_RUN。自然48h/7d观察 NOT_RUN。 |

重叠批次按最终批次记账。定向实际MariaDB检查、隔离夹具与普通成功链分别列示。候补真实主链只有一位候补，越序及不合格候补由隔离定向检查覆盖。

## 修复与工程选择

首个候选1010901在普通链中发现终态通知停在不可访问提示。1010902增加当前终态安全结果读取及APP回流，仅平台详情404进入最小结果回退，并保留身份、权限代际和迟到响应检查。原候选及APK已在Owner本机保存。

普通注册的虚构账号最初因缺少 `is_synthetic` 标记而被平台邀请以404拒绝。本版补充已知本机开发库内的管理员Web虚构账号设置，要求当前管理会话、CSRF、明确确认和理由审计，实际通过该表单标记虚构16/17/18，再执行正常邀请。设置只写账号开发分类，参与仍由本人动作形成。

原PHP fixture缺phone、Web测试guard、异步测试类型/生命周期、自动化测试路径及键盘/视窗错误均保留在本机原日志。早期部分截图和活动定位读取发生在异步动作完成前，作为中间原证保留。公开精选截图改为先等待稳定UI语义，再截取并人工核对；发布代次及幂等原载荷由最终数据库记录和原命令重放验证。

## 部署、迁移与资源

后端通过既有Docker真实开发服务的源码挂载运行。`ContactService`、`StatusPostController`、`BuddyService`、`PlatformEventService`、`NotificationService`、相关控制器、路由及两份迁移共12份关键文件，容器字节hash与稳定工程相等。规范化Git内容、部署hash与最终源码提交对应。完整部署挂载回执留本机。

真实MariaDB已应用 `2026_11_14_110000_create_status_post_favorites` 和 `2026_11_14_120000_add_buddy_discovery_publications`。现场读取确认发布代次唯一索引、发现来源唯一索引，旧数据私有默认。原开发数据库、AVD及安卓用户数据保留。

显式DB/API/WS重启窗口为北京时间11:58:09至11:58:16。源码部署、好友、收藏、活动、CN/MC事实读回相等。SFU最终实际启动时间与状态详见资源摘要，本版媒体证据沿具名通信范围继承。

资源实读截至 `2026-11-14T12:09:08.960013+08:00`，DB/API/WS/SFU均running、SFU Room0。双APP及两保留AVD已停止，ADB5038 USB排除实读通过。最终及中间APK、完整HTTP/UI/数据库读回、原截图、凭据与私有工具均保留Owner本机。

原主库 dirty/index/diff 的SHA256与开工保护基线一致，稳定根受保护 `%SystemDrive%/` 保留。

## 继承与验收出口

v10.1.8六项及R1-01沿Owner与顾问已接受范围继承，依据 `1074c210ee7fa6641799fa6e19d29fc46ef6b2bc` 的R1交付与接受基线。call63/call64通信具名证据、既有搜索、引用、媒体及审核范围继续按原manifest说明保留。本版增加通用API异常statusCode供通知精确404回退，RTC媒体与CN/MC状态机源码的本版差异为空。

真实Push为 `REAL_PUSH_PROVIDER_PENDING`，历史非注入SFU精确根因为 `UNKNOWN`。本版设备实测为双模拟器，手机为 `NOT_USED`。硬件、自然长期期限及真实活动/支付范围按原记录保存。

本次工程交付等待新的GPT顾问会话验收。当前六项PASS是上述约定开发范围的工程判断，版本进度统一见ACTIVE_STATE。

## 精选稳定界面证据

| 内容 | 图片 |
|---|---|
| 好友接受及撤回记录 | [查看](evidence/ac01-accepted.png) |
| 作者动态与Showcase独立 | [查看](evidence/ac02-author-independent.png) |
| 收藏失效占位 | [查看](evidence/ac02-unavailable-placeholder.png) |
| 重启后已确认好友搭子 | [查看](evidence/ac04-confirmed-after-restart.png) |
| 搭子终态通知回流 | [查看](evidence/ac04-terminal-notification.png) |
| 平台排程完成及已确认参与 | [查看](evidence/ac05-completed-confirmed.png) |
| 平台终态通知最小结果 | [查看](evidence/ac05-terminal-notification.png) |
| 冷启后当前收藏与占位 | [查看](evidence/ac06-favorites-after-restart.png) |
