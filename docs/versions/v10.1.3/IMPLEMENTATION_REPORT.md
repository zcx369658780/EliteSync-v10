# EliteSync v10.1.3｜集中实现报告

2026-10-21。**V10.1.3_CANDIDATE_DELIVERED / AWAITING_ASTRA_INDEPENDENT_FUNCTION_ACCEPTANCE / V10.1.4_NOT_STARTED**。

本文是本版唯一实现主报告。结论均为 **CODEX_REPORTED**；源码与公开脱敏回执可由 Astra 直接核验，物理运行原证保持 **LOCAL_ONLY**。非作者工程复核无未关闭阻断，**不构成 Astra ACCEPTED**；未合产品 main，未启动下一版。

## 1. 权威、基线与固定身份

Owner手动派发的唯一[冻结计划](plan.md) Blob `74b67f4a61d2b38f7993dcfcb345510bc57cd65a`、[综合任务](task_order.md) Blob `249981ba9dc3d1aac8f6f676d99504a79d5c8b12`保持原字节；未重写冻结AC或历史裁决。

| 对象 | 固定身份 |
|---|---|
| 开工及发布前live main | `e4c854453e2d477562e8df2fb1dccf58df8d705d` |
| main Root Tree | `d23ac2343e4ba3ab20e82a550b9d216c12153030` |
| main已接受apps | `365810451b6faad98e041835be6c86f4f81be0a9` |
| main已接受services | `96b2972a19ec49108cf5c11d144179e5693570a9` |
| **本版最终源码Commit** | **`e27db2012e2c57390c4da179330552a6b64a728d`** |
| 本版源码Root Tree | `cf670270aaac7d641d58939eaea7737c23b89417` |
| 本版apps Tree | `d4569b330629d74c6e5f3ee1d6438245d7bfd024` |
| 本版services Tree | `4d637a3fd827e00974887d9ce515a1833a8f3a8a` |
| 产品候选分支 | `codex/v10.1.3-buddy-friend-community` |
| 临时审阅分支 | `codex/review-v10.1.3-20261021` |
| 固定审阅Commit / Tree | `a8c234e4b6f3e8837ab2e6978ab29ca43a38d172` / `f853f13166939b671e982f4ddb6d4c11ab9c36a5` |

v10.1.2功能与安全集成的双重独立接受仍有效；v10.1.0 `PARTIAL / NOT_ACCEPTED`、AC-10.1-08 PARTIAL、v10.1.1数据库事故/恢复、1.2原失败均保留。专用工作树接续main后在本候选分支实施，不整体合入未接受分支。源码共34条产品路径，精确path/mode/Blob列入manifest与审阅包；后续报告提交不改变apps/services。

