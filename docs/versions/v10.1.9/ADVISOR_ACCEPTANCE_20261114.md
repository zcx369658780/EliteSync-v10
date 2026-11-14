# v10.1.9 顾问验收：限定 R1 补修

日期：2026-11-14（北京时间）。Owner：华霜魂。被审交付：6a9f28d9e60ff8abbad96494925ccea3b2dd46a4。

## 结论

**CHANGES_REQUIRED — V1019-R1-01 OPEN（P2）。**

三项 AC 按约定开发范围接受：AC19-04、AC19-05、AC19-06。AC19-01、AC19-02、AC19-03 的主体功能和已报告普通成功链有对应实现与证据，但共同保留“收到明确失权响应后清除旧页面投影”的一项缺口，暂记 PARTIAL。三个触发入口合并为一个补充项，不重新开发产品，不重开 v10.1.8。

工程报告中的六项 PASS 保留其工程自验身份；本报告另记顾问结论。Owner 对 v10.1.9 的最终接受仍为 PENDING。本次只下达 [R1 任务](supplement-r1-20261114/task_order.md)，不自动开始 v10.1.10。

## 1. 审查对象与方法

| 身份 | 核对结果 |
|---|---|
| 仓库 / 分支 | zcx369658780/EliteSync-v10 / codex/v10.1.9-social-buddy-activities-20261114 |
| 原任务 | b429f5a56cb3878aad285405b9d5c3928da166ac |
| 已接受父基线 | be0112ac53fc0ab3d3bfaf360552b020bcca3476 |
| 本次工程交付 | 6a9f28d9e60ff8abbad96494925ccea3b2dd46a4 |
| APP / 后端源码 | dfcef55a9801e2b2a4e80c59013f35c2f0d82ef6，为工程交付的唯一父提交 |
| 实际候选 | 10.1.9-dev / 1010902 / com.elitesync.v1015dev / source Debug / arm64-v8a |
| APK SHA256 | d275dacce4ade375bb209756f2b6c8c316de59ec80efea738f5dcbefc5968cd0 |
| 签名 SHA256 | 7c023c0fbdab8cd4f53daedbc95badb47d5f968b2c267d94fa695655f391bd42 |

GitHub compare 显示任务到交付 ahead 8、behind 0，merge base 即原任务，共54个变动文件；任务单与冻结计划未变。最终源码到交付仅一个提交，包含文档与精选截图，没有产品源码差异。AGENTS 与原任务相同。

已审 [实施报告](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/docs/versions/v10.1.9/IMPLEMENTATION_REPORT.md)、[manifest](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/docs/versions/v10.1.9/artifact_manifest.json)、[去敏证据摘要](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/docs/versions/v10.1.9/EVIDENCE_SUMMARY.json)、当前入口及必要受影响 APP/后端/迁移/Web/测试。按 Social/社区、Buddy、Platform 三个范围交叉审查；顾问复核了三个缺口的实际控制流与拒绝来源。

顾问没有访问 Windows 工程盘、运行手机或模拟器、执行 PHP/Flutter 测试、重启服务或听取原音。本报告的代码判断与 Git/文件核对为顾问直接审查；运行、安装、数据库及资源事实来自 Codex 具名报告。下述缺口为固定源码路径确认，顾问实机重演 NOT_RUN；不把静态分析写成设备运行。

## 2. 六项 AC

