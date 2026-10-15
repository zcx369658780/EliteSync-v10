# v10.0.7 R1 定点返修交付

**V10.0.7 R1 CANDIDATE DELIVERED — AWAITING ASTRA FINAL ACCEPTANCE**。本报告追加R1事实，不改冻结8项AC，不改初始候选、旧报告或原始失败；不是Codex自我ACCEPT。

## 固定身份

- 冻结plan：`ef1bf4d07f5d7b84a38fb0f59f2efbe951ff4307` / Blob `151d75b67238826841467fa93c140825ebf61282`，字节保持。
- 初始候选：`69b3f26c6ed28a7306e4ba6b902aac2475bfe103` / Tree `09982c2349fb47c276018ff24aa30ac2f267dc34`，仍在本分支历史中，原EXECUTION_REPORT/TEST_RESULTS/RUNBOOK/manifest不重写。
- 独立R1意见：[ASTRA_R1_REVIEW_FINDINGS.md](ASTRA_R1_REVIEW_FINDINGS.md)，固定提交 `657c1af73749c2925dd4fd8a7b3a63350f86cb79` / Blob `177e6511d68d1bd10b9dd217157e7f2beca81360`。本次先实际读取全文与plan并核Blob。main实测 `1fd22c280cd10d2a8aa7039d51845604dbc791e6`；纯文档更新不替换产品起点，不重做K08。
- **R1源码锚**：`d3fa5f2bc891931fc9bb86eeb196d233d8686d71` / Tree `66b0050ed85d74cd3a55509264cd2c095089f4a5`。后续候选仅增加R1报告/原证/状态登记；最终candidate commit/tree由固定GitHub交付和本地`r1/candidate-publication.json`回读确定，避免文件自引用自身SHA。
- 分支继续 `codex/v10.0.7-app-restoration`，普通non-force发布，不合并main。原专用树复用。E为原v1007证据根，本轮全部追加`E/r1`，不覆盖原证。

## R1-01：消息通知服务端最小化及当前权限

修改三处：

1. `ConversationAtomicSendService`停止从私信正文截取摘要，停止把发送者姓名/peer及原始路由参数写入消息通知。
2. `NotificationService::createForUser`集中把message及相关私聊通知保存成通用title/body和必要`message_id/source`。不同消息仍以独立消息指针保留事件，幂等重播不重复创建。正文和发送者名称不进入新通知记录。
3. `presentationForUser`对旧消息记录也统一通用正文/标题，不透传原payload/route_args。只有服务端真实message的receiver匹配、当前`LiveConsentService`的live_read gate成立、实际room存在，才从真实消息派生conversation导航；不信任旧通知自报peer/conversation/title。撤销/block/禁用/未知或reader异常返回通用无导航通知，不清空事件。notifications四个入口补`account.active`，禁用账号不能继续列出、计数或标记。

既有非私聊站内事件不整体清除。合法用户仍能读取事件/未读、标记已读和获取受权导航；目标会话再次经过原权限门。七条消息路由及私有媒体门没有移除或放宽。生产/未配置环境不使用本地授权，消息通知只给通用表示。

### 真实HTTP/MariaDB结果

不恢复原Bob3或原MC撤销终态，不重seed任何库。仅在`elitesync_v1007_dev`追加具名虚构R1 sender11 / recipient12与Match5权限夹具。该Match是限定通知测试的数据库前提，**没有冒称新执行Matching consumer或新增APP匹配成果**。初次夹具week_tag过长在事务中回滚，消耗自增9/10但没有落下账号；修正后11/12正常建立，原失败/exit0陷阱保留。

两身份通过真实HTTP分别完成CN请求/接受、MC请求/接受，CN4 ACTIVE rev2；上传本版1x1虚构PNG成为media2 ready，发送真实Message5并由对方读取。通知10的实际DB为通用title/body，payload仅`{source:message,message_id:5}`，没有正文标记或发送者姓名。当前有权API只派生实际Conversation2导航，消息及图片读取200；通知未读1→已读0、事件仍存在。

随后实测：