源码Commit与含本报告的完整交付Commit分开：后者通过候选远端HEAD及交付后REST回读固定，报告不写自身提交hash以避免自引用。实际GitHub源代码：[固定源码](https://github.com/zcx369658780/EliteSync-v10/tree/e27db2012e2c57390c4da179330552a6b64a728d)；[固定脱敏审阅目录](https://github.com/zcx369658780/EliteSync-v10/tree/a8c234e4b6f3e8837ab2e6978ab29ca43a38d172/docs/_temporary_review/v1013-20261021)。

## 2. 实现与数据/受众合同

### 独立Buddy

新增 `BuddyService`、`BuddyController` 和 APP `buddy_v1013/BuddyPage`。Home次级与Progress独立入口使用真实API，四个顶层Tab不变，保留旧Mock路由排除。两位不填问卷、不参与匹配、无身份断言/正式关系的虚构用户可使用MEAL/STUDY。

活动仅保存UUID、owner/guest、MEAL/STUDY、100字以内主题、可空40字以内粗城市、ONLINE或PUBLIC_PLACE_UNSPECIFIED、预算档位、UTC start/end、state/revision及来源审计。没有自由文本地址、坐标、电话、证件、生辰、附件或公开目录；控制器拒绝actor伪装及禁止字段，对主题/城市做保守内容限制（可能拒绝部分正常文本，这是本版保守开发边界）。

默认只有本人；好友来源要求当前有效friendship及其revision、双方Buddy许可epoch、作者点对点邀请，收件人主动申请后作者明确确认。非好友只能手动兑换作者签发的64hex高熵凭据（48小时、单次、可撤销、数据库只留hash、发行时显示一次），不能用用户数字ID/枚举列表骚扰。终态或撤销后旧凭据不复活；拒绝后同一生命周期不能换幂等key重邀。

状态为DRAFT→OPEN→REQUESTED→CONFIRMED→COMPLETED，另有CANCELLED/DECLINED/WITHDRAWN/EXPIRED；参与者按角色明确操作，revision及actor/key幂等守护。有序用户锁→活动→授权/slots，事务外候选在锁后复核；每人最多3个未结束活动，每活动创建人和一位guest。过期槽在分配前释放。Block/禁用/注销/许可关闭等按当前权限收敛；解除好友只撤FRIEND来源，不能错误等同独立token、CN或MC。取消/拒绝不造Safety Finding，不建立好友/CN/MC/Conversation/正式关系。

### 好友社区、评论、私有媒体与通知

复用Status单一真值与原点赞/取消/举报，不建第二套Post。作者显式选择SELF/FRIENDS；统一 `PostAudience` 当前授权用于帖子/互动/评论/媒体。用户锁后当前读并复核session、作者状态、friendship/Block及Moderation；事务外只定位，锁后复核owner，未降低RR隔离级别。Status发布/改受众/删除也复核当前session；移除隐式private_birth_place落库回退。

一级评论UUID、post/author、body、state/revision、author/key唯一；最多280 Unicode字符、本人5次/10分钟、20条/页，不支持嵌套/链接/附件/私信。本人或文章作者可按revision删除，管理端可具名隐藏；原文保留数据库，客户端输出tombstone/null body。评论作者被Block/限权时正文也按当前权限遮蔽。分页、空态、错误、下一页替换明确；切号/epoch变化清页，迟到响应不写回旧账户内容。

通知只存必要ID/最小元数据，不拼原评论、活动全文或地点。当前权限失效时service输出空payload/body与不可用标题，HTTP列表过滤失效项；原通知行保留。APP新通知先经当前API授权再打开页面重读；单帖预检路径为 `/status/posts/{id}`，评论路径为 `/status-posts/{id}/comments`。真实GUI点击新通知未单独演练，见NOT_RUN，不以Widget代替实际点击。

Web `/admin/buddy-community` 复用现有admin/RBAC/CSRF；最多50条Buddy审计、20条具名评论举报，隐藏操作要求理由/confirm/revision并记审计。不能代双方确认Buddy或自动开放消息。

### 迁移与环境隔离

新增普通迁移 `2026_10_21_170000_create_buddy_and_comments.php`，只在本版新空库执行：

| 表/变更 | 持久约束与用途 |
|---|---|
| buddy_preferences | user主键，默认enabled=false、revision |
| buddy_activities | UUID主键、owner/guest FK、状态及revision |
| buddy_invitations | 来源friendship/revision、双方epoch、token_hash唯一、到期/核销/撤销 |
| buddy_slots | user/slot、activity/role、activity/user三重唯一；MariaDB CHECK slot 1..3 |
| buddy_commands | actor/key唯一、请求fingerprint与结果revision |
| buddy_audits | 活动/actor/action/最小facts审计 |
| status_post_comments | UUID、post/author FK、author/key唯一、原文及状态墓碑 |
| moderation_reports增量 | nullable target_status_comment_id/index；沿用审核真值 |

FK采用restrict，未实际删除历史或共享资料。未执行任何旧库fresh/清理。`APP_DB_CONNECTION`优先配置和testing/sqlite/:memory:防误清合同未改，普通PHPUnit仅memory；专项runtime guard固定local/mysql、loopback、43324、具名新库、无URL/socket且RR。

本版归属：数据库 `elitesync_v10_1_3_dev`，MariaDB10.11/REPEATABLE-READ，容器 `elitesync-v1013-buddy-db`，卷 `elitesync-v1013-buddy-data-20261021`；仅loopback43324，API8017，WS8018未启动。秘密配置和虚构账户凭据未入Git。数据库含测试用户与演练数据，不代表真实供应商/真实认证。

## 3. 冻结AC逐项结果

下表PASS仅为Codex执行结果，供Astra独立接受/拒收；范围限制不省略。

| AC-10.1.3 | 结果 | 证据与实际层级 |
|---|---|---|
| 01 基线/隔离 | CODEX_REPORTED PASS | main完整产品身份、四根HEAD/完整status/untracked/index指纹前后全等；新库新卷/空库backup/普通迁移；PHPUnit隔离未改。`protection-final-result.json`。 |
| 02 非婚恋搭子 | CODEX_REPORTED PASS | 同最终APK真实APP两角色MEAL/token及STUDY/friend邀请→主动申请→创建人确认→完结；API/DB回读，问卷/参与/身份断言/正式关系全0。STUDY好友关系由另一次真实API形成，Buddy全生命周期在APP操作；不冒称好友本身在APP形成。`app-meal-result.json`、`app-study-result.json`。 |
| 03 受控可达 | CODEX_REPORTED PASS | 真实HTTP匿名401、未受邀扫描404、错/撤销/过期token404；Block后解除不复活、关闭再开旧epoch404、旧注销token401、禁用登录403；actor/地址422，拒绝无通知/写入增量。`http-negative-result.json`及Feature。 |
| 04 状态/并发 | CODEX_REPORTED PASS | 两个独立进程调用真实Buddy服务，连接206/207单guest200/409；208/209争第3/4槽200/409，用户最终3槽、活动2槽；另有HTTP幂等/旧revision/终态负例和APP取消/真实到期。不是双socket HTTP并发。`buddy-concurrent-v2-result.json`。 |
| 05 独立同意 | CODEX_REPORTED PASS | APP MEAL后friends/CN/MC/Conversation/formal增量全0；STUDY只保留先行显式friendship。独立HTTP先形成CN_ACTIVE/MC_ACTIVE后Buddy withdraw前后完全相等；最终同对好友＋已完结Buddy发送普通消息404，CN_NONE/MC_NONE/send=false，计数不增。 |
| 06 动态/受众 | CODEX_REPORTED PASS | APP作者合成封面上传/FRIENDS发布，好友读正文/图；HTTP陌生人/SELF、列表/单帖/作者/媒体一致拒绝；API最终作者改SELF，APP旧评论刷新清页。图片选择器发生转码，服务字节等backing，不等原PNG。 |
| 07 评论/点赞/举报 | CODEX_REPORTED PASS | APP喜欢/取消、两条评论、一条自删tombstone；真实HTTP分页20+1、评论限额/跨actor/重放/作者删除/举报，Web具名隐藏body=null；重启再登录读回。评论不发MC/私信。 |
| 08 撤权/RR | CODEX_REPORTED PASS | SELF/unfriend/Block/delete/closure/disable六组实际HTTP旧帖/评论写/like/媒体六入口均404、feed移除、拒绝计数不变；两组RR必需边及额外logout边见下节，原媒体/点赞R1定点回归通过。旧通知service空投影且HTTP过滤。 |
| 09 Android真实界面 | CODEX_REPORTED PASS（注明分层） | 最终APK从固定源码构建/实装/pull同hash；真实Home/Progress、两搭子链、好友社区/封面/评论、切号重登、离线错误清页与SELF撤权；Widget覆盖迟到响应/分页/通知路由。真实GUI通知点击NOT_RUN；手机/RTC未操作。 |
| 10 Web/安全 | CODEX_REPORTED PASS | 实际浏览器虚构admin登录/具名举报ACTIVE→HIDDEN，API body=null；普通用户仍302回login权限错误，匿名302，缺CSRF419，旧审核重放409。未新增代替用户确认能力；1.2直接相关边界回归。 |
| 11 重启/真值 | CODEX_REPORTED PASS | 真正本版DB/API受控重启，18表所有行所有列排序hash/行数全等；实际HTTP和APP重新退出/登录读回。最终SELF写在重启比对之后，最终快照和backup另存。 |
| 12 集中交付 | CODEX_REPORTED PASS / 待独立验收 | 本报告+manifest、固定源码/APK、独立非作者复核、54文件最小脱敏短期分支、原失败/exit及恢复点；普通non-force候选发布和REST逐Blob/字节回读。报告交付Commit及回读见最终交付消息。未合main/自接受/清理/启动1.4。 |

## 4. MariaDB RR与受控并发证据

三组均实际查询REPEATABLE-READ，没有用SQLite sleep或全局锁数代替具名等待； reader是真实HTTP Laravel kernel路由，writer是独立CLI事务中实际Controller/service。首次定位读取完成→观测精确INNODB等待边→释放屏障→writer COMMIT→HTTP恢复；锁后执行当前授权，拒绝不算500/死锁/进程异常。

| 场景 | reader / writer connection | 精确锁 | 恢复结果 |
|---|---|---|---|
| 评论POST等待FRIENDS→SELF | 103 / 102 | users PRIMARY 13 | COMMIT先于HTTP恢复，404，无评论/点赞/通知/命令/举报增量 |
| 私有封面等待解除好友 | 108 / 107 | users PRIMARY 13 | COMMIT后404，无私有字节/副作用 |
| 旧token受众写等待logout | 224 / 223 | users PRIMARY 44 | COMMIT后401，无写入/通知副作用 |

精确transaction/connection/锁索引/键值/观察时间与first-read记录在 `rr2-audience.exact-wait.json`、`rr2-unfriend.exact-wait.json`、`rr3-logout.exact-wait.json`；对应result记录writer exit0、COMMIT次序及零增量。

原 `rr-three-cases` exit1：writer Request resolver错误导致null user/回滚，原reader响应未保存，不能说那次拒绝成功。`rr-three-cases-v2` **整体exit1**：前两组有完整有效证据，第三logout观察器误等post首读（该写路径先锁用户）。额外 `rr-session-v3` exit0完成精确logout边；未覆盖或抹掉原失败。

## 5. 测试、APP/Web实测与APK

| 检查/实际命令 | 原始退出与结果 |
|---|---|
| `php vendor/phpunit/phpunit/phpunit --filter 'V1013BuddyCommunityTest\|V1011R1AuthorizationTest\|V1011SocialTest\|V1012R1BoundaryTest'` | `feature-final` exit0；39 tests/584 assertions；保留2 Deprecations、2 PHPUnit Deprecations |
| `flutter test --no-pub test/features/status test/app/router/buddy_route_exclusion_test.dart test/features/buddy_v1013/buddy_pages_test.dart test/features/notification/presentation/pages/notification_center_page_test.dart` | `flutter-affected-final` exit0；55 tests |
| 仅1.3 gate的Home/Progress根入口Widget | `root-entry-widget-01` exit0；5 tests，明确1.2 gate=false |
| 旧Home/Progress回归 | `root-entry-legacy-widget-01` exit0；30 tests |
| 定点Flutter analyze / PHP lint | 最终相关analyze exit0；17个PHP/Blade/路由文件lint exit0 |
| Android离线开发构建 | `android-build-final` exit0；固定源码之后开建，前后tracked产品字节无变化 |
| 最终APK badging / signer / install | 三者exit0；安装pull与交付包同SHA256 |
| 实际DB/API重启、最终backup/停止、四保护根 | `owned-database-api-restart`、`final-backup-resource-stop`、`protected-roots-final`均exit0 |

这些测试集合有交叠，不相加声称独立总数。完整最终命令参数与stdout摘录见审阅包 `final-check-receipts.json`；全部原始command/stdout/stderr保持LOCAL_ONLY并有SHA索引。

APP实测是同一最终安装包＋本版API＋独立MariaDB＋获准既有AVD：A创建开放MEAL及token，B正常退出换号后手动兑换，A再登录确认及完结；STUDY通过独立好友来源，B从Progress主动申请，A确认完结。取消/过期用了真实API预备的本版合成草稿，APP实际取消、读到真实5秒到期EXPIRED；不是声称全部fixture创建都由GUI完成。

社区使用本版新合成72×72蓝色图片，由APP系统照片选择器选取/转码/上传、作者发FRIENDS，好友实际读取、点赞/取消/评论/自删。API离线刷新请求结束后APP显示Connection error并清除旧评论；首次在请求尚pending时取样失败已保留。DB/API重启后APP真实退出重新登录读回正常评论和墓碑。最后作者通过实际API把帖改SELF，旧好友当前页面刷新拒绝并清空正文；最终数据库受众是SELF，不拿撤权前FRIENDS快照冒充终态。

浏览器仅操作本版隐藏IAB，实际admin具名隐藏；临时浏览器已关闭。截图/原UI树仅本地，公开副本无照片/账户/token截图；未使用全局桌面控制或手机。

| 最终APK项目 | 值 |
|---|---|
| 文件（本地保留） | `EliteSync-v10.1.3-e27db201.apk`（完整位置由本地交付链接提供） |
| 源码 | `e27db2012e2c57390c4da179330552a6b64a728d` |
| applicationId | `com.elitesync.v1013dev` |
| versionName / code | `10.1.3-dev` / `1010301` |
| ABI | `arm64-v8a`, `x86_64` |
| 字节数 | `411589695` |
| APK / installed pull SHA256 | `a134e5c1fecfed3449ede1c996c57e2972774ee777071d071cd59a6017c2ed6d` |
| 开发签名证书SHA256 | `9c3fc6b545c35a0033adfbebf6c010536a616464094caf2981321644762f4b09` |

构建参数：`assembleDebug -PflutterDartDefines=ELITESYNC_V1013_LOCAL_BUILD=true -PrelationshipDualDeviceBuild=true --offline --console=plain`。历史名DualDeviceBuild表示双ABI构建选项，本版只用AVD，未用手机或重开媒体窗口。后端绑定固定源码/API8017/本版独立库；不是可用于生产或真实供应商的包。

旧48695cf2源码APK SHA256 `2bd2463d67f936726b35d747a619bd6ed08ce3a5d9ca022bbfa63716a1615eee`保留：实际Home gate只认1.2导致入口缺失，观察失败exit1，随后修复Home/Progress并重建最终包。旧包绝不当最终测试通过制品。

## 6. 非作者复核与原失败保留

独立只读GPT-6.1 Sol/high有界复核聚焦当前受控来源、旧token、竞争、通知/媒体副作用及必要APP入口。发现并修正地址保守限制、拒后换key重邀、过期槽释放、通知当前投影、Status锁后session和通知单帖预检路由；最终e27及实际根入口补丁增量复核无未关闭阻断。最后逐表核18表前后hash、APK源码绑定/install pull、APP SELF拒绝、保护指纹和资源停止一致。

审稿人未独立运行设备、DB、API、构建或读取私密原证，物理结论来自执行方指定安全回执。[非作者归档](https://github.com/zcx369658780/EliteSync-v10/tree/a8c234e4b6f3e8837ab2e6978ab29ca43a38d172/docs/_temporary_review/v1013-20261021/non-author-review.md)。公开副本最后有界检查保留28个原非零exit；提出stdout截尾含本地路径碎片的小项后已统一按整行脱敏重算SHA，产品源码不变。

`original-failure-index.json`列出28个原非零命令及原stdout/stderr字节数、SHA256；`command-exit-index.json`含审阅包形成前的运行/测试命令索引。额外实际旧APK入口失败另有固定JSON。包括：首轮Feature helper可见性冲突exit255、fixture必填phone缺失exit2、真实429限额、错误CN状态预期、未绑定cover导致404、并发合法409预期不符、UI滚动/取样、Web302/权限提示解析、观察器依赖/进程、分析与Widget/路由预期、未staged提交exit1。原件不覆盖、不删除、不把总体exit1改0；最终通过另列。

特别保留 `consolidate-app` exit1：原脚本误期望HTTP列表有不可用空payload项；真实service把这些项过滤。补核原通知持久行＋当前service空投影＋HTTP列表遗漏后 `consolidate-app-v2` exit0，而不是删掉通知隐私断言来追绿。所有401/404/409/419/422/429按各自语义登记，500/死锁/观察进程异常不算授权拒绝成功。

交付静态扫描另有一次工具误报：`formal-preflight` exit1将`https://`误匹配成Windows驱动器路径，报告实际未含该类个人路径；修正扫描器的词边界后重新核验，保留原stderr及退出码，交付阶段附加回执摘要见manifest。未为此重跑功能环境。

## 7. 持久化、恢复点与资源终态

受控重启前后18张表名称、全部行/列排序SHA256和行数相同：Buddy六表、Status/评论/点赞/媒体、好友/社交请求、CN/MC/正式关系、通知、举报及admin审计。公开的是hash/行数，不含原SQL。前后为 `durability-before-restart.json`、`durability-after-restart.json`；后续SELF测试写入单独 `durability-final.json`，不强行与前快照哈希相等。

| 恢复点 | SHA256 / 结果 |
|---|---|
| 新库迁移前空库backup | `empty-before-migrate.private.sql`保留LOCAL_ONLY |
| 重启前backup | `6d7426ef3df6fd545d6c0d93ca076de57973c7d73269d7e4de4bb08f19aec210`，274017 bytes，exit0 |
| 最终backup | `44f629f25a088d5dfca3cb56e00ac542085520fa8c455875bac742476bc9c1f7`，274173 bytes，exit0 |

最终API STOPPED、专属DB容器EXITED、卷RETAINED、获准AVD STOPPED、本版adb reverse8017 REMOVED；8017/8018/43324均不接受连接，WS8018从未启动。临时IAB已关闭。未停止全局ADB/WSL/Docker Desktop或旧服务。

四保护根（原dirty v10根、旧仓、前1.2连续树、1.1专用树）在开工与终态逐根比较HEAD输出字节、完整porcelain/untracked输出字节、index定位字节及实际index SHA256，全true；原status约13MB也按原字节保存/比较，没有仅看简表。未清理资产、删除卷/备份或尝试恢复/重置这些根。

## 8. 公开交付、项目源与NOT_RUN

普通non-force已发布源码候选和独立短期审阅分支，REST逐一核Commit/Tree、完整apps/services、冻结plan/task Blob及54个审阅文件的Blob/字节SHA256；随后本报告/manifest/ACTIVE_STATE以文档提交接续候选，再做最终独立GET字节回读。具体完整交付Commit/Tree与最终回读本地回执由终态消息提供。无force、main写入、PR合并、历史分支删除或证据清理。

审阅包仅最小公开副本，54文件和path/mode/Blob/sha清单可在固定审阅分支读取。原凭据、.env、SQL、令牌、带账户UI树/截图、设备原日志、APK大包均LOCAL_ONLY；公开副本不能代替原物理证据。独立短期审阅分支不得合入main或产品分支，阅后清理仍须另行精确任务。

2026-10-21项目源ZIP只检查本任务两个具名路径，未取得固定SHA256原件，状态 **BYTE_MIRROR_PENDING**；不扩大搜索、不造字节一致。Owner已手动更新ChatGPT项目附件，不能据此写“用户未上传”。没有修改原语义候选或旧项目源历史。

**NOT_RUN / 未授权部分：** 手机安装/USB操作、RTC/实际音视频通话/人工听辨、麦克风/相机、UDP/DNAT/防火墙/UAC/全局SDK/系统配置；阿里云旧试点、公网/证书/备案、真实身份/地图/Push/支付供应商及费用；真实账号认证/正式恋爱关系；全国陌生人目录/精确位置/群活动；无关全部算法oracle或全部历史AC重跑；真实GUI通知点击（已有Widget路由＋真实HTTP/service授权）；原ZIP字节镜像；生产部署、产品main集成、Astra接受、审阅分支清理、v10.1.4。

终态停在本版候选，等待Astra独立功能验收。已下载到真实客户端的内容不能追溯抹除；本版拒绝后续读取与清除APP当前页面不构成对所有历史副本物理销毁的承诺。