| AC | 顾问结论 | 已有依据及本轮保留点 |
|---|---|---|
| AC19-01 好友与联系人 | PARTIAL / R1-01 | 用途候选、最小标签、当前提交复核、普通请求/接受/撤回与合法聊天链有证；联系人“加载更多”收到业务403仍保留旧选项。 |
| AC19-02 作者与收藏 | PARTIAL / R1-01 | 作者动态/Showcase分权、唯一持久收藏、显式设值幂等、失效占位与本人取消有证；广场旧动态的新增收藏操作收到404后仍保留正文与旧卡。 |
| AC19-03 自愿搭子发现 | PARTIAL / R1-01 | 明确发布、最小卡、私有默认、期限、200扫描推进及Web撤下有实现和证据；发现分页收到当前Buddy许可403仍保留旧卡和申请按钮。 |
| AC19-04 双人搭子闭环 | SCOPE_ACCEPTED | 独立DISCOVERY/FRIEND来源、唯一guest、REQUESTED计槽、每人3槽、同号幂等、成功配额、作者确认/完结及终态通知对应。公开到期不误撤已成立参与。 |
| AC19-05 平台活动闭环 | SCOPE_ACCEPTED | 两席三账号普通链、APPLIED占位、候补/释放/后台提升/取消与最小终态回流对应；容量、当前资格和按序提升有事务锁及定向测试。 |
| AC19-06 持久化与交付 | SCOPE_ACCEPTED | 当前1010902的源码、交付、部署声明与文件身份相符；重登/冷启/必要重启读回有具名摘要。后续R1新候选仅需核其受影响增量身份。 |

SCOPE_ACCEPTED 均限定原 plan.md 的开发范围，不代表发布、生产就绪、全硬件或真实线下活动验收。

## 3. 唯一补充项：V1019-R1-01

**P2 — 新入口收到明确失权或资源不可用响应后，旧投影未及时清除。**

| 入口 | 确定触发路径 | 当前行为与影响 |
|---|---|---|
| 联系人分页 / AC19-01 | 已有第一页及下一页；当前账号在另一端变为 moderation_status=restricted，仍为active且未disabled；加载更多返回403 account unavailable。 | _loadMore 经默认 replace:false 的 run 获得 null 后直接返回；旧_items、游标和可选入口保留。仅有ES代称/占位头像，未发现私图正文泄露或提交越权成功。 |
| 动态流收藏 / AC19-02 | B已看到A的FRIENDS动态；A另一端改SELF、删除或关系失效；B在旧卡点收藏 true，服务端当前受众检查返回404。 | catch只显示“收藏状态未确认，可按原操作重试”，没有移除旧卡、清投影或失效provider；已展示正文及可能的封面组件继续留在页面。 |
| 搭子发现分页 / AC19-03 | 已有第一页及下一页；同账号另一端关闭Buddy；当前页加载更多返回403 enable Buddy first。 | _more获得null直接返回；已有卡、游标和申请按钮仍显示。后端仍拒绝新申请，没有发现授权旁路。 |

代码定位：