| 当前状态 | 通知API消息条目 | 消息/图片 |
|---|---|---|
| 双方MC ACTIVE | 通用文字，无私信正文/姓名；真实Conversation2导航 | 200 / 200 |
| recipient block sender | 保留事件但payload/route_args空，route_name空，无正文/姓名 | 404 / 404 |
| 正常unblock | 当前reader恢复可信导航 | 原门保持 |
| MC REVOKED rev3（read/send两行） | 通用无导航，未读/已读操作仍可用 | 404 / 404 |
| admin实际禁用recipient12，旧token | 列表/未读接口401，token已撤销 | 不借通知授予任何访问 |

原Alice通知API还对原始message通知1/2作了实测：Bob已禁用且原MC revoked后，旧正文/身份不返回，原记录及read_at不改写。原通知3/9归禁用Bob，认证拒绝；新Reader的模拟旧记录测试覆盖其同类出参。历史DB明文摘要仍作为原始受控开发记录保留，**没有伪称已批量清洗旧存储**；R1修复其API读取旁路，并停止产生新明文摘要。

[真实时序](evidence/r1/run-notification-business.stdout)、[撤销后负例](evidence/r1/notifications-revoked.json)、[block负例](evidence/r1/notifications-blocked.json)、[旧记录保护](evidence/r1/original-legacy-notifications-protected.json)、[新通知/当前CN-MC数据库](evidence/r1/db-notification.stdout)。旧候选旁路可在本轮修复前`initial-revoked-notifications.json`与修复后收据对比。

原数据比对：初始交付终态与R1结束时，原users8、answers/attempts/drafts/astro、Match1～4、CN1～3、MC1/2、Message1～4、MBTI、Status及likes、Notification1～9逐行包含且值相同。只追加R1具名夹具，不抹掉成功业务及原失败。见`original-data-preservation.json`。

### 自动回归

真实服务端authority测试覆盖：新存储最小化、合法导航派生、伪造旧conversation/title/payload不透传、旧正文始终隐藏、MC撤销、block、disabled、未知配置、非真实receiver/无效message指针、事件计数/已读保留。它使用真实LiveConsent writer/gates与HTTP middleware，不mock current权限。

最终相关PHP5文件 **27项/332断言通过，exit0**，保留2项vendor弃用。包含NotificationApiTest、MessageApiTest、V1007LiveConsentTest、V1007PrivateMediaTest和新增V1007R1NotificationPrivacyTest。既有通知测试的明文peer/route持久断言替换为更强的最小存储断言，并从真实message/room继续核receiver/sender/conversation及幂等，未删有效保护。首次新增fixture用了非UUID被422拒绝；另暴露notifications缺account.active和测试cache配置键误配，均修正并留原失败。phpunit.xml补正确`APP_CACHE_STORE=array`以隔离测试文件缓存；不删除throttle、不清本地业务缓存或降低限流。

## R1-02：6项Flutter失败的修复与固定起点归因

详见[R1_TEST_ATTRIBUTION](R1_TEST_ATTRIBUTION.md)和固定对象清单/基线原流。

- typed mock：测试起点已有ID=1错误期望，本轮之前只增了fake CancelToken签名；datasource起点/初始候选同Blob且始终确定返回990000499。本轮按typed合同修正断言，保留ID、client key、正文、conversation、replay其余断言，不改变真实消息语义。
- 其余5项：从**0989812c固定Git对象**导出独立临时Flutter package（441份具名源逐字节核对、同锁、offline依赖），不带.env、不建worktree、不接DB/API，不替换专用树产品。实际5文件 **20通过/5失败 exit1**，逐项复现3项legacy及2项缺同次fixture。不是仅凭文件未改推断，也不是完整历史套件重验。
- 两诊断套件必须传入同次纯PHP输出；exporter不加载Laravel/Composer/.env或真实服务。本次12个虚构scenario/930 checks，输出SHA `334b71e018915aedac38385d4b328bca2b6514572f90c41a8888897bba5e8ad9`。不提供fixture仍fail-closed；没有static fallback或skip。

**Match权限核查**：既存旧widget渲染server headline造成的文案断言失败仍保留，不能声称展示合同全绿。但该widget `_primaryAction`只刷新/返回首页，不使用conversationCapability创建CN/MC或发消息；server headline来自matching highlights，不是同意证据。当前local恢复用LiveMatchPage，显式提示“匹配不能替代双方独立连接和消息同意”，按钮只导航，写入仍需双方独立服务端流程。真实R1四步CN/MC与撤销后消息404、原V1007LiveConsentTest的match alone/单方拒绝共同核验，没有把Match结果当聊天授权。旧headline可能造成误读是具名legacy展示观察项，没有用改文案或减断言伪造权限完成。