- [ContactPickerPage 90–110行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/relationships_v1011/contact_picker_page.dart#L90-L110)；[ContactService 16–18行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Services/ContactService.php#L16-L18)；[JourneyStore 30–31行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Services/JourneyStore.php#L30-L31)。
- [StatusSquarePage 253–270行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/status/presentation/pages/status_square_page.dart#L253-L270)；[StatusPostController 248–263行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Http/Controllers/Api/V1/StatusPostController.php#L248-L263)；[PostAudience](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Services/PostAudience.php)与[动态provider](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/status/presentation/providers/status_posts_provider.dart)。
- [BuddyDiscoveryPage 100–118行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/buddy_v1013/buddy_discovery_page.dart#L100-L118)；[BuddyService 124–129行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Services/BuddyService.php#L124-L129)。
- [SessionBoundPage 88–98行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/relationships_v1011/session_bound_page.dart#L88-L98)仅在replace=true错误分支清投影；[RelationshipApi](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/features/relationships_v1011/relationship_api.dart)携带statusCode但不主动广播权限失效；[AuthInterceptor 88–137行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/apps/flutter_elitesync_module/lib/core/network/interceptors/auth_interceptor.dart#L88-L137)不覆盖上述普通业务403/404。

本项只要求“已经收到明确拒绝后”的清理；不引入所有远端变化必须实时推送撤回的新增要求。普通断网、超时与5xx不能一律冒充失权。同账号合法输入与尚未确认命令的不可变key仍须按原约定保护。切号或权限代际改变后的旧响应不得清除或覆盖新账号当前数据。

已有作者分页明确对401/403/404清理；收藏列表读取采用replace:true。无需借本项改造全APP。具体最小修复和验证见R1任务。

## 4. 重要已核结果

### 后端权限与业务

联系人仅从本人已有合法关系/请求上下文产生，按用途重判，不是人员目录。收藏设值和唯一关联正确，取消不要求重获原文权限；失效列表post=null且不向作者通知。作者动态与Showcase分别读取。

Buddy独立来源不会落入FRIEND分支。CONSUMED发布不再以公开截止时间撤销已有参与；唯一guest、槽位、revision、成功配额及幂等在事务内对应。平台APPLIED/CONFIRMED占容量，WAITLISTED不占；仅提升当前最早合格候补，终态通知不恢复旧报名动作。

### 本机虚构账号设置入口

[PlatformAccess 12–22行](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Services/PlatformAccess.php#L12-L22)实际限定local环境、mysql/mariadb、明确开发库名/端口组合、127.0.0.1且禁用连接URL/socket；testing仅SQLite内存库。Web入口继承auth:web、account.active、admin.phone与CSRF，并复核未撤销管理会话。

[developmentParticipant](https://github.com/zcx369658780/EliteSync-v10/blob/6a9f28d9e60ff8abbad96494925ccea3b2dd46a4/services/backend-laravel/app/Http/Controllers/Web/PlatformController.php#L15-L34)要求明确确认、理由、正常普通目标账号和事务审计，实际仅设置is_synthetic；不写参与、好友或CN/MC。此开发辅助入口在现有授权范围内，不作为本版新阻塞；它也不构成真实运营账号或生产服务开放。

### 候选与文件身份

manifest所列12份部署关键文件Git Blob全部与固定交付一致。9份Git原始文本SHA256直接匹配声明，PlatformEventService及API/Web PlatformController三份以CRLF工作区换行形式匹配；各自运行hash与本地hash相等是Codex报告事实，不是顾问在容器中重测。

实施报告和EVIDENCE_SUMMARY的公开hash对应CRLF本地文本，规范化后与Git内容一致。检查了五张精选界面（作者分权、冷启收藏占位、重启后已确认好友搭子、平台完成/确认、平台终态最小结果），文件hash均匹配manifest；画面与声明状态相符。没有检查全部旧截图或拆解私有原证。

## 5. 非阻断限制及记账

- 后端41 tests / 1250 assertions、Flutter74项、15份改动Dart analyze为Codex具名最终批次。顾问核测试设计，没有复跑；重叠批次不累加。
- 全库静态检查仍FAIL：9个既有测试签名错误、3条提示。12个列举文件均不在本次完整变更清单；SessionNotifier所在session_provider.dart在任务/交付的Git Blob均为7bbfd6e093a34ce94b79b28b81bdc850b1eac7bf。它们不转成PASS，也不纳入此次R1。
- 真实MariaDB竞争guest为200/409，平台同命令并发为200/200且无重复参与/revision增长，属于具名定向工程证据。平台普通主链仅一名候补；越序与不合格候补来自隔离测试。控制时间不冒充自然期限观察。
- LOCAL_DOCS_SYNCED由Codex报告，时间2026-11-14T10:12:51.864247+08:00；顾问未直接读取D盘。本次新增顾问/R1文档的Windows同步另为PENDING_LOCAL_SYNC，不能继承为已落盘。
- 最近运行资源仍是工程报告2026-11-14T12:09:08.960013+08:00快照；不代表此刻实时状态。手机NOT_USED。
- v10.1.8范围接受、R1-01 CLOSED继续保留；真实Push REAL_PUSH_PROVIDER_PENDING，历史非注入SFU/RPC精确根因UNKNOWN，完整硬件/自然期限及其他既有限制分别保留。

## 6. 下一步与停止点

Codex安全同步本次顾问/R1文档后，在原稳定根及本版分支仅修复V1019-R1-01，做三条拒绝反例及受影响必要验证，提交精简R1报告、实际新候选/源码身份和去敏证据。已接受主体链按未变范围继承；不重跑整版六项、旧通话、全硬件或全资产哈希。

固定提交保存回读后停下供本顾问复核。无v10.1.10任务、无main集成、无发布。原工程报告/原证及中间1010901、1010902身份保留。