## R1-03：Dart全范围info

固定起点与初始候选的对应测试/pubspec对象相同，独立基线实际复现3info/exit1。本轮只给测试直接使用的**既已锁定crypto3.0.7**增加dev_dependency，lock唯一变化transitive→direct dev，全部版本/包hash不变；超深JSON测试改等价字符串插值，断言不变。没有升级依赖或全项目lint重构。

## 最终实际检查状态

| 检查 | 结果 | 精确口径 |
|---|---|---|
| Flutter普通全量，不传fixture | **793通过/5失败，exit1** | legacy3＋缺同次fixture2；不称PASS |
| Flutter全量，传本次PHP fixture | **821通过/3失败，exit1** | legacy3仍保留，明确可复现 |
| 本轮typed＋两诊断套件 | **36项通过，exit0** | 同次PHP输入，不代表真实业务资格 |
| 全范围Dart analyze | **No issues found，exit0** | 本轮实际全范围运行，原exit1原证保持 |
| 产品lib analyze | **No issues found，exit0** | 单列产品范围，未冒充全套 |
| 相关PHP | **27项/332断言，exit0** | vendor弃用2项保留 |

所有命令、stdout/stderr/exit与流hash见[evidence/r1/index.json](evidence/r1/index.json)。bounded辅助receipt的时间为事后登记而非虚构起止时间；其独立`.exit`与原流保留。runner外层exit0不代替child，standalone PHP输出另实际解析JSON核成功。

## 源码与安装包身份

**R1没有Flutter lib或Android产品源码变化，不重新构建/安装APK。** 两棵Git subtree与初始候选相同：Android `8b5522866720fcb7f5448683e1bcb23b639fdfca`，Flutter lib `03c83a1c4615352c29003f724e8f193fd8603538`。仅Flutter测试/pubspec dev元信息改变；后端已更新到R1源码锚。最初逐文件hash-object受既有CRLF过滤影响的16项假差异原收据保留，最后以Git subtree相同＋无工作区产品diff核定，不把过滤结果误报源变更。

复用原build-07/安装结果：APP构建源码锚 `7f8da6954db8ef994f91e586c8a4f91fa0bc0a4f` / Tree `754b9a65b41ac9393687417836e380effc81c09b`。物理包本轮重新计算hash仍相同：

- APK：`fe3d9556977e5cbd34ec006a67537fd6f41efbc9d2a57e724f5d64932b102765`。
- AAR：`76800ca93d696d8cfb0db87be930bd106927bb26edd45c4c730ec3193957acb5`。

路径仍为原E/packages-final，仅Windows LOCAL_ONLY。R1未声称安装新包或重新完成所有APP流程；沿用原真实APP成功证据，只对PHP通知、消息/媒体权限和指定测试做差异回归。

## 保护、复现和剩余观察

本轮只重启具名0.7容器及loopback服务，未seed/迁移原数据。结束再次核PID/端口归属停止自有PHP/front和容器；保留0.7持久卷/私配。AVD未启动。原0.6容器/卷保持停止未写，原dirty根本轮HEAD/index/status/43项具名hash前后一致；历史105/109项未重验。未读SQL gzip/VHDX、真实账号/生产，没有第三方费用/系统安装。

如Owner以后授权回看，用原RUNBOOK启动0.7容器与新的runtime目录，不seed。R1 recipient12有意禁用、CN4独立ACTIVE rev2、MC3/4 REVOKED rev3；旧token401与通用无导航是预期终态，不重置来制造正例。读原时序/新存储/基线复测证据即可独立审核。诊断fixture确切运行方法见归因文档。

未运行：新APK构建/安装及新APP全流程（产品源未变）、全部PHP/完整历史APP、RTC、完整紫微/西占、生产/备份/真实用户及0.8。剩余3项legacy文案/显示/UNKNOWN导航失败、普通无fixture的2项输入失败显式保留，由Astra结合固定归因证据终裁。候选不自接受、不合并main、不启动后继版本。
